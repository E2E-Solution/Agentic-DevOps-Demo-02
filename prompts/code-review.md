# Prompt Templates: Code Review

Ready-to-use prompts for reviewing pull requests and improving code quality.

---

## Review a PR for Bugs and Issues

> Review PR #[NUMBER] in this repo. Look for:
> - Logic errors or off-by-one mistakes
> - Null/undefined handling gaps
> - Race conditions or concurrency issues
> - Missing error handling
> - Edge cases the author may not have considered
> Flag anything that could cause a bug in production.

## Summarize a PR and Assess Risk

> Summarize what PR #[NUMBER] changes in plain language. Then rate its
> risk level (low, medium, high) based on:
> - How many files are changed
> - Whether it touches critical paths (auth, payments, data storage)
> - Whether it has adequate test coverage
> - How complex the logic changes are

## Security Review

> Review PR #[NUMBER] with a security focus. Check for:
> - SQL injection or command injection risks
> - Hardcoded secrets or credentials
> - Improper input validation or sanitization
> - Authentication or authorization bypasses
> - Sensitive data exposure in logs or responses
> Explain each finding and suggest a fix.

## Performance Review

> Analyze PR #[NUMBER] for performance concerns. Look for:
> - N+1 queries or unnecessary database calls
> - Missing pagination on large data sets
> - Expensive operations inside loops
> - Missing caching opportunities
> - Large payload sizes or unoptimized assets
> Suggest concrete improvements for each finding.

## Find Breaking Changes

> Check PR #[NUMBER] for potential breaking changes. Look at:
> - API contract changes (endpoints, request/response shapes)
> - Database schema changes without migrations
> - Removed or renamed public functions or exports
> - Changed configuration or environment variable names
> - Dependency version bumps that may affect consumers
> List each breaking change and who might be affected.

## Check for Anti-Patterns

> Review PR #[NUMBER] for common anti-patterns:
> - God classes or functions doing too much
> - Deep nesting or overly complex conditionals
> - Copy-pasted code that should be shared
> - Magic numbers or strings without constants
> - Tight coupling between unrelated components
> For each issue, explain the problem and suggest a better approach.

## Suggest Code Quality Improvements

> Look at the changes in PR #[NUMBER] and suggest improvements for
> readability and maintainability:
> - Better variable or function names
> - Opportunities to simplify complex logic
> - Missing or unclear comments on non-obvious code
> - Consistent style with the rest of the codebase
> - Better use of language features or standard libraries

## Review Test Coverage

> Check whether PR #[NUMBER] has adequate tests. Identify:
> - New code paths that have no test coverage
> - Edge cases that should have tests but don't
> - Tests that are too tightly coupled to implementation
> - Missing integration or end-to-end tests for the feature
> Suggest specific test cases the author should add.
