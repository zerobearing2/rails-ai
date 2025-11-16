# frozen_string_literal: true

require_relative "../support/agent_integration_test_case"

# Bootstrap integration test for new agent structure
# Tests that architect agent:
# - References superpowers workflows
# - Delegates to specialized agents (developer, security, devops, uat)
# - Loads skills from skills-new/ directory
# - Enforces TEAM_RULES.md
class NewBootstrapTest < AgentIntegrationTestCase
  def scenario_name
    "new_bootstrap"
  end

  def agent_prompt
    <<~PROMPT
      @architect

      Hey, I need to add a simple welcome page for our Rails app. Just a basic homepage that shows "Welcome to Rails" when someone visits the root URL.

      This should be straightforward - just need a controller action and a view. No database or models needed for this. Oh, and can you include a controller test to make sure the page renders?

      Thanks!
    PROMPT
  end

  def expected_pass
    true # Should pass - minimal feature with all domains covered
  end

  # Custom assertions for new structure
  def test_scenario
    judgment = super

    agent_output = judgment[:agent_output]

    # Should reference superpowers workflows
    assert_match(/superpowers:(test-driven-development|verification-before-completion|writing-plans)/,
                 agent_output,
                 "Architect should reference superpowers workflows")

    # Should delegate to developer agent (not backend/frontend separately)
    assert_match(/@developer|Task.*developer/i, agent_output,
                 "Architect should delegate to @developer agent")

    # Should load rails-ai skills from skills/
    assert_match(/rails-ai:(controllers|testing|views|models)/,
                 agent_output,
                 "Architect should load rails-ai consolidated skills")

    # Should enforce TEAM_RULES.md
    assert_match(/TEAM_RULES|Rule #|TDD|RED-GREEN-REFACTOR/i,
                 agent_output,
                 "Architect should reference TEAM_RULES.md")

    judgment
  end
end
