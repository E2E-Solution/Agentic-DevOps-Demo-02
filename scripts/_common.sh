#!/usr/bin/env bash
# =============================================================================
# Agentic DevOps — Shared Script Library
# =============================================================================
# Common functions and variables used by all PM/Dev/QA scripts.
# Source this file at the top of any script:
#   SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#   source "$SCRIPT_DIR/_common.sh"
# =============================================================================

# ---------------------------------------------------------------------------
# Colors & Formatting
# ---------------------------------------------------------------------------
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ---------------------------------------------------------------------------
# Logging Helpers
# ---------------------------------------------------------------------------
log_step() { echo -e "${BLUE}▶${NC} $1"; }
log_ok()   { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_fail() { echo -e "${RED}✗${NC} $1"; }

# ---------------------------------------------------------------------------
# Prerequisite Checks
# ---------------------------------------------------------------------------

# Check that gh CLI is installed
require_gh() {
    if ! command -v gh &>/dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) is required but not installed.${NC}"
        echo -e "  If you're in a Codespace, try rebuilding the container."
        echo -e "  Otherwise, see: https://cli.github.com/manual/installation"
        exit 1
    fi
}

# Check that gh CLI is authenticated
require_gh_auth() {
    require_gh
    if ! gh auth status &>/dev/null 2>&1; then
        echo -e "${RED}Error: Not authenticated with GitHub CLI.${NC}"
        echo -e "  Run: ${BOLD}gh auth login${NC}"
        exit 1
    fi
}

# Check that we're inside a Git repository (or --repo flag was provided)
require_repo_context() {
    local repo_flag="$1"
    if [ -z "$repo_flag" ] && ! git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
        echo -e "${RED}Error: Not inside a Git repository.${NC}"
        echo -e ""
        echo -e "  You can either:"
        echo -e "    1. ${BOLD}cd${NC} into a cloned repository first"
        echo -e "    2. Use the ${BOLD}--repo owner/repo${NC} flag"
        echo -e ""
        echo -e "  Example: ${BOLD}$(basename "$0") --repo your-org/your-repo${NC}"
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Common Argument Helpers
# ---------------------------------------------------------------------------

# Print a standard header box
print_header() {
    local title="$1"
    echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  ${title}${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Print a section divider
print_section() {
    echo -e "${BOLD}── $1 ──${NC}"
    echo ""
}

# Print a tip line
print_tip() {
    echo -e "  ${CYAN}Tip:${NC} $1"
}
