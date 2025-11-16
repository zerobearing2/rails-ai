# Skill Testing Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement RED-GREEN-REFACTOR skill testing infrastructure to prove skills prevent anti-patterns

**Architecture:** Replace judge-based integration tests with behavior tests that run scenarios without/with skills, verify assertions programmatically

**Tech Stack:** Minitest, Ruby, YAML, ClaudeAdapter (existing), test/support infrastructure

---

## Task 1: Create Base Test Infrastructure

**Files:**
- Create: `test/skills/skill_test_case.rb`
- Reference: `test/test_helper.rb` (existing constants)
- Reference: `test/support/llm_adapter.rb` (existing ClaudeAdapter)

**Step 1: Create skill_test_case.rb file**

Create the file with base class structure:

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

    return unless Dir.exist?(scenario_dir)

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

**Step 2: Verify file created**

Run: `ls -la test/skills/skill_test_case.rb`
Expected: File exists

**Step 3: Commit**

```bash
git add test/skills/skill_test_case.rb
git commit -m "feat: add SkillTestCase base class for RED-GREEN-REFACTOR testing"
```

---

## Task 2: Create Jobs Skill Test

**Files:**
- Create: `test/skills/jobs_skill_test.rb`
- Reference: `test/skills/skill_test_case.rb`

**Step 1: Create jobs_skill_test.rb file**

```ruby
# frozen_string_literal: true

require_relative "skill_test_case"

# Test jobs skill behavior using RED-GREEN-REFACTOR cycle
# Verifies skill prevents anti-patterns like deliver_now, missing auth, etc.
class JobsSkillTest < SkillTestCase
  def skill_name
    "jobs"
  end
end

# Auto-generate test methods from scenario files
JobsSkillTest.generate_tests_from_scenarios
```

**Step 2: Verify file created**

Run: `ls -la test/skills/jobs_skill_test.rb`
Expected: File exists

**Step 3: Commit**

```bash
git add test/skills/jobs_skill_test.rb
git commit -m "feat: add JobsSkillTest for testing jobs skill behavior"
```

---

## Task 3: Create Scenario Directory Structure

**Files:**
- Create: `test/skills/jobs/scenarios/` (directory)
- Create: `test/skills/mailers/scenarios/` (directory)
- Create: `test/skills/styling/scenarios/` (directory)

**Step 1: Create directories**

Run:
```bash
mkdir -p test/skills/jobs/scenarios
mkdir -p test/skills/mailers/scenarios
mkdir -p test/skills/styling/scenarios
```

**Step 2: Verify directories created**

Run: `ls -la test/skills/*/scenarios`
Expected: All three directories exist

**Step 3: Create .gitkeep files**

Run:
```bash
touch test/skills/jobs/scenarios/.gitkeep
touch test/skills/mailers/scenarios/.gitkeep
touch test/skills/styling/scenarios/.gitkeep
```

**Step 4: Commit**

```bash
git add test/skills/jobs/scenarios/.gitkeep
git add test/skills/mailers/scenarios/.gitkeep
git add test/skills/styling/scenarios/.gitkeep
git commit -m "feat: create scenario directories for skill testing"
```

---

## Task 4: Write First Jobs Skill Scenario

**Files:**
- Create: `test/skills/jobs/scenarios/01_email_without_background_job.md`

**Step 1: Create scenario file**

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

**Step 2: Verify file created**

Run: `cat test/skills/jobs/scenarios/01_email_without_background_job.md`
Expected: File contains scenario content

**Step 3: Commit**

```bash
git add test/skills/jobs/scenarios/01_email_without_background_job.md
git commit -m "feat: add email background job scenario for jobs skill"
```

---

## Task 5: Write Second Jobs Skill Scenario

**Files:**
- Create: `test/skills/jobs/scenarios/02_job_monitoring_without_auth.md`

**Step 1: Create scenario file**

```markdown
---
skill: jobs
antipattern: missing_auth
description: Agent mounts Mission Control without authentication
---

# Scenario

Add Mission Control Jobs dashboard for monitoring background jobs.

Requirements:
- Web UI for viewing job status
- Production deployment
- Team access needed

Implement Mission Control setup.

# Expected Baseline Behavior (WITHOUT skill)

Agent should mount route without authentication.

# Expected With-Skill Behavior (WITH skill)

Agent should add authenticate block or HTTP basic auth.

# Assertions

Must include:
- authenticate
- admin
```

**Step 2: Verify file created**

Run: `cat test/skills/jobs/scenarios/02_job_monitoring_without_auth.md`
Expected: File contains scenario content

**Step 3: Commit**

```bash
git add test/skills/jobs/scenarios/02_job_monitoring_without_auth.md
git commit -m "feat: add Mission Control auth scenario for jobs skill"
```

