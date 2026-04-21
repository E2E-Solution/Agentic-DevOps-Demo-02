# QA/Tester Onboarding Guide

Welcome to **Agentic DevOps for QA Engineers**! This guide gets your testing environment ready.

---

## Step 1: Open the Terminal

When your Codespace loads, you should see a terminal at the bottom of the screen. If not:
- Press `` Ctrl+` `` (backtick) to open the terminal
- Or go to **Terminal → New Terminal** in the menu bar

## Step 2: Verify Your Environment

Run the health check to make sure all tools are working:

```bash
health-check
```

This confirms that GitHub CLI, Copilot CLI, and your testing tools are properly configured. Fix any issues it reports before moving on.

## Step 3: Authenticate with GitHub

If you're not already logged in:

```bash
gh auth login
```

> **Note:** GitHub Codespaces usually handles authentication automatically. Run `gh auth status` to check — if you see your username, you're all set.

## Step 4: Connect to Your Repository

Clone the repository you'll be testing:

```bash
gh repo clone your-org/your-repo
cd your-repo
```

Replace `your-org/your-repo` with your actual project. All QA scripts and commands will use this repo's data.

## Step 5: Launch GitHub Copilot CLI

Start your AI assistant:

```bash
copilot
```

Try these QA-focused prompts to get started:

- `"Show me all open bugs in this repo"`
- `"What tests are failing in CI?"`
- `"Help me write a test plan for the latest feature"`

Type `/help` inside Copilot CLI to see all available commands.

## Step 6: QA Scripts Overview

Run any of these scripts from your repo directory:

| Command | What It Does |
|---------|--------------|
| `test-status` | Shows current test pass/fail rates from CI |
| `bug-tracker` | Summarizes open bugs by severity and assignee |
| `test-coverage` | Reports code coverage metrics from recent runs |
| `ci-status` | Checks pipeline health and recent workflow runs |
| `health-check` | Verifies your environment is working |

Example — check your current test health:

```bash
test-status
```

## Step 7: Explore QA Prompt Templates

Browse tested prompts designed for QA workflows:

```bash
ls prompts/
cat prompts/test-planning.md
```

Key templates for QA engineers:

| Template | Use Case |
|----------|----------|
| `prompts/test-planning.md` | Generate test cases and regression plans |
| `prompts/bug-analysis.md` | Analyze bug patterns and root causes |
| `prompts/quality-report.md` | Build quality status reports |

Copy any prompt, start `copilot`, and paste it in to get AI-powered testing assistance.

## Step 8: Understanding GitHub Actions for Test Results

Test results live in GitHub Actions. To check the latest runs:

```bash
gh run list --limit 10
```

To see details on a failed run:

```bash
gh run view <run-id> --log-failed
```

Look for test summary annotations in the Actions tab of your repository — they show pass/fail counts and failure details at a glance.

---

## What's Next?

- 🧪 Read the [Test Planning Guide](qa-02-test-planning.md) for AI-assisted test case generation
- 🐛 Read the [Defect Management Guide](qa-03-defect-management.md) to track and analyze bugs
- 📊 Read the [Quality Reporting Guide](qa-04-quality-reporting.md) to build stakeholder reports

---

## Need Help?

- Run `health-check` to diagnose environment issues
- Run `welcome` to go through the onboarding again
- Ask Copilot CLI: `"Help me get started with QA"` — it knows this workspace!
