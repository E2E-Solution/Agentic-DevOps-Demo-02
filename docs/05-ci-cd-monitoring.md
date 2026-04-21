# CI/CD Monitoring

Understand your build pipelines and deployment status without needing to read code.

---

## What Is CI/CD?

- **CI (Continuous Integration)** — Automated checks that run when code changes are proposed. They verify the code works correctly (tests, linting, security scans).
- **CD (Continuous Deployment)** — Automated processes that deploy code to production or staging environments.

As a PM, you need to know:
- Are our builds passing? ✅
- Is anything broken? ❌
- Has the latest code been deployed? 🚀

---

## Quick Start: Check Pipeline Status

```bash
ci-status
```

This shows you:
- Recent workflow runs with pass/fail status
- Failed runs that need developer attention
- Grouped by workflow name for easy scanning

### Script Options

```bash
ci-status --repo your-org/repo   # Specific repository
ci-status --limit 20             # Show more runs
```

---

## Understanding Workflow Status

| Icon | Status | What It Means |
|------|--------|---------------|
| ✅ | **Success** | Everything passed — code is good |
| ❌ | **Failure** | Something broke — developer needs to fix it |
| 🔄 | **In Progress** | Currently running |
| ⏳ | **Queued** | Waiting to start |
| ⚪ | **Cancelled** | Run was stopped manually |

---

## Common CI/CD Commands

### List Recent Runs
```bash
gh run list --limit 10
```

### View a Specific Run
```bash
gh run view 12345
```

### See Why a Run Failed
```bash
gh run view 12345 --log-failed
```

### Re-Run a Failed Workflow
```bash
gh run rerun 12345
```

### List All Workflows
```bash
gh workflow list
```

---

## AI-Powered CI/CD Monitoring

Ask Copilot CLI:

### Understand Failures
> "The CI pipeline is failing on the main branch. Can you tell me why in plain language?"

### Check Deployment Status
> "What's the latest deployment status? Is the production environment up to date?"

### Identify Patterns
> "Have our CI pipelines been failing more often recently? What's the trend?"

### Get Recommendations
> "Our build times have been increasing. Can you analyze what's slowing things down?"

---

## What to Watch For

### Red Flags 🚩
- **Repeated failures on main branch** — This is urgent. The main codebase may be broken.
- **Failed deployments** — New features aren't reaching users.
- **Long build times** — Slows down the entire team.

### Healthy Signs ✅
- **Mostly green builds** — The team is maintaining code quality.
- **Quick fix times** — Failures are resolved within hours, not days.
- **Regular deployments** — New code ships frequently and reliably.

---

## Tips for PMs

1. **Check CI status daily** — Make it part of your morning routine
2. **Include CI health in standups** — "Are all builds green?"
3. **Escalate repeated failures** — If the same workflow fails for more than a day, involve the tech lead
4. **Understand deploy schedules** — Know when your team deploys and how to check status
