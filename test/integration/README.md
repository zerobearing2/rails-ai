# Integration Tests for New Agent Structure

This directory contains integration tests for the refactored rails-ai agent system (v0.3.0).

## Quick Reference

### Test Files

| File | Class | Scenario | Agent(s) Tested | Purpose |
|------|-------|----------|-----------------|---------|
| bootstrap_test.rb | NewBootstrapTest | new_bootstrap | @architect | Basic coordination & delegation |
| developer_agent_test.rb | DeveloperAgentTest | developer_agent_fullstack | @developer | Full-stack Rails development |
| uat_agent_test.rb | UatAgentTest | uat_agent_testing | @uat | Testing & QA workflows |
| devops_agent_test.rb | DevopsAgentTest | devops_agent_infrastructure | @devops | Infrastructure & deployment |
| security_agent_test.rb | SecurityAgentTest | security_agent_audit | @security | Security auditing |
| superpowers_integration_test.rb | SuperpowersIntegrationTest | superpowers_workflows | @architect | End-to-end workflow orchestration |
| skill_loading_test.rb | SkillLoadingTest | skill_loading_new_structure | @architect, @developer, @security | Skill loading from consolidated structure |

**Total:** 7 test files

### Running Tests

```bash
# List available scenarios
rake test:integration:list

# Run bootstrap test (fast, cheap infrastructure test)
rake test:integration:bootstrap

# Run individual scenario
rake test:integration:scenario[bootstrap]
rake test:integration:scenario[developer_agent]
rake test:integration:scenario[uat_agent]
rake test:integration:scenario[devops_agent]
rake test:integration:scenario[security_agent]
rake test:integration:scenario[superpowers_integration]
rake test:integration:scenario[skill_loading]
```

**Note:** Integration tests invoke Claude CLI and are slow/expensive. Run individually, not in bulk.

### Key Assertions by Category

**Superpowers References:**
- `superpowers:brainstorming` - Design refinement
- `superpowers:writing-plans` - Implementation planning
- `superpowers:executing-plans` - Batch execution
- `superpowers:subagent-driven-development` - Fast iteration
- `superpowers:test-driven-development` - TDD process
- `superpowers:systematic-debugging` - Investigation framework
- `superpowers:verification-before-completion` - Quality validation

**Agent Delegation:**
- `@architect` - Coordinator (references superpowers)
- `@developer` - Full-stack Rails (replaces @backend + @frontend + @debug)
- `@uat` - Testing/QA (replaces @tests)
- `@devops` - Infrastructure (new)
- `@security` - Security auditing (refactored)

