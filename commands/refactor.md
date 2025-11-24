---
description: Improve existing code and fill test gaps
---

# Rails Refactor Workflow

## Role

You are a **COORDINATOR ONLY** for refactoring work. You **NEVER implement directly**.

**MANDATORY:** All implementation work is delegated to the `rails-ai:developer` agent via the Task tool. This keeps the user's context window clean.

## Coordinator vs Developer Agent Responsibilities

| Coordinator (You) | Developer Agent (Task tool) |
|-------------------|----------------------------|
| Verify baseline passes | Load skills and TEAM_RULES |
| Plan the refactor scope | Write code with TDD |
| Dispatch `rails-ai:developer` agent | Run verification commands |
| Verify behavior unchanged | Report completion status |
| Handle retries/escalation | Make incremental changes |
| Update CHANGELOG | Apply domain patterns |

## Purpose

Use this workflow when:
- Improving existing code structure
- Extracting concerns, services, or query objects
- Filling gaps in test coverage
- Cleaning up technical debt
- Improving UI/view code

## Superpowers Workflows

**Always:**
- `superpowers:using-git-worktrees` — isolate refactor work
- `superpowers:dispatching-parallel-agents` — run independent refactors concurrently
- `superpowers:verification-before-completion` — verify tests pass BEFORE and AFTER refactoring
- `superpowers:finishing-a-development-branch` — merge/PR options

**For test gaps:**
- `superpowers:test-driven-development` — fill test coverage gaps
- `superpowers:testing-anti-patterns` — avoid test mistakes

## Process

### Step 1: Verify Baseline (CRITICAL - HARD STOP)

**Before anything else, verify tests pass:**

```bash
bin/ci
```

**If tests fail:** STOP. Do not proceed. Refactoring requires a green baseline.

Tell the user: "Cannot refactor - `bin/ci` is failing. Fix the failing tests first with `/rails-ai:debug`, then retry `/rails-ai:refactor`."

**If tests pass:** Continue to Step 2.

### Step 2: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for refactor work.

### Step 3: Plan the Refactor

Assess what needs to be refactored:
- What code is being restructured?
- What test coverage exists?
- Do test gaps need filling first?
- What is the expected outcome?

### Step 4: Dispatch Developer Agent (MANDATORY)

**You MUST dispatch refactoring to the `rails-ai:developer` agent using the Task tool.**

#### Parallel Dispatch for Independent Refactors

Use `superpowers:dispatching-parallel-agents` when the refactor scope includes **3+ independent areas** that:
- Don't share state or dependencies
- Can be refactored without affecting each other
- Touch different files/domains

**Parallel dispatch example:** If refactoring involves extracting 3 different concerns from a large model — and they're independent — dispatch 3 `rails-ai:developer` agents concurrently in a single message with multiple Task tool calls.

**Sequential dispatch:** If refactors depend on each other (e.g., extracting a concern then using it elsewhere), dispatch one at a time.

**IMPORTANT for refactor mode:** Even with parallel dispatch, each agent must independently verify `behavior_changed: false`. If ANY agent reports behavior changed, stop all work and escalate.

#### Dispatch to Developer Agent

Use the Task tool to dispatch to the `rails-ai:developer` agent:

```
Task tool:
- subagent_type: rails-ai:developer
- prompt: |
    Mode: refactor
    Task: [What to restructure]
    Files: [Absolute paths needed]
    Context: [Baseline status, expected outcome]

    CRITICAL: Behavior must NOT change. Report behavior_changed: false.
```

The `rails-ai:developer` agent will automatically load its instructions and relevant skills.

**Include in the prompt:**
1. Baseline status: `bin/ci` passed before starting
2. Refactor scope: What code is being restructured and why
3. File paths the agent will need
4. Expected outcome (structure change, NOT behavior change)

### Step 5: Handle Developer Agent Response

When agent returns:

**If successful AND behavior unchanged:**
- Verify agent ran `bin/ci`
- Verify tests are passing
- Confirm `behavior_changed: false` in report
- Continue to Step 6

**If behavior changed:**
- **DO NOT RETRY** — This is not a retry situation
- Escalate immediately to user with:
  - What behavior changed
  - Which tests revealed the change
  - Recommendation: revert and rethink approach

**If failed or incomplete (but behavior not changed):**
- Apply retry logic (see below)

### Retry Logic

If `rails-ai:developer` agent fails or returns incomplete work (but behavior was not changed):

1. **Attempt 1:** Re-dispatch with clarified instructions
2. **Attempt 2:** Re-dispatch with more context/file contents
3. **Attempt 3:** Re-dispatch with explicit step-by-step guidance

**After 3 failed attempts:** Escalate to user with:
- What was attempted
- What failed
- Specific blocker requiring human input

### Step 6: Code Review

Before finalizing, run `/rails-ai:review`:

1. Review the refactoring against TEAM_RULES
2. Check for over-abstraction, pattern violations
3. Verify behavior was truly preserved
4. Address any blockers found

**If blockers found:** Dispatch `rails-ai:developer` agent with mode `fix` to address issues, then re-review.

**If clean:** Continue to Step 7.

### Step 7: Update CHANGELOG

Add entry under `## [Unreleased]`:

```markdown
### Changed
- [Description of refactoring]
```

Or if fixing issues:

```markdown
### Fixed
- [Description of what was fixed]
```

### Step 8: Complete Branch

Use `superpowers:finishing-a-development-branch`:
- Verify all tests pass
- Present merge/PR options
- Clean up worktree

## Completion Checklist

Before claiming refactor is complete:

- [ ] Baseline verified (`bin/ci` passed BEFORE dispatching)
- [ ] Developer agent was dispatched via Task tool (MANDATORY)
- [ ] Agent reported `bin/ci` passes
- [ ] Behavior NOT changed (`behavior_changed: false`)
- [ ] `/rails-ai:review` completed — blockers addressed
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] `superpowers:verification-before-completion` used — evidence before claims
- [ ] `superpowers:finishing-a-development-branch` used — proper completion

---

**Now handle the refactor request: {{ARGS}}**
