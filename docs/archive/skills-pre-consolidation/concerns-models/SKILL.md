---
name: rails-ai:concerns-models
description: Organize and share model behavior using ActiveSupport::Concern for cleaner, more maintainable Rails models.
---

# Model Concerns

Organize and share model behavior using ActiveSupport::Concern for cleaner, more maintainable Rails models.

<when-to-use>
- Extracting shared behavior across multiple models (Taggable, Timestampable, Sluggable)
- Organizing model-specific features (Notifications, StatusTracking, SoftDelete)
- Keeping models focused and slim
- Creating reusable, testable modules
- Preventing model bloat and separation of concerns
- Adding polymorphic behavior to multiple models
- ALWAYS - When model exceeds 200 lines or has distinct feature sets
</when-to-use>

<benefits>
- **Code Reusability** - Share behavior across multiple models without inheritance
- **Better Organization** - Group related functionality in focused modules
- **Easier Testing** - Test concerns in isolation from models
- **Reduced Complexity** - Keep models slim and focused on core responsibilities
- **Namespace Safety** - Prevent naming conflicts with namespaced concerns
- **Clear Dependencies** - Explicit `included do` blocks show what gets added
- **Maintainability** - Change concern logic in one place, affects all includers
</benefits>

<standards>
- Use SINGULAR model name for namespacing (User::, not Users::)
- Place domain-specific child concerns alongside the parent model in `app/models/[model_name]/[concern].rb`
- Place generic/shared concerns in `app/models/concerns/` or `app/models/concerns/shared/`
- Use `extend ActiveSupport::Concern` at the top
- Put associations, validations, callbacks in `included do` block
- Define instance methods at module level
- Use `class_methods do` block for class methods
- Extract to `concerns/` or `concerns/shared/` when used across 3+ models
- Test concerns independently in `test/models/concerns/` or `test/models/[model_name]/`
- Keep concerns focused - one concern per feature/behavior
- Name concerns clearly after their purpose (Settings, Notifications, Taggable, etc.)
</standards>

## Basic Concern Structure

<pattern name="concern-anatomy">
<description>Standard structure for ActiveSupport::Concern modules</description>

**Basic Concern:**
```ruby
# app/models/feedback/notifications.rb
module Feedback::Notifications
  extend ActiveSupport::Concern

  included do
    has_many :notification_subscribers, dependent: :destroy
    validates :recipient_email, presence: true, if: :notifications_enabled?

    after_create_commit :notify_recipient_of_submission
    after_update_commit :notify_sender_of_response, if: :response_added?

    scope :with_pending_notifications, -> { where(notified_at: nil) }
    scope :notification_sent, -> { where.not(notified_at: nil) }
  end

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

  def notifications_enabled?
    recipient_email.present? && !notification_disabled
  end

  class_methods do
    def send_pending_notifications
      with_pending_notifications.find_each(&:notify_recipient_of_submission)
    end

    def notification_stats
      { pending: with_pending_notifications.count, sent: notification_sent.count, total: count }
    end
  end
end
```

**Usage in Model:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  include Feedback::Notifications

  validates :content, presence: true
  # ... other model code
end

# Now Feedback has all notification behavior
feedback = Feedback.create!(content: "Test", recipient_email: "user@example.com")
feedback.notification_sent?  # false
feedback.notify_recipient_of_submission
feedback.notification_sent?  # true

