# frozen_string_literal: true

require_relative "../../support/skill_test_case"

class ViewcomponentSlotsTest < SkillTestCase
  self.skill_domain = "frontend"
  self.skill_name = "viewcomponent-slots"

  def test_skill_file_exists
    assert skill_file_exists?("frontend", "viewcomponent-slots"),
           "viewcomponent-slots.md should exist in skills/frontend/"
  end

  def test_has_yaml_front_matter
    assert_skill_has_yaml_front_matter
  end

  def test_has_required_metadata
    assert_skill_has_required_metadata
    assert_equal "viewcomponent-slots", skill_metadata["name"]
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
