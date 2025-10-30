# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class AgentStructureTest < Minitest::Test
  def setup
    @agent_files = Dir.glob("agents/*.md")
  end

  def test_specialized_agents_have_skills_preset_section
    specialized_agents = @agent_files.reject { |f| f.include?("architect.md") }

    specialized_agents.each do |file|
      content = File.read(file)

      # Should have a Skills Preset section (various heading formats)
      assert_match(/##.*Skills.*Preset|##.*Preset.*Skills/i, content,
                   "#{file}: missing 'Skills Preset' section")
    end
  end

  def test_agents_reference_external_yaml_registries
    @agent_files.each do |file|
      content = File.read(file)

      # Should reference SKILLS_REGISTRY.yml
      assert_match(/SKILLS_REGISTRY\.yml/, content,
                   "#{file}: should reference SKILLS_REGISTRY.yml")
    end
  end

  def test_specialized_agents_have_role_description
    specialized_agents = @agent_files.reject { |f| f.include?("architect.md") }

    specialized_agents.each do |file|
      yaml = extract_yaml_front_matter(file)

      assert yaml["role"], "#{file}: missing 'role' field in YAML front matter"
      refute_empty yaml["role"], "#{file}: 'role' field should not be empty"
    end
  end

  def test_all_agents_have_descriptive_names
    @agent_files.each do |file|
      basename = File.basename(file, ".md")

      # All agents should have simple, descriptive names
      assert_match(/^(architect|backend|frontend|tests|security|debug)$/, basename,
                   "#{file}: should have a descriptive name without 'rails-' prefix")
    end
  end

  def test_coordinator_has_unique_name
    coordinator = @agent_files.find { |f| f.include?("architect.md") }
    basename = File.basename(coordinator, ".md")

    assert_equal "architect", basename,
                 "Coordinator should be named 'architect.md'"
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
