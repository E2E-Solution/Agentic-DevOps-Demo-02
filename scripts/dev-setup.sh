#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — Developer Environment Onboarding
# =============================================================================
# Checks prerequisites, shows repo info, and helps new developers get started.
#
# Usage:
#   dev-setup.sh                    # Auto-detect current repo
#   dev-setup.sh --repo owner/repo  # Specify repository
#   dev-setup.sh --help             # Show help
#
# Examples:
#   dev-setup.sh
#   dev-setup.sh --repo my-org/my-app
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# Defaults
REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --repo)  REPO="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: dev-setup.sh [--repo owner/repo]"
            echo ""
            echo "Options:"
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

# ---------------------------------------------------------------------------
# Prerequisite Checks
# ---------------------------------------------------------------------------
print_header "🛠  Developer Environment Setup"

print_section "Prerequisites"

check_tool() {
    local name="$1"
    local cmd="$2"
    if command -v "$cmd" &>/dev/null; then
        local version
        version=$("$cmd" --version 2>&1 | head -1)
        log_ok "$name — $version"
    else
        log_warn "$name — not installed"
    fi
}

check_tool "Git" git
check_tool "GitHub CLI" gh
check_tool "Node.js" node
check_tool "Python" python3
check_tool "npm" npm
check_tool "Docker" docker
echo ""

# Check gh auth
if gh auth status &>/dev/null 2>&1; then
    GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
    log_ok "GitHub CLI authenticated as @$GH_USER"
else
    log_fail "GitHub CLI not authenticated — run: gh auth login"
    echo ""
    print_tip "Run ${BOLD}gh auth login${NC} to authenticate with GitHub."
    exit 1
fi
echo ""

require_repo_context "$REPO"

# ---------------------------------------------------------------------------
# Repository Info
# ---------------------------------------------------------------------------
print_section "Repository Info"

REPO_INFO=$(gh repo view $REPO_FLAG --json name,owner,defaultBranchRef,description,url,diskUsage,pushedAt 2>/dev/null || echo "{}")

REPO_NAME=$(echo "$REPO_INFO" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('owner',{}).get('login','?')+'/'+d.get('name','?'))" 2>/dev/null || echo "unknown")
REPO_DESC=$(echo "$REPO_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('description','') or 'No description')" 2>/dev/null || echo "")
DEFAULT_BRANCH=$(echo "$REPO_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('defaultBranchRef',{}).get('name','main'))" 2>/dev/null || echo "main")
REPO_URL=$(echo "$REPO_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('url',''))" 2>/dev/null || echo "")
LAST_PUSH=$(echo "$REPO_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('pushedAt','unknown')[:10])" 2>/dev/null || echo "unknown")

echo -e "  ${BLUE}Repository:${NC}      $REPO_NAME"
echo -e "  ${BLUE}Description:${NC}     $REPO_DESC"
echo -e "  ${BLUE}Default Branch:${NC}  $DEFAULT_BRANCH"
echo -e "  ${BLUE}URL:${NC}             $REPO_URL"
echo -e "  ${BLUE}Last Push:${NC}       $LAST_PUSH"
echo ""

# ---------------------------------------------------------------------------
# Branches
# ---------------------------------------------------------------------------
print_section "Recent Branches"

BRANCHES=$(gh api "repos/${REPO_NAME}/branches?per_page=10&sort=updated" 2>/dev/null || echo "[]")
echo "$BRANCHES" | python3 -c "
import sys, json
branches = json.load(sys.stdin)
if not branches:
    print('  No branches found.')
else:
    for b in branches[:10]:
        name = b.get('name', '?')
        protected = ' 🔒' if b.get('protected', False) else ''
        print(f'    • {name}{protected}')
" 2>/dev/null || echo "  (Could not list branches)"
echo ""

# ---------------------------------------------------------------------------
# Recent Pull Requests
# ---------------------------------------------------------------------------
print_section "Recent Open Pull Requests"

OPEN_PRS=$(gh pr list $REPO_FLAG --state open --limit 10 --json number,title,author,createdAt,reviewDecision 2>/dev/null || echo "[]")
PR_COUNT=$(echo "$OPEN_PRS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

if [ "$PR_COUNT" -gt 0 ]; then
    echo "$OPEN_PRS" | python3 -c "
import sys, json
prs = json.load(sys.stdin)
for pr in prs:
    num = pr.get('number', '?')
    title = pr.get('title', '')
    author = '@' + pr.get('author', {}).get('login', 'unknown')
    review = pr.get('reviewDecision', '') or 'PENDING'
    icon = '🟢' if review == 'APPROVED' else '🟡' if review == 'REVIEW_REQUIRED' else '⚪'
    print(f'  {icon} #{num} {title}  ({author}, {review})')
" 2>/dev/null || echo "  (Could not parse PRs)"
else
    echo "  No open pull requests."
fi
echo ""

# ---------------------------------------------------------------------------
# Issues Assigned to Current User
# ---------------------------------------------------------------------------
print_section "Your Open Issues"

MY_ISSUES=$(gh issue list $REPO_FLAG --assignee "@me" --state open --limit 10 --json number,title,labels,createdAt 2>/dev/null || echo "[]")
MY_ISSUE_COUNT=$(echo "$MY_ISSUES" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

if [ "$MY_ISSUE_COUNT" -gt 0 ]; then
    echo "$MY_ISSUES" | python3 -c "
import sys, json
issues = json.load(sys.stdin)
for i in issues:
    num = i.get('number', '?')
    title = i.get('title', '')
    labels = ', '.join([l['name'] for l in i.get('labels', [])])
    label_str = f' [{labels}]' if labels else ''
    print(f'    #{num} {title}{label_str}')
" 2>/dev/null || echo "  (Could not parse issues)"
else
    echo "  No open issues assigned to you."
fi
echo ""

# ---------------------------------------------------------------------------
# Next Steps
# ---------------------------------------------------------------------------
print_section "Suggested Next Steps"

echo -e "  1. ${BOLD}Start coding:${NC} Create a branch and open a PR"
echo -e "       git checkout -b feature/my-change"
echo ""
echo -e "  2. ${BOLD}Review PRs:${NC} Check open pull requests"
echo -e "       gh pr list --state open"
echo ""
echo -e "  3. ${BOLD}Use Copilot CLI:${NC} Get AI assistance in the terminal"
echo -e "       copilot \"Explain the architecture of this repo\""
echo ""
echo -e "  4. ${BOLD}Run code review:${NC} Use the code review helper"
echo -e "       ./scripts/code-review.sh"
echo ""

print_tip "Run ${BOLD}./scripts/health-check.sh${NC} to verify your full environment."
echo ""
