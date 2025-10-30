# Minitest Best Practices Comprehensive Patterns
# Reference: Minitest Documentation, Rails Testing Guide
# Category: TESTS - MINITEST

#
# ============================================================================
# What is Minitest?
# ============================================================================
#
# Minitest is a complete suite of testing facilities supporting TDD (Test-Driven
# Development), BDD (Behavior-Driven Development), mocking, and benchmarking.
# It's Rails' default testing framework since Rails 4.
#
# Key Principles:
# ✅ Fast - Minimal overhead, runs quickly
# ✅ Simple - Easy to understand and debug
# ✅ Flexible - Supports multiple styles (Test::Unit, Spec, Benchmark)
# ✅ Built-in - Ships with Ruby, no external dependencies
# ✅ Parallel - Run tests in parallel for speed
#
# Testing Philosophy:
# - RED: Write a failing test first
# - GREEN: Make it pass with minimal code
# - REFACTOR: Improve code while keeping tests green
#

#
# ============================================================================
# ✅ BASIC TEST STRUCTURE
# ============================================================================
#

require "test_helper"

# Test classes inherit from ActiveSupport::TestCase (which wraps Minitest::Test)
class BasicExampleTest < ActiveSupport::TestCase
  # Test methods start with "test_" or use the "test" macro
  def test_the_truth
    assert true
  end

  # Or use the "test" macro for more readable names
  test "the truth with macro" do
    assert true
  end

  # Skip a test
  test "this will be skipped" do
    skip "implement this later"
  end
end

#
# ============================================================================
# ✅ SETUP AND TEARDOWN
# ============================================================================
#

class SetupTeardownTest < ActiveSupport::TestCase
  # Called before EVERY test
  def setup
    @user = User.create!(
      name: "Test User",
      email: "test@example.com"
    )
    @feedback = Feedback.create!(
      content: "Test feedback",
      recipient_email: "recipient@example.com"
    )
  end

  # Called after EVERY test
  def teardown
    # Clean up if needed (usually not necessary with transactional fixtures)
    Rails.cache.clear
  end

  test "user exists after setup" do
    assert @user.persisted?
    assert_equal "Test User", @user.name
  end

  test "feedback exists after setup" do
    assert @feedback.persisted?
  end
end

#
# ============================================================================
# ✅ COMMON ASSERTIONS
# ============================================================================
#

class AssertionsTest < ActiveSupport::TestCase
  test "equality assertions" do
    assert_equal 4, 2 + 2
    refute_equal 5, 2 + 2  # Opposite of assert_equal

    assert_same @obj, @obj  # Same object identity
    refute_same User.new, User.new
  end

  test "boolean assertions" do
    assert true
    refute false

    assert_nil nil
    refute_nil "something"
  end

  test "inclusion assertions" do
    assert_includes [1, 2, 3], 2
    refute_includes [1, 2, 3], 4

    assert_in_delta 1.0, 1.001, 0.01  # Float comparison
  end

  test "pattern matching assertions" do
    assert_match /hello/i, "Hello World"
    refute_match /goodbye/, "Hello World"
  end

  test "exception assertions" do
    assert_raises(ArgumentError) do
      raise ArgumentError, "Invalid argument"
    end

    assert_nothing_raised do
      1 + 1
    end
  end

  test "predicate assertions" do
    user = User.new
    assert_predicate user, :new_record?
    refute_predicate user, :persisted?
  end

  test "instance assertions" do
    assert_instance_of String, "hello"
    assert_kind_of Numeric, 42
  end

  test "respond_to assertions" do
    assert_respond_to "string", :upcase
    refute_respond_to "string", :foo
  end

  test "empty/present assertions" do
    assert_empty []
    refute_empty [1, 2, 3]
  end
end

#
# ============================================================================
# ✅ RAILS-SPECIFIC ASSERTIONS
# ============================================================================
#

class RailsAssertionsTest < ActiveSupport::TestCase
  test "difference assertions" do
    assert_difference "User.count", 1 do
      User.create!(name: "New User", email: "new@example.com")
    end

    assert_no_difference "User.count" do
      User.first  # Just reading, not creating
    end

    # Multiple counters
    assert_difference ["User.count", "Feedback.count"], 1 do
      user = User.create!(name: "User", email: "user@example.com")
      Feedback.create!(
        content: "Content",
        recipient_email: user.email
      )
    end
  end

  test "validation assertions" do
    user = User.new  # Invalid - missing required fields

    refute user.valid?
    assert_not user.save

    user.name = "Valid"
    user.email = "valid@example.com"

    assert user.valid?
    assert user.save
  end

  test "query assertions" do
    users = User.where(name: "Test")

    assert users.exists?
    refute users.blank?
  end
end

#
# ============================================================================
# ✅ TEST ORGANIZATION PATTERNS
# ============================================================================
#

# Group related tests in a class
class UserCreationTest < ActiveSupport::TestCase
  test "creates user with valid attributes" do
    user = User.new(name: "Alice", email: "alice@example.com")
    assert user.save
  end

  test "fails with missing name" do
    user = User.new(email: "bob@example.com")
    refute user.save
    assert_includes user.errors[:name], "can't be blank"
  end

  test "fails with duplicate email" do
    User.create!(name: "Carol", email: "carol@example.com")

    user = User.new(name: "Dave", email: "carol@example.com")
    refute user.save
    assert_includes user.errors[:email], "has already been taken"
  end
