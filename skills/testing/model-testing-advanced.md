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
- Ensuring proper error handling
- Testing enum states and transitions
- Verifying custom validators
</when-to-use>

<benefits>
- **Comprehensive Coverage** - Tests all aspects of model behavior
- **Regression Prevention** - Catches breaking changes early
- **Documentation** - Tests serve as executable specifications
- **Confidence** - Deploy with certainty that models work correctly
- **Edge Case Detection** - Uncovers boundary conditions and errors
- **Refactoring Safety** - Change implementation without breaking behavior
</benefits>

<standards>
- Test ALL validations (presence, format, length, numericality, uniqueness)
- Test ALL associations and their options
- Test ALL scopes with edge cases (empty results, boundary conditions)
- Test ALL callbacks and their side effects
- Test error conditions and exceptions
- Use fixtures for consistent test data
- Use descriptive test names that explain expected behavior
- Test one concept per test method
- Keep tests fast (no external API calls without mocking)
</standards>

## Testing Validations

<pattern name="presence-validations">
<description>Test required fields are validated</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "valid with all required attributes" do
    feedback = Feedback.new(
      content: "This is constructive feedback that meets the minimum length requirement of 50 characters",
      recipient_email: "user@example.com",
      status: "pending"
    )

    assert feedback.valid?
  end

  test "invalid without content" do
    feedback = Feedback.new(
      recipient_email: "user@example.com",
      status: "pending"
    )

    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end

  test "invalid without recipient_email" do
    feedback = Feedback.new(
      content: "Valid content that is more than fifty characters long for testing",
      status: "pending"
    )

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
  test "valid with properly formatted email" do
    feedback = Feedback.new(
      content: "Valid content with minimum length of fifty characters for testing",
      recipient_email: "user@example.com"
    )

    assert feedback.valid?
  end

  test "invalid with malformed email" do
    invalid_emails = [
      "not-an-email",
      "@example.com",
      "user@",
      "user name@example.com",
      "user@example",
      ""
    ]

    invalid_emails.each do |invalid_email|
      feedback = Feedback.new(
        content: "Valid content with minimum length of fifty characters for testing",
        recipient_email: invalid_email
      )

      assert_not feedback.valid?, "#{invalid_email.inspect} should be invalid"
      assert_includes feedback.errors[:recipient_email], "is invalid"
    end
  end

  test "valid with edge case emails" do
    valid_emails = [
      "user+tag@example.com",
      "user.name@example.co.uk",
      "123@example.com"
    ]

    valid_emails.each do |valid_email|
      feedback = Feedback.new(
        content: "Valid content with minimum length of fifty characters for testing",
        recipient_email: valid_email
      )

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
    feedback = Feedback.new(
      content: "Too short",  # Less than 50 characters
      recipient_email: "user@example.com"
    )

    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "is too short (minimum is 50 characters)"
  end

  test "valid with content at exactly minimum length" do
    feedback = Feedback.new(
      content: "a" * 50,  # Exactly 50 characters
      recipient_email: "user@example.com"
    )

    assert feedback.valid?
  end

  test "invalid with content above maximum length" do
    feedback = Feedback.new(
      content: "a" * 5001,  # More than 5000 characters
      recipient_email: "user@example.com"
    )

    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "is too long (maximum is 5000 characters)"
  end

  test "valid with content at exactly maximum length" do
    feedback = Feedback.new(
      content: "a" * 5000,  # Exactly 5000 characters
      recipient_email: "user@example.com"
    )

    assert feedback.valid?
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
    allowed_statuses = %w[pending delivered read responded]

    allowed_statuses.each do |status|
      feedback = Feedback.new(
        content: "Valid content with minimum length of fifty characters for testing",
        recipient_email: "user@example.com",
        status: status
      )

      assert feedback.valid?, "#{status.inspect} should be valid"
    end
  end

  test "invalid with disallowed status value" do
    feedback = Feedback.new(
      content: "Valid content with minimum length of fifty characters for testing",
      recipient_email: "user@example.com",
      status: "invalid_status"
    )

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
    existing_user = users(:alice)  # From fixtures

    new_user = User.new(
      name: "Bob",
      email: existing_user.email  # Duplicate email
    )

    assert_not new_user.valid?
    assert_includes new_user.errors[:email], "has already been taken"
  end

  test "valid with unique email" do
    user = User.new(
      name: "Charlie",
      email: "charlie@example.com"  # Unique email
    )

    assert user.valid?
  end

  test "uniqueness validation is case insensitive" do
    existing_user = users(:alice)  # email: alice@example.com

    new_user = User.new(
      name: "Bob",
      email: existing_user.email.upcase  # ALICE@EXAMPLE.COM
    )

    assert_not new_user.valid?
    assert_includes new_user.errors[:email], "has already been taken"
  end
