---
name: model-testing-advanced
domain: testing
dependencies: [activerecord-patterns, tdd-minitest]
version: 1.0
rails_version: 8.1+
---

# Advanced Model Testing

Comprehensive testing patterns for ActiveRecord models including associations, validations, scopes, callbacks, class methods, edge cases, and error handling.

<when-to-use>
- Testing complex models with multiple validations
- Verifying associations and their options (dependent: :destroy, optional: true, etc.)
- Testing scopes with various conditions and edge cases
- Validating callback behavior and side effects
- Testing class methods and business logic
- Testing enum states and transitions
</when-to-use>

<benefits>
- **Comprehensive Coverage** - Tests all aspects of model behavior
- **Regression Prevention** - Catches breaking changes early
- **Documentation** - Tests serve as executable specifications
- **Edge Case Detection** - Uncovers boundary conditions and errors
</benefits>

<standards>
- Test ALL validations, associations, scopes, and callbacks
- Test edge cases (empty results, boundary conditions)
- Use fixtures for consistent test data
- Use descriptive test names that explain expected behavior
- Test one concept per test method
</standards>

## Testing Validations

<pattern name="presence-validations">
<description>Test required fields are validated</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "valid with all required attributes" do
    feedback = Feedback.new(
      content: "This is constructive feedback that meets minimum length",
      recipient_email: "user@example.com", status: "pending"
    )
    assert feedback.valid?
  end

  test "invalid without content" do
    feedback = Feedback.new(recipient_email: "user@example.com", status: "pending")
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end

  test "invalid without recipient_email" do
    feedback = Feedback.new(content: "Valid content with fifty characters", status: "pending")
    assert_not feedback.valid?
    assert_includes feedback.errors[:recipient_email], "can't be blank"
  end
end
```
</pattern>

<pattern name="format-validations">
<description>Test format validations like email, URL, phone number</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "invalid with malformed email" do
    invalid_emails = ["not-an-email", "@example.com", "user@", "user name@example.com"]

    invalid_emails.each do |invalid_email|
      feedback = Feedback.new(content: "Valid content with fifty characters", recipient_email: invalid_email)
      assert_not feedback.valid?, "#{invalid_email.inspect} should be invalid"
      assert_includes feedback.errors[:recipient_email], "is invalid"
    end
  end

  test "valid with edge case emails" do
    valid_emails = ["user+tag@example.com", "user.name@example.co.uk", "123@example.com"]

    valid_emails.each do |valid_email|
      feedback = Feedback.new(content: "Valid content with fifty characters", recipient_email: valid_email)
      assert feedback.valid?, "#{valid_email.inspect} should be valid"
    end
  end
end
```
</pattern>

<pattern name="length-validations">
<description>Test minimum and maximum length constraints</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "invalid with content below minimum length" do
    feedback = Feedback.new(content: "Too short", recipient_email: "user@example.com")
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "is too short (minimum is 50 characters)"
  end

  test "valid at exactly minimum and maximum length" do
    assert Feedback.new(content: "a" * 50, recipient_email: "user@example.com").valid?
    assert Feedback.new(content: "a" * 5000, recipient_email: "user@example.com").valid?
  end

  test "invalid above maximum length" do
    feedback = Feedback.new(content: "a" * 5001, recipient_email: "user@example.com")
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "is too long (maximum is 5000 characters)"
  end
end
```
</pattern>

<pattern name="inclusion-validations">
<description>Test values are restricted to specific set</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "valid with allowed status values" do
    %w[pending delivered read responded].each do |status|
      feedback = Feedback.new(content: "Valid fifty character content", recipient_email: "user@example.com", status: status)
      assert feedback.valid?, "#{status.inspect} should be valid"
    end
  end

  test "invalid with disallowed status value" do
    feedback = Feedback.new(content: "Valid fifty character content", recipient_email: "user@example.com", status: "invalid")
    assert_not feedback.valid?
    assert_includes feedback.errors[:status], "is not included in the list"
  end
end
```
</pattern>

