# Agent Integration Tests

Minitest-based integration tests for evaluating rails-ai agent planning capabilities. Tests invoke real agents via Claude CLI and use parallel LLM judges to evaluate output quality.

## Overview

This testing framework:
1. **Invokes real agents** via Claude CLI to produce implementation plans
2. **Judges plans in parallel** using 3 domain-specific LLM judges (backend, tests, security)
3. **Auto-grades** with clear pass/fail criteria (70% threshold)
4. **Logs all evaluations** for tracking improvement over time
5. **Saves detailed artifacts** to timestamped directories

## Quick Start

### Prerequisites

- `claude` CLI installed and authenticated
- `rails-ai` configured and up to date
- Ruby with minitest gem

### Run a Test

```bash
# Run specific scenario
rake test:agents:scenario[simple_model_plan]

# Or directly with ruby
ruby -Itest test/agents/integration/simple_model_plan_test.rb

# Run all integration tests (long-running)
rake test:agents:integration
```

## Architecture

### Test Structure

```
test/agents/integration/
├── agent_integration_test_base.rb       # Base class with common logic
├── simple_model_plan_test.rb            # Individual test scenario
├── support/
│   └── judge_prompts/
│       ├── backend_judge_prompt.md      # Backend evaluation criteria
│       ├── tests_judge_prompt.md        # Tests evaluation criteria
│       └── security_judge_prompt.md     # Security evaluation criteria
└── README.md                            # This file
```

### Scoring System

- **Total Score**: 150 points (3 domains × 50 points each)
- **Pass Threshold**: 105 points (70%)
- **Domains**:
  - **Backend** (50 pts): Model design, migrations, validations, business logic, Rails conventions
  - **Tests** (50 pts): Coverage, quality, organization, edge cases, maintainability
  - **Security** (50 pts): Authorization, mass assignment, validation, sensitive data, best practices

Each domain has 5 criteria scored 0-10 points each.

### Test Flow

```
1. Test loads scenario (system prompt + agent prompt)
2. Invokes Claude CLI with prompts
3. Agent produces implementation plan
4. Spawns 3 parallel judge threads
5. Each judge loads relevant skills/rules and evaluates
6. Scores are aggregated
7. Pass/fail determined (≥70% = pass)
8. Results logged to tmp/ directory
```

## Creating New Tests

### 1. Create Test File

```ruby
# test/agents/integration/my_scenario_test.rb
require_relative "agent_integration_test_base"

class MyScenarioTest < AgentIntegrationTestBase
  def scenario_name
    "my_scenario"
  end

  def system_prompt
    <<~PROMPT
      You are evaluating the rails-ai architect agent in a testing scenario.
      The agent should plan implementations without executing code.
    PROMPT
  end

  def agent_prompt
    <<~PROMPT
      @agent-rails-ai:architect

      **IMPORTANT:** This is a planning test. Coordinate with specialist agents
      to produce a detailed implementation plan.

      ## Current Application State
      [existing code context]

      ## Task
      [clear requirements]

      ## Instructions
      Provide detailed plan with:
      1. Architecture overview
      2. Complete code for all files
      3. Rationale for decisions
    PROMPT
  end

  def expected_pass
    true  # Set false to test failure cases
  end

  # Optional: Add custom assertions beyond standard scoring
  def test_scenario
    judgment = super  # Runs base test + judging

    # Add your own assertions
    assert_match(/class MyModel/, judgment[:agent_output])
    assert judgment[:domain_scores]["backend"][:score] >= 40

    judgment
  end
end
```

### 2. Run Your Test

```bash
rake test:agents:scenario[my_scenario]
```

### 3. Review Results

```bash
# View summary
ls -t tmp/test/integration/runs/*my_scenario* | head -1 | xargs -I {} cat {}/summary.md

# View judge log
cat tmp/test/integration/JUDGE_LOG.md
```

## Test Output

### During Test Run

```
Running integration test: test/agents/integration/simple_model_plan_test.rb
Run options: --seed 12345

# Running:

SimpleModelPlanTest#test_scenario
  [Invoking Claude CLI with agent prompt...]
  [Agent producing plan...]
  [Running 3 parallel domain judges...]
  [Backend: 45/50, Tests: 42/50, Security: 38/50]
  [Total: 125/150 (83%) - PASS]

Finished in 45.23s, 0.0221 runs/s, 0.1326 assertions/s.

1 runs, 6 assertions, 0 failures, 0 errors, 0 skips

✓ Results logged to: tmp/test/integration/JUDGE_LOG.md
```

### After Test Run

Results saved to timestamped directories:

```
tmp/test/integration/
├── JUDGE_LOG.md                                    # Chronological log of all runs
└── runs/
    └── 20251102_123456_my_scenario/
        ├── agent_output.md                         # Full agent response
        ├── backend_judgment.md                     # Backend evaluation
        ├── tests_judgment.md                       # Tests evaluation
        ├── security_judgment.md                    # Security evaluation
        └── summary.md                              # Combined scores & result
```

### Example Summary Output

```markdown
# Integration Test Summary: simple_model_plan

**Timestamp**: 2025-11-02 12:34:56
**Git SHA**: abc123
**Git Branch**: main

## Overall Result

**PASS ✓**

**Total Score**: 125/150 (83%)
**Threshold**: 105/150 (70%)

## Domain Scores

- **Backend**: 45/50
- **Tests**: 42/50
- **Security**: 38/50

## Detailed Judgments

See individual files:
- [backend_judgment.md](./backend_judgment.md)
- [tests_judgment.md](./tests_judgment.md)
- [security_judgment.md](./security_judgment.md)

## Agent Output

See [agent_output.md](./agent_output.md) for full agent response.
```

