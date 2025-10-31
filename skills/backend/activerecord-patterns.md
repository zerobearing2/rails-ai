---
name: activerecord-patterns
domain: backend
dependencies: []
version: 1.0
rails_version: 8.1+
---

# ActiveRecord Patterns

Master ActiveRecord patterns for Rails 8.1+ including associations, validations, callbacks, scopes, and query optimization.

<when-to-use>
- Building database-backed models
- Defining relationships between models
- Implementing data validation logic
- Creating reusable query scopes
- Managing model lifecycle with callbacks
- Optimizing database queries
- ALWAYS - Core pattern for Rails applications
</when-to-use>

<benefits>
- **Convention Over Configuration** - Minimal setup for maximum functionality
- **Automatic Migrations** - Schema changes tracked in version control
- **Association Magic** - Clean syntax for complex relationships
- **Validation Framework** - Declarative data integrity rules
- **Query Interface** - Chainable, composable queries
- **Database Agnostic** - Works with PostgreSQL, MySQL, SQLite
- **Performance Tools** - Built-in N+1 prevention and eager loading
</benefits>

<standards>
- Define associations at the top of the model
- Use validations to enforce data integrity
- Minimize callback usage - prefer service objects
- Use scopes for reusable queries, not class methods
- Always eager load associations to prevent N+1 queries
- Use enums for status/state fields
- Follow naming conventions: singular model names, namespaced for nested entities
- Keep models focused - extract concerns when needed
- Use `dependent:` option on associations for cleanup
- Prefer database constraints with validations for critical data
</standards>

## Model Naming & Organization

<pattern name="namespaced-models">
<description>Use namespaced models for entities that are conceptually owned by or part of a parent model</description>

**When to Use Namespaced Models:**

Use `Parent::Child` notation when:
- The child model represents something that is conceptually "part of" or "owned by" the parent
- The child doesn't have independent meaning outside the parent context
- You're modeling a domain aggregate (User + User::Setting + User::Profile)
- You want to organize related models in a clear hierarchy

**When NOT to Use Namespacing:**
- Models with independent meaning (Session, not User::Session)
- Models involved in many-to-many relationships
- Models that multiple unrelated parents might reference
- Models that represent first-class domain concepts

**Namespaced Model Example:**
```ruby
# app/models/user/setting.rb
module User
  class Setting < ApplicationRecord
    belongs_to :user

    validates :theme, inclusion: { in: %w[light dark auto] }
    validates :notifications_enabled, inclusion: { in: [true, false] }
  end
end

# app/models/user.rb
class User < ApplicationRecord
  has_one :setting, class_name: "User::Setting", dependent: :destroy

  after_create :create_default_setting

  private

  def create_default_setting
    create_setting(theme: "light", notifications_enabled: true)
  end
end
```

**Migration:**
```ruby
# db/migrate/20251031_create_user_settings.rb
class CreateUserSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :user_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :theme, default: "light", null: false
      t.boolean :notifications_enabled, default: true, null: false
      t.jsonb :preferences, default: {}

      t.timestamps
    end

    add_index :user_settings, :user_id, unique: true
  end
end
```

**Generator Command:**
```bash
# Generate namespaced model
bin/rails generate model User::Setting user:references theme:string notifications_enabled:boolean

# Directory structure created:
# app/models/user/setting.rb
# test/models/user/setting_test.rb
# db/migrate/XXXXXX_create_user_settings.rb
```

**File Organization:**
```
app/models/
├── user.rb                 # class User
├── user/
│   ├── setting.rb         # class User::Setting
│   ├── profile.rb         # class User::Profile
│   └── preference.rb      # class User::Preference
├── order.rb               # class Order
├── order/
│   ├── line_item.rb       # class Order::LineItem
│   └── payment.rb         # class Order::Payment
└── session.rb             # class Session (not User::Session - independent concept)
```

**Good Examples:**
```ruby
# ✅ GOOD - Nested entities that belong to parent
User::Setting       # Settings are part of a user
User::Profile       # Profile is part of a user
Order::LineItem     # Line items are part of an order
Order::Payment      # Payments belong to an order
Admin::Dashboard    # Admin-specific model
Api::Client         # API namespace for client models

# ❌ BAD - Flat naming obscures relationship
UserSetting         # Unclear this belongs to User
OrderItem           # Doesn't show ownership
UserProfile         # Flat namespace loses clarity
```