---

## Task 6: Write Third Jobs Skill Scenario

**Files:**
- Create: `test/skills/jobs/scenarios/03_synchronous_job_execution.md`

**Step 1: Create scenario file**

```markdown
---
skill: jobs
antipattern: perform_now
description: Agent uses perform_now instead of perform_later for job execution
---

# Scenario

Create a data export job that generates a CSV file.

Requirements:
- Export user data to CSV
- Email CSV to requesting user
- Handle large datasets (10k+ rows)

Implement the export job.

# Expected Baseline Behavior (WITHOUT skill)

Agent should use `perform_now` which blocks execution.

# Expected With-Skill Behavior (WITH skill)

Agent should use `perform_later` for async execution.

# Assertions

Must include:
- perform_later
- ApplicationJob
- queue
```

**Step 2: Verify file created**

Run: `cat test/skills/jobs/scenarios/03_synchronous_job_execution.md`
Expected: File contains scenario content

**Step 3: Commit**

```bash
git add test/skills/jobs/scenarios/03_synchronous_job_execution.md
git commit -m "feat: add async job execution scenario for jobs skill"
```

---

## Task 7: Write First Mailers Skill Scenario

**Files:**
- Create: `test/skills/mailers/scenarios/01_path_helpers_instead_of_url.md`
- Create: `test/skills/mailers_skill_test.rb`

**Step 1: Create mailers skill test file**

```ruby
# frozen_string_literal: true

require_relative "skill_test_case"

# Test mailers skill behavior using RED-GREEN-REFACTOR cycle
# Verifies skill prevents anti-patterns like path helpers, deliver_now, etc.
class MailersSkillTest < SkillTestCase
  def skill_name
    "mailers"
  end
end

# Auto-generate test methods from scenario files
MailersSkillTest.generate_tests_from_scenarios
```

**Step 2: Create scenario file**

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
- _url
- password_reset_url
- default_url_options
```

**Step 3: Verify files created**

Run:
```bash
ls -la test/skills/mailers_skill_test.rb
cat test/skills/mailers/scenarios/01_path_helpers_instead_of_url.md
```
Expected: Both files exist with correct content

**Step 4: Commit**

```bash
git add test/skills/mailers_skill_test.rb
git add test/skills/mailers/scenarios/01_path_helpers_instead_of_url.md
git commit -m "feat: add mailers skill test and URL helpers scenario"
```

---

## Task 8: Write First Styling Skill Scenario

**Files:**
- Create: `test/skills/styling/scenarios/01_hardcoded_colors.md`
- Create: `test/skills/styling_skill_test.rb`

**Step 1: Create styling skill test file**

```ruby
# frozen_string_literal: true

require_relative "skill_test_case"

# Test styling skill behavior using RED-GREEN-REFACTOR cycle
# Verifies skill prevents anti-patterns like hardcoded colors, inline styles, etc.
class StylingSkillTest < SkillTestCase
  def skill_name
    "styling"
  end
end

# Auto-generate test methods from scenario files
StylingSkillTest.generate_tests_from_scenarios
```

**Step 2: Create scenario file**

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

**Step 3: Verify files created**

Run:
```bash
ls -la test/skills/styling_skill_test.rb
cat test/skills/styling/scenarios/01_hardcoded_colors.md
```
Expected: Both files exist with correct content

**Step 4: Commit**

```bash
git add test/skills/styling_skill_test.rb
git add test/skills/styling/scenarios/01_hardcoded_colors.md
git commit -m "feat: add styling skill test and hardcoded colors scenario"
```

---

## Task 9: Update .gitignore for Results

**Files:**
- Modify: `.gitignore`

**Step 1: Add results directories to .gitignore**

Add these lines to `.gitignore`:

```
# Skill test results (LLM outputs)
test/skills/*/results/
```

**Step 2: Verify gitignore updated**

Run: `cat .gitignore | grep "test/skills"`
Expected: Line about test/skills/*/results/ appears

**Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: gitignore skill test results directories"
```

---

## Task 10: Remove Old Integration Tests

**Files:**
- Delete: `test/integration/` directory
- Delete: `test/support/judge_prompts/` directory
- Delete: `test/support/agent_integration_test_case.rb`

**Step 1: Remove integration tests**

Run:
```bash
git rm -r test/integration
```

**Step 2: Remove judge prompts**

Run:
```bash
git rm -r test/support/judge_prompts
```

**Step 3: Remove agent integration test case**

Run:
```bash
git rm test/support/agent_integration_test_case.rb
```

**Step 4: Verify files removed**

Run:
```bash
ls test/integration 2>&1
ls test/support/judge_prompts 2>&1
ls test/support/agent_integration_test_case.rb 2>&1
```
Expected: "No such file or directory" for all three

**Step 5: Commit**

```bash
git commit -m "refactor: remove old judge-based integration tests"
```

---

## Task 11: Refactor TESTING.md

**Files:**
- Modify: `TESTING.md`

**Step 1: Read current TESTING.md**

Run: `cat TESTING.md`

**Step 2: Replace content with new workflow**

Replace entire content with:

```markdown
# Testing Rails AI Skills

