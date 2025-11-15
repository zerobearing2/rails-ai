# frozen_string_literal: true

require_relative "../test_helper"

# Base class for skill unit tests in new structure
# Tests skills in skills-new/{directory}/SKILL.md format
class SkillTestCase < Minitest::Test
  class << self
    attr_accessor :skill_name, :skill_directory
  end

  def skill_path
    File.join(SKILLS_NEW_PATH, self.class.skill_directory)
  end

  def skill_file_path
    File.join(skill_path, "SKILL.md")
  end

  def skill_content
    @skill_content ||= load_skill(self.class.skill_directory)
  end

  def skill_metadata
    @skill_metadata ||= parse_skill_yaml(skill_content)
  end

  def frontmatter
    # Extract just the frontmatter string for pattern matching
    skill_content.match(/\A---\n(.*?)\n---\n/m)&.captures&.first || ""
  end

  # Common assertions for all skills in new structure

  def assert_skill_directory_exists
    assert Dir.exist?(skill_path),
           "Skill directory should exist at: #{skill_path}"
  end

  def assert_has_skill_md_file
    assert File.exist?(skill_file_path),
           "SKILL.md should exist at: #{skill_file_path}"
  end

  def assert_has_minimal_frontmatter
    assert_predicate skill_metadata, :any?, "Skill must have YAML front matter"

    # Check for name and description in frontmatter
    assert skill_metadata["name"], "Skill must have 'name' in frontmatter"
    assert skill_metadata["description"], "Skill must have 'description' in frontmatter"
  end

  def assert_name_has_rails_ai_prefix
    name = skill_metadata["name"]

    # Exception: using-rails-ai meta skill doesn't have prefix
    return if self.class.skill_directory == "using-rails-ai"

    assert name&.start_with?("rails-ai:"),
           "Skill name must have 'rails-ai:' prefix, got: #{name}"
  end

  def assert_description_is_present
    description = skill_metadata["description"]
    assert description, "Description must be present"
    refute_empty description.to_s.strip, "Description must not be empty"
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

  def assert_xml_tags_valid
    # Check that all opening tags have closing tags
    opening_tags = skill_content.scan(/<([a-z\-]+)(?:\s|>)/).flatten
    closing_tags = skill_content.scan(/<\/([a-z\-]+)>/).flatten

    # Common XML tags used in skills
    common_tags = %w[
      when-to-use benefits standards pattern antipatterns testing
      related-skills superpowers-integration team-rule-enforcement
    ]

    common_tags.each do |tag|
      next unless skill_content.include?("<#{tag}>")

      opening_count = skill_content.scan(/<#{tag}>/).size
      closing_count = skill_content.scan(/<\/#{tag}>/).size

      assert_equal opening_count, closing_count,
                   "Tag <#{tag}> has mismatched opening/closing tags (#{opening_count} opening, #{closing_count} closing)"
    end
  end

  def assert_references_superpowers(expected_skill)
    # Check if skill references a superpowers skill appropriately
    assert_includes skill_content, expected_skill,
                    "Skill should reference #{expected_skill}"
  end
end
