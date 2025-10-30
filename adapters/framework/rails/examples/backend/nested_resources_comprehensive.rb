# Comprehensive Nested Resources Pattern (TEAM_RULES.md Rule #3 & #5)
# Reference: Rails Guides - Routing, Namespacing
# Category: CONTROLLERS & MODELS - NESTED RESOURCES

# ============================================================================
# Project Standard for Nested Resources
# ============================================================================

# This example demonstrates the project-standard approach for:
# 1. Child controllers (Rule #3) - RESTful routes with nested directory structure
# 2. Child models (Rule #5) - Nested directory structure with module namespacing

# Key Principles:
# ✅ Use PLURAL parent directory for both controllers and models (feedbacks/, not feedback/)
# ✅ Use module namespacing (module Feedbacks; class SendingsController)
# ✅ Routes use `module:` parameter for automatic namespace mapping
# ✅ Tests mirror the directory structure
# ✅ Consistency across controllers, models, and tests

# ============================================================================
# Part 1: Child Controllers (TEAM_RULES.md Rule #3)
# ============================================================================

# -------------------------------------------------------------------
# Routes Configuration
# -------------------------------------------------------------------

# config/routes.rb
Rails.application.routes.draw do
  # ✅ GOOD: Nested child controllers with REST-only actions
  resources :feedbacks do
    # Use `module: :feedbacks` to map routes to Feedbacks:: namespace
    # This tells Rails: "Look for the controller in app/controllers/feedbacks/"

    resource :sending, only: [:create], module: :feedbacks
    resource :retry, only: [:create], module: :feedbacks
    resource :publication, only: [:create, :destroy], module: :feedbacks

    # For child resources with full CRUD:
    resources :responses, only: [:index, :create, :destroy], module: :feedbacks
  end

  # ❌ BAD: Custom member actions (violates REST)
  # resources :feedbacks do
  #   member do
  #     post :send_feedback    # Should be: resource :sending
  #     post :retry_ai         # Should be: resource :retry
  #     post :publish          # Should be: resource :publication
  #   end
  # end

  # ❌ BAD: Flat controller structure
  # resources :feedbacks do
  #   resource :sending, only: [:create], controller: "feedback_sendings"
  # end
end

# Generated Routes:
# feedback_sending POST  /feedbacks/:feedback_id/sending      feedbacks/sendings#create
# feedback_retry   POST  /feedbacks/:feedback_id/retry        feedbacks/retries#create
# feedback_responses GET  /feedbacks/:feedback_id/responses   feedbacks/responses#index
#                  POST  /feedbacks/:feedback_id/responses   feedbacks/responses#create

# -------------------------------------------------------------------
# Child Controller: Sending Feedback
# -------------------------------------------------------------------

# app/controllers/feedbacks/sendings_controller.rb
module Feedbacks
  class SendingsController < ApplicationController
    before_action :set_feedback

    # POST /feedbacks/:feedback_id/sending
    def create
      if @feedback.ready_to_send?
        @feedback.start_sending!
        SendFeedbackEmailJob.perform_later(@feedback.id)

        redirect_to @feedback, notice: "Feedback is being sent"
      else
        redirect_to @feedback, alert: "Feedback is not ready to send"
      end
    end

    private

    def set_feedback
      @feedback = Feedback.find(params[:feedback_id])
    end
  end
end

# -------------------------------------------------------------------
# Child Controller: Retrying AI Processing
# -------------------------------------------------------------------

# app/controllers/feedbacks/retries_controller.rb
module Feedbacks
  class RetriesController < ApplicationController
    before_action :set_feedback

    # POST /feedbacks/:feedback_id/retry
    def create
      if @feedback.can_retry_ai?
        @feedback.reset_for_retry!
        ProcessFeedbackWithAiJob.perform_later(@feedback.id)

        redirect_to @feedback, notice: "Retrying AI processing"
      else
        redirect_to @feedback, alert: "Cannot retry at this time"
      end
    end

    private

    def set_feedback
      @feedback = Feedback.find(params[:feedback_id])
    end
  end
end

# -------------------------------------------------------------------
# Child Controller: Full CRUD Example
# -------------------------------------------------------------------

# app/controllers/feedbacks/responses_controller.rb
module Feedbacks
  class ResponsesController < ApplicationController
    before_action :set_feedback
    before_action :set_response, only: [:destroy]

    # GET /feedbacks/:feedback_id/responses
    def index
      @responses = @feedback.responses.order(created_at: :desc)
    end

    # POST /feedbacks/:feedback_id/responses
    def create
      @response = @feedback.responses.build(response_params)

      if @response.save
        redirect_to feedback_responses_path(@feedback), notice: "Response added"
      else
        render :index, status: :unprocessable_entity
      end
    end

    # DELETE /feedbacks/:feedback_id/responses/:id
    def destroy
      @response.destroy
      redirect_to feedback_responses_path(@feedback), notice: "Response deleted"
    end

    private

    def set_feedback
      @feedback = Feedback.find(params[:feedback_id])
    end

    def set_response
      @response = @feedback.responses.find(params[:id])
    end

    def response_params
      params.require(:response).permit(:content, :author_name)
    end
  end
