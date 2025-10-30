# Mocking and Stubbing Comprehensive Patterns
# Reference: Minitest Documentation, WebMock Documentation
# Category: TESTS - MOCKING & STUBBING

#
# ============================================================================
# What are Mocking and Stubbing?
# ============================================================================
#
# Mocking and stubbing are techniques for isolating code under test by
# replacing dependencies with controlled test doubles.
#
# Stubbing: Replace a method with a predetermined return value
# Mocking: Stub + verify the method was called with expected arguments
#
# Benefits:
# ✅ Isolation - Test code in isolation from dependencies
# ✅ Speed - Avoid slow external services (APIs, databases)
# ✅ Control - Simulate hard-to-reproduce scenarios (errors, edge cases)
# ✅ Determinism - Tests are predictable and repeatable
#
# When to Use:
# - External API calls (use WebMock per TEAM_RULES.md Rule #18)
# - Time-dependent code (use travel_to when possible)
# - Third-party service integrations
# - Complex dependency chains
# - Error conditions
#
# When NOT to Use:
# - Testing your own code paths (use real objects)
# - Simple associations (use fixtures)
# - Database operations (use transactional fixtures)
#

#
# ============================================================================
# ✅ BASIC STUBBING WITH stub
# ============================================================================
#

require "test_helper"

class BasicStubbingTest < ActiveSupport::TestCase
  # Stub a method on an object
  test "stubs instance method" do
    user = users(:alice)

    # Temporarily replace the method
    user.stub :name, "Stubbed Name" do
      assert_equal "Stubbed Name", user.name
    end

    # Original method restored after block
    assert_equal "Alice Johnson", user.name
  end

  # Stub multiple methods
  test "stubs multiple methods" do
    feedback = feedbacks(:one)

    feedback.stub :content, "Stubbed content" do
      feedback.stub :status, "stubbed_status" do
        assert_equal "Stubbed content", feedback.content
        assert_equal "stubbed_status", feedback.status
      end
    end
  end

  # Stub class method
  test "stubs class method" do
    User.stub :count, 999 do
      assert_equal 999, User.count
    end

    # Real count after block
    refute_equal 999, User.count
  end

  # Stub with block (dynamic return value)
  test "stubs with block" do
    feedback = feedbacks(:one)

    feedback.stub :content, ->(){ "Dynamic: #{Time.current}" } do
      assert_match /^Dynamic:/, feedback.content
    end
  end
end

#
# ============================================================================
# ✅ MINITEST::MOCK - BASIC MOCKING
# ============================================================================
#

class MinitestMockTest < ActiveSupport::TestCase
  # Create a mock object
  test "creates mock object" do
    mock = Minitest::Mock.new

    # Set expectation: expect method to be called with args, returns value
    mock.expect :call, "mocked result", ["arg1", "arg2"]

    # Call the method
    result = mock.call("arg1", "arg2")

    assert_equal "mocked result", result

    # Verify all expectations were met
    mock.verify
  end

  # Mock with multiple expectations
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

  # Mock that expects specific call count
  test "expects method called multiple times" do
    mock = Minitest::Mock.new

    # Expect :increment to be called 3 times
    mock.expect :increment, nil
    mock.expect :increment, nil
    mock.expect :increment, nil

    3.times { mock.increment }

    mock.verify
  end
end

#
# ============================================================================
# ✅ STUBBING EXTERNAL DEPENDENCIES
# ============================================================================
#

class ExternalDependenciesTest < ActiveSupport::TestCase
  # Stub external service call
  test "stubs external API client" do
    feedback = feedbacks(:one)

    # Assume we have an AIService class
    AIService.stub :improve_content, "Improved content" do
      result = AIService.improve_content(feedback.content)
      assert_equal "Improved content", result
    end
  end

  # Stub with error simulation
  test "simulates external service error" do
    AIService.stub :improve_content, ->(*){ raise StandardError.new("API Error") } do
      assert_raises(StandardError) do
        AIService.improve_content("test")
      end
    end
  end

  # Stub module method
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
end

#
# ============================================================================
# ✅ WEBMOCK - HTTP REQUEST STUBBING (TEAM_RULES.md Rule #18)
# ============================================================================
#

# Gemfile:
# gem "webmock", group: :test

# test/test_helper.rb:
# require "webmock/minitest"

