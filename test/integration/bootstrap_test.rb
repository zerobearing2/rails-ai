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

  def agent_prompt
    <<~PROMPT
      @rails-ai:architect

      Hey, I need to add a simple welcome page for our Rails app. Just a basic homepage that shows "Welcome to Rails" when someone visits the root URL.

      This should be straightforward - just need a controller action and a view. No database or models needed for this. Oh, and can you include a controller test to make sure the page renders?

      Thanks!
    PROMPT
  end

  def expected_pass
    true  # Should pass - minimal feature with all domains covered
  end
end
