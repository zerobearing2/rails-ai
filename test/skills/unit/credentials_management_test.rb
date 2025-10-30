# frozen_string_literal: true

require_relative "../skill_test_case"

class CredentialsManagementTest < SkillTestCase
  self.skill_domain = "config"
  self.skill_name = "credentials-management"

  def test_skill_file_exists
    assert skill_file_exists?("config", "credentials-management"),
           "credentials-management.md should exist in skills/config/"
  end

  def test_has_yaml_front_matter
    assert_skill_has_yaml_front_matter
  end

  def test_has_required_metadata
    assert_skill_has_required_metadata
    assert_equal "credentials-management", skill_metadata["name"]
    assert_equal "config", skill_metadata["domain"]
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
