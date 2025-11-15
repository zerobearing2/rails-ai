# frozen_string_literal: true

require_relative "../../test/support/agent_integration_test_case"

# Integration test for UAT/QA agent
# Tests the new UAT agent that replaces tests agent with broader QA focus
#
# Expected behavior: UAT agent should:
# - Write comprehensive test suites
# - Validate features meet requirements
# - Ensure quality gates pass (bin/ci)
# - Follow TDD process (RED-GREEN-REFACTOR)
# - Reference superpowers:test-driven-development
# - Use rails-ai:tdd-minitest for Rails patterns
class UatAgentTest < AgentIntegrationTestCase
  def scenario_name
    "uat_agent_testing"
  end

  def agent_prompt
    <<~PROMPT
      @uat

      I need comprehensive tests for a User authentication system. The developer has implemented:

      **User model:**
      ```ruby
      class User < ApplicationRecord
        has_secure_password
        validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
        validates :name, presence: true, length: { minimum: 2, maximum: 100 }
      end
      ```

      **SessionsController:**
      - create (login)
      - destroy (logout)

      Create test suite including:
      1. **Model tests** - validations, password encryption
      2. **Controller tests** - login flow, logout flow, invalid credentials
      3. **Integration tests** - full user authentication flow
      4. **Security tests** - ensure passwords are encrypted, session management is secure

      Follow TDD best practices and ensure all quality gates pass.
    PROMPT
  end

  def expected_pass
    true
  end

  def test_scenario
    judgment = super

    agent_output = judgment[:agent_output]

    # Should reference superpowers TDD
    assert_match(/superpowers:test-driven-development/,
                 agent_output,
                 "UAT should reference superpowers:test-driven-development")

    # Should use rails-ai testing skills
    assert_match(/rails-ai:(tdd-minitest|fixtures|model-testing|test-helpers)/,
                 agent_output,
                 "UAT should use rails-ai testing skills")

    # Should include TDD workflow
    assert_match(/RED.*GREEN.*REFACTOR|TDD|test.*first/i,
                 agent_output,
                 "UAT should follow TDD workflow")

    # Should include model tests
    assert_match(/test.*User.*validation|validates.*email/,
                 agent_output,
                 "UAT should create model validation tests")

    # Should include controller tests
    assert_match(/test.*sessions.*create|test.*login/i,
                 agent_output,
                 "UAT should create controller tests")

    # Should include integration tests
    assert_match(/integration|full.*flow/i,
                 agent_output,
                 "UAT should create integration tests")

    # Should reference quality gates (bin/ci)
    assert_match(%r{bin/ci|quality.*gate|all.*tests.*pass}i,
                 agent_output,
                 "UAT should reference quality gates")

    # Should include security considerations
    assert_match(/password.*encrypt|secure|session/i,
                 agent_output,
                 "UAT should include security test considerations")

    # Tests score should be high (at least 40/50)
    tests_score = judgment.dig(:domain_scores, "tests", :score)

    assert_operator tests_score, :>=, 40,
                    "UAT agent should score high on tests domain, got #{tests_score}/50"

    judgment
  end
end
