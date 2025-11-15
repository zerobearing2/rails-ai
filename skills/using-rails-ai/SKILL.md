---
name: using-rails-ai
description: Rails-AI introduction - explains how rails-ai (Rails domain layer) integrates with superpowers (universal workflows) for Rails development
---

# Using Rails-AI: Rails Domain Layer on Superpowers Workflows

## What is Rails-AI?

Rails-AI provides **Rails-specific domain knowledge** that integrates with **Superpowers universal workflows**.

**Two-Layer Architecture:**

```text

┌─────────────────────────────────────────┐
│ RAILS-AI (Domain Layer)                 │
│ - Rails patterns (Hotwire, AR, etc.)    │
│ - TEAM_RULES.md enforcement             │
│ - Rails debugging tools                 │
│ - Context7 Rails docs integration       │
└─────────────────────────────────────────┘
           ↓ uses
┌─────────────────────────────────────────┐
│ SUPERPOWERS (Workflow Layer)            │
│ - brainstorming, planning, executing    │
│ - TDD, debugging, verification          │
│ - Code review, parallelization          │
└─────────────────────────────────────────┘

```

## When to Use Rails-AI

**Use Rails-AI for:**
- ✅ Rails patterns (Hotwire, ActiveRecord, Tailwind)
- ✅ Rails debugging (logs, console, byebug)
- ✅ TEAM_RULES.md enforcement (Solid Stack, Minitest, REST, TDD)
- ✅ Rails file structure knowledge

**Use Superpowers for:**
- ✅ Design refinement (brainstorming)
- ✅ Implementation planning (writing-plans)
- ✅ Execution workflows (executing-plans, subagent-driven-development)
- ✅ TDD process (test-driven-development)
- ✅ Debugging process (systematic-debugging)
- ✅ Code review (requesting-code-review)

## Typical Rails Workflow

**User:** "I need a user authentication system"

**Architect coordinates:**

1. **Design Phase:**
   - Use superpowers:brainstorming (Socratic questioning)
   - Load rails-ai:configuration, rails-ai:models for context
   - Query Context7 for current Rails auth patterns
   - Document to docs/plans/YYYY-MM-DD-auth-design.md

2. **Planning Phase:**
   - Use superpowers:writing-plans (bite-sized TDD tasks)
   - Reference rails-ai:testing, rails-ai:models in tasks
   - Include exact Rails paths (app/models/user.rb, test/models/user_test.rb)
   - Save to docs/plans/YYYY-MM-DD-auth-plan.md

3. **Execution Phase:**
   - Use superpowers:subagent-driven-development (fast iteration + review)
   - Delegate to @backend with rails-ai:models, rails-ai:controllers skills
   - Each task: RED-GREEN-REFACTOR (superpowers:TDD + rails-ai:testing)
   - Review with superpowers:code-reviewer against TEAM_RULES.md

4. **Verification:**
   - Use superpowers:verification-before-completion
   - Run bin/ci (all quality gates)
   - Confirm evidence before success claim

## Available Rails-AI Skills

**9 Domain-Based Skills (Consolidated):**

1. **rails-ai:views** - Frontend UI with Hotwire, ViewComponent, Tailwind, DaisyUI, forms, accessibility
2. **rails-ai:controllers** - RESTful actions, nested resources, skinny controllers, concerns, strong parameters
3. **rails-ai:models** - ActiveRecord patterns, validations, associations, callbacks, query objects, form objects
4. **rails-ai:testing** - TDD with Minitest, fixtures, mocking, test helpers, ViewComponent testing
5. **rails-ai:security** - XSS, SQL injection, CSRF, strong parameters, file uploads, command injection
6. **rails-ai:configuration** - Environment config, credentials, initializers, Docker, RuboCop
7. **rails-ai:jobs-mailers** - SolidQueue, SolidCache, SolidCable, ActionMailer (TEAM RULE #1: NO Redis/Sidekiq)
8. **rails-ai:debugging** - Rails debugging tools (logs, console, byebug) + superpowers:systematic-debugging
9. **rails-ai:using-rails-ai** - This guide - how rails-ai integrates with superpowers workflows

## TEAM_RULES.md Enforcement

**6 Critical Rules (REJECT violations):**
1. ❌ NEVER Sidekiq/Redis → ✅ SolidQueue/SolidCache
2. ❌ NEVER RSpec → ✅ Minitest only
3. ❌ NEVER custom routes → ✅ RESTful resources
4. ❌ NEVER skip TDD → ✅ RED-GREEN-REFACTOR
5. ❌ NEVER merge without bin/ci → ✅ All quality gates pass
6. ❌ NEVER WebMock bypass → ✅ Mock all HTTP in tests

See rules/TEAM_RULES.md for all 20 rules.

## Getting Started

**Entry point:** @architect
- Analyzes requests
- Loads relevant rails-ai skills
- References superpowers workflows
- Delegates to specialized agents (@backend, @frontend, @tests, @security, @debug)
- Enforces TEAM_RULES.md
- Queries Context7 for current Rails/gem docs

**Example:**

```text

User: "Add email validation to User model"

@architect:
1. Determines this is backend work
2. References superpowers:test-driven-development for TDD process
3. Loads rails-ai:testing for Minitest patterns
4. Loads rails-ai:models for validation patterns
5. Delegates to @backend with context
6. @backend follows TDD: write test → RED → implement → GREEN → refactor
7. Reviews with superpowers:code-reviewer against TEAM_RULES.md

```

## Learn More

**Superpowers skills:** Use superpowers:using-superpowers for full introduction
**Rails-AI rules:** See rules/TEAM_RULES.md
**Context7 docs:** Architect queries automatically for current Rails/gem patterns
