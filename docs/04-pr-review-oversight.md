# PR Review Oversight

Monitor pull request activity, identify bottlenecks, and keep code reviews moving.

---

## What Are Pull Requests?

A **pull request (PR)** is how developers propose changes to the codebase. As a PM, you need to monitor:
- Are PRs being reviewed in a timely manner?
- Are CI checks passing?
- Are there bottlenecks slowing down the team?

---

## Quick Start: Run the PR Summary Script

```bash
pr-summary
```

This shows you:
- All open PRs with their review status
- Recently merged PRs
- Stale PRs that need attention
- Review bottleneck analysis

### Script Options

```bash
pr-summary --days 14            # Last 14 days (default: 7)
pr-summary --repo your-org/repo # Specific repository
```

---

## Understanding PR Status

| Status | What It Means | Action Needed? |
|--------|---------------|----------------|
| 🟡 **Review Required** | PR needs someone to review it | Find a reviewer |
| 🟢 **Approved** | Reviewed and approved | Can be merged |
| 🔴 **Changes Requested** | Reviewer wants changes | Developer needs to update |
| ⚪ **Draft** | Work in progress | No action needed yet |
| ❌ **CI Failing** | Automated checks are failing | Developer needs to fix |

---

## AI-Powered PR Oversight

### Get a Plain-Language PR Summary
> "Explain what PR #42 changes in simple terms. What problem does it solve and what's the risk?"

### Find Review Bottlenecks
> "Which PRs have been waiting longest for review? Who should review them?"

### Check Merge Readiness
> "Is PR #42 ready to merge? Check CI status, reviews, and conflicts."

### Review Activity Report
> "How active are code reviews this week? Who's doing the most reviews?"

---

## Common PR Management Actions

### Request a Review
```bash
gh pr edit 42 --add-reviewer @reviewer-username
```

### Check PR Status
```bash
gh pr view 42
```

### List All Open PRs
```bash
gh pr list --state open
```

### See PR Checks
```bash
gh pr checks 42
```

---

## Key Metrics to Track

As a PM, watch for these signals:

- **PR Age** — PRs open longer than 3-5 days may indicate review bottlenecks
- **Review Time** — Time from PR open to first review should be < 24 hours
- **Merge Time** — Time from PR open to merge should ideally be < 3 days
- **Reviewer Load** — If one person is reviewing everything, spread the load

---

## Prompt Templates

See [prompts/pr-review.md](../prompts/pr-review.md) for more PR oversight prompts.
