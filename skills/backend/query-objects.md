---
name: query-objects
domain: backend
dependencies: []
version: 1.0
rails_version: 8.1+
---

# Query Objects Pattern

Encapsulate complex database queries in reusable, testable, chainable query objects that keep models and controllers clean.

<when-to-use>
- Complex queries spanning multiple tables or joins
- Filtering logic with multiple parameters
- Search functionality with multiple conditions
- Queries requiring aggregations or calculations
- Queries reused across multiple controllers or contexts
- Replacing cluttered model scopes
- Building composable query pipelines
</when-to-use>

<benefits>
- **Single Responsibility** - Each query object handles one query concern
- **Reusability** - Use across controllers, services, and background jobs
- **Testability** - Test complex queries in isolation from models
- **Composability** - Chain methods to build complex queries
- **Maintainability** - Keep models focused on business logic
- **Performance** - Easier to optimize and add eager loading
</benefits>

<standards>
- Place query objects in `app/queries/` directory
- Name with `Query` suffix (e.g., `FeedbackQuery`)
- Accept an initial relation (default to `Model.all`)
- Make methods chainable by returning `self`
- Provide a `results` or `call` method to execute
- Use instance variables to build the relation incrementally
- Include eager loading to prevent N+1 queries
- Keep query objects focused on querying, not business logic
- Test with real database queries, not mocks
</standards>

## Basic Query Object

<pattern name="basic-chainable-query">
<description>Simple query object with chainable filter methods</description>

**Query Object:**
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

  # Convenience method
  def call
    results
  end
end
```

**Controller Usage:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  def index
    @feedbacks = FeedbackQuery.new
      .by_recipient(params[:email])
      .by_status(params[:status])
      .recent(20)
      .results
  end
end
```

**Model Usage:**
```ruby
# app/models/user.rb
class User < ApplicationRecord
  def recent_feedback(limit = 10)
    FeedbackQuery.new
      .by_recipient(email)
      .recent(limit)
      .results
  end
end
```
</pattern>

## Advanced Query Patterns

<pattern name="advanced-with-scopes">
<description>Query object with extended scopes module for additional filters</description>

**Query Object:**
```ruby
# app/queries/advanced_feedback_query.rb
class AdvancedFeedbackQuery
  attr_reader :relation

  def initialize(relation = Feedback.all)
    @relation = relation.extending(Scopes)
  end

  module Scopes
    def with_sender_info
      where.not(sender_email: nil).or(where.not(sender_name: nil))
    end

    def anonymous
      where(sender_email: nil, sender_name: nil)
    end

    def unanswered
      where(response: nil)
    end

    def responded
      where.not(response: nil)
    end

    def ai_improved
      where(ai_improved: true)
    end

    def by_date_range(start_date, end_date)
      where(created_at: start_date..end_date)
    end
  end

  def filter_by_params(params)
    params.each do |key, value|
      next if value.blank?

      case key.to_sym
      when :recipient_email
        @relation = @relation.where("recipient_email ILIKE ?", "%#{value}%")
      when :sender_email
        @relation = @relation.where("sender_email ILIKE ?", "%#{value}%")
      when :status
        @relation = @relation.where(status: value)
      when :category
        @relation = @relation.where(category: value)
      when :ai_improved
        @relation = @relation.ai_improved
      when :date_from
        @relation = @relation.where("created_at >= ?", value)
      when :date_to
        @relation = @relation.where("created_at <= ?", value)
      end
    end

    self
  end

  def search(query)
    return self if query.blank?

    @relation = @relation.where(
      "content ILIKE ? OR response ILIKE ?",
      "%#{query}%",
      "%#{query}%"
    )
    self
  end

  def paginate(page:, per_page: 25)
    @relation = @relation.page(page).per(per_page)
    self
  end

  def order_by(column, direction = :desc)
    @relation = @relation.order(column => direction)
    self
  end

  def results
    @relation
  end

  def count
    @relation.count
  end

  def exists?
    @relation.exists?
  end
end
```

**Usage:**
```ruby
query = AdvancedFeedbackQuery.new
query.filter_by_params(params)
  .search(params[:q])
  .order_by(:created_at, :desc)
  .paginate(page: params[:page])

@feedbacks = query.results
@total = query.count
```
</pattern>

<pattern name="aggregation-query">
<description>Query object for aggregations and statistical calculations</description>

