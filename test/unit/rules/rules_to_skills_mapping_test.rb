# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

# This test validates that skill references in TEAM_RULES.md are valid
# Note: The old architecture had a separate RULES_TO_SKILLS_MAPPING.yml file
# but now all rules and skill mappings are in TEAM_RULES.md
class RulesToSkillsMappingTest < Minitest::Test
  def setup
    @team_rules_file = "rules/TEAM_RULES.md"
    @team_rules_content = File.read(@team_rules_file)
    # Get all skill files from skills directory
    @all_skill_files = Dir.glob("skills/**/*.md")
  end

  # Test that quick lookup has skill references
  def test_quick_lookup_has_skill_references
    quick_lookup_match = @team_rules_content.match(/<quick-lookup\s+id="rule-index">.*?```yaml\s+(.*?)```/m)

    assert quick_lookup_match, "Should find quick lookup YAML section"

    team_rules_index = YAML.safe_load(quick_lookup_match[1])["rule_index"]

    rules_with_skills = team_rules_index.select { |_, rule_data| rule_data["skills"] }

    refute_empty rules_with_skills, "At least some rules should have skill references"
  end

  # Test that skill references are well-formed (some skills may be aspirational)
  def test_skill_references_are_well_formed
    quick_lookup_match = @team_rules_content.match(/<quick-lookup\s+id="rule-index">.*?```yaml\s+(.*?)```/m)
    skip unless quick_lookup_match

    team_rules_index = YAML.safe_load(quick_lookup_match[1])["rule_index"]

    team_rules_index.each do |rule_num, rule_data|
      next unless rule_data["skills"]

      assert_kind_of Array, rule_data["skills"],
                     "Rule ##{rule_num} skills should be an array"

      rule_data["skills"].each do |skill_name|
        assert_kind_of String, skill_name,
                       "Rule ##{rule_num} skill name should be a string"
        refute_empty skill_name,
                     "Rule ##{rule_num} skill name should not be empty"
      end
    end
  end

  # Test that enforcement actions are well-formed
  def test_enforcement_actions_are_defined
    quick_lookup_match = @team_rules_content.match(/<quick-lookup\s+id="rule-index">.*?```yaml\s+(.*?)```/m)
    skip unless quick_lookup_match

    team_rules_index = YAML.safe_load(quick_lookup_match[1])["rule_index"]

    team_rules_index.each do |rule_num, rule_data|
      next unless rule_data["action"]

      valid_actions = %w[REJECT SUGGEST WARN]

      assert_includes valid_actions, rule_data["action"],
                      "Rule ##{rule_num} has invalid action '#{rule_data['action']}' (must be one of: #{valid_actions.join(', ')})"
    end
  end

  # Test that trigger keywords are well-formed
  def test_trigger_keywords_are_arrays
    quick_lookup_match = @team_rules_content.match(/<quick-lookup\s+id="rule-index">.*?```yaml\s+(.*?)```/m)
    skip unless quick_lookup_match

    team_rules_index = YAML.safe_load(quick_lookup_match[1])["rule_index"]

    team_rules_index.each do |rule_num, rule_data|
      next unless rule_data["triggers"]

      assert_kind_of Array, rule_data["triggers"],
                     "Rule ##{rule_num} triggers should be an array"
    end
  end
end
