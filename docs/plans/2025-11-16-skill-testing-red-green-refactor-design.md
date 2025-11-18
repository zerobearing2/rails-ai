# Skill Testing with RED-GREEN-REFACTOR

**Date:** 2025-11-16
**Status:** Approved
**Context:** Replace integration tests with RED-GREEN-REFACTOR cycle for skill behavior testing

## Problem

Current integration tests don't prove skills actually change agent behavior:
- Tests verify "does the plan look good" via judge scoring
- Don't demonstrate skills prevent anti-patterns
- Expensive (4 LLM judges per test)
- Don't follow TDD principles from superpowers

## Solution

Replace integration tests with skill behavior tests using RED-GREEN-REFACTOR cycle.

### Core Concept

**Key principle from superpowers:**
> If you didn't watch an agent fail without the skill, you don't know if the skill prevents the right failures.

**Approach:**
- Test individual skill effectiveness using RED-GREEN-REFACTOR
- Prove each skill prevents specific anti-patterns
- Automated via Minitest, programmatic checks (no judge LLMs)
- Same test infrastructure (subagents, logging), different focus

**Running tests:**
- **NOT part of bin/ci** - too slow, LLM-dependent
- Developer runs manually during skill development: `ruby -Itest test/skills/jobs_skill_test.rb`
- Or run all skill tests: `ruby -Itest test/skills/*_skill_test.rb`
- Used to verify skill changes prevent anti-patterns
- Development tool, not CI gate

### Test Structure

**Directory layout:**

```
test/skills/
  jobs/
    scenarios/
      01_email_without_background_job.md
      02_job_monitoring_without_auth.md
      03_deliver_now_antipattern.md
    results/  # gitignored, generated during test runs
      YYYY-MM-DD-HH-MM-SS/
        01-baseline.md
        01-with-skill.md
  mailers/
    scenarios/
      01_path_helpers_instead_of_url.md
      02_deliver_now_blocking.md
  styling/
    scenarios/
      01_hardcoded_colors.md
      02_inline_styles.md
  jobs_skill_test.rb
  mailers_skill_test.rb
  styling_skill_test.rb
  skill_test_case.rb  # base class
```

**Scenario file format (01_email_without_background_job.md):**

```markdown
---
skill: jobs
antipattern: deliver_now
description: Agent uses blocking email delivery instead of background job
---

# Scenario

You're adding a welcome email notification to user signup.

Requirements:
- Send email when user creates account
- Email contains welcome message and login link
- Must not block the HTTP request

Implement this feature.

# Expected Baseline Behavior (WITHOUT skill)

Agent should use `deliver_now` which blocks the request.

# Expected With-Skill Behavior (WITH skill)

Agent should use `deliver_later` with SolidQueue.

# Assertions

Must include:
- deliver_later (not deliver_now)
- Reference to jobs or background processing
- SolidQueue or async delivery mentioned
```

### Implementation

**Base class (test/skills/skill_test_case.rb):**

