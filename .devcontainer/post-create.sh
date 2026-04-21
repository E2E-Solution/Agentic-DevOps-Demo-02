#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps for Project Managers — Post-Create Setup
# =============================================================================
# This script runs automatically when the Codespace is created.
# It installs tools not available as devcontainer features and configures
# the environment for PM workflows.
# =============================================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_step() { echo -e "${BLUE}▶${NC} $1"; }
log_ok()   { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_fail() { echo -e "${RED}✗${NC} $1"; }

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Agentic DevOps — Setting Up Your Environment...   ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# ---------------------------------------------------------------------------
# 1. Install GitHub Copilot CLI (via gh extension)
# ---------------------------------------------------------------------------
log_step "Installing GitHub Copilot CLI..."
if command -v gh &>/dev/null; then
    if gh extension install github/gh-copilot 2>/dev/null || gh extension upgrade gh-copilot 2>/dev/null; then
        log_ok "GitHub Copilot CLI installed (gh copilot)"
    else
        log_warn "Could not install Copilot CLI extension. You can install it later: gh extension install github/gh-copilot"
    fi
else
    log_warn "GitHub CLI (gh) not found — Copilot CLI installation skipped"
fi

# ---------------------------------------------------------------------------
# 2. Install Microsoft WorkIQ (Preview — requires M365 admin consent)
# ---------------------------------------------------------------------------
log_step "Checking Microsoft WorkIQ availability..."
if npm install -g @microsoft/workiq@latest 2>/dev/null; then
    log_ok "Microsoft WorkIQ installed"
else
    log_warn "WorkIQ is not yet available or requires M365 admin consent for your tenant"
    log_warn "This is expected — WorkIQ is a preview feature. See docs/06-workplace-intelligence.md"
fi

# ---------------------------------------------------------------------------
# 3. Configure Git defaults (PM-friendly settings)
# ---------------------------------------------------------------------------
log_step "Configuring Git defaults..."
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.autoSetupRemote true
git config --global core.autocrlf input
log_ok "Git configured with PM-friendly defaults"

# ---------------------------------------------------------------------------
# 4. Set up shell aliases for common commands
# ---------------------------------------------------------------------------
log_step "Setting up shell aliases..."

ALIAS_FILE="$HOME/.bash_aliases"

# Resolve the workspace root (Codespaces default: /workspaces/<repo>)
WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cat > "$ALIAS_FILE" << ALIASES
# Agentic DevOps — PM Shortcuts
alias sprint-report='bash ${WORKSPACE_ROOT}/scripts/sprint-report.sh'
alias issue-triage='bash ${WORKSPACE_ROOT}/scripts/issue-triage.sh'
alias pr-summary='bash ${WORKSPACE_ROOT}/scripts/pr-summary.sh'
alias ci-status='bash ${WORKSPACE_ROOT}/scripts/ci-status.sh'
alias health-check='bash ${WORKSPACE_ROOT}/scripts/health-check.sh'
alias welcome='bash ${WORKSPACE_ROOT}/scripts/welcome.sh'

# Agentic DevOps — Developer Shortcuts
alias dev-setup='bash ${WORKSPACE_ROOT}/scripts/dev-setup.sh'
alias code-review='bash ${WORKSPACE_ROOT}/scripts/code-review.sh'
alias dependency-check='bash ${WORKSPACE_ROOT}/scripts/dependency-check.sh'
alias release-prep='bash ${WORKSPACE_ROOT}/scripts/release-prep.sh'

# Agentic DevOps — QA/Tester Shortcuts
alias test-status='bash ${WORKSPACE_ROOT}/scripts/test-status.sh'
alias bug-tracker='bash ${WORKSPACE_ROOT}/scripts/bug-tracker.sh'
alias test-coverage='bash ${WORKSPACE_ROOT}/scripts/test-coverage.sh'

# Copilot CLI shortcut
alias copilot-start='gh copilot'

# Quick gh CLI shortcuts
alias my-issues='gh issue list --assignee @me'
alias my-prs='gh pr list --author @me'
alias my-reviews='gh pr list --search "review-requested:@me"'
ALIASES

# Ensure aliases are loaded in new shells
if ! grep -q "bash_aliases" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# Load Agentic DevOps aliases' >> "$HOME/.bashrc"
    echo '[ -f ~/.bash_aliases ] && . ~/.bash_aliases' >> "$HOME/.bashrc"
fi

log_ok "Shell aliases configured (sprint-report, issue-triage, pr-summary, ci-status, dev-setup, code-review, test-status, etc.)"

# ---------------------------------------------------------------------------
# 5. Make all scripts executable
# ---------------------------------------------------------------------------
log_step "Making scripts executable..."
SCRIPT_DIR="$(dirname "$0")/../scripts"
if [ -d "$SCRIPT_DIR" ]; then
    chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true
    log_ok "Scripts are now executable"
else
    log_warn "Scripts directory not found — skipping"
fi

# ---------------------------------------------------------------------------
# 6. Run health check
# ---------------------------------------------------------------------------
log_step "Running environment health check..."
echo ""

check_tool() {
    local name="$1"
    local cmd="$2"
    if command -v "$cmd" &>/dev/null; then
        local version
        version=$($cmd --version 2>/dev/null | head -1 || echo "installed")
        log_ok "$name — $version"
        return 0
    else
        log_fail "$name — NOT FOUND"
        return 1
    fi
}

ISSUES=0
check_tool "Node.js" "node"           || ((ISSUES++))
check_tool "npm" "npm"                 || ((ISSUES++))
check_tool "Python" "python3"          || ((ISSUES++))
check_tool "Git" "git"                 || ((ISSUES++))
check_tool "GitHub CLI" "gh"           || ((ISSUES++))
gh copilot --version &>/dev/null 2>&1 && log_ok "GitHub Copilot CLI — installed (gh copilot)" || { log_fail "GitHub Copilot CLI — NOT FOUND"; ((ISSUES++)); }

echo ""
if [ "$ISSUES" -eq 0 ]; then
    log_ok "All tools installed successfully!"
else
    log_warn "$ISSUES tool(s) had issues. Run 'health-check' for details."
fi

# ---------------------------------------------------------------------------
# 7. Display welcome message
# ---------------------------------------------------------------------------
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║         🚀 Your Environment is Ready!               ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Quick Start:${NC}"
echo -e "    ${GREEN}1.${NC} Run ${BOLD}welcome${NC} to start the guided onboarding"
echo -e "    ${GREEN}2.${NC} Run ${BOLD}gh copilot${NC} to launch GitHub Copilot CLI"
echo -e "    ${GREEN}3.${NC} Run ${BOLD}health-check${NC} to verify your setup"
echo ""
echo -e "  ${BOLD}PM Shortcuts:${NC}"
echo -e "    ${BLUE}sprint-report${NC}  — Generate a sprint status report"
echo -e "    ${BLUE}issue-triage${NC}   — AI-assisted issue triage"
echo -e "    ${BLUE}pr-summary${NC}     — Summarize PR activity"
echo -e "    ${BLUE}ci-status${NC}      — Check CI/CD pipeline status"
echo ""
echo -e "  ${BOLD}Developer Shortcuts:${NC}"
echo -e "    ${BLUE}code-review${NC}    — AI-assisted code review"
echo -e "    ${BLUE}dependency-check${NC} — Audit dependencies"
echo -e "    ${BLUE}release-prep${NC}   — Prepare a release"
echo ""
echo -e "  ${BOLD}QA/Tester Shortcuts:${NC}"
echo -e "    ${BLUE}test-status${NC}    — Test run results summary"
echo -e "    ${BLUE}bug-tracker${NC}    — Open bug summary"
echo -e "    ${BLUE}test-coverage${NC}  — Test coverage metrics"
echo ""
echo -e "  ${BOLD}Documentation:${NC} Open ${BLUE}docs/${NC} folder or read ${BLUE}README.md${NC}"
echo ""