<pattern name="uniqueness-validations">
<description>Test uniqueness constraints with scopes</description>

```ruby
# test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "invalid with duplicate email" do
    existing = users(:alice)
    new_user = User.new(name: "Bob", email: existing.email)
    assert_not new_user.valid?
    assert_includes new_user.errors[:email], "has already been taken"
  end

  test "uniqueness validation is case insensitive" do
    existing = users(:alice)
    new_user = User.new(name: "Bob", email: existing.email.upcase)
    assert_not new_user.valid?
    assert_includes new_user.errors[:email], "has already been taken"
  end
end
```
</pattern>
</invoke>

<pattern name="custom-validations">
<description>Test custom validation methods</description>

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  validate :content_must_be_constructive

  private
  def content_must_be_constructive
    return if content.blank?
    offensive_words = %w[stupid idiot dumb]
    errors.add(:content, "must be constructive") if offensive_words.any? { |w| content.downcase.include?(w) }
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "invalid with offensive language" do
    feedback = Feedback.new(content: "This is stupid and should not be implemented", recipient_email: "user@example.com")
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "must be constructive"
  end

  test "valid with constructive content" do
    feedback = Feedback.new(content: "This could be improved by considering alternatives", recipient_email: "user@example.com")
    assert feedback.valid?
  end
end
```
</pattern>

## Testing Associations

<pattern name="belongs-to-associations">
<description>Test belongs_to relationships and options</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "belongs to recipient" do
    association = Feedback.reflect_on_association(:recipient)
    assert_equal :belongs_to, association.macro
    assert_equal "User", association.class_name
  end

  test "recipient association is optional" do
    feedback = Feedback.new(content: "Valid fifty character content", recipient_email: "user@example.com", recipient: nil)
    assert feedback.valid?
  end

  test "can access recipient through association" do
    feedback = feedbacks(:one)
    user = users(:alice)
    feedback.update!(recipient: user)
    assert_equal user, feedback.recipient
    assert_equal user.id, feedback.recipient_id
  end
end
```
</pattern>

<pattern name="has-many-associations">
<description>Test has_many relationships and dependent options</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "has many abuse reports" do
    assert_equal :has_many, Feedback.reflect_on_association(:abuse_reports).macro
  end

  test "destroying feedback destroys associated abuse reports" do
    feedback = feedbacks(:one)
    3.times { feedback.abuse_reports.create!(reason: "spam", reporter_email: "reporter@example.com") }

    assert_difference "AbuseReport.count", -3 do
      feedback.destroy
    end
  end

  test "feedback has zero abuse reports by default" do
    feedback = Feedback.create!(content: "Valid fifty character content", recipient_email: "user@example.com")
    assert_empty feedback.abuse_reports
  end
end
```
</pattern>

<pattern name="has-one-associations">
<description>Test has_one relationships and dependent options</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "has one response" do
    association = Feedback.reflect_on_association(:response)
    assert_equal :has_one, association.macro
    assert_equal "FeedbackResponse", association.class_name
  end

  test "destroying feedback destroys associated response" do
    feedback = feedbacks(:one)
    response = FeedbackResponse.create!(feedback: feedback, content: "Thank you")

    assert_difference "FeedbackResponse.count", -1 do
      feedback.destroy
    end
    assert_not FeedbackResponse.exists?(response.id)
  end

  test "can create response through association" do
    feedback = feedbacks(:one)
    response = feedback.create_response!(content: "Thank you")
    assert_equal feedback, response.feedback
    assert_equal response, feedback.reload.response
  end
end
```
</pattern>

## Testing Scopes

