# Design: Rename /refactor to /fix

**Date:** 2025-01-28
**Status:** Approved

## Summary

Rename the `/rails-ai:refactor` command to `/rails-ai:fix` to better align with common developer workflows. "Fix" is a more intuitive verb for improving existing code — whether that's fixing code quality issues, filling test gaps, addressing review feedback, or restructuring.

## Motivation

- "Fix" is more commonly how developers think about improving existing code
- "Refactor" implies a narrow constraint (no behavior change) that's often too restrictive
- Aligns better with the mental model: `/feature` for new code, `/fix` for existing code

## Changes

### Commands

| Before | After |
|--------|-------|
| `/rails-ai:refactor` | `/rails-ai:fix` |
| `/rails-ai:feature` | unchanged |
| `/rails-ai:debug` | unchanged |

### Developer Agent Modes

| Before | After |
|--------|-------|
| `feature` mode | unchanged |
| `refactor` mode | **removed** |
| `fix` mode | updated wording |

### `/fix` Command Behavior

- **No baseline requirement** — can fix failing tests (unlike `/refactor` which required green baseline)
- **Behavior change allowed** — improving code may change behavior, and that's OK
- **No investigation phase** — user knows what needs fixing (unlike `/debug` which investigates first)
- **Uses `fix` mode** for developer agent dispatch

### `/debug` vs `/fix` Distinction

| Aspect | `/debug` | `/fix` |
|--------|----------|--------|
| Purpose | Something is broken, need to find out why | I know what needs improving |
| Investigation | Yes (systematic debugging, root cause tracing) | No |
| Dispatch timing | After investigation completes | Immediately |
| Use case | Bugs, unexpected failures, production errors | Code quality, test gaps, review findings, restructuring |

### Developer Agent `fix` Mode Updates

Current wording:
> - No baseline verification needed (things may be broken)
> - You're fixing specific issues
> - Follow TDD: write test that exposes the bug, then fix
> - Changed behavior is expected (that's the fix)

Updated wording (covers bugs AND code improvements):
> - No baseline verification needed
> - You're fixing or improving existing code
> - For bugs: write test that exposes the bug, then fix
> - For improvements: ensure tests cover the change, then implement
> - Changed behavior is allowed when it's the intended improvement

## Files to Modify

1. `commands/refactor.md` → rename to `commands/fix.md`, update content
2. `agents/developer.md` → remove `refactor` mode, update `fix` mode wording
3. `AGENTS.md` → update documentation
4. `test/unit/` → update tests referencing refactor

## Migration

No user migration needed — this is a rename with expanded scope, not a breaking change in workflow.
