# AI-Assisted Issue Triage

Use AI to help you label, prioritize, and assign issues efficiently.

---

## What Is Issue Triage?

Issue triage is the process of reviewing new issues and deciding:
- **What type** is it? (bug, feature, question, etc.)
- **How important** is it? (critical, high, medium, low)
- **Who should work on it?** (assign to a team member)
- **When should it be done?** (add to a milestone/sprint)

---

## Quick Start: Run the Triage Script

```bash
issue-triage
```

This script shows you:
- Issues without labels (need categorization)
- Issues without assignees (need owners)
- Suggestions for how to use AI to triage them

### Script Options

```bash
issue-triage --repo your-org/your-repo    # Specific repository
issue-triage --limit 10                    # Show only 10 issues
```

---

## AI-Powered Triage with Copilot CLI

Start Copilot and use these prompts:

### Auto-Label Issues
> "Look at the open issues that have no labels. Suggest labels for each one based on the title and description. Use these labels: bug, enhancement, documentation, question, high-priority."

### Prioritize Issues
> "Review all open issues and create a priority ranking. Consider: user impact, blocking potential, age of the issue, and number of reactions."

### Suggest Assignees
> "For each unassigned issue, suggest a team member to assign it to. Base this on who has been working on related code in recent PRs."

### Identify Duplicates
> "Check if any open issues are duplicates of each other. Look for similar titles and descriptions."

---

## Common Triage Actions

### Add Labels
```bash
gh issue edit 123 --add-label "bug,high-priority"
```

### Assign Someone
```bash
gh issue edit 123 --add-assignee @username
```

### Add to Sprint
```bash
gh issue edit 123 --milestone "Sprint 5"
```

### Close as Duplicate
```bash
gh issue close 123 --comment "Duplicate of #456"
```

### Request More Information
```bash
gh issue comment 123 --body "Thanks for reporting! Could you provide steps to reproduce this issue?"
```

---

## Triage Best Practices for PMs

1. **Triage regularly** — Set a recurring time (daily or every other day) to review new issues
2. **Use labels consistently** — Agree on a label taxonomy with your team
3. **Don't assign everything** — Some issues may need more info before assignment
4. **Prioritize ruthlessly** — Not everything is high priority. Be honest about importance.
5. **Close stale issues** — If an issue hasn't had activity in 60+ days and isn't critical, consider closing it

---

## Prompt Templates

See [prompts/issue-triage.md](../prompts/issue-triage.md) for more triage prompts.