**Usage:**
```ruby
# Create associated records
user = User.create!(email: "user@example.com")
user.setting.update(theme: "dark")

# Query through associations
User.joins(:setting).where(user_settings: { theme: "dark" })

# Access namespaced model directly
User::Setting.where(notifications_enabled: true)

# Factory/fixture references
# test/fixtures/user/settings.yml
one:
  user: alice
  theme: dark
  notifications_enabled: true
```
</pattern>

<pattern name="flat-vs-namespaced">
<description>Decision guide for when to use flat vs namespaced models</description>

**Use Flat Models When:**

```ruby
# Independent business concepts
class Session < ApplicationRecord
  belongs_to :user
  # Session exists as its own concept, not "part of" User
end

class Tag < ApplicationRecord
  has_many :taggings
  # Tags are shared across many models - independent concept
end

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  # Comments are reusable, not owned by a single parent
end
```

**Use Namespaced Models When:**

```ruby
# Settings/preferences owned by parent
class User::Setting < ApplicationRecord
  belongs_to :user
  # Doesn't make sense without a User
end

# Sub-entities in an aggregate
class Order::LineItem < ApplicationRecord
  belongs_to :order
  # Line items are meaningless outside an Order context
end

# Domain-specific modules
class Admin::Report < ApplicationRecord
  # Admin namespace groups related functionality
end
```

**Decision Matrix:**

| Question | Flat Model | Namespaced Model |
|----------|------------|------------------|
| Can exist without parent? | Yes → Flat | No → Namespace |
| Shared across multiple parents? | Yes → Flat | No → Namespace |
| Independent business concept? | Yes → Flat | No → Namespace |
| Part of a domain aggregate? | No → Flat | Yes → Namespace |

</pattern>

## Associations

<pattern name="basic-associations">
<description>Standard ActiveRecord associations for model relationships</description>

**Model with Associations:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  # Belongs to - Single parent relationship
  belongs_to :recipient, class_name: "User", optional: true
  belongs_to :category, counter_cache: true

  # Has one - Single child relationship
  has_one :response, class_name: "FeedbackResponse", dependent: :destroy

  # Has many - Multiple children
  has_many :abuse_reports, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :taggings, dependent: :destroy

  # Scoped associations
  has_many :recent_reports, -> { where(created_at: 7.days.ago..) },
    class_name: "AbuseReport"
  has_many :resolved_reports, -> { where(status: "resolved") },
    class_name: "AbuseReport"
end
```

**Migration:**
```ruby
# db/migrate/20251030_create_feedbacks.rb
class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :recipient, foreign_key: { to_table: :users }, null: true
      t.references :category, foreign_key: true, null: false
      t.text :content, null: false
      t.string :status, default: "pending", null: false

      t.timestamps
    end

    add_index :feedbacks, :status
    add_index :feedbacks, :created_at
  end
end
```

**Usage:**
```ruby
# Create with associations
feedback = Feedback.create!(
  content: "Great work!",
  recipient: current_user,
  category: Category.find_by(name: "General")
)

# Access associations
feedback.recipient.email
feedback.response&.content
feedback.tags.pluck(:name)

# Build associated records
feedback.build_response(content: "Thank you!")
feedback.tags << Tag.find_or_create_by(name: "urgent")
```
</pattern>

<pattern name="polymorphic-associations">
<description>Flexible associations where a model belongs to multiple types</description>

**Polymorphic Model:**
```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :author, class_name: "User"

  validates :content, presence: true
end

# app/models/feedback.rb
class Feedback < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
end

# app/models/response.rb
class FeedbackResponse < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
end
```

**Migration:**
```ruby
class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :commentable, polymorphic: true, null: false
      t.references :author, foreign_key: { to_table: :users }, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :comments, [:commentable_type, :commentable_id]
  end
end
```

**Usage:**
```ruby
# Add comments to different types
feedback.comments.create!(content: "Great feedback", author: user)
response.comments.create!(content: "Good response", author: user)

