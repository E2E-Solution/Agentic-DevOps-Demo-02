#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — Open Bug Summary
# =============================================================================
# Summarizes open bugs by severity, age, and assignee. Highlights bugs that
# need attention (no assignee, no severity label, or aging).
#
# Usage:
#   bug-tracker.sh                     # Default: last 30 days for metrics
#   bug-tracker.sh --days 7            # Shorter comparison window
#   bug-tracker.sh --repo owner/repo   # Specify repository
#
# Examples:
#   ./scripts/bug-tracker.sh
#   ./scripts/bug-tracker.sh --days 14 --repo my-org/my-app
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# Defaults
DAYS=30
REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --days)  DAYS="$2"; shift 2 ;;
        --repo)  REPO="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: bug-tracker.sh [--days N] [--repo owner/repo]"
            echo ""
            echo "Options:"
            echo "  --days N           Comparison window for opened vs closed (default: 30)"
            echo "  --repo owner/repo  Target repository (default: current repo)"
            echo "  --help, -h         Show this help message"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

SINCE_DATE=$(date -d "-${DAYS} days" +%Y-%m-%d 2>/dev/null || date -v-${DAYS}d +%Y-%m-%d 2>/dev/null)
REPO_FLAG=""
if [ -n "$REPO" ]; then
    REPO_FLAG="--repo $REPO"
fi

# Check prerequisites
require_gh_auth
require_repo_context "$REPO"

print_header "🐛 Open Bug Summary"

DISPLAY_REPO="$REPO"
if [ -z "$DISPLAY_REPO" ]; then
    DISPLAY_REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "current repo")
fi
echo -e "  ${BLUE}Repository:${NC} $DISPLAY_REPO"
echo -e "  ${BLUE}Period:${NC}     Last $DAYS days (since $SINCE_DATE)"
echo ""

# ---------------------------------------------------------------------------
# Fetch open bugs
# ---------------------------------------------------------------------------
log_step "Fetching open bugs…"

OPEN_BUGS=$(gh issue list $REPO_FLAG --label "bug" --state open --limit 500 \
    --json number,title,createdAt,labels,assignees,updatedAt 2>/dev/null || echo "[]")

