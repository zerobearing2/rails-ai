# Namespaced Controller Concern Pattern
# Reference: Rails Guides - ActiveSupport::Concern
# Category: CONTROLLERS - CONCERNS

# ============================================================================
# What Are Namespaced Controller Concerns?
# ============================================================================

# Controller concerns extract shared behavior across controllers.
# Namespacing prevents conflicts and provides better organization.

# Common uses:
# ✅ Authentication/authorization
# ✅ Error handling
# ✅ Response formatting
# ✅ Rate limiting
# ✅ Pagination
# ✅ Filtering

# ============================================================================
# ✅ RECOMMENDED: Authentication Concern
# ============================================================================

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

# Usage in controller
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  include Authentication

  # Skip auth for public actions
  skip_authentication_for :new, :create

  def index
    @feedbacks = current_user.feedbacks
  end
end

# ============================================================================
# ✅ EXAMPLE: API Response Formatting Concern
# ============================================================================

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

# Usage
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

# ============================================================================
# ✅ EXAMPLE: Pagination Concern
# ============================================================================

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

# Usage
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  include Paginatable

  default_page_size 50

  def index
    @feedbacks = paginate(Feedback.all)
    @pagination = pagination_meta(@feedbacks)
  end
end

# ============================================================================
# ✅ EXAMPLE: Filterable Concern
# ============================================================================

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

# Usage
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  include Filterable

  filterable_by :status, :created_at, :recipient_email

  def index
    @feedbacks = filter_collection(Feedback.all)
  end
end

# ============================================================================
# ✅ EXAMPLE: Error Tracking Concern
# ============================================================================

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

# ============================================================================
# ✅ EXAMPLE: Cache Management Concern
# ============================================================================

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

# Usage
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

# ============================================================================
# ✅ TESTING CONTROLLER CONCERNS
# ============================================================================

# test/controllers/concerns/authentication_test.rb
require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
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

# ============================================================================
# File Organization
# ============================================================================

# app/controllers/concerns/
# ├── authentication.rb         # Shared authentication
# ├── authorization.rb          # Permission checking
# ├── paginatable.rb           # Pagination
# ├── filterable.rb            # Query filtering
# ├── cacheable.rb             # Cache management
# ├── error_trackable.rb       # Error handling
# ├── api/
# │   ├── response_handler.rb  # API responses
# │   ├── versioning.rb        # API versioning
# │   └── rate_limitable.rb    # API rate limiting
# └── admin/
#     ├── auditable.rb         # Admin audit logging
#     └── exportable.rb        # Data exports

# ============================================================================
# RULE: Extract shared controller behavior into concerns
# NAMESPACE: Use namespaces for API and admin-specific concerns
# TEST: Test concerns in isolation with dummy controllers
# ORGANIZE: Group related concerns in subdirectories
# HELPER: Use helper_method for methods needed in views
# ============================================================================
