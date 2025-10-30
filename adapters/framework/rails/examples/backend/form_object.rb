# Form Object Pattern (ActiveModel::API)
# Reference: Rails Guides - Active Model Basics
# Category: MODELS - FORM OBJECTS

# ============================================================================
# What Are Form Objects?
# ============================================================================

# Form objects encapsulate complex form logic, validation, and data processing
# without requiring a database-backed model. They use ActiveModel::API to
# provide model-like behavior (validations, form_with compatibility, etc.).

# Benefits:
# ✅ Handle multi-model forms
# ✅ Complex validation logic
# ✅ Non-database forms (contact, search)
# ✅ Keep models and controllers thin
# ✅ Better testability

# ============================================================================
# ✅ RECOMMENDED: Basic Form Object
# ============================================================================

# app/forms/contact_form.rb
class ContactForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :message, :string
  attribute :subject, :string

  validates :name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :subject, presence: true

  def deliver
    return false unless valid?

    ContactMailer.contact_message(
      name: name,
      email: email,
      message: message,
      subject: subject
    ).deliver_later

    true
  end
end

# Controller usage
# app/controllers/contacts_controller.rb
class ContactsController < ApplicationController
  def new
    @contact_form = ContactForm.new
  end

  def create
    @contact_form = ContactForm.new(contact_params)

    if @contact_form.deliver
      redirect_to root_path, notice: "Message sent successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.expect(contact_form: [:name, :email, :message, :subject])
  end
end

# View usage
# app/views/contacts/new.html.erb
<%= form_with model: @contact_form, url: contacts_path do |form| %>
  <%= form.text_field :name %>
  <%= form.email_field :email %>
  <%= form.text_field :subject %>
  <%= form.text_area :message %>
  <%= form.submit %>
<% end %>

# ============================================================================
# ✅ EXAMPLE: Multi-Model Form Object
# ============================================================================

# app/forms/user_registration_form.rb
class UserRegistrationForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :name, :string
  attribute :company_name, :string
  attribute :company_size, :string
  attribute :role, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }
  validates :password_confirmation, presence: true
  validates :name, presence: true
  validates :company_name, presence: true

  validate :passwords_match

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @user = create_user
      @company = create_company
      @membership = create_membership

      send_welcome_email
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  attr_reader :user, :company, :membership

  private

  def create_user
    User.create!(
      email: email,
      password: password,
      name: name
    )
  end

  def create_company
    Company.create!(
      name: company_name,
      size: company_size,
      owner: @user
    )
  end

  def create_membership
    Membership.create!(
      user: @user,
      company: @company,
      role: role || "admin"
    )
  end

  def send_welcome_email
    UserMailer.welcome(@user).deliver_later
  end

  def passwords_match
    return if password.blank?

    unless password == password_confirmation
      errors.add(:password_confirmation, "doesn't match password")
    end
  end
end

# Usage
form = UserRegistrationForm.new(registration_params)
if form.save
  redirect_to dashboard_path(form.company)
else
  render :new
end

# ============================================================================
# ✅ EXAMPLE: Search Form Object
# ============================================================================

