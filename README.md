# rails-ai 🚂🤖

## The Vision

Build Rails apps so autonomously they leave today's Next.js and React generators in the dust. We're not playing catch-up—we're setting the pace and showing what LLM-driven development really looks like when Rails is in the driver's seat. This project exists to prove that Rails has always been the right tool for this moment, and we're here to back that up.

## The Problem

Right now, LLMs excel at Next.js and Node code. Ask them to build a Rails app and you get... okay results. Ask for a Next.js app and you get production-ready code.

**Why?** Training data. JavaScript/TypeScript dominates the training sets. Rails, despite being more mature and productive, is underrepresented.

**The irony?** Rails is actually better suited for AI code generation:

- **Convention over Configuration** — Less decision-making, more consistent patterns
- **Strong opinions** — Clear right/wrong answers
- **Battle-tested** — 20+ years of best practices
- **Monolithic by default** — Simpler mental model
- **Solid Stack** — Rails 8's batteries-included approach

Rails was built to make developers productive by removing decisions. That same philosophy makes it perfect for LLMs — fewer choices, more consistency, clearer patterns.

## The Path Forward

We're not just building another code assistant. We're systematically solving LLM accuracy for Rails through a phased approach:

**Phase 1: Specialized Agents** ✅
Seven agents built on current LLMs, each mastering a domain (backend, frontend, tests, security). Working together, they're already better than general-purpose LLMs at Rails.

**Phase 2: Structured Intelligence** ✅ (In Progress)
Skills teaching LLMs specific Rails patterns. Team rules enforcing conventions. Custom RuboCop cops catching mistakes. We're encoding Rails wisdom into reusable, testable modules.

**Phase 3: Memory & Context**
Index thousands of high-quality Rails codebases. When generating code, retrieve relevant examples in real-time. Learn from production Rails apps at scale using RAG and vector search.

**Phase 4: The Goal**
100% autonomous generation. Full-stack features with auth, payments, admin, APIs, background jobs. Production-ready code with tests and security. First-try pass rates of 85%+.

We're building the tooling to make Rails the best framework for AI-assisted development.

## Where We Are Now

**Phase 1 Complete:** Seven specialized agents working in concert. The architect coordinates, specialist agents handle their domains. Already better than using Claude or GPT-4 alone for Rails work.

**Phase 2 In Progress:** 40+ modular skills teaching specific Rails patterns. Team rules enforcing conventions. Everything tested and validated. We're expanding skills coverage and building custom RuboCop cops.

**What works today:**
- @agent-rails-ai:architect orchestrates feature development
- Specialized agents for backend, frontend, tests, security, debugging
- Context7 integration for up-to-date Rails documentation
- Specification Pyramid planning framework
- Skills-based knowledge that's testable and reusable

**What's coming:**
- RAG with SQLite vector search (Phase 3)
- Index of thousands of production Rails patterns
- 30-50% accuracy improvement from contextual examples
- Eventually: 85%+ first-try pass rate, 100% autonomous features

## Join Us

This is bigger than a plugin. We're proving Rails can lead in the AI era.

**If you're a Rails developer:** Try the agents. Break them. Tell us what's missing. Your real-world usage drives what we build.

**If you're into AI/ML:** We need help with Phase 3 (RAG) and Phase 4 (fine-tuning). Indexing Rails codebases, building evaluation frameworks, improving retrieval quality.

**If you care about Rails:** Star the repo. Spread the word. Rails deserves world-class AI tooling. Help us build it.

The goal isn't just good — it's to make Rails the obvious choice for AI-assisted development. Help us get there.

