#!/usr/bin/env bash
set -o pipefail

# =============================================================================
# Agentic DevOps — Seed Demo Data
# =============================================================================
# Populates a repository with realistic mock data (labels, milestones,
# issues, and pull requests) for showcasing Agentic DevOps workflows.
#
# Usage:
#   seed-demo-data.sh                        # Create demo data
#   seed-demo-data.sh --cleanup              # Remove demo data
#   seed-demo-data.sh --repo owner/repo      # Target a specific repository
#
# Designed to run via GitHub Actions (workflow_dispatch) or locally.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_common.sh
source "$SCRIPT_DIR/_common.sh"

# ── Defaults ─────────────────────────────────────────────────────────────────
ACTION="seed"
REPO=""
DEMO_PREFIX="[Demo]"
CREATED_ISSUES=0
CREATED_PRS=0

# ── Parse Arguments ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --cleanup)  ACTION="cleanup"; shift ;;
        --repo)     REPO="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: seed-demo-data.sh [--cleanup] [--repo owner/repo]"
            echo ""
            echo "  --cleanup          Remove demo data instead of creating it"
            echo "  --repo owner/repo  Target repository (default: current repo)"
            echo "  --help, -h         Show this help"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

require_gh_auth

# ── Resolve Repository ───────────────────────────────────────────────────────
REPO_NAME=""
if [ -n "$REPO" ]; then
    REPO_NAME="$REPO"
else
    REPO_NAME=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "")
fi

if [ -z "$REPO_NAME" ]; then
    log_fail "Could not determine repository. Use --repo owner/repo."
    exit 1
fi

REPO_OWNER="${REPO_NAME%%/*}"
REPO_REPO="${REPO_NAME##*/}"

# Always pass --repo explicitly to avoid auto-detection issues in CI
REPO_ARGS=(--repo "$REPO_NAME")

