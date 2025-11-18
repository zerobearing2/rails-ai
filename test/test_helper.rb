# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "yaml"
require "json"

# Base paths for new skill structure
ROOT_PATH = File.expand_path("..", __dir__)
SKILLS_NEW_PATH = File.join(ROOT_PATH, "skills")
TEST_SUPPORT_PATH = File.join(__dir__, "support")

# Helper methods for new skill structure testing
module SkillTestHelpers
  # Load skill from new flat structure: skills/{skill-directory}/SKILL.md
  def load_skill(skill_directory)
    skill_path = File.join(SKILLS_NEW_PATH, skill_directory, "SKILL.md")
    File.read(skill_path)
  end

  def parse_skill_yaml(skill_content)
    # Extract YAML front matter
    if skill_content =~ /\A---\n(.*?)\n---\n/m
      YAML.safe_load(::Regexp.last_match(1), permitted_classes: [Symbol])
    else
      {}
    end
  end

  def extract_patterns(skill_content, pattern_name)
    # Extract specific pattern from skill
    pattern_regex = %r{<pattern name="#{pattern_name}">.*?</pattern>}m
    matches = skill_content.scan(pattern_regex)
    matches.first
  end

  def extract_code_examples(skill_content)
    # Extract all code blocks
    skill_content.scan(/```(?:ruby|erb|javascript|bash|yaml|json)\n(.*?)```/m).map(&:first)
  end

  def skill_directory_exists?(skill_directory)
    Dir.exist?(File.join(SKILLS_NEW_PATH, skill_directory))
  end

  def skill_file_exists?(skill_directory)
    File.exist?(File.join(SKILLS_NEW_PATH, skill_directory, "SKILL.md"))
  end
end

# Include helpers in test classes
Minitest::Test.include SkillTestHelpers
require_relative "support/skill_test_case"
