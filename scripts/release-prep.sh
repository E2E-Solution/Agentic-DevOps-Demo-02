#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — Release Preparation Helper
# =============================================================================
# Shows unreleased commits, merged PRs since last release, open milestone
# issues, and suggests Copilot prompts for generating changelogs.
#
# Usage:
#   release-prep.sh                        # Auto-detect latest tag
#   release-prep.sh --tag v1.2.0           # Compare against specific tag
#   release-prep.sh --repo owner/repo      # Specify repository
#   release-prep.sh --help                 # Show help
#
# Examples:
#   release-prep.sh
#   release-prep.sh --tag v2.0.0
#   release-prep.sh --repo my-org/my-app --tag v1.5.0
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# Defaults
TAG=""
REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tag)  TAG="$2"; shift 2 ;;
        --repo) REPO="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: release-prep.sh [--tag TAG] [--repo owner/repo]"
            echo ""
            echo "Options:"
            echo "  --tag TAG           Compare against a specific tag (default: latest)"
            echo "  --repo owner/repo   Specify the repository (default: current repo)"
            echo "  --help, -h          Show this help message"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

REPO_FLAG=""
if [ -n "$REPO" ]; then
    REPO_FLAG="--repo $REPO"
fi

require_gh_auth
require_repo_context "$REPO"

print_header "🚀  Release Preparation"

# Resolve repo name
if [ -n "$REPO" ]; then
    REPO_NAME="$REPO"
else
    REPO_NAME=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || echo "")
    if [ -z "$REPO_NAME" ]; then
        log_fail "Could not determine repository name."
        exit 1
    fi
fi
REPO_OWNER="${REPO_NAME%%/*}"
REPO_REPO="${REPO_NAME##*/}"

# ---------------------------------------------------------------------------
# Find Latest Release / Tag
# ---------------------------------------------------------------------------
print_section "Latest Release"

if [ -z "$TAG" ]; then
    LATEST_RELEASE=$(gh api "repos/$REPO_OWNER/$REPO_REPO/releases/latest" --jq '.tag_name' 2>/dev/null || echo "")
    if [ -n "$LATEST_RELEASE" ]; then
        TAG="$LATEST_RELEASE"
        log_ok "Latest release: $TAG"
    else
        # Fall back to latest tag
        TAG=$(gh api "repos/$REPO_OWNER/$REPO_REPO/tags?per_page=1" --jq '.[0].name' 2>/dev/null || echo "")
        if [ -n "$TAG" ]; then
            log_ok "Latest tag (no release): $TAG"
        else
            log_warn "No releases or tags found — showing all recent activity."
        fi
    fi
else
    log_ok "Comparing against tag: $TAG"
fi

# Get release date for filtering
RELEASE_DATE=""
if [ -n "$TAG" ]; then
    RELEASE_DATE=$(gh api "repos/$REPO_OWNER/$REPO_REPO/git/ref/tags/$TAG" --jq '.object.sha' 2>/dev/null | \
        xargs -I{} gh api "repos/$REPO_OWNER/$REPO_REPO/git/commits/{}" --jq '.committer.date' 2>/dev/null || echo "")
    if [ -z "$RELEASE_DATE" ]; then
        # Try annotated tag
        TAG_SHA=$(gh api "repos/$REPO_OWNER/$REPO_REPO/git/ref/tags/$TAG" --jq '.object.sha' 2>/dev/null || echo "")
        if [ -n "$TAG_SHA" ]; then
            RELEASE_DATE=$(gh api "repos/$REPO_OWNER/$REPO_REPO/git/tags/$TAG_SHA" --jq '.tagger.date' 2>/dev/null || echo "")
        fi
    fi
    if [ -n "$RELEASE_DATE" ]; then
        echo -e "  ${BLUE}Release Date:${NC} ${RELEASE_DATE:0:10}"
    fi
fi
echo ""

# ---------------------------------------------------------------------------
# Unreleased Commits
# ---------------------------------------------------------------------------
print_section "Unreleased Commits"

DEFAULT_BRANCH=$(gh repo view $REPO_FLAG --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || echo "main")

