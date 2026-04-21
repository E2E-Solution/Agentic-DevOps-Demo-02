#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — AI-Assisted Code Review Helper
# =============================================================================
# Helps review pull requests by showing diff stats, review status, CI status,
# and suggesting Copilot prompts for deeper analysis.
#
# Usage:
#   code-review.sh                     # List open PRs needing review
#   code-review.sh --pr 42             # Review a specific PR
#   code-review.sh --repo owner/repo   # Specify repository
#   code-review.sh --help              # Show help
#
# Examples:
#   code-review.sh --pr 15
#   code-review.sh --pr 15 --repo my-org/my-app
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# Defaults
PR_NUMBER=""
REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --pr)   PR_NUMBER="$2"; shift 2 ;;
        --repo) REPO="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: code-review.sh [--pr NUMBER] [--repo owner/repo]"
            echo ""
            echo "Options:"
            echo "  --pr NUMBER         Review a specific pull request"
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

print_header "🔍  Code Review Helper"

# ---------------------------------------------------------------------------
# Single PR Review Mode
# ---------------------------------------------------------------------------
if [ -n "$PR_NUMBER" ]; then
    log_step "Fetching PR #$PR_NUMBER details..."
    echo ""

    PR_DATA=$(gh pr view $REPO_FLAG "$PR_NUMBER" --json number,title,author,state,body,createdAt,additions,deletions,changedFiles,baseRefName,headRefName,reviewDecision,reviews,statusCheckRollup,labels,mergeable,isDraft 2>/dev/null)

    if [ -z "$PR_DATA" ] || [ "$PR_DATA" = "null" ]; then
        log_fail "Could not fetch PR #$PR_NUMBER. Check the PR number and repo."
        exit 1
    fi

    # --- Overview ---
    print_section "PR Overview"

    echo "$PR_DATA" | python3 -c "
import sys, json
pr = json.load(sys.stdin)
author = '@' + pr.get('author', {}).get('login', 'unknown')
state = pr.get('state', 'UNKNOWN')
draft = ' (DRAFT)' if pr.get('isDraft', False) else ''
review = pr.get('reviewDecision', '') or 'PENDING'
base = pr.get('baseRefName', '?')
head = pr.get('headRefName', '?')
mergeable = pr.get('mergeable', 'UNKNOWN')

print(f'  Title:     #{pr[\"number\"]} {pr[\"title\"]}')
print(f'  Author:    {author}')
print(f'  State:     {state}{draft}')
print(f'  Branch:    {head} → {base}')
print(f'  Review:    {review}')
print(f'  Mergeable: {mergeable}')
" 2>/dev/null || echo "  (Could not parse PR data)"
    echo ""

    # --- Diff Stats ---
    print_section "Diff Stats"

    echo "$PR_DATA" | python3 -c "
import sys, json
pr = json.load(sys.stdin)
adds = pr.get('additions', 0)
dels = pr.get('deletions', 0)
files = pr.get('changedFiles', 0)
total = adds + dels

risk = '🟢 Small'
if total > 500:
    risk = '🔴 Large — consider splitting this PR'
elif total > 200:
    risk = '🟡 Medium — review carefully'

print(f'  Files Changed:  {files}')
print(f'  Additions:      +{adds}')
print(f'  Deletions:      -{dels}')
print(f'  Total Changes:  {total} lines')
print(f'  Risk Level:     {risk}')
" 2>/dev/null || echo "  (Could not parse diff stats)"
    echo ""

    # --- Files Changed ---
    print_section "Files Changed"

    FILES=$(gh pr diff $REPO_FLAG "$PR_NUMBER" --stat 2>/dev/null || echo "")
    if [ -n "$FILES" ]; then
        echo "$FILES" | head -20 | sed 's/^/  /'
        FILE_COUNT=$(echo "$FILES" | wc -l)
        if [ "$FILE_COUNT" -gt 20 ]; then
            echo -e "  ${YELLOW}... and $((FILE_COUNT - 20)) more files${NC}"
        fi
    else
        echo "  (Could not fetch diff stats)"
    fi
    echo ""

    # --- Review Status ---
    print_section "Review Status"

    echo "$PR_DATA" | python3 -c "
import sys, json
pr = json.load(sys.stdin)
reviews = pr.get('reviews', [])
if not reviews:
    print('  No reviews yet.')
else:
    seen = {}
    for r in reviews:
        author = r.get('author', {}).get('login', 'unknown')
        state = r.get('state', 'PENDING')
        seen[author] = state
    for author, state in seen.items():
        icon = '✅' if state == 'APPROVED' else '🔄' if state == 'CHANGES_REQUESTED' else '💬' if state == 'COMMENTED' else '⏳'
        print(f'  {icon} @{author} — {state}')