# app/forms/feedback_search_form.rb
class FeedbackSearchForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :query, :string
  attribute :status, :string
  attribute :date_from, :date
  attribute :date_to, :date
  attribute :recipient_email, :string
  attribute :sort_by, :string, default: "created_at"
  attribute :sort_direction, :string, default: "desc"

  validates :sort_by, inclusion: {
    in: %w[created_at updated_at status],
    message: "is not a valid sort field"
  }

  validates :sort_direction, inclusion: {
    in: %w[asc desc],
    message: "must be 'asc' or 'desc'"
  }

  def results
    return Feedback.none unless valid?

    scope = Feedback.all
    scope = apply_query(scope)
    scope = apply_status_filter(scope)
    scope = apply_date_range(scope)
    scope = apply_email_filter(scope)
    scope = apply_sorting(scope)
    scope
  end

  def has_filters?
    query.present? ||
      status.present? ||
      date_from.present? ||
      date_to.present? ||
      recipient_email.present?
  end

  private

  def apply_query(scope)
    return scope if query.blank?

    scope.where(
      "content ILIKE ? OR response ILIKE ?",
      "%#{query}%",
      "%#{query}%"
    )
  end

  def apply_status_filter(scope)
    return scope if status.blank?

    scope.where(status: status)
  end

  def apply_date_range(scope)
    scope = scope.where("created_at >= ?", date_from) if date_from.present?
    scope = scope.where("created_at <= ?", date_to) if date_to.present?
    scope
  end

  def apply_email_filter(scope)
    return scope if recipient_email.blank?

    scope.where("recipient_email ILIKE ?", "%#{recipient_email}%")
  end

  def apply_sorting(scope)
    scope.order("#{sort_by} #{sort_direction}")
  end
end

# Controller usage
class FeedbacksController < ApplicationController
  def index
    @search_form = FeedbackSearchForm.new(search_params)
    @feedbacks = @search_form.results.page(params[:page])
  end

  private

  def search_params
    params.fetch(:feedback_search_form, {}).permit(
      :query, :status, :date_from, :date_to, :recipient_email,
      :sort_by, :sort_direction
    )
  end
end

# ============================================================================
# ✅ EXAMPLE: Wizard Form Object (Multi-Step)
# ============================================================================

# app/forms/feedback_wizard_form.rb
class FeedbackWizardForm
  include ActiveModel::API
  include ActiveModel::Attributes

  # Step 1: Recipient
  attribute :recipient_email, :string
  attribute :sender_name, :string

  # Step 2: Content
  attribute :content, :string
  attribute :category, :string

  # Step 3: Options
  attribute :allow_ai_improvement, :boolean, default: false
  attribute :sender_email, :string

  # Wizard state
  attribute :current_step, :integer, default: 1

  validates :recipient_email, presence: true, email: true, if: :step_1?
  validates :sender_name, presence: true, if: :step_1?

  validates :content, presence: true, length: { minimum: 10 }, if: :step_2?
  validates :category, presence: true, if: :step_2?

  validates :sender_email, email: { allow_blank: true }, if: :step_3?

  def next_step
    return false unless valid_for_current_step?

    self.current_step += 1
    true
  end

  def previous_step
    self.current_step -= 1 if current_step > 1
  end

  def complete?
    current_step > 3
  end

  def save
    return false unless valid?

    feedback = Feedback.create!(
      recipient_email: recipient_email,
      sender_name: sender_name,
      content: content,
      category: category,
      allow_ai_improvement: allow_ai_improvement,
      sender_email: sender_email
    )

    feedback.improve_with_ai if allow_ai_improvement

    true
  end

  private

  def valid_for_current_step?
    case current_step
    when 1 then valid_step_1?
    when 2 then valid_step_2?
    when 3 then valid_step_3?
    else false
    end
  end

  def valid_step_1?
    validate_context(:step_1)
  end

  def valid_step_2?
    validate_context(:step_2)
  end

  def valid_step_3?
    validate_context(:step_3)
  end

  def step_1?
    validation_context == :step_1
  end

  def step_2?
    validation_context == :step_2
  end

  def step_3?
    validation_context == :step_3
  end

  def validate_context(context)
    self.validation_context = context
    valid?
  ensure
    self.validation_context = nil
  end
end

# Controller usage
class FeedbackWizardController < ApplicationController
  def show
    @form = current_form
  end

  def update
    @form = current_form
    @form.assign_attributes(form_params)

    if @form.next_step
      if @form.complete?
        if @form.save
          redirect_to success_path
        else
          render :show
        end
      else
        session[:wizard_data] = @form.attributes
        redirect_to feedback_wizard_path
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def current_form
    FeedbackWizardForm.new(session[:wizard_data] || {})
  end

  def form_params
    params.expect(feedback_wizard_form: [
      :recipient_email, :sender_name, :content, :category,
      :allow_ai_improvement, :sender_email
    ])
  end