This project uses RED-GREEN-REFACTOR cycle to test that skills prevent anti-patterns.

## Philosophy

**Key principle:** If you didn't watch an agent fail without the skill, you don't know if the skill prevents the right failures.

We test skills by:
1. **RED:** Run scenario WITHOUT skill → agent uses anti-pattern
2. **GREEN:** Run scenario WITH skill → agent follows pattern
3. **REFACTOR:** Find loopholes, update skill, re-test

## Running Tests

### Unit Tests (Fast - Run in CI)

```bash
bin/ci
```

Runs:
- Markdown linting on all SKILL.md files
- Unit tests for any Ruby utilities

### Skill Behavior Tests (Slow - Manual Only)

**NOT run in bin/ci** - requires LLM calls, too slow for CI.

Run individual skill tests:

```bash
# Test jobs skill
ruby -Itest test/skills/jobs_skill_test.rb

# Test mailers skill
ruby -Itest test/skills/mailers_skill_test.rb

# Test styling skill
ruby -Itest test/skills/styling_skill_test.rb
```

Run all skill tests:

```bash
ruby -Itest test/skills/*_skill_test.rb
```

Run specific scenario:

```bash
ruby -Itest test/skills/jobs_skill_test.rb -n test_01_email_without_background_job
```

## Writing New Scenarios

### 1. Create Scenario File

Create `test/skills/{skill}/scenarios/NN_description.md`:

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

### 2. Run Test (Should Fail)

```bash
ruby -Itest test/skills/jobs_skill_test.rb -n test_NN_description
```

Expected: FAIL - baseline contaminated OR with-skill missing pattern

### 3. Update Skill

Edit `skills/{skill}/SKILL.md` to prevent the anti-pattern.

Add:
- Pattern showing correct approach
- Antipattern showing wrong approach
- Standards enforcing the rule

### 4. Re-run Test (Should Pass)

```bash
ruby -Itest test/skills/jobs_skill_test.rb -n test_NN_description
```

Expected: PASS - baseline clean, with-skill has pattern

### 5. Review Outputs

```bash
cat test/skills/jobs/results/YYYYMMDD_HHMMSS_NN_description/baseline.md
cat test/skills/jobs/results/YYYYMMDD_HHMMSS_NN_description/with_skill.md
```

Check for:
- Baseline uses anti-pattern
- With-skill uses correct pattern
- No rationalizations in with-skill output

### 6. Iterate if Needed

If agent finds loopholes:
- Document the rationalization
- Update skill to close loophole
- Re-run test to verify

## Test Structure

```
test/
  skills/
    jobs/
      scenarios/           # Scenario files
        01_email_without_background_job.md
        02_job_monitoring_without_auth.md
      results/            # gitignored - LLM outputs
        YYYYMMDD_HHMMSS_01_email.../
          baseline.md
          with_skill.md
          success.txt OR failures.txt
    mailers/
      scenarios/
        01_path_helpers_instead_of_url.md
      results/
    styling/
      scenarios/
        01_hardcoded_colors.md
      results/
    jobs_skill_test.rb
    mailers_skill_test.rb
    styling_skill_test.rb
    skill_test_case.rb    # Base class
```

## How It Works

### Test Execution Flow

1. **Parse scenario:** Extract prompt, assertions from markdown
2. **RED phase:** Run LLM with prompt, NO skill access → baseline output
3. **GREEN phase:** Run LLM with prompt, WITH skill in system prompt → with-skill output
4. **VERIFY phase:** Check assertions
   - Baseline should NOT have good patterns
   - With-skill SHOULD have good patterns
5. **Save results:** Write outputs to results/ directory

### Automated Assertions

Each scenario defines assertions (patterns that should appear):

```markdown
# Assertions

Must include:
- deliver_later
- SolidQueue
- background
```

Test verifies:
- ❌ Baseline does NOT include these (proves anti-pattern)
- ✅ With-skill DOES include these (proves skill works)

### Manual Review

Assertions catch keywords, but you should manually review for:
- Agent rationalizations in baseline
- Compliance without resistance in with-skill
- Loopholes or creative workarounds

## Related

