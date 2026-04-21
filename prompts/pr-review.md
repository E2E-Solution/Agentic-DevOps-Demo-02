# Prompt Templates: PR Review Oversight

Ready-to-use prompts for monitoring and managing pull requests.

---

## Summarize a PR in Plain Language

> Explain what PR #[NUMBER] changes in simple terms. I'm not a developer —
> tell me what it does, why it matters, and if there are any risks.

## PR Status Dashboard

> Show me all open PRs with their status:
> - Who opened it and when
> - Whether it's been reviewed
> - Whether CI checks are passing
> - How many files it changes
>
> Flag any that need my attention.

## Find Review Bottlenecks

> Which PRs have been waiting longest for review? Who are the reviewers
> and can we reassign to unblock them?

## Check for Stale PRs

> Find PRs that have been open for more than 7 days. Are they blocked
> on review, failing CI, or just forgotten?

## Review Activity Report

> Generate a report of review activity for the last week:
> - How many PRs were reviewed and by whom
> - Average time from PR open to first review
> - Average time from PR open to merge
> - Who are our most active reviewers?

## Request Reviews

> PR #[NUMBER] has been open for 3 days with no reviewers. Based on
> who has expertise in the changed files, suggest 2-3 people to review it.

## Merge Readiness Check

> Is PR #[NUMBER] ready to merge? Check:
> - All CI checks passing
> - At least one approval
> - No unresolved review comments
> - No merge conflicts
> Give me a clear yes/no with details.

## Compare PR to Issue Requirements

> PR #[NUMBER] is supposed to fix issue #[NUMBER]. Does the PR actually
> address all the requirements described in the issue? Are there any gaps?
