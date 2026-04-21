#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic DevOps — Welcome & Onboarding
# =============================================================================
# Guided first-launch experience for project managers.
# Walks you through authentication and shows you what you can do.
# =============================================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${CYAN}"
cat << 'BANNER'

    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║     █████╗  ██████╗ ███████╗███╗   ██╗████████╗██╗ ██████╗║
    ║    ██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝██║██╔════╝║
    ║    ███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║   ██║██║     ║
    ║    ██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║   ██║██║     ║
    ║    ██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║   ██║╚██████╗║
    ║    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝ ╚═════╝║
    ║                                                           ║
    ║           ██████╗ ███████╗██╗   ██╗ ██████╗ ██████╗ ███████╗║
    ║           ██╔══██╗██╔════╝██║   ██║██╔═══██╗██╔══██╗██╔════╝║
    ║           ██║  ██║█████╗  ██║   ██║██║   ██║██████╔╝███████╗║
    ║           ██║  ██║██╔══╝  ╚██╗ ██╔╝██║   ██║██╔═══╝ ╚════██║║
    ║           ██████╔╝███████╗ ╚████╔╝ ╚██████╔╝██║     ███████║║
    ║           ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚══════╝║
    ║                                                           ║
    ║     AI-Powered Project Management with GitHub Copilot     ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝

BANNER
echo -e "${NC}"

echo -e "${BOLD}Welcome to Agentic DevOps for Project Managers!${NC}"
echo ""
echo -e "This environment gives you AI-powered tools to manage your"
echo -e "GitHub projects — no technical setup required."
echo ""

# ---------------------------------------------------------------------------
# Step 1: Check GitHub CLI Authentication
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Step 1: GitHub Authentication ──${NC}"
echo ""

if gh auth status &>/dev/null 2>&1; then
    GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
    echo -e "  ${GREEN}✓${NC} You're logged in to GitHub as ${BOLD}@$GH_USER${NC}"
else
    echo -e "  ${YELLOW}⚠${NC} You need to log in to GitHub first."
    echo ""
    echo -e "  ${BOLD}Running GitHub login...${NC}"
    echo -e "  Follow the instructions in your browser."
    echo ""
    gh auth login --web --git-protocol https 2>&1 || {
        echo -e "  ${RED}Login failed or was cancelled.${NC}"
        echo -e "  You can try again later with: ${BOLD}gh auth login${NC}"
    }
fi
echo ""

# ---------------------------------------------------------------------------
# Step 2: Check Copilot CLI
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Step 2: GitHub Copilot CLI ──${NC}"
echo ""

if command -v copilot &>/dev/null || gh copilot --version &>/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} GitHub Copilot CLI is available"
    echo -e "  To start an AI-powered session, run: ${BOLD}gh copilot${NC}"
    echo ""
    echo -e "  ${BLUE}Copilot CLI is your main tool for AI-assisted project management.${NC}"
    echo -e "  You can ask it questions in plain English, like:"
    echo -e "    • ${CYAN}\"Show me all open issues labeled as bug\"${NC}"
    echo -e "    • ${CYAN}\"Create a milestone for the Q3 release\"${NC}"
    echo -e "    • ${CYAN}\"Summarize what changed in PR #42\"${NC}"
else
    echo -e "  ${RED}✗${NC} Copilot CLI not found."
    echo -e "  Fix: Run ${BOLD}gh extension install github/gh-copilot${NC}"
fi
echo ""

# ---------------------------------------------------------------------------
# Step 3: Check WorkIQ
# ---------------------------------------------------------------------------
echo -e "${BOLD}── Step 3: Microsoft WorkIQ (Microsoft 365 Integration) ──${NC}"
echo ""

if command -v workiq &>/dev/null 2>&1 || npm list -g @microsoft/workiq &>/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Microsoft WorkIQ is installed"
    echo -e ""
    echo -e "  WorkIQ connects to your Microsoft 365 data (emails, meetings,"
    echo -e "  Teams messages, documents) through GitHub Copilot CLI."
    echo -e ""
    echo -e "  ${YELLOW}Note:${NC} Your M365 admin must approve WorkIQ for your tenant."
    echo -e "  Ask your IT admin about WorkIQ access if you haven't already."
else
    echo -e "  ${YELLOW}⚠${NC} WorkIQ is not installed."
    echo -e "  Fix: Run ${BOLD}npm install -g @microsoft/workiq${NC}"
fi
echo ""

