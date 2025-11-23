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

  def test_agent_has_role_placeholder
    assert_match(/\{\{ROLE\}\}/i, @content,
                 "Agent should have {{ROLE}} placeholder for role injection")
  end

  def test_agent_has_diff_placeholder
    assert_match(/\{\{DIFF\}\}/i, @content,
                 "Agent should have {{DIFF}} placeholder for diff content")
  end

  def test_agent_has_files_changed_placeholder
    assert_match(/\{\{FILES_CHANGED\}\}/i, @content,
                 "Agent should have {{FILES_CHANGED}} placeholder")
  end

  # Security role tests
  def test_security_role_covers_xss
    assert_match(/XSS/i, @content,
                 "Security role should check for XSS vulnerabilities")
    assert_match(/html_safe/i, @content,
                 "Security role should warn against html_safe on user input")
  end

  def test_security_role_covers_sql_injection
    assert_match(/SQL injection/i, @content,
                 "Security role should check for SQL injection")
    assert_match(/string interpolation/i, @content,
                 "Security role should warn against string interpolation in SQL")
  end

  def test_security_role_covers_csrf
    assert_match(/CSRF/i, @content,
                 "Security role should check for CSRF protection")
    assert_match(/csrf_meta_tags/i, @content,
                 "Security role should check for csrf_meta_tags")
  end

  def test_security_role_covers_file_uploads
    assert_match(/file upload/i, @content,
                 "Security role should check file upload security")
    assert_match(/ActiveStorage/i, @content,
                 "Security role should mention ActiveStorage")
  end

  def test_security_role_covers_command_injection
    assert_match(/command injection/i, @content,
                 "Security role should check for command injection")
    assert_match(/array form/i, @content,
                 "Security role should recommend array form for system commands")
  end

  # Rules role tests
  def test_rules_role_covers_critical_rules
    # Rule #1: Solid Stack
    assert_match(/Rule #1.*Solid Stack/i, @content,
                 "Rules role should cover Rule #1 (Solid Stack)")
    assert_match(/sidekiq/i, @content,
                 "Rules role should flag Sidekiq as violation")
    assert_match(/SolidQueue/i, @content,
                 "Rules role should recommend SolidQueue")

    # Rule #2: Minitest
    assert_match(/Rule #2.*Minitest/i, @content,
                 "Rules role should cover Rule #2 (Minitest)")
    assert_match(/rspec/i, @content,
                 "Rules role should flag RSpec as violation")

    # Rule #3: RESTful
    assert_match(/Rule #3.*RESTful/i, @content,
                 "Rules role should cover Rule #3 (RESTful actions)")

    # Rule #4: TDD
    assert_match(/Rule #4.*TDD/i, @content,
                 "Rules role should cover Rule #4 (TDD)")

    # Rule #17: bin/ci
    assert_match(%r{Rule #17.*bin/ci}i, @content,
                 "Rules role should cover Rule #17 (bin/ci)")

    # Rule #18: WebMock
    assert_match(/Rule #18.*WebMock/i, @content,
                 "Rules role should cover Rule #18 (WebMock)")
  end

  def test_rules_role_includes_quality_checks
    assert_match(/separation of concerns/i, @content,
                 "Rules role should check separation of concerns")
    assert_match(/error handling/i, @content,
                 "Rules role should check error handling")
    assert_match(/DRY/i, @content,
                 "Rules role should check DRY principle")
  end

  def test_rules_role_has_quality_tag
    assert_match(/\[QUALITY\]/i, @content,
                 "Rules role should use [QUALITY] tag")
  end

  # Domain role tests
  def test_domain_role_covers_models
    assert_match(/Models.*rails-ai:models/i, @content,
                 "Domain role should reference rails-ai:models")
    assert_match(/Validations/i, @content,
                 "Domain role should check validations")
    assert_match(/Associations/i, @content,
                 "Domain role should check associations")
    assert_match(/N\+1/i, @content,
                 "Domain role should check N+1 queries")
  end

  def test_domain_role_covers_controllers
    assert_match(/Controllers.*rails-ai:controllers/i, @content,
                 "Domain role should reference rails-ai:controllers")
    assert_match(/Strong parameters/i, @content,
                 "Domain role should check strong parameters")
    assert_match(/REST actions/i, @content,
                 "Domain role should check REST actions only")
  end

  def test_domain_role_covers_jobs
    assert_match(/Jobs.*rails-ai:jobs/i, @content,
                 "Domain role should reference rails-ai:jobs")
    assert_match(/SolidQueue/i, @content,
                 "Domain role should require SolidQueue")
    assert_match(/Idempotent/i, @content,
                 "Domain role should check idempotent operations")
  end

  def test_domain_role_covers_mailers
    assert_match(/Mailers.*rails-ai:mailers/i, @content,
                 "Domain role should reference rails-ai:mailers")
    assert_match(/deliver_later/i, @content,
                 "Domain role should check async delivery")
  end

  # Testing role tests
  def test_testing_role_covers_tdd
    assert_match(/TDD Compliance/i, @content,
                 "Testing role should check TDD compliance")
    assert_match(/RED-GREEN-REFACTOR/i, @content,
                 "Testing role should reference RED-GREEN-REFACTOR")
  end

  def test_testing_role_covers_fixtures
    assert_match(/Fixtures/i, @content,
                 "Testing role should check fixtures usage")
    assert_match(/not factories/i, @content,
                 "Testing role should prefer fixtures over factories")
  end

  def test_testing_role_covers_webmock
    assert_match(/WebMock.*HTTP/i, @content,
                 "Testing role should require WebMock for HTTP")
    assert_match(/mock\.verify/i, @content,
                 "Testing role should check mock.verify")
  end

  def test_testing_role_covers_minitest
    assert_match(/Minitest.*not RSpec/i, @content,
                 "Testing role should require Minitest")
  end

  # UI role tests
  def test_ui_role_covers_turbo
    assert_match(/Turbo.*Hotwire/i, @content,
                 "UI role should cover Turbo/Hotwire")
    assert_match(/Turbo Morph/i, @content,
                 "UI role should prefer Turbo Morph")
    assert_match(/Turbo Frames/i, @content,
                 "UI role should cover Turbo Frames")
  end

  def test_ui_role_covers_stimulus
    assert_match(/Stimulus/i, @content,
                 "UI role should cover Stimulus")
    assert_match(/_controller\.js/i, @content,
                 "UI role should check controller naming convention")
  end

  def test_ui_role_covers_viewcomponent
    assert_match(/ViewComponent/i, @content,
                 "UI role should cover ViewComponent")
    assert_match(/not partials/i, @content,
                 "UI role should prefer ViewComponent over partials")
  end

  def test_ui_role_covers_accessibility
    assert_match(/Accessibility/i, @content,
                 "UI role should cover accessibility")
    assert_match(/ARIA/i, @content,
                 "UI role should check ARIA labels")
    assert_match(/Keyboard/i, @content,
                 "UI role should check keyboard navigation")
  end

  # Output format tests
  def test_agent_specifies_yaml_output_format
    assert_match(/findings:/i, @content,
                 "Agent should specify findings output format")
    assert_match(/severity:/i, @content,
                 "Agent should specify severity field")
    assert_match(/tag:/i, @content,
                 "Agent should specify tag field")
    assert_match(/file:/i, @content,
                 "Agent should specify file field")
    assert_match(/line:/i, @content,
                 "Agent should specify line field")
    assert_match(/issue:/i, @content,
                 "Agent should specify issue field")
    assert_match(/fix:/i, @content,
                 "Agent should specify fix field")
  end

  def test_agent_defines_severity_levels
    assert_match(/critical/i, @content,
                 "Agent should define critical severity")
    assert_match(/important/i, @content,
                 "Agent should define important severity")
    assert_match(/minor/i, @content,
                 "Agent should define minor severity")
  end

  def test_agent_has_all_required_tags
    tags = %w[SECURITY RULE QUALITY MODELS CONTROLLERS JOBS MAILERS TESTING UI HOTWIRE STYLING]

    tags.each do |tag|
      assert_match(/\[#{tag}/i, @content,
                   "Agent should define [#{tag}] tag")
    end
  end
end
