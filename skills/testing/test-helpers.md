---
name: test-helpers
domain: testing
dependencies: [tdd-minitest]
version: 1.0
rails_version: 8.1+
---

# Test Helpers & Setup

Reusable test helper methods that simplify test writing by extracting common operations into shared modules. Reduce duplication and improve test readability.

<when-to-use>
- Setting up authentication in tests
- Making API requests in integration tests
- Creating test data beyond fixtures
- Testing time-dependent behavior
- Building custom assertions for domain logic
- Sharing test utilities across test files
- Configuring parallel test execution
</when-to-use>

<benefits>
- **DRY** - Don't repeat yourself across test files
- **Readability** - Clearer test intent with descriptive helper methods
- **Maintainability** - Change once, update everywhere
- **Reusability** - Share common test patterns across your test suite
- **Consistency** - Standardize how tests handle common scenarios
- **Speed** - Streamlined test setup and teardown
</benefits>

<standards>
- Organize helpers in `test/test_helpers/` directory
- Create focused helper modules (Authentication, ApiHelpers, etc.)
- Include helpers globally in test_helper.rb or per test class
- Use descriptive method names that read like English
- Document complex helper methods with comments
- Keep helper methods simple and single-purpose
- Test your test helpers if they contain complex logic
- Use parallel test execution for faster test runs
</standards>

## Central Test Configuration

<pattern name="test-helper-setup">
<description>Configure test environment and include helper modules</description>

**test/test_helper.rb:**
```ruby
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests
    fixtures :all

    # Include custom test helpers globally
    include TestHelpers::Authentication
    include TestHelpers::ApiHelpers
    include TestHelpers::AssertionHelpers
  end
end

# Suppress ActionCable warnings in tests
ActionCable.server.config.logger = Logger.new(nil)

# Set default URL options for tests
Rails.application.routes.default_url_options[:host] = "example.com"

# Configure ActionMailer for tests
ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.deliveries.clear

# Disable Rails logger output during tests
Rails.logger.level = Logger::WARN
```

**Benefits:**
- Single point of configuration for all tests
- Automatic parallel execution for speed
- Clean test output without noise
- Consistent test environment
</pattern>

## Authentication Helpers

<pattern name="authentication-helpers">
<description>Simplify user authentication in controller and integration tests</description>

**test/test_helpers/authentication.rb:**
```ruby
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

    # Create and sign in a user in one step
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
```

**Usage:**
```ruby
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
```
</pattern>

## API Test Helpers

<pattern name="api-helpers">
<description>Streamline API testing with JSON parsing and authenticated requests</description>

**test/test_helpers/api_helpers.rb:**
```ruby
module TestHelpers
  module ApiHelpers
    # Parse JSON response
    def json_response
      JSON.parse(response.body)
    end

    # Make authenticated GET request
    def api_get(url, user: nil, **options)
      headers = options[:headers] || {}
      headers["Authorization"] = "Bearer #{user.api_token}" if user

      get url, headers: headers, **options
    end

    # Make authenticated POST request
    def api_post(url, params: {}, user: nil)
      headers = { "Content-Type" => "application/json" }
      headers["Authorization"] = "Bearer #{user.api_token}" if user

      post url, params: params.to_json, headers: headers
    end

    # Assert JSON response contains expected keys
    def assert_json_response(expected_keys)
      actual_keys = json_response.keys.map(&:to_sym)
      expected_keys.each do |key|
        assert_includes actual_keys, key.to_sym,
          "Expected JSON to include key: #{key}"
      end
    end
  end
end
```

**Usage:**
```ruby
class Api::FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "returns JSON feedback list" do
    api_get api_feedbacks_url, user: users(:alice)

    assert_response :success
    assert_json_response [:feedbacks, :total, :page]
    assert_equal 10, json_response["feedbacks"].length
  end
end
```
</pattern>

## Time Travel Helpers

<pattern name="time-helpers">
<description>Test time-dependent behavior with readable helper methods</description>

**test/test_helpers/time_helpers.rb:**
```ruby
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
```

**Usage:**
```ruby
test "shows expired feedbacks" do
  feedback = feedbacks(:expiring_soon)

  next_week do
    expired = Feedback.expired
    assert_includes expired, feedback
  end
end
```
</pattern>

## Custom Assertion Helpers

<pattern name="assertion-helpers">
<description>Domain-specific assertions for clearer test intent</description>

