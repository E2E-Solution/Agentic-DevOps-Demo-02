# AI-Assisted Code Review

This guide covers how to use AI tools to review pull requests efficiently and catch issues early.

---

## Step 1: Run the Code Review Script

Start by getting an overview of open PRs:

```bash
code-review
```

This script scans open pull requests and highlights:
1. Large diffs that need careful attention
2. PRs with no test changes
3. PRs with failing CI checks
4. Stale PRs that have been open too long

## Step 2: Review a Specific PR

Drill into a specific pull request using the GitHub CLI:

```bash
gh pr view 42
gh pr diff 42
gh pr checks 42
```

For a summary of what changed and why:

```bash
gh pr view 42 --comments
```

## Step 3: Use Copilot CLI for Deeper Review

Start Copilot CLI and use prompts from the code review template:

```bash
copilot
```

Try these prompts (adapted from `prompts/code-review.md`):

- `"Review the diff for PR #42 and summarize the changes"`
- `"Are there any security concerns in PR #42?"`
- `"Does PR #42 include adequate test coverage?"`
- `"What are the risk areas in this pull request?"`

Copilot CLI has access to the repository context and can read diffs directly.

## Understanding Risk Indicators

When reviewing PRs, watch for these signals:

| Indicator | Why It Matters |
|-----------|----------------|
| **Large diff (500+ lines)** | Hard to review thoroughly; suggest splitting |
| **No test changes** | New code without tests increases regression risk |
| **Failing CI** | Do not approve until all checks pass |
| **No description** | Missing context makes review error-prone |
| **Force pushes** | Previous review comments may be outdated |
| **Long-lived branch** | Likely to have merge conflicts; may need rebase |

## Step 4: Leave Structured Feedback

Use the GitHub CLI to comment on PRs:

```bash
gh pr comment 42 --body "Reviewed with AI assistance. Summary: ..."
```

To request changes:

```bash
gh pr review 42 --request-changes --body "See inline comments"
```

To approve:

```bash
gh pr review 42 --approve --body "LGTM — changes look good"
```

## Quick Reference

Common commands for code review workflows:

```bash
# List all open PRs
gh pr list

# List PRs that need your review
gh pr list --search "review-requested:@me"

# View PR details with full context
gh pr view 42 --web

# Check CI status for a PR
gh pr checks 42

# Check out a PR locally to test
gh pr checkout 42

# Run the full review script
code-review
```

---

## Best Practices

- **Review in layers** — Read the description first, then the diff, then run tests locally if needed.
- **Use AI for first pass** — Let Copilot CLI flag risk areas, then apply your judgment.
- **Keep reviews timely** — Stale PRs block the team. Aim to review within one business day.
- **Be specific in feedback** — Reference file names and line numbers when requesting changes.
- **Check the tests** — Even if CI passes, verify that new tests actually cover the changed behavior.

---

## What's Next?

- 🐛 Read the [Debugging Guide](dev-03-debugging.md) to diagnose CI failures during review
- 🚀 Read the [Release Management Guide](dev-04-release.md) to understand how reviewed code gets shipped
- 📖 See `prompts/code-review.md` for more review prompts to use with Copilot CLI
