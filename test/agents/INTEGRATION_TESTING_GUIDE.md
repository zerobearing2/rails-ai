# Integration Testing Guide

## Overview

The agent integration testing framework has been rewritten from shell scripts to **minitest-based tests** for better maintainability, CI integration, and developer familiarity.

## What Changed

### Before (Shell Scripts)
```
test/agents/integration/
├── run_test.sh              # Manual test runner
├── run_judge.sh             # Manual judge runner
├── scenarios/
│   └── 01_simple_model_plan.md
└── judge/
    ├── backend_judge_prompt.md
    ├── tests_judge_prompt.md
    ├── security_judge_prompt.md
    ├── load_domain_context.sh
    ├── run_parallel_judges.sh
    └── combine_judgments.sh
```

**Workflow**: Run scripts manually → Copy prompts → Invoke Claude → Parse output

### After (Minitest)
```
test/agents/integration/
├── agent_integration_test_base.rb    # Base class with common logic
├── simple_model_plan_test.rb         # Individual test scenario
├── support/
│   └── judge_prompts/
│       ├── backend_judge_prompt.md
│       ├── tests_judge_prompt.md
│       └── security_judge_prompt.md
└── README.md
```

**Workflow**: `rake test:agents:scenario[simple_model_plan]` → Everything automatic

## Why Minitest?

### Benefits

1. **Standard Ruby Test Framework**
   - Familiar to all Ruby developers
   - Works with standard tooling (rake, CI systems)
   - No learning curve

2. **Better Code Organization**
   - Inheritable base class for common logic
   - Each test is a Ruby class with clear structure
   - Easy to add custom assertions per scenario

3. **CI/CD Integration**
   - Standard rake tasks
   - Easy to run in CI pipelines
   - Can parallelize test execution

4. **Maintainability**
   - Less code duplication
   - Single source of truth for test logic
   - Easier to refactor and improve

5. **Developer Experience**
   - Run with standard `rake` or `ruby` commands
   - Detailed test output with minitest formatting
   - Can use all minitest features (setup, teardown, skip, etc.)

### What We Kept

- **Same judge prompts** (moved to `support/judge_prompts/`)
- **Same scoring system** (150 points, 70% threshold)
- **Same parallel judging** (3 domains evaluated concurrently)
- **Same context loading** (skills/rules per domain)
- **Same logging** (chronological judge log, timestamped runs)

## Quick Start

### Run a Single Test

```bash
rake test:agents:scenario[simple_model_plan]
```

### Run All Integration Tests

```bash
rake test:agents:integration
```

### Run Directly with Ruby

```bash
ruby -Itest test/agents/integration/simple_model_plan_test.rb
```

## Creating New Tests

### 1. Create Test File

```ruby
# test/agents/integration/my_new_scenario_test.rb
require_relative "agent_integration_test_base"

class MyNewScenarioTest < AgentIntegrationTestBase
  def scenario_name
    "my_new_scenario"
  end

  def system_prompt
    <<~PROMPT
      [Context for test environment]
    PROMPT
  end

  def agent_prompt
    <<~PROMPT
      @agent-rails-ai:architect

      [Detailed scenario with requirements]
    PROMPT
  end

  def expected_pass
    true  # or false
  end

  # Optional: Add custom assertions
  def test_scenario
    judgment = super

    # Your assertions
    assert_match(/expected pattern/, judgment[:agent_output])
    assert judgment[:domain_scores]["backend"][:score] >= 40

    judgment
  end
end
```

### 2. Run Your Test

```bash
rake test:agents:scenario[my_new_scenario]
```

### 3. Review Results

```bash
# View summary
cat tmp/test/integration/runs/<latest>/summary.md

# View judge log
cat tmp/test/integration/JUDGE_LOG.md
```

## Base Class Features

The `AgentIntegrationTestBase` class provides:

- **Agent Invocation**: Automatically calls Claude CLI with prompts
- **Parallel Judges**: Spawns 3 threads for concurrent evaluation
- **Context Loading**: Loads relevant skills/rules per domain
- **Score Parsing**: Extracts and aggregates scores
- **Logging**: Saves results to timestamped directories
- **Assertions**: Built-in pass/fail verification

## Architecture

