# Changelog

All notable changes to rails-ai will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2025-11-15

### Major Changes

This release represents a **major architectural transformation** from a custom agent system to a layered architecture built on Superpowers workflows.

#### Layered Architecture
- **NEW:** Rails-AI now builds on Superpowers for universal workflow orchestration
- **NEW:** Clear separation: Rails-AI (domain layer) + Superpowers (workflow foundation)
- **BREAKING:** Superpowers is now a required dependency - must be installed first

#### Agent Reorganization (7 → 5 agents)
- **BREAKING:** Consolidated agents by domain:
  - `architect` - Coordinator (refactored to reference Superpowers workflows)
  - `developer` - Full-stack Rails developer (combines backend + frontend + debug)
  - `security` - Security specialist (unchanged role, updated to reference Superpowers)
  - `devops` - Infrastructure and deployment specialist (NEW)
  - `uat` - Testing and quality assurance specialist (NEW)
- **REMOVED:** `backend.md` agent (merged into developer)
- **REMOVED:** `frontend.md` agent (merged into developer)
- **REMOVED:** `debug.md` agent (merged into developer)
- **REMOVED:** `plan.md` agent (planning now uses superpowers:writing-plans)

#### Skills Reduction (41 → 33 skills)
- **REMOVED:** 4 ViewComponent skills (not using yet - deferred to future):
  - `viewcomponent-basics.md`
  - `viewcomponent-slots.md`
  - `viewcomponent-previews.md`
  - `viewcomponent-variants.md`
- **ADDED:** `debugging-rails` skill for Rails-specific debugging tools
- **ADDED:** `using-rails-ai` skill explaining Rails-AI/Superpowers integration
- **CHANGED:** All skills now namespaced as `rails-ai:skillname`

### Superpowers Integration

#### Workflow References
Architect agent now references Superpowers workflows for orchestration:
- Design phase: `superpowers:brainstorming`
- Planning phase: `superpowers:writing-plans`
- Execution phase: `superpowers:executing-plans` or `superpowers:subagent-driven-development`
- Debugging phase: `superpowers:systematic-debugging`
- Review phase: `superpowers:requesting-code-review`
- Verification: `superpowers:verification-before-completion`
- Parallel work: `superpowers:dispatching-parallel-agents`

#### Skill Integration
Skills with workflow dependencies include REQUIRED BACKGROUND sections:
- `rails-ai:tdd-minitest` requires `superpowers:test-driven-development`
- `rails-ai:debugging-rails` requires `superpowers:systematic-debugging`

### Documentation

#### New Documentation
- **Added:** `docs/migration-v0.3.md` - Migration guide from v0.2 to v0.3
- **Added:** `docs/superpowers-integration.md` - Detailed integration documentation

#### Updated Documentation
- **Updated:** `README.md` with:
  - Superpowers dependency requirement
  - Updated agent count (5 agents)
  - Updated skill count (33 skills)
  - Layered architecture diagram
  - Updated installation instructions
  - Updated agent list (removed plan, backend, frontend, debug)
- **Updated:** `.claude-plugin/marketplace.json` with:
  - Version 0.3.0
  - Superpowers dependency declaration
  - Updated description emphasizing layered architecture

### What Stays the Same

#### Team Rules
- All 20 team rules from TEAM_RULES.md remain enforced
- Custom RuboCop cops preserved (Style/NestedBracketAccess)

#### Context7 Integration
- Context7 MCP server integration unchanged
- Up-to-date Rails documentation fetching preserved

#### Core Skills
- Backend skills (ActiveRecord, controllers, mailers, etc.)
- Frontend skills (Hotwire, Tailwind, DaisyUI, views, etc.)
- Testing skills (Minitest, TDD, fixtures, etc.)
- Security skills (SQL injection, XSS, CSRF, etc.)
- Config skills (Docker, credentials, Solid Stack, etc.)

### Breaking Changes Summary

1. **Superpowers Required:** Must install Superpowers before rails-ai v0.3.0
2. **Agent Names Changed:**
  - `@agent-rails-ai:backend` → `@agent-rails-ai:developer`
  - `@agent-rails-ai:frontend` → `@agent-rails-ai:developer`
  - `@agent-rails-ai:debug` → `@agent-rails-ai:developer`
  - `@agent-rails-ai:tests` → `@agent-rails-ai:uat`
  - `@agent-rails-ai:plan` → Use `@agent-rails-ai:architect` (references superpowers:writing-plans)
3. **ViewComponent Skills Removed:** 4 skills removed (will return in future release)
4. **Skill Namespacing:** All skills now `rails-ai:skillname`

### Migration Guide

See [docs/migration-v0.3.md](docs/migration-v0.3.md) for detailed migration instructions.