end
```
</pattern>

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
    if offensive_words.any? { |word| content.downcase.include?(word) }
      errors.add(:content, "must be constructive and professional")
    end
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "invalid with offensive language in content" do
    feedback = Feedback.new(
      content: "This is a stupid idea that no one should follow or implement",
      recipient_email: "user@example.com"
    )

    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "must be constructive and professional"
  end

  test "valid with constructive professional content" do
    feedback = Feedback.new(
      content: "This approach could be improved by considering alternative implementations",
      recipient_email: "user@example.com"
    )

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
    feedback = Feedback.new(
      content: "Valid content with minimum length of fifty characters for testing",
      recipient_email: "user@example.com",
      recipient: nil  # No recipient
    )

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
    association = Feedback.reflect_on_association(:abuse_reports)

    assert_equal :has_many, association.macro
  end

  test "destroying feedback destroys associated abuse reports" do
    feedback = feedbacks(:one)

    # Create abuse reports
    3.times do
      feedback.abuse_reports.create!(
        reason: "spam",
        reporter_email: "reporter@example.com"
      )
    end

    report_ids = feedback.abuse_reports.pluck(:id)

    assert_difference "AbuseReport.count", -3 do
      feedback.destroy
    end

    # Verify reports are destroyed
    report_ids.each do |id|
      assert_not AbuseReport.exists?(id)
    end
  end

  test "feedback has zero abuse reports by default" do
    feedback = Feedback.create!(
      content: "Valid content with minimum length of fifty characters for testing",
      recipient_email: "user@example.com"
    )

    assert_empty feedback.abuse_reports
    assert_equal 0, feedback.abuse_reports.count
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
    response = FeedbackResponse.create!(
      feedback: feedback,
      content: "Thank you for the feedback"
    )

    response_id = response.id

    assert_difference "FeedbackResponse.count", -1 do
      feedback.destroy
    end

    assert_not FeedbackResponse.exists?(response_id)
  end

  test "can create response through association" do
    feedback = feedbacks(:one)

    response = feedback.create_response!(
      content: "Thank you for the feedback"
    )

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
    # Create old feedback (outside 30 days)
    old_feedback = Feedback.create!(
      content: "Old feedback that is more than fifty characters long for testing",
      recipient_email: "old@example.com",
      created_at: 31.days.ago
    )

    # Create recent feedback (within 30 days)
    recent_feedback = Feedback.create!(
      content: "Recent feedback that is more than fifty characters for testing",
      recipient_email: "recent@example.com",
      created_at: 10.days.ago
    )

    results = Feedback.recent

    assert_includes results, recent_feedback
    assert_not_includes results, old_feedback
  end

  test "recent scope returns empty when no recent feedbacks" do
    Feedback.destroy_all

    # Create only old feedback
    Feedback.create!(
      content: "Old feedback that is more than fifty characters long for testing",
      recipient_email: "old@example.com",
      created_at: 31.days.ago
    )

    assert_empty Feedback.recent
  end

  test "recent scope includes feedback created exactly 30 days ago" do
    feedback = Feedback.create!(
      content: "Boundary feedback that is more than fifty characters for testing",
      recipient_email: "boundary@example.com",
      created_at: 30.days.ago
    )

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
    pending = Feedback.create!(
      content: "Pending feedback with more than fifty characters for testing",
      recipient_email: "pending@example.com",
      status: "pending"
    )

    delivered = Feedback.create!(
      content: "Delivered feedback with more than fifty characters for testing",
      recipient_email: "delivered@example.com",
      status: "delivered"
    )

    read = Feedback.create!(
      content: "Read feedback with more than fifty characters for testing",
      recipient_email: "read@example.com",
      status: "read"
    )

    unread_feedbacks = Feedback.unread

    assert_includes unread_feedbacks, delivered
    assert_not_includes unread_feedbacks, pending
    assert_not_includes unread_feedbacks, read
  end

  test "unread scope returns empty when no delivered feedbacks" do
    Feedback.destroy_all

    Feedback.create!(
      content: "Read feedback with more than fifty characters for testing",
      recipient_email: "read@example.com",
      status: "read"
    )

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
    alice_feedback = Feedback.create!(
      content: "Feedback for Alice with more than fifty characters for testing",
      recipient_email: "alice@example.com"
    )

    bob_feedback = Feedback.create!(
      content: "Feedback for Bob with more than fifty characters for testing",
      recipient_email: "bob@example.com"
    )

    alice_feedbacks = Feedback.by_recipient("alice@example.com")

    assert_includes alice_feedbacks, alice_feedback
    assert_not_includes alice_feedbacks, bob_feedback
  end

  test "by_recipient scope returns empty for non-existent email" do
    results = Feedback.by_recipient("nonexistent@example.com")

    assert_empty results
  end

  test "by_recipient scope is case sensitive" do
    feedback = Feedback.create!(
      content: "Case sensitive feedback with more than fifty characters for testing",
      recipient_email: "alice@example.com"
    )

    # Different case should not match
    results = Feedback.by_recipient("ALICE@EXAMPLE.COM")

    assert_empty results
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
    # Create various feedbacks
    recent_unread = Feedback.create!(
      content: "Recent unread with more than fifty characters for testing",
      recipient_email: "alice@example.com",
      status: "delivered",
      created_at: 5.days.ago
    )

    old_unread = Feedback.create!(
      content: "Old unread with more than fifty characters for testing",
      recipient_email: "alice@example.com",
      status: "delivered",
      created_at: 35.days.ago
    )

    recent_read = Feedback.create!(
      content: "Recent read with more than fifty characters for testing",
      recipient_email: "alice@example.com",
      status: "read",
      created_at: 5.days.ago
    )

    # Chain scopes
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
      Feedback.create!(
        content: "New feedback with more than fifty characters for testing",
        recipient_email: "user@example.com"
      )
    end
  end

  test "does not enqueue job when creation fails" do
    assert_no_enqueued_jobs do
      feedback = Feedback.new(content: nil)  # Invalid
      feedback.save  # Returns false
    end
  end

  test "passes correct arguments to job" do
    feedback = Feedback.create!(
      content: "New feedback with more than fifty characters for testing",
      recipient_email: "user@example.com"
    )

    assert_enqueued_with(
      job: SendFeedbackJob,
      args: [feedback.id]
    )
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
    feedback = Feedback.create!(
      content: "<script>alert('xss')</script>Valid feedback with minimum length",
      recipient_email: "user@example.com"
    )

    assert_not_includes feedback.content, "<script>"
    assert_includes feedback.content, "Valid feedback"
  end

  test "preserves plain text content" do
    plain_text = "Simple feedback with no HTML and more than fifty characters"

    feedback = Feedback.create!(
      content: plain_text,
      recipient_email: "user@example.com"
    )

    assert_equal plain_text, feedback.content
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
      feedback.update!(content: "Updated content with fifty characters minimum")
    end
  end

  test "does not send notification on creation" do
    assert_no_enqueued_emails do
      Feedback.create!(
        content: "New feedback with more than fifty characters for testing",
        recipient_email: "user@example.com",
        status: "pending"
      )
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
    where(status: "delivered")
      .where("delivered_at < ?", 7.days.ago)
      .where.missing(:response)
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "needs_followup returns delivered feedbacks without response" do
    # Create feedback needing followup
    needs_followup = Feedback.create!(
      content: "Needs followup with more than fifty characters for testing",
      recipient_email: "user@example.com",
      status: "delivered",
      delivered_at: 10.days.ago
    )

    # Create feedback not needing followup (has response)
    with_response = Feedback.create!(
      content: "Has response with more than fifty characters for testing",
      recipient_email: "user@example.com",
      status: "delivered",
      delivered_at: 10.days.ago
    )
    with_response.create_response!(content: "Thank you")

    # Create feedback not needing followup (too recent)
    too_recent = Feedback.create!(
      content: "Too recent with more than fifty characters for testing",
      recipient_email: "user@example.com",
      status: "delivered",
      delivered_at: 3.days.ago
    )

    results = Feedback.needs_followup

    assert_includes results, needs_followup
    assert_not_includes results, with_response
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
    joins(:response)
      .average("EXTRACT(EPOCH FROM (feedback_responses.created_at - feedbacks.created_at))")
      .to_i
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "average_response_time calculates correct average" do
    # Create feedback with 1 day response time
    feedback1 = Feedback.create!(
      content: "First feedback with more than fifty characters for testing",
      recipient_email: "user@example.com",
      created_at: 5.days.ago
    )
    feedback1.create_response!(
      content: "Response 1",
      created_at: 4.days.ago
    )

    # Create feedback with 2 day response time
    feedback2 = Feedback.create!(
      content: "Second feedback with more than fifty characters for testing",
      recipient_email: "user@example.com",
      created_at: 5.days.ago
    )
    feedback2.create_response!(
      content: "Response 2",
      created_at: 3.days.ago
    )

    # Average should be 1.5 days = 129600 seconds
    average = Feedback.average_response_time

    assert_in_delta 129600, average, 60  # Allow 60 second variance
  end

  test "average_response_time returns nil when no responses" do
    Feedback.destroy_all

    Feedback.create!(
      content: "No response feedback with more than fifty characters for testing",
      recipient_email: "user@example.com"
    )

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

    # Reload from database
    feedback.reload

    assert_equal "delivered", feedback.status
    assert_not_nil feedback.delivered_at
  end

  test "mark_as_delivered! raises error if save fails" do
    feedback = feedbacks(:pending)

    # Stub valid? to return false
    feedback.stub(:valid?, false) do
      assert_raises(ActiveRecord::RecordInvalid) do
        feedback.mark_as_delivered!
      end
    end
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
    feedback = Feedback.create!(
      content: "Test feedback with more than fifty characters for testing",
      recipient_email: "alice@example.com"
    )

    assert feedback.readable_by?("alice@example.com")
  end

  test "readable_by? returns false for non-matching email" do
    feedback = Feedback.create!(
      content: "Test feedback with more than fifty characters for testing",
      recipient_email: "alice@example.com"
    )

    assert_not feedback.readable_by?("bob@example.com")
  end

  test "readable_by? is case sensitive" do
    feedback = Feedback.create!(
      content: "Test feedback with more than fifty characters for testing",
      recipient_email: "alice@example.com"
    )

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
    feedback = Feedback.create!(
      content: "Test feedback with more than fifty characters for testing",
      recipient_email: "user@example.com",
      status: "pending"
    )

    assert feedback.status_pending?
    assert_not feedback.status_delivered?
    assert_not feedback.status_read?
    assert_not feedback.status_responded?
  end

  test "enum provides bang methods to change state" do
    feedback = feedbacks(:pending)

    feedback.status_delivered!

    assert feedback.status_delivered?
    assert_equal "delivered", feedback.status
  end

  test "can query by enum state" do
    pending = Feedback.create!(
      content: "Pending feedback with more than fifty characters for testing",
      recipient_email: "user@example.com",
      status: "pending"
    )

    delivered = Feedback.create!(
      content: "Delivered feedback with more than fifty characters for testing",
      recipient_email: "user@example.com",
      status: "delivered"
    )

    pending_feedbacks = Feedback.status_pending

    assert_includes pending_feedbacks, pending
    assert_not_includes pending_feedbacks, delivered
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
    feedback = Feedback.create!(
      content: "Feedback with no reports and fifty characters for testing",
      recipient_email: "user@example.com"
    )

    assert_empty feedback.abuse_reports
    assert_equal 0, feedback.abuse_reports.count
    assert_nothing_raised do
      feedback.abuse_reports.each { |report| puts report }
    end
  end

  test "handles nil associations gracefully" do
    feedback = Feedback.create!(
      content: "Feedback with no recipient and fifty characters for testing",
      recipient_email: "user@example.com",
      recipient: nil
    )

    assert_nil feedback.recipient
    assert_nothing_raised do
      feedback.recipient&.name
    end
  end

  test "handles unicode content correctly" do
    unicode_content = "Emoji feedback 😀 with unicode 日本語 and fifty+ characters"

    feedback = Feedback.create!(
      content: unicode_content,
      recipient_email: "user@example.com"
    )

    assert_equal unicode_content, feedback.reload.content
  end

  test "handles maximum length content" do
    max_content = "a" * 5000

    feedback = Feedback.create!(
      content: max_content,
      recipient_email: "user@example.com"
    )

    assert_equal 5000, feedback.reload.content.length
  end
end
```
</pattern>

