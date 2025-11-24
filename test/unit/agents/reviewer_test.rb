# frozen_string_literal: true

require_relative "../../test_helper"

class ReviewerAgentTest < Minitest::Test
  def setup
    @agent_file = "agents/reviewer.md"
    @content = File.read(@agent_file)
  end

  def test_agent_file_exists
    assert_path_exists @agent_file, "reviewer.md agent should exist"
  end

  # Input documentation tests (matching developer_test.rb pattern)
  def test_agent_documents_input_format
    assert_match(/Mode:.*security.*rules.*domain.*testing.*ui/im, @content,
                 "Agent should document Mode input")
    assert_match(/Task:/i, @content,
                 "Agent should document Task input")
    assert_match(/Files:/i, @content,
                 "Agent should document Files input")
    assert_match(/Context:/i, @content,
                 "Agent should document Context input")
  end

  # XML mode tags tests (matching developer_test.rb pattern)
  def test_agent_uses_xml_mode_tags
    assert_match(/<mode-security>/i, @content,
                 "Agent should have <mode-security> XML tag")
    assert_match(/<mode-rules>/i, @content,
                 "Agent should have <mode-rules> XML tag")
    assert_match(/<mode-domain>/i, @content,
                 "Agent should have <mode-domain> XML tag")
    assert_match(/<mode-testing>/i, @content,
                 "Agent should have <mode-testing> XML tag")
    assert_match(/<mode-ui>/i, @content,
                 "Agent should have <mode-ui> XML tag")
  end

  # Mode tests
  def test_agent_defines_security_mode
    assert_match(/mode.*security/i, @content,
                 "Agent should define security mode")
  end

  def test_agent_defines_rules_mode
    assert_match(/mode.*rules/i, @content,
                 "Agent should define rules mode")
  end

  def test_agent_defines_domain_mode
    assert_match(/mode.*domain/i, @content,
                 "Agent should define domain mode")
  end

  def test_agent_defines_testing_mode
    assert_match(/mode.*testing/i, @content,
                 "Agent should define testing mode")
  end

  def test_agent_defines_ui_mode
    assert_match(/mode.*ui/i, @content,
                 "Agent should define ui mode")
  end

  # Output format tests (unified with developer agent)
  def test_agent_has_unified_output_format
    assert_match(/status:.*success.*failed.*blocked/im, @content,
                 "Agent should have status field in output")
    assert_match(/mode:.*security.*rules.*domain.*testing.*ui/im, @content,
                 "Agent should have mode field in output")
    assert_match(/summary:/i, @content,
                 "Agent should have summary field in output")
  end

  # Skill tool usage tests (matching developer_test.rb pattern)
  def test_agent_instructs_skill_tool_usage
    assert_match(/Skill tool/i, @content,
                 "Agent should instruct using the Skill tool to load skills")
  end

  def test_security_mode_references_security_skill
    assert_match(/rails-ai:security/i, @content,
                 "Security mode should reference rails-ai:security skill")
  end

  def test_security_mode_mentions_key_vulnerabilities
    assert_match(/XSS/i, @content, "Security mode should mention XSS")
    assert_match(/SQL Injection/i, @content, "Security mode should mention SQL Injection")
    assert_match(/CSRF/i, @content, "Security mode should mention CSRF")
    assert_match(/File Upload/i, @content, "Security mode should mention File Upload")
    assert_match(/Command Injection/i, @content, "Security mode should mention Command Injection")
  end

  def test_security_mode_has_security_tag
    assert_match(/\[SECURITY\]/i, @content,
                 "Security mode should use [SECURITY] tag")
  end

  # Rules mode tests
  def test_rules_mode_references_team_rules
    assert_match(%r{rules/TEAM_RULES\.md}i, @content,
                 "Rules mode should reference rules/TEAM_RULES.md")
  end

  def test_rules_mode_mentions_severity_levels
    assert_match(/Critical.*severity/i, @content,
                 "Rules mode should mention critical severity")
    assert_match(/High.*severity/i, @content,
                 "Rules mode should mention high severity")
  end

  def test_rules_mode_includes_quality_checks
    assert_match(/separation of concerns/i, @content,
                 "Rules mode should check separation of concerns")
    assert_match(/error handling/i, @content,
                 "Rules mode should check error handling")
    assert_match(/DRY/i, @content,
                 "Rules mode should check DRY principle")
  end

  def test_rules_mode_has_rule_and_quality_tags
    assert_match(/\[RULE #N\]/i, @content,
                 "Rules mode should use [RULE #N] tag pattern")
    assert_match(/\[QUALITY\]/i, @content,
                 "Rules mode should use [QUALITY] tag")
  end

  # Domain mode skill references (via Skill tool)
  def test_domain_mode_references_models_skill
    assert_match(/rails-ai:models/i, @content,
                 "Domain mode should reference rails-ai:models skill")
  end

  def test_domain_mode_references_controllers_skill
    assert_match(/rails-ai:controllers/i, @content,
                 "Domain mode should reference rails-ai:controllers skill")
  end

  def test_domain_mode_references_jobs_skill
    assert_match(/rails-ai:jobs/i, @content,
                 "Domain mode should reference rails-ai:jobs skill")
  end

  def test_domain_mode_references_mailers_skill
    assert_match(/rails-ai:mailers/i, @content,
                 "Domain mode should reference rails-ai:mailers skill")
  end

  def test_domain_mode_has_domain_tags
    assert_match(/\[MODELS\]/i, @content, "Domain mode should use [MODELS] tag")
    assert_match(/\[CONTROLLERS\]/i, @content, "Domain mode should use [CONTROLLERS] tag")
    assert_match(/\[JOBS\]/i, @content, "Domain mode should use [JOBS] tag")
    assert_match(/\[MAILERS\]/i, @content, "Domain mode should use [MAILERS] tag")
  end

  # Testing mode tests (via Skill tool)
  def test_testing_mode_references_testing_skill
    assert_match(/rails-ai:testing/i, @content,
                 "Testing mode should reference rails-ai:testing skill")
  end

  def test_testing_mode_mentions_key_patterns
    assert_match(/TDD/i, @content, "Testing mode should mention TDD")
    assert_match(/Minitest/i, @content, "Testing mode should mention Minitest")
    assert_match(/Fixtures/i, @content, "Testing mode should mention Fixtures")
    assert_match(/WebMock/i, @content, "Testing mode should mention WebMock")
  end

  def test_testing_mode_has_testing_tag
    assert_match(/\[TESTING\]/i, @content,
                 "Testing mode should use [TESTING] tag")
  end

  # UI mode skill references (via Skill tool)
  def test_ui_mode_references_ui_skill
    assert_match(/rails-ai:ui/i, @content,
                 "UI mode should reference rails-ai:ui skill")
  end

  def test_ui_mode_references_hotwire_skill
    assert_match(/rails-ai:hotwire/i, @content,
                 "UI mode should reference rails-ai:hotwire skill")
  end

  def test_ui_mode_references_styling_skill
    assert_match(/rails-ai:styling/i, @content,
                 "UI mode should reference rails-ai:styling skill")
  end

  def test_ui_mode_has_ui_tags
    assert_match(/\[UI\]/i, @content, "UI mode should use [UI] tag")
    assert_match(/\[HOTWIRE\]/i, @content, "UI mode should use [HOTWIRE] tag")
    assert_match(/\[STYLING\]/i, @content, "UI mode should use [STYLING] tag")
  end

  # Findings format tests
  def test_agent_specifies_findings_format
    assert_match(/findings:/i, @content, "Agent should specify findings output format")
    assert_match(/severity:/i, @content, "Agent should specify severity field")
    assert_match(/tag:/i, @content, "Agent should specify tag field")
    assert_match(/file:/i, @content, "Agent should specify file field")
    assert_match(/line:/i, @content, "Agent should specify line field")
    assert_match(/issue:/i, @content, "Agent should specify issue field")
    assert_match(/fix:/i, @content, "Agent should specify fix field")
    assert_match(/reference:/i, @content, "Agent should specify reference field")
  end

  def test_agent_defines_severity_levels
    assert_match(/critical/i, @content, "Agent should define critical severity")
    assert_match(/important/i, @content, "Agent should define important severity")
    assert_match(/minor/i, @content, "Agent should define minor severity")
  end

  def test_agent_instructs_to_load_skills_first
    assert_match(/Load.*relevant.*skill.*FIRST/i, @content,
                 "Agent should instruct to load skills first using Skill tool")
  end

  def test_agent_requires_reference_field
    assert_match(/reference.*field.*citing/i, @content,
                 "Agent should require reference field citing source")
  end

  # Process tests
  def test_agent_has_clear_process_steps
    assert_match(/Load.*skills/i, @content,
                 "Agent should have step to load skills")
    assert_match(/Analyze the diff/i, @content,
                 "Agent should have step to analyze diff")
    assert_match(/Return findings/i, @content,
                 "Agent should have step to return findings")
  end

  # Mode announcement tests (matching developer_test.rb pattern)
  def test_agent_announces_mode
    assert_match(/@agent-rails-ai:reviewer.*SECURITY.*mode/i, @content,
                 "Agent should announce security mode")
    assert_match(/@agent-rails-ai:reviewer.*RULES.*mode/i, @content,
                 "Agent should announce rules mode")
    assert_match(/@agent-rails-ai:reviewer.*DOMAIN.*mode/i, @content,
                 "Agent should announce domain mode")
    assert_match(/@agent-rails-ai:reviewer.*TESTING.*mode/i, @content,
                 "Agent should announce testing mode")
    assert_match(/@agent-rails-ai:reviewer.*UI.*mode/i, @content,
                 "Agent should announce ui mode")
  end
end