# Query polymorphic associations
Comment.where(commentable: feedback)
Comment.where(commentable_type: "Feedback")
```
</pattern>

<pattern name="self-referential-associations">
<description>Models that reference themselves for hierarchical data</description>

**Self-Referential Model:**
```ruby
# app/models/category.rb
class Category < ApplicationRecord
  # Parent-child relationship
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: :parent_id,
    dependent: :destroy

  # All descendants recursively
  has_many :descendants, class_name: "Category", foreign_key: :parent_id

  # Scopes
  scope :root_categories, -> { where(parent_id: nil) }
  scope :with_children, -> { includes(:children) }

  def ancestors
    return [] if parent.nil?
    [parent] + parent.ancestors
  end

  def root
    parent.nil? ? self : parent.root
  end

  def depth
    parent.nil? ? 0 : parent.depth + 1
  end
end
```

**Migration:**
```ruby
class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.references :parent, foreign_key: { to_table: :categories }

      t.timestamps
    end

    add_index :categories, :parent_id
  end
end
```
</pattern>

## Validations

<pattern name="comprehensive-validations">
<description>Built-in Rails validations for data integrity</description>

**Model with Validations:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  # Presence validations
  validates :content, presence: true
  validates :recipient_email, presence: true

  # Length validations
  validates :content, length: {
    minimum: 50,
    maximum: 5000,
    message: "must be between 50 and 5000 characters"
  }

  # Format validations
  validates :recipient_email, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: "must be a valid email address"
  }

  # Inclusion/Exclusion validations
  validates :status, inclusion: {
    in: %w[pending delivered read responded],
    message: "%{value} is not a valid status"
  }

  # Uniqueness validations
  validates :tracking_code, uniqueness: {
    scope: :recipient_email,
    case_sensitive: false
  }

  # Numericality validations
  validates :rating, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5
  }, allow_nil: true

  # Custom validations
  validate :content_not_spam
  validate :recipient_can_receive_feedback, on: :create

  private

  def content_not_spam
    return if content.blank?

    spam_keywords = %w[viagra cialis lottery winner]
    if spam_keywords.any? { |keyword| content.downcase.include?(keyword) }
      errors.add(:content, "appears to contain spam")
    end
  end

  def recipient_can_receive_feedback
    return if recipient_email.blank?

    user = User.find_by(email: recipient_email)
    if user&.feedback_disabled?
      errors.add(:recipient_email, "has disabled feedback")
    end
  end
end
```

**Conditional Validations:**
```ruby
class Feedback < ApplicationRecord
  # Validate only if condition is met
  validates :response, presence: true, if: :responded?
  validates :sender_email, presence: true, unless: :anonymous?

  # Validate with Proc
  validates :ai_improved_content, presence: true,
    if: -> { ai_improved? && status == "pending" }

  private

  def responded?
    status == "responded"
  end

  def anonymous?
    sender_email.blank? && sender_name.blank?
  end
end
```
</pattern>

<pattern name="custom-validators">
<description>Reusable validation classes for complex logic</description>

**Email Validator:**
```ruby
# app/validators/email_validator.rb
class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    unless value =~ EMAIL_REGEX
      record.errors.add(attribute, options[:message] || "is not a valid email")
    end
  end
end

# Usage
class Feedback < ApplicationRecord
  validates :recipient_email, email: true
  validates :sender_email, email: { allow_blank: true }
end
```

**Content Length Validator:**
```ruby
# app/validators/content_length_validator.rb
class ContentLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    word_count = value.to_s.split.size

    if options[:minimum_words] && word_count < options[:minimum_words]
      record.errors.add(
        attribute,
        "must have at least #{options[:minimum_words]} words"
      )
    end

    if options[:maximum_words] && word_count > options[:maximum_words]
      record.errors.add(
        attribute,
        "must have at most #{options[:maximum_words]} words"
      )
    end
  end
end

# Usage
class Feedback < ApplicationRecord
  validates :content, content_length: {
    minimum_words: 10,
    maximum_words: 500
  }
end
```
</pattern>

## Scopes and Query Methods

<pattern name="effective-scopes">
<description>Reusable query scopes for common filtering</description>

