# Rails-AI Testing Framework

Comprehensive testing framework for validating skills and agents using minitest.

## Test Organization

Tests are organized by **type** (unit vs integration) rather than by category (skills vs agents), following Rails conventions:

```
test/
├── test_helper.rb                        # Global test setup and helpers
├── README.md                             # This file
├── INTEGRATION_TESTING_GUIDE.md          # Detailed integration test guide
├── AGENT_INTEGRATION_TESTING.md          # Agent-specific integration guide
├── support/                              # Shared test infrastructure
│   ├── skill_test_case.rb                # Base class for skill tests
│   ├── agent_integration_test_case.rb    # Base class for agent integration tests
│   └── judge_prompts/                    # Judge evaluation criteria
│       ├── backend_judge_prompt.md
│       ├── tests_judge_prompt.md
│       └── security_judge_prompt.md
├── unit/                                 # Fast tests (no external dependencies)
│   ├── skills/                           # Skill validation tests
│   │   ├── turbo_page_refresh_test.rb
│   │   ├── form_objects_test.rb
│   │   └── ...
│   └── agents/                           # Agent structure/validation tests
│       ├── agent_structure_test.rb
│       ├── agent_content_test.rb
│       └── ...
└── integration/                          # Slow tests (use LLMs/Claude CLI)
    ├── skills/                           # LLM judge tests for skills
    │   └── turbo_page_refresh_integration_test.rb
    └── agents/                           # Agent planning/execution tests
        └── simple_model_plan_test.rb
```

## Running Tests

### Quick Start

```bash
# Run all unit tests (fast)
rake test:unit

# Run all integration tests (slow, requires LLMs)
INTEGRATION=1 rake test:integration

# Run everything
rake test:all
```

### Unit Tests (Fast)

Unit tests validate structure, syntax, and metadata without external dependencies:

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

**What unit tests check:**
- File structure and YAML front matter
- Required metadata fields
- Code syntax and examples
- Links and references
- Consistency across files

### Integration Tests (Slow)

Integration tests use LLMs to judge quality and agents to produce plans:

```bash
# All integration tests (requires API keys)
INTEGRATION=1 rake test:integration

# Skills only
INTEGRATION=1 rake test:integration:skills

# Agents only
rake test:integration:agents

# Specific agent scenario
rake test:integration:scenario[simple_model_plan]
```

**What integration tests check:**
- Agent planning capabilities
- Code quality when using skills
- Adherence to best practices
- Security considerations
- Test coverage

**Note:** Agent integration tests use Claude CLI and don't require API keys to be set separately.

### Test Coverage Report

```bash
rake test:report
```

Example output:
```
=== Test Coverage Report ===

Skills:
  Total: 45
  Unit Tests: 43 (95.6% coverage)
  Integration Tests: 1

Agents:
  Total: 7
  Unit Tests: 5
  Integration Tests: 1

Overall:
  Unit Tests: 48
  Integration Tests: 2
  Total Tests: 50

Run tests:
  rake test:unit                    # Fast unit tests
  rake test:integration             # Slow integration tests
  rake test:unit:skills             # Skills unit tests only
  rake test:unit:agents             # Agents unit tests only
  rake test:integration:scenario[X] # Specific agent scenario
```

## Creating New Tests

### New Skill Test

```bash
rake test:new_skill[my-new-skill,frontend]
```

This generates a test template at `test/unit/skills/my-new-skill_test.rb`.

### New Agent Integration Test

Create a file `test/integration/agents/my_scenario_test.rb`:

```ruby
require_relative "../../support/agent_integration_test_case"

class MyScenarioTest < AgentIntegrationTestCase
  def scenario_name
    "my_scenario"
  end

  def system_prompt
    "System context for the test..."
  end

  def agent_prompt
    "@agent-rails-ai:architect\n\n[Your scenario here]"
  end

  def expected_pass
    true  # or false
  end
end
```

## CI/CD Integration

### Local CI

```bash
# Run full CI pipeline (lint + unit tests)
bin/ci

# Run with integration tests
INTEGRATION=1 bin/ci
```

### GitHub Actions

