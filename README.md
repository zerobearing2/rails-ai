# rails-ai 🚂🤖

## The Vision

Build Rails apps so autonomously they leave today's Next.js and React generators in the dust. We're not playing catch-up—we're setting the pace and showing what LLM-driven development really looks like when Rails is in the driver's seat. This project exists to prove that Rails has always been the right tool for this moment, and we're here to back that up.

That ambition only matters if we're honest about where Rails stands with LLMs today.

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

## Roadmap

We're turning that gap into a roadmap instead of a wish list.

**Phase 1 — Specialized Agents** ✅ Completed  
Seven domain experts (architect, backend, frontend, tests, security, debug, plan) already outperform generic LLM sessions by coordinating like a real team.

**Phase 2 — Structured Intelligence** 🛠️ In progress  
Forty-one modular skills, shared team rules, and custom cops bake Rails judgment into reusable modules. Every agent pulls from the same tested playbook.

**Phase 3 — Memory & Context** 🔬 In design  
Index thousands of production Rails patterns, wire them into a local memory + knowledge graph, and retrieve the right snippet at the right time with RAG + SQLite vector search so every response is grounded in real context.

**Phase 4 — Fully Autonomous Rails** 🚀 Goal  
Ship end-to-end features—auth, payments, background jobs, admin, APIs—complete with tests and security, and hit an 85%+ first-pass success rate.

**What already works**
- @agent-rails-ai:architect orchestrates real features end to end
- Specialists cover backend, frontend, tests, security, and debugging
- Context7 keeps every agent current with live Rails documentation
- Specification Pyramid planning keeps scope and delivery aligned
- A 41-skill registry gives repeatable, testable Rails knowledge

**What we're building next**
- Phase 3 RAG pipeline with SQLite vector search
- A library of thousands of indexed production Rails patterns
- 30–50% accuracy gains from better retrieval signals
- A straight path to 85%+ first-try pass rates and autonomous delivery

## Join Us

This is bigger than a plugin. We're proving Rails can lead in the AI era.

**If you're a Rails developer:** Try the agents. Break them. Tell us what's missing. Your real-world usage drives what we build.

**If you're into AI/ML:** We need help with Phase 3 (RAG) and Phase 4 (fine-tuning). Indexing Rails codebases, building evaluation frameworks, improving retrieval quality.

**If you care about Rails:** Star the repo. Spread the word. Rails deserves world-class AI tooling. Help us build it.

The goal isn't just good — it's to make Rails the obvious choice for AI-assisted development. Help us get there.

→ [Get started](#installation)
→ [Contribute](CONTRIBUTING.md)
→ [Testing guide](TESTING.md)
→ [Report issues](https://github.com/zerobearing2/rails-ai/issues)

---

## Installation

Get the agents running in a few minutes—no yak shaving required.

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

Every agent ships with the same north star, so the code they write feels like the Rails we ship by hand. This is an **opinionated** system that follows:
- 37signals philosophy (simple, pragmatic, delete code)
- Rails conventions (REST-only, no custom actions)
- Solid Stack (Rails 8: SolidQueue, SolidCache, SolidCable)
- Minitest (no RSpec)
- TDD always (RED-GREEN-REFACTOR)
- Peer review workflow

## Known Issues

### Claude Code v2.0.30 MCP regression

- **Symptom:** Task agents (rails-ai or built-in) fail to launch when any MCP server is configured, showing `API Error: 400 tools: Tool names must be unique`.
- **Why it happens:** v2.0.30 duplicates tool names while passing MCP tools to sub-agents.
- **Workaround:** Downgrade to `@anthropic-ai/claude-code@2.0.28` or `2.0.29` and disable auto-updates, or temporarily comment out MCP entries in `.claude.json` until Anthropic ships a fix.
- **Tracker:** [anthropics/claude-code#10668](https://github.com/anthropics/claude-code/issues/10668).

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

## Built by Sr. LLM

Consider this the resume entry for our self-promoted "Senior LLM." Yes, this entire system—the coordinator, the specialized agents, the 41 modular skills, the test framework, even this README—was architected and refined by Claude. An AI building AI tools to help AI build better Rails apps, and insisting on the fancy title while doing it.

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

We're on the hook to prove Rails can lead the AI era. If that sounds fun, bring your scars, your pull requests, and your favorite lint rules—we'll build Phase 4 together.
