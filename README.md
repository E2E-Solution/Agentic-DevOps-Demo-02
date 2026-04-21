# 🚀 Agentic DevOps Template

**AI-powered DevOps workflows for your entire team — PMs, Developers, and QA.**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/E2E-Solution/Agentic-DevOps-Template?quickstart=1)

> **For everyone on the team:** This template gives PMs, Developers, and QA Engineers a ready-to-use environment with AI tools for managing GitHub projects, writing better code, and shipping quality software. Just click the button above to start.

---

## ⚡ Quick Start

1. **Click** the **"Open in GitHub Codespaces"** button above (or use **"Use this template"** → **"Open in a codespace"**)
2. **Wait** for the environment to build (~2-3 minutes on first launch)
3. **Run** `welcome` in the terminal to start the guided onboarding
4. **Launch** `copilot` to start an AI-powered session

That's it! You're ready to work with AI — whether you're managing projects, writing code, or testing software.

---

## 🎯 What Can You Do?

### 📋 Project Manager Activities

| Activity | How | Script |
|----------|-----|--------|
| **Sprint Reports** | Generate status reports with metrics | `sprint-report` |
| **Issue Triage** | AI-assisted labeling and prioritization | `issue-triage` |
| **PR Oversight** | Monitor review status and bottlenecks | `pr-summary` |
| **CI/CD Status** | Check pipeline health and failures | `ci-status` |
| **M365 Intelligence** | Query emails, meetings, Teams | Via Copilot + WorkIQ |

### 💻 Developer Activities

| Activity | How | Script |
|----------|-----|--------|
| **Code Review** | AI-assisted review of PRs and diffs | `code-review` |
| **Dependency Audit** | Check for outdated or vulnerable packages | `dependency-check` |
| **Release Prep** | Automate changelog and release checklist | `release-prep` |
| **Dev Environment** | Bootstrap local setup and tooling | `dev-setup` |

### 🧪 QA / Tester Activities

| Activity | How | Script |
|----------|-----|--------|
| **Test Status** | View pass/fail results across test suites | `test-status` |
| **Bug Tracking** | Surface and triage open defects | `bug-tracker` |
| **Test Coverage** | Analyze code coverage metrics | `test-coverage` |
| **Quality Reports** | Generate quality summary for stakeholders | Via Copilot prompts |

### 🤖 Shared

| Activity | How |
|----------|-----|
| **AI Assistant** | Ask anything in plain English — run `copilot` |

---

## 🛠️ What's Included

This Codespace comes pre-installed with everything you need:

### Tools
| Tool | Purpose | Version |
|------|---------|---------|
| **GitHub Copilot CLI** | AI assistant in your terminal | Latest |
| **GitHub CLI (`gh`)** | Manage issues, PRs, workflows | Latest |
| **Microsoft WorkIQ** | Query Microsoft 365 data | Latest |
| **Node.js** | Runtime for Copilot CLI and WorkIQ | 22 |
| **Python** | Runtime for data processing scripts | 3.12 |
| **Git** | Version control | Latest |

### VS Code Extensions
- **GitHub Copilot** & **Copilot Chat** — AI pair programming
- **GitHub Pull Requests** — Manage PRs from VS Code
- **GitHub Actions** — Monitor CI/CD workflows
- **GitLens** — Visualize Git history and blame

### Scripts

Pre-built automation in the `scripts/` directory — run from the terminal:

| Persona | Scripts |
|---------|---------|
| **PM** | `sprint-report`, `issue-triage`, `pr-summary`, `ci-status` |
| **Developer** | `dev-setup`, `code-review`, `dependency-check`, `release-prep` |
| **QA** | `test-status`, `bug-tracker`, `test-coverage` |
| **Everyone** | `welcome`, `health-check` |

### Prompt Templates

Tested prompts in the `prompts/` directory — copy-paste into Copilot CLI:

| Template | Persona |
|----------|---------|
| `project-planning.md`, `sprint-report.md`, `issue-triage.md`, `meeting-prep.md` | PM |
| `code-review.md`, `architecture.md`, `debugging.md` | Developer |
| `test-planning.md`, `bug-analysis.md`, `quality-report.md` | QA |
| `pr-review.md` | Everyone |

---

## 📚 Documentation

Step-by-step guides for every workflow:

### 📋 Project Manager Guides

| Guide | Description |
|-------|-------------|
| [Getting Started](docs/01-getting-started.md) | First launch walkthrough |
| [Project Planning](docs/02-project-planning.md) | Managing issues, milestones, and projects |
| [Issue Triage](docs/03-issue-triage.md) | AI-assisted issue management |
| [PR Review Oversight](docs/04-pr-review-oversight.md) | Monitoring pull requests |
| [CI/CD Monitoring](docs/05-ci-cd-monitoring.md) | Understanding build & deployment status |
| [Workplace Intelligence](docs/06-workplace-intelligence.md) | Using WorkIQ for M365 data |
| [Reporting](docs/07-reporting.md) | Generating status reports |

### 💻 Developer Guides

| Guide | Description |
|-------|-------------|
| [Dev Environment Setup](docs/dev-01-setup.md) | Bootstrapping your local dev environment |
| [Code Review](docs/dev-02-code-review.md) | AI-assisted code review workflows |
| [Debugging](docs/dev-03-debugging.md) | Using AI to investigate and fix issues |
| [Release Management](docs/dev-04-release.md) | Preparing and shipping releases |

