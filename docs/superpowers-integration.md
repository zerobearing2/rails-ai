# Superpowers Integration

## Overview

Rails-AI v0.3.0 introduces a **layered architecture** where Rails-AI provides Rails-specific domain knowledge on top of Superpowers' universal workflow foundation. This document explains how the two systems integrate and work together.

## Layered Architecture

```text
┌─────────────────────────────────────────────┐
│         Rails-AI (Domain Layer)             │
│                                             │
│  • 5 Rails-specialized agents               │
│    - architect (coordinator)                │
│    - developer (full-stack)                 │
│    - security (auditing)                    │
│    - devops (infrastructure)                │
│    - uat (testing)                          │
│                                             │
│  • 33 Rails domain skills                   │
│    - ActiveRecord patterns                  │
│    - Hotwire/Turbo/Stimulus                 │
│    - Minitest/TDD                           │
│    - Security patterns                      │
│    - Docker/Solid Stack                     │
│                                             │
│  • Team rules & RuboCop cops                │
│    - 20 Rails conventions                   │
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

v0.3.0 reorganizes the system into clear layers:

**Superpowers (Foundation):** Universal workflows that work for any language/framework
- Brainstorming, planning, TDD, debugging, review
- Cross-language patterns
- Workflow orchestration

**Rails-AI (Domain):** Rails-specific knowledge and patterns
- Rails conventions (REST, strong parameters, etc.)
- Hotwire/Turbo/Stimulus patterns
- ActiveRecord best practices
- Minitest/TDD for Rails
- Security patterns (SQL injection, XSS, CSRF, etc.)
- Solid Stack configuration
- 20 team rules specific to Rails

### Benefits

1. **No Duplication:** Workflows exist in one place (Superpowers)
2. **Better Maintenance:** Fix workflow bugs once, benefit everywhere
3. **Clearer Responsibilities:** Rails-AI focuses on Rails patterns
4. **Automatic Improvements:** When Superpowers improves TDD workflow, Rails-AI benefits
5. **Ecosystem Integration:** Other domain plugins can build on same foundation

## How Agents Reference Superpowers

### Architect Agent

The architect agent is the primary orchestrator. It references Superpowers workflows at each phase:

#### Design Phase (Rough Idea → Design)
```markdown
**Use superpowers:brainstorming**
- Load rails-ai skills for context (Hotwire, ActiveRecord, etc.)
- Apply Rails conventions during ideation
```

#### Planning Phase (Design → Implementation Plan)
```markdown
**Use superpowers:writing-plans**
- Reference rails-ai skills in tasks
- Include exact Rails file paths
- Follow Rails file structure conventions
```

#### Execution Phase (Plan → Implementation)
```markdown
**Choose execution style:**
- Batch: superpowers:executing-plans
- Fast: superpowers:subagent-driven-development
- Delegate to @developer, @security, @devops, @uat with rails-ai skills
```

#### Debugging Phase (Issues → Root Cause → Fix)
```markdown
**Use superpowers:systematic-debugging**
- Load rails-ai:debugging-rails for Rails-specific tools
- Delegate to @developer for Rails debugging
```

#### Review Phase (Work → Verification)
```markdown
**Use superpowers:requesting-code-review**
- Review against TEAM_RULES.md + Rails conventions
**Use superpowers:verification-before-completion**
- Run bin/ci before claiming success
```

#### Parallel Coordination
```markdown
**Use superpowers:dispatching-parallel-agents**
- Coordinate @developer, @security, @devops, @uat in parallel
```

### Developer Agent

The developer agent implements features using Superpowers TDD workflow:

```markdown
**TDD Mandatory:**
**Use superpowers:test-driven-development for process**
**Use rails-ai:tdd-minitest for Rails/Minitest patterns**