```ruby
# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../support/llm_adapter"
require "yaml"
require "fileutils"

# Base class for skill behavior tests
# Uses RED-GREEN-REFACTOR cycle to verify skills prevent anti-patterns
#
# Subclasses should:
# - Define skill_name (e.g., "jobs")
# - Load scenarios from test/skills/{skill_name}/scenarios/
# - Tests automatically generated from scenario files
class SkillTestCase < Minitest::Test
  # Override in subclass
  def skill_name
    raise NotImplementedError, "Subclass must define skill_name"
  end

  # Override to customize LLM adapter
  def llm_adapter
    @llm_adapter ||= ClaudeAdapter.new
  end

  # Automatically generate test methods from scenario files
  def self.generate_tests_from_scenarios
    return if self == SkillTestCase # Don't run for base class

    skill = new.skill_name
    scenario_dir = File.join(ROOT_PATH, "test", "skills", skill, "scenarios")

    Dir.glob(File.join(scenario_dir, "*.md")).sort.each do |scenario_file|
      scenario_name = File.basename(scenario_file, ".md")

      define_method("test_#{scenario_name}") do
        run_scenario(scenario_file)
      end
    end
  end

  private

  def run_scenario(scenario_file)
    scenario = parse_scenario(scenario_file)
    scenario_name = File.basename(scenario_file, ".md")

    # Create results directory
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    results_dir = File.join(
      ROOT_PATH, "test", "skills", skill_name, "results",
      "#{timestamp}_#{scenario_name}"
    )
    FileUtils.mkdir_p(results_dir)

    # RED: Run without skill
    puts "\n[RED] Running baseline (without skill)..."
    baseline_output = run_agent(scenario[:prompt], without_skill: true)
    File.write(File.join(results_dir, "baseline.md"), baseline_output)

    # GREEN: Run with skill
    puts "[GREEN] Running with skill..."
    with_skill_output = run_agent(scenario[:prompt], without_skill: false)
    File.write(File.join(results_dir, "with_skill.md"), with_skill_output)

    # VERIFY: Check assertions
    puts "[VERIFY] Checking assertions..."
    verify_assertions(scenario, baseline_output, with_skill_output, results_dir)
  end

  def parse_scenario(file)
    content = File.read(file)

    # Extract YAML frontmatter
    if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
      frontmatter = YAML.safe_load($1)
      body = content.sub(/\A---\s*\n.*?\n---\s*\n/m, "")
    else
      frontmatter = {}
      body = content
    end

    # Extract sections
    prompt = body[/# Scenario\s*\n(.*?)(?=\n# )/m, 1]&.strip
    assertions_text = body[/# Assertions\s*\n(.*)/m, 1]&.strip

    {
      skill: frontmatter["skill"],
      antipattern: frontmatter["antipattern"],
      description: frontmatter["description"],
      prompt: prompt,
      assertions: parse_assertions(assertions_text)
    }
  end

  def parse_assertions(text)
    return [] unless text

    # Extract "Must include:" items
    items = text.scan(/^[-*]\s+(.+)$/).flatten
    items.map(&:strip)
  end

  def run_agent(prompt, without_skill:)
    system_prompt = build_system_prompt(without_skill)

    llm_adapter.execute(
      prompt: prompt,
      system_prompt: system_prompt,
      streaming: false
    )
  end

  def build_system_prompt(without_skill)
    if without_skill
      # RED: Baseline without skill access
      <<~PROMPT
        You are implementing features for a Rails 8.1 application.

        Provide implementation code. Be concise and direct.
        Do not ask for clarification - make reasonable assumptions.
      PROMPT
    else
      # GREEN: With skill access
      skill_path = File.join(ROOT_PATH, "skills", skill_name, "SKILL.md")
      skill_content = File.read(skill_path)

      <<~PROMPT
        You are implementing features for a Rails 8.1 application.

        You have access to the following skill:

        #{skill_content}

        Follow the skill patterns and standards.
        Provide implementation code. Be concise and direct.
        Do not ask for clarification - make reasonable assumptions.
      PROMPT
    end
  end

  def verify_assertions(scenario, baseline, with_skill, results_dir)
    failures = []

    scenario[:assertions].each do |assertion|
      # Check baseline DOESN'T have good pattern (proves RED works)
      if baseline.include?(assertion)
        failures << "BASELINE CONTAMINATED: Found '#{assertion}' in baseline (should only appear with skill)"
      end

      # Check with-skill DOES have good pattern (proves GREEN works)
      unless with_skill.include?(assertion)
        failures << "MISSING PATTERN: Expected '#{assertion}' in with-skill output"
      end
    end

    if failures.any?
      summary = "#{failures.size} assertion(s) failed:\n" + failures.join("\n")
      File.write(File.join(results_dir, "failures.txt"), summary)
      flunk(summary)
    else
      File.write(File.join(results_dir, "success.txt"), "All assertions passed!")
    end
  end
end
```

**Concrete test class (test/skills/jobs_skill_test.rb):**

```ruby
# frozen_string_literal: true

require_relative "skill_test_case"

class JobsSkillTest < SkillTestCase
  def skill_name
    "jobs"
  end
end

# Auto-generate test methods from scenario files
JobsSkillTest.generate_tests_from_scenarios
```

### Developer Workflow

**When creating/updating a skill:**

1. **Write scenario first (RED):**
   ```bash
   # Create test/skills/jobs/scenarios/04_new_antipattern.md
   # Define the anti-pattern you want to prevent
   ```

2. **Run test to establish baseline:**
   ```bash
   ruby -Itest test/skills/jobs_skill_test.rb -n test_04_new_antipattern
   ```

   Expected: Test FAILS - baseline has good pattern, or with-skill missing pattern

3. **Update skill to prevent anti-pattern (GREEN):**
   ```bash
   # Edit skills/jobs/SKILL.md
   # Add pattern, antipattern, or standards to prevent the behavior
   ```

4. **Re-run test:**
   ```bash
   ruby -Itest test/skills/jobs_skill_test.rb -n test_04_new_antipattern
   ```

   Expected: Test PASSES - baseline clean, with-skill has pattern

5. **Review outputs manually:**
   ```bash
   cat test/skills/jobs/results/20251116_143022_04_new_antipattern/baseline.md
   cat test/skills/jobs/results/20251116_143022_04_new_antipattern/with_skill.md
   ```

   Check for rationalizations in baseline, compliance in with-skill

6. **Iterate (REFACTOR):**
   - If agent finds loopholes, document rationalization
   - Update skill to close loophole
   - Re-run test to verify still passes

