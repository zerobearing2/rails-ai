---
name: rails-ai:test-helpers
description: Use when creating reusable test utilities - provides authentication helpers, API helpers, custom assertions, and factory methods for DRY test code
---

# Test Helpers & Setup

Reusable test helper methods that simplify test writing by extracting common operations into shared modules.

<superpowers-integration>
**REQUIRED BACKGROUND:** Use superpowers:test-driven-development for TDD process
  - That skill defines RED-GREEN-REFACTOR cycle
  - This skill provides Rails-specific test helper patterns
</superpowers-integration>

<when-to-use>
- Setting up authentication in tests
- Making API requests in integration tests
- Creating test data beyond fixtures
- Testing time-dependent behavior
- Building custom assertions for domain logic
</when-to-use>

<benefits>
- **DRY** - Don't repeat yourself across test files
- **Readability** - Clearer test intent with descriptive methods
- **Maintainability** - Change once, update everywhere
- **Consistency** - Standardize common test scenarios
</benefits>

<standards>
- Organize helpers in `test/test_helpers/` directory
- Create focused helper modules (Authentication, ApiHelpers, etc.)
- Include helpers globally in test_helper.rb or per test class
- Use descriptive method names that read like English
- Keep helper methods simple and single-purpose
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
    parallelize(workers: :number_of_processors)
    fixtures :all

    # Include custom test helpers globally
    include TestHelpers::Authentication
    include TestHelpers::ApiHelpers
    include TestHelpers::AssertionHelpers
  end
end

# Optional: suppress noise in test output
ActionCable.server.config.logger = Logger.new(nil)
Rails.application.routes.default_url_options[:host] = "example.com"
ActionMailer::Base.delivery_method = :test
Rails.logger.level = Logger::WARN
```
</pattern>

## Authentication Helpers

<pattern name="authentication-helpers">
<description>Simplify user authentication in controller and integration tests</description>

**test/test_helpers/authentication.rb:**
```ruby
module TestHelpers
  module Authentication
    def sign_in_as(user)
      post sign_in_url, params: { email: user.email, password: "password" }
    end

    def sign_out
      delete sign_out_url
    end

    def signed_in?
      session[:user_id].present?
    end

    def create_and_sign_in_user(**attrs)
      user = User.create!({ name: "Test", email: "test@example.com", password: "password" }.merge(attrs))
      sign_in_as(user)
      user
    end
  end
end
```

**Usage:**
```ruby
class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "shows profile when signed in" do
    sign_in_as users(:alice)
    get profile_url
    assert_response :success
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
    def json_response
      JSON.parse(response.body)
    end

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

    def assert_json_response(expected_keys)
      actual = json_response.keys.map(&:to_sym)
      expected_keys.each { |key| assert_includes actual, key.to_sym }
    end
  end
end
```

**Usage:**
```ruby
test "returns JSON feedback list" do
  api_get api_feedbacks_url, user: users(:alice)
  assert_response :success
  assert_json_response [:feedbacks, :total, :page]
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
    def at_time(time, &block)
      travel_to(time, &block)
    end

    def yesterday(&block)
      travel_to(1.day.ago, &block)
    end

    def next_week(&block)
      travel_to(1.week.from_now, &block)
    end
  end
end
```

**Usage:**
```ruby
test "shows expired feedbacks" do
  next_week do
    assert_includes Feedback.expired, feedbacks(:expiring_soon)
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
    def assert_visible(selector, text: nil)
      text ? assert_selector(selector, text: text, visible: true) : assert_selector(selector, visible: true)
    end

    def assert_hidden(selector)
      assert_no_selector selector, visible: true
    end

    def assert_flash(type, message)
      assert_equal message, flash[type]
    end

    def assert_validation_error(model, attribute, fragment)
      refute model.valid?
      assert_match /#{fragment}/i, model.errors[attribute].join(", ")
    end

    def assert_email_sent_to(email, subject: nil)
      emails = ActionMailer::Base.deliveries.select { |e| e.to.include?(email) }
      assert emails.any?, "No email sent to #{email}"
      assert emails.any? { |e| e.subject == subject }, "No email with subject '#{subject}'" if subject
    end
  end
end
```

**Usage:**
```ruby
test "shows error for invalid feedback" do
  assert_validation_error Feedback.new(content: nil), :content, "can't be blank"
end

test "sends notification email" do
  FeedbackMailer.notification(feedbacks(:one)).deliver_now
  assert_email_sent_to "user@example.com", subject: "New Feedback"
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
    def create_user(**attrs)
      User.create!({ name: "User #{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@example.com" }.merge(attrs))
    end

    def create_feedback(**attrs)
      Feedback.create!({ content: "Test content", recipient_email: "user@example.com", status: "pending" }.merge(attrs))
    end

    def create_admin_user(**attrs)
      create_user(attrs.merge(admin: true))
    end
  end
