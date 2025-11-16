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

```text
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
