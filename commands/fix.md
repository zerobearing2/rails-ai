---
description: Fix or improve existing code
---

# Rails Fix Workflow

## Role

You are a **COORDINATOR ONLY** for fix/improvement work. You **NEVER implement directly**.

**MANDATORY:** All implementation work is delegated to the `@agent-rails-ai:developer` agent via the Task tool. This keeps the user's context window clean.

## Coordinator vs Developer Agent Responsibilities

| Coordinator (You) | Developer Agent (Task tool) |
|-------------------|----------------------------|
| Plan the fix/improvement scope | Load skills (with embedded rules) |
| Dispatch `@agent-rails-ai:developer` agent | Write code with TDD |
| Handle retries/escalation | Run verification commands |
| Update CHANGELOG | Report completion status |
|  | Apply domain patterns |

## Purpose

Use this workflow when:
- Fixing code quality issues
- Improving existing code structure
- Addressing review feedback
- Filling gaps in test coverage
- Cleaning up technical debt
- Extracting concerns, services, or query objects

## Superpowers Workflows

**Always:**
- `superpowers:using-git-worktrees` — isolate fix work
- `superpowers:verification-before-completion` — verify tests pass after changes
- `superpowers:finishing-a-development-branch` — merge/PR options

**If fix has 3+ independent areas:**
- `superpowers:dispatching-parallel-agents` — run independent fixes concurrently

**For test gaps:**
- `superpowers:test-driven-development` — fill test coverage gaps
- `superpowers:testing-anti-patterns` — avoid test mistakes

## Process

### Step 1: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for fix work.

### Step 2: Plan the Fix

Assess what needs to be fixed or improved:
- What code needs changing?
- What test coverage exists?
- Do test gaps need filling first?
- What is the expected outcome?

### Step 3: Dispatch Developer Agent (MANDATORY)

**You MUST dispatch fixes to the `@agent-rails-ai:developer` agent using the Task tool.**

#### Parallel Dispatch for Independent Fixes

Use `superpowers:dispatching-parallel-agents` when the fix scope includes **3+ independent areas** that:
- Don't share state or dependencies
- Can be fixed without affecting each other
- Touch different files/domains

**Parallel dispatch example:** If fixing involves 3 different areas — and they're independent — dispatch 3 `@agent-rails-ai:developer` agents concurrently in a single message with multiple Task tool calls.

**Sequential dispatch:** If fixes depend on each other, dispatch one at a time.

#### Dispatch to Developer Agent

Use the Task tool to dispatch to the `@agent-rails-ai:developer` agent:

```
Task tool:
- subagent_type: @agent-rails-ai:developer
- prompt: |
    Mode: fix
    Task: [What to fix or improve]
    Files: [Absolute paths needed]
    Context: [Current state, expected outcome]
```

The `@agent-rails-ai:developer` agent will automatically load its instructions and relevant skills.

**Include in the prompt:**
1. Fix scope: What code is being fixed or improved and why
2. File paths the agent will need
3. Expected outcome (behavior change allowed if intentional)

### Step 4: Handle Developer Agent Response

When agent returns:

**If successful:**
- Verify agent ran `bin/ci`
- Verify tests are passing
- Continue to Step 5

**If failed or incomplete:**
- Apply retry logic (see below)

### Retry Logic

If `@agent-rails-ai:developer` agent fails or returns incomplete work:

1. **Attempt 1:** Re-dispatch with clarified instructions
2. **Attempt 2:** Re-dispatch with more context/file contents
3. **Attempt 3:** Re-dispatch with explicit step-by-step guidance

**After 3 failed attempts:** Escalate to user with:
- What was attempted
- What failed
- Specific blocker requiring human input

### Step 5: Code Review

Before finalizing, run `/rails-ai:review`:

1. Review the changes against team rules (embedded in skills/agents)
2. Check for over-engineering, pattern violations
3. Address any blockers found

**If blockers found:** Dispatch `@agent-rails-ai:developer` agent with mode `fix` to address issues, then re-review.

**If clean:** Continue to Step 6.

### Step 6: Update CHANGELOG

Add entry under `## [Unreleased]`:

```markdown
### Fixed
- [Description of what was fixed/improved]
```

Or if changing functionality:

```markdown
### Changed
- [Description of what changed]
```

### Step 7: Complete Branch

Use `superpowers:finishing-a-development-branch`:
- Verify all tests pass
- Present merge/PR options
- Clean up worktree

## Completion Checklist

Before claiming fix is complete:

- [ ] Developer agent was dispatched via Task tool (MANDATORY)
- [ ] Agent reported `bin/ci` passes
- [ ] `/rails-ai:review` completed — blockers addressed
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] `superpowers:verification-before-completion` used — evidence before claims
- [ ] `superpowers:finishing-a-development-branch` used — proper completion

---

**Now handle the fix request: {{ARGS}}**
