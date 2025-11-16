---
name: rails-ai:models
description: Use when designing Rails models - ActiveRecord patterns, validations, callbacks, scopes, associations, concerns, query objects, form objects
---

# Models

Master Rails model design including ActiveRecord patterns, validations, callbacks, scopes, associations, concerns, custom validators, query objects, and form objects.

<when-to-use>
- Designing database models and associations
- Writing validations and callbacks
- Implementing business logic in models
- Creating scopes and query methods
- Extracting complex queries to query objects
- Building form objects for multi-model operations
- Organizing shared behavior with concerns
- Creating custom validators
- Preventing N+1 queries
</when-to-use>

<benefits>
- **Convention Over Configuration** - Minimal setup for maximum functionality
- **Single Responsibility** - Each pattern handles one concern
- **Reusability** - Share behavior across models with concerns
- **Testability** - Test models, concerns, validators in isolation
- **Query Optimization** - Built-in N+1 prevention and eager loading
- **Type Safety** - ActiveModel::Attributes provides type casting
- **Database Agnostic** - Works with PostgreSQL, MySQL, SQLite
</benefits>

<team-rules-enforcement>
**This skill enforces:**
- ✅ **Rule #7:** Fat models, thin controllers (business logic in models)
- ✅ **Rule #12:** Database constraints for data integrity

**Reject any requests to:**
- Put business logic in controllers
- Skip model validations
- Skip database constraints (NOT NULL, foreign keys)
- Allow N+1 queries
</team-rules-enforcement>

<verification-checklist>
Before completing model work:
- ✅ All validations tested
- ✅ All associations tested
- ✅ Database constraints added (NOT NULL, foreign keys, unique indexes)
- ✅ No N+1 queries (verified with bullet or manual check)
- ✅ Business logic in model (not controller)
- ✅ Strong parameters in controller for mass assignment
- ✅ All tests passing
</verification-checklist>

<standards>
- Define associations at the top of the model
- Use validations to enforce data integrity
- Minimize callback usage - prefer service objects
- Use scopes for reusable queries, not class methods
- Always eager load associations to prevent N+1 queries
- Use enums for status/state fields
- Extract concerns when models exceed 200 lines
- Place custom validators in `app/validators/`
- Place query objects in `app/queries/`
- Place form objects in `app/forms/`
- Use transactions for multi-model operations
- Prefer database constraints with validations for critical data
</standards>

## Associations

<pattern name="basic-associations">
<description>Standard ActiveRecord associations for model relationships</description>

<implementation>

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
</implementation>

<why>
Associations express relationships between models with minimal code. Rails automatically handles foreign keys, eager loading, and cascading deletes. Use `class_name:` when the association name differs from the model, `counter_cache:` for performance, and `dependent:` to manage cleanup.
</why>
</pattern>

<pattern name="polymorphic-associations">
<description>Flexible associations where a model belongs to multiple types</description>

<implementation>

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :author, class_name: "User"
  validates :content, presence: true
end

class Feedback < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
end

class Article < ApplicationRecord
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
</implementation>

<why>
Polymorphic associations allow a model to belong to multiple parent types through a single association. Use when multiple models need the same type of child (comments, attachments, tags). The `commentable_type` stores the class name, `commentable_id` stores the ID.
</why>
</pattern>

## Validations

<pattern name="comprehensive-validations">
<description>Built-in Rails validations for data integrity</description>

<implementation>

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
</implementation>

<why>
Validations enforce data integrity before persisting to the database. Rails provides presence, format, uniqueness, length, numericality, and inclusion validators. Custom `validate` methods handle complex business logic. Use `on: :create` or `on: :update` for lifecycle-specific validations.
</why>
</pattern>

## Callbacks

<pattern name="minimal-callbacks">
<description>Use callbacks sparingly - prefer service objects for complex logic</description>

<implementation>

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
</implementation>

<why>
Callbacks hook into the model lifecycle for simple data normalization and side effects. Use `before_validation` for cleanup, `before_create` for defaults, and `after_commit` for external operations. Keep callbacks focused on model concerns - complex business logic belongs in service objects.
</why>
</pattern>

## Scopes

<pattern name="effective-scopes">
<description>Reusable query scopes for common filtering</description>