<pattern name="time-based-scopes">
<description>Test scopes with time conditions</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "recent scope returns feedbacks from last 30 days" do
    old = Feedback.create!(content: "Old fifty character feedback", recipient_email: "old@example.com", created_at: 31.days.ago)
    recent = Feedback.create!(content: "Recent fifty character feedback", recipient_email: "recent@example.com", created_at: 10.days.ago)

    results = Feedback.recent
    assert_includes results, recent
    assert_not_includes results, old
  end

  test "recent scope returns empty when no recent feedbacks" do
    Feedback.destroy_all
    Feedback.create!(content: "Old fifty character feedback", recipient_email: "old@example.com", created_at: 31.days.ago)
    assert_empty Feedback.recent
  end

  test "recent scope includes boundary (exactly 30 days)" do
    feedback = Feedback.create!(content: "Boundary fifty character feedback", recipient_email: "b@example.com", created_at: 30.days.ago)
    assert_includes Feedback.recent, feedback
  end
end
```
</pattern>

<pattern name="status-based-scopes">
<description>Test scopes filtering by status or state</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "unread scope returns only delivered feedbacks" do
    pending = Feedback.create!(content: "Pending fifty characters", recipient_email: "p@example.com", status: "pending")
    delivered = Feedback.create!(content: "Delivered fifty characters", recipient_email: "d@example.com", status: "delivered")
    read = Feedback.create!(content: "Read fifty characters", recipient_email: "r@example.com", status: "read")

    unread = Feedback.unread
    assert_includes unread, delivered
    assert_not_includes unread, pending
    assert_not_includes unread, read
  end

  test "unread scope returns empty when no delivered feedbacks" do
    Feedback.destroy_all
    Feedback.create!(content: "Read fifty characters", recipient_email: "r@example.com", status: "read")
    assert_empty Feedback.unread
  end
end
```
</pattern>

<pattern name="parameterized-scopes">
<description>Test scopes that accept parameters</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "by_recipient scope filters by email" do
    alice = Feedback.create!(content: "Alice fifty characters", recipient_email: "alice@example.com")
    bob = Feedback.create!(content: "Bob fifty characters", recipient_email: "bob@example.com")

    results = Feedback.by_recipient("alice@example.com")
    assert_includes results, alice
    assert_not_includes results, bob
  end

  test "by_recipient scope returns empty for non-existent email" do
    assert_empty Feedback.by_recipient("nonexistent@example.com")
  end

  test "by_recipient scope is case sensitive" do
    Feedback.create!(content: "Case fifty characters", recipient_email: "alice@example.com")
    assert_empty Feedback.by_recipient("ALICE@EXAMPLE.COM")
  end
end
```
</pattern>

<pattern name="chaining-scopes">
<description>Test that scopes can be chained together</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "scopes can be chained together" do
    recent_unread = Feedback.create!(content: "Recent unread fifty chars", recipient_email: "alice@example.com", status: "delivered", created_at: 5.days.ago)
    old_unread = Feedback.create!(content: "Old unread fifty chars", recipient_email: "alice@example.com", status: "delivered", created_at: 35.days.ago)
    recent_read = Feedback.create!(content: "Recent read fifty chars", recipient_email: "alice@example.com", status: "read", created_at: 5.days.ago)

    results = Feedback.recent.unread.by_recipient("alice@example.com")
    assert_includes results, recent_unread
    assert_not_includes results, old_unread
    assert_not_includes results, recent_read
  end
end
```
</pattern>

## Testing Callbacks

<pattern name="after-create-callbacks">
<description>Test callbacks that run after record creation</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "enqueues delivery job after creation" do
    assert_enqueued_with(job: SendFeedbackJob) do
      Feedback.create!(content: "New fifty character feedback", recipient_email: "user@example.com")
    end
  end

  test "does not enqueue job when creation fails" do
    assert_no_enqueued_jobs do
      Feedback.new(content: nil).save
    end
  end
end
```
</pattern>

<pattern name="before-save-callbacks">
<description>Test callbacks that modify records before saving</description>

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  before_save :sanitize_content
  private
  def sanitize_content
    self.content = ActionController::Base.helpers.sanitize(content)
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "sanitizes HTML in content before save" do
    feedback = Feedback.create!(content: "<script>alert('xss')</script>Valid fifty chars", recipient_email: "user@example.com")
    assert_not_includes feedback.content, "<script>"
    assert_includes feedback.content, "Valid"
  end
end
```
</pattern>

