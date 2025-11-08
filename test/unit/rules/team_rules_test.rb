# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class TeamRulesTest < Minitest::Test
  def setup
    @rules_file = "rules/TEAM_RULES.md"
    @content = File.read(@rules_file)
    @yaml = extract_yaml_front_matter(@rules_file)
  end

  # Test YAML front matter structure
  def test_has_valid_yaml_front_matter
    refute_nil @yaml, "TEAM_RULES.md should have YAML front matter"
    assert_kind_of Hash, @yaml, "YAML front matter should be a hash"
  end

  def test_has_required_metadata_fields
    required_fields = %w[name description version last_updated type priority scope]

    required_fields.each do |field|
      assert @yaml[field], "TEAM_RULES.md should have '#{field}' field"
    end
  end

  def test_metadata_values_are_correct
    assert_equal "TEAM_RULES", @yaml["name"]
    assert_equal "enforcement_rules", @yaml["type"]
    assert_equal "critical", @yaml["priority"]
    assert_equal "all_agents", @yaml["scope"]
  end

  def test_has_rule_categories
    assert @yaml["categories"], "Should have categories defined"
    assert_kind_of Array, @yaml["categories"], "Categories should be an array"
    refute_empty @yaml["categories"], "Categories should not be empty"

    expected_categories = %w[stack_architecture testing routing code_quality workflow performance]

    expected_categories.each do |category|
      assert_includes @yaml["categories"], category,
                      "Should include '#{category}' category"
    end
  end

  def test_has_violation_keywords
    assert @yaml["violation_keywords"], "Should have violation_keywords defined"
    assert_kind_of Hash, @yaml["violation_keywords"], "violation_keywords should be a hash"

    # Critical rules should have violation keywords
    critical_rules_with_keywords = %w[rule_1 rule_2 rule_3 rule_4 rule_18]
    critical_rules_with_keywords.each do |rule|
      assert @yaml["violation_keywords"][rule],
             "Critical #{rule} should have violation keywords"
      assert_kind_of Array, @yaml["violation_keywords"][rule],
                     "#{rule} violation keywords should be an array"
    end
  end

  def test_has_enforcement_metadata
    assert @yaml["enforcement"], "Should have enforcement metadata"
    assert @yaml["enforcement"]["automatic"], "Should have automatic enforcement list"
    assert @yaml["enforcement"]["manual"], "Should have manual enforcement list"
    assert @yaml["enforcement"]["severity"], "Should have severity levels"
  end

  def test_severity_levels_are_defined
    severity = @yaml["enforcement"]["severity"]

    assert severity["critical"], "Should have critical severity rules"
    assert severity["high"], "Should have high severity rules"
    assert severity["moderate"], "Should have moderate severity rules"

    # Critical rules should include the major rules
    expected_critical = %w[rule_1 rule_2 rule_3 rule_4 rule_17 rule_18]

    expected_critical.each do |rule|
      assert_includes severity["critical"], rule,
                      "#{rule} should be marked as critical severity"
    end
  end

  # Test rule structure and format
  def test_all_19_rules_are_present
    (1..19).each do |rule_num|
      assert_match(/^###\s+#{rule_num}\.\s+/m, @content,
                   "Rule ##{rule_num} should be present")
    end
  end

  def test_rules_have_rule_tags
    # Critical rules should have <rule> tags
    critical_rules = [1, 2, 3, 4, 17, 18]

    critical_rules.each do |rule_num|
      assert_match(/<rule\s+id="#{rule_num}"/m, @content,
                   "Rule ##{rule_num} should have <rule id=\"#{rule_num}\"> tag")
    end
  end

  def test_critical_rules_have_priority_attribute
    critical_rules = [1, 2, 3, 4, 17, 18]

    critical_rules.each do |rule_num|
      assert_match(/<rule\s+id="#{rule_num}".*priority="critical"/m, @content,
                   "Rule ##{rule_num} should have priority=\"critical\" attribute")
    end
  end

  def test_rules_have_category_attribute
    # Check that rules have category attributes
    expected_categories = %w[stack_architecture testing routing code_quality workflow]

    expected_categories.each do |category|
      assert_match(/category="#{category}"/m, @content,
                   "At least one rule should have category=\"#{category}\"")
    end
  end

  def test_critical_rules_have_violation_triggers
    critical_rules = [1, 2, 3, 4, 18]

    critical_rules.each do |rule_num|
      # Find the rule section
      rule_pattern = %r{<rule\s+id="#{rule_num}".*?>.*?</rule>}m

      assert_match(rule_pattern, @content, "Rule ##{rule_num} should have complete <rule> section")

      rule_section = @content.match(rule_pattern)[0]

      assert_match(/<violation-triggers>/m, rule_section,
                   "Rule ##{rule_num} should have <violation-triggers> section")
    end
  end

  def test_critical_rules_have_enforcement_section
    critical_rules = [1, 2, 3, 4, 17, 18]

    critical_rules.each do |rule_num|
      rule_pattern = %r{<rule\s+id="#{rule_num}".*?>.*?</rule>}m
      next unless @content.match?(rule_pattern)

      rule_section = @content.match(rule_pattern)[0]

      assert_match(/<enforcement\s+/m, rule_section,
                   "Rule ##{rule_num} should have <enforcement> section")
      assert_match(/action="REJECT"/m, rule_section,
                   "Rule ##{rule_num} should have action=\"REJECT\"")
      assert_match(/severity="critical"/m, rule_section,
                   "Rule ##{rule_num} should have severity=\"critical\"")
    end
  end

  def test_rules_have_require_and_reject_markers
    critical_rules = [1, 2, 3, 4, 17, 18]

    critical_rules.each do |rule_num|
      rule_pattern = %r{<rule\s+id="#{rule_num}".*?>.*?</rule>}m
      next unless @content.match?(rule_pattern)

      rule_section = @content.match(rule_pattern)[0]

      assert_match(/✅\s+(\*\*)?REQUIRE(\*\*)?:/m, rule_section,
                   "Rule ##{rule_num} should have ✅ REQUIRE: marker")
      assert_match(/❌\s+(\*\*)?REJECT(\*\*)?:/m, rule_section,
                   "Rule ##{rule_num} should have ❌ REJECT: marker")
    end
  end

  def test_rules_have_implementation_skills_section
    # Rules that should have implementation skills
    rules_with_skills = [1, 2, 3, 4, 5, 7, 12, 15, 18]

    rules_with_skills.each do |rule_num|
      rule_pattern = %r{<rule\s+id="#{rule_num}".*?>.*?</rule>}m
      next unless @content.match?(rule_pattern)

      rule_section = @content.match(rule_pattern)[0]

      assert_match(/<implementation-skills>/m, rule_section,
                   "Rule ##{rule_num} should have <implementation-skills> section")
    end
  end

  def test_rules_have_why_explanation
    critical_rules = [1, 2, 3, 4, 17, 18]

    critical_rules.each do |rule_num|
      rule_pattern = %r{<rule\s+id="#{rule_num}".*?>.*?</rule>}m
      next unless @content.match?(rule_pattern)

      rule_section = @content.match(rule_pattern)[0]

      assert_match(/\*\*Why:\*\*/m, rule_section,
                   "Rule ##{rule_num} should have **Why:** explanation")
    end
  end

  def test_has_quick_lookup_section
    assert_match(/<quick-lookup\s+id="rule-index">/m, @content,
                 "Should have <quick-lookup id=\"rule-index\"> section")
  end

  def test_quick_lookup_has_yaml_index
    quick_lookup_pattern = %r{<quick-lookup\s+id="rule-index">.*?</quick-lookup>}m

    assert_match(quick_lookup_pattern, @content, "Should have quick-lookup section")

    quick_lookup = @content.match(quick_lookup_pattern)[0]

    # Should have YAML code block with rule_index
    assert_match(/```yaml\s+rule_index:/m, quick_lookup,
                 "Quick lookup should have YAML code block with rule_index")

    # Critical rules should be in the index
    [1, 2, 3, 4, 17, 18].each do |rule_num|
      assert_match(/^\s+#{rule_num}:/m, quick_lookup,
                   "Quick lookup should include rule #{rule_num}")
    end
  end

  def test_rule_index_has_required_fields
    quick_lookup_pattern = %r{<quick-lookup\s+id="rule-index">.*?</quick-lookup>}m
    quick_lookup = @content.match(quick_lookup_pattern)[0]

    # Extract YAML from the code block
    yaml_match = quick_lookup.match(/```yaml\s+(.*?)```/m)

    assert yaml_match, "Quick lookup should have valid YAML code block"

    rule_index = YAML.safe_load(yaml_match[1])["rule_index"]

    rule_index.each do |rule_num, rule_data|
      assert rule_data["name"], "Rule #{rule_num} should have name"
      assert rule_data["severity"], "Rule #{rule_num} should have severity"
      assert rule_data["action"], "Rule #{rule_num} should have action"

      # Critical rules should have triggers
      if %w[critical].include?(rule_data["severity"]) && rule_num != 17
        assert rule_data["triggers"], "Rule #{rule_num} should have triggers"
      end
    end
  end

  def test_no_duplicate_rule_numbers
    rule_headers = @content.scan(/^###\s+(\d+)\.\s+/)
    rule_numbers = rule_headers.flatten.map(&:to_i)

    assert_equal rule_numbers.uniq.sort, rule_numbers.sort,
                 "Rule numbers should be unique and sequential"
  end

  def test_rules_are_sequential
    rule_headers = @content.scan(/^###\s+(\d+)\.\s+/)
    rule_numbers = rule_headers.flatten.map(&:to_i)

    assert_equal (1..19).to_a, rule_numbers.sort,
                 "Rules should be numbered 1-19 sequentially"
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
