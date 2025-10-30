# Test Setup and Helpers Comprehensive Patterns
# Reference: Rails Testing Guide, Minitest Documentation
# Category: TESTS - SETUP & HELPERS

#
# ============================================================================
# What are Test Helpers?
# ============================================================================
#
# Test helpers are reusable methods that simplify test writing by extracting
# common operations into shared modules. They reduce duplication and make
# tests more readable.
#
# Benefits:
# ✅ DRY - Don't Repeat Yourself across tests
# ✅ Readability - Clearer test intent
# ✅ Maintainability - Change once, update everywhere
# ✅ Reusability - Share across test files
#

#
# ============================================================================
# ✅ TEST_HELPER.RB - CENTRAL CONFIGURATION
# ============================================================================
#

# test/test_helper.rb
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Include custom test helpers
    include TestHelpers::Authentication
    include TestHelpers::ApiHelpers
  end
end

#
# ============================================================================
# ✅ AUTHENTICATION TEST HELPER
# ============================================================================
#

# test/test_helpers/authentication.rb
module TestHelpers
  module Authentication
    # Sign in a user for controller/integration tests
    def sign_in_as(user)
      post sign_in_url, params: {
        email: user.email,
        password: "password"  # Assuming test fixtures use this
      }
    end

    # Sign out current user
    def sign_out
      delete sign_out_url
    end

    # Check if user is signed in
    def signed_in?
      session[:user_id].present?
    end

    # Create and sign in a user
    def create_and_sign_in_user(attributes = {})
      user = User.create!({
        name: "Test User",
        email: "test@example.com",
        password: "password"
      }.merge(attributes))

      sign_in_as(user)
      user
    end
  end
end

# Usage in tests:
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "shows profile when signed in" do
    sign_in_as users(:alice)

    get profile_url
    assert_response :success
  end

  test "redirects to sign in when not authenticated" do
    get profile_url
    assert_redirected_to sign_in_url
  end
end

#
# ============================================================================
# ✅ API TEST HELPERS
# ============================================================================
#

# test/test_helpers/api_helpers.rb
module TestHelpers
  module ApiHelpers
    # Parse JSON response
    def json_response
      JSON.parse(response.body)
    end

    # Make authenticated API request
    def api_get(url, user: nil, **options)
      headers = options[:headers] || {}
      headers["Authorization"] = "Bearer #{user.api_token}" if user

      get url, headers: headers, **options
    end

    def api_post(url, params: {}, user: nil)
      headers = { "Content-Type" => "application/json" }
      headers["Authorization"] = "Bearer #{user.api_token}" if user

      post url, params: params.to_json, headers: headers
    end

    # Assert JSON response structure
    def assert_json_response(expected_keys)
      actual_keys = json_response.keys.map(&:to_sym)
      expected_keys.each do |key|
        assert_includes actual_keys, key.to_sym,
          "Expected JSON to include key: #{key}"
      end
    end
  end
end

# Usage:
class Api::FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "returns JSON feedback list" do
    api_get api_feedbacks_url, user: users(:alice)

    assert_response :success
    assert_json_response [:feedbacks, :total, :page]
    assert_equal 10, json_response["feedbacks"].length
  end
end

#
# ============================================================================
# ✅ TIME TRAVEL HELPERS
# ============================================================================
#

# test/test_helpers/time_helpers.rb
module TestHelpers
  module TimeHelpers
    # Freeze time to specific moment
    def at_time(time, &block)
      travel_to(time, &block)
    end

    # Travel to yesterday
    def yesterday(&block)
      travel_to(1.day.ago, &block)
    end

    # Travel to next week
    def next_week(&block)
      travel_to(1.week.from_now, &block)
    end

    # Freeze time during test
    def freeze_time
      travel_to(Time.current)
    end

    # Unfreeze time
    def unfreeze_time
      travel_back
    end
  end
end

#
# ============================================================================
# ✅ ASSERTION HELPERS
# ============================================================================
#

# test/test_helpers/assertion_helpers.rb
module TestHelpers
  module AssertionHelpers
    # Assert element is visible
    def assert_visible(selector, text: nil)
      if text
        assert_selector selector, text: text, visible: true
      else
        assert_selector selector, visible: true
      end
    end

    # Assert element is hidden
    def assert_hidden(selector)
      assert_no_selector selector, visible: true
    end

    # Assert flash message
    def assert_flash(type, message)
      assert_equal message, flash[type]
    end

    # Assert validation error
    def assert_validation_error(model, attribute, message_fragment)
      refute model.valid?
      error_messages = model.errors[attribute].join(", ")
      assert_match /#{message_fragment}/i, error_messages
    end

    # Assert email sent to
    def assert_email_sent_to(email, subject: nil)
      emails = ActionMailer::Base.deliveries
      matching = emails.select { |e| e.to.include?(email) }

      assert matching.any?, "No email sent to #{email}"

      if subject
        assert matching.any? { |e| e.subject == subject },
          "No email with subject '#{subject}' sent to #{email}"
      end
    end
  end
end

#
# ============================================================================
# ✅ FACTORY HELPERS (LIGHTWEIGHT)
# ============================================================================
#

