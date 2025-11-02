# Changelog

All notable changes to rails-ai will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
