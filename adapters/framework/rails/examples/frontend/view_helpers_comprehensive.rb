# View Helpers Comprehensive Patterns
# Reference: Rails Guides - Action View Helpers
# Category: FRONTEND - VIEW HELPERS

# ============================================================================
# What Are View Helpers?
# ============================================================================

# View helpers are Ruby modules that provide methods for generating HTML,
# formatting data, and encapsulating view logic. They keep views clean and DRY.

# Types of helpers:
# - Built-in Rails helpers (link_to, form_with, etc.)
# - Custom application helpers
# - Module-specific helpers

# Benefits:
# ✅ Reusable view logic
# ✅ Keep views clean
# ✅ Easy to test
# ✅ Encapsulate complex HTML generation

# ============================================================================
# ✅ BUILT-IN RAILS HELPERS (Most Common)
# ============================================================================

module BuiltInHelpersExample
  # Text Helpers
  def text_examples
    # Truncate long text
    truncate("This is a very long sentence", length: 20)
    # => "This is a very lo..."

    # Pluralize
    pluralize(1, "feedback")  # => "1 feedback"
    pluralize(5, "feedback")  # => "5 feedbacks"

    # Time ago in words
    time_ago_in_words(3.days.ago)  # => "3 days"
    time_ago_in_words(2.hours.ago) # => "about 2 hours"

    # Number formatting
    number_to_currency(1234.56)           # => "$1,234.56"
    number_to_percentage(85.5)            # => "85.5%"
    number_with_delimiter(1234567)        # => "1,234,567"
    number_to_human(1234567)              # => "1.23 Million"
    number_to_human_size(1234567890)      # => "1.15 GB"

    # Simple format (converts newlines to <br>)
    simple_format("Line 1\nLine 2")
    # => "<p>Line 1<br />Line 2</p>"

    # Sanitize HTML
    sanitize("<script>alert('xss')</script><p>Safe</p>")
    # => "<p>Safe</p>"

    # Strip tags
    strip_tags("<p>Hello <strong>world</strong></p>")
    # => "Hello world"

    # Word wrap
    word_wrap("This is a very long sentence", line_width: 15)
    # => "This is a very\nlong sentence"
  end

  # Link Helpers
  def link_examples
    # Basic link
    link_to "Home", root_path
    # => <a href="/">Home</a>

    # Link with class
    link_to "Home", root_path, class: "btn btn-primary"

    # Link with data attributes
    link_to "Delete", feedback_path(@feedback),
      data: { turbo_method: :delete, turbo_confirm: "Are you sure?" }

    # Link with block
    link_to root_path do
      content_tag(:span, "Home")
    end

    # Mail to
    mail_to "support@example.com"
    # => <a href="mailto:support@example.com">support@example.com</a>

    mail_to "support@example.com", "Contact Us",
      subject: "Feedback Question",
      body: "I have a question about..."

    # Button to (creates form with single button)
    button_to "Delete", feedback_path(@feedback),
      method: :delete,
      data: { turbo_confirm: "Are you sure?" },
      class: "btn btn-danger"
  end

  # Asset Helpers
  def asset_examples
    # Stylesheets
    stylesheet_link_tag "application", "data-turbo-track": "reload"
    # => <link rel="stylesheet" href="/assets/application-abc123.css" data-turbo-track="reload" />

    # JavaScript
    javascript_importmap_tags
    # => <script type="importmap">...</script>

    # Images
    image_tag "logo.png", alt: "Company Logo", class: "logo"
    # => <img src="/assets/logo.png" alt="Company Logo" class="logo" />

    # With size
    image_tag "avatar.jpg", size: "50x50"
    # => <img src="/assets/avatar.jpg" width="50" height="50" />

    # Favicon
    favicon_link_tag "favicon.ico"
  end

  # Tag Helpers
  def tag_examples
    # Content tag
    content_tag(:div, "Hello", class: "alert")
    # => <div class="alert">Hello</div>

    # Tag builder
    tag.div class: "card" do
      tag.h2("Title") + tag.p("Content")
    end
    # => <div class="card"><h2>Title</h2><p>Content</p></div>

    # Self-closing tag
    tag.br
    # => <br>

    # Data attributes
    tag.button "Click me",
      data: { action: "click->controller#method" }
  end

  # Date/Time Helpers
  def datetime_examples
    # Distance of time in words
    distance_of_time_in_words(Time.current, 2.days.from_now)
    # => "2 days"

    # Time select (form helper)
    time_select :feedback, :created_at

    # Date select
    date_select :feedback, :submitted_on

    # Localized date
    l(Date.today)               # => "12/25/2025"
    l(Time.current, format: :long)
  end