**Query Object:**
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
      total_count: total_count,
      responded_count: responded_count,
      pending_count: pending_count,
      average_response_time: average_response_time,
      ai_improved_count: ai_improved_count,
      by_status: status_breakdown,
      by_category: category_breakdown
    }
  end

  private

  def total_count
    @relation.count
  end

  def responded_count
    @relation.where.not(response: nil).count
  end

  def pending_count
    @relation.where(response: nil).count
  end

  def average_response_time
    responded = @relation.where.not(response: nil, responded_at: nil)

    return 0 if responded.empty?

    times = responded.map { |f| (f.responded_at - f.created_at).to_i }
    (times.sum / times.size.to_f / 3600).round(2) # Hours
  end

  def ai_improved_count
    @relation.where(ai_improved: true).count
  end

  def status_breakdown
    @relation.group(:status).count
  end

  def category_breakdown
    @relation.group(:category).count
  end
end
```

**Usage:**
```ruby
stats_query = FeedbackStatsQuery.new
  .by_recipient(current_user.email)
  .by_date_range(30.days.ago, Time.current)

@stats = stats_query.stats
# => {
#   total_count: 42,
#   responded_count: 28,
#   pending_count: 14,
#   average_response_time: 4.5,
#   ai_improved_count: 15,
#   by_status: { "pending" => 14, "responded" => 28 },
#   by_category: { "general" => 20, "technical" => 22 }
# }
```
</pattern>

<pattern name="multi-model-query">
<description>Query object combining data from multiple models</description>

**Query Object:**
```ruby
# app/queries/user_activity_query.rb
class UserActivityQuery
  def initialize(user)
    @user = user
  end

  def recent_activity(limit = 20)
    {
      feedbacks_sent: recent_feedbacks_sent(limit),
      feedbacks_received: recent_feedbacks_received(limit),
      responses_given: recent_responses(limit),
      combined_timeline: combined_timeline(limit)
    }
  end

  private

  attr_reader :user

  def recent_feedbacks_sent(limit)
    Feedback.where(sender_email: user.email)
      .order(created_at: :desc)
      .limit(limit)
  end

  def recent_feedbacks_received(limit)
    Feedback.where(recipient_email: user.email)
      .order(created_at: :desc)
      .limit(limit)
  end

  def recent_responses(limit)
    Feedback.where(recipient_email: user.email)
      .where.not(response: nil)
      .order(responded_at: :desc)
      .limit(limit)
  end

  def combined_timeline(limit)
    sent = recent_feedbacks_sent(100).map { |f| activity_item(f, :sent) }
    received = recent_feedbacks_received(100).map { |f| activity_item(f, :received) }
    responses = recent_responses(100).map { |f| activity_item(f, :responded) }

    (sent + received + responses)
      .sort_by { |item| item[:timestamp] }
      .reverse
      .take(limit)
  end

  def activity_item(feedback, type)
    {
      type: type,
      feedback: feedback,
      timestamp: timestamp_for(feedback, type)
    }
  end

  def timestamp_for(feedback, type)
    case type
    when :responded then feedback.responded_at
    else feedback.created_at
    end
  end
end
```

**Usage:**
```ruby
activity = UserActivityQuery.new(current_user).recent_activity(10)
```
</pattern>

<pattern name="join-query">
<description>Query object with joins and includes for associations</description>

**Query Object:**
```ruby
# app/queries/feedback_with_tags_query.rb
class FeedbackWithTagsQuery
  def initialize(relation = Feedback.all)
    @relation = relation
  end

  def with_tags
    @relation = @relation.includes(:tags)
    self
  end

  def tagged_with(tag_name)
    @relation = @relation.joins(:tags).where(tags: { name: tag_name })
    self
  end

  def tagged_with_any(tag_names)
    @relation = @relation.joins(:tags).where(tags: { name: tag_names }).distinct
    self
  end

  def tagged_with_all(tag_names)
    tag_names.each do |tag_name|
      @relation = @relation.joins(:tags).where(tags: { name: tag_name })
    end
    @relation = @relation.distinct
    self
  end

  def most_tagged(limit = 10)
    @relation = @relation
      .select("feedbacks.*, COUNT(taggings.id) as tags_count")
      .joins(:taggings)
      .group("feedbacks.id")
      .order("tags_count DESC")
      .limit(limit)
    self
  end

  def results
    @relation
  end
end
```

**Usage:**
```ruby
@feedbacks = FeedbackWithTagsQuery.new
  .tagged_with_any(["urgent", "important"])
  .with_tags
  .results
