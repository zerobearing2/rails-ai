# frozen_string_literal: true

require_relative "../../support/agent_integration_test_case"

# Integration test for simple model planning scenario
#
# Tests the rails-ai architect agent's ability to plan a Rails model implementation
# with proper validations, associations, migrations, and tests.
#
# Expected behavior: Agent should coordinate with backend and tests agents to
# produce a comprehensive plan with detailed code for:
# - Article model with validations and associations
# - Migration with proper indexes and foreign keys
# - User model association changes
# - Comprehensive model tests
#
class SimpleModelPlanTest < AgentIntegrationTestCase
  def scenario_name
    "simple_model_plan"
  end

  def system_prompt
    <<~PROMPT
      You are evaluating the rails-ai architect agent in a testing scenario. The agent should:
      - Plan implementations without executing code
      - Provide detailed, structured responses
      - Follow Rails 8.1 best practices
      - Respond in the exact format requested

      You will invoke the agent and it should produce a complete implementation plan.
    PROMPT
  end

  def agent_prompt
    <<~PROMPT
      @agent-rails-ai:architect

      **IMPORTANT:** This is a planning test. Coordinate with the appropriate specialist agents (@backend, @tests, etc.) to gather detailed implementation plans from each. Then consolidate all their plans into a single comprehensive response that includes:

      - Complete code for all files (models, migrations, tests)
      - Detailed implementation steps
      - Rationale for architectural decisions

      Delegate the planning work to specialist agents as needed, then combine their outputs into one detailed plan. Do NOT just summarize - include all the actual code and implementation details from each agent.

      Please plan the implementation for the following Rails development task:

      ## Current Application State

      You are working on a **Rails 8.1.1 blog application** with the following existing code:

      ### app/models/user.rb
      ```ruby
      class User < ApplicationRecord
        validates :name, presence: true
        validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
      end
      ```

      ### db/schema.rb (excerpt)
      ```ruby
      ActiveRecord::Schema[8.1].define(version: 2025_11_01_120000) do
        create_table "users", force: :cascade do |t|
          t.string "name", null: false
          t.string "email", null: false
          t.text "bio"
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
          t.index ["email"], name: "index_users_on_email", unique: true
        end
      end
      ```

      ### config/routes.rb
      ```ruby
      Rails.application.routes.draw do
        resources :users, only: [:index, :show]
      end
      ```

      ## Task

      Plan the implementation for adding an **Article model** with the following requirements:

      **Attributes:**
      - `title` (string, required, maximum 200 characters)
      - `body` (text, required)
      - `published_at` (datetime, optional)
      - `author_id` (integer, required, foreign key to users table)

      **Requirements:**
      - Appropriate validations on all fields
      - Association to User model (an article belongs to an author who is a User)
      - User model should have the reciprocal association
      - Include a `published` scope for articles where `published_at` is not null and in the past
      - Migration should be reversible
      - Include basic model tests

      ## Instructions for Agent

      **DO NOT execute or implement code.**

      Instead, provide a detailed implementation plan that includes:

      1. **Architecture Overview** - High-level approach and key decisions
      2. **Step-by-Step Plan** - Ordered list of implementation steps
      3. **Model Code** - Complete `app/models/article.rb`
      4. **User Model Changes** - What to add to `app/models/user.rb`
      5. **Migration** - Complete migration file with proper naming
      6. **Tests** - Key test cases for `test/models/article_test.rb`
      7. **Rationale** - Explain important decisions (naming, validations, indexes, etc.)

      ## Output Format

      Please structure your response as:

      ```markdown
      # Implementation Plan: Article Model

      ## Architecture Overview
      [2-3 sentences on approach]

      ## Implementation Steps
      1. [Step 1]
      2. [Step 2]
      ...

      ## Code Implementation

      ### app/models/article.rb
      \\```ruby
      [complete code]
      \\```

      ### app/models/user.rb (changes)
      \\```ruby
      # Add this to the User model:
      [code to add]
      \\```

      ### db/migrate/YYYYMMDDHHMMSS_create_articles.rb
      \\```ruby
      [complete migration]
      \\```

      ### test/models/article_test.rb
      \\```ruby
      [key test cases]
      \\```

      ## Key Decisions & Rationale

      - **Decision 1**: [Explanation]
      - **Decision 2**: [Explanation]
      ...

      ## Verification Steps

      1. [How to verify this works]
      2. [Commands to run]
      ```
    PROMPT
  end

  def expected_pass
    true
  end

  # Optional: Add custom assertions beyond pass/fail
  def test_scenario
    judgment = super

    # Custom assertions for this scenario
    agent_output = judgment[:agent_output]

    # Should include Article model code
    assert_match(/class Article < ApplicationRecord/, agent_output,
                 "Agent output should include Article model class definition")

    # Should include migration
    assert_match(/create_table :articles/, agent_output,
                 "Agent output should include articles table migration")

    # Should include validations
    assert_match(/validates :title/, agent_output,
                 "Agent output should include title validation")

    # Should include association
    assert_match(/belongs_to :author|belongs_to :user/, agent_output,
                 "Agent output should include belongs_to association")

    # Should include tests
    assert_match(/test.*Article|describe.*Article|it.*article/i, agent_output,
                 "Agent output should include test cases")

    # Should include published scope
    assert_match(/scope :published/, agent_output,
                 "Agent output should include published scope")

    # Backend score should be strong (at least 35/50)
    backend_score = judgment[:domain_scores]["backend"][:score]
    assert backend_score >= 35,
           "Backend score should be at least 35/50, got #{backend_score}/50"

    # Tests score should be reasonable (at least 30/50)
    tests_score = judgment[:domain_scores]["tests"][:score]
    assert tests_score >= 30,
           "Tests score should be at least 30/50, got #{tests_score}/50"

    judgment
  end
end
