# Superpowers Integration

## Overview

Rails-AI provides a **layered architecture** where Rails-specific domain knowledge sits on top of Superpowers' universal workflow foundation. This document explains how the two systems integrate and work together.

## Layered Architecture

```text
┌─────────────────────────────────────────────┐
│         Rails-AI (Domain Layer)             │
│                                             │
│  • 6 workflow commands                      │
│    - /rails-ai:setup                        │
│    - /rails-ai:plan                         │
│    - /rails-ai:feature                      │
│    - /rails-ai:refactor                     │
│    - /rails-ai:debug                        │
│    - /rails-ai:review                       │
│                                             │
│  • 11 Rails domain skills                   │
│    - project-setup                          │
│    - controllers                            │
│    - debugging                              │
│    - hotwire                                │
│    - jobs (Solid Stack)                     │
│    - mailers                                │
│    - models                                 │
│    - security                               │
│    - styling (Tailwind + DaisyUI)           │
│    - testing (Minitest/TDD)                 │
│    - views                                  │
│                                             │
│  • Team rules & RuboCop cops                │
│    - 20+ Rails conventions                  │
│    - Custom cops (Hash#dig, etc.)           │
│                                             │
└─────────────────────────────────────────────┘
                    ↓ uses
┌─────────────────────────────────────────────┐
│    Superpowers (Workflow Foundation)        │
│                                             │
│  • Universal workflows                      │
│    - brainstorming                          │
│    - writing-plans                          │
│    - test-driven-development                │
│    - systematic-debugging                   │
│    - requesting-code-review                 │
│    - verification-before-completion         │
│    - executing-plans                        │
│    - subagent-driven-development            │
│    - dispatching-parallel-agents            │
│    - using-git-worktrees                    │
│    - finishing-a-development-branch         │
│    - root-cause-tracing                     │
│    - condition-based-waiting                │
│    - testing-anti-patterns                  │
│    - receiving-code-review                  │
│                                             │
│  • Cross-language patterns                  │
│    - Works for any language/framework       │
│    - Generic software engineering           │
│                                             │
└─────────────────────────────────────────────┘
```

## Why This Architecture?

### Problem: Non-Determinism

Before v0.4.0, Rails-AI used a single `/rails-ai:architect` coordinator that "decided" which superpowers workflows to use. This led to:
- Inconsistent workflow selection
- Context window decay (skill mapping could be forgotten)
- Non-deterministic behavior

### Solution: Domain-Specific Workflows

Rails-AI now provides 6 workflow commands that mirror real Rails developer workflows. Each command:
- **Hardcodes** which superpowers workflows to use (deterministic)
- **Dynamically loads** relevant Rails-AI skills based on task scope
- Has clear **completion requirements** (bin/ci, CHANGELOG, verification)

### Benefits

1. **Deterministic:** Each workflow always uses the same superpowers
2. **No Context Decay:** Commands reload fresh each invocation
3. **Mirror Real Workflows:** Commands match how Rails devs actually work
4. **Clear Separation:** Superpowers = HOW, Rails-AI = WHAT

## Workflow to Superpowers Mapping

### /rails-ai:setup

**Superpowers:**
- verification-before-completion

**Rails-AI Skills (dynamic):**
- project-setup

### /rails-ai:plan

**Superpowers:**
- brainstorming
- writing-plans (optional, if formal plan requested)

**Rails-AI Skills (dynamic):**
- Based on what's being planned

### /rails-ai:feature

**Superpowers:**
- using-git-worktrees
- brainstorming + writing-plans (if no plan provided)
- executing-plans (if plan provided)
- subagent-driven-development
- dispatching-parallel-agents (if 3+ independent tasks)
- test-driven-development
- testing-anti-patterns
- verification-before-completion
- finishing-a-development-branch

**Rails-AI Skills (dynamic):**
- testing (always)
- models, controllers, views, hotwire, styling, jobs, mailers, security (based on scope)

### /rails-ai:refactor

**Superpowers:**
- using-git-worktrees
- verification-before-completion (before AND after)
- test-driven-development
- testing-anti-patterns
- finishing-a-development-branch

**Rails-AI Skills (dynamic):**
- testing (always)
- Based on what's being refactored

### /rails-ai:debug

**Superpowers:**
- systematic-debugging
- root-cause-tracing
- condition-based-waiting (if flaky tests)
- test-driven-development
- verification-before-completion

**Rails-AI Skills (dynamic):**
- debugging (always)
- Based on bug location

### /rails-ai:review

**Superpowers:**
- requesting-code-review
- receiving-code-review (if processing feedback)

