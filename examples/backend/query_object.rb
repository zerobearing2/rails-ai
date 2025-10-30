# Query Object Pattern
# Reference: Rails Query Objects Best Practices
# Category: MODELS - QUERY OBJECTS

# ============================================================================
# What Are Query Objects?
# ============================================================================

# Query objects encapsulate complex database queries, keeping models and
# controllers clean. They provide a single responsibility pattern for
# query logic that would otherwise clutter models.

# Benefits:
# ✅ Encapsulate complex queries
# ✅ Reusable across controllers/contexts
# ✅ Easier to test
# ✅ Keep models focused
# ✅ Composable and chainable

# When to use:
# - Queries spanning multiple tables
# - Complex filtering logic
# - Aggregations and calculations
# - Queries used in multiple places

# ============================================================================
# ✅ RECOMMENDED: Basic Query Object
# ============================================================================

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

# Usage in controllers
class FeedbacksController < ApplicationController
  def index
    @feedbacks = FeedbackQuery.new
      .by_recipient(params[:email])
      .by_status(params[:status])
      .recent(20)
      .results
  end
end

# Usage in models/services
class User < ApplicationRecord
  def recent_feedback(limit = 10)
    FeedbackQuery.new
      .by_recipient(email)
      .recent(limit)
      .results
  end
end

# ============================================================================
# ✅ EXAMPLE: Advanced Query Object with Scopes
# ============================================================================

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

# Usage
query = AdvancedFeedbackQuery.new
query.filter_by_params(params)
  .search(params[:q])
  .order_by(:created_at, :desc)
  .paginate(page: params[:page])
@feedbacks = query.results
@total = query.count

# ============================================================================
# ✅ EXAMPLE: Aggregation Query Object
# ============================================================================

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

# Usage
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

# ============================================================================
# ✅ EXAMPLE: Multi-Model Query Object
# ============================================================================

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

# Usage
activity = UserActivityQuery.new(current_user).recent_activity(10)

# ============================================================================
# ✅ EXAMPLE: Join Query Object
# ============================================================================

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

# Usage
@feedbacks = FeedbackWithTagsQuery.new
  .tagged_with_any(["urgent", "important"])
  .with_tags
  .results

# ============================================================================
# ✅ EXAMPLE: Subquery Object
# ============================================================================

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

# Usage
@top_recipients = PopularRecipientsQuery.new.top_recipients(10)
@responsive_recipients = PopularRecipientsQuery.new.recipients_with_response_rate

# ============================================================================
# ✅ EXAMPLE: Callable Query Object
# ============================================================================

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

# Simple usage
@feedbacks = CallableFeedbackQuery.call(params)

# ============================================================================
# ✅ TESTING QUERY OBJECTS
# ============================================================================

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
end

# ============================================================================
# File Organization
# ============================================================================

# app/queries/
# ├── feedback_query.rb
# ├── advanced_feedback_query.rb
# ├── feedback_stats_query.rb
# ├── user_activity_query.rb
# ├── feedback_with_tags_query.rb
# ├── popular_recipients_query.rb
# └── callable_feedback_query.rb

# test/queries/
# ├── feedback_query_test.rb
# ├── feedback_stats_query_test.rb
# └── ...

# ============================================================================
# RULE: Extract complex queries into query objects
# CHAINABLE: Make query methods return self for method chaining
# TEST: Test query objects with real database queries
# COMPOSE: Build complex queries by composing simple methods
# SCOPES: Use query objects instead of adding many scopes to models
# ============================================================================