```
Test Class
    ↓
scenario_name, system_prompt, agent_prompt, expected_pass
    ↓
run_agent() → Invoke Claude CLI
    ↓
judge_output(agent_output)
    ↓
run_parallel_judges()
    ├── Backend Judge Thread
    │   ├── Load backend skills/rules
    │   └── Evaluate (score/50)
    ├── Tests Judge Thread
    │   ├── Load testing skills/rules
    │   └── Evaluate (score/50)
    └── Security Judge Thread
        ├── Load security skills/rules
        └── Evaluate (score/50)
    ↓
Aggregate scores (total/150)
    ↓
Determine pass/fail (≥70%)
    ↓
Log results to tmp/ directory
    ↓
Assert matches expected_pass
```

## Test Output

### During Execution

```
Running: SimpleModelPlanTest#test_scenario
  [Invoking agent...]
  [Running judges...]
  [Backend: 45/50, Tests: 42/50, Security: 38/50]
  [Total: 125/150 (83%) - PASS]

1 runs, 6 assertions, 0 failures
```

### After Execution

Results saved to:
```
tmp/test/integration/
├── JUDGE_LOG.md                           # Chronological log
└── runs/
    └── YYYYMMDD_HHMMSS_scenario_name/
        ├── agent_output.md                # Agent response
        ├── backend_judgment.md            # Backend evaluation
        ├── tests_judgment.md              # Tests evaluation
        ├── security_judgment.md           # Security evaluation
        └── summary.md                     # Combined result
```

## Migration Notes

### For Test Authors

**Old way:**
1. Edit `scenarios/XX_name.md`
2. Run `./run_test.sh XX`
3. Copy prompts manually
4. Run `./run_judge.sh`

**New way:**
1. Create `test/agents/integration/name_test.rb`
2. Run `rake test:agents:scenario[name]`
3. Everything else is automatic

### For CI/CD

**Old way:**
```bash
# Not possible - required manual interaction
```

**New way:**
```bash
# Standard rake integration
rake test:agents:integration

# Or specific scenarios
rake test:agents:scenario[simple_model_plan]
```

### For Debugging

**Old way:**
```bash
# View script logs
cat tmp/test/integration/runs/.../agent_plan.md
```

**New way:**
```bash
# Same file structure
cat tmp/test/integration/runs/.../agent_output.md

# Plus standard minitest output
ruby -Itest test/agents/integration/simple_model_plan_test.rb --verbose
```

## Backward Compatibility

### Judge Prompts

Judge prompts remain **unchanged** - just moved to `support/judge_prompts/`:

- `backend_judge_prompt.md`
- `tests_judge_prompt.md`
- `security_judge_prompt.md`

### Scoring System

Scoring remains **identical**:

- 3 domains × 50 points = 150 total
- 70% threshold = 105 points to pass
- 5 criteria per domain (10 points each)

### Output Format

Test artifacts use the **same structure** in `tmp/test/integration/`:

- Same timestamped run directories
- Same `JUDGE_LOG.md` format
- Same individual judgment files

## Troubleshooting

### "Base class not found"

Ensure you're running tests from project root:
```bash
ruby -Itest test/agents/integration/simple_model_plan_test.rb
```

### "Judge prompts not found"

Check prompts exist:
```bash
ls test/agents/integration/support/judge_prompts/
```

Should show: `backend_judge_prompt.md`, `tests_judge_prompt.md`, `security_judge_prompt.md`

### "Claude CLI failed"

Verify Claude CLI is installed and authenticated:
```bash
which claude
claude --version
```

## Next Steps

1. **Run existing test**: `rake test:agents:scenario[simple_model_plan]`
2. **Review output**: `cat tmp/test/integration/runs/<latest>/summary.md`
3. **Create new scenarios** as needed using the test template above
4. **Integrate with CI** by adding to your CI config:
   ```yaml
   - name: Run agent integration tests
     run: rake test:agents:integration
   ```

## See Also

- [Integration Test README](integration/README.md) - Detailed documentation
- [Agent Unit Tests](unit/) - Fast structural validation
- [Skills Documentation](../../skills/) - Skills loaded by judges
- [Rakefile](../../Rakefile) - Test task definitions
