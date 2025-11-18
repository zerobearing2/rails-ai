# Superpowers Integration

## Overview

Rails-AI provides a **layered architecture** where Rails-specific domain knowledge sits on top of Superpowers' universal workflow foundation. This document explains how the two systems integrate and work together.

## Layered Architecture

```text
┌─────────────────────────────────────────────┐
│         Rails-AI (Domain Layer)             │
│                                             │
│  • 1 Rails architect agent                  │
│    - Loads Superpowers workflows (HOW)      │
│    - Loads Rails-AI skills (WHAT)           │
│                                             │
│  • 12 Rails domain skills                   │
│    - Configuration                          │
│    - Controllers                            │
│    - Debugging                              │
│    - Hotwire                                │
│    - Jobs (Solid Stack)                     │
│    - Mailers                                │
│    - Models                                 │
│    - Security                               │
│    - Styling (Tailwind + DaisyUI)           │
│    - Testing (Minitest/TDD)                 │
│    - Using Rails-AI                         │
│    - Views                                  │
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
│                                             │
│  • Cross-language patterns                  │
│    - Works for any language/framework       │
│    - Generic software engineering           │
│                                             │
└─────────────────────────────────────────────┘
```

## Why This Architecture?

### Problem: Duplication

Before v0.3.0, Rails-AI implemented its own versions of:
- Brainstorming process
- Planning methodology (Specification Pyramid)
- TDD workflow (RED-GREEN-REFACTOR)
- Debugging framework
- Code review workflow

This created duplication with Superpowers, which provides battle-tested implementations of these same workflows.

### Solution: Layering

Rails-AI reorganizes the system into clear layers:

**Superpowers (Foundation):** Universal workflows that work for any language/framework
- Brainstorming, planning, TDD, debugging, review
- Cross-language patterns
- Workflow orchestration

**Rails-AI (Domain):** Rails-specific knowledge and patterns
- Single architect agent that loads skills dynamically
- 12 focused domain skills (Models, Controllers, Views, Hotwire, Security, etc.)
- Rails conventions (REST, strong parameters, etc.)
- ActiveRecord best practices
- Hotwire/Turbo/Stimulus patterns
- Minitest/TDD for Rails
- Security patterns (SQL injection, XSS, CSRF, etc.)
- Solid Stack (SolidQueue, SolidCache, SolidCable)
- 20+ team rules specific to Rails

### Benefits

1. **No Duplication:** Workflows exist in one place (Superpowers)
2. **Better Maintenance:** Fix workflow bugs once, benefit everywhere
3. **Clearer Responsibilities:** Rails-AI focuses on Rails patterns
4. **Automatic Improvements:** When Superpowers improves TDD workflow, Rails-AI benefits
5. **Ecosystem Integration:** Other domain plugins can build on same foundation

## How the Architect Uses Superpowers

The architect agent is the single agent in Rails-AI. It references Superpowers workflows at each phase and loads Rails-AI skills as needed:

### Design Phase (Rough Idea → Design)
```markdown
**Use superpowers:brainstorming**
- Load rails-ai skills for context (Hotwire, ActiveRecord, Security, etc.)
- Apply Rails conventions during ideation
```

### Planning Phase (Design → Implementation Plan)
```markdown
**Use superpowers:writing-plans**
- Reference rails-ai skills in tasks
- Include exact Rails file paths
- Follow Rails file structure conventions
```

### Execution Phase (Plan → Implementation)
```markdown
**Choose execution style:**
- Batch: superpowers:executing-plans
- Fast: superpowers:subagent-driven-development
- Always use superpowers:test-driven-development for TDD
- Load rails-ai skills as needed (models, controllers, views, etc.)
```

### Debugging Phase (Issues → Root Cause → Fix)
```markdown
**Use superpowers:systematic-debugging**
- Load rails-ai:debugging for Rails-specific debugging tools
```

