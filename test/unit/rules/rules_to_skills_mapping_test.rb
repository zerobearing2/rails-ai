# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class RulesToSkillsMappingTest < Minitest::Test
  def setup
    @mapping_file = "rules/RULES_TO_SKILLS_MAPPING.yml"
    @mapping = YAML.load_file(@mapping_file, permitted_classes: [Date])
    @skills_registry = YAML.load_file("skills/SKILLS_REGISTRY.yml", permitted_classes: [Symbol, Date])
    @all_skills = @skills_registry["skills"].keys
  end

  # Test file structure
  def test_has_metadata_section
    assert @mapping["metadata"], "Should have metadata section"
    assert @mapping["metadata"]["total_rules"], "Should have total_rules count"
    assert @mapping["metadata"]["rules_with_skills"], "Should have rules_with_skills count"
    assert @mapping["metadata"]["rules_without_skills"], "Should have rules_without_skills count"
    assert @mapping["metadata"]["coverage_percent"], "Should have coverage_percent"
  end

  def test_metadata_counts_are_correct
    metadata = @mapping["metadata"]

    assert_equal 19, metadata["total_rules"],
                 "Should have 19 total rules"

    rules_with_skills = @mapping["rules_with_skills"]&.keys&.length || 0

    assert_equal metadata["rules_with_skills"], rules_with_skills,
                 "rules_with_skills count should match actual count"

    # Coverage calculation
    expected_coverage = (rules_with_skills.to_f / 19 * 100).round

    assert_equal expected_coverage, metadata["coverage_percent"],
                 "coverage_percent should be correctly calculated"
  end

  def test_has_rules_by_domain_section
    assert @mapping["rules_by_domain"], "Should have rules_by_domain section"
    assert_kind_of Hash, @mapping["rules_by_domain"], "rules_by_domain should be a hash"
  end

  def test_all_domains_are_defined
    domains = @mapping["rules_by_domain"]

    expected_domains = %w[
      stack_architecture
      routing
      testing
      frontend
      backend
      workflow
      philosophy
      code_quality
    ]

    expected_domains.each do |domain|
      assert domains[domain], "Should have '#{domain}' domain"
      assert domains[domain]["description"], "#{domain} should have description"
      assert domains[domain]["rules"], "#{domain} should have rules list"
    end
  end

  def test_domains_have_valid_structure
    @mapping["rules_by_domain"].each do |domain_name, domain_data|
      assert domain_data["description"], "#{domain_name} should have description"
      assert_kind_of String, domain_data["description"],
                     "#{domain_name} description should be a string"

      assert domain_data["rules"], "#{domain_name} should have rules"
      assert_kind_of Array, domain_data["rules"],
                     "#{domain_name} rules should be an array"

      assert domain_data["agents"], "#{domain_name} should have agents"
      assert_kind_of Array, domain_data["agents"],
                     "#{domain_name} agents should be an array"
    end
  end

  def test_has_rules_with_skills_section
    assert @mapping["rules_with_skills"], "Should have rules_with_skills section"
    assert_kind_of Hash, @mapping["rules_with_skills"],
                   "rules_with_skills should be a hash"
  end

  def test_has_rules_without_skills_section
    assert @mapping["rules_without_skills"], "Should have rules_without_skills section"
    assert_kind_of Hash, @mapping["rules_without_skills"],
                   "rules_without_skills should be a hash"
  end

  def test_has_keyword_to_rule_lookup
    assert @mapping["keyword_to_rule"], "Should have keyword_to_rule lookup section"
    assert_kind_of Hash, @mapping["keyword_to_rule"],
                   "keyword_to_rule should be a hash"
  end

  # Test individual rule structure
  def test_rules_with_skills_have_required_fields
    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      assert rule_data["id"], "#{rule_key} should have id"
      assert rule_data["name"], "#{rule_key} should have name"
      assert rule_data["severity"], "#{rule_key} should have severity"
      assert rule_data["enforcement_action"], "#{rule_key} should have enforcement_action"
      assert rule_data["category"], "#{rule_key} should have category"
      # NOTE: Some critical rules (like rule_17) are in rules_with_skills for organizational purposes
      # but don't have implementation skills (they're workflow/process rules)
    end
  end

  def test_critical_rules_have_violation_triggers
    critical_rules = @mapping["rules_with_skills"].select do |_, rule_data|
      rule_data["severity"] == "critical"
    end

    critical_rules.each do |rule_key, rule_data|
      # Skip rules that don't need triggers (like rule_17)
      next if rule_data["id"] == 17

      assert rule_data["violation_triggers"],
             "#{rule_key} (critical) should have violation_triggers"

      triggers = rule_data["violation_triggers"]

      assert triggers["keywords"] || triggers["patterns"],
             "#{rule_key} violation_triggers should have keywords or patterns"

      if triggers["keywords"]
        assert_kind_of Array, triggers["keywords"],
                       "#{rule_key} keywords should be an array"
      end

      if triggers["patterns"]
        assert_kind_of Array, triggers["patterns"],
                       "#{rule_key} patterns should be an array"
      end
    end
  end

  def test_critical_rules_have_rejection_response
    critical_rules = @mapping["rules_with_skills"].select do |_, rule_data|
      rule_data["severity"] == "critical" && rule_data["enforcement_action"] == "REJECT"
    end

    critical_rules.each do |rule_key, rule_data|
      assert rule_data["rejection_response"],
             "#{rule_key} (critical REJECT) should have rejection_response"
      assert_kind_of String, rule_data["rejection_response"],
                     "#{rule_key} rejection_response should be a string"
    end
  end

  def test_rule_ids_match_rule_numbers
    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      # Extract number from rule_key (e.g., "rule_1_solid_stack" -> 1)
      expected_id = rule_key.match(/rule_(\d+)_/)[1].to_i

      assert_equal expected_id, rule_data["id"],
                   "#{rule_key} id should match the number in the key"
    end
  end

  def test_rule_severities_are_valid
    valid_severities = %w[critical high moderate]

    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      assert_includes valid_severities, rule_data["severity"],
                      "#{rule_key} severity should be one of: #{valid_severities.join(', ')}"
    end
  end

  def test_enforcement_actions_are_valid
    valid_actions = %w[REJECT SUGGEST]

    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      assert_includes valid_actions, rule_data["enforcement_action"],
                      "#{rule_key} enforcement_action should be REJECT or SUGGEST"
    end
  end

  def test_rule_categories_match_domains
    valid_categories = @mapping["rules_by_domain"].keys

    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      assert_includes valid_categories, rule_data["category"],
                      "#{rule_key} category '#{rule_data['category']}' should be a valid domain"
    end
  end

  # Test skills references
  def test_primary_skills_exist_in_registry
    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      next unless rule_data["skills"]

      primary_skill = rule_data["skills"]["primary"]
      next unless primary_skill

      assert_includes @all_skills, primary_skill,
                      "#{rule_key} references primary skill '#{primary_skill}' which doesn't exist in SKILLS_REGISTRY.yml"
    end
  end

  def test_related_skills_exist_in_registry
    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      next unless rule_data["skills"] && rule_data["skills"]["related"]

      rule_data["skills"]["related"].each do |related|
        skill_name = related["skill"]

        assert_includes @all_skills, skill_name,
                        "#{rule_key} references related skill '#{skill_name}' which doesn't exist in SKILLS_REGISTRY.yml"
      end
    end
  end

  def test_skill_locations_have_correct_format
    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      next unless rule_data["skills"]

      # Check primary skill location
      if rule_data["skills"]["location"]
        location = rule_data["skills"]["location"]

        assert_match(%r{^skills/\w+/[\w-]+\.md$}, location,
                     "#{rule_key} primary skill location should match pattern 'skills/domain/skill-name.md'")
      end

      # Check related skill locations
      next unless rule_data["skills"]["related"]

      rule_data["skills"]["related"].each do |related|
        next unless related["location"]

        location = related["location"]

        assert_match(%r{^skills/\w+/[\w-]+\.md$}, location,
                     "#{rule_key} related skill location should match pattern 'skills/domain/skill-name.md'")
      end
    end
  end

  def test_skill_files_actually_exist
    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      next unless rule_data["skills"]

      # Check primary skill file
      if rule_data["skills"]["location"]
        location = rule_data["skills"]["location"]

        assert_path_exists location,
                           "#{rule_key} primary skill file should exist at #{location}"
      end

      # Check related skill files
      next unless rule_data["skills"]["related"]

      rule_data["skills"]["related"].each do |related|
        next unless related["location"]

        location = related["location"]

        assert_path_exists location,
                           "#{rule_key} related skill file should exist at #{location}"
      end
    end
  end

  # Test keyword lookup
  def test_keyword_to_rule_references_valid_rules
    all_rule_keys = @mapping["rules_with_skills"].keys +
                    @mapping["rules_without_skills"].keys

    @mapping["keyword_to_rule"].each do |keyword, rule_key|
      assert_includes all_rule_keys, rule_key,
                      "keyword '#{keyword}' references invalid rule '#{rule_key}'"
    end
  end

  def test_keywords_are_lowercase
    @mapping["keyword_to_rule"].each_key do |keyword|
      assert_equal keyword, keyword.downcase,
                   "Keyword '#{keyword}' should be lowercase for consistency"
    end
  end

  # Test completeness
  def test_all_19_rules_are_accounted_for
    rules_with_skills = @mapping["rules_with_skills"].keys
    rules_without_skills = @mapping["rules_without_skills"].keys

    all_rules = (rules_with_skills + rules_without_skills).map do |rule_key|
      rule_key.match(/rule_(\d+)_/)[1].to_i
    end.sort

    assert_equal (1..19).to_a, all_rules,
                 "All 19 rules should be present in either rules_with_skills or rules_without_skills"
  end

  def test_no_rules_are_duplicated
    rules_with_skills = @mapping["rules_with_skills"].keys
    rules_without_skills = @mapping["rules_without_skills"].keys

    intersection = rules_with_skills & rules_without_skills

    assert_empty intersection,
                 "Rules should not appear in both rules_with_skills and rules_without_skills: #{intersection.join(', ')}"
  end

  def test_rules_in_domains_match_rules_sections
    # Get all rules from rules_by_domain
    rules_in_domains = @mapping["rules_by_domain"].values.flat_map { |d| d["rules"] }.uniq.sort

    # Get all rules from rules_with_skills and rules_without_skills
    all_rules = (@mapping["rules_with_skills"].keys + @mapping["rules_without_skills"].keys).sort

    assert_equal all_rules.sort, rules_in_domains.sort,
                 "Rules in domains should match rules in rules_with_skills + rules_without_skills"
  end

  def test_critical_rules_match_expected_list
    critical_rules = @mapping["rules_with_skills"].select do |_, rule_data|
      rule_data["severity"] == "critical"
    end.keys

    # Extract rule numbers
    critical_rule_numbers = critical_rules.map do |rule_key|
      rule_key.match(/rule_(\d+)_/)[1].to_i
    end.sort

    expected_critical = [1, 2, 3, 4, 17, 18]

    assert_equal expected_critical, critical_rule_numbers,
                 "Critical rules should be: #{expected_critical.join(', ')}"
  end

  # Test rules without skills
  def test_rules_without_skills_have_required_fields
    @mapping["rules_without_skills"].each do |rule_key, rule_data|
      assert rule_data["id"], "#{rule_key} should have id"
      assert rule_data["name"], "#{rule_key} should have name"
      assert rule_data["severity"], "#{rule_key} should have severity"
      assert rule_data["category"], "#{rule_key} should have category"
      assert rule_data["reason"], "#{rule_key} should have reason for no skills"
    end
  end

  def test_rules_without_skills_have_valid_reasons
    valid_reasons = [
      "Enforced by rubocop",
      "Process/workflow rule",
      "Philosophy/principle",
      "Deprecation guidance"
    ]

    @mapping["rules_without_skills"].each do |rule_key, rule_data|
      next unless rule_data["reason"]

      reason_valid = valid_reasons.any? { |valid| rule_data["reason"].include?(valid) }

      assert reason_valid,
             "#{rule_key} reason '#{rule_data['reason']}' should mention one of: #{valid_reasons.join(', ')}"
    end
  end
end
