# Design: Domain-Specific Workflow Commands

**Date:** 2025-11-22
**Status:** Ready for implementation

## Problem

The current `/rails-ai:architect` coordinator approach has issues:

1. **Context window decay** — Skill mapping loaded via `using-rails-ai` skill can be truncated in long sessions
2. **Non-deterministic** — Claude "decides" which superpowers to use, leading to inconsistent workflows
3. **Single entry point confusion** — Users must describe what they want; architect routes them
4. **SessionStart hook unreliable** — Local plugin hooks may not fire properly (known Claude Code bug)

## Solution

Replace the single coordinator with **6 domain-specific workflow commands** that mirror real Rails developer workflows. Each command is self-contained with hardcoded superpowers integration.

**Target users:** Experienced Rails developers using a spec-driven approach. They know what they're doing (debugging, implementing, refactoring) and can pick the right workflow.

## Architecture

### Core Principle

- **Superpowers = HOW** (hardcoded per workflow, deterministic process)
- **Rails-AI skills = WHAT** (dynamically loaded based on task scope)

### Workflow Commands

| Command | When to Use |
|---------|-------------|
| `/rails-ai:setup` | Project configuration, gem setup, validation |
| `/rails-ai:plan` | Brainstorm ideas, optionally produce formal plan |
| `/rails-ai:feature` | Implement new functionality (with or without pre-written plan) |
| `/rails-ai:refactor` | Improve existing code, fill test gaps |
| `/rails-ai:debug` | Fix something broken |
| `/rails-ai:review` | Review code/PR against TEAM_RULES |

Order reflects typical project lifecycle: setup → plan → feature → refactor → debug → review.

## Workflow-to-Superpowers Mapping

### `/rails-ai:setup`

**Superpowers:**
- `verification-before-completion`

**Rails-AI skills (dynamic):**
- `project-setup`

**Completion:** bin/ci ✅, CHANGELOG ❌, verification ✅

---

### `/rails-ai:plan`

**Superpowers:**
- `brainstorming`
- `writing-plans` (optional, if formal plan requested)

**Rails-AI skills (dynamic):**
- Load relevant domain skills based on what's being planned

**Completion:** None (produces plan document, not code)

---

### `/rails-ai:feature`

**Superpowers:**
- `using-git-worktrees` — isolate feature work
- `brainstorming` + `writing-plans` — if no plan provided
- `executing-plans` — if plan provided
- `subagent-driven-development` — dispatch workers per task
- `dispatching-parallel-agents` — if 3+ independent tasks
- `test-driven-development` — RED-GREEN-REFACTOR always
- `testing-anti-patterns` — avoid test mistakes
- `verification-before-completion` — before claiming done
- `finishing-a-development-branch` — merge/PR options

**Rails-AI skills (dynamic):**
- `models`, `controllers`, `views`, `hotwire`, `styling`, `jobs`, `mailers`, `security`, `testing` — based on feature scope

**Completion:** bin/ci ✅, CHANGELOG ✅, verification ✅

---

### `/rails-ai:refactor`

**Superpowers:**
- `using-git-worktrees` — isolate refactor work
- `verification-before-completion` — verify tests pass BEFORE refactoring
- `test-driven-development` — for any test gaps
- `testing-anti-patterns` — avoid test mistakes
- `verification-before-completion` — verify tests pass AFTER refactoring
- `finishing-a-development-branch` — merge/PR options

**Rails-AI skills (dynamic):**
- Based on what's being refactored

**Completion:** bin/ci ✅, CHANGELOG ✅, verification ✅

---

### `/rails-ai:debug`

**Superpowers:**
- `systematic-debugging` — four-phase investigation
- `root-cause-tracing` — trace error to source
- `condition-based-waiting` — if flaky test issue
- `test-driven-development` — write regression test
- `verification-before-completion` — verify fix works

**Rails-AI skills (dynamic):**
- `debugging` + relevant domain skills

**Completion:** bin/ci ✅, CHANGELOG ❌, verification ✅

---

### `/rails-ai:review`

**Superpowers:**
- `requesting-code-review` — dispatch reviewer agent
- `receiving-code-review` — if processing feedback

**Rails-AI skills (dynamic):**
- Relevant domain skills for context

**Completion:** None (produces feedback, not code)

---

## Refactoring Scope

### Remove

- [ ] `/rails-ai:architect` command (`commands/architect.md`)
- [ ] `using-rails-ai` skill (`skills/using-rails-ai/`)
- [ ] SessionStart hook (`hooks/hooks.json`, `hooks/session-start.sh`)

### Add

- [ ] `/rails-ai:setup` command
- [ ] `/rails-ai:plan` command
- [ ] `/rails-ai:feature` command
- [ ] `/rails-ai:refactor` command
- [ ] `/rails-ai:debug` command
- [ ] `/rails-ai:review` command

### Refactor

- [ ] Rails-AI skills — remove superpowers references, pure domain knowledge only
- [ ] README — document workflow commands and when to use each
- [ ] CHANGELOG — document this architectural change

## Command Structure Template

Each workflow command follows consistent structure:

```markdown
---
description: [One-line description]
---

## Purpose
[When to use this workflow]

## Superpowers Workflows
[List of superpowers skills — always loaded by this workflow]

## Rails-AI Skills
[Instructions for dynamically loading rails-ai skills based on task scope]

## Process
[Step-by-step workflow mirroring real Rails dev behavior]

## Completion Checklist (if applicable)
- [ ] bin/ci passes
- [ ] CHANGELOG.md updated (if required)
- [ ] superpowers:verification-before-completion used
```

## Skills Refactoring

Rails-AI skills currently contain superpowers references. After refactor:

| Before | After |
|--------|-------|
| Domain knowledge + process instructions | Domain knowledge only |
| "Use `superpowers:systematic-debugging`" | Patterns, rules, examples |
| Mixed concerns | Pure Rails expertise |

Skills to audit for superpowers references:
- `debugging` (references `systematic-debugging`)
- `testing` (references `test-driven-development`)
- Any others with workflow instructions

## Migration Path

1. Create new workflow commands
2. Refactor skills to remove superpowers references
3. Update README with new usage instructions
4. Remove architect command
5. Remove using-rails-ai skill
6. Remove SessionStart hook
7. Update CHANGELOG

## Success Criteria

- [ ] Each workflow command is self-contained
- [ ] Superpowers integration is deterministic (hardcoded per workflow)
- [ ] Rails-AI skills are pure domain knowledge
- [ ] No context window decay issues (no skill mapping to forget)
- [ ] README clearly documents when to use each workflow
- [ ] Existing rails-ai skills still work (just loaded differently)