# ═════════════════════════════════════════════════════════════════════════════
# Helper — create a single demo issue (body is read from stdin / heredoc)
# ═════════════════════════════════════════════════════════════════════════════
create_demo_issue() {
    local title="$1"
    local labels="${2:-}"
    local milestone="${3:-}"
    local close="${4:-false}"

    local body
    body=$(cat)

    local -a args=(--title "$DEMO_PREFIX $title")

    # Write body to temp file (avoids shell escaping issues)
    local tmpfile=""
    if [ -n "$body" ]; then
        tmpfile=$(mktemp)
        printf '%s\n' "$body" > "$tmpfile"
        args+=(--body-file "$tmpfile")
    fi

    # Add labels
    if [ -n "$labels" ]; then
        IFS=',' read -ra label_arr <<< "$labels"
        for l in "${label_arr[@]}"; do
            args+=(--label "$l")
        done
    fi

    # Add milestone
    if [ -n "$milestone" ]; then
        args+=(--milestone "$milestone")
    fi

    # Create the issue — capture both stdout (URL) and stderr (errors)
    local result
    result=$(gh issue create "${args[@]}" "${REPO_ARGS[@]}" 2>&1 || echo "")
    [ -n "$tmpfile" ] && rm -f "$tmpfile"

    if [[ "$result" == https://* ]]; then
        local num="${result##*/}"
        if [ "$close" = "true" ] && [ -n "$num" ]; then
            gh issue close "$num" "${REPO_ARGS[@]}" >/dev/null 2>&1 || true
            log_ok "Issue #$num (closed): $title"
        else
            log_ok "Issue #$num: $title"
        fi
        CREATED_ISSUES=$((CREATED_ISSUES + 1))
    else
        log_fail "Failed to create: $title"
        # Show the first line of the error for diagnostics
        echo -e "       ${RED}${result%%$'\n'*}${NC}" >&2
    fi

    sleep 0.5
}

# ═════════════════════════════════════════════════════════════════════════════
# LABELS
# ═════════════════════════════════════════════════════════════════════════════
LABEL_DEFS=(
    "priority: critical|B60205|Immediate attention required"
    "priority: high|D93F0B|Important - address soon"
    "priority: medium|FBCA04|Normal priority"
    "priority: low|0E8A16|Nice to have"
    "status: blocked|B60205|Blocked by dependency or issue"
    "status: in-progress|FBCA04|Actively being worked on"
    "status: ready-for-review|0E8A16|Ready for code review"
    "team: frontend|C5DEF5|Frontend team"
    "team: backend|BFD4F2|Backend team"
    "team: infrastructure|D4C5F9|Infrastructure / DevOps team"
)

create_labels() {
    print_section "🏷️  Creating Labels"
    for entry in "${LABEL_DEFS[@]}"; do
        IFS='|' read -r name color desc <<< "$entry"
        local result
        # --force: create label or update it if it already exists
        result=$(gh label create "$name" --color "$color" --description "$desc" \
            --force "${REPO_ARGS[@]}" 2>&1) && \
            log_ok "Label: $name" || \
            log_warn "Label: $name - ${result:0:100}"
        sleep 0.3
    done
    echo ""
}

# ═════════════════════════════════════════════════════════════════════════════
# MILESTONES
# ═════════════════════════════════════════════════════════════════════════════
MILESTONE_SPRINT1="Sprint 1 - Foundation"
MILESTONE_SPRINT2="Sprint 2 - Core Features"
MILESTONE_SPRINT3="Sprint 3 - Polish and Launch"

create_milestones() {
    print_section "🎯 Creating Milestones (Sprints)"

    local current_due future_due
    current_due=$(date -u -d "+14 days" +%Y-%m-%dT23:59:59Z 2>/dev/null \
               || date -u -v+14d +%Y-%m-%dT23:59:59Z)
    future_due=$(date -u -d "+28 days" +%Y-%m-%dT23:59:59Z 2>/dev/null \
              || date -u -v+28d +%Y-%m-%dT23:59:59Z)

    local result

    # Sprint 1 — completed (closed, no due date needed)
    result=$(gh api "repos/$REPO_OWNER/$REPO_REPO/milestones" \
        -f title="$MILESTONE_SPRINT1" \
        -f description="Initial project setup, CI/CD, authentication, and landing page." \
        -f state="closed" 2>&1) && \
        log_ok "Milestone: $MILESTONE_SPRINT1 (closed)" || \
        log_warn "Milestone: $MILESTONE_SPRINT1 - ${result:0:100}"

    # Sprint 2 — current (open, due in 14 days)
    result=$(gh api "repos/$REPO_OWNER/$REPO_REPO/milestones" \
        -f title="$MILESTONE_SPRINT2" \
        -f due_on="$current_due" \
        -f description="Search, notifications, API optimization, and bug fixes." 2>&1) && \
        log_ok "Milestone: $MILESTONE_SPRINT2 (open, due in 14 days)" || \
        log_warn "Milestone: $MILESTONE_SPRINT2 - ${result:0:100}"

    # Sprint 3 — future (open, due in 28 days)
    result=$(gh api "repos/$REPO_OWNER/$REPO_REPO/milestones" \
        -f title="$MILESTONE_SPRINT3" \
        -f due_on="$future_due" \
        -f description="Dark mode, performance audit, documentation, and launch prep." 2>&1) && \
        log_ok "Milestone: $MILESTONE_SPRINT3 (open, due in 28 days)" || \
        log_warn "Milestone: $MILESTONE_SPRINT3 - ${result:0:100}"

    echo ""
}

# ═════════════════════════════════════════════════════════════════════════════
# ISSUES
# ═════════════════════════════════════════════════════════════════════════════
create_issues() {
    print_section "📋 Creating Issues"

    # ── Sprint 1 — Foundation (all closed) ───────────────────────────────────
    log_step "Sprint 1 - Foundation (completed work)..."
    echo ""

    create_demo_issue "Set up CI/CD pipeline with GitHub Actions" \
        "type: task,team: infrastructure" \
        "$MILESTONE_SPRINT1" \
        "true" << 'EOF'
Configure automated testing, linting, and deployment workflows for the repository.

**Acceptance Criteria:**
- CI runs on every pull request
- Linting for shell scripts and Markdown
- Health check validates the environment
EOF

    create_demo_issue "Design and implement database schema" \
        "type: task,team: backend" \
        "$MILESTONE_SPRINT1" \
        "true" << 'EOF'
Create the initial database schema for the TaskFlow application.

**Tables needed:**
- users (id, email, name, role, created_at)
- projects (id, name, description, owner_id)
- tasks (id, title, description, status, assignee_id, project_id)
- comments (id, body, author_id, task_id, created_at)
- labels (id, name, color, project_id)
EOF

    create_demo_issue "Implement user authentication API" \
        "type: feature,team: backend" \
        "$MILESTONE_SPRINT1" \
        "true" << 'EOF'
Build JWT-based authentication with login, logout, and token refresh.

**Endpoints:**
- POST /api/auth/login
- POST /api/auth/logout
- POST /api/auth/refresh

**Requirements:**
- Passwords hashed with bcrypt
- Access tokens expire after 15 minutes
- Refresh tokens expire after 7 days
EOF

    create_demo_issue "Create landing page design and implementation" \
        "type: feature,team: frontend" \
        "$MILESTONE_SPRINT1" \
        "true" << 'EOF'
Design and build the marketing landing page with responsive layout.

**Sections:**
- Hero with product screenshot
- Feature highlights (3-column grid)
- Testimonials carousel
- Call-to-action with sign-up form
- Footer with links
EOF

    create_demo_issue "Fix: Login session expires too quickly" \
        "type: bug,team: backend,priority: high" \
        "$MILESTONE_SPRINT1" \
        "true" << 'EOF'
Users are being logged out after only 5 minutes of inactivity.

**Expected:** Session should last at least 30 minutes.
**Actual:** Session expires after approximately 5 minutes.

**Steps to reproduce:**
1. Log in to the application
2. Wait 5 minutes without interacting
3. Try to navigate - redirected to login page

**Root cause:** The JWT_EXPIRY env variable was set to "5m" instead of "30m".
EOF

    # ── Sprint 2 — Core Features (mix of open and closed) ───────────────────
    echo ""
    log_step "Sprint 2 - Core Features (current sprint)..."
    echo ""

    create_demo_issue "Add full-text search for tasks" \
        "type: feature,team: frontend,status: in-progress" \
        "$MILESTONE_SPRINT2" \
        "false" << 'EOF'
Implement search across task titles and descriptions.

**Requirements:**
- Real-time search-as-you-type with debouncing
- Filter by project, assignee, and status
- Highlight matching terms in results
- Show recent searches

**Technical approach:**
- PostgreSQL full-text search with tsvector
- GIN index on task title + description
- API endpoint: GET /api/tasks/search?q=...
EOF

    create_demo_issue "Optimize API response times for dashboard" \
        "type: task,team: backend,priority: high" \
        "$MILESTONE_SPRINT2" \
        "false" << 'EOF'
Dashboard API calls take 3-5 seconds. Target: under 500ms.

**Investigation findings:**
- N+1 queries on task list endpoint (fetching assignee for each task)
- Missing database indexes on project_id and assignee_id columns
- No response caching for project metadata

**Proposed fixes:**
1. Add eager loading for task -> assignee relationship
2. Create composite index on (project_id, status, assignee_id)
3. Add Redis cache layer for project metadata (5-minute TTL)
EOF

    create_demo_issue "Dashboard fails to load on mobile devices" \
        "type: bug,priority: critical,status: blocked,team: frontend" \
        "$MILESTONE_SPRINT2" \
        "false" << 'EOF'
The main dashboard is completely broken on mobile browsers.

**Affected:** iOS Safari, Android Chrome (viewport < 768px)
**Error:** JavaScript exception - "ResizeObserver loop limit exceeded"

**Impact:** Approximately 30% of users access the app via mobile devices.

**Root cause:** The dashboard grid uses fixed-width columns (repeat(3, 400px))
that exceed mobile viewport width. The ResizeObserver fires continuously as
the grid tries to recalculate layout.

**Blocked:** Waiting for the responsive grid component library update (v3.2).
EOF

    create_demo_issue "Update REST API documentation" \
        "type: documentation,team: backend" \
        "$MILESTONE_SPRINT2" \
        "false" << 'EOF'
API docs are outdated - missing new endpoints added during Sprint 1.

**Sections that need updating:**
- Authentication endpoints (login, logout, refresh)
- Task CRUD operations
- Search endpoint (when implemented)
- Error response formats and status codes
- Rate limiting information

Recommend migrating from manual Markdown docs to auto-generated OpenAPI spec.
EOF

    create_demo_issue "Add unit tests for authentication module" \
        "type: task,team: backend,status: in-progress" \
        "$MILESTONE_SPRINT2" \
        "false" << 'EOF'
Current test coverage for the auth module is only 23%. Target: 80%+.

**Test cases needed:**
- Login with valid credentials - returns access + refresh tokens
- Login with invalid password - returns 401
- Login with non-existent user - returns 401
- Token refresh with valid refresh token - returns new access token
- Token refresh with expired token - returns 401
- Session expiry after configured timeout
- Role-based access control (admin vs. regular user)
EOF

    create_demo_issue "Implement email notification system" \
        "type: feature,team: backend,priority: medium" \
        "$MILESTONE_SPRINT2" \
        "true" << 'EOF'
Send email notifications for task assignments, mentions, and due dates.

**Integration:** SendGrid API

**Email templates:**
- Task assigned to you
- You were mentioned in a comment
- Task due date approaching (24h reminder)
- Weekly digest summary

**User preferences:**
- Allow users to opt in/out per notification type
- Support immediate vs. daily digest modes
EOF

    create_demo_issue "Fix: Pagination breaks on filtered results" \
        "type: bug,team: frontend,priority: high" \
        "$MILESTONE_SPRINT2" \
        "true" << 'EOF'
When filtering tasks by label then navigating to page 2, the filter resets
and shows unfiltered results.

**Steps to reproduce:**
1. Navigate to task list
2. Filter by label "bug"
3. Click page 2
4. Filter disappears - all tasks shown

**Root cause:** Filter state not included in pagination URL params.

**Fix:** Persist filter parameters in URL query string across page navigation.
Used URLSearchParams to merge pagination and filter state.
EOF

    # ── Sprint 3 — Polish & Launch (future) ──────────────────────────────────
    echo ""
    log_step "Sprint 3 - Polish and Launch (planned)..."
    echo ""

    create_demo_issue "Add dark mode support" \
        "type: feature,team: frontend,priority: low" \
        "$MILESTONE_SPRINT3" \
        "false" << 'EOF'
Implement a dark color theme with user toggle.

**Requirements:**
- CSS custom properties for theming
- Persist preference in localStorage
- Respect OS-level prefers-color-scheme setting
- All components must support both light and dark themes
- Smooth transition animation between themes
EOF

    create_demo_issue "Conduct performance audit and optimization" \
        "type: task,team: infrastructure" \
        "$MILESTONE_SPRINT3" \
        "false" << 'EOF'
Full performance review before public launch.

**Audit checklist:**
- Lighthouse audit (target: 90+ in all categories)
- Bundle size analysis and tree-shaking review
- Database query profiling (slow query log)
- CDN configuration and cache headers review
- Load testing with k6 (target: 500 concurrent users)
- Memory profiling for background workers
EOF

    # ── Backlog — no milestone ───────────────────────────────────────────────
    echo ""
    log_step "Backlog (untriaged and low-priority items)..."
    echo ""

    create_demo_issue "Refactor error handling middleware" \
        "type: task,team: backend,priority: medium" \
        "" \
        "false" << 'EOF'
Current error handling is inconsistent across API routes. Some endpoints
return plain text errors, others return JSON with different formats.

**Goal:** Centralize error formatting, logging, and HTTP status code mapping
in a single middleware layer.

**Consistent error response format:**
- error.code (machine-readable string)
- error.message (human-readable description)
- error.details (optional, validation errors)
EOF

    # These 4 issues are intentionally unlabeled — they serve as triage targets
    # for the issue-triage script demo.

    create_demo_issue "Users report slow page loads on the dashboard" \
        "" "" "false" << 'EOF'
Several users have reported the dashboard takes 10+ seconds to load
during peak hours (9-11 AM EST).

No specific error messages - just slow performance. The loading spinner
appears but the data takes a long time to populate.

This needs investigation to determine whether the bottleneck is frontend
rendering, API latency, or a database issue.
EOF

    create_demo_issue "Add CSV export for project reports" \
        "" "" "false" << 'EOF'
As a project manager, I want to export task lists and reports as CSV files
so I can share them with stakeholders who don't use the application.

Should support:
- Task list export (with filters applied)
- Sprint report export
- Time tracking summary export

The export button should appear in the toolbar when viewing any list or report.
EOF

    create_demo_issue "App crashes when uploading files larger than 10MB" \
        "" "" "false" << 'EOF'
Uploading attachments over 10MB causes the application to crash with a
502 Bad Gateway error.

**Steps to reproduce:**
1. Open any task
2. Click "Attach file"
3. Select a file larger than 10MB
4. Upload fails with a 502 error

The browser console shows: "Request Entity Too Large"

Likely need to increase the Nginx client_max_body_size and the API
multipart upload limit.
EOF

    create_demo_issue "Add keyboard shortcuts for power users" \
        "" "" "false" << 'EOF'
Power users have requested keyboard shortcuts for common actions to speed
up their workflow.

Suggested shortcuts:
- Ctrl+K - Quick search (focus search bar)
- C - Create new task
- J / K - Navigate up/down in task list
- L - Add label to selected task
- A - Assign selected task
- ? - Show keyboard shortcuts help overlay

Should follow the same patterns as GitHub's own keyboard shortcuts.
EOF

    create_demo_issue "Investigate memory leak in background job workers" \
        "type: bug,team: infrastructure,priority: high" \
        "" \
        "false" << 'EOF'
Worker processes slowly consume more memory over time without releasing it.

**Observed behavior:**
- After ~48 hours of uptime, memory usage grows from 256 MB to over 2 GB
- Workers become unresponsive and need manual restart
- Occurs on both staging and production environments

**Likely cause:** Event listeners not being cleaned up in the notification
queue processor. Each processed job attaches a new listener but never
removes the previous one.

**Monitoring:** Set up memory usage alerts at 1 GB threshold.
EOF

    echo ""
}

# ═════════════════════════════════════════════════════════════════════════════
# PULL REQUESTS
# ═════════════════════════════════════════════════════════════════════════════
create_pull_requests() {
    print_section "🔀 Creating Pull Requests"

    # Ensure git is configured (may already be set by CI workflow)
    git config user.name  "github-actions[bot]" 2>/dev/null || true
    git config user.email "41898282+github-actions[bot]@users.noreply.github.com" 2>/dev/null || true

    # In CI, ensure git can push using GH_TOKEN
    if [ -n "${CI:-}" ] && [ -n "${GH_TOKEN:-}" ]; then
        git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/${REPO_OWNER}/${REPO_REPO}.git"
    fi

    local default_branch
    default_branch=$(gh repo view "${REPO_ARGS[@]}" --json defaultBranchRef \
        -q '.defaultBranchRef.name' 2>/dev/null || echo "main")

    _create_pr_search_api "$default_branch"
    _create_pr_mobile_fix "$default_branch"
    _create_pr_api_docs   "$default_branch"

    # Return to default branch
    git checkout "$default_branch" &>/dev/null || true
    echo ""
}

# Helper: push a branch and open a PR (with error logging)
_push_branch_and_pr() {
    local branch="$1"
    local base="$2"
    local file="$3"
    local commit_msg="$4"
    local pr_title="$5"
    local body_file="$6"
    local labels="$7"
    local draft="${8:-false}"

    # Create branch from base
    local checkout_err
    checkout_err=$(git checkout -B "$branch" "origin/$base" 2>&1) || {
        log_warn "Could not create branch: $branch - ${checkout_err:0:100}"
        return 1
    }

    # Stage and commit
    git add "$file" >/dev/null 2>&1
    git commit -m "$commit_msg" >/dev/null 2>&1 || true

    # Push (capture errors)
    local push_err
    push_err=$(git push origin "$branch" --force 2>&1) || {
        log_warn "Could not push branch: $branch"
        echo -e "       ${RED}${push_err:0:150}${NC}" >&2
        git checkout "$base" >/dev/null 2>&1 || true
        return 1
    }
    git checkout "$base" >/dev/null 2>&1 || true

    # Build PR create arguments
    local -a pr_args=(
        --title "$DEMO_PREFIX $pr_title"
        --body-file "$body_file"
        --base "$base"
        --head "$branch"
    )

    if [ -n "$labels" ]; then
        IFS=',' read -ra label_arr <<< "$labels"
        for l in "${label_arr[@]}"; do
            pr_args+=(--label "$l")
        done
    fi
    [ "$draft" = "true" ] && pr_args+=(--draft)

    # Create PR (capture both stdout and stderr)
    local result
    result=$(gh pr create "${pr_args[@]}" "${REPO_ARGS[@]}" 2>&1 || echo "")

    if [[ "$result" == https://* ]]; then
        local label=""
        [ "$draft" = "true" ] && label=" (draft)"
        log_ok "PR${label}: $pr_title"
        CREATED_PRS=$((CREATED_PRS + 1))
    else
        log_warn "Could not create PR: $pr_title"
        echo -e "       ${RED}${result:0:150}${NC}" >&2
    fi
    sleep 0.5
}

# ── PR 1: Feature — search API ──────────────────────────────────────────────
_create_pr_search_api() {
    local base="$1"
    local branch="demo/feature-search-api"
    local file="docs/samples/search-api-design.md"

    git checkout -B "$branch" "origin/$base" >/dev/null 2>&1 || {
        log_warn "Could not create branch: $branch"; return; }
    mkdir -p docs/samples
    cat > "$file" << 'FILECONTENT'
# Search API Design

## Endpoint

`GET /api/tasks/search`

## Query Parameters

| Parameter | Type   | Required | Description                |
|-----------|--------|----------|----------------------------|
| q         | string | yes      | Search query text          |
| project   | int    | no       | Filter by project ID       |
| status    | string | no       | Filter by task status      |
| page      | int    | no       | Page number (default: 1)   |
| limit     | int    | no       | Results per page (max: 50) |

## Example Request

```
GET /api/tasks/search?q=dashboard&status=open&page=1&limit=20
```

## Response Format

```json
{
  "results": [
    {
      "id": 42,
      "title": "Fix dashboard loading issue",
      "description": "The dashboard takes too long to load...",
      "status": "open",
      "score": 0.95
    }
  ],
  "total": 1,
  "page": 1,
  "pages": 1
}
```

## Implementation Notes

- Use PostgreSQL full-text search with `tsvector` columns
- Add GIN index on task title and description
- Implement search result ranking by relevance score
- Cache frequent queries with 5-minute TTL via Redis
- Debounce client-side requests (300ms)
FILECONTENT

    local body_file
    body_file=$(mktemp)
    cat > "$body_file" << 'PRBODY'
Adds the API design document for the task search endpoint.

## Changes

- Added `docs/samples/search-api-design.md` with full endpoint specification
- Defines query parameters, response format, and implementation approach

## Related Issues

Part of the full-text search feature work for Sprint 2.

## Review Checklist

- [ ] API design reviewed by backend team
- [ ] Response format validated against frontend expectations
- [ ] Pagination approach consistent with other list endpoints
PRBODY

    _push_branch_and_pr "$branch" "$base" "$file" \
        "Add search API design document" \
        "Feature: Add search API endpoint" \
        "$body_file" \
        "type: feature,team: backend"
    rm -f "$body_file"
}

# ── PR 2: Bug fix — mobile dashboard (draft) ────────────────────────────────
_create_pr_mobile_fix() {
    local base="$1"
    local branch="demo/fix-mobile-dashboard"
    local file="docs/samples/mobile-fix-notes.md"

    git checkout -B "$branch" "origin/$base" >/dev/null 2>&1 || {
        log_warn "Could not create branch: $branch"; return; }
    mkdir -p docs/samples
    cat > "$file" << 'FILECONTENT'
# Mobile Dashboard Fix - Investigation Notes

## Problem

The dashboard grid layout uses fixed column widths that exceed the mobile
viewport. The `ResizeObserver` fires continuously as the grid recalculates,
causing a JavaScript error loop.

## Root Cause

```css
/* Current (broken on mobile) */
.dashboard-grid {
  grid-template-columns: repeat(3, 400px);  /* Requires 1200px minimum */
}
```

## Proposed Fix

```css
/* Fixed - responsive columns */
.dashboard-grid {
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
}
```

## Testing Matrix

| Device           | Browser        | Status  |
|------------------|----------------|---------|
| iPhone 15        | Safari 17      | TODO    |
| Pixel 8          | Chrome 124     | TODO    |
| iPad Air         | Safari 17      | TODO    |
| Desktop (resize) | Chrome DevTools | Pass    |

## Screenshots

_Will be attached after real-device testing._
FILECONTENT

    local body_file
    body_file=$(mktemp)
    cat > "$body_file" << 'PRBODY'
Fixes the mobile dashboard layout issue caused by fixed-width CSS grid columns.

## Changes

- Added `docs/samples/mobile-fix-notes.md` with investigation notes and proposed CSS fix

## Status

> **Draft** - Needs real-device testing before review.

The CSS fix has been verified in Chrome DevTools responsive mode but still
needs testing on actual iOS and Android devices.

## Related Issues

Addresses the critical mobile dashboard bug in Sprint 2.
PRBODY

    _push_branch_and_pr "$branch" "$base" "$file" \
        "Fix mobile dashboard responsive layout" \
        "Fix: Resolve mobile dashboard responsive layout" \
        "$body_file" \
        "type: bug,team: frontend,priority: critical" \
        "true"  # draft
    rm -f "$body_file"
}

# ── PR 3: Documentation — API reference ─────────────────────────────────────
_create_pr_api_docs() {
    local base="$1"
    local branch="demo/docs-api-reference"
    local file="docs/samples/api-reference.md"

    git checkout -B "$branch" "origin/$base" >/dev/null 2>&1 || {
        log_warn "Could not create branch: $branch"; return; }
    mkdir -p docs/samples
    cat > "$file" << 'FILECONTENT'
# API Endpoint Reference

## Authentication

| Method | Path               | Description          | Auth Required |
|--------|--------------------|----------------------|---------------|
| POST   | /api/auth/login    | Authenticate user    | No            |
| POST   | /api/auth/logout   | End session          | Yes           |
| POST   | /api/auth/refresh  | Refresh access token | Yes (refresh) |

## Tasks

| Method | Path              | Description        | Auth Required |
|--------|-------------------|--------------------|---------------|
| GET    | /api/tasks        | List tasks         | Yes           |
| POST   | /api/tasks        | Create task        | Yes           |
| GET    | /api/tasks/:id    | Get task details   | Yes           |
| PUT    | /api/tasks/:id    | Update task        | Yes           |
| DELETE | /api/tasks/:id    | Delete task        | Yes (admin)   |
| GET    | /api/tasks/search | Search tasks       | Yes           |

## Projects

| Method | Path               | Description        | Auth Required |
|--------|--------------------|--------------------|---------------|
| GET    | /api/projects      | List projects      | Yes           |
| POST   | /api/projects      | Create project     | Yes           |
| GET    | /api/projects/:id  | Get project detail | Yes           |
| PUT    | /api/projects/:id  | Update project     | Yes (owner)   |
| DELETE | /api/projects/:id  | Delete project     | Yes (admin)   |

## Common Response Codes

| Code | Meaning               |
|------|-----------------------|
| 200  | Success               |
| 201  | Created               |
| 400  | Bad request           |
| 401  | Not authenticated     |
| 403  | Not authorized        |
| 404  | Resource not found    |
| 429  | Rate limit exceeded   |
| 500  | Internal server error |

## Error Response Format

All errors follow a consistent format:

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "The requested resource was not found.",
    "details": null
  }
}
```

## Rate Limiting

- Authenticated requests: 1000 per hour
- Search endpoint: 30 per minute
- Rate limit headers included in every response:
  - `X-RateLimit-Limit`
  - `X-RateLimit-Remaining`
  - `X-RateLimit-Reset`
FILECONTENT

    local body_file
    body_file=$(mktemp)
    cat > "$body_file" << 'PRBODY'
Updates the API reference documentation with all endpoints from Sprint 1.

## Changes

- Added complete endpoint reference (`docs/samples/api-reference.md`)
- Covers authentication, tasks, and projects endpoints
- Added error response format and rate limiting documentation

## Related Issues

Addresses the API documentation update task in Sprint 2.

## Review Checklist

- [ ] All endpoint paths are correct
- [ ] Response codes match implementation
- [ ] Rate limits match server configuration
PRBODY

    _push_branch_and_pr "$branch" "$base" "$file" \
        "Update API endpoint reference docs" \
        "Docs: Update API endpoint reference" \
        "$body_file" \
        "type: documentation,team: backend,status: ready-for-review"
    rm -f "$body_file"
}

# ═════════════════════════════════════════════════════════════════════════════
# CLEANUP — remove all demo data
# ═════════════════════════════════════════════════════════════════════════════
cleanup_data() {
    print_header "🧹 Cleaning Up Demo Data"
    echo -e "  ${BLUE}Repository:${NC} $REPO_NAME"
    echo ""

    # ── Close demo issues ────────────────────────────────────────────────────
    print_section "Closing Demo Issues"
    local issue_numbers
    issue_numbers=$(gh issue list "${REPO_ARGS[@]}" \
        --search "in:title $DEMO_PREFIX" --state open --limit 100 \
        --json number -q '.[].number' 2>/dev/null || echo "")

    if [ -n "$issue_numbers" ]; then
        for num in $issue_numbers; do
            gh issue close "$num" "${REPO_ARGS[@]}" >/dev/null 2>&1 && \
                log_ok "Closed issue #$num" || \
                log_warn "Could not close issue #$num"
            sleep 0.3
        done
    else
        log_ok "No open demo issues found"
    fi
    echo ""

    # ── Close demo PRs and delete branches ───────────────────────────────────
    print_section "Closing Demo Pull Requests"
    local pr_data
    pr_data=$(gh pr list "${REPO_ARGS[@]}" \
        --search "in:title $DEMO_PREFIX" --state open --limit 100 \
        --json number,headRefName \
        -q '.[] | "\(.number) \(.headRefName)"' 2>/dev/null || echo "")

    if [ -n "$pr_data" ]; then
        while IFS=' ' read -r num branch; do
            [ -z "$num" ] && continue
            gh pr close "$num" "${REPO_ARGS[@]}" --delete-branch >/dev/null 2>&1 && \
                log_ok "Closed PR #$num and deleted branch: $branch" || \
                log_warn "Could not close PR #$num"
            sleep 0.3
        done <<< "$pr_data"
    else
        log_ok "No open demo PRs found"
    fi

    # Clean up any remaining demo/ branches
    local demo_branches
    demo_branches=$(git ls-remote --heads origin 'refs/heads/demo/*' 2>/dev/null \
        | awk '{print $2}' | sed 's|refs/heads/||' || echo "")
    if [ -n "$demo_branches" ]; then
        while IFS= read -r branch; do
            [ -z "$branch" ] && continue
            git push origin --delete "$branch" >/dev/null 2>&1 && \
                log_ok "Deleted orphan branch: $branch" || \
                log_warn "Could not delete branch: $branch"
        done <<< "$demo_branches"
    fi
    echo ""

    # ── Delete milestones ────────────────────────────────────────────────────
    print_section "Deleting Milestones"
    local ms_names=("$MILESTONE_SPRINT1" "$MILESTONE_SPRINT2" "$MILESTONE_SPRINT3")
    for ms_name in "${ms_names[@]}"; do
        local ms_number
        ms_number=$(gh api "repos/$REPO_OWNER/$REPO_REPO/milestones?state=all&per_page=100" \
            --jq ".[] | select(.title==\"$ms_name\") | .number" 2>/dev/null || echo "")
        if [ -n "$ms_number" ]; then
            gh api -X DELETE "repos/$REPO_OWNER/$REPO_REPO/milestones/$ms_number" >/dev/null 2>&1 && \
                log_ok "Deleted milestone: $ms_name" || \
                log_warn "Could not delete: $ms_name"
        else
            log_ok "Already removed: $ms_name"
        fi
    done
    echo ""

    # ── Delete custom labels ─────────────────────────────────────────────────
    print_section "Deleting Custom Labels"
    for entry in "${LABEL_DEFS[@]}"; do
        IFS='|' read -r name _ _ <<< "$entry"
        gh label delete "$name" "${REPO_ARGS[@]}" --yes >/dev/null 2>&1 && \
            log_ok "Deleted label: $name" || \
            log_ok "Already removed: $name"
        sleep 0.2
    done
    echo ""

    # ── Clean up local sample files (if in working tree) ─────────────────────
    if [ -d "docs/samples" ]; then
        rm -rf docs/samples
        log_ok "Removed local docs/samples/ directory"
        echo ""
    fi

    print_section "✅ Cleanup Complete"
    echo -e "  Demo data has been removed from ${BOLD}$REPO_NAME${NC}."
    echo -e "  Note: Closed issues remain visible in history (GitHub does not"
    echo -e "  support issue deletion)."
    echo ""
}

# ═════════════════════════════════════════════════════════════════════════════
# SEED — main orchestrator
# ═════════════════════════════════════════════════════════════════════════════
seed_data() {
    print_header "🌱 Seeding Demo Data"
    echo -e "  ${BLUE}Repository:${NC} $REPO_NAME"
    echo -e "  ${BLUE}Prefix:${NC}     $DEMO_PREFIX (identifies all demo items)"
    echo ""

    create_labels
    create_milestones
    create_issues
    create_pull_requests

    echo ""
    print_section "✅ Seeding Complete"
    echo -e "  Created ${BOLD}$CREATED_ISSUES issues${NC} and ${BOLD}$CREATED_PRS pull requests${NC}."
    echo ""
    echo -e "  ${CYAN}Try these commands to explore your demo data:${NC}"
    echo ""
    echo -e "    ${BOLD}sprint-report${NC}    — View sprint progress and metrics"
    echo -e "    ${BOLD}issue-triage${NC}     — Find and triage unlabeled issues"
    echo -e "    ${BOLD}pr-summary${NC}       — Review pull request activity"
    echo -e "    ${BOLD}ci-status${NC}        — Check CI/CD pipeline health"
    echo ""
    echo -e "  ${CYAN}To remove all demo data later:${NC}"
    echo -e "    ${BOLD}./scripts/seed-demo-data.sh --cleanup${NC}"
    echo ""
}

# ═════════════════════════════════════════════════════════════════════════════
# Main
# ═════════════════════════════════════════════════════════════════════════════
case "$ACTION" in
    seed)    seed_data ;;
    cleanup) cleanup_data ;;
    *)       log_fail "Unknown action: $ACTION"; exit 1 ;;
esac
