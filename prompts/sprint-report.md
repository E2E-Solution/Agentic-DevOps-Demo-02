# Prompt Templates: Sprint Reporting

Ready-to-use prompts for generating project status reports.

---

## Sprint Status Report

> Generate a sprint status report for the last 2 weeks. Include:
> - Issues closed vs. opened
> - PRs merged
> - Top contributors
> - Key blockers
> - Velocity trend compared to previous sprints

## Executive Summary

> Create a one-paragraph executive summary of the project's current status.
> Focus on: progress toward goals, key risks, and what stakeholders need
> to know. Keep it under 100 words.

## Release Notes Draft

> Based on the PRs merged since the last release tag, draft user-facing
> release notes. Group changes by: New Features, Bug Fixes, Improvements.
> Use plain language — these are for end users, not developers.

## Burndown Analysis

> Analyze our sprint burndown. Based on the rate of issue closure, are
> we on track to finish the milestone by the due date? If not, how many
> issues should we descope?

## Team Velocity Report

> Calculate team velocity for the last 4 sprints:
> - Issues closed per sprint
> - Story points completed (if using labels)
> - Average cycle time (issue open to close)
> Show the trend — are we getting faster or slower?

## Blocker Report

> List all current blockers:
> - Issues labeled "blocked" or "high-priority"
> - PRs with failing CI that haven't been fixed
> - Issues assigned but with no activity in 5+ days
> For each blocker, suggest an action to unblock it.

## Stakeholder Update Email

> Draft a stakeholder update email covering:
> - What we accomplished this sprint
> - What we're working on next sprint
> - Any risks or decisions needed
> Keep it professional and concise.

## Retrospective Data

> Pull data for our sprint retrospective:
> - What went well (issues closed, PRs merged quickly)
> - What could be improved (stale PRs, review delays, CI failures)
> - Metrics comparison to last sprint
