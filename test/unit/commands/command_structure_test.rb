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

  def test_architect_uses_using_rails_ai_skill
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    assert_match(/load the.*rails-ai:using-rails-ai.*skill/i, content,
                 "Architect command should load using-rails-ai skill")
  end

  def test_architect_forbids_implementing
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should clearly define what architect cannot do
    assert_match(/YOU DON'T.*Write or edit code/im, content,
                 "Architect should forbid writing code")
    assert_match(/workers implement/i, content,
                 "Architect should clarify workers implement")
    assert_match(/dispatch.*worker/i, content,
                 "Architect should instruct to dispatch workers")
  end

  def test_architect_trusts_using_rails_ai_skill
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should trust using-rails-ai skill for skill mapping
    assert_match(/using-rails-ai.*skill.*tells you/i, content,
                 "Architect should reference using-rails-ai skill for guidance")
    assert_match(/using-rails-ai/i, content,
                 "Architect should reference using-rails-ai skill")
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

  def test_architect_references_team_rules
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    assert_match(/TEAM_RULES\.md/i, content,
                 "Architect should reference TEAM_RULES.md")
  end

  def test_architect_references_superpowers
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should reference Superpowers for workflow coordination
    assert_match(/superpowers.*workflow/i, content,
                 "Architect should reference Superpowers for workflow coordination")
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

  def test_architect_handles_pre_written_plans
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should have a section for handling pre-written plans
    assert_match(/pre-written plan/i, content,
                 "Architect should describe handling pre-written plans")
    assert_match(/plan file|plan document/i, content,
                 "Architect should recognize plan files/documents")
  end

  def test_architect_clarifies_vague_plans
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should clarify with user when plan is vague
    assert_match(/vague.*clarify|clarify.*vague/i, content,
                 "Architect should clarify with user when plan is vague")
  end

  def test_architect_skips_brainstorming_for_pre_written_plans
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should skip brainstorming when plan is provided
    assert_match(/no re-brainstorming/i, content,
                 "Architect should skip brainstorming when plan is provided")
  end

  def test_architect_implements_detailed_plans_as_is
    architect = @command_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should implement detailed plans as-is
    assert_match(/detailed.*implement.*as-is|implement.*as-is/i, content,
                 "Architect should implement detailed plans as-is")
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
