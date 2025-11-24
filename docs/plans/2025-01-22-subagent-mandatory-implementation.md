# Subagent-Mandatory Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update feature.md and refactor.md to mandate subagent dispatch for all implementation work.

**Architecture:** Slash commands become coordinators-only. They plan, dispatch a subagent with rich context, receive verification reports, and auto-retry on failure (3x max).

**Tech Stack:** Claude Code slash commands, Task tool with general-purpose subagent

---

## Task 1: Update `commands/feature.md` - Coordinator Role

**Files:**
- Modify: `commands/feature.md` (full rewrite)

**Step 1: Read current file**

Review the current feature.md structure to understand what's there.

**Step 2: Rewrite feature.md with coordinator pattern**

Replace the entire content with the new coordinator-only structure:

```markdown
---
description: Implement new functionality with or without a pre-written plan
---

# Rails Feature Workflow (Coordinator)

## Role

You are a **COORDINATOR ONLY**. You plan and dispatch — you **NEVER implement directly**.

All implementation work happens in subagents with fresh context. This keeps the user's context window clean.

## Purpose

Use this workflow when:
- Implementing new functionality
- Building a feature from a spec or plan
- Adding new capabilities to an existing Rails app

## Coordinator Responsibilities

| You DO (Coordinator) | Subagent DOES (Worker) |
|---------------------|------------------------|
| Brainstorm with user | Write implementation code |
| Create/review plan | TDD cycle (RED-GREEN-REFACTOR) |
| Select rails-ai skills | Run tests |
| Dispatch subagent | Run bin/ci |
| Handle retry on failure | Update CHANGELOG |
| Report final status | Verification checklist |

## Process

### Step 1: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for feature work.

### Step 2: Determine Plan Status

**If user provides a plan:**
- Read and understand the plan
- Skip to Step 4

**If no plan provided:**
- Use `superpowers:brainstorming` to refine the design with user
- Use `superpowers:writing-plans` to create implementation tasks

### Step 3: Identify Required Skills

Based on feature scope, determine which rails-ai skills the subagent needs:

| Feature involves | Skills to include |
|------------------|-------------------|
| Models, databases | `rails-ai:models` |
| Controllers, routes | `rails-ai:controllers` |
| Views, templates | `rails-ai:views` |
| Hotwire, Turbo, Stimulus | `rails-ai:hotwire` |
| CSS, Tailwind | `rails-ai:styling` |
| Background jobs | `rails-ai:jobs` |
| Email | `rails-ai:mailers` |
| Security | `rails-ai:security` |
| Tests (ALWAYS) | `rails-ai:testing` |

### Step 4: Assemble Context Package

Build the rich context package for the subagent:

```
CONTEXT PACKAGE:
1. Implementation Plan - Full task list with specific files and code
2. File Paths - Key files to read/modify
3. TEAM_RULES Summary - Critical rules:
   - Rule #1: Solid Stack only (NO Sidekiq/Redis)
   - Rule #2: Minitest only (NO RSpec)
   - Rule #3: REST routes only
   - Rule #4: TDD always
   - Rule #17: bin/ci must pass
   - Rule #20: Hash#dig for nested access
4. Skills to Load - Explicit list from Step 3
5. Completion Requirements:
   - bin/ci must pass
   - CHANGELOG.md updated under ## [Unreleased]
   - All tests written BEFORE implementation (TDD)
```

### Step 5: Dispatch Subagent

**MANDATORY:** Use the Task tool to dispatch a general-purpose subagent.

```
Task tool parameters:
- subagent_type: "general-purpose"
- prompt: [Context package + implementation instructions]
- description: "Implement [feature name]"
```

The subagent prompt MUST include:

1. The complete context package from Step 4
2. Instruction to use `superpowers:test-driven-development`
3. Instruction to use `superpowers:testing-anti-patterns`
4. Instruction to run `bin/ci` before completion
5. Instruction to update CHANGELOG.md
6. Required return format (verification report)

**Required return format for subagent:**

```
VERIFICATION REPORT:
- Summary: [What was implemented]
- Files Changed: [List of files]
- bin/ci: PASSED | FAILED [error output if failed]
- Tests Added: [count]
- CHANGELOG Updated: yes | no
- Issues Found: [any blockers or concerns]
```

### Step 6: Handle Subagent Response

**If verification report shows all PASSED:**
- Report success to user
- Proceed to Step 7

**If verification report shows FAILED:**
- Auto-dispatch retry (up to 3 attempts)
- Include error context in retry prompt
- After 3 failures, escalate to user with full history

### Step 7: Complete Branch

Use `superpowers:finishing-a-development-branch`:
- Verify tests pass (should already be verified)
- Present merge/PR options to user
- Clean up worktree

## Retry Logic

```
Attempt 1 → FAILED
  └── Dispatch Attempt 2 with error context
