# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../support/llm_adapter"
require "yaml"
require "fileutils"

# Base class for skill behavior tests
# Uses RED-GREEN-REFACTOR cycle to verify skills prevent anti-patterns
#
# Subclasses should:
# - Define skill_name (e.g., "jobs")
# - Load scenarios from test/skills/{skill_name}/scenarios/
# - Tests automatically generated from scenario files
class SkillTestCase < Minitest::Test
  # Override in subclass
  def skill_name
    raise NotImplementedError, "Subclass must define skill_name"
  end

  # Override to customize LLM adapter
  def llm_adapter
    @llm_adapter ||= ClaudeAdapter.new
  end

  # Automatically generate test methods from scenario files
  def self.generate_tests_from_scenarios
    return if self == SkillTestCase # Don't run for base class

    skill = new.skill_name
    scenario_dir = File.join(ROOT_PATH, "test", "skills", skill, "scenarios")

    return unless Dir.exist?(scenario_dir)

    Dir.glob(File.join(scenario_dir, "*.md")).sort.each do |scenario_file|
      scenario_name = File.basename(scenario_file, ".md")

      define_method("test_#{scenario_name}") do
        run_scenario(scenario_file)
      end
    end
  end

  private

  def run_scenario(scenario_file)
    scenario = parse_scenario(scenario_file)
    scenario_name = File.basename(scenario_file, ".md")

    # Create results directory
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    results_dir = File.join(
      ROOT_PATH, "test", "skills", skill_name, "results",
      "#{timestamp}_#{scenario_name}"
    )
    FileUtils.mkdir_p(results_dir)

    # RED: Run without skill
    puts "\n[RED] Running baseline (without skill)..."
    baseline_output = run_agent(scenario[:prompt], without_skill: true)
    File.write(File.join(results_dir, "baseline.md"), baseline_output)

    # GREEN: Run with skill
    puts "[GREEN] Running with skill..."
    with_skill_output = run_agent(scenario[:prompt], without_skill: false)
    File.write(File.join(results_dir, "with_skill.md"), with_skill_output)

    # VERIFY: Check assertions
    puts "[VERIFY] Checking assertions..."
    verify_assertions(scenario, baseline_output, with_skill_output, results_dir)
  end

  def parse_scenario(file)
    content = File.read(file)

    # Extract YAML frontmatter
    if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
      frontmatter = YAML.safe_load($1, permitted_classes: [Symbol])
      body = content.sub(/\A---\s*\n.*?\n---\s*\n/m, "")
    else
      frontmatter = {}
      body = content
    end

    # Extract sections
    prompt = body[/# Scenario\s*\n(.*?)(?=\n# )/m, 1]&.strip
    assertions_text = body[/# Assertions\s*\n(.*)/m, 1]&.strip

    # Validate required sections
    validate_scenario_sections(file, prompt, assertions_text)

    {
      skill: frontmatter["skill"],
      antipattern: frontmatter["antipattern"],
      description: frontmatter["description"],
      prompt: prompt,
      assertions: parse_assertions(assertions_text)
    }
  rescue Errno::ENOENT => e
    raise "Scenario file not found: #{file} (#{e.message})"
  rescue Psych::SyntaxError => e
    raise "Invalid YAML frontmatter in #{file}: #{e.message}"
  end

  def validate_scenario_sections(file, prompt, assertions_text)
    errors = []
    errors << "Missing '# Scenario' section" if prompt.nil? || prompt.empty?
    errors << "Missing '# Assertions' section" if assertions_text.nil? || assertions_text.empty?

    return if errors.empty?

    raise "Invalid scenario file #{file}:\n  #{errors.join("\n  ")}"
  end

  def parse_assertions(text)
    return [] unless text

    # Extract "Must include:" items
    items = text.scan(/^[-*]\s+(.+)$/).flatten
    items.map(&:strip)
  end

  def run_agent(prompt, without_skill:)
    system_prompt = build_system_prompt(without_skill)

    llm_adapter.execute(
      prompt: prompt,
      system_prompt: system_prompt,
      streaming: false
    )
  end

  def build_system_prompt(without_skill)
    if without_skill
      # RED: Baseline without skill access
      <<~PROMPT
        You are implementing features for a Rails 8.1 application.

        Provide implementation code. Be concise and direct.
        Do not ask for clarification - make reasonable assumptions.
      PROMPT
    else
      # GREEN: With skill access
      skill_path = File.join(ROOT_PATH, "skills", skill_name, "SKILL.md")

      begin
        skill_content = File.read(skill_path)
      rescue Errno::ENOENT => e
        raise "Skill file not found: #{skill_path} (#{e.message})"
      end

      <<~PROMPT
        You are implementing features for a Rails 8.1 application.

        You have access to the following skill:

        #{skill_content}

        Follow the skill patterns and standards.
        Provide implementation code. Be concise and direct.
        Do not ask for clarification - make reasonable assumptions.
      PROMPT
    end
  end

  def verify_assertions(scenario, baseline, with_skill, results_dir)
    failures = []

    scenario[:assertions].each do |assertion|
      # Create regex pattern with word boundaries for more precise matching
      # Escape special regex characters in the assertion
      escaped_assertion = Regexp.escape(assertion)
      # Use word boundaries (\b) to match whole words/phrases
      pattern = /\b#{escaped_assertion}\b/

      # Check baseline DOESN'T have good pattern (proves RED works)
      if baseline.match?(pattern)
        failures << "BASELINE CONTAMINATED: Found '#{assertion}' in baseline (should only appear with skill)"
      end

      # Check with-skill DOES have good pattern (proves GREEN works)
      unless with_skill.match?(pattern)
        failures << "MISSING PATTERN: Expected '#{assertion}' in with-skill output"
      end
    end

    if failures.any?
      summary = "#{failures.size} assertion(s) failed:\n" + failures.join("\n")
      File.write(File.join(results_dir, "failures.txt"), summary)
      flunk(summary)
    else
      File.write(File.join(results_dir, "success.txt"), "All assertions passed!")
    end
  end
end
