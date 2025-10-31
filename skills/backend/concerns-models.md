---
name: concerns-models
domain: backend
dependencies: [activerecord-patterns]
version: 1.0
rails_version: 8.1+

# Team rules enforcement
enforces_team_rule:
  - rule_id: 5
    rule_name: "Proper Namespacing"
    severity: moderate
    enforcement_action: SUGGEST
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

  # Code in `included do` block runs when concern is included
  # Executes in the context of the including class
  included do
    # Associations
    has_many :notification_subscribers, dependent: :destroy

    # Validations
    validates :recipient_email, presence: true, if: :notifications_enabled?

    # Callbacks
    after_create_commit :notify_recipient_of_submission
    after_update_commit :notify_sender_of_response, if: :response_added?

    # Scopes
    scope :with_pending_notifications, -> { where(notified_at: nil) }
    scope :notification_sent, -> { where.not(notified_at: nil) }
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

  def notifications_enabled?
    recipient_email.present? && !notification_disabled
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
        sent: notification_sent.count,
        total: count
      }
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

    # Override default scope to exclude soft-deleted records
    # Note: Use with caution - default_scope can cause issues
    # Prefer explicit .active scope in queries
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

  # Override in including model
  def slug_source
    # Default implementation - override in model
    raise NotImplementedError, "#{self.class} must implement slug_source method"
  end

  def slug_source_changed?
    # Default implementation - override in model
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

<pattern name="timestampable-concern">
<description>Track creation, update, and custom timestamps</description>

**Timestampable Concern:**
```ruby
# app/models/concerns/timestampable.rb
module Timestampable
  extend ActiveSupport::Concern

  included do
    # Rails provides created_at/updated_at by default
    # This concern adds additional timestamp tracking

    before_create :set_created_metadata
    before_update :set_updated_metadata
  end

  def created_by_user
    User.find_by(id: created_by_id)
  end

  def updated_by_user
    User.find_by(id: updated_by_id)
  end

  def time_since_created
    return nil unless created_at

    Time.current - created_at
  end

  def time_since_updated
    return nil unless updated_at

    Time.current - updated_at
  end

  def recently_created?(threshold = 24.hours)
    time_since_created && time_since_created < threshold
  end

  def recently_updated?(threshold = 24.hours)
    time_since_updated && time_since_updated < threshold
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

    def updated_by(user)
      where(updated_by_id: user.id)
    end

    def created_since(time)
      where("created_at >= ?", time)
    end

    def updated_since(time)
      where("updated_at >= ?", time)
    end

    def recently_created(threshold = 24.hours)
      created_since(threshold.ago)
    end

    def recently_updated(threshold = 24.hours)
      updated_since(threshold.ago)
    end
  end
end
```
</pattern>

<pattern name="searchable-concern">
<description>Full-text search functionality for models</description>

**Searchable Concern:**
```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern

  class_methods do
    # Override in model to define searchable columns
    def searchable_columns
      raise NotImplementedError, "#{name} must implement searchable_columns"
    end

    def search(query)
      return none if query.blank?

      sanitized_query = sanitize_sql_like(query.to_s)
      conditions = searchable_columns.map do |column|
        "#{column} ILIKE :query"
      end.join(" OR ")

      where(conditions, query: "%#{sanitized_query}%")
    end

    def search_any(queries)
      return none if queries.blank?

      queries.flatten.compact.reduce(none) do |relation, query|
        relation.or(search(query))
      end
    end

    def search_all(queries)
      return all if queries.blank?

      queries.flatten.compact.reduce(all) do |relation, query|
        relation.merge(search(query))
      end
    end
  end

  def search_rank(query)
    return 0 if query.blank?

    self.class.searchable_columns.count do |column|
      send(column).to_s.downcase.include?(query.downcase)
    end
  end
end
```

**Usage:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  include Searchable

  def self.searchable_columns
    [:content, :sender_name, :sender_email]
  end
end

# Search across multiple columns
Feedback.search("bug report")
# WHERE (content ILIKE '%bug report%' OR sender_name ILIKE '%bug report%' OR sender_email ILIKE '%bug report%')

