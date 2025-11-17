# rails-ai 🚂🤖

> **⚠️ EXPERIMENTAL:** This project is under active development and not yet stable. APIs, architecture, and workflows may change significantly. Use in production at your own risk. We're currently in Phase 2 of a 4-phase roadmap.

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

**Phase 1 — Specialized Agents** ✅ Completed → Simplified
Single architect agent loads domain skills on demand. Built on Superpowers workflows for orchestration.

**Phase 2 — Structured Intelligence** ✅ Completed
Twelve domain-organized skills, shared team rules, and custom cops bake Rails judgment into reusable modules. The architect loads skills as needed. Built on Superpowers for universal workflows.

**Phase 3 — Memory & Context** 🔬 In design  
Index thousands of production Rails patterns, wire them into a local memory + knowledge graph, and retrieve the right snippet at the right time with RAG + SQLite vector search so every response is grounded in real context.

**Phase 4 — Fully Autonomous Rails** 🚀 Goal  
Ship end-to-end features—auth, payments, background jobs, admin, APIs—complete with tests and security, and hit an 85%+ first-pass success rate.

**What already works**
- @agent-rails-ai:architect orchestrates real features end to end
- Single architect loads Superpowers workflows (HOW to work) and Rails-AI skills (WHAT you're building)
- Built on Superpowers for universal workflows (brainstorming, planning, TDD, debugging, review)
- Twelve domain-organized skills provide repeatable, testable Rails knowledge
- Team rules and custom RuboCop cops enforce Rails conventions

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

1. **Install Superpowers (required dependency):**

   Rails-AI builds on Superpowers for universal workflows (brainstorming, planning, TDD, debugging, review).

   ```bash
   claude
   ```

   Then in Claude Code:
   ```
   /plugin marketplace add obra/superpowers
   /plugin install superpowers
   ```

2. **Install rails-ai:**

   Open a Claude Code session in your terminal:
   ```bash
   claude
   ```

   Then run these commands in the Claude Code session:
   ```
   /plugin marketplace add zerobearing2/rails-ai
   /plugin install rails-ai
   ```

3. **Start using Rails-AI:**

   Once installed, you can use the `/rails-ai:architect` command in any Claude Code session:

   ```text
   /rails-ai:architect add user authentication
   /rails-ai:architect debug failing test
   /rails-ai:architect plan new feature
   ```

   The command invokes the Rails architect agent, which loads superpowers workflows (process) and rails-ai skills (domain expertise) as needed.

   For complete details on available skills and usage patterns, see `skills/using-rails-ai/SKILL.md`.

That's it! The architect is now available globally in all your Rails projects.

## Usage

In any Rails project with Claude Code:

```text
# Use the convenience command (recommended)
/rails-ai:architect Add user authentication feature

# Or invoke the architect agent directly
@agent-rails-ai:architect Add user authentication feature
```

The `/rails-ai:architect` command is a shortcut that invokes the architect agent. Use it for features, debugging, planning, refactoring, or any Rails development task.

The architect will analyze requirements, load relevant superpowers workflows (for process) and rails-ai skills (for domain expertise), and deliver a complete implementation with tests.

## Architecture

Rails-AI is a **two-layer system** built on Superpowers:

```text
┌─────────────────────────────────────────────┐
│ LAYER 1: Superpowers (Universal Process)   │
│  • brainstorming - Refine ideas             │
│  • writing-plans - Create plans             │
│  • test-driven-development - TDD cycle      │
│  • systematic-debugging - Investigation     │
│  • subagent-driven-development - Execution  │
│  • dispatching-parallel-agents - Coordinate │
│  • requesting-code-review - Quality gates   │
│  • finishing-a-development-branch - Complete│
│  • receiving-code-review - Handle feedback  │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ LAYER 2: Rails-AI (Domain Expertise)       │
│  • @rails-ai:architect (single agent)       │
│  • 12 Rails domain skills                   │
│  • Team rules & RuboCop cops                │
│  • Rails 8+ patterns and conventions        │
└─────────────────────────────────────────────┘
```

**Key Principle:**
- **Superpowers = HOW** to work (process framework)
- **Rails-AI = WHAT** you're building (domain knowledge)
- The architect loads both as needed

## Project Structure

```text
rails-ai/
├── agents/          # @rails-ai:architect (single agent)
├── commands/        # /rails-ai:architect convenience command
├── skills/          # 12 domain-organized skills (see skills/using-rails-ai/SKILL.md for details)
├── rules/           # Team rules and decision matrices
├── test/            # Minitest-based skill testing framework
├── bin/             # Development scripts (setup, ci)
└── docs/            # Documentation and guides
```

For the complete list of skills with descriptions, see `skills/using-rails-ai/SKILL.md`.

## Philosophy

Every agent ships with the same north star, so the code they write feels like the Rails we ship by hand. This is an **opinionated** system that follows:
- 37signals philosophy (simple, pragmatic, delete code)
- Rails conventions (REST-only, no custom actions)
- Solid Stack (Rails 8: SolidQueue, SolidCache, SolidCable)
- Minitest (no RSpec)
- TDD always via superpowers:test-driven-development
- Peer review via superpowers:requesting-code-review
- Layered architecture (Rails-AI on Superpowers)

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

Consider this the resume entry for our self-promoted "Senior LLM." Yes, this entire system—the coordinator, the specialized agents, the 12 modular skills, the test framework, even this README—was architected and refined by Claude. An AI building AI tools to help AI build better Rails apps, and insisting on the fancy title while doing it.

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

### Dependencies

Rails-AI is built on top of [Superpowers](https://github.com/obra/superpowers), a universal workflow framework for Claude Code that provides the process layer (brainstorming, planning, TDD, debugging, code review). Superpowers is a required dependency.

### Specification Pyramid Concept

The planning workflow's systematic documentation approach (Vision → Architecture → Features → Tasks) is inspired by the **Specification Pyramid** concept from [Robert Evans](https://www.linkedin.com/in/rrevans/), a highly accomplished Rubyist, friend, colleague, and expert in the field.

Read more about the Specification Pyramid in his article: [Why Your PRD Isn't Working for AI](https://signalthinking.com/p/why-your-prd-isnt-working-for-ai-083)

### Philosophy

Inspired by 37signals' philosophy of simple, conventional Rails development.

## Support

- Report bugs or request features via [GitHub Issues](https://github.com/zerobearing2/rails-ai/issues)
- Check the [documentation](docs/) for guides and help
- See [TESTING.md](TESTING.md) for development and testing questions

We're on the hook to prove Rails can lead the AI era. If that sounds fun, bring your scars, your pull requests, and your favorite lint rules—we'll build Phase 4 together.