**test/test_helpers/assertion_helpers.rb:**
```ruby
module TestHelpers
  module AssertionHelpers
    # Assert element is visible in system tests
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

    # Assert validation error on model
    def assert_validation_error(model, attribute, message_fragment)
      refute model.valid?
      error_messages = model.errors[attribute].join(", ")
      assert_match /#{message_fragment}/i, error_messages
    end

    # Assert email sent to recipient
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
```

**Usage:**
```ruby
test "shows error for invalid feedback" do
  feedback = Feedback.new(content: nil)

  assert_validation_error feedback, :content, "can't be blank"
end

test "sends notification email" do
  feedback = feedbacks(:one)
  FeedbackMailer.notification(feedback).deliver_now

  assert_email_sent_to feedback.recipient_email, subject: "New Feedback"
end
```
</pattern>

## Factory Helpers

<pattern name="factory-helpers">
<description>Lightweight factory methods for creating test data</description>

**test/test_helpers/factory_helpers.rb:**
```ruby
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
```

**Usage:**
```ruby
test "admin can delete any feedback" do
  admin = create_admin_user
  feedback = create_feedback

  sign_in_as admin
  delete feedback_url(feedback)

  assert_response :redirect
end
```

**Note:** Prefer fixtures over factory methods for most tests. Use factories when you need unique attributes or when fixtures become unwieldy.
</pattern>

## File Upload Helpers

<pattern name="file-helpers">
<description>Create test files for upload testing</description>

**test/test_helpers/file_helpers.rb:**
```ruby
module TestHelpers
  module FileHelpers
    # Load fixture file
    def fixture_file(filename)
      file_path = Rails.root.join("test", "fixtures", "files", filename)
      Rack::Test::UploadedFile.new(file_path)
    end

    # Create test image
    def create_test_image(filename: "test.jpg")
      file = Tempfile.new([filename, ".jpg"])
      file.write("fake image data")
      file.rewind

      Rack::Test::UploadedFile.new(file.path, "image/jpeg")
    end

    # Create test PDF
    def create_test_pdf(filename: "test.pdf")
      file = Tempfile.new([filename, ".pdf"])
      file.write("%PDF-1.4\nfake pdf")
      file.rewind

      Rack::Test::UploadedFile.new(file.path, "application/pdf")
    end
  end
end
```

**Usage:**
```ruby
test "user can upload avatar" do
  user = users(:alice)
  image = create_test_image

  sign_in_as user
  patch profile_url, params: { user: { avatar: image } }

  assert user.reload.avatar.attached?
end
```
</pattern>

## Request Helpers

<pattern name="request-helpers">
<description>Simplify common request patterns in integration tests</description>

**test/test_helpers/request_helpers.rb:**
```ruby
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

    # Simulate AJAX GET request
    def xhr_get(url, **options)
      get url, headers: { "X-Requested-With" => "XMLHttpRequest" }, **options
    end

    # Simulate AJAX POST request
    def xhr_post(url, **options)
      post url, headers: { "X-Requested-With" => "XMLHttpRequest" }, **options
    end
  end
end
```

**Usage:**
```ruby
test "creating feedback via AJAX returns Turbo Stream" do
  xhr_post feedbacks_url, params: {
    feedback: { content: "Test" }
  }

  assert_response :success
  assert_equal "text/vnd.turbo-stream.html", response.media_type
end
```
</pattern>

## Helper Inclusion Patterns

<pattern name="helper-inclusion">
<description>Different strategies for including helpers in tests</description>

**Option 1: Include in specific test classes**
```ruby
class MyControllerTest < ActionDispatch::IntegrationTest
  include TestHelpers::Authentication
  include TestHelpers::ApiHelpers
end
```

**Option 2: Include globally in test_helper.rb**
```ruby
# test/test_helper.rb
class ActiveSupport::TestCase
  include TestHelpers::FactoryHelpers
  include TestHelpers::AssertionHelpers
end
```

**Option 3: Include in parent test classes**
```ruby
# test/test_helper.rb
class ActionDispatch::IntegrationTest
  include TestHelpers::Authentication
  include TestHelpers::RequestHelpers
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include TestHelpers::AssertionHelpers
end
```

**Best Practice:** Use option 3 for type-specific helpers (API helpers in integration tests, assertion helpers in system tests). Use option 2 for universal helpers.
</pattern>

## Parallel Test Configuration

<pattern name="parallel-setup">
<description>Configure parallel test execution for faster test runs</description>