Process:
1. superpowers:test-driven-development provides RED-GREEN-REFACTOR workflow
2. rails-ai:tdd-minitest provides Rails-specific test patterns
3. Developer combines both for Rails TDD implementation
```

### Security Agent

The security agent audits code using Superpowers review workflow:

```markdown
**Use superpowers:requesting-code-review**
- Apply Rails security rules from TEAM_RULES.md
- Check against rails-ai security skills
- Verify strong parameters, CSRF protection, etc.
```

### DevOps Agent

The devops agent configures infrastructure with verification:

```markdown
**Use superpowers:verification-before-completion**
- Verify Docker configurations
- Test Solid Stack setup
- Run bin/ci for quality gates
```

### UAT Agent

The uat agent performs testing with systematic approach:

```markdown
**Use superpowers:systematic-debugging for test failures**
**Use rails-ai:tdd-minitest for test patterns**
- Run test suites
- Debug failures using superpowers workflow
- Apply Rails testing patterns
```

## Workflow Examples

### Example 1: Adding User Authentication

**User request:**
```
@agent-rails-ai:architect Add user authentication feature
```

**Architect workflow:**

1. **Design Phase**
   ```
   Uses: superpowers:brainstorming
   Context: rails-ai skills (activerecord-patterns, security-*, forms-nested)
   Output: Authentication design with Rails conventions
   ```

2. **Planning Phase**
   ```
   Uses: superpowers:writing-plans
   Context: Rails file structure (app/models, app/controllers, etc.)
   Context: rails-ai:controller-restful, rails-ai:security-strong-params
   Output: Specification Pyramid plan with Rails tasks
   ```

3. **Execution Phase**
   ```
   Delegates to: @agent-rails-ai:developer

   Developer uses:
   - superpowers:test-driven-development (RED-GREEN-REFACTOR)
   - rails-ai:tdd-minitest (Rails test patterns)
   - rails-ai:activerecord-patterns (User model)
   - rails-ai:controller-restful (SessionsController)
   - rails-ai:security-strong-params (parameter filtering)
   - rails-ai:security-csrf (CSRF protection)
   ```

4. **Security Review**
   ```
   Delegates to: @agent-rails-ai:security

   Security uses:
   - superpowers:requesting-code-review (review workflow)
   - rails-ai:security-* skills (all security patterns)
   - TEAM_RULES.md (Rule #8: Strong parameters, Rule #15: Security patterns)
   ```

5. **Verification**
   ```
   Uses: superpowers:verification-before-completion
   Runs: bin/ci (linting, tests, quality gates)
   Checks: All tests pass, no security issues
   ```

### Example 2: Debugging Failing Test

**User request:**
```
@agent-rails-ai:developer Fix failing test in UserTest
```

**Developer workflow:**

1. **Analyze Failure**
   ```
   Uses: superpowers:systematic-debugging
   Context: rails-ai:debugging-rails (Rails debugging tools)
   Actions:
   - Read test output
   - Identify failure reason
   - Check Rails logs
   ```

2. **Fix with TDD**
   ```
   Uses: superpowers:test-driven-development
   Context: rails-ai:tdd-minitest
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
@agent-rails-ai:architect Add Turbo Frame for live updating comments
```

**Architect workflow:**

1. **Design**
   ```
   Uses: superpowers:brainstorming
   Context: rails-ai:hotwire-turbo, rails-ai:hotwire-stimulus
   Output: Turbo Frame design following TEAM_RULES.md Rule #9
   ```

2. **Plan**
   ```
   Uses: superpowers:writing-plans
   Tasks:
   - Add Turbo Frame to view (rails-ai:hotwire-turbo)
   - Add Stimulus controller if needed (rails-ai:hotwire-stimulus)
   - Write tests (rails-ai:tdd-minitest)
   ```

3. **Execute**
   ```
   Delegates to: @developer

   Developer uses:
   - superpowers:test-driven-development
   - rails-ai:hotwire-turbo (Turbo Frame patterns)
   - rails-ai:hotwire-stimulus (Stimulus controller patterns)
   - rails-ai:view-helpers (view helper patterns)
   ```

## Skills That Reference Superpowers

Several Rails-AI skills include "REQUIRED BACKGROUND" sections that reference Superpowers skills:

### rails-ai:tdd-minitest
```markdown
## REQUIRED BACKGROUND
Load superpowers:test-driven-development for TDD workflow (RED-GREEN-REFACTOR)

This skill provides Rails/Minitest-specific patterns.
Superpowers provides the TDD process.
```

### rails-ai:debugging-rails
```markdown
## REQUIRED BACKGROUND
Load superpowers:systematic-debugging for debugging methodology

This skill provides Rails-specific debugging tools.
Superpowers provides the debugging workflow.
```

### rails-ai:using-rails-ai
```markdown
## REQUIRED BACKGROUND
Load superpowers:* workflows for orchestration

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

### 1. Architect Agent System Prompt
The architect's system prompt includes workflow selection logic:

```markdown
## Workflow Selection (Reference Superpowers)

### Design Phase (Rough Idea → Design)
**Use superpowers:brainstorming**

### Planning Phase (Design → Implementation Plan)
**Use superpowers:writing-plans**

### Execution Phase (Plan → Implementation)
**Use superpowers:executing-plans or superpowers:subagent-driven-development**

### Debugging Phase (Issues → Root Cause → Fix)
**Use superpowers:systematic-debugging**

### Review Phase (Work → Verification)
**Use superpowers:requesting-code-review**
**Use superpowers:verification-before-completion**
```

### 2. Developer Agent System Prompt
The developer's system prompt enforces TDD via Superpowers:

```markdown
**TDD Mandatory:**
**Use superpowers:test-driven-development for process**
**Use rails-ai:tdd-minitest for Rails/Minitest patterns**
```

### 3. Skills REQUIRED BACKGROUND Sections
Skills that depend on Superpowers workflows include explicit background requirements:

```markdown
## REQUIRED BACKGROUND
Load superpowers:test-driven-development for TDD workflow
```

This ensures Claude loads both the workflow and the domain patterns.

## Dependency Management

### plugin.json
Rails-AI declares Superpowers as a dependency:

```json
{
  "name": "rails-ai",
  "version": "0.3.0",
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

Rails-AI v0.3.0 introduces a clean separation of concerns:

**Superpowers = Universal Workflows**
- Brainstorming, planning, TDD, debugging, review
- Cross-language patterns
- Workflow orchestration

**Rails-AI = Rails Domain Knowledge**
- Rails conventions and patterns
- Hotwire/Turbo/Stimulus
- ActiveRecord best practices
- Minitest/TDD for Rails
- Security patterns
- Configuration (Docker, Solid Stack)
- 20 team rules

Together, they provide a powerful system for Rails development where:
- Architects orchestrate using Superpowers workflows
- Developers implement using Rails-AI domain skills
- Both systems work together seamlessly

This layered architecture means better maintenance, less duplication, clearer responsibilities, and automatic improvements as both systems evolve.

## Questions?

- See [docs/migration-v0.3.md](migration-v0.3.md) for migration from v0.2.x
- See [CHANGELOG.md](../CHANGELOG.md) for complete list of changes
- Report issues at [GitHub Issues](https://github.com/zerobearing2/rails-ai/issues)
- See [README.md](../README.md) for installation and usage
