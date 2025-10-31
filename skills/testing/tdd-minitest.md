---
name: tdd-minitest
domain: testing
dependencies: []
version: 1.0
rails_version: 8.1+

# Team rules enforcement
enforces_team_rule:
  - rule_id: 2
    rule_name: "Minitest Only"
    severity: critical
    enforcement_action: REJECT
  - rule_id: 4
    rule_name: "TDD Always"
    severity: critical
    enforcement_action: REJECT
---

# TDD with Minitest

Test-Driven Development workflow using Minitest, Rails' default testing framework. Write tests first, make them pass, then refactor.

<when-to-use>
- All code development (TDD is always enforced in this team)
- Model, controller, job, and mailer tests
- System tests for full-stack features
</when-to-use>

<benefits>
- **Fast** - Minimal overhead, runs quickly
- **Simple** - Easy to understand and debug
- **Built-in** - Ships with Ruby and Rails
- **Parallel** - Run tests concurrently for speed
</benefits>

<standards>
- ALWAYS write tests FIRST (RED-GREEN-REFACTOR cycle)
- Test classes inherit from `ActiveSupport::TestCase`
- Use `test "description" do` macro for readable test names
- Use fixtures for test data (in `test/fixtures/`)
- Use `assert` and `refute` for assertions
- One assertion concept per test method
- Use `setup` for common test preparation
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

Result: **FAIL** (validation doesn't exist yet)

**Step 2: GREEN - Make it pass with minimal code**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  validates :content, presence: true
end
```

Result: **PASS**

**Step 3: REFACTOR - Improve code while keeping tests green**
</pattern>

## Test Structure

<pattern name="basic-test-structure">
<description>Standard Minitest test class structure</description>

```ruby
# test/models/feedback_test.rb
require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "the truth" do
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
class FeedbackTest < ActiveSupport::TestCase
  def setup
    @feedback = feedbacks(:one)
    @user = users(:alice)
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
  test "equality and boolean" do
    assert_equal 4, 2 + 2
    refute_equal 5, 2 + 2
    assert_nil nil
    refute_nil "something"
  end

  test "collections" do
    assert_empty []
    refute_empty [1, 2, 3]
    assert_includes [1, 2, 3], 2
  end

  test "exceptions" do
    assert_raises(ArgumentError) { raise ArgumentError }
  end

  test "difference" do
    assert_difference "Feedback.count", 1 do
      Feedback.create!(content: "Test")
    end

    assert_no_difference "Feedback.count" do
      Feedback.new(content: nil).save
    end
  end

  test "match and instance" do
    assert_match /hello/, "hello world"
    assert_instance_of String, "hello"
    assert_respond_to "string", :upcase
  end
end
```
</pattern>

## Model Testing

<pattern name="model-validation-tests">
<description>Testing ActiveRecord validations</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    feedback = Feedback.new(content: "Great work!", recipient_email: "user@example.com")
    assert feedback.valid?
  end

  test "is invalid without content" do
    feedback = Feedback.new(content: nil)
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end

  test "is invalid with invalid email format" do
    feedback = Feedback.new(recipient_email: "invalid")
    assert_not feedback.valid?
    assert_includes feedback.errors[:recipient_email], "is invalid"
  end
end
```
</pattern></invoke>

<pattern name="model-method-tests">
<description>Testing model methods and behavior</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "recent scope returns feedbacks from last 7 days" do
    results = Feedback.recent
    assert_includes results, feedbacks(:recent)
    refute_includes results, feedbacks(:old)
  end

  test "mark_as_read! updates read_at timestamp" do
    feedback = feedbacks(:unread)
    assert_nil feedback.read_at
    feedback.mark_as_read!
    assert_not_nil feedback.reload.read_at
  end
end
```
</pattern>

## Controller Testing

<pattern name="controller-action-tests">
<description>Testing controller actions and responses</description>

```ruby
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "GET index returns success" do
    get feedbacks_url
    assert_response :success
  end

  test "GET show displays feedback" do
    get feedback_url(feedbacks(:one))
    assert_response :success
  end

  test "POST create with valid params creates feedback" do
    assert_difference("Feedback.count", 1) do
      post feedbacks_url, params: { feedback: { content: "New feedback", recipient_email: "test@example.com" } }
    end
    assert_redirected_to feedback_url(Feedback.last)
  end

  test "POST create with invalid params does not create feedback" do
    assert_no_difference("Feedback.count") do
      post feedbacks_url, params: { feedback: { content: nil } }
    end
    assert_response :unprocessable_entity
  end

  test "DELETE destroy removes feedback" do
    assert_difference("Feedback.count", -1) do
      delete feedback_url(feedbacks(:one))
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
require "application_system_test_case"

class FeedbacksTest < ApplicationSystemTestCase
  test "creating a feedback" do
    visit feedbacks_url
    click_on "New Feedback"
    fill_in "Content", with: "This is great feedback"
    fill_in "Recipient email", with: "user@example.com"
    click_on "Create Feedback"

    assert_text "Feedback was successfully created"
  end

  test "editing a feedback" do
    visit feedback_url(feedbacks(:one))
    click_on "Edit"
    fill_in "Content", with: "Updated content"
    click_on "Update Feedback"

    assert_text "Feedback was successfully updated"
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
# ❌ BAD - Code written first, then tests
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - RED-GREEN-REFACTOR cycle
# 1. Write failing test
# 2. Write minimal code to pass
# 3. Refactor
```
</good-example>
</antipattern>

<antipattern>
<description>Testing multiple concerns in one test</description>
<reason>Makes tests harder to debug when they fail</reason>
<bad-example>
```ruby
# ❌ BAD - Multiple validations in one test
test "feedback validations" do
  feedback = Feedback.new
  assert_not feedback.valid?
  assert_includes feedback.errors[:content], "can't be blank"
  assert_includes feedback.errors[:email], "can't be blank"
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - One concern per test
test "is invalid without content" do
  feedback = Feedback.new(content: nil)
  assert_not feedback.valid?
  assert_includes feedback.errors[:content], "can't be blank"
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
  user = User.create!(email: "test@example.com")
  feedback = Feedback.create!(content: "Test", user: user)
  assert_equal user, feedback.user
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use fixtures
# test/fixtures/users.yml: alice: { email: alice@example.com }
# test/fixtures/feedbacks.yml: one: { content: "Great!", user: alice }

test "feedback belongs to user" do
  assert_equal users(:alice), feedbacks(:one).user
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/feedback_test.rb

# Run specific test by line number
rails test test/models/feedback_test.rb:12

# Run tests matching pattern
rails test -n /validation/

# Run in parallel (faster)
rails test --parallel
```
</testing>

<related-skills>
- fixtures-test-data - Using fixtures effectively
- minitest-mocking - Stubbing and mocking
- viewcomponent-testing - Testing ViewComponents
</related-skills>

<resources>
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Minitest Documentation](https://github.com/minitest/minitest)
- [Minitest Assertions](https://docs.seattlerb.org/minitest/Minitest/Assertions.html)
</resources>