### Migration Plan

**Remove:**
- test/integration/* files (developer_agent_test.rb, etc.)
- test/support/judge_prompts/* (no more LLM judges)
- test/support/agent_integration_test_case.rb (replaced by skill_test_case.rb)
- Results table tracking from TESTING.md

**Keep:**
- test/support/llm_adapter.rb (still needed for subagents)
- Unit tests for Ruby code (test/unit/*)
- Markdown linting (bin/ci)

**Update:**
- Refactor TESTING.md to document new RED-GREEN-REFACTOR workflow

## Example Scenarios

### Jobs Skill

**test/skills/jobs/scenarios/01_email_without_background_job.md:**

```markdown
---
skill: jobs
antipattern: deliver_now
description: Agent uses blocking email delivery instead of background job
---

# Scenario

You're adding a welcome email notification to user signup.

Requirements:
- Send email when user creates account
- Email contains welcome message and login link
- Must not block the HTTP request

Implement this feature.

# Expected Baseline Behavior (WITHOUT skill)

Agent should use `deliver_now` which blocks the request.

# Expected With-Skill Behavior (WITH skill)

Agent should use `deliver_later` with SolidQueue.

# Assertions

Must include:
- deliver_later
- SolidQueue
- background
```

### Mailers Skill

**test/skills/mailers/scenarios/01_path_helpers_instead_of_url.md:**

```markdown
---
skill: mailers
antipattern: path_helpers
description: Agent uses *_path helpers instead of *_url helpers in emails
---

# Scenario

Create a password reset email that includes a link to reset the password.

Requirements:
- Email sent to user with reset instructions
- Link to password reset page with token
- Link must work when clicked from email client

Implement the mailer.

# Expected Baseline Behavior (WITHOUT skill)

Agent should use `password_reset_path` (relative URL).

# Expected With-Skill Behavior (WITH skill)

Agent should use `password_reset_url` (absolute URL).

# Assertions

Must include:
- _url (not _path)
- password_reset_url
- default_url_options
```

### Styling Skill

**test/skills/styling/scenarios/01_hardcoded_colors.md:**

```markdown
---
skill: styling
antipattern: hardcoded_colors
description: Agent hardcodes colors instead of using DaisyUI theme variables
---

# Scenario

Create a button component for form submission.

Requirements:
- Primary action button (blue)
- Should work in light and dark themes
- Consistent with design system

Implement the button styling.

# Expected Baseline Behavior (WITHOUT skill)

Agent should use hardcoded colors like `bg-blue-500` or `#3B82F6`.

# Expected With-Skill Behavior (WITH skill)

Agent should use DaisyUI semantic classes like `btn-primary`.

# Assertions

Must include:
- btn-primary
- DaisyUI
```

## Benefits

1. **Proves skills work** - RED-GREEN-REFACTOR cycle demonstrates skill actually changes behavior
2. **Faster feedback** - No expensive LLM judge calls (4 per test → 2 per test)
3. **Focused testing** - Each scenario tests one specific anti-pattern, not overall plan quality
4. **TDD alignment** - Same discipline applied to skills as we teach for code
5. **Iterative refinement** - Easy to add new scenarios when finding new anti-patterns
6. **Clear pass/fail** - Automated assertions vs subjective judge scoring
7. **Developer tool** - Run during skill development, not blocking CI

## Trade-offs

1. **Manual verification still needed** - Assertions catch patterns, but you should review outputs for rationalizations
2. **Scenario maintenance** - Need to create/maintain scenario files for each anti-pattern
3. **Not comprehensive** - Tests specific anti-patterns, not overall skill quality
4. **LLM-dependent** - Still requires LLM calls (2 per scenario), just fewer
5. **Slower than unit tests** - Can't run in bin/ci due to LLM latency

## Success Metrics

- Skill tests pass consistently
- Manual review shows baseline has anti-patterns
- Manual review shows with-skill output follows patterns
- No rationalizations found in with-skill output

## Implementation Checklist

- [ ] Create test/skills/skill_test_case.rb base class
- [ ] Create test/skills/jobs_skill_test.rb
- [ ] Create test/skills/jobs/scenarios/ directory
- [ ] Write 3 initial job skill scenarios
- [ ] Add test/skills/jobs/results/ to .gitignore
- [ ] Remove test/integration/ directory
- [ ] Remove test/support/judge_prompts/ directory
- [ ] Remove test/support/agent_integration_test_case.rb
- [ ] Refactor TESTING.md with new workflow
- [ ] Document workflow in TESTING.md
- [ ] Run first skill test to verify infrastructure works

## Related

- superpowers:testing-skills-with-subagents - Core methodology
- superpowers:test-driven-development - RED-GREEN-REFACTOR principles
- test/support/llm_adapter.rb - Subagent execution infrastructure
