# Debugging with AI Assistance

This guide covers how to use Copilot CLI and GitHub tools to diagnose failures, trace bugs, and run post-incident analysis.

---

## Step 1: Check CI/CD Status

Start by identifying which workflows are failing:

```bash
ci-status
```

For more detail on recent workflow runs:

```bash
gh run list --limit 10
```

To inspect a specific failed run:

```bash
gh run view 123456789
```

## Step 2: Read the Logs

Drill into the failed job logs to find the error:

```bash
gh run view 123456789 --log-failed
```

This outputs only the logs from failed steps, cutting through the noise. For full logs:

```bash
gh run view 123456789 --log
```

> **Tip:** Pipe long logs through `grep` to find specific errors:
> ```bash
> gh run view 123456789 --log-failed | grep -i "error\|fail\|exception"
> ```

## Step 3: Use Copilot CLI to Diagnose

Start Copilot CLI and use prompts from `prompts/debugging.md`:

```bash
copilot
```

Try these prompts:

- `"Why did the latest CI run fail?"`
- `"Look at the test failures in the last workflow run and explain the root cause"`
- `"What changed recently that could have broken the build?"`

Copilot CLI can read workflow logs, diffs, and commit history to help pinpoint the issue.

## Step 4: Trace from Symptom to Root Cause

Follow this workflow to systematically track down bugs:

1. **Identify the symptom** — What failed? A test, a build step, a deployment?
2. **Find the error message** — Use `gh run view --log-failed` to get the exact error.
3. **Check recent changes** — What was merged since the last green build?
   ```bash
   gh pr list --state merged --limit 5
   git log --oneline -10
   ```
4. **Narrow the scope** — Which files changed? Which tests broke?
   ```bash
   gh pr diff 42
   ```
5. **Reproduce locally** — Check out the branch and run the failing test.
   ```bash
   gh pr checkout 42
   ```

## Step 5: Re-run Failed Workflows

Once you've identified and fixed the issue, re-run the failed workflow:

```bash
gh run rerun 123456789 --failed   # re-run only failed jobs
gh run rerun 123456789             # re-run entire workflow
gh run watch 123456789             # watch run in progress
```

## Post-Incident Analysis

After resolving a significant failure, document what happened:

1. **What broke?** — Describe the failure in plain language.
2. **What caused it?** — Link to the commit or PR that introduced the issue.
3. **How was it fixed?** — Link to the fix PR.
4. **How do we prevent it?** — Add tests, improve CI checks, or update processes.

Use Copilot CLI to draft the analysis:

```bash
copilot
# "Summarize what caused the CI failure in run 123456789 and what PR fixed it"
```

## Quick Reference

```bash
ci-status                                # Check pipeline health
gh run list --limit 10                   # List recent runs
gh run view <run-id>                     # View a specific run
gh run view <run-id> --log-failed        # Show only failed logs
gh run rerun <run-id> --failed           # Re-run failed jobs
gh run watch <run-id>                    # Watch a run in progress
gh pr list --state merged --limit 5      # List recent merges
```

---

## What's Next?

- 🔍 Read the [Code Review Guide](dev-02-code-review.md) to catch bugs before they merge
- 🚀 Read the [Release Management Guide](dev-04-release.md) to ensure clean releases
- 📖 See `prompts/debugging.md` for more diagnostic prompts to use with Copilot CLI
