# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class CommandStructureTest < Minitest::Test
  def setup
    @command_files = Dir.glob("commands/*.md")
  end

  def test_architect_command_exists
    architect = @command_files.find { |f| f.include?("architect.md") }

    assert architect, "architect.md command should exist"
  end

  def test_architect_loads_using_rails_ai_skill
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    assert_match(/Use the using-rails-ai skill/i, content,
                 "Architect command should load using-rails-ai skill")
  end

  def test_architect_forbids_implementing
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should have CRITICAL block forbidding implementation
    assert_match(/CRITICAL/i, content,
                 "Architect should have CRITICAL enforcement block")
    assert_match(/FORBIDDEN|DO NOT IMPLEMENT/i, content,
                 "Architect should explicitly forbid implementing")
    assert_match(/dispatch.*worker/i, content,
                 "Architect should instruct to dispatch workers")
  end

  def test_architect_references_skills
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should reference skills
    assert_match(/rails-ai:(models|controllers|views|hotwire|styling|testing|security|
                              debugging|jobs|mailers|configuration|using-rails-ai)/ix, content,
                 "Architect command should reference rails-ai skills")
  end

  def test_architect_has_coordinator_role
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should describe coordinator role (not implementer)
    assert_match(/coordinator/i, content,
                 "Architect should describe coordinator role")
    assert_match(/dispatch.*worker/i, content,
                 "Architect should mention dispatching workers")
  end

  def test_architect_has_team_rules_enforcement
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    assert_match(/TEAM_RULES\.md/i, content,
                 "Architect should reference TEAM_RULES.md")
    assert_match(/Sidekiq.*Redis.*SolidQueue/im, content,
                 "Architect should enforce Solid Stack over Sidekiq/Redis")
    assert_match(/RSpec.*Minitest/im, content,
                 "Architect should enforce Minitest over RSpec")
  end

  def test_architect_has_workflow_patterns
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should have workflow patterns
    assert_match(/brainstorming/i, content,
                 "Architect should reference brainstorming workflow")
    assert_match(/writing-plans|subagent-driven-development|dispatching-parallel-agents/i, content,
                 "Architect should reference execution workflows")
    assert_match(/requesting-code-review/i, content,
                 "Architect should reference code review workflow")
  end

  def test_architect_references_superpowers
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should reference Superpowers workflows
    assert_match(/superpowers:/i, content,
                 "Architect should reference Superpowers workflows")
  end

  def test_architect_has_yaml_frontmatter
    architect = @command_files.find { |f| f.include?("architect.md") }
    yaml = extract_yaml_front_matter(architect)

    assert yaml, "Architect should have YAML front matter"
    assert yaml["description"], "Architect should have description in YAML front matter"
  end

  def test_architect_has_args_placeholder
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Slash commands can use {{ARGS}} to receive user arguments
    assert_match(/\{\{ARGS\}\}/i, content,
                 "Architect should use {{ARGS}} placeholder for user input")
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