The CI workflow runs automatically on pull requests:

- **Fast checks** (always run): Linting + unit tests
- **Integration tests** (manual only): Requires `workflow_dispatch` trigger

See `.github/workflows/ci.yml` for details.

## Test Types Explained

### Unit Tests

**Purpose:** Validate structure, syntax, and metadata
**Speed:** Fast (seconds)
**Dependencies:** None
**When to use:** Always

**Skills unit tests check:**
- YAML front matter validity
- Required metadata (name, domain, description)
- Required sections (when-to-use, benefits, standards)
- Code examples are syntactically valid
- Links work and references exist

**Agents unit tests check:**
- YAML front matter validity
- Required metadata (role, skills_preset)
- Reference SKILLS_REGISTRY.yml
- Consistent naming conventions
- No deprecated references

### Integration Tests

**Purpose:** Validate quality using LLMs or actual agent execution
**Speed:** Slow (minutes)
**Dependencies:** LLM APIs or Claude CLI
**When to use:** Before major releases, after significant changes

**Skills integration tests:**
- Generate code using the skill
- Have LLM judge code quality
- Check adherence to patterns
- Verify antipattern avoidance

**Agent integration tests:**
- Invoke real agent via Claude CLI
- Agent produces implementation plan
- 3 domain judges evaluate in parallel (backend, tests, security)
- Score against 150-point rubric (70% to pass)
- Log results for tracking improvement

## Writing Good Tests

### Skills

1. **Test the structure** - Ensure YAML and sections exist
2. **Test the examples** - Validate code syntax
3. **Test integration** - Have LLM judge generated code (optional)

### Agents

1. **Test the structure** - Ensure YAML and references are valid
2. **Test planning** - Have agent produce plans and judge quality
3. **Test execution** - Have agent actually implement (future)

## Troubleshooting

### "Cannot load file -- test_helper"

Make sure you run tests with `-Itest` flag:
```bash
ruby -Itest test/unit/skills/my_test.rb
```

Or use rake tasks which handle this automatically.

### "No LLM API keys found"

Integration tests for skills require `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`.
Agent integration tests use Claude CLI and don't require environment variables.

### "Test file not found"

After restructuring, test paths have changed:
- Old: `test/skills/unit/foo_test.rb`
- New: `test/unit/skills/foo_test.rb`

Update your commands accordingly.

## Migration Notes

### October 2024 Restructure

Tests were reorganized from category-based to type-based structure:

**Before:**
```
test/
├── skills/
│   ├── unit/
│   └── integration/
└── agents/
    ├── unit/
    └── integration/
```

**After:**
```
test/
├── unit/
│   ├── skills/
│   └── agents/
└── integration/
    ├── skills/
    └── agents/
```

**Benefits:**
- Clearer separation of fast vs slow tests
- Easier to run all unit or all integration tests
- Follows Rails conventions
- Better CI/CD integration

**Breaking changes:**
- Test file paths changed
- Rake task names changed (old tasks still work for backward compatibility)
- Require paths in test files updated

See commit history for detailed migration steps.

## Philosophy

### Unit Tests: Fast Feedback

Unit tests should run in seconds and catch obvious issues:
- Missing files
- Invalid YAML
- Broken syntax
- Missing required fields

### Integration Tests: Quality Assurance

Integration tests should validate quality but run infrequently:
- Does the skill produce good code?
- Does the agent plan correctly?
- Are best practices followed?
- Is the output production-ready?

### Balance

- **During development:** Run unit tests constantly
- **Before commits:** Run full CI (lint + unit)
- **Before releases:** Run integration tests
- **Track trends:** Review integration test logs over time

## See Also

- [Integration Testing Guide](INTEGRATION_TESTING_GUIDE.md) - Detailed guide for agent integration tests
- [Agent Integration Testing](AGENT_INTEGRATION_TESTING.md) - Agent-specific integration test details
- [Skills Documentation](../skills/) - Skills being tested
- [Agents Documentation](../agents/) - Agents being tested
- [Rakefile](../Rakefile) - Task definitions
- [CI Script](../bin/ci) - Local CI pipeline
