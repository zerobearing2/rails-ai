# Skill Testing Methodology

**Version:** 1.0
**Status:** Proposal
**Last Updated:** 2025-10-30

Testing skills for LLM consumption requires different approaches than traditional unit testing. This document outlines practical methodologies for validating that skills produce expected outcomes when used by agents.

---

## The Challenge

**Why Traditional Testing Doesn't Work:**
- Skills are consumed by LLMs, not executed as code
- LLM output is non-deterministic (different valid solutions)
- Need to verify *understanding* and *application*, not exact output
- Must test patterns, principles, and code quality—not string matching

**What We Need to Validate:**
1. **Comprehension** - Does the LLM understand the skill?
2. **Application** - Does it apply patterns correctly?
3. **Avoidance** - Does it avoid antipatterns?
4. **Completeness** - Does it cover all relevant aspects?
5. **Quality** - Is the generated code production-ready?

---

## Approach 1: Skill Test Suites (Recommended)

Create a test suite for each skill with structured test cases.

### Structure

```
skills/
├── frontend/
│   ├── turbo-page-refresh.md
│   └── turbo-page-refresh.test.yml    # Test suite
├── backend/
│   ├── form-objects.md
│   └── form-objects.test.yml          # Test suite
```

### Test Case Format

```yaml
# skills/frontend/turbo-page-refresh.test.yml
skill: turbo-page-refresh
version: 1.0
test_cases:
  - name: "Enable page refresh with morph"
    description: "Agent should enable morph on body element"
    scenario: |
      User asks: "I want to add Turbo page refresh with morphing to my app"

    expected_patterns:
      - 'data-turbo-refresh-method="morph"'
      - 'data-turbo-refresh-scroll="preserve"'
      - pattern: '<body.*data-turbo'
        description: "Should add to body tag"

    forbidden_patterns:
      - 'turbo_frame_tag'
      - 'data-turbo-frame'

    validation:
      - type: "syntax"
        language: "erb"
      - type: "contains_text"
        text: "data-turbo-refresh-method"
      - type: "rails_convention"
        rule: "uses_data_attributes"

  - name: "Broadcasting page refresh"
    description: "Agent should use broadcast_refresh_to correctly"
    scenario: |
      User asks: "Make it so when a feedback is created, all users see it in real-time"

    expected_patterns:
      - 'broadcast_refresh_to'
      - 'after_create_commit'
      - 'turbo_stream_from'

    forbidden_patterns:
      - 'broadcast_append_to'
      - 'broadcast_replace_to'
      - 'turbo_frame_tag.*feedbacks'

    validation:
      - type: "ruby_syntax"
      - type: "method_call"
        method: "broadcast_refresh_to"
        args: 1
      - type: "callback_used"
        callback: "after_create_commit"

  - name: "Permanent elements preserve state"
    description: "Agent should use data-turbo-permanent for stateful elements"
    scenario: |
      User says: "My form loses focus when the page refreshes"

    expected_patterns:
      - 'data-turbo-permanent'
      - pattern: 'data.*turbo.*permanent.*form'
        description: "Should wrap form or input in permanent element"

    validation:
      - type: "contains_attribute"
        attribute: "data-turbo-permanent"
```

### Test Runner (Pseudocode)

```ruby
# test/skill_test_runner.rb
class SkillTestRunner
  def initialize(skill_name)
    @skill = load_skill(skill_name)
    @test_suite = load_test_suite(skill_name)
    @agent = initialize_agent_with_skill(@skill)
  end

  def run_all_tests
    @test_suite.test_cases.each do |test_case|
      run_test_case(test_case)
    end
  end

  def run_test_case(test_case)
    # 1. Give scenario to agent
    response = @agent.process(test_case.scenario)

    # 2. Validate expected patterns present
    test_case.expected_patterns.each do |pattern|
      assert_pattern_present(response, pattern)
    end

    # 3. Validate forbidden patterns absent
    test_case.forbidden_patterns.each do |pattern|
      assert_pattern_absent(response, pattern)
    end

    # 4. Run structured validations
    test_case.validations.each do |validation|
      validate(response, validation)
    end
  end
end
```

**Pros:**
- Structured, repeatable tests
- Version control friendly (YAML)
- Easy to add new test cases
- Can automate with CI/CD

