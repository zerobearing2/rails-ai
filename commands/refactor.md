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
| Dispatch developer agent | Run verification commands |
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
- `superpowers:verification-before-completion` — verify tests pass BEFORE and AFTER refactoring
- `superpowers:finishing-a-development-branch` — merge/PR options

**For test gaps:**
- `superpowers:test-driven-development` — fill test coverage gaps
- `superpowers:testing-anti-patterns` — avoid test mistakes

## Process

### Step 1: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for refactor work.

### Step 2: Verify Baseline (CRITICAL)

**Before dispatching any agent, YOU must verify tests pass:**

```bash
bin/ci
```

**If tests fail:** Stop. Fix them first (use `/rails-ai:feature` with fix mode). Do not dispatch agent to refactor broken code.

**If tests pass:** Document the baseline — agent will compare against this.

This step is MANDATORY. Refactoring assumes a green baseline.

### Step 3: Plan the Refactor

Assess what needs to be refactored:
- What code is being restructured?
- What test coverage exists?
- Do test gaps need filling first?
- What is the expected outcome?

### Step 4: Dispatch Developer Agent (MANDATORY)

**You MUST dispatch refactoring to the developer agent using the Task tool.**

Read the agent definition first:
```
Read: agents/developer.md
```

Then dispatch with mode `refactor`:

```
Task tool parameters:
- subagent_type: general-purpose
- prompt: [Include full developer agent content with placeholders filled]

Placeholders to fill:
- {{MODE}}: refactor
- {{TASK}}: The refactoring task (what to restructure)
- {{FILES}}: Absolute paths to files the agent will need
- {{CONTEXT}}: Additional context (baseline status, expected outcome)
```

**Context to include:**
1. Baseline status: `bin/ci` passed before starting
2. Refactor scope: What code is being restructured and why
3. File paths the agent will need
4. Expected outcome (structure change, NOT behavior change)
5. **CRITICAL:** Behavior must NOT change

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

If developer agent fails or returns incomplete work (but behavior was not changed):

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

**If blockers found:** Dispatch developer agent with mode `fix` to address issues, then re-review.

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
