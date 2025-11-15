# frozen_string_literal: true

require_relative "../../support/skill_test_case"

class ViewHelpersTest < SkillTestCase
  self.skill_name = "rails-ai:view-helpers"
  self.skill_directory = "view-helpers"

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
    assert_skill_has_section("when-to-use")
    assert_skill_has_section("benefits")
    assert_skill_has_section("standards")
  end

  def test_xml_tags_valid
    assert_xml_tags_valid
  end

  def test_has_code_examples
    assert_code_examples_are_valid
  end
end