# Class methods available
Feedback.notification_stats
# => { pending: 5, sent: 15, total: 20 }
```
</pattern>

## Common Concern Patterns

<pattern name="taggable-concern">
<description>Polymorphic tagging behavior for multiple models</description>

**Taggable Concern:**
```ruby
# app/models/concerns/taggable.rb
module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings

    scope :tagged_with, ->(tag_name) {
      joins(:tags).where(tags: { name: tag_name }).distinct
    }

    scope :untagged, -> {
      left_joins(:taggings).where(taggings: { id: nil })
    }

    scope :with_any_tags, ->(*tag_names) {
      joins(:tags).where(tags: { name: tag_names.flatten }).distinct
    }

    scope :with_all_tags, ->(*tag_names) {
      tag_names.flatten.reduce(all) do |relation, tag_name|
        relation.tagged_with(tag_name)
      end
    }
  end

  def tag_list
    tags.pluck(:name).join(", ")
  end

  def tag_list=(names)
    self.tags = names.to_s.split(",").map do |name|
      Tag.find_or_create_by(name: name.strip.downcase)
    end
  end

  def add_tag(tag_name)
    return if tagged_with?(tag_name)

    tags << Tag.find_or_create_by(name: tag_name.strip.downcase)
  end

  def remove_tag(tag_name)
    tags.delete(Tag.find_by(name: tag_name.strip.downcase))
  end

  def tagged_with?(tag_name)
    tags.exists?(name: tag_name.strip.downcase)
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
        .select("tags.*, COUNT(taggings.id) as usage_count")
        .order("usage_count DESC")
        .limit(limit)
    end
  end
end
```

**Usage Across Models:**
```ruby
# Multiple models can be taggable
class Feedback < ApplicationRecord
  include Taggable
end

class Article < ApplicationRecord
  include Taggable
end

class Product < ApplicationRecord
  include Taggable
end

# Use tagging behavior
feedback.tag_list = "bug, urgent, ui"
feedback.add_tag("needs-review")
feedback.remove_tag("urgent")
feedback.tagged_with?("bug")  # true

# Query tagged records
Feedback.tagged_with("bug")
Article.with_all_tags("rails", "tutorial")
Product.popular_tags(5)
```
</pattern>

<pattern name="soft-deletable-concern">
<description>Soft delete functionality with restoration capabilities</description>

**Soft Deletable Concern:**
```ruby
# app/models/concerns/soft_deletable.rb
module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(deleted_at: nil) }
    scope :deleted, -> { where.not(deleted_at: nil) }
    scope :deleted_since, ->(date) { where("deleted_at >= ?", date) }
  end

  def soft_delete
    return false if deleted?

    update(deleted_at: Time.current, deleted_by: Current.user&.id)
  end

  def soft_delete!
    raise ActiveRecord::RecordNotDestroyed unless soft_delete
  end

  def restore
    return false unless deleted?

    update(deleted_at: nil, deleted_by: nil)
  end

  def restore!
    raise ActiveRecord::RecordNotRestored unless restore
  end

  def deleted?
    deleted_at.present?
  end

  def active?
    !deleted?
  end

  class_methods do
    def with_deleted
      unscope(where: :deleted_at)
    end

    def only_deleted
      deleted
    end

    def permanently_delete_old_records(days_ago = 30)
      deleted_since(days_ago.days.ago..).destroy_all
    end

    def restore_all
      deleted.update_all(deleted_at: nil, deleted_by: nil)
    end
  end
end
```

**Migration:**
```ruby
# db/migrate/20251030_add_soft_delete_to_feedbacks.rb
class AddSoftDeleteToFeedbacks < ActiveRecord::Migration[8.1]
  def change
    add_column :feedbacks, :deleted_at, :datetime
    add_column :feedbacks, :deleted_by, :bigint

    add_index :feedbacks, :deleted_at
    add_foreign_key :feedbacks, :users, column: :deleted_by
  end
end
```

**Usage:**
```ruby
class Feedback < ApplicationRecord
  include SoftDeletable
end

feedback = Feedback.first
feedback.soft_delete  # Marks as deleted
feedback.deleted?     # true

# Query only active records
Feedback.active

# Include deleted records
Feedback.with_deleted

# Only deleted records
Feedback.deleted

# Restore a record
feedback.restore
feedback.active?  # true

# Permanently delete old records
Feedback.permanently_delete_old_records(90)  # Delete records deleted 90+ days ago
```
</pattern>

<pattern name="sluggable-concern">
<description>Automatic URL-friendly slug generation from attribute</description>

**Sluggable Concern:**
```ruby
# app/models/concerns/sluggable.rb
module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: :should_generate_slug?

    validates :slug, presence: true, uniqueness: true,
      format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens" }
  end

  def to_param
    slug
  end

  private

  def generate_slug
    base_slug = slug_source.to_s.parameterize
    return if base_slug.blank?

    candidate_slug = base_slug
    counter = 1

    while self.class.exists?(slug: candidate_slug)
      candidate_slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = candidate_slug
  end

  def should_generate_slug?
    slug.blank? || slug_source_changed?
  end

  def slug_source
    raise NotImplementedError, "#{self.class} must implement slug_source method"
  end

  def slug_source_changed?
    false
  end

  class_methods do
    def find_by_slug!(slug)
      find_by!(slug: slug)
    end
  end
