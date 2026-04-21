# Prompt Templates: Issue Triage

Ready-to-use prompts for triaging and managing issues.

---

## Auto-Label Issues

> Look at all unlabeled open issues in this repo. For each one, read the
> title and description and suggest appropriate labels from: bug, enhancement,
> documentation, question, good-first-issue, high-priority, low-priority.

## Find Stale Issues

> Show me issues that haven't had any activity in the last 30 days.
> For each one, suggest whether to: close it, re-prioritize it, or
> ping the assignee.

## Identify Duplicate Issues

> Check the open issues for potential duplicates. Look for issues with
> similar titles or descriptions and suggest which ones might be the same.

## Prioritize the Backlog

> Review all open issues and sort them by priority. Consider:
> - How many users does this affect?
> - Is it blocking other work?
> - How old is the issue?
> - Does it have a lot of reactions/comments?

## Assign Issues to Team Members

> Look at the open unassigned issues. Based on who has been working on
> related code recently (from commit and PR history), suggest who should
> own each issue.

## Create a Bug Report Template Response

> I need to respond to issue #[NUMBER]. The bug report is missing
> reproduction steps. Draft a friendly response asking for:
> - Steps to reproduce
> - Expected behavior
> - Actual behavior
> - Browser/OS information

## Bulk Update Issues

> Move all issues labeled "v1.0" that are still open to the "v1.1" milestone.
> Add a comment explaining the re-prioritization.

## Weekly Triage Summary

> Generate a weekly triage summary showing:
> - New issues opened this week
> - Issues closed this week
> - Issues that need triage (no label or assignee)
> - Oldest open issues that need attention