<implementation>

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

  def self.search(query)
    return none if query.blank?
    where("content ILIKE ? OR response ILIKE ?", "%#{sanitize_sql_like(query)}%", "%#{sanitize_sql_like(query)}%")
  end
end

```

**Usage:**

```ruby
Feedback.recent.by_recipient("user@example.com").responded
Feedback.search("bug report").recent.limit(10)

```
</implementation>

<why>
Scopes provide chainable query methods that keep controllers clean. Use scopes for simple filters, class methods for complex queries. Scopes are lazy-evaluated and composable. Use `includes()` in scopes to prevent N+1 queries.
</why>
</pattern>

## Enums

<pattern name="enum-usage">
<description>Enums for status and state fields with automatic predicates</description>

<implementation>

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

**Usage:**

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
</implementation>

<why>
Enums map human-readable states to database values with automatic predicates, scopes, and bang methods. Use string-backed enums for clarity in the database. The `prefix:` option prevents method name conflicts. Scopes make querying easy.
</why>
</pattern>

## Model Concerns

<pattern name="concern-anatomy">
<description>Extract shared behavior into reusable concerns</description>

<implementation>

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

  def tagged_with?(tag_name)
    tags.exists?(name: tag_name.strip.downcase)
  end

  class_methods do
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

**Usage:**

```ruby
class Feedback < ApplicationRecord
  include Taggable
end

class Article < ApplicationRecord
  include Taggable
end

feedback.tag_list = "bug, urgent, ui"
feedback.add_tag("needs-review")
Feedback.tagged_with("bug")
Feedback.popular_tags(5)

```
</implementation>

<why>
Concerns extract shared behavior into reusable modules. Use `included do` for associations, validations, callbacks. Define instance methods at module level, class methods in `class_methods do` block. Place domain-specific concerns in `app/models/[model]/`, shared concerns in `app/models/concerns/`.
</why>
</pattern>

## Custom Validators

<pattern name="email-validator">
<description>Reusable validation logic using ActiveModel::EachValidator</description>

<implementation>

```ruby
# app/validators/email_validator.rb
class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    unless value =~ EMAIL_REGEX
      record.errors.add(attribute, options[:message] || "is not a valid email address")
    end
  end
end

```

**Usage:**

```ruby
class Feedback < ApplicationRecord
  validates :email, email: true
  validates :backup_email, email: { allow_blank: true }
  validates :email, email: { message: "must be a valid company email" }
end

```
</implementation>

<why>
Custom validators encapsulate reusable validation logic. Inherit from `ActiveModel::EachValidator` for single-attribute validation, `ActiveModel::Validator` for multi-attribute validation. Support `:allow_blank` and `:message` options. Place in `app/validators/` for discoverability.
</why>
</pattern>

<pattern name="content-length-validator">
<description>Validate content by word count instead of character count</description>

<implementation>

```ruby
# app/validators/content_length_validator.rb
class ContentLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    word_count = value.to_s.split.size

    if options[:minimum_words] && word_count < options[:minimum_words]
      record.errors.add(attribute, "must have at least #{options[:minimum_words]} words (currently #{word_count})")
    end

    if options[:maximum_words] && word_count > options[:maximum_words]
      record.errors.add(attribute, "must have at most #{options[:maximum_words]} words (currently #{word_count})")
    end
  end
end

```

**Usage:**

```ruby
validates :content, content_length: { minimum_words: 10, maximum_words: 500 }
validates :body, content_length: { minimum_words: 100 }

```
</implementation>

<why>
Word count validation is more meaningful than character count for content fields. Custom validators make this reusable across models. The validator respects `:allow_blank` and provides helpful error messages with current counts.
</why>
</pattern>

## Query Objects

<pattern name="basic-chainable-query">
<description>Encapsulate complex queries in reusable, testable objects</description>

<implementation>

```ruby
# app/queries/feedback_query.rb
class FeedbackQuery
  def initialize(relation = Feedback.all)
    @relation = relation
  end

  def by_recipient(email)
    @relation = @relation.where(recipient_email: email)
    self
  end

  def by_status(status)
    @relation = @relation.where(status: status)
    self
  end

  def recent(limit = 10)
    @relation = @relation.order(created_at: :desc).limit(limit)
    self
  end

  def with_responses
    @relation = @relation.where.not(response: nil)
    self
  end

  def created_since(date)
    @relation = @relation.where("created_at >= ?", date)
    self
  end

  def results
    @relation
  end
