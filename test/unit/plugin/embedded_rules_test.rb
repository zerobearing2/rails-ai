# frozen_string_literal: true

require_relative "../../test_helper"

class EmbeddedRulesTest < Minitest::Test
  # Skills that MUST have embedded rules
  SKILLS_WITH_RULES = {
    "skills/testing/SKILL.md" => [
      "Minitest Only", "TDD Required", "WebMock Required", "No System Tests"
    ],
    "skills/controllers/SKILL.md" => ["RESTful Actions Only", "Thin Controllers", "Proper Namespacing"],
    "skills/models/SKILL.md" => ["Proper Namespacing"],
    "skills/hotwire/SKILL.md" => ["Turbo Morph Default", "Progressive Enhancement"],
    "skills/jobs/SKILL.md" => ["Solid Stack Only"],
    "skills/setup/SKILL.md" => ["Double Quotes", "Hash#dig"],
    "skills/ui/SKILL.md" => ["Partials for Fragments", "Semantic HTML"],
    "skills/mailers/SKILL.md" => ["Async Delivery", "Dual Format"],
    "skills/security/SKILL.md" => ["Strong Params Always", "Brakeman Zero Warnings"]
  }.freeze

  # Skills that should NOT have embedded rules
  SKILLS_WITHOUT_RULES = %w[
    skills/styling/SKILL.md
    skills/debugging/SKILL.md
  ].freeze

  # Agents with quality rules
  AGENTS_WITH_RULES = {
    "agents/developer.md" => [
      "Be Concise", "Don't Over-Engineer", "Reduce Complexity", "No Premature Optimization"
    ],
    "agents/reviewer.md" => [
      "Be Concise", "Don't Over-Engineer", "Reduce Complexity", "No Premature Optimization"
    ]
  }.freeze

  SKILLS_WITH_RULES.each do |file, rules|
    define_method("test_#{file.gsub('/', '_').gsub('.', '_')}_contains_expected_rules") do
      content = File.read(File.join(ROOT_PATH, file))

      assert_match(/<team-rules>/, content, "#{file} missing <team-rules> section")

      rules.each do |rule_name|
        assert_match(/###\s+#{Regexp.escape(rule_name)}\s+\[/m, content,
                     "#{file} missing rule: #{rule_name}")
      end
    end
  end

  AGENTS_WITH_RULES.each do |file, rules|
    define_method("test_#{file.gsub('/', '_').gsub('.', '_')}_contains_expected_quality_rules") do
      content = File.read(File.join(ROOT_PATH, file))

      assert_match(/<team-rules>/, content, "#{file} missing <team-rules> section")

      rules.each do |rule_name|
        assert_match(/###\s+#{Regexp.escape(rule_name)}\s+\[/m, content,
                     "#{file} missing rule: #{rule_name}")
      end
    end
  end

  def test_skills_without_rules_do_not_have_team_rules_section
    SKILLS_WITHOUT_RULES.each do |file|
      path = File.join(ROOT_PATH, file)
      next unless File.exist?(path)

      content = File.read(path)

      refute_match(/<team-rules>/, content,
                   "#{file} should NOT have <team-rules> section - rules belong in agents")
    end
  end

  def test_rules_directory_has_been_deleted
    refute_path_exists File.join(ROOT_PATH, "rules"),
                       "rules/ directory should be deleted - rules are now embedded in skills and agents"
  end

  def test_all_skills_with_rules_have_severity_levels
    SKILLS_WITH_RULES.each_key do |file|
      validate_severity_levels_in_file(file)
    end
  end

  def test_all_agents_with_rules_have_severity_levels
    AGENTS_WITH_RULES.each_key do |file|
      validate_severity_levels_in_file(file)
    end
  end

  def test_rules_have_reject_or_prefer_guidance
    SKILLS_WITH_RULES.each_key do |file|
      validate_guidance_in_file(file)
    end
  end

  private

  def validate_severity_levels_in_file(file)
    content = File.read(File.join(ROOT_PATH, file))
    team_rules_match = content.match(%r{<team-rules>(.*?)</team-rules>}m)
    return unless team_rules_match

    team_rules = team_rules_match[1]
    rule_headers = team_rules.scan(/###\s+[^\[]+\[([^\]]+)\]/)

    rule_headers.each do |match|
      severity = match[0]

      assert_includes %w[CRITICAL HIGH MODERATE LOW], severity,
                      "#{file}: Invalid severity '#{severity}'. Must be CRITICAL, HIGH, MODERATE, or LOW"
    end
  end

  def validate_guidance_in_file(file)
    content = File.read(File.join(ROOT_PATH, file))
    team_rules_match = content.match(%r{<team-rules>(.*?)</team-rules>}m)
    return unless team_rules_match

    team_rules = team_rules_match[1]
    rule_blocks = team_rules.split("###").reject(&:empty?)

    rule_blocks.each do |block|
      rule_name = extract_rule_name(block)
      next if rule_name.nil? || rule_name.empty?

      has_guidance = block.include?("Reject:") || block.include?("Prefer:")

      assert has_guidance,
             "#{file}: Rule '#{rule_name}' should have either 'Reject:' or 'Prefer:' guidance"
    end
  end

  def extract_rule_name(block)
    first_line = block.lines.first
    return nil unless first_line

    stripped = first_line.strip
    return nil unless stripped.include?("[")

    stripped.split("[").first&.strip
  end
end