end

#
# ============================================================================
# ✅ DESCRIPTIVE TEST NAMES
# ============================================================================
#

class DescriptiveTestNamesTest < ActiveSupport::TestCase
  # ❌ BAD - Vague test name
  test "test_user" do
    user = User.create!(name: "Test", email: "test@example.com")
    assert user.persisted?
  end

  # ✅ GOOD - Descriptive test name
  test "creates user with valid name and email" do
    user = User.create!(name: "Test", email: "test@example.com")
    assert user.persisted?
  end

  # ✅ GOOD - Describes expected behavior
  test "sends welcome email after user creation" do
    assert_enqueued_with(job: WelcomeEmailJob) do
      User.create!(name: "Test", email: "test@example.com")
    end
  end

  # ✅ GOOD - Describes edge case
  test "handles user with extremely long name gracefully" do
    long_name = "A" * 1000
    user = User.new(name: long_name, email: "test@example.com")

    refute user.valid?
    assert_includes user.errors[:name], "is too long"
  end
end

#
# ============================================================================
# ✅ DRY TESTS WITH SHARED SETUP
# ============================================================================
#

class DRYTestsTest < ActiveSupport::TestCase
  # Extract common setup
  def setup
    @valid_attributes = {
      name: "Test User",
      email: "test@example.com"
    }
  end

  test "creates user with valid attributes" do
    user = User.new(@valid_attributes)
    assert user.save
  end

  test "updates user with valid attributes" do
    user = User.create!(@valid_attributes)
    user.name = "Updated Name"
    assert user.save
  end
end

#
# ============================================================================
# ✅ TESTING ACTIVERECORD MODELS
# ============================================================================
#

class FeedbackModelTest < ActiveSupport::TestCase
  test "valid feedback with all required attributes" do
    feedback = Feedback.new(
      content: "Great product!",
      recipient_email: "user@example.com"
    )

    assert feedback.valid?
  end

  test "invalid without content" do
    feedback = Feedback.new(recipient_email: "user@example.com")

    refute feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end

  test "invalid with short content" do
    feedback = Feedback.new(
      content: "Hi",  # Too short
      recipient_email: "user@example.com"
    )

    refute feedback.valid?
    assert_includes feedback.errors[:content], "is too short"
  end

  test "sanitizes content on save" do
    feedback = Feedback.create!(
      content: "<script>alert('xss')</script>Safe content",
      recipient_email: "user@example.com"
    )

    refute_includes feedback.content, "<script>"
  end
end

#
# ============================================================================
# ✅ TESTING ASSOCIATIONS
# ============================================================================
#

class AssociationsTest < ActiveSupport::TestCase
  test "user has many feedbacks" do
    user = users(:alice)

    assert_respond_to user, :feedbacks
    assert_kind_of ActiveRecord::Associations::CollectionProxy, user.feedbacks
  end

  test "destroying user destroys associated feedbacks" do
    user = users(:alice)
    feedback_id = user.feedbacks.create!(
      content: "Test",
      recipient_email: "test@example.com"
    ).id

    assert_difference "Feedback.count", -1 do
      user.destroy
    end

    refute Feedback.exists?(feedback_id)
  end

  test "feedback belongs to sender" do
    feedback = feedbacks(:one)

    assert_respond_to feedback, :sender
    assert_instance_of User, feedback.sender
  end
end

#
# ============================================================================
# ✅ TESTING SCOPES
# ============================================================================
#

class ScopesTest < ActiveSupport::TestCase
  test "pending scope returns only pending feedbacks" do
    pending = Feedback.create!(
      content: "Pending",
      recipient_email: "test@example.com",
      status: "pending"
    )

    responded = Feedback.create!(
      content: "Responded",
      recipient_email: "test@example.com",
      status: "responded"
    )

    pending_feedbacks = Feedback.pending

    assert_includes pending_feedbacks, pending
    refute_includes pending_feedbacks, responded
  end

  test "recent scope orders by created_at desc" do
    old = Feedback.create!(
      content: "Old",
      recipient_email: "test@example.com",
      created_at: 2.days.ago
    )

    new = Feedback.create!(
      content: "New",
      recipient_email: "test@example.com",
      created_at: 1.hour.ago
    )

    recent = Feedback.recent

    assert_equal new, recent.first
    assert_equal old, recent.last
  end
end

#
# ============================================================================
# ✅ TESTING CALLBACKS
# ============================================================================
#

class CallbacksTest < ActiveSupport::TestCase
  test "sets default status on create" do
    feedback = Feedback.create!(
      content: "Test",
      recipient_email: "test@example.com"
    )

    assert_equal "pending", feedback.status
  end

  test "sends notification email after create" do
    assert_enqueued_with(job: FeedbackNotificationJob) do
      Feedback.create!(
        content: "Test",
        recipient_email: "test@example.com"
      )
    end
  end

  test "updates timestamp on status change" do
    feedback = feedbacks(:one)
    original_time = feedback.updated_at

    travel 1.hour do
      feedback.update!(status: "responded")
      assert_operator feedback.updated_at, :>, original_time
    end
  end