<pattern name="error-handling">
<description>Test proper error handling and exception cases</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "handles database constraint violations gracefully" do
    # Assuming unique constraint on recipient_email + created_at
    feedback1 = Feedback.create!(
      content: "First feedback with more than fifty characters for testing",
      recipient_email: "user@example.com"
    )

    feedback2 = Feedback.new(
      content: "Duplicate feedback with more than fifty characters testing",
      recipient_email: "user@example.com",
      created_at: feedback1.created_at
    )

    assert_raises(ActiveRecord::RecordNotUnique) do
      feedback2.save(validate: false)  # Bypass validations to hit DB constraint
    end
  end

  test "handles nil arguments in query methods" do
    feedback = feedbacks(:one)

    assert_nothing_raised do
      result = feedback.readable_by?(nil)
      assert_not result
    end
  end

  test "handles malformed data gracefully" do
    feedback = Feedback.new(
      content: "Valid content with more than fifty characters for testing",
      recipient_email: "user@example.com"
    )

    # Manually set invalid data bypassing validations
    feedback.save(validate: false)
    feedback.update_column(:status, "invalid_status")

    # Should handle gracefully when reloading
    assert_nothing_raised do
      feedback.reload
      feedback.status
    end
  end
end
```
</pattern>

<pattern name="race-conditions">
<description>Test concurrent access and race condition handling</description>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "handles optimistic locking conflicts" do
    # Assuming model uses lock_version for optimistic locking
    skip "Enable if using optimistic locking" unless Feedback.column_names.include?("lock_version")

    feedback1 = Feedback.create!(
      content: "Concurrent feedback with more than fifty characters for testing",
      recipient_email: "user@example.com"
    )

    # Load same record twice
    feedback_copy1 = Feedback.find(feedback1.id)
    feedback_copy2 = Feedback.find(feedback1.id)

    # Update first copy
    feedback_copy1.update!(status: "delivered")

    # Try to update second copy (should raise error)
    assert_raises(ActiveRecord::StaleObjectError) do
      feedback_copy2.update!(status: "read")
    end
  end

  test "handles concurrent counter updates" do
    feedback = feedbacks(:one)

    # Simulate concurrent updates
    threads = 5.times.map do
      Thread.new do
        feedback.abuse_reports.create!(
          reason: "spam",
          reporter_email: "reporter@example.com"
        )
      end
    end

    threads.each(&:join)

    assert_equal 5, feedback.reload.abuse_reports.count
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Testing multiple validations in one test</description>
<reason>Makes tests hard to debug when they fail - unclear which validation failed</reason>
<bad-example>
```ruby
# ❌ BAD - Multiple validations in one test
test "validates all required fields" do
  feedback = Feedback.new

  assert_not feedback.valid?
  assert_includes feedback.errors[:content], "can't be blank"
  assert_includes feedback.errors[:recipient_email], "can't be blank"
  assert_includes feedback.errors[:status], "can't be blank"
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - One validation per test
test "invalid without content" do
  feedback = Feedback.new(
    recipient_email: "user@example.com",
    status: "pending"
  )

  assert_not feedback.valid?
  assert_includes feedback.errors[:content], "can't be blank"