end

# ============================================================================
# ✅ EXAMPLE: API Form Object
# ============================================================================

# app/forms/api/feedback_submission_form.rb
module Api
  class FeedbackSubmissionForm
    include ActiveModel::API
    include ActiveModel::Attributes
    include ActiveModel::Serialization

    attribute :recipient_email, :string
    attribute :content, :string
    attribute :sender_name, :string
    attribute :sender_email, :string
    attribute :category, :string
    attribute :metadata, :json, default: {}

    validates :recipient_email, presence: true, email: true
    validates :content, presence: true, length: { minimum: 10, maximum: 5000 }
    validates :sender_email, email: { allow_blank: true }

    validate :validate_metadata

    def submit
      return false unless valid?

      @feedback = Feedback.create!(attributes.except("metadata"))
      @feedback.update(metadata: metadata) if metadata.present?

      FeedbackMailer.notify_recipient(@feedback).deliver_later

      true
    end

    attr_reader :feedback

    def as_json(options = {})
      if feedback
        {
          success: true,
          feedback: {
            id: feedback.id,
            token: feedback.token,
            created_at: feedback.created_at
          }
        }
      else
        {
          success: false,
          errors: errors.as_json
        }
      end
    end

    private

    def validate_metadata
      return if metadata.blank?

      unless metadata.is_a?(Hash)
        errors.add(:metadata, "must be a valid JSON object")
      end
    end
  end
end

# API controller usage
module Api
  class FeedbacksController < ApiController
    def create
      form = FeedbackSubmissionForm.new(feedback_params)

      if form.submit
        render json: form, status: :created
      else
        render json: form, status: :unprocessable_entity
      end
    end

    private

    def feedback_params
      params.expect(feedback: [
        :recipient_email, :content, :sender_name,
        :sender_email, :category, :metadata
      ])
    end
  end
end

# ============================================================================
# ✅ TESTING FORM OBJECTS
# ============================================================================

# test/forms/contact_form_test.rb
require "test_helper"

class ContactFormTest < ActiveSupport::TestCase
  test "valid with all required attributes" do
    form = ContactForm.new(
      name: "John Doe",
      email: "john@example.com",
      subject: "Question",
      message: "This is my message"
    )

    assert form.valid?
  end

  test "invalid without name" do
    form = ContactForm.new(email: "john@example.com", message: "Message")

    assert_not form.valid?
    assert_includes form.errors[:name], "can't be blank"
  end

  test "invalid with short message" do
    form = ContactForm.new(
      name: "John",
      email: "john@example.com",
      subject: "Test",
      message: "Short"
    )

    assert_not form.valid?
    assert_includes form.errors[:message], "is too short"
  end

  test "delivers email when form is valid" do
    form = ContactForm.new(
      name: "John Doe",
      email: "john@example.com",
      subject: "Question",
      message: "This is my message"
    )

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      assert form.deliver
    end
  end

  test "does not deliver email when invalid" do
    form = ContactForm.new(name: "John")

    assert_no_enqueued_jobs do
      assert_not form.deliver
    end
  end
end

# ============================================================================
# File Organization
# ============================================================================

# app/forms/
# ├── contact_form.rb
# ├── user_registration_form.rb
# ├── feedback_search_form.rb
# ├── feedback_wizard_form.rb
# └── api/
#     └── feedback_submission_form.rb

# test/forms/
# ├── contact_form_test.rb
# ├── user_registration_form_test.rb
# └── ...

# ============================================================================
# RULE: Use form objects for complex, multi-model, or non-database forms
# INCLUDE: ActiveModel::API for model-like behavior
# VALIDATE: Add comprehensive validations just like models
# TEST: Test form objects in isolation without database
# TRANSACTION: Wrap multi-model operations in transactions
# ============================================================================
