# rails-ai 🚂🤖

**Opinionated Rails-only AI agent system**

> 🔒 **Private Repository**: This is a private repo during the agent tuning and testing phase. Will be open-sourced once battle-tested.

## 🎭 The Meta Moment

**100% written by AI, for AI**

Yes, you read that right. This entire agent system—the coordinator, the specialized agents, the 33 modular skills, the test framework, even this README—was architected, implemented, and refined by Claude. An AI building AI tools to help AI build better Rails apps.

*If this feels uncomfortably meta, that's because it is.*

```
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

An opinionated AI agent system specifically for Ruby on Rails development. Provides 8 specialized agents that work together following Rails conventions and 37signals-inspired best practices.

## Current Status: Agent Tuning Phase

This project is currently **private** and in active development. We're:
- 🔧 Tuning and refining the 8 specialized agents
- 🧪 Testing across real Rails projects
- 📝 Gathering examples and patterns
- 🎯 Improving decision matrices and rules

**Will open source** once the agents are refined and battle-tested.

## Features

- 🎯 **8 Specialized Agents**: Coordinator, Frontend, Backend, Tests, Config, Security, Design, Debug
- 🚂 **Rails-Only**: Focused exclusively on Ruby on Rails (no other frameworks)
- 🤖 **LLM Support**: Works with Claude Code and OpenAI/Cursor
- 🌍 **Global Install**: Symlinks to your home folder for use across all Rails projects
- 📚 **39+ Code Examples**: Rails-specific patterns and best practices
- 📋 **19 Team Rules**: Enforced conventions (Solid Stack, Minitest, REST-only, TDD)

## Installation (Local)

```bash
# Clone repo
cd ~/Projects/rails-ai

# Run installer (coming in Phase 3)
./install.sh
```

This will symlink the agents to `~/.claude/agents/` or `~/.cursor/agents/` so they're available in all your Rails projects.

## Usage

In any Rails project with Claude Code:

```
@rails - Add user authentication feature
```

The coordinator agent will create a plan, delegate to specialists, and deliver a complete implementation.

## Project Structure

```
rails-ai/
├── agents/          # 8 specialized Rails agents
├── skills/          # 33 modular skills (frontend, backend, testing, security, config)
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
- 🔜 Create global installer
- 🔜 Test across multiple Rails projects
- 🔜 Refine agents based on real usage
- 🔜 Improve examples and patterns
- 🔜 Document learnings

### Phase 2: Open Source Release (Future)
- Clean up and finalize agents
- Complete documentation
- Add MIT license
- Public release with announcement

## Credits

Inspired by 37signals' philosophy of simple, conventional Rails development.
