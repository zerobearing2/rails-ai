# Strong Parameters (Mass Assignment Protection)
# Reference: Rails 8.1 Action Controller Overview
# Category: CRITICAL SECURITY

# ============================================================================
# ❌ VULNERABLE: Mass Assignment Without Protection
# ============================================================================

# NEVER do this - allows any attribute to be set
def create
  Person.create(params[:person])
end
# Raises: ActiveModel::ForbiddenAttributesError (good!)
# Attack: params[:person] = { name: "John", admin: true }
# Impact: User could make themselves admin

# ============================================================================
# ✅ SECURE: Strong Parameters with expect (Rails 8.1)
# ============================================================================

class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)
    if @feedback.save
      redirect_to @feedback, notice: "Created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @feedback = Feedback.find(params[:id])
    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # expect method: Raises if :feedback key missing or structure wrong
  def feedback_params
    params.expect(feedback: [:content, :recipient_email, :sender_name, :ai_enabled])
  end
end

# ============================================================================
# ✅ Alternative: permit (More Flexible)
# ============================================================================

class FeedbacksController < ApplicationController
  private

  # permit method: Returns empty hash if :feedback missing (more lenient)
  def feedback_params
    params.require(:feedback).permit(:content, :recipient_email, :sender_name, :ai_enabled)
  end
end

# ============================================================================
# ✅ Nested Attributes with expect
# ============================================================================

class PeopleController < ApplicationController
  private

  def person_params
    params.expect(
      person: [
        :name,
        :age,
        addresses_attributes: [:id, :street, :city, :_destroy]  # Nested association
      ]
    )
  end
end

# ============================================================================
# ✅ Complex Nested Structures
# ============================================================================

# Given params:
params = ActionController::Parameters.new(
  name: "Martin",
  emails: ["me@example.com"],
  friends: [
    { name: "André", family: { name: "RubyGems" }, hobbies: ["keyboards", "card games"] },
    { name: "Kewe", family: { name: "Baroness" }, hobbies: ["video games"] }
  ]
)

# Permit complex structure
name, emails, friends = params.expect(
  :name,                 # Scalar
  emails: [],            # Array of scalars
  friends: [[            # Array of hashes
    :name,               # Scalar in hash
    family: [:name],     # Nested hash
    hobbies: []          # Array in hash
  ]]
)

# ============================================================================
# ✅ Arbitrary Data Hash (Use Carefully)
# ============================================================================

def product_params
  params.expect(product: [:name, data: {}])
  # Allows arbitrary hash in data field
  # Use only for truly flexible data structures
end

# ============================================================================
# ✅ Different Permissions by Context
# ============================================================================

class UsersController < ApplicationController
  def create
    # Regular users can set basic attributes
    @user = User.new(user_params)
    # ...
  end

  def admin_update
    # Admins can set additional attributes
    @user = User.find(params[:id])
    @user.update(admin_user_params)
    # ...
  end

  private

  def user_params
    params.expect(user: [:name, :email, :password, :password_confirmation])
  end

  def admin_user_params
    # Admins can also set role, confirmed_at, etc.
    params.expect(user: [:name, :email, :password, :password_confirmation, :role, :confirmed_at])
  end
end

# ============================================================================
# ✅ permit! for Trusted Internal Operations (DANGEROUS)
# ============================================================================

# ONLY use permit! for trusted, internal-only operations
# ⚠️ WARNING: Bypasses all security checks
def internal_import_params
  params.require(:import_data).permit!  # Permits EVERYTHING
  # Use ONLY when importing from trusted internal sources
  # NEVER for user-submitted data
end

# ============================================================================
# ✅ Testing Strong Parameters
# ============================================================================

# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "creates feedback with permitted parameters" do
    post feedbacks_url, params: {
      feedback: {
        content: "Great job!",
        recipient_email: "user@example.com",
        admin: true  # ⚠️ This should be filtered out
      }
    }

    feedback = Feedback.last
    assert_equal "Great job!", feedback.content
    assert_equal "user@example.com", feedback.recipient_email
    assert_nil feedback.admin  # Strong parameters blocked this
  end

  test "rejects invalid parameters with expect" do
    assert_raises(ActionController::ParameterMissing) do
      post feedbacks_url, params: { wrong_key: { content: "test" } }
    end
  end
end

# ============================================================================
# ✅ IRB Testing Examples
# ============================================================================

# Test in Rails console
params = ActionController::Parameters.new(id: 1, admin: "true")
# => #<ActionController::Parameters {"id"=>1, "admin"=>"true"} permitted: false>

params.permit(:id)
# => #<ActionController::Parameters {"id"=>1} permitted: true>

params.permit(:id, :admin)
# => #<ActionController::Parameters {"id"=>1, "admin"=>"true"} permitted: true>

# ============================================================================
# ✅ ViewComponent Integration
# ============================================================================

# When rendering components with user data
class FeedbackCardComponent < ViewComponent::Base
  def initialize(feedback:)
    # Only pass safe attributes to component
    @content = feedback.content
    @email = feedback.recipient_email
    # Don't pass entire model unless you control all attributes
  end
end

# ============================================================================
# RULE: ALWAYS use expect() or permit() for user parameters
# NEVER: Mass assign params directly (raises ForbiddenAttributesError)
# expect(): Strict - raises if key missing or structure wrong (Rails 8.1)
# permit(): Lenient - returns empty hash if key missing
# permit!(): DANGEROUS - only for trusted internal data
# ============================================================================
