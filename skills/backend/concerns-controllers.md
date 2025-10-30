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

      collection = if collection.respond_to?("filter_by_#{key}")
        collection.public_send("filter_by_#{key}", value)
      elsif collection.column_names.include?(key.to_s)
        collection.where(key => value)
      else
        collection
      end
    end

    collection
  end

  def filtering_params
    params.permit(allowed_filters)
  end

  def allowed_filters
    []
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
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  include Filterable

  filterable_by :status, :created_at, :recipient_email

  def index
    @feedbacks = filter_collection(Feedback.all)
  end
end
```

**Model Scopes (Optional):**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  scope :filter_by_status, ->(status) { where(status: status) }
  scope :filter_by_created_at, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :filter_by_recipient_email, ->(email) { where("recipient_email ILIKE ?", "%#{sanitize_sql_like(email)}%") }
end
```
</pattern>

## Error Tracking Concern

<pattern name="error-tracking-concern">
<description>Centralized error handling and logging</description>

**Concern:**
```ruby
# app/controllers/concerns/error_trackable.rb
module ErrorTrackable
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActionController::RoutingError, with: :handle_routing_error
  end

  private

  def handle_standard_error(exception)
    log_error(exception)
    notify_error_tracker(exception)

    if Rails.env.production?
      render_error_page(500)
    else
      raise exception
    end
  end

  def handle_routing_error(exception)
    log_error(exception)
    render_error_page(404)
  end

  def log_error(exception)
    Rails.logger.error("#{exception.class}: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))
  end

  def notify_error_tracker(exception)
    # Send to error tracking service (e.g., Sentry, Honeybadger)
    # ErrorTracker.notify(exception, context: error_context)
  end

  def error_context
    {
      user_id: current_user&.id,
      request_id: request.uuid,
      params: params.to_unsafe_h,
      url: request.url
    }
  end

  def render_error_page(status)
    render "errors/#{status}", status: status, layout: "error"
  end
end
```

**Usage:**
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include ErrorTrackable
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

## Cache Management Concern

<pattern name="cache-management-concern">
<description>HTTP caching and ETags for better performance</description>

**Concern:**
```ruby
# app/controllers/concerns/cacheable.rb
module Cacheable
  extend ActiveSupport::Concern

  private

  def cache_key_for(object)
    "#{controller_name}/#{action_name}/#{object.cache_key_with_version}"
  end

  def cache_collection_key
    "#{controller_name}/#{action_name}/#{params[:page]}/#{params[:filter]}"
  end

  def set_cache_headers(max_age: 1.hour, public: true)
    expires_in max_age, public: public
  end

  def stale_resource?(resource, etag_options: {})
    stale?(
      etag: [resource, etag_options],
      last_modified: resource.updated_at.utc,
      public: true
    )
  end

  class_methods do
    def cache_page(*actions, **options)
      after_action(**options.slice(:only, :except, :if, :unless)) do
        set_cache_headers(**options.except(:only, :except, :if, :unless))
      end
    end
  end
end
```

**Usage:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  include Cacheable

  cache_page :index, :show, max_age: 5.minutes, public: true

  def show
    @feedback = Feedback.find(params[:id])

    if stale_resource?(@feedback)
      # Render will happen automatically
    end
  end
end
```

**Benefits:**
- Conditional GET support (304 Not Modified)
- ETags for cache validation
- Last-Modified headers
- Reduced server rendering for unchanged resources
</pattern>

## Rate Limiting Concern

<pattern name="rate-limiting-concern">
<description>Protect endpoints with rate limiting (Rails 8.1+)</description>

**Concern:**
```ruby
# app/controllers/concerns/rate_limitable.rb
module RateLimitable
  extend ActiveSupport::Concern

  class_methods do
    # DSL for rate limiting
    def rate_limit_action(action, to:, within:, by: :ip_address, **options)
      rate_limit(
        to: to,
        within: within,
        by: -> { rate_limit_key(by) },
        only: action,
        **options
      )
    end

    def rate_limit_api(to: 100, within: 1.hour)
      rate_limit(
        to: to,
        within: within,
        by: -> { api_rate_limit_key },
        with: -> { render_rate_limit_error }
      )
    end
  end

  private

  def rate_limit_key(strategy)
    case strategy
    when :ip_address
      request.remote_ip
    when :user
      current_user&.id || request.remote_ip
    when :api_key
      request.headers["X-API-Key"] || request.remote_ip
    else
      strategy.call if strategy.respond_to?(:call)
    end
  end

  def api_rate_limit_key
    # Use API key if present, otherwise IP
    request.headers["X-API-Key"] || "ip:#{request.remote_ip}"
  end

  def render_rate_limit_error
    respond_to do |format|
      format.html do
        render "errors/429", status: :too_many_requests
      end
      format.json do
        render json: {
          error: "Rate limit exceeded",
          message: "Too many requests. Please try again later."
        }, status: :too_many_requests
      end
    end
  end
