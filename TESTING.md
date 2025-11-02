# Testing Guide

Comprehensive testing framework for rails-ai using minitest.

## Table of Contents

- [Quick Start](#quick-start)
- [Test Organization](#test-organization)
- [Unit Tests](#unit-tests)
- [Integration Tests](#integration-tests)
- [Integration Test Results](#integration-test-results)
- [Creating Tests](#creating-tests)
- [CI/CD](#cicd)
- [Troubleshooting](#troubleshooting)

## Quick Start

```bash
# Run all unit tests (fast, < 1 second)
rake test:unit

# Run specific integration scenario (individual scenarios only)
rake test:integration:scenario[simple_model_plan]

# Show test coverage report
rake test:report
```

**Important:** Bulk integration test runs (`rake test:integration`) are **disabled** due to cost and time. Integration tests must be run individually.

## Test Organization

Tests are organized by **type** (unit vs integration) following Rails conventions:

```
test/
├── test_helper.rb              # Global test setup
├── support/                    # Shared test infrastructure
│   ├── skill_test_case.rb      # Base class for skill tests
│   ├── agent_integration_test_case.rb  # Base for integration tests
│   └── judge_prompts/          # 4 domain judge evaluation criteria
│       ├── backend_judge_prompt.md
│       ├── frontend_judge_prompt.md
│       ├── tests_judge_prompt.md
│       └── security_judge_prompt.md
├── unit/                       # Fast tests (no external dependencies)
│   ├── skills/                 # Skill structure/syntax validation
│   └── agents/                 # Agent structure/metadata validation
└── integration/                # Slow tests (use Claude CLI)
    └── *_test.rb               # Agent planning scenario tests
```

## Unit Tests

**Purpose:** Validate structure, syntax, and metadata
**Speed:** Fast (seconds)
**Dependencies:** None
**When to run:** On every commit

### Running Unit Tests

```bash
# All unit tests
rake test:unit

# Skills only
rake test:unit:skills

# Agents only
rake test:unit:agents

# Specific file
rake test:file[test/unit/skills/turbo_page_refresh_test.rb]
```

### What Unit Tests Check

**Skills:**
- YAML front matter validity
- Required metadata (name, domain, description)
- Required sections (when-to-use, benefits, standards)
- Code examples are syntactically valid
- Links work and references exist

**Agents:**
- YAML front matter validity
- Required metadata (role, skills_preset)
- Reference SKILLS_REGISTRY.yml correctly
- Consistent naming conventions
- No deprecated references

### Creating New Unit Tests

Generate a skill test template:

```bash
rake test:new_skill[my-skill,frontend]
```

This creates `test/unit/skills/my-skill_test.rb` with standard test structure.

## Integration Tests

**Purpose:** Validate agent planning capabilities
**Speed:** Slow (minutes per scenario)
**Dependencies:** Claude CLI
**When to run:** Manually before releases (no CI automation due to cost/time)

### How Integration Tests Work

1. **Invoke real agent** via Claude CLI with a planning scenario
2. **Agent produces implementation plan** using rails-ai agents
3. **Single LLM call coordinates 4 parallel domain judges** to evaluate the plan:
   - Backend (models, migrations, validations, Rails conventions)
   - Frontend (views, Hotwire, Tailwind, forms, accessibility)
   - Tests (test planning, coverage, Minitest usage)
   - Security (authorization, validation, sensitive data, best practices)
4. **Score against 200-point rubric** (50 points per domain)
5. **Pass threshold:** 140 points (70%)
6. **Track timing data**: Agent duration, judge duration, total duration
7. **Log results** to timestamped directories and update results table

**Architecture Note:** Instead of spawning 4 separate LLM calls with Ruby threads, we use a single Claude CLI call that coordinates parallel evaluation tasks internally. This is more efficient and takes advantage of the LLM's native parallel task execution capabilities.

### Running Integration Tests

**Important:** Integration tests are run **individually only** due to cost and time.

```bash
# Run specific scenario (ONLY way to run integration tests)
rake test:integration:scenario[simple_model_plan]

# Or run directly with ruby
ruby -Itest test/integration/simple_model_plan_test.rb

# Bulk run is DISABLED (will show error with available scenarios)
rake test:integration  # ❌ Disabled - shows error message
```

**Live Logging:**
Integration tests log progress in real-time to `tmp/test/integration/live.log`. The test will print the tail command when it starts:

```
→ Live log: tmp/test/integration/live.log
  Tail with: tail -f tmp/test/integration/live.log
```

In another terminal, run the tail command to watch progress live. This is especially useful for long-running tests.

**When to Run Integration Tests:**
- Before releasing a new version
- After significant changes to agents or skills
- When adding new agent capabilities
- When troubleshooting agent planning issues

**Selective Testing Strategy:**
Choose scenarios that test the areas affected by your changes. No need to run all scenarios on every change.

### Integration Test Output

Results are saved to:

```
tmp/test/integration/
├── JUDGE_LOG.md                      # Chronological log of all runs
└── runs/
    └── YYYYMMDD_HHMMSS_scenario_name/
        ├── agent_output.md           # Agent's implementation plan
        ├── backend_judgment.md       # Backend evaluation
        ├── frontend_judgment.md      # Frontend evaluation
        ├── tests_judgment.md         # Tests evaluation
        ├── security_judgment.md      # Security evaluation
        └── summary.md                # Combined scores and result
```

### Creating New Integration Tests

Create a file `test/integration/my_scenario_test.rb`:

```ruby
require_relative "../support/agent_integration_test_case"

class MyScenarioTest < AgentIntegrationTestCase
  def scenario_name
    "my_scenario"
  end

  def system_prompt
    <<~PROMPT
      You are evaluating the rails-ai architect agent.
      [Add context about test environment...]
    PROMPT
  end

  def agent_prompt
    <<~PROMPT
      @agent-rails-ai:architect

      **IMPORTANT:** This is a planning test. Coordinate with specialist agents
      to create a comprehensive implementation plan.

      ## Scenario
      [Describe the feature to implement...]

      ## Requirements
      - [Requirement 1]
      - [Requirement 2]
    PROMPT
  end

  def expected_pass
    true  # or false if testing failure detection
  end

  # Optional: Add custom assertions
  def test_scenario
    judgment = super

    # Your custom assertions
    assert_match(/class Article < ApplicationRecord/, judgment[:agent_output])
    assert judgment[:domain_scores]["backend"][:score] >= 40

    judgment
  end
end
```

Then run: `rake test:integration:scenario[my_scenario]`

## Integration Test Results

This table is updated each time an integration test runs. It provides a quick reference of test health and performance per feature branch.

| Scenario | Last Run | Agent Time | Judge Time | Total Time | Total Score | Backend | Frontend | Tests | Security | Result |
|----------|----------|------------|------------|------------|-------------|---------|----------|-------|----------|--------|
| simple_model_plan | - | - | - | - | -/200 | -/50 | -/50 | -/50 | -/50 | ⏸️ PENDING |

**Legend:**
- ✅ PASS: Score ≥ 140/200 (70%)
- ❌ FAIL: Score < 140/200
- ⏸️ PENDING: Not yet run on this branch

**Timing Notes:**
- **Agent Time**: Time for agent to produce implementation plan
- **Judge Time**: Time for 4 parallel domain judges to evaluate (single LLM call)
- **Total Time**: End-to-end test duration including setup/teardown

**Note:** Integration tests are run manually due to cost and time. We decide when to run them based on the significance of changes.

## CI/CD

### Local CI

```bash
# Quick check (linting + unit tests)
bin/ci

# Note: INTEGRATION=1 flag shows warning - integration tests must be run individually
INTEGRATION=1 bin/ci  # ⚠️ Shows warning, doesn't run integration tests
```

### GitHub Actions

The CI workflow runs automatically on pull requests:

- ✅ **Fast checks** (always run): Linting + unit tests
- ⏸️ **Integration tests**: Manual only (not automated due to cost/time)

See `.github/workflows/ci.yml` for details.

## Test Coverage Report

```bash
rake test:report
```

Example output:
```
=== Test Coverage Report ===

Skills:
  Total: 45
  Unit Tests: 43 (95.6% coverage)

Agents:
  Total: 7
  Unit Tests: 5
  Integration Tests: 1

Overall:
  Unit Tests: 48
  Integration Tests: 1
  Total Tests: 49

Run tests:
  rake test:unit                    # Fast unit tests
  rake test:integration             # Slow integration tests
  rake test:unit:skills             # Skills unit tests only
  rake test:unit:agents             # Agents unit tests only
  rake test:integration:scenario[X] # Specific scenario
```

## Troubleshooting

### "Cannot load file -- test_helper"

Make sure you run tests with `-Itest` flag:
```bash
ruby -Itest test/unit/skills/my_test.rb
```

Or use rake tasks which handle this automatically.

### "No Claude CLI found"

Integration tests require Claude CLI to be installed and available in your PATH.
See https://docs.anthropic.com/claude-code for installation instructions.

### "Judge prompts not found"

Check prompts exist:
```bash
ls test/support/judge_prompts/
```

Should show: `backend_judge_prompt.md`, `frontend_judge_prompt.md`, `tests_judge_prompt.md`, `security_judge_prompt.md`

### "Test file not found"

After restructuring (Nov 2024), test paths changed:
- Old: `test/agents/integration/foo_test.rb`
- New: `test/integration/foo_test.rb`

Update your commands accordingly.

## Testing Philosophy

### Unit Tests: Fast Feedback

Unit tests run in seconds and catch obvious issues:
- Missing files
- Invalid YAML
- Broken syntax
- Missing required fields

**Run constantly during development.**

### Integration Tests: Quality Assurance

Integration tests validate agent planning quality but are slow and expensive:
- Does the agent plan correctly?
- Are all domains covered (backend, frontend, tests, security)?
- Are best practices followed?
- Is the plan production-ready?

**Run manually before releases or after significant agent/skill changes.**

### Balance

- **During development:** Run unit tests constantly
- **Before commits:** Run full CI (lint + unit)
- **Before releases:** Run integration tests manually
- **Track trends:** Review integration test logs and results table over time

## See Also

- [README.md](README.md) - Project overview
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [Skills Documentation](skills/) - Skills being tested
- [Agents Documentation](agents/) - Agents being tested
- [Rakefile](Rakefile) - Task definitions