# ---------------------------------------------------------------------------
# Step 4: Quick Start Menu
# ---------------------------------------------------------------------------
echo -e "${BOLD}── What Would You Like to Do? ──${NC}"
echo ""
echo -e "  ${GREEN}1${NC})  ${BOLD}Launch Copilot CLI${NC} — Start an AI-powered session"
echo -e "  ${GREEN}2${NC})  ${BOLD}View my GitHub issues${NC} — See issues assigned to you"
echo -e "  ${GREEN}3${NC})  ${BOLD}Check CI/CD status${NC} — View recent workflow runs"
echo -e "  ${GREEN}4${NC})  ${BOLD}Generate a sprint report${NC} — Get project status summary"
echo -e "  ${GREEN}5${NC})  ${BOLD}Run health check${NC} — Verify all tools are working"
echo -e "  ${GREEN}6${NC})  ${BOLD}Read the docs${NC} — Open the getting started guide"
echo -e "  ${GREEN}7${NC})  ${BOLD}Developer tools${NC} — Code review, dependency check, release prep"
echo -e "  ${GREEN}8${NC})  ${BOLD}QA/Tester tools${NC} — Test status, bug tracker, coverage"
echo -e "  ${GREEN}q${NC})  ${BOLD}Exit${NC} — Close this wizard"
echo ""

while true; do
    read -rp "$(echo -e "${BOLD}Choose an option (1-8, q): ${NC}")" choice
    case "$choice" in
        1)
            echo ""
            echo -e "${BLUE}Launching GitHub Copilot CLI...${NC}"
            echo -e "Type ${BOLD}/help${NC} to see available commands."
            echo ""
            copilot || gh copilot || echo -e "${YELLOW}Copilot CLI exited. Run 'gh copilot' to start again.${NC}"
            break
            ;;
        2)
            echo ""
            echo -e "${BLUE}Fetching your assigned issues...${NC}"
            echo ""
            gh issue list --assignee @me --limit 20 2>/dev/null || {
                echo -e "${YELLOW}Could not fetch issues. Make sure you're authenticated (gh auth login)${NC}"
                echo -e "${YELLOW}and have a repository set (cd into a cloned repo first).${NC}"
            }
            echo ""
            ;;
        3)
            echo ""
            echo -e "${BLUE}Checking CI/CD status...${NC}"
            echo ""
            bash "$(dirname "$0")/ci-status.sh" 2>/dev/null || {
                echo -e "${YELLOW}CI status script needs a repository context.${NC}"
                echo -e "Clone a repo first: ${BOLD}gh repo clone owner/repo${NC}"
            }
            echo ""
            ;;
        4)
            echo ""
            bash "$(dirname "$0")/sprint-report.sh" 2>/dev/null || {
                echo -e "${YELLOW}Sprint report needs a repository context.${NC}"
                echo -e "Clone a repo first: ${BOLD}gh repo clone owner/repo${NC}"
            }
            echo ""
            ;;
        5)
            echo ""
            bash "$(dirname "$0")/health-check.sh"
            echo ""
            ;;
        6)
            echo ""
            echo -e "${BLUE}Opening the getting started guide...${NC}"
            SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
            REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
            if command -v code &>/dev/null; then
                code "$REPO_ROOT/docs/01-getting-started.md" 2>/dev/null || cat "$REPO_ROOT/docs/01-getting-started.md" 2>/dev/null
            else
                cat "$REPO_ROOT/docs/01-getting-started.md" 2>/dev/null || echo "Guide not found."
            fi
            echo ""
            ;;
        7)
            echo ""
            echo -e "${BOLD}── Developer Tools ──${NC}"
            echo ""
            echo -e "  ${GREEN}code-review${NC}       — AI-assisted code review helper"
            echo -e "  ${GREEN}dependency-check${NC}  — Check for outdated/vulnerable dependencies"
            echo -e "  ${GREEN}release-prep${NC}      — Release preparation helper"
            echo -e "  ${GREEN}dev-setup${NC}         — Developer environment onboarding"
            echo ""
            echo -e "  Run any command above, or ask Copilot CLI for help."
            echo ""
            ;;
        8)
            echo ""
            echo -e "${BOLD}── QA/Tester Tools ──${NC}"
            echo ""
            echo -e "  ${GREEN}test-status${NC}       — Test run results summary"
            echo -e "  ${GREEN}bug-tracker${NC}       — Open bug summary and trends"
            echo -e "  ${GREEN}test-coverage${NC}     — Test coverage metrics"
            echo ""
            echo -e "  Run any command above, or ask Copilot CLI for help."
            echo ""
            ;;
        q|Q)
            echo ""
            echo -e "${GREEN}Happy managing! Run 'welcome' anytime to see this again.${NC}"
            echo ""
            break
            ;;
        *)
            echo -e "${YELLOW}Please choose 1-8 or q to exit.${NC}"
            ;;
    esac
done