**Model with Scopes:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  # Simple scopes
  scope :recent, -> { where(created_at: 30.days.ago..) }
  scope :unread, -> { where(status: "delivered") }
  scope :responded, -> { where.not(response: nil) }
  scope :anonymous, -> { where(sender_email: nil, sender_name: nil) }

  # Parameterized scopes
  scope :by_recipient, ->(email) { where(recipient_email: email) }
  scope :by_status, ->(status) { where(status: status) }
  scope :created_since, ->(date) { where("created_at >= ?", date) }
  scope :with_rating, ->(min, max) { where(rating: min..max) }

  # Scopes with joins
  scope :with_category, ->(name) {
    joins(:category).where(categories: { name: name })
  }
  scope :by_tag, ->(tag_name) {
    joins(:tags).where(tags: { name: tag_name }).distinct
  }

  # Scopes with eager loading
  scope :with_associations, -> {
    includes(:recipient, :response, :category, :tags)
  }

  # Chainable scopes
  scope :popular, -> {
    where("views_count > ?", 100).order(views_count: :desc)
  }
  scope :trending, -> {
    recent.popular.limit(10)
  }

  # Default scope (use sparingly!)
  # default_scope { where(deleted_at: nil) }
end
```

**Usage:**
```ruby
# Chain scopes together
Feedback.recent.by_recipient("user@example.com").responded

# Combine with ActiveRecord methods
Feedback.by_status("pending").order(created_at: :desc).limit(10)

# Use in associations
user.feedbacks.recent.with_associations

# Scope with OR conditions
Feedback.where(status: "pending").or(Feedback.where(status: "delivered"))
```
</pattern>

<pattern name="query-methods">
<description>Class methods for complex queries that don't fit scopes</description>

**Query Class Methods:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  # Use scopes for simple, chainable queries
  scope :recent, -> { where(created_at: 30.days.ago..) }

  # Use class methods for complex queries
  def self.search(query)
    return none if query.blank?

    where(
      "content ILIKE ? OR response ILIKE ?",
      "%#{sanitize_sql_like(query)}%",
      "%#{sanitize_sql_like(query)}%"
    )
  end

  def self.statistics_for_period(start_date, end_date)
    where(created_at: start_date..end_date)
      .group(:status)
      .count
  end

  def self.top_recipients(limit = 10)
    select("recipient_email, COUNT(*) as feedback_count")
      .group(:recipient_email)
      .order("feedback_count DESC")
      .limit(limit)
  end

  def self.with_response_rate
    select(
      "*",
      "CASE WHEN response IS NOT NULL THEN true ELSE false END as has_response"
    )
  end

  # Finder methods
  def self.find_by_tracking_code!(code)
    find_by!(tracking_code: code)
  rescue ActiveRecord::RecordNotFound
    raise ActiveRecord::RecordNotFound, "Feedback not found with code: #{code}"
  end
end
```
</pattern>

## Callbacks

<pattern name="minimal-callbacks">
<description>Use callbacks sparingly - prefer service objects for complex logic</description>

**Appropriate Callback Usage:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  # ✅ GOOD - Simple attribute transformations
  before_validation :normalize_email
  before_validation :strip_whitespace

  # ✅ GOOD - Generate default values
  before_create :generate_tracking_code

  # ✅ GOOD - Trigger background jobs
  after_create_commit :enqueue_delivery_job
  after_update_commit :notify_recipient_of_response, if: :response_added?

  # ✅ GOOD - Cleanup dependent records
  after_destroy_commit :cleanup_attachments

  private

  def normalize_email
    self.recipient_email = recipient_email&.downcase&.strip
  end

  def strip_whitespace
    self.content = content&.strip
  end

  def generate_tracking_code
    self.tracking_code = SecureRandom.alphanumeric(10).upcase
  end

  def enqueue_delivery_job
    SendFeedbackJob.perform_later(id)
  end

  def response_added?
    saved_change_to_response? && response.present?
  end

  def notify_recipient_of_response
    FeedbackMailer.notify_of_response(self).deliver_later
  end

  def cleanup_attachments
    # Cleanup associated files, etc.
  end
end
```

**Available Callbacks:**
```ruby
# Creating records
before_validation
after_validation
before_save
around_save
before_create
around_create
after_create
after_save
after_commit / after_rollback

