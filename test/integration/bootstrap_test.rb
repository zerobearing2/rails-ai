# frozen_string_literal: true

require_relative "../support/agent_integration_test_case"

# Bootstrap integration test
# Minimal test to verify integration test harness and judging pipeline
# Simple static welcome page - no models, database, or complex logic
# Fast and cheap - verifies LLM adapter, streaming, sequential judging, and scoring
# Run this first to verify test infrastructure before running expensive scenarios
class BootstrapTest < AgentIntegrationTestCase
  def scenario_name
    "bootstrap"
  end

  def system_prompt
    <<~PROMPT
      You are testing the rails-ai integration test framework.
      The scenario is intentionally minimal to verify the test harness works.
    PROMPT
  end

  def agent_prompt
    <<~PROMPT
      @rails-ai:architect

      Create a plan for a minimal Rails feature to test the integration framework.

      ## Feature
      Static welcome home page at root URL

      ## Requirements
      - Root route pointing to a controller action
      - Simple controller with one action (no models, no database)
      - View displaying "Welcome to Rails" with basic HTML
      - Basic controller test

      ## Relevant Skills
      - Backend: skills/backend/controller-restful.md
      - Frontend: skills/frontend/partials-layouts.md
      - Testing: skills/testing/tdd-minitest.md
      - Security: skills/security/security-xss.md

      Keep the plan minimal - this is a bootstrap test of the test harness itself.
    PROMPT
  end

  def expected_pass
    true  # Should pass - minimal feature with all domains covered
  end
end