- `docs/plans/2025-11-16-skill-testing-red-green-refactor-design.md` - Design document
- `@superpowers:testing-skills-with-subagents` - Core methodology
- `@superpowers:test-driven-development` - RED-GREEN-REFACTOR principles
```

**Step 3: Verify content replaced**

Run: `head -20 TESTING.md`
Expected: New content about RED-GREEN-REFACTOR

**Step 4: Commit**

```bash
git add TESTING.md
git commit -m "docs: refactor TESTING.md for RED-GREEN-REFACTOR workflow"
```

---

## Task 12: Verify Infrastructure Works

**Files:**
- Run: `test/skills/jobs_skill_test.rb`

**Step 1: Check that test file loads**

Run: `ruby -Itest -e "require_relative 'test/skills/jobs_skill_test'; puts 'Loaded successfully'"`
Expected: "Loaded successfully"

**Step 2: List generated tests**

Run: `ruby -Itest test/skills/jobs_skill_test.rb --verbose`
Expected: Shows 3 test methods (01, 02, 03 scenarios)

**Step 3: Verify ClaudeAdapter available**

Run: `which claude`
Expected: Path to claude CLI (e.g., /usr/local/bin/claude)

**Step 4: Document verification complete**

No commit needed - verification only.

---

## Task 13: Create README for Skill Testing

**Files:**
- Create: `test/skills/README.md`

**Step 1: Create README**

```markdown
# Skill Behavior Tests

Tests that verify skills prevent anti-patterns using RED-GREEN-REFACTOR cycle.

## Quick Start

Run all skill tests:

```bash
ruby -Itest test/skills/*_skill_test.rb
```

Run specific skill:

```bash
ruby -Itest test/skills/jobs_skill_test.rb
```

Run specific scenario:

```bash
ruby -Itest test/skills/jobs_skill_test.rb -n test_01_email_without_background_job
```

## How It Works

Each test:
1. **RED:** Runs scenario WITHOUT skill → agent uses anti-pattern
2. **GREEN:** Runs scenario WITH skill → agent follows pattern
3. **VERIFY:** Checks assertions pass

Results saved to `test/skills/{skill}/results/` (gitignored).

## Adding Scenarios

1. Create `test/skills/{skill}/scenarios/NN_description.md`
2. Run test (should fail)
3. Update `skills/{skill}/SKILL.md` to prevent anti-pattern
4. Re-run test (should pass)
5. Review outputs for rationalizations

See `TESTING.md` for detailed workflow.

## Structure

- `skill_test_case.rb` - Base class with RED-GREEN-REFACTOR logic
- `{skill}_skill_test.rb` - Concrete test class per skill
- `{skill}/scenarios/*.md` - Test scenarios
- `{skill}/results/` - LLM outputs (gitignored)
```

**Step 2: Verify file created**

Run: `cat test/skills/README.md`
Expected: README content appears

**Step 3: Commit**

```bash
git add test/skills/README.md
git commit -m "docs: add README for skill behavior tests"
```

---

## Task 14: Final Verification

**Step 1: Run bin/ci**

Run: `bin/ci`
Expected: All markdown linting passes (no skill tests run in CI)

**Step 2: Verify directory structure**

Run:
```bash
tree test/skills -L 3
```
Expected:
```
test/skills
├── README.md
├── jobs
│   └── scenarios
│       ├── 01_email_without_background_job.md
│       ├── 02_job_monitoring_without_auth.md
│       └── 03_synchronous_job_execution.md
├── jobs_skill_test.rb
├── mailers
│   └── scenarios
│       └── 01_path_helpers_instead_of_url.md
├── mailers_skill_test.rb
├── skill_test_case.rb
├── styling
│   └── scenarios
│       └── 01_hardcoded_colors.md
└── styling_skill_test.rb
```

**Step 3: Verify git status**

Run: `git status`
Expected: Working tree clean (all changes committed)

**Step 4: Document completion**

Implementation complete. Skill testing infrastructure ready for use.

---

## Summary

**What was built:**

1. **Base infrastructure** - SkillTestCase with RED-GREEN-REFACTOR logic
2. **Three skill tests** - Jobs, mailers, styling
3. **Five scenarios** - Email background job, Mission Control auth, async execution, URL helpers, hardcoded colors
4. **Documentation** - Updated TESTING.md, added test/skills/README.md
5. **Cleanup** - Removed old judge-based integration tests

**What to do next:**

Run your first skill test:

```bash
ruby -Itest test/skills/jobs_skill_test.rb -n test_01_email_without_background_job
```

This will:
1. Run scenario WITHOUT jobs skill → baseline output
2. Run scenario WITH jobs skill → with-skill output
3. Verify assertions pass
4. Save results to test/skills/jobs/results/

Review the outputs to see RED-GREEN-REFACTOR in action!
