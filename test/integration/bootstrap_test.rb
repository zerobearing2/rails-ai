# frozen_string_literal: true

require_relative "../support/agent_integration_test_case"

# Bootstrap integration test
# Simple test to verify the integration test harness is working correctly
# Uses a basic but complete Rails plan to test LLM adapter, streaming, and judging
# Fast and cheap - tests full flow without expensive agent scenarios
# Run this test to verify the test infrastructure before running expensive agent scenarios
class BootstrapTest < AgentIntegrationTestCase
  def scenario_name
    "bootstrap"
  end

  def system_prompt
    <<~PROMPT
      You are a Rails architect creating a simple but complete implementation plan.
      Be thorough but concise.
    PROMPT
  end

  def agent_prompt
    <<~PROMPT
      Create an implementation plan for a basic Rails feature:

      Feature: Display a welcome page with user greeting

      Requirements:
      - WelcomeController with index action
      - View displaying "Hello, [User Name]!"
      - Route for welcome page
      - Controller tests

      Apply relevant skills from:
      - Backend: skills/backend/controller-restful.md, skills/backend/antipattern-fat-controllers.md
      - Frontend: skills/frontend/partials-layouts.md, skills/frontend/view-helpers.md
      - Testing: skills/testing/tdd-minitest.md
      - Security: skills/security/security-xss.md, skills/security/security-csrf.md

      Provide complete plan covering all domains.
    PROMPT
  end

  def expected_pass
    true  # Should pass with a complete plan covering all domains
  end

  # Use the standard test flow to test full judging pipeline
  # This tests: agent execution, file-based evaluation, parallel judging, scoring
  # No custom implementation needed - inherits from AgentIntegrationTestCase
end
