# Quality Metrics and Reporting

Generate quality reports and assess release readiness using Agentic DevOps tools.

---

## Gathering Quality Metrics

Start by running the QA scripts to collect current data:

```bash
test-status
test-coverage
```

`test-status` shows pass/fail rates from your latest CI runs. `test-coverage` reports which parts of the codebase are covered by tests and where gaps exist.

For additional data, pull directly from GitHub:

```bash
gh run list --limit 20
gh issue list --label "bug" --state open
gh issue list --label "bug" --state closed --search "closed:>2024-01-01"
```

## Using Quality Report Prompts

Load the quality report prompt template:

```bash
cat prompts/quality-report.md
```

Copy a prompt into `copilot` to generate reports:

- `"Generate a quality status report for milestone v2.1"`
- `"Summarize test results from the last 5 CI runs"`
- `"What is our current defect density?"`

## Generating Quality Status Reports

A quality status report should answer three questions: Where are we? What's at risk? What do we recommend?

Use this structure for stakeholder updates:

| Section | Content |
|---------|---------|
| **Summary** | One-line quality health statement |
| **Test Results** | Pass rate, total tests, new failures |
| **Defect Status** | Open bugs by severity, trend direction |
| **Coverage** | Code coverage percentage, gap areas |
| **Risks** | Untested features, flaky tests, blocked items |
| **Recommendation** | Go/no-go or action items |

Ask Copilot to draft the report:

- `"Create a quality report for this sprint including test results and open bugs"`
- `"Summarize quality risks for the v2.1 release"`

Pull supporting data:

```bash
gh run list --workflow "tests.yml" --limit 10
gh issue list --label "bug" --label "severity:critical" --state open
```

## Release Readiness Assessments

Before recommending a release, evaluate these quality gates:

| Gate | Check | Command |
|------|-------|---------|
| **All tests pass** | No failures in latest CI run | `gh run list --limit 1` |
| **No critical bugs** | Zero open critical/high defects | `gh issue list --label "bug,severity:critical" --state open` |
| **Coverage threshold** | Coverage meets team standard | `test-coverage` |
| **Regression complete** | All regression tests executed | Check test plan issue |
| **Performance validated** | Response times within SLA | Review performance test results |

Ask Copilot to compile the assessment:

- `"Are we ready to release v2.1? Check all quality gates."`
- `"What open bugs would block the release?"`
- `"Summarize regression test results for this milestone"`

If any gate fails, document the risk and escalate:

```bash
gh issue create --title "Release Risk: 3 critical bugs open for v2.1" \
  --label "qa,release-blocker" \
  --body "## Blocking Issues
- #101 Payment timeout under load
- #104 Data export missing columns
- #108 Login fails on mobile Safari

## Recommendation
Do not release until these are resolved."
```

## Building Quality Dashboards from GitHub Data

Combine GitHub CLI queries to build a repeatable quality dashboard. Key metrics to track:

**Test Health**
```bash
gh run list --workflow "tests.yml" --limit 5 --json conclusion,createdAt \
  --jq '.[] | "\(.createdAt) \(.conclusion)"'
```

**Defect Trends**
```bash
gh issue list --label "bug" --state all --json state,createdAt,closedAt \
  --jq 'group_by(.state) | .[] | {state: .[0].state, count: length}'
```

For recurring reports, ask Copilot to automate:

- `"Create a weekly quality summary I can share with the team"`
- `"Track our bug fix rate over the last month"`

---

## What's Next?

- 🧪 Read the [Test Planning Guide](qa-02-test-planning.md) to improve coverage and reduce risk
- 🐛 Read the [Defect Management Guide](qa-03-defect-management.md) for bug tracking best practices
- 🏁 Read the [QA Setup Guide](qa-01-setup.md) if you haven't set up your environment yet

---

## Need Help?

- Run `test-status` and `test-coverage` for quick metrics
- Browse `prompts/quality-report.md` for ready-to-use prompts
- Ask Copilot CLI: `"Help me build a quality report for this sprint"`
