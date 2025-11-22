---
description: Review code and PRs against TEAM_RULES
---

# Rails Review Workflow

## Purpose

Use this workflow when:
- Reviewing a pull request
- Reviewing a branch before merge
- Auditing code for TEAM_RULES compliance
- Getting a second opinion on implementation

**This workflow produces feedback, not code.**

## Superpowers Workflows

This workflow uses:
- `superpowers:requesting-code-review` — dispatch reviewer agent
- `superpowers:receiving-code-review` — if processing/responding to feedback

## Rails-AI Skills

Load based on what's being reviewed:

| Code involves | Load these skills |
|---------------|-------------------|
| Models, ActiveRecord | `rails-ai:models` |
| Controllers, routes | `rails-ai:controllers` |
| Views, templates | `rails-ai:views` |
| Hotwire, Turbo | `rails-ai:hotwire` |
| Styling, CSS | `rails-ai:styling` |
| Background jobs | `rails-ai:jobs` |
| Mailers | `rails-ai:mailers` |
| Security | `rails-ai:security` |
| Tests | `rails-ai:testing` |

## Process

### Step 1: Identify What to Review

Clarify the review scope:
- Specific PR? (provide URL or branch name)
- Specific files or directory?
- Full codebase audit?

### Step 2: Load Relevant Skills

Based on the code being reviewed:

```
Use Skill tool to load:
- rails-ai:[domain-skill]
- rails-ai:[domain-skill]
```

### Step 3: Review Against TEAM_RULES

Check code against all 20 TEAM_RULES. Critical violations to catch:

**Reject immediately:**
1. Sidekiq/Redis instead of SolidQueue/SolidCache
2. RSpec instead of Minitest
3. Custom routes instead of RESTful resources
4. Missing tests (TDD violation)
5. Merge without bin/ci passing
6. WebMock not mocking all HTTP in tests

**Check thoroughly:**
- Proper use of concerns
- Strong parameters
- N+1 query prevention
- Security vulnerabilities (XSS, SQL injection, CSRF)
- Accessibility (WCAG 2.1 AA)
- Code organization and patterns

### Step 4: Dispatch Review

Use `superpowers:requesting-code-review`:
- Dispatches code-reviewer agent
- Reviews against plan/requirements
- Checks TEAM_RULES compliance
- Reports findings

### Step 5: Present Findings

Organize feedback by severity:

**Blockers** (must fix before merge):
- TEAM_RULES violations
- Security vulnerabilities
- Missing tests for new behavior
- Broken functionality

**Suggestions** (should consider):
- Code organization improvements
- Performance concerns
- Better patterns available

**Nitpicks** (optional):
- Style preferences
- Minor naming suggestions

### Step 6: If Processing Feedback

If you're on the receiving end of a review:

Use `superpowers:receiving-code-review`:
- Apply technical rigor to feedback
- Don't blindly agree — verify suggestions make sense
- Push back on questionable feedback with evidence

## Completion

**No completion checklist** — this workflow produces feedback, not code.

Output is:
- Review findings organized by severity
- Specific line references where applicable
- Recommendations for addressing issues

---

**Now handle the review request: {{ARGS}}**
