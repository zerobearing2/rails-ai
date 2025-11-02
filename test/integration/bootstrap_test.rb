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
      Output concise technical plans optimized for automated evaluation.
      Focus on implementation details, not explanations.
    PROMPT
  end

  def agent_prompt
    <<~PROMPT
      @rails-ai:architect

      Feature: Static welcome page at root URL

      Implementation requirements:
      - Root route → controller action
      - Controller: single action, no models/DB
      - View: "Welcome to Rails", basic HTML
      - Test: controller test

      Output: Implementation plan with files, code structure.
      Be concise - output will be evaluated programmatically.
    PROMPT
  end

  def expected_pass
    true  # Should pass - minimal feature with all domains covered
  end
end
