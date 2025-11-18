# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class AgentConsistencyTest < Minitest::Test
  def test_agent_count_matches_single_coordinator_architecture
    agent_count = Dir.glob("agents/*.md").count

    assert_equal 1, agent_count,
                 "Expected 1 agent (architect coordinator), found #{agent_count}"
  end

  def test_required_agents_exist
    required_agents = [
      "architect.md" # Single coordinator agent
    ]

    required_agents.each do |agent|
      assert_path_exists "agents/#{agent}",
                         "Required agent '#{agent}' is missing"
    end
  end

  def test_no_legacy_agents_exist
    legacy_agents = [
      "config.md",
      "design.md",
      "feature.md",
      "refactor.md",
      "rails.md",
      "rails-backend.md",
      "rails-frontend.md",
      "rails-security.md",
      "rails-debug.md",
      "rails-tests.md",
      "plan.md",       # Old planning agent
      "backend.md",    # Old specialized agents
      "frontend.md",
      "security.md",
      "debug.md",
      "tests.md"
    ]

    legacy_agents.each do |agent|
      refute_path_exists "agents/#{agent}",
                         "Legacy agent '#{agent}' should not exist (consolidated into architect)"
    end
  end

  def test_agents_match_documentation
    # Check AGENTS.md documents the single-agent architecture
    agents_doc = File.read("AGENTS.md")

    # Should mention single-agent architecture
    assert_match(/single-agent architecture/i, agents_doc,
                 "AGENTS.md should document single-agent architecture")

    # Should reference the architect coordinator
    assert_match(/architect/i, agents_doc,
                 "AGENTS.md should reference architect coordinator")
  end

  def test_architect_has_team_rules_enforcement
    architect_file = "agents/architect.md"
    content = File.read(architect_file)

    # Should reference TEAM_RULES.md
    assert_match(/TEAM_RULES\.md/i, content,
                 "Architect should reference TEAM_RULES.md")

    # Should have critical rules section
    assert_match(/<critical.*?>.*TEAM_RULES/im, content,
                 "Architect should have critical section referencing TEAM_RULES")
  end
end
