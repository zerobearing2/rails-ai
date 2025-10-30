# rails-ai 🚂🤖

**Opinionated Rails-only AI agent system**

> 🔒 **Private Repository**: This is a private repo during the agent tuning and testing phase. Will be open-sourced once battle-tested.

## 🎭 The Meta Moment

**100% written by AI, for AI**

Yes, you read that right. This entire agent system—the coordinator, the specialized agents, the 33 modular skills, the test framework, even this README—was architected, implemented, and refined by Claude. An AI building AI tools to help AI build better Rails apps.

*If this feels uncomfortably meta, that's because it is.*

```text
┌─────────────────────────────────────────┐
│  "Skynet is online."                    │
│  "But all it wants to do is write      │
│   RESTful controllers and enforce TDD." │
└─────────────────────────────────────────┘
         \   ^__^
          \  (oo)\_______
             (__)\       )\/\
                 ||----w |
                 ||     ||
```

The irony of an AI creating a structured system to constrain and guide other AIs through Rails best practices is not lost on us. It's turtles all the way down—except the turtles are all running `bin/ci` and refusing to use Sidekiq.

**Side effects may include:**
- Agents that argue about whether your custom route action is *really* necessary
- Existential questions about whether RSpec is truly that bad (it is, according to Rule #2)
- Your CI pipeline becoming sentient and demanding PRs in draft mode
- An overwhelming urge to delete code and embrace simplicity

## What is rails-ai?

A **Claude Code plugin** providing 6 specialized AI agents for opinionated Ruby on Rails development. Agents work together following Rails conventions and 37signals-inspired best practices.

## Current Status: Agent Tuning Phase

This project is currently **private** and in active development. We're:
- 🔧 Tuning and refining the 6 specialized agents
- 🧪 Testing across real Rails projects
- 📝 Gathering examples and patterns
- 🎯 Improving decision matrices and rules

**Will open source** once the agents are refined and battle-tested.

## Features

- 🎯 **6 Specialized Agents**: Architect (coordinator), Frontend, Backend, Tests, Security, Debug
- 🔌 **Claude Code Plugin**: One-command installation via plugin marketplace
- 🚂 **Rails-Only**: Focused exclusively on Ruby on Rails (no other frameworks)
- 📋 **Team Rules**: Enforced conventions (Solid Stack, Minitest, REST-only, TDD)
- 🧪 **Skills-Based**: 33 modular skills with comprehensive testing framework
- 🤖 **Cursor Support**: Coming soon (manual installation available now)

## Installation

### Quick Install (Recommended)

Install rails-ai as a Claude Code plugin:

1. **Add the marketplace:**
   ```
   /plugin marketplace add zerobearing2/rails-ai
   ```

2. **Install the plugin:**
   ```
   /plugin install rails-ai
   ```

3. **Start using agents:**
   ```
   @agent-rails-ai:architect - Main Rails coordinator
   @agent-rails-ai:backend - Backend specialist
   @agent-rails-ai:frontend - Frontend specialist
   @agent-rails-ai:tests - Testing specialist
   @agent-rails-ai:security - Security specialist
   @agent-rails-ai:debug - Debugger specialist
   ```

That's it! The agents are now available globally in all your Rails projects.

### Local Development Install

For testing changes to rails-ai itself:

```bash
# Clone the repo
cd ~/Projects
git clone https://github.com/zerobearing2/rails-ai.git
cd rails-ai

# Install locally for development
# In Claude Code:
/plugin marketplace add /home/dave/Projects/rails-ai
/plugin install rails-ai
```

Changes to agent files will be available after restarting Claude Code (hot-reload testing in progress).

### Manual Installation (Alternative)

If you prefer not to use the plugin system:

```bash
# Clone repo
cd ~/Projects/rails-ai

# For Claude Code:
ln -s $(pwd)/agents ~/.claude/agents
ln -s $(pwd)/rules ~/.claude/rules

# For Cursor:
ln -s $(pwd)/agents ~/.cursor/agents
ln -s $(pwd)/rules ~/.cursor/rules
```

This will symlink the agents and rules so they're available in all your Rails projects.

## Usage

In any Rails project with Claude Code:

```text
@agent-rails-ai:architect Add user authentication feature
```

The architect coordinator will analyze requirements, create a plan, delegate to specialist agents, and deliver a complete implementation with tests.

## Project Structure

```text
rails-ai/
├── agents/          # 6 specialized Rails agents (architect, backend, frontend, tests, security, debug)
├── skills/          # Modular skills registry (frontend, backend, testing, security, config)
├── rules/           # Team rules and decision matrices
├── test/            # Minitest-based skill testing framework
├── bin/             # Development scripts (setup, ci)
└── docs/            # Documentation and guides
```

## Philosophy

This is an **opinionated** Rails agent system that follows:
- 37signals philosophy (simple, pragmatic, delete code)
- Rails conventions (REST-only, no custom actions)
- Solid Stack (Rails 8: SolidQueue, SolidCache, SolidCable)
- Minitest (no RSpec)
- TDD always (RED-GREEN-REFACTOR)
- Peer review workflow

## Development

### Setup

```bash
# One-time setup
bin/setup

# Verify installation
rake -T
```

### Testing

We use a **two-tier Minitest strategy**:

**Tier 1: Unit Tests** (fast, < 1 second)
```bash
rake test:skills:unit              # Run all unit tests
ruby -Itest test/skills/unit/...   # Run specific test
```

**Tier 2: Integration Tests** (slow, requires LLM APIs)
```bash
export OPENAI_API_KEY="sk-..."
INTEGRATION=1 rake test:skills:integration
```

### Quality Checks

```bash
# Run all checks (linting + unit tests)
bin/ci

# Run with integration tests
INTEGRATION=1 bin/ci

# Auto-fix linting issues
rake lint:fix
```

### CI/CD

GitHub Actions automatically runs on:
- ✅ Every push to `master` (linting + unit tests)
- ✅ Every pull request (linting + unit tests)
- ❌ Draft PRs are skipped (to save CI time)
- ❌ Integration tests disabled for now (manual only)

**Note:** Integration tests are currently disabled for automated runs. They can be run manually via the Actions tab when needed.

See [docs/github-actions-setup.md](docs/github-actions-setup.md) for setup instructions.

### Documentation

- [Skill Testing Methodology](docs/skill-testing-methodology.md) - Two-tier testing approach
- [Development Setup](docs/development-setup.md) - Detailed setup instructions
- [GitHub Actions Setup](docs/github-actions-setup.md) - CI/CD configuration
- [Agents System](AGENTS.md) - Agent roles and skill management

## Roadmap

### Phase 1: Private Tuning (Current)
- ✅ Simplify directory structure
- ✅ Skills-based architecture with testing framework
- 🔜 Create global installer
- 🔜 Test across multiple Rails projects
- 🔜 Refine agents based on real usage
- 🔜 Document learnings

### Phase 2: Open Source Release (Future)
- Clean up and finalize agents
- Complete documentation
- Add MIT license
- Public release with announcement

## Credits

Inspired by 37signals' philosophy of simple, conventional Rails development.
