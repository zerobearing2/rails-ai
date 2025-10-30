# frozen_string_literal: true

require_relative "../skill_test_case"

class SecurityXssTest < SkillTestCase
  self.skill_domain = "security"
  self.skill_name = "security-xss"

  def test_skill_file_exists
    assert skill_file_exists?("security", "security-xss"),
           "security-xss.md should exist in skills/security/"
  end

  def test_has_yaml_front_matter
    assert_skill_has_yaml_front_matter
  end

  def test_has_required_metadata
    assert_skill_has_required_metadata
    assert_equal "security-xss", skill_metadata["name"]
    assert_equal "security", skill_metadata["domain"]
  end

  def test_has_required_sections
    assert_skill_has_section("when-to-use")
    assert_skill_has_section("attack-vectors")
    assert_skill_has_section("standards")
  end

  def test_has_code_examples
    assert_code_examples_are_valid
  end
end
