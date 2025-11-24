# Subagent-Mandatory Implementation Design

## Problem

The current `/rails-ai:feature` and `/rails-ai:refactor` workflows list `superpowers:subagent-driven-development` as an option, not a mandate. This allows Claude to rationalize doing work directly in the user's context, leading to:

- Inconsistent subagent usage
- User's context window filling with implementation details
- Context window turnover forcing new sessions mid-feature

## Solution

Make subagent dispatch **mandatory** for implementation work. The slash commands become **coordinators only** — they plan and dispatch, but never implement directly.

## Architecture

```
User Context (Coordinator)          Subagent Context (Worker)
┌─────────────────────────┐        ┌─────────────────────────┐
│ /rails-ai:feature       │        │ Fresh context           │
│                         │        │                         │
│ 1. Brainstorm/Plan      │───────▶│ • Implementation plan   │
│ 2. Dispatch subagent    │        │ • File paths            │
│ 3. Receive report       │◀───────│ • TEAM_RULES            │
│ 4. Retry if failed      │        │ • Skills to load        │
│ 5. Report to user       │        │ • TDD + verification    │
└─────────────────────────┘        └─────────────────────────┘
```

**Key principle:** User stays as architect with clean context. Implementation happens in subagents with fresh context windows.

## Context Package

The coordinator assembles a rich context package before dispatching:

```
CONTEXT PACKAGE
├── Implementation Plan
│   └── Tasks with specific files, code changes, test requirements
├── File Paths
│   └── Key files the subagent will need to read/modify
├── TEAM_RULES Summary
│   └── Critical rules (TDD, no Sidekiq, nested bracket access, etc.)
├── Skills to Load
│   └── Explicit list: rails-ai:testing, rails-ai:models, etc.
└── Completion Requirements
    └── Must pass: bin/ci, CHANGELOG updated, verification checklist
```

## Verification Report

The subagent returns a structured verification report:

```
VERIFICATION REPORT
├── Summary: "Added User model with validations, 3 tests"
├── Files Changed: [app/models/user.rb, test/models/user_test.rb]
├── bin/ci: PASSED | FAILED (with error output)
├── Tests Added: 3
├── CHANGELOG Updated: yes | no
└── Issues Found: [] | ["description of blocker"]
```

## Retry Logic

Automatic retry on failure, up to 3 attempts:

```
Attempt 1 → FAILED (bin/ci lint error)
  └── Auto-dispatch Attempt 2 with error context
Attempt 2 → FAILED (test failure)
  └── Auto-dispatch Attempt 3 with error context
Attempt 3 → FAILED
  └── ESCALATE to user with full history
```

After 3 failed attempts, escalate to user with complete context of what was tried.

## Scope

### Affected Workflows

| Workflow | Change |
|----------|--------|
| `feature` | Coordinator-only, mandatory subagent dispatch |
| `refactor` | Coordinator-only, mandatory subagent dispatch |

### Unchanged Workflows

| Workflow | Reason |
|----------|--------|
| `setup` | Direct user interaction for config decisions |
| `plan` | Brainstorming conversation with user |
| `debug` | User wants to see investigation unfold |
| `review` | Reviewing, not implementing |

## Coordinator vs Subagent Responsibilities

| Coordinator (User Context) | Subagent (Fresh Context) |
|---------------------------|-------------------------|
| Brainstorming with user | Implementation code |
| Writing/reviewing plan | TDD cycle (RED-GREEN-REFACTOR) |
| Skill selection decisions | Running tests |
| Dispatching subagent | Running bin/ci |
| Retry decisions | Updating CHANGELOG |
| Final status report | Verification checklist |

## Implementation Tasks

### Task 1: Update `commands/feature.md`

1. Add coordinator role definition at top
2. Remove "or" options — subagent is mandatory
3. Add context package assembly step
4. Add subagent dispatch with Task tool specification
5. Add retry loop (3 attempts max)
6. Add escalation handling
7. Restructure process: Plan → Dispatch → Verify → Report

### Task 2: Update `commands/refactor.md`

Same changes as feature.md, adapted for refactoring context.

### Task 3: Test the workflows

1. Run `/rails-ai:feature` on a test task
2. Verify subagent is dispatched (not direct implementation)
3. Verify retry logic works on simulated failure
4. Verify escalation after 3 failures

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Subagent usage | Mandatory | Prevents rationalization, ensures clean context |
| Context package | Rich | Subagent has everything needed to work independently |
| Return format | Summary + verification | Clear completion status for coordinator |
| Retry handling | Auto-retry, 3 max | Streamlined flow, escalate persistent failures |
| Affected workflows | Feature + Refactor only | Other workflows need direct interaction |