→ [Get started](#installation)
→ [Contribute](TESTING.md)
→ [Report issues](https://github.com/zerobearing2/rails-ai/issues)

---

## Installation

### Quick Install (Recommended)

Install rails-ai as a Claude Code plugin:

1. **Get a Context7 API key:**

   The rails-ai agents use the Context7 MCP server to fetch up-to-date Rails documentation.

   - Sign up at [context7.com](https://context7.com) to get your free API key
   - Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):
     ```bash
     export CONTEXT7_API_KEY="your-api-key-here"
     ```
   - Restart your terminal or run `source ~/.bashrc` (or `~/.zshrc`)

2. **Install the plugin:**

   Open a Claude Code session in your terminal:
   ```bash
   claude
   ```

   Then run these commands in the Claude Code session:
   ```
   /plugin marketplace add zerobearing2/rails-ai
   /plugin install rails-ai
   ```

   **Restart Claude Code** to activate the Context7 MCP server integration.

3. **Verify the setup:**

   After restarting Claude Code, verify Context7 is connected:
   ```
   /mcp
   ```

   You should see `plugin:rails-ai:context7` listed as connected. If it shows as failed, check that:
   - Your `CONTEXT7_API_KEY` environment variable is set correctly
   - You've restarted your terminal after setting the environment variable
   - Claude Code can access the environment variable

4. **Start using agents:**

   In any Claude Code session, you can now invoke the agents:
   ```
   @agent-rails-ai:architect - Main Rails coordinator
   @agent-rails-ai:plan - Specification Pyramid planning specialist
   @agent-rails-ai:backend - Backend specialist
   @agent-rails-ai:frontend - Frontend specialist
   @agent-rails-ai:tests - Testing specialist
   @agent-rails-ai:security - Security specialist
   @agent-rails-ai:debug - Debugger specialist
   ```

That's it! The agents are now available globally in all your Rails projects with access to up-to-date Rails documentation via Context7.

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
├── agents/          # 7 specialized Rails agents (architect, plan, backend, frontend, tests, security, debug)
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

1. **Downgrade to v2.0.28 or v2.0.29 and disable auto-update** (recommended):
   ```bash
   # Downgrade to working version
   npm install -g @anthropic-ai/claude-code@2.0.29

   # Prevent auto-update to v2.0.30
   echo 'export DISABLE_AUTOUPDATER=1' >> ~/.bashrc
   export DISABLE_AUTOUPDATER=1
   ```

   This keeps Claude Code on the working version and prevents it from auto-updating back to v2.0.30.

2. **Temporarily disable MCP servers**: Comment out MCP configurations in `.claude.json` before using agents

3. **Use minimal MCP configuration**: Reduce to essential MCP servers only

**Status**: High priority issue tracked at [anthropics/claude-code#10668](https://github.com/anthropics/claude-code/issues/10668)

**Note**: This is a Claude Code platform issue, not specific to rails-ai. Once fixed upstream, rails-ai agents will work normally with MCP servers.

---

## Contributing

We welcome contributions!

- See [TESTING.md](TESTING.md) for development setup and testing guide
- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

Please also review:
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)

## License

MIT License - see [LICENSE](LICENSE) for details.

## The Meta Moment

Yes, this entire system—the coordinator, the specialized agents, the 40 modular skills, the test framework, even this README—was architected and refined by Claude. An AI building AI tools to help AI build better Rails apps.

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

An AI wrote a rulebook for other AIs, teaching them Rails conventions, when to refactor, and why custom route actions are almost always wrong. The teacher became the textbook.

## Credits

### Specification Pyramid Concept

The planning agent's systematic documentation approach (Vision → Architecture → Features → Tasks) is inspired by the **Specification Pyramid** concept from [Robert Evans](https://www.linkedin.com/in/rrevans/), a highly accomplished Rubyist, friend, colleague, and expert in the field.

Read more about the Specification Pyramid in his article: [Why Your PRD Isn't Working for AI](https://signalthinking.com/p/why-your-prd-isnt-working-for-ai-083)

### Philosophy

Inspired by 37signals' philosophy of simple, conventional Rails development.

## Support

- Report bugs or request features via [GitHub Issues](https://github.com/zerobearing2/rails-ai/issues)
- Check the [documentation](docs/) for guides and help
- See [TESTING.md](TESTING.md) for development and testing questions