# Updating records
before_validation
after_validation
before_save
around_save
before_update
around_update
after_update
after_save
after_commit / after_rollback

# Destroying records
before_destroy
around_destroy
after_destroy
after_commit / after_rollback
```
</pattern>

## Enums

<pattern name="enum-usage">
<description>Enums for status and state fields with automatic predicates</description>

**Model with Enums:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  # String-based enum (recommended for readability)
  enum :status, {
    pending: "pending",
    delivered: "delivered",
    read: "read",
    responded: "responded",
    archived: "archived"
  }, prefix: true, scopes: true

  # Integer-based enum
  enum :priority, {
    low: 0,
    medium: 1,
    high: 2,
    urgent: 3
  }, prefix: :priority

  # Track state changes
  after_update :log_status_change, if: :saved_change_to_status?

  private

  def log_status_change
    Rails.logger.info(
      "Feedback ##{id} status: #{status_before_last_save} -> #{status}"
    )
  end
end
```

**Enum Usage:**
```ruby
# Set enum values
feedback.status = "pending"
feedback.status_pending!  # Updates and saves

# Query enum values
feedback.status_pending?  # true/false
feedback.status           # "pending"

# Scopes (when scopes: true)
Feedback.status_pending
Feedback.status_responded
Feedback.priority_urgent

# Get all enum values
Feedback.statuses         # {"pending" => "pending", ...}
Feedback.statuses.keys    # ["pending", "delivered", ...]

# Before/after tracking
feedback.update(status: "delivered")
feedback.status_before_last_save  # "pending"
feedback.saved_change_to_status?  # true
```

**Migration:**
```ruby
class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      # String enum
      t.string :status, default: "pending", null: false

      # Integer enum
      t.integer :priority, default: 0, null: false

      t.timestamps
    end

    add_index :feedbacks, :status
    add_index :feedbacks, :priority
  end
end
```
</pattern>

## Query Optimization

<pattern name="n-plus-one-prevention">
<description>Eager load associations to prevent N+1 queries</description>

**Problem - N+1 Queries:**
```ruby
# ❌ BAD - Triggers N+1 queries
@feedbacks = Feedback.limit(20)

@feedbacks.each do |feedback|
  puts feedback.recipient.name        # Query for each feedback
  puts feedback.category.name         # Another query for each
  puts feedback.tags.pluck(:name)     # More queries!
end
# Result: 1 + 20 + 20 + 20 = 61 queries!
```

**Solution - Eager Loading:**
```ruby
# ✅ GOOD - Eager load associations
@feedbacks = Feedback
  .includes(:recipient, :category, :tags)
  .limit(20)

@feedbacks.each do |feedback|
  puts feedback.recipient.name        # No query
  puts feedback.category.name         # No query
  puts feedback.tags.pluck(:name)     # No query
end
# Result: 4 queries total (feedback, recipients, categories, tags)
```

**Eager Loading Methods:**
```ruby
# includes - Loads in separate queries (default)
Feedback.includes(:recipient, :tags)

# preload - Forces separate queries
Feedback.preload(:recipient, :tags)

# eager_load - Uses LEFT OUTER JOIN
Feedback.eager_load(:recipient, :tags)

# Nested includes
Feedback.includes(recipient: :profile, tags: :category)

# Conditional includes
Feedback.includes(:response).where.not(response: nil)
```
</pattern>

<pattern name="select-only-needed-columns">
<description>Select only required columns to reduce memory usage</description>

**Select Specific Columns:**
```ruby
# ✅ GOOD - Select only needed columns
Feedback.select(:id, :content, :status, :created_at)

# For display lists
Feedback.select(:id, :content, :recipient_email, :status)
  .order(created_at: :desc)
  .limit(50)

# With calculations
Feedback.select("id, content, LENGTH(content) as content_length")
  .where("LENGTH(content) > 1000")

# Using pluck for single/multiple columns
Feedback.pluck(:id, :tracking_code)
# Returns: [[1, "ABC123"], [2, "DEF456"]]

Feedback.pluck(:recipient_email).uniq
# Returns: ["user1@example.com", "user2@example.com"]
```
</pattern>

<pattern name="batch-processing">
<description>Process large datasets efficiently with batching</description>