end

# -------------------------------------------------------------------
# View Helpers Usage
# -------------------------------------------------------------------

# In views: app/views/feedbacks/show.html.erb
<%# Correct route helpers (no changes needed from previous structure) %>
<%= button_to "Send Feedback", feedback_sending_path(@feedback), method: :post %>
<%= button_to "Retry AI", feedback_retry_path(@feedback), method: :post %>
<%= link_to "View Responses", feedback_responses_path(@feedback) %>

# ============================================================================
# Part 2: Child Models (TEAM_RULES.md Rule #5)
# ============================================================================

# -------------------------------------------------------------------
# Child Model: Response
# -------------------------------------------------------------------

# app/models/feedbacks/response.rb
module Feedbacks
  class Response < ApplicationRecord
    # Table name: feedbacks_responses (automatically inferred by Rails)
    # Foreign key: feedback_id (singular parent)

    belongs_to :feedback

    validates :content, presence: true, length: { minimum: 10 }
    validates :author_name, presence: true

    scope :recent, -> { order(created_at: :desc) }
    scope :by_author, ->(name) { where(author_name: name) }

    def summary
      content.truncate(100)
    end
  end
end

# -------------------------------------------------------------------
# Child Model: Attachment
# -------------------------------------------------------------------

# app/models/feedbacks/attachment.rb
module Feedbacks
  class Attachment < ApplicationRecord
    # Table name: feedbacks_attachments
    # Foreign key: feedback_id

    belongs_to :feedback

    has_one_attached :file

    validates :file, presence: true
    validates :filename, presence: true

    def image?
      file.content_type.start_with?("image/")
    end

    def pdf?
      file.content_type == "application/pdf"
    end
  end
end

# -------------------------------------------------------------------
# Parent Model: Feedback
# -------------------------------------------------------------------

# app/models/feedback.rb
class Feedback < ApplicationRecord
  # Associations to child models
  has_many :responses, class_name: "Feedbacks::Response", dependent: :destroy
  has_many :attachments, class_name: "Feedbacks::Attachment", dependent: :destroy

  validates :content, presence: true
  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # State management methods
  def ready_to_send?
    ai_processed? && improved_content.present?
  end

  def can_retry_ai?
    ai_failed? || ai_processing_timeout?
  end

  def start_sending!
    update!(status: :sending, sending_started_at: Time.current)
  end

  def reset_for_retry!
    update!(status: :draft, ai_processing_started_at: nil)
  end
end

# -------------------------------------------------------------------
# Migrations
# -------------------------------------------------------------------

# db/migrate/20251030000001_create_feedbacks_responses.rb
class CreateFeedbacksResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks_responses do |t|
      t.references :feedback, null: false, foreign_key: true
      t.text :content, null: false
      t.string :author_name, null: false

      t.timestamps
    end

    add_index :feedbacks_responses, [:feedback_id, :created_at]
  end
end

# db/migrate/20251030000002_create_feedbacks_attachments.rb
class CreateFeedbacksAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks_attachments do |t|
      t.references :feedback, null: false, foreign_key: true
      t.string :filename, null: false
      t.string :content_type
      t.integer :file_size

      t.timestamps
    end
  end
end

# ============================================================================
# Part 3: Testing
# ============================================================================

# -------------------------------------------------------------------
# Controller Tests
# -------------------------------------------------------------------

# test/controllers/feedbacks/sendings_controller_test.rb
require "test_helper"

module Feedbacks
  class SendingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @feedback = feedbacks(:one)
      @feedback.update!(status: :ai_processed, improved_content: "Improved feedback")
    end

    test "should send feedback when ready" do
      assert_enqueued_with job: SendFeedbackEmailJob do
        post feedback_sending_url(@feedback)
      end

      assert_redirected_to @feedback
      assert_equal "Feedback is being sent", flash[:notice]

      @feedback.reload
      assert @feedback.sending?
    end

    test "should not send when not ready" do
      @feedback.update!(status: :draft)

      post feedback_sending_url(@feedback)

      assert_redirected_to @feedback
      assert_equal "Feedback is not ready to send", flash[:alert]
    end
  end
end

# test/controllers/feedbacks/responses_controller_test.rb
require "test_helper"

module Feedbacks
  class ResponsesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @feedback = feedbacks(:one)
    end

    test "should create response" do
      assert_difference("Feedbacks::Response.count") do
        post feedback_responses_url(@feedback), params: {
          response: { content: "Thank you for the feedback", author_name: "John" }
        }
      end

      assert_redirected_to feedback_responses_url(@feedback)
    end
  end
end

# -------------------------------------------------------------------
# Model Tests
# -------------------------------------------------------------------

# test/models/feedbacks/response_test.rb
require "test_helper"

