# Quick Reference - Integration Tests

## Test Files

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

## Running Tests

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

## Key Assertions by Category

### Superpowers References
- `superpowers:brainstorming` - Design refinement
- `superpowers:writing-plans` - Implementation planning
- `superpowers:executing-plans` - Batch execution
- `superpowers:subagent-driven-development` - Fast iteration
- `superpowers:test-driven-development` - TDD process
- `superpowers:systematic-debugging` - Investigation framework
- `superpowers:verification-before-completion` - Quality validation

### Agent Delegation
- `@architect` - Coordinator (references superpowers)
- `@developer` - Full-stack Rails (replaces @backend + @frontend + @debug)
- `@uat` - Testing/QA (replaces @tests)
- `@devops` - Infrastructure (new)
- `@security` - Security auditing (refactored)

### Skills Loading (Consolidated v0.3.0)
- `rails-ai:controllers` - RESTful controllers, nested resources, strong params
- `rails-ai:models` - ActiveRecord patterns, validations, associations, query/form objects
- `rails-ai:views` - Hotwire, ViewComponent, Tailwind, forms, accessibility
- `rails-ai:testing` - TDD with Minitest, fixtures, mocking, test helpers
- `rails-ai:security` - XSS, SQL injection, CSRF, file uploads, command injection
- `rails-ai:configuration` - Environment config, credentials, initializers, Docker, RuboCop
- `rails-ai:jobs-mailers` - SolidQueue, SolidCache, SolidCable, ActionMailer
- `rails-ai:debugging` - Rails debugging tools + superpowers:systematic-debugging
- `rails-ai:using-rails-ai` - Meta skill for Rails-AI introduction

### TEAM_RULES.md Enforcement
- Rule #1: No Sidekiq/Redis (use SolidQueue/SolidCache)
- Rule #2: No RSpec (use Minitest)
- Rule #4: TDD Always (RED-GREEN-REFACTOR)

## Test Architecture

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

## Interpreting Results

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
