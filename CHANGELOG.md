# Changelog

All notable changes to rails-ai will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- 6 workflow commands replacing single architect coordinator:
  - `/rails-ai:setup` — Project configuration, gem setup, validation
  - `/rails-ai:plan` — Brainstorm ideas, create implementation plans
  - `/rails-ai:feature` — Implement new functionality with TDD
  - `/rails-ai:refactor` — Improve existing code, fill test gaps
  - `/rails-ai:debug` — Fix bugs with systematic debugging
  - `/rails-ai:review` — Review code/PRs against TEAM_RULES

### Changed
- **BREAKING**: Architecture refactored from single `/rails-ai:architect` to 6 domain-specific workflow commands
- **BREAKING**: Superpowers workflows now hardcoded per command (deterministic) instead of dynamically selected
- Skills refactored to pure domain knowledge (removed superpowers references)
- Each workflow command mirrors real Rails developer workflows
- README completely rewritten for new architecture
- docs/superpowers-integration.md rewritten to explain new workflow-to-superpowers mapping

### Removed
- `/rails-ai:architect` command (replaced by 6 workflow commands)
- `using-rails-ai` skill (content moved to workflow commands)
- SessionStart hook (no longer needed — workflows are explicit)
- Superpowers references from `debugging` and `testing` skills

### Fixed
- Context window decay issue — workflow commands reload fresh each invocation
- Non-deterministic superpowers selection — now hardcoded per workflow

## [0.3.1] - 2025-11-21

### Added
- Architect persona for Rails 8+ application design and coordination

### Changed
- Upgraded to expert coordinator role for improved guidance

### Removed
- Documentation plans from source control


## [0.3.0] - 2025-11-20

Based on my analysis of the git commits, here's the CHANGELOG entry:

### Added
- Rake task `test:unit:commands` for running command tests
- Project validation workflow to verify TEAM_RULES.md compliance, required gems, and configuration

### Changed
- **BREAKING**: Architect converted from agent to slash command coordinator (`agents/architect.md` → `commands/architect.md`)
- **BREAKING**: Architecture simplified from 7 agents to single `/rails-ai:architect` command that dispatches general-purpose workers
- Renamed skill: `rails-ai:configuration` → `rails-ai:project-setup`
- Consolidated skill-loading enforcement into `using-rails-ai` skill as single source of truth
- Test infrastructure: replaced 5 agent test files (375 lines) with command structure tests (10 tests, 33 assertions)
- Terminology consistency: "skill-loading" → "skill-usage" throughout documentation

### Fixed
- AGENTS.md path reference: `agents/architect.md` → `commands/architect.md`
- Missing Rake task for command tests
- 31 test failures by adding `require "date"` to test helper
- 2 skipped tests in `using-rails-ai` skill with proper assertions

### Removed
- 6 agent files: `backend.md`, `debug.md`, `frontend.md`, `plan.md`, `security.md`, `tests.md`
- Obsolete integration test infrastructure from Rakefile and CI scripts
- Outdated documentation files: PR template, development setup, GitHub Actions setup, releasing guide
- `.claude/` configuration directory (users manage their own settings)
- 33 individual skill markdown files, consolidated into 12 domain skill files


### Major Architecture Refactor (v0.3.0)

**Coordinator Architecture**: Consolidated from 7 agents to `/rails-ai:architect` slash command that coordinates development by dispatching general-purpose workers.

#### Architecture Changes
- **BREAKING**: 7 agents → 1 `/rails-ai:architect` slash command (coordinator, not agent)
- **BREAKING**: Removed SKILLS_REGISTRY.yml (now file-based skill discovery)
- **BREAKING**: Removed RULES_TO_SKILLS_MAPPING.yml (rules in TEAM_RULES.md)
- **NEW**: Built on Superpowers for universal workflows (brainstorming, planning, TDD, debugging, code review)
- **NEW**: Clear separation: Superpowers (HOW to work) + Rails-AI (WHAT you're building)
- **NEW**: 12 domain-organized skills loaded on-demand

#### Removed
- Context7 MCP server integration and .mcp.json
- Integration test infrastructure (replaced with unit tests only)
- ViewComponent skills (4 skills - deferred to future)
- Legacy agent files: plan.md, backend.md, frontend.md, tests.md, security.md, debug.md

#### Added
- `/rails-ai:architect` slash command coordinates all work (loads skills, dispatches workers)
- Clean separation: coordinator (loads context) vs workers (implement features)
- Superpowers dependency (required)
- SessionStart hook with proper plugin configuration
- `using-rails-ai` skill explaining architecture
- `debugging` skill for Rails debugging tools

#### Changed
- **Skills**: Now 12 domain skills with YAML front matter (was 41 with registry)
- **Command**: `/rails-ai:architect` instead of `/rails-ai:rails-ai`
- **Tests**: Unit tests only (152 tests, 1621 assertions)
- **Documentation**: Drastically simplified (README: 268→71 lines, CONTRIBUTING: 160→68 lines, AGENTS.md: 876→146 lines)

#### Skills (12 total)
1. project-setup - Project validation, environment config, credentials, Docker, RuboCop (coordinates with domain skills)
2. controllers - RESTful actions, strong parameters, concerns
3. debugging - Rails debugging tools + superpowers:systematic-debugging
4. hotwire - Turbo Drive, Frames, Streams, Morph, Stimulus
5. jobs - SolidQueue, SolidCache, SolidCable (NO Redis/Sidekiq)
6. mailers - ActionMailer with async delivery
7. models - ActiveRecord patterns, validations, associations
8. security - XSS, SQL injection, CSRF, file uploads
9. styling - Tailwind CSS, DaisyUI
10. testing - TDD with Minitest, fixtures, mocking
11. using-rails-ai - Introduction and architecture guide
12. views - Partials, helpers, forms, accessibility (WCAG 2.1 AA)

#### Team Rules
- All 20 team rules from TEAM_RULES.md remain enforced
- Custom RuboCop cops preserved (Style/NestedBracketAccess)

#### Dependencies
- **ADDED**: Superpowers (required) - universal workflow framework
- **REMOVED**: Context7 MCP server (optional, removed)

---

## [0.2.0] - 2025-11-12

### Added
- Custom RuboCop cop: Style/NestedBracketAccess (Rule #20)
- Test coverage reporting
- Skill testing framework with RED-GREEN-REFACTOR workflow

### Changed
- Enhanced TEAM_RULES.md with quick lookup index
- Improved bin/ci with better output formatting

## [0.1.3] - 2025-10-31

### Added
- Planning Agent for Specification Pyramid Framework

### Changed
- Updated concerns location conventions for better organization
- Enforced markdown linting in CI with all violations fixed
