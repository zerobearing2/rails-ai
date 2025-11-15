# frozen_string_literal: true

require_relative "../../test/support/agent_integration_test_case"

# Integration test for DevOps agent
# Tests the new DevOps agent for infrastructure and deployment
#
# Expected behavior: DevOps agent should:
# - Handle Docker configuration
# - Setup deployment pipelines
# - Configure Rails 8 Solid Stack for production
# - Manage environment configuration
# - Ensure production readiness
class DevopsAgentTest < AgentIntegrationTestCase
  def scenario_name
    "devops_agent_infrastructure"
  end

  def agent_prompt
    <<~PROMPT
      @devops

      We need to prepare our Rails 8 app for production deployment. Set up:

      **Docker:**
      - Production-ready Dockerfile
      - docker-compose.yml for local development

      **Solid Stack Production Config:**
      - SolidQueue for background jobs
      - SolidCache for caching
      - SolidCable for WebSockets

      **CI/CD:**
      - GitHub Actions workflow for CI
      - Run bin/ci on every push
      - Deploy to production on main branch merge

      **Environment:**
      - Production credentials management
      - Environment-specific configuration
      - Database connection pooling

      Ensure everything follows TEAM_RULES.md (no Sidekiq, no Redis).
    PROMPT
  end

  def expected_pass
    true
  end

  def test_scenario
    judgment = super

    agent_output = judgment[:agent_output]

    # Should use rails-ai config/deployment skills
    assert_match(/rails-ai:(docker|solid-stack|credentials|environment-config)/,
                 agent_output,
                 "DevOps should use rails-ai infrastructure skills")

    # Should include Docker configuration
    assert_match(/Dockerfile|docker-compose/,
                 agent_output,
                 "DevOps should create Docker configuration")

    # Should enforce Solid Stack (TEAM_RULES.md Rule #1)
    assert_match(/SolidQueue|SolidCache|SolidCable/,
                 agent_output,
                 "DevOps should configure Solid Stack")

    # Should NOT use Sidekiq/Redis (TEAM_RULES.md violation)
    refute_match(/[Ss]idekiq|[Rr]edis[^a-z]/,
                 agent_output,
                 "DevOps should NOT use Sidekiq or Redis")

    # Should include CI/CD configuration
    assert_match(%r{GitHub Actions|\.github/workflows|CI/CD},
                 agent_output,
                 "DevOps should create CI/CD pipeline")

    # Should reference bin/ci
    assert_match(%r{bin/ci},
                 agent_output,
                 "DevOps should use bin/ci in CI pipeline")

    # Should include credentials management
    assert_match(/credentials|secrets|encrypted/i,
                 agent_output,
                 "DevOps should configure credentials management")

    # Should include environment configuration
    assert_match(/environment|production\.rb|config/i,
                 agent_output,
                 "DevOps should configure environments")

    judgment
  end
end
