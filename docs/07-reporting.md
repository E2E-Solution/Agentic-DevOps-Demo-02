# Generating Reports

Create professional status reports, sprint summaries, and stakeholder updates.

---

## Quick Start: Sprint Report

Run the sprint report script:

```bash
sprint-report
```

### Customize Your Report

```bash
sprint-report --days 7              # Last 7 days instead of 14
sprint-report --milestone "Sprint 5" # Filter by milestone
sprint-report --repo your-org/repo   # Specific repository
```

### Save to a File

```bash
sprint-report --repo your-org/repo > sprint-5-report.md
```

---

## Report Types

### 1. Sprint Status Report

The `sprint-report` script generates:
- Issues opened vs. closed
- PRs merged
- Sprint velocity metrics
- Top open issues
- PRs needing attention

### 2. AI-Generated Reports with Copilot

For more tailored reports, ask Copilot CLI:

#### Executive Summary
> "Write a one-paragraph executive summary of our project's status. Focus on progress, risks, and key decisions needed."

#### Release Notes
> "Based on PRs merged since the last release, write user-friendly release notes grouped by: New Features, Bug Fixes, and Improvements."

#### Team Performance
> "Generate a team performance report showing: issues closed per person, PRs reviewed per person, and average cycle time."

### 3. Combined Reports (GitHub + M365)

Using WorkIQ with Copilot:
> "Create a comprehensive project status report combining our GitHub milestone progress with any relevant email discussions and meeting decisions from this week."

---

## Sharing Reports

### Copy to Clipboard
After generating a report, select the text and copy it.

### Save as Markdown
```bash
sprint-report > reports/sprint-5.md
```

### Share via GitHub
Create a GitHub discussion or wiki page:
```bash
# Create a discussion with the report
gh api repos/{owner}/{repo}/discussions -f title="Sprint 5 Report" -f body="$(sprint-report)"
```

### Email via Copilot
> "Draft a stakeholder email with this sprint's status report. Include what we accomplished, what's next, and any blockers."

---

## Scheduling Regular Reports

While you can't schedule from within the Codespace, you can:

1. **Bookmark this Codespace** and open it at the start of each sprint review
2. **Create a recurring reminder** to run `sprint-report` before standups
3. **Ask Copilot** to generate a report at the beginning of each session

---

## Customizing Reports

### Change the Time Period
```bash
sprint-report --days 30    # Monthly report
sprint-report --days 7     # Weekly report
sprint-report --days 1     # Daily report
```

### Focus on Specific Areas
Ask Copilot to generate focused reports:
> "Generate a bug-only report: how many bugs were opened and closed this sprint?"
> "Show me a report on documentation issues only"
> "Create a dependency/blocker report for the current sprint"

---

## Prompt Templates

See [prompts/sprint-report.md](../prompts/sprint-report.md) for more reporting prompts.
