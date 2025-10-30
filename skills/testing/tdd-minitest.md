---
name: tdd-minitest
domain: testing
dependencies: []
version: 1.0
rails_version: 8.1+
---

# TDD with Minitest

Test-Driven Development workflow using Minitest, Rails' default testing framework. Write tests first, make them pass, then refactor.

<when-to-use>
- All code development (TDD is always enforced in this team)
- Writing model, controller, job, mailer tests
- Testing ViewComponents and helper methods
- System tests for full-stack features
- Regression testing for bug fixes
</when-to-use>

<benefits>
- **Fast** - Minimal overhead, runs quickly
- **Simple** - Easy to understand and debug
- **Built-in** - Ships with Ruby and Rails
- **Parallel** - Run tests concurrently for speed
- **Flexible** - Supports multiple testing styles
- **Confidence** - Tests document expected behavior
</benefits>

<standards>
- ALWAYS write tests FIRST (RED-GREEN-REFACTOR cycle)
- Test classes inherit from `ActiveSupport::TestCase`
- Use `test "description" do` macro for readable test names
- Use fixtures for test data (in `test/fixtures/`)
- Use `assert` and `refute` for assertions
- Run tests with `rails test` or `bin/rails test`
- Keep tests fast - use factories sparingly
- One assertion concept per test method
- Use `setup` and `teardown` for common test preparation
</standards>

## TDD Workflow

<pattern name="red-green-refactor">
<description>Core TDD cycle - write failing test, make it pass, refactor</description>

**Step 1: RED - Write a failing test**
```ruby
# test/models/feedback_test.rb
require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "is invalid without content" do
    feedback = Feedback.new(content: nil)

    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end
end
```