# test/test_helpers/factory_helpers.rb
module TestHelpers
  module FactoryHelpers
    def create_user(**attributes)
      User.create!({
        name: "Test User #{SecureRandom.hex(4)}",
        email: "user-#{SecureRandom.hex(4)}@example.com"
      }.merge(attributes))
    end

    def create_feedback(**attributes)
      Feedback.create!({
        content: "Test feedback content",
        recipient_email: "recipient@example.com",
        status: "pending"
      }.merge(attributes))
    end

    def create_admin_user(**attributes)
      create_user(attributes.merge(admin: true))
    end
  end
end

#
# ============================================================================
# ✅ DATABASE HELPERS
# ============================================================================
#

# test/test_helpers/database_helpers.rb
module TestHelpers
  module DatabaseHelpers
    # Disable transactional fixtures for specific test
    def disable_transactions
      self.use_transactional_tests = false
    end

    # Truncate specific tables
    def truncate_tables(*table_names)
      table_names.each do |table|
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table}")
      end
    end

    # Count records matching criteria
    def count_where(model, **conditions)
      model.where(conditions).count
    end
  end
end

#
# ============================================================================
# ✅ FILE UPLOAD HELPERS
# ============================================================================
#

# test/test_helpers/file_helpers.rb
module TestHelpers
  module FileHelpers
    def fixture_file(filename)
      file_path = Rails.root.join("test", "fixtures", "files", filename)
      Rack::Test::UploadedFile.new(file_path)
    end

    def create_test_image(filename: "test.jpg")
      file = Tempfile.new([filename, ".jpg"])
      file.write("fake image data")
      file.rewind

      Rack::Test::UploadedFile.new(file.path, "image/jpeg")
    end

    def create_test_pdf(filename: "test.pdf")
      file = Tempfile.new([filename, ".pdf"])
      file.write("%PDF-1.4\nfake pdf")
      file.rewind

      Rack::Test::UploadedFile.new(file.path, "application/pdf")
    end
  end
end

#
# ============================================================================
# ✅ REQUEST HELPERS
# ============================================================================
#

# test/test_helpers/request_helpers.rb
module TestHelpers
  module RequestHelpers
    # Follow redirect and return response
    def follow_and_return
      follow_redirect!
      response
    end

    # POST and follow redirect
    def post_and_follow(url, **options)
      post url, **options
      follow_redirect! if response.redirect?
    end

    # Simulate AJAX request
    def xhr_get(url, **options)
      get url, headers: { "X-Requested-With" => "XMLHttpRequest" }, **options
    end

    def xhr_post(url, **options)
      post url, headers: { "X-Requested-With" => "XMLHttpRequest" }, **options
    end
  end
end

#
# ============================================================================
# ✅ EAGER LOADING ALL HELPERS
# ============================================================================
#

# In test/test_helper.rb, automatically load all helpers:
# Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each do |file|
#   require file
# end

#
# ============================================================================
# ✅ HELPER INCLUSION PATTERNS
# ============================================================================
#

# Option 1: Include in specific test classes
class MyControllerTest < ActionDispatch::IntegrationTest
  include TestHelpers::Authentication
  include TestHelpers::ApiHelpers
end

# Option 2: Include globally in test_helper.rb
class ActiveSupport::TestCase
  include TestHelpers::FactoryHelpers
  include TestHelpers::AssertionHelpers
end

# Option 3: Include in parent classes
class ActionDispatch::IntegrationTest
  include TestHelpers::Authentication
  include TestHelpers::RequestHelpers
end

#
# ============================================================================
# ✅ PARALLEL TEST SETUP
# ============================================================================
#

# test/test_helper.rb
class ActiveSupport::TestCase
  # Setup code run before parallel processes fork
  parallelize_setup do |worker|
    # Setup databases for parallel workers
    # Usually Rails handles this automatically
  end

  # Teardown code run after parallel processes complete
  parallelize_teardown do |worker|
    # Cleanup after parallel workers
    FileUtils.rm_rf(Rails.root.join("tmp", "test_worker_#{worker}"))
  end

  parallelize(workers: :number_of_processors)
end

#
# ============================================================================
# ✅ TEST CONFIGURATION
# ============================================================================
#

# test/test_helper.rb additional config:

# Suppress action cable warnings in tests
ActionCable.server.config.logger = Logger.new(nil)

# Set default URL options for tests
Rails.application.routes.default_url_options[:host] = "example.com"

# Configure ActionMailer for tests
ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.deliveries.clear

# Disable Rails logger output during tests
Rails.logger.level = Logger::WARN

#
# ============================================================================
# ✅ CUSTOM MINITEST REPORTERS (OPTIONAL)
# ============================================================================
#

# Gemfile:
# gem "minitest-reporters", group: :test

# test/test_helper.rb:
# require "minitest/reporters"
# Minitest::Reporters.use! [
#   Minitest::Reporters::ProgressReporter.new,
#   Minitest::Reporters::JUnitReporter.new
# ]

#
# ============================================================================
# RULE: Organize helpers in test/test_helpers/ directory
# INCLUDE: Include helpers globally in test_helper.rb or per-class
# DRY: Extract repeated test logic into helpers
# NAMING: Use descriptive helper method names
# DOCUMENTATION: Comment complex helpers
# TESTING: Test your test helpers if they contain logic
# ============================================================================
#
