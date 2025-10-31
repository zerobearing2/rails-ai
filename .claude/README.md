# Claude Code Settings

This directory contains Claude Code configuration for the rails-ai project.

## Files

- **`settings.json`** - Shared project settings (committed to repo)
  - Pre-approved bash commands for common operations
  - Environment variables for testing
  - Sandbox configuration

- **`settings.local.json`** - Personal settings (gitignored, not committed)
  - Your personal overrides and preferences
  - API keys and local configurations

## Settings Hierarchy

Claude Code merges settings in this order (most specific wins):

1. Enterprise policies (system administrator)
2. Command-line flags
3. **Local** (`.claude/settings.local.json`) - your personal overrides
4. **Project** (`.claude/settings.json`) - shared with team ✅
5. User (`~/.claude/settings.json`) - your global settings

## Pre-approved Commands

The project `settings.json` pre-approves these bash commands so they run without confirmation:

### Git (Read-only)
- `git status`, `git log`, `git diff`, `git show`
- `git branch`, `git remote`, `git ls-files`

### Testing
- All `rake test:*` commands
- All unit and integration test runners
- `bin/ci` (our standard CI checks)

### Linting
- All `rake lint*` commands
- `rubocop`, `mdl` (markdown linter)

### Ruby/Bundler
- `bundle exec`, `bundle install`, `ruby`

### File Operations
- Safe read operations: `cat`, `ls`, `tree`, `find`, `grep`, `wc`, `head`, `tail`

### GitHub CLI (Read-only)
- `gh pr list/view`, `gh issue list/view`, `gh repo view`

## Commands that Require Approval

These commands will **prompt for confirmation** before running:

### Git (Write operations)
- `git commit`, `git push`, `git pull`
- `git checkout`, `git merge`, `git rebase`

### GitHub (Write operations)
- `gh pr create/merge`
- `gh issue create`

### File Modifications
- `rm`, `mv`, `cp -r`

## Denied Commands

These commands are **blocked** and require explicit override:

- `git push --force`, `git reset --hard`, `git clean -fd`
- `rm -rf`, `sudo`, `chmod`, `chown`

## Environment Variables

Default environment for all sessions:

```json
{
  "RAILS_ENV": "test",
  "RACK_ENV": "test"
}
```

## Sandbox

Bash commands run in sandbox mode for safety:

```json
{
  "sandbox": {
    "enabled": true
  }
}
```

## Customization

To override these settings for your local environment:

1. Create `.claude/settings.local.json` (it's gitignored)
2. Add your personal preferences:

```json
{
  "permissions": {
    "allow": [
      "Bash(your:custom:command)"
    ]
  },
  "env": {
    "YOUR_API_KEY": "your-key-here"
  }
}
```

Local settings merge with and override project settings.

## Documentation

- [Claude Code Settings Docs](https://docs.claude.com/en/docs/claude-code/settings)
- [Permissions System](https://docs.claude.com/en/docs/claude-code/permissions)

## Contributing

When adding new rake tasks or common commands to the project, consider adding them to the `allow` list in `settings.json` so contributors don't need to approve them repeatedly.