end

test "invalid without recipient_email" do
  feedback = Feedback.new(
    content: "Valid content with fifty characters",
    status: "pending"
  )

  assert_not feedback.valid?
  assert_includes feedback.errors[:recipient_email], "can't be blank"
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not testing edge cases and boundaries</description>
<reason>Bugs often occur at boundaries - must test min, max, empty, nil</reason>
<bad-example>
```ruby
# ❌ BAD - Only testing typical cases
test "valid with content" do
  feedback = Feedback.new(
    content: "This is good feedback",
    recipient_email: "user@example.com"
  )

  assert feedback.valid?
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Testing boundaries
test "valid with minimum length content" do
  feedback = Feedback.new(
    content: "a" * 50,  # Exactly minimum
    recipient_email: "user@example.com"
  )

  assert feedback.valid?
end

test "invalid with below minimum length content" do
  feedback = Feedback.new(
    content: "a" * 49,  # One below minimum
    recipient_email: "user@example.com"
  )

  assert_not feedback.valid?
end

test "valid with maximum length content" do
  feedback = Feedback.new(
    content: "a" * 5000,  # Exactly maximum
    recipient_email: "user@example.com"
  )

  assert feedback.valid?
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not testing callback side effects</description>
<reason>Callbacks modify state - must verify they execute correctly</reason>
<bad-example>
```ruby
# ❌ BAD - Not testing job enqueuing
test "creates feedback" do
  feedback = Feedback.create!(
    content: "New feedback with fifty characters",
    recipient_email: "user@example.com"
  )

  assert feedback.persisted?
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Testing callback side effect
test "enqueues delivery job after creation" do
  assert_enqueued_with(job: SendFeedbackJob) do
    Feedback.create!(
      content: "New feedback with more than fifty characters for testing",
      recipient_email: "user@example.com"
    )
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not testing scope chainability</description>
<reason>Scopes should be composable - test they work together</reason>
<bad-example>
```ruby
# ❌ BAD - Only testing scopes in isolation
test "recent scope works" do
  results = Feedback.recent
  assert results.any?
end

test "unread scope works" do
  results = Feedback.unread
  assert results.any?
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Testing scope chaining
test "can chain recent and unread scopes" do
  recent_unread = Feedback.create!(
    content: "Recent unread with fifty characters",
    recipient_email: "user@example.com",
    status: "delivered",
    created_at: 5.days.ago
  )

  old_unread = Feedback.create!(
    content: "Old unread with fifty characters",
    recipient_email: "user@example.com",
    status: "delivered",
    created_at: 35.days.ago
  )

  results = Feedback.recent.unread

  assert_includes results, recent_unread
  assert_not_includes results, old_unread
end
```
</good-example>
</antipattern>

