# Prompt Templates: Quality Reporting

Ready-to-use prompts for quality metrics, dashboards, and release readiness.

---

## Quality Status Report

> Generate a quality status report for this project. Include:
> - Open bugs by severity (critical, major, minor)
> - Bug open vs. close rate for the last 30 days
> - CI/CD pass rate for recent workflow runs
> - Average time to fix a bug (open to close)
> Present it as a summary I can share with leadership.

## Test Trend Analysis

> Analyze testing trends over the last [N] sprints:
> - How many bugs were found per sprint?
> - How many were fixed vs. carried over?
> - Are we finding bugs earlier or later in the cycle?
> Show the trend and flag any sprints where quality dipped.

## Release Readiness Assessment

> We're planning to release at the end of this milestone. Assess whether
> we're ready by checking:
> - Are there any open critical or major bugs?
> - Have all planned issues been closed or descoped?
> - Are there any PRs still waiting for review?
> - Is the CI pipeline passing on the release branch?
> Give a go / no-go recommendation with supporting data.

## Defect Escape Summary

> Summarize defects that escaped to production in the last [N] releases.
> For each one:
> - What was the impact?
> - Which release introduced it?
> - How long until it was detected and fixed?
> Identify any patterns and recommend process improvements.

## Quality Dashboard from GitHub Data

> Build a quality dashboard using data from this repository. Include:
> - Open bug count over time (weekly for the last 8 weeks)
> - Mean time to resolution for bugs
> - Percentage of PRs with failing checks before merge
> - Top 5 most-reported bug areas (by label or component)
> Format it as a table I can paste into a status update.

## CI/CD Health Summary

> Review the last 20 workflow runs and summarize CI/CD health:
> - Overall pass rate
> - Most common failure reasons
> - Average run duration
> - Any workflows that are flaky (pass, fail, pass pattern)
> Highlight anything that needs developer attention.

## Sprint Quality Retrospective

> Pull quality data for the sprint that just ended:
> - Bugs opened vs. bugs closed
> - Bugs found in code review vs. found in testing vs. found in production
> - Test coverage changes (if available)
> - CI failures caused by the team's own changes
> Summarize what went well and what to improve next sprint.

## Risk Areas Heatmap

> Identify the riskiest areas of this project by looking at:
> - Files or directories with the most bug-fix commits
> - Code areas with frequent CI failures
> - Components with the most open issues
> Rank the top 5 risk areas and explain why each one is high risk.
