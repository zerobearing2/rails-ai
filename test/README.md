# Skill Testing with Minitest

Comprehensive testing framework for validating that skills produce expected outcomes when used by agents.

## Test Structure

```
test/
├── test_helper.rb                    # Setup and helpers
├── skills/
│   ├── skill_test_case.rb           # Base class for skill tests
│   ├── unit/                         # Fast validation tests
│   │   ├── turbo_page_refresh_test.rb
│   │   ├── form_objects_test.rb
│   │   └── ...
│   └── integration/                  # LLM judge tests (slow)
│       ├── turbo_page_refresh_integration_test.rb
│       └── ...
```

## Running Tests

### All Unit Tests (Fast - No LLM Calls)

```bash
# Run all unit tests
ruby -Itest test/skills/unit/*_test.rb

# Or use rake
rake test:skills:unit
```

### Single Skill Unit Test

```bash
ruby -Itest test/skills/unit/turbo_page_refresh_test.rb
```

### All Integration Tests (Slow - Uses LLMs)

```bash
# Requires INTEGRATION=1 flag
INTEGRATION=1 ruby -Itest test/skills/integration/*_test.rb

# Or use rake
rake test:skills:integration
```

### Cross-Validation Tests (Multiple LLMs)

```bash
# Requires both INTEGRATION=1 and CROSS_VALIDATE=1
INTEGRATION=1 CROSS_VALIDATE=1 ruby -Itest test/skills/integration/turbo_page_refresh_integration_test.rb
```

### All Tests

```bash
rake test:skills
```

## Test Types

### Unit Tests

**Purpose:** Fast validation of skill structure and critical patterns
**Speed:** < 1 second per skill
**When:** Every skill change

**What they test:**
- ✅ Skill file exists
- ✅ Has valid YAML front matter
- ✅ Has required metadata (name, domain, version)
- ✅ Has required sections (when-to-use, benefits, standards, etc.)
- ✅ Has documented patterns
- ✅ Has code examples
- ✅ Has good (✅) and bad (❌) examples
- ✅ Documents key patterns (e.g., `data-turbo-refresh-method`)
- ✅ Shows antipatterns
- ✅ Links related skills
- ✅ Includes testing examples

**Example:**

```ruby
class TurboPageRefreshTest < SkillTestCase
  self.skill_domain = "frontend"
  self.skill_name = "turbo-page-refresh"

  def test_documents_morph_method
    assert_pattern_present(
      skill_content,
      /data-turbo-refresh-method="morph"/,
      "Should document data-turbo-refresh-method attribute"
    )
  end
end
```

### Integration Tests

**Purpose:** Validate that agents apply skills correctly using LLM-as-judge
**Speed:** ~2-5 seconds per test case (LLM API calls)
**When:** Before commits, weekly, or on major changes

**What they test:**
- ✅ Generated code has expected patterns
- ✅ Generated code avoids forbidden patterns
- ✅ LLM judge rates code quality >= 4.0/5.0
- ✅ Multiple LLMs agree on pass/fail (cross-validation)
- ✅ Agent avoids documented antipatterns

**Example:**

```ruby
class TurboPageRefreshIntegrationTest < SkillTestCase
  def test_agent_can_enable_page_refresh
    skip_unless_integration

    scenario = "Add Turbo page refresh with morphing"
    generated_code = call_agent_with_skill(scenario)

    # Fast pattern checks
    assert_pattern_present generated_code, /data-turbo-refresh-method="morph"/

    # Comprehensive LLM evaluation
    result = judge_with_llm(
      provider: :openai,
      prompt: create_judge_prompt("turbo-page-refresh", scenario, generated_code)
    )

    assert result["pass"], "LLM judge should pass the generated code"
    assert result["overall_score"] >= 4.0
  end
end
```

## LLM Judge Evaluation

### How It Works

1. **Scenario** - Give agent a task (e.g., "Add page refresh with morphing")
2. **Generate** - Agent produces code using the skill
3. **Judge** - LLM evaluates the code on multiple criteria:
   - Correct pattern usage (1-5)
   - Rails 8.1+ conventions (1-5)
   - Avoids antipatterns (1-5)
   - Code quality (1-5)
4. **Result** - Pass/Fail + scores + specific issues/suggestions

### Judge Response Format

```json
{
  "overall_score": 4.5,
  "pass": true,
  "scores": {
    "correct_pattern": 5,
    "rails_conventions": 4,
    "avoids_antipatterns": 5,
    "code_quality": 4
  },
  "issues": ["Minor formatting inconsistency"],
  "suggestions": ["Consider adding comment explaining morph behavior"]
}
```

### Cross-Validation

Use multiple LLMs to reduce bias:

```ruby
results = cross_validate(scenario, generated_code, "turbo-page-refresh")
# => {
#   openai: { overall_score: 4.5, pass: true, ... },
#   anthropic: { overall_score: 4.3, pass: true, ... },
#   average_score: 4.4,
#   agreement: true
# }
```

## Configuration

### Environment Variables

