# Defect Tracking and Management

Track, analyze, and manage bugs effectively using Agentic DevOps tools.

---

## Getting a Bug Overview

Run the bug tracker script to see the current state of defects:

```bash
bug-tracker
```

This gives you a summary of open bugs by severity, assignee, and age — a quick snapshot of defect health.

To dig deeper with the GitHub CLI:

```bash
gh issue list --label "bug" --state open
```

Filter by priority or severity:

```bash
gh issue list --label "bug,high-priority" --state open
gh issue list --label "bug" --search "sort:created-desc"
```

## Using Bug Analysis Prompts

Load the bug analysis prompt template for AI-powered defect insights:

```bash
cat prompts/bug-analysis.md
```

Copy a prompt into `copilot` to get help with:

- `"Analyze the root cause of bug #87"`
- `"Are there patterns in our recent bugs?"`
- `"Which component has the most open defects?"`

## Filing Effective Bug Reports

A good bug report saves hours of developer time. Include these elements every time:

| Section | What to Include |
|---------|-----------------|
| **Title** | Clear, specific summary (e.g., "Login fails with special characters in password") |
| **Steps to Reproduce** | Numbered steps anyone can follow |
| **Expected Result** | What should happen |
| **Actual Result** | What actually happens |
| **Environment** | Browser, OS, version, deployment |
| **Evidence** | Screenshots, logs, error messages |

Create a bug from the command line:

```bash
gh issue create --label "bug" --title "Login fails with special characters" \
  --body-file bug-report.md
```

> **Tip:** Ask Copilot to help draft the report: `"Help me write a bug report for a login failure I found"`

## Analyzing Bug Trends and Patterns

Spot recurring quality issues by looking at defect trends. Ask Copilot:

- `"What are the most common types of bugs filed this month?"`
- `"Which areas of the codebase have the most bugs?"`
- `"Show me bug trends over the last 3 sprints"`

Useful commands for trend analysis:

```bash
gh issue list --label "bug" --state closed --search "closed:>2024-01-01"
gh issue list --label "bug" --state open --search "created:>2024-01-01"
```

Look for patterns in:
- **Component** — Is one module producing most bugs?
- **Root cause** — Are bugs from missed requirements, regressions, or integration gaps?
- **Timing** — Do bugs spike after certain types of changes?

## Severity and Priority Classification

Use consistent labels so the team shares a common understanding of urgency:

| Severity | Meaning | Example |
|----------|---------|---------|
| **Critical** | System down, data loss, no workaround | Payment processing crashes |
| **High** | Major feature broken, workaround exists | Search returns wrong results |
| **Medium** | Feature partially working, minor impact | Sorting ignores accented characters |
| **Low** | Cosmetic or minor inconvenience | Button alignment off by 2 pixels |

**Priority** is separate from severity — it reflects business urgency:

- **P1** — Fix immediately (blocks release or users)
- **P2** — Fix this sprint
- **P3** — Fix when capacity allows
- **P4** — Nice to have, backlog

Apply labels from the command line:

```bash
gh issue edit 87 --add-label "severity:high,priority:P2"
```

---

## What's Next?

- 📊 Read the [Quality Reporting Guide](qa-04-quality-reporting.md) to report on defect metrics
- 🧪 Read the [Test Planning Guide](qa-02-test-planning.md) to prevent bugs with better test coverage
- 🏁 Read the [QA Setup Guide](qa-01-setup.md) if you haven't set up your environment yet

---

## Need Help?

- Run `bug-tracker` for a quick defect summary
- Browse `prompts/bug-analysis.md` for ready-to-use prompts
- Ask Copilot CLI: `"Help me analyze our open bugs"`
