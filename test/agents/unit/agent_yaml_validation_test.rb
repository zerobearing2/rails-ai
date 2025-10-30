# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class AgentYamlValidationTest < Minitest::Test
  def setup
    @agent_files = Dir.glob("agents/*.md")
  end

  def test_all_agents_have_valid_yaml_front_matter
    @agent_files.each do |file|
      yaml = extract_yaml_front_matter(file)

      refute_nil yaml, "#{file}: missing YAML front matter"

      # Required fields
      assert yaml["name"], "#{file}: missing 'name' field"
      assert yaml["description"], "#{file}: missing 'description' field"

      # Name matches filename (rails.md → rails, rails-backend.md → rails-backend)
      expected_name = File.basename(file, ".md")

      assert_equal expected_name, yaml["name"],
                   "#{file}: name '#{yaml['name']}' should match filename '#{expected_name}'"
    end
  end

  def test_specialized_agents_have_coordinates_with
    specialized_agents = @agent_files.reject { |f| f.include?("rails.md") }

    specialized_agents.each do |file|
      yaml = extract_yaml_front_matter(file)

      assert yaml["coordinates_with"], "#{file}: missing 'coordinates_with' field"
      assert_kind_of Array, yaml["coordinates_with"], "#{file}: 'coordinates_with' should be an array"
      refute_empty yaml["coordinates_with"], "#{file}: 'coordinates_with' should not be empty"
    end
  end

  def test_coordinator_has_valid_front_matter
    coordinator = @agent_files.find { |f| f.include?("rails.md") }
    yaml = extract_yaml_front_matter(coordinator)

    assert_equal "rails", yaml["name"]
    assert yaml["description"].include?("architect") || yaml["description"].include?("coordinator")
    assert yaml["coordinates_with"], "Coordinator should list agents it coordinates"
  end

  private

  def extract_yaml_front_matter(file)
    content = File.read(file)
    match = content.match(/^---\s*\n(.*?)\n---\s*\n/m)
    return nil unless match

    YAML.safe_load(match[1], permitted_classes: [Symbol], aliases: true)
  rescue Psych::SyntaxError => e
    flunk "#{file}: Invalid YAML syntax - #{e.message}"
  end
end