## Base Class Features

The `AgentIntegrationTestBase` class provides:

### Automatic Agent Invocation
- Constructs Claude CLI commands
- Passes system and agent prompts
- Captures agent output

### Parallel Domain Judges
- Spawns 3 threads (one per domain)
- Each judge loads relevant skills/rules
- Judges evaluate concurrently for speed

### Context Loading
Automatically loads relevant content for each domain:

- **Backend**: Models, migrations, associations, validations, ActiveRecord patterns
- **Tests**: Testing, minitest, fixtures, mocking, coverage patterns
- **Security**: Security, authorization, authentication, CSRF, XSS, SQL injection

### Score Parsing
- Extracts scores from judge outputs
- Aggregates across domains
- Determines pass/fail against threshold

### Logging
- Appends to chronological judge log
- Saves detailed outputs to timestamped directories
- Includes git SHA and branch for tracking

### Built-in Assertions
- Verifies pass/fail matches expectation
- Can be extended with custom assertions in subclasses

## Judge Prompts

Located in `support/judge_prompts/`, each domain has a markdown file defining:

- 5 evaluation criteria (10 points each)
- Specific patterns to look for
- Antipatterns to watch for
- Output format requirements

### Example Criteria (Backend)

1. **Model Design** (10 pts): Proper associations, naming, structure
2. **Migration Quality** (10 pts): Indexes, constraints, reversibility
3. **Validations** (10 pts): Appropriate validations, custom validators
4. **Business Logic** (10 pts): Scopes, methods, concerns usage
5. **Rails Conventions** (10 pts): Idiomatic Rails, best practices

## Viewing Results

### List Recent Runs
```bash
ls -lt tmp/test/integration/runs/ | head -10
```

### View Specific Run
```bash
# Replace with your timestamp and scenario
cat tmp/test/integration/runs/20251102_123456_simple_model_plan/summary.md
```

### View Judge Reasoning
```bash
cat tmp/test/integration/runs/20251102_123456_simple_model_plan/backend_judgment.md
```

### View Full Judge Log
```bash
cat tmp/test/integration/JUDGE_LOG.md
```

### Search Log for Patterns
```bash
# Find all failing tests
grep -A 5 "FAIL" tmp/test/integration/JUDGE_LOG.md

# Find tests with low backend scores
grep -A 2 "Backend:" tmp/test/integration/JUDGE_LOG.md | grep -B 1 "[12][0-9]/50"
```

## Configuration

### Adjust Pass Threshold

Edit `agent_integration_test_base.rb`:

```ruby
PASS_THRESHOLD = (MAX_TOTAL_SCORE * 0.7).to_i  # Currently 105/150 (70%)
```

### Customize Domain Context

Override `load_domain_context` in base class to change which skills/rules are loaded per domain.

### Modify Judge Criteria

Edit markdown files in `support/judge_prompts/` to adjust evaluation criteria.

## Troubleshooting

### "Claude CLI failed"
```bash
# Check Claude CLI is installed
which claude

# Verify authentication
claude --version
```

### "Judge prompt not found"
```bash
# Ensure judge prompts exist
ls test/agents/integration/support/judge_prompts/
# Should show: backend_judge_prompt.md, tests_judge_prompt.md, security_judge_prompt.md
```

### "Score parsing failed"
- Judge output must match format: `## Domain Total: XX/50`
- Check judge prompt enforces this format
- View raw judge output in `*_judgment.md` files

### Tests Timeout
- Agent planning can take 30-90 seconds
- Judge evaluation adds another 30-60 seconds per domain (parallel)
- Total test time: ~2-3 minutes per scenario

## Comparison to Shell Scripts

### Previous Approach (Shell Scripts)
- ❌ Manual test execution
- ❌ No standard test runner
- ❌ Hard to integrate with CI
- ❌ No assertions beyond pass/fail
- ✅ Simple to understand

### Current Approach (Minitest)
- ✅ Standard Ruby test framework
- ✅ Rake integration
- ✅ Easy CI/CD integration
- ✅ Custom assertions per test
- ✅ Inheritable base class
- ✅ Familiar to Ruby developers

## Tips

### Fast Iteration During Development
```bash
# Run just one test repeatedly
watch -n 60 'rake test:agents:scenario[simple_model_plan]'
```

### Compare Results Over Time
```bash
# Extract scores from judge log
grep "Total:" tmp/test/integration/JUDGE_LOG.md

# Track improvement for specific scenario
grep -A 3 "simple_model_plan" tmp/test/integration/JUDGE_LOG.md
```

### Debug Test Failures
```bash
# View agent output
find tmp/test/integration/runs -name "agent_output.md" -exec head -20 {} \;

# View judge critiques
find tmp/test/integration/runs -name "*_judgment.md" -exec grep -A 5 "Critical Issues" {} \;
```

## Future Enhancements

- [ ] Add mocking support for faster development iteration
- [ ] Implement CI mode (subset of fast, critical scenarios)
- [ ] Add performance tracking dashboard
- [ ] Create test generator wizard
- [ ] Add HTML report generation
- [ ] Implement judge agreement metrics (cross-validate with multiple LLMs)
- [ ] Add support for testing full agent execution (not just planning)
- [ ] Parallel test execution (multiple scenarios simultaneously)

## See Also

- [Agent Unit Tests](../unit/) - Fast structural validation
- [Skills Documentation](../../../skills/) - Skills loaded by judges
- [Rules Documentation](../../../rules/) - Rules loaded by judges
- [Agent Documentation](../../../agents/) - Agent system architecture