# Search for any term
Feedback.search_any(["bug", "feature"])

# Search for all terms
Feedback.search_all(["urgent", "payment"])
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
    Rails.logger.info(
      "Feedback ##{id} status changed: " \
      "#{status_before_last_save} -> #{status} by #{Current.user&.email}"
    )

    # Optionally create audit record
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

## Namespacing Guidelines

<pattern name="namespacing-strategy">
<description>When to use domain-specific child concerns vs shared concerns</description>

**Domain-Specific Child Concerns (Alongside Parent Model):**
```ruby
# app/models/feedback/
# ├── notifications.rb      # Feedback-specific notification logic
# ├── status_trackable.rb   # Feedback status management
# └── ai_improvements.rb    # Feedback AI enhancement

# app/models/user/
# ├── authenticatable.rb    # User authentication
# ├── profile_completable.rb
# └── settings.rb           # User-specific settings

# Rule: Use ModelName:: namespace when concern is specific to ONE model
# Place alongside the parent model in app/models/[model_name]/
# This is different from child models which use PLURAL (Feedbacks::Response)
# Concerns use SINGULAR because they augment the parent model
```

**Shared/Generic Concerns (In concerns/ directory):**
```ruby
# app/models/concerns/
# ├── taggable.rb           # Used by Feedback, Article, Product
# ├── soft_deletable.rb     # Used by Feedback, Comment, Attachment
# ├── sluggable.rb          # Used by Article, Category, Tag
# ├── searchable.rb         # Used by multiple models
# └── timestampable.rb      # Generic timestamp tracking

# Rule: Place in concerns/ when concern is used by 3+ models
# Or when designed to be globally reusable from the start
# Use simple module names (Taggable, not Shared::Taggable)
```

**File Organization:**
```
app/models/
├── feedback.rb
├── feedback/
│   ├── notifications.rb      # module Feedback::Notifications
│   ├── status_trackable.rb   # module Feedback::StatusTrackable
│   └── ai_improvements.rb    # module Feedback::AiImprovements
├── user.rb
├── user/
│   ├── authenticatable.rb    # module User::Authenticatable
│   ├── profile_completable.rb # module User::ProfileCompletable
│   └── settings.rb           # module User::Settings
├── concerns/
│   ├── taggable.rb           # module Taggable
│   ├── soft_deletable.rb     # module SoftDeletable
│   ├── sluggable.rb          # module Sluggable
│   ├── searchable.rb         # module Searchable
│   └── timestampable.rb      # module Timestampable
└── README.md
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

    if self.class.notification_async
      NotificationMailer.send("#{event}_notification", self).deliver_later
    else
      NotificationMailer.send("#{event}_notification", self).deliver_now
    end
  end

  def should_notify?
    respond_to?(self.class.notification_email_method) && !skip_notifications
  end

  private

  notification_events.each do |event|
    define_method "notify_on_#{event}" do
      notify(event)
    end
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
<description>Creating "god concerns" with too much responsibility</description>
<reason>Defeats the purpose of extracting concerns - keeps code coupled and hard to understand</reason>
<bad-example>
```ruby
# ❌ BAD - Concern doing too many things
module Feedback::Everything
  extend ActiveSupport::Concern

  included do
    # Notifications
    after_create :send_notification
    # Status tracking
    after_update :log_status_change
    # Tagging
    has_many :tags
    # Soft delete
    scope :active, -> { where(deleted_at: nil) }
    # Search
    scope :search, ->(q) { where("content LIKE ?", "%#{q}%") }
    # Analytics
    after_save :track_analytics
    # Caching
    after_commit :clear_cache
    # ... 200 more lines
  end

  # 50 instance methods
  # 30 class methods
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Focused, single-responsibility concerns
module Feedback::Notifications
  extend ActiveSupport::Concern
  # Only notification-related code
end

module Feedback::StatusTrackable
  extend ActiveSupport::Concern
  # Only status tracking code
end

