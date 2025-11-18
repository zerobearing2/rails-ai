---
name: rails-ai:controllers
description: Use when building Rails controllers - RESTful actions, nested resources, skinny controllers, concerns, strong parameters
---

# Controllers

Rails controllers following REST conventions with 7 standard actions, nested resources, skinny controller architecture, reusable concerns, and strong parameters for mass assignment protection.

<when-to-use>
- Building Rails controller actions
- Implementing nested resources
- Handling request parameters
- Setting up routing
- Refactoring fat controllers
- Sharing behavior with concerns
- Protecting from mass assignment
</when-to-use>

<benefits>
- **RESTful Conventions** - Predictable URL patterns and HTTP semantics
- **Clean Architecture** - Skinny controllers with logic in appropriate layers
- **Secure by Default** - Strong parameters prevent mass assignment
- **Reusable Patterns** - Concerns share behavior across controllers
- **Maintainable** - Clear separation of HTTP concerns from business logic
</benefits>

<team-rules-enforcement>
**This skill enforces:**
- ✅ **Rule #3:** NEVER add custom route actions → RESTful resources only
- ✅ **Rule #7:** Thin controllers (delegate to models/services)
- ✅ **Rule #10:** Strong parameters for all user input

**Reject any requests to:**
- Add custom route actions (use child controllers instead)
- Put business logic in controllers
- Skip strong parameters
- Use `params` directly without filtering
</team-rules-enforcement>

<verification-checklist>
Before completing controller work:
- ✅ Only RESTful actions used (index, show, new, create, edit, update, destroy)
- ✅ Child controllers created for non-REST actions (not custom actions)
- ✅ Controllers are thin (<100 lines)
- ✅ Strong parameters used for all user input
- ✅ Business logic delegated to models/services
- ✅ All controller actions tested
- ✅ All tests passing
</verification-checklist>