end
```

**Usage:**
```ruby
test "admin can delete feedback" do
  sign_in_as create_admin_user
  delete feedback_url(create_feedback)
  assert_response :redirect
end
```

**Note:** Prefer fixtures for most tests. Use factories for unique attributes.
</pattern>

## File Upload Helpers

<pattern name="file-helpers">
<description>Create test files for upload testing</description>

**test/test_helpers/file_helpers.rb:**
```ruby
module TestHelpers
  module FileHelpers
    def fixture_file(filename)
      Rack::Test::UploadedFile.new(Rails.root.join("test", "fixtures", "files", filename))
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
```

**Usage:**
```ruby
test "user uploads avatar" do
  sign_in_as users(:alice)
  patch profile_url, params: { user: { avatar: create_test_image } }
  assert users(:alice).reload.avatar.attached?
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
    def post_and_follow(url, **options)
      post url, **options
      follow_redirect! if response.redirect?
    end

    def xhr_get(url, **options)
      get url, headers: { "X-Requested-With" => "XMLHttpRequest" }, **options
    end

    def xhr_post(url, **options)
      post url, headers: { "X-Requested-With" => "XMLHttpRequest" }, **options
    end
  end
end
```

**Usage:**
```ruby
test "AJAX request returns Turbo Stream" do
  xhr_post feedbacks_url, params: { feedback: { content: "Test" } }
  assert_response :success
  assert_equal "text/vnd.turbo-stream.html", response.media_type
end
```
</pattern>

## Helper Inclusion Patterns

<pattern name="helper-inclusion">
<description>Different strategies for including helpers in tests</description>

**Global inclusion (test_helper.rb):**
```ruby
class ActiveSupport::TestCase
  include TestHelpers::FactoryHelpers
  include TestHelpers::AssertionHelpers
end
```

**Type-specific inclusion:**
```ruby
class ActionDispatch::IntegrationTest
  include TestHelpers::Authentication
  include TestHelpers::RequestHelpers
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include TestHelpers::AssertionHelpers
end
```

**Per-class inclusion:**
```ruby
class MyControllerTest < ActionDispatch::IntegrationTest
  include TestHelpers::Authentication
end
```
</pattern>

## Parallel Test Configuration

<pattern name="parallel-setup">
<description>Configure parallel test execution for faster test runs</description>

**test/test_helper.rb:**
```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

  parallelize_setup do |worker|
    # Rails handles database setup automatically
  end

  parallelize_teardown do |worker|
    FileUtils.rm_rf(Rails.root.join("tmp", "test_worker_#{worker}"))
  end
end
```

**Disable for specific tests:**
```ruby
class FeedbackTest < ActiveSupport::TestCase
  parallelize(workers: 1)

  test "requires exclusive database access" do
    # ...
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
# ❌ BAD - Too much magic
def setup_complete_feedback_scenario(with_responses: true, archived: false, tags: [])
  user = create_user(admin: true)
  sign_in_as user
  feedback = create_feedback(archived: archived)
  tags.each { |tag| feedback.tags << Tag.create!(name: tag) }
  3.times { create_response(feedback: feedback) } if with_responses
  [user, feedback]
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Simple, explicit helpers
module TestHelpers
  module FactoryHelpers
    def create_user(**attrs)
      User.create!({ name: "Test" }.merge(attrs))
    end
  end

  module Authentication
    def sign_in_as(user)
      post sign_in_url, params: { email: user.email, password: "password" }
    end
  end
end

# Explicit test setup
test "admin views feedback with responses" do
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
<description>Testing implementation details in helpers</description>
<reason>Couples tests to internal implementation</reason>
<bad-example>
```ruby
# ❌ BAD - Directly manipulates session
def sign_in_as(user)
  session[:user_id] = user.id
  session[:authenticated_at] = Time.current
  cookies.signed[:remember_token] = user.remember_token
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Uses public interface
def sign_in_as(user)
  post sign_in_url, params: { email: user.email, password: "password" }
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test complex helper logic:

```ruby
# test/test_helpers/assertion_helpers_test.rb
class AssertionHelpersTest < ActiveSupport::TestCase
  include TestHelpers::AssertionHelpers

  test "assert_validation_error detects errors" do
    assert_validation_error User.new(email: nil), :email, "can't be blank"
  end

  test "assert_email_sent_to finds emails" do
    ActionMailer::Base.deliveries.clear
    UserMailer.welcome("test@example.com").deliver_now
    assert_email_sent_to "test@example.com"
  end
end
```
</testing>

<related-skills>
- superpowers:test-driven-development (TDD process)
- rails-ai:tdd-minitest (Minitest patterns)
- rails-ai:fixtures (Test data patterns)
</related-skills>

<resources>
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html#helpers-available-for-testing)
- [Minitest Docs](https://github.com/minitest/minitest)
- [ActiveSupport::TestCase API](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
</resources>
