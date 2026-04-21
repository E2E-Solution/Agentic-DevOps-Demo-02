#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — Test Coverage Metrics Helper
# =============================================================================
# Looks for test coverage data in GitHub Actions artifacts and local files.
# Shows whatever coverage information is available, or guides you on setting
# up coverage reporting.
#
# Usage:
#   test-coverage.sh                    # Check current repo
#   test-coverage.sh --repo owner/repo  # Specify repository
#
# Examples:
#   ./scripts/test-coverage.sh
#   ./scripts/test-coverage.sh --repo my-org/my-app
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# Defaults
REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --repo)   REPO="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: test-coverage.sh [--repo owner/repo]"
            echo ""
            echo "Options:"
            echo "  --repo owner/repo  Target repository (default: current repo)"
            echo "  --help, -h         Show this help message"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

API_REPO=""
if [ -n "$REPO" ]; then
    API_REPO="$REPO"
else
    API_REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "")
fi

# Check prerequisites
require_gh_auth
require_repo_context "$REPO"

print_header "📊 Test Coverage Metrics"

DISPLAY_REPO="${API_REPO:-current repo}"
echo -e "  ${BLUE}Repository:${NC} $DISPLAY_REPO"
echo ""

FOUND_COVERAGE=false

# ---------------------------------------------------------------------------
# Check GitHub Actions for coverage artifacts
# ---------------------------------------------------------------------------
print_section "CI Coverage Artifacts"
log_step "Searching for coverage artifacts in recent workflow runs…"

if [ -n "$API_REPO" ]; then
    # Fetch recent successful workflow runs
    RECENT_RUNS=$(gh api "repos/$API_REPO/actions/runs?status=success&per_page=10" \
        --jq '.workflow_runs[].id' 2>/dev/null || echo "")

    ARTIFACT_FOUND=false

    if [ -n "$RECENT_RUNS" ]; then
        for RUN_ID in $RECENT_RUNS; do
            ARTIFACTS=$(gh api "repos/$API_REPO/actions/runs/$RUN_ID/artifacts" \
                --jq '.artifacts[] | select(.name | test("coverage|lcov|codecov|cobertura|jacoco"; "i")) | .name' 2>/dev/null || echo "")
            if [ -n "$ARTIFACTS" ]; then
                if [ "$ARTIFACT_FOUND" = false ]; then
                    log_ok "Found coverage artifacts in run #$RUN_ID:"
                    ARTIFACT_FOUND=true
                    FOUND_COVERAGE=true
                fi
                echo "$ARTIFACTS" | while read -r name; do
                    echo -e "    ${GREEN}●${NC} $name"
                done
                break
            fi
        done
    fi

    if [ "$ARTIFACT_FOUND" = false ]; then
        log_warn "No coverage artifacts found in recent CI runs"
    fi
else
    log_warn "Could not determine repository for API queries"
fi
echo ""

# ---------------------------------------------------------------------------
# Check for coverage-related CI steps in workflow files
# ---------------------------------------------------------------------------
print_section "CI Workflow Analysis"
log_step "Checking workflow files for coverage configuration…"

if [ -n "$API_REPO" ]; then
    WORKFLOW_FILES=$(gh api "repos/$API_REPO/actions/workflows" \
        --jq '.workflows[].path' 2>/dev/null || echo "")

    if [ -n "$WORKFLOW_FILES" ]; then
        COVERAGE_WORKFLOWS=""
        while IFS= read -r wf_path; do
            [ -z "$wf_path" ] && continue
            WF_CONTENT=$(gh api "repos/$API_REPO/contents/$wf_path" \
                --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || echo "")
            if echo "$WF_CONTENT" | grep -qi "coverage\|codecov\|coveralls\|lcov\|cobertura\|jacoco\|istanbul\|nyc\|pytest.*cov\|--coverage" 2>/dev/null; then
                COVERAGE_WORKFLOWS="${COVERAGE_WORKFLOWS}${wf_path}\n"
                FOUND_COVERAGE=true
            fi
        done <<< "$WORKFLOW_FILES"

        if [ -n "$COVERAGE_WORKFLOWS" ]; then
            log_ok "Workflows with coverage steps:"
            echo -e "$COVERAGE_WORKFLOWS" | while IFS= read -r wf; do
                [ -z "$wf" ] && continue
                echo -e "    ${GREEN}●${NC} $wf"
            done
        else
            log_warn "No coverage steps found in workflow files"
        fi
    else
        log_warn "No workflow files found"
    fi
else
    log_warn "Skipping workflow analysis (no repo context for API)"
fi
echo ""

# ---------------------------------------------------------------------------
# Check for local coverage files
# ---------------------------------------------------------------------------
print_section "Local Coverage Files"
log_step "Scanning for local coverage data…"

# Common coverage file locations
COVERAGE_PATHS=(
    "coverage/lcov.info"
    "coverage/coverage-summary.json"
    "coverage/cobertura-coverage.xml"
    "coverage/clover.xml"
    "coverage/index.html"
    ".coverage"
    "lcov.info"
    "cobertura.xml"
    "jacoco.xml"
    "target/site/jacoco/index.html"
    "htmlcov/index.html"
    "cover/excoveralls.json"
    "coverage.xml"
    "coverage.json"
)

LOCAL_FOUND=false
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")

