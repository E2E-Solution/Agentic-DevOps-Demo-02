# Prompt Templates: Test Planning

Ready-to-use prompts for test planning and test case generation.

---

## Generate Test Cases from a User Story

> Read issue #[NUMBER] and generate a set of test cases that cover the
> acceptance criteria. For each test case, include:
> - Test ID and title
> - Preconditions
> - Steps to perform
> - Expected result
> Group them by: happy path, negative cases, and edge cases.

## Create a Regression Test Plan

> We're preparing a release from the last [N] merged PRs. Review the
> changes and create a regression test plan. For each area affected:
> - List what should be tested
> - Note the risk level (high, medium, low)
> - Suggest whether manual or automated testing is appropriate
> Prioritize the highest-risk areas first.

## Identify Edge Cases and Boundary Conditions

> Look at issue #[NUMBER] (or the code in [PATH]). Identify edge cases
> and boundary conditions that testers should cover, including:
> - Empty or null inputs
> - Maximum and minimum values
> - Concurrent or duplicate actions
> - Permission and access boundaries
> For each, describe a short test scenario.

## Map Test Coverage to Requirements

> List all open issues in the current milestone. For each issue, check
> whether there are related test files or test cases in the repository.
> Produce a coverage matrix showing:
> - Requirement (issue title and number)
> - Test coverage status (covered, partial, missing)
> - Recommended next steps for any gaps

## Prioritize Tests for a Specific Change

> PR #[NUMBER] is ready for testing. Based on the files changed and the
> areas of the codebase affected, recommend which tests to run first.
> Rank them by risk of regression — highest risk first. Flag any areas
> with no existing tests that need manual verification.

## Design a Smoke Test Suite

> Define a minimal smoke test suite for this project that covers the
> most critical user flows. Keep it under 10 tests. For each test:
> - Describe the scenario in one sentence
> - Note which part of the system it validates
> These should be the first tests run after every deployment.

## Exploratory Testing Charter

> Based on the changes in the last sprint (merged PRs and closed issues),
> write 3–5 exploratory testing charters. Each charter should include:
> - Area to explore
> - What to look for (potential risks)
> - Time box suggestion
> Focus on areas where the recent changes are most likely to cause surprises.
