# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class AgentStructureTest < Minitest::Test
  def setup
    @agent_files = Dir.glob("agents/*.md")
  end

  def test_architect_references_skills
    # Architect should reference skills in content
    architect = @agent_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should reference skills directory or SKILLS_REGISTRY
    assert_match(/skills/i, content,
                 "Architect: should reference skills")
  end

  def test_agents_reference_skills
    @agent_files.each do |file|
      content = File.read(file)

      # Should reference skills in some form (rails-ai:skills or skills/)
      skill_pattern = %r{rails-ai:(models|controllers|views|hotwire|styling|testing|security|
                                    debugging|jobs|mailers|configuration|using-rails-ai)|skills/}ix

      assert_match(skill_pattern, content, "#{file}: should reference rails-ai skills")
    end
  end

  def test_architect_has_role_description
    architect = @agent_files.find { |f| f.include?("architect.md") }
    yaml = extract_yaml_front_matter(architect)

    assert yaml["role"], "Architect: missing 'role' field in YAML front matter"
    refute_empty yaml["role"], "Architect: 'role' field should not be empty"
  end

  def test_architect_has_descriptive_name
    architect = @agent_files.find { |f| f.include?("architect.md") }
    basename = File.basename(architect, ".md")

    assert_equal "architect", basename,
                 "Agent should be named 'architect.md'"
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
