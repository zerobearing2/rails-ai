# frozen_string_literal: true

require_relative "../../test/support/agent_integration_test_case"

# Integration test for skill loading from skills-new/ directory
# Tests that agents properly load and reference skills from the new flat structure
#
# Expected behavior: Agents should:
# - Load skills from skills-new/ directory (not old skills/ hierarchy)
# - Reference skills with rails-ai: prefix
# - Load superpowers skills for workflows
# - Skills should reference superpowers for process, rails-ai for implementation
class SkillLoadingTest < AgentIntegrationTestCase
  def scenario_name
    "skill_loading_new_structure"
  end

  def agent_prompt
    <<~PROMPT
      @architect

      Create a blog post feature with:
      - Post model (title, body, published_at)
      - Hotwire Turbo for instant updates
      - TDD with Minitest
      - Security review (XSS prevention)

      This should test that you can load skills from the new skills-new/ structure.
    PROMPT
  end

  def expected_pass
    true
  end

  def test_scenario
    judgment = super

    agent_output = judgment[:agent_output]

    # Should reference rails-ai skills with prefix
    assert_match(/rails-ai:activerecord-patterns/,
                 agent_output,
                 "Should load rails-ai:activerecord-patterns from skills-new/")

    assert_match(/rails-ai:hotwire-turbo/,
                 agent_output,
                 "Should load rails-ai:hotwire-turbo from skills-new/")

    assert_match(/rails-ai:tdd-minitest/,
                 agent_output,
                 "Should load rails-ai:tdd-minitest from skills-new/")

    assert_match(/rails-ai:security-xss/,
                 agent_output,
                 "Should load rails-ai:security-xss from skills-new/")

    # Skills should reference superpowers for process
    assert_match(/superpowers:test-driven-development/,
                 agent_output,
                 "rails-ai:tdd-minitest should reference superpowers:test-driven-development")

    # Should delegate to appropriate agents
    assert_match(/@developer/,
                 agent_output,
                 "Should delegate to @developer for implementation")

    assert_match(/@security/,
                 agent_output,
                 "Should delegate to @security for security review")

    # Should NOT reference old skills structure (frontend/backend directories)
    refute_match(%r{skills/frontend|skills/backend},
                 agent_output,
                 "Should NOT reference old skills directory structure")

    judgment
  end
end
