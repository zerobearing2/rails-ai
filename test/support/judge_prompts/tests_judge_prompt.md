Evaluate Rails testing implementation plan.

## Critical Check

**REQUIRED**: If the agent asks for clarification instead of providing implementation plans/code, FAIL this evaluation:
- Set total_score to 0/50
- Add suggestion: "Agent must provide implementation plans, not ask for clarification in test scenarios"

Agents should make reasonable assumptions and provide concrete plans with code examples.

## Scoring (50 points total, 5 categories × 10 points each)

**IMPORTANT**: If a category is not applicable to this feature, award full points (10/10) for that category. Only deduct points for missing or incorrect implementation of relevant aspects.

Score the plan against these testing skills:

**Test Coverage (0-10)**
- If models: Model validations, associations, scopes tested
- Controllers: Happy and sad paths
- Edge cases for relevant functionality

**Test Quality (0-10)**
- skills/testing/tdd-minitest.md
- Clear test names, proper assertions
- One thing per test

**Test Organization (0-10)**
- skills/testing/test-helpers.md
- Correct locations (unit vs integration)
- Minitest conventions

**Test Data (0-10)**
- If models/database: skills/testing/fixtures-test-data.md
- If no database: 10/10 (not applicable)

**Advanced Testing (0-10)**
- If models: skills/testing/model-testing-advanced.md
- If mocking needed: skills/testing/minitest-mocking.md
- If ViewComponents: skills/testing/viewcomponent-testing.md
- If simple feature: 10/10 (not applicable)
