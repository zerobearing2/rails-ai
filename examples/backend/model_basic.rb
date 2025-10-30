# Example: Basic Rails Model with Validations and Associations
# Reference: backend/model_basic

class Feedback < ApplicationRecord
  # Associations
  belongs_to :recipient, class_name: "User", optional: true
  has_one :response, class_name: "FeedbackResponse", dependent: :destroy
  has_many :abuse_reports, dependent: :destroy

  # Validations
  validates :content, presence: true, length: { minimum: 50, maximum: 5000 }
  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: %w[pending delivered read responded] }

  # Scopes (see model_with_scopes.rb for more examples)
  scope :recent, -> { where(created_at: 30.days.ago..) }
  scope :unread, -> { where(status: "delivered") }
  scope :by_recipient, ->(email) { where(recipient_email: email) }

  # Enums
  enum :status, {
    pending: "pending",
    delivered: "delivered",
    read: "read",
    responded: "responded"
  }, prefix: true

  # Business logic methods
  def mark_as_delivered!
    update!(status: :delivered, delivered_at: Time.current)
  end

  def readable_by?(email)
    recipient_email == email
  end

  # Callbacks (use sparingly - see model_with_callbacks.rb)
  after_create :enqueue_delivery_job

  private

  def enqueue_delivery_job
    SendFeedbackJob.perform_later(id)
  end
end

# Key Patterns Demonstrated:
# 1. Clear association definitions
# 2. Comprehensive validations
# 3. Useful scopes for common queries
# 4. Enums for status management
# 5. Business logic in public methods
# 6. Minimal callback usage