end
```

**Usage in Model:**
```ruby
# app/models/article.rb
class Article < ApplicationRecord
  include Sluggable

  validates :title, presence: true

  private

  def slug_source
    title
  end

  def slug_source_changed?
    title_changed?
  end
end

# Automatic slug generation
article = Article.create!(title: "How to Use Rails Concerns")
article.slug  # => "how-to-use-rails-concerns"
article.to_param  # => "how-to-use-rails-concerns"

# Duplicate titles get numbered slugs
article2 = Article.create!(title: "How to Use Rails Concerns")
article2.slug  # => "how-to-use-rails-concerns-1"

# Use in routes
article_path(article)  # => "/articles/how-to-use-rails-concerns"

# Find by slug
Article.find_by_slug!("how-to-use-rails-concerns")
```
</pattern>

<pattern name="status-trackable-concern">
<description>Track status changes with timestamps and history</description>

**Status Trackable Concern:**
```ruby
# app/models/feedback/status_trackable.rb
module Feedback::StatusTrackable
  extend ActiveSupport::Concern

  included do
    enum :status, {
      pending: "pending",
      reviewed: "reviewed",
      responded: "responded",
      archived: "archived"
    }, prefix: true, scopes: true

    # Track status changes
    after_update :log_status_change, if: :saved_change_to_status?
    after_update :update_status_timestamp, if: :saved_change_to_status?

    scope :recently_updated, -> { where("status_updated_at > ?", 24.hours.ago) }
    scope :stale, ->(threshold = 7.days) { where("status_updated_at < ?", threshold.ago) }
  end

  def status_age
    return nil if status_updated_at.blank?

    Time.current - status_updated_at
  end

  def stale?(threshold = 7.days)
    status_age && status_age > threshold
  end

  def status_changed_from_to?(from_status, to_status)
    status_before_last_save == from_status.to_s && status == to_status.to_s
  end

  def status_history
    # Requires status_changes table or audit log
    StatusChange.where(feedback_id: id).order(created_at: :desc)
  end

  private

  def log_status_change
    Rails.logger.info("Feedback ##{id} status: #{status_before_last_save} -> #{status}")
    StatusChange.create!(
      feedback_id: id,
      from_status: status_before_last_save,
      to_status: status,
      changed_by_id: Current.user&.id
    )
  end

  def update_status_timestamp
    update_column(:status_updated_at, Time.current)
  end

  class_methods do
    def status_distribution
      group(:status).count
    end

    def by_status_age(status_value, min_age: nil, max_age: nil)
      relation = where(status: status_value)
      relation = relation.where("status_updated_at <= ?", min_age.ago) if min_age
      relation = relation.where("status_updated_at >= ?", max_age.ago) if max_age
      relation
    end

    def status_summary
      {
        total: count,
        by_status: status_distribution,
        recently_changed: recently_updated.count,
        stale: stale.count
      }
    end
  end
end
```
</pattern>

## Additional Pattern Examples

<pattern name="timestampable-concern">
<description>Track creation and update metadata with user tracking</description>

**Timestampable Concern:**
```ruby
# app/models/concerns/timestampable.rb
module Timestampable
  extend ActiveSupport::Concern

  included do
    before_create :set_created_metadata
    before_update :set_updated_metadata
  end

  def created_by_user
    User.find_by(id: created_by_id)
  end

  def recently_created?(threshold = 24.hours)
    created_at && (Time.current - created_at) < threshold
  end

  def recently_updated?(threshold = 24.hours)
    updated_at && (Time.current - updated_at) < threshold
  end

  private

  def set_created_metadata
    self.created_by_id = Current.user&.id
    self.created_ip = Current.request_ip
  end

  def set_updated_metadata
    self.updated_by_id = Current.user&.id
    self.updated_ip = Current.request_ip
  end

  class_methods do
    def created_by(user)
      where(created_by_id: user.id)
    end

    def recently_created(threshold = 24.hours)
      where("created_at >= ?", threshold.ago)
    end

    def recently_updated(threshold = 24.hours)
      where("updated_at >= ?", threshold.ago)
    end
  end
