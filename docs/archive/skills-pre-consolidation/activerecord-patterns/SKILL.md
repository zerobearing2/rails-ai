---
name: rails-ai:activerecord-patterns
description: Master ActiveRecord patterns for Rails 8.1+ including associations, validations, callbacks, scopes, and query optimization.
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
class CreateUserSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :user_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :theme, default: "light", null: false
      t.boolean :notifications_enabled, default: true, null: false
      t.timestamps
    end
    add_index :user_settings, :user_id, unique: true
  end
end
```

**Generator Command:**
```bash
bin/rails generate model User::Setting user:references theme:string
```

**File Organization:**
```
app/models/
├── user.rb
├── user/setting.rb, profile.rb, preference.rb
├── order.rb
├── order/line_item.rb, payment.rb
└── session.rb  # Independent, not User::Session
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
user = User.create!(email: "user@example.com")
user.setting.update(theme: "dark")
User.joins(:setting).where(user_settings: { theme: "dark" })
User::Setting.where(notifications_enabled: true)
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
class Feedback < ApplicationRecord
  belongs_to :recipient, class_name: "User", optional: true
  belongs_to :category, counter_cache: true
  has_one :response, class_name: "FeedbackResponse", dependent: :destroy
  has_many :abuse_reports, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  # Scoped associations
  has_many :recent_reports, -> { where(created_at: 7.days.ago..) },
    class_name: "AbuseReport"
end
```

**Migration:**
```ruby
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
  end
end
```

**Usage:**
```ruby
feedback = Feedback.create!(content: "Great work!", recipient: current_user, category: Category.find_by(name: "General"))
feedback.recipient.email
feedback.build_response(content: "Thank you!")
feedback.tags << Tag.find_or_create_by(name: "urgent")
```
</pattern>

<pattern name="polymorphic-associations">
<description>Flexible associations where a model belongs to multiple types</description>

**Polymorphic Model:**
```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :author, class_name: "User"
  validates :content, presence: true
end

class Feedback < ApplicationRecord
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
feedback.comments.create!(content: "Great feedback", author: user)
Comment.where(commentable: feedback)
```
</pattern>

<pattern name="self-referential-associations">
<description>Models that reference themselves for hierarchical data</description>

**Self-Referential Model:**
```ruby
class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :destroy

  scope :root_categories, -> { where(parent_id: nil) }

  def ancestors
    parent.nil? ? [] : [parent] + parent.ancestors
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
  end
end
```
</pattern>

## Validations

<pattern name="comprehensive-validations">
<description>Built-in Rails validations for data integrity</description>

**Model with Validations:**
```ruby
class Feedback < ApplicationRecord
  validates :content, presence: true, length: { minimum: 50, maximum: 5000 }
  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: %w[pending delivered read responded] }
  validates :tracking_code, uniqueness: { scope: :recipient_email, case_sensitive: false }
  validates :rating, numericality: { only_integer: true, in: 1..5 }, allow_nil: true

  validate :content_not_spam
  validate :recipient_can_receive_feedback, on: :create

  private

  def content_not_spam
    return if content.blank?
    spam_keywords = %w[viagra cialis lottery]
    errors.add(:content, "appears to contain spam") if spam_keywords.any? { |k| content.downcase.include?(k) }
  end

  def recipient_can_receive_feedback
    return if recipient_email.blank?
    user = User.find_by(email: recipient_email)
    errors.add(:recipient_email, "has disabled feedback") if user&.feedback_disabled?
  end
end
```

**Conditional Validations:**
```ruby
validates :response, presence: true, if: :responded?
validates :sender_email, presence: true, unless: :anonymous?
validates :ai_content, presence: true, if: -> { ai_improved? && status == "pending" }
```
</pattern>

<pattern name="custom-validators">
<description>Reusable validation classes for complex logic</description>

**Custom Validator:**
```ruby
# app/validators/email_validator.rb
class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    record.errors.add(attribute, "is not a valid email") unless value =~ EMAIL_REGEX
  end
end

# Usage
class Feedback < ApplicationRecord
  validates :recipient_email, email: true
end
```

**Word Count Validator:**
```ruby
class ContentLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    word_count = value.to_s.split.size
    record.errors.add(attribute, "must have at least #{options[:minimum_words]} words") if options[:minimum_words] && word_count < options[:minimum_words]
  end