module Taggable
  extend ActiveSupport::Concern
  # Only tagging code
end

# Model includes multiple focused concerns
class Feedback < ApplicationRecord
  include Feedback::Notifications
  include Feedback::StatusTrackable
  include Taggable
  include SoftDeletable
end
```
</good-example>
</antipattern>

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
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "tagging works" do
    feedback = feedbacks(:one)
    feedback.add_tag("urgent")
    assert feedback.tagged_with?("urgent")
  end
end

# No dedicated concern tests - if concern breaks, all model tests break
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Test concerns independently
# test/models/concerns/shared/taggable_test.rb
class Shared::TaggableTest < ActiveSupport::TestCase
  # Create a test model that includes the concern
  class TaggableTestModel < ApplicationRecord
    self.table_name = "feedbacks"
    include Shared::Taggable
  end

  test "add_tag adds a tag" do
    record = TaggableTestModel.first
    record.add_tag("urgent")

    assert record.tagged_with?("urgent")
    assert_includes record.tags.pluck(:name), "urgent"
  end

  test "tag_list= creates tags from comma-separated string" do
    record = TaggableTestModel.first
    record.tag_list = "bug, urgent, needs-review"

    assert_equal 3, record.tags.count
    assert record.tagged_with?("bug")
    assert record.tagged_with?("urgent")
  end

  test "tagged_with? is case-insensitive" do
    record = TaggableTestModel.first
    record.add_tag("urgent")

    assert record.tagged_with?("URGENT")
    assert record.tagged_with?("Urgent")
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Concerns with dependencies on other concerns</description>
<reason>Creates tight coupling and makes concerns less reusable</reason>
<bad-example>
```ruby
# ❌ BAD - Concern depends on another concern
module Feedback::Analytics
  extend ActiveSupport::Concern

  included do
    # Assumes StatusTrackable is already included!
    after_update :track_status_analytics, if: :saved_change_to_status?
  end

  def track_status_analytics
    # Calls methods from StatusTrackable concern
    Analytics.track("status_changed", {
      from: status_before_last_save,  # From StatusTrackable
      to: status,
      age: status_age  # From StatusTrackable
    })
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Self-contained concerns
module Feedback::Analytics
  extend ActiveSupport::Concern

  included do
    after_update :track_status_analytics, if: :saved_change_to_status?
  end

  def track_status_analytics
    # Doesn't assume other concerns exist
    Analytics.track("status_changed", {
      from: status_before_last_save,
      to: status,
      feedback_id: id
    })
  end
end

