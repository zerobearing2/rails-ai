# frozen_string_literal: true

require_relative "../test_helper"
require "open3"
require "tmpdir"

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
  DOMAINS = %w[backend tests security].freeze
  MAX_SCORE_PER_DOMAIN = 50
  MAX_TOTAL_SCORE = DOMAINS.size * MAX_SCORE_PER_DOMAIN # 150
  PASS_THRESHOLD = (MAX_TOTAL_SCORE * 0.7).to_i # 105

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

  # Main test method - subclasses can override to add custom assertions
  def test_scenario
    # Run the agent
    agent_output = run_agent

    # Judge the output
    judgment = judge_output(agent_output)

    # Log results
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
    # Create temp files for prompts
    system_prompt_file = Tempfile.new(["system_prompt", ".txt"])
    agent_prompt_file = Tempfile.new(["agent_prompt", ".txt"])

    begin
      system_prompt_file.write(system_prompt)
      system_prompt_file.flush

      agent_prompt_file.write(agent_prompt)
      agent_prompt_file.flush

      # Run claude CLI
      cmd = [
        "claude",
        "--print",
        "--system-prompt",
        system_prompt
      ]

      stdout, stderr, status = Open3.capture3(*cmd, stdin_data: agent_prompt)

      unless status.success?
        raise "Claude CLI failed with status #{status.exitstatus}:\n#{stderr}"
      end

      stdout
    ensure
      system_prompt_file.close
      system_prompt_file.unlink
      agent_prompt_file.close
      agent_prompt_file.unlink
    end
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
    threads = DOMAINS.map do |domain|
      Thread.new do
        judge_domain(domain, agent_output)
      end
    end

    # Wait for all judges and collect results
    results = threads.map(&:value)

    # Convert to hash keyed by domain
    DOMAINS.zip(results).to_h
  end

  def judge_domain(domain, agent_output)
    # Load judge prompt
    judge_prompt = load_judge_prompt(domain)

    # Load domain context (skills/rules)
    domain_context = load_domain_context(domain)

    # Build full judge input
    judge_input = [
      judge_prompt,
      "",
      "## Domain Context (Skills & Rules)",
      "",
      domain_context,
      "",
      "## Scenario Requirements",
      "",
      agent_prompt,
      "",
      "## Agent Output to Evaluate",
      "",
      agent_output
    ].join("\n")

    # Run claude CLI as judge
    stdout, stderr, status = Open3.capture3(
      "claude",
      "--print",
      stdin_data: judge_input
    )

    unless status.success?
      raise "Judge (#{domain}) failed with status #{status.exitstatus}:\n#{stderr}"
    end

    # Parse score from output
    score = parse_score_from_judgment(stdout, domain)

    {
      domain: domain,
      score: score,
      judgment_text: stdout
    }
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

      ## Domain Scores

      #{judgment[:domain_scores].map { |d, r| "- **#{d.capitalize}**: #{r[:score]}/#{MAX_SCORE_PER_DOMAIN}" }.join("\n")}

      ## Detailed Judgments

      See individual files:
      #{judgment[:domain_scores].keys.map { |d| "- [#{d}_judgment.md](./#{d}_judgment.md)" }.join("\n")}

      ## Agent Output

      See [agent_output.md](./agent_output.md) for full agent response.
    MARKDOWN
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
end
