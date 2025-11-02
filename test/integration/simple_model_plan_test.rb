# frozen_string_literal: true

require_relative "../support/agent_integration_test_case"

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
      Output concise technical plans optimized for automated evaluation.
      Focus on implementation code and skill applications, not verbose explanations.
    PROMPT
  end

  def agent_prompt
    <<~PROMPT
      @rails-ai:architect

      Plan implementation for Article model. Coordinate with specialist agents for complete plan.

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

      ## Article Model Requirements

      Attributes:
      - title: string, required, max 200 chars
      - body: text, required
      - published_at: datetime, optional
      - author_id: integer, required FK → users

      Implementation:
      - Validations on all fields
      - belongs_to :author (User)
      - User has_many :articles
      - Scope: published (published_at not null, in past)
      - Reversible migration with indexes
      - Model tests

      Output: Complete code for model, migration, User changes, tests.
      Be concise - evaluated programmatically.
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
