# Release Process

This document describes how to create a new release of rails-ai.

## Prerequisites

Before creating a release, ensure you have:

1. **GitHub CLI installed** - `gh` command
   ```bash
   # Install on macOS
   brew install gh

   # Install on Linux
   sudo apt install gh  # or use your package manager
   ```

2. **GitHub CLI authenticated**
   ```bash
   gh auth login
   ```

3. **All changes committed** - No uncommitted changes in your working directory

4. **On master/main branch** - Or explicitly confirm you want to release from another branch

5. **Latest changes pulled** - Up to date with remote

## Quick Release

```bash
bin/release
```

Or for a dry run (see what will happen without making changes):

```bash
bin/release --dry-run
```

The script will guide you through:

1. **Pull latest changes** from GitHub (skipped in dry-run)
2. **Run CI checks** (linting + tests) - must pass (skipped in dry-run)
3. **Version bump** - Choose patch/minor/major or custom
4. **Analyze commits** - Gets all commits since last version tag
5. **Generate release notes** - Uses Claude CLI to summarize commits (if available)
6. **Review & edit** - Confirm or edit AI-generated notes
7. **Review release** - Confirm the complete release details
8. **Update CHANGELOG.md** - Automatically inserts new version (dry-run shows preview)
9. **Commit changes** - Commits changelog with release notes
10. **Create git tag** - Tags commit with version (e.g., v1.0.0)
11. **Push to GitHub** - Pushes commits and tags
12. **Create GitHub Release** - Creates release with formatted notes

## Release Types

### Patch Release (Bug Fixes)
- Version: `0.1.0` → `0.1.1`
- When: Bug fixes, small improvements, documentation updates
- Example: Fixing broken tests, correcting typos, minor refactors

### Minor Release (New Features)
- Version: `0.1.1` → `0.2.0`
- When: New features, new skills, backward-compatible changes
- Example: Adding new agent, new skill, new capability

### Major Release (Breaking Changes)
- Version: `0.2.0` → `1.0.0`
- When: Breaking changes, major refactors, API changes
- Example: Changing agent architecture, removing features, incompatible updates

### Custom Version
- Version: Any valid semver (e.g., `2.5.3`)
- When: Special cases, pre-releases, version corrections

## AI-Powered Release Notes

The script uses **Claude CLI** to automatically generate release notes from your git commits!

### How it works

1. **Analyzes commits** - Gets all commits since last version tag
2. **Summarizes with AI** - Claude reads commits and generates clean changelog
3. **Keep a Changelog format** - Automatically categorizes into Added, Changed, Fixed, etc.
4. **Review & edit** - You can approve, edit, or reject the AI-generated notes

### Example

```text
Commits since last version:
- Add bin/release script for automated releases
- Fix settings.json: Remove invalid JSON comments
- Update AGENTS.md for open source release
- Add Claude Code project settings

Claude CLI generates:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### Added
- Automated release script (bin/release) for version bumping and GitHub releases
- Claude Code project settings with pre-approved commands

### Changed
- Updated AGENTS.md documentation for open source architecture

### Fixed
- Fixed invalid JSON comments in settings.json
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Use these release notes? (y/n/e to edit)
```

### No Claude CLI

If Claude CLI is not installed, the script falls back to manual entry. Install with:

```bash
npm install -g @anthropics/claude-cli
```

## Release Notes Format

Release notes use standard [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) categories:

- **Added** - New features
- **Changed** - Changes to existing functionality
- **Fixed** - Bug fixes
- **Removed** - Removed features
- **Deprecated** - Soon-to-be removed features
- **Security** - Security improvements

Example:

```markdown
### Added
- New backend skill for API authentication
- Support for Rails 8.1 features

### Changed
- Improved architect agent coordination
- Updated SKILLS_REGISTRY.yml format

### Fixed
- Fixed bug in viewcomponent-testing skill
- Corrected YAML validation in CI

### Removed
- Deprecated rails-config agent (merged into backend)
```

## What Happens During Release

### 1. Pre-flight Checks
```bash
# Checks for uncommitted changes
git status --porcelain

# Verifies branch
git branch --show-current

# Pulls latest
git pull origin master

# Runs full CI
bin/ci
```

### 2. Version Calculation
```bash
# Extracts current version from CHANGELOG.md
CURRENT_VERSION=$(grep -m 1 '\[.*\]' CHANGELOG.md | ...)

# Calculates new version based on your selection
# Patch: 0.1.0 → 0.1.1
# Minor: 0.1.1 → 0.2.0
# Major: 0.2.0 → 1.0.0
```

