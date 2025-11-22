---
description: Implement new functionality with or without a pre-written plan
---

# Rails Feature Workflow

## Purpose

Use this workflow when:
- Implementing new functionality
- Building a feature from a spec or plan
- Adding new capabilities to an existing Rails app

## Superpowers Workflows

This workflow uses:

**Always:**
- `superpowers:using-git-worktrees` — isolate feature work
- `superpowers:test-driven-development` — RED-GREEN-REFACTOR cycle
- `superpowers:testing-anti-patterns` — avoid test mistakes
- `superpowers:verification-before-completion` — evidence before claims
- `superpowers:finishing-a-development-branch` — merge/PR options

**If no plan provided:**
- `superpowers:brainstorming` — refine the feature design
- `superpowers:writing-plans` — create implementation tasks

**If plan provided:**
- `superpowers:executing-plans` — execute in controlled batches

**For implementation:**
- `superpowers:subagent-driven-development` — dispatch workers per task
- `superpowers:dispatching-parallel-agents` — if 3+ independent tasks

## Rails-AI Skills

Load based on feature scope:

| Feature involves | Load these skills |
|------------------|-------------------|
| Models, databases, ActiveRecord | `rails-ai:models` |
| Controllers, routes, REST | `rails-ai:controllers` |
| Views, templates, forms | `rails-ai:views` |
| Hotwire, Turbo, Stimulus | `rails-ai:hotwire` |
| CSS, Tailwind, DaisyUI | `rails-ai:styling` |
| Background jobs, caching | `rails-ai:jobs` |
| Email functionality | `rails-ai:mailers` |
| Security concerns | `rails-ai:security` |
| Tests (always) | `rails-ai:testing` |

**Always load `rails-ai:testing`** — TDD is non-negotiable (TEAM_RULES #4).

## Process

### Step 1: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for feature work.

### Step 2: Determine Plan Status

**If user provides a plan:**
- Read and understand the plan
- Skip to Step 4

**If no plan provided:**
- Load relevant rails-ai domain skills
- Use `superpowers:brainstorming` to refine the design
- Use `superpowers:writing-plans` to create implementation tasks

### Step 3: Load Rails-AI Skills

Based on feature scope, load appropriate domain skills:

```
Use Skill tool to load:
- rails-ai:testing (always)
- rails-ai:[domain-skill]
- rails-ai:[domain-skill]
```

### Step 4: Execute Implementation

Use `superpowers:executing-plans` or `superpowers:subagent-driven-development`:

For each task:
1. **Write test first** (RED) — use `superpowers:test-driven-development`
2. **Watch test fail** — confirms test works
3. **Implement minimal code** (GREEN)
4. **Refactor if needed**
5. **Verify tests pass**

Use `superpowers:testing-anti-patterns` to avoid:
- Testing mock behavior instead of real behavior
- Adding test-only methods to production code
- Mocking without understanding dependencies

For 3+ independent tasks, use `superpowers:dispatching-parallel-agents`.

### Step 5: Verify Implementation

Before claiming feature is complete:

1. Run full test suite
2. Run `bin/ci` (linting + tests)
3. Use `superpowers:verification-before-completion`

### Step 6: Update CHANGELOG

Add entry under `## [Unreleased]` with appropriate section:

```markdown
### Added
- [Description of new feature]
```

### Step 7: Complete Branch

Use `superpowers:finishing-a-development-branch`:
- Verify tests pass
- Present merge/PR options
- Clean up worktree

## Completion Checklist

Before claiming feature is complete:

- [ ] All tests pass (RED-GREEN verified)
- [ ] `bin/ci` passes (all linters and tests)
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] `superpowers:verification-before-completion` used — evidence before claims
- [ ] `superpowers:finishing-a-development-branch` used — proper completion

---

**Now handle the feature request: {{ARGS}}**
