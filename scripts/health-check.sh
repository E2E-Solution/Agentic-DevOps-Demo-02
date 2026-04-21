#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — Environment Health Check
# =============================================================================
# Verifies all tools are installed and configured correctly.
# Run this anytime to diagnose issues with your environment.
# =============================================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PASS=0
WARN=0
FAIL=0

section() { echo -e "\n${BOLD}── $1 ──${NC}"; }
pass()    { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; WARN=$((WARN + 1)); }
fail()    { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }

echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Agentic DevOps — Environment Health Check     ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"

# ---------------------------------------------------------------------------
# Core Runtimes
# ---------------------------------------------------------------------------
section "Core Runtimes"

if command -v node &>/dev/null; then
    NODE_VER=$(node --version 2>/dev/null)
    NODE_MAJOR=$(echo "$NODE_VER" | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 22 ]; then
        pass "Node.js $NODE_VER (>= 22 required)"
    else
        warn "Node.js $NODE_VER (version 22+ recommended for Copilot CLI)"
    fi
else
    fail "Node.js — NOT INSTALLED"
    echo -e "       Fix: This should be installed by the devcontainer. Try rebuilding."
fi

if command -v npm &>/dev/null; then
    pass "npm $(npm --version 2>/dev/null)"
else
    fail "npm — NOT INSTALLED"
fi

if command -v python3 &>/dev/null; then
    pass "Python $(python3 --version 2>/dev/null | awk '{print $2}')"
else
    warn "Python — not installed (optional, some scripts may need it)"
fi

if command -v git &>/dev/null; then
    pass "Git $(git --version 2>/dev/null | awk '{print $3}')"
else
    fail "Git — NOT INSTALLED"
fi

# ---------------------------------------------------------------------------
# GitHub Tools
# ---------------------------------------------------------------------------
section "GitHub Tools"

if command -v gh &>/dev/null; then
    GH_VER=$(gh --version 2>/dev/null | head -1)
    pass "GitHub CLI — $GH_VER"

    if gh auth status &>/dev/null; then
        GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
        pass "GitHub CLI authenticated as @$GH_USER"
    else
        warn "GitHub CLI — NOT authenticated"
        echo -e "       Fix: Run ${BOLD}gh auth login${NC}"
    fi
else
    fail "GitHub CLI (gh) — NOT INSTALLED"
    echo -e "       Fix: This should be installed by the devcontainer. Try rebuilding."
fi

if command -v copilot &>/dev/null; then
    COPILOT_VER=$(copilot --version 2>/dev/null || echo "installed")
    pass "GitHub Copilot CLI — $COPILOT_VER"
elif gh copilot --version &>/dev/null 2>&1; then
    pass "GitHub Copilot CLI — installed (gh copilot extension)"
else
    fail "GitHub Copilot CLI — NOT INSTALLED"
    echo -e "       Fix: Run ${BOLD}gh extension install github/gh-copilot${NC}"
fi

# ---------------------------------------------------------------------------
# Microsoft WorkIQ
# ---------------------------------------------------------------------------
section "Microsoft WorkIQ"

if command -v workiq &>/dev/null || npx --yes @microsoft/workiq --version &>/dev/null 2>&1; then
    pass "Microsoft WorkIQ — installed"
else
    warn "Microsoft WorkIQ — not available (preview feature)"
    echo -e "       Note: WorkIQ is a preview feature requiring M365 admin consent."
    echo -e "       See: ${BOLD}docs/06-workplace-intelligence.md${NC}"
fi

# ---------------------------------------------------------------------------
# Scripts
# ---------------------------------------------------------------------------
section "PM Scripts"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
for script in sprint-report.sh issue-triage.sh pr-summary.sh ci-status.sh welcome.sh; do
    if [ -x "$SCRIPT_DIR/$script" ]; then
        pass "$script — executable"
    elif [ -f "$SCRIPT_DIR/$script" ]; then
        warn "$script — exists but not executable"
        echo -e "       Fix: Run ${BOLD}chmod +x scripts/$script${NC}"
    else
        warn "$script — not found in scripts/"
    fi
done

# ---------------------------------------------------------------------------
# Copilot Instructions
# ---------------------------------------------------------------------------
section "Copilot Configuration"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -f "$REPO_ROOT/AGENTS.md" ]; then
    pass "AGENTS.md — found"
else
    warn "AGENTS.md — not found (Copilot CLI custom instructions)"
fi

if [ -f "$REPO_ROOT/.github/copilot-instructions.md" ]; then
    pass ".github/copilot-instructions.md — found"
else
    warn ".github/copilot-instructions.md — not found"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo -e "${BOLD}── Summary ──${NC}"
echo -e "  ${GREEN}✓ $PASS passed${NC}  ${YELLOW}⚠ $WARN warnings${NC}  ${RED}✗ $FAIL failures${NC}"

if [ "$FAIL" -eq 0 ] && [ "$WARN" -eq 0 ]; then
    echo -e "\n  ${GREEN}${BOLD}🎉 Everything looks great! You're ready to go.${NC}"
elif [ "$FAIL" -eq 0 ]; then
    echo -e "\n  ${YELLOW}${BOLD}⚡ Environment is functional with some warnings.${NC}"
else
    echo -e "\n  ${RED}${BOLD}🔧 Some tools need attention. Follow the fix instructions above.${NC}"
fi
echo ""
