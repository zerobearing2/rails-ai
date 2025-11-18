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
