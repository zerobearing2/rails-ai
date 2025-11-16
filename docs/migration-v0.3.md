# Migration Guide: v0.2 to v0.3

## Overview

Rails-AI v0.3.0 represents a major architectural shift that transforms the system from a custom agent framework into a layered architecture built on Superpowers workflows. This guide will help you migrate from v0.2.x to v0.3.0.

## Breaking Changes

### 1. Agent Reorganization

**v0.2.x had 7 agents:**
- `@agent-rails-ai:architect` - Coordinator
- `@agent-rails-ai:backend` - Backend specialist
- `@agent-rails-ai:frontend` - Frontend specialist
- `@agent-rails-ai:tests` - Testing specialist
- `@agent-rails-ai:security` - Security specialist
- `@agent-rails-ai:debug` - Debugging specialist
- `@agent-rails-ai:plan` - Planning specialist

**v0.3.0 has 5 agents:**
- `@agent-rails-ai:architect` - Main coordinator (references superpowers workflows)
- `@agent-rails-ai:developer` - Full-stack Rails developer (combines backend, frontend, debug)
- `@agent-rails-ai:security` - Security specialist
- `@agent-rails-ai:devops` - Infrastructure and deployment specialist
- `@agent-rails-ai:uat` - Testing and quality assurance specialist

### 2. Removed Agents

**Removed: `@agent-rails-ai:plan`**
- Planning functionality now uses `superpowers:writing-plans`
- The architect agent references superpowers planning workflows

**Removed: `@agent-rails-ai:backend`, `@agent-rails-ai:frontend`, `@agent-rails-ai:debug`**
- Combined into single `@agent-rails-ai:developer` agent
- Modern Rails developers work full-stack, so this consolidation reflects reality

### 3. Skill Count Reduction

**v0.2.x: 41 skills**
- Included 4 ViewComponent skills (viewcomponent-basics, viewcomponent-slots, viewcomponent-previews, viewcomponent-variants)
- Included plan-related skills

**v0.3.0: 33 skills**
- Removed 4 ViewComponent skills (not using ViewComponent yet - deferred to future)
- Removed plan-related skills (separate project scope)
- Added 1 new skill: `using-rails-ai`
- Added 1 new skill: `debugging-rails`

### 4. Superpowers Dependency

**Required:** Rails-AI now requires Superpowers to be installed as a dependency.

Superpowers provides universal workflows that Rails-AI references:
- `superpowers:brainstorming` - Design phase workflow
- `superpowers:writing-plans` - Planning workflow
- `superpowers:test-driven-development` - TDD workflow
- `superpowers:systematic-debugging` - Debugging workflow
- `superpowers:requesting-code-review` - Code review workflow
- `superpowers:verification-before-completion` - Verification workflow
- `superpowers:executing-plans` - Batch execution workflow
- `superpowers:subagent-driven-development` - Fast execution workflow
- `superpowers:dispatching-parallel-agents` - Parallel coordination

### 5. Skill Namespacing

All skills are now namespaced as `rails-ai:skillname` for clarity and to avoid conflicts with other plugins.

## Migration Steps

### Step 1: Install Superpowers

Before upgrading to rails-ai v0.3.0, install Superpowers:

```bash
claude
```

Then in Claude Code:
```
/plugin marketplace add zerobearing2/superpowers
/plugin install superpowers
```

### Step 2: Upgrade Rails-AI

```bash
/plugin update rails-ai
```

Or reinstall:
```
/plugin uninstall rails-ai
/plugin marketplace add zerobearing2/rails-ai
/plugin install rails-ai
```

### Step 3: Restart Claude Code

**Important:** Restart Claude Code to activate the new architecture and load both plugins.

### Step 4: Update Your Workflows

**Before (v0.2.x):**
```
@agent-rails-ai:plan Create a plan for user authentication feature

@agent-rails-ai:backend Implement the User model
@agent-rails-ai:frontend Add login form
@agent-rails-ai:tests Write tests for authentication
@agent-rails-ai:debug Fix authentication bug
```

**After (v0.3.0):**
```text
@agent-rails-ai:architect Add user authentication feature

Architect will:
1. Use superpowers:brainstorming for design
2. Use superpowers:writing-plans for planning
3. Delegate to @developer for implementation
4. Use superpowers:test-driven-development for TDD
5. Use superpowers:systematic-debugging for debugging
6. Use superpowers:requesting-code-review for review
```

**Or directly invoke specialists:**
```
@agent-rails-ai:developer Implement user authentication with TDD
@agent-rails-ai:security Audit authentication implementation
@agent-rails-ai:uat Verify authentication works end-to-end
```

### Step 5: Update Custom Workflows (If Any)

If you have custom workflows that reference specific agents:

**Before:**
```text
# Custom workflow referencing old agents
1. @agent-rails-ai:backend - build API
2. @agent-rails-ai:frontend - build UI
3. @agent-rails-ai:tests - write tests
```

