---
description: Improve existing code and fill test gaps
---

# Rails Refactor Workflow

## Purpose

Use this workflow when:
- Improving existing code structure
- Extracting concerns, services, or query objects
- Filling gaps in test coverage
- Cleaning up technical debt
- Improving UI/view code

## Superpowers Workflows

This workflow uses:

**Always:**
- `superpowers:using-git-worktrees` — isolate refactor work
- `superpowers:verification-before-completion` — verify tests pass BEFORE refactoring
- `superpowers:test-driven-development` — for any test gaps
- `superpowers:testing-anti-patterns` — avoid test mistakes
- `superpowers:verification-before-completion` — verify tests pass AFTER refactoring
- `superpowers:finishing-a-development-branch` — merge/PR options

## Rails-AI Skills

Load based on what's being refactored:

| Refactoring involves | Load these skills |
|----------------------|-------------------|
| Models, ActiveRecord | `rails-ai:models` |
| Controllers | `rails-ai:controllers` |
| Views, partials | `rails-ai:views` |
| Hotwire, Stimulus | `rails-ai:hotwire` |
| Styling, CSS | `rails-ai:styling` |
| Background jobs | `rails-ai:jobs` |
| Mailers | `rails-ai:mailers` |
| Security improvements | `rails-ai:security` |
| Tests (always) | `rails-ai:testing` |

**Always load `rails-ai:testing`** — refactoring without tests is gambling.

## Process

### Step 1: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for refactor work.

### Step 2: Verify Tests Pass BEFORE Refactoring

**CRITICAL:** Use `superpowers:verification-before-completion` to confirm:

```bash
bin/ci
```

**If tests fail:** Fix them first. Do not refactor broken code.

**If tests pass:** Document the baseline — you'll compare against this.

### Step 3: Assess Test Coverage

Before refactoring, check if the code being refactored has adequate test coverage:

- Are the behaviors under test covered?
- Will your refactor break existing tests?
- Do you need to add tests first?

### Step 4: Load Rails-AI Skills

Based on refactor scope:

```
Use Skill tool to load:
- rails-ai:testing (always)
- rails-ai:[domain-skill]
```

### Step 5: Fill Test Gaps (If Needed)

If test coverage is insufficient, use `superpowers:test-driven-development`:

1. Write tests for existing behavior (they should pass)
2. Verify tests actually test the behavior (not just pass)
3. Now you have a safety net for refactoring

Use `superpowers:testing-anti-patterns` to avoid:
- Testing mock behavior instead of real behavior
- Adding test-only methods to production code

### Step 6: Refactor

Make incremental changes:
1. Small refactor step
2. Run tests
3. Verify still green
4. Repeat

**Do not change behavior** — refactoring is restructuring, not feature work.

### Step 7: Verify Tests Pass AFTER Refactoring

Use `superpowers:verification-before-completion`:

```bash
bin/ci
```

Same tests should pass. If new tests were added, all tests should pass.

### Step 8: Update CHANGELOG

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

### Step 9: Complete Branch

Use `superpowers:finishing-a-development-branch`:
- Verify tests pass
- Present merge/PR options
- Clean up worktree

## Completion Checklist

Before claiming refactor is complete:

- [ ] Tests passed BEFORE refactoring (baseline established)
- [ ] Tests pass AFTER refactoring (behavior preserved)
- [ ] `bin/ci` passes (all linters and tests)
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] `superpowers:verification-before-completion` used — evidence before claims
- [ ] `superpowers:finishing-a-development-branch` used — proper completion

---

**Now handle the refactor request: {{ARGS}}**
