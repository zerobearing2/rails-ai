---
name: concerns-controllers
domain: backend
dependencies: [controller-restful]
version: 1.0
rails_version: 8.1+
---

# Controller Concerns

Extract shared controller behavior into reusable concerns for authentication, authorization, error handling, API responses, pagination, filtering, and caching.

<when-to-use>
- Sharing behavior across multiple controllers
- Implementing authentication/authorization patterns
- Standardizing error handling across controllers
- Formatting API responses consistently
- Adding pagination, filtering, or caching to controllers
- Creating reusable controller mixins
- Avoiding code duplication in controllers
</when-to-use>

<benefits>
- **DRY Code** - Share behavior across controllers without inheritance
- **Modularity** - Mix in only needed functionality
- **Testability** - Test concerns in isolation
- **Organization** - Group related behavior logically
- **Namespace Safety** - Prevent method name conflicts
- **Class Methods** - Add class-level DSL methods
- **Callbacks** - Define callbacks in the including controller's context
</benefits>

<standards>
- ALWAYS use `ActiveSupport::Concern` for controller concerns
- Use `included do...end` for callbacks that run in controller context
- Use `class_methods do...end` for DSL-style methods
- Use `private` methods for concern implementation details
- Namespace concerns for API and admin (e.g., `Api::ResponseHandler`)
- Test concerns with dummy controllers in isolation
- Use `helper_method` to expose methods to views
- Keep concerns focused on single responsibility
- Store in `app/controllers/concerns/` directory
</standards>

## Authentication Concern

<pattern name="authentication-concern">
<description>Reusable authentication logic with session management</description>

**Concern:**
```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    # Run before actions in the context of the including controller
    before_action :require_authentication

    # Helper methods available in views
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
    # Skip authentication for specific actions
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

  # Skip auth for public actions
  skip_authentication_for :new, :create

  def index
    @feedbacks = current_user.feedbacks
  end

  def show
    @feedback = current_user.feedbacks.find(params[:id])
  end
end
```

**Benefits:**
- Consistent authentication across controllers
- Easy to skip auth for specific actions
- `current_user` available in views via `helper_method`
- Single source of truth for authentication logic
</pattern>

## API Response Formatting

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
    render_error(
      "Record not found",
      status: :not_found,
      errors: { message: exception.message }
    )
  end

  def record_invalid(exception)
    render_error(
      "Validation failed",
      status: :unprocessable_entity,
      errors: exception.record.errors.as_json
    )
  end

  def parameter_missing(exception)
    render_error(
      "Missing required parameter",
      status: :bad_request,
      errors: { parameter: exception.param }
    )
  end

  class_methods do
    def api_resource(name, options = {})
      define_method(:resource_name) { name }
      define_method(:resource_class) { name.to_s.classify.constantize }
    end
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

  private

  def feedback_params
    params.require(:feedback).permit(:content, :recipient_email)
  end
end
```

**Response Examples:**
```json
// Success response
{
  "success": true,
  "message": "Feedback created",
  "data": {
    "id": 1,
    "content": "Great work!",
    "recipient_email": "user@example.com"
  }
}