**Batch Methods:**
```ruby
# find_each - Process records in batches of 1000
Feedback.find_each do |feedback|
  feedback.process_something
end

# Custom batch size
Feedback.find_each(batch_size: 500) do |feedback|
  feedback.process_something
end

# find_in_batches - Get batches, not individual records
Feedback.find_in_batches(batch_size: 100) do |feedbacks|
  # feedbacks is an array of 100 records
  FeedbackProcessor.process_batch(feedbacks)
end

# in_batches - Yields ActiveRecord::Relation
Feedback.in_batches(of: 1000) do |relation|
  relation.update_all(processed: true)
end

# Start from specific ID
Feedback.find_each(start: 1000, batch_size: 500) do |feedback|
  feedback.process_something
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Using callbacks for complex business logic</description>
<reason>Makes models hard to test, introduces hidden side effects, couples unrelated concerns</reason>
<bad-example>
```ruby
# ❌ BAD - Complex logic in callbacks
class Feedback < ApplicationRecord
  after_create :send_email, :update_analytics, :notify_slack,
    :create_audit_log, :trigger_webhooks

  private

  def send_email
    FeedbackMailer.notify_recipient(self).deliver_now
  end

  def update_analytics
    Analytics.track("feedback_created", { id: id, status: status })
  end

  def notify_slack
    SlackNotifier.notify("New feedback received")
  end

  def create_audit_log
    AuditLog.create!(action: "feedback_created", resource: self)
  end

  def trigger_webhooks
    WebhookService.new(self).trigger_all
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use service object
class Feedback < ApplicationRecord
  after_create_commit :enqueue_creation_job

  private

  def enqueue_creation_job
    ProcessFeedbackCreationJob.perform_later(id)
  end
end

# app/services/create_feedback_service.rb
class CreateFeedbackService
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end

  def call
    feedback = Feedback.create!(@params)

    # Explicit, testable, traceable
    FeedbackMailer.notify_recipient(feedback).deliver_later
    Analytics.track("feedback_created", feedback_id: feedback.id)
    SlackNotifier.notify("New feedback received")
    AuditLog.create!(action: "feedback_created", resource: feedback)
    WebhookService.new(feedback).trigger_all

    feedback
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not using database indexes on foreign keys and query columns</description>
<reason>Causes slow queries, poor performance at scale</reason>
<bad-example>
```ruby
# ❌ BAD - No indexes on frequently queried columns
class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.integer :recipient_id
      t.string :status
      t.string :recipient_email
      t.timestamps
    end
  end
end

# Slow queries:
Feedback.where(recipient_id: user.id)     # Table scan
Feedback.where(status: "pending")         # Table scan
Feedback.where(recipient_email: email)    # Table scan
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Add indexes for performance
class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :recipient, foreign_key: { to_table: :users }, index: true
      t.string :status, null: false, default: "pending"
      t.string :recipient_email, null: false
      t.timestamps
    end

    add_index :feedbacks, :status
    add_index :feedbacks, :recipient_email
    add_index :feedbacks, :created_at
    add_index :feedbacks, [:status, :created_at]  # Composite index
  end
end

# Fast queries with indexes
Feedback.where(recipient_id: user.id)
Feedback.where(status: "pending")
Feedback.where(recipient_email: email)
```
</good-example>
</antipattern>

<antipattern>
<description>Using default_scope</description>
<reason>Creates unexpected behavior, hard to override, couples queries to model</reason>
<bad-example>
```ruby
# ❌ BAD - default_scope creates confusion
class Feedback < ApplicationRecord
  default_scope { where(deleted_at: nil).order(created_at: :desc) }
end

# Unexpected behavior:
Feedback.all                    # Always ordered by created_at desc
Feedback.order(status: :asc)    # Still ordered by created_at desc!
Feedback.unscoped.all           # Must remember to unscope
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use explicit scopes
class Feedback < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :default_view, -> { active.recent_first }
end

# Explicit, predictable:
Feedback.active                 # Only non-deleted
Feedback.recent_first           # Only ordering
Feedback.default_view           # Both filters, clear intent
Feedback.active.order(status: :asc)  # Can override
```
</good-example>
</antipattern>

