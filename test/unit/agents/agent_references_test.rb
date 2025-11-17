# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class AgentReferencesTest < Minitest::Test
  def setup
    @agent_files = Dir.glob("agents/*.md")
    @existing_agents = @agent_files.map { |f| File.basename(f, ".md") }
  end

  def test_no_references_to_old_multi_agent_architecture
    # Check for old agent mentions with @ prefix (agent references, not URLs or filenames)
    legacy_patterns = [
      /rails\.md(?!\.)/, # Old coordinator filename (not in URLs)
      %r{@rails(?!/)}, # Old @rails coordinator mention (but allow @rails/package.js)
      /@rails-backend/, # Old agent mentions
      /@rails-frontend/,
      /@rails-tests/,
      /@rails-security/,
      /@rails-debug/,
      /@plan(?![a-z])/, # Old planning agent (but allow "planning")
      /@backend(?![a-z])/,
      /@frontend(?![a-z])/,
      /@tests(?![a-z])/,
      /@security(?![a-z])/,
      /@debug(?![a-z])/
    ]

    @agent_files.each do |file|
      content = File.read(file)

      legacy_patterns.each do |pattern|
        refute_match(pattern, content,
                     "#{file}: still references legacy agent pattern '#{pattern.inspect}'")
      end
    end
  end

  def test_skill_file_references_exist
    @agent_files.each do |file|
      content = File.read(file)

      # Extract skill file references like: skills/frontend/viewcomponent-basics.md
      skill_refs = content.scan(%r{skills/([\w/-]+\.md)})

      skill_refs.flatten.each do |skill_path|
        assert_path_exists "skills/#{skill_path}",
                           "#{file}: references non-existent skill file 'skills/#{skill_path}'"
      end
    end
  end

  def test_architect_yaml_is_well_formed
    architect = @agent_files.find { |f| f.include?("architect.md") }
    yaml = extract_yaml_front_matter(architect)

    refute_nil yaml, "Architect YAML front matter should be parseable"
    assert_kind_of Hash, yaml, "Architect YAML should be a hash"
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
