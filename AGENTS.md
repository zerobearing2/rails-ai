# Rails AI Agent System

**Status:** Experimental - Phase 2 of 4
**Architecture:** 6 workflow commands + 2 agents + 11 domain skills

This document is internal documentation for contributors.

## Architecture

Rails-AI uses a **workflow command architecture** where each command loads:

- **Superpowers workflows** - Process layer (brainstorming, TDD, debugging, code review)
- **Rails-AI skills** - Domain expertise (11 Rails-specific skills)
- **Team rules** - 20 conventions from TEAM_RULES.md

### Structure

```text
rails-ai/
├── commands/                  # 6 workflow commands
│   ├── setup.md               # /rails-ai:setup
│   ├── plan.md                # /rails-ai:plan
│   ├── feature.md             # /rails-ai:feature (uses developer agent)
│   ├── refactor.md            # /rails-ai:refactor (uses developer agent)
│   ├── debug.md               # /rails-ai:debug (uses developer agent)
│   └── review.md              # /rails-ai:review (uses reviewer agent)
├── agents/                    # Reusable agent definitions
│   ├── developer.md           # Implementation agent with feature/refactor/fix modes
│   └── reviewer.md            # Multi-role code reviewer agent
├── skills/                    # 11 domain skills
│   ├── setup/
│   ├── controllers/
│   ├── debugging/
│   ├── hotwire/
│   ├── jobs/
│   ├── mailers/
│   ├── models/
│   ├── security/
│   ├── styling/
│   ├── testing/
│   └── ui/                    # Unified frontend (orchestrates design → styling → hotwire)
├── rules/
│   └── TEAM_RULES.md          # 20 team conventions
└── test/
    └── unit/                  # Fast unit tests only
```

## Workflow Commands

**6 workflow commands** mirror how experienced Rails developers work:

| Command | Purpose | Coordinator-Only? |
|---------|---------|-------------------|
| `/rails-ai:setup` | Project configuration, gem setup, validation | No |
| `/rails-ai:plan` | Brainstorm ideas, create implementation plans | No |
| `/rails-ai:feature` | Implement new functionality (uses developer agent) | **Yes** |
| `/rails-ai:refactor` | Improve existing code (uses developer agent) | **Yes** |
| `/rails-ai:debug` | Fix bugs (investigates, then uses developer agent) | **Yes** |
| `/rails-ai:review` | Multi-agent review (uses 3 parallel reviewer agents) | **Yes** |

**Coordinator-only** means the command dispatches agents for implementation/review work, keeping user context clean.

## Agents

**Reusable agent definitions** in `agents/`:

| Agent | Description | Used By |
|-------|-------------|---------|
| `developer.md` | Implementation agent with 3 modes | feature, refactor, debug commands |
| `reviewer.md` | Code reviewer with 3 modes | review command |

### Unified Agent Interface

All agents share the same input/output structure for consistency:

**Input (from coordinator):**
```
Mode: <variant>
Task: <what to do>
Files: <relevant paths>
Context: <additional details>
```

**Output (from agent):**
```yaml
status: success | failed | blocked
mode: <variant used>
summary: "Brief description"
# Agent-specific fields...
issues:  # Only if status is failed or blocked
  - "Description of blocker"
```

### Developer Agent Modes

| Mode | Baseline Required | Behavior Change OK | Use Case |
|------|-------------------|-------------------|----------|
| `feature` | No | Yes | Implementing new features |
| `refactor` | Yes (tests must pass) | No | Improving existing code |
| `fix` | No | Yes | Fixing bugs or review findings |

**What the developer agent does:**
1. Loads relevant skills based on task (skills contain domain rules)
2. Implements with TDD (RED-GREEN-REFACTOR)
3. Runs `bin/ci` to verify
4. Reports completion with structured output

Critical rules (1-4, 17, 18) are embedded in the agent. Domain-specific rules come from skills. This minimizes context usage per task.

### Reviewer Agent Modes

| Mode | Checks | Tags |
|------|--------|------|
| `security-and-rules` | Security vulnerabilities + TEAM_RULES + code quality | `[SECURITY]`, `[RULE #N]`, `[QUALITY]` |
| `implementation` | Model, controller, job, mailer, testing patterns | `[MODELS]`, `[CONTROLLERS]`, `[JOBS]`, `[MAILERS]`, `[TESTING]` |
| `ui` | Views, Turbo, Stimulus, ViewComponent, styling, accessibility | `[UI]`, `[HOTWIRE]`, `[STYLING]` |