end

#
# ============================================================================
# ✅ TESTING WITH TIME
# ============================================================================
#

class TimeTestingTest < ActiveSupport::TestCase
  test "uses travel_to for time-dependent logic" do
    user = User.create!(
      name: "Test",
      email: "test@example.com",
      trial_ends_at: 1.week.from_now
    )

    refute user.trial_expired?

    travel 2.weeks do
      assert user.trial_expired?
    end

    # Time returns to normal after block
    refute user.trial_expired?
  end

  test "freezes time with travel_to" do
    freeze_time = Time.zone.local(2024, 10, 29, 12, 0, 0)

    travel_to freeze_time do
      assert_equal freeze_time, Time.current
    end
  end
end

#
# ============================================================================
# ✅ TESTING JOBS
# ============================================================================
#

class JobsTest < ActiveJob::TestCase
  test "job is enqueued" do
    assert_enqueued_jobs 0

    FeedbackNotificationJob.perform_later(feedbacks(:one))

    assert_enqueued_jobs 1
  end

  test "job is performed with correct arguments" do
    feedback = feedbacks(:one)

    assert_performed_with(
      job: FeedbackNotificationJob,
      args: [feedback]
    ) do
      FeedbackNotificationJob.perform_later(feedback)
      perform_enqueued_jobs
    end
  end

  test "job sends email" do
    feedback = feedbacks(:one)

    assert_emails 1 do
      FeedbackNotificationJob.perform_now(feedback)
    end
  end
end

#
# ============================================================================
# ✅ TESTING MAILERS
# ============================================================================
#

class FeedbackMailerTest < ActionMailer::TestCase
  test "notification email" do
    feedback = feedbacks(:one)
    email = FeedbackMailer.notification(feedback)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["noreply@example.com"], email.from
    assert_equal [feedback.recipient_email], email.to
    assert_equal "New Feedback Received", email.subject
    assert_match feedback.content, email.body.encoded
  end
end

#
# ============================================================================
# ✅ TESTING CONTROLLERS
# ============================================================================
#

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "GET index returns success" do
    get feedbacks_url

    assert_response :success
  end

  test "GET show displays feedback" do
    feedback = feedbacks(:one)
    get feedback_url(feedback)

    assert_response :success
    assert_select "h1", text: /Feedback/
  end

  test "POST create with valid params creates feedback" do
    assert_difference "Feedback.count", 1 do
      post feedbacks_url, params: {
        feedback: {
          content: "Great service!",
          recipient_email: "user@example.com"
        }
      }
    end

    assert_redirected_to feedback_path(Feedback.last)
  end

  test "POST create with invalid params renders new" do
    assert_no_difference "Feedback.count" do
      post feedbacks_url, params: {
        feedback: { content: "" }  # Invalid
      }
    end

    assert_response :unprocessable_entity
  end

  test "DELETE destroy removes feedback" do
    feedback = feedbacks(:one)

    assert_difference "Feedback.count", -1 do
      delete feedback_url(feedback)
    end

    assert_redirected_to feedbacks_path
  end
end

#
# ============================================================================
# ✅ PARALLEL TESTING
# ============================================================================
#

# Configured in test_helper.rb:
# class ActiveSupport::TestCase
#   parallelize(workers: :number_of_processors)
# end

# For tests that can't run in parallel:
class NonParallelTest < ActiveSupport::TestCase
  # Disable parallelization for this specific test class
  parallelize(workers: 1)

  test "single worker test" do
    # Tests that manipulate global state
  end
end

#
# ============================================================================
# ✅ BEST PRACTICES SUMMARY
# ============================================================================
#

# DO:
# ✅ Write descriptive test names that describe expected behavior
# ✅ Use setup/teardown to DRY up tests
# ✅ Test one behavior per test
# ✅ Use fixtures for consistent test data
# ✅ Test edge cases and error conditions
# ✅ Keep tests fast (< 100ms per test)
# ✅ Run tests in random order (default in Minitest)
# ✅ Use travel_to for time-dependent tests
# ✅ Test public interfaces, not private methods
# ✅ Use assert_difference for database changes

# DON'T:
# ❌ Don't test Rails' built-in functionality
# ❌ Don't use sleep or wait in tests
# ❌ Don't create dependencies between tests
# ❌ Don't test implementation details
# ❌ Don't skip tests permanently
# ❌ Don't use puts for debugging (use byebug/pry)
# ❌ Don't write tests without assertions
# ❌ Don't test multiple behaviors in one test
# ❌ Don't ignore flaky tests

#
# ============================================================================
# RULE: Always follow TDD - RED, GREEN, REFACTOR
# SPEED: Keep tests fast with transactional fixtures
# ISOLATION: Tests should not depend on each other
# CLARITY: Test names should describe expected behavior
# COVERAGE: Aim for 85%+ coverage, 100% for critical paths
# PARALLEL: Use parallel testing for speed (default in Rails)
# ============================================================================
#