if [ -n "$REPO_ROOT" ]; then
    for cpath in "${COVERAGE_PATHS[@]}"; do
        full_path="$REPO_ROOT/$cpath"
        if [ -f "$full_path" ]; then
            if [ "$LOCAL_FOUND" = false ]; then
                log_ok "Found local coverage files:"
                LOCAL_FOUND=true
                FOUND_COVERAGE=true
            fi
            SIZE=$(du -h "$full_path" 2>/dev/null | cut -f1)
            MODIFIED=$(date -r "$full_path" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "unknown")
            echo -e "    ${GREEN}●${NC} $cpath  ($SIZE, modified $MODIFIED)"
        fi
    done

    # Check for coverage directories
    if [ -d "$REPO_ROOT/coverage" ] && [ "$LOCAL_FOUND" = false ]; then
        FILE_COUNT=$(find "$REPO_ROOT/coverage" -type f 2>/dev/null | wc -l)
        if [ "$FILE_COUNT" -gt 0 ]; then
            log_ok "Found coverage/ directory with $FILE_COUNT files"
            LOCAL_FOUND=true
            FOUND_COVERAGE=true
        fi
    fi

    if [ -d "$REPO_ROOT/htmlcov" ] && [ "$LOCAL_FOUND" = false ]; then
        log_ok "Found htmlcov/ directory (Python coverage)"
        LOCAL_FOUND=true
        FOUND_COVERAGE=true
    fi
fi

if [ "$LOCAL_FOUND" = false ]; then
    log_warn "No local coverage files found"
fi
echo ""

# ---------------------------------------------------------------------------
# Parse coverage summary if available
# ---------------------------------------------------------------------------
if [ -n "$REPO_ROOT" ] && [ -f "$REPO_ROOT/coverage/coverage-summary.json" ]; then
    print_section "Coverage Summary"

    python3 -c "
import sys, json

with open('$REPO_ROOT/coverage/coverage-summary.json') as f:
    data = json.load(f)

total = data.get('total', {})
metrics = ['lines', 'statements', 'functions', 'branches']

for m in metrics:
    info = total.get(m, {})
    pct = info.get('pct', 0)
    covered = info.get('covered', 0)
    total_count = info.get('total', 0)
    if pct >= 80:
        icon = '\033[0;32m●\033[0m'
    elif pct >= 60:
        icon = '\033[1;33m●\033[0m'
    else:
        icon = '\033[0;31m●\033[0m'
    print(f'  {icon} {m.capitalize():12s} {pct:6.1f}%  ({covered}/{total_count})')

print()
" 2>/dev/null || log_warn "Could not parse coverage summary"
fi

if [ -n "$REPO_ROOT" ] && [ -f "$REPO_ROOT/.coverage" ]; then
    # Try to show Python coverage summary
    if command -v python3 &>/dev/null; then
        print_section "Python Coverage Data"
        python3 -c "
try:
    import coverage
    cov = coverage.Coverage()
    cov.load()
    pct = cov.report(file=None, show_missing=False)
except Exception:
    pass
" 2>/dev/null || log_warn "Install 'coverage' package to read .coverage data: pip install coverage"
        echo ""
    fi
fi

# ---------------------------------------------------------------------------
# Setup guidance if no coverage found
# ---------------------------------------------------------------------------
if [ "$FOUND_COVERAGE" = false ]; then
    print_section "📋 Setting Up Coverage"

    echo -e "  No coverage data was found. Here's how to add it:"
    echo ""
    echo -e "  ${BOLD}JavaScript / TypeScript (Jest):${NC}"
    echo -e "    Add to package.json scripts:"
    echo -e "    ${CYAN}\"test:coverage\": \"jest --coverage\"${NC}"
    echo ""
    echo -e "  ${BOLD}Python (pytest):${NC}"
    echo -e "    ${CYAN}pip install pytest-cov${NC}"
    echo -e "    ${CYAN}pytest --cov=src --cov-report=xml${NC}"
    echo ""
    echo -e "  ${BOLD}Java (JaCoCo via Maven):${NC}"
    echo -e "    Add the jacoco-maven-plugin to your pom.xml"
    echo ""
    echo -e "  ${BOLD}Go:${NC}"
    echo -e "    ${CYAN}go test -coverprofile=coverage.out ./...${NC}"
    echo ""
    echo -e "  ${BOLD}GitHub Actions — Upload coverage artifact:${NC}"
    echo -e "    ${CYAN}- uses: actions/upload-artifact@v4${NC}"
    echo -e "    ${CYAN}  with:${NC}"
    echo -e "    ${CYAN}    name: coverage-report${NC}"
    echo -e "    ${CYAN}    path: coverage/${NC}"
    echo ""
fi

# ---------------------------------------------------------------------------
# Copilot suggestions
# ---------------------------------------------------------------------------
print_section "💡 Next Steps"

echo -e "  ${CYAN}Ask Copilot to help with coverage:${NC}"
echo -e "    ${BOLD}\"Add test coverage reporting to our CI pipeline\"${NC}"
echo -e "    ${BOLD}\"Which parts of the codebase have the least test coverage?\"${NC}"
echo -e "    ${BOLD}\"Help me write tests for the uncovered files\"${NC}"
echo -e "    ${BOLD}\"Set up Codecov integration for this repository\"${NC}"
echo ""
echo -e "  ${CYAN}Generate a coverage report locally:${NC}"
echo -e "    ${BOLD}npm test -- --coverage${NC}    (JavaScript)"
echo -e "    ${BOLD}pytest --cov=src${NC}          (Python)"
echo -e "    ${BOLD}go test -cover ./...${NC}      (Go)"
echo ""

print_tip "Aim for at least 80% line coverage on critical paths."
echo ""
