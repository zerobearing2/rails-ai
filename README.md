# rails-ai 🤖

**Multi-agent AI development system for Ruby on Rails**

> ⚠️ **Work in Progress**: This project is under active development. Current status: Extracting from feedback-app.

## Overview

rails-ai is an AI-powered multi-agent development system for Ruby on Rails projects. It provides a team of 8 specialized AI agents that work together to help you build features, fix bugs, write tests, and maintain high code quality—all following Rails conventions and 37signals-inspired best practices.

## Current Status

**Phase 0: Migration complete ✓**
- ✓ Agents, examples, and documentation moved from feedback-app
- ✓ Monorepo structure in place
- ✓ Git repository initialized
- → Next: Create GitHub remote and begin abstraction

## Project Structure

```
rails-ai/
├── core/                      # Generic agent patterns (coming soon)
├── adapters/
│   ├── llm/                   # LLM provider adapters (coming soon)
│   └── framework/
│       └── rails/             # Rails-specific content
│           ├── agents/        # 8 specialized agents
│           ├── examples/      # ~39 code examples
│           ├── rules/         # Team rules and decision matrices
│           └── templates/     # Project templates
├── scripts/                   # Installation and update scripts (coming soon)
├── templates/                 # Generic templates (coming soon)
└── docs/                      # Documentation
```

## License

MIT License (to be finalized)

## Credits

Originally developed for the feedback-app project. Inspired by 37signals' philosophy: simple, pragmatic, conventional Rails development.