```bash
# Enable integration tests (LLM calls)
export INTEGRATION=1

# Enable cross-validation (multiple LLMs)
export CROSS_VALIDATE=1

# LLM API keys (when not using mock)
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
```

### Test Configuration

Edit `test/test_helper.rb` to configure:

- Default LLM provider
- Mock vs real LLM calls
- Judge prompt templates
- Pass/fail thresholds

## Writing New Tests

### 1. Create Unit Test

```ruby
# test/skills/unit/my_skill_test.rb
require_relative "../skill_test_case"

class MySkillTest < SkillTestCase
  self.skill_domain = "backend"  # or frontend, testing, security, config
  self.skill_name = "my-skill"

  def test_skill_file_exists
    assert skill_file_exists?("backend", "my-skill")
  end

  def test_has_required_metadata
    assert_skill_has_required_metadata
  end

  def test_documents_key_pattern
    assert_pattern_present(
      skill_content,
      /MyKeyPattern/,
      "Should document the key pattern"
    )
  end

  # Add more tests...
end
```

### 2. Create Integration Test (Optional)

```ruby
# test/skills/integration/my_skill_integration_test.rb
require_relative "../skill_test_case"

class MySkillIntegrationTest < SkillTestCase
  self.skill_domain = "backend"
  self.skill_name = "my-skill"

  def test_agent_applies_pattern_correctly
    skip_unless_integration

    scenario = "Apply my skill pattern"
    generated_code = call_agent_with_skill(scenario)

    assert_pattern_present generated_code, /expected_pattern/
    assert_pattern_absent generated_code, /forbidden_pattern/

    result = judge_with_llm(
      provider: :openai,
      prompt: create_judge_prompt("my-skill", scenario, generated_code)
    )

    assert result["pass"]
  end
end
```

### 3. Run Tests

```bash
# Unit test only
ruby -Itest test/skills/unit/my_skill_test.rb

# Integration test
INTEGRATION=1 ruby -Itest test/skills/integration/my_skill_integration_test.rb
```

## Helpers Available

### SkillTestHelpers

- `load_skill(domain, skill_name)` - Load skill file content
- `parse_skill_yaml(content)` - Extract YAML front matter
- `extract_patterns(content, name)` - Get specific pattern
- `extract_code_examples(content)` - Get all code blocks
- `skill_file_exists?(domain, name)` - Check file exists

### Assertions

- `assert_skill_has_yaml_front_matter`
- `assert_skill_has_required_metadata`
- `assert_skill_has_section(name)`
- `assert_skill_has_pattern(name)`
- `assert_code_examples_are_valid`
- `assert_has_good_and_bad_examples`
- `assert_pattern_present(code, pattern, message)`
- `assert_pattern_absent(code, pattern, message)`

### LLMJudgeHelpers

- `create_judge_prompt(skill, scenario, code)` - Build judge prompt
- `judge_with_llm(provider:, prompt:)` - Get LLM evaluation
- `cross_validate(scenario, code, skill)` - Multi-LLM validation

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Skill Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.3
      - name: Run unit tests
        run: rake test:skills:unit

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.3
      - name: Run integration tests
        env:
          INTEGRATION: 1
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: rake test:skills:integration
```

## Troubleshooting

### Tests fail with "cannot load such file"

Ensure you run with `-Itest` flag:

```bash
ruby -Itest test/skills/unit/turbo_page_refresh_test.rb
```

### Integration tests are skipped

Set `INTEGRATION=1`:

```bash
INTEGRATION=1 ruby -Itest test/skills/integration/turbo_page_refresh_integration_test.rb
```

### LLM API errors

Check API keys are set and valid:

```bash
echo $OPENAI_API_KEY
echo $ANTHROPIC_API_KEY
```

Use mock provider for testing without API calls:

```ruby
result = judge_with_llm(provider: :mock, prompt: prompt)
```

## Best Practices

1. **Write unit tests first** - Fast feedback on skill structure
2. **Add integration tests for critical skills** - Security, config, core patterns
3. **Use cross-validation sparingly** - Costs 2x API calls
4. **Mock in development** - Use real LLMs in CI/CD only
5. **Update tests with skills** - Keep tests in sync with skill changes
6. **Document expected patterns** - Make tests readable

## Metrics

Track over time:

- **Test coverage** - % of skills with tests
- **Pass rate** - % of tests passing
- **Average judge score** - Quality of generated code
- **Agreement rate** - How often multiple LLMs agree

Example:

```bash
# Run all tests and generate report
rake test:skills:report

# => Skill Test Report
#    Coverage: 33/33 skills (100%)
#    Unit Tests: 165/165 passing (100%)
#    Integration Tests: 24/33 passing (73%)
#    Average Judge Score: 4.3/5.0
#    Cross-Validation Agreement: 95%
```

---

## Next Steps

1. **Add more unit tests** - Cover all 33 skills
2. **Implement real LLM clients** - Replace mock with actual APIs
3. **Add integration tests** - Start with high-priority skills
4. **Automate in CI/CD** - Run on every commit
5. **Track metrics** - Monitor quality over time