OPEN_COUNT=$(echo "$OPEN_BUGS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

log_step "Fetching recently closed bugs…"

CLOSED_BUGS=$(gh issue list $REPO_FLAG --label "bug" --state closed \
    --search "closed:>=$SINCE_DATE" --limit 500 \
    --json number,title,closedAt 2>/dev/null || echo "[]")

CLOSED_COUNT=$(echo "$CLOSED_BUGS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

NEW_BUGS=$(gh issue list $REPO_FLAG --label "bug" --state all \
    --search "created:>=$SINCE_DATE" --limit 500 \
    --json number,title,createdAt 2>/dev/null || echo "[]")

NEW_COUNT=$(echo "$NEW_BUGS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

log_ok "Found $OPEN_COUNT open bugs"
echo ""

# ---------------------------------------------------------------------------
# Metrics overview
# ---------------------------------------------------------------------------
print_section "Metrics"

echo -e "  ${RED}● Open Bugs:${NC}       $OPEN_COUNT"
echo -e "  ${GREEN}● Closed (${DAYS}d):${NC}   $CLOSED_COUNT"
echo -e "  ${BLUE}● Opened (${DAYS}d):${NC}   $NEW_COUNT"

# Net change
if [ "$NEW_COUNT" -gt 0 ] || [ "$CLOSED_COUNT" -gt 0 ]; then
    NET=$((NEW_COUNT - CLOSED_COUNT))
    if [ "$NET" -gt 0 ]; then
        echo -e "  ${YELLOW}● Net Change:${NC}      +$NET (growing)"
    elif [ "$NET" -lt 0 ]; then
        echo -e "  ${GREEN}● Net Change:${NC}      $NET (shrinking)"
    else
        echo -e "  ${BLUE}● Net Change:${NC}      0 (stable)"
    fi
fi

# Average age
echo "$OPEN_BUGS" | python3 -c "
import sys, json
from datetime import datetime, timezone

bugs = json.load(sys.stdin)
if not bugs:
    print('  Average Age:      N/A')
else:
    now = datetime.now(timezone.utc)
    ages = []
    for b in bugs:
        created = datetime.fromisoformat(b['createdAt'].replace('Z', '+00:00'))
        ages.append((now - created).days)
    avg_age = sum(ages) / len(ages)
    oldest = max(ages)
    print(f'  \033[0;34m● Avg Age:\033[0m         {avg_age:.0f} days')
    print(f'  \033[0;34m● Oldest Bug:\033[0m      {oldest} days')
" 2>/dev/null || true

echo ""

# ---------------------------------------------------------------------------
# Bugs by severity
# ---------------------------------------------------------------------------
print_section "By Severity"

echo "$OPEN_BUGS" | python3 -c "
import sys, json

bugs = json.load(sys.stdin)
severity_order = ['critical', 'high', 'medium', 'low']
severity_icons = {
    'critical': '🔴',
    'high':     '🟠',
    'medium':   '🟡',
    'low':      '🟢',
}

categorized = {s: [] for s in severity_order}
uncategorized = []

for b in bugs:
    label_names = [l['name'].lower() for l in b.get('labels', [])]
    found = False
    for sev in severity_order:
        # Match labels like 'critical', 'severity: critical', 'priority: high', 'p0', etc.
        if any(sev in ln for ln in label_names):
            categorized[sev].append(b)
            found = True
            break
    if not found:
        # Also check for p0/p1/p2/p3 patterns
        priority_map = {'p0': 'critical', 'p1': 'high', 'p2': 'medium', 'p3': 'low'}
        matched = False
        for pn, sev in priority_map.items():
            if any(pn in ln for ln in label_names):
                categorized[sev].append(b)
                matched = True
                break
        if not matched:
            uncategorized.append(b)

for sev in severity_order:
    bugs_in_sev = categorized[sev]
    icon = severity_icons[sev]
    count = len(bugs_in_sev)
    print(f'  {icon} {sev.capitalize():10s} {count} bug(s)')
    for b in bugs_in_sev[:3]:
        assignees = ', '.join(['@'+a['login'] for a in b.get('assignees', [])]) or 'unassigned'
        print(f'      #{b[\"number\"]} {b[\"title\"][:60]}  → {assignees}')
    if count > 3:
        print(f'      … and {count - 3} more')

if uncategorized:
    print(f'  ⚪ No severity  {len(uncategorized)} bug(s)')
    for b in uncategorized[:3]:
        assignees = ', '.join(['@'+a['login'] for a in b.get('assignees', [])]) or 'unassigned'
        print(f'      #{b[\"number\"]} {b[\"title\"][:60]}  → {assignees}')
    if len(uncategorized) > 3:
        print(f'      … and {len(uncategorized) - 3} more')

print()
" 2>/dev/null || log_warn "Could not categorize bugs by severity"

# ---------------------------------------------------------------------------
# Bugs needing attention
# ---------------------------------------------------------------------------
print_section "⚠ Needs Attention"

echo "$OPEN_BUGS" | python3 -c "
import sys, json
from datetime import datetime, timezone

bugs = json.load(sys.stdin)
now = datetime.now(timezone.utc)
severity_labels = ['critical', 'high', 'medium', 'low', 'p0', 'p1', 'p2', 'p3']

no_assignee = []
no_severity = []
stale = []

for b in bugs:
    label_names = [l['name'].lower() for l in b.get('labels', [])]
    assignees = b.get('assignees', [])
    created = datetime.fromisoformat(b['createdAt'].replace('Z', '+00:00'))
    age = (now - created).days

    if not assignees:
        no_assignee.append(b)
    if not any(any(sev in ln for sev in severity_labels) for ln in label_names):
        no_severity.append(b)
    if age > 30:
        stale.append((b, age))

if no_assignee:
    print(f'  \033[1;33m⚠ Unassigned bugs: {len(no_assignee)}\033[0m')
    for b in no_assignee[:5]:
        print(f'    #{b[\"number\"]} {b[\"title\"][:65]}')
    if len(no_assignee) > 5:
        print(f'    … and {len(no_assignee) - 5} more')
    print()

if no_severity:
    print(f'  \033[1;33m⚠ No severity label: {len(no_severity)}\033[0m')
    for b in no_severity[:5]:
        print(f'    #{b[\"number\"]} {b[\"title\"][:65]}')
    if len(no_severity) > 5:
        print(f'    … and {len(no_severity) - 5} more')
    print()

if stale:
    stale.sort(key=lambda x: -x[1])
    print(f'  \033[1;33m⚠ Stale bugs (>30 days old): {len(stale)}\033[0m')
    for b, age in stale[:5]:
        print(f'    #{b[\"number\"]} {b[\"title\"][:55]}  ({age} days old)')
    if len(stale) > 5:
        print(f'    … and {len(stale) - 5} more')
    print()

if not no_assignee and not no_severity and not stale:
    print('  \033[0;32m✓ All bugs have assignees and severity labels. Nice!\033[0m')
    print()
" 2>/dev/null || log_warn "Could not analyze bugs needing attention"

# ---------------------------------------------------------------------------
# Copilot suggestions
# ---------------------------------------------------------------------------
print_section "💡 Next Steps"

echo -e "  ${CYAN}Triage unassigned bugs:${NC}"
echo -e "    ${BOLD}gh issue edit <number> --add-assignee @username${NC}"
echo ""
echo -e "  ${CYAN}Add severity labels:${NC}"
echo -e "    ${BOLD}gh issue edit <number> --add-label \"high\"${NC}"
echo ""
echo -e "  ${CYAN}Ask Copilot to help analyze:${NC}"
echo -e "    ${BOLD}\"What are the most critical open bugs in this repo?\"${NC}"
echo -e "    ${BOLD}\"Help me triage the unassigned bugs\"${NC}"
echo -e "    ${BOLD}\"Which bugs have been open the longest and why?\"${NC}"
echo -e "    ${BOLD}\"Suggest which bugs to prioritize for the next sprint\"${NC}"
echo ""

print_tip "Run this script before sprint planning to understand the bug backlog."
echo ""
