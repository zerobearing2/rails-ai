# frozen_string_literal: true

require_relative "../../support/skill_test_case"

class TailwindUtilityFirstTest < SkillTestCase
  self.skill_domain = "frontend"
  self.skill_name = "tailwind-utility-first"

  def test_skill_file_exists
    assert skill_file_exists?("frontend", "tailwind-utility-first"),
           "tailwind-utility-first.md should exist in skills/frontend/"
  end

  def test_has_yaml_front_matter
    assert_skill_has_yaml_front_matter
  end

  def test_has_required_metadata
    assert_skill_has_required_metadata
    assert_equal "tailwind-utility-first", skill_metadata["name"]
    assert_equal "frontend", skill_metadata["domain"]
  end

  def test_has_required_sections
    assert_skill_has_section("when-to-use")
    assert_skill_has_section("benefits")
    assert_skill_has_section("standards")
  end

  def test_has_code_examples
    assert_code_examples_are_valid
  end
end
