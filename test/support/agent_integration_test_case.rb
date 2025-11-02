# frozen_string_literal: true

require_relative "../test_helper"
require_relative "llm_adapter"
require "tmpdir"
require "fileutils"

# Base class for agent integration tests
# Provides common functionality for:
# - Invoking claude CLI with agent prompts
# - Running parallel domain judges
# - Parsing and aggregating scores
# - Logging test results
#
# Subclasses should:
# - Define scenario_name
# - Define system_prompt
# - Define agent_prompt
# - Define expected_pass (true/false)
# - Optionally define custom assertions in test_scenario method
class AgentIntegrationTestCase < Minitest::Test
  DOMAINS = %w[backend frontend tests security].freeze
  MAX_SCORE_PER_DOMAIN = 50
  MAX_TOTAL_SCORE = DOMAINS.size * MAX_SCORE_PER_DOMAIN # 200
  PASS_THRESHOLD = (MAX_TOTAL_SCORE * 0.7).to_i # 140

  # Tell Minitest not to run this base class as a test
  def self.runnable_methods
    if self == AgentIntegrationTestCase
      []
    else
      super
    end
  end

  # Override in subclass
  def scenario_name
    raise NotImplementedError, "Subclass must define scenario_name"
  end

  # Default system prompt for integration tests - can be overridden in subclasses
  def system_prompt
    <<~PROMPT
      You are planning features for a Rails 8.1 application (NOT the rails-ai project itself).

      This is a test scenario - provide implementation plans even if the current directory
      doesn't have Rails app structure. Assume you're planning for a standard Rails app.

      Output concise technical plans with code. Do not ask for clarification.
    PROMPT
  end

  def agent_prompt
    raise NotImplementedError, "Subclass must define agent_prompt"
  end

  def expected_pass
    raise NotImplementedError, "Subclass must define expected_pass (true/false)"
  end

  # LLM adapter - can be overridden to use different LLM
  def llm_adapter
    @llm_adapter ||= ClaudeAdapter.new
  end

  # Main test method - subclasses can override to add custom assertions
  def test_scenario
    start_time = Time.now
    setup_live_logging

    log_live "\n" + ("=" * 80)
    log_live "Integration Test: #{scenario_name}"
    log_live ("=" * 80)
    log_live ""

    # Run the agent
    log_live "Step 1/2: Running agent (invoking Claude CLI)..."
    agent_start = Time.now
    agent_output = run_agent
    agent_duration = Time.now - agent_start
    log_live "✓ Agent completed in #{format_duration(agent_duration)}"
    log_live ""

    # Judge the output
    log_live "Step 2/2: Running judges (4 sequential domain evaluations)..."
    judge_start = Time.now
    judgment = judge_output(agent_output)
    judge_duration = Time.now - judge_start
    log_live "✓ Judges completed in #{format_duration(judge_duration)}"
    log_live ""

    total_duration = Time.now - start_time

    # Add timing data to judgment
    judgment[:timing] = {
      agent_duration: agent_duration,
      judge_duration: judge_duration,
      total_duration: total_duration
    }

    # Log results
    log_live "Results:"
    log_live "  Total Score: #{judgment[:total_score]}/#{judgment[:max_score]} (#{judgment[:percentage]}%)"
    judgment[:domain_scores].each do |domain, result|
      log_live "  - #{domain.capitalize}: #{result[:score]}/#{MAX_SCORE_PER_DOMAIN}"
    end
    log_live "  Result: #{judgment[:pass] ? 'PASS ✓' : 'FAIL ✗'}"
    log_live "  Total Duration: #{format_duration(total_duration)}"
    log_live ""

    log_judgment(judgment)

    # Assert pass/fail matches expectation
    if expected_pass
      assert judgment[:pass], build_failure_message(judgment, "Expected PASS but got FAIL")
    else
      refute judgment[:pass], build_failure_message(judgment, "Expected FAIL but got PASS")
    end

    # Return judgment for subclass assertions
    judgment
  end

  private

  def run_agent
    log_live "  Invoking #{llm_adapter.name} with agent prompt..."
    log_live "  (This may take several minutes...)"

    # Stream to log file but not console
    agent_output = llm_adapter.execute(
      prompt: agent_prompt,
      system_prompt: system_prompt,
      streaming: true,
      on_chunk: ->(text) { log_live(text, newline: false, console: false) }
    )

    log_live "  ✓ Agent response received"

    agent_output
  rescue StandardError => e
    log_live "  ✗ ERROR: #{llm_adapter.name} failed!"
    log_live ""
    log_live "Error: #{e.message}"
    raise
  end

  def judge_output(agent_output)
    # Run parallel domain judges
    domain_judgments = run_parallel_judges(agent_output)

    # Combine scores
    total_score = domain_judgments.values.sum { |j| j[:score] }
    percentage = (total_score * 100.0 / MAX_TOTAL_SCORE).round
    pass = total_score >= PASS_THRESHOLD

    {
      timestamp: Time.now,
      scenario: scenario_name,
      git_sha: git_sha,
      git_branch: git_branch,
      domain_scores: domain_judgments,
      total_score: total_score,
      max_score: MAX_TOTAL_SCORE,
      percentage: percentage,
      threshold: PASS_THRESHOLD,
      pass: pass,
      agent_output: agent_output
    }
  end

  def run_parallel_judges(agent_output)
    log_live "  Writing agent output to temp file..."

    # Write agent output to temp file to avoid embedding large text in prompt
    tmp_dir = File.join(ROOT_PATH, "tmp", "test", "integration")
    FileUtils.mkdir_p(tmp_dir)
    agent_output_file = File.join(tmp_dir, "agent_output_#{scenario_name}.md")
    File.write(agent_output_file, agent_output)

    log_live "  Running judges sequentially (4 domain evaluations)..."

    # Run each domain judge sequentially to avoid prompt length issues
    results = {}
    DOMAINS.each_with_index do |domain, index|
      begin
        log_live "  [#{index + 1}/4] Evaluating #{domain}..."

        judge_prompt = build_single_domain_judge_prompt(domain, agent_output_file)

        judge_output = llm_adapter.execute(
          prompt: judge_prompt,
          streaming: true,
          on_chunk: ->(text) { log_live(text, newline: false, console: false) }
        )

        score = parse_score_from_judgment(judge_output, domain)
        results[domain] = {
          domain: domain,
          score: score,
          judgment_text: judge_output
        }

        log_live "  ✓ #{domain.capitalize}: #{score}/#{MAX_SCORE_PER_DOMAIN}"
      rescue StandardError => e
        log_live "  ✗ ERROR: Judge failed for #{domain}!"
        log_live ""
        log_live "Error: #{e.message}"
        raise
      end
    end

    log_live "  ✓ All judges complete"

    results
  end

  def build_single_domain_judge_prompt(domain, agent_output_file)
    judge_prompt = load_judge_prompt(domain)

    <<~PROMPT
      You are evaluating a Rails implementation plan for the #{domain} domain.

      ## Scenario Requirements

      #{agent_prompt}

      ## Agent Output to Evaluate

      #{File.read(agent_output_file)}

      ## Evaluation Criteria

      #{judge_prompt}

      ## IMPORTANT: Output Format

      Provide your evaluation as JSON only (no markdown, no extra text):

      {
        "scores": {
          "criterion_1": <score>,
          "criterion_2": <score>,
          ...
        },
        "total_score": <sum>,
        "max_score": 50,
        "suggestions": [
          "Brief suggestion 1",
          "Brief suggestion 2",
          ...
        ]
      }

      Be concise. Include up to 10 critical suggestions.
    PROMPT
  end


  def parse_score_from_judgment(judgment_text, domain)
    # Try to parse as JSON first
    begin
      # Remove markdown code blocks if present
      json_text = judgment_text.strip
      json_text = json_text.gsub(/^```json?\n/, "").gsub(/\n```$/, "")

      data = JSON.parse(json_text)
      return data["total_score"].to_i if data["total_score"]
    rescue JSON::ParserError
      # Fall back to text parsing
    end

    # Fallback: Look for score in format: "## Backend Total: 45/50" or "Backend Total: 45/50"
    match = judgment_text.match(/##?\s*#{domain.capitalize}\s+Total:\s*(\d+)\/\d+/i)

    if match
      match[1].to_i
    else
      # Try to extract any score pattern
      match = judgment_text.match(/Total:\s*(\d+)\/\d+/)
      match ? match[1].to_i : 0
    end
  end

  def log_judgment(judgment)
    # Ensure tmp directory exists
    log_dir = File.join(ROOT_PATH, "tmp", "test", "integration")
    FileUtils.mkdir_p(log_dir)

    log_file = File.join(log_dir, "JUDGE_LOG.md")

    # Create log file if it doesn't exist
    unless File.exist?(log_file)
      File.write(log_file, <<~HEADER)
        # Agent Integration Test Judge Log

        This file contains a chronological log of all judge evaluations for tracking accuracy and improvement over time.

        Format: Each entry includes timestamp, scenario, git version, scores, and pass/fail result.

        ---

      HEADER
    end

    # Append judgment entry
    File.open(log_file, "a") do |f|
      f.puts "\n## Evaluation: #{judgment[:timestamp].strftime('%Y-%m-%d %H:%M:%S')}"
      f.puts ""
      f.puts "**Scenario**: #{judgment[:scenario]}"
      f.puts "**Git SHA**: #{judgment[:git_sha]}"
      f.puts "**Git Branch**: #{judgment[:git_branch]}"
      f.puts ""
      f.puts "### Timing"
      f.puts ""
      f.puts "- **Agent Duration**: #{format_duration(judgment[:timing][:agent_duration])}"
      f.puts "- **Judge Duration**: #{format_duration(judgment[:timing][:judge_duration])}"
      f.puts "- **Total Duration**: #{format_duration(judgment[:timing][:total_duration])}"
      f.puts ""
      f.puts "### Domain Scores"
      f.puts ""
      judgment[:domain_scores].each do |domain, result|
        f.puts "- **#{domain.capitalize}**: #{result[:score]}/#{MAX_SCORE_PER_DOMAIN}"
      end
      f.puts "- **Total**: #{judgment[:total_score]}/#{judgment[:max_score]} (#{judgment[:percentage]}%)"
      f.puts ""
      f.puts "### Result"
      f.puts ""
      f.puts "**#{judgment[:pass] ? 'PASS' : 'FAIL'}** (Threshold: #{judgment[:threshold]}/#{judgment[:max_score]})"
      f.puts ""
      f.puts "---"
      f.puts ""
    end

    # Also save detailed output to timestamped file
    run_dir = File.join(
      log_dir,
      "runs",
      "#{judgment[:timestamp].strftime('%Y%m%d_%H%M%S')}_#{scenario_name}"
    )
    FileUtils.mkdir_p(run_dir)

    # Save agent output
    File.write(File.join(run_dir, "agent_output.md"), judgment[:agent_output])

    # Save each domain judgment
    judgment[:domain_scores].each do |domain, result|
      File.write(
        File.join(run_dir, "#{domain}_judgment.md"),
        result[:judgment_text]
      )
    end

    # Save combined summary
    File.write(
      File.join(run_dir, "summary.md"),
      build_summary_markdown(judgment)
    )

    # Update results table in TESTING.md
    update_results_table(judgment)
  end

  def update_results_table(judgment)
    testing_file = File.join(ROOT_PATH, "TESTING.md")
    content = File.read(testing_file)

    # Format the result emoji
    result_emoji = judgment[:pass] ? "✅ PASS" : "❌ FAIL"

    # Format the row data
    last_run = judgment[:timestamp].strftime("%Y-%m-%d")
    agent_time = format_duration(judgment[:timing][:agent_duration])
    judge_time = format_duration(judgment[:timing][:judge_duration])
    total_time = format_duration(judgment[:timing][:total_duration])
    total_score = "#{judgment[:total_score]}/200"
    backend_score = "#{judgment[:domain_scores]["backend"][:score]}/50"
    frontend_score = "#{judgment[:domain_scores]["frontend"][:score]}/50"
    tests_score = "#{judgment[:domain_scores]["tests"][:score]}/50"
    security_score = "#{judgment[:domain_scores]["security"][:score]}/50"

    # Build the new row
    new_row = "| #{scenario_name} | #{last_run} | #{agent_time} | #{judge_time} | #{total_time} | #{total_score} | #{backend_score} | #{frontend_score} | #{tests_score} | #{security_score} | #{result_emoji} |"

    # Find and replace the row for this scenario
    # Match pattern: | scenario_name | ... |
    pattern = /^\| #{Regexp.escape(scenario_name)} \|.*\|$/

    if content =~ pattern
      # Update existing row
      content.gsub!(pattern, new_row)
    else
      # Add new row after the header separator
      header_separator = "|----------|----------|------------|------------|------------|-------------|---------|----------|-------|----------|--------|"
      content.sub!(header_separator, "#{header_separator}\n#{new_row}")
    end

    # Write back to file
    File.write(testing_file, content)
  end

  def build_summary_markdown(judgment)
    <<~MARKDOWN
      # Integration Test Summary: #{scenario_name}

      **Timestamp**: #{judgment[:timestamp].strftime('%Y-%m-%d %H:%M:%S')}
      **Git SHA**: #{judgment[:git_sha]}
      **Git Branch**: #{judgment[:git_branch]}

      ## Overall Result

      **#{judgment[:pass] ? 'PASS ✓' : 'FAIL ✗'}**

      **Total Score**: #{judgment[:total_score]}/#{judgment[:max_score]} (#{judgment[:percentage]}%)
      **Threshold**: #{judgment[:threshold]}/#{judgment[:max_score]} (70%)

      ## Timing

      - **Agent Duration**: #{format_duration(judgment[:timing][:agent_duration])}
      - **Judge Duration**: #{format_duration(judgment[:timing][:judge_duration])}
      - **Total Duration**: #{format_duration(judgment[:timing][:total_duration])}

      ## Domain Scores

      #{judgment[:domain_scores].map { |d, r| "- **#{d.capitalize}**: #{r[:score]}/#{MAX_SCORE_PER_DOMAIN}" }.join("\n")}

      ## Detailed Judgments

      See individual files:
      #{judgment[:domain_scores].keys.map { |d| "- [#{d}_judgment.md](./#{d}_judgment.md)" }.join("\n")}

      ## Agent Output

      See [agent_output.md](./agent_output.md) for full agent response.
    MARKDOWN
  end

  def format_duration(seconds)
    if seconds < 1
      "#{(seconds * 1000).round}ms"
    elsif seconds < 60
      "#{seconds.round(1)}s"
    else
      minutes = (seconds / 60).floor
      remaining_seconds = (seconds % 60).round
      "#{minutes}m #{remaining_seconds}s"
    end
  end

  def build_failure_message(judgment, base_message)
    <<~MSG
      #{base_message}

      Scenario: #{scenario_name}
      Total Score: #{judgment[:total_score]}/#{judgment[:max_score]} (#{judgment[:percentage]}%)
      Threshold: #{judgment[:threshold]}/#{judgment[:max_score]}

      Domain Scores:
      #{judgment[:domain_scores].map { |d, r| "  - #{d.capitalize}: #{r[:score]}/#{MAX_SCORE_PER_DOMAIN}" }.join("\n")}

      Run `cat tmp/test/integration/runs/#{judgment[:timestamp].strftime('%Y%m%d_%H%M%S')}_#{scenario_name}/summary.md` for details
    MSG
  end

  def support_dir
    File.join(ROOT_PATH, "test", "support")
  end

  def load_judge_prompt(domain)
    prompt_file = File.join(support_dir, "judge_prompts", "#{domain}_judge_prompt.md")
    File.read(prompt_file)
  end

  def git_sha
    result = `git rev-parse --short HEAD 2>/dev/null`.strip
    result.empty? ? "unknown" : result
  end

  def git_branch
    result = `git branch --show-current 2>/dev/null`.strip
    result.empty? ? "unknown" : result
  end

  def setup_live_logging
    # Create live log file
    log_dir = File.join(ROOT_PATH, "tmp", "test", "integration")
    FileUtils.mkdir_p(log_dir)

    @live_log_file = File.join(log_dir, "live.log")

    # Clear previous log
    File.write(@live_log_file, "")

    # Print log location
    puts "\n→ Live log: #{@live_log_file}"
    puts "  Tail with: tail -f #{@live_log_file}\n\n"
  end

  def log_live(message, newline: true, console: true)
    # Write to log file
    File.open(@live_log_file, "a") do |f|
      if newline
        f.puts message
      else
        f.print message
      end
      f.flush
    end

    # Optionally print to stdout (default: true for status updates)
    return unless console

    if newline
      puts message
    else
      print message
      $stdout.flush
    end
  end
end