**test/test_helper.rb:**
```ruby
class ActiveSupport::TestCase
  # Setup code run before parallel processes fork
  parallelize_setup do |worker|
    # Rails automatically handles database setup
    # Add custom setup here if needed
  end

  # Teardown code run after parallel processes complete
  parallelize_teardown do |worker|
    # Cleanup after parallel workers
    FileUtils.rm_rf(Rails.root.join("tmp", "test_worker_#{worker}"))
  end

  # Enable parallel execution
  parallelize(workers: :number_of_processors)
end
```

**Disable parallelization for specific tests:**
```ruby
class FeedbackTest < ActiveSupport::TestCase
  # Disable for tests that can't run in parallel
  parallelize(workers: 1)

  test "something that requires exclusive database access" do
    # Test code
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Creating overly complex helper methods</description>
<reason>Makes tests harder to understand and debug</reason>
<bad-example>
```ruby
# test/test_helpers/complex_helpers.rb
module TestHelpers
  module ComplexHelpers
    # ❌ BAD - Too much magic, unclear what this does
    def setup_complete_feedback_scenario(with_responses: true, archived: false, tags: [])
      user = create_user(admin: true)
      sign_in_as user
      feedback = create_feedback(archived: archived)
      tags.each { |tag| feedback.tags << Tag.create!(name: tag) }
      if with_responses
        3.times { create_response(feedback: feedback) }
      end
      [user, feedback]
    end
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Simple, focused helper methods
module TestHelpers
  module FactoryHelpers
    def create_user(**attributes)
      User.create!({ name: "Test User" }.merge(attributes))
    end

    def create_feedback(**attributes)
      Feedback.create!({ content: "Test" }.merge(attributes))
    end
  end

  module Authentication
    def sign_in_as(user)
      post sign_in_url, params: { email: user.email, password: "password" }
    end
  end
end

# In test, be explicit about setup
test "admin can view feedback with responses" do
  admin = create_user(admin: true)
  feedback = create_feedback
  3.times { create_response(feedback: feedback) }

  sign_in_as admin
  get feedback_url(feedback)

  assert_response :success
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not organizing helpers into focused modules</description>
<reason>Creates one giant helper file that's hard to maintain</reason>
<bad-example>
```ruby
# ❌ BAD - Everything in one module
module TestHelpers
  def sign_in_as(user)
    # ...
  end

  def json_response
    # ...
  end

  def create_user
    # ...
  end

  def assert_visible(selector)
    # ...
  end

  # 50 more methods...
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Organized by concern
module TestHelpers
  module Authentication
    def sign_in_as(user)
      # ...
    end
  end

  module ApiHelpers
    def json_response
      # ...
    end
  end

  module FactoryHelpers
    def create_user
      # ...
    end
  end

  module AssertionHelpers
    def assert_visible(selector)
      # ...
    end
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Testing implementation details in helpers</description>
<reason>Couples tests to internal implementation</reason>
<bad-example>
```ruby
# ❌ BAD - Helper knows too much about implementation
module TestHelpers
  module Authentication
    def sign_in_as(user)
      session[:user_id] = user.id
      session[:authenticated_at] = Time.current
      cookies.signed[:remember_token] = user.remember_token
    end
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Helper uses public interface
module TestHelpers
  module Authentication
    def sign_in_as(user)
      # Use the same path users would take
      post sign_in_url, params: {
        email: user.email,
        password: "password"
      }
    end
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test your test helpers if they contain complex logic:

```ruby
# test/test_helpers/assertion_helpers_test.rb
require "test_helper"

class AssertionHelpersTest < ActiveSupport::TestCase
  include TestHelpers::AssertionHelpers

  test "assert_validation_error detects missing attribute errors" do
    user = User.new(email: nil)

    assert_validation_error user, :email, "can't be blank"
  end

  test "assert_email_sent_to finds matching emails" do
    ActionMailer::Base.deliveries.clear

    UserMailer.welcome("test@example.com").deliver_now

    assert_email_sent_to "test@example.com"
  end
end
```

**Run helper tests:**
```bash
rails test test/test_helpers/
```
</testing>

<related-skills>
- tdd-minitest - Core testing patterns
- fixtures-test-data - Using fixtures for test data
- minitest-mocking - Stubbing and mocking in tests
- system-testing - Full-stack feature testing
</related-skills>

<resources>
- [Rails Testing Guide - Helpers](https://guides.rubyonrails.org/testing.html#helpers-available-for-testing)
- [Minitest Documentation](https://github.com/minitest/minitest)
- [Rails API: ActiveSupport::TestCase](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
</resources>