**Cons:**
- Requires building test runner infrastructure
- Still need to define "good enough" criteria
- May need LLM to evaluate complex outputs

---

## Approach 2: Pattern Assertions (Quick & Simple)

Use regex/grep to check for key patterns in generated code.

### Implementation

```bash
# test/skills/test_turbo_page_refresh.sh
#!/bin/bash

SKILL="turbo-page-refresh"
AGENT="feature"

echo "Testing skill: $SKILL"

# Test 1: Enable morph
echo "Test: Enable page refresh with morph"
RESULT=$(./scripts/run_agent.sh $AGENT "Add Turbo page refresh with morphing")

# Assert expected patterns
echo "$RESULT" | grep -q 'data-turbo-refresh-method="morph"' || {
  echo "❌ FAIL: Missing data-turbo-refresh-method"
  exit 1
}

echo "$RESULT" | grep -q 'data-turbo-refresh-scroll="preserve"' || {
  echo "❌ FAIL: Missing scroll preservation"
  exit 1
}

# Assert forbidden patterns
echo "$RESULT" | grep -q 'turbo_frame_tag' && {
  echo "❌ FAIL: Should not use turbo_frame_tag for page refresh"
  exit 1
}

echo "✅ PASS: Enable morph test"

# Test 2: Broadcasting
echo "Test: Broadcasting page refresh"
RESULT=$(./scripts/run_agent.sh $AGENT "Broadcast feedback changes to all users")

echo "$RESULT" | grep -q 'broadcast_refresh_to' || {
  echo "❌ FAIL: Missing broadcast_refresh_to"
  exit 1
}

echo "$RESULT" | grep -q 'after_create_commit' || {
  echo "❌ FAIL: Missing callback"
  exit 1
}

echo "✅ PASS: Broadcasting test"

echo ""
echo "All tests passed for $SKILL ✅"
```

**Pros:**
- Simple to implement
- Fast to run
- No special infrastructure needed
- Easy to understand

**Cons:**
- Brittle (exact string matching)
- Can't validate code quality or logic
- Limited to presence/absence checks
- Doesn't validate understanding

---

## Approach 3: LLM-as-Judge (Most Comprehensive)

Use another LLM instance to evaluate if the output meets criteria.

### Implementation

```yaml
# skills/frontend/turbo-page-refresh.judge.yml
skill: turbo-page-refresh
evaluator_prompt: |
  You are evaluating code generated by an AI agent that was given the turbo-page-refresh skill.

  Evaluate the following aspects on a scale of 1-5:

  1. **Correct Pattern Usage**: Does it use data-turbo-refresh-method="morph"?
  2. **Scroll Preservation**: Does it preserve scroll position?
  3. **Broadcasting**: Does it use broadcast_refresh_to (not frame-specific broadcasts)?
  4. **State Preservation**: Does it use data-turbo-permanent for forms/inputs?
  5. **Avoids Frames**: Does it avoid turbo_frame_tag for this use case?
  6. **Rails 8.1 Conventions**: Does it follow modern Rails patterns?

  Provide:
  - Score for each aspect (1-5)
  - Overall score (average)
  - Pass/Fail (pass if overall >= 4.0)
  - Specific issues found
  - Suggestions for improvement

test_cases:
  - name: "Enable morph"
    user_request: "Add Turbo page refresh with morphing to my app"
    generated_code: |
      # Agent's output goes here

  - name: "Real-time updates"
    user_request: "Make feedback appear in real-time for all users"
    generated_code: |
      # Agent's output goes here
```

### Judge Prompt

```ruby
# lib/skill_judge.rb
class SkillJudge
  def evaluate(skill_name, test_case, generated_code)
    judge_prompt = load_judge_prompt(skill_name)

    evaluation_request = <<~PROMPT
      #{judge_prompt}

      ## Test Case
      User Request: #{test_case.user_request}

      ## Generated Code
      ```ruby
      #{generated_code}
      ```

      Provide your evaluation in JSON format:
      {
        "scores": {
          "correct_pattern": 4,
          "scroll_preservation": 5,
          ...
        },
        "overall_score": 4.2,
        "pass": true,
        "issues": ["Missing X", "Should use Y"],
        "suggestions": ["Consider Z"]
      }
    PROMPT

    llm_evaluate(evaluation_request)
  end
end
```