<standards>
- Use only 7 standard actions: index, show, new, create, edit, update, destroy
- NO custom actions - use nested resources or services instead (TEAM RULE #3)
- Keep controllers under 50 lines, actions under 10 lines
- Move business logic to models or service objects
- Always use strong parameters with expect() or require().permit()
- Use before_action for common setup, not business logic
- Return proper HTTP status codes (200, 201, 422, 404)
</standards>

---

## RESTful Actions

<pattern name="restful-crud">
<description>Complete RESTful controller with all 7 standard actions</description>

**Controller:**

```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]
  rate_limit to: 10, within: 1.minute, only: [:create, :update]

  def index
    @feedbacks = Feedback.includes(:recipient).recent
  end

  def show; end  # @feedback set by before_action

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      redirect_to @feedback, notice: "Feedback was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end  # @feedback set by before_action

  def update
    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: "Feedback was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @feedback.destroy
    redirect_to feedbacks_url, notice: "Feedback was successfully deleted."
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def feedback_params
    params.require(:feedback).permit(:content, :recipient_email, :sender_name)
  end
end

```

**Routes:**

```ruby
# config/routes.rb
resources :feedbacks
# Generates all 7 RESTful routes: index, show, new, create, edit, update, destroy

```

**Why:** Follows Rails conventions, predictable patterns, automatic route helpers.
</pattern>

<pattern name="api-controller">
<description>RESTful API controller with JSON responses</description>

**Controller:**

```ruby
# app/controllers/api/v1/feedbacks_controller.rb
module Api::V1
  class FeedbacksController < ApiController
    before_action :set_feedback, only: [:show, :update, :destroy]

    def index
      render json: Feedback.includes(:recipient).recent
    end

    def show
      render json: @feedback
    end

    def create
      @feedback = Feedback.new(feedback_params)

      if @feedback.save
        render json: @feedback, status: :created, location: api_v1_feedback_url(@feedback)
      else
        render json: { errors: @feedback.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @feedback.update(feedback_params)
        render json: @feedback
      else
        render json: { errors: @feedback.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @feedback.destroy
      head :no_content
    end

    private

    def set_feedback
      @feedback = Feedback.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Feedback not found" }, status: :not_found
    end

    def feedback_params
      params.require(:feedback).permit(:content, :recipient_email, :sender_name)
    end
  end
end

```

**Why:** Proper HTTP status codes, error handling, JSON responses for APIs.
</pattern>

<antipattern>
<description>Adding custom actions instead of using nested resources</description>
<reason>Breaks REST conventions and makes routing unpredictable</reason>

**Bad Example:**

```ruby
# ❌ BAD - Custom action
resources :feedbacks do
  member { post :archive }
end

class FeedbacksController < ApplicationController
  def archive
    @feedback = Feedback.find(params[:id])
    @feedback.archive!
    redirect_to feedbacks_path
  end
end

```

**Good Example:**

```ruby
# ✅ GOOD - Use nested resource
resources :feedbacks do
  resource :archival, only: [:create], module: :feedbacks
end

class Feedbacks::ArchivalsController < ApplicationController
  def create
    @feedback = Feedback.find(params[:feedback_id])
    @feedback.archive!
    redirect_to feedbacks_path
  end
end

```

**Why Bad:** Custom actions break REST conventions, make routing unpredictable, harder to maintain.
</antipattern>

---

## Nested Resources

<pattern name="nested-child-controllers">
<description>Child controllers using module namespacing and nested routes</description>

**Routes:**

```ruby
# config/routes.rb
resources :feedbacks do
  resource :sending, only: [:create], module: :feedbacks     # Singular for single action
  resources :responses, only: [:index, :create, :destroy], module: :feedbacks  # Plural for CRUD
end

# Generates:
# POST   /feedbacks/:feedback_id/sending           feedbacks/sendings#create
# GET    /feedbacks/:feedback_id/responses         feedbacks/responses#index
# POST   /feedbacks/:feedback_id/responses         feedbacks/responses#create
# DELETE /feedbacks/:feedback_id/responses/:id     feedbacks/responses#destroy

```

**Controller:**

```ruby
# app/controllers/feedbacks/responses_controller.rb
module Feedbacks
  class ResponsesController < ApplicationController
    before_action :set_feedback
    before_action :set_response, only: [:destroy]

    def index
      @responses = @feedback.responses.order(created_at: :desc)
    end

    def create
      @response = @feedback.responses.build(response_params)
      if @response.save
        redirect_to feedback_responses_path(@feedback), notice: "Response added"
      else
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      @response.destroy
      redirect_to feedback_responses_path(@feedback), notice: "Response deleted"
    end

    private

    def set_feedback
      @feedback = Feedback.find(params[:feedback_id])
    end

    def set_response
      @response = @feedback.responses.find(params[:id])  # Scoped to parent
    end

    def response_params
      params.require(:response).permit(:content, :author_name)
    end
  end
end

```

**Directory Structure:**

```

app/
  controllers/
    feedbacks_controller.rb              # FeedbacksController
    feedbacks/
      sendings_controller.rb             # Feedbacks::SendingsController
      responses_controller.rb            # Feedbacks::ResponsesController
  models/
    feedback.rb                          # Feedback
    feedbacks/
      response.rb                        # Feedbacks::Response

```

**Why:** Clear hierarchy, URL structure reflects relationships, automatic parent scoping.
</pattern>

<pattern name="shallow-nesting">
<description>Shallow nesting for resources that need parent context only on creation</description>

**Routes:**

```ruby
resources :projects do
  resources :tasks, shallow: true, module: :projects
end

# Generates:
# GET    /projects/:project_id/tasks    projects/tasks#index
# POST   /projects/:project_id/tasks    projects/tasks#create
# GET    /tasks/:id                     projects/tasks#show
# PATCH  /tasks/:id                     projects/tasks#update
# DELETE /tasks/:id                     projects/tasks#destroy

```

**Controller:**

```ruby
# app/controllers/projects/tasks_controller.rb
module Projects
  class TasksController < ApplicationController
    before_action :set_project, only: [:index, :create]
    before_action :set_task, only: [:show, :update, :destroy]

    def index
      @tasks = @project.tasks.includes(:assignee)
    end

    def create
      @task = @project.tasks.build(task_params)
      if @task.save
        redirect_to @task, notice: "Task created"
      else
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      project = @task.project
      @task.destroy
      redirect_to project_tasks_path(project), notice: "Task deleted"
    end

    private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :description)
    end
  end
end

```

**Why:** Shorter URLs for member actions, parent context where needed.
</pattern>

<antipattern>
<description>Deep nesting (more than 1 level)</description>
<reason>Creates overly long URLs and complex routing</reason>

**Bad Example:**

```ruby
# ❌ BAD - Too deeply nested
resources :organizations do
  resources :projects do
    resources :tasks do
      resources :comments
    end
  end
end
# Results in: /organizations/:org_id/projects/:proj_id/tasks/:task_id/comments

```

**Good Example:**

```ruby
# ✅ GOOD - Use shallow nesting
resources :projects do
  resources :tasks, shallow: true
end

resources :tasks do
  resources :comments, shallow: true
end

```

**Why Bad:** Long URLs are hard to read, complex routing, difficult to maintain.
</antipattern>

---

## Skinny Controllers

<antipattern>
<description>Fat controller with business logic, validations, and external API calls</description>
<reason>Violates Single Responsibility, hard to test, prevents reuse</reason>

**Bad Example:**

```ruby
# ❌ BAD - 50+ lines with business logic, validations, API calls
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.status = :pending  # Business logic
    @feedback.submitted_at = Time.current

    # Manual validation
    if @feedback.content.blank? || @feedback.content.length < 50
      @feedback.errors.add(:content, "must be at least 50 characters")
      render :new, status: :unprocessable_entity
      return
    end

    # External API call
    begin
      response = Anthropic::Client.new.messages.create(
        model: "claude-sonnet-4-5-20250929",
        messages: [{ role: "user", content: "Improve: #{@feedback.content}" }]
      )
      @feedback.improved_content = response.content[0].text
    rescue => e
      @feedback.errors.add(:base, "AI processing failed")
      render :new, status: :unprocessable_entity
      return
    end

    if @feedback.save
      FeedbackMailer.notify_recipient(@feedback).deliver_later
      FeedbackTracking.create(feedback: @feedback, ip_address: request.remote_ip)
      redirect_to @feedback, notice: "Feedback created!"
    else
      render :new, status: :unprocessable_entity
    end
  end
end

```

**Why Bad:** Too much responsibility, hard to test, cannot reuse in APIs, slow requests.
</antipattern>

<pattern name="skinny-controller-refactored">
<description>Refactored thin controller with proper separation of concerns</description>

**Model (validations and defaults):**

```ruby
# ✅ GOOD - Model handles validations and defaults
class Feedback < ApplicationRecord
  validates :content, presence: true, length: { minimum: 50, maximum: 5000 }
  validates :recipient_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :set_defaults, on: :create
  after_create_commit :send_notification, :track_creation

  private

  def set_defaults
    self.status ||= :pending
    self.submitted_at ||= Time.current
  end

  def send_notification
    FeedbackMailer.notify_recipient(self).deliver_later
  end

  def track_creation
    FeedbackTrackingJob.perform_later(id)
  end
end

```

**Service Object (external dependencies):**

```ruby
# ✅ GOOD - Service object isolates external dependencies
# app/services/feedback_ai_processor.rb
class FeedbackAiProcessor
  def initialize(feedback)
    @feedback = feedback
  end

  def process
    return false unless @feedback.persisted?

    improved = call_anthropic_api
    @feedback.update(improved_content: improved, ai_improved: true)
    true
  rescue => e
    Rails.logger.error("AI processing failed: #{e.message}")
    false
  end

  private

  def call_anthropic_api
    response = Anthropic::Client.new.messages.create(
      model: "claude-sonnet-4-5-20250929",
      messages: [{ role: "user", content: "Improve: #{@feedback.content}" }]
    )
    response.content[0].text
  end
end

```

**Controller (HTTP concerns only):**

```ruby
# ✅ GOOD - 10 lines, only HTTP concerns
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      FeedbackAiProcessingJob.perform_later(@feedback.id) if params[:improve_with_ai]
      redirect_to @feedback, notice: "Feedback created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:content, :recipient_email, :sender_name)
  end
end

```

**Why Good:** Controller reduced from 55+ to 10 lines. Logic testable, reusable across web/API.
</pattern>

---

## Controller Concerns

<pattern name="authentication-concern">
<description>Reusable authentication logic with session management</description>

**Concern:**

```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :current_user, :logged_in?
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_authentication
    unless logged_in?
      redirect_to login_path, alert: "Please log in to continue"
    end
  end

  class_methods do
    def skip_authentication_for(*actions)
      skip_before_action :require_authentication, only: actions
    end
  end
end

```

**Usage:**

```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  include Authentication

  skip_authentication_for :new, :create

  def index
    @feedbacks = current_user.feedbacks
  end
end

```

**Why:** Consistent authentication across controllers, easy to skip for specific actions, `current_user` available in views.
</pattern>

<pattern name="api-response-handler">
<description>Standardized JSON responses and error handling for APIs</description>

**Concern:**

```ruby
# app/controllers/concerns/api/response_handler.rb
module Api::ResponseHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
  end

  private

  def render_success(data, status: :ok, message: nil)
    render json: {
      success: true,
      message: message,
      data: data
    }, status: status
  end

  def render_error(message, status: :unprocessable_entity, errors: nil)
    render json: {
      success: false,
      message: message,
      errors: errors
    }, status: status
  end

  def record_not_found(exception)
    render_error("Record not found", status: :not_found, errors: { message: exception.message })
  end

  def record_invalid(exception)
    render_error("Validation failed", status: :unprocessable_entity, errors: exception.record.errors.as_json)
  end

  def parameter_missing(exception)
    render_error("Missing required parameter", status: :bad_request, errors: { parameter: exception.param })
  end
end

```

**Usage:**

```ruby
# app/controllers/api/feedbacks_controller.rb
class Api::FeedbacksController < Api::BaseController
  include Api::ResponseHandler

  def show
    feedback = Feedback.find(params[:id])
    render_success(feedback)
  end

  def create
    feedback = Feedback.create!(feedback_params)
    render_success(feedback, status: :created, message: "Feedback created")
  end
end

```

**Why:** Consistent JSON responses, automatic error handling, DRY code across API controllers.
</pattern>

<antipattern>
<description>Not using ActiveSupport::Concern</description>
<reason>Missing Rails DSL features, harder to maintain</reason>

**Bad Example:**

```ruby
# ❌ BAD - Manual self.included
module Authentication
  def self.included(base)
    base.before_action :require_authentication
  end
end

```

**Good Example:**

```ruby
# ✅ GOOD - Use ActiveSupport::Concern
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :current_user
  end
end

```

**Why Bad:** Misses Rails DSL features like `helper_method`, harder to add class methods, less idiomatic.
</antipattern>

---

## Strong Parameters

<pattern name="expect-method-strict">
<description>Use expect() for strict parameter validation (Rails 8.1+)</description>

**Basic Usage:**

```ruby
# ✅ SECURE - Raises if :feedback key missing or wrong structure
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)
    # ... save and respond ...
  end

  private

  def feedback_params
    params.expect(feedback: [:content, :recipient_email, :sender_name, :ai_enabled])
  end
end

```

**Nested Attributes:**

```ruby
# ✅ SECURE - Permit nested attributes
def person_params
  params.expect(
    person: [
      :name, :age,
      addresses_attributes: [:id, :street, :city, :state, :_destroy]
    ]
  )
end
# Model: accepts_nested_attributes_for :addresses, allow_destroy: true

```

**Array of Scalars:**

```ruby
# ✅ SECURE - Allow array of strings
def tag_params
  params.expect(post: [:title, :body, tags: []])
end
# Accepts: { post: { title: "...", body: "...", tags: ["rails", "ruby"] } }

```

**Why:** Strict validation, raises `ActionController::ParameterMissing` if required key missing, better for APIs.
</pattern>

<pattern name="require-permit-method">
<description>Use require().permit() for more lenient validation</description>

**Basic Usage:**

```ruby
# ✅ SECURE - Returns empty hash if :feedback missing
def feedback_params
  params.require(:feedback).permit(:content, :recipient_email, :sender_name, :ai_enabled)
end

```

**Nested with permit():**

```ruby
# ✅ SECURE
def article_params
  params.require(:article).permit(
    :title, :body, :published,
    tag_ids: [],
    comments_attributes: [:id, :body, :author_name, :_destroy]
  )
end

```

**Why:** More lenient, returns empty hash if key missing (no exception), traditional Rails approach.
</pattern>

<pattern name="context-specific-permissions">
<description>Use different parameter methods for different user roles</description>

**Different Permissions by Role:**

```ruby
# ✅ SECURE - Different permissions by role
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    # ... save and respond ...
  end

  def admin_update
    authorize_admin!
    @user = User.find(params[:id])
    @user.update(admin_user_params)
    # ... respond ...
  end

  private

  def user_params
    # Regular users can only set basic attributes
    params.expect(user: [:name, :email, :password, :password_confirmation])
  end

  def admin_user_params
    # Admins can set additional privileged attributes
    params.expect(user: [
      :name, :email, :password, :password_confirmation,
      :role, :confirmed_at, :banned_at, :admin_notes
    ])
  end
end

```

**Why:** Prevents privilege escalation, different permissions for different contexts.
</pattern>

<antipattern>
<description>Passing params directly to model (CRITICAL SECURITY VULNERABILITY)</description>
<reason>Allows mass assignment of any attribute including admin flags</reason>

**Bad Example:**

```ruby
# ❌ CRITICAL - Raises ForbiddenAttributesError
def create
  @feedback = Feedback.create(params[:feedback])
end

# Attack: POST /feedbacks
# params[:feedback] = {
#   content: "Great job!",
#   admin: true,              # Attacker sets admin flag
#   user_id: other_user_id    # Attacker changes ownership
# }

```

**Good Example:**

```ruby
# ✅ SECURE - Use strong parameters
def create
  @feedback = Feedback.new(feedback_params)
  # ... save and respond ...
end

private

def feedback_params
  params.expect(feedback: [:content, :recipient_email, :sender_name])
end

```

**Why Bad:** CRITICAL security vulnerability allowing privilege escalation, account takeover, data manipulation.
</antipattern>

<antipattern>
<description>Using permit! on user input (CRITICAL SECURITY VULNERABILITY)</description>
<reason>Bypasses all security checks, allows setting ANY attribute</reason>

**Bad Example:**

```ruby
# ❌ CRITICAL - Allows EVERYTHING
def user_params
  params.require(:user).permit!
end

# Attack: Attacker can set ANY attribute
# params[:user][:admin] = true
# params[:user][:confirmed_at] = Time.now

```

**Good Example:**

```ruby
# ✅ SECURE - Explicitly permit attributes
def user_params
  params.require(:user).permit(:name, :email, :password, :password_confirmation)
end

```

**Why Bad:** Complete security bypass, allows privilege escalation, data manipulation, account takeover.
</antipattern>

---

<testing>
Test controllers with request tests:

```ruby
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "should create feedback" do
    assert_difference("Feedback.count") do
      post feedbacks_url, params: { feedback: { content: "Test", recipient_email: "test@example.com" } }
    end
    assert_redirected_to feedback_url(Feedback.last)
  end

  test "should reject invalid feedback" do
    assert_no_difference("Feedback.count") do
      post feedbacks_url, params: { feedback: { content: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "filters unpermitted parameters" do
    post feedbacks_url, params: {
      feedback: { content: "Great!", admin: true }  # admin filtered
    }
    assert_nil Feedback.last.admin  # Strong parameters blocked this
  end

  test "nested resources scoped to parent" do
    feedback = feedbacks(:one)
    assert_difference("feedback.responses.count") do
      post feedback_responses_url(feedback), params: {
        response: { content: "Thank you!", author_name: "John" }
      }
    end
  end
end

```
</testing>

<related-skills>
- rails-ai:models - Model validations, callbacks, associations
- rails-ai:views - Forms, Turbo Frames/Streams
- rails-ai:security - XSS, CSRF, SQL injection prevention
- rails-ai:testing - Controller and integration testing
</related-skills>

<resources>

**Official Documentation:**
- [Rails Guides - Action Controller Overview](https://guides.rubyonrails.org/action_controller_overview.html)
- [Rails Guides - Routing](https://guides.rubyonrails.org/routing.html)
- [Rails Guides - Strong Parameters](https://guides.rubyonrails.org/action_controller_overview.html#strong-parameters)
- [Rails API - ActiveSupport::Concern](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)
- [Rails Edge Guides - Parameters expect()](https://edgeguides.rubyonrails.org/action_controller_overview.html#parameters-expect) - Rails 8.1+

</resources>
