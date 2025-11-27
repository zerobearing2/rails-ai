# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails-AI is a Claude Code plugin providing Rails domain expertise. Built on [Superpowers](https://github.com/obra/superpowers) workflows.

**Read `AGENTS.md` for detailed architecture** — workflow commands, agent modes, skill structure, rules, and development guidelines.

## Commands

```bash
bin/ci                      # Full CI: lint + tests (run before commits)
rake test:unit              # All unit tests
rake test:unit:skills       # Skills tests only
rake test:unit:agents       # Agents tests only
rake lint:fix               # Auto-fix Ruby style issues
```

## Key Conventions

- **TDD always** — RED-GREEN-REFACTOR
- **Minitest only** — no RSpec
- **Solid Stack** — SolidQueue, SolidCache, SolidCable (NO Redis/Sidekiq)
- **PRs target `develop` branch** — not `main`
