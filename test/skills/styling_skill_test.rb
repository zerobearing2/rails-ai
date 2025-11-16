# frozen_string_literal: true

require_relative "skill_test_case"

# Test styling skill behavior using RED-GREEN-REFACTOR cycle
# Verifies skill prevents anti-patterns like hardcoded colors, inline styles, etc.
class StylingSkillTest < SkillTestCase
  def skill_name
    "styling"
  end
end

# Auto-generate test methods from scenario files
StylingSkillTest.generate_tests_from_scenarios