The review command dispatches 3 agents in parallel (one per mode) and consolidates findings by severity. This streamlined approach reduces cost by 40% while maintaining comprehensive coverage.

## Skills

**11 domain-organized skills** with YAML front matter:

1. **setup** - Project validation, environment config, credentials, Docker, RuboCop
2. **controllers** - RESTful actions, strong parameters, concerns
3. **debugging** - Rails debugging tools (logs, console, byebug) + Playwright browser debugging
4. **hotwire** - Turbo Drive, Frames, Streams, Morph, Stimulus
5. **jobs** - SolidQueue, SolidCache, SolidCable (NO Redis/Sidekiq)
6. **mailers** - ActionMailer with async delivery
7. **models** - ActiveRecord patterns, validations, associations
8. **security** - XSS, SQL injection, CSRF, file uploads
9. **styling** - Tailwind CSS, DaisyUI
10. **testing** - TDD with Minitest, fixtures, mocking
11. **ui** - Unified frontend workflow: design → styling → hotwire → accessibility (WCAG 2.1 AA)

**Frontend workflow:** The `ui` skill orchestrates the complete frontend flow. When loaded, it sequentially loads `frontend-design:frontend-design` (creative direction), `rails-ai:styling`, and `rails-ai:hotwire` to ensure cohesive UI development.

Each skill includes:

- YAML front matter (name, description)
- When to use
- Patterns and examples
- Anti-patterns to avoid

## Team Rules

**20 conventions** in `rules/TEAM_RULES.md`:

**Critical rules (REJECT violations):**

1. NEVER Sidekiq/Redis → SolidQueue/SolidCache
2. NEVER RSpec → Minitest only
3. NEVER custom routes → RESTful resources
4. NEVER skip TDD → RED-GREEN-REFACTOR
5. NEVER merge without review → Draft PRs
6. NEVER WebMock bypass → Mock all HTTP

See TEAM_RULES.md for all 20 rules with enforcement levels.

## Development

### Testing

```bash
rake test:unit              # All unit tests
rake test:unit:skills       # Skills only
rake test:unit:commands     # Commands only
rake test:unit:agents       # Agents only
rake test:unit:rules        # Rules only
bin/ci                      # Full check (lint + tests)
```

**Unit tests validate:**

- Command structure and content
- Agent structure and roles
- Skill structure and metadata
- Rules consistency and mappings
- No integration tests (removed)

### Adding Skills

1. Create `skills/domain/SKILL.md` with YAML front matter
2. Add unit tests in `test/unit/skills/domain_test.rb`
3. **Update `skills/setup/SKILL.md`** if the new skill affects project verification
4. Update workflow commands if needed
5. Run `bin/ci`

### Adding Rules

1. Add to `rules/TEAM_RULES.md`
2. Update quick lookup index
3. Set enforcement severity
4. Add tests in `test/unit/rules/`
5. **Update `skills/setup/SKILL.md`** if the rule affects project setup verification
6. Update domain skills that enforce the rule
7. Run `bin/ci`

### Modifying Workflow Commands

1. Edit `commands/<workflow>.md`
2. Maintain YAML front matter structure
3. Reference Superpowers workflows correctly
4. For coordinator-only commands (feature, refactor, debug, review):
   - Ensure agent dispatch is mandatory
   - Include context package assembly
   - Include retry logic (for developer agent)
5. Run `bin/ci`

### Updating Domain Skills

1. Edit `skills/domain/SKILL.md`
2. If adding gem requirements → Update `skills/setup/SKILL.md`
3. If adding configuration patterns → Update `skills/setup/SKILL.md`
4. Update tests in `test/unit/skills/domain_test.rb`
5. Run `bin/ci`

## Quality Checks

```bash
rake lint               # All linters
rake lint:ruby          # RuboCop
rake lint:markdown      # Markdown
rake lint:yaml          # YAML front matter
rake lint:fix           # Auto-fix Ruby
```

**Before committing:**

1. Run `bin/ci` - must pass
2. Update documentation if needed
3. Use draft PR for review

## Philosophy

- Workflow commands coordinate all work
- Superpowers = HOW to work (process)
- Rails-AI = WHAT you're building (domain)
- TDD always (RED-GREEN-REFACTOR)
- Minitest, not RSpec
- RESTful actions only (friendly URLs allowed)
- Solid Stack (Rails 8)

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.
