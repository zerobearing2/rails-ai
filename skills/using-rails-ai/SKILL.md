---
name: using-rails-ai
description: Rails-AI introduction - explains how rails-ai (Rails domain layer) integrates with superpowers (universal workflows) for Rails development
---

# Using Rails-AI: Rails Domain Layer on Superpowers Workflows

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
- 1 agent (architect)
- Superpowers workflows handle coordination
- Rails-AI skills provide domain expertise
- Clean separation of concerns

### How It Works

**User request** → **/rails-ai:architect** → **Loads workflows + skills** → **Executes work**

#### Example: "Add user authentication"

1. **Architect loads superpowers:brainstorming**
   - Loads rails-ai:models + rails-ai:security for context
   - Refines design with user

2. **Architect loads superpowers:writing-plans**
   - Creates implementation plan
   - Specifies which skills to use per task

3. **Architect loads superpowers:subagent-driven-development**
   - Dispatches subagents for each task:
     • Subagent 1: User model → loads rails-ai:models + rails-ai:testing
     • Subagent 2: Sessions controller → loads rails-ai:controllers + rails-ai:testing
     • Subagent 3: Login views → loads rails-ai:views + rails-ai:styling
   - Reviews each subagent's work

4. **Architect loads superpowers:finishing-a-development-branch**
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

This command invokes the Rails architect agent, which:
- Analyzes requests
- Loads superpowers workflows (for process)
- Loads rails-ai skills (for domain expertise)
- Executes work directly or via subagent-driven-development
- Enforces TEAM_RULES.md

**Example:**

```text

User: "/rails-ai:architect Add email validation to User model"

Architect:
1. Determines this is model work requiring TDD
2. Loads superpowers:test-driven-development for process
3. Loads rails-ai:testing for Minitest patterns
4. Loads rails-ai:models for validation patterns
5. Follows TDD cycle: write test → RED → implement → GREEN → refactor
6. Verifies TEAM_RULES.md compliance

```

**Alternative:** You can also invoke the architect directly with `@agent-rails-ai:architect <request>`

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
