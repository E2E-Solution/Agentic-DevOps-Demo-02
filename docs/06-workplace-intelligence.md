# Workplace Intelligence with WorkIQ

Connect to Microsoft 365 to query emails, meetings, Teams messages, and documents — all through Copilot CLI.

---

## What Is WorkIQ?

**WorkIQ** is a Microsoft tool that connects GitHub Copilot CLI to your **Microsoft 365** data. It lets you ask questions like:

- "What emails did I get about the release this week?"
- "What was discussed in yesterday's standup meeting?"
- "Find the latest project plan on SharePoint"
- "What are my upcoming meetings?"

---

## Prerequisites

Before you can use WorkIQ:

1. **Microsoft 365 account** with a Copilot license
2. **Admin consent** — Your M365 tenant administrator must approve WorkIQ
3. **Authentication** — You'll need to sign in with your Microsoft account

> **Note:** If WorkIQ isn't working, ask your IT administrator to approve the WorkIQ application for your M365 tenant. This is a one-time setup.

---

## Getting Started

### Check If WorkIQ Is Installed

```bash
health-check
```

Look for the "Microsoft WorkIQ" section. If it shows as installed, you're good to go.

### Using WorkIQ Through Copilot CLI

WorkIQ is integrated as a skill in Copilot CLI. Start Copilot and ask M365 questions:

```bash
copilot
```

Then try:
> "What meetings do I have today?"
> "Show me emails from this week about the project launch"
> "What was discussed in the team meeting yesterday?"

---

## Common WorkIQ Use Cases

### Meeting Preparation
> "What emails have I received about [topic] in the last week?"
> "Summarize what was discussed in the last meeting about [project]"
> "Who sent me documents related to [feature]?"

### Project Context
> "What Teams messages mention our upcoming release?"
> "Find the latest version of the project plan document"
> "What did [person] say about the timeline?"

### Action Item Tracking
> "What action items came out of yesterday's standup?"
> "Are there any email threads where I'm mentioned that I haven't responded to?"

### People & Organization
> "Who has been communicating about [topic]?"
> "What is [person]'s role and recent activity?"

---

## Combining WorkIQ with GitHub Data

The power of this workspace is combining **GitHub project data** with **Microsoft 365 communication data**:

### Sprint Review Prep
> "Show me what we shipped this sprint from GitHub, and find any related emails or Teams discussions about these features"

### Stakeholder Updates
> "Based on our GitHub milestone progress and recent stakeholder emails, draft a status update"

### Risk Assessment
> "Are there any emails or Teams messages flagging concerns about our current sprint deliverables?"

---

## Privacy & Security

- WorkIQ only accesses data **you have permission to see** in Microsoft 365
- Your queries are processed securely through Microsoft's infrastructure
- No M365 data is stored in the Codespace or GitHub
- You can log out at any time

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "WorkIQ not found" | Run `npm install -g @microsoft/workiq` |
| "Authentication failed" | Sign out and sign in again through the Copilot CLI |
| "Access denied" | Ask your M365 admin to grant WorkIQ tenant consent |
| "No results" | Try rephrasing your query or broadening the time range |
