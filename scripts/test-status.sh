#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — Test Run Status Summary
# =============================================================================
# Shows recent test/CI workflow run results from GitHub Actions.
# Groups by workflow, highlights repeated failures, and suggests next steps.
#
# Usage:
#   test-status.sh                     # Default: last 10 runs per workflow
#   test-status.sh --limit 20         # Show more runs
#   test-status.sh --repo owner/repo  # Specify repository
#
# Examples:
#   ./scripts/test-status.sh
#   ./scripts/test-status.sh --limit 5 --repo my-org/my-app
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# Defaults
LIMIT=10
REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --limit)  LIMIT="$2"; shift 2 ;;
        --repo)   REPO="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: test-status.sh [--limit N] [--repo owner/repo]"
            echo ""
            echo "Options:"
            echo "  --limit N          Number of recent runs to inspect per workflow (default: 10)"
            echo "  --repo owner/repo  Target repository (default: current repo)"
            echo "  --help, -h         Show this help message"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

REPO_FLAG=""
if [ -n "$REPO" ]; then
    REPO_FLAG="--repo $REPO"
fi

# Check prerequisites
require_gh_auth
require_repo_context "$REPO"

print_header "🧪 Test Run Status Summary"

DISPLAY_REPO="$REPO"
if [ -z "$DISPLAY_REPO" ]; then
    DISPLAY_REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "current repo")
fi
echo -e "  ${BLUE}Repository:${NC} $DISPLAY_REPO"
echo -e "  ${BLUE}Limit:${NC}      Last $LIMIT runs per workflow"
echo ""

# ---------------------------------------------------------------------------
# Fetch workflow runs
# ---------------------------------------------------------------------------
log_step "Fetching recent workflow runs…"

ALL_RUNS=$(gh run list $REPO_FLAG --limit 100 --json databaseId,name,status,conclusion,headBranch,createdAt,updatedAt,event 2>/dev/null || echo "[]")