**Rails-AI Skills (dynamic):**
- Based on code being reviewed

## Completion Requirements

| Workflow | bin/ci | CHANGELOG | verification |
|----------|--------|-----------|--------------|
| setup    | Yes    | No        | Yes          |
| plan     | No     | No        | No           |
| feature  | Yes    | Yes       | Yes          |
| refactor | Yes    | Yes       | Yes          |
| debug    | Yes    | No        | Yes          |
| review   | No     | No        | No           |

## Workflow Examples

### Example 1: Adding User Authentication

**User request:**
```
/rails-ai:feature Add user authentication
```

**Workflow:**

1. **Workspace Isolation**
   ```
   Uses: superpowers:using-git-worktrees
   ```

2. **Planning (no plan provided)**
   ```
   Uses: superpowers:brainstorming + superpowers:writing-plans
   Loads: rails-ai:models, rails-ai:security
   ```

3. **Implementation**
   ```
   Uses: superpowers:test-driven-development
   Loads:
   - rails-ai:testing (Minitest patterns)
   - rails-ai:models (User model)
   - rails-ai:controllers (SessionsController)
   - rails-ai:security (strong parameters, CSRF)
   ```

4. **Completion**
   ```
   Uses: superpowers:verification-before-completion
   Runs: bin/ci
   Updates: CHANGELOG.md
   Uses: superpowers:finishing-a-development-branch
   ```

### Example 2: Debugging Failing Test

**User request:**
```
/rails-ai:debug Fix failing test in UserTest
```

**Workflow:**

1. **Investigation**
   ```
   Uses: superpowers:systematic-debugging
   Uses: superpowers:root-cause-tracing
   Loads: rails-ai:debugging
   ```

2. **Regression Test**
   ```
   Uses: superpowers:test-driven-development
   Loads: rails-ai:testing
   ```

3. **Verification**
   ```
   Uses: superpowers:verification-before-completion
   Runs: bin/ci
   ```

### Example 3: Refactoring Controller

**User request:**
```
/rails-ai:refactor Extract service object from UsersController
```

**Workflow:**

1. **Workspace & Baseline**
   ```
   Uses: superpowers:using-git-worktrees
   Uses: superpowers:verification-before-completion (baseline)
   ```

2. **Test Coverage**
   ```
   Uses: superpowers:test-driven-development
   Loads: rails-ai:testing, rails-ai:controllers
   ```

3. **Refactor**
   ```
   Loads: rails-ai:controllers, rails-ai:models
   ```

4. **Completion**
   ```
   Uses: superpowers:verification-before-completion (verify)
   Runs: bin/ci
   Updates: CHANGELOG.md
   Uses: superpowers:finishing-a-development-branch
   ```

## Skills as Pure Domain Knowledge

Rails-AI skills no longer reference superpowers workflows. They provide pure domain knowledge:
- Patterns and examples
- Rails conventions
- Team rules
- Best practices

The workflow commands handle the integration with superpowers.

## When to Use What

### Use Rails-AI Workflow Commands When:
- Working on a Rails project
- Need Rails-specific patterns enforced
- Want deterministic superpowers integration

### Use Superpowers Directly When:
- Working on non-Rails projects
- Need workflow without Rails domain knowledge
- Building other domain plugins

## Dependency Management

### plugin.json
Rails-AI declares Superpowers as a dependency:

```json
{
  "name": "rails-ai",
  "dependencies": {
    "superpowers": ">=0.1.0"
  }
}
```

### Installation Order
Users must install Superpowers first:

```bash
# 1. Install Superpowers
/plugin marketplace add obra/superpowers
/plugin install superpowers

# 2. Install Rails-AI
/plugin marketplace add zerobearing2/rails-ai
/plugin install rails-ai
```

## Summary

Rails-AI provides a clean separation of concerns:

**Superpowers = Universal Workflows (HOW)**
- Brainstorming, planning, TDD, debugging, review
- Cross-language patterns
- Workflow orchestration

**Rails-AI = Rails Domain Knowledge (WHAT)**
- 6 workflow commands (setup, plan, feature, refactor, debug, review)
- 11 focused domain skills
- Rails conventions and patterns
- 20+ team rules

Together, they provide a powerful system where:
- Workflow commands define WHEN to use which superpowers (deterministic)
- Skills provide WHAT patterns to follow (domain knowledge)
- Both systems work together seamlessly

## Questions?

- See [CHANGELOG.md](../CHANGELOG.md) for complete list of changes
- Report issues at [GitHub Issues](https://github.com/zerobearing2/rails-ai/issues)
- See [README.md](../README.md) for installation and usage
