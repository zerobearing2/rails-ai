# rails-ai 🚂

> **⚠️ EXPERIMENTAL:** Under active development. APIs and architecture may change. Phase 2 of 4.

Rails domain expertise for Claude Code. Built on [Superpowers](https://github.com/obra/superpowers) workflows.

## The Vision

Build Rails apps so autonomously they leave today's Next.js and React generators in the dust. We're not playing catch-up—we're setting the pace and showing what LLM-driven development really looks like when Rails is in the driver's seat.

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

## What It Does

Adds Rails-specific skills to Claude Code: ActiveRecord patterns, Hotwire, Minitest/TDD, security, Solid Stack (Rails 8), and 20+ team conventions.

The `/rails-ai:architect` command loads Superpowers workflows (process) and Rails-AI skills (domain knowledge), then coordinates general-purpose agents to build features end-to-end.

## Installation

```bash
# 1. Install Superpowers (required)
claude
/plugin marketplace add obra/superpowers
/plugin install superpowers

# 2. Install rails-ai
/plugin marketplace add zerobearing2/rails-ai
/plugin install rails-ai
```

## Usage

```bash
/rails-ai:architect add user authentication
/rails-ai:architect debug failing test
/rails-ai:architect refactor UserController
```

**Local Development Note:** If you're developing rails-ai locally (installed from a local directory), SessionStart hooks don't execute due to a [Claude Code limitation](https://github.com/anthropics/claude-code/issues/11939). Manually load the skill once per session:

```text
Load the skill: using-rails-ai
```

This loads the full protocol including Superpowers integration and skill-loading enforcement. Not needed when installed from GitHub.

## Architecture

**Two-layer system:**

- **Superpowers** = HOW to work (brainstorming, planning, TDD, debugging, code review)
- **Rails-AI** = WHAT you're building (12 Rails domain skills + team rules)

The `/rails-ai:architect` slash command loads both layers, then dispatches general-purpose agents as workers to implement features.

## Philosophy

Opinionated Rails development:
- 37signals philosophy (simple, pragmatic)
- Rails conventions (REST-only)
- Solid Stack (SolidQueue, SolidCache, SolidCable)
- Minitest, not RSpec
- TDD always

## Roadmap

We're turning that gap into a roadmap instead of a wish list.

**Phase 1 — Architect Coordinator** ✅ Complete
Clean architecture with `/rails-ai:architect` slash command that coordinates development: loads Superpowers workflows (HOW) and Rails-AI skills (WHAT), then dispatches general-purpose workers to implement. No complexity, clear separation between coordination and execution.

**Phase 2 — Domain Skills & Team Rules** 🚧 Current
12 focused domain skills, 20+ team conventions, and custom RuboCop cops. Every decision backed by Rails best practices in reusable, testable modules.

**Phase 3 — Memory & Context** 🔬 Next
Index thousands of production Rails patterns, wire them into local memory + knowledge graph, and retrieve the right snippet at the right time with RAG + SQLite vector search.

**Phase 4 — Fully Autonomous Rails** 🚀 Goal
Ship end-to-end features—auth, payments, background jobs, admin, APIs—complete with tests and security. Target: 85%+ first-pass success rate.

**What already works:**
- `/rails-ai:architect` coordinates features end-to-end (planning → worker dispatch → review)
- 12 domain skills cover models, controllers, views, Hotwire, security, testing, and more
- Superpowers workflows provide battle-tested TDD, debugging, and code review
- 20+ team rules enforce Rails conventions automatically
- Clean separation: coordinator loads skills, workers implement features

**What we're building next:**
- Phase 3 RAG pipeline with SQLite vector search
- Library of thousands of indexed production Rails patterns
- 30–50% accuracy gains from better retrieval and context
- Path to 85%+ first-try pass rates and autonomous feature delivery

## Join Us

This is bigger than a plugin. We're proving Rails can lead in the AI era.

**If you're a Rails developer:** Try the architect. Break it. Tell us what's missing. Your real-world usage drives what we build.

**If you're into AI/ML:** We need help with Phase 3 (RAG) and Phase 4 (autonomous delivery). Indexing Rails codebases, building evaluation frameworks, improving retrieval quality.

**If you care about Rails:** Star the repo. Spread the word. Rails deserves world-class AI tooling. Help us build it.

The goal isn't just good—it's to make Rails the obvious choice for AI-assisted development. Help us get there.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [TESTING.md](TESTING.md).

## Credits

Built on [Superpowers](https://github.com/obra/superpowers) by [@obra](https://github.com/obra).

Planning approach inspired by [Specification Pyramid](https://signalthinking.com/p/why-your-prd-isnt-working-for-ai-083) by [Robert Evans](https://github.com/revans).

## License

MIT License - see [LICENSE](LICENSE).
