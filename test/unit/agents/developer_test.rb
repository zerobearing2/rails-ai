# frozen_string_literal: true

require_relative "../../test_helper"

class DeveloperAgentTest < Minitest::Test
  def setup
    @agent_file = "agents/developer.md"
    @content = File.read(@agent_file)
  end

  def test_agent_file_exists
    assert_path_exists @agent_file, "developer.md agent should exist"
  end

  # Placeholder tests
  def test_agent_has_mode_placeholder
    assert_match(/\{\{MODE\}\}/i, @content,
                 "Agent should have {{MODE}} placeholder")
  end

  def test_agent_has_task_placeholder
    assert_match(/\{\{TASK\}\}/i, @content,
                 "Agent should have {{TASK}} placeholder")
  end

  def test_agent_has_files_placeholder
    assert_match(/\{\{FILES\}\}/i, @content,
                 "Agent should have {{FILES}} placeholder")
  end

  def test_agent_has_context_placeholder
    assert_match(/\{\{CONTEXT\}\}/i, @content,
                 "Agent should have {{CONTEXT}} placeholder")
  end

  # Mode tests
  def test_agent_defines_feature_mode
    assert_match(/mode.*feature/i, @content,
                 "Agent should define feature mode")
  end

  def test_agent_defines_refactor_mode
    assert_match(/mode.*refactor/i, @content,
                 "Agent should define refactor mode")
  end

  def test_agent_defines_fix_mode
    assert_match(/mode.*fix/i, @content,
                 "Agent should define fix mode")
  end

  def test_agent_explains_mode_differences
    # Feature: no baseline, new functionality (check table)
    assert_match(/feature.*No.*Yes.*new functionality/im, @content,
                 "Feature mode should not require baseline, allow behavior change")

    # Refactor: baseline required, no behavior change (check table)
    assert_match(/refactor.*Yes.*tests must pass.*No.*restructuring/im, @content,
                 "Refactor mode should require baseline, not allow behavior change")

    # Fix: no baseline, fixes issues (check table)
    assert_match(/fix.*No.*Yes.*fixing/im, @content,
                 "Fix mode should not require baseline, allow behavior change")
  end

  # Skill loading tests
  def test_agent_instructs_skill_tool_usage
    assert_match(/Skill tool/i, @content,
                 "Agent should instruct using the Skill tool to load skills")
  end

  def test_agent_references_models_skill
    assert_match(/rails-ai:models/i, @content,
                 "Agent should reference rails-ai:models skill")
  end

  def test_agent_references_controllers_skill
    assert_match(/rails-ai:controllers/i, @content,
                 "Agent should reference rails-ai:controllers skill")
  end

  def test_agent_references_testing_skill
    assert_match(/rails-ai:testing/i, @content,
                 "Agent should reference rails-ai:testing skill")
  end

  def test_agent_references_ui_skill
    assert_match(/rails-ai:ui/i, @content,
                 "Agent should reference rails-ai:ui skill")
  end

  def test_agent_references_hotwire_skill
    assert_match(/rails-ai:hotwire/i, @content,
                 "Agent should reference rails-ai:hotwire skill")
  end

  def test_agent_references_styling_skill
    assert_match(/rails-ai:styling/i, @content,
                 "Agent should reference rails-ai:styling skill")
  end

  def test_agent_references_jobs_skill
    assert_match(/rails-ai:jobs/i, @content,
                 "Agent should reference rails-ai:jobs skill")
  end

  def test_agent_references_mailers_skill
    assert_match(/rails-ai:mailers/i, @content,
                 "Agent should reference rails-ai:mailers skill")
  end

  def test_agent_references_security_skill
    assert_match(/rails-ai:security/i, @content,
                 "Agent should reference rails-ai:security skill")
  end

  def test_testing_skill_is_always_required
    assert_match(/testing.*always/i, @content,
                 "Testing skill should always be required")
  end

  # TDD tests
  def test_agent_requires_tdd
    assert_match(/TDD/i, @content,
                 "Agent should require TDD")
    assert_match(/RED-GREEN-REFACTOR/i, @content,
                 "Agent should reference RED-GREEN-REFACTOR cycle")
  end

  def test_agent_describes_red_green_refactor
    assert_match(/RED.*failing test/i, @content,
                 "Agent should describe RED phase")
    assert_match(/GREEN.*pass/i, @content,
                 "Agent should describe GREEN phase")
    assert_match(/REFACTOR.*clean/i, @content,
                 "Agent should describe REFACTOR phase")
  end

  # Critical rules tests
  def test_agent_mentions_critical_rules
    assert_match(/Rule #1.*Solid Stack/i, @content,
                 "Agent should mention Rule #1 (Solid Stack)")
    assert_match(/Rule #2.*Minitest/i, @content,
                 "Agent should mention Rule #2 (Minitest)")
    assert_match(/Rule #3.*RESTful/i, @content,
                 "Agent should mention Rule #3 (RESTful)")
    assert_match(/Rule #4.*TDD/i, @content,
                 "Agent should mention Rule #4 (TDD)")
    assert_match(/Rule #17.*bin.ci/i, @content,
                 "Agent should mention Rule #17 (bin/ci)")
    assert_match(/Rule #18.*WebMock/i, @content,
                 "Agent should mention Rule #18 (WebMock)")
  end

  # Verification tests
  def test_agent_requires_bin_ci
    assert_match(/bin.ci/i, @content,
                 "Agent should require bin/ci verification")
  end

  # Output format tests
  def test_agent_specifies_output_format
    assert_match(/status:/i, @content,
                 "Agent should specify status in output")
    assert_match(/mode:/i, @content,
                 "Agent should specify mode in output")
    assert_match(/tests:/i, @content,
                 "Agent should specify tests in output")
    assert_match(/verification:/i, @content,
                 "Agent should specify verification in output")
    assert_match(/files:/i, @content,
                 "Agent should specify files in output")
  end

  def test_agent_tracks_behavior_changed
    assert_match(/behavior_changed/i, @content,
                 "Agent should track behavior_changed")
  end

  def test_refactor_mode_requires_behavior_unchanged
    # Check that refactor mode has critical requirement for behavior_changed
    assert_match(/CRITICAL.*Refactor.*behavior_changed.*false/im, @content,
                 "Refactor mode should require behavior_changed: false")
  end
end
