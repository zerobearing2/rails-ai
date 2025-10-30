# Changelog

All notable changes to rails-ai will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-30

### Added
- **Claude Code Plugin Support** - rails-ai is now installable as a Claude Code plugin
  - `.claude-plugin/plugin.json` manifest for plugin metadata
  - `.claude-plugin/marketplace.json` for self-distributing marketplace
  - One-command installation: `/plugin marketplace add zerobearing2/rails-ai`
- **Updated Installation Documentation**
  - Plugin installation as primary method in README.md
  - Local development installation instructions
  - Manual installation as alternative option
  - Plugin architecture documented in docs/plan.md
- **Skills Folder Decision**
  - Keeping `skills/` folder name (testing for collisions with Claude native skills)
  - Our structure uses different naming conventions (no `SKILL.md` files)
  - Will monitor and rename to `rails-skills/` if collisions occur

### Changed
- Installation workflow simplified to plugin-based approach
- Documentation updated to reflect plugin architecture

### Notes
- Private repository during agent tuning phase
- Will be open-sourced once battle-tested
- Cursor and Codex support planned for future releases

## [Unreleased] - Private Tuning Phase

### In Progress
- Agent tuning and refinement
- Testing across real Rails projects
- Gathering examples and patterns
- Testing skills/ folder for Claude native conflicts

### Future
- Open source release (TBD)
- MIT License (upon open source)
- Cursor plugin support
- Codex plugin support
- Public documentation expansion

---

**Repository:** https://github.com/zerobearing2/rails-ai
**Status:** Private (will be open-sourced later)
