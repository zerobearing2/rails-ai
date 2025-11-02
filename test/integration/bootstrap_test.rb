# frozen_string_literal: true

require_relative "../support/agent_integration_test_case"

# Bootstrap integration test
# Simple test to verify the integration test harness is working correctly
# Uses a trivial Rails plan to test LLM adapter, streaming, and judging
# Fast and cheap - tests full flow without expensive agent scenarios
# Run this test to verify the test infrastructure before running expensive agent scenarios
class BootstrapTest < AgentIntegrationTestCase
  def scenario_name
    "bootstrap"
  end

  def system_prompt
    <<~PROMPT
      You are a Rails architect helping plan a simple feature.
      Keep your response VERY short and simple - just outline the basics.
    PROMPT
  end

  def agent_prompt
    <<~PROMPT
      Plan a simple "Hello World" feature for a Rails app:
      - A single page that displays "Hello World"
      - Keep it extremely simple (1-2 sentences per section)

      Just give a brief plan covering:
      - Controller action needed
      - View file needed
      - Route needed
    PROMPT
  end

  def expected_pass
    false  # Minimal "Hello World" plan won't score high enough to pass
  end

  # Use the standard test flow to test full judging pipeline
  # This tests: agent execution, file-based evaluation, parallel judging, scoring
  # No custom implementation needed - inherits from AgentIntegrationTestCase
end