Attempt 2 → FAILED
  └── Dispatch Attempt 3 with error context
Attempt 3 → FAILED
  └── ESCALATE to user:
      "After 3 attempts, implementation is still failing:
       - Attempt 1: [error]
       - Attempt 2: [error]
       - Attempt 3: [error]
       How would you like to proceed?"
```

## Completion Checklist

Before reporting feature complete to user:

- [ ] Subagent dispatched (NOT implemented directly)
- [ ] Verification report received with all PASSED
- [ ] `bin/ci` passes confirmed
- [ ] CHANGELOG.md updated confirmed
- [ ] `superpowers:finishing-a-development-branch` used

---

**Now handle the feature request: {{ARGS}}**
```

**Step 3: Verify file saved correctly**

Read the file back and confirm structure is correct.

**Step 4: Commit**

```bash
git add commands/feature.md
git commit -m "refactor(feature): mandate subagent dispatch for implementation

Coordinator-only pattern: plan and dispatch, never implement directly.
- Rich context package for subagent
- Auto-retry on failure (3x max)
- Structured verification report"
```

---

## Task 2: Update `commands/refactor.md` - Coordinator Role

**Files:**
- Modify: `commands/refactor.md` (full rewrite)

**Step 1: Read current file**

Review the current refactor.md structure.

**Step 2: Rewrite refactor.md with coordinator pattern**

Replace the entire content with the new coordinator-only structure:

```markdown
---
description: Improve existing code and fill test gaps
---

# Rails Refactor Workflow (Coordinator)

## Role

You are a **COORDINATOR ONLY**. You plan and dispatch — you **NEVER implement directly**.

All refactoring work happens in subagents with fresh context. This keeps the user's context window clean.

## Purpose

Use this workflow when:
- Improving existing code structure
- Extracting concerns, services, or query objects
- Filling gaps in test coverage
- Cleaning up technical debt
- Improving UI/view code

## Coordinator Responsibilities

| You DO (Coordinator) | Subagent DOES (Worker) |
|---------------------|------------------------|
| Assess refactor scope | Write test coverage gaps |
| Verify tests pass BEFORE | Execute refactoring |
| Create refactor plan | Run tests incrementally |
| Select rails-ai skills | Run bin/ci |
| Dispatch subagent | Update CHANGELOG |
| Handle retry on failure | Verification checklist |
| Report final status | |

## Process

### Step 1: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for refactor work.

### Step 2: Verify Tests Pass BEFORE Refactoring

**CRITICAL:** Run `bin/ci` to establish baseline.

```bash
bin/ci
```

**If tests fail:** Stop. Fix tests first. Do not dispatch subagent for refactoring on broken code.

**If tests pass:** Document the baseline. Subagent will compare against this.

### Step 3: Assess Refactor Scope

Analyze the code to be refactored:
- What behaviors need test coverage?
- What's the refactoring strategy?
- What rails-ai skills are needed?

### Step 4: Identify Required Skills

Based on refactor scope, determine which rails-ai skills the subagent needs:

| Refactoring involves | Skills to include |
|----------------------|-------------------|
| Models, ActiveRecord | `rails-ai:models` |
| Controllers | `rails-ai:controllers` |
| Views, partials | `rails-ai:views` |
| Hotwire, Stimulus | `rails-ai:hotwire` |
| Styling, CSS | `rails-ai:styling` |
| Background jobs | `rails-ai:jobs` |
| Mailers | `rails-ai:mailers` |
| Security | `rails-ai:security` |
| Tests (ALWAYS) | `rails-ai:testing` |

### Step 5: Assemble Context Package

Build the rich context package for the subagent:

```
CONTEXT PACKAGE:
1. Refactor Plan - What to refactor and how
2. File Paths - Files being refactored
3. Test Coverage Gaps - Tests to add before refactoring
4. TEAM_RULES Summary - Critical rules:
   - Rule #1: Solid Stack only (NO Sidekiq/Redis)
   - Rule #2: Minitest only (NO RSpec)
   - Rule #4: TDD always
   - Rule #9: Don't over-abstract
   - Rule #17: bin/ci must pass
5. Skills to Load - Explicit list from Step 4
6. Completion Requirements:
   - Tests pass BEFORE refactoring (baseline)
   - Tests pass AFTER refactoring (behavior preserved)
   - bin/ci must pass
   - CHANGELOG.md updated under ## [Unreleased]