end

# ============================================================================
# ✅ CUSTOM APPLICATION HELPERS
# ============================================================================

# app/helpers/application_helper.rb
module ApplicationHelper
  # Page title helper
  def page_title(title = nil)
    base_title = "The Feedback Agent"

    if title.present?
      "#{title} | #{base_title}"
    else
      base_title
    end
  end

  # Flash message helper
  def flash_messages
    flash.map do |type, message|
      alert_type = case type.to_sym
      when :notice then "success"
      when :alert then "warning"
      when :error then "error"
      else "info"
      end

      content_tag :div, class: "alert alert-#{alert_type}" do
        content_tag(:span, message)
      end
    end.join.html_safe
  end

  # Active link helper
  def active_link_to(name, path, options = {})
    css_class = current_page?(path) ? "active" : ""
    options[:class] = [options[:class], css_class].compact.join(" ")
    link_to name, path, options
  end

  # Icon helper
  def icon(name, options = {})
    options[:class] = ["icon", "icon-#{name}", options[:class]].compact.join(" ")
    content_tag :i, "", options
  end

  # Avatar helper
  def avatar_for(user, size: 40)
    if user.avatar.attached?
      image_tag user.avatar.variant(resize_to_limit: [size, size]),
        alt: user.name,
        class: "avatar",
        loading: "lazy"
    else
      content_tag :div, user.initials,
        class: "avatar avatar-placeholder",
        style: "width: #{size}px; height: #{size}px;"
    end
  end

  # Status badge helper
  def status_badge(status)
    variants = {
      "pending" => "warning",
      "reviewed" => "info",
      "responded" => "success",
      "archived" => "neutral"
    }

    variant = variants[status] || "neutral"

    content_tag :span, status.titleize,
      class: "badge badge-#{variant}"
  end

  # Breadcrumbs helper
  def breadcrumbs
    return unless @breadcrumbs.present?

    content_tag :nav, class: "breadcrumbs", "aria-label": "Breadcrumb" do
      content_tag :ol do
        @breadcrumbs.map.with_index do |(name, path), index|
          content_tag :li do
            if index == @breadcrumbs.size - 1
              content_tag :span, name, "aria-current": "page"
            else
              link_to name, path
            end
          end
        end.join.html_safe
      end
    end
  end

  # Markdown helper
  def markdown(text)
    return "" if text.blank?

    # Using a markdown gem like Redcarpet
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(hard_wrap: true),
      autolink: true,
      tables: true,
      fenced_code_blocks: true
    )

    markdown.render(text).html_safe
  end

  # Conditional wrapper
  def conditional_wrapper(condition, tag: :div, **options, &block)
    content = capture(&block)

    if condition
      content_tag(tag, content, options)
    else
      content
    end
  end
end

# ============================================================================
# ✅ MODULE-SPECIFIC HELPERS
# ============================================================================

# app/helpers/feedbacks_helper.rb
module FeedbacksHelper
  # AI improved badge
  def ai_improved_badge(feedback)
    return unless feedback.ai_improved?

    content_tag :span, class: "badge badge-primary badge-sm" do
      icon("sparkles") + " AI Enhanced"
    end
  end

  # Feedback status icon
  def feedback_status_icon(status)
    icons = {
      "pending" => "clock",
      "reviewed" => "eye",
      "responded" => "check-circle",
      "archived" => "archive"
    }

    icon(icons[status] || "circle")
  end

  # Character count with color
  def character_count_display(content, max_length: 1000)
    count = content.to_s.length
    percentage = (count.to_f / max_length * 100).round

    color_class = if percentage > 90
      "text-error"
    elsif percentage > 75
      "text-warning"
    else
      "text-base-content"
    end

    content_tag :span, class: color_class do
      "#{count} / #{max_length}"
    end
  end

  # Response time display
  def response_time_display(feedback)
    return "No response yet" unless feedback.responded_at

    duration = feedback.responded_at - feedback.created_at
    hours = (duration / 3600).round

    if hours < 1
      "Less than 1 hour"
    elsif hours < 24
      "#{hours} #{'hour'.pluralize(hours)}"
    else
      days = (hours / 24).round
      "#{days} #{'day'.pluralize(days)}"
    end
  end

  # Feedback excerpt with highlight
  def feedback_excerpt(feedback, query: nil, length: 150)
    text = truncate(feedback.content, length: length)

    if query.present?
      highlight(text, query, highlighter: '<mark>\1</mark>')
    else
      text
    end
  end

  # Sender display (anonymous vs identified)
  def sender_display(feedback)
    if feedback.sender_name.present?
      content_tag :span do
        icon("user") + " #{feedback.sender_name}"
      end
    else
      content_tag :span, class: "text-muted" do
        icon("user-secret") + " Anonymous"
      end
    end
  end
