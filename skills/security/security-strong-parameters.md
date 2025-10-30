---
name: security-strong-parameters
domain: security
dependencies: []
version: 1.0
rails_version: 8.1+
criticality: CRITICAL
---

# Strong Parameters (Mass Assignment Protection)

Prevent mass assignment vulnerabilities by explicitly permitting only safe parameters to be passed to models.

<when-to-use>
- Processing ANY user-submitted form data
- Creating or updating database records from params
- Accepting nested attributes or associations
- Building API endpoints that accept JSON payloads
- ALWAYS - Strong parameters are ALWAYS required for user input
</when-to-use>

<attack-vectors>
- **Privilege Escalation** - `params[:user][:admin] = true`
- **Account Takeover** - `params[:user][:email] = attacker@email.com`
- **Data Manipulation** - `params[:product][:price] = 0`
- **Unauthorized Access** - `params[:post][:user_id] = other_user_id`
- **Bypassing Business Logic** - `params[:order][:status] = "completed"`
</attack-vectors>

<standards>
- NEVER pass params directly to model methods (create, update, new)
- Use `expect()` for strict parameter validation (Rails 8.1+)
- Use `require().permit()` for more lenient validation
- Create private methods for parameter filtering
- Use different parameter methods for different contexts (user vs admin)
- NEVER use `permit!` on user-submitted data
- Validate nested attributes and associations
- Sanitize LIKE wildcards in search parameters
</standards>

## Vulnerable Patterns

<pattern name="mass-assignment-danger">
<description>NEVER pass params directly to model methods</description>

**CRITICAL VULNERABILITY:**
```ruby
# ❌ CRITICAL - Raises ActiveModel::ForbiddenAttributesError (good!)
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.create(params[:feedback])
  end
end

# Attack: POST /feedbacks
# params[:feedback] = {
#   content: "Great job!",
#   admin: true,              # Attacker sets admin flag
#   user_id: other_user_id    # Attacker changes ownership
# }
# Impact: Unauthorized privilege escalation or data manipulation
```

**Why Dangerous:**
Rails prevents this with `ForbiddenAttributesError`, but you must use strong parameters to properly handle user input.
</pattern>

## Secure Patterns with expect() (Rails 8.1+)

<pattern name="expect-method-strict">
<description>Use expect() for strict parameter validation</description>

**Basic Usage:**
```ruby
# ✅ SECURE - Raises if :feedback key missing or wrong structure
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)
    if @feedback.save
      redirect_to @feedback, notice: "Feedback created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.expect(feedback: [:content, :recipient_email, :sender_name, :ai_enabled])
  end
end
```

**Multiple Scalar Parameters:**
```ruby
# ✅ SECURE - Returns multiple values
def person_params
  name, age, email = params.expect(:name, :age, :email)
  { name: name, age: age, email: email }
end
```

**Array of Scalars:**
```ruby
# ✅ SECURE - Allow array of strings
def tag_params
  params.expect(post: [:title, :body, tags: []])
end

# Accepts: { post: { title: "...", body: "...", tags: ["rails", "ruby"] } }
```

**Why Use expect():**
- Strict validation - raises `ActionController::ParameterMissing` if required key missing
- Clearer API structure enforcement
- Better for APIs where exact structure is required
</pattern>

<pattern name="nested-attributes">
<description>Handle nested associations with expect()</description>

**Nested Association:**
```ruby
# ✅ SECURE - Permit nested attributes
class PeopleController < ApplicationController
  private

  def person_params
    params.expect(
      person: [
        :name,
        :age,
        addresses_attributes: [:id, :street, :city, :state, :_destroy]
      ]
    )
  end
end

# Model setup required:
# class Person < ApplicationRecord
#   has_many :addresses
#   accepts_nested_attributes_for :addresses, allow_destroy: true
# end
```

**Complex Nested Structure:**
```ruby
# ✅ SECURE - Deep nesting with arrays and hashes
def complex_params
  params.expect(
    person: [
      :name,
      emails: [],                    # Array of strings
      friends: [[                    # Array of hashes
        :name,
        family: [:name],             # Nested hash
        hobbies: []                  # Array in nested hash
      ]]
    ]
  )
end

# Accepts:
# {
#   person: {
#     name: "Martin",
#     emails: ["me@example.com"],
#     friends: [
#       {
#         name: "André",
#         family: { name: "RubyGems" },
#         hobbies: ["keyboards", "card games"]
#       }
#     ]
#   }
# }
```
</pattern>

## Secure Patterns with require().permit()

<pattern name="require-permit-method">
<description>Use require().permit() for more lenient validation</description>