RUN_COUNT=$(echo "$ALL_RUNS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

if [ "$RUN_COUNT" -eq 0 ]; then
    log_warn "No workflow runs found. This repository may not have GitHub Actions configured."
    echo ""
    echo -e "  ${CYAN}To set up CI testing, ask Copilot:${NC}"
    echo -e "    ${BOLD}\"Help me set up a GitHub Actions CI workflow for this project\"${NC}"
    echo ""
    exit 0
fi

log_ok "Found $RUN_COUNT recent workflow runs"
echo ""

# ---------------------------------------------------------------------------
# Filter to test-related workflows & summarize
# ---------------------------------------------------------------------------
print_section "Workflow Summary"

python3 -c "
import sys, json
from datetime import datetime, timezone

runs = json.load(sys.stdin)
limit = int('$LIMIT')

# Filter to test-related workflows (name contains test, ci, check, lint, build, quality)
test_keywords = ['test', 'ci', 'check', 'lint', 'build', 'quality', 'validate', 'verify']
test_runs = [r for r in runs if any(kw in r['name'].lower() for kw in test_keywords)]

# If no test-like workflows, show all workflows
if not test_runs:
    test_runs = runs
    print('  \033[1;33m⚠\033[0m No workflows matched test/CI keywords — showing all workflows')
    print()

# Group by workflow name
from collections import defaultdict
groups = defaultdict(list)
for r in test_runs:
    groups[r['name']].append(r)

total_pass = 0
total_fail = 0
total_running = 0
failing_workflows = []

for wf_name in sorted(groups.keys()):
    wf_runs = groups[wf_name][:limit]
    successes = sum(1 for r in wf_runs if r.get('conclusion') == 'success')
    failures = sum(1 for r in wf_runs if r.get('conclusion') == 'failure')
    running = sum(1 for r in wf_runs if r.get('status') in ('in_progress', 'queued'))
    cancelled = sum(1 for r in wf_runs if r.get('conclusion') == 'cancelled')
    total = len(wf_runs)

    total_pass += successes
    total_fail += failures
    total_running += running

    # Determine overall health
    if running > 0:
        icon = '🔄'
        health = '\033[0;34mrunning\033[0m'
    elif failures == 0:
        icon = '✅'
        health = '\033[0;32mall passing\033[0m'
    elif successes == 0:
        icon = '🔴'
        health = '\033[0;31mall failing\033[0m'
        failing_workflows.append(wf_name)
    elif failures >= total // 2:
        icon = '🟡'
        health = '\033[1;33mmostly failing\033[0m'
        failing_workflows.append(wf_name)
    else:
        icon = '🟢'
        health = '\033[0;32mmostly passing\033[0m'

    pass_rate = f'{successes}/{total}'
    print(f'  {icon} \033[1m{wf_name}\033[0m')
    print(f'      Pass: {pass_rate}  |  Fail: {failures}  |  Running: {running}  |  Status: {health}')

    # Show latest run info
    latest = wf_runs[0]
    created = latest.get('createdAt', '')[:10]
    branch = latest.get('headBranch', 'unknown')
    conclusion = latest.get('conclusion') or latest.get('status', 'unknown')
    print(f'      Latest: {created} on \033[0;36m{branch}\033[0m — {conclusion}')
    print()

# Print aggregate stats
print(f'  \033[1m── Totals ──\033[0m')
print()
grand_total = total_pass + total_fail + total_running
if grand_total > 0:
    pass_pct = total_pass / grand_total * 100
    print(f'  \033[0;32m✓ Passed:\033[0m  {total_pass}  ({pass_pct:.0f}%)')
    print(f'  \033[0;31m✗ Failed:\033[0m  {total_fail}')
    if total_running > 0:
        print(f'  \033[0;34m⟳ Running:\033[0m {total_running}')
print()

# Highlight repeated failures
if failing_workflows:
    print(f'  \033[0;31m⚠ Repeatedly Failing Workflows:\033[0m')
    for wf in failing_workflows:
        print(f'    • {wf}')
    print()
" <<< "$ALL_RUNS" 2>/dev/null || log_warn "Could not parse workflow runs"

# ---------------------------------------------------------------------------
# Currently running workflows
# ---------------------------------------------------------------------------
RUNNING_RUNS=$(echo "$ALL_RUNS" | python3 -c "
import sys, json
runs = json.load(sys.stdin)
running = [r for r in runs if r.get('status') in ('in_progress', 'queued')]
if running:
    print('  \033[1m── Currently Running ──\033[0m')
    print()
    for r in running[:10]:
        status = '🔄 in progress' if r['status'] == 'in_progress' else '⏳ queued'
        print(f'    {status}  {r[\"name\"]} on {r.get(\"headBranch\", \"unknown\")}')
    print()
else:
    print('  No workflows currently running.')
    print()
" 2>/dev/null || echo "")

print_section "Active Runs"
echo "$RUNNING_RUNS"

# ---------------------------------------------------------------------------
# Recent failures detail
# ---------------------------------------------------------------------------
print_section "Recent Failures"

echo "$ALL_RUNS" | python3 -c "
import sys, json

runs = json.load(sys.stdin)
failures = [r for r in runs if r.get('conclusion') == 'failure'][:5]

if not failures:
    print('  \033[0;32m✓ No recent failures — looking good!\033[0m')
    print()
else:
    for r in failures:
        created = r.get('createdAt', '')[:16].replace('T', ' ')
        print(f'  \033[0;31m✗\033[0m \033[1m{r[\"name\"]}\033[0m')
        print(f'    Branch: {r.get(\"headBranch\", \"unknown\")}  |  Date: {created}  |  Run ID: {r[\"databaseId\"]}')
    print()
" 2>/dev/null || log_warn "Could not parse failure details"

# ---------------------------------------------------------------------------
# Copilot suggestions
# ---------------------------------------------------------------------------
print_section "💡 Next Steps"

echo -e "  ${CYAN}Investigate a failing workflow:${NC}"
echo -e "    ${BOLD}gh run view <run-id> --log-failed${NC}"
echo ""
echo -e "  ${CYAN}Ask Copilot to help debug:${NC}"
echo -e "    ${BOLD}\"Why is the CI workflow failing on main?\"${NC}"
echo -e "    ${BOLD}\"Show me the test failures from the latest run\"${NC}"
echo -e "    ${BOLD}\"Help me fix the flaky tests in this repo\"${NC}"
echo ""
echo -e "  ${CYAN}Re-run a failed workflow:${NC}"
echo -e "    ${BOLD}gh run rerun <run-id>${NC}"
echo ""

print_tip "Run this script regularly to catch test regressions early."
echo ""