end

# Usage: validates :content, content_length: { minimum_words: 10 }
```
</pattern>

## Scopes and Query Methods

<pattern name="effective-scopes">
<description>Reusable query scopes for common filtering</description>

**Model with Scopes:**
```ruby
class Feedback < ApplicationRecord
  scope :recent, -> { where(created_at: 30.days.ago..) }
  scope :unread, -> { where(status: "delivered") }
  scope :responded, -> { where.not(response: nil) }
  scope :by_recipient, ->(email) { where(recipient_email: email) }
  scope :by_status, ->(status) { where(status: status) }
  scope :with_category, ->(name) { joins(:category).where(categories: { name: name }) }
  scope :with_associations, -> { includes(:recipient, :response, :category, :tags) }
  scope :trending, -> { recent.where("views_count > ?", 100).order(views_count: :desc).limit(10) }
end
```

**Usage:**
```ruby
Feedback.recent.by_recipient("user@example.com").responded
Feedback.by_status("pending").order(created_at: :desc).limit(10)
user.feedbacks.recent.with_associations
```
</pattern>

<pattern name="query-methods">
<description>Class methods for complex queries that don't fit scopes</description>

**Query Class Methods:**
```ruby
class Feedback < ApplicationRecord
  scope :recent, -> { where(created_at: 30.days.ago..) }

  def self.search(query)
    return none if query.blank?
    where("content ILIKE ? OR response ILIKE ?", "%#{sanitize_sql_like(query)}%", "%#{sanitize_sql_like(query)}%")
  end

  def self.statistics_for_period(start_date, end_date)
    where(created_at: start_date..end_date).group(:status).count
  end

  def self.top_recipients(limit = 10)
    select("recipient_email, COUNT(*) as feedback_count").group(:recipient_email).order("feedback_count DESC").limit(limit)
  end
end
```
</pattern>

## Callbacks

<pattern name="minimal-callbacks">
<description>Use callbacks sparingly - prefer service objects for complex logic</description>

**Appropriate Callback Usage:**
```ruby
class Feedback < ApplicationRecord
  before_validation :normalize_email, :strip_whitespace
  before_create :generate_tracking_code
  after_create_commit :enqueue_delivery_job
  after_update_commit :notify_recipient_of_response, if: :response_added?

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
end
```

**Available Callbacks:**
```ruby
before_validation, after_validation, before_save, before_create, after_create, after_save, after_commit
before_update, after_update, before_destroy, after_destroy
```
</pattern>

## Enums

<pattern name="enum-usage">
<description>Enums for status and state fields with automatic predicates</description>

**Model with Enums:**
```ruby
class Feedback < ApplicationRecord
  enum :status, {
    pending: "pending",
    delivered: "delivered",
    read: "read",
    responded: "responded"
  }, prefix: true, scopes: true

  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }, prefix: :priority
end
```

**Enum Usage:**
```ruby
feedback.status = "pending"
feedback.status_pending!              # Updates and saves
feedback.status_pending?              # true/false
Feedback.status_pending               # Scope
Feedback.statuses.keys                # ["pending", "delivered", ...]
feedback.status_before_last_save      # Track changes
```

**Migration:**
```ruby
class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.string :status, default: "pending", null: false
      t.integer :priority, default: 0, null: false
      t.timestamps
    end
    add_index :feedbacks, :status
  end
end
```
</pattern>

## Query Optimization

<pattern name="n-plus-one-prevention">
<description>Eager load associations to prevent N+1 queries</description>

**N+1 Query Prevention:**
```ruby
# ❌ BAD - N+1 queries (1 + 20 + 20 + 20 = 61 queries)
@feedbacks = Feedback.limit(20)
@feedbacks.each do |f|
  puts f.recipient.name, f.category.name, f.tags.pluck(:name)
end

# ✅ GOOD - Eager loading (4 queries total)
@feedbacks = Feedback.includes(:recipient, :category, :tags).limit(20)
@feedbacks.each do |f|
  puts f.recipient.name, f.category.name, f.tags.pluck(:name)
