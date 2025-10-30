# frozen_string_literal: true

require_relative "../test_helper"

# Base class for skill unit tests
class SkillTestCase < Minitest::Test
  class << self
    attr_accessor :skill_domain, :skill_name
  end

  def skill_content
    @skill_content ||= load_skill(self.class.skill_domain, self.class.skill_name)
  end

  def skill_metadata
    @skill_metadata ||= parse_skill_yaml(skill_content)
  end

  # Common assertions for all skills

  def assert_skill_has_yaml_front_matter
    assert_predicate skill_metadata, :any?, "Skill must have YAML front matter"
  end

  def assert_skill_has_required_metadata
    assert skill_metadata["name"], "Skill must have name"
    assert skill_metadata["domain"], "Skill must have domain"
    assert skill_metadata["version"], "Skill must have version"
    assert skill_metadata["rails_version"], "Skill must specify rails_version"
  end

  def assert_skill_has_section(section_name)
    assert_includes skill_content, "<#{section_name}>",
                    "Skill must have <#{section_name}> section"
    assert_includes skill_content, "</#{section_name}>",
                    "Skill <#{section_name}> section must be closed"
  end

  def assert_skill_has_pattern(pattern_name)
    assert_includes skill_content, %(<pattern name="#{pattern_name}">),
                    "Skill must have pattern: #{pattern_name}"
  end

  def assert_code_examples_are_valid
    examples = extract_code_examples(skill_content)

    assert_predicate examples, :any?, "Skill must have code examples"

    examples.each_with_index do |example, index|
      refute_empty example.strip,
                   "Code example #{index + 1} should not be empty"
    end
  end

  def assert_has_good_and_bad_examples
    assert_includes skill_content, "✅",
                    "Skill should mark good examples with ✅"
    assert_includes skill_content, "❌",
                    "Skill should mark bad examples with ❌"
  end

  def assert_pattern_present(code, pattern, message = nil)
    assert_match pattern, code,
                 message || "Expected pattern not found: #{pattern}"
  end

  def assert_pattern_absent(code, pattern, message = nil)
    refute_match pattern, code,
                 message || "Forbidden pattern found: #{pattern}"
  end
end