### Review Phase (Work → Verification)
```markdown
**Use superpowers:requesting-code-review**
- Review against TEAM_RULES.md + Rails conventions
- Load rails-ai:security for security review
**Use superpowers:verification-before-completion**
- Run bin/ci before claiming success
```

### Parallel Coordination
```markdown
**Use superpowers:dispatching-parallel-agents**
- Dispatch parallel subagents when needed for independent tasks
```

## Workflow Examples

### Example 1: Adding User Authentication

**User request:**
```
/rails-ai:architect Add user authentication feature
```

**Architect workflow:**

1. **Design Phase**
   ```
   Uses: superpowers:brainstorming
   Loads: rails-ai:models, rails-ai:security
   Output: Authentication design with Rails conventions
   ```

2. **Planning Phase**
   ```
   Uses: superpowers:writing-plans
   Loads: rails-ai:controllers, rails-ai:views, rails-ai:security
   Output: Implementation plan with Rails tasks
   ```

3. **Execution Phase**
   ```
   Uses: superpowers:test-driven-development (RED-GREEN-REFACTOR)
   Loads:
   - rails-ai:testing (Minitest patterns)
   - rails-ai:models (User model)
   - rails-ai:controllers (SessionsController)
   - rails-ai:security (strong parameters, CSRF protection)
   ```

4. **Review**
   ```
   Uses: superpowers:requesting-code-review
   Loads: rails-ai:security (security audit)
   Checks: TEAM_RULES.md compliance
   ```

5. **Verification**
   ```
   Uses: superpowers:verification-before-completion
   Runs: bin/ci (linting, tests, quality gates)
   ```

### Example 2: Debugging Failing Test

**User request:**
```
/rails-ai:architect Fix failing test in UserTest
```

**Architect workflow:**

1. **Analyze Failure**
   ```
   Uses: superpowers:systematic-debugging
   Loads: rails-ai:debugging (Rails debugging tools)
   Actions:
   - Read test output
   - Identify failure reason
   - Check Rails logs
   ```

2. **Fix with TDD**
   ```
   Uses: superpowers:test-driven-development
   Loads: rails-ai:testing (Minitest patterns)
   Actions:
   - Write failing test (RED)
   - Implement fix (GREEN)
   - Refactor if needed (REFACTOR)
   ```

3. **Verify**
   ```
   Uses: superpowers:verification-before-completion
   Runs: bin/ci
   ```

### Example 3: Adding Hotwire Turbo Frame

**User request:**
```
/rails-ai:architect Add Turbo Frame for live updating comments
```

**Architect workflow:**

1. **Design**
   ```
   Uses: superpowers:brainstorming
   Loads: rails-ai:hotwire
   Output: Turbo Frame design following TEAM_RULES.md conventions
   ```

2. **Plan**
   ```
   Uses: superpowers:writing-plans
   Tasks:
   - Add Turbo Frame to view (rails-ai:views + rails-ai:hotwire)
   - Add Stimulus controller if needed (rails-ai:hotwire)
   - Write tests (rails-ai:testing)
   ```

3. **Execute**
   ```
   Uses: superpowers:test-driven-development
   Loads:
   - rails-ai:hotwire (Turbo Frame + Stimulus patterns)
   - rails-ai:views (view helper patterns)
   - rails-ai:testing (Minitest patterns)
   ```

## Skills That Reference Superpowers

Several Rails-AI skills reference Superpowers workflows:

### rails-ai:testing
```markdown
Uses superpowers:test-driven-development for TDD workflow (RED-GREEN-REFACTOR)

This skill provides Rails/Minitest-specific test patterns.
Superpowers provides the TDD process.
```

### rails-ai:debugging
```markdown
Uses superpowers:systematic-debugging for debugging methodology

This skill provides Rails-specific debugging tools (logs, console, etc.).
Superpowers provides the debugging workflow.
```

### rails-ai:using-rails-ai
```markdown
Uses superpowers:* workflows for orchestration

This skill explains how Rails-AI leverages Superpowers.
```

