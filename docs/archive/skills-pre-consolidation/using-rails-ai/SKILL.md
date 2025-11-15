---
name: using-rails-ai
description: Rails-AI introduction - explains how rails-ai (Rails domain layer) integrates with superpowers (universal workflows) for Rails development
---

# Using Rails-AI: Rails Domain Layer on Superpowers Workflows

## What is Rails-AI?

Rails-AI provides **Rails-specific domain knowledge** that integrates with **Superpowers universal workflows**.

**Two-Layer Architecture:**

```
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
   - Load rails-ai:solid-stack, rails-ai:activerecord-patterns for context
   - Query Context7 for current Rails auth patterns
   - Document to docs/plans/YYYY-MM-DD-auth-design.md

2. **Planning Phase:**
   - Use superpowers:writing-plans (bite-sized TDD tasks)
   - Reference rails-ai:tdd-minitest, rails-ai:activerecord-patterns in tasks
   - Include exact Rails paths (app/models/user.rb, test/models/user_test.rb)
   - Save to docs/plans/YYYY-MM-DD-auth-plan.md

3. **Execution Phase:**
   - Use superpowers:subagent-driven-development (fast iteration + review)
   - Delegate to @backend with rails-ai skills
   - Each task: RED-GREEN-REFACTOR (superpowers:TDD process + rails-ai:tdd-minitest patterns)
   - Review with superpowers:code-reviewer against TEAM_RULES.md

4. **Verification:**
   - Use superpowers:verification-before-completion
   - Run bin/ci (all quality gates)
   - Confirm evidence before success claim

## Available Rails-AI Skills

**Frontend (9 skills - ViewComponent removed):**
- rails-ai:hotwire-turbo, rails-ai:turbo-morph, rails-ai:hotwire-stimulus
- rails-ai:tailwind, rails-ai:daisyui
- rails-ai:view-helpers, rails-ai:forms-nested
- rails-ai:accessibility, rails-ai:partials

**Backend (10 skills):**
- rails-ai:controller-restful, rails-ai:activerecord-patterns
- rails-ai:form-objects, rails-ai:query-objects
- rails-ai:concerns-models, rails-ai:concerns-controllers
- rails-ai:custom-validators, rails-ai:action-mailer
- rails-ai:nested-resources, rails-ai:antipattern-fat-controllers

**Testing (5 skills):**
- rails-ai:tdd-minitest (+ superpowers:test-driven-development)
- rails-ai:fixtures, rails-ai:minitest-mocking
- rails-ai:test-helpers, rails-ai:model-testing

**Security (6 skills):**
- rails-ai:security-xss, rails-ai:security-sql-injection, rails-ai:security-csrf
- rails-ai:security-strong-params, rails-ai:security-file-uploads, rails-ai:security-command-injection

**Config (6 skills):**
- rails-ai:solid-stack, rails-ai:docker, rails-ai:rubocop
- rails-ai:initializers, rails-ai:credentials, rails-ai:environment-config

**Debugging (1 skill):**
- rails-ai:debugging-rails (+ superpowers:systematic-debugging)

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
```
User: "Add email validation to User model"

@architect:
1. Determines this is backend work
2. References superpowers:test-driven-development for TDD process
3. Loads rails-ai:tdd-minitest for Rails/Minitest patterns
4. Loads rails-ai:activerecord-patterns for validation patterns
5. Delegates to @backend with context
6. @backend follows TDD: write test → RED → implement → GREEN → refactor
7. Reviews with superpowers:code-reviewer against TEAM_RULES.md
```

## Learn More

**Superpowers skills:** Use superpowers:using-superpowers for full introduction
**Rails-AI rules:** See rules/TEAM_RULES.md
**Context7 docs:** Architect queries automatically for current Rails/gem patterns