end
```

**Usage:**
```ruby
class Feedback < ApplicationRecord
  include Timestampable
end

# Query by creator
Feedback.created_by(current_user)

# Find recent records
Feedback.recently_created(1.week)
Feedback.recently_updated(3.days)
```
</pattern>

## Namespacing Guidelines

<pattern name="namespacing-strategy">
<description>When to use domain-specific child concerns vs shared concerns</description>

**Domain-Specific Child Concerns (Alongside Parent Model):**
```ruby
# app/models/feedback/
# ├── notifications.rb      # Feedback-specific notification logic
# ├── status_trackable.rb   # Feedback status management
# └── ai_improvements.rb

# Rule: Use SINGULAR ModelName:: namespace when concern is specific to ONE model
# Place alongside parent model in app/models/[model_name]/
# Different from child models which use PLURAL (Feedbacks::Response)
```

**Shared/Generic Concerns (In concerns/ directory):**
```ruby
# app/models/concerns/
# ├── taggable.rb           # Used by Feedback, Article, Product
# ├── soft_deletable.rb     # Used by Feedback, Comment, Attachment
# └── sluggable.rb          # Used by Article, Category, Tag

# Rule: Place in concerns/ when used by 3+ models or designed for reuse
```

**File Organization:**
```
app/models/
├── feedback.rb
├── feedback/
│   ├── notifications.rb      # module Feedback::Notifications
│   ├── status_trackable.rb   # module Feedback::StatusTrackable
│   └── ai_improvements.rb
├── concerns/
│   ├── taggable.rb           # module Taggable
│   ├── soft_deletable.rb     # module SoftDeletable
│   └── sluggable.rb          # module Sluggable
```
</pattern>

## Configuration via Class Attributes

<pattern name="configurable-concerns">
<description>Make concerns configurable with class attributes</description>

**Configurable Concern:**
```ruby
# app/models/concerns/notifiable.rb
module Notifiable
  extend ActiveSupport::Concern

  included do
    class_attribute :notification_email_method, default: :email
    class_attribute :notification_events, default: [:created, :updated]
    class_attribute :notification_async, default: true

    notification_events.each do |event|
      after_commit "notify_on_#{event}", on: event, if: :should_notify?
    end
  end

  def notify(event)
    return unless should_notify?
    email = send(self.class.notification_email_method)
    return if email.blank?

    mailer = NotificationMailer.send("#{event}_notification", self)
    self.class.notification_async ? mailer.deliver_later : mailer.deliver_now
  end

  def should_notify?
    respond_to?(self.class.notification_email_method) && !skip_notifications
  end
end
```

**Usage with Configuration:**
```ruby
class Feedback < ApplicationRecord
  include Notifiable

  # Configure the concern for this model
  self.notification_email_method = :recipient_email
  self.notification_events = [:created, :responded]
  self.notification_async = true
end

class Comment < ApplicationRecord
  include Notifiable

  # Different configuration for comments
  self.notification_email_method = :author_email
  self.notification_events = [:created]
  self.notification_async = false
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Using plural namespace for model concerns</description>
<reason>Breaks Rails conventions - concerns augment the model, not create children</reason>
<bad-example>
```ruby
# ❌ BAD - Plural namespace
module Feedbacks::Notifications  # Wrong!
  extend ActiveSupport::Concern
end

class Feedback < ApplicationRecord
  include Feedbacks::Notifications  # Confusing!
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Singular namespace
module Feedback::Notifications  # Correct!
  extend ActiveSupport::Concern
end

class Feedback < ApplicationRecord
  include Feedback::Notifications  # Clear!
end

# Note: Plural is ONLY for child models/controllers
class Feedbacks::Response < ApplicationRecord  # This is correct
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not testing concerns in isolation</description>
<reason>Makes it hard to verify concern behavior, leads to brittle tests</reason>
<bad-example>
```ruby
# ❌ BAD - Only testing concerns through models
class FeedbackTest < ActiveSupport::TestCase
  test "tagging works" do
    feedback = feedbacks(:one)
    feedback.add_tag("urgent")
    assert feedback.tagged_with?("urgent")
  end