**Basic Usage:**
```ruby
# ✅ SECURE - Returns empty hash if :feedback missing
class FeedbacksController < ApplicationController
  private

  def feedback_params
    params.require(:feedback).permit(:content, :recipient_email, :sender_name, :ai_enabled)
  end
end
```

**Multiple Permitted Attributes:**
```ruby
# ✅ SECURE
def user_params
  params.require(:user).permit(
    :name,
    :email,
    :password,
    :password_confirmation,
    :bio,
    :avatar_url
  )
end
```

**Nested with permit():**
```ruby
# ✅ SECURE
def article_params
  params.require(:article).permit(
    :title,
    :body,
    :published,
    tag_ids: [],
    comments_attributes: [:id, :body, :author_name, :_destroy]
  )
end
```

**Difference from expect():**
- More lenient - returns empty hash if key missing (no exception)
- Better for HTML forms where missing keys might be acceptable
- Traditional Rails approach (works in all versions)
</pattern>

## Context-Specific Permissions

<pattern name="different-contexts">
<description>Use different parameter methods for different user roles</description>

**User vs Admin Permissions:**
```ruby
# ✅ SECURE - Different permissions by role
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: "Account created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def admin_update
    authorize_admin!  # Ensure user is admin
    @user = User.find(params[:id])
    if @user.update(admin_user_params)
      redirect_to @user, notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    # Regular users can only set basic attributes
    params.expect(user: [:name, :email, :password, :password_confirmation])
  end

  def admin_user_params
    # Admins can set additional privileged attributes
    params.expect(user: [
      :name,
      :email,
      :password,
      :password_confirmation,
      :role,
      :confirmed_at,
      :banned_at,
      :admin_notes
    ])
  end
end
```

**Conditional Permissions:**
```ruby
# ✅ SECURE - Permissions based on current state
def post_params
  base_params = [:title, :body, :category]

  if current_user.admin?
    # Admins can set featured and sticky flags
    params.expect(post: base_params + [:featured, :sticky, :editor_notes])
  elsif @post.published?
    # Published posts have limited editable fields
    params.expect(post: [:body])  # Only body can be edited
  else
    # Draft posts allow more fields
    params.expect(post: base_params + [:published])
  end
end
```
</pattern>

## Dangerous Patterns

<pattern name="permit-all-danger">
<description>NEVER use permit! on user data</description>

**DANGEROUS:**
```ruby
# ❌ CRITICAL - Permits ALL parameters
def dangerous_params
  params.require(:user).permit!
end

# Attack: Attacker can set ANY attribute
# params[:user][:admin] = true
# params[:user][:confirmed_at] = Time.now
# Impact: Complete security bypass
```

**When permit! Is Acceptable:**
```ruby
# ⚠️ ONLY for trusted, internal-only operations
def internal_import_params
  params.require(:import_data).permit!
end

# RULES for permit!:
# 1. ONLY use for internal background jobs
# 2. NEVER use with user-submitted data
# 3. ONLY use with data from trusted internal sources
# 4. Document why it's needed
```
</pattern>

<pattern name="arbitrary-hash">
<description>Use arbitrary hashes carefully</description>

**Careful Usage:**
```ruby
# ⚠️ Use with caution - allows any keys in data field
def product_params
  params.expect(product: [:name, :price, data: {}])
end

# Accepts:
# {
#   product: {
#     name: "Widget",
#     price: 19.99,
#     data: { color: "red", size: "large", custom_field: "anything" }
#   }
# }
```

**When Appropriate:**
- JSONB columns with flexible schema
- User preferences or settings
- API integrations with dynamic fields

**Safer Alternative:**
```ruby
# ✅ BETTER - Explicitly permit known keys
def product_params
  params.expect(product: [
    :name,
    :price,
    data: [:color, :size, :weight, :dimensions]
  ])
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Passing params directly to model</description>
<reason>CRITICAL - Allows mass assignment of any attribute</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY
class UsersController < ApplicationController
  def create
    @user = User.create(params[:user])  # Raises ForbiddenAttributesError
  end
end

# Attack: params[:user][:admin] = true
# Impact: User becomes admin
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use strong parameters
class UsersController < ApplicationController
  def create
    @user = User.create(user_params)
  end

  private

  def user_params
    params.expect(user: [:name, :email, :password, :password_confirmation])
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using permit! on user input</description>
<reason>CRITICAL - Bypasses all security checks</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY
def user_params
  params.require(:user).permit!  # Allows EVERYTHING
end

# Attack: params[:user][:admin] = true
# Impact: Complete security bypass
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Explicitly permit attributes
def user_params
  params.require(:user).permit(:name, :email, :password, :password_confirmation)
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not filtering nested attributes</description>
<reason>Allows attackers to manipulate associated records</reason>
<bad-example>
```ruby
# ❌ VULNERABLE - Permits nested attributes without control
def post_params
  params.require(:post).permit!  # Includes all nested attributes