**After:**
```text
# Custom workflow with new agents
1. @agent-rails-ai:developer - build feature end-to-end with TDD
2. @agent-rails-ai:security - security audit
3. @agent-rails-ai:uat - acceptance testing
```

## What Stays the Same

### 1. Team Rules

All 20 team rules from TEAM_RULES.md remain enforced:
- Rule #1: Strict REST routing
- Rule #2: No custom controller actions
- Rule #3: TDD mandatory
- Rule #4: Concerns organization
- Rule #5: Form objects for complex forms
- Rule #6: Query objects for complex queries
- Rule #7: Service objects discouraged
- Rule #8: Strong parameters mandatory
- Rule #9: Turbo Frame usage patterns
- Rule #10: Hotwire-first approach
- Rule #11: No JavaScript frameworks (React, Vue, Angular)
- Rule #12: Tailwind utility-first CSS
- Rule #13: DaisyUI component usage
- Rule #14: Minitest required (no RSpec)
- Rule #15: Security pattern enforcement
- Rule #16: Credentials management
- Rule #17: Environment configuration
- Rule #18: Docker configuration
- Rule #19: Solid Stack setup
- Rule #20: Hash#dig preference

### 2. Context7 Integration

Context7 MCP server integration for up-to-date Rails documentation remains unchanged.

### 3. Custom RuboCop Cops

All custom RuboCop cops remain in place:
- `Style/NestedBracketAccess` - Enforces Hash#dig usage

### 4. Core Skills

Core Rails skills remain available (now namespaced):
- Backend skills (ActiveRecord, controllers, mailers, etc.)
- Frontend skills (Hotwire, Tailwind, DaisyUI, views, etc.)
- Testing skills (Minitest, TDD, fixtures, etc.)
- Security skills (SQL injection, XSS, CSRF, etc.)
- Config skills (Docker, credentials, Solid Stack, etc.)

## Troubleshooting

### Issue: "superpowers not found" error

**Solution:** Install Superpowers before using rails-ai v0.3.0:
```
/plugin marketplace add zerobearing2/superpowers
/plugin install superpowers
```

### Issue: Old agent names not working

**Solution:** Update to new agent names:
- `@agent-rails-ai:backend` → `@agent-rails-ai:developer`
- `@agent-rails-ai:frontend` → `@agent-rails-ai:developer`
- `@agent-rails-ai:debug` → `@agent-rails-ai:developer`
- `@agent-rails-ai:tests` → `@agent-rails-ai:uat`
- `@agent-rails-ai:plan` → Use `@agent-rails-ai:architect` (which references superpowers:writing-plans)

### Issue: ViewComponent skills missing

**Explanation:** ViewComponent skills were removed in v0.3.0 because the project isn't using ViewComponent yet. They'll be added back in a future release when needed.

**Workaround:** Reference ViewComponent documentation directly or use generic view patterns from `rails-ai:partials` and `rails-ai:view-helpers`.

### Issue: Context7 not connecting

**Solution:** Same as v0.2.x - verify your CONTEXT7_API_KEY environment variable:
```bash
echo $CONTEXT7_API_KEY
```

If not set, add to your shell profile and restart your terminal.

## Benefits of v0.3.0

### 1. Layered Architecture

Rails-AI now has a clear separation of concerns:
- **Rails-AI (Domain Layer):** Rails-specific knowledge, patterns, and conventions
- **Superpowers (Workflow Foundation):** Universal workflows that work across all projects

This means:
- Less duplication (workflows in one place)
- Better maintenance (fix workflow bugs once)
- Clearer responsibilities (Rails-AI focuses on Rails patterns)

### 2. Consolidated Agents

The new 5-agent structure better reflects modern Rails development:
- **architect:** High-level coordination and workflow orchestration
- **developer:** Full-stack implementation (most Rails devs work full-stack)
- **security:** Specialized security auditing
- **devops:** Infrastructure, deployment, CI/CD
- **uat:** End-to-end testing and quality assurance

### 3. Workflow Reuse

By leveraging Superpowers workflows, Rails-AI:
- Gets improvements to brainstorming, planning, TDD, debugging automatically
- Stays focused on Rails domain knowledge
- Integrates better with other domain-specific plugins

### 4. Skill Clarity

33 focused skills (down from 41) means:
- Less noise (removed unused ViewComponent skills)
- Clearer scope (Rails patterns only)
- Better organization (namespaced as `rails-ai:*`)

## Need Help?

- Check [docs/superpowers-integration.md](superpowers-integration.md) for details on how Rails-AI integrates with Superpowers
- Review [CHANGELOG.md](../CHANGELOG.md) for complete list of changes
- Report issues at [GitHub Issues](https://github.com/zerobearing2/rails-ai/issues)
- See [README.md](../README.md) for updated installation and usage instructions

## Version History

- **v0.2.x:** Custom agent system with 7 agents, 41 skills, centralized YAML registry
- **v0.3.0:** Layered architecture on Superpowers with 5 agents, 33 skills, automatic skill discovery
