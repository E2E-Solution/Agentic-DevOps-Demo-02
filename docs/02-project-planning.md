# Project Planning with GitHub

Manage your sprints, milestones, issues, and project boards — all from the terminal.

---

## Key Concepts

| What You Call It | GitHub Name | What It Is |
|------------------|-------------|------------|
| Sprint | **Milestone** | A time-boxed set of work with a due date |
| Story / Task | **Issue** | A unit of work to be completed |
| Epic | **Issue with sub-issues** | A large piece of work broken into smaller issues |
| Board | **Project** | A Kanban-style board for tracking progress |
| Backlog | **Open issues** | Work not yet scheduled into a sprint |

---

## Managing Milestones (Sprints)

### View Current Milestones

```bash
gh api repos/{owner}/{repo}/milestones --jq '.[] | "\(.title) — \(.open_issues) open, \(.closed_issues) closed, due: \(.due_on)"'
```

Or just ask Copilot CLI:
> "Show me all milestones and their progress"

### Create a New Milestone

```bash
gh api repos/{owner}/{repo}/milestones -f title="Sprint 5" -f due_on="2026-05-04T00:00:00Z" -f description="Focus on user authentication"
```

Or ask Copilot:
> "Create a milestone called Sprint 5, due in 2 weeks, focused on user auth"

---

## Managing Issues

### View Your Issues

```bash
# Issues assigned to you
gh issue list --assignee @me

# All open bugs
gh issue list --label bug

# Issues in a specific milestone
gh issue list --milestone "Sprint 5"
```

### Create Issues

```bash
gh issue create --title "Add password reset flow" --label "enhancement" --assignee @username --milestone "Sprint 5"
```

Or ask Copilot:
> "Create an issue for adding password reset functionality. Label it as an enhancement and add it to Sprint 5."

### Bulk Operations

Ask Copilot for bulk changes:
> "Move all open issues labeled v1.0 to the v1.1 milestone"
> "Label all issues from user @bob as 'team-backend'"

---

## Using Project Boards

### View Projects

```bash
gh project list
```

### Manage Project Items

Ask Copilot:
> "Add all open issues from Sprint 5 to our project board"
> "Move completed issues to the Done column"

---

## Planning a Sprint

Here's a typical sprint planning workflow:

1. **Review the backlog:**
   > "Show me all open issues not in any milestone, sorted by priority"

2. **Estimate capacity:**
   > "How many issues did we close in the last 3 sprints on average?"

3. **Select sprint items:**
   > "Based on our velocity, suggest which backlog items to include in Sprint 6"

4. **Create the milestone:**
   > "Create Sprint 6 milestone due in 2 weeks"

5. **Assign issues:**
   > "Assign the Sprint 6 issues to team members based on their expertise"

---

## Prompt Templates

See [prompts/project-planning.md](../prompts/project-planning.md) for more ready-to-use prompts.
