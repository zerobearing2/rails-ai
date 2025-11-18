# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class AgentContentTest < Minitest::Test
  def setup
    @agent_files = Dir.glob("agents/*.md")
    # Get all skill files from the skills directory
    @all_skill_files = Dir.glob("skills/**/*.md").map { |f| File.basename(f, ".md").downcase }
  end

  # Test that architect has required sections
  def test_architect_has_required_sections
    architect = @agent_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    required_sections = [
      /##\s+Role/i,
      /TEAM_RULES\.md/i
    ]

    required_sections.each do |section_regex|
      assert_match section_regex, content,
                   "Architect: missing required section matching #{section_regex.inspect}"
    end
  end

  # Test that architect references superpowers workflows
  def test_architect_references_superpowers
    architect = @agent_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should reference superpowers workflows
    assert_match(/superpowers/i, content,
                 "Architect: should reference superpowers workflows")
  end

  # Test that skill files mentioned in agent content exist
  def test_skill_file_references_exist
    @agent_files.each do |file|
      content = File.read(file)

      # Extract skill file references: skills/domain/skill-name.md
      skill_refs = content.scan(%r{skills/([\w/-]+\.md)})

      skill_refs.flatten.uniq.each do |skill_path|
        assert_path_exists "skills/#{skill_path}",
                           "#{file}: references 'skills/#{skill_path}' which doesn't exist"
      end
    end
  end

  # Test that architect has valid YAML metadata fields
  def test_architect_has_complete_metadata
    architect = @agent_files.find { |f| f.include?("architect.md") }
    yaml = extract_yaml_front_matter(architect)

    # Architect should have these fields
    assert yaml["role"], "Architect: missing 'role' field"
    assert yaml["triggers"], "Architect: missing 'triggers' field"
    assert yaml["capabilities"], "Architect: missing 'capabilities' field"

    # Capabilities should be an array
    assert_kind_of Array, yaml["capabilities"],
                   "Architect: capabilities should be an array"
    refute_empty yaml["capabilities"], "Architect: capabilities should not be empty"
  end

  # Test that model field is valid
  def test_agents_have_valid_model_field
    valid_models = %w[inherit sonnet opus haiku]

    @agent_files.each do |file|
      yaml = extract_yaml_front_matter(file)

      if yaml["model"]
        assert_includes valid_models, yaml["model"],
                        "#{file}: model '#{yaml['model']}' is not valid (must be: #{valid_models.join(', ')})"
      end
    end
  end

  # Test that architect has workflow specified
  def test_architect_has_workflow
    architect = @agent_files.find { |f| f.include?("architect.md") }
    yaml = extract_yaml_front_matter(architect)

    # Architect should have workflow specified
    assert yaml["workflow"], "Architect: missing 'workflow' field"
    assert_kind_of String, yaml["workflow"],
                   "Architect: workflow should be a string"
    refute_empty yaml["workflow"], "Architect: workflow should not be empty"
  end

  # Test that architect has critical sections
  def test_architect_has_critical_sections
    architect = @agent_files.find { |f| f.include?("architect.md") }
    content = File.read(architect)

    # Should have <critical> tags in content
    assert_match(%r{<critical.*?>.*?</critical>}im, content,
                 "Architect should have <critical> tags in content")
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
