# frozen_string_literal: true

require_relative "../skill_test_case"

class TurboPageRefreshTest < SkillTestCase
  self.skill_domain = "frontend"
  self.skill_name = "turbo-page-refresh"

  def test_skill_file_exists
    assert skill_file_exists?("frontend", "turbo-page-refresh"),
           "turbo-page-refresh.md should exist in skills/frontend/"
  end

  def test_has_yaml_front_matter
    assert_skill_has_yaml_front_matter
  end

  def test_has_required_metadata
    assert_skill_has_required_metadata

    assert_equal "turbo-page-refresh", skill_metadata["name"]
    assert_equal "frontend", skill_metadata["domain"]
    assert_in_delta(1.0, skill_metadata["version"])
  end

  def test_has_dependencies
    assert skill_metadata.key?("dependencies"),
           "Skill should declare dependencies (even if empty array)"

    # turbo-page-refresh depends on hotwire-turbo
    assert_includes skill_metadata["dependencies"], "hotwire-turbo",
                    "turbo-page-refresh should depend on hotwire-turbo"
  end

  def test_has_required_sections
    assert_skill_has_section("when-to-use")
    assert_skill_has_section("benefits")
    assert_skill_has_section("standards")
    assert_skill_has_section("antipatterns")
    assert_skill_has_section("testing")
    assert_skill_has_section("related-skills")
    assert_skill_has_section("resources")
  end

  def test_has_key_patterns
    assert_skill_has_pattern("enable-page-refresh")
    assert_skill_has_pattern("broadcast-page-refresh")
    assert_skill_has_pattern("permanent-elements")
    assert_skill_has_pattern("customize-morphing")
  end

  def test_has_code_examples
    assert_code_examples_are_valid
  end

  def test_has_good_and_bad_examples
    assert_has_good_and_bad_examples
  end

  def test_documents_morph_method
    assert_pattern_present(
      skill_content,
      /data-turbo-refresh-method="morph"/,
      "Should document data-turbo-refresh-method attribute"
    )
  end

  def test_documents_scroll_preservation
    assert_pattern_present(
      skill_content,
      /data-turbo-refresh-scroll="preserve"/,
      "Should document scroll preservation"
    )
  end

  def test_documents_broadcast_refresh
    assert_pattern_present(
      skill_content,
      /broadcast_refresh_to/,
      "Should document broadcast_refresh_to method"
    )
  end

  def test_documents_permanent_elements
    assert_pattern_present(
      skill_content,
      /data-turbo-permanent/,
      "Should document data-turbo-permanent attribute"
    )
  end

  def test_shows_antipatterns
    # Should show when NOT to use frames
    assert_includes skill_content, "turbo_frame_tag",
                    "Should mention turbo_frame_tag in antipatterns"

    # Should be marked as bad
    antipatterns_section = skill_content[%r{<antipatterns>.*</antipatterns>}m]

    assert antipatterns_section, "Should have antipatterns section"
    assert_includes antipatterns_section, "❌",
                    "Antipatterns should be marked with ❌"
  end

  def test_shows_when_to_use_over_frames
    assert skill_content.include?("simpler") || skill_content.include?("Simpler"),
           "Should explain that page refresh is simpler than frames"
  end

  def test_includes_testing_examples
    testing_section = skill_content[%r{<testing>.*</testing>}m]

    assert testing_section, "Should have testing section"

    # Should show how to test page refresh behavior
    assert_pattern_present(
      testing_section,
      /using_session|ApplicationSystemTestCase|test.*refresh/i,
      "Testing section should show system test examples"
    )
  end

  def test_links_related_skills
    related_section = skill_content[%r{<related-skills>.*</related-skills>}m]

    assert related_section, "Should have related-skills section"

    assert_includes related_section, "hotwire-turbo",
                    "Should link to hotwire-turbo skill"
  end

  def test_includes_turbo_documentation_resources
    resources_section = skill_content[%r{<resources>.*</resources>}m]

    assert resources_section, "Should have resources section"

    assert_pattern_present(
      resources_section,
      /turbo\.hotwired\.dev|hotwired\.dev/i,
      "Should link to official Turbo documentation"
    )
  end

  def test_code_examples_use_rails_8_conventions
    examples = extract_code_examples(skill_content)

    # Check for modern Rails patterns
    code_text = examples.join("\n")

    # Should show turbo-rails 2.0+ patterns
    assert_pattern_present(
      code_text,
      /broadcast_refresh|data-turbo-refresh/,
      "Examples should use Turbo 2.0+ page refresh API"
    )
  end

  def test_shows_spa_benefits
    benefits_section = skill_content[%r{<benefits>.*</benefits>}m]

    assert benefits_section, "Should have benefits section"

    assert_pattern_present(
      benefits_section,
      /SPA|single.?page/i,
      "Should explain SPA-like benefits"
    )
  end
end
