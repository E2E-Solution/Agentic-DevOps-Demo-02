# Prompt Templates: Project Planning

Ready-to-use prompts for managing your GitHub projects. Copy and paste these
into **GitHub Copilot CLI** (`copilot`) or adapt them to your needs.

---

## Create a New Milestone

> Create a milestone called "Sprint 5" with a due date 2 weeks from now.
> Add a description: "Focus on user authentication and onboarding improvements."

## Plan Sprint Issues

> Look at the open issues in this repo and suggest which ones should go into
> the next sprint. Prioritize by: bug fixes first, then high-priority
> enhancements, then documentation.

## Create Issues from Requirements

> I need to create issues for these requirements:
> 1. Users should be able to reset their password via email
> 2. The dashboard should load in under 3 seconds
> 3. We need API documentation for the /users endpoint
>
> Create one issue for each with appropriate labels and a clear description.

## Set Up a Project Board

> Help me create a GitHub Project board with these columns:
> - Backlog
> - Ready for Sprint
> - In Progress
> - In Review
> - Done
>
> Then move all open issues into the Backlog column.

## Review Milestone Progress

> Show me the progress on our current milestone. How many issues are
> completed vs. remaining? Are we on track to finish by the due date?

## Estimate Sprint Capacity

> Based on our velocity from the last 3 sprints (issues closed per sprint),
> how many issues can we realistically take on in the next sprint?

## Create a Release Checklist

> Create a checklist issue for our next release. Include steps for:
> - Feature freeze
> - QA testing
> - Documentation review
> - Stakeholder sign-off
> - Deployment
> - Post-release monitoring
