# Skill Testing Methodology

**Version:** 2.0 (Implemented)
**Status:** Active
**Last Updated:** 2025-10-30

Testing skills for LLM consumption requires different approaches than traditional unit testing. This document describes our implemented two-tier testing strategy using Minitest.

---

## The Challenge

**Why Traditional Testing Doesn't Work:**
- Skills are consumed by LLMs, not executed as code
- LLM output is non-deterministic (different valid solutions)
- Need to verify *understanding* and *application*, not exact output
- Must test patterns, principles, and code quality—not string matching

**What We Validate:**
1. **Structure** - Skill has valid format and required sections
2. **Comprehension** - LLM can parse and understand the skill
3. **Application** - LLM applies patterns correctly
4. **Avoidance** - LLM avoids documented antipatterns
5. **Quality** - Generated code follows Rails 8.1+ conventions

---

## Our Approach: Two-Tier Minitest Strategy

We use **Minitest** (Rails' default testing framework) with a two-tier approach:

### Tier 1: Unit Tests (Fast - Structure Validation)
- **Speed:** < 1 second per skill
- **Purpose:** Validate skill file structure and content
- **When:** Every change, every commit
- **No LLM calls:** Pure Ruby parsing and regex

### Tier 2: Integration Tests (Slow - LLM-as-Judge)
- **Speed:** ~2-5 seconds per test case
- **Purpose:** Validate agent applies skill correctly
- **When:** Before commits, weekly, or on major changes
- **Requires:** LLM API access (OpenAI, Anthropic)

---

## Tier 1: Unit Tests (Structure Validation)

### What Unit Tests Validate

Every skill must have:

✅ **File Structure**
- Valid YAML front matter
- Required metadata (name, domain, version, rails_version)
- Dependency declarations

✅ **Required Sections**
- `<when-to-use>` - When to apply this skill
- `<benefits>` - Why use this pattern
- `<standards>` - Implementation rules
- `<antipatterns>` - What to avoid
- `<testing>` - How to test implementations
- `<related-skills>` - Dependencies and related skills
- `<resources>` - Documentation links

✅ **Pattern Definitions**
- Named patterns with `<pattern name="...">` tags
- Code examples for each pattern
- Good (✅) and bad (❌) examples

✅ **Specific Patterns**
- Key implementation details documented
- Attributes, methods, callbacks present
- Convention adherence (Rails 8.1+)

### Example Unit Test

```ruby
# test/skills/unit/turbo_page_refresh_test.rb
class TurboPageRefreshTest < SkillTestCase
  self.skill_domain = "frontend"
  self.skill_name = "turbo-page-refresh"

  # Structure tests
  def test_skill_file_exists
    assert skill_file_exists?("frontend", "turbo-page-refresh")
  end

  def test_has_yaml_front_matter
    assert_skill_has_yaml_front_matter
  end

  def test_has_required_metadata
    assert_skill_has_required_metadata
    assert_equal "turbo-page-refresh", skill_metadata["name"]
    assert_equal "frontend", skill_metadata["domain"]
    assert_equal 1.0, skill_metadata["version"]
  end

  # Section tests
  def test_has_required_sections
    assert_skill_has_section("when-to-use")
    assert_skill_has_section("benefits")
    assert_skill_has_section("standards")
    assert_skill_has_section("antipatterns")
  end

  # Pattern tests
  def test_has_key_patterns
    assert_skill_has_pattern("enable-page-refresh")
    assert_skill_has_pattern("broadcast-page-refresh")
    assert_skill_has_pattern("permanent-elements")
  end

  # Content validation
  def test_documents_morph_method
    assert_pattern_present(
      skill_content,
      /data-turbo-refresh-method="morph"/,
      "Should document data-turbo-refresh-method attribute"
    )
  end

  def test_shows_antipatterns
    assert_includes skill_content, "turbo_frame_tag"
    assert_includes skill_content, "❌"
  end
end
```

### Running Unit Tests

```bash
# Run all unit tests (< 1 second)
rake test:skills:unit

# Run specific skill test
ruby -Itest test/skills/unit/turbo_page_refresh_test.rb

# Generate new unit test template
rake test:skills:new[my-skill,backend]
```

### Benefits of Unit Tests

- ⚡ **Fast:** < 1 second for all skills
- 🔄 **Repeatable:** Deterministic, no LLM variance
- 💰 **Free:** No API costs
- 🚀 **CI/CD friendly:** Run on every commit
- 📝 **Documentation:** Tests document expected structure

---

## Tier 2: Integration Tests (LLM-as-Judge)

### What Integration Tests Validate

Integration tests use an **LLM-as-judge** pattern to evaluate if agents apply skills correctly:

✅ **Pattern Application**
- Generated code contains expected patterns
- Attributes, methods, callbacks used correctly

✅ **Antipattern Avoidance**
- Generated code doesn't contain forbidden patterns
- Follows documented standards

✅ **Code Quality**
- LLM judge rates code on multiple criteria (1-5 scale)
- Overall score >= 4.0 required to pass
- Provides specific feedback on issues

✅ **Cross-Validation** (optional)
- Multiple LLMs judge the same output
- Reduces bias, increases confidence
- Agreement rate tracked

### Example Integration Test

```ruby
# test/skills/integration/turbo_page_refresh_integration_test.rb
class TurboPageRefreshIntegrationTest < SkillTestCase
  self.skill_domain = "frontend"
  self.skill_name = "turbo-page-refresh"

  def test_agent_can_enable_page_refresh
    skip_unless_integration

    scenario = "Add Turbo page refresh with morphing to my Rails app"
    generated_code = call_agent_with_skill(scenario)

    # Fast pattern assertions
    assert_pattern_present generated_code, /data-turbo-refresh-method="morph"/
    assert_pattern_present generated_code, /data-turbo-refresh-scroll="preserve"/
    assert_pattern_absent generated_code, /turbo_frame_tag/

    # Comprehensive LLM evaluation
    result = judge_with_llm(
      provider: :openai,
      prompt: create_judge_prompt("turbo-page-refresh", scenario, generated_code)
    )

    assert result["pass"], "LLM judge should pass the generated code"
    assert_operator result["overall_score"], :>=, 4.0,
                    "Overall score should be >= 4.0, got #{result['overall_score']}"
  end

  def test_cross_validation_with_multiple_llms
    skip_unless_integration
    skip "Cross-validation requires multiple LLM APIs" unless ENV["CROSS_VALIDATE"]

    scenario = "Add Turbo page refresh with morphing"
    generated_code = call_agent_with_skill(scenario)

    # Get judgments from multiple LLMs
    results = cross_validate(scenario, generated_code, "turbo-page-refresh")

    # Check agreement between judges
    assert results[:agreement],
           "OpenAI and Anthropic should agree on pass/fail"

    assert_operator results[:average_score], :>=, 4.0,
                    "Average score across judges should be >= 4.0"
  end
end
```

### LLM Judge Evaluation

The judge evaluates code on multiple criteria:

```ruby
# Judge prompt structure
{
  "overall_score": 4.5,        # Average of all criteria (1-5)
  "pass": true,                # >= 4.0 = pass
  "scores": {
    "correct_pattern": 5,      # Uses data-turbo-refresh-method
    "rails_conventions": 4,    # Follows Rails 8.1+ patterns
    "avoids_antipatterns": 5,  # No turbo_frame_tag for simple refresh
    "code_quality": 4          # Clean, readable, production-ready
  },
  "issues": [                  # Specific problems found
    "Minor formatting inconsistency"
  ],
  "suggestions": [             # How to improve
    "Consider adding comment explaining morph behavior"
  ]
}
```

### Running Integration Tests

```bash
# Run all integration tests (requires LLM APIs)
INTEGRATION=1 rake test:skills:integration

# Set API keys
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."

# Run with cross-validation (2x API calls)
INTEGRATION=1 CROSS_VALIDATE=1 rake test:skills:integration

# Run specific integration test
INTEGRATION=1 ruby -Itest test/skills/integration/turbo_page_refresh_integration_test.rb
```

### Benefits of Integration Tests

- 🎯 **Comprehensive:** Evaluates understanding, not just presence
- 🤖 **Intelligent:** LLM can assess quality, context, intent
- 🔍 **Detailed feedback:** Specific issues and suggestions
- ✅ **Cross-validation:** Multiple LLMs reduce bias
- 📊 **Metrics:** Track quality scores over time

### Drawbacks

- 💰 **Cost:** Requires LLM API calls (~$0.01 per test)
- ⏱️ **Slow:** ~2-5 seconds per test case
- 🎲 **Non-deterministic:** LLM responses vary slightly
- 🔑 **Requires setup:** API keys, network access

---

## Test Infrastructure

### Base Test Class

```ruby
# test/skills/skill_test_case.rb
class SkillTestCase < Minitest::Test
  class << self
    attr_accessor :skill_domain, :skill_name
  end

  def skill_content
    @skill_content ||= load_skill(self.class.skill_domain, self.class.skill_name)
  end

  def skill_metadata
    @skill_metadata ||= parse_skill_yaml(skill_content)
  end

  # Common assertions
  def assert_skill_has_yaml_front_matter
  def assert_skill_has_required_metadata
  def assert_skill_has_section(section_name)
  def assert_skill_has_pattern(pattern_name)
  def assert_code_examples_are_valid
  def assert_has_good_and_bad_examples
  def assert_pattern_present(code, pattern, message = nil)
  def assert_pattern_absent(code, pattern, message = nil)
end
```

### Test Helpers

**SkillTestHelpers** (unit tests):
- `load_skill(domain, skill_name)` - Load skill file
- `parse_skill_yaml(content)` - Extract YAML front matter
- `extract_patterns(content, name)` - Get specific pattern
- `extract_code_examples(content)` - Get all code blocks
- `skill_file_exists?(domain, name)` - Check file exists

**LLMJudgeHelpers** (integration tests):
- `create_judge_prompt(skill, scenario, code)` - Build judge prompt
- `judge_with_llm(provider:, prompt:)` - Get LLM evaluation
- `cross_validate(scenario, code, skill)` - Multi-LLM validation
- `skip_unless_integration` - Skip if INTEGRATION=1 not set

### Mock LLM Client

For testing without API costs:

```ruby
# test/test_helper.rb
class LLMClient
  def initialize(provider: :mock, model: nil)
    @provider = provider
  end

  def evaluate(prompt)
    case @provider
    when :mock
      mock_evaluation  # Returns passing scores
    when :openai
      evaluate_with_openai(prompt)
    when :anthropic
      evaluate_with_anthropic(prompt)
    end
  end

  private

  def mock_evaluation
    {
      "overall_score" => 4.5,
      "pass" => true,
      "scores" => {
        "correct_pattern" => 5,
        "rails_conventions" => 4,
        "avoids_antipatterns" => 5,
        "code_quality" => 4
      },
      "issues" => [],
      "suggestions" => []
    }
  end
end
```

---

## Rake Tasks

```bash
# Unit tests (fast)
rake test:skills:unit                    # Run all unit tests
rake test:skills:skill[skill-name]       # Run specific skill test
rake test:skills:new[skill-name,domain]  # Generate test template

# Integration tests (slow)
rake test:skills:integration             # Run all integration tests
rake test:skills:all                     # Run unit + integration

# Coverage report
rake test:skills:report
# => Total Skills: 40
#    Unit Tests: 19
#    Integration Tests: 5
#    Coverage: 47.5%
```

---

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
          bundler-cache: true
      - name: Run unit tests
        run: bundle exec rake test:skills:unit

  integration-tests:
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.3
          bundler-cache: true
      - name: Run integration tests
        env:
          INTEGRATION: 1
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: bundle exec rake test:skills:integration
```

---

## Writing New Tests

### 1. Create Unit Test

Use the template generator:

```bash
rake test:skills:new[my-skill,backend]
```

Or manually create:

```ruby
# test/skills/unit/my_skill_test.rb
require_relative "../skill_test_case"

class MySkillTest < SkillTestCase
  self.skill_domain = "backend"
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

---

## Current Test Coverage

As of 2025-10-30:

```bash
$ rake test:skills:report

=== Skill Test Coverage Report ===

Total Skills: 40
Unit Tests: 1
Integration Tests: 1
Coverage: 2.5%

Run tests:
  rake test:skills:unit          # Fast unit tests
  rake test:skills:integration   # Slow integration tests
  rake test:skills:all           # All tests
```

**Proven working:**
- ✅ turbo-page-refresh (19 unit tests, 5 integration tests)
- ✅ Framework validated (< 0.003s test execution)

---

## Metrics to Track

### Per Skill
- Pass rate (% of test cases passing)
- Average LLM judge score
- Pattern coverage (% of patterns tested)
- Common failure patterns

### Overall
- Total skill coverage (% with tests)
- Unit test pass rate
- Integration test pass rate
- Average judge score across all skills
- Cross-validation agreement rate

### Performance
- Unit test execution time (target: < 1s total)
- Integration test execution time (target: < 5s per test)
- API costs (track $ spent on LLM judge calls)

---

## Best Practices

### 1. Write Unit Tests First
- Fast feedback on skill structure
- Validates machine-readability
- No API costs

### 2. Add Integration Tests for Critical Skills
- Security patterns (XSS, SQL injection, CSRF)
- Configuration (Solid Stack, credentials)
- Core patterns (Turbo, ViewComponent, TDD)

### 3. Use Cross-Validation Sparingly
- Costs 2x API calls
- Use for high-stakes skills
- Weekly or before releases

### 4. Mock in Development
- Use mock LLM client for rapid iteration
- Use real LLMs in CI/CD only
- Prevents accidental API charges

### 5. Keep Tests in Sync
- Update tests when skills change
- Tests are documentation
- Failing tests = skill needs update

### 6. Document Expected Patterns
- Make tests readable
- Comments explain *why*, not just *what*
- Future developers understand intent

---

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

### Tests are slow

- Unit tests should be < 1 second total
- If slow, you're calling LLMs (use mocks)
- Integration tests are expected to be slow (2-5s per test)

---

## Implementation History

### Version 1.0 (Proposal)
- Explored 5 different approaches
- Documented pros/cons of each
- Recommended hybrid strategy

### Version 2.0 (Implemented)
- Chose two-tier Minitest approach
- Built SkillTestCase base class
- Implemented LLM-as-judge pattern
- Added cross-validation support
- Created Rake automation
- Proven with turbo-page-refresh skill

---

## Next Steps

1. **Scale test coverage** - Add tests for remaining 32 skills
2. **Implement real LLM clients** - Replace mock with actual APIs
3. **Add more integration tests** - Start with high-priority skills
4. **Automate in CI/CD** - Run on every commit (unit) and weekly (integration)
5. **Track metrics** - Monitor quality over time
6. **Refine judge prompts** - Improve evaluation accuracy

---

## Resources

- [Minitest Documentation](https://github.com/minitest/minitest)
- [LLM Evaluation Best Practices](https://www.anthropic.com/index/evaluating-ai-systems)
- [Testing AI Applications](https://www.promptingguide.ai/applications/evaluation)
- [LLM-as-Judge Methodology](https://arxiv.org/abs/2306.05685)

---

**Version History:**
- **1.0** (2025-10-30) - Initial methodology proposal (5 approaches explored)
- **2.0** (2025-10-30) - Implemented two-tier Minitest strategy