<pattern name="after-update-callbacks">
<description>Test callbacks that run after updates</description>

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  after_update :notify_status_change, if: :saved_change_to_status?
  private
  def notify_status_change
    FeedbackStatusMailer.status_changed(self).deliver_later
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "sends notification email when status changes" do
    feedback = feedbacks(:one)
    assert_enqueued_emails 1 do
      feedback.update!(status: "read")
    end
  end

  test "does not send notification when status unchanged" do
    feedback = feedbacks(:one)
    assert_no_enqueued_emails do
      feedback.update!(content: "Updated fifty character content")
    end
  end
end
```
</pattern>

## Testing Class Methods

<pattern name="class-method-queries">
<description>Test custom class methods that query records</description>

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  def self.needs_followup
    where(status: "delivered").where("delivered_at < ?", 7.days.ago).where.missing(:response)
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "needs_followup returns delivered feedbacks without response" do
    needs = Feedback.create!(content: "Needs fifty chars", recipient_email: "user@example.com", status: "delivered", delivered_at: 10.days.ago)
    has_resp = Feedback.create!(content: "Has fifty chars", recipient_email: "user@example.com", status: "delivered", delivered_at: 10.days.ago)
    has_resp.create_response!(content: "Thank you")
    too_recent = Feedback.create!(content: "Recent fifty chars", recipient_email: "user@example.com", status: "delivered", delivered_at: 3.days.ago)

    results = Feedback.needs_followup
    assert_includes results, needs
    assert_not_includes results, has_resp
    assert_not_includes results, too_recent
  end
end
```
</pattern>

<pattern name="class-method-calculations">
<description>Test class methods that perform calculations</description>

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  def self.average_response_time
    joins(:response).average("EXTRACT(EPOCH FROM (feedback_responses.created_at - feedbacks.created_at))").to_i
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "average_response_time calculates correct average" do
    f1 = Feedback.create!(content: "First fifty chars", recipient_email: "u@example.com", created_at: 5.days.ago)
    f1.create_response!(content: "R1", created_at: 4.days.ago)
    f2 = Feedback.create!(content: "Second fifty chars", recipient_email: "u@example.com", created_at: 5.days.ago)
    f2.create_response!(content: "R2", created_at: 3.days.ago)

    assert_in_delta 129600, Feedback.average_response_time, 60
  end

  test "average_response_time returns nil when no responses" do
    Feedback.destroy_all
    Feedback.create!(content: "No response fifty chars", recipient_email: "u@example.com")
    assert_nil Feedback.average_response_time
  end
end
```
</pattern>

## Testing Instance Methods

<pattern name="state-transition-methods">
<description>Test methods that change record state</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "mark_as_delivered! updates status and timestamp" do
    feedback = feedbacks(:pending)
    assert_equal "pending", feedback.status
    assert_nil feedback.delivered_at

    feedback.mark_as_delivered!

    assert_equal "delivered", feedback.status
    assert_not_nil feedback.delivered_at
    assert_in_delta Time.current, feedback.delivered_at, 1.second
  end

  test "mark_as_delivered! persists changes to database" do
    feedback = feedbacks(:pending)
    feedback.mark_as_delivered!
    feedback.reload

    assert_equal "delivered", feedback.status
    assert_not_nil feedback.delivered_at
  end
end
```
</pattern>

<pattern name="query-methods">
<description>Test methods that return boolean or query results</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "readable_by? returns true for matching email" do
    feedback = Feedback.create!(content: "Test fifty chars", recipient_email: "alice@example.com")
    assert feedback.readable_by?("alice@example.com")
  end

  test "readable_by? returns false for non-matching email" do
    feedback = Feedback.create!(content: "Test fifty chars", recipient_email: "alice@example.com")
    assert_not feedback.readable_by?("bob@example.com")
  end

  test "readable_by? is case sensitive" do
    feedback = Feedback.create!(content: "Test fifty chars", recipient_email: "alice@example.com")
    assert_not feedback.readable_by?("ALICE@EXAMPLE.COM")
  end
