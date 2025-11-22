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

  def test_review_command_references_superpowers
    review = @command_files.find { |f| f.include?("review.md") }
    content = File.read(review)

    assert_match(/superpowers:requesting-code-review/i, content,
                 "Review command should reference requesting-code-review superpowers workflow")
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
    assert_match(/Context Package/i, content,
                 "Feature command should have Context Package section")
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
    assert_match(/Behavior Changed/i, content,
                 "Refactor command should include critical behavior change check")
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

    assert_match(/rails-ai:project-setup/i, content,
                 "Setup command should reference project-setup skill")
  end

  def test_commands_describe_rails_ai_skill_loading
    %w[feature refactor debug].each do |command|
      file = @command_files.find { |f| f.include?("#{command}.md") }
      content = File.read(file)

      assert_match(/Rails-AI Skills/i, content,
                   "#{command} command should describe loading Rails-AI skills")
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