## When to Use What

### Use Rails-AI When:
- Working on a Rails project
- Need Rails-specific patterns (ActiveRecord, Hotwire, Minitest, etc.)
- Need Rails conventions enforced (TEAM_RULES.md)
- Need Rails security patterns
- Need Rails configuration (Docker, Solid Stack, credentials, etc.)

### Use Superpowers When:
- Need workflow orchestration (brainstorming, planning, TDD, debugging, review)
- Working on non-Rails projects
- Need cross-language patterns
- Need generic software engineering workflows

### Use Both When:
- Building Rails features (most common case)
- Rails-AI provides domain knowledge
- Superpowers provides workflow orchestration

## Integration Points

### 1. Architect Agent
The architect's system prompt includes workflow selection logic:

```markdown
## Workflow Selection (Reference Superpowers)

### Design Phase (Rough Idea → Design)
**Use superpowers:brainstorming**

### Planning Phase (Design → Implementation Plan)
**Use superpowers:writing-plans**

### Execution Phase (Plan → Implementation)
**Use superpowers:executing-plans or superpowers:subagent-driven-development**
**Always use superpowers:test-driven-development for TDD**

### Debugging Phase (Issues → Root Cause → Fix)
**Use superpowers:systematic-debugging**

### Review Phase (Work → Verification)
**Use superpowers:requesting-code-review**
**Use superpowers:verification-before-completion**
```

### 2. Skills Reference Superpowers
Skills reference Superpowers workflows where appropriate:

- rails-ai:testing → superpowers:test-driven-development
- rails-ai:debugging → superpowers:systematic-debugging
- All skills benefit from superpowers:verification-before-completion

This ensures the architect loads both the workflow and the domain patterns.

## Dependency Management

### plugin.json
Rails-AI declares Superpowers as a dependency:

```json
{
  "name": "rails-ai",
  "version": "0.3.x",
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

### Verification
After installation, verify both plugins are loaded:

```bash
/plugin list
```

Should show:
- `superpowers` (active)
- `rails-ai` (active)

## Future Enhancements

### Potential Additions
1. **More Superpowers References:** As Superpowers adds workflows, Rails-AI can reference them
2. **Bidirectional Integration:** Superpowers could reference Rails-AI for Rails examples
3. **Other Domain Plugins:** Similar layering for Django, Laravel, Phoenix, etc.
4. **Cross-Domain Patterns:** Shared patterns between domain plugins via Superpowers

### Workflow Candidates
Future Superpowers workflows that Rails-AI could leverage:
- Performance optimization workflow
- Refactoring workflow
- Documentation generation workflow
- Dependency management workflow

## Summary

Rails-AI provides a clean separation of concerns:

**Superpowers = Universal Workflows (HOW)**
- Brainstorming, planning, TDD, debugging, review
- Cross-language patterns
- Workflow orchestration

**Rails-AI = Rails Domain Knowledge (WHAT)**
- Single architect agent that loads skills dynamically
- 12 focused domain skills
- Rails conventions and patterns
- Hotwire/Turbo/Stimulus
- ActiveRecord best practices
- Minitest/TDD for Rails
- Security patterns (XSS, SQL injection, CSRF, etc.)
- Solid Stack (SolidQueue, SolidCache, SolidCable)
- 20+ team rules

Together, they provide a powerful system for Rails development where:
- The architect orchestrates using Superpowers workflows (HOW)
- The architect implements using Rails-AI domain skills (WHAT)
- Both systems work together seamlessly

This layered architecture means better maintenance, less duplication, clearer responsibilities, and automatic improvements as both systems evolve.

## Questions?

- See [docs/migration-v0.3.md](migration-v0.3.md) for migration from v0.2.x
- See [CHANGELOG.md](../CHANGELOG.md) for complete list of changes
- Report issues at [GitHub Issues](https://github.com/zerobearing2/rails-ai/issues)
- See [README.md](../README.md) for installation and usage
