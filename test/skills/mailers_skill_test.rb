# frozen_string_literal: true

require_relative "skill_test_case"

# Test mailers skill behavior using RED-GREEN-REFACTOR cycle
# Verifies skill prevents anti-patterns like path helpers, deliver_now, etc.
class MailersSkillTest < SkillTestCase
  def skill_name
    "mailers"
  end
end

# Auto-generate test methods from scenario files
MailersSkillTest.generate_tests_from_scenarios