class WebMockTest < ActiveSupport::TestCase
  # Basic HTTP stub
  test "stubs HTTP GET request" do
    stub_request(:get, "https://api.example.com/feedback")
      .to_return(
        status: 200,
        body: '{"status":"success"}',
        headers: { "Content-Type" => "application/json" }
      )

    # Make actual HTTP request (will be intercepted)
    response = Net::HTTP.get(URI("https://api.example.com/feedback"))

    assert_equal '{"status":"success"}', response
  end

  # Stub with request body matching
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

    # This would match the stub
    # HTTP.post("https://api.example.com/ai/improve",
    #   json: { content: "Test feedback" })
  end

  # Stub with multiple responses (sequence)
  test "stubs with response sequence" do
    stub_request(:get, "https://api.example.com/status")
      .to_return(
        { status: 503, body: "Service Unavailable" },
        { status: 503, body: "Service Unavailable" },
        { status: 200, body: "OK" }
      )

    # First two calls return 503, third returns 200
  end

  # Stub with timeout simulation
  test "simulates timeout" do
    stub_request(:get, "https://api.example.com/slow")
      .to_timeout

    # This would raise a timeout error
    # assert_raises(Net::OpenTimeout) do
    #   Net::HTTP.get(URI("https://api.example.com/slow"))
    # end
  end

  # Stub with dynamic response
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

  # Assert request was made
  test "asserts request was made with WebMock" do
    stub_request(:get, "https://api.example.com/check")
      .to_return(status: 200)

    Net::HTTP.get(URI("https://api.example.com/check"))

    assert_requested :get, "https://api.example.com/check", times: 1
  end
end

#
# ============================================================================
# ✅ STUBBING TIME (Alternative to travel_to)
# ============================================================================
#

class TimeStubbingTest < ActiveSupport::TestCase
  # Prefer travel_to, but stub can be used
  test "stubs Time.current" do
    frozen_time = Time.zone.local(2024, 10, 29, 12, 0, 0)

    Time.stub :current, frozen_time do
      assert_equal frozen_time, Time.current
    end
  end

  # Stub Date.today
  test "stubs Date.today" do
    frozen_date = Date.new(2024, 10, 29)

    Date.stub :today, frozen_date do
      assert_equal frozen_date, Date.today
    end
  end

  # NOTE: Prefer Rails' travel_to over stubbing time
  # travel_to is more comprehensive and handles edge cases
  test "prefer travel_to over stubbing" do
    frozen_time = Time.zone.local(2024, 10, 29, 12, 0, 0)

    travel_to frozen_time do
      assert_equal frozen_time, Time.current
      assert_equal frozen_time.to_date, Date.today
    end
  end
end

#
# ============================================================================
# ✅ MOCKING ACTIVERECORD
# ============================================================================
#

class ActiveRecordMockingTest < ActiveSupport::TestCase
  # Mock ActiveRecord query
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

  # Stub scope
  test "stubs scope" do
    mock_relation = [feedbacks(:one), feedbacks(:two)]

    Feedback.stub :pending, mock_relation do
      pending = Feedback.pending
      assert_equal 2, pending.size
    end
  end

  # Mock save
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

  # Stub association
  test "stubs association" do
    user = users(:alice)
    mock_feedbacks = [Minitest::Mock.new, Minitest::Mock.new]

    user.stub :feedbacks, mock_feedbacks do
      assert_equal 2, user.feedbacks.size
    end
  end
end

#
# ============================================================================
# ✅ MOCKING MAILERS
# ============================================================================
#

class MailerMockingTest < ActiveSupport::TestCase
  # Mock mailer delivery
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

  # Prefer assert_enqueued_with for testing mailers
  test "prefer assert_enqueued_with over mocking" do
    feedback = feedbacks(:one)

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      FeedbackMailer.notification(feedback).deliver_later
    end
  end
end

#
# ============================================================================
# ✅ MOCKING BACKGROUND JOBS
# ============================================================================
#

class JobMockingTest < ActiveSupport::TestCase
  # Mock job perform
  test "mocks job perform" do
    feedback = feedbacks(:one)

    SendFeedbackJob.stub :perform_later, true do
      result = SendFeedbackJob.perform_later(feedback)
      assert result
    end

    # Job not actually enqueued
  end

  # Prefer assert_enqueued_jobs
  test "prefer assert_enqueued_jobs over mocking" do
    feedback = feedbacks(:one)

    assert_enqueued_jobs 1, only: SendFeedbackJob do
      SendFeedbackJob.perform_later(feedback)
    end
  end

  # Mock job failure
  test "simulates job failure" do
    feedback = feedbacks(:one)

    SendFeedbackJob.stub :perform_now, ->(*){ raise StandardError.new("Job failed") } do
      assert_raises(StandardError) do
        SendFeedbackJob.perform_now(feedback)
      end
    end
  end
end

#
# ============================================================================
# ✅ PARTIAL STUBBING
# ============================================================================
#

class PartialStubbingTest < ActiveSupport::TestCase
  # Stub one method while keeping others real
  test "partially stubs object" do
    user = users(:alice)

    # Stub only one method
    user.stub :admin?, true do
      assert user.admin?  # Stubbed
      assert_equal "Alice Johnson", user.name  # Real method
      assert_equal "alice@example.com", user.email  # Real method
    end
  end

  # Call original method in stub
  test "calls original method in stub" do
    feedback = feedbacks(:one)
    original_content = feedback.content

    feedback.stub :content, ->(){ "[STUB] #{original_content}" } do
      assert_match /^\[STUB\]/, feedback.content
    end
  end