" 2>/dev/null || echo "  (Could not parse reviews)"
    echo ""

    # --- CI Status ---
    print_section "CI / Check Status"

    echo "$PR_DATA" | python3 -c "
import sys, json
pr = json.load(sys.stdin)
checks = pr.get('statusCheckRollup', [])
if not checks:
    print('  No CI checks found.')
else:
    for c in checks:
        name = c.get('name', c.get('context', 'unknown'))
        status = c.get('conclusion', c.get('state', 'PENDING')) or 'IN_PROGRESS'
        icon = '✅' if status in ('SUCCESS', 'success') else '❌' if status in ('FAILURE', 'failure', 'ERROR', 'error') else '🔄'
        print(f'  {icon} {name} — {status}')
" 2>/dev/null || echo "  (Could not parse CI status)"
    echo ""

    # --- Copilot Prompts ---
    print_section "Suggested Copilot Prompts"

    echo -e "  Try these with ${BOLD}copilot${NC} for deeper analysis:"
    echo ""
    echo -e "  ${CYAN}1.${NC} \"Review PR #$PR_NUMBER for bugs, security issues, and code quality\""
    echo -e "  ${CYAN}2.${NC} \"Summarize the changes in PR #$PR_NUMBER in plain language\""
    echo -e "  ${CYAN}3.${NC} \"Check if PR #$PR_NUMBER has adequate test coverage\""
    echo -e "  ${CYAN}4.${NC} \"Suggest improvements for the code in PR #$PR_NUMBER\""
    echo ""

# ---------------------------------------------------------------------------
# List PRs Needing Review
# ---------------------------------------------------------------------------
else
    log_step "Finding PRs that need review..."
    echo ""

    OPEN_PRS=$(gh pr list $REPO_FLAG --state open --limit 50 --json number,title,author,createdAt,additions,deletions,changedFiles,reviewDecision,statusCheckRollup,isDraft,labels 2>/dev/null || echo "[]")
    PR_COUNT=$(echo "$OPEN_PRS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

    if [ "$PR_COUNT" -eq 0 ]; then
        log_ok "No open pull requests — nothing to review!"
        echo ""
        exit 0
    fi

    print_section "Open PRs Needing Review ($PR_COUNT total)"

    echo "$OPEN_PRS" | python3 -c "
import sys, json
from datetime import datetime, timezone

prs = json.load(sys.stdin)

# Sort by creation date (oldest first)
prs.sort(key=lambda p: p.get('createdAt', ''))

for pr in prs:
    num = pr.get('number', '?')
    title = pr.get('title', '')[:60]
    author = '@' + pr.get('author', {}).get('login', 'unknown')
    adds = pr.get('additions', 0)
    dels = pr.get('deletions', 0)
    total = adds + dels
    draft = pr.get('isDraft', False)
    review = pr.get('reviewDecision', '') or 'PENDING'

    # Age calculation
    created = pr.get('createdAt', '')
    age = ''
    if created:
        try:
            dt = datetime.fromisoformat(created.replace('Z', '+00:00'))
            days = (datetime.now(timezone.utc) - dt).days
            age = f'{days}d ago'
        except:
            age = ''

    # Risk indicator
    risk = '🟢'
    if total > 500:
        risk = '🔴'
    elif total > 200:
        risk = '🟡'

    # Review indicator
    review_icon = '✅' if review == 'APPROVED' else '🔄' if review == 'CHANGES_REQUESTED' else '⏳'

    # CI status
    checks = pr.get('statusCheckRollup', [])
    ci_ok = all(c.get('conclusion', '') in ('SUCCESS', 'success') for c in checks) if checks else False
    ci_icon = '✅' if ci_ok else '❌' if checks else '⚪'

    draft_str = ' [DRAFT]' if draft else ''
    print(f'  {risk} #{num:<5} {title:<60}{draft_str}')
    print(f'         {author:<20} {age:<10} ±{total:<6} Review: {review_icon} {review:<20} CI: {ci_icon}')
    print()
" 2>/dev/null || echo "  (Could not parse PR list)"

    # --- Summary ---
    print_section "Quick Actions"

    echo -e "  Review a specific PR:"
    echo -e "    ${BOLD}./scripts/code-review.sh --pr <NUMBER>${NC}"
    echo ""
    echo -e "  Checkout a PR locally:"
    echo -e "    ${BOLD}gh pr checkout <NUMBER>${NC}"
    echo ""

    print_tip "Large PRs (🔴) are riskier — consider reviewing them first or asking the author to split them."
    echo ""
fi