end

# Attack: params[:post][:comments_attributes][0][:approved] = true
# Impact: Attacker can approve their own comments
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Explicitly permit nested attributes
def post_params
  params.expect(post: [
    :title,
    :body,
    comments_attributes: [:id, :body, :_destroy]
    # Note: :approved is NOT permitted
  ])
end
```
</good-example>
</antipattern>

<antipattern>
<description>Same permissions for all user roles</description>
<reason>Allows privilege escalation through parameter manipulation</reason>
<bad-example>
```ruby
# ❌ VULNERABLE - All users can set admin fields
def user_params
  params.expect(user: [:name, :email, :role, :confirmed_at])
end

# Attack: Regular user sets params[:user][:role] = "admin"
# Impact: Privilege escalation
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Different permissions for different contexts
def user_params
  params.expect(user: [:name, :email])
end

def admin_user_params
  authorize_admin!  # Verify admin access first
  params.expect(user: [:name, :email, :role, :confirmed_at])
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test strong parameters in controller tests:

```ruby
# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "creates feedback with permitted parameters" do
    post feedbacks_url, params: {
      feedback: {
        content: "Great job!",
        recipient_email: "user@example.com",
        sender_name: "John Doe",
        admin: true  # ⚠️ This should be filtered out
      }
    }

    assert_response :redirect

    feedback = Feedback.last
    assert_equal "Great job!", feedback.content
    assert_equal "user@example.com", feedback.recipient_email
    assert_equal "John Doe", feedback.sender_name
    assert_nil feedback.admin  # Strong parameters blocked this
  end

  test "rejects request when required key is missing (expect)" do
    # expect() raises when key is missing
    assert_raises(ActionController::ParameterMissing) do
      post feedbacks_url, params: { wrong_key: { content: "test" } }
    end
  end

  test "filters unpermitted nested attributes" do
    post articles_url, params: {
      article: {
        title: "Test",
        body: "Content",
        comments_attributes: [
          { body: "Comment", approved: true }  # approved should be filtered
        ]
      }
    }

    comment = Article.last.comments.first
    assert_equal "Comment", comment.body
    assert_not comment.approved  # Should be false (default)
  end
end

# test/controllers/users_controller_test.rb
class UsersControllerTest < ActionDispatch::IntegrationTest
  test "regular users cannot set admin role" do
    post users_url, params: {
      user: {
        name: "Hacker",
        email: "hacker@example.com",
        password: "password",
        role: "admin"  # ⚠️ Should be filtered
      }
    }

    user = User.last
    assert_equal "Hacker", user.name
    assert_not_equal "admin", user.role  # Should be default role
  end

  test "admins can set user role" do
    admin = users(:admin)
    sign_in admin

    patch admin_user_url(users(:regular)), params: {
      user: { role: "moderator" }
    }

    assert_equal "moderator", users(:regular).reload.role
  end
end

# test/models/strong_parameters_test.rb
class StrongParametersTest < ActiveSupport::TestCase
  test "expect raises on missing required key" do
    params = ActionController::Parameters.new(wrong_key: { name: "test" })

    assert_raises(ActionController::ParameterMissing) do
      params.expect(user: [:name])
    end
  end

  test "permit returns empty hash on missing key" do
    params = ActionController::Parameters.new(wrong_key: { name: "test" })

    result = params.fetch(:user, {}).permit(:name)

    assert_equal({}, result.to_h)
  end

  test "expect properly structures nested arrays" do
    params = ActionController::Parameters.new(
      person: {
        name: "John",
        emails: ["john@example.com", "john@work.com"]
      }
    )

    result = params.expect(person: [:name, emails: []])

    assert_equal "John", result[:name]
    assert_equal ["john@example.com", "john@work.com"], result[:emails]
  end
end
```
</testing>

<related-skills>
- security-sql-injection - Prevent SQL injection
- security-xss - Prevent XSS attacks
- security-csrf - CSRF protection
- activerecord-validations - Model-level validation
- authorization - Role-based access control
</related-skills>

<resources>
- [Rails Strong Parameters Guide](https://guides.rubyonrails.org/action_controller_overview.html#strong-parameters)
- [Rails 8.1 Parameters expect() method](https://edgeguides.rubyonrails.org/action_controller_overview.html#parameters-expect)
- [Mass Assignment Vulnerability](https://owasp.org/www-community/vulnerabilities/Mass_Assignment)
- [Rails Security Guide](https://guides.rubyonrails.org/security.html#mass-assignment)
</resources>