### Benefits

1. **Less Duplication:** Workflows in one place (Superpowers), Rails patterns in another (Rails-AI)
2. **Better Maintenance:** Workflow improvements benefit all domain plugins
3. **Clearer Responsibilities:** Rails-AI focuses on Rails domain knowledge
4. **Automatic Improvements:** Superpowers workflow enhancements automatically benefit Rails-AI
5. **Ecosystem Integration:** Foundation for other domain plugins (Django, Laravel, Phoenix, etc.)

## [0.2.1] - 2025-11-08

### Added
- Rule #20: Prefer `Hash#dig` over nested bracket access for safer hash traversal
- Custom RuboCop cop (`Style/NestedBracketAccess`) to enforce `Hash#dig` usage
- Comprehensive unit tests for rules system


## [0.2.0] - 2025-11-02

### Changed
- Excluded MD012 linting rule to allow multiple blank lines in markdown files
- Optimized agent system prompts reducing token usage by 36,909 tokens (14-15% reduction)


## [0.1.4] - 2025-10-31

Based on the commits, here's the CHANGELOG entry:

### Changed
- Optimized agent skills reducing token usage by 38.5% (85,986 tokens saved)
- Enhanced release script with automated linting enforcement

## [0.1.3] - 2025-10-31

### Added
- Planning Agent for Specification Pyramid Framework
- Context7 MCP support for up-to-date Rails documentation

### Changed
- Updated concerns location conventions for better organization
- Enforced markdown linting in CI with all violations fixed

### Fixed
- Architect agent delegation enforcement

## [0.1.2] - 2025-10-31

### Added
- Known Issues section documenting Claude Code v2.0.30 MCP bug

### Changed
- Meta Moment section with more relatable metaphors
- CHANGELOG.md format to match git tags and Keep a Changelog standard

### Fixed
- Errors in bin/release script

### Removed
- Manual installation section from README

### Added
- Claude Code project settings (`.claude/settings.json`) with pre-approved commands
- Comprehensive `.claude/README.md` documenting settings system
- Release automation script (`bin/release`) with AI-powered release notes
- Release documentation (`docs/releasing.md`) with complete workflow guide
- Dry-run mode for testing releases (`bin/release --dry-run`)

### Changed
- Removed manual installation section from README (plugin is primary method)
- Updated AGENTS.md to v2.0 reflecting open source status and current architecture
- Enhanced `bin/release` with Claude CLI integration for automated changelog generation
- Synchronized plugin version updates with git releases in `bin/release`
- Updated references from personal username to `zerobearing2` for consistency

### Fixed
- Claude CLI integration now uses `--print` flag instead of `--no-stream`
- Function definition order in `bin/release` script

## [0.1.1] - 2025-10-30

### Added
- MIT License for permissive open source use
- Contributing guidelines (`CONTRIBUTING.md`) with development workflow
- Code of Conduct (`CODE_OF_CONDUCT.md`) following Contributor Covenant 2.1
- Security policy (`SECURITY.md`) with vulnerability reporting process
- GitHub issue templates for bug reports and feature requests
- GitHub pull request template
- `.gitattributes` for consistent line endings across platforms

### Changed
- Updated README.md to reflect open source status
- Removed references to private repository
- Added Contributing, License, and Support sections to README

## [0.1.0] - 2025-10-30

### Added

- **Claude Code Plugin Support** - rails-ai is now installable as a Claude Code plugin
  - `.claude-plugin/marketplace.json` for plugin distribution
  - One-command installation: `/plugin marketplace add zerobearing2/rails-ai`
- Initial plugin architecture and documentation
- Skills registry system for centralized skill management

### Changed

- **Agent Naming Convention** - Simplified agent names by removing `rails-` prefix
  - `rails.md` → `architect.md` (uses `@rails-ai:architect`)
  - `rails-backend.md` → `backend.md` (uses `@rails-ai:backend`)
  - `rails-frontend.md` → `frontend.md` (uses `@rails-ai:frontend`)
  - `rails-tests.md` → `tests.md` (uses `@rails-ai:tests`)
  - `rails-security.md` → `security.md` (uses `@rails-ai:security`)
  - `rails-debug.md` → `debug.md` (uses `@rails-ai:debug`)
- Updated all cross-references, tests, and documentation to reflect new agent names
- Installation workflow simplified to plugin-based approach

### Fixed
- Removed duplicate `plugin.json` (marketplace.json is sufficient for local installation)
- Fixed incomplete agent rename references found by code review
- Restored test safeguard for legacy coordinator mentions

---

**Repository:** https://github.com/zerobearing2/rails-ai
**Status:** Open Source (MIT License)
