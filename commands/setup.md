---
description: Project configuration, gem setup, and validation
---

# Rails Setup Workflow

## Purpose

Use this workflow when:
- Setting up a new Rails project
- Configuring gems and dependencies
- Validating project structure against TEAM_RULES
- Setting up environment, credentials, Docker, or RuboCop

## Superpowers Workflows

This workflow uses:
- `superpowers:verification-before-completion` — verify setup works before claiming done

## Rails-AI Skills

Load based on setup scope:
- `rails-ai:project-setup` — always load for setup tasks

## Process

### Step 1: Understand the Setup Request

Clarify what needs to be configured:
- New project bootstrap?
- Adding/configuring a gem?
- Environment configuration?
- Docker setup?
- RuboCop configuration?
- Credentials management?

### Step 2: Load Skills

```
Use Skill tool to load:
- rails-ai:project-setup
```

### Step 3: Read Current State

- Check existing configuration files
- Review Gemfile for current dependencies
- Check for existing Docker/credentials setup
- Understand what's already in place

### Step 4: Execute Setup

Follow the patterns in `rails-ai:project-setup`:
- Use Rails 8+ defaults (SolidQueue, SolidCache, SolidCable)
- Follow TEAM_RULES.md conventions
- Configure according to project standards

### Step 5: Validate Setup

Run validation commands:
```bash
bundle install
bin/rails db:prepare  # if database changes
bin/ci                # full CI pipeline
```

### Step 6: Completion Checklist

Before claiming setup is complete:

- [ ] `bin/ci` passes (all linters and tests)
- [ ] Use `superpowers:verification-before-completion` — evidence before claims

**No CHANGELOG entry required for setup tasks.**

---

**Now handle the setup request: {{ARGS}}**
