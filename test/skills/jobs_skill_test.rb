# frozen_string_literal: true

require_relative "skill_test_case"

# Test jobs skill behavior using RED-GREEN-REFACTOR cycle
# Verifies skill prevents anti-patterns like deliver_now, missing auth, etc.
class JobsSkillTest < SkillTestCase
  def skill_name
    "jobs"
  end
end

# Auto-generate test methods from scenario files
JobsSkillTest.generate_tests_from_scenarios