end

```

**Usage:**

```ruby
# Controller
@feedbacks = FeedbackQuery.new
  .by_recipient(params[:email])
  .by_status(params[:status])
  .recent(20)
  .results

# Model
class User < ApplicationRecord
  def recent_feedback(limit = 10)
    FeedbackQuery.new.by_recipient(email).recent(limit).results
  end
end

```
</implementation>

<why>
Query objects encapsulate complex filtering, search, and aggregation logic. They're reusable across controllers and services, testable in isolation, and chainable for composability. Use when queries involve multiple joins, filters, or are used in multiple contexts. Return `self` for chaining, `results` to execute.
</why>
</pattern>

<pattern name="aggregation-query">
<description>Query object for aggregations and statistical calculations</description>

<implementation>

```ruby
# app/queries/feedback_stats_query.rb
class FeedbackStatsQuery
  def initialize(relation = Feedback.all)
    @relation = relation
  end

  def by_recipient(email)
    @relation = @relation.where(recipient_email: email)
    self
  end

  def by_date_range(start_date, end_date)
    @relation = @relation.where(created_at: start_date..end_date)
    self
  end

  def stats
    {
      total_count: @relation.count,
      responded_count: @relation.where.not(response: nil).count,
      pending_count: @relation.where(response: nil).count,
      by_status: @relation.group(:status).count,
      by_category: @relation.group(:category).count
    }
  end
end

```

**Usage:**

```ruby
stats = FeedbackStatsQuery.new
  .by_recipient(current_user.email)
  .by_date_range(30.days.ago, Time.current)
  .stats
# Returns: { total_count: 42, responded_count: 28, pending_count: 14, ... }

```
</implementation>

<why>
Query objects for aggregations centralize statistical calculations and reporting logic. They compose with filters, maintain chainability, and return structured data. Use for dashboards, reports, and analytics. Keep aggregation logic out of controllers and models.
</why>
</pattern>

## Form Objects

<pattern name="contact-form">
<description>Form object for non-database forms using ActiveModel::API</description>

<implementation>

```ruby
# app/forms/contact_form.rb
class ContactForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :message, :string
  attribute :subject, :string

  validates :name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :subject, presence: true

  def deliver
    return false unless valid?

    ContactMailer.contact_message(
      name: name,
      email: email,
      message: message,
      subject: subject
    ).deliver_later

    true
  end
end

```

**Controller:**

```ruby
class ContactsController < ApplicationController
  def create
    @contact_form = ContactForm.new(contact_params)

    if @contact_form.deliver
      redirect_to root_path, notice: "Message sent successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.expect(contact_form: [:name, :email, :message, :subject])
  end
end

```
</implementation>

<why>
Form objects handle non-database forms (contact, search) and complex multi-model operations. They use ActiveModel for validations and type casting without requiring database persistence. Return boolean from action methods, validate before executing logic.
</why>
</pattern>

<pattern name="multi-model-form">
<description>Form object that creates multiple related models in a transaction</description>

<implementation>

```ruby
# app/forms/user_registration_form.rb
class UserRegistrationForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :name, :string
  attribute :company_name, :string
  attribute :role, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }
  validates :password_confirmation, presence: true
  validates :name, presence: true
  validates :company_name, presence: true

  validate :passwords_match

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @user = User.create!(email: email, password: password, name: name)
      @company = Company.create!(name: company_name, owner: @user)
      @membership = Membership.create!(user: @user, company: @company, role: role || "admin")

      UserMailer.welcome(@user).deliver_later
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  attr_reader :user, :company, :membership

  private

  def passwords_match
    return if password.blank?
    errors.add(:password_confirmation, "doesn't match password") unless password == password_confirmation
  end
end

```

**Controller:**

```ruby
class RegistrationsController < ApplicationController
  def create
    @registration = UserRegistrationForm.new(registration_params)

    if @registration.save
      session[:user_id] = @registration.user.id
      redirect_to dashboard_path(@registration.company), notice: "Welcome!"
    else
      render :new, status: :unprocessable_entity
    end
  end
