---
name: rails-ai:minitest-mocking
description: Use when testing Rails code with external dependencies - provides stubbing, mocking, and WebMock patterns (REQUIRED for HTTP requests per Rule #18)
---

# Minitest Mocking and Stubbing

Isolate code under test by replacing dependencies with controlled test doubles. Use mocking for external services, stubbing for method replacement, and WebMock for HTTP requests.

<superpowers-integration>
**REQUIRED BACKGROUND:** Use superpowers:test-driven-development for TDD process
  - That skill defines RED-GREEN-REFACTOR cycle
  - This skill provides Rails/Minitest-specific mocking and stubbing patterns
</superpowers-integration>

<when-to-use>
- External API calls (REQUIRED per TEAM_RULES.md Rule #18)
- Third-party service integrations
- Time-dependent code (when travel_to is insufficient)
- Error condition simulation
</when-to-use>

<benefits>
- **Isolation** - Test code independently from dependencies
- **Speed** - Avoid slow external services
- **Control** - Simulate hard-to-reproduce scenarios
- **Determinism** - Tests are predictable and repeatable
</benefits>

<standards>
- ALWAYS use WebMock for HTTP requests (per TEAM_RULES.md Rule #18)
- Prefer `stub` for method replacement with return values
- Use `Minitest::Mock` for verifying method calls and arguments
- Call `mock.verify` to ensure expectations are met
- Prefer real objects over mocks when possible
- Use dependency injection for better testability
- Prefer `travel_to` over stubbing time
- Keep mocking minimal - over-mocking makes tests brittle
</standards>

## Basic Stubbing

<pattern name="stub-instance-method">
<description>Replace a method temporarily with predetermined return value</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "stubs instance method" do
    user = users(:alice)

    user.stub :name, "Stubbed Name" do
      assert_equal "Stubbed Name", user.name
    end

    assert_equal "Alice Johnson", user.name  # Restored after block
  end

  test "stubs with lambda for dynamic return" do
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
  end

  test "stubs module singleton method" do
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
    mock.expect :call, "mocked result", ["arg1", "arg2"]

    result = mock.call("arg1", "arg2")

    assert_equal "mocked result", result
    mock.verify  # REQUIRED
  end

  test "mock with multiple expectations" do
    mock = Minitest::Mock.new
    mock.expect :save, true
    mock.expect :valid?, true

    assert mock.save
    assert mock.valid?
    mock.verify
  end

  test "expects method called multiple times" do
    mock = Minitest::Mock.new
    3.times { mock.expect :increment, nil }

    3.times { mock.increment }
    mock.verify
  end

  test "uses assert_mock for auto-verification" do
    mock = Minitest::Mock.new
    mock.expect :call, "result"

    assert_mock mock do
      mock.call
    end  # Automatically calls verify
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

    User.stub :find, mock_user do
      assert_equal "Mocked User", User.find(123).name
    end

    mock_user.verify
  end

  test "stubs scope" do
    mock_relation = [feedbacks(:one), feedbacks(:two)]

    Feedback.stub :pending, mock_relation do
      assert_equal 2, Feedback.pending.size
    end
  end

  test "mocks save to prevent database write" do
    feedback = Feedback.new(content: "Test", recipient_email: "test@example.com")

    feedback.stub :save, true do
      assert feedback.save
      refute feedback.persisted?  # Not actually saved
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
    AIService.stub :improve_content, "Improved content" do
      result = AIService.improve_content(feedbacks(:one).content)
      assert_equal "Improved content", result
    end
  end

  test "simulates external service error" do
    AIService.stub :improve_content, -> (*) { raise StandardError.new("API Error") } do
      assert_raises(StandardError) { AIService.improve_content("test") }
    end
  end

  test "simulates timeout" do
    AIService.stub :call, -> (*) { raise Net::OpenTimeout.new("Request timeout") } do
      assert_raises(Net::OpenTimeout) { AIService.call("test") }
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
      .to_return(status: 200, body: '{"status":"success"}')

    response = Net::HTTP.get(URI("https://api.example.com/feedback"))
    assert_equal '{"status":"success"}', response
  end

  test "stubs POST with body matching" do
    stub_request(:post, "https://api.example.com/ai/improve")
      .with(body: hash_including(content: "Test feedback"))
      .to_return(status: 200, body: '{"improved":"Enhanced"}')
  end

  test "stubs with response sequence for retry logic" do
    stub_request(:get, "https://api.example.com/status")
      .to_return(
        { status: 503 },
        { status: 503 },
        { status: 200, body: "OK" }
      )
  end

  test "simulates timeout" do
    stub_request(:get, "https://api.example.com/slow").to_timeout

    assert_raises(Net::OpenTimeout) do
      Net::HTTP.get(URI("https://api.example.com/slow"))
    end
  end

  test "stubs with dynamic response" do
    stub_request(:post, "https://api.example.com/echo")
      .to_return { |request| { status: 200, body: request.body } }
  end
end
```

**Verify Requests:**
```ruby
test "verifies HTTP request was made" do
  stub_request(:get, "https://api.example.com/check").to_return(status: 200)

  Net::HTTP.get(URI("https://api.example.com/check"))

  assert_requested :get, "https://api.example.com/check", times: 1
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
    end
  end

  # Alternative: Stub when travel_to insufficient
  test "stubs Time.current" do
    Time.stub :current, Time.zone.local(2024, 10, 29, 12, 0, 0) do
      assert_equal Time.zone.local(2024, 10, 29, 12, 0, 0), Time.current
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
  # ✅ PREFERRED: Use assert_enqueued_jobs
  test "uses assert_enqueued_jobs instead of mocking" do
    feedback = feedbacks(:one)

    assert_enqueued_jobs 1, only: SendFeedbackJob do
      SendFeedbackJob.perform_later(feedback)
    end
  end

  test "simulates job failure" do
    SendFeedbackJob.stub :perform_now, -> (*) { raise StandardError.new("Job failed") } do
      assert_raises(StandardError) { SendFeedbackJob.perform_now(feedbacks(:one)) }
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
    fake_ai_service = Object.new
    def fake_ai_service.improve_content(content)
      "Improved: #{content}"
    end

    processor = FeedbackProcessorGood.new(ai_service: fake_ai_service)
    processor.process(feedbacks(:one))

    assert_match /^Improved:/, feedbacks(:one).content
  end
end
```
</pattern>

<pattern name="fake-objects">
<description>Create simple fake objects instead of complex mocks</description>

```ruby
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
    def fake_service.improve_content(content)
      raise StandardError.new("Service unavailable")
    end

    assert_raises(StandardError) { fake_service.improve_content("test") }
  end
end
```

**Benefits:** More readable, reusable, easier to maintain, can track state
</pattern>

<pattern name="partial-stubbing">
<description>Stub specific methods while keeping others real</description>

```ruby
class PartialStubbingTest < ActiveSupport::TestCase
  test "partially stubs object" do
    user = users(:alice)

    user.stub :admin?, true do
      assert user.admin?  # Stubbed
      assert_equal "Alice Johnson", user.name  # Real
      assert_equal "alice@example.com", user.email  # Real
    end
  end

  test "calls original method in stub" do
    feedback = feedbacks(:one)
    original = feedback.content

    feedback.stub :content, -> { "[STUB] #{original}" } do
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
  test "tracks method calls manually" do
    save_called = false

    feedbacks(:one).stub :save, -> { save_called = true; true } do
      feedbacks(:one).save
    end

    assert save_called, "Expected save to be called"
  end

  test "verifies with mock" do
    mock = Minitest::Mock.new
    mock.expect :process, "result", ["arg1", 123, { key: "value" }]

    result = mock.process("arg1", 123, { key: "value" })

    assert_equal "result", result
    mock.verify
  end

  test "verifies HTTP request with WebMock" do
    stub_request(:post, "https://api.example.com/track").to_return(status: 200)

    Net::HTTP.post(URI("https://api.example.com/track"), "data")

    assert_requested :post, "https://api.example.com/track", times: 1
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Forgetting to call mock.verify</description>
<reason>Mock expectations are not validated, test may pass incorrectly</reason>
<bad-example>
```ruby
# ❌ BAD - Expectations not verified
test "forgets to verify mock" do
  mock = Minitest::Mock.new
  mock.expect :call, "result"
  # NO mock.verify called
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Always verify
test "verifies mock expectations" do
  mock = Minitest::Mock.new
  mock.expect :call, "result"

  mock.call
  mock.verify
end

# ✅ BETTER - Use assert_mock
test "uses assert_mock" do
  mock = Minitest::Mock.new
  mock.expect :call, "result"

  assert_mock mock do
    mock.call
  end
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
</antipatterns>

<testing>
Test mocking and stubbing behavior:

```ruby
class AIIntegrationTest < ActiveSupport::TestCase
  test "stubs external AI service" do
    AIService.stub :improve_content, "AI improved" do
      assert_equal "AI improved", AIService.improve_content(feedbacks(:one).content)
    end
  end

  test "uses WebMock for HTTP API calls" do
    stub_request(:post, "https://api.openai.com/v1/completions")
      .with(body: hash_including(prompt: "Improve this"))
      .to_return(status: 200, body: '{"choices":[{"text":"Improved"}]}')

    # Make API call...
    assert_requested :post, "https://api.openai.com/v1/completions"
  end
end

# test/test_helper.rb
# ...
require "webmock/minitest"  # Required for WebMock
```
</testing>

<related-skills>
- superpowers:test-driven-development (TDD process)
- rails-ai:tdd-minitest (Minitest patterns)
- rails-ai:fixtures (Test data patterns)
</related-skills>

<resources>
- [Minitest Documentation](https://github.com/minitest/minitest)
- [WebMock Documentation](https://github.com/bblimke/webmock)
- [Rails Testing Guide - Time-Dependent Code](https://guides.rubyonrails.org/testing.html#testing-time-dependent-code)
</resources>
