#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — CI/CD Pipeline Status
# =============================================================================
# Shows the status of recent GitHub Actions workflow runs.
#
# Usage:
#   ci-status.sh                    # Check current repo
#   ci-status.sh --repo owner/repo  # Specify repository
#   ci-status.sh --limit 10         # Number of recent runs
# =============================================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO=""
LIMIT=15

while [[ $# -gt 0 ]]; do
    case $1 in
        --repo)  REPO="$2"; shift 2 ;;
        --limit) LIMIT="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: ci-status.sh [--repo owner/repo] [--limit N]"
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
echo -e "${BOLD}║          ⚙️  CI/CD Pipeline Status                   ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
if [ -n "$REPO" ]; then
    echo -e "  ${BLUE}Repository:${NC} $REPO"
    echo ""
fi

# ---------------------------------------------------------------------------
# Workflow Runs
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Recent Workflow Runs ──${NC}"
echo ""

RUNS=$(gh run list $REPO_FLAG --limit "$LIMIT" --json databaseId,displayTitle,status,conclusion,event,headBranch,createdAt,updatedAt,workflowName 2>/dev/null || echo "[]")
RUN_COUNT=$(echo "$RUNS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

if [ "$RUN_COUNT" -eq 0 ]; then
    echo -e "  ${YELLOW}No workflow runs found.${NC}"
    echo -e "  Make sure you're in a repository with GitHub Actions configured."
    echo ""
    exit 0
fi

echo "$RUNS" | python3 -c "
import sys, json

runs = json.load(sys.stdin)

# Count by status
success = sum(1 for r in runs if r.get('conclusion') == 'success')
failure = sum(1 for r in runs if r.get('conclusion') == 'failure')
running = sum(1 for r in runs if r.get('status') == 'in_progress')
other = len(runs) - success - failure - running

print(f'  Total runs: {len(runs)} (last {len(runs)} shown)')
print(f'  ✅ Success: {success}  ❌ Failed: {failure}  🔄 Running: {running}  ⚪ Other: {other}')
print()

# Group by workflow
workflows = {}
for r in runs:
    wf = r.get('workflowName', 'Unknown')
    if wf not in workflows:
        workflows[wf] = []
    workflows[wf].append(r)

for wf_name, wf_runs in workflows.items():
    latest = wf_runs[0]
    conclusion = latest.get('conclusion', latest.get('status', 'unknown'))

    icon = {
        'success': '✅', 'failure': '❌', 'cancelled': '⚪',
        'in_progress': '🔄', 'queued': '⏳'
    }.get(conclusion, '❓')

    print(f'  {icon} {wf_name}')
    for r in wf_runs[:3]:
        c = r.get('conclusion', r.get('status', 'unknown'))
        branch = r.get('headBranch', 'unknown')
        title = r.get('displayTitle', '')[:50]
        run_icon = {'success': '✅', 'failure': '❌', 'cancelled': '⚪', 'in_progress': '🔄', 'queued': '⏳'}.get(c, '❓')
        print(f'       {run_icon} {title} ({branch}) — {c}')
    print()
" 2>/dev/null

# ---------------------------------------------------------------------------
# Failed Runs Detail
# ---------------------------------------------------------------------------
FAILED_RUNS=$(echo "$RUNS" | python3 -c "
import sys, json
runs = json.load(sys.stdin)
failed = [r for r in runs if r.get('conclusion') == 'failure']
print(json.dumps(failed))
" 2>/dev/null || echo "[]")

FAILED_COUNT=$(echo "$FAILED_RUNS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

if [ "$FAILED_COUNT" -gt 0 ]; then
    echo -e "${BOLD}── ❌ Failed Runs (Need Attention) ──${NC}"
    echo ""
    echo "$FAILED_RUNS" | python3 -c "
import sys, json
runs = json.load(sys.stdin)
for r in runs[:5]:
    print(f'  ❌ {r.get(\"displayTitle\", \"Unknown\")}')
    print(f'       Workflow: {r.get(\"workflowName\", \"Unknown\")}')
    print(f'       Branch:   {r.get(\"headBranch\", \"Unknown\")}')
    print(f'       Run ID:   {r.get(\"databaseId\", \"Unknown\")}')
    print(f'       View:     gh run view {r.get(\"databaseId\", \"\")} --log-failed')
    print()
" 2>/dev/null

    echo -e "  ${CYAN}Tip:${NC} To investigate a failure, run:"
    echo -e "       ${BOLD}gh run view <RUN_ID> --log-failed${NC}"
    echo -e "       Or ask Copilot CLI: \"Why did workflow run <RUN_ID> fail?\""
    echo ""
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Quick Actions ──${NC}"
echo ""
echo -e "  ${GREEN}Re-run a failed workflow:${NC}"
echo -e "    gh run rerun <RUN_ID>"
echo ""
echo -e "  ${GREEN}View workflow logs:${NC}"
echo -e "    gh run view <RUN_ID> --log"
echo ""
echo -e "  ${GREEN}List all workflows:${NC}"
echo -e "    gh workflow list"
echo ""
echo -e "  ${CYAN}Tip:${NC} Ask Copilot CLI: \"What's failing in our CI/CD pipelines?\""
echo ""
