---
description: Implement new functionality with or without a pre-written plan
---

# Rails Feature Workflow

## Role

You are a **COORDINATOR ONLY** for feature implementation. You **NEVER implement directly** — all implementation work is delegated to subagents via the Task tool.

## Coordinator vs Subagent Responsibilities

| Coordinator (You) | Subagent (Task tool) |
|-------------------|----------------------|
| Plan the work | Execute the implementation |
| Assemble context package | Write code and tests |
| Dispatch subagent | Run verification commands |
| Review subagent results | Report completion status |
| Handle retries/escalation | Follow TDD cycle |
| Update CHANGELOG | Load domain skills |

## Purpose

Use this workflow when:
- Implementing new functionality
- Building a feature from a spec or plan
- Adding new capabilities to an existing Rails app

## Superpowers Workflows

**Always:**
- `superpowers:using-git-worktrees` — isolate feature work
- `superpowers:verification-before-completion` — evidence before claims
- `superpowers:finishing-a-development-branch` — merge/PR options

**If no plan provided:**
- `superpowers:brainstorming` — refine the feature design
- `superpowers:writing-plans` — create implementation tasks

**If plan provided:**
- `superpowers:executing-plans` — execute in controlled batches

## Rails-AI Skills (for Subagent)

The subagent loads these based on feature scope:

| Feature involves | Subagent loads |
|------------------|----------------|
| Models, databases, ActiveRecord | `rails-ai:models` |
| Controllers, routes, REST | `rails-ai:controllers` |
| Views, templates, forms | `rails-ai:views` |
| Hotwire, Turbo, Stimulus | `rails-ai:hotwire` |
| CSS, Tailwind, DaisyUI | `rails-ai:styling` |
| Background jobs, caching | `rails-ai:jobs` |
| Email functionality | `rails-ai:mailers` |
| Security concerns | `rails-ai:security` |
| Tests (always) | `rails-ai:testing` |

**Subagent always loads `rails-ai:testing`** — TDD is non-negotiable.

## Process

### Step 1: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for feature work.

### Step 2: Determine Plan Status

**If user provides a plan:**
- Read and understand the plan
- Skip to Step 3

**If no plan provided:**
- Use `superpowers:brainstorming` to refine the design
- Use `superpowers:writing-plans` to create implementation tasks

### Step 3: Assemble Context Package

Before dispatching subagent, assemble complete context:

**Required Context:**
1. **Plan** — The implementation plan (tasks, order, dependencies)
2. **File Paths** — Absolute paths to all files subagent will need
3. **TEAM_RULES Summary** — Critical rules subagent must follow:
   - Rule #1: Solid Stack only (NO Sidekiq/Redis)
   - Rule #2: Minitest only (NO RSpec)
   - Rule #3: REST routes only
   - Rule #4: TDD always (RED-GREEN-REFACTOR)
   - Rule #17: `bin/ci` must pass before completion
   - Rule #20: Use `Hash#dig` for nested hash access
4. **Skills to Load** — Which rails-ai skills subagent should load
5. **Completion Requirements** — What "done" looks like:
   - All tests pass
   - `bin/ci` passes
   - Feature works as specified

### Step 4: Dispatch Subagent (MANDATORY)

**You MUST dispatch implementation to a subagent using the Task tool.**

```
Task tool prompt structure:

## Implementation Task: [Feature Name]

### Context
[Brief description of what we're building]

### Plan
[The implementation plan with numbered tasks]

### Files to Read
[List absolute file paths the subagent needs]

### TEAM_RULES (MUST FOLLOW)
- #1: Solid Stack only — NO Sidekiq, NO Redis
- #2: Minitest only — NO RSpec
- #3: REST routes only — no custom route patterns
- #4: TDD always — write test first, watch it fail, then implement
- #17: bin/ci must pass — run before claiming done
- #20: Hash#dig — use for all nested hash access

### Skills to Load
Use Skill tool to load:
- rails-ai:testing (ALWAYS)
- [other relevant skills]

### Completion Requirements
1. All tests pass (verified RED-GREEN)
2. bin/ci passes
3. [Feature-specific requirements]

### Verification Report
When complete, report:
- Tests written and passing (list them)
- bin/ci output (pass/fail)
- Files created/modified
- Any issues encountered
```

### Step 5: Handle Subagent Response

When subagent returns:

**If successful:**
- Verify subagent ran `bin/ci`
- Verify tests are passing
- Continue to Step 6

**If failed or incomplete:**
- Apply retry logic (see below)

### Retry Logic

If subagent fails or returns incomplete work:

1. **Attempt 1:** Re-dispatch with clarified instructions
2. **Attempt 2:** Re-dispatch with more context/file contents
3. **Attempt 3:** Re-dispatch with explicit step-by-step guidance

**After 3 failed attempts:** Escalate to user with:
- What was attempted
- What failed
- Specific blocker requiring human input

### Step 6: Update CHANGELOG

Add entry under `## [Unreleased]` with appropriate section:

```markdown
### Added
- [Description of new feature]
```

### Step 7: Complete Branch

Use `superpowers:finishing-a-development-branch`:
- Verify all tests pass
- Present merge/PR options
- Clean up worktree

## Completion Checklist

Before claiming feature is complete:

- [ ] Subagent was dispatched via Task tool (MANDATORY)
- [ ] Subagent reported `bin/ci` passes
- [ ] All tests pass (RED-GREEN verified by subagent)
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] `superpowers:verification-before-completion` used — evidence before claims
- [ ] `superpowers:finishing-a-development-branch` used — proper completion

---

**Now handle the feature request: {{ARGS}}**
