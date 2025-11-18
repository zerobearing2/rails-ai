# frozen_string_literal: true

require_relative "../../test_helper"

class RulesConsistencyTest < Minitest::Test
  def setup
    @team_rules_file = "rules/TEAM_RULES.md"
    @team_rules_content = File.read(@team_rules_file)
    @team_rules_yaml = extract_yaml_front_matter(@team_rules_file)
    # Get all skill files from skills directory
    @all_skill_files = Dir.glob("skills/**/*.md")
  end

  # Test that TEAM_RULES.md has valid front matter
  def test_team_rules_has_valid_yaml_front_matter
    refute_nil @team_rules_yaml, "TEAM_RULES.md should have YAML front matter"
    assert @team_rules_yaml["name"], "Should have name field"
    assert @team_rules_yaml["description"], "Should have description field"
    assert @team_rules_yaml["version"], "Should have version field"
  end

  # Test consistency of rule counts
  def test_rule_count_consistency
    team_rules_count = @team_rules_yaml.dig("enforcement", "severity").values.flatten.uniq.length

    assert_equal 20, team_rules_count,
                 "TEAM_RULES.md should have 20 unique rules in severity lists"
  end

  def test_critical_rules_are_defined
    # Get critical rules from TEAM_RULES.md
    team_rules_critical = @team_rules_yaml.dig("enforcement", "severity", "critical")
    team_critical_numbers = team_rules_critical.map { |r| r.match(/\d+/)[0].to_i }.sort

    expected_critical = [1, 2, 3, 4, 17, 18]

    assert_equal expected_critical, team_critical_numbers,
                 "Critical rules should be: #{expected_critical.join(', ')}"
  end

  def test_violation_keywords_are_defined
    team_keywords = @team_rules_yaml["violation_keywords"]

    refute_nil team_keywords, "Should have violation_keywords defined"
    refute_empty team_keywords, "Should have at least one violation keyword rule"

    # Check that keywords are arrays
    team_keywords.each do |rule_key, keywords|
      assert_kind_of Array, keywords,
                     "#{rule_key} violation keywords should be an array"
    end
  end

  def test_all_rules_mentioned_in_team_rules_content
    # Check that all 20 rules have sections in TEAM_RULES.md content
    (1..20).each do |rule_num|
      assert_match(/^###\s+#{rule_num}\.\s+/m, @team_rules_content,
                   "TEAM_RULES.md should have section for Rule ##{rule_num}")
    end
  end

  def test_rule_quick_lookup_is_well_formed
    # Extract rule names from quick lookup in TEAM_RULES.md
    quick_lookup_match = @team_rules_content.match(/<quick-lookup\s+id="rule-index">.*?```yaml\s+(.*?)```/m)

    assert quick_lookup_match, "Should find quick lookup YAML section"

    team_rules_index = YAML.safe_load(quick_lookup_match[1])["rule_index"]

    refute_nil team_rules_index, "Quick lookup should have rule_index"
    refute_empty team_rules_index, "Quick lookup rule_index should not be empty"

    # Check that each rule has required fields
    team_rules_index.each do |rule_num, rule_data|
      assert rule_data["name"], "Rule ##{rule_num} should have name"
      assert rule_data["severity"], "Rule ##{rule_num} should have severity"
    end
  end

  def test_severity_levels_in_enforcement_match_quick_lookup
    # Get severities from enforcement section
    enforcement_severities = @team_rules_yaml.dig("enforcement", "severity")

    # Get severities from quick lookup
    quick_lookup_match = @team_rules_content.match(/<quick-lookup\s+id="rule-index">.*?```yaml\s+(.*?)```/m)
    team_rules_index = YAML.safe_load(quick_lookup_match[1])["rule_index"]

    # Check that rules in enforcement section match their severity in quick lookup
    enforcement_severities.each do |severity, rules|
      rules.each do |rule_key|
        rule_num = rule_key.match(/\d+/)[0].to_i
        rule_data = team_rules_index[rule_num]
        next unless rule_data

        assert_equal severity.to_s, rule_data["severity"],
                     "Rule ##{rule_num} severity should match between enforcement and quick lookup"
      end
    end
  end

  # Test that skills section is well-formed (some skills may be aspirational)
  def test_skills_in_quick_lookup_are_well_formed
    quick_lookup_match = @team_rules_content.match(/<quick-lookup\s+id="rule-index">.*?```yaml\s+(.*?)```/m)
    skip unless quick_lookup_match

    team_rules_index = YAML.safe_load(quick_lookup_match[1])["rule_index"]

    team_rules_index.each do |rule_num, rule_data|
      next unless rule_data["skills"]

      assert_kind_of Array, rule_data["skills"],
                     "Rule ##{rule_num} skills should be an array"
      refute_empty rule_data["skills"],
                   "Rule ##{rule_num} skills should not be empty if present"
    end
  end

  # Test that categories are well defined
  def test_categories_are_defined
    categories = @team_rules_yaml["categories"]

    refute_nil categories, "Should have categories defined"
    refute_empty categories, "Should have at least one category"
    assert_kind_of Array, categories, "Categories should be an array"
  end

  # Test domain index exists
  def test_rules_by_domain_section_exists
    assert_match(/<domain-index\s+id="rules-by-domain">/i, @team_rules_content,
                 "TEAM_RULES.md should have rules-by-domain index section")
  end

  private

  def extract_yaml_front_matter(file)
    content = File.read(file)
    match = content.match(/^---\s*\n(.*?)\n---\s*\n/m)
    return nil unless match

    YAML.safe_load(match[1], permitted_classes: [Symbol, Date], aliases: true)
  rescue Psych::SyntaxError
    nil
  end
end
