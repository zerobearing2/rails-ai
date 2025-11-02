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

  def system_prompt
    raise NotImplementedError, "Subclass must define system_prompt"
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
    log_live "Step 2/2: Running judges (4 parallel domain evaluations)..."
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
    agent_output_file = File.join(@test_dir, "agent_output.md")
    File.write(agent_output_file, agent_output)

    log_live "  Building coordinator prompt with 4 domain tasks..."

    # Build a single prompt that references the file instead of embedding the output
    coordinator_prompt = build_coordinator_judge_prompt(agent_output_file)

    log_live "  Invoking #{llm_adapter.name} for parallel judging..."
    log_live "  (This may take several minutes...)"

    # Stream to log file but not console
    judge_output = llm_adapter.execute(
      prompt: coordinator_prompt,
      streaming: true,
      on_chunk: ->(text) { log_live(text, newline: false, console: false) }
    )

    log_live "  ✓ Judging complete"
    log_live "  Parsing domain judgments from coordinator response..."

    # Parse the coordinated response to extract each domain's judgment
    results = parse_coordinator_response(judge_output)

    log_live "  ✓ Successfully parsed #{results.size} domain judgments"

    results
  rescue StandardError => e
    log_live "  ✗ ERROR: Coordinator judge failed!"
    log_live ""
    log_live "Error: #{e.message}"
    raise
  end

  def build_coordinator_judge_prompt(agent_output_file)
    # Load all judge prompts and domain contexts
    domain_contexts = DOMAINS.map do |domain|
      {
        domain: domain,
        judge_prompt: load_judge_prompt(domain),
        context: load_domain_context(domain)
      }
    end

    <<~PROMPT
      You are coordinating 4 parallel domain judges to evaluate a Rails implementation plan.

      **IMPORTANT**: You must evaluate all 4 domains IN PARALLEL using separate tasks. This is more efficient than sequential evaluation.

      ## Scenario Requirements

      #{agent_prompt}

      ## Agent Output to Evaluate

      The agent's implementation plan is in the file: #{agent_output_file}

      Please read this file using the Read tool to access the plan you need to evaluate.

      ## Your Task

      Create 4 parallel evaluation tasks - one for each domain. Each task should independently evaluate the agent's plan according to its domain's criteria and context.

      #{domain_contexts.map { |d| build_domain_task_prompt(d) }.join("\n\n")}

      ## Output Format

      You MUST output each domain's evaluation in this exact format:

      ```
      ### DOMAIN: backend
      [Full backend evaluation following the backend judge prompt format]
      ### END DOMAIN: backend

      ### DOMAIN: frontend
      [Full frontend evaluation following the frontend judge prompt format]
      ### END DOMAIN: frontend

      ### DOMAIN: tests
      [Full tests evaluation following the tests judge prompt format]
      ### END DOMAIN: tests

      ### DOMAIN: security
      [Full security evaluation following the security judge prompt format]
      ### END DOMAIN: security
      ```

      Each domain evaluation MUST include its total score in the exact format specified by that domain's judge prompt (e.g., "## Backend Total: XX/50").
    PROMPT
  end

  def build_domain_task_prompt(domain_info)
    <<~TASK
      ### #{domain_info[:domain].capitalize} Domain Task

      **Criteria**: Evaluate according to this judge prompt:

      #{domain_info[:judge_prompt]}

      **Domain Context** (Skills & Rules to reference):

      #{domain_info[:context]}
    TASK
  end

  def parse_coordinator_response(response)
    # Extract each domain's judgment from the coordinated response
    judgments = {}

    DOMAINS.each do |domain|
      # Extract text between ### DOMAIN: {domain} and ### END DOMAIN: {domain}
      pattern = /### DOMAIN: #{domain}\s*(.*?)\s*### END DOMAIN: #{domain}/m
      match = response.match(pattern)

      if match
        judgment_text = match[1].strip
        score = parse_score_from_judgment(judgment_text, domain)

        judgments[domain] = {
          domain: domain,
          score: score,
          judgment_text: judgment_text
        }
      else
        # Fallback if format not followed
        warn "Warning: Could not parse #{domain} judgment from coordinator response"
        judgments[domain] = {
          domain: domain,
          score: 0,
          judgment_text: "ERROR: Could not parse judgment from coordinator response"
        }
      end
    end

    judgments
  end

  def load_judge_prompt(domain)
    prompt_file = File.join(support_dir, "judge_prompts", "#{domain}_judge_prompt.md")
    File.read(prompt_file)
  end

  def load_domain_context(domain)
    # Load relevant skills for this domain
    skills = case domain
             when "backend"
               load_skills_for_patterns(%w[model migration association validation activerecord])
             when "frontend"
               load_skills_for_patterns(%w[view partial component hotwire turbo stimulus tailwind daisyui form])
             when "tests"
               load_skills_for_patterns(%w[test minitest fixture mock coverage])
             when "security"
               load_skills_for_patterns(%w[security authorization authentication csrf xss sql])
             else
               ""
             end

    # Load relevant rules
    rules = load_rules_for_domain(domain)

    [skills, rules].join("\n\n")
  end

  def load_skills_for_patterns(patterns)
    skills_content = []

    patterns.each do |pattern|
      # Find skill files matching pattern
      skill_files = Dir.glob(File.join(SKILLS_PATH, "**", "*#{pattern}*.md"))

      skill_files.each do |file|
        skills_content << "### Skill: #{File.basename(file, '.md')}\n\n"
        skills_content << File.read(file)
        skills_content << "\n\n---\n\n"
      end
    end

    skills_content.join
  end

  def load_rules_for_domain(domain)
    # Load rules from rules/ directory if they exist
    rules_dir = File.join(ROOT_PATH, "rules")
    return "" unless Dir.exist?(rules_dir)

    rules_content = []

    # Find rule files that might be relevant to domain
    rule_files = Dir.glob(File.join(rules_dir, "**", "*.md"))

    rule_files.each do |file|
      # Simple heuristic: include rule if filename contains domain keyword
      next unless relevant_to_domain?(file, domain)

      rules_content << "### Rule: #{File.basename(file, '.md')}\n\n"
      rules_content << File.read(file)
      rules_content << "\n\n---\n\n"
    end

    rules_content.join
  end

  def relevant_to_domain?(file, domain)
    basename = File.basename(file, ".md").downcase

    case domain
    when "backend"
      basename.match?(/model|migration|database|activerecord|validation/)
    when "frontend"
      basename.match?(/view|partial|component|hotwire|turbo|stimulus|tailwind|daisyui|form|ui/)
    when "tests"
      basename.match?(/test|minitest|coverage|quality/)
    when "security"
      basename.match?(/security|auth|csrf|xss|injection/)
    else
      false
    end
  end

  def parse_score_from_judgment(judgment_text, domain)
    # Look for score in format: "## Backend Total: 45/50" or "Backend Total: 45/50"
    match = judgment_text.match(/##?\s*#{domain.capitalize}\s+Total:\s*(\d+)\/\d+/i)

    if match
      match[1].to_i
    else
      # Fallback: try to extract any score pattern
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

  def git_sha
    `git rev-parse --short HEAD 2>/dev/null`.strip.presence || "unknown"
  end

  def git_branch
    `git branch --show-current 2>/dev/null`.strip.presence || "unknown"
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