<antipattern>
<description>Testing implementation instead of behavior</description>
<reason>Tests should verify what happens, not how it happens</reason>
<bad-example>
```ruby
# ❌ BAD - Testing implementation details
test "mark_as_delivered! calls update! with correct hash" do
  feedback = feedbacks(:pending)

  feedback.expects(:update!).with(
    status: :delivered,
    delivered_at: Time.current
  )

  feedback.mark_as_delivered!
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Testing behavior
test "mark_as_delivered! updates status and timestamp" do
  feedback = feedbacks(:pending)

  feedback.mark_as_delivered!

  assert_equal "delivered", feedback.reload.status
  assert_not_nil feedback.delivered_at
  assert_in_delta Time.current, feedback.delivered_at, 1.second
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Run advanced model tests with focused execution:

```bash
# Run all model tests
rails test test/models/

# Run specific model test file
rails test test/models/feedback_test.rb

# Run specific test by line number
rails test test/models/feedback_test.rb:145

# Run tests matching pattern
rails test test/models/feedback_test.rb -n /validation/

# Run with verbose output
rails test test/models/feedback_test.rb --verbose

# Check test coverage (requires simplecov gem)
COVERAGE=true rails test test/models/
```

Verify test quality:
```ruby
# Check test covers all code paths
# - Every validation should have at least 2 tests (valid and invalid)
# - Every association should have tests for behavior and dependent options
# - Every scope should test normal case, edge case, and empty result
# - Every callback should test side effects and conditional execution
# - Every public method should test success, failure, and edge cases
```
</testing>

<related-skills>
- tdd-minitest - TDD workflow basics
- fixtures-test-data - Using fixtures effectively
- minitest-mocking - Stubbing and mocking
- activerecord-patterns - Model design patterns
- activerecord-associations - Association configuration
- activerecord-validations - Validation patterns
</related-skills>

<resources>
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Minitest Documentation](https://github.com/minitest/minitest)
- [Better Specs](https://www.betterspecs.org/)
- [Testing Rails](https://testing-rails.thoughtbot.com/)
</resources>
