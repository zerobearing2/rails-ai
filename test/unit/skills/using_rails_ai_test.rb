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

  def test_xml_tags_valid
    assert_xml_tags_valid
  end

  # Meta skill-specific tests

  def test_has_architecture_diagram
    assert_includes skill_content, "┌─────────────────────────────────────────────┐",
                    "Meta skill should include architecture diagram"
  end

  def test_explains_superpowers_integration
    assert_includes skill_content, "Superpowers",
                    "Meta skill should explain Superpowers integration"
    assert_includes skill_content, "HOW",
                    "Meta skill should explain HOW (workflows)"
    assert_includes skill_content, "WHAT",
                    "Meta skill should explain WHAT (domain knowledge)"
  end

  def test_lists_available_skills
    # Meta skill should reference the 12 domain skills
    assert_includes skill_content, "12 Rails domain skills",
                    "Meta skill should mention the 12 domain skills"
  end
end