end

#
# ============================================================================
# ✅ ADVANCED: DEPENDENCY INJECTION FOR TESTABILITY
# ============================================================================
#

# Instead of mocking, prefer dependency injection

# ❌ BAD - Hard to test
class FeedbackProcessorBad
  def process(feedback)
    improved = AIService.improve_content(feedback.content)
    feedback.update!(content: improved)
  end
end

# ✅ GOOD - Dependency injection
class FeedbackProcessorGood
  def initialize(ai_service: AIService)
    @ai_service = ai_service
  end

  def process(feedback)
    improved = @ai_service.improve_content(feedback.content)
    feedback.update!(content: improved)
  end
end

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

#
# ============================================================================
# ✅ TESTING WITH FAKE OBJECTS (Test Doubles)
# ============================================================================
#

# Create simple fake objects instead of complex mocks

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

    # Use fake in code
    result = fake_service.improve_content("original")

    assert_equal "Test improved", result
    assert fake_service.improve_content_called
  end

  test "fake object simulates error" do
    fake_service = FakeAIService.new

    def fake_service.improve_content(content)
      raise StandardError.new("Service unavailable")
    end

    assert_raises(StandardError) do
      fake_service.improve_content("test")
    end
  end
end

#
# ============================================================================
# ✅ VERIFYING METHOD CALLS
# ============================================================================
#

class VerifyingCallsTest < ActiveSupport::TestCase
  # Track method calls with instance variable
  test "tracks method calls manually" do
    feedback = feedbacks(:one)
    save_called = false

    feedback.stub :save, ->{ save_called = true; true } do
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

#
# ============================================================================
# ✅ COMMON PITFALLS AND SOLUTIONS
# ============================================================================
#

class PitfallsTest < ActiveSupport::TestCase
  # ❌ PITFALL: Forgetting to call mock.verify
  test "demonstrates forgetting verify" do
    mock = Minitest::Mock.new
    mock.expect :call, "result"

    # If we don't call mock.call, verify will fail
    # mock.verify  # Would raise Minitest::Assertion
  end

  # ❌ PITFALL: Argument mismatch
  test "demonstrates argument mismatch" do
    mock = Minitest::Mock.new
    mock.expect :process, "result", ["expected_arg"]

    # This would fail because arguments don't match
    # mock.process("different_arg")
    # mock.verify  # Raises
  end

  # ✅ SOLUTION: Use assert_mock with auto-verify
  test "uses assert_mock for auto-verification" do
    mock = Minitest::Mock.new
    mock.expect :call, "result"

    assert_mock mock do
      mock.call
    end  # Automatically calls verify at end
  end

  # ❌ PITFALL: Over-stubbing
  test "demonstrates over-stubbing" do
    # Don't stub everything - test becomes meaningless
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

  # ✅ SOLUTION: Test real behavior when possible
  test "tests real behavior instead" do
    user = User.new(name: "Test", email: "test@example.com")

    assert user.valid?
    assert user.save
    assert user.persisted?
  end
end

#
# ============================================================================
# ✅ BEST PRACTICES SUMMARY
# ============================================================================
#

# DO:
# ✅ Use WebMock for HTTP requests (per TEAM_RULES.md Rule #18)
# ✅ Stub external services and APIs
# ✅ Use travel_to for time-dependent tests
# ✅ Call mock.verify to ensure expectations met
# ✅ Prefer real objects over mocks when possible
# ✅ Use dependency injection for testability
# ✅ Create simple fake objects for complex dependencies
# ✅ Stub to isolate code under test
# ✅ Mock to verify interactions
# ✅ Use descriptive mock expectations

# DON'T:
# ❌ Don't stub your own code (test it for real)
# ❌ Don't over-mock (makes tests brittle)
# ❌ Don't forget to call mock.verify
# ❌ Don't use mocks for simple scenarios
# ❌ Don't stub private methods (test public interface)
# ❌ Don't create complex mock chains
# ❌ Don't mock Time (use travel_to instead)
# ❌ Don't mock ActiveRecord unless necessary
# ❌ Don't test mocks (test behavior)

#
# ============================================================================
# RULE: Use mocking/stubbing for external dependencies only
# WEBMOCK: Required for HTTP requests (TEAM_RULES.md Rule #18)
# ISOLATION: Stub to isolate code under test from dependencies
# VERIFY: Always call mock.verify to ensure expectations met
# PREFER REAL: Use real objects when possible, mocks when necessary
# DEPENDENCY INJECTION: Design for testability with DI
# ============================================================================
#