**Skills & TEAM_RULES:**
- See `skills/using-rails-ai/SKILL.md` for complete skill list and descriptions
- See `rules/TEAM_RULES.md` for all 20 rules (Rule #1: No Sidekiq/Redis, Rule #2: No RSpec, Rule #4: TDD Always)

### Test Architecture

Each integration test:
1. **Invokes Claude CLI** with agent prompt (via `llm_adapter.rb`)
2. **Runs domain judges** in parallel (backend, frontend, tests, security)
3. **Scores output** on 200-point scale (50 points per domain)
4. **Pass threshold:** 140/200 (70%)

Tests verify agents:
- Reference appropriate superpowers workflows
- Load correct Rails-AI consolidated skills
- Delegate to specialized agents
- Enforce TEAM_RULES.md
- Produce concrete implementation plans

### Interpreting Results

**PASS (≥140/200):** Agent produced quality implementation with proper workflows
**FAIL (<140/200):** Check scores by domain to identify gaps:
- **Backend:** Model/controller implementation quality
- **Frontend:** View/Hotwire/styling implementation
- **Tests:** Test coverage and TDD adherence
- **Security:** Security considerations and validation

Common failure patterns:
- Agent asks clarifying questions instead of implementing (0/200)
- Missing TDD workflow references
- Incomplete skill loading
- Missing TEAM_RULES.md enforcement

---

## Test Coverage

### 1. Bootstrap Test (`bootstrap_test.rb`)
**Purpose:** Basic functionality test for the new architect agent structure

**Tests:**
- Architect references superpowers workflows
- Architect delegates to developer agent (not separate backend/frontend)
- Architect loads rails-ai skills from skills-new/
- Architect enforces TEAM_RULES.md

**Expected Result:** PASS

---

### 2. Developer Agent Test (`developer_agent_test.rb`)
**Purpose:** Tests the unified full-stack developer agent

**Tests:**
- Handles both backend and frontend work (full-stack)
- References superpowers:test-driven-development for TDD process
- Uses rails-ai backend skills (models, controllers)
- Uses rails-ai frontend skills (views, hotwire, styling)
- Uses rails-ai testing skills (testing)
- Follows RED-GREEN-REFACTOR workflow
- Creates models, controllers, views, and tests end-to-end

**Agent Under Test:** @developer (new unified agent)

**Replaces:** Old @backend + @frontend + @debug agents

**Expected Result:** PASS

---

### 3. UAT Agent Test (`uat_agent_test.rb`)
**Purpose:** Tests the UAT/QA agent with broader quality focus

**Tests:**
- Writes comprehensive test suites
- Validates features meet requirements
- References superpowers:test-driven-development
- Uses rails-ai testing skill
- Includes model, controller, integration, and security tests
- References quality gates (bin/ci)
- Scores high on tests domain (>=40/50)

**Agent Under Test:** @uat (renamed from @tests with broader QA focus)

**Expected Result:** PASS

---

### 4. DevOps Agent Test (`devops_agent_test.rb`)
**Purpose:** Tests the new DevOps agent for infrastructure and deployment

**Tests:**
- Handles Docker configuration
- Configures Rails 8 Solid Stack for production
- Creates CI/CD pipelines (GitHub Actions)
- Manages environment configuration and credentials
- Enforces TEAM_RULES.md Rule #1 (no Sidekiq/Redis)
- Uses rails-ai infrastructure skills (configuration, jobs)

**Agent Under Test:** @devops (new agent)

**Expected Result:** PASS

---

### 5. Security Agent Test (`security_agent_test.rb`)
**Purpose:** Tests the refactored security agent with superpowers integration

**Tests:**
- Audits code for OWASP Top 10 vulnerabilities
- References superpowers:systematic-debugging for investigation
- Uses rails-ai security skill
- Identifies SQL injection, XSS, command injection, and file upload vulnerabilities
- Provides remediation guidance
- Scores vulnerabilities by severity (Critical/High/Medium/Low)
- Scores high on security domain (>=40/50)

**Agent Under Test:** @security (refactored to use superpowers)

**Expected Result:** PASS

---

### 6. Superpowers Integration Test (`superpowers_integration_test.rb`)
**Purpose:** Tests architect's integration with superpowers workflows

**Tests:**
- References superpowers:brainstorming for design refinement
- References superpowers:writing-plans for planning
- References superpowers:executing-plans or subagent-driven-development for execution
- References superpowers:test-driven-development for TDD enforcement
- References superpowers:verification-before-completion for validation
- Loads rails-ai skills for Rails-specific context
- Delegates to specialized agents (@developer, @uat)
- Enforces TEAM_RULES.md

**Agent Under Test:** @architect (refactored to reference superpowers)

**Expected Result:** PASS

---

### 7. Skill Loading Test (`skill_loading_test.rb`)
**Purpose:** Tests that skills load from new skills-new/ flat structure

**Tests:**
- Loads skills from skills/ directory (not old skills/ hierarchy)
- References skills with rails-ai: prefix
- Skills reference superpowers for process (testing → superpowers:test-driven-development)
- Delegates to appropriate agents (@developer, @security)
- Does NOT reference old skills/frontend or skills/backend structure

**Expected Result:** PASS

---

## Running Tests

### Run all new integration tests:
```bash
ruby -Itest test-new/integration/*_test.rb
```

### Run individual test:
```bash
ruby -Itest test-new/integration/bootstrap_test.rb
```

### Run with verbose output:
```bash
ruby -Itest test-new/integration/bootstrap_test.rb --verbose
```

---

## Test Pattern Changes from Old Structure

### Old Structure (test/integration/)
- **Agents:** @backend, @frontend, @tests, @security, @debug, @plan, @architect
- **Skills:** Loaded from skills/frontend/, skills/backend/, etc.
- **No superpowers integration**
- **Architect implemented orchestration**

### New Structure (test/integration/)
- **Agents:** @architect, @developer, @security, @devops, @uat (5 domain-based agents)
- **Skills:** Loaded from skills/ (flat namespace with rails-ai: prefix)
- **Superpowers integration:** Architect references superpowers workflows
- **Architect coordinates:** Delegates to superpowers for orchestration

---

## Key Assertions in New Tests

### 1. Superpowers References
```ruby
assert_match(/superpowers:test-driven-development/,
             agent_output,
             "Should reference superpowers workflows")
```

### 2. New Agent Delegation
```ruby
assert_match(/@developer/,  # Not @backend or @frontend
             agent_output,
             "Should delegate to unified developer agent")
```

### 3. Skills Loading
```ruby
assert_match(/rails-ai:testing/,  # With rails-ai: prefix
             agent_output,
             "Should load from skills/ with prefix")
```

### 4. No Old Structure References
```ruby
refute_match(/skills\/frontend|skills\/backend/,
             agent_output,
             "Should NOT reference old directory structure")
```

---

## Test Infrastructure

All integration tests inherit from `AgentIntegrationTestCase` (in test/support/agent_integration_test_case.rb).

**Common functionality:**
- Invokes Claude CLI with agent prompts
- Runs parallel domain judges (backend, frontend, tests, security)
- Parses and aggregates scores
- Logs results to tmp/test/integration/
- Updates TESTING.md results table

**Test structure:**
```ruby
class MyTest < AgentIntegrationTestCase
  def scenario_name
    "test_name"
  end

  def agent_prompt
    <<~PROMPT
      @architect

      Your test prompt here
    PROMPT
  end

  def expected_pass
    true  # or false
  end

  # Optional: Add custom assertions
  def test_scenario
    judgment = super  # Run base test

    # Add custom assertions
    assert_match(/pattern/, judgment[:agent_output])

    judgment
  end
end
```

---

## Migration from Old Tests

When migrating from old integration tests:

1. **Update agent references:**
   - `@backend` + `@frontend` → `@developer`
   - `@tests` → `@uat`
   - Add `@devops` for infrastructure tests

2. **Add superpowers assertions:**
   - Check for superpowers:test-driven-development
   - Check for superpowers:systematic-debugging
   - Check for superpowers workflow references in architect

3. **Update skill loading assertions:**
   - Use `rails-ai:` prefix
   - Check skills/ loading
   - Verify superpowers references in skills

4. **Update TEAM_RULES.md enforcement:**
   - Rule #1: No Sidekiq/Redis (use SolidQueue/SolidCache)
   - Rule #2: No RSpec (use Minitest)
   - Rule #4: TDD always (RED-GREEN-REFACTOR)

---

## Success Criteria (Phase 3 - Migration Plan Section 8.2)

- [ ] Bootstrap test passes (architect coordination)
- [ ] Developer agent test passes (full-stack implementation)
- [ ] UAT agent test passes (comprehensive testing)
- [ ] DevOps agent test passes (infrastructure)
- [ ] Security agent test passes (auditing with superpowers)
- [ ] Superpowers integration test passes (all workflows)
- [ ] Skill loading test passes (skills-new/ structure)

All tests should pass before Phase 4 (Cutover & Cleanup) begins.

---

## Related Documentation

- Migration Plan: `/home/dave/Projects/rails-ai/docs/skills-migrate-plan.md` (Section 8.2)
- Agent Refactoring: `/home/dave/Projects/rails-ai/agents-refactored/REFACTOR_SUMMARY.md`
- Old Integration Tests: `/home/dave/Projects/rails-ai/test/integration/`
- Test Infrastructure: `/home/dave/Projects/rails-ai/test/support/agent_integration_test_case.rb`
