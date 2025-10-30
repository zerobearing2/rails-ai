# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class AgentConsistencyTest < Minitest::Test
  def test_agent_count_matches_six_agent_architecture
    agent_count = Dir.glob("agents/*.md").count

    assert_equal 6, agent_count,
                 "Expected 6 agents (1 coordinator + 5 specialized), found #{agent_count}"
  end

  def test_required_agents_exist
    required_agents = [
      "architect.md",  # Coordinator
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
    # Check AGENTS.md lists exactly 6 agents
    agents_doc = File.read("AGENTS.md")

    # Should mention "6 specialized agents" or "6 agents"
    assert_match(/6\s+(specialized\s+)?agents/i, agents_doc,
                 "AGENTS.md should document 6-agent architecture")

    # Should not mention 8 agents
    refute_match(/8\s+(specialized\s+)?agents/i, agents_doc,
                 "AGENTS.md should not reference old 8-agent architecture")
  end

  def test_decision_matrices_match_agents
    decision_matrices = YAML.load_file("rules/DECISION_MATRICES.yml")

    # Check keyword_lookup section references valid agents
    keyword_lookup = decision_matrices["keyword_lookup"]
    skip unless keyword_lookup

    existing_agents = Dir.glob("agents/*.md").map { |f| File.basename(f, ".md") }

    keyword_lookup.each_value do |agent|
      agent_name = agent.to_s.split.first # Handle "architect (orchestrate PR review)"

      if agent_name.match?(/^(architect|backend|frontend|tests|security|debug)$/)
        assert_includes existing_agents, agent_name,
                        "DECISION_MATRICES.yml references non-existent agent '#{agent_name}'"
      end
    end
  end
end
