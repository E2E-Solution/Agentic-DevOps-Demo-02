# Developer Onboarding Guide

Welcome to **Agentic DevOps for Developers**! This guide walks you through setting up your development environment.

---

## Step 1: Verify Prerequisites

Run the developer setup checker to confirm your environment is ready:

```bash
dev-setup
```

This script validates:
1. Git is installed and configured
2. GitHub CLI (`gh`) is authenticated
3. Copilot CLI is available
4. Required shell aliases are loaded

If anything is missing, the script provides instructions to fix it.

## Step 2: Authenticate with GitHub

If `dev-setup` reports you're not authenticated:

```bash
gh auth login
gh auth status
```

For SSH-based workflows, make sure your SSH key is registered:

```bash
gh ssh-key list
```

## Step 3: Clone and Configure Your Repository

Clone the repo you'll be working on:

```bash
gh repo clone your-org/your-repo
cd your-repo
```

Set up your Git identity if not already configured:

```bash
git config user.name "Your Name"
git config user.email "you@example.com"
```

Create a working branch:

```bash
git checkout -b feature/your-feature main
```

## Step 4: Explore Developer Scripts

These scripts are available from the terminal:

| Command | What It Does |
|---------|--------------|
| `dev-setup` | Checks prerequisites and environment health |
| `code-review` | Analyzes open PRs for risk and quality |
| `test-status` | Shows test results across recent runs |
| `test-coverage` | Reports code coverage metrics |
| `dependency-check` | Audits dependencies for issues |
| `release-prep` | Prepares a release with checks and changelog |
| `ci-status` | Shows CI/CD pipeline health |
| `health-check` | Verifies the full environment is working |

Run any script without arguments to see its usage information.

## Step 5: Use Developer Prompt Templates

The `prompts/` directory contains tested prompts for Copilot CLI:

```bash
ls prompts/
cat prompts/code-review.md
```

Key templates for developers:

| Template | Use Case |
|----------|----------|
| `prompts/code-review.md` | Structured PR review guidance |
| `prompts/debugging.md` | Diagnosing failures and tracing bugs |
| `prompts/architecture.md` | Understanding system design decisions |
| `prompts/test-planning.md` | Planning test coverage for new features |
| `prompts/bug-analysis.md` | Root cause analysis for reported bugs |

To use a template, start Copilot CLI and paste the prompt:

```bash
copilot
# Then paste or type a prompt from the template
```

## Step 6: Verify Everything Works

Run a quick smoke test of your environment:

```bash
health-check
ci-status
```

Both should complete without errors. If you see warnings, follow the suggested fixes.

---

## What's Next?

- 🔍 Read the [Code Review Guide](dev-02-code-review.md) for AI-assisted PR reviews
- 🐛 Read the [Debugging Guide](dev-03-debugging.md) to diagnose failures with AI
- 🚀 Read the [Release Management Guide](dev-04-release.md) to ship with confidence

---

## Need Help?

- Run `dev-setup` to re-check your environment
- Run `health-check` to diagnose broader issues
- Ask Copilot CLI: `"Help me set up my dev environment"` — it knows this workspace!
