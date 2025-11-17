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

      # Name should include namespace (rails-ai:architect)
      assert_includes yaml["name"], "rails-ai:",
                      "#{file}: name '#{yaml['name']}' should include namespace 'rails-ai:'"
    end
  end

  def test_architect_has_valid_front_matter
    architect = @agent_files.find { |f| f.include?("architect.md") }
    yaml = extract_yaml_front_matter(architect)

    assert_equal "rails-ai:architect", yaml["name"],
                 "Architect name should be 'rails-ai:architect'"
    assert yaml["description"], "Architect should have description"
    assert yaml["role"], "Architect should have role field"
    assert yaml["capabilities"], "Architect should have capabilities field"
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