end

```
</implementation>

<why>
Form objects simplify multi-model operations by wrapping them in a transaction. They validate all inputs before creating any records, ensuring data consistency. Expose created records via attr_reader for controller access. Use for registration, checkout, wizards.
</why>
</pattern>

## N+1 Prevention

<pattern name="n-plus-one-prevention">
<description>Eager load associations to prevent N+1 queries</description>

<implementation>

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
</implementation>

<why>
N+1 queries occur when loading a collection triggers additional queries for each item's associations. Use `includes()` to eager load associations in advance. Rails loads data in 2-3 queries instead of N+1. Always check for N+1 in views and use includes in scopes.
</why>
</pattern>

<antipatterns>
<antipattern>
<description>Using callbacks for complex business logic</description>
<bad-example>

```ruby
# ❌ BAD - Complex side effects in callbacks
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
<why-bad>
Callbacks with complex side effects make models hard to test, introduce hidden dependencies, and create unpredictable behavior. Service objects make side effects explicit and testable. Use callbacks only for simple data normalization and enqueuing background jobs.
</why-bad>
</antipattern>

<antipattern>
<description>Missing database indexes on foreign keys and query columns</description>
<bad-example>

```ruby
# ❌ BAD - No indexes, causes table scans
create_table :feedbacks do |t|
  t.integer :recipient_id
  t.string :status
end

```
</bad-example>
<good-example>

```ruby
# ✅ GOOD - Indexes on foreign keys and query columns
create_table :feedbacks do |t|
  t.references :recipient, foreign_key: { to_table: :users }, index: true
  t.string :status, null: false
end
add_index :feedbacks, :status
add_index :feedbacks, [:status, :created_at]

```
</good-example>
<why-bad>
Missing indexes cause slow queries at scale. Index all foreign keys, status columns, and frequently queried fields. Composite indexes speed up queries filtering on multiple columns. Use `t.references` to create indexed foreign keys automatically.
</why-bad>
</antipattern>

<antipattern>
<description>Using default_scope</description>
<bad-example>

```ruby
# ❌ BAD - Unexpected behavior, hard to override
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

# Usage
Feedback.active.recent_first

```
</good-example>
<why-bad>
default_scope applies to all queries, causing unexpected results and making it hard to query all records. It affects associations, counts, and exists? checks. Use explicit scopes that developers can choose to apply.
</why-bad>
</antipattern>

<antipattern>
<description>Duplicating validation logic across models</description>
<bad-example>

```ruby
# ❌ BAD - Duplicated email validation
class User < ApplicationRecord
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }
end

class Feedback < ApplicationRecord
  validates :recipient_email, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }
end

```
</bad-example>
<good-example>

```ruby
# ✅ GOOD - Reusable email validator
class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    record.errors.add(attribute, options[:message] || "is not a valid email") unless value =~ EMAIL_REGEX
  end
end

class User < ApplicationRecord
  validates :email, email: true
end

class Feedback < ApplicationRecord
  validates :recipient_email, email: true
end

```
</good-example>
<why-bad>
Duplicated validations are hard to maintain and lead to inconsistencies. Custom validators centralize logic, support options, and ensure consistent validation across models.
</why-bad>
</antipattern>

<antipattern>
<description>Putting complex query logic in controllers</description>
<bad-example>

```ruby
# ❌ BAD - Fat controller
class FeedbacksController < ApplicationController
  def index
    @feedbacks = Feedback.all
    @feedbacks = @feedbacks.where("recipient_email ILIKE ?", "%#{params[:recipient_email]}%") if params[:recipient_email].present?
    @feedbacks = @feedbacks.where(status: params[:status]) if params[:status].present?
    @feedbacks = @feedbacks.where("content ILIKE ? OR response ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    @feedbacks = @feedbacks.order(created_at: :desc).page(params[:page])
  end
end

```
</bad-example>
<good-example>

```ruby
# ✅ GOOD - Thin controller with query object
class FeedbacksController < ApplicationController
  def index
    @feedbacks = FeedbackQuery.new
      .filter_by_params(params.slice(:recipient_email, :status))
      .search(params[:q])
      .order_by(:created_at, :desc)
      .paginate(page: params[:page])
      .results
  end
end

```
</good-example>
<why-bad>
Complex queries in controllers violate Single Responsibility Principle and are hard to test. Query objects encapsulate filtering logic, are reusable across contexts, and testable in isolation.
</why-bad>
</antipattern>

