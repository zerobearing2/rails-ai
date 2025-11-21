---
name: using-rails-ai
description: Rails-AI introduction - explains how rails-ai (Rails domain layer) integrates with superpowers (universal workflows) for Rails development
---

# Using Rails-AI: Rails Domain Layer on Superpowers Workflows

<EXTREMELY-IMPORTANT>
## ⚠️ DEPENDENCY CHECK: Superpowers Required

**Rails-AI requires the Superpowers plugin to function.**

Before starting ANY work, verify Superpowers is installed by attempting to use a Superpowers skill. If you see an error like "skill not found" or "plugin not available":

**⚠️ WARNING: Superpowers plugin not installed!**

Rails-AI cannot function without Superpowers. Please install it:

```
/plugin marketplace add obra/superpowers
/plugin install superpowers
```

Then restart Claude Code.

**Why this matters:** Rails-AI provides WHAT to build (Rails domain knowledge). Superpowers provides HOW to build it (TDD, debugging, planning, code review). Without Superpowers, you cannot follow the mandatory workflows.

If Superpowers is installed, proceed normally.

## MANDATORY: Use Superpowers Foundation First

**Rails-AI builds on Superpowers. You MUST use the foundation before doing ANY work.**

**FIRST ACTION when starting any Rails work:**
1. Use `superpowers:using-superpowers` skill (Skill tool)
2. This establishes mandatory skill-usage protocol
3. Then use relevant rails-ai domain skills (see table below)

**Why use superpowers:using-superpowers?**
- Enforces checking for skills BEFORE any task
- Establishes discipline of using skills with Skill tool
- Prevents rationalizing away skill usage
- Provides proven workflow framework

**Without using superpowers:using-superpowers first:**
- You will skip using skills when you should
- You will rationalize that tasks are "too simple" for skills
- You will operate without the proven process framework

## Rails-AI Skill-to-Task Mapping

**Superpowers handles skill-usage enforcement. This table tells you WHICH Rails skills to use:**

| User Request Involves | Use These Skills |
|----------------------|-------------------|
| Models, databases, ActiveRecord | rails-ai:models |
| Controllers, routes, REST | rails-ai:controllers |
| Views, templates, forms | rails-ai:views |
| Hotwire, Turbo, Stimulus | rails-ai:hotwire |
| CSS, Tailwind, DaisyUI | rails-ai:styling |
| Tests, TDD, Minitest | rails-ai:testing |
| Security, XSS, SQL injection | rails-ai:security |
| Background jobs, caching | rails-ai:jobs |
| Email, ActionMailer | rails-ai:mailers |
| Project setup, validation, gems | rails-ai:project-setup |
| Environment config, Docker | rails-ai:project-setup |
| Debugging Rails issues | rails-ai:debugging |

**Each Rails-AI skill contains:**
- Required gems and dependencies
- TEAM_RULES.md enforcement for that domain
- Rails 8+ patterns and conventions
- Security requirements
- Code examples and anti-patterns

## Planning Rails Features

**CRITICAL: Load domain skills BEFORE brainstorming or planning.**

You can't give expert advice on Rails features if you haven't loaded the relevant domain knowledge. The brainstorming skill is process-agnostic — it doesn't know Rails patterns, TEAM_RULES, or which gems to use. You need to load that context first.

**Planning workflow:**
1. Load relevant rails-ai domain skills (see table below)
2. Read the codebase to understand what exists
3. THEN use `superpowers:brainstorming` to refine the idea
4. THEN use `superpowers:writing-plans` to create implementation plan

**Which skills to load for common features:**

| Feature Type | Load These Skills |
|--------------|-------------------|
| Authentication/Authorization | `rails-ai:security` + `rails-ai:models` + `rails-ai:controllers` |
| User-facing forms/pages | `rails-ai:views` + `rails-ai:hotwire` + `rails-ai:styling` |
| API endpoints | `rails-ai:controllers` + `rails-ai:security` |
| Background processing | `rails-ai:jobs` + `rails-ai:models` |
| Email features | `rails-ai:mailers` + `rails-ai:jobs` + `rails-ai:views` |
| Data modeling | `rails-ai:models` + `rails-ai:testing` |
| Interactive UI | `rails-ai:hotwire` + `rails-ai:views` + `rails-ai:controllers` |
| New project setup | `rails-ai:project-setup` |