if [ -n "$TAG" ]; then
    COMMITS=$(gh api "repos/$REPO_OWNER/$REPO_REPO/compare/$TAG...$DEFAULT_BRANCH" --jq '.commits' 2>/dev/null || echo "[]")
    AHEAD=$(echo "$COMMITS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
else
    # No tag — show recent commits
    COMMITS=$(gh api "repos/$REPO_OWNER/$REPO_REPO/commits?sha=$DEFAULT_BRANCH&per_page=30" 2>/dev/null || echo "[]")
    AHEAD=$(echo "$COMMITS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
fi

if [ "$AHEAD" -eq 0 ]; then
    log_ok "No unreleased commits — $DEFAULT_BRANCH is up to date with $TAG."
else
    if [ -n "$TAG" ]; then
        echo -e "  ${BLUE}$AHEAD commits${NC} on $DEFAULT_BRANCH since $TAG"
    else
        echo -e "  ${BLUE}Showing last $AHEAD commits${NC} on $DEFAULT_BRANCH"
    fi
    echo ""

    echo "$COMMITS" | python3 -c "
import sys, json
commits = json.load(sys.stdin)
for c in commits[:20]:
    if isinstance(c, dict):
        sha = c.get('sha', '?')[:7]
        msg = c.get('commit', {}).get('message', '').split('\n')[0][:70]
        author = c.get('commit', {}).get('author', {}).get('name', 'unknown')
        date = c.get('commit', {}).get('author', {}).get('date', '')[:10]
        print(f'    {sha} {msg}')
        print(f'           {author} on {date}')
total = len(commits)
if total > 20:
    print(f'    ... and {total - 20} more commits')
" 2>/dev/null || echo "  (Could not parse commits)"
fi
echo ""

# ---------------------------------------------------------------------------
# Merged PRs Since Last Release
# ---------------------------------------------------------------------------
print_section "Merged PRs Since Last Release"

if [ -n "$RELEASE_DATE" ]; then
    MERGED_PRS=$(gh pr list $REPO_FLAG --state merged --search "merged:>=${RELEASE_DATE:0:10}" --limit 50 --json number,title,author,mergedAt,labels 2>/dev/null || echo "[]")
else
    # No release date — show recently merged
    SINCE_FALLBACK=$(date -d "-30 days" +%Y-%m-%d 2>/dev/null || date -v-30d +%Y-%m-%d 2>/dev/null || echo "")
    if [ -n "$SINCE_FALLBACK" ]; then
        MERGED_PRS=$(gh pr list $REPO_FLAG --state merged --search "merged:>=$SINCE_FALLBACK" --limit 50 --json number,title,author,mergedAt,labels 2>/dev/null || echo "[]")
    else
        MERGED_PRS=$(gh pr list $REPO_FLAG --state merged --limit 20 --json number,title,author,mergedAt,labels 2>/dev/null || echo "[]")
    fi
fi

MERGED_COUNT=$(echo "$MERGED_PRS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

if [ "$MERGED_COUNT" -eq 0 ]; then
    echo "  No merged PRs found in this period."
else
    echo -e "  ${GREEN}$MERGED_COUNT merged PR(s):${NC}"
    echo ""
    echo "$MERGED_PRS" | python3 -c "
import sys, json

prs = json.load(sys.stdin)

# Group by label category
features = []
fixes = []
others = []

for pr in prs:
    labels = [l['name'].lower() for l in pr.get('labels', [])]
    if any(l in labels for l in ['bug', 'fix', 'bugfix', 'hotfix']):
        fixes.append(pr)
    elif any(l in labels for l in ['enhancement', 'feature', 'feat']):
        features.append(pr)
    else:
        others.append(pr)

def print_prs(prs, category):
    if prs:
        print(f'  {category}:')
        for pr in prs:
            num = pr.get('number', '?')
            title = pr.get('title', '')[:65]
            author = '@' + pr.get('author', {}).get('login', 'unknown')
            print(f'    • #{num} {title} ({author})')
        print()

print_prs(features, '✨ Features / Enhancements')
print_prs(fixes, '🐛 Bug Fixes')
print_prs(others, '📝 Other Changes')
" 2>/dev/null || echo "  (Could not parse merged PRs)"
fi
echo ""

# ---------------------------------------------------------------------------
# Open Milestone Issues
# ---------------------------------------------------------------------------
print_section "Open Milestone Issues"

MILESTONES=$(gh api "repos/$REPO_OWNER/$REPO_REPO/milestones?state=open&per_page=5" 2>/dev/null || echo "[]")
MS_COUNT=$(echo "$MILESTONES" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

if [ "$MS_COUNT" -eq 0 ]; then
    echo "  No open milestones found."
else
    echo "$MILESTONES" | python3 -c "
import sys, json
milestones = json.load(sys.stdin)
for ms in milestones:
    title = ms.get('title', '?')
    open_issues = ms.get('open_issues', 0)
    closed_issues = ms.get('closed_issues', 0)
    total = open_issues + closed_issues
    due = ms.get('due_on', '')
    due_str = f' (due {due[:10]})' if due else ''
    pct = int(closed_issues / total * 100) if total > 0 else 0

    bar_len = 20
    filled = int(bar_len * pct / 100)
    bar = '█' * filled + '░' * (bar_len - filled)

    print(f'  📌 {title}{due_str}')
    print(f'     [{bar}] {pct}% — {closed_issues}/{total} issues closed, {open_issues} remaining')
    print()
" 2>/dev/null || echo "  (Could not parse milestones)"

    # Show open issues in the first milestone
    FIRST_MS=$(echo "$MILESTONES" | python3 -c "import sys,json; print(json.load(sys.stdin)[0].get('number',''))" 2>/dev/null || echo "")
    FIRST_MS_TITLE=$(echo "$MILESTONES" | python3 -c "import sys,json; print(json.load(sys.stdin)[0].get('title',''))" 2>/dev/null || echo "")

    if [ -n "$FIRST_MS" ]; then
        MS_ISSUES=$(gh issue list $REPO_FLAG --milestone "$FIRST_MS_TITLE" --state open --limit 15 --json number,title,labels,assignees 2>/dev/null || echo "[]")
        MS_ISSUE_COUNT=$(echo "$MS_ISSUES" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

        if [ "$MS_ISSUE_COUNT" -gt 0 ]; then
            echo -e "  ${BOLD}Open issues in \"$FIRST_MS_TITLE\":${NC}"
            echo "$MS_ISSUES" | python3 -c "
import sys, json
issues = json.load(sys.stdin)
for i in issues:
    num = i.get('number', '?')
    title = i.get('title', '')[:60]
    assignees = ', '.join(['@'+a['login'] for a in i.get('assignees', [])])
    assign_str = assignees if assignees else 'unassigned'
    print(f'    #{num} {title} → {assign_str}')
" 2>/dev/null || echo "    (Could not parse issues)"
            echo ""
        fi
    fi
fi
echo ""

# ---------------------------------------------------------------------------
# Release Checklist
# ---------------------------------------------------------------------------
print_section "Release Checklist"

echo -e "  ${CYAN}☐${NC} All milestone issues resolved or deferred"
echo -e "  ${CYAN}☐${NC} CI passing on $DEFAULT_BRANCH"
echo -e "  ${CYAN}☐${NC} Changelog / release notes drafted"
echo -e "  ${CYAN}☐${NC} Version bumped in relevant files"
echo -e "  ${CYAN}☐${NC} Final review of unreleased changes"
echo ""

# ---------------------------------------------------------------------------
# Suggested Copilot Prompts
# ---------------------------------------------------------------------------
print_section "Suggested Copilot Prompts"

echo -e "  Generate release artifacts with ${BOLD}copilot${NC}:"
echo ""
if [ -n "$TAG" ]; then
    echo -e "  ${CYAN}1.${NC} \"Generate a changelog for all changes since $TAG\""
    echo -e "  ${CYAN}2.${NC} \"Write release notes summarizing PRs merged since $TAG\""
else
    echo -e "  ${CYAN}1.${NC} \"Generate a changelog from recent commits on $DEFAULT_BRANCH\""
    echo -e "  ${CYAN}2.${NC} \"Write release notes summarizing recently merged PRs\""
fi
echo -e "  ${CYAN}3.${NC} \"Check if there are any breaking changes in the unreleased commits\""
echo -e "  ${CYAN}4.${NC} \"Draft a GitHub release description for the next version\""
echo ""

echo -e "  Create the release:"
echo -e "    ${BOLD}gh release create <TAG> --generate-notes${NC}"
echo ""

print_tip "Use ${BOLD}gh release create --generate-notes${NC} for auto-generated release notes from merged PRs."
echo ""