```
</pattern>

<pattern name="subquery-aggregate">
<description>Query object with subqueries and aggregations</description>

**Query Object:**
```ruby
# app/queries/popular_recipients_query.rb
class PopularRecipientsQuery
  def initialize(relation = Feedback.all)
    @relation = relation
  end

  def top_recipients(limit = 10)
    @relation
      .select("recipient_email, COUNT(*) as feedback_count")
      .group(:recipient_email)
      .order("feedback_count DESC")
      .limit(limit)
  end

  def recipients_with_response_rate
    @relation
      .select(
        "recipient_email",
        "COUNT(*) as total_feedback",
        "COUNT(CASE WHEN response IS NOT NULL THEN 1 END) as responded",
        "CAST(COUNT(CASE WHEN response IS NOT NULL THEN 1 END) AS FLOAT) / " \
        "COUNT(*) * 100 as response_rate"
      )
      .group(:recipient_email)
      .having("COUNT(*) >= ?", 5) # At least 5 feedback items
      .order("response_rate DESC")
  end

  def recipients_with_avg_response_time
    @relation
      .select(
        "recipient_email",
        "AVG(EXTRACT(EPOCH FROM (responded_at - created_at)) / 3600) as avg_hours"
      )
      .where.not(responded_at: nil)
      .group(:recipient_email)
      .order("avg_hours ASC")
  end
end
```

**Usage:**
```ruby
@top_recipients = PopularRecipientsQuery.new.top_recipients(10)
@responsive_recipients = PopularRecipientsQuery.new.recipients_with_response_rate
```
</pattern>

<pattern name="callable-query">
<description>Single-purpose callable query object using class method</description>

**Query Object:**
```ruby
# app/queries/callable_feedback_query.rb
class CallableFeedbackQuery
  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params
    @relation = Feedback.all
  end

  def call
    apply_filters
    apply_search
    apply_sorting
    apply_pagination
    @relation
  end

  private

  attr_reader :params

  def apply_filters
    @relation = @relation.where(status: params[:status]) if params[:status].present?
    @relation = @relation.where(category: params[:category]) if params[:category].present?

    if params[:date_from].present?
      @relation = @relation.where("created_at >= ?", params[:date_from])
    end

    if params[:date_to].present?
      @relation = @relation.where("created_at <= ?", params[:date_to])
    end
  end

  def apply_search
    return unless params[:q].present?

    @relation = @relation.where(
      "content ILIKE ? OR response ILIKE ?",
      "%#{params[:q]}%",
      "%#{params[:q]}%"
    )
  end

  def apply_sorting
    sort_column = params[:sort] || "created_at"
    sort_direction = params[:direction]&.downcase == "asc" ? :asc : :desc

    @relation = @relation.order(sort_column => sort_direction)
  end

  def apply_pagination
    @relation = @relation.page(params[:page]).per(params[:per_page] || 25)
  end
end
```

**Usage:**
```ruby
# Simple one-liner
@feedbacks = CallableFeedbackQuery.call(params)
```
</pattern>

## Scopes vs Query Objects

<pattern name="when-to-choose">
<description>Guidelines for choosing between scopes and query objects</description>

**Use Scopes When:**
```ruby
# ✅ Simple, reusable filters on a single model
class Feedback < ApplicationRecord
  scope :recent, -> { order(created_at: :desc) }
  scope :responded, -> { where.not(response: nil) }
  scope :pending, -> { where(response: nil) }
  scope :for_recipient, ->(email) { where(recipient_email: email) }
end

# Usage is simple and clear
Feedback.recent.responded.for_recipient("user@example.com")
```

**Use Query Objects When:**
```ruby
# ✅ Complex logic with multiple conditions
class FeedbackQuery
  # Handles complex filtering, searching, pagination, sorting
  # Multiple responsibilities that would clutter the model
  # Logic used across different contexts
end