**Pros:**
- Most comprehensive evaluation
- Can assess code quality, not just patterns
- Understands context and intent
- Can provide actionable feedback
- Evaluates "understanding" not just output

**Cons:**
- Requires LLM API calls (cost)
- Slower than static analysis
- Non-deterministic evaluations
- Need to validate the judge itself

---

## Approach 4: Golden Examples (Reference-Based)

Maintain reference implementations for each skill pattern.

### Structure

```
skills/
├── frontend/
│   ├── turbo-page-refresh.md
│   └── turbo-page-refresh.golden/
│       ├── enable_morph.rb.golden
│       ├── broadcast_refresh.rb.golden
│       └── permanent_elements.erb.golden
```

### Golden Example

```ruby
# skills/frontend/turbo-page-refresh.golden/enable_morph.rb.golden
# GOLDEN EXAMPLE: Enable page refresh with morph
#
# This is the reference implementation for enabling Turbo page refresh.
# Generated code should be structurally similar to this.

# app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body data-turbo-refresh-method="morph" data-turbo-refresh-scroll="preserve">
    <%= yield %>
  </body>
</html>

# Key patterns to check:
# - data-turbo-refresh-method="morph" on body
# - data-turbo-refresh-scroll="preserve" on body
# - Applied to layout, not individual views
```

### Comparison Tool

```ruby
# lib/golden_comparator.rb
class GoldenComparator
  def compare(generated_code, golden_example)
    golden_patterns = extract_patterns(golden_example)

    results = {
      patterns_matched: [],
      patterns_missing: [],
      similarity_score: 0.0
    }

    golden_patterns.each do |pattern|
      if matches_pattern?(generated_code, pattern)
        results[:patterns_matched] << pattern
      else
        results[:patterns_missing] << pattern
      end
    end

    results[:similarity_score] = calculate_similarity(
      generated_code,
      golden_example
    )

    results
  end

  private

  def extract_patterns(golden_code)
    # Extract key patterns from comments or annotations
    patterns = []

    golden_code.scan(/# Key pattern: (.+)$/) do |pattern|
      patterns << pattern.first
    end

    patterns
  end
end
```

**Pros:**
- Clear reference for "correct" implementation
- Easy to update as conventions change
- Visual comparison possible
- Good documentation

**Cons:**
- Many valid implementations (not just one golden)
- Can't cover all scenarios
- Maintenance overhead (update goldens when skill changes)
- Rigid—doesn't allow for alternative approaches

---

## Approach 5: Integration Testing (Real World)

Apply skills to actual Rails projects and verify results.

### Setup

```bash
# test/integration/skill_integration_test.sh

# 1. Create test Rails app
rails new test_app --skip-test

# 2. Apply skill via agent
echo "Testing turbo-page-refresh skill on real Rails app..."
cd test_app

# 3. Run agent with skill
RESULT=$(run_agent "feature" "Add Turbo page refresh with morphing")

# 4. Verify changes
echo "Checking layout file..."
grep -q 'data-turbo-refresh-method="morph"' app/views/layouts/application.html.erb || {
  echo "❌ Layout not updated correctly"
  exit 1
}

# 5. Test the app actually works
rails server -d -p 3001
sleep 5

# 6. Run system tests
curl http://localhost:3001 | grep -q "data-turbo-refresh-method" || {
  echo "❌ App doesn't render correctly"
  exit 1
}

# 7. Check for antipatterns
grep -r "turbo_frame_tag" app/ && {
  echo "⚠️  Warning: Found turbo_frame_tag (might be acceptable, manual review needed)"
}

# 8. Cleanup
rails server:kill
cd ..
rm -rf test_app

echo "✅ Integration test passed"
```

**Pros:**
- Tests in real environment
- Validates actual functionality
- Catches integration issues
- High confidence in results

**Cons:**
- Slow (spinning up Rails apps)
- Complex setup
- Hard to isolate failures
- Requires actual Rails installation

---

## Recommended Hybrid Approach

Combine multiple approaches for comprehensive coverage:

### Tier 1: Fast Feedback (Pattern Assertions)
**When:** Every skill change
**Purpose:** Quick sanity check
```bash
# Run in < 5 seconds
./test/skills/quick_check.sh turbo-page-refresh
```

