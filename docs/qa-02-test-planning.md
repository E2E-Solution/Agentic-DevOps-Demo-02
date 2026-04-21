# AI-Assisted Test Planning

Use Copilot CLI and prompt templates to build thorough test plans faster.

---

## Using the Test Planning Prompt Template

Start by loading the test planning prompts:

```bash
cat prompts/test-planning.md
```

Copy a prompt, launch `copilot`, and paste it in. The AI will generate structured test cases based on your project context.

## Generating Test Cases from User Stories

When a new feature issue is created, turn it into test cases immediately. In Copilot CLI, try:

- `"Generate test cases for issue #42"`
- `"What edge cases should we test for the login feature?"`
- `"Create acceptance criteria for the file upload story"`

You can also pull issue details directly:

```bash
gh issue view 42
```

Then ask Copilot to generate test cases covering the happy path, error handling, boundary conditions, and integration points.

## Creating Regression Test Plans

Before each release, build a regression plan that covers critical paths. Ask Copilot:

- `"Create a regression test plan for milestone v2.1"`
- `"What areas are most risky based on recent changes?"`

To see what changed since the last release:

```bash
gh pr list --state merged --search "milestone:v2.1"
```

Focus regression testing on:
1. **Changed areas** — Features with recent PRs
2. **High-risk modules** — Code with frequent bug fixes
3. **Integration points** — Where components connect
4. **Previous failures** — Tests that have failed before

## Mapping Test Coverage to Requirements

Track which requirements have test coverage and which have gaps. Use Copilot to help:

- `"List all open feature issues and their test status"`
- `"Which requirements from milestone v2.1 are missing test cases?"`

Build a coverage matrix by checking issues against your test inventory:

```bash
gh issue list --label "enhancement" --milestone "v2.1"
```

For each feature, verify you have:

| Coverage Area | Question to Ask |
|---------------|-----------------|
| Functional tests | Does each acceptance criterion have a test? |
| Edge cases | Are boundary conditions covered? |
| Integration tests | Are cross-feature interactions tested? |
| Performance tests | Are response time requirements validated? |
| Accessibility tests | Are a11y requirements verified? |

## Best Practices for Test Planning with AI

**Be specific with your prompts.** Instead of "write tests," say "write test cases for the password reset flow, including expired tokens and rate limiting."

**Iterate on generated plans.** AI gives you a strong starting point — refine it with your domain knowledge. Ask follow-up questions:

- `"What did we miss in this test plan?"`
- `"Add negative test cases for the payment flow"`
- `"Prioritize these test cases by risk"`

**Review against past defects.** Check what bugs were found in similar features:

```bash
gh issue list --label "bug" --search "authentication"
```

Use that history to strengthen your test plan.

**Version your test plans.** Store test plans as issues or markdown files in the repo so the team can review and track them:

```bash
gh issue create --title "Test Plan: v2.1 Release" --body-file test-plan.md --label "qa"
```

---

## What's Next?

- 🐛 Read the [Defect Management Guide](qa-03-defect-management.md) to track bugs effectively
- 📊 Read the [Quality Reporting Guide](qa-04-quality-reporting.md) for stakeholder reports
- 🏁 Read the [QA Setup Guide](qa-01-setup.md) if you haven't set up your environment yet

---

## Need Help?

- Run `health-check` to diagnose environment issues
- Browse `prompts/test-planning.md` for ready-to-use prompts
- Ask Copilot CLI: `"Help me plan tests for the next release"`