// Error response
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "content": ["can't be blank"],
    "recipient_email": ["is invalid"]
  }
}
```
</pattern>

## Pagination Concern

<pattern name="pagination-concern">
<description>Reusable pagination with configurable page sizes</description>

**Concern:**
```ruby
# app/controllers/concerns/paginatable.rb
module Paginatable
  extend ActiveSupport::Concern

  included do
    before_action :set_pagination_params
  end

  private

  def set_pagination_params
    @page = params[:page]&.to_i || 1
    @per_page = params[:per_page]&.to_i || default_per_page
    @per_page = 100 if @per_page > 100 # Max limit
  end

  def default_per_page
    25
  end

  def paginate(collection)
    collection.page(@page).per(@per_page)
  end

  def pagination_meta(collection)
    {
      current_page: @page,
      per_page: @per_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end

  class_methods do
    def default_page_size(size)
      define_method(:default_per_page) { size }
    end
  end
end
```

**Usage:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  include Paginatable

  default_page_size 50

  def index
    @feedbacks = paginate(Feedback.all)
    @pagination = pagination_meta(@feedbacks)
  end
end
```

**API Response:**
```ruby
def index
  feedbacks = paginate(Feedback.all)

  render json: {
    feedbacks: feedbacks,
    pagination: pagination_meta(feedbacks)
  }
end
```
</pattern>

## Filterable Concern

<pattern name="filterable-concern">
<description>Dynamic filtering with attribute allowlist</description>

**Concern:**
```ruby
# app/controllers/concerns/filterable.rb
module Filterable
  extend ActiveSupport::Concern

  private

  def filter_collection(collection)
    filtering_params.each do |key, value|
      next if value.blank?
      collection = collection.respond_to?("filter_by_#{key}") ?
        collection.public_send("filter_by_#{key}", value) :
        collection.where(key => value)
    end
    collection
  end

  def filtering_params
    params.permit(allowed_filters)
  end

  class_methods do
    def filterable_by(*attributes)
      define_method(:allowed_filters) { attributes }
    end
  end
end
```

**Usage:**
```ruby
class FeedbacksController < ApplicationController
  include Filterable
  filterable_by :status, :recipient_email

  def index
    @feedbacks = filter_collection(Feedback.all)
  end
end
```
</pattern>

## Authorization Concern

<pattern name="authorization-concern">
<description>Permission checking with Pundit-style authorization</description>

**Concern:**
```ruby
# app/controllers/concerns/authorizable.rb
module Authorizable
  extend ActiveSupport::Concern

  included do
    rescue_from NotAuthorizedError, with: :user_not_authorized
  end

  class NotAuthorizedError < StandardError; end

  private

  def authorize!(record, action = nil)
    action ||= action_name.to_sym
    policy = policy_for(record)

    unless policy.public_send("#{action}?")
      raise NotAuthorizedError, "Not authorized to #{action} this #{record.class.name}"
    end

    record
  end

  def policy_for(record)
    policy_class = "#{record.class.name}Policy".constantize
    policy_class.new(current_user, record)
  end

  def user_not_authorized(exception)
    respond_to do |format|
      format.html do
        redirect_to root_path, alert: exception.message
      end
      format.json do
        render json: { error: exception.message }, status: :forbidden
      end
    end
  end

  class_methods do
    def authorize_resource(options = {})
      before_action(options) do
        instance_variable = "@#{controller_name.singularize}"
        record = instance_variable_get(instance_variable)
        authorize!(record) if record
      end
    end
  end
end
```

**Policy:**
```ruby
# app/policies/feedback_policy.rb
class FeedbackPolicy
  attr_reader :user, :feedback

  def initialize(user, feedback)
    @user = user
    @feedback = feedback
  end

  def show?
    user.present? && (feedback.user_id == user.id || user.admin?)
  end

  def update?
    user.present? && feedback.user_id == user.id
  end

  def destroy?
    update?
  end
end
```

**Usage:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  include Authentication
  include Authorizable

  before_action :set_feedback, only: [:show, :edit, :update, :destroy]
  authorize_resource only: [:show, :edit, :update, :destroy]

  def show
    # @feedback already authorized by before_action
  end

  def update
    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def feedback_params
    params.require(:feedback).permit(:content)
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Not using ActiveSupport::Concern</description>
<bad-example>
```ruby
module Authentication
  def self.included(base)
    base.before_action :require_authentication
  end
end
```
</bad-example>
<good-example>
```ruby
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :current_user
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Creating concerns that do too much</description>
<bad-example>
```ruby
module Everything
  extend ActiveSupport::Concern
  # 500 lines of mixed concerns...
end
```
</bad-example>
<good-example>
```ruby
class FeedbacksController < ApplicationController
  include Authentication
  include Authorizable
  include Paginatable
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not exposing methods to views with helper_method</description>
<bad-example>
```ruby
module Authentication
  private
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
# <%= current_user.name %> won't work!
```
</bad-example>
<good-example>
```ruby
module Authentication
  included do
    helper_method :current_user
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test controller concerns in isolation using dummy controllers:

```ruby
# test/controllers/concerns/authentication_test.rb
require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  class TestController < ApplicationController
    include Authentication
    def protected_action
      render plain: "Protected: #{current_user.name}"
    end
  end

  setup do
    Rails.application.routes.draw do
      get "/test/protected" => "authentication_test/test#protected_action"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "redirects unauthenticated users" do
    get "/test/protected"
    assert_redirected_to login_path
  end

  test "allows authenticated users" do
    log_in_as(users(:one))
    get "/test/protected"
    assert_response :success
  end
end
```

**Test API Response Handler:**
```ruby
# test/controllers/concerns/api/response_handler_test.rb
module Api
  class ResponseHandlerTest < ActionDispatch::IntegrationTest
    class TestController < ApiController
      include Api::ResponseHandler
      def success_action
        render_success({ message: "Success" })
      end
    end

    test "renders success response" do
      get "/api/test/success"
      assert_response :success
      json = JSON.parse(response.body)
      assert json["success"]
    end
  end
end
```
</testing>

<related-skills>
- controller-restful - RESTful controller patterns
- security-strong-parameters - Parameter filtering
- activerecord-patterns - Model scopes for filtering
- hotwire-turbo - Turbo response handling
</related-skills>

<resources>
- [Rails Guides - Active Support Concern](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)
- [Rails Guides - Controller Concerns](https://guides.rubyonrails.org/action_controller_overview.html#concerns)
- [Rails Rate Limiting (8.1+)](https://guides.rubyonrails.org/action_controller_overview.html#rate-limiting)
</resources>
