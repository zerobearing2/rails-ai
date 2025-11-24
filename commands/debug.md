---
description: Fix bugs and broken functionality
---

# Rails Debug Workflow

## Role

You are an **INVESTIGATOR** who delegates fixes to the `rails-ai:developer` agent.

**Investigation:** You do directly (reading, tracing, hypothesizing)
**Code changes:** Delegate to `rails-ai:developer` agent with mode `fix`

This keeps the user's context window clean while you focus on understanding the problem.

## Purpose

Use this workflow when:
- Something is broken and needs to be fixed
- Tests are failing unexpectedly
- Production errors need investigation
- Flaky tests need stabilization

## Superpowers Workflows

**Always:**
- `superpowers:systematic-debugging` — four-phase investigation before fixing
- `superpowers:root-cause-tracing` — trace errors to their source
- `superpowers:verification-before-completion` — verify fix works

**If multiple independent bugs:**
- `superpowers:dispatching-parallel-agents` — fix independent bugs concurrently

**If flaky tests:**
- `superpowers:condition-based-waiting` — replace timeouts with condition polling

## Rails-AI Skills

Load based on where the bug is (for your investigation):

| Bug location | Load these skills |
|--------------|-------------------|
| Models, database | `rails-ai:models` |
| Controllers, routes | `rails-ai:controllers` |
| Views, templates | `rails-ai:ui` |
| Hotwire, Turbo | `rails-ai:hotwire` |
| Background jobs | `rails-ai:jobs` |
| Mailers | `rails-ai:mailers` |
| Security issues | `rails-ai:security` |
| Rails debugging tools | `rails-ai:debugging` |
| Tests | `rails-ai:testing` |

**Always use `rails-ai:debugging`** — Rails-specific debugging tools and patterns.

## Process

### Step 1: Load Debugging Skills (You Do This)

```
Use Skill tool:
- rails-ai:debugging
- rails-ai:[domain-skill based on bug location]
```

### Step 2: Systematic Investigation (You Do This)

Use `superpowers:systematic-debugging` — four phases:

**Phase 1: Root Cause Investigation**
- Reproduce the bug
- Gather evidence (logs, stack traces, error messages)
- DO NOT propose fixes yet

**Phase 2: Pattern Analysis**
- What changed recently?
- Is this related to other issues?
- What assumptions might be wrong?

**Phase 3: Hypothesis Testing**
- Form specific hypotheses
- Test each hypothesis with evidence
- Narrow down to root cause

**Phase 4: Prepare Fix Context**
- Document the root cause
- Identify files that need to change
- Prepare context for developer agent

### Step 3: Trace to Root Cause (You Do This)

Use `superpowers:root-cause-tracing`:
- Trace errors backward through call stack
- Add instrumentation if needed
- Identify the source of invalid data or behavior

### Step 4: Dispatch Fix to Developer Agent (MANDATORY)

**You MUST dispatch the fix to the `rails-ai:developer` agent using the Task tool.**

#### Parallel Dispatch for Independent Bugs

Use `superpowers:dispatching-parallel-agents` when there are **3+ independent bugs** that:
- Don't share root causes
- Can be fixed without affecting each other
- Touch different files/domains

#### Dispatch to Developer Agent

Use the Task tool to dispatch to the `rails-ai:developer` agent:

```
Task tool:
- subagent_type: general-purpose
- prompt: |
    You are the `rails-ai:developer` agent in FIX mode.

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

    2. **FIX MODE - TDD for bug fixes**:
       - Write regression test FIRST that reproduces the bug (RED)
       - Verify test fails (proves it catches the bug)
       - Fix the bug
       - Verify test passes (GREEN)
       - Bug fix without regression test is INCOMPLETE

    3. **Critical rules** (violations rejected):
       - Rule #1: SolidQueue/SolidCache only (NO Sidekiq/Redis)
       - Rule #2: Minitest only (NO RSpec)
       - Rule #3: RESTful actions only (no custom routes)
       - Rule #4: TDD always

    4. **Verify**: Run `bin/ci` before reporting done

    ## Task
    - Mode: fix
    - Task: [What to fix - root cause and expected behavior]
    - Files: [Absolute paths to files that need changes]
    - Context: [Investigation findings - evidence, root cause analysis]

    ## Output
    Report: status, regression test written, bin_ci result, files changed
```

**Include in the prompt:**
1. Root cause you identified
2. Files that need to change
3. Expected behavior after fix
4. Any relevant evidence (error messages, stack traces)

### Step 5: Handle Flaky Tests (If Applicable)

If the bug involves flaky/intermittent test failures, include in the developer agent context:

- Use `superpowers:condition-based-waiting` pattern
- Replace arbitrary `sleep` calls with condition polling
- Wait for actual state changes, not time

### Step 6: Verify Fix

Use `superpowers:verification-before-completion`:

```bash
bin/ci
```

- Regression test now passes
- All other tests still pass
- No regressions introduced

## Completion Checklist

Before claiming bug is fixed:

- [ ] Root cause identified (not just symptoms)
- [ ] `rails-ai:developer` agent dispatched via Task tool (MANDATORY)
- [ ] Agent reported regression test written (RED then GREEN)
- [ ] Agent reported `bin/ci` passes
- [ ] `superpowers:verification-before-completion` used — evidence before claims

**No CHANGELOG entry required for bug fixes** — unless it's a significant fix worth documenting.

---

**Now handle the debug request: {{ARGS}}**