module Feedbacks
  class ResponseTest < ActiveSupport::TestCase
    test "belongs to feedback" do
      response = feedbacks_responses(:one)
      assert_instance_of Feedback, response.feedback
    end

    test "requires content" do
      response = Feedbacks::Response.new(author_name: "John")
      assert_not response.valid?
      assert_includes response.errors[:content], "can't be blank"
    end

    test "recent scope orders by created_at desc" do
      responses = Feedbacks::Response.recent.to_a
      assert_equal responses, responses.sort_by(&:created_at).reverse
    end
  end
end

# -------------------------------------------------------------------
# Fixtures
# -------------------------------------------------------------------

# test/fixtures/feedbacks/responses.yml
one:
  feedback: one
  content: "This is a response to the feedback"
  author_name: "John Doe"
  created_at: <%= 1.day.ago %>

two:
  feedback: one
  content: "Another response"
  author_name: "Jane Smith"
  created_at: <%= 2.days.ago %>

# ============================================================================
# Directory Structure Summary
# ============================================================================

# app/
#   controllers/
#     feedbacks_controller.rb              # FeedbacksController
#     feedbacks/
#       sendings_controller.rb             # Feedbacks::SendingsController
#       retries_controller.rb              # Feedbacks::RetriesController
#       responses_controller.rb            # Feedbacks::ResponsesController
#   models/
#     feedback.rb                          # Feedback
#     feedbacks/
#       response.rb                        # Feedbacks::Response
#       attachment.rb                      # Feedbacks::Attachment
#   views/
#     feedbacks/
#       index.html.erb
#       show.html.erb
#       sendings/
#         # (optional views for child controllers)
#       responses/
#         index.html.erb
# test/
#   controllers/
#     feedbacks_controller_test.rb
#     feedbacks/
#       sendings_controller_test.rb
#       responses_controller_test.rb
#   models/
#     feedback_test.rb
#     feedbacks/
#       response_test.rb
#       attachment_test.rb
#   fixtures/
#     feedbacks.yml
#     feedbacks/
#       responses.yml
#       attachments.yml

# ============================================================================
# Key Benefits of This Approach
# ============================================================================

# 1. Organization
#    - Related controllers grouped in feedbacks/ subdirectory
#    - Related models grouped in feedbacks/ subdirectory
#    - Clear parent-child relationships

# 2. Consistency
#    - Both controllers and models use PLURAL parent namespace (Feedbacks::)
#    - Same pattern across entire codebase

# 3. Clarity
#    - Module namespacing makes relationships explicit
#    - No ambiguity about which controller/model is which

# 4. Scalability
#    - Easy to add more child resources (Feedbacks::Comments, Feedbacks::Tags, etc.)
#    - Namespace prevents naming conflicts

# 5. Rails Conventions
#    - Works seamlessly with Rails routing and ActiveRecord
#    - No magic configuration needed

# 6. Testing
#    - Test structure mirrors code structure
#    - Easy to find and organize tests

# ============================================================================
# Common Pitfalls to Avoid
# ============================================================================

# ❌ DON'T: Use singular parent directory
# app/models/feedback/response.rb  # module Feedback; class Response
# REASON: Inconsistent with controller naming (Feedbacks::)

# ❌ DON'T: Forget module namespacing in class definition
# app/models/feedbacks/response.rb
# class Response < ApplicationRecord  # Missing module Feedbacks
# REASON: Rails won't find the class correctly

# ❌ DON'T: Use custom controller parameter in routes
# resource :sending, only: [:create], controller: "feedback_sendings"
# REASON: Doesn't leverage Rails namespace conventions, harder to maintain

# ❌ DON'T: Mix flat and nested structures
# app/controllers/feedback_sendings_controller.rb  # Flat
# app/controllers/feedbacks/retries_controller.rb  # Nested
# REASON: Inconsistent, confusing for team members

# ============================================================================
# Related TEAM_RULES
# ============================================================================

# Rule #3: RESTful Routes Only
# - No custom member/collection actions
# - Create child controllers for additional actions
# - Use nested directory structure with module namespacing

# Rule #5: Proper Namespacing
# - Child models in app/models/[parent_plural]/
# - Use module namespacing: module Feedbacks; class Response
# - Table names: [parent_plural]_[child_plural]
# - Tests mirror structure

# Rule #4: TDD Always
# - Write tests first for all child controllers and models
# - Test files mirror code structure

# ============================================================================
# Quick Reference Card
# ============================================================================

# Routes:         resource :sending, only: [:create], module: :feedbacks
# Controller:     app/controllers/feedbacks/sendings_controller.rb
# Class:          module Feedbacks; class SendingsController
# Test:           test/controllers/feedbacks/sendings_controller_test.rb
# Route Helper:   feedback_sending_path(@feedback)

# Model:          app/models/feedbacks/response.rb
# Class:          module Feedbacks; class Response
# Table:          feedbacks_responses
# Foreign Key:    feedback_id
# Association:    has_many :responses, class_name: "Feedbacks::Response"
# Usage:          Feedbacks::Response.create(feedback: @feedback, ...)
# Test:           test/models/feedbacks/response_test.rb
# Fixture:        test/fixtures/feedbacks/responses.yml