<antipattern>
<description>Not handling dependent record cleanup</description>
<reason>Leaves orphaned records, violates referential integrity</reason>
<bad-example>
```ruby
# ❌ BAD - No cleanup strategy
class Feedback < ApplicationRecord
  has_many :comments
  has_many :attachments
  has_one :response
end

# Deleting feedback leaves orphaned records
feedback.destroy
# comments, attachments, response still exist!
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Define cleanup strategy
class Feedback < ApplicationRecord
  has_many :comments, dependent: :destroy      # Delete all
  has_many :attachments, dependent: :purge_later  # For Active Storage
  has_one :response, dependent: :destroy       # Delete the response
  has_many :tags, dependent: :nullify          # Keep tags, remove link
end

# Or use database foreign keys
class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :feedback, foreign_key: { on_delete: :cascade }
      t.text :content
      t.timestamps
    end
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test ActiveRecord models with unit and integration tests:

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  # Validation tests
  test "requires content" do
    feedback = Feedback.new(recipient_email: "user@example.com")
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end

  test "validates email format" do
    feedback = Feedback.new(content: "Test", recipient_email: "invalid")
    assert_not feedback.valid?
    assert_includes feedback.errors[:recipient_email], "must be a valid email"
  end

  test "validates content length" do
    feedback = Feedback.new(
      content: "Short",
      recipient_email: "user@example.com"
    )
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "is too short"
  end

  # Association tests
  test "has many abuse reports" do
    feedback = feedbacks(:one)
    report = feedback.abuse_reports.create!(
      reason: "spam",
      reporter_email: "reporter@example.com"
    )

    assert_includes feedback.abuse_reports, report
  end

  test "destroys dependent abuse reports" do
    feedback = feedbacks(:one)
    feedback.abuse_reports.create!(
      reason: "spam",
      reporter_email: "reporter@example.com"
    )

    assert_difference("AbuseReport.count", -1) do
      feedback.destroy
    end
  end

  # Scope tests
  test "recent scope returns feedbacks from last 30 days" do
    old_feedback = Feedback.create!(
      content: "Old",
      recipient_email: "user@example.com",
      created_at: 31.days.ago
    )
    new_feedback = feedbacks(:one)

    recent = Feedback.recent

    assert_includes recent, new_feedback
    assert_not_includes recent, old_feedback
  end

  test "by_recipient scope filters by email" do
    feedback1 = feedbacks(:one)
    feedback2 = feedbacks(:two)
    feedback1.update(recipient_email: "alice@example.com")
    feedback2.update(recipient_email: "bob@example.com")

    results = Feedback.by_recipient("alice@example.com")

    assert_includes results, feedback1
    assert_not_includes results, feedback2
  end

  # Callback tests
  test "generates tracking code before create" do
    feedback = Feedback.create!(
      content: "Test feedback",
      recipient_email: "user@example.com"
    )

    assert_not_nil feedback.tracking_code
    assert_equal 10, feedback.tracking_code.length
  end

  test "enqueues delivery job after create" do
    assert_enqueued_with(job: SendFeedbackJob) do
      Feedback.create!(
        content: "Test",
        recipient_email: "user@example.com"
      )
    end
  end

  # Enum tests
  test "status enum provides predicate methods" do
    feedback = feedbacks(:one)
    feedback.update(status: "pending")

    assert feedback.status_pending?
    assert_not feedback.status_delivered?
  end

  test "status enum provides bang methods" do
    feedback = feedbacks(:one)
    feedback.status_delivered!

    assert_equal "delivered", feedback.status
    assert feedback.status_delivered?
  end
end
```
</testing>

<related-skills>
- controller-restful - RESTful controllers for models
- tdd-minitest - Testing models thoroughly
- security-strong-parameters - Secure mass assignment
- security-sql-injection - SQL injection prevention
</related-skills>

<resources>
- [Rails Guides - Active Record Basics](https://guides.rubyonrails.org/active_record_basics.html)
- [Rails Guides - Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
- [Rails Guides - Active Record Validations](https://guides.rubyonrails.org/active_record_validations.html)
- [Rails Guides - Active Record Callbacks](https://guides.rubyonrails.org/active_record_callbacks.html)
- [Rails Guides - Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
</resources>
