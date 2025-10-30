# frozen_string_literal: true

require_relative "../skill_test_case"

class ModelTestingAdvancedTest < SkillTestCase
  self.skill_domain = "testing"
  self.skill_name = "model-testing-advanced"

  def test_skill_file_exists
    assert skill_file_exists?("testing", "model-testing-advanced"),
           "model-testing-advanced.md should exist in skills/testing/"
  end

  def test_has_yaml_front_matter
    assert_skill_has_yaml_front_matter
  end

  def test_has_required_metadata
    assert_skill_has_required_metadata
    assert_equal "model-testing-advanced", skill_metadata["name"]
    assert_equal "testing", skill_metadata["domain"]
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
