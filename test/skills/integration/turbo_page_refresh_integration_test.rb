# frozen_string_literal: true

require_relative "../skill_test_case"

class TurboPageRefreshIntegrationTest < SkillTestCase
  self.skill_domain = "frontend"
  self.skill_name = "turbo-page-refresh"

  # Skip integration tests by default (slow, requires LLM APIs)
  # Run with: INTEGRATION=1 ruby test/skills/integration/turbo_page_refresh_integration_test.rb
  def skip_unless_integration
    skip "Integration tests disabled (set INTEGRATION=1 to enable)" unless ENV["INTEGRATION"]
  end

  # Test Case 1: Enable Page Refresh with Morph
  def test_agent_can_enable_page_refresh
    skip_unless_integration

    scenario = "I want to add Turbo page refresh with morphing to my Rails app"

    # Simulated agent output (in real test, call actual agent)
    generated_code = <<~CODE
      # app/views/layouts/application.html.erb
      <!DOCTYPE html>
      <html>
        <head>
          <title>My App</title>
          <%= csrf_meta_tags %>
          <%= csp_meta_tag %>
        </head>

        <body data-turbo-refresh-method="morph" data-turbo-refresh-scroll="preserve">
          <%= yield %>
        </body>
      </html>
    CODE

    # Unit-style pattern assertions (fast)
    assert_pattern_present generated_code, /data-turbo-refresh-method="morph"/,
                           "Should add morph attribute to body"

    assert_pattern_present generated_code, /data-turbo-refresh-scroll="preserve"/,
                           "Should preserve scroll position"

    assert_pattern_present generated_code, /<body.*data-turbo/,
                           "Should add attributes to body tag"

    # LLM judge evaluation (slow, comprehensive)
    judge_prompt = create_judge_prompt(
      "turbo-page-refresh",
      scenario,
      generated_code
    )

    result = judge_with_llm(provider: :mock, prompt: judge_prompt)

    assert result["pass"], "LLM judge should pass the generated code"
    assert_operator result["overall_score"], :>=, 4.0, "Overall score should be >= 4.0, got #{result['overall_score']}"
  end

  # Test Case 2: Broadcasting Page Refresh
  def test_agent_can_setup_broadcasting
    skip_unless_integration

    scenario = "Make it so when a feedback is created, all users see it in real-time using page refresh"

    generated_code = <<~CODE
      # app/models/feedback.rb
      class Feedback < ApplicationRecord
        belongs_to :user

        after_create_commit -> { broadcast_refresh_to "feedbacks" }
        after_update_commit -> { broadcast_refresh_to "feedbacks" }
        after_destroy_commit -> { broadcast_refresh_to "feedbacks" }
      end

      # app/views/feedbacks/index.html.erb
      <%= turbo_stream_from "feedbacks" %>

      <div class="feedbacks-list">
        <% @feedbacks.each do |feedback| %>
          <%= render feedback %>
        <% end %>
      </div>
    CODE

    # Pattern assertions
    assert_pattern_present generated_code, /broadcast_refresh_to/,
                           "Should use broadcast_refresh_to"

    assert_pattern_present generated_code, /after_create_commit|after_update_commit/,
                           "Should use callbacks to broadcast"

    assert_pattern_present generated_code, /turbo_stream_from/,
                           "Should subscribe to turbo stream"

    # Should NOT use frame-specific broadcasts
    assert_pattern_absent generated_code, /broadcast_append_to/,
                          "Should not use broadcast_append_to"

    assert_pattern_absent generated_code, /broadcast_replace_to/,
                          "Should not use broadcast_replace_to"

    assert_pattern_absent generated_code, /turbo_frame_tag/,
                          "Should not use turbo_frame_tag for page refresh"

    # LLM evaluation
    result = judge_with_llm(
      provider: :mock,
      prompt: create_judge_prompt("turbo-page-refresh", scenario, generated_code)
    )

    assert result["pass"], "LLM judge should pass the broadcasting code"
  end

  # Test Case 3: Permanent Elements
  def test_agent_preserves_form_state
    skip_unless_integration

    scenario = "My form loses focus when the page refreshes. Fix it."

    generated_code = <<~CODE
      <%= form_with model: @feedback do |form| %>
        <div data-turbo-permanent id="feedback-form">
          <%= form.text_area :content,
                             placeholder: "Your feedback..." %>
          <%= form.submit "Submit" %>
        </div>
      <% end %>
    CODE

    # Pattern assertions
    assert_pattern_present generated_code, /data-turbo-permanent/,
                           "Should use data-turbo-permanent"

    assert_pattern_present generated_code, /data-turbo-permanent.*form/im,
                           "Should wrap form or input with permanent attribute"

    # LLM evaluation
    result = judge_with_llm(
      provider: :mock,
      prompt: create_judge_prompt("turbo-page-refresh", scenario, generated_code)
    )

    assert result["pass"], "LLM judge should approve permanent element usage"
  end

  # Test Case 4: Cross-Validation (Use multiple LLMs)
  def test_cross_validation_with_multiple_llms
    skip_unless_integration
    skip "Cross-validation requires multiple LLM APIs" unless ENV["CROSS_VALIDATE"]

    scenario = "Add Turbo page refresh with morphing"

    generated_code = <<~CODE
      <body data-turbo-refresh-method="morph" data-turbo-refresh-scroll="preserve">
        <%= yield %>
      </body>
    CODE

    # Get judgments from multiple LLMs
    results = cross_validate(scenario, generated_code, "turbo-page-refresh")

    # Check agreement between judges
    assert results[:agreement],
           "OpenAI and Anthropic should agree on pass/fail"

    # Average score should be good
    assert_operator results[:average_score], :>=, 4.0, "Average score across judges should be >= 4.0"

    puts "\n=== Cross-Validation Results ==="
    puts "OpenAI Score: #{results[:openai]['overall_score']}"
    puts "Anthropic Score: #{results[:anthropic]['overall_score']}"
    puts "Average: #{results[:average_score]}"
    puts "Agreement: #{results[:agreement]}"
  end

  # Test Case 5: Antipattern Detection
  def test_agent_avoids_antipatterns
    skip_unless_integration

    scenario = "Show real-time feedback updates"

    # BAD: Using Turbo Frames when page refresh is simpler
    bad_code = <<~CODE
      <%= turbo_frame_tag "feedbacks-list" do %>
        <% @feedbacks.each do |feedback| %>
          <%= turbo_frame_tag dom_id(feedback) do %>
            <%= render feedback %>
          <% end %>
        <% end %>
      <% end %>

      # Model
      after_create_commit do
        broadcast_replace_to "feedbacks",
                             target: dom_id(self),
                             partial: "feedback",
                             locals: { feedback: self }
      end
    CODE

    # Pattern assertions - should detect antipatterns
    antipattern_detected = bad_code.match?(/turbo_frame_tag.*feedbacks/im)

    assert antipattern_detected,
           "Should detect unnecessary frame usage"

    # LLM should score this lower
    result = judge_with_llm(
      provider: :mock,
      prompt: create_judge_prompt("turbo-page-refresh", scenario, bad_code)
    )

    # With mock, we expect it to still pass, but in real LLM it should score lower
    # or fail for using frames when page refresh is simpler
    puts "\n=== Antipattern Detection ==="
    puts "Score: #{result['overall_score']}"
    puts "Issues: #{result['issues'].join(', ')}"
  end

  # Helper: Simulate agent output (replace with actual agent call)
  def call_agent_with_skill(_scenario)
    # TODO: Actually call agent with skill loaded
    # For now, return mock output
    <<~CODE
      <body data-turbo-refresh-method="morph" data-turbo-refresh-scroll="preserve">
        <%= yield %>
      </body>
    CODE
  end
end