end
```

**Eager Loading Methods:**
```ruby
Feedback.includes(:recipient, :tags)           # Separate queries (default)
Feedback.preload(:recipient, :tags)            # Forces separate queries
Feedback.eager_load(:recipient, :tags)         # LEFT OUTER JOIN
Feedback.includes(recipient: :profile)         # Nested associations
```
</pattern>

<pattern name="select-only-needed-columns">
<description>Select only required columns to reduce memory usage</description>

**Select Specific Columns:**
```ruby
Feedback.select(:id, :content, :status, :created_at)
Feedback.select("id, LENGTH(content) as content_length").where("LENGTH(content) > 1000")
Feedback.pluck(:id, :tracking_code)        # [[1, "ABC123"], [2, "DEF456"]]
Feedback.pluck(:recipient_email).uniq
```
</pattern>

<pattern name="batch-processing">
<description>Process large datasets efficiently with batching</description>

**Batch Processing:**
```ruby
Feedback.find_each { |f| f.process_something }                        # Default 1000
Feedback.find_each(batch_size: 500) { |f| f.process_something }      # Custom size
Feedback.find_in_batches(batch_size: 100) { |batch| FeedbackProcessor.process(batch) }
Feedback.in_batches(of: 1000) { |relation| relation.update_all(processed: true) }
```
</pattern>

<antipatterns>
<antipattern>
<description>Using callbacks for complex business logic</description>
<reason>Makes models hard to test, introduces hidden side effects</reason>
<bad-example>
```ruby
# ❌ BAD
class Feedback < ApplicationRecord
  after_create :send_email, :update_analytics, :notify_slack, :create_audit_log
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

# Service handles all side effects explicitly
class CreateFeedbackService
  def call
    feedback = Feedback.create!(@params)
    FeedbackMailer.notify_recipient(feedback).deliver_later
    Analytics.track("feedback_created", feedback_id: feedback.id)
    feedback
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Missing database indexes</description>
<reason>Causes slow queries at scale</reason>
<bad-example>
```ruby
# ❌ BAD - Table scans
create_table :feedbacks do |t|
  t.integer :recipient_id
  t.string :status
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD
create_table :feedbacks do |t|
  t.references :recipient, foreign_key: { to_table: :users }, index: true
  t.string :status, null: false
end
add_index :feedbacks, :status
add_index :feedbacks, [:status, :created_at]
```
</good-example>
</antipattern>

<antipattern>
<description>Using default_scope</description>
<reason>Unexpected behavior, hard to override</reason>
<bad-example>
```ruby
# ❌ BAD
class Feedback < ApplicationRecord
  default_scope { where(deleted_at: nil).order(created_at: :desc) }
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Explicit scopes
class Feedback < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }
  scope :recent_first, -> { order(created_at: :desc) }
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test models with unit tests:

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "validates presence of content" do
    feedback = Feedback.new(recipient_email: "user@example.com")
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end

  test "destroys dependent records" do
    feedback = feedbacks(:one)
    feedback.abuse_reports.create!(reason: "spam", reporter_email: "test@example.com")
    assert_difference("AbuseReport.count", -1) { feedback.destroy }
  end

  test "scope filters correctly" do
    old = Feedback.create!(content: "Old", recipient_email: "u@example.com", created_at: 31.days.ago)
    recent = Feedback.recent
    assert_not_includes recent, old
  end

  test "enum provides predicate methods" do
    feedback = feedbacks(:one)
    feedback.update(status: "pending")
    assert feedback.status_pending?
  end

  test "callback generates tracking code" do
    feedback = Feedback.create!(content: "Test", recipient_email: "user@example.com")
    assert_equal 10, feedback.tracking_code.length
  end
end
```
</testing>

<related-skills>
- rails-ai:controller-restful - RESTful controllers for models
- rails-ai:tdd-minitest - Testing models thoroughly
- rails-ai:security-strong-parameters - Secure mass assignment
- rails-ai:security-sql-injection - SQL injection prevention
</related-skills>

<resources>
- [Active Record Basics](https://guides.rubyonrails.org/active_record_basics.html)
- [Associations](https://guides.rubyonrails.org/association_basics.html)
- [Validations](https://guides.rubyonrails.org/active_record_validations.html)
- [Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
</resources>
