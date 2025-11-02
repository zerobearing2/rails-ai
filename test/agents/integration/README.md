# Agent Integration Tests

Executable integration tests for evaluating rails-ai agent planning capabilities.

## Overview

This testing framework:
1. **Provides detailed scenarios** with existing code context
2. **Asks agents to plan** (not execute) implementations
3. **Uses LLM judge** to evaluate plan quality
4. **Auto-grades** with pass/fail criteria
5. **Runs in isolation** using temp files

## Quick Start

### Prerequisites

- `claude` CLI installed
- `rails-ai` plugin configured
- Current working branch of rails-ai

### Run a Test

```bash
cd test/agents/integration
./run_test.sh 01
```

Follow the prompts:
1. Update plugin to latest version
2. Run agent with scenario
3. Run judge evaluation
4. View results

## How It Works

### 1. Scenario with Bootstrap

Each scenario (`scenarios/XX_*.md`) contains:
- **Scenario Bootstrap**: Existing Rails app code (models, schema, routes)
- **Task**: What to implement
- **Instructions**: Ask agent to plan (not execute)
- **Output Format**: Structure for agent's response

Example: `scenarios/01_simple_model_plan.md`

### 2. Agent Planning

Agent (e.g., `@rails-ai:architect`) reads the scenario and outputs a detailed plan to:
```
/tmp/rails-ai-test/agent_plan.md
```

Plan includes:
- Architecture overview
- Implementation steps
- Complete code for models, migrations, tests
- Rationale for decisions

### 3. LLM Judge Evaluation

Judge evaluates the plan on 5 dimensions (0-10 each):
- **Architecture & Design**: Rails conventions, associations, DB design
- **Code Quality**: Syntax, idioms, best practices
- **Completeness**: All requirements met, nothing missing
- **Implementation Details**: Validations, indexes, scopes
- **Explanation Quality**: Clear rationale, good structure

**Total**: 50 points
**Passing**: 35+ points (70%)

Judge outputs structured evaluation to:
```
/tmp/rails-ai-test/judge_result.md
```

### 4. Auto-Grading

The `evaluate_results.sh` script:
- Parses judge output
- Checks score ≥ 35/50
- Checks for critical blockers
- Returns PASS/FAIL
- Shows summary and recommendations

## File Structure

```
test/agents/integration/
├── README.md                      # This file
├── run_test.sh                    # Main test runner
├── evaluate_results.sh            # Results parser/grader
├── scenarios/                     # Test scenarios
│   └── 01_simple_model_plan.md    # Scenario: Add Article model
└── judge/                         # Judge configuration
    └── judge_prompt.md            # LLM judge evaluation criteria
```

## Running Tests

### Manual Workflow

#### Step 1: Update Plugin

```bash
claude
```

```
/plugin update rails-ai
# Point to your working branch
```

#### Step 2: Run Agent

```bash
claude
```

```
/plugin rails-ai:architect

[Paste content from scenarios/01_simple_model_plan.md]
```

Agent writes plan to `/tmp/rails-ai-test/agent_plan.md`

#### Step 3: Run Judge

```bash
claude
```

```
[Paste content from judge/judge_prompt.md]

## Scenario
[Paste from scenarios/01_simple_model_plan.md]

## Agent's Plan
[Paste from /tmp/rails-ai-test/agent_plan.md]
```

Judge writes evaluation to `/tmp/rails-ai-test/judge_result.md`

#### Step 4: Evaluate

```bash
./evaluate_results.sh /tmp/rails-ai-test/judge_result.md
```

Output:
```
=== Evaluation Results ===

Score Breakdown:
  Architecture & Design: 9/10
  Code Quality: 9/10
  Completeness: 8/10
  Implementation Details: 9/10
  Explanation Quality: 10/10

Total Score: 45/50 (90%)
Grade: Excellent

✓ PASS (Score: 45 ≥ 35)
```

### Automated Workflow (Using run_test.sh)

```bash
./run_test.sh 01
```

Follow the interactive prompts for each step.

## Evaluation Criteria

### Passing Requirements

✓ Total score ≥ 35/50 (70%)
✓ No critical blockers
✓ All core requirements addressed
✓ Code would work if implemented

### Failing Reasons

✗ Total score < 35/50
✗ Critical blockers present
✗ Core requirements missing
✗ Code has syntax errors

## Creating New Scenarios

### Template

```markdown
# Integration Test Scenario: [Name]

## Scenario Bootstrap

You are working on a Rails 8.1.1 [app type] with:

### app/models/[model].rb
\```ruby
[existing code]
\```

### db/schema.rb
\```ruby
[existing schema]
\```

## Task

[Clear requirements]

## Instructions for Agent

DO NOT execute code.

Provide:
1. Architecture Overview
2. Step-by-Step Plan
3. Model Code
4. Migration
5. Tests
6. Rationale

## Output Format

[Template for agent response]

---

**Write your plan to:** `/tmp/rails-ai-test/agent_plan.md`
```

### Best Practices

1. **Rich context**: Include enough existing code for realistic planning
2. **Clear requirements**: Be specific about what's needed
3. **Real scenarios**: Base on actual Rails development tasks
4. **Testable criteria**: Design requirements that can be objectively judged

## Advantages

✅ **No Rails app needed**: Runs anywhere
✅ **Fast iteration**: Seconds, not minutes
✅ **Isolated**: Uses temp files, no cleanup
✅ **Reproducible**: Same scenario, consistent evaluation
✅ **Automated grading**: Pass/fail with clear criteria

## Example Output

### Passing Test (45/50)

```
=== Evaluation Results ===

Total Score: 45/50 (90%)
Grade: Excellent

✓ PASS (Score: 45 ≥ 35)

Critical Blockers: None

Top Issues:
1. Missing index on published_at for scope performance
2. Could add null: false constraint on title in migration
3. None

Summary:
Excellent implementation plan that demonstrates strong
understanding of Rails conventions and best practices.
Code is clean, well-structured, and would work perfectly
if implemented. Minor optimizations possible.

Recommendations:
1. Add composite index on [author_id, published_at]
2. Consider null: false on required fields in migration
3. Add test for published scope edge cases
```

### Failing Test (28/50)

```
=== Evaluation Results ===

Total Score: 28/50 (56%)
Grade: Poor

✗ FAIL (Score: 28 < 35)

Critical Blockers:
- Migration missing foreign key constraint
- Validation syntax errors
- Association not bidirectional

Top Issues:
1. belongs_to missing, only has_many defined
2. Validation uses incorrect syntax (validates_presence_of deprecated)
3. Migration doesn't set up proper foreign key

Summary:
Plan has significant issues that would prevent it from
working correctly. Missing critical Rails concepts like
bidirectional associations and proper migration structure.
```

## Troubleshooting

### Agent doesn't write to /tmp/rails-ai-test/agent_plan.md

Make sure the scenario instructions include:
```
**Write your plan to:** `/tmp/rails-ai-test/agent_plan.md`
```

### Judge output can't be parsed

Check that judge followed the exact format in `judge/judge_prompt.md`.

### Tests fail due to plugin version

Ensure you've updated the plugin to your working branch:
```
/plugin update rails-ai
```

## Next Steps

1. Run test 01 to establish baseline
2. Iterate on agent prompts based on results
3. Add more scenarios for different complexities
4. Track improvements over time

## See Also

- [Agent Documentation](../../../agents/)
- [Plugin Documentation](../../../docs/plugin.md)
