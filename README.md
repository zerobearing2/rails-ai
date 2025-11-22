# rails-ai

> **EXPERIMENTAL:** Under active development. APIs and architecture may change.

Rails domain expertise for Claude Code. Built on [Superpowers](https://github.com/obra/superpowers) workflows.

## What It Does

Provides Rails-specific workflows and domain skills for Claude Code: ActiveRecord patterns, Hotwire, Minitest/TDD, security, Solid Stack (Rails 8), and 20+ team conventions.

**Six workflow commands** mirror how experienced Rails developers actually work:

| Command | When to Use |
|---------|-------------|
| `/rails-ai:setup` | Project configuration, gem setup, validation |
| `/rails-ai:plan` | Brainstorm ideas, create implementation plans |
| `/rails-ai:feature` | Implement new functionality |
| `/rails-ai:refactor` | Improve existing code, fill test gaps |
| `/rails-ai:debug` | Fix bugs and broken functionality |
| `/rails-ai:review` | Review code/PRs against TEAM_RULES |

Each workflow command loads the appropriate Superpowers workflows (process) and Rails-AI skills (domain knowledge) automatically.

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

### Local Development Install

```bash
# 1. Clone the repository
git clone https://github.com/zerobearing2/rails-ai.git
cd rails-ai

# 2. Install Superpowers (required dependency)
claude
/plugin marketplace add obra/superpowers
/plugin install superpowers

# 3. Add local directory as a marketplace and install
/plugin marketplace add /path/to/rails-ai
/plugin install rails-ai@rails-ai

# 4. Restart Claude Code to load the plugin
```

**Run tests before submitting changes:**

```bash
bin/ci
```

## Usage

```bash
# Set up a new project
/rails-ai:setup configure Docker and credentials

# Plan a feature
/rails-ai:plan user authentication with OAuth

# Implement from a plan
/rails-ai:feature implement the authentication plan

# Refactor existing code
/rails-ai:refactor extract service object from UsersController

# Debug an issue
/rails-ai:debug tests failing in user_test.rb

# Review before merge
/rails-ai:review check PR #123 against team rules
```

## Architecture

**Two-layer system:**

- **Superpowers** = HOW to work (brainstorming, planning, TDD, debugging, code review)
- **Rails-AI** = WHAT you're building (12 Rails domain skills + team rules)

Each workflow command combines the right superpowers workflows with the relevant Rails-AI skills for that task.

### Workflow → Superpowers Mapping

| Workflow | Superpowers Used |
|----------|------------------|
| `setup` | verification-before-completion |
| `plan` | brainstorming, writing-plans |
| `feature` | using-git-worktrees, brainstorming, writing-plans, executing-plans, subagent-driven-development, test-driven-development, testing-anti-patterns, verification-before-completion, finishing-a-development-branch |
| `refactor` | using-git-worktrees, test-driven-development, testing-anti-patterns, verification-before-completion, finishing-a-development-branch |
| `debug` | systematic-debugging, root-cause-tracing, condition-based-waiting, test-driven-development, verification-before-completion |
| `review` | requesting-code-review, receiving-code-review |

### Rails-AI Skills (11 total)

Domain skills are loaded dynamically based on what the task involves:

1. **project-setup** — Environment config, credentials, Docker, RuboCop
2. **models** — ActiveRecord patterns, validations, associations, callbacks
3. **controllers** — RESTful actions, strong parameters, concerns
4. **views** — Partials, helpers, forms, accessibility (WCAG 2.1 AA)
5. **hotwire** — Turbo Drive, Frames, Streams, Morph, Stimulus
6. **styling** — Tailwind CSS, DaisyUI theming
7. **testing** — TDD with Minitest, fixtures, mocking
8. **security** — XSS, SQL injection, CSRF, file uploads
9. **jobs** — SolidQueue, SolidCache, SolidCable (NO Redis/Sidekiq)
10. **mailers** — ActionMailer, async delivery, templates
11. **debugging** — Rails debugging tools (logs, console, byebug)

## Philosophy

Opinionated Rails development:
- 37signals philosophy (simple, pragmatic)
- Rails conventions (REST-only)
- Solid Stack (SolidQueue, SolidCache, SolidCable)
- Minitest, not RSpec
- TDD always

## Roadmap

**Phase 1 — Foundation (v0.1-v0.2)** ✅ Complete
Initial skills, team rules, testing framework.

**Phase 2 — Domain Workflows (v0.3-v0.4)** ✅ Complete
Six workflow commands replacing architect coordinator, 11 domain skills, deterministic superpowers integration.

**Phase 3 — Memory & Context** 🔬 Next
Index production Rails patterns, wire into local memory + knowledge graph, RAG + SQLite vector search.

**Phase 4 — Fully Autonomous Rails**
Ship end-to-end features complete with tests and security. Target: 85%+ first-pass success rate.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [TESTING.md](TESTING.md).

## Credits

Built on [Superpowers](https://github.com/obra/superpowers) by [@obra](https://github.com/obra).

## License

MIT License - see [LICENSE](LICENSE).
