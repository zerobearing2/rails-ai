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
    assert_match(/Role:.*security.*rules.*domain.*testing.*ui/im, @content,
                 "Agent should document Role input")
    assert_match(/Files Changed:/i, @content,
                 "Agent should document Files Changed input")
    assert_match(/Diff:/i, @content,
                 "Agent should document Diff input")
  end

  # XML role tags tests (matching developer_test.rb pattern)
  def test_agent_uses_xml_role_tags
    assert_match(/<role-security>/i, @content,
                 "Agent should have <role-security> XML tag")
    assert_match(/<role-rules>/i, @content,
                 "Agent should have <role-rules> XML tag")
    assert_match(/<role-domain>/i, @content,
                 "Agent should have <role-domain> XML tag")
    assert_match(/<role-testing>/i, @content,
                 "Agent should have <role-testing> XML tag")
    assert_match(/<role-ui>/i, @content,
                 "Agent should have <role-ui> XML tag")
  end

  # Role tests
  def test_agent_defines_security_role
    assert_match(/role.*security/i, @content,
                 "Agent should define security role")
  end

  def test_agent_defines_rules_role
    assert_match(/role.*rules/i, @content,
                 "Agent should define rules role")
  end

  def test_agent_defines_domain_role
    assert_match(/role.*domain/i, @content,
                 "Agent should define domain role")
  end

  def test_agent_defines_testing_role
    assert_match(/role.*testing/i, @content,
                 "Agent should define testing role")
  end

  def test_agent_defines_ui_role
    assert_match(/role.*ui/i, @content,
                 "Agent should define ui role")
  end

  # Skill tool usage tests (matching developer_test.rb pattern)
  def test_agent_instructs_skill_tool_usage
    assert_match(/Skill tool/i, @content,
                 "Agent should instruct using the Skill tool to load skills")
  end

  def test_security_role_references_security_skill
    assert_match(/rails-ai:security/i, @content,
                 "Security role should reference rails-ai:security skill")
  end

  def test_security_role_mentions_key_vulnerabilities
    assert_match(/XSS/i, @content, "Security role should mention XSS")
    assert_match(/SQL Injection/i, @content, "Security role should mention SQL Injection")
    assert_match(/CSRF/i, @content, "Security role should mention CSRF")
    assert_match(/File Upload/i, @content, "Security role should mention File Upload")
    assert_match(/Command Injection/i, @content, "Security role should mention Command Injection")
  end

  def test_security_role_has_security_tag
    assert_match(/\[SECURITY\]/i, @content,
                 "Security role should use [SECURITY] tag")
  end

  # Rules role tests
  def test_rules_role_references_team_rules
    assert_match(%r{rules/TEAM_RULES\.md}i, @content,
                 "Rules role should reference rules/TEAM_RULES.md")
  end

  def test_rules_role_mentions_severity_levels
    assert_match(/Critical.*severity/i, @content,
                 "Rules role should mention critical severity")
    assert_match(/High.*severity/i, @content,
                 "Rules role should mention high severity")
  end

  def test_rules_role_includes_quality_checks
    assert_match(/separation of concerns/i, @content,
                 "Rules role should check separation of concerns")
    assert_match(/error handling/i, @content,
                 "Rules role should check error handling")
    assert_match(/DRY/i, @content,
                 "Rules role should check DRY principle")
  end

  def test_rules_role_has_rule_and_quality_tags
    assert_match(/\[RULE #N\]/i, @content,
                 "Rules role should use [RULE #N] tag pattern")
    assert_match(/\[QUALITY\]/i, @content,
                 "Rules role should use [QUALITY] tag")
  end

  # Domain role skill references (via Skill tool)
  def test_domain_role_references_models_skill
    assert_match(/rails-ai:models/i, @content,
                 "Domain role should reference rails-ai:models skill")
  end

  def test_domain_role_references_controllers_skill
    assert_match(/rails-ai:controllers/i, @content,
                 "Domain role should reference rails-ai:controllers skill")
  end

  def test_domain_role_references_jobs_skill
    assert_match(/rails-ai:jobs/i, @content,
                 "Domain role should reference rails-ai:jobs skill")
  end

  def test_domain_role_references_mailers_skill
    assert_match(/rails-ai:mailers/i, @content,
                 "Domain role should reference rails-ai:mailers skill")
  end

  def test_domain_role_has_domain_tags
    assert_match(/\[MODELS\]/i, @content, "Domain role should use [MODELS] tag")
    assert_match(/\[CONTROLLERS\]/i, @content, "Domain role should use [CONTROLLERS] tag")
    assert_match(/\[JOBS\]/i, @content, "Domain role should use [JOBS] tag")
    assert_match(/\[MAILERS\]/i, @content, "Domain role should use [MAILERS] tag")
  end

  # Testing role tests (via Skill tool)
  def test_testing_role_references_testing_skill
    assert_match(/rails-ai:testing/i, @content,
                 "Testing role should reference rails-ai:testing skill")
  end

  def test_testing_role_mentions_key_patterns
    assert_match(/TDD/i, @content, "Testing role should mention TDD")
    assert_match(/Minitest/i, @content, "Testing role should mention Minitest")
    assert_match(/Fixtures/i, @content, "Testing role should mention Fixtures")
    assert_match(/WebMock/i, @content, "Testing role should mention WebMock")
  end

  def test_testing_role_has_testing_tag
    assert_match(/\[TESTING\]/i, @content,
                 "Testing role should use [TESTING] tag")
  end

  # UI role skill references (via Skill tool)
  def test_ui_role_references_ui_skill
    assert_match(/rails-ai:ui/i, @content,
                 "UI role should reference rails-ai:ui skill")
  end

  def test_ui_role_references_hotwire_skill
    assert_match(/rails-ai:hotwire/i, @content,
                 "UI role should reference rails-ai:hotwire skill")
  end

  def test_ui_role_references_styling_skill
    assert_match(/rails-ai:styling/i, @content,
                 "UI role should reference rails-ai:styling skill")
  end

  def test_ui_role_has_ui_tags
    assert_match(/\[UI\]/i, @content, "UI role should use [UI] tag")
    assert_match(/\[HOTWIRE\]/i, @content, "UI role should use [HOTWIRE] tag")
    assert_match(/\[STYLING\]/i, @content, "UI role should use [STYLING] tag")
  end

  # Output format tests
  def test_agent_specifies_yaml_output_format
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

  # Role announcement tests (matching developer_test.rb mode announcement pattern)
  def test_agent_announces_role
    assert_match(/@agent-rails-ai:reviewer.*SECURITY/i, @content,
                 "Agent should announce security role")
    assert_match(/@agent-rails-ai:reviewer.*RULES/i, @content,
                 "Agent should announce rules role")
    assert_match(/@agent-rails-ai:reviewer.*DOMAIN/i, @content,
                 "Agent should announce domain role")
    assert_match(/@agent-rails-ai:reviewer.*TESTING/i, @content,
                 "Agent should announce testing role")
    assert_match(/@agent-rails-ai:reviewer.*UI/i, @content,
                 "Agent should announce ui role")
  end
end
