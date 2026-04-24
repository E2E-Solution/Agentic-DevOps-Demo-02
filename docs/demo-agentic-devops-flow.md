# 🎬 Agentic DevOps Demo — End-to-End Flow

A step-by-step demo script showcasing the **complete agentic DevOps lifecycle**: from
user requirements → backlog planning → issue breakdown → Copilot coding agent →
code review → merge.

**Target audience:** Developers and architects who want to see the mechanics of
GitHub Copilot's agentic capabilities in a real DevOps workflow.

**Estimated duration:** 30–45 minutes (adjust depth per section).

---

## Prerequisites

Before starting the demo, ensure:

- [ ] You have a GitHub Codespace open on this repository (or a local dev environment)
- [ ] GitHub Copilot is enabled for the repository
- [ ] The Copilot coding agent is enabled (repository settings → Copilot → Coding agent)
- [ ] The `gh` CLI is authenticated (`gh auth status`)
- [ ] Demo issues exist (see [Demo Issues](#demo-issues) below)

### Demo Issues

This demo uses pre-created issues in this repository:

| Issue | Title | Purpose |
|-------|-------|---------|
| #6 | \[Epic\] Build Task Management REST API | Parent epic |
| #7 | \[Task\] Set up Node.js project scaffolding | Copilot agent task |
| #8 | \[Task\] Create Task data model and in-memory storage | Copilot agent task |
| #9 | \[Task\] Implement CRUD API endpoints for tasks | Copilot agent task |
| #10 | \[Task\] Add request validation middleware | Copilot agent task |
| #11 | \[Task\] Add centralized error handling middleware | Copilot agent task |
| #12 | \[Task\] Write unit tests for API endpoints | Copilot agent task |
| #13 | \[Task\] Add search and filter capability | Manual dev + code review |

---

## Act 1 — Requirements Gathering and Epic Creation

> **Persona:** Project Manager / Product Owner
> **Goal:** Show how Copilot helps turn a vague user requirement into a structured
> GitHub epic with clear scope.

### 🎙️ Talking Points

- PMs often receive requirements in natural language — Copilot bridges the gap
  between "what the user wants" and "what developers need to build"
- GitHub Issues are the single source of truth — no separate ticketing system needed
- Epics with sub-issue checklists give visibility into progress

### 📋 Demo Steps

#### Step 1: Start with the user requirement

Present the raw requirement (paste in Copilot CLI or explain verbally):

> "We need a simple REST API for managing tasks. Users should be able to
> create tasks with a title, description, status, and priority. They should be
> able to list all tasks, filter by status, update task details, and delete
> tasks. The API should validate inputs and return meaningful error messages."

#### Step 2: Ask Copilot to create a structured epic

In Copilot CLI, ask:

> "Based on this requirement, create a GitHub issue as an epic for a Task
> Management REST API. Break it down into sub-issues that are small enough
> for independent implementation. Use Node.js with TypeScript and Express."

**Show the audience:** Copilot understands the requirement and proposes a structured
breakdown with technical decisions.

#### Step 3: Show the created epic

```bash
gh issue view 6
```

**Highlight:**

- The epic has a clear description, technical approach, and a checklist of sub-issues
- Each sub-issue is small, independent, and low-risk
- The milestone `Demo: Agentic DevOps Flow` groups everything together

---

## Act 2 — Issue Breakdown into Agent-Friendly Tasks

> **Persona:** Developer / Tech Lead
> **Goal:** Show how to write issues that produce high-quality output from the
> Copilot coding agent.

### 🎙️ Talking Points

- **Issue quality directly affects agent output quality** — this is the most
  important principle of agentic DevOps
- Each issue should include: clear title, detailed description, file paths,
  code patterns, and acceptance criteria
- Small, single-responsibility issues work best — the agent can focus on one
  thing at a time
- Labels like `copilot-agent` and `low-risk` signal intent and risk level

### 📋 Demo Steps

#### Step 1: Show the issue list

```bash
gh issue list --milestone "Demo: Agentic DevOps Flow" --json number,title,labels --jq '.[] | "\(.number) | \(.title) | \(.labels | map(.name) | join(", "))"'
```

#### Step 2: Deep-dive into a well-structured issue

```bash
gh issue view 7
```

**Walk through the anatomy of a good agent issue:**

1. **Description** — What needs to be done and why
2. **Implementation Instructions** — Step-by-step with code examples,
   directory structure, and configuration
3. **Acceptance Criteria** — Checkboxes that define "done"
4. **Notes** — Gotchas, constraints, and patterns to follow
5. **Dependencies** — Which issues must be completed first

#### Step 3: Compare with a vague issue (anti-pattern)

Explain what would happen with a vague issue like:

> "Set up the project" (no details, no acceptance criteria)

vs. the detailed issue #7 that specifies exact file structure, `package.json`
contents, and TypeScript configuration.

#### Step 4: Show the repo's supporting infrastructure

```bash
# The agent reads these files to understand context:
cat .github/copilot-instructions.md    # How the agent should behave
cat .github/copilot-setup-steps.yml    # What tools the agent has available
cat AGENTS.md                          # Detailed persona instructions
```

**Key insight:** The `copilot-setup-steps.yml` installs `shellcheck` and
`markdownlint-cli2` — the agent uses these to validate its own output before
opening a PR.

---

## Act 3 — Assign to Copilot Coding Agent

> **Persona:** Developer
> **Goal:** Show the full agentic loop — assign an issue to Copilot and watch
> it create a branch, write code, and open a PR.

### 🎙️ Talking Points

- The Copilot coding agent is a "virtual developer" that reads the issue,
  writes code, and opens a PR — just like a human would
- It runs in a secure cloud environment configured by `copilot-setup-steps.yml`
- The agent can run linters, tests, and builds to validate its work before
  submitting
- You can assign multiple independent issues in parallel

### 📋 Demo Steps

#### Step 1: Assign an issue to Copilot

**Option A — Via GitHub UI:**

1. Open issue #7 in the browser
2. In the sidebar, click "Assignees"
3. Type `copilot` and select the Copilot coding agent
4. (Or use the "Start work" button if available)

**Option B — Via `gh` CLI:**

```bash
# Assign to copilot using the GitHub UI or API
# Note: The gh CLI may require the GitHub UI for agent assignment
# Open the issue in the browser:
gh issue view 7 --web
```

> **Important:** As of this demo, assigning to the Copilot coding agent is
> done through the GitHub web UI. Navigate to the issue → Assignees → select
> `Copilot`.

#### Step 2: Monitor the agent's progress

Once assigned, Copilot will:

1. **Read the issue** — Understand the requirements and acceptance criteria
2. **Create a branch** — Named after the issue (e.g., `copilot/issue-7`)
3. **Write code** — Following the implementation instructions
4. **Run validation** — Execute linters and tests from `copilot-setup-steps.yml`
5. **Open a PR** — With a description linking back to the issue

Watch for the PR to appear:

```bash
# Check for new PRs (poll every 30 seconds or watch the GitHub UI)
gh pr list --state open
```

#### Step 3: Review the agent's PR

Once the PR appears:

```bash
# View the PR details
gh pr view <PR_NUMBER>

# View the diff
gh pr diff <PR_NUMBER>

# Check CI status
gh pr checks <PR_NUMBER>
```

**Walk through with the audience:**

- The PR description references the issue and explains what was done
- The code follows the patterns specified in the issue
- The agent ran the configured linters/checks before submitting
- CI workflows are triggered automatically

#### Step 4: Assign additional issues (parallel work)

Show that you can assign multiple independent issues simultaneously:

- Assign #8 (Task data model) — independent of #7 or after #7 completes
- The agent works on each in its own branch

**Key insight:** Issues with dependencies (#9 depends on #7 and #8) should be
assigned after their dependencies are merged — the agent needs the prior code
to exist in the repository.

### 🔄 Recommended Assignment Order

Because the sub-issues have dependencies, assign them in waves. **Only assign the
next wave after the previous wave's PRs are merged into `main`** — the agent
needs the prior code to exist in the repository.

| Wave | Issues | Why |
|------|--------|-----|
| 1 | #7 (scaffolding) | Foundation — no dependencies |
| 2 | #8 (data model) | Needs `src/` structure from #7 |
| 3 | #9 (CRUD endpoints) | Needs model from #8 |
| 4 | #11 (error handling) | Needs routes from #9; defines error classes used by #10 |
| 5 | #10 (validation) | Needs error classes from #11 |
| 6 | #12 (unit tests) | Needs all implementation complete |

> **💡 Live demo tip:** Run wave 1 live end-to-end to show the audience the full
> loop. For subsequent waves, consider having pre-completed PRs ready to show
> as "already completed" examples to stay within the time budget.

---

## Act 4 — Manual Code Change and Code Review Agent

> **Persona:** Developer
> **Goal:** Show the "human writes code, AI reviews it" workflow using Copilot
> code review.

### 🎙️ Talking Points

- Not everything needs to be built by an agent — developers still write code
- Copilot code review acts as an always-available, thorough reviewer
- It catches bugs, security issues, performance problems, and style inconsistencies
- The review feedback loop is fast — iterate and re-request in minutes, not hours

### 📋 Demo Steps

#### Step 1: Create a feature branch for the manual change

```bash
git checkout -b feature/task-search-filter
```

#### Step 2: Implement the search/filter feature

Implement the changes described in issue #13. For the demo, you can either:

- **Live-code** the feature (shows Copilot Chat assisting with implementation)
- **Use a pre-prepared branch** (faster for time-constrained demos)

> **💡 Demo tip:** Intentionally include 1-2 believable flaws in your
> implementation to guarantee interesting review comments. For example:
>
> - Use case-sensitive search instead of case-insensitive (the issue requires
>   case-insensitive)
> - Accept any string for `sortBy` without validating against allowed fields
>
> This ensures the code review demo produces visible, useful feedback.

The key files to modify:

- `src/models/taskStore.ts` — Add a `search()` method with filtering logic
- `src/routes/tasks.ts` — Add query parameter parsing to `GET /api/tasks`

#### Step 3: Commit and push

```bash
git add src/models/taskStore.ts src/routes/tasks.ts
git commit -m "feat: add search and filter capability to task list endpoint

Implements query parameter support for GET /api/tasks:
- search: text search in title and description
- status: filter by task status
- priority: filter by priority level
- sortBy/order: control result sorting

Closes #13"
git push -u origin feature/task-search-filter
```

#### Step 4: Open a PR

```bash
gh pr create \
  --title "feat: Add search and filter capability to task list endpoint" \
  --body "## What does this PR do?

Adds query parameter support to \`GET /api/tasks\` for searching, filtering, and sorting tasks.

## Related Issues

- Closes #13

## Type of Change

- [x] ✨ New feature

## Checklist

- [x] Tests pass locally
- [x] Documentation updated (if applicable)
- [x] No breaking changes
- [x] PR title follows conventional format" \
  --milestone "Demo: Agentic DevOps Flow"
```

#### Step 5: Request Copilot code review

**Option A — Via GitHub UI:**

1. Open the PR in the browser
2. Click "Reviewers" in the sidebar
3. Select `Copilot` as a reviewer

**Option B — Via Copilot Chat (in VS Code):**

> "Review PR #\<number\> for bugs, security issues, and code quality."

#### Step 6: Walk through the review feedback

Show the audience:

- **Inline comments** — Copilot annotates specific lines with suggestions
- **Bug detection** — Missing null checks, edge cases, off-by-one errors
- **Security concerns** — Input sanitization, injection risks
- **Performance suggestions** — Algorithmic improvements, unnecessary operations
- **Code quality** — Naming, structure, patterns

#### Step 7: Iterate on feedback

1. Address the review comments (fix the code)
2. Push the updated commit
3. Re-request review from Copilot
4. Show the resolved comments and approval

---

## Act 5 — Review, Merge, and Close the Loop

> **Persona:** All (PM oversight, Dev merge, QA verification)
> **Goal:** Close the full cycle — merge PRs, auto-close issues, show reporting.

### 🎙️ Talking Points

- PRs auto-close linked issues on merge (when using "Closes #N")
- CI checks enforce quality gates before merge
- Sprint reports give PMs real-time visibility into progress
- The full loop is: Requirement → Issue → Agent/Dev → PR → Review → Merge → Done

### 📋 Demo Steps

#### Step 1: Verify CI checks pass

```bash
gh pr checks <PR_NUMBER>
```

Show the CI workflow running the linters and health check defined in
`template-ci.yml`.

> **Note:** The default CI workflow validates shell scripts and markdown.
> For the Task Management API, the Copilot coding agent runs `npm install`,
> `npm run build`, and `npm test` in its own environment using the
> configuration in `copilot-setup-steps.yml`. In a production setup, you
> would add a dedicated API CI job to the workflow.

#### Step 2: Merge a PR

```bash
gh pr merge <PR_NUMBER> --squash --delete-branch
```

**Show:** The linked issue is automatically closed.

#### Step 3: Run a sprint report

```bash
bash scripts/sprint-report.sh
```

Or ask Copilot:

> "Show me the progress on the 'Demo: Agentic DevOps Flow' milestone. How many
> issues are closed vs. open?"

#### Step 4: Show the PR activity summary

```bash
bash scripts/pr-summary.sh
```

#### Step 5: Recap the full flow

Show a summary view:

```bash
# All issues in the milestone
gh issue list --milestone "Demo: Agentic DevOps Flow" --state all --json number,title,state --jq '.[] | "\(.state) | #\(.number) | \(.title)"'
```

---

## Key Takeaways

Summarize these points for the audience:

### 1. Issue Quality = Agent Output Quality

The more detailed and structured your issues are, the better the Copilot coding
agent performs. Include: file paths, code patterns, acceptance criteria, and
constraints.

### 2. Small, Independent Issues Work Best

Break work into the smallest independent units. This makes agent work more
reliable, easier to review, and safer to merge.

### 3. The Agent Is a Team Member

Treat the Copilot coding agent like a junior developer: give it clear
instructions, review its work, and provide feedback through PR reviews.

### 4. Humans + AI = Better Together

The demo shows both patterns:

- **Agent builds, human reviews** (issues #7–#12)
- **Human builds, AI reviews** (issue #13)

Both patterns produce better code than either alone.

### 5. The Full Loop Is Automated

From issue creation to PR merge, the workflow is:
Requirement → Epic → Sub-issues → Agent assignment → PR → CI checks →
Code review → Merge → Issue closed → Sprint report updated

---

## Supporting Files in This Repository

| File | Purpose |
|------|---------|
| `.github/copilot-setup-steps.yml` | Configures the agent's environment (tools, linters) |
| `.github/copilot-instructions.md` | Tells the agent how to behave in this repo |
| `AGENTS.md` | Detailed persona instructions for the agent |
| `.github/ISSUE_TEMPLATE/*.yml` | Structured issue templates (bug, feature, task) |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR template with checklist |
| `.github/workflows/template-ci.yml` | CI workflow for linting and health checks |
| `scripts/sprint-report.sh` | Generate sprint status reports |
| `scripts/pr-summary.sh` | Summarize PR activity |
| `prompts/code-review.md` | Ready-to-use code review prompts |
| `prompts/project-planning.md` | Ready-to-use planning prompts |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Copilot coding agent not available | Check repository settings → Copilot → Coding agent is enabled |
| Agent doesn't pick up the issue | Ensure the issue is assigned to `Copilot` (not a human) |
| Agent PR fails CI | Review the CI logs — the agent may need updated setup steps |
| Code review not triggered | Ensure Copilot is added as a reviewer on the PR |
| `gh` CLI not authenticated | Run `gh auth login` or `gh auth status` to verify |