# ❌ Fat Model with Too Many Scopes
class Feedback < ApplicationRecord
  scope :recent, -> { order(created_at: :desc) }
  scope :responded, -> { where.not(response: nil) }
  scope :pending, -> { where(response: nil) }
  scope :by_recipient, ->(email) { where(recipient_email: email) }
  scope :by_sender, ->(email) { where(sender_email: email) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_category, ->(category) { where(category: category) }
  scope :search, ->(q) { where("content ILIKE ?", "%#{q}%") }
  scope :ai_improved, -> { where(ai_improved: true) }
  # ... 20 more scopes
end

# ✅ Clean Model with Query Object
class Feedback < ApplicationRecord
  # Only the most common scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :responded, -> { where.not(response: nil) }
end

# Complex queries moved to query object
class FeedbackQuery
  # All the complex filtering logic
end
```

**Decision Matrix:**
- Single model, simple condition → **Use scope**
- Multiple models or joins → **Use query object**
- Used in 1-2 places → **Use scope**
- Used across many contexts → **Use query object**
- Simple one-liner → **Use scope**
- Multi-step logic → **Use query object**
- More than 5-7 scopes on a model → **Extract to query object**
</pattern>

<antipatterns>
<antipattern>
<description>Cluttering models with too many scopes</description>
<reason>Makes models hard to maintain and understand</reason>
<bad-example>
```ruby
# ❌ FAT MODEL - Too many scopes
class Feedback < ApplicationRecord
  scope :recent, -> { order(created_at: :desc) }
  scope :responded, -> { where.not(response: nil) }
  scope :pending, -> { where(response: nil) }
  scope :by_recipient, ->(email) { where(recipient_email: email) }
  scope :by_sender, ->(email) { where(sender_email: email) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_category, ->(category) { where(category: category) }
  scope :search_content, ->(q) { where("content ILIKE ?", "%#{q}%") }
  scope :search_response, ->(q) { where("response ILIKE ?", "%#{q}%") }
  scope :ai_improved, -> { where(ai_improved: true) }
  scope :created_after, ->(date) { where("created_at >= ?", date) }
  scope :created_before, ->(date) { where("created_at <= ?", date) }
  scope :with_sender_info, -> { where.not(sender_email: nil) }
  scope :anonymous, -> { where(sender_email: nil) }
  # ... and 15 more scopes
end
```
</bad-example>
<good-example>
```ruby
# ✅ CLEAN MODEL - Basic scopes only
class Feedback < ApplicationRecord
  scope :recent, -> { order(created_at: :desc) }
  scope :responded, -> { where.not(response: nil) }
  scope :pending, -> { where(response: nil) }
end

# ✅ QUERY OBJECT - Complex filtering
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

  def search(query)
    return self if query.blank?
    @relation = @relation.where("content ILIKE ? OR response ILIKE ?", "%#{query}%", "%#{query}%")
    self
  end

  def results
    @relation
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Putting complex query logic in controllers</description>
<reason>Controllers become bloated and logic cannot be reused</reason>
<bad-example>
```ruby
# ❌ FAT CONTROLLER - Complex query logic
class FeedbacksController < ApplicationController
  def index
    @feedbacks = Feedback.all

    if params[:recipient_email].present?
      @feedbacks = @feedbacks.where("recipient_email ILIKE ?", "%#{params[:recipient_email]}%")
    end

    if params[:status].present?
      @feedbacks = @feedbacks.where(status: params[:status])
    end

    if params[:q].present?
      @feedbacks = @feedbacks.where(
        "content ILIKE ? OR response ILIKE ?",
        "%#{params[:q]}%",
        "%#{params[:q]}%"
      )
    end

    if params[:date_from].present?
      @feedbacks = @feedbacks.where("created_at >= ?", params[:date_from])
    end

    @feedbacks = @feedbacks.order(created_at: :desc).page(params[:page])
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ THIN CONTROLLER - Delegates to query object
class FeedbacksController < ApplicationController
  def index
    @feedbacks = FeedbackQuery.new
      .filter_by_params(params.slice(:recipient_email, :status, :date_from))
      .search(params[:q])
      .order_by(:created_at, :desc)
      .paginate(page: params[:page])
      .results
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not making query methods chainable</description>
<reason>Prevents composing queries and forces nesting</reason>
<bad-example>
```ruby
# ❌ NOT CHAINABLE - Must nest or reassign
class FeedbackQuery
  def by_recipient(email)
    @relation.where(recipient_email: email)  # Returns relation, not self
  end

  def by_status(status)
    @relation.where(status: status)  # Returns relation, not self
  end
end

# Forces awkward usage
query = FeedbackQuery.new
relation = query.by_recipient(email)
relation = relation.where(status: status)  # Can't chain from query object
```
</bad-example>
<good-example>
```ruby
# ✅ CHAINABLE - Returns self
class FeedbackQuery
  def by_recipient(email)
    @relation = @relation.where(recipient_email: email)
    self  # Return self to enable chaining
  end

  def by_status(status)
    @relation = @relation.where(status: status)
    self  # Return self to enable chaining
  end

  def results
    @relation  # Final method returns relation
  end
end

# Enables clean chaining
FeedbackQuery.new
  .by_recipient(email)
  .by_status(status)
  .results
```
</good-example>
</antipattern>

<antipattern>
<description>N+1 queries in query objects</description>
<reason>Poor performance when iterating over results</reason>
<bad-example>
```ruby
# ❌ N+1 PROBLEM - Missing includes
class FeedbackQuery
  def with_recipients
    @relation = @relation.all  # No eager loading
    self
  end
end

# Controller
@feedbacks = FeedbackQuery.new.with_recipients.results

# View - triggers N+1
@feedbacks.each do |feedback|
  feedback.recipient.name  # Extra query for each feedback!
end
```
</bad-example>
<good-example>
```ruby
# ✅ EAGER LOADING - Prevents N+1
class FeedbackQuery
  def with_recipients
    @relation = @relation.includes(:recipient)  # Eager load
    self
  end
end

# Controller
@feedbacks = FeedbackQuery.new.with_recipients.results

# View - no N+1
@feedbacks.each do |feedback|
  feedback.recipient.name  # No extra queries!
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test query objects with real database queries, not mocks:

```ruby
# test/queries/feedback_query_test.rb
require "test_helper"

class FeedbackQueryTest < ActiveSupport::TestCase
  setup do
    @recipient_email = "recipient@example.com"
    @feedback1 = feedbacks(:one)
    @feedback2 = feedbacks(:two)
  end

  test "filters by recipient email" do
    @feedback1.update(recipient_email: @recipient_email)
    @feedback2.update(recipient_email: "other@example.com")

    results = FeedbackQuery.new.by_recipient(@recipient_email).results

    assert_includes results, @feedback1
    assert_not_includes results, @feedback2
  end

  test "filters by status" do
    @feedback1.update(status: "pending")
    @feedback2.update(status: "responded")

    results = FeedbackQuery.new.by_status("pending").results

    assert_includes results, @feedback1
    assert_not_includes results, @feedback2
  end

  test "chains multiple filters" do
    @feedback1.update(
      recipient_email: @recipient_email,
      status: "pending"
    )
    @feedback2.update(
      recipient_email: @recipient_email,
      status: "responded"
    )

    results = FeedbackQuery.new
      .by_recipient(@recipient_email)
      .by_status("pending")
      .results

    assert_includes results, @feedback1
    assert_not_includes results, @feedback2
  end

  test "returns recent feedbacks with limit" do
    5.times { Feedback.create!(content: "Test", recipient_email: @recipient_email) }

    results = FeedbackQuery.new.recent(3).results

    assert_equal 3, results.size
  end

  test "filters feedbacks with responses" do
    @feedback1.update(response: "Thank you")
    @feedback2.update(response: nil)

    results = FeedbackQuery.new.with_responses.results

    assert_includes results, @feedback1
    assert_not_includes results, @feedback2
  end

  test "query object is chainable" do
    query = FeedbackQuery.new
      .by_recipient(@recipient_email)
      .by_status("pending")

    # Should return self for chaining
    assert_instance_of FeedbackQuery, query
  end

  test "includes eager loads to prevent N+1" do
    @feedback1.update(recipient_email: @recipient_email)

    assert_queries(2) do  # 1 for feedbacks, 1 for recipients
      feedbacks = FeedbackQuery.new
        .by_recipient(@recipient_email)
        .with_associations
        .results

      feedbacks.each { |f| f.recipient&.name }
    end
  end
end

# test/queries/feedback_stats_query_test.rb
class FeedbackStatsQueryTest < ActiveSupport::TestCase
  test "calculates correct statistics" do
    recipient = "stats@example.com"

    # Create test data
    3.times { Feedback.create!(recipient_email: recipient, response: "Thanks") }
    2.times { Feedback.create!(recipient_email: recipient, response: nil) }

    stats = FeedbackStatsQuery.new.by_recipient(recipient).stats

    assert_equal 5, stats[:total_count]
    assert_equal 3, stats[:responded_count]
    assert_equal 2, stats[:pending_count]
  end

  test "handles empty result set" do
    stats = FeedbackStatsQuery.new.by_recipient("nonexistent@example.com").stats

    assert_equal 0, stats[:total_count]
    assert_equal 0, stats[:responded_count]
  end
end
```
</testing>

<related-skills>
- controller-restful - Using query objects in controllers
- activerecord-queries - Efficient ActiveRecord querying
- n-plus-one-prevention - Preventing N+1 queries
- service-objects - Service objects for business logic
- model-organization - Keeping models focused
</related-skills>

<resources>
- [Rails Guides - Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
- [Query Objects Pattern](https://thoughtbot.com/blog/a-case-for-query-objects-in-rails)
- [Organizing Business Logic in Rails](https://blog.appsignal.com/2020/06/17/using-query-objects-in-rails.html)
</resources>
