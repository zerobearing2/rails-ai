---
description: Fix bugs and broken functionality
---

# Rails Debug Workflow

## Purpose

Use this workflow when:
- Something is broken and needs to be fixed
- Tests are failing unexpectedly
- Production errors need investigation
- Flaky tests need stabilization

## Superpowers Workflows

This workflow uses:

**Always:**
- `superpowers:systematic-debugging` — four-phase investigation before fixing
- `superpowers:root-cause-tracing` — trace errors to their source
- `superpowers:test-driven-development` — write regression test for the fix
- `superpowers:verification-before-completion` — verify fix works

**If flaky tests:**
- `superpowers:condition-based-waiting` — replace timeouts with condition polling

## Rails-AI Skills

Load based on where the bug is:

| Bug location | Load these skills |
|--------------|-------------------|
| Models, database | `rails-ai:models` |
| Controllers, routes | `rails-ai:controllers` |
| Views, templates | `rails-ai:views` |
| Hotwire, Turbo | `rails-ai:hotwire` |
| Background jobs | `rails-ai:jobs` |
| Mailers | `rails-ai:mailers` |
| Security issues | `rails-ai:security` |
| Rails debugging tools | `rails-ai:debugging` |
| Tests | `rails-ai:testing` |

**Always load `rails-ai:debugging`** — Rails-specific debugging tools and patterns.

## Process

### Step 1: Load Debugging Skills

```
Use Skill tool to load:
- rails-ai:debugging
- rails-ai:[domain-skill based on bug location]
```

### Step 2: Systematic Investigation

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

**Phase 4: Implementation**
- Only now propose a fix
- Fix the root cause, not symptoms

### Step 3: Trace to Root Cause

Use `superpowers:root-cause-tracing`:
- Trace errors backward through call stack
- Add instrumentation if needed
- Identify the source of invalid data or behavior

### Step 4: Write Regression Test

Use `superpowers:test-driven-development`:

1. **Write a test that reproduces the bug** (should FAIL)
2. **Verify the test fails** — proves test catches the bug
3. **Fix the bug**
4. **Verify the test passes** — proves fix works
5. **Verify test fails if you revert the fix** — proves test is valid

**This is non-negotiable.** A bug fix without a regression test is incomplete.

### Step 5: Handle Flaky Tests (If Applicable)

If the bug involves flaky/intermittent test failures:

Use `superpowers:condition-based-waiting`:
- Replace arbitrary `sleep` calls with condition polling
- Wait for actual state changes, not time
- Eliminate race conditions

### Step 6: Verify Fix

Use `superpowers:verification-before-completion`:

```bash
bin/ci
```

- Original bug test now passes
- All other tests still pass
- No regressions introduced

## Completion Checklist

Before claiming bug is fixed:

- [ ] Root cause identified (not just symptoms)
- [ ] Regression test written and verified (RED then GREEN)
- [ ] `bin/ci` passes (all linters and tests)
- [ ] `superpowers:verification-before-completion` used — evidence before claims

**No CHANGELOG entry required for bug fixes** — unless it's a significant fix worth documenting.

---

**Now handle the debug request: {{ARGS}}**
