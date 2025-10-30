# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class AgentReferencesTest < Minitest::Test
  def setup
    @agent_files = Dir.glob("agents/*.md")
    @existing_agents = @agent_files.map { |f| File.basename(f, ".md") }
  end

  def test_coordinates_with_only_references_existing_agents
    @agent_files.each do |file|
      yaml = extract_yaml_front_matter(file)
      next unless yaml && yaml["coordinates_with"]

      coordinates = yaml["coordinates_with"]

      coordinates.each do |agent|
        assert_includes @existing_agents, agent,
                        "#{file}: coordinates_with references non-existent agent '#{agent}'"
      end
    end
  end

  def test_no_references_to_deleted_agents
    # Check for old agent mentions with @ prefix (agent references, not URLs or filenames)
    legacy_patterns = [
      /rails\.md(?!\.)/,      # Old coordinator filename (not in URLs)
      /@rails-backend/,       # Old agent mentions
      /@rails-frontend/,
      /@rails-tests/,
      /@rails-security/,
      /@rails-debug/
    ]

    @agent_files.each do |file|
      content = File.read(file)

      legacy_patterns.each do |pattern|
        refute_match(pattern, content,
                     "#{file}: still references legacy agent pattern '#{pattern.inspect}'")
      end
    end
  end

  def test_skill_references_exist_in_registry
    registry = YAML.load_file("skills/SKILLS_REGISTRY.yml")
    all_skills = registry["skills"].keys

    @agent_files.each do |file|
      content = File.read(file)

      # Extract skill file references like: skills/frontend/viewcomponent-basics.md
      skill_refs = content.scan(%r{skills/\w+/([\w-]+)\.md})

      skill_refs.flatten.each do |skill_name|
        assert_includes all_skills, skill_name,
                        "#{file}: references non-existent skill '#{skill_name}'"
      end
    end
  end

  def test_all_specialized_agents_coordinate_with_architect
    specialized_agents = @agent_files.reject { |f| f.include?("architect.md") }

    specialized_agents.each do |file|
      yaml = extract_yaml_front_matter(file)
      next unless yaml && yaml["coordinates_with"]

      coordinates = yaml["coordinates_with"]

      assert_includes coordinates, "architect",
                      "#{file}: should coordinate with 'architect' - found: #{coordinates.inspect}"
    end
  end

  def test_coordinator_coordinates_with_all_specialized_agents
    coordinator = @agent_files.find { |f| f.include?("architect.md") }
    yaml = extract_yaml_front_matter(coordinator)

    specialized = @existing_agents - ["architect"]
    coordinates = yaml["coordinates_with"]

    specialized.each do |agent|
      assert_includes coordinates, agent,
                      "Coordinator should coordinate with '#{agent}'"
    end
  end

  private

  def extract_yaml_front_matter(file)
    content = File.read(file)
    match = content.match(/^---\s*\n(.*?)\n---\s*\n/m)
    return nil unless match

    YAML.safe_load(match[1], permitted_classes: [Symbol], aliases: true)
  rescue Psych::SyntaxError
    nil
  end
end