Run test: `rails test test/models/feedback_test.rb`
Result: **FAIL** (validation doesn't exist yet)

**Step 2: GREEN - Make it pass with minimal code**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  validates :content, presence: true
end
```

Run test: `rails test test/models/feedback_test.rb`
Result: **PASS**

**Step 3: REFACTOR - Improve code while keeping tests green**
```ruby
# If needed, refactor model or test
# Tests should still pass after refactoring
```
</pattern>

## Test Structure

<pattern name="basic-test-structure">
<description>Standard Minitest test class structure</description>

```ruby
# test/models/feedback_test.rb
require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  # Use test macro for readable names
  test "the truth" do
    assert true
  end

  # Or traditional method naming
  def test_the_truth
    assert true
  end

  # Skip a test temporarily
  test "this will be implemented later" do
    skip "implement this feature first"
  end
end
```
</pattern>

<pattern name="setup-and-teardown">
<description>Prepare and clean up test environment</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  # Called before EVERY test
  def setup
    @feedback = feedbacks(:one)  # Load fixture
    @user = users(:alice)
  end

  # Called after EVERY test
  def teardown
    # Clean up if needed (usually not necessary)
  end

  test "feedback belongs to user" do
    assert_equal @user, @feedback.user
  end
end
```
</pattern>

## Assertions

<pattern name="common-assertions">
<description>Most frequently used Minitest assertions</description>

```ruby
class AssertionsTest < ActiveSupport::TestCase
  test "equality assertions" do
    assert_equal 4, 2 + 2
    refute_equal 5, 2 + 2

    assert_same object1, object1  # Same object identity
    refute_same object1, object2
  end

  test "boolean assertions" do
    assert true
    refute false

    assert_nil nil
    refute_nil "something"
  end

  test "collection assertions" do
    assert_empty []
    refute_empty [1, 2, 3]

    assert_includes [1, 2, 3], 2
    refute_includes [1, 2, 3], 4
  end

  test "exception assertions" do
    assert_raises(ArgumentError) do
      raise ArgumentError, "error message"
    end

    assert_nothing_raised do
      # Code that should not raise
    end
  end

  test "difference assertions" do
    assert_difference "Feedback.count", 1 do
      Feedback.create!(content: "Test")
    end

    assert_no_difference "Feedback.count" do
      feedback = Feedback.new(content: nil)
      feedback.save  # Invalid, won't save
    end
  end

  test "match assertions" do
    assert_match /hello/, "hello world"
    refute_match /goodbye/, "hello world"
  end

  test "instance assertions" do
    assert_instance_of String, "hello"
    assert_kind_of Numeric, 42  # Integer is a kind of Numeric
  end

  test "response assertions" do
    assert_respond_to "string", :upcase
    refute_respond_to "string", :nonexistent_method
  end
end
```
</pattern>

## Model Testing

<pattern name="model-validation-tests">
<description>Testing ActiveRecord validations</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    feedback = Feedback.new(
      content: "Great work!",
      recipient_email: "user@example.com"
    )

    assert feedback.valid?
  end

  test "is invalid without content" do
    feedback = Feedback.new(content: nil)

    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end

  test "is invalid with short content" do
    feedback = Feedback.new(content: "Hi")

    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "is too short"
  end

  test "is invalid with invalid email format" do
    feedback = Feedback.new(recipient_email: "invalid")

    assert_not feedback.valid?
    assert_includes feedback.errors[:recipient_email], "is invalid"
  end
end
```
</pattern>

<pattern name="model-method-tests">
<description>Testing model methods and behavior</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "recent scope returns feedbacks from last 7 days" do
    old_feedback = feedbacks(:old)  # Created 10 days ago
    recent_feedback = feedbacks(:recent)  # Created 2 days ago

    results = Feedback.recent

    assert_includes results, recent_feedback
    refute_includes results, old_feedback
  end

  test "mark_as_read! updates read_at timestamp" do
    feedback = feedbacks(:unread)
    assert_nil feedback.read_at

    feedback.mark_as_read!

    assert_not_nil feedback.reload.read_at
  end

  test "archiving feedback preserves content" do
    feedback = feedbacks(:one)
    original_content = feedback.content

    feedback.archive!

    assert feedback.archived?
    assert_equal original_content, feedback.reload.content
  end
end
```
</pattern>

## Controller Testing

<pattern name="controller-action-tests">
<description>Testing controller actions and responses</description>

```ruby
# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "GET index returns success" do
    get feedbacks_url

    assert_response :success
  end

  test "GET show displays feedback" do
    feedback = feedbacks(:one)

    get feedback_url(feedback)

    assert_response :success
    assert_select "h1", feedback.content
  end

  test "POST create with valid params creates feedback" do
    assert_difference("Feedback.count", 1) do
      post feedbacks_url, params: {
        feedback: {
          content: "New feedback",
          recipient_email: "test@example.com"
        }
      }
    end

    assert_redirected_to feedback_url(Feedback.last)
    follow_redirect!
    assert_select "div.notice", "Feedback was successfully created."
  end

  test "POST create with invalid params does not create feedback" do
    assert_no_difference("Feedback.count") do
      post feedbacks_url, params: {
        feedback: { content: nil }
      }
    end

    assert_response :unprocessable_entity
  end

  test "DELETE destroy removes feedback" do
    feedback = feedbacks(:one)

    assert_difference("Feedback.count", -1) do
      delete feedback_url(feedback)
    end

    assert_redirected_to feedbacks_url
  end
end
```
</pattern>

## System Testing

<pattern name="system-test">
<description>Full-stack feature testing with browser simulation</description>

```ruby
# test/system/feedbacks_test.rb
require "application_system_test_case"

class FeedbacksTest < ApplicationSystemTestCase
  test "creating a feedback" do
    visit feedbacks_url

    click_on "New Feedback"

    fill_in "Content", with: "This is great feedback"
    fill_in "Recipient email", with: "user@example.com"

    click_on "Create Feedback"

    assert_text "Feedback was successfully created"
    assert_text "This is great feedback"
  end

  test "editing a feedback" do
    feedback = feedbacks(:one)

    visit feedback_url(feedback)

    click_on "Edit"

    fill_in "Content", with: "Updated content"

    click_on "Update Feedback"

    assert_text "Feedback was successfully updated"
    assert_text "Updated content"
  end

  test "deleting a feedback" do
    feedback = feedbacks(:one)

    visit feedbacks_url

    accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "Feedback was successfully deleted"
    assert_no_text feedback.content
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Writing tests after writing code</description>
<reason>Defeats the purpose of TDD - tests should drive design</reason>
<bad-example>
```ruby
# ❌ BAD - Code written first
# 1. Write Feedback model
# 2. Then write tests

# This is NOT TDD!
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Tests written first
# 1. Write failing test
# 2. Write minimal code to pass
# 3. Refactor

# This IS TDD (RED-GREEN-REFACTOR)
```
</good-example>
</antipattern>

<antipattern>
<description>Testing multiple concerns in one test</description>
<reason>Makes tests harder to debug when they fail</reason>
<bad-example>
```ruby
# ❌ BAD - Multiple assertions for different concerns
test "feedback validations" do
  feedback = Feedback.new

  assert_not feedback.valid?
  assert_includes feedback.errors[:content], "can't be blank"
  assert_includes feedback.errors[:email], "can't be blank"
  assert_includes feedback.errors[:email], "is invalid"
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - One concern per test
test "is invalid without content" do
  feedback = Feedback.new(content: nil, email: "valid@example.com")

  assert_not feedback.valid?
  assert_includes feedback.errors[:content], "can't be blank"
end

test "is invalid without email" do
  feedback = Feedback.new(content: "Valid", email: nil)

  assert_not feedback.valid?
  assert_includes feedback.errors[:email], "can't be blank"
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not using fixtures for test data</description>
<reason>Makes tests slower and harder to maintain</reason>
<bad-example>
```ruby
# ❌ BAD - Creating records in every test
test "feedback belongs to user" do
  user = User.create!(email: "test@example.com", password: "password")
  feedback = Feedback.create!(content: "Test", user: user)

  assert_equal user, feedback.user
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use fixtures
# test/fixtures/users.yml
alice:
  email: alice@example.com

# test/fixtures/feedbacks.yml
one:
  content: "Great work!"
  user: alice

# Test
test "feedback belongs to user" do
  feedback = feedbacks(:one)
  user = users(:alice)

  assert_equal user, feedback.user
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Run tests with various options:

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/feedback_test.rb

# Run specific test by line number
rails test test/models/feedback_test.rb:12

# Run tests matching pattern
rails test test/models/feedback_test.rb -n /validation/

# Run tests in parallel (faster)
rails test --parallel

# Run with verbose output
rails test --verbose

# Run system tests only
rails test:system
```
</testing>

<related-skills>
- fixtures-test-data - Using fixtures effectively
- minitest-mocking - Stubbing and mocking
- viewcomponent-testing - Testing ViewComponents
- system-testing-advanced - Advanced Capybara patterns
</related-skills>

<resources>
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Minitest Documentation](https://github.com/minitest/minitest)
- [Minitest Assertions](https://docs.seattlerb.org/minitest/Minitest/Assertions.html)
</resources>
