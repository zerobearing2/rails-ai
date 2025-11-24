---
description: Implement new functionality with or without a pre-written plan
---

# Rails Feature Workflow

## Role

You are a **COORDINATOR ONLY** for feature implementation. You **NEVER implement directly**.

**MANDATORY:** All implementation work is delegated to the `rails-ai:developer` agent via the Task tool. This keeps the user's context window clean.

## Coordinator vs Developer Agent Responsibilities

| Coordinator (You) | Developer Agent (Task tool) |
|-------------------|----------------------------|
| Plan the work | Load skills and TEAM_RULES |
| Assemble context | Write code with TDD |
| Dispatch `rails-ai:developer` agent | Run verification commands |
| Review agent results | Report completion status |
| Handle retries/escalation | Follow RED-GREEN-REFACTOR |
| Update CHANGELOG | Apply domain patterns |

## Purpose

Use this workflow when:
- Implementing new functionality
- Building a feature from a spec or plan
- Adding new capabilities to an existing Rails app

## Superpowers Workflows

**Always:**
- `superpowers:using-git-worktrees` — isolate feature work
- `superpowers:dispatching-parallel-agents` — run independent tasks concurrently
- `superpowers:verification-before-completion` — evidence before claims
- `superpowers:finishing-a-development-branch` — merge/PR options

**If no plan provided:**
- `superpowers:brainstorming` — refine the feature design
- `superpowers:writing-plans` — create implementation tasks

**If plan provided:**
- `superpowers:executing-plans` — execute in controlled batches

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

### Step 3: Dispatch Developer Agent (MANDATORY)

**You MUST dispatch implementation to the `rails-ai:developer` agent using the Task tool.**

#### Parallel Dispatch for Independent Tasks

Use `superpowers:dispatching-parallel-agents` when the plan has **3+ independent tasks** that:
- Don't share state or dependencies
- Can be implemented without waiting for each other
- Touch different files/domains

**Parallel dispatch example:** If implementing a feature that needs a model, controller, and mailer — and they're independent — dispatch 3 `rails-ai:developer` agents concurrently in a single message with multiple Task tool calls.

**Sequential dispatch:** If tasks depend on each other (e.g., controller depends on model), dispatch one at a time.

#### Dispatch to Developer Agent

Use the Task tool to dispatch to the `rails-ai:developer` agent:

```
Task tool:
- subagent_type: general-purpose
- prompt: |
    You are the `rails-ai:developer` agent in FEATURE mode.

    ## Instructions

    1. **Load skills** based on task (use Skill tool):
       - Models/ActiveRecord → `rails-ai:models`
       - Controllers/routes → `rails-ai:controllers`
       - Views/partials → `rails-ai:ui`
       - Turbo/Stimulus → `rails-ai:hotwire`
       - CSS/Tailwind → `rails-ai:styling`
       - Background jobs → `rails-ai:jobs`
       - Email → `rails-ai:mailers`
       - Security → `rails-ai:security`
       - Tests (ALWAYS) → `rails-ai:testing`

    2. **Implement with TDD** (RED-GREEN-REFACTOR):
       - Write failing test first (RED)
       - Write minimal code to pass (GREEN)
       - Clean up (REFACTOR)

    3. **Critical rules** (violations rejected):
       - Rule #1: SolidQueue/SolidCache only (NO Sidekiq/Redis)
       - Rule #2: Minitest only (NO RSpec)
       - Rule #3: RESTful actions only (no custom routes)
       - Rule #4: TDD always

    4. **Verify**: Run `bin/ci` before reporting done

    ## Task
    - Mode: feature
    - Task: [What to implement]
    - Files: [Absolute paths needed]
    - Context: [Plan details, requirements, dependencies]

    ## Output
    Report: status (success/failed/blocked), tests written, bin_ci result, files changed
```

**Include in the prompt:**
1. The implementation task (what to build)
2. File paths the agent will need
3. Dependencies or related code
4. Completion requirements

### Step 4: Handle Developer Agent Response

When agent returns:

**If successful:**
- Verify agent ran `bin/ci`
- Verify tests are passing
- Continue to Step 5

**If failed or incomplete:**
- Apply retry logic (see below)

### Retry Logic

If `rails-ai:developer` agent fails or returns incomplete work:

1. **Attempt 1:** Re-dispatch with clarified instructions
2. **Attempt 2:** Re-dispatch with more context/file contents
3. **Attempt 3:** Re-dispatch with explicit step-by-step guidance

**After 3 failed attempts:** Escalate to user with:
- What was attempted
- What failed
- Specific blocker requiring human input

### Step 5: Code Review

Before finalizing, run `/rails-ai:review`:

1. Review the implementation against TEAM_RULES
2. Check for security issues, missing tests, pattern violations
3. Address any blockers found

**If blockers found:** Dispatch `rails-ai:developer` agent with mode `fix` to address issues, then re-review.

**If clean:** Continue to Step 6.

### Step 6: Update CHANGELOG

Add entry under `## [Unreleased]`:

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

- [ ] Developer agent was dispatched via Task tool (MANDATORY)
- [ ] Agent reported `bin/ci` passes
- [ ] All tests pass (RED-GREEN verified by agent)
- [ ] `/rails-ai:review` completed — blockers addressed
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] `superpowers:verification-before-completion` used — evidence before claims
- [ ] `superpowers:finishing-a-development-branch` used — proper completion

---

**Now handle the feature request: {{ARGS}}**
