# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class AgentConsistencyTest < Minitest::Test
  def test_agent_count_matches_seven_agent_architecture
    agent_count = Dir.glob("agents/*.md").count

    assert_equal 7, agent_count,
                 "Expected 7 agents (1 coordinator + 1 planning + 5 specialized), found #{agent_count}"
  end

  def test_required_agents_exist
    required_agents = [
      "architect.md",  # Coordinator
      "plan.md",       # Planning (Specification Pyramid)
      "backend.md",    # Backend API + config + refactoring
      "frontend.md",   # Frontend UI + design/UX
      "security.md",   # Security audits
      "debug.md",      # Debugging
      "tests.md"       # Testing
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
      "rails-tests.md"
    ]

    legacy_agents.each do |agent|
      refute_path_exists "agents/#{agent}",
                         "Legacy agent '#{agent}' should not exist (renamed to new convention)"
    end
  end

  def test_agents_match_documentation
    # Check AGENTS.md lists exactly 7 agents
    agents_doc = File.read("AGENTS.md")

    # Should mention "7 specialized agents" or "7 agents"
    assert_match(/7\s+(specialized\s+)?agents/i, agents_doc,
                 "AGENTS.md should document 7-agent architecture")

    # Should not mention 6 or 8 agents
    refute_match(/[68]\s+(specialized\s+)?agents/i, agents_doc,
                 "AGENTS.md should not reference old 6 or 8-agent architecture")
  end

  def test_architect_decisions_match_agents
    architect_decisions = YAML.load_file("rules/ARCHITECT_DECISIONS.yml")

    # Check agent_selection_quick_lookup section references valid agents
    quick_lookup = architect_decisions["agent_selection_quick_lookup"]
    skip unless quick_lookup

    keyword_lookup = quick_lookup["keywords_to_agent"]
    skip unless keyword_lookup

    existing_agents = Dir.glob("agents/*.md").map { |f| File.basename(f, ".md") }

    keyword_lookup.each_value do |agent|
      agent_name = agent.to_s.split.first # Handle "architect (orchestrate PR review)"

      if agent_name.match?(/^(architect|plan|backend|frontend|tests|security|debug)$/)
        assert_includes existing_agents, agent_name,
                        "ARCHITECT_DECISIONS.yml references non-existent agent '#{agent_name}'"
      end
    end
  end
end