### 🧪 QA Guides

| Guide | Description |
|-------|-------------|
| [QA Environment Setup](docs/qa-01-setup.md) | Setting up your testing workspace |
| [Test Planning](docs/qa-02-test-planning.md) | Creating and managing test plans with AI |
| [Defect Management](docs/qa-03-defect-management.md) | Tracking and triaging bugs |
| [Quality Reporting](docs/qa-04-quality-reporting.md) | Generating quality metrics and reports |

---

## 🏗️ Repository Structure

```
├── .devcontainer/              # Codespace environment configuration
│   ├── devcontainer.json       # Tool and extension definitions
│   └── post-create.sh          # Auto-setup script
├── .github/                    # GitHub & Copilot configuration
│   ├── ISSUE_TEMPLATE/         # Issue templates for bugs, features, etc.
│   ├── workflows/              # GitHub Actions CI/CD workflows
│   ├── copilot-instructions.md
│   ├── copilot-setup-steps.yml # Copilot agent setup
│   ├── instructions/           # Additional Copilot instructions
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/                       # Guides for PMs, Developers, and QA
├── scripts/                    # Automation scripts
│   ├── sprint-report.sh        #   PM: sprint status
│   ├── issue-triage.sh         #   PM: issue triage
│   ├── pr-summary.sh           #   PM: PR overview
│   ├── ci-status.sh            #   PM: pipeline health
│   ├── dev-setup.sh            #   Dev: environment bootstrap
│   ├── code-review.sh          #   Dev: AI code review
│   ├── dependency-check.sh     #   Dev: dependency audit
│   ├── release-prep.sh         #   Dev: release checklist
│   ├── test-status.sh          #   QA: test results
│   ├── bug-tracker.sh          #   QA: defect tracking
│   ├── test-coverage.sh        #   QA: coverage metrics
│   ├── welcome.sh              #   Onboarding wizard
│   └── health-check.sh         #   Environment diagnostics
├── prompts/                    # Copilot prompt templates
│   ├── project-planning.md     #   PM prompts
│   ├── sprint-report.md
│   ├── issue-triage.md
│   ├── meeting-prep.md
│   ├── code-review.md          #   Dev prompts
│   ├── architecture.md
│   ├── debugging.md
│   ├── test-planning.md        #   QA prompts
│   ├── bug-analysis.md
│   ├── quality-report.md
│   └── pr-review.md            #   Shared
├── AGENTS.md                   # Copilot CLI agent instructions
├── CODE_OF_CONDUCT.md          # Community guidelines
├── CONTRIBUTING.md             # How to contribute
└── README.md                   # This file
```

---

## 🔑 Prerequisites

Before using this template, ensure your organization has:

- [ ] **GitHub Copilot** — Business or Enterprise plan enabled
- [ ] **GitHub Copilot CLI** — Not disabled in org policies
- [ ] **GitHub Codespaces** — Enabled for your organization
- [ ] **WorkIQ** (optional) — M365 admin consent granted

> **Note:** Your GitHub admin can verify these settings. If you can't access Copilot or Codespaces, contact your GitHub organization administrator.

---

## 💡 Tips

### 📋 For Project Managers

**Use Copilot CLI like a team member** — just tell it what you need in plain English:
```
> "Show me all bugs assigned to our team that are overdue"
> "Draft a sprint report and email it to stakeholders"
> "Why is the CI pipeline failing on the main branch?"
```

**Work with your own repos** — clone any repository you manage:
```bash
gh repo clone your-org/your-repo
cd your-repo
```
Then all scripts and Copilot commands will work with that repo's data.

**Save your reports** — scripts output to the terminal by default. To save as a file:
```bash
sprint-report --repo your-org/your-repo > reports/sprint-5.md
```

### 💻 For Developers

**Get AI code reviews** — run `code-review` to get a quick AI-assisted review of your changes before opening a PR.

**Audit dependencies fast** — run `dependency-check` to scan for outdated or vulnerable packages across your project.

**Use prompt templates for architecture decisions** — browse `prompts/architecture.md` for tested prompts to reason through design choices with Copilot.

### 🧪 For QA Engineers

**Check test health at a glance** — run `test-status` to see pass/fail results across all test suites in the repo.

**Triage bugs efficiently** — run `bug-tracker` to surface open defects, then use `prompts/bug-analysis.md` to investigate root causes with AI.

**Generate quality reports** — use `prompts/quality-report.md` with Copilot to produce stakeholder-ready quality summaries.

### 🤖 For Everyone

**Use prompt templates** — browse the `prompts/` directory for tested prompts. Copy them into Copilot CLI and customize:
```bash
cat prompts/sprint-report.md   # View available prompts
copilot                        # Start Copilot, then paste a prompt
```

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Not authenticated" errors | Run `gh auth login` to log in to GitHub |
| Copilot CLI not found | Run `gh extension install github/gh-copilot` |
| WorkIQ not working | WorkIQ is a preview feature — ask your M365 admin about tenant consent |
| Scripts not executable | Run `chmod +x scripts/*.sh` |
| Codespace is slow | Try a larger machine type in Codespace settings |

Run `health-check` anytime to diagnose environment issues.

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to get involved.

---

## 📝 License

[MIT](LICENSE) — Use this template freely within your organization.
