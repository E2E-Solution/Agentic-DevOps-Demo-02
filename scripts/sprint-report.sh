#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — Sprint Report Generator
# =============================================================================
# Generates a sprint status report for the current repository.
# Uses the GitHub CLI to pull issue and PR data.
#
# Usage:
#   sprint-report.sh                    # Default: last 14 days
#   sprint-report.sh --days 7           # Custom period
#   sprint-report.sh --milestone "v2.0" # Filter by milestone
#   sprint-report.sh --repo owner/repo  # Specify repository
# =============================================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Defaults
DAYS=14
MILESTONE=""
REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --days)     DAYS="$2"; shift 2 ;;
        --milestone) MILESTONE="$2"; shift 2 ;;
        --repo)     REPO="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: sprint-report.sh [--days N] [--milestone NAME] [--repo owner/repo]"
            exit 0 ;;
        *)          echo "Unknown option: $1"; exit 1 ;;
    esac
done

SINCE_DATE=$(date -d "-${DAYS} days" +%Y-%m-%d 2>/dev/null || date -v-${DAYS}d +%Y-%m-%d 2>/dev/null)
REPO_FLAG=""
if [ -n "$REPO" ]; then
    REPO_FLAG="--repo $REPO"
fi

# Check prerequisites
if ! command -v gh &>/dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is required. Run: npm install -g gh${NC}"
    exit 1
fi

if ! gh auth status &>/dev/null 2>&1; then
    echo -e "${RED}Error: Not authenticated. Run: gh auth login${NC}"
    exit 1
fi

echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║            📊 Sprint Status Report                  ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BLUE}Period:${NC} Last $DAYS days (since $SINCE_DATE)"
if [ -n "$MILESTONE" ]; then
    echo -e "  ${BLUE}Milestone:${NC} $MILESTONE"
fi
if [ -n "$REPO" ]; then
    echo -e "  ${BLUE}Repository:${NC} $REPO"
fi
echo ""

# ---------------------------------------------------------------------------
# Issues Summary
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Issues ──${NC}"
echo ""

MILESTONE_FLAG=""
if [ -n "$MILESTONE" ]; then
    MILESTONE_FLAG="--milestone $MILESTONE"
fi

# Closed issues in period
CLOSED_ISSUES=$(gh issue list $REPO_FLAG $MILESTONE_FLAG --state closed --search "closed:>=$SINCE_DATE" --limit 500 --json number,title,closedAt,labels,assignees 2>/dev/null || echo "[]")
CLOSED_COUNT=$(echo "$CLOSED_ISSUES" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

# Open issues
OPEN_ISSUES=$(gh issue list $REPO_FLAG $MILESTONE_FLAG --state open --limit 500 --json number,title,createdAt,labels,assignees 2>/dev/null || echo "[]")
OPEN_COUNT=$(echo "$OPEN_ISSUES" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

# New issues in period
NEW_ISSUES=$(gh issue list $REPO_FLAG $MILESTONE_FLAG --state all --search "created:>=$SINCE_DATE" --limit 500 --json number,title,state,createdAt 2>/dev/null || echo "[]")
NEW_COUNT=$(echo "$NEW_ISSUES" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

echo -e "  ${GREEN}✓ Closed:${NC}  $CLOSED_COUNT issues resolved"
echo -e "  ${YELLOW}○ Open:${NC}    $OPEN_COUNT issues remaining"
echo -e "  ${BLUE}+ New:${NC}     $NEW_COUNT issues created in this period"
echo ""

# Show top open issues
if [ "$OPEN_COUNT" -gt 0 ]; then
    echo -e "  ${BOLD}Top Open Issues:${NC}"
    echo "$OPEN_ISSUES" | python3 -c "
import sys, json
issues = json.load(sys.stdin)[:10]
for i in issues:
    labels = ', '.join([l['name'] for l in i.get('labels', [])])
    assignees = ', '.join(['@'+a['login'] for a in i.get('assignees', [])])
    label_str = f' [{labels}]' if labels else ''
    assign_str = f' → {assignees}' if assignees else ' → unassigned'
    print(f'    #{i[\"number\"]} {i[\"title\"]}{label_str}{assign_str}')
" 2>/dev/null || echo "    (Could not parse issues)"
    echo ""
fi

# ---------------------------------------------------------------------------
# Pull Requests Summary
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Pull Requests ──${NC}"
echo ""

# Merged PRs in period
MERGED_PRS=$(gh pr list $REPO_FLAG --state merged --search "merged:>=$SINCE_DATE" --limit 500 --json number,title,mergedAt,author 2>/dev/null || echo "[]")
MERGED_COUNT=$(echo "$MERGED_PRS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

# Open PRs
OPEN_PRS=$(gh pr list $REPO_FLAG --state open --limit 500 --json number,title,createdAt,author,reviewDecision 2>/dev/null || echo "[]")
OPEN_PR_COUNT=$(echo "$OPEN_PRS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

echo -e "  ${GREEN}✓ Merged:${NC}  $MERGED_COUNT pull requests merged"
echo -e "  ${YELLOW}○ Open:${NC}    $OPEN_PR_COUNT pull requests pending"
echo ""

# Show PRs needing attention
if [ "$OPEN_PR_COUNT" -gt 0 ]; then
    echo -e "  ${BOLD}Open PRs Needing Attention:${NC}"
    echo "$OPEN_PRS" | python3 -c "
import sys, json
prs = json.load(sys.stdin)[:10]
for pr in prs:
    author = '@' + pr.get('author', {}).get('login', 'unknown')
    review = pr.get('reviewDecision', 'PENDING')
    status_icon = '🟢' if review == 'APPROVED' else '🟡' if review == 'REVIEW_REQUIRED' else '⚪'
    print(f'    {status_icon} #{pr[\"number\"]} {pr[\"title\"]} by {author} — {review}')
" 2>/dev/null || echo "    (Could not parse PRs)"
    echo ""
fi

# ---------------------------------------------------------------------------
# Velocity Metrics
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Sprint Velocity ──${NC}"
echo ""

if [ "$NEW_COUNT" -gt 0 ] && [ "$CLOSED_COUNT" -gt 0 ]; then
    RATIO=$(python3 -c "print(f'{$CLOSED_COUNT/$NEW_COUNT:.1%}')" 2>/dev/null || echo "N/A")
    echo -e "  ${BLUE}Resolution Rate:${NC}  $RATIO (closed/created)"
fi
echo -e "  ${BLUE}Issues Closed:${NC}    $CLOSED_COUNT in $DAYS days"
echo -e "  ${BLUE}PRs Merged:${NC}       $MERGED_COUNT in $DAYS days"

DAILY_VELOCITY=$(python3 -c "print(f'{$CLOSED_COUNT/$DAYS:.1f}')" 2>/dev/null || echo "N/A")
echo -e "  ${BLUE}Daily Velocity:${NC}   ~$DAILY_VELOCITY issues/day"
echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Report generated $(date '+%Y-%m-%d %H:%M')               ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Tip:${NC} For an AI-powered deep analysis, run:"
echo -e "       ${BOLD}copilot${NC} and ask: \"Analyze the sprint health for this repo\""
echo ""
