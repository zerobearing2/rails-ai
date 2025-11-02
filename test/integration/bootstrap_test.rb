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
      Create a simple implementation plan for a basic Rails feature:

      Feature: Display a welcome page with user greeting

      Requirements:
      - Create a WelcomeController with an index action
      - Create a view that displays "Hello, [User Name]!"
      - Add a route for the welcome page
      - Basic tests for the controller action

      Provide a complete but concise plan covering:
      - Backend (controller, any models if needed)
      - Frontend (view with proper structure)
      - Tests (what to test)
      - Security (any basic considerations)

      Keep it simple but cover all domains properly.
    PROMPT
  end

  def expected_pass
    true  # Should pass with a complete plan covering all domains
  end

  # Use the standard test flow to test full judging pipeline
  # This tests: agent execution, file-based evaluation, parallel judging, scoring
  # No custom implementation needed - inherits from AgentIntegrationTestCase
end
