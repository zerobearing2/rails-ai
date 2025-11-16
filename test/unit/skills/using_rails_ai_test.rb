# frozen_string_literal: true

require "test_helper"

class UsingRailsAiTest < SkillTestCase
  self.skill_name = "using-rails-ai"
  self.skill_directory = "using-rails-ai"

  def test_skill_directory_exists
    assert_skill_directory_exists
  end

  def test_has_skill_md_file
    assert_has_skill_md_file
  end

  def test_has_minimal_frontmatter
    assert_has_minimal_frontmatter
  end

  def test_name_has_rails_ai_prefix
    assert_name_has_rails_ai_prefix
  end

  def test_description_is_present
    assert_description_is_present
  end

  def test_has_required_sections
    # using-rails-ai is a meta/documentation skill
    # It uses markdown headers instead of XML sections
    skip "Meta skill uses different structure (markdown headers, not XML sections)"
  end

  def test_xml_tags_valid
    assert_xml_tags_valid
  end

  def test_has_code_examples
    # using-rails-ai is a meta/documentation skill
    # It has a diagram and example text, but not code examples in code fences
    skip "Meta skill is documentation-focused, no code examples required"
  end
end