# Or explicitly document dependencies
module Feedback::AdvancedAnalytics
  extend ActiveSupport::Concern

  # Document required concerns
  # Requires: Feedback::StatusTrackable

  included do
    # Verify dependency
    unless included_modules.include?(Feedback::StatusTrackable)
      raise "Feedback::AdvancedAnalytics requires Feedback::StatusTrackable"
    end
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

  included do
    after_create :process_feedback
  end

  def process_feedback
    # 100+ lines of complex business logic
    sanitize_content
    detect_language
    analyze_sentiment
    extract_keywords
    categorize_feedback
    assign_to_team
    create_notifications
    update_analytics
    trigger_webhooks
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
  def initialize(feedback)
    @feedback = feedback
  end

  def call
    sanitize_content
    detect_language
    analyze_sentiment
    # ... clear, testable, maintainable
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
  # Test concern in isolation
  class NotifiableTestModel < ApplicationRecord
    self.table_name = "feedbacks"
    include Feedback::Notifications
  end

  setup do
    @feedback = NotifiableTestModel.first
  end

  test "notifies recipient after creation" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      NotifiableTestModel.create!(
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

  test "marks notification as sent after delivery" do
    @feedback.notify_recipient_of_submission

    assert @feedback.notification_sent?
    assert_not_nil @feedback.notified_at
  end

  test "finds pending notifications" do
    @feedback.update(notified_at: nil)

    assert_includes NotifiableTestModel.with_pending_notifications, @feedback
  end

  test "sends pending notifications in batch" do
    @feedback.update(notified_at: nil)

    assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
      NotifiableTestModel.send_pending_notifications
    end
  end

  test "returns notification stats" do
    stats = NotifiableTestModel.notification_stats

    assert_includes stats, :pending
    assert_includes stats, :sent
    assert_includes stats, :total
    assert_kind_of Integer, stats[:pending]
  end

  test "does not notify if recipient_email blank" do
    @feedback.update(recipient_email: nil)

    assert_no_enqueued_jobs do
      @feedback.notify_recipient_of_submission
    end
  end
end

# test/models/concerns/taggable_test.rb
class TaggableTest < ActiveSupport::TestCase
  class TaggableTestModel < ApplicationRecord
    self.table_name = "feedbacks"
    include Taggable
  end

  setup do
    @record = TaggableTestModel.first
  end

  test "add_tag creates new tag" do
    assert_difference "@record.tags.count", 1 do
      @record.add_tag("urgent")
    end

    assert @record.tagged_with?("urgent")
  end

  test "add_tag is idempotent" do
    @record.add_tag("urgent")

    assert_no_difference "@record.tags.count" do
      @record.add_tag("urgent")
    end
  end

  test "tag_list= creates multiple tags" do
    @record.tag_list = "bug, feature, enhancement"

    assert_equal 3, @record.tags.count
    assert @record.tagged_with?("bug")
    assert @record.tagged_with?("feature")
  end

  test "remove_tag deletes tag association" do
    @record.add_tag("urgent")

    assert_difference "@record.tags.count", -1 do
      @record.remove_tag("urgent")
    end

    assert_not @record.tagged_with?("urgent")
  end

  test "tagged_with scope finds records by tag" do
    @record.add_tag("urgent")
    other = TaggableTestModel.create!(content: "Test")

    results = TaggableTestModel.tagged_with("urgent")

    assert_includes results, @record
    assert_not_includes results, other
  end

  test "most_tagged returns records with most tags" do
    @record.tag_list = "a, b, c, d"
    other = TaggableTestModel.create!(content: "Test")
    other.tag_list = "x"

    most_tagged = TaggableTestModel.most_tagged(1)

    assert_equal @record, most_tagged.first
  end
end

# test/models/concerns/soft_deletable_test.rb
class SoftDeletableTest < ActiveSupport::TestCase
  class SoftDeletableTestModel < ApplicationRecord
    self.table_name = "feedbacks"
    include SoftDeletable
  end

  setup do
    @record = SoftDeletableTestModel.first
  end

  test "soft_delete marks record as deleted" do
    @record.soft_delete

    assert @record.deleted?
    assert_not_nil @record.deleted_at
  end

  test "soft_delete returns false if already deleted" do
    @record.soft_delete

    assert_not @record.soft_delete
  end

  test "restore unmarks record as deleted" do
    @record.soft_delete
    @record.restore

    assert @record.active?
    assert_nil @record.deleted_at
  end

  test "active scope excludes deleted records" do
    @record.soft_delete

    assert_not_includes SoftDeletableTestModel.active, @record
  end

  test "deleted scope includes only deleted records" do
    @record.soft_delete

    assert_includes SoftDeletableTestModel.deleted, @record
  end

  test "with_deleted includes all records" do
    active_count = SoftDeletableTestModel.count
    @record.soft_delete

    assert_equal active_count, SoftDeletableTestModel.with_deleted.count
  end
end
```
</testing>

<related-skills>
- activerecord-patterns - Core ActiveRecord functionality
- controller-restful - Controllers using models with concerns
- service-objects - When to use services vs concerns
- form-objects - Form objects can use concerns too
</related-skills>

<resources>
- [Rails Guides - ActiveSupport::Concern](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)
- [DHH on Concerns](https://signalvnoise.com/posts/3372-put-chubby-models-on-a-diet-with-concerns)
- [Rails Autoloading and Reloading Constants](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html)
- [Refactoring with Concerns](https://blog.appsignal.com/2020/09/16/rails-concers-to-concern-or-not-to-concern.html)
</resources>
