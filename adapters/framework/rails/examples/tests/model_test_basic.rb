# Example: Basic Model Test with Minitest
# Reference: tests/model_test_basic

require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  # TDD Pattern: Write test FIRST, then implement

  # Test validations
  test "valid with all required attributes" do
    feedback = Feedback.new(
      content: "This is great constructive feedback that is more than 50 characters long",
      recipient_email: "user@example.com"
    )

    assert feedback.valid?
  end

  test "invalid without content" do
    feedback = Feedback.new(recipient_email: "user@example.com")

    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end

  test "invalid with short content" do
    feedback = Feedback.new(
      content: "Too short",
      recipient_email: "user@example.com"
    )

    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "is too short (minimum is 50 characters)"
  end

  test "invalid with malformed email" do
    feedback = Feedback.new(
      content: "This is valid constructive feedback that is more than 50 characters long",
      recipient_email: "not-an-email"
    )

    assert_not feedback.valid?
    assert_includes feedback.errors[:recipient_email], "is invalid"
  end

  # Test associations
  test "belongs to recipient" do
    feedback = Feedback.reflect_on_association(:recipient)

    assert_equal :belongs_to, feedback.macro
  end

  test "has one response" do
    feedback = Feedback.reflect_on_association(:response)

    assert_equal :has_one, feedback.macro
  end

  # Test scopes
  test "recent scope returns feedbacks from last 30 days" do
    old_feedback = feedbacks(:old)  # fixture from > 30 days ago
    recent_feedback = feedbacks(:recent)  # fixture from < 30 days ago

    assert_not_includes Feedback.recent, old_feedback
    assert_includes Feedback.recent, recent_feedback
  end

  # Test business logic methods
  test "mark_as_delivered updates status and delivered_at" do
    feedback = feedbacks(:pending)

    assert_equal "pending", feedback.status

    feedback.mark_as_delivered!

    assert_equal "delivered", feedback.status
    assert_not_nil feedback.delivered_at
    assert_in_delta Time.current, feedback.delivered_at, 1.second
  end

  test "readable_by returns true for matching email" do
    feedback = feedbacks(:delivered)

    assert feedback.readable_by?(feedback.recipient_email)
    assert_not feedback.readable_by?("other@example.com")
  end
end

# Key Patterns Demonstrated:
# 1. Descriptive test names
# 2. Test validations (presence, length, format)
# 3. Test associations
# 4. Test scopes with fixtures
# 5. Test business logic methods
# 6. Use of fixtures (feedbacks(:name))
# 7. Assertions: assert, assert_not, assert_includes, assert_equal, assert_in_delta
# 8. TDD: Write these tests FIRST, then implement model
