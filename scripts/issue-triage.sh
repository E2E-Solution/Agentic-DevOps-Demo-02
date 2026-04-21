#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — AI-Assisted Issue Triage
# =============================================================================
# Helps project managers triage unlabeled or unassigned issues.
# Fetches issues and uses GitHub Copilot CLI for AI-powered suggestions.
#
# Usage:
#   issue-triage.sh                   # Triage unlabeled issues
#   issue-triage.sh --repo owner/repo # Specify repository
#   issue-triage.sh --limit 10        # Limit number of issues
# =============================================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO=""
LIMIT=20

while [[ $# -gt 0 ]]; do
    case $1 in
        --repo)  REPO="$2"; shift 2 ;;
        --limit) LIMIT="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: issue-triage.sh [--repo owner/repo] [--limit N]"
            exit 0 ;;
        *)       echo "Unknown option: $1"; exit 1 ;;
    esac
done

REPO_FLAG=""
if [ -n "$REPO" ]; then
    REPO_FLAG="--repo $REPO"
fi

if ! gh auth status &>/dev/null 2>&1; then
    echo -e "${RED}Error: Not authenticated. Run: gh auth login${NC}"
    exit 1
fi

echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║          🏷️  AI-Assisted Issue Triage               ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# ---------------------------------------------------------------------------
# Fetch issues needing triage
# ---------------------------------------------------------------------------
echo -e "${BLUE}▶${NC} Fetching issues that need triage..."
echo ""

# Get unlabeled issues
UNLABELED=$(gh issue list $REPO_FLAG --state open --search "no:label" --limit "$LIMIT" --json number,title,body,createdAt,author 2>/dev/null || echo "[]")
UNLABELED_COUNT=$(echo "$UNLABELED" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

# Get unassigned issues
UNASSIGNED=$(gh issue list $REPO_FLAG --state open --search "no:assignee" --limit "$LIMIT" --json number,title,body,createdAt,labels 2>/dev/null || echo "[]")
UNASSIGNED_COUNT=$(echo "$UNASSIGNED" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

echo -e "  ${YELLOW}🏷️  Unlabeled issues:${NC}   $UNLABELED_COUNT"
echo -e "  ${YELLOW}👤 Unassigned issues:${NC}  $UNASSIGNED_COUNT"
echo ""

if [ "$UNLABELED_COUNT" -eq 0 ] && [ "$UNASSIGNED_COUNT" -eq 0 ]; then
    echo -e "  ${GREEN}🎉 All issues are labeled and assigned! Nothing to triage.${NC}"
    echo ""
    exit 0
fi

# ---------------------------------------------------------------------------
# Display issues for triage
# ---------------------------------------------------------------------------
if [ "$UNLABELED_COUNT" -gt 0 ]; then
    echo -e "${BOLD}── Unlabeled Issues (Need Labels) ──${NC}"
    echo ""
    echo "$UNLABELED" | python3 -c "
import sys, json
issues = json.load(sys.stdin)
for i in issues:
    author = '@' + i.get('author', {}).get('login', 'unknown')
    body_preview = (i.get('body', '') or '')[:100].replace('\n', ' ')
    if len(i.get('body', '') or '') > 100:
        body_preview += '...'
    print(f'  #{i[\"number\"]} {i[\"title\"]}')
    print(f'       By {author} | {body_preview}')
    print()
" 2>/dev/null
fi

if [ "$UNASSIGNED_COUNT" -gt 0 ]; then
    echo -e "${BOLD}── Unassigned Issues (Need Owners) ──${NC}"
    echo ""
    echo "$UNASSIGNED" | python3 -c "
import sys, json
issues = json.load(sys.stdin)
for i in issues:
    labels = ', '.join([l['name'] for l in i.get('labels', [])])
    label_str = f' [{labels}]' if labels else ' [no labels]'
    print(f'  #{i[\"number\"]} {i[\"title\"]}{label_str}')
" 2>/dev/null
    echo ""
fi

# ---------------------------------------------------------------------------
# AI-Powered Triage Suggestions
# ---------------------------------------------------------------------------
echo -e "${BOLD}── AI-Powered Triage ──${NC}"
echo ""
echo -e "  To get AI suggestions for triaging these issues, start"
echo -e "  GitHub Copilot CLI and use these prompts:"
echo ""
echo -e "  ${CYAN}For labeling:${NC}"
echo -e "    ${BOLD}copilot${NC}"
echo -e "    > \"Look at the unlabeled issues in this repo and suggest"
echo -e "      appropriate labels (bug, enhancement, documentation, etc.)"
echo -e "      for each one based on the issue title and description\""
echo ""
echo -e "  ${CYAN}For assignment:${NC}"
echo -e "    > \"Based on recent commit activity and PR history, suggest"
echo -e "      who should be assigned to each unassigned issue\""
echo ""
echo -e "  ${CYAN}For prioritization:${NC}"
echo -e "    > \"Review the open issues and suggest a priority order"
echo -e "      based on severity, age, and dependencies\""
echo ""

# ---------------------------------------------------------------------------
# Quick Actions
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Quick Actions ──${NC}"
echo ""
echo -e "  ${GREEN}Label an issue:${NC}"
echo -e "    gh issue edit <NUMBER> --add-label \"bug,high-priority\""
echo ""
echo -e "  ${GREEN}Assign an issue:${NC}"
echo -e "    gh issue edit <NUMBER> --add-assignee @username"
echo ""
echo -e "  ${GREEN}Add to milestone:${NC}"
echo -e "    gh issue edit <NUMBER> --milestone \"Sprint 5\""
echo ""
echo -e "  ${CYAN}Tip:${NC} Or just tell Copilot CLI what to do in plain English!"
echo ""
