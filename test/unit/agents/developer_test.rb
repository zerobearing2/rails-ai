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

  # Input documentation tests
  def test_agent_documents_input_format
    assert_match(/Mode:.*feature.*refactor.*fix/im, @content,
                 "Agent should document Mode input")
    assert_match(/Task:/i, @content,
                 "Agent should document Task input")
    assert_match(/Files:/i, @content,
                 "Agent should document Files input")
    assert_match(/Context:/i, @content,
                 "Agent should document Context input")
  end

  # XML mode tags tests
  def test_agent_uses_xml_mode_tags
    assert_match(/<mode-feature>/i, @content,
                 "Agent should have <mode-feature> XML tag")
    assert_match(/<mode-refactor>/i, @content,
                 "Agent should have <mode-refactor> XML tag")
    assert_match(/<mode-fix>/i, @content,
                 "Agent should have <mode-fix> XML tag")
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

  # Quality rules tests - rules are now embedded in agents via <team-rules>
  def test_agent_has_embedded_team_rules
    assert_match(/<team-rules>/i, @content,
                 "Agent should have embedded <team-rules> section")
  end

  def test_agent_mentions_quality_rules
    assert_match(/Be Concise/i, @content,
                 "Agent should mention Be Concise rule")
    assert_match(/Don't Over-Engineer/i, @content,
                 "Agent should mention Don't Over-Engineer rule")
    assert_match(/Reduce Complexity/i, @content,
                 "Agent should mention Reduce Complexity rule")
    assert_match(/No Premature Optimization/i, @content,
                 "Agent should mention No Premature Optimization rule")
  end

  def test_agent_references_domain_rules_in_skills
    assert_match(/Domain rules are in skills/i, @content,
                 "Agent should reference that domain rules are in skills")
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

  def test_refactor_mode_requires_behavior_unchanged
    # Check that refactor mode has critical requirement about behavior change
    assert_match(/CRITICAL.*Refactor.*behavior changed.*status: failed/im, @content,
                 "Refactor mode should fail if behavior changed")
  end
end
