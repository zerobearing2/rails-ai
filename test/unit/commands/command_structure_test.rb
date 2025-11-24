# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class CommandStructureTest < Minitest::Test
  WORKFLOW_COMMANDS = %w[setup plan feature refactor debug review].freeze

  def setup
    @command_files = Dir.glob("commands/*.md")
  end

  def test_all_workflow_commands_exist
    WORKFLOW_COMMANDS.each do |command|
      file = @command_files.find { |f| f.include?("#{command}.md") }

      assert file, "#{command}.md command should exist"
    end
  end

  def test_commands_have_yaml_frontmatter
    WORKFLOW_COMMANDS.each do |command|
      file = @command_files.find { |f| f.include?("#{command}.md") }
      yaml = extract_yaml_front_matter(file)

      assert yaml, "#{command} should have YAML front matter"
      assert yaml["description"], "#{command} should have description in YAML front matter"
    end
  end

  def test_commands_have_args_placeholder
    WORKFLOW_COMMANDS.each do |command|
      file = @command_files.find { |f| f.include?("#{command}.md") }
      content = File.read(file)

      assert_match(/\{\{ARGS\}\}/i, content,
                   "#{command} should use {{ARGS}} placeholder for user input")
    end
  end

  def test_feature_command_references_superpowers
    feature = @command_files.find { |f| f.include?("feature.md") }
    content = File.read(feature)

    assert_match(/superpowers:verification-before-completion/i, content,
                 "Feature command should reference verification superpowers workflow")
    assert_match(/superpowers:using-git-worktrees/i, content,
                 "Feature command should reference git-worktrees superpowers workflow")
    assert_match(/superpowers:finishing-a-development-branch/i, content,
                 "Feature command should reference finishing-a-development-branch superpowers workflow")
  end

  def test_debug_command_references_superpowers
    debug = @command_files.find { |f| f.include?("debug.md") }
    content = File.read(debug)

    assert_match(/superpowers:systematic-debugging/i, content,
                 "Debug command should reference systematic-debugging superpowers workflow")
    assert_match(/superpowers:root-cause-tracing/i, content,
                 "Debug command should reference root-cause-tracing superpowers workflow")
  end

  def test_plan_command_references_superpowers
    plan = @command_files.find { |f| f.include?("plan.md") }
    content = File.read(plan)

    assert_match(/superpowers:brainstorming/i, content,
                 "Plan command should reference brainstorming superpowers workflow")
    assert_match(/superpowers:writing-plans/i, content,
                 "Plan command should reference writing-plans superpowers workflow")
  end

  def test_refactor_command_references_superpowers
    refactor = @command_files.find { |f| f.include?("refactor.md") }
    content = File.read(refactor)

    assert_match(/superpowers:verification-before-completion/i, content,
                 "Refactor command should reference verification superpowers workflow")
    assert_match(/superpowers:test-driven-development/i, content,
                 "Refactor command should reference TDD superpowers workflow")
  end

  def test_review_command_has_parallel_agent_architecture
    review = @command_files.find { |f| f.include?("review.md") }
    content = File.read(review)

    assert_match(/3 Parallel/i, content,
                 "Review command should dispatch 3 parallel agents")
    assert_match(/Task tool/i, content,
                 "Review command should use Task tool for agent dispatch")
  end

  def test_review_command_has_all_three_modes
    review = @command_files.find { |f| f.include?("review.md") }
    content = File.read(review)

    assert_match(/Mode: security-and-rules/i, content,
                 "Review command should have security-and-rules mode")
    assert_match(/Mode: implementation/i, content,
                 "Review command should have implementation mode")
    assert_match(/Mode: ui/i, content,
                 "Review command should have ui mode")
  end

  def test_review_command_has_smart_scope_detection
    review = @command_files.find { |f| f.include?("review.md") }
    content = File.read(review)

    assert_match(/PR URL/i, content,
                 "Review command should detect PR URLs")
    assert_match(/branch/i, content,
                 "Review command should detect branch names")
    assert_match(/uncommitted/i, content,
                 "Review command should handle uncommitted changes")
    assert_match(/git diff/i, content,
                 "Review command should use git diff")
  end

  def test_review_command_has_file_analysis
    review = @command_files.find { |f| f.include?("review.md") }
    content = File.read(review)

    assert_match(%r{app/models}i, content,
                 "Review command should analyze model files")
    assert_match(%r{app/controllers}i, content,
                 "Review command should analyze controller files")
    assert_match(%r{app/views}i, content,
                 "Review command should analyze view files")
    assert_match(%r{test/}i, content,
                 "Review command should analyze test files")
  end

  def test_review_command_has_consolidation_step
    review = @command_files.find { |f| f.include?("review.md") }
    content = File.read(review)

    assert_match(/Consolidate/i, content,
                 "Review command should consolidate findings")
    assert_match(/Dedupe/i, content,
                 "Review command should deduplicate findings")
    assert_match(/severity/i, content,
                 "Review command should sort by severity")
  end

  def test_review_command_has_verdict_generation
    review = @command_files.find { |f| f.include?("review.md") }
    content = File.read(review)

    assert_match(/Verdict/i, content,
                 "Review command should generate verdict")
    assert_match(/Ready to merge/i, content,
                 "Review command should include merge readiness")
    assert_match(/Critical/i, content,
                 "Review command should classify critical issues")
    assert_match(/Important/i, content,
                 "Review command should classify important issues")
    assert_match(/Minor/i, content,
                 "Review command should classify minor issues")
  end

  def test_review_command_has_next_actions
    review = @command_files.find { |f| f.include?("review.md") }
    content = File.read(review)

    assert_match(/Next Actions/i, content,
                 "Review command should present next actions")
    assert_match(/Fix issues/i, content,
                 "Review command should offer fix option")
    assert_match(/Create PR/i, content,
                 "Review command should offer PR creation option")
  end

  def test_review_command_defines_all_tags
    review = @command_files.find { |f| f.include?("review.md") }
    content = File.read(review)

    tags = %w[SECURITY RULE QUALITY MODELS CONTROLLERS JOBS MAILERS TESTING UI HOTWIRE STYLING]

    tags.each do |tag|
      assert_match(/\[#{tag}/i, content,
                   "Review command should define [#{tag}] tag")
    end
  end

  def test_review_command_references_reviewer_agent
    review = @command_files.find { |f| f.include?("review.md") }
    content = File.read(review)

    assert_match(/@agent-rails-ai:reviewer/i, content,
                 "Review command should reference @agent-rails-ai:reviewer agent")
    assert_match(/subagent_type:.*@agent-rails-ai:reviewer/i, content,
                 "Review command should dispatch via subagent_type")
  end

  def test_feature_command_has_completion_checklist
    feature = @command_files.find { |f| f.include?("feature.md") }
    content = File.read(feature)

    assert_match(/completion checklist/i, content,
                 "Feature command should have completion checklist")
    assert_match(%r{bin/ci}i, content,
                 "Feature command should require bin/ci")
    assert_match(/CHANGELOG/i, content,
                 "Feature command should require CHANGELOG update")
  end

  def test_refactor_command_has_completion_checklist
    refactor = @command_files.find { |f| f.include?("refactor.md") }
    content = File.read(refactor)

    assert_match(/completion checklist/i, content,
                 "Refactor command should have completion checklist")
    assert_match(%r{bin/ci}i, content,
                 "Refactor command should require bin/ci")
    assert_match(/CHANGELOG/i, content,
                 "Refactor command should require CHANGELOG update")
  end

  def test_feature_command_has_coordinator_pattern
    feature = @command_files.find { |f| f.include?("feature.md") }
    content = File.read(feature)

    assert_match(/COORDINATOR ONLY/i, content,
                 "Feature command should declare COORDINATOR ONLY role")
    assert_match(/NEVER implement directly/i, content,
                 "Feature command should prohibit direct implementation")
    assert_match(/Task tool/i, content,
                 "Feature command should reference Task tool for subagent dispatch")
    assert_match(/Retry Logic/i, content,
                 "Feature command should have Retry Logic section")
    assert_match(/subagent_type.*@agent-rails-ai:developer/im, content,
                 "Feature command should dispatch to @agent-rails-ai:developer agent")
  end

  def test_refactor_command_has_coordinator_pattern
    refactor = @command_files.find { |f| f.include?("refactor.md") }
    content = File.read(refactor)

    assert_match(/COORDINATOR ONLY/i, content,
                 "Refactor command should declare COORDINATOR ONLY role")
    assert_match(/NEVER implement directly/i, content,
                 "Refactor command should prohibit direct implementation")
    assert_match(/Task tool/i, content,
                 "Refactor command should reference Task tool for subagent dispatch")
    assert_match(/Retry Logic/i, content,
                 "Refactor command should have Retry Logic section")
    assert_match(/Verify Baseline/i, content,
                 "Refactor command should have baseline verification step")
    assert_match(/behavior.changed/i, content,
                 "Refactor command should include behavior change check")
    assert_match(/subagent_type.*@agent-rails-ai:developer/im, content,
                 "Refactor command should dispatch to @agent-rails-ai:developer agent")
  end

  def test_debug_command_has_completion_checklist
    debug = @command_files.find { |f| f.include?("debug.md") }
    content = File.read(debug)

    assert_match(/completion checklist/i, content,
                 "Debug command should have completion checklist")
    assert_match(%r{bin/ci}i, content,
                 "Debug command should require bin/ci")
  end

  def test_setup_command_references_project_setup_skill
    setup = @command_files.find { |f| f.include?("setup.md") }
    content = File.read(setup)

    assert_match(/rails-ai:setup/i, content,
                 "Setup command should reference setup skill")
  end

  def test_debug_command_describes_rails_ai_skill_loading
    # Debug command loads skills for investigation, delegates fixes to developer agent
    debug = @command_files.find { |f| f.include?("debug.md") }
    content = File.read(debug)

    assert_match(/Rails-AI Skills/i, content,
                 "Debug command should describe loading Rails-AI skills")
  end

  def test_debug_command_delegates_to_developer_agent
    debug = @command_files.find { |f| f.include?("debug.md") }
    content = File.read(debug)

    assert_match(/@agent-rails-ai:developer/i, content,
                 "Debug command should reference @agent-rails-ai:developer agent")
    assert_match(/mode.*fix/i, content,
                 "Debug command should specify fix mode for developer agent")
  end

  def test_feature_and_refactor_delegate_to_developer_agent
    # Feature and refactor delegate skill loading to developer agent
    %w[feature refactor].each do |command|
      file = @command_files.find { |f| f.include?("#{command}.md") }
      content = File.read(file)

      assert_match(/@agent-rails-ai:developer/i, content,
                   "#{command} command should reference @agent-rails-ai:developer agent")
      assert_match(/mode.*#{command}/i, content,
                   "#{command} command should specify mode")
    end
  end

  private

  def extract_yaml_front_matter(file)
    content = File.read(file)
    match = content.match(/^---\s*\n(.*?)\n---\s*\n/m)
    return nil unless match

    YAML.safe_load(match[1], permitted_classes: [Symbol], aliases: true)
  rescue Psych::SyntaxError
    {}
  end
end