end
# No dedicated concern tests
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Test concerns independently
class TaggableTest < ActiveSupport::TestCase
  class TaggableTestModel < ApplicationRecord
    self.table_name = "feedbacks"
    include Taggable
  end

  test "add_tag adds a tag" do
    record = TaggableTestModel.first
    record.add_tag("urgent")
    assert record.tagged_with?("urgent")
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using concerns to hide complex business logic</description>
<reason>Concerns should organize code, not hide complexity - use service objects instead</reason>
<bad-example>
```ruby
# ❌ BAD - Complex business logic hidden in concern
module Feedback::Processing
  extend ActiveSupport::Concern

  def process_feedback
    # 100+ lines of complex business logic
    sanitize_content
    detect_language
    analyze_sentiment
    # ... more complexity
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use service object for complex logic
module Feedback::Processing
  extend ActiveSupport::Concern

  included do
    after_create_commit :enqueue_processing
  end

  private

  def enqueue_processing
    ProcessFeedbackJob.perform_later(id)
  end
end

# app/services/process_feedback_service.rb
class ProcessFeedbackService
  def call
    sanitize_content
    detect_language
    # ... clear, testable
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test concerns independently and in context:

```ruby
# test/models/feedback/notifications_test.rb
class Feedback::NotificationsTest < ActiveSupport::TestCase
  class NotifiableTestModel < ApplicationRecord
    self.table_name = "feedbacks"
    include Feedback::Notifications
  end

  setup do
    @feedback = NotifiableTestModel.first
  end

  test "notifies recipient after creation" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      NotifiableTestModel.create!(content: "Test", recipient_email: "user@example.com")
    end
  end

  test "marks notification as sent" do
    @feedback.notify_recipient_of_submission
    assert @feedback.notification_sent?
  end

  # ... (additional notification tests)
end

# test/models/concerns/taggable_test.rb
class TaggableTest < ActiveSupport::TestCase
  class TaggableTestModel < ApplicationRecord
    self.table_name = "feedbacks"
    include Taggable
  end

  test "add_tag creates new tag" do
    record = TaggableTestModel.first
    record.add_tag("urgent")
    assert record.tagged_with?("urgent")
  end

  test "tag_list= creates multiple tags from comma-separated string" do
    record = TaggableTestModel.first
    record.tag_list = "bug, urgent, needs-review"
    assert_equal 3, record.tags.count
  end

  # ... (additional tagging tests)
end

# test/models/concerns/soft_deletable_test.rb
class SoftDeletableTest < ActiveSupport::TestCase
  class SoftDeletableTestModel < ApplicationRecord
    self.table_name = "feedbacks"
    include SoftDeletable
  end

  test "soft_delete marks record as deleted" do
    record = SoftDeletableTestModel.first
    record.soft_delete
    assert record.deleted?
  end

  test "active scope excludes deleted records" do
    record = SoftDeletableTestModel.first
    record.soft_delete
    assert_not_includes SoftDeletableTestModel.active, record
  end

  # ... (additional soft delete tests)
end
```
</testing>

<related-skills>
- rails-ai:activerecord-patterns - Core ActiveRecord functionality
- rails-ai:controller-restful - Controllers using models with concerns

- rails-ai:form-objects - Form objects can use concerns too
</related-skills>

<resources>
- [Rails Guides - ActiveSupport::Concern](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)
- [DHH on Concerns](https://signalvnoise.com/posts/3372-put-chubby-models-on-a-diet-with-concerns)
- [Rails Autoloading and Reloading Constants](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html)
- [Refactoring with Concerns](https://blog.appsignal.com/2020/09/16/rails-concers-to-concern-or-not-to-concern.html)
</resources>
