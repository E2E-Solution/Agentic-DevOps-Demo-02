# Contributing to Agentic DevOps Template

Thank you for your interest in improving this template! This guide will help you contribute effectively.

## 🎯 What This Project Is

This is a **starter template** for AI-powered DevOps activities. It provides:
- Shell scripts for common PM, Developer, and QA workflows
- Prompt templates for use with GitHub Copilot CLI
- Documentation guides for each persona
- A pre-configured Codespace environment

**There is no application code** — the scripts, prompts, and docs _are_ the product.

## 🏗️ Repository Structure

```
├── .devcontainer/          # Codespace environment setup
├── .github/                # GitHub config, templates, workflows
│   ├── copilot-instructions.md
│   ├── instructions/       # Role-based Copilot instructions
│   ├── ISSUE_TEMPLATE/     # Issue form templates
│   └── workflows/          # CI/CD workflows
├── docs/                   # Step-by-step guides (numbered by persona)
├── scripts/                # Automation scripts
│   ├── _common.sh          # Shared functions (source this in new scripts)
│   └── *.sh                # Individual scripts
├── prompts/                # Copilot CLI prompt templates
├── AGENTS.md               # Copilot CLI agent instructions
└── README.md
```

## 📝 How to Contribute

### Adding a New Script

1. Create your script in `scripts/` with a descriptive name: `scripts/my-script.sh`
2. Source the shared library at the top:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
   source "$SCRIPT_DIR/_common.sh"
   ```
3. Use shared functions: `require_gh_auth`, `print_header`, `log_ok`, etc.
4. Add `--help` support and `--repo` flag for repository targeting
5. Add an alias in `.devcontainer/post-create.sh`

### Adding a Prompt Template

1. Create a `.md` file in `prompts/` following the existing format
2. Include a title, description, and organized sections of prompts
3. Each prompt should be copy-paste ready for Copilot CLI

### Adding Documentation

1. Follow the naming convention: `docs/<persona>-<number>-<topic>.md`
   - PM docs: `docs/01-*.md` through `docs/07-*.md`
   - Developer docs: `docs/dev-01-*.md` through `docs/dev-04-*.md`
   - QA docs: `docs/qa-01-*.md` through `docs/qa-04-*.md`
2. Write for the target persona — PMs need plain language, developers can handle technical detail

### Updating Agent Instructions

- `AGENTS.md` contains persona-specific sections — edit the relevant persona section
- `.github/copilot-instructions.md` has general Copilot context
- `.github/instructions/*.instructions.md` has role-specific instructions

## ✅ Quality Checklist

Before submitting a pull request:

- [ ] Shell scripts pass `shellcheck` (run `shellcheck scripts/*.sh`)
- [ ] Markdown files are well-formatted
- [ ] New scripts include `--help` flag support
- [ ] New scripts source `scripts/_common.sh`
- [ ] Documentation is written for the correct persona's skill level
- [ ] No secrets or credentials are included

## 🔄 Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b add-new-qa-script`
3. Make your changes
4. Test scripts locally or in a Codespace
5. Submit a pull request with a clear description

## 💬 Questions?

Open an issue with the `question` label, or start a discussion in the repository.