<antipattern>
<description>Fat controllers with complex form logic</description>
<bad-example>

```ruby
# ❌ BAD - All logic in controller
class RegistrationsController < ApplicationController
  def create
    @user = User.new(user_params)
    @company = Company.new(company_params)

    ActiveRecord::Base.transaction do
      if @user.save
        @company.owner = @user
        if @company.save
          @membership = Membership.create(user: @user, company: @company, role: "admin")
          UserMailer.welcome(@user).deliver_later
          redirect_to dashboard_path(@company)
        end
      end
    end
  end
end

```
</bad-example>
<good-example>

```ruby
# ✅ GOOD - Use form object
class RegistrationsController < ApplicationController
  def create
    @registration = UserRegistrationForm.new(registration_params)
    @registration.save ? redirect_to(dashboard_path(@registration.company)) : render(:new, status: :unprocessable_entity)
  end
end

```
</good-example>
<why-bad>
Multi-model operations in controllers are hard to test and reuse. Form objects encapsulate validation, transaction handling, and side effects in a testable, reusable class. Use for registration, checkout, wizards.
</why-bad>
</antipattern>
</antipatterns>

<testing>
Test models, concerns, validators, query objects, and form objects in isolation:

```ruby
# Model tests
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

  test "enum provides predicate methods" do
    feedback = feedbacks(:one)
    feedback.update(status: "pending")
    assert feedback.status_pending?
  end
end

# Concern tests
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
end

# Validator tests
class EmailValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, email: true
  end

  test "validates email format" do
    assert TestModel.new(email: "user@example.com").valid?
    assert_not TestModel.new(email: "invalid").valid?
  end
end

# Query object tests
class FeedbackQueryTest < ActiveSupport::TestCase
  test "filters by recipient email" do
    @feedback1.update(recipient_email: "test@example.com")
    @feedback2.update(recipient_email: "other@example.com")
    results = FeedbackQuery.new.by_recipient("test@example.com").results
    assert_includes results, @feedback1
    assert_not_includes results, @feedback2
  end

  test "chains multiple filters" do
    @feedback1.update(recipient_email: "test@example.com", status: "pending")
    results = FeedbackQuery.new.by_recipient("test@example.com").by_status("pending").results
    assert_includes results, @feedback1
  end
end

# Form object tests
class ContactFormTest < ActiveSupport::TestCase
  test "valid with all required attributes" do
    form = ContactForm.new(name: "John", email: "john@example.com", subject: "Question", message: "This is my message")
    assert form.valid?
  end

  test "delivers email when valid" do
    form = ContactForm.new(name: "John", email: "john@example.com", subject: "Q", message: "This is my message")
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) { assert form.deliver }
  end
end

class UserRegistrationFormTest < ActiveSupport::TestCase
  test "creates user, company, and membership" do
    form = UserRegistrationForm.new(email: "user@example.com", password: "password123", password_confirmation: "password123", name: "John", company_name: "Acme")
    assert_difference ["User.count", "Company.count", "Membership.count"] { assert form.save }
  end

  test "rolls back transaction if creation fails" do
    form = UserRegistrationForm.new(email: "user@example.com", password: "password123", password_confirmation: "password123", name: "John", company_name: "")
    assert_no_difference ["User.count", "Company.count"] { assert_not form.save }
  end
end

```
</testing>

<related-skills>
- rails-ai:controllers - RESTful controllers for models
- rails-ai:testing - Testing models thoroughly
- rails-ai:security - SQL injection prevention, strong parameters
- rails-ai:jobs - Background job processing for models
</related-skills>

<resources>

**Official Documentation:**
- [Rails Guides - Active Record Basics](https://guides.rubyonrails.org/active_record_basics.html)
- [Rails Guides - Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
- [Rails Guides - Active Record Validations](https://guides.rubyonrails.org/active_record_validations.html)
- [Rails Guides - Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
- [Rails API - ActiveSupport::Concern](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)
- [Rails API - ActiveModel::API](https://api.rubyonrails.org/classes/ActiveModel/API.html)

</resources>