end
```
</pattern>

## Testing Enums

<pattern name="enum-states">
<description>Test enum definitions and state transitions</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "defines status enum with correct values" do
    assert_equal "pending", Feedback.statuses[:status_pending]
    assert_equal "delivered", Feedback.statuses[:status_delivered]
    assert_equal "read", Feedback.statuses[:status_read]
    assert_equal "responded", Feedback.statuses[:status_responded]
  end

  test "enum provides predicate methods with prefix" do
    feedback = Feedback.create!(content: "Test fifty chars", recipient_email: "user@example.com", status: "pending")
    assert feedback.status_pending?
    assert_not feedback.status_delivered?
  end

  test "enum provides bang methods to change state" do
    feedback = feedbacks(:pending)
    feedback.status_delivered!
    assert feedback.status_delivered?
    assert_equal "delivered", feedback.status
  end

  test "can query by enum state" do
    pending = Feedback.create!(content: "Pending fifty chars", recipient_email: "u@example.com", status: "pending")
    delivered = Feedback.create!(content: "Delivered fifty chars", recipient_email: "u@example.com", status: "delivered")

    results = Feedback.status_pending
    assert_includes results, pending
    assert_not_includes results, delivered
  end
end
```
</pattern>

## Testing Edge Cases

<pattern name="boundary-conditions">
<description>Test behavior at boundaries (min/max values, empty states)</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "handles empty collections gracefully" do
    feedback = Feedback.create!(content: "Feedback fifty chars", recipient_email: "user@example.com")
    assert_empty feedback.abuse_reports
    assert_equal 0, feedback.abuse_reports.count
  end

  test "handles nil associations gracefully" do
    feedback = Feedback.create!(content: "Feedback fifty chars", recipient_email: "user@example.com", recipient: nil)
    assert_nil feedback.recipient
    assert_nothing_raised { feedback.recipient&.name }
  end

  test "handles unicode content correctly" do
    unicode = "Emoji feedback 😀 with unicode 日本語 and fifty+ characters"
    feedback = Feedback.create!(content: unicode, recipient_email: "user@example.com")
    assert_equal unicode, feedback.reload.content
  end
end
```
</pattern>

<pattern name="error-handling">
<description>Test proper error handling and exception cases</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "handles nil arguments in query methods" do
    feedback = feedbacks(:one)
    assert_nothing_raised do
      result = feedback.readable_by?(nil)
      assert_not result
    end
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Testing multiple validations in one test</description>
<bad-example>
```ruby
# ❌ BAD
test "validates all required fields" do
  feedback = Feedback.new
  assert_not feedback.valid?
  assert_includes feedback.errors[:content], "can't be blank"
  assert_includes feedback.errors[:recipient_email], "can't be blank"
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - One validation per test
test "invalid without content" do
  feedback = Feedback.new(recipient_email: "user@example.com")
  assert_not feedback.valid?
  assert_includes feedback.errors[:content], "can't be blank"
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not testing edge cases and boundaries</description>
<bad-example>
```ruby
# ❌ BAD - Only typical cases
test "valid with content" do
  assert Feedback.new(content: "Good feedback", recipient_email: "user@example.com").valid?
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Test boundaries
test "valid at exactly minimum length" do
  assert Feedback.new(content: "a" * 50, recipient_email: "user@example.com").valid?
end

test "invalid below minimum length" do
  feedback = Feedback.new(content: "a" * 49, recipient_email: "user@example.com")
  assert_not feedback.valid?
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```bash
# Run all model tests
rails test test/models/

# Run specific model test file
rails test test/models/feedback_test.rb

# Run specific test by line number
rails test test/models/feedback_test.rb:145

# Run tests matching pattern
rails test test/models/feedback_test.rb -n /validation/
```
</testing>

<related-skills>
- tdd-minitest - TDD workflow basics
- fixtures-test-data - Using fixtures effectively
- activerecord-patterns - Model design patterns
</related-skills>

<resources>
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Minitest Documentation](https://github.com/minitest/minitest)
- [Testing Rails](https://testing-rails.thoughtbot.com/)
</resources>
