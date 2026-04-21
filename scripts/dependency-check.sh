#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — Dependency Check
# =============================================================================
# Detects project type, checks for outdated/vulnerable dependencies,
# and shows Dependabot alerts if available.
#
# Usage:
#   dependency-check.sh                    # Check current repo
#   dependency-check.sh --repo owner/repo  # Specify repository
#   dependency-check.sh --help             # Show help
#
# Examples:
#   dependency-check.sh
#   dependency-check.sh --repo my-org/my-app
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# Defaults
REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --repo) REPO="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: dependency-check.sh [--repo owner/repo]"
            echo ""
            echo "Options:"
            echo "  --repo owner/repo   Specify the repository (default: current repo)"
            echo "  --help, -h          Show this help message"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

require_gh_auth
require_repo_context "$REPO"

print_header "📦  Dependency Check"

# Resolve repo name for API calls
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

echo -e "  ${BLUE}Repository:${NC} $REPO_NAME"
echo ""

# ---------------------------------------------------------------------------
# Detect Project Type
# ---------------------------------------------------------------------------
print_section "Project Detection"

FOUND_ANY=false

# Check for Node.js (package.json)
HAS_NPM=false
if gh api "repos/$REPO_OWNER/$REPO_REPO/contents/package.json" --jq '.name' &>/dev/null; then
    HAS_NPM=true
    FOUND_ANY=true
    log_ok "Node.js project detected (package.json)"
fi

# Check for Python (requirements.txt or pyproject.toml)
HAS_PIP=false
PIP_FILE=""
if gh api "repos/$REPO_OWNER/$REPO_REPO/contents/requirements.txt" --jq '.name' &>/dev/null; then
    HAS_PIP=true
    PIP_FILE="requirements.txt"
    FOUND_ANY=true
    log_ok "Python project detected (requirements.txt)"
elif gh api "repos/$REPO_OWNER/$REPO_REPO/contents/pyproject.toml" --jq '.name' &>/dev/null; then
    HAS_PIP=true
    PIP_FILE="pyproject.toml"
    FOUND_ANY=true
    log_ok "Python project detected (pyproject.toml)"
fi

# Check for Go (go.mod)
if gh api "repos/$REPO_OWNER/$REPO_REPO/contents/go.mod" --jq '.name' &>/dev/null; then
    FOUND_ANY=true
    log_ok "Go project detected (go.mod)"
fi

# Check for Ruby (Gemfile)
if gh api "repos/$REPO_OWNER/$REPO_REPO/contents/Gemfile" --jq '.name' &>/dev/null; then
    FOUND_ANY=true
    log_ok "Ruby project detected (Gemfile)"
fi

# Check for Java/Kotlin (pom.xml or build.gradle)
if gh api "repos/$REPO_OWNER/$REPO_REPO/contents/pom.xml" --jq '.name' &>/dev/null; then
    FOUND_ANY=true
    log_ok "Java/Maven project detected (pom.xml)"
elif gh api "repos/$REPO_OWNER/$REPO_REPO/contents/build.gradle" --jq '.name' &>/dev/null; then
    FOUND_ANY=true
    log_ok "Java/Gradle project detected (build.gradle)"
fi

# Check for .NET (*.csproj — check root directory listing)
if gh api "repos/$REPO_OWNER/$REPO_REPO/contents/" --jq '.[].name' 2>/dev/null | grep -q '\.csproj$\|\.sln$'; then
    FOUND_ANY=true
    log_ok ".NET project detected (.csproj/.sln)"
fi

if [ "$FOUND_ANY" = false ]; then
    log_warn "No recognized dependency files found in root directory."
    echo ""
    echo -e "  Supported: package.json, requirements.txt, pyproject.toml,"
    echo -e "             go.mod, Gemfile, pom.xml, build.gradle, *.csproj"
    echo ""
fi
echo ""

# ---------------------------------------------------------------------------
# Local Audit (if we're in the repo working tree)
# ---------------------------------------------------------------------------
if [ -z "$REPO" ] && git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    WORK_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

    if [ "$HAS_NPM" = true ] && [ -f "$WORK_DIR/package.json" ]; then
        print_section "npm Audit"

        if command -v npm &>/dev/null; then
            if [ -f "$WORK_DIR/package-lock.json" ] || [ -f "$WORK_DIR/node_modules/.package-lock.json" ]; then
                AUDIT_OUTPUT=$(cd "$WORK_DIR" && npm audit --json 2>/dev/null || echo "{}")
                echo "$AUDIT_OUTPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    vulns = data.get('vulnerabilities', {})
    meta = data.get('metadata', {}).get('vulnerabilities', {})
    total = meta.get('total', len(vulns))
    crit = meta.get('critical', 0)
    high = meta.get('high', 0)
    moderate = meta.get('moderate', 0)
    low = meta.get('low', 0)

    if total == 0:
        print('  ✓ No known vulnerabilities found.')
    else:
        print(f'  Found {total} vulnerabilities:')
        if crit:   print(f'    🔴 Critical: {crit}')
        if high:   print(f'    🟠 High:     {high}')
        if moderate: print(f'    🟡 Moderate: {moderate}')
        if low:    print(f'    🟢 Low:      {low}')
        print()
        print('  Run: npm audit fix')
