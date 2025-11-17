# Changelog

All notable changes to rails-ai will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Major Architecture Refactor (v0.3.0)

**Single-Agent Architecture**: Consolidated from 7 agents to 1 architect agent that dynamically loads Superpowers workflows and Rails-AI skills.

#### Architecture Changes
- **BREAKING**: 7 agents → 1 architect agent
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
- Single architect agent coordinates all work
- Command: `/rails-ai:architect` (renamed from `/rails-ai:rails-ai`)
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
1. configuration - Environment config, credentials, Docker, RuboCop
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
