# frozen_string_literal: true

require_relative "../../test/support/agent_integration_test_case"

# Integration test for developer agent (full-stack Rails)
# Tests the new unified developer agent that replaces backend + frontend + debug agents
#
# Expected behavior: Developer agent should:
# - Handle both backend and frontend work (full-stack)
# - Follow TDD (RED-GREEN-REFACTOR)
# - Reference superpowers:test-driven-development for process
# - Use rails-ai skills for implementation patterns
# - Create models, controllers, views, and tests
class DeveloperAgentTest < AgentIntegrationTestCase
  def scenario_name
    "developer_agent_fullstack"
  end

  def agent_prompt
    <<~PROMPT
      @developer

      Create a simple Task model for a todo app with the following:

      **Backend:**
      - Task model with: title (required, max 200 chars), description (optional), completed (boolean, default false)
      - Validation for title presence and length
      - Scope for completed and pending tasks

      **Frontend:**
      - Tasks controller with index, show, create, update actions (RESTful)
      - Index view showing list of tasks
      - Use Hotwire Turbo for instant updates

      **Tests:**
      - Model tests for validations and scopes
      - Controller tests for all actions
      - Follow TDD (write tests first)

      This is a full-stack feature - you should handle everything end-to-end.
    PROMPT
  end

  def expected_pass
    true
  end

  def test_scenario
    judgment = super

    agent_output = judgment[:agent_output]

    # Should reference superpowers TDD workflow
    assert_match(/superpowers:test-driven-development/,
                 agent_output,
                 "Developer should reference superpowers:test-driven-development")

    # Should use rails-ai backend skills
    assert_match(/rails-ai:(activerecord-patterns|controller-restful)/,
                 agent_output,
                 "Developer should use rails-ai backend skills")

    # Should use rails-ai frontend skills
    assert_match(/rails-ai:(hotwire-turbo|view-helpers)/,
                 agent_output,
                 "Developer should use rails-ai frontend skills")

    # Should use rails-ai testing skills
    assert_match(/rails-ai:(tdd-minitest|fixtures|model-testing)/,
                 agent_output,
                 "Developer should use rails-ai testing skills")

    # Should include TDD workflow
    assert_match(/RED.*GREEN.*REFACTOR|failing test.*first/i,
                 agent_output,
                 "Developer should follow TDD workflow")

    # Should include model code
    assert_match(/class Task < ApplicationRecord/,
                 agent_output,
                 "Developer should create Task model")

    # Should include controller code
    assert_match(/class TasksController < ApplicationController/,
                 agent_output,
                 "Developer should create TasksController")

    # Should include tests
    assert_match(/test.*Task|class TaskTest/,
                 agent_output,
                 "Developer should create tests")

    # Should include Hotwire/Turbo
    assert_match(/turbo|Turbo/,
                 agent_output,
                 "Developer should use Hotwire Turbo")

    judgment
  end
end
