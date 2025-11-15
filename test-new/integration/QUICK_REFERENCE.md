# Quick Reference - Integration Tests

## Test Files

| File | Class | Scenario | Agent(s) Tested | Lines |
|------|-------|----------|-----------------|-------|
| bootstrap_test.rb | NewBootstrapTest | new_bootstrap | @architect | 60 |
| developer_agent_test.rb | DeveloperAgentTest | developer_agent_fullstack | @developer | 105 |
| uat_agent_test.rb | UatAgentTest | uat_agent_testing | @uat | 109 |
| devops_agent_test.rb | DevopsAgentTest | devops_agent_infrastructure | @devops | 94 |
| security_agent_test.rb | SecurityAgentTest | security_agent_audit | @security | 111 |
| superpowers_integration_test.rb | SuperpowersIntegrationTest | superpowers_workflows | @architect | 94 |
| skill_loading_test.rb | SkillLoadingTest | skill_loading_new_structure | @architect, @developer, @security | 78 |

**Total:** 7 test files, 651 lines of code

## Running Tests

```bash
# All tests
ruby -Itest test-new/integration/*_test.rb

# Individual tests
ruby -Itest test-new/integration/bootstrap_test.rb
ruby -Itest test-new/integration/developer_agent_test.rb
ruby -Itest test-new/integration/uat_agent_test.rb
ruby -Itest test-new/integration/devops_agent_test.rb
ruby -Itest test-new/integration/security_agent_test.rb
ruby -Itest test-new/integration/superpowers_integration_test.rb
ruby -Itest test-new/integration/skill_loading_test.rb

# With verbose output
ruby -Itest test-new/integration/bootstrap_test.rb --verbose
```

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

### Skills Loading
- `rails-ai:activerecord-patterns`
- `rails-ai:controller-restful`
- `rails-ai:hotwire-turbo`
- `rails-ai:tdd-minitest`
- `rails-ai:fixtures`
- `rails-ai:model-testing`
- `rails-ai:security-xss`
- `rails-ai:security-sql-injection`
- `rails-ai:security-command-injection`
- `rails-ai:security-file-uploads`
- `rails-ai:docker`
- `rails-ai:solid-stack`
- `rails-ai:credentials`
- `rails-ai:environment-config`

### TEAM_RULES.md Enforcement
- Rule #1: No Sidekiq/Redis (use SolidQueue/SolidCache)
- Rule #2: No RSpec (use Minitest)
- Rule #4: TDD Always (RED-GREEN-REFACTOR)

## Expected Results

All tests should **PASS**:
- ✅ bootstrap_test.rb
- ✅ developer_agent_test.rb
- ✅ uat_agent_test.rb
- ✅ devops_agent_test.rb
- ✅ security_agent_test.rb
- ✅ superpowers_integration_test.rb
- ✅ skill_loading_test.rb

## Phase 3 Validation

These tests correspond to Migration Plan Section 10.3 (Phase 3: Integration & Validation):

**Day 1-2: Superpowers Integration Testing**
- ✅ `superpowers_integration_test.rb` - All workflows

**Day 3: Agent Integration Testing**
- ✅ `developer_agent_test.rb` - Full-stack developer
- ✅ `uat_agent_test.rb` - Testing/QA
- ✅ `devops_agent_test.rb` - Infrastructure
- ✅ `security_agent_test.rb` - Security with superpowers

**Day 4: Bootstrap & Skill Loading**
- ✅ `bootstrap_test.rb` - Basic coordination
- ✅ `skill_loading_test.rb` - Skills-new/ structure