except:
    print('  (Could not parse npm audit output)')
" 2>/dev/null || echo "  (npm audit failed)"
            else
                log_warn "No package-lock.json found — run 'npm install' first."
            fi
        else
            log_warn "npm not installed — skipping local audit."
        fi
        echo ""
    fi

    if [ "$HAS_PIP" = true ] && [ -f "$WORK_DIR/$PIP_FILE" ]; then
        print_section "Python Dependency Check"

        if command -v pip-audit &>/dev/null; then
            log_step "Running pip-audit..."
            cd "$WORK_DIR" && pip-audit 2>/dev/null || log_warn "pip-audit found issues (see above)."
        else
            log_warn "pip-audit not installed. Install with: pip install pip-audit"
            echo -e "  Listing dependencies from $PIP_FILE instead:"
            echo ""
            if [ "$PIP_FILE" = "requirements.txt" ]; then
                head -20 "$WORK_DIR/requirements.txt" | sed 's/^/    /'
                LINE_COUNT=$(wc -l < "$WORK_DIR/requirements.txt")
                if [ "$LINE_COUNT" -gt 20 ]; then
                    echo -e "    ${YELLOW}... and $((LINE_COUNT - 20)) more${NC}"
                fi
            else
                echo "    (pyproject.toml detected — use pip-audit for full analysis)"
            fi
        fi
        echo ""
    fi
fi

# ---------------------------------------------------------------------------
# Dependabot Alerts (via GitHub API)
# ---------------------------------------------------------------------------
print_section "Dependabot Alerts"

ALERTS=$(gh api "repos/$REPO_OWNER/$REPO_REPO/dependabot/alerts?state=open&per_page=25" 2>/dev/null || echo "UNAVAILABLE")

if [ "$ALERTS" = "UNAVAILABLE" ]; then
    log_warn "Could not fetch Dependabot alerts."
    echo -e "  This may mean Dependabot is not enabled, or you lack permission."
    echo -e "  Enable at: https://github.com/$REPO_NAME/settings/security_analysis"
else
    echo "$ALERTS" | python3 -c "
import sys, json

alerts = json.load(sys.stdin)
if not alerts:
    print('  ✓ No open Dependabot alerts — looking good!')
else:
    # Count by severity
    sevs = {}
    for a in alerts:
        sev = a.get('security_advisory', {}).get('severity', 'unknown')
        sevs[sev] = sevs.get(sev, 0) + 1

    total = len(alerts)
    print(f'  Found {total} open Dependabot alert(s):')
    order = ['critical', 'high', 'medium', 'low']
    icons = {'critical': '🔴', 'high': '🟠', 'medium': '🟡', 'low': '🟢'}
    for s in order:
        if s in sevs:
            print(f'    {icons.get(s, \"⚪\")} {s.capitalize()}: {sevs[s]}')
    for s in sevs:
        if s not in order:
            print(f'    ⚪ {s.capitalize()}: {sevs[s]}')

    print()
    print('  Top alerts:')
    for a in alerts[:10]:
        pkg = a.get('dependency', {}).get('package', {}).get('name', 'unknown')
        sev = a.get('security_advisory', {}).get('severity', '?')
        summary = a.get('security_advisory', {}).get('summary', 'No summary')[:70]
        icon = icons.get(sev, '⚪')
        print(f'    {icon} {pkg} ({sev}) — {summary}')
    if total > 10:
        print(f'    ... and {total - 10} more alerts')
" 2>/dev/null || echo "  (Could not parse Dependabot alerts)"
fi
echo ""

# ---------------------------------------------------------------------------
# Summary & Next Steps
# ---------------------------------------------------------------------------
print_section "Next Steps"

echo -e "  ${CYAN}1.${NC} Review and fix critical/high alerts first"
echo -e "  ${CYAN}2.${NC} Enable Dependabot if not already active:"
echo -e "       https://github.com/$REPO_NAME/settings/security_analysis"
echo -e "  ${CYAN}3.${NC} Use Copilot for help:"
echo -e "       ${BOLD}copilot${NC} \"Help me fix the Dependabot alerts in this repo\""
echo ""

print_tip "Run this script regularly to stay on top of dependency vulnerabilities."
echo ""