### 3. Version File Updates

**CHANGELOG.md:**
```markdown
## [Unreleased]

## [0.2.0] - 2025-10-31     ← New entry inserted here

### Added
- Your release notes here

## [0.1.1] - 2025-10-30     ← Previous versions below
...
```

**Claude Plugin (.claude-plugin/marketplace.json):**
```json
{
  "plugins": [
    {
      "name": "rails-ai",
      "version": "0.2.0",     ← Updated to match release
      ...
    }
  ]
}
```

### 4. Git Operations
```bash
# Commit changelog and plugin version
git add CHANGELOG.md .claude-plugin/marketplace.json
git commit -m "Release 0.2.0\n\n[release notes]"

# Create annotated tag
git tag -a "v0.2.0" -m "Release v0.2.0\n\n[release notes]"

# Push commits and tags
git push origin master
git push origin v0.2.0
```

### 5. GitHub Release
```bash
# Creates GitHub release with formatted notes
gh release create "v0.2.0" \
  --title "v0.2.0" \
  --notes "[formatted release notes]" \
  --latest
```

The GitHub release includes:
- Your release notes
- Installation instructions
- Link to CHANGELOG.md
- Full changelog comparison link

## Manual Release (Without Script)

If you need to create a release manually:

```bash
# 1. Update version files
vim CHANGELOG.md
# Add new version entry under [Unreleased]

vim .claude-plugin/marketplace.json
# Update "version" field to match release

# 2. Commit
git add CHANGELOG.md .claude-plugin/marketplace.json
git commit -m "Release v0.2.0"

# 3. Tag
git tag -a v0.2.0 -m "Release v0.2.0"

# 4. Push
git push origin master
git push origin v0.2.0

# 5. Create GitHub release
gh release create v0.2.0 \
  --title "v0.2.0" \
  --notes "Release notes here" \
  --latest
```

## Rollback a Release

If something goes wrong:

### Delete GitHub Release
```bash
gh release delete v0.2.0 --yes
```

### Delete Git Tag
```bash
# Local
git tag -d v0.2.0

# Remote
git push origin :refs/tags/v0.2.0
```

### Revert Commit
```bash
git revert HEAD
git push origin master
```

## Dry Run Mode

Test the release process without making any changes:

```bash
bin/release --dry-run
```

This will:
- ✅ Skip CI checks
- ✅ Skip git pull
- ✅ Allow uncommitted changes
- ✅ Show version bump calculation
- ✅ Analyze commits and generate release notes
- ✅ Show preview of what would be released
- ❌ **Not** update CHANGELOG.md
- ❌ **Not** create commits or tags
- ❌ **Not** push to GitHub
- ❌ **Not** create GitHub release

Perfect for:
- Testing the script
- Previewing release notes
- Verifying commit analysis
- Planning next release

## Troubleshooting

### CI Checks Fail
```bash
# Fix issues
rake lint:fix          # Auto-fix linting
rake test:unit  # Run tests

# Re-run CI
bin/ci
```

### Claude CLI Not Working
```bash
# Check if installed
which claude

# Install/reinstall
npm install -g @anthropics/claude-cli

# Test it
echo "Hello" | claude
```

### Wrong Version Released
1. Delete the GitHub release
2. Delete the git tag (local and remote)
3. Revert the commit
4. Run `bin/release` again with correct version

### Release Notes Have Typo
You can edit the GitHub release after creation:
```bash
gh release edit v0.2.0 --notes "Corrected release notes"
```

Or edit directly on GitHub web interface.

### Permission Denied Pushing Tags
```bash
# Check remote
git remote -v

# Ensure you have push access
gh auth status
```

## Post-Release

After a successful release:

1. **Announce** - Share in Discord, social media, etc.
2. **Monitor** - Watch for issues reported by users
3. **Hotfix if needed** - Use patch release for critical bugs
4. **Plan next release** - Update [Unreleased] section in CHANGELOG.md

## Semantic Versioning Reference

rails-ai follows [Semantic Versioning 2.0.0](https://semver.org/):

Given a version number `MAJOR.MINOR.PATCH`, increment:
- **MAJOR** - Incompatible API changes
- **MINOR** - Backward-compatible new functionality
- **PATCH** - Backward-compatible bug fixes

Examples:
- `0.1.0` - Initial development
- `0.2.0` - New features added
- `0.2.1` - Bug fix
- `1.0.0` - Stable release, ready for production

## Questions

- Check the [bin/release](../bin/release) script source
- Review [CHANGELOG.md](../CHANGELOG.md) for examples
- Ask in GitHub Discussions or Issues