**Always include `rails-ai:testing`** — TDD is non-negotiable (TEAM_RULES #4).

**Why this order matters:**
- Domain skills give you Rails patterns and constraints
- Reading code shows you what's already there
- Brainstorming with this context produces better designs
- Plans written with domain knowledge specify the right skills for workers

## Superpowers Reference

Superpowers provides universal workflows. Here's when to use each in Rails development:

### Planning & Design
| Skill | When to Use |
|-------|-------------|
| `superpowers:brainstorming` | Refining feature ideas before implementation |
| `superpowers:writing-plans` | Creating detailed implementation plans with tasks |
| `superpowers:executing-plans` | Running through a plan in controlled batches |

### Implementation
| Skill | When to Use |
|-------|-------------|
| `superpowers:test-driven-development` | Any feature or bugfix — write test first, watch fail, implement |
| `superpowers:subagent-driven-development` | Executing plans with fresh workers per task |
| `superpowers:dispatching-parallel-agents` | 3+ independent tasks that can run concurrently |
| `superpowers:using-git-worktrees` | Isolating feature work from main workspace |

### Quality & Review
| Skill | When to Use |
|-------|-------------|
| `superpowers:requesting-code-review` | Before merging — dispatches code-reviewer agent |
| `superpowers:receiving-code-review` | Processing review feedback with technical rigor |
| `superpowers:verification-before-completion` | Before claiming work is done — run tests, confirm output |
| `superpowers:finishing-a-development-branch` | Work complete, deciding merge/PR/cleanup |

### Debugging & Testing
| Skill | When to Use |
|-------|-------------|
| `superpowers:systematic-debugging` | Any bug or test failure — investigate before fixing |
| `superpowers:root-cause-tracing` | Tracing errors back through call stack |
| `superpowers:testing-anti-patterns` | Avoiding mocking mistakes, test pollution |
| `superpowers:condition-based-waiting` | Fixing flaky tests with race conditions |

### Defense & Security
| Skill | When to Use |
|-------|-------------|
| `superpowers:defense-in-depth` | Validation at multiple layers to prevent bugs |

### Agents
| Agent | When to Use |
|-------|-------------|
| `superpowers:code-reviewer` | Dispatched by requesting-code-review for PR review |

### Commands (Shortcuts)
| Command | What it Does |
|---------|--------------|
| `/superpowers:brainstorm` | Quick access to brainstorming skill |
| `/superpowers:write-plan` | Quick access to writing-plans skill |
| `/superpowers:execute-plan` | Quick access to executing-plans skill |

**Rails-specific usage:**
- Always load rails-ai domain skills BEFORE superpowers workflows
- `rails-ai:debugging` wraps `superpowers:systematic-debugging` with Rails context
- `rails-ai:testing` enforces TDD via `superpowers:test-driven-development`
</EXTREMELY-IMPORTANT>

## How Rails-AI Works

**Rails-AI is a two-layer system built on Superpowers:**

```text
┌─────────────────────────────────────────────┐
│ LAYER 1: Superpowers (Universal Process)   │
│ • brainstorming - Refine ideas              │
│ • writing-plans - Create plans              │
│ • test-driven-development - TDD cycle       │
│ • systematic-debugging - Investigation      │
│ • subagent-driven-development - Execution   │
│ • dispatching-parallel-agents - Coordination│
│ • requesting-code-review - Quality gates    │
│ • finishing-a-development-branch - Complete │
│ • receiving-code-review - Handle feedback   │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ LAYER 2: Rails-AI (Domain Expertise)       │
│ • 12 Rails domain skills                   │
│ • TEAM_RULES.md enforcement                 │
│ • Rails 8+ patterns and conventions         │
└─────────────────────────────────────────────┘
```

**Key Principle:**
- **Superpowers = HOW** to work (process framework)
- **Rails-AI = WHAT** you're building (domain knowledge)
- The architect loads both as needed

### Architecture Evolution

**Previous architecture (complex):**
- 5 agents (architect, developer, security, devops, uat)
- Ambiguous delegation chains
- Overlap between agent roles and workflows

**Current architecture (simple):**
- 1 slash command (/rails-ai:architect) - coordinator
- Superpowers workflows handle process (HOW)
- Rails-AI skills provide domain expertise (WHAT)
- General-purpose workers implement features
- Clean separation of concerns

### How It Works

**User request** → **/rails-ai:architect** → **Uses skills** → **Dispatches workers** → **Reviews**

#### Example: "Add user authentication"

1. **Coordinator uses superpowers:brainstorming**
   - Uses rails-ai:models + rails-ai:security for context
   - Refines design with user

2. **Coordinator uses superpowers:writing-plans**
   - Creates implementation plan
   - Specifies which skills workers should use per task

3. **Coordinator uses superpowers:subagent-driven-development**
   - Dispatches general-purpose workers for each task:
     • Worker 1: User model → uses rails-ai:models + rails-ai:testing
     • Worker 2: Sessions controller → uses rails-ai:controllers + rails-ai:testing
     • Worker 3: Login views → uses rails-ai:views + rails-ai:styling
   - Reviews each worker's output

4. **Coordinator uses superpowers:finishing-a-development-branch**
   - Verifies TEAM_RULES.md compliance
   - Creates PR or merges

**Result:** Clean feature with tests, following all conventions

## Available Rails-AI Skills

**12 Domain-Based Skills (Consolidated):**

1. **rails-ai:views** - Partials, helpers, forms, accessibility (WCAG 2.1 AA)
2. **rails-ai:hotwire** - Turbo Drive, Turbo Frames, Turbo Streams, Turbo Morph, Stimulus controllers
3. **rails-ai:styling** - Tailwind CSS utility-first framework, DaisyUI component library, theming
4. **rails-ai:controllers** - RESTful actions, nested resources, skinny controllers, concerns, strong parameters
5. **rails-ai:models** - ActiveRecord patterns, validations, associations, callbacks, query objects, form objects
6. **rails-ai:testing** - TDD with Minitest, fixtures, mocking, test helpers
7. **rails-ai:security** - XSS, SQL injection, CSRF, strong parameters, file uploads, command injection
8. **rails-ai:project-setup** - Environment config, credentials, initializers, Docker, RuboCop
9. **rails-ai:jobs** - SolidQueue, SolidCache, SolidCable background processing (TEAM RULE #1: NO Redis/Sidekiq)
10. **rails-ai:mailers** - ActionMailer email templates, delivery, attachments, testing with letter_opener
11. **rails-ai:debugging** - Rails debugging tools (logs, console, byebug) + superpowers:systematic-debugging
12. **rails-ai:using-rails-ai** - This guide - how rails-ai integrates with superpowers workflows

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

**Primary interface:** `/rails-ai:architect` command

The simplest way to use Rails-AI is the `/rails-ai:architect` convenience command:

```text
/rails-ai:architect add user authentication
/rails-ai:architect fix failing test in user_test.rb
/rails-ai:architect plan payment processing feature
/rails-ai:architect refactor UserController
```

This command acts as the Rails architect coordinator, which:
- Analyzes requests
- Uses superpowers workflows (for process)
- Uses rails-ai skills (for domain expertise)
- Dispatches general-purpose workers to implement features
- Reviews work and enforces TEAM_RULES.md

**Example:**

```text

User: "/rails-ai:architect Add email validation to User model"

Architect (coordinator):
1. Determines this is model work requiring TDD
2. Loads superpowers:test-driven-development for process
3. Loads rails-ai:testing for Minitest patterns
4. Loads rails-ai:models for validation patterns
5. Dispatches general-purpose worker with those skills loaded
6. Worker follows TDD cycle: write test → RED → implement → GREEN → refactor
7. Reviews worker output and verifies TEAM_RULES.md compliance

```


## Learn More

**Superpowers skills:** Use superpowers:using-superpowers for full introduction
**Rails-AI rules:** See rules/TEAM_RULES.md

<resources>

**Official Documentation:**
- [Rails-AI GitHub](https://github.com/zerobearing2/rails-ai) - Main repository
- [Superpowers GitHub](https://github.com/zerobearing2/superpowers) - Workflow dependency
- [Claude Code](https://code.claude.com/) - Platform documentation

**Internal References:**
- TEAM_RULES.md - Team coding standards and conventions
- All 12 domain skills in skills/ directory

</resources>
