# Prompt Templates: Bug Analysis

Ready-to-use prompts for analyzing bugs and managing defects.

---

## Analyze Bug Patterns and Trends

> Look at all issues labeled "bug" in this repo. Identify patterns:
> - Which areas of the codebase have the most bugs?
> - Are bugs increasing or decreasing over time?
> - Are there common root causes (e.g., missing validation, race conditions)?
> Summarize the top 3 trends and suggest where to focus quality improvements.

## Investigate Root Cause from a Bug Report

> Read issue #[NUMBER] and investigate the likely root cause. Based on
> the bug description and the relevant code, explain:
> - What is probably going wrong
> - Which files or components are involved
> - Whether this could affect other areas of the system
> Keep the explanation non-technical — I need to communicate this to stakeholders.

## Find Duplicate or Related Bugs

> Check whether issue #[NUMBER] is a duplicate of or related to any
> existing open or recently closed issues. Look for bugs with similar
> symptoms, affected components, or error messages. List any matches
> with a confidence level (likely duplicate, possibly related, different issue).

## Assess Regression Risk for a Code Change

> PR #[NUMBER] is about to merge. Based on the files changed, assess
> the risk of introducing regressions:
> - Which existing features could be affected?
> - Are there bugs in the history of these files?
> - What is the overall risk level (high, medium, low)?
> Recommend specific areas to retest before merging.

## Recommend Bug Severity and Priority

> Review the open issues labeled "bug" that don't have a severity or
> priority assigned. For each one, recommend:
> - Severity (critical, major, minor, cosmetic)
> - Priority (P1–P4)
> - Brief justification for your recommendation
> Use these criteria: user impact, workaround availability, and frequency.

## Bug Escape Analysis

> Compare bugs found in production (labeled "production" or "escaped")
> against bugs caught during testing. For each escaped bug:
> - When was it introduced (which PR or release)?
> - Why wasn't it caught earlier?
> - What kind of test would have prevented it?
> Summarize lessons learned for the team.

## Stale Bug Cleanup

> List all open bugs that haven't had activity in 60+ days. For each one,
> suggest whether to:
> - Close as no longer reproducible
> - Re-prioritize and assign to someone
> - Request more information from the reporter
> Draft a short comment for each recommended action.