### Tier 2: Structured Tests (Test Suites)
**When:** Before commit
**Purpose:** Validate expected/forbidden patterns
```bash
# Run in < 30 seconds
./test/skills/run_test_suite.rb turbo-page-refresh
```

### Tier 3: Quality Assessment (LLM-as-Judge)
**When:** Weekly or on major changes
**Purpose:** Comprehensive evaluation
```bash
# Run in ~2 minutes (LLM API calls)
./test/skills/judge_quality.rb turbo-page-refresh
```

### Tier 4: Real-World Validation (Integration)
**When:** Before release
**Purpose:** Ensure production readiness
```bash
# Run in ~5 minutes
./test/skills/integration_test.sh turbo-page-refresh
```

---

## Practical Implementation Plan

### Phase 1: Start Simple (Pattern Assertions)
1. Create `test/skills/` directory
2. Write bash scripts with grep-based assertions
3. Run manually on skill updates
4. Document expected patterns per skill

### Phase 2: Add Structure (Test Suites)
1. Design YAML test case format
2. Build simple Ruby test runner
3. Convert bash scripts to YAML test cases
4. Automate in Git hooks

### Phase 3: Add Intelligence (LLM-as-Judge)
1. Create judge prompt templates
2. Build evaluation harness
3. Run on subset of critical skills
4. Use for quality gates

### Phase 4: Real-World Testing (Integration)
1. Create test Rails app template
2. Automate skill application
3. Run actual tests in test app
4. Use in CI/CD pipeline

---

## Example: Testing `turbo-page-refresh` Skill

### Quick Test (Tier 1)
```bash
# test/skills/turbo_page_refresh_quick.sh
echo "Testing turbo-page-refresh skill..."

RESULT=$(run_agent "Add page refresh with morph")

echo "$RESULT" | grep -q 'data-turbo-refresh-method="morph"' && \
echo "$RESULT" | grep -q 'data-turbo-refresh-scroll="preserve"' && \
! echo "$RESULT" | grep -q 'turbo_frame_tag' && \
echo "✅ Quick test passed" || echo "❌ Quick test failed"
```

### Structured Test (Tier 2)
```yaml
# skills/frontend/turbo-page-refresh.test.yml
skill: turbo-page-refresh
test_cases:
  - name: enable_morph
    scenario: "Add page refresh with morphing"
    expected: [data-turbo-refresh-method, data-turbo-refresh-scroll]
    forbidden: [turbo_frame_tag]

  - name: broadcast_refresh
    scenario: "Make feedback appear in real-time for all users"
    expected: [broadcast_refresh_to, turbo_stream_from]
    forbidden: [broadcast_append_to, broadcast_replace_to]
```

### Judge Evaluation (Tier 3)
```ruby
SkillJudge.evaluate(
  skill: "turbo-page-refresh",
  scenario: "Add page refresh with morphing",
  generated_code: agent_output
)
# => { overall_score: 4.5, pass: true, issues: [], ... }
```

---

## Metrics to Track

**Per Skill:**
- Pass rate (% of test cases passing)
- Average quality score (from LLM judge)
- Common failure patterns
- Time to fix failures

**Overall:**
- Total skill coverage (% with tests)
- Average pass rate across all skills
- Test execution time
- False positive/negative rate

---

## Next Steps

1. **Choose initial approach** - Pattern assertions recommended for quick start
2. **Create test for 1-2 skills** - Prove the concept
3. **Document patterns** - What makes a test "good"
4. **Automate** - Git hooks or CI/CD
5. **Iterate** - Add more sophisticated testing as needed

---

## Open Questions

1. **Evaluation criteria:** What makes generated code "good enough"?
2. **Variance handling:** How much variance is acceptable?
3. **Test maintenance:** Who updates tests when skills change?
4. **Failure recovery:** What happens when tests fail?
5. **Coverage goals:** Do we need 100% test coverage?

---

## Resources

- [LLM Evaluation Best Practices](https://www.anthropic.com/index/evaluating-ai-systems)
- [Testing AI Applications](https://www.promptingguide.ai/applications/evaluation)
- [LLM-as-Judge Methodology](https://arxiv.org/abs/2306.05685)

---

**Version History:**
- **1.0** (2025-10-30) - Initial methodology proposal
