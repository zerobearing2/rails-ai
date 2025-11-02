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
- Complex queries with joins, multiple filters, or aggregations
- Search functionality with multiple conditions
- Queries reused across controllers or contexts
- Replacing cluttered model scopes (>5-7 scopes)
</when-to-use>

<benefits>
- **Single Responsibility** - Each query object handles one query concern
- **Reusability** - Use across controllers, services, and background jobs
- **Testability** - Test complex queries in isolation
- **Composability** - Chain methods to build queries
- **Performance** - Easier to optimize and prevent N+1
</benefits>

<standards>
- Place in `app/queries/`, name with `Query` suffix
- Accept initial relation (default `Model.all`)
- Return `self` for chainability, provide `results`/`call` to execute
- Use instance variables to build relation incrementally
- Include eager loading to prevent N+1
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
      @relation = case key.to_sym
      when :recipient_email then @relation.where("recipient_email ILIKE ?", "%#{value}%")
      when :sender_email then @relation.where("sender_email ILIKE ?", "%#{value}%")
      when :status then @relation.where(status: value)
      when :category then @relation.where(category: value)
      when :ai_improved then @relation.ai_improved
      when :date_from then @relation.where("created_at >= ?", value)
      when :date_to then @relation.where("created_at <= ?", value)
      else @relation
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
    (times.sum / times.size.to_f / 3600).round(2)
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
stats = FeedbackStatsQuery.new
  .by_recipient(current_user.email)
  .by_date_range(30.days.ago, Time.current)
  .stats
# Returns: { total_count: 42, responded_count: 28, pending_count: 14, ... }
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

  def recent_feedbacks_sent(limit)
    Feedback.where(sender_email: @user.email).order(created_at: :desc).limit(limit)
  end

  def recent_feedbacks_received(limit)
    Feedback.where(recipient_email: @user.email).order(created_at: :desc).limit(limit)
  end

  def recent_responses(limit)
    Feedback.where(recipient_email: @user.email).where.not(response: nil)
      .order(responded_at: :desc).limit(limit)
  end

  def combined_timeline(limit)
    sent = recent_feedbacks_sent(100).map { |f| { type: :sent, feedback: f, timestamp: f.created_at } }
    received = recent_feedbacks_received(100).map { |f| { type: :received, feedback: f, timestamp: f.created_at } }
    responses = recent_responses(100).map { |f| { type: :responded, feedback: f, timestamp: f.responded_at } }
    (sent + received + responses).sort_by { |item| item[:timestamp] }.reverse.take(limit)
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

  def apply_filters
    @relation = @relation.where(status: @params[:status]) if @params[:status].present?
    @relation = @relation.where(category: @params[:category]) if @params[:category].present?
    @relation = @relation.where("created_at >= ?", @params[:date_from]) if @params[:date_from].present?
    @relation = @relation.where("created_at <= ?", @params[:date_to]) if @params[:date_to].present?
  end

  def apply_search
    return unless @params[:q].present?
    @relation = @relation.where("content ILIKE ? OR response ILIKE ?", "%#{@params[:q]}%", "%#{@params[:q]}%")
  end

  def apply_sorting
    column = @params[:sort] || "created_at"
    direction = @params[:direction]&.downcase == "asc" ? :asc : :desc
    @relation = @relation.order(column => direction)
  end

  def apply_pagination
    @relation = @relation.page(@params[:page]).per(@params[:per_page] || 25)
  end
end
```

**Usage:**
```ruby
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
- Complex logic with multiple conditions
- Multiple models or joins required
- Used across many contexts
- Multi-step logic or more than 5-7 scopes on a model

```ruby
# ✅ Clean Model - Basic scopes only
class Feedback < ApplicationRecord
  scope :recent, -> { order(created_at: :desc) }
  scope :responded, -> { where.not(response: nil) }
end

# ✅ Query Object - Complex filtering
class FeedbackQuery
  # Handles complex filtering, searching, pagination, sorting
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Putting complex query logic in controllers</description>
<bad-example>
```ruby
# ❌ FAT CONTROLLER
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
# ✅ THIN CONTROLLER - Delegates to query object
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
</antipattern>

<antipattern>
<description>Not making query methods chainable</description>
<bad-example>
```ruby
# ❌ NOT CHAINABLE - Returns relation, not self
class FeedbackQuery
  def by_recipient(email)
    @relation.where(recipient_email: email)
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ CHAINABLE - Returns self for chaining
class FeedbackQuery
  def by_recipient(email)
    @relation = @relation.where(recipient_email: email)
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
<description>N+1 queries from missing eager loading</description>
<bad-example>
```ruby
# ❌ Missing includes causes N+1
class FeedbackQuery
  def with_recipients
    @relation = @relation.all
    self
  end
end

# View triggers N+1
@feedbacks.each { |f| f.recipient.name }
```
</bad-example>
<good-example>
```ruby
# ✅ Eager loading prevents N+1
class FeedbackQuery
  def with_recipients
    @relation = @relation.includes(:recipient)
    self
  end
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

  test "query object is chainable" do
    query = FeedbackQuery.new.by_recipient("test@example.com").by_status("pending")
    assert_instance_of FeedbackQuery, query
  end

  test "includes eager loads to prevent N+1" do
    assert_queries(2) do
      feedbacks = FeedbackQuery.new.with_associations.results
      feedbacks.each { |f| f.recipient&.name }
    end
  end
end

class FeedbackStatsQueryTest < ActiveSupport::TestCase
  test "calculates correct statistics" do
    3.times { Feedback.create!(recipient_email: "test@example.com", response: "Thanks") }
    2.times { Feedback.create!(recipient_email: "test@example.com", response: nil) }
    stats = FeedbackStatsQuery.new.by_recipient("test@example.com").stats
    assert_equal 5, stats[:total_count]
    assert_equal 3, stats[:responded_count]
  end
end
```
</testing>

<related-skills>
- controller-restful - Using query objects in controllers
- activerecord-patterns - Efficient ActiveRecord patterns
- n-plus-one-prevention - Preventing N+1 queries

</related-skills>

<resources>
- [Rails Guides - Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
- [Query Objects Pattern](https://thoughtbot.com/blog/a-case-for-query-objects-in-rails)
- [Using Query Objects in Rails](https://blog.appsignal.com/2020/06/17/using-query-objects-in-rails.html)
</resources>