end
```

**Usage:**
```ruby
# app/controllers/api/feedbacks_controller.rb
class Api::FeedbacksController < Api::BaseController
  include RateLimitable

  # Rate limit entire API
  rate_limit_api to: 100, within: 1.hour

  # Additional limit for write operations
  rate_limit_action :create, to: 10, within: 1.minute, by: :user
  rate_limit_action :update, to: 10, within: 1.minute, by: :user

  def create
    feedback = Feedback.create!(feedback_params)
    render json: feedback, status: :created
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Not using ActiveSupport::Concern</description>
<reason>Loses ability to properly handle included blocks and class methods</reason>
<bad-example>
```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # This won't work as expected
  def self.included(base)
    base.before_action :require_authentication
  end
end
```
</bad-example>
<good-example>
```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :current_user
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_authentication
    redirect_to login_path unless current_user
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Creating concerns that do too much</description>
<reason>Violates single responsibility principle and makes testing harder</reason>
<bad-example>
```ruby
# app/controllers/concerns/everything.rb
module Everything
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
    before_action :authorize
    before_action :log_request
    before_action :set_pagination
  end

  # 500 lines of mixed concerns...
end
```
</bad-example>
<good-example>
```ruby
# Separate concerns by responsibility
class FeedbacksController < ApplicationController
  include Authentication
  include Authorizable
  include Paginatable
  include AuditLoggable

  # Clear which concerns provide which functionality
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not exposing methods to views with helper_method</description>
<reason>Methods needed in views won't be accessible</reason>
<bad-example>
```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end

# In view - won't work!
<%= current_user.name %>
```
</bad-example>
<good-example>
```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end
end

# In view - works!
<% if logged_in? %>
  Welcome, <%= current_user.name %>
<% end %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not namespacing API or admin concerns</description>
<reason>Can cause naming conflicts and unclear organization</reason>
<bad-example>
```ruby
# app/controllers/concerns/response_handler.rb
module ResponseHandler
  # Used by both API and web controllers - confusing!
end
```
</bad-example>
<good-example>
```ruby
# app/controllers/concerns/api/response_handler.rb
module Api::ResponseHandler
  extend ActiveSupport::Concern
  # Clearly API-specific
end

# app/controllers/concerns/admin/auditable.rb
module Admin::Auditable
  extend ActiveSupport::Concern
  # Clearly admin-specific
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
  # Create a dummy controller for testing
  class TestController < ApplicationController
    include Authentication

    def public_action
      render plain: "Public"
    end

    def protected_action
      render plain: "Protected: #{current_user.name}"
    end
  end

  setup do
    # Define routes for test controller
    Rails.application.routes.draw do
      get "/test/public" => "authentication_test/test#public_action"
      get "/test/protected" => "authentication_test/test#protected_action"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "allows access to public actions" do
    get "/test/public"
    assert_response :success
    assert_equal "Public", response.body
  end

  test "redirects unauthenticated users from protected actions" do
    get "/test/protected"
    assert_redirected_to login_path
    assert_equal "Please log in to continue", flash[:alert]
  end

  test "allows authenticated users to access protected actions" do
    user = users(:one)
    log_in_as(user)

    get "/test/protected"
    assert_response :success
    assert_includes response.body, user.name
  end
end
```

**Test API Response Handler:**
```ruby
# test/controllers/concerns/api/response_handler_test.rb
require "test_helper"

module Api
  class ResponseHandlerTest < ActionDispatch::IntegrationTest
    class TestController < ApiController
      include Api::ResponseHandler

      def success_action
        render_success({ message: "Success" })
      end

      def error_action
        render_error("Something went wrong", errors: { field: ["is invalid"] })
      end

      def not_found_action
        raise ActiveRecord::RecordNotFound, "Record not found"
      end
    end

    setup do
      Rails.application.routes.draw do
        namespace :api do
          get "/test/success" => "response_handler_test/test#success_action"
          get "/test/error" => "response_handler_test/test#error_action"
          get "/test/not_found" => "response_handler_test/test#not_found_action"
        end
      end
    end

    teardown do
      Rails.application.reload_routes!
    end

    test "renders success response" do
      get "/api/test/success"
      assert_response :success

      json = JSON.parse(response.body)
      assert json["success"]
      assert_equal "Success", json["data"]["message"]
    end

    test "renders error response" do
      get "/api/test/error"
      assert_response :unprocessable_entity

      json = JSON.parse(response.body)
      assert_not json["success"]
      assert_equal "Something went wrong", json["message"]
      assert_equal ["is invalid"], json["errors"]["field"]
    end

    test "handles record not found" do
      get "/api/test/not_found"
      assert_response :not_found

      json = JSON.parse(response.body)
      assert_not json["success"]
      assert_equal "Record not found", json["message"]
    end
  end
end
```

**Test Filterable Concern:**
```ruby
# test/controllers/concerns/filterable_test.rb
require "test_helper"

class FilterableTest < ActiveSupport::TestCase
  class TestController < ApplicationController
    include Filterable

    filterable_by :status, :email

    attr_accessor :params

    def initialize
      @params = ActionController::Parameters.new
    end
  end

  test "filters by allowed attributes" do
    controller = TestController.new
    controller.params = ActionController::Parameters.new(status: "active", email: "test@example.com")

    filters = controller.send(:filtering_params)

    assert_equal "active", filters[:status]
    assert_equal "test@example.com", filters[:email]
  end

  test "ignores non-allowed attributes" do
    controller = TestController.new
    controller.params = ActionController::Parameters.new(status: "active", admin: true)

    filters = controller.send(:filtering_params)

    assert_equal "active", filters[:status]
    assert_nil filters[:admin]
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