7. Baseline Status - "bin/ci passed at [timestamp]"
```

### Step 6: Dispatch Subagent

**MANDATORY:** Use the Task tool to dispatch a general-purpose subagent.

```
Task tool parameters:
- subagent_type: "general-purpose"
- prompt: [Context package + refactoring instructions]
- description: "Refactor [component name]"
```

The subagent prompt MUST include:

1. The complete context package from Step 5
2. Instruction to fill test gaps FIRST (if needed)
3. Instruction to refactor incrementally (change → test → repeat)
4. Instruction to NOT change behavior (restructure only)
5. Instruction to run `bin/ci` before completion
6. Instruction to update CHANGELOG.md
7. Required return format (verification report)

**Required return format for subagent:**

```
VERIFICATION REPORT:
- Summary: [What was refactored]
- Files Changed: [List of files]
- Tests Added: [count] (for coverage gaps)
- bin/ci BEFORE: PASSED (baseline)
- bin/ci AFTER: PASSED | FAILED [error output if failed]
- Behavior Changed: no | yes [explanation if yes - this is a problem!]
- CHANGELOG Updated: yes | no
- Issues Found: [any blockers or concerns]
```

### Step 7: Handle Subagent Response

**If verification report shows all PASSED and Behavior Changed: no:**
- Report success to user
- Proceed to Step 8

**If Behavior Changed: yes:**
- This is a problem — refactoring should not change behavior
- Escalate to user immediately

**If bin/ci FAILED:**
- Auto-dispatch retry (up to 3 attempts)
- Include error context in retry prompt
- After 3 failures, escalate to user with full history

### Step 8: Complete Branch

Use `superpowers:finishing-a-development-branch`:
- Verify tests pass (should already be verified)
- Present merge/PR options to user
- Clean up worktree

## Retry Logic

```
Attempt 1 → FAILED
  └── Dispatch Attempt 2 with error context
Attempt 2 → FAILED
  └── Dispatch Attempt 3 with error context
Attempt 3 → FAILED
  └── ESCALATE to user:
      "After 3 attempts, refactoring is still failing:
       - Attempt 1: [error]
       - Attempt 2: [error]
       - Attempt 3: [error]
       How would you like to proceed?"
```

## Completion Checklist

Before reporting refactor complete to user:

- [ ] Tests passed BEFORE refactoring (baseline)
- [ ] Subagent dispatched (NOT implemented directly)
- [ ] Verification report received with all PASSED
- [ ] Behavior NOT changed (restructure only)
- [ ] `bin/ci` passes confirmed
- [ ] CHANGELOG.md updated confirmed
- [ ] `superpowers:finishing-a-development-branch` used

---

**Now handle the refactor request: {{ARGS}}**
```

**Step 3: Verify file saved correctly**

Read the file back and confirm structure is correct.

**Step 4: Commit**

```bash
git add commands/refactor.md
git commit -m "refactor(refactor): mandate subagent dispatch for implementation

Coordinator-only pattern: plan and dispatch, never implement directly.
- Baseline verification before dispatching
- Rich context package for subagent
- Auto-retry on failure (3x max)
- Structured verification report"
```

---

## Task 3: Update Tests

**Files:**
- Modify: `test/unit/commands/command_structure_test.rb`

**Step 1: Read current test file**

Review what's currently being tested.

**Step 2: Add coordinator pattern assertions**

Add tests to verify:
- feature.md contains "COORDINATOR ONLY"
- feature.md contains "NEVER implement directly"
- feature.md contains "Task tool"
- refactor.md contains same coordinator patterns

**Step 3: Run tests**

```bash
bin/ci
```

Expected: All tests pass

**Step 4: Commit**

```bash
git add test/unit/commands/command_structure_test.rb
git commit -m "test: add coordinator pattern assertions for feature/refactor"
```

---

## Task 4: Update CHANGELOG

**Files:**
- Modify: `CHANGELOG.md`

**Step 1: Add entry under Unreleased**

```markdown
### Changed
- Feature and Refactor workflows now mandate subagent dispatch (coordinator-only pattern)
- Implementation work happens in subagent context, keeping user context clean
- Auto-retry on failure (3 attempts max) before escalating to user
```

**Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for subagent-mandatory pattern"
```

---

## Task 5: Final Verification

**Step 1: Run full CI**

```bash
bin/ci
```

Expected: All tests and linters pass

**Step 2: Review changes**

```bash
git log --oneline -5
git diff HEAD~4..HEAD --stat
```

Verify 4 commits for the 4 tasks above.
