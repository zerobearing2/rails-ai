# frozen_string_literal: true

require_relative "../support/agent_integration_test_case"

# Bootstrap integration test
# Simple test to verify the integration test harness is working correctly
# Uses a trivial prompt (count to 10) to test LLM adapter and streaming
# SKIPS expensive judging since that's not needed for infrastructure verification
# Run this test to verify the test infrastructure before running expensive agent scenarios
class BootstrapTest < AgentIntegrationTestCase
  def scenario_name
    "bootstrap"
  end

  def system_prompt
    <<~PROMPT
      You are a helpful assistant testing the integration test framework.
      Keep your responses short and simple.
    PROMPT
  end

  def agent_prompt
    <<~PROMPT
      Please count from 1 to 10, with each number on its own line.

      Just output the numbers, nothing else.
    PROMPT
  end

  def expected_pass
    true
  end

  # Override test to skip expensive judging and just test LLM adapter + streaming
  def test_scenario
    start_time = Time.now
    setup_live_logging

    log_live "\n" + ("=" * 80)
    log_live "Bootstrap Integration Test: #{scenario_name}"
    log_live ("=" * 80)

    # Step 1: Run the agent
    log_live "Step 1/1: Running agent (testing LLM adapter + streaming)..."
    log_live "  Invoking #{llm_adapter.name} with agent prompt..."
    log_live "  " + ("-" * 76)

    agent_start = Time.now
    agent_output = llm_adapter.execute(
      prompt: agent_prompt,
      system_prompt: system_prompt,
      streaming: true,
      on_chunk: ->(text) { log_live(text, newline: false) }
    )
    agent_duration = Time.now - agent_start

    log_live ""
    log_live "  " + ("-" * 76)
    log_live "✓ Agent completed in #{format_duration(agent_duration)}"

    # Skip judging - not needed for bootstrap test
    log_live "\nSkipping judging (bootstrap test only verifies infrastructure)"

    total_duration = Time.now - start_time
    log_live "\nTotal duration: #{format_duration(total_duration)}"

    # Basic assertions to verify the test harness is working
    (1..10).each do |num|
      assert_match(/#{num}/, agent_output, "Agent output should contain number #{num}")
    end

    assert agent_output.length < 500, "Bootstrap output should be short (< 500 chars)"

    log_live "\n" + ("=" * 80)
    log_live "✓ BOOTSTRAP TEST PASSED"
    log_live ("=" * 80)
    log_live "\nIntegration test harness is working correctly:"
    log_live "  ✓ LLM adapter connectivity"
    log_live "  ✓ Real-time streaming output"
    log_live "  ✓ Live logging"
    log_live "\nYou can now run full agent scenarios with confidence."
    log_live ""

    # Return minimal judgment structure for compatibility
    {
      scenario: scenario_name,
      agent_output: agent_output,
      timing: {
        agent_duration: agent_duration,
        total_duration: total_duration
      },
      bootstrap: true
    }
  end
end
