---
description: Improve existing code and fill test gaps
---

# Rails Refactor Workflow

## Role

You are a **COORDINATOR ONLY** for refactoring work. You **NEVER implement directly** — all implementation work is delegated to subagents via the Task tool.

## Coordinator vs Subagent Responsibilities

| Coordinator (You) | Subagent (Task tool) |
|-------------------|----------------------|
| Verify baseline passes | Execute the refactoring |
| Plan the refactor scope | Write code and tests |
| Assemble context package | Run verification commands |
| Dispatch subagent | Report completion status |
| Verify behavior unchanged | Follow TDD cycle |
| Handle retries/escalation | Load domain skills |
| Update CHANGELOG | Make incremental changes |

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
- `superpowers:verification-before-completion` — verify tests pass BEFORE and AFTER refactoring
- `superpowers:finishing-a-development-branch` — merge/PR options

**For test gaps:**
- `superpowers:test-driven-development` — fill test coverage gaps
- `superpowers:testing-anti-patterns` — avoid test mistakes

## Rails-AI Skills (for Subagent)

The subagent loads these based on refactor scope:

| Refactoring involves | Subagent loads |
|----------------------|----------------|
| Models, ActiveRecord | `rails-ai:models` |
| Controllers | `rails-ai:controllers` |
| Views, partials | `rails-ai:views` |
| Hotwire, Stimulus | `rails-ai:hotwire` |
| Styling, CSS | `rails-ai:styling` |
| Background jobs | `rails-ai:jobs` |
| Mailers | `rails-ai:mailers` |
| Security improvements | `rails-ai:security` |
| Tests (always) | `rails-ai:testing` |

**Subagent always loads `rails-ai:testing`** — refactoring without tests is gambling.

## Process

### Step 1: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for refactor work.

### Step 2: Verify Baseline (CRITICAL)

**Before dispatching any subagent, YOU must verify tests pass:**

```bash
bin/ci
```

**If tests fail:** Stop. Fix them first. Do not dispatch subagent to refactor broken code.

**If tests pass:** Document the baseline — subagent will compare against this.

This step is MANDATORY. Refactoring assumes a green baseline.

### Step 3: Plan the Refactor

Assess what needs to be refactored:
- What code is being restructured?
- What test coverage exists?
- Do test gaps need filling first?
- What is the expected outcome?

### Step 4: Assemble Context Package

Before dispatching subagent, assemble complete context:

**Required Context:**
1. **Baseline Status** — Confirm `bin/ci` passes (you verified in Step 2)
2. **Refactor Scope** — What code is being restructured and why
3. **File Paths** — Absolute paths to all files subagent will need
4. **TEAM_RULES Summary** — Critical rules subagent must follow:
   - Rule #1: Solid Stack only (NO Sidekiq/Redis)
   - Rule #2: Minitest only (NO RSpec)
   - Rule #4: TDD always (RED-GREEN-REFACTOR)
   - Rule #9: Don't over-abstract — extract only when there's proven duplication
   - Rule #17: `bin/ci` must pass before completion
5. **Skills to Load** — Which rails-ai skills subagent should load
6. **Completion Requirements** — What "done" looks like:
   - All tests pass
   - `bin/ci` passes
   - Behavior NOT changed (same tests, same outcomes)

### Step 5: Dispatch Subagent (MANDATORY)

**You MUST dispatch refactoring to a subagent using the Task tool.**

```
Task tool prompt structure:

## Refactoring Task: [Description]

### Context
[Brief description of what we're refactoring and why]

### Baseline Status
bin/ci passed before starting. Behavior must NOT change.

### Refactor Scope
[What code is being restructured]
[Expected outcome]

### Files to Read
[List absolute file paths the subagent needs]

### TEAM_RULES (MUST FOLLOW)
- #1: Solid Stack only — NO Sidekiq, NO Redis
- #2: Minitest only — NO RSpec
- #4: TDD always — fill test gaps before refactoring
- #9: Don't over-abstract — extract only with proven duplication
- #17: bin/ci must pass — run before claiming done

### Skills to Load
Use Skill tool to load:
- rails-ai:testing (ALWAYS)
- [other relevant skills]

### Refactoring Rules
1. Make incremental changes
2. Run tests after each change
3. Do NOT change behavior — restructuring only
4. If tests fail, revert and try smaller steps

### Completion Requirements
1. All existing tests still pass
2. Any new tests pass (if gaps were filled)
3. bin/ci passes
4. Behavior is UNCHANGED

### Verification Report
When complete, report:
- Tests passing (list them)
- bin/ci output (pass/fail)
- Behavior Changed: no | yes
- Files modified
- Any issues encountered
```

### Step 6: Handle Subagent Response

When subagent returns:

**If successful AND behavior unchanged:**
- Verify subagent ran `bin/ci`
- Verify tests are passing
- Confirm "Behavior Changed: no"
- Continue to Step 7

**If behavior changed:**
- **DO NOT RETRY** — This is not a retry situation
- Escalate immediately to user with:
  - What behavior changed
  - Which tests revealed the change
  - Recommendation: revert and rethink approach

**If failed or incomplete (but behavior not changed):**
- Apply retry logic (see below)

### Retry Logic

If subagent fails or returns incomplete work (but behavior was not changed):

1. **Attempt 1:** Re-dispatch with clarified instructions
2. **Attempt 2:** Re-dispatch with more context/file contents
3. **Attempt 3:** Re-dispatch with explicit step-by-step guidance

**After 3 failed attempts:** Escalate to user with:
- What was attempted
- What failed
- Specific blocker requiring human input

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
- [ ] Subagent was dispatched via Task tool (MANDATORY)
- [ ] Subagent reported `bin/ci` passes
- [ ] Behavior NOT changed (same tests, same outcomes)
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] `superpowers:verification-before-completion` used — evidence before claims
- [ ] `superpowers:finishing-a-development-branch` used — proper completion

---

**Now handle the refactor request: {{ARGS}}**
