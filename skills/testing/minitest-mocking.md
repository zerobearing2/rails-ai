---
name: minitest-mocking
domain: testing
dependencies: []
version: 1.0
rails_version: 8.1+

# Team rules enforcement
enforces_team_rule:
  - rule_id: 18
    rule_name: "WebMock: No Live HTTP in Tests"
    severity: critical
    enforcement_action: REJECT
---

# Minitest Mocking and Stubbing

Isolate code under test by replacing dependencies with controlled test doubles. Use mocking for external services, stubbing for method replacement, and WebMock for HTTP requests.

<when-to-use>
- External API calls (REQUIRED per TEAM_RULES.md Rule #18)
- Third-party service integrations
- Time-dependent code (when travel_to is insufficient)
- Complex dependency chains
- Error condition simulation
- Testing interactions without side effects
</when-to-use>

<benefits>
- **Isolation** - Test code independently from dependencies
- **Speed** - Avoid slow external services and network calls
- **Control** - Simulate hard-to-reproduce scenarios (errors, edge cases)
- **Determinism** - Tests are predictable and repeatable
- **Safety** - Prevent unintended side effects (emails, payments)
</benefits>

<standards>
- ALWAYS use WebMock for HTTP requests (per TEAM_RULES.md Rule #18)
- Prefer `stub` for method replacement with return values
- Use `Minitest::Mock` for verifying method calls and arguments
- Call `mock.verify` to ensure expectations are met
- Prefer real objects over mocks when possible
- Use dependency injection for better testability
- Don't mock your own code - test it for real
- Prefer `travel_to` over stubbing time
- Keep mocking minimal - over-mocking makes tests brittle
</standards>

## Basic Stubbing

<pattern name="stub-instance-method">
<description>Replace a method temporarily with predetermined return value</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "stubs instance method" do
    user = users(:alice)

    # Temporarily replace the method
    user.stub :name, "Stubbed Name" do
      assert_equal "Stubbed Name", user.name
    end

    # Original method restored after block
    assert_equal "Alice Johnson", user.name
  end

  # Stub with block for dynamic return value
  test "stubs with block" do
    feedback = feedbacks(:one)

    feedback.stub :content, -> { "Dynamic: #{Time.current}" } do
      assert_match /^Dynamic:/, feedback.content
    end
  end
end
```

**Key Points:**
- Stub is scoped to the block
- Original method restored automatically
- Use lambda for dynamic return values
</pattern>

<pattern name="stub-class-method">
<description>Stub class methods and singleton methods</description>

```ruby
class StubbingClassMethodsTest < ActiveSupport::TestCase
  test "stubs class method" do
    User.stub :count, 999 do
      assert_equal 999, User.count
    end

    # Real count after block
    refute_equal 999, User.count
  end

  test "stubs module singleton method" do
    module EmailValidator
      def self.valid?(email)
        email.include?("@")
      end
    end

    EmailValidator.stub :valid?, true do
      assert EmailValidator.valid?("invalid-email")
    end
  end

  test "stubs multiple methods" do
    feedback = feedbacks(:one)

    feedback.stub :content, "Stubbed content" do
      feedback.stub :status, "stubbed_status" do
        assert_equal "Stubbed content", feedback.content
        assert_equal "stubbed_status", feedback.status
      end
    end
  end
end
```
</pattern>

## Minitest::Mock

<pattern name="basic-mocking">
<description>Create mock objects to verify method calls and arguments</description>

```ruby
class MinitestMockTest < ActiveSupport::TestCase
  test "creates mock object" do
    mock = Minitest::Mock.new

    # Set expectation: method, return_value, [arguments]
    mock.expect :call, "mocked result", ["arg1", "arg2"]

    # Call the method
    result = mock.call("arg1", "arg2")

    assert_equal "mocked result", result

    # Verify all expectations were met (REQUIRED)
    mock.verify
  end

  test "mock with multiple expectations" do
    mock = Minitest::Mock.new

    mock.expect :save, true
    mock.expect :valid?, true
    mock.expect :persisted?, true

    assert mock.save
    assert mock.valid?
    assert mock.persisted?

    mock.verify
  end

  test "expects method called multiple times" do
    mock = Minitest::Mock.new

    # Expect :increment to be called 3 times
    mock.expect :increment, nil
    mock.expect :increment, nil
    mock.expect :increment, nil

    3.times { mock.increment }

    mock.verify
  end

  test "uses assert_mock for auto-verification" do
    mock = Minitest::Mock.new
    mock.expect :call, "result"

    assert_mock mock do
      mock.call
    end  # Automatically calls verify at end
  end
end
```

**Important:** Always call `mock.verify` or use `assert_mock` to ensure expectations were met.
</pattern>

<pattern name="mock-activerecord">
<description>Mock ActiveRecord queries and methods</description>

```ruby
class ActiveRecordMockingTest < ActiveSupport::TestCase
  test "mocks ActiveRecord find" do
    mock_user = Minitest::Mock.new
    mock_user.expect :name, "Mocked User"
    mock_user.expect :email, "mocked@example.com"

    User.stub :find, mock_user do
      user = User.find(123)
      assert_equal "Mocked User", user.name
      assert_equal "mocked@example.com", user.email
    end

    mock_user.verify
  end

  test "stubs scope" do
    mock_relation = [feedbacks(:one), feedbacks(:two)]

    Feedback.stub :pending, mock_relation do
      pending = Feedback.pending
      assert_equal 2, pending.size
    end
  end

  test "mocks save to prevent database write" do
    feedback = Feedback.new(
      content: "Test",
      recipient_email: "test@example.com"
    )

    feedback.stub :save, true do
      assert feedback.save
      refute feedback.persisted?  # Not actually saved
    end
  end

  test "stubs association" do
    user = users(:alice)
    mock_feedbacks = [Minitest::Mock.new, Minitest::Mock.new]

    user.stub :feedbacks, mock_feedbacks do
      assert_equal 2, user.feedbacks.size
    end
  end
end
```

**Note:** Prefer testing with real ActiveRecord objects when possible. Only mock when necessary for isolation.
</pattern>

## External Dependencies

<pattern name="stub-external-services">
<description>Stub external API clients and third-party services</description>

```ruby
class ExternalDependenciesTest < ActiveSupport::TestCase
  test "stubs external API client" do
    feedback = feedbacks(:one)

    # Assume we have an AIService class
    AIService.stub :improve_content, "Improved content" do
      result = AIService.improve_content(feedback.content)
      assert_equal "Improved content", result
    end
  end

  test "simulates external service error" do
    AIService.stub :improve_content, -> (*) { raise StandardError.new("API Error") } do
      assert_raises(StandardError) do
        AIService.improve_content("test")
      end
    end
  end

  test "simulates timeout" do
    slow_service = -> (*) { raise Net::OpenTimeout.new("Request timeout") }

    AIService.stub :call, slow_service do
      assert_raises(Net::OpenTimeout) do
        AIService.call("test")
      end
    end
  end
end
```
</pattern>

<pattern name="webmock-http-stubs">
<description>Stub HTTP requests with WebMock (REQUIRED per TEAM_RULES.md Rule #18)</description>

**Setup:**
```ruby
# Gemfile
gem "webmock", group: :test

# test/test_helper.rb
require "webmock/minitest"
```

**Basic HTTP Stubs:**
```ruby
class WebMockTest < ActiveSupport::TestCase
  test "stubs HTTP GET request" do
    stub_request(:get, "https://api.example.com/feedback")
      .to_return(
        status: 200,
        body: '{"status":"success"}',
        headers: { "Content-Type" => "application/json" }
      )

    response = Net::HTTP.get(URI("https://api.example.com/feedback"))

    assert_equal '{"status":"success"}', response
  end

  test "stubs POST with body matching" do
    stub_request(:post, "https://api.example.com/ai/improve")
      .with(
        body: hash_including(content: "Test feedback"),
        headers: { "Content-Type" => "application/json" }
      )
      .to_return(
        status: 200,
        body: '{"improved":"Enhanced feedback"}'
      )

    # Request with matching body will use this stub
  end

  test "stubs with response sequence" do
    stub_request(:get, "https://api.example.com/status")
      .to_return(
        { status: 503, body: "Service Unavailable" },
        { status: 503, body: "Service Unavailable" },
        { status: 200, body: "OK" }
      )

    # First two calls return 503, third returns 200
    # Good for testing retry logic
  end

  test "simulates timeout" do
    stub_request(:get, "https://api.example.com/slow")
      .to_timeout

    assert_raises(Net::OpenTimeout) do
      Net::HTTP.get(URI("https://api.example.com/slow"))
    end
  end

  test "stubs with dynamic response block" do
    stub_request(:post, "https://api.example.com/echo")
      .to_return do |request|
        {
          status: 200,
          body: request.body,
          headers: { "Content-Type" => "application/json" }
        }
      end

    # Response echoes request body
  end
end
```

**Verify Requests:**
```ruby
test "verifies HTTP request was made" do
  stub_request(:get, "https://api.example.com/check")
    .to_return(status: 200)

  Net::HTTP.get(URI("https://api.example.com/check"))

  # Assert request was made with specific parameters
  assert_requested :get, "https://api.example.com/check", times: 1

  # More specific verification
  assert_requested :post, "https://api.example.com/data",
    times: 1,
    headers: { "Content-Type" => "application/json" }
end
```
</pattern>

## Time Stubbing

<pattern name="stub-time">
<description>Stub time-dependent code (prefer travel_to when possible)</description>

```ruby
class TimeStubbingTest < ActiveSupport::TestCase
  # ✅ PREFERRED: Use travel_to
  test "uses travel_to for time manipulation" do
    frozen_time = Time.zone.local(2024, 10, 29, 12, 0, 0)

    travel_to frozen_time do
      assert_equal frozen_time, Time.current
      assert_equal frozen_time.to_date, Date.today

      # All time-related methods are frozen
    end
  end

  # Alternative: Stub when travel_to insufficient
  test "stubs Time.current" do
    frozen_time = Time.zone.local(2024, 10, 29, 12, 0, 0)

    Time.stub :current, frozen_time do
      assert_equal frozen_time, Time.current
    end
  end

  test "stubs Date.today" do
    frozen_date = Date.new(2024, 10, 29)

    Date.stub :today, frozen_date do
      assert_equal frozen_date, Date.today
    end
  end
end
```

**Recommendation:** Always prefer `travel_to` over stubbing time. It's more comprehensive and handles edge cases better.
</pattern>

## Mocking Mailers and Jobs

<pattern name="mock-mailers">
<description>Mock mailer delivery for testing</description>

```ruby
class MailerMockingTest < ActiveSupport::TestCase
  # ❌ NOT RECOMMENDED: Mock mailer delivery
  test "mocks mailer without sending" do
    feedback = feedbacks(:one)
    mock_mailer = Minitest::Mock.new
    mock_delivery = Minitest::Mock.new

    mock_mailer.expect :notification, mock_delivery, [feedback]
    mock_delivery.expect :deliver_later, true

    FeedbackMailer.stub :notification, mock_mailer do
      mailer = FeedbackMailer.notification(feedback)
      assert mailer.deliver_later
    end

    mock_mailer.verify
    mock_delivery.verify
  end

  # ✅ PREFERRED: Use assert_enqueued_with
  test "uses assert_enqueued_with instead of mocking" do
    feedback = feedbacks(:one)

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      FeedbackMailer.notification(feedback).deliver_later
    end
  end
end
```
</pattern>

<pattern name="mock-jobs">
<description>Mock background job execution</description>

```ruby
class JobMockingTest < ActiveSupport::TestCase
  # ❌ NOT RECOMMENDED: Mock job perform
  test "mocks job perform" do
    feedback = feedbacks(:one)

    SendFeedbackJob.stub :perform_later, true do
      result = SendFeedbackJob.perform_later(feedback)
      assert result
    end

    # Job not actually enqueued
  end

  # ✅ PREFERRED: Use assert_enqueued_jobs
  test "uses assert_enqueued_jobs instead of mocking" do
    feedback = feedbacks(:one)

    assert_enqueued_jobs 1, only: SendFeedbackJob do
      SendFeedbackJob.perform_later(feedback)
    end
  end

  test "simulates job failure" do
    feedback = feedbacks(:one)

    SendFeedbackJob.stub :perform_now, -> (*) { raise StandardError.new("Job failed") } do
      assert_raises(StandardError) do
        SendFeedbackJob.perform_now(feedback)
      end
    end
  end
end
```
</pattern>

## Advanced Patterns

<pattern name="dependency-injection">
<description>Design for testability with dependency injection</description>

**❌ Bad - Hard to test:**
```ruby
class FeedbackProcessorBad
  def process(feedback)
    # Tightly coupled to AIService
    improved = AIService.improve_content(feedback.content)
    feedback.update!(content: improved)
  end
end
```

**✅ Good - Dependency injection:**
```ruby
class FeedbackProcessorGood
  def initialize(ai_service: AIService)
    @ai_service = ai_service
  end

  def process(feedback)
    improved = @ai_service.improve_content(feedback.content)
    feedback.update!(content: improved)
  end
end
```

**Test:**
```ruby
class DependencyInjectionTest < ActiveSupport::TestCase
  test "uses dependency injection instead of mocking" do
    feedback = feedbacks(:one)

    # Create fake service object
    fake_ai_service = Object.new
    def fake_ai_service.improve_content(content)
      "Improved: #{content}"
    end

    # Inject fake service
    processor = FeedbackProcessorGood.new(ai_service: fake_ai_service)
    processor.process(feedback)

    assert_match /^Improved:/, feedback.content
  end
end
```
</pattern>

<pattern name="fake-objects">
<description>Create simple fake objects instead of complex mocks</description>

```ruby
# Create reusable fake for testing
class FakeAIService
  attr_reader :improve_content_called

  def initialize(response: "Improved content")
    @response = response
    @improve_content_called = false
  end

  def improve_content(content)
    @improve_content_called = true
    @response
  end
end

class FakeObjectsTest < ActiveSupport::TestCase
  test "uses fake object instead of mock" do
    fake_service = FakeAIService.new(response: "Test improved")

    result = fake_service.improve_content("original")

    assert_equal "Test improved", result
    assert fake_service.improve_content_called
  end

  test "fake object simulates error" do
    fake_service = FakeAIService.new

    # Override method for error simulation
    def fake_service.improve_content(content)
      raise StandardError.new("Service unavailable")
    end

    assert_raises(StandardError) do
      fake_service.improve_content("test")
    end
  end
end
```

**Benefits:**
- More readable than complex mock setups
- Reusable across multiple tests
- Easier to maintain
- Can track state and behavior
</pattern>

<pattern name="partial-stubbing">
<description>Stub specific methods while keeping others real</description>

```ruby
class PartialStubbingTest < ActiveSupport::TestCase
  test "partially stubs object" do
    user = users(:alice)

    # Stub only one method
    user.stub :admin?, true do
      assert user.admin?  # Stubbed
      assert_equal "Alice Johnson", user.name  # Real method
      assert_equal "alice@example.com", user.email  # Real method
    end
  end

  test "calls original method in stub" do
    feedback = feedbacks(:one)
    original_content = feedback.content

    feedback.stub :content, -> { "[STUB] #{original_content}" } do
      assert_match /^\[STUB\]/, feedback.content
    end
  end
end
```
</pattern>

<pattern name="verify-method-calls">
<description>Verify methods were called with expected arguments</description>

```ruby
class VerifyingCallsTest < ActiveSupport::TestCase
  # Manual tracking
  test "tracks method calls manually" do
    feedback = feedbacks(:one)
    save_called = false

    feedback.stub :save, -> { save_called = true; true } do
      feedback.save
    end

    assert save_called, "Expected save to be called"
  end

  # Use mock.expect and mock.verify
  test "verifies with mock" do
    mock = Minitest::Mock.new

    # Expect specific call with specific arguments
    mock.expect :process, "result", ["arg1", 123, { key: "value" }]

    result = mock.process("arg1", 123, { key: "value" })

    assert_equal "result", result
    mock.verify  # Raises if expectation not met
  end

  # Verify with WebMock
  test "verifies HTTP request with WebMock" do
    stub_request(:post, "https://api.example.com/track")
      .to_return(status: 200)

    Net::HTTP.post(URI("https://api.example.com/track"), "data")

    assert_requested :post, "https://api.example.com/track",
      times: 1,
      headers: { "Content-Type" => "application/x-www-form-urlencoded" }
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Over-mocking and stubbing your own code</description>
<reason>Makes tests brittle and meaningless - you're testing mocks, not behavior</reason>
<bad-example>
```ruby
# ❌ BAD - Everything is mocked, testing nothing
test "over-stubbed test" do
  user = users(:alice)

  user.stub :valid?, true do
    user.stub :save, true do
      user.stub :persisted?, true do
        # This doesn't test anything useful
        assert user.valid?
        assert user.save
        assert user.persisted?
      end
    end
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Test real behavior
test "tests real behavior" do
  user = User.new(name: "Test", email: "test@example.com")

  assert user.valid?
  assert user.save
  assert user.persisted?
end
```
</good-example>
</antipattern>

<antipattern>
<description>Forgetting to call mock.verify</description>
<reason>Mock expectations are not validated, test may pass incorrectly</reason>
<bad-example>
```ruby
# ❌ BAD - Expectations not verified
test "forgets to verify mock" do
  mock = Minitest::Mock.new
  mock.expect :call, "result"

  # If we don't call mock.call, test still passes!
  # NO mock.verify called
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Always verify expectations
test "verifies mock expectations" do
  mock = Minitest::Mock.new
  mock.expect :call, "result"

  mock.call
  mock.verify  # Ensures expectation was met
end

# ✅ BETTER - Use assert_mock for auto-verification
test "uses assert_mock" do
  mock = Minitest::Mock.new
  mock.expect :call, "result"

  assert_mock mock do
    mock.call
  end  # Automatically verifies
end
```
</good-example>
</antipattern>

<antipattern>
<description>Mocking ActiveRecord unnecessarily</description>
<reason>Rails transactional fixtures are fast enough for most tests</reason>
<bad-example>
```ruby
# ❌ BAD - Unnecessary mocking
test "mocks ActiveRecord when not needed" do
  mock_user = Minitest::Mock.new
  mock_user.expect :name, "Test"
  mock_user.expect :email, "test@example.com"

  User.stub :find, mock_user do
    user = User.find(1)
    assert_equal "Test", user.name
  end

  mock_user.verify
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use real ActiveRecord with fixtures
test "uses real ActiveRecord" do
  user = users(:alice)

  assert_equal "Alice Johnson", user.name
  assert_equal "alice@example.com", user.email
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not using WebMock for HTTP requests</description>
<reason>Violates TEAM_RULES.md Rule #18, makes tests slow and brittle</reason>
<bad-example>
```ruby
# ❌ BAD - Real HTTP request in test
test "makes real HTTP request" do
  response = Net::HTTP.get(URI("https://api.example.com/feedback"))

  assert_includes response, "success"
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use WebMock (REQUIRED)
test "stubs HTTP request with WebMock" do
  stub_request(:get, "https://api.example.com/feedback")
    .to_return(status: 200, body: '{"status":"success"}')

  response = Net::HTTP.get(URI("https://api.example.com/feedback"))

  assert_includes response, "success"
end
```
</good-example>
</antipattern>

<antipattern>
<description>Mocking instead of using dependency injection</description>
<reason>Tight coupling makes code harder to test and maintain</reason>
<bad-example>
```ruby
# ❌ BAD - Tightly coupled, requires mocking
class FeedbackProcessor
  def process(feedback)
    AIService.improve_content(feedback.content)
  end
end

test "mocks tightly coupled service" do
  feedback = feedbacks(:one)

  AIService.stub :improve_content, "Improved" do
    processor = FeedbackProcessor.new
    processor.process(feedback)
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Dependency injection, use fake object
class FeedbackProcessor
  def initialize(ai_service: AIService)
    @ai_service = ai_service
  end

  def process(feedback)
    @ai_service.improve_content(feedback.content)
  end
end

test "injects fake service" do
  feedback = feedbacks(:one)
  fake_service = Object.new
  def fake_service.improve_content(content)
    "Improved: #{content}"
  end

  processor = FeedbackProcessor.new(ai_service: fake_service)
  processor.process(feedback)
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test mocking and stubbing behavior:

```ruby
# test/models/ai_integration_test.rb
class AIIntegrationTest < ActiveSupport::TestCase
  test "stubs external AI service" do
    feedback = feedbacks(:one)

    AIService.stub :improve_content, "AI improved content" do
      result = AIService.improve_content(feedback.content)
      assert_equal "AI improved content", result
    end
  end

  test "uses WebMock for HTTP API calls" do
    stub_request(:post, "https://api.openai.com/v1/completions")
      .with(body: hash_including(prompt: "Improve this"))
      .to_return(
        status: 200,
        body: '{"choices":[{"text":"Improved text"}]}'
      )

    # Make API call
    # Verify with assert_requested
    assert_requested :post, "https://api.openai.com/v1/completions"
  end
end

# test/test_helper.rb
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"  # Required for WebMock

class ActiveSupport::TestCase
  fixtures :all
  parallelize(workers: :number_of_processors)
end
```
</testing>

<related-skills>
- tdd-minitest - Test-Driven Development workflow
- fixtures-test-data - Using fixtures for test data
- viewcomponent-testing - Testing ViewComponents
- system-testing-advanced - Advanced integration testing
</related-skills>

<resources>
- [Minitest Documentation](https://github.com/minitest/minitest)
- [WebMock Documentation](https://github.com/bblimke/webmock)
- [Rails Testing Guide - Testing Time-Dependent Code](https://guides.rubyonrails.org/testing.html#testing-time-dependent-code)
- [Martin Fowler - Mocks Aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html)
</resources>
