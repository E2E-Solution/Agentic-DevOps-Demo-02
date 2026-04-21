# Prompt Templates: Architecture & Codebase Understanding

Ready-to-use prompts for exploring codebases, understanding design decisions, and planning changes.

---

## Map the Codebase Structure

> Give me a high-level map of this repository:
> - What are the main directories and what does each one contain?
> - What language(s) and frameworks are used?
> - Where is the entry point of the application?
> - How is the code organized — by feature, by layer, or something else?
> Present this as a summary a new team member could use to get oriented.

## Understand Dependency Relationships

> Analyze the dependencies in this project:
> - What are the key external dependencies and what do they do?
> - Are there any outdated or deprecated packages?
> - Are there circular dependencies between internal modules?
> - Which dependencies are the riskiest (unmaintained, too many transitive deps)?
> Summarize in a table with dependency name, purpose, and risk level.

## Find Where a Feature Is Implemented

> I need to understand how [FEATURE NAME] works in this codebase. Find:
> - Which files and functions implement this feature
> - How data flows through the feature from input to output
> - What external services or APIs it depends on
> - Where the tests for this feature live
> Give me a walkthrough I can follow to understand the full picture.

## Plan a Refactoring

> I want to refactor [DESCRIBE AREA — e.g., "the authentication module"].
> Help me plan it:
> - What does the current implementation look like?
> - What are the main problems with it?
> - What would a better design look like?
> - What is the safest order to make changes (to avoid breaking things)?
> - What tests need to exist before we start refactoring?
> Break this into a step-by-step plan with manageable PRs.

## Evaluate Technical Debt

> Assess the technical debt in this repository:
> - Are there TODOs, FIXMEs, or HACKs in the code? How many and where?
> - Are there areas with no test coverage?
> - Is the documentation up to date with the actual code?
> - Are there patterns that are inconsistent across the codebase?
> - Which areas of debt are the highest risk to address first?
> Rank the findings by impact and effort to fix.

## Understand the API Surface

> Document the public API surface of this project:
> - What endpoints, commands, or interfaces does it expose?
> - What are the inputs and outputs for each?
> - Are there any undocumented or internal-only APIs?
> - How is authentication and authorization handled?
> Present this as a quick-reference guide.

## Assess Impact of a Proposed Change

> I'm planning to [DESCRIBE CHANGE — e.g., "replace the database from
> Postgres to MySQL"]. Before we start, analyze the impact:
> - What parts of the codebase would need to change?
> - What existing tests would break?
> - What are the risks and unknowns?
> - How long would this realistically take?
> - Are there intermediate steps we can ship incrementally?

## Review the CI/CD Pipeline Design

> Explain how the CI/CD pipeline works for this project:
> - What workflows are defined and what triggers them?
> - What do the build, test, and deploy steps do?
> - Are there any gaps — things that should be automated but aren't?
> - How long does the pipeline take, and could it be faster?
> Suggest improvements to make the pipeline more reliable or efficient.
