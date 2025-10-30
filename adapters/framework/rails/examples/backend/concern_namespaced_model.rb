# Namespaced Model Concern Pattern
# Reference: Rails Guides - ActiveSupport::Concern
# Category: MODELS - CONCERNS

# ============================================================================
# What Are Namespaced Model Concerns?
# ============================================================================

# Concerns are modules that encapsulate related functionality for models.
# Namespacing concerns under the model name (e.g., Feedback::Notifications)
# provides better organization and prevents naming conflicts.

# IMPORTANT: Concerns use SINGULAR model name (Feedback::), not plural (Feedbacks::)
# This is different from child models/controllers which use PLURAL (Feedbacks::Response)
# Rationale: Concerns augment the parent model, so they share its namespace

# Benefits:
# ✅ Organize related behavior (notifications, tagging, soft delete, etc.)
# ✅ Share functionality across multiple models
# ✅ Keep models slim and focused
# ✅ Easier testing in isolation
# ✅ Clear namespace prevents conflicts

# ============================================================================
# ✅ RECOMMENDED: Namespaced Model Concern
# ============================================================================

# app/models/concerns/feedback/notifications.rb
module Feedback::Notifications
  extend ActiveSupport::Concern

  # Code in `included do` block runs when concern is included
  # It executes in the context of the including class (Feedback model)
  included do
    # Associations specific to notifications
    has_many :notification_subscribers, dependent: :destroy

    # Callbacks
    after_create_commit :notify_recipient_of_submission
    after_update_commit :notify_sender_of_response, if: :response_added?

    # Scopes
    scope :with_pending_notifications, -> { where(notified_at: nil) }
  end

  # Instance methods available to the model
  def notify_recipient_of_submission
    return if recipient_email.blank?

    FeedbackMailer.notify_recipient(self).deliver_later
    touch(:notified_at)
  end

  def notify_sender_of_response
    return if sender_email.blank? || response.blank?

    FeedbackMailer.notify_sender_of_response(self).deliver_later
  end

  def response_added?
    saved_change_to_response? && response.present?
  end

  def notification_sent?
    notified_at.present?
  end

  # Class methods via class_methods block
  class_methods do
    def send_pending_notifications
      with_pending_notifications.find_each do |feedback|
        feedback.notify_recipient_of_submission
      end
    end

    def notification_stats
      {
        pending: with_pending_notifications.count,
        sent: where.not(notified_at: nil).count,
        total: count
      }
    end
  end
end

# Usage in model
# app/models/feedback.rb
class Feedback < ApplicationRecord
  include Feedback::Notifications

  validates :content, presence: true
  # ... other model code
end

# ============================================================================
# ✅ ANOTHER EXAMPLE: Tagging Concern
# ============================================================================

# app/models/concerns/feedback/taggable.rb
module Feedback::Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings

    scope :tagged_with, ->(tag_name) {
      joins(:tags).where(tags: { name: tag_name })
    }

    scope :untagged, -> {
      left_joins(:taggings).where(taggings: { id: nil })
    }
  end

  def tag_list
    tags.pluck(:name).join(", ")
  end

  def tag_list=(names)
    self.tags = names.split(",").map do |name|
      Tag.find_or_create_by(name: name.strip)
    end
  end

  def add_tag(tag_name)
    tags << Tag.find_or_create_by(name: tag_name) unless tagged_with?(tag_name)
  end

  def remove_tag(tag_name)
    tags.delete(Tag.find_by(name: tag_name))
  end

  def tagged_with?(tag_name)
    tags.exists?(name: tag_name)
  end

  class_methods do
    def most_tagged(limit = 10)
      select("#{table_name}.*, COUNT(taggings.id) as tags_count")
        .joins(:taggings)
        .group("#{table_name}.id")
        .order("tags_count DESC")
        .limit(limit)
    end

    def popular_tags(limit = 10)
      Tag.joins(:taggings)
        .where(taggings: { taggable_type: name })
        .group("tags.id")
        .order("COUNT(taggings.id) DESC")
        .limit(limit)
    end
  end
end

# ============================================================================
# ✅ EXAMPLE: Soft Delete Concern
# ============================================================================