end

# ============================================================================
# ✅ HELPER CONCERNS (Reusable Modules)
# ============================================================================

# app/helpers/concerns/date_formatting.rb
module DateFormatting
  extend ActiveSupport::Concern

  # Format date relative to now
  def format_relative_date(date)
    return "Never" if date.nil?

    if date.today?
      "Today at #{date.strftime('%l:%M %p')}"
    elsif date.yesterday?
      "Yesterday at #{date.strftime('%l:%M %p')}"
    elsif date > 7.days.ago
      "#{date.strftime('%A')} at #{date.strftime('%l:%M %p')}"
    else
      date.strftime("%b %d, %Y")
    end
  end

  # Format date range
  def format_date_range(start_date, end_date)
    if start_date.year == end_date.year
      if start_date.month == end_date.month
        "#{start_date.strftime('%b %d')} - #{end_date.strftime('%d, %Y')}"
      else
        "#{start_date.strftime('%b %d')} - #{end_date.strftime('%b %d, %Y')}"
      end
    else
      "#{start_date.strftime('%b %d, %Y')} - #{end_date.strftime('%b %d, %Y')}"
    end
  end
end

# Include in ApplicationHelper
# module ApplicationHelper
#   include DateFormatting
# end

# ============================================================================
# ✅ TESTING HELPERS
# ============================================================================

# test/helpers/feedbacks_helper_test.rb
require "test_helper"

class FeedbacksHelperTest < ActionView::TestCase
  test "ai_improved_badge shows badge for AI improved feedback" do
    feedback = feedbacks(:ai_improved)

    result = ai_improved_badge(feedback)

    assert_includes result, "AI Enhanced"
    assert_includes result, "badge"
  end

  test "ai_improved_badge returns nil for non-AI feedback" do
    feedback = feedbacks(:regular)

    result = ai_improved_badge(feedback)

    assert_nil result
  end

  test "character_count_display shows correct color" do
    # Under 75%
    result = character_count_display("a" * 500, max_length: 1000)
    assert_includes result, "text-base-content"

    # 75-90%
    result = character_count_display("a" * 800, max_length: 1000)
    assert_includes result, "text-warning"

    # Over 90%
    result = character_count_display("a" * 950, max_length: 1000)
    assert_includes result, "text-error"
  end

  test "response_time_display formats correctly" do
    feedback = feedbacks(:one)
    feedback.update(
      created_at: 2.days.ago,
      responded_at: 1.day.ago
    )

    result = response_time_display(feedback)

    assert_equal "1 day", result
  end
end

# ============================================================================
# ✅ ADVANCED PATTERNS
# ============================================================================

# Cacheable helper
module CacheableHelper
  def cached_user_info(user)
    cache ["user_info", user] do
      render partial: "users/info", locals: { user: user }
    end
  end
end

# Component-style helper
module ComponentHelper
  def alert_component(type:, message:, dismissible: true)
    render partial: "shared/alert",
      locals: {
        type: type,
        message: message,
        dismissible: dismissible
      }
  end

  def card_component(title: nil, &block)
    content = capture(&block)

    render partial: "shared/card",
      locals: { title: title, content: content }
  end
end

# Presenter-style helper
module PresenterHelper
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)

    yield presenter if block_given?

    presenter
  end
end

# Usage:
# <% present(@feedback) do |feedback| %>
#   <%= feedback.status_badge %>
#   <%= feedback.formatted_date %>
# <% end %>

# ============================================================================
# RULE: Keep helpers focused and single-purpose
# TEST: Write tests for custom helpers
# ORGANIZE: Use module-specific helpers (feedbacks_helper.rb)
# PREFER: ViewComponents over complex helpers
# DRY: Extract reusable logic into helper concerns
# ============================================================================
