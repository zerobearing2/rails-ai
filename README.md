# rails-ai 🚂

> **⚠️ EXPERIMENTAL:** Under active development. APIs and architecture may change. Phase 2 of 4.

Rails domain expertise for Claude Code. Built on [Superpowers](https://github.com/obra/superpowers) workflows.

## What It Does

Adds Rails-specific skills to Claude Code: ActiveRecord patterns, Hotwire, Minitest/TDD, security, Solid Stack (Rails 8), and 20 team conventions.

The architect agent loads Superpowers workflows (process) and Rails-AI skills (domain knowledge) to build features end-to-end.

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

## Architecture

**Two-layer system:**

- **Superpowers** = HOW to work (brainstorming, planning, TDD, debugging, code review)
- **Rails-AI** = WHAT you're building (12 Rails domain skills + team rules)

The architect loads both as needed.

## Philosophy

Opinionated Rails development:
- 37signals philosophy (simple, pragmatic)
- Rails conventions (REST-only)
- Solid Stack (SolidQueue, SolidCache, SolidCable)
- Minitest, not RSpec
- TDD always

## Roadmap

- **Phase 1**: ✅ Single architect agent with skill loading
- **Phase 2**: ✅ 12 domain skills + team rules + RuboCop cops
- **Phase 3**: 🔬 RAG + SQLite vector search for production Rails patterns
- **Phase 4**: 🚀 85%+ first-pass success rate, fully autonomous features

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [TESTING.md](TESTING.md).

## Credits

Built on [Superpowers](https://github.com/obra/superpowers) by [@obra](https://github.com/obra).

Planning approach inspired by [Specification Pyramid](https://signalthinking.com/p/why-your-prd-isnt-working-for-ai-083) by [Robert Evans](https://www.linkedin.com/in/rrevans/).

## License

MIT License - see [LICENSE](LICENSE).
