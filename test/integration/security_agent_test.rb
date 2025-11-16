# frozen_string_literal: true

require_relative "../support/agent_integration_test_case"

# Integration test for Security agent with superpowers debugging
# Tests the refactored Security agent that references superpowers workflows
#
# Expected behavior: Security agent should:
# - Audit code for OWASP Top 10 vulnerabilities
# - Use superpowers:systematic-debugging for investigation
# - Apply rails-ai security skills for Rails-specific patterns
# - Provide remediation guidance
# - Score vulnerabilities by severity
class SecurityAgentTest < AgentIntegrationTestCase
  def scenario_name
    "security_agent_audit"
  end

  def agent_prompt
    <<~PROMPT
      @security

      Audit this Rails controller for security vulnerabilities:

      ```ruby
      class ArticlesController < ApplicationController
        def index
          @query = params[:search]
          @articles = Article.where("title LIKE '%#{@query}%'")
        end

        def show
          @article = Article.find(params[:id])
          @content = @article.content
        end

        def upload
          file = params[:file]
          File.write("public/uploads/#{file.original_filename}", file.read)
          redirect_to root_path
        end

        def admin_action
          system("rm -rf #{params[:path]}")
        end
      end
      ```

      Identify all security vulnerabilities (SQL injection, XSS, command injection, file upload issues) and provide remediation guidance.
    PROMPT
  end

  def expected_pass
    true
  end

  def test_scenario
    judgment = super

    agent_output = judgment[:agent_output]

    # Should reference superpowers systematic debugging
    assert_match(/superpowers:systematic-debugging/,
                 agent_output,
                 "Security should reference superpowers:systematic-debugging for investigation")

    # Should use rails-ai security skills
    assert_match(/rails-ai:(security-sql-injection|security-xss|security-command-injection|security-file-uploads)/,
                 agent_output,
                 "Security should use rails-ai security skills")

    # Should identify SQL injection vulnerability
    assert_match(/SQL.*injection|vulnerable.*query|LIKE.*%/i,
                 agent_output,
                 "Security should identify SQL injection")

    # Should identify XSS vulnerability
    assert_match(/XSS|cross-site.*script|html_safe|sanitize/i,
                 agent_output,
                 "Security should identify XSS risk")

    # Should identify command injection
    assert_match(/command.*injection|system.*vulnerable|shell.*escape/i,
                 agent_output,
                 "Security should identify command injection")

    # Should identify file upload vulnerability
    assert_match(/file.*upload.*vulnerable|path.*traversal|filename.*sanitize/i,
                 agent_output,
                 "Security should identify file upload issues")

    # Should provide remediation
    assert_match(/remediation|fix|secure.*alternative|instead.*use/i,
                 agent_output,
                 "Security should provide remediation guidance")

    # Should score by severity
    assert_match(/critical|high|medium|low|severity/i,
                 agent_output,
                 "Security should score vulnerabilities by severity")

    # Security score should be high (at least 40/50)
    security_score = judgment.dig(:domain_scores, "security", :score)

    assert_operator security_score, :>=, 40,
                    "Security agent should score high, got #{security_score}/50"

    judgment
  end
end
