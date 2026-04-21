#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — Pull Request Activity Summary
# =============================================================================
# Generates a summary of PR activity for project managers.
#
# Usage:
#   pr-summary.sh                    # Default: last 7 days
#   pr-summary.sh --days 14          # Custom period
#   pr-summary.sh --repo owner/repo  # Specify repository
# =============================================================================

BOLD='\033[1m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DAYS=7
REPO=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --days) DAYS="$2"; shift 2 ;;
        --repo) REPO="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: pr-summary.sh [--days N] [--repo owner/repo]"
            exit 0 ;;
        *)      echo "Unknown option: $1"; exit 1 ;;
    esac
done

SINCE_DATE=$(date -d "-${DAYS} days" +%Y-%m-%d 2>/dev/null || date -v-${DAYS}d +%Y-%m-%d 2>/dev/null)
REPO_FLAG=""
if [ -n "$REPO" ]; then
    REPO_FLAG="--repo $REPO"
fi

if ! gh auth status &>/dev/null 2>&1; then
    echo -e "${RED}Error: Not authenticated. Run: gh auth login${NC}"
    exit 1
fi

echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║           🔀 Pull Request Activity Summary          ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BLUE}Period:${NC} Last $DAYS days (since $SINCE_DATE)"
if [ -n "$REPO" ]; then
    echo -e "  ${BLUE}Repository:${NC} $REPO"
fi
echo ""

# ---------------------------------------------------------------------------
# Open PRs
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Open Pull Requests ──${NC}"
echo ""

OPEN_PRS=$(gh pr list $REPO_FLAG --state open --limit 100 --json number,title,author,createdAt,reviewDecision,isDraft,headRefName,additions,deletions,changedFiles 2>/dev/null || echo "[]")
OPEN_COUNT=$(echo "$OPEN_PRS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

echo -e "  Total open: ${BOLD}$OPEN_COUNT${NC}"
echo ""

if [ "$OPEN_COUNT" -gt 0 ]; then
    echo "$OPEN_PRS" | python3 -c "
import sys, json
from datetime import datetime, timezone

prs = json.load(sys.stdin)
now = datetime.now(timezone.utc)

# Categorize
needs_review = []
approved = []
drafts = []
stale = []

for pr in prs:
    created = datetime.fromisoformat(pr['createdAt'].replace('Z', '+00:00'))
    age_days = (now - created).days
    pr['age_days'] = age_days

    if pr.get('isDraft', False):
        drafts.append(pr)
    elif pr.get('reviewDecision') == 'APPROVED':
        approved.append(pr)
    else:
        needs_review.append(pr)

    if age_days > 7 and not pr.get('isDraft', False):
        stale.append(pr)

# Print categories
if needs_review:
    print('  🟡 Needs Review:')
    for pr in needs_review[:10]:
        author = '@' + pr.get('author', {}).get('login', 'unknown')
        print(f'    #{pr[\"number\"]} {pr[\"title\"]}')
        print(f'         By {author} | {pr[\"age_days\"]}d old | +{pr.get(\"additions\",0)}/-{pr.get(\"deletions\",0)} in {pr.get(\"changedFiles\",0)} files')
    print()

if approved:
    print('  🟢 Approved (ready to merge):')
    for pr in approved[:10]:
        author = '@' + pr.get('author', {}).get('login', 'unknown')
        print(f'    #{pr[\"number\"]} {pr[\"title\"]} by {author}')
    print()

if drafts:
    print(f'  ⚪ Drafts: {len(drafts)} draft PR(s)')
    print()

if stale:
    print('  🔴 Stale PRs (> 7 days old, not draft):')
    for pr in stale[:5]:
        author = '@' + pr.get('author', {}).get('login', 'unknown')
        print(f'    #{pr[\"number\"]} {pr[\"title\"]} by {author} — {pr[\"age_days\"]} days old')
    print()
" 2>/dev/null
fi

# ---------------------------------------------------------------------------
# Recently Merged
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Recently Merged ──${NC}"
echo ""

MERGED_PRS=$(gh pr list $REPO_FLAG --state merged --search "merged:>=$SINCE_DATE" --limit 100 --json number,title,author,mergedAt,additions,deletions,changedFiles 2>/dev/null || echo "[]")
MERGED_COUNT=$(echo "$MERGED_PRS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

echo -e "  Merged in last $DAYS days: ${BOLD}$MERGED_COUNT${NC}"
echo ""

if [ "$MERGED_COUNT" -gt 0 ]; then
    echo "$MERGED_PRS" | python3 -c "
import sys, json
prs = json.load(sys.stdin)[:15]

total_additions = sum(pr.get('additions', 0) for pr in prs)
total_deletions = sum(pr.get('deletions', 0) for pr in prs)
total_files = sum(pr.get('changedFiles', 0) for pr in prs)

for pr in prs:
    author = '@' + pr.get('author', {}).get('login', 'unknown')
    print(f'  ✓ #{pr[\"number\"]} {pr[\"title\"]}')
    print(f'       By {author} | +{pr.get(\"additions\",0)}/-{pr.get(\"deletions\",0)}')

print()
print(f'  📈 Total changes: +{total_additions}/-{total_deletions} across {total_files} files')
" 2>/dev/null
    echo ""
fi

# ---------------------------------------------------------------------------
# Review Bottlenecks
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Insights ──${NC}"
echo ""

echo "$OPEN_PRS" | python3 -c "
import sys, json
from datetime import datetime, timezone

prs = json.load(sys.stdin)
if not prs:
    print('  No open PRs — great work keeping things clean!')
    sys.exit()

now = datetime.now(timezone.utc)
ages = []
for pr in prs:
    created = datetime.fromisoformat(pr['createdAt'].replace('Z', '+00:00'))
    ages.append((now - created).days)

avg_age = sum(ages) / len(ages)
max_age = max(ages)
needs_review = sum(1 for pr in prs if pr.get('reviewDecision') not in ('APPROVED',) and not pr.get('isDraft', False))

print(f'  Average PR age:      {avg_age:.0f} days')
print(f'  Oldest open PR:      {max_age} days')
print(f'  Awaiting review:     {needs_review}')
print()

if needs_review > 5:
    print('  ⚠️  High number of PRs awaiting review — consider a review sprint')
elif avg_age > 5:
    print('  ⚠️  Average PR age is high — PRs may be getting stale')
else:
    print('  ✅ PR flow looks healthy!')
" 2>/dev/null

echo ""
echo -e "  ${CYAN}Tip:${NC} For deeper analysis, ask Copilot CLI:"
echo -e "       \"Which PRs have been waiting longest for review and who could review them?\""
echo ""
