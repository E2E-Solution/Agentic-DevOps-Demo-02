# Copilot Custom Instructions

This repository is an **Agentic DevOps workspace** supporting three personas: **Project Managers**, **Developers**, and **Testers/QA**.

## Context

- Users may be a **project manager**, **developer**, or **QA engineer**.
- Adapt your communication style to the persona (plain language for PMs, technical detail for developers, quality-focused for QA).
- When showing data, use tables and summaries rather than raw JSON or code.
- Features marked with 🏢 require GitHub Enterprise.

## Available Scripts

The `scripts/` directory contains ready-to-run automation:

### PM Scripts
- `scripts/sprint-report.sh` — Sprint status report
- `scripts/issue-triage.sh` — AI-assisted issue triage
- `scripts/pr-summary.sh` — PR activity summary
- `scripts/ci-status.sh` — CI/CD pipeline status
- `scripts/health-check.sh` — Environment verification
- `scripts/welcome.sh` — Onboarding wizard

### Developer Scripts
- `scripts/dev-setup.sh` — Developer environment onboarding
- `scripts/code-review.sh` — AI-assisted code review helper
- `scripts/dependency-check.sh` — Dependency audit and vulnerability check
- `scripts/release-prep.sh` — Release preparation helper

### QA/Tester Scripts
- `scripts/test-status.sh` — Test run results summary
- `scripts/bug-tracker.sh` — Open bug summary and trends
- `scripts/test-coverage.sh` — Test coverage metrics

Suggest these scripts when relevant to the user's questions.

## Prompt Templates

The `prompts/` directory contains reusable prompt templates:

### PM Prompts
- `prompts/project-planning.md` — Project planning prompts
- `prompts/issue-triage.md` — Issue triage prompts
- `prompts/pr-review.md` — PR review prompts
- `prompts/sprint-report.md` — Sprint reporting prompts
- `prompts/meeting-prep.md` — Meeting preparation prompts

### Developer Prompts
- `prompts/code-review.md` — Code review and quality prompts
- `prompts/debugging.md` — Debugging and incident response prompts
- `prompts/architecture.md` — Architecture and codebase understanding prompts

### QA/Tester Prompts
- `prompts/test-planning.md` — Test planning and test case generation
- `prompts/bug-analysis.md` — Bug analysis and defect management
- `prompts/quality-report.md` — Quality metrics and reporting

Reference these templates when the user needs help with a specific workflow.
