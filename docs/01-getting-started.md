# Getting Started

Welcome to **Agentic DevOps for Project Managers**! This guide walks you through your first session.

---

## Step 1: Open the Terminal

When your Codespace loads, you should see a terminal at the bottom of the screen. If not:
- Press `` Ctrl+` `` (backtick) to open the terminal
- Or go to **Terminal → New Terminal** in the menu bar

## Step 2: Run the Welcome Script

Type this in the terminal and press Enter:

```bash
welcome
```

This interactive wizard will:
1. Check if you're logged in to GitHub
2. Help you authenticate if needed
3. Show you what tools are available
4. Let you try some actions right away

## Step 3: Authenticate with GitHub

If you're not already logged in, the welcome script will help. You can also log in manually:

```bash
gh auth login
```

Follow the on-screen instructions — you'll be directed to a web page to confirm your login.

> **Note:** GitHub Codespaces usually handles authentication automatically. If you see your username when you run `gh auth status`, you're already logged in!

## Step 4: Launch GitHub Copilot CLI

This is your main AI assistant. Start it by typing:

```bash
copilot
```

You'll see a prompt where you can type questions in plain English. Try these:

- `"What can you do?"`
- `"Show me all open issues in this repo"`
- `"Help me triage the open bugs"`

Type `/help` inside Copilot CLI to see all available commands.

## Step 5: Connect to Your Repository

To work with your project's data, clone your repository:

```bash
gh repo clone your-org/your-repo
cd your-repo
```

Replace `your-org/your-repo` with your actual organization and repository name.

Now all scripts and Copilot commands will use your repo's data!

## Step 6: Try the PM Scripts

Run any of these scripts from your repo directory:

| Command | What It Does |
|---------|--------------|
| `sprint-report` | Generates a sprint status report |
| `issue-triage` | Shows issues that need labeling/assignment |
| `pr-summary` | Summarizes pull request activity |
| `ci-status` | Checks CI/CD pipeline health |
| `health-check` | Verifies your environment is working |

## Step 7: Explore Prompt Templates

Browse tested prompts you can use with Copilot CLI:

```bash
ls prompts/
cat prompts/project-planning.md
```

Copy any prompt, start `copilot`, and paste it in to get AI-powered help.

---

## What's Next?

- 📖 Read the [Project Planning Guide](02-project-planning.md) to manage issues and milestones
- 🏷️ Read the [Issue Triage Guide](03-issue-triage.md) for AI-assisted triage
- 🔀 Read the [PR Review Guide](04-pr-review-oversight.md) to monitor pull requests
- ⚙️ Read the [CI/CD Guide](05-ci-cd-monitoring.md) to understand build pipelines
- 📧 Read the [WorkIQ Guide](06-workplace-intelligence.md) to connect to Microsoft 365

---

## Need Help?

- Run `health-check` to diagnose environment issues
- Run `welcome` to go through the onboarding again
- Ask Copilot CLI: `"Help me get started"` — it knows this workspace!