# app/models/concerns/feedback/soft_deletable.rb
module Feedback::SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(deleted_at: nil) }
    scope :deleted, -> { where.not(deleted_at: nil) }

    # Override default scope to exclude soft-deleted records
    default_scope { active }
  end

  def soft_delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end

  def deleted?
    deleted_at.present?
  end

  class_methods do
    def with_deleted
      unscope(where: :deleted_at)
    end

    def permanently_delete_old_records(days_ago = 30)
      with_deleted
        .where("deleted_at < ?", days_ago.days.ago)
        .destroy_all
    end
  end
end

# Usage
# class Feedback < ApplicationRecord
#   include Feedback::SoftDeletable
# end
#
# feedback.soft_delete  # Marks as deleted
# feedback.restore      # Restores the record
# Feedback.deleted      # Only soft-deleted records
# Feedback.with_deleted # All records including deleted

# ============================================================================
# ✅ EXAMPLE: Status Tracking Concern
# ============================================================================

# app/models/concerns/feedback/status_trackable.rb
module Feedback::StatusTrackable
  extend ActiveSupport::Concern

  included do
    enum :status, {
      pending: 0,
      reviewed: 1,
      responded: 2,
      archived: 3
    }, prefix: true

    # Track status changes
    after_update :log_status_change, if: :saved_change_to_status?

    scope :recently_updated, -> { where("status_updated_at > ?", 24.hours.ago) }
  end

  def log_status_change
    update_column(:status_updated_at, Time.current)

    Rails.logger.info(
      "Feedback ##{id} status changed: " \
      "#{status_before_last_save} -> #{status}"
    )
  end

  def status_age
    return nil if status_updated_at.blank?

    Time.current - status_updated_at
  end

  def stale?(threshold = 7.days)
    status_age && status_age > threshold
  end

  class_methods do
    def status_distribution
      group(:status).count
    end

    def stale_feedbacks(threshold = 7.days)
      where("status_updated_at < ?", threshold.ago)
    end
  end
end

# ============================================================================
# ✅ TESTING NAMESPACED CONCERNS
# ============================================================================

# test/models/concerns/feedback/notifications_test.rb
require "test_helper"

class Feedback::NotificationsTest < ActiveSupport::TestCase
  setup do
    @feedback = feedbacks(:one)
  end

  test "notifies recipient after creation" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      Feedback.create!(
        content: "Test feedback",
        recipient_email: "recipient@example.com"
      )
    end
  end

  test "notifies sender when response added" do
    @feedback.update(sender_email: "sender@example.com")

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      @feedback.update(response: "Thank you for the feedback")
    end
  end

  test "marks notification as sent" do
    @feedback.notify_recipient_of_submission

    assert @feedback.notification_sent?
    assert_not_nil @feedback.notified_at
  end

  test "finds pending notifications" do
    @feedback.update(notified_at: nil)

    assert_includes Feedback.with_pending_notifications, @feedback
  end

  test "sends pending notifications" do
    @feedback.update(notified_at: nil)

    assert_enqueued_jobs 1 do
      Feedback.send_pending_notifications
    end
  end

  test "returns notification stats" do
    stats = Feedback.notification_stats

    assert_includes stats, :pending
    assert_includes stats, :sent
    assert_includes stats, :total
  end
end

# ============================================================================
# File Organization
# ============================================================================

# Recommended structure:
# app/models/concerns/
# ├── feedback/
# │   ├── notifications.rb      # Notification behavior
# │   ├── taggable.rb           # Tagging functionality
# │   ├── soft_deletable.rb     # Soft delete support
# │   └── status_trackable.rb   # Status tracking
# ├── user/
# │   ├── authenticatable.rb    # Authentication
# │   └── profile_completable.rb
# └── shared/
#     ├── timestampable.rb      # Shared across all models
#     └── sluggable.rb

# ============================================================================
# RULE: Use namespaced concerns for model-specific behavior
# PREFER: Namespace concerns under model name (Feedback::Notifications)
# EXTRACT: When a concern is shared across models, move to shared/
# TEST: Always test concerns in isolation
# ORGANIZE: Group related concerns in subdirectories by model
# ============================================================================
