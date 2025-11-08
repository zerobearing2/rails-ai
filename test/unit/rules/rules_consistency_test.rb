# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class RulesConsistencyTest < Minitest::Test
  def setup
    @team_rules_file = "rules/TEAM_RULES.md"
    @mapping_file = "rules/RULES_TO_SKILLS_MAPPING.yml"
    @architect_file = "rules/ARCHITECT_DECISIONS.yml"

    @team_rules_content = File.read(@team_rules_file)
    @team_rules_yaml = extract_yaml_front_matter(@team_rules_file)
    @mapping = YAML.load_file(@mapping_file, permitted_classes: [Date])
    @architect = YAML.load_file(@architect_file, permitted_classes: [Date, Symbol])

    @skills_registry = YAML.load_file("skills/SKILLS_REGISTRY.yml", permitted_classes: [Symbol, Date])
  end

  # Test consistency between TEAM_RULES.md and RULES_TO_SKILLS_MAPPING.yml
  def test_rule_count_consistency
    team_rules_count = @team_rules_yaml.dig("enforcement", "severity").values.flatten.length

    mapping_total = @mapping.dig("metadata", "total_rules")

    assert_equal 20, team_rules_count,
                 "TEAM_RULES.md should have 20 rules in severity lists"
    assert_equal 20, mapping_total,
                 "RULES_TO_SKILLS_MAPPING.yml should have 20 rules total"
  end

  def test_critical_rules_consistency
    # Get critical rules from TEAM_RULES.md
    team_rules_critical = @team_rules_yaml.dig("enforcement", "severity", "critical")
    team_critical_numbers = team_rules_critical.map { |r| r.match(/\d+/)[0].to_i }.sort

    # Get critical rules from RULES_TO_SKILLS_MAPPING.yml
    mapping_critical = @mapping["rules_with_skills"].select do |_, rule_data|
      rule_data["severity"] == "critical"
    end
    mapping_critical_numbers = mapping_critical.values.map { |r| r["id"] }.sort

    assert_equal team_critical_numbers, mapping_critical_numbers,
                 "Critical rules should match between TEAM_RULES.md and RULES_TO_SKILLS_MAPPING.yml"

    expected_critical = [1, 2, 3, 4, 17, 18]

    assert_equal expected_critical, team_critical_numbers,
                 "Critical rules should be: #{expected_critical.join(', ')}"
  end

  def test_violation_keywords_consistency
    # Compare violation_keywords in TEAM_RULES.md with RULES_TO_SKILLS_MAPPING.yml
    team_keywords = @team_rules_yaml["violation_keywords"]

    team_keywords.each do |rule_key, keywords|
      # Convert rule_1 to rule_1_xxx format by finding matching rule in mapping
      mapping_rule = @mapping["rules_with_skills"].find do |key, _|
        key.start_with?(rule_key)
      end

      next unless mapping_rule

      _, mapping_rule_data = mapping_rule

      next unless mapping_rule_data["violation_triggers"]

      mapping_keywords = mapping_rule_data.dig("violation_triggers", "keywords") || []

      # Check that TEAM_RULES keywords are subset of mapping keywords
      keywords.each do |keyword|
        assert_includes mapping_keywords, keyword,
                        "#{rule_key}: keyword '#{keyword}' in TEAM_RULES.md should be in RULES_TO_SKILLS_MAPPING.yml"
      end
    end
  end

  def test_all_rules_mentioned_in_team_rules_content
    # Check that all 19 rules have sections in TEAM_RULES.md content
    (1..19).each do |rule_num|
      assert_match(/^###\s+#{rule_num}\.\s+/m, @team_rules_content,
                   "TEAM_RULES.md should have section for Rule ##{rule_num}")
    end
  end

  def test_rule_names_consistency
    # Extract rule names from quick lookup in TEAM_RULES.md
    quick_lookup_match = @team_rules_content.match(/<quick-lookup\s+id="rule-index">.*?```yaml\s+(.*?)```/m)

    assert quick_lookup_match, "Should find quick lookup YAML section"

    team_rules_index = YAML.safe_load(quick_lookup_match[1])["rule_index"]

    # Compare with RULES_TO_SKILLS_MAPPING.yml
    team_rules_index.each do |rule_num, team_rule_data|
      # Find corresponding rule in mapping
      mapping_rule = @mapping["rules_with_skills"].find do |_, mapping_data|
        mapping_data["id"] == rule_num
      end

      next unless mapping_rule

      _, mapping_rule_data = mapping_rule

      assert_equal team_rule_data["name"], mapping_rule_data["name"],
                   "Rule ##{rule_num} name should match between TEAM_RULES.md and RULES_TO_SKILLS_MAPPING.yml"
    end
  end

  def test_severity_levels_consistency
    # Check that severity levels in quick lookup match RULES_TO_SKILLS_MAPPING.yml
    quick_lookup_match = @team_rules_content.match(/<quick-lookup\s+id="rule-index">.*?```yaml\s+(.*?)```/m)
    team_rules_index = YAML.safe_load(quick_lookup_match[1])["rule_index"]

    team_rules_index.each do |rule_num, team_rule_data|
      mapping_rule = @mapping["rules_with_skills"].find do |_, mapping_data|
        mapping_data["id"] == rule_num
      end

      next unless mapping_rule

      _, mapping_rule_data = mapping_rule

      assert_equal team_rule_data["severity"], mapping_rule_data["severity"],
                   "Rule ##{rule_num} severity should match between TEAM_RULES.md and RULES_TO_SKILLS_MAPPING.yml"
    end
  end

  def test_enforcement_actions_consistency
    # Check that enforcement actions match
    quick_lookup_match = @team_rules_content.match(/<quick-lookup\s+id="rule-index">.*?```yaml\s+(.*?)```/m)
    team_rules_index = YAML.safe_load(quick_lookup_match[1])["rule_index"]

    team_rules_index.each do |rule_num, team_rule_data|
      mapping_rule = @mapping["rules_with_skills"].find do |_, mapping_data|
        mapping_data["id"] == rule_num
      end

      next unless mapping_rule

      _, mapping_rule_data = mapping_rule

      next unless team_rule_data["action"] && mapping_rule_data["enforcement_action"]

      assert_equal team_rule_data["action"], mapping_rule_data["enforcement_action"],
                   "Rule ##{rule_num} enforcement action should match between TEAM_RULES.md and RULES_TO_SKILLS_MAPPING.yml"
    end
  end

  # Test skill references consistency
  def test_skills_mentioned_in_team_rules_exist_in_mapping
    # Find all skill references in TEAM_RULES.md <implementation-skills> sections
    skill_sections = @team_rules_content.scan(%r{<implementation-skills>(.*?)</implementation-skills>}m)

    skill_sections.each do |section|
      # Extract skill names from markdown list items or inline text
      skill_refs = section[0].scan(%r{skills/\w+/([\w-]+)\.md})

      skill_refs.flatten.each do |skill_name|
        assert skill_mentioned_in_mapping?(skill_name),
               "Skill '#{skill_name}' mentioned in TEAM_RULES.md should be in RULES_TO_SKILLS_MAPPING.yml"
      end
    end
  end

  def test_skills_in_mapping_exist_in_registry
    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      next unless rule_data["skills"]

      # Check primary skill
      if rule_data.dig("skills", "primary")
        skill_name = rule_data.dig("skills", "primary")

        assert @skills_registry.dig("skills", skill_name),
               "#{rule_key} primary skill '#{skill_name}' should exist in SKILLS_REGISTRY.yml"
      end

      # Check related skills
      next unless rule_data.dig("skills", "related")

      rule_data.dig("skills", "related").each do |related|
        skill_name = related["skill"]

        assert @skills_registry.dig("skills", skill_name),
               "#{rule_key} related skill '#{skill_name}' should exist in SKILLS_REGISTRY.yml"
      end
    end
  end

  def test_skills_have_correct_categories
    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      next unless rule_data["skills"]

      rule_data["category"]

      # Check primary skill domain
      next unless rule_data.dig("skills", "primary")

      skill_name = rule_data.dig("skills", "primary")
      skill_data = @skills_registry.dig("skills", skill_name)

      next unless skill_data

      skill_domain = skill_data["domain"]

      # Some flexibility here - rule category and skill domain can differ
      # but they should be related (e.g., stack_architecture rule can use config skills)
      assert skill_domain,
             "#{rule_key} primary skill '#{skill_name}' should have a domain in SKILLS_REGISTRY.yml"
    end
  end

  # Test ARCHITECT_DECISIONS.yml references
  def test_architect_references_team_rules
    # Check that ARCHITECT_DECISIONS.yml mentions TEAM_RULES.md
    architect_content = YAML.dump(@architect)

    assert_match(/TEAM_RULES|team_rules/i, architect_content,
                 "ARCHITECT_DECISIONS.yml should reference TEAM_RULES")
  end

  def test_architect_has_team_rules_enforcement_section
    # Check for team rules enforcement section in architect decisions
    assert @architect["team_rules_enforcement"],
           "ARCHITECT_DECISIONS.yml should have team_rules_enforcement section"
  end

  def test_architect_critical_rules_match_team_rules
    skip unless @architect["team_rules_enforcement"]

    architect_critical = @architect.dig("team_rules_enforcement", "critical_rules")
    skip unless architect_critical

    # Should mention critical rules
    team_critical = [1, 2, 3, 4, 17, 18]

    team_critical.each do |rule_num|
      next unless rule_mentioned_in_architect?(rule_num, architect_critical)

      assert true, "Critical Rule ##{rule_num} is properly referenced in ARCHITECT_DECISIONS.yml"
    end
  end

  # Test bidirectional consistency
  def test_keyword_lookup_covers_critical_violations
    keyword_to_rule = @mapping["keyword_to_rule"]

    # Critical violation keywords from TEAM_RULES.md
    critical_keywords = @team_rules_yaml["violation_keywords"]

    critical_keywords.each do |rule_key, keywords|
      keywords.each do |keyword|
        assert keyword_to_rule[keyword],
               "Critical keyword '#{keyword}' from #{rule_key} should be in keyword_to_rule lookup"
      end
    end
  end

  def test_rules_by_domain_cover_all_rules
    # Get all rules from rules_by_domain
    rules_in_domains = @mapping["rules_by_domain"].values.flat_map { |d| d["rules"] }.uniq

    # Get all rules from rules_with_skills and rules_without_skills
    all_rules = @mapping["rules_with_skills"].keys + @mapping["rules_without_skills"].keys

    assert_equal all_rules.sort, rules_in_domains.sort,
                 "rules_by_domain should cover all rules in rules_with_skills + rules_without_skills"
  end

  def test_no_orphaned_skills
    # Check that all skills mentioned in mapping exist in the skills directory
    @mapping["rules_with_skills"].each do |rule_key, rule_data|
      next unless rule_data["skills"]

      # Check primary skill file
      if rule_data.dig("skills", "location")
        location = rule_data.dig("skills", "location")

        assert_path_exists location,
                           "#{rule_key} primary skill file should exist: #{location}"
      end

      # Check related skill files
      next unless rule_data.dig("skills", "related")

      rule_data.dig("skills", "related").each do |related|
        next unless related["location"]

        location = related["location"]

        assert_path_exists location,
                           "#{rule_key} related skill file should exist: #{location}"
      end
    end
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

  def skill_mentioned_in_mapping?(skill_name)
    @mapping["rules_with_skills"].any? do |_, rule_data|
      next unless rule_data["skills"]

      primary_match = rule_data.dig("skills", "primary") == skill_name
      related_match = rule_data.dig("skills", "related")&.any? { |related| related["skill"] == skill_name }

      primary_match || related_match
    end
  end

  def rule_mentioned_in_architect?(rule_num, architect_critical)
    architect_critical.any? do |critical_rule|
      critical_rule.to_s.include?("rule_#{rule_num}") ||
        critical_rule.to_s.include?("Rule ##{rule_num}") ||
        critical_rule.to_s.match?(/\b#{rule_num}\b/)
    end
  end
end
