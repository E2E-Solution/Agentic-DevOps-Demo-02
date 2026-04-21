# Prompt Templates: Debugging & Incident Response

Ready-to-use prompts for diagnosing failures, tracing bugs, and handling incidents.

---

## Diagnose a CI/CD Failure

> The latest CI run failed on this repo. Pull the logs from the most
> recent failed workflow run and tell me:
> - Which job and step failed
> - What the actual error message is
> - Whether this is a flaky test, a real code issue, or an infrastructure problem
> - What the developer should do to fix it
> Explain in plain language — not everyone reading this is a developer.

## Trace a Bug to Root Cause

> We're seeing this bug: [DESCRIBE SYMPTOMS]. Help me trace it:
> - What part of the codebase is most likely responsible?
> - What are the possible causes?
> - What files or functions should the developer investigate first?
> - What tests or checks would confirm the root cause?
> Walk me through the investigation step by step.

## Analyze an Error Message

> I got this error: [PASTE ERROR OR STACK TRACE]. Explain:
> - What does this error mean in plain language?
> - What is the most likely cause?
> - What file and line is the problem in?
> - What is the recommended fix?
> - Could this error affect other parts of the system?

## Investigate a Performance Regression

> Our application is slower than it was last week. Help me investigate:
> - Check recent PRs merged in the last 7 days for changes that could
>   affect performance (database queries, API calls, large data processing)
> - Identify the most likely culprit PR
> - Suggest specific metrics or logs to check to confirm the cause
> - Recommend a fix or rollback strategy

## Post-Incident Analysis

> We just resolved an incident. Help me write a post-mortem:
> - Timeline: What happened and when? (Use recent CI runs, PRs, and
>   deployments to reconstruct events)
> - Root cause: What was the underlying problem?
> - Impact: What was affected and for how long?
> - Resolution: What fixed it?
> - Action items: What should we do to prevent this from happening again?

## Compare a Working Build to a Broken Build

> The last successful workflow run was [RUN ID or "before today"]. Compare
> it to the current failing run:
> - What changed between the two runs? (new commits, dependency updates)
> - Are the failure logs different?
> - Is this a new failure or a recurrence of a known issue?
> Help me figure out what broke and when.

## Check for Flaky Tests

> Look at the recent CI workflow runs for this repo. Identify tests that:
> - Pass sometimes and fail other times on the same code
> - Have inconsistent timing
> - Depend on external services or network calls
> List the flaky tests and suggest how to stabilize each one.

## Triage a Production Alert

> We received an alert: [DESCRIBE ALERT]. Help me triage it:
> - Is this a new issue or has it happened before?
> - What is the severity — is it user-facing?
> - What recent changes (PRs, deployments) could have caused it?
> - What should we do right now to mitigate the impact?
> - Who on the team should own the investigation?
