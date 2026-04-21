# Release Management

This guide covers how to prepare, validate, and ship releases using the Agentic DevOps tools.

---

## Step 1: Run Pre-Release Checks

Before starting a release, verify that everything is in good shape:

```bash
release-prep
```

This script checks:
1. All CI checks are passing on the default branch
2. No critical issues are still open for the milestone
3. Dependencies are up to date
4. Recent PRs are merged and accounted for

## Step 2: Audit Dependencies

Run a dependency check to catch security vulnerabilities or outdated packages:

```bash
dependency-check
```

Review the output for:

| Severity | Action |
|----------|--------|
| **Critical / High** | Must fix before release |
| **Medium** | Fix if possible, or document as known issue |
| **Low** | Track for next release cycle |

## Step 3: Review What's Shipping

Get a clear picture of what's included in this release:

```bash
# PRs merged since the last release tag
gh pr list --state merged --search "merged:>2024-01-01" --limit 50

# Commits since the last tag
git log v1.0.0..HEAD --oneline

# Issues closed since the last release
gh issue list --state closed --search "closed:>2024-01-01" --limit 50
```

Replace `v1.0.0` and the date with your last release tag and date.

## Step 4: Generate a Changelog

Use Copilot CLI to draft release notes:

```bash
copilot
```

Try these prompts:

- `"Generate a changelog from the PRs merged since tag v1.0.0"`
- `"Summarize the changes in this release for the team"`
- `"Categorize recent merged PRs into features, fixes, and improvements"`

You can also generate notes automatically with the GitHub CLI:

```bash
gh release create v1.1.0 --generate-notes --draft
```

The `--draft` flag creates the release without publishing, so you can review and edit first.

## Step 5: Create the Release

When you're ready to publish:

```bash
gh release create v1.1.0 \
  --title "v1.1.0" \
  --notes-file CHANGELOG.md
```

For a pre-release (beta, RC):

```bash
gh release create v1.1.0-rc1 --prerelease --title "v1.1.0 Release Candidate 1"
```

## Step 6: Verify the Release

After publishing, confirm everything looks right:

```bash
gh release view v1.1.0
gh run list --limit 5
```

Check that any release-triggered workflows (deployments, publishing) completed successfully.

## Release Checklist

- [ ] All CI checks pass on the default branch
- [ ] `dependency-check` reports no critical vulnerabilities
- [ ] `release-prep` completes without errors
- [ ] Changelog is written and reviewed
- [ ] Milestone issues are closed or moved
- [ ] Release tagged with correct semantic version
- [ ] Release-triggered workflows succeed

## Quick Reference

```bash
release-prep                                                    # Pre-release validation
dependency-check                                                # Audit dependencies
git log v1.0.0..HEAD --oneline                                  # Commits since last release
gh release create v1.1.0 --generate-notes --draft               # Draft release
gh release create v1.1.0 --title "v1.1.0" --notes-file CHANGELOG.md  # Publish
gh release view v1.1.0                                          # View a release
gh release list                                                 # List all releases
```

---

## What's Next?

- 🔍 Read the [Code Review Guide](dev-02-code-review.md) to ensure quality before release
- 🐛 Read the [Debugging Guide](dev-03-debugging.md) to handle post-release issues
- 📖 See `prompts/quality-report.md` for prompts to assess release readiness
