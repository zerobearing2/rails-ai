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
    deleted_agents = %w[rails-config rails-design rails-feature rails-refactor]

    @agent_files.each do |file|
      content = File.read(file)

      deleted_agents.each do |deleted|
        refute_match(/#{Regexp.escape(deleted)}/, content,
                     "#{file}: still references deleted agent '#{deleted}'")
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
    specialized_agents = @agent_files.reject { |f| f.include?("rails.md") }

    specialized_agents.each do |file|
      yaml = extract_yaml_front_matter(file)
      next unless yaml && yaml["coordinates_with"]

      coordinates = yaml["coordinates_with"]

      assert_includes coordinates, "rails",
                      "#{file}: should coordinate with 'rails' (architect) - found: #{coordinates.inspect}"
    end
  end

  def test_coordinator_coordinates_with_all_specialized_agents
    coordinator = @agent_files.find { |f| f.include?("rails.md") }
    yaml = extract_yaml_front_matter(coordinator)

    specialized = @existing_agents - ["rails"]
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
