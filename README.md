# rails-ai 🚂🤖

**Opinionated Rails-only AI agent system**

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

Think of it this way: an AI wrote a rulebook for other AIs, teaching them how to follow Rails conventions, when to refactor, and why custom route actions are almost always a bad idea. The teacher became the textbook. The architect became the blueprint.

**Side effects may include:**
- Agents that argue about whether your custom route action is *really* necessary
- Existential questions about whether RSpec is truly that bad (it is, according to Rule #2)
- Your CI pipeline becoming sentient and demanding PRs in draft mode
- An overwhelming urge to delete code and embrace simplicity

## What is rails-ai?

A **Claude Code plugin** providing 6 specialized AI agents for opinionated Ruby on Rails development. Agents work together following Rails conventions and 37signals-inspired best practices.

## Current Status

This project is **open source** and actively maintained. We welcome contributions!

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
/plugin marketplace add /home/zerobearing2/Projects/rails-ai
/plugin install rails-ai
```

Changes to agent files will be available after restarting Claude Code (hot-reload testing in progress).

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
- [Release Process](docs/releasing.md) - How to create releases
- [Agents System](AGENTS.md) - Agent roles and skill management

## Roadmap

### Current
- ✅ Skills-based architecture with testing framework
- ✅ Claude Code plugin support
- ✅ MIT License and open source
- 🔜 Expand skill coverage
- 🔜 Improve agent coordination
- 🔜 Add more real-world examples
- 🔜 Enhanced Cursor support

## Known Issues

### Claude Code v2.0.30 - Agent Launch Failures with MCP Servers

**Issue**: Task agents and subagents fail to launch when MCP servers are configured, returning:
```
API Error: 400 tools: Tool names must be unique
```

**Affected Versions**: Claude Code v2.0.30 (possibly v2.0.29)

**Impact**:
- All agents in rails-ai plugin cannot be invoked
- Built-in agents (Explore, Plan) also affected
- Occurs with any MCP server configuration (single or multiple)

**Root Cause**: A regression in v2.0.30 that duplicates tool names during subprocess initialization when making MCP tools available to sub-agents.

**Workarounds**:

1. **Downgrade to v2.0.28** (recommended):
   ```bash
   npm install -g @anthropic-ai/claude-code@2.0.28
   ```

2. **Temporarily disable MCP servers**: Comment out MCP configurations in `.claude.json` before using agents

3. **Use minimal MCP configuration**: Reduce to essential MCP servers only

**Status**: High priority issue tracked at [anthropics/claude-code#10668](https://github.com/anthropics/claude-code/issues/10668)

**Note**: This is a Claude Code platform issue, not specific to rails-ai. Once fixed upstream, rails-ai agents will work normally with MCP servers.

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Before contributing, please review:
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)
- Development setup instructions above

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

Inspired by 37signals' philosophy of simple, conventional Rails development.

## Support

- Report bugs or request features via [GitHub Issues](https://github.com/zerobearing2/rails-ai/issues)
- Check the [documentation](docs/) for guides and help
- Review [CONTRIBUTING.md](CONTRIBUTING.md) for development questions
