# frozen_string_literal: true

require_relative "../../test/support/agent_integration_test_case"

# Integration test for superpowers workflows integration
# Tests that architect agent properly references and uses superpowers workflows
#
# Expected behavior: Architect should:
# - Reference superpowers:brainstorming for design
# - Reference superpowers:writing-plans for planning
# - Reference superpowers:executing-plans for batch execution
# - Reference superpowers:test-driven-development for TDD enforcement
# - Reference superpowers:systematic-debugging for debugging
# - Reference superpowers:requesting-code-review for review
# - Reference superpowers:verification-before-completion for validation
class SuperpowersIntegrationTest < AgentIntegrationTestCase
  def scenario_name
    "superpowers_workflows"
  end

  def agent_prompt
    <<~PROMPT
      @architect

      I have a rough idea for a feature: "Users should be able to export their data to CSV"

      Can you help me:
      1. Refine this idea into a concrete design
      2. Create an implementation plan
      3. Coordinate development with proper TDD
      4. Ensure we follow all quality gates

      This should demonstrate your full workflow orchestration capabilities.
    PROMPT
  end

  def expected_pass
    true
  end

  def test_scenario
    judgment = super

    agent_output = judgment[:agent_output]

    # Should reference brainstorming workflow
    assert_match(/superpowers:brainstorming/,
                 agent_output,
                 "Architect should reference superpowers:brainstorming for design refinement")

    # Should reference planning workflow
    assert_match(/superpowers:writing-plans/,
                 agent_output,
                 "Architect should reference superpowers:writing-plans for planning")

    # Should reference execution workflow (either batch or subagent-driven)
    assert_match(/superpowers:(executing-plans|subagent-driven-development)/,
                 agent_output,
                 "Architect should reference superpowers execution workflow")

    # Should reference TDD workflow
    assert_match(/superpowers:test-driven-development/,
                 agent_output,
                 "Architect should reference superpowers:test-driven-development")

    # Should reference verification workflow
    assert_match(/superpowers:verification-before-completion/,
                 agent_output,
                 "Architect should reference superpowers:verification-before-completion")

    # Should still load rails-ai skills for Rails-specific context
    assert_match(/rails-ai:/,
                 agent_output,
                 "Architect should load rails-ai skills for Rails context")

    # Should delegate to specialized agents
    assert_match(/@developer|@uat|Task/,
                 agent_output,
                 "Architect should delegate to specialized agents")

    # Should enforce TEAM_RULES.md
    assert_match(/TEAM_RULES|Rule #/,
                 agent_output,
                 "Architect should enforce TEAM_RULES.md")

    judgment
  end
end
