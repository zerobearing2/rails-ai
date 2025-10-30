---
name: view-helpers
domain: frontend
dependencies: []
version: 1.0
rails_version: 8.1+
---

# Rails View Helpers

View helpers are Ruby modules that provide reusable methods for generating HTML, formatting data, and encapsulating view logic. They keep views clean, DRY, and maintainable.

<when-to-use>
- Generating repetitive HTML patterns (badges, icons, status indicators)
- Formatting data consistently (dates, numbers, text)
- Creating reusable UI components without ViewComponent overhead
- Encapsulating complex conditional rendering logic
- Building application-wide utilities (page titles, breadcrumbs, flash messages)
- When you need a simpler alternative to ViewComponent
</when-to-use>

<benefits>
- **Reusability** - Write once, use across all views
- **Testability** - Helpers are easy to unit test
- **Clean Views** - Move complex logic out of templates
- **Auto-Escaping** - Helpers respect Rails security defaults
- **Modularity** - Organize by domain (FeedbacksHelper, UsersHelper)
</benefits>

<standards>
- Keep helpers focused and single-purpose
- Use module-specific helpers (feedbacks_helper.rb) over ApplicationHelper when possible
- NEVER use `html_safe` or `raw` on user input (XSS vulnerability)
- Return HTML strings using `content_tag` or tag builder
- Test custom helpers thoroughly
- Prefer ViewComponents for complex, stateful components
- Use helper concerns for shared functionality across helpers
- Follow Rails naming conventions (module name matches controller)
</standards>

## Built-In Rails Helpers

Rails provides powerful built-in helpers for common view tasks.

<pattern name="text-helpers">
<description>Format and manipulate text content</description>

```ruby
# Truncate long text
truncate("This is a very long sentence", length: 20)
# => "This is a very lo..."

# Pluralize
pluralize(1, "feedback")  # => "1 feedback"
pluralize(5, "feedback")  # => "5 feedbacks"

# Time ago in words
time_ago_in_words(3.days.ago)  # => "3 days"
time_ago_in_words(2.hours.ago) # => "about 2 hours"

# Simple format (converts newlines to <br>)
simple_format("Line 1\nLine 2")
# => "<p>Line 1<br />Line 2</p>"

# Sanitize HTML (removes dangerous tags/attributes)
sanitize("<script>alert('xss')</script><p>Safe</p>")
# => "<p>Safe</p>"

# Strip tags
strip_tags("<p>Hello <strong>world</strong></p>")
# => "Hello world"

# Word wrap
word_wrap("This is a very long sentence", line_width: 15)
# => "This is a very\nlong sentence"

# Highlight search terms
highlight("Ruby on Rails", "Rails", highlighter: '<mark>\1</mark>')
# => "Ruby on <mark>Rails</mark>"
```

**In Views:**
```erb
<div class="feedback-content">
  <%= truncate(@feedback.content, length: 150) %>
</div>

<div class="timestamp">
  <%= time_ago_in_words(@feedback.created_at) %> ago
</div>

<div class="count">
  <%= pluralize(@feedbacks.count, "feedback") %>
</div>
```
</pattern>

<pattern name="number-helpers">
<description>Format numbers, currency, and percentages</description>

```ruby
# Currency
number_to_currency(1234.56)           # => "$1,234.56"
number_to_currency(1234.56, unit: "€") # => "€1,234.56"

# Percentage
number_to_percentage(85.5)            # => "85.5%"
number_to_percentage(85.5, precision: 0) # => "86%"

# Delimiter (commas)
number_with_delimiter(1234567)        # => "1,234,567"

# Human readable
number_to_human(1234567)              # => "1.23 Million"
number_to_human_size(1234567890)      # => "1.15 GB"

# Phone number
number_to_phone(5551234567)           # => "555-123-4567"
```

**In Views:**
```erb
<div class="price">
  <%= number_to_currency(@plan.price) %>
</div>

<div class="completion">
  <%= number_to_percentage(@project.completion_rate, precision: 1) %>
</div>

<div class="users">
  <%= number_with_delimiter(@app.user_count) %> users
</div>
```
</pattern>

<pattern name="link-helpers">
<description>Generate links, buttons, and email links</description>

```ruby
# Basic link
link_to "Home", root_path
# => <a href="/">Home</a>

# Link with CSS classes
link_to "Home", root_path, class: "btn btn-primary"

# Link with data attributes (Turbo)
link_to "Delete", feedback_path(@feedback),
  data: { turbo_method: :delete, turbo_confirm: "Are you sure?" }

# Link with block
link_to root_path do
  content_tag(:span, "Home", class: "icon")
end

# Email link
mail_to "support@example.com"
# => <a href="mailto:support@example.com">support@example.com</a>

mail_to "support@example.com", "Contact Us",
  subject: "Feedback Question",
  body: "I have a question about..."

# Button (creates form with single button)
button_to "Delete", feedback_path(@feedback),
  method: :delete,
  data: { turbo_confirm: "Are you sure?" },
  class: "btn btn-danger"
```

**In Views:**
```erb
<nav>
  <%= link_to "Dashboard", dashboard_path, class: "nav-link" %>
  <%= link_to "Settings", settings_path, class: "nav-link" %>
</nav>

<div class="actions">
  <%= button_to "Delete", @feedback, method: :delete,
    data: { turbo_confirm: "Delete this feedback?" },
    class: "btn btn-error" %>
</div>
```
</pattern>

<pattern name="tag-builder">
<description>Build HTML tags programmatically</description>

```ruby
# Content tag (older style)
content_tag(:div, "Hello", class: "alert")
# => <div class="alert">Hello</div>

# Tag builder (modern Rails 8.1+)
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
# => <button data-action="click->controller#method">Click me</button>

# Nested tags
tag.ul class: "list" do
  safe_join([
    tag.li("Item 1"),
    tag.li("Item 2"),
    tag.li("Item 3")
  ])
end
```

**In Views:**
```erb
<%= tag.div class: "status-indicator status-#{@feedback.status}" do %>
  <%= tag.span @feedback.status.titleize, class: "status-text" %>
<% end %>

<%= tag.div class: "avatar", style: "background-color: #{@user.color}" do %>
  <%= @user.initials %>
<% end %>
```
</pattern>

<pattern name="asset-helpers">
<description>Link to stylesheets, JavaScript, and images</description>

```ruby
# Stylesheets
stylesheet_link_tag "application", "data-turbo-track": "reload"
# => <link rel="stylesheet" href="/assets/application.css" data-turbo-track="reload" />

# JavaScript (Rails 8.1+ with importmaps)
javascript_importmap_tags
# => <script type="importmap">...</script>

# Images
image_tag "logo.png", alt: "Company Logo", class: "logo"
# => <img src="/assets/logo.png" alt="Company Logo" class="logo" />

# Image with size
image_tag "avatar.jpg", size: "50x50"
# => <img src="/assets/avatar.jpg" width="50" height="50" />

# Favicon
favicon_link_tag "favicon.ico"

# Video
video_tag "intro.mp4", controls: true, width: 640
```

**In Views:**
```erb
<!DOCTYPE html>
<html>
  <head>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
    <%= favicon_link_tag %>
  </head>
  <body>
    <%= image_tag "hero.jpg", alt: "Hero image", class: "hero-image" %>
  </body>
</html>
```
</pattern>

<pattern name="date-time-helpers">
<description>Format dates and times</description>

```ruby
# Distance of time in words
distance_of_time_in_words(Time.current, 2.days.from_now)
# => "2 days"

distance_of_time_in_words_to_now(3.hours.ago)
# => "about 3 hours"

# Localized date/time (uses I18n)
l(Date.today)                    # => "12/25/2025"
l(Time.current, format: :long)   # => "December 25, 2025 14:30"
l(Time.current, format: :short)  # => "Dec 25, 14:30"

# Form date/time selects
date_select :feedback, :submitted_on
time_select :feedback, :created_at
datetime_select :meeting, :scheduled_at
```

**In Views:**
```erb
<div class="created-at">
  Created <%= time_ago_in_words(@feedback.created_at) %> ago
</div>

<div class="date-range">
  <%= l(@report.start_date) %> - <%= l(@report.end_date) %>
</div>

<div class="updated">
  Last updated: <%= l(@post.updated_at, format: :long) %>
</div>
```
</pattern>

## Custom Application Helpers

Create reusable helpers for application-wide functionality.

<pattern name="page-title-helper">
<description>Manage page titles consistently</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def page_title(title = nil)
    base_title = "The Feedback Agent"

    if title.present?
      "#{title} | #{base_title}"
    else
      base_title
    end
  end
end
```

**In Layout:**
```erb
<!DOCTYPE html>
<html>
  <head>
    <title><%= page_title(yield(:title)) %></title>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

**In Views:**
```erb
<% content_for :title, "Feedback Dashboard" %>

<h1>Feedback Dashboard</h1>
<%# Page title will be: "Feedback Dashboard | The Feedback Agent" %>
```
</pattern>

<pattern name="flash-messages-helper">
<description>Display flash messages with consistent styling</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def flash_messages
    flash.map do |type, message|
      alert_type = case type.to_sym
      when :notice then "success"
      when :alert then "warning"
      when :error then "error"
      else "info"
      end

      content_tag :div, class: "alert alert-#{alert_type}" do
        content_tag(:span, message) +
        button_tag(type: "button", class: "close", data: { dismiss: "alert" }) do
          "×"
        end
      end
    end.join.html_safe
  end
end
```

**In Layout:**
```erb
<div class="flash-container">
  <%= flash_messages %>
</div>
```

**Usage in Controller:**
```ruby
redirect_to @feedback, notice: "Feedback created successfully"
redirect_to feedbacks_path, alert: "You must be signed in"
```
</pattern>

<pattern name="active-link-helper">
<description>Highlight current navigation link</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def active_link_to(name, path, options = {})
    css_class = current_page?(path) ? "active" : ""
    options[:class] = [options[:class], css_class].compact.join(" ")
    link_to name, path, options
  end
end
```

**In Navigation:**
```erb
<nav>
  <%= active_link_to "Dashboard", dashboard_path, class: "nav-link" %>
  <%= active_link_to "Feedbacks", feedbacks_path, class: "nav-link" %>
  <%= active_link_to "Settings", settings_path, class: "nav-link" %>
</nav>
```

**CSS:**
```css
.nav-link {
  color: #666;
}

.nav-link.active {
  color: #000;
  font-weight: bold;
}
```
</pattern>

<pattern name="icon-helper">
<description>Generate icon markup consistently</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def icon(name, options = {})
    options[:class] = ["icon", "icon-#{name}", options[:class]].compact.join(" ")
    content_tag :i, "", options
  end

  # With text
  def icon_with_text(icon_name, text, options = {})
    icon(icon_name) + " " + text
  end
end
```

**In Views:**
```erb
<%= icon("user") %>
<%# => <i class="icon icon-user"></i> %>

<%= icon("trash", class: "text-error") %>
<%# => <i class="icon icon-trash text-error"></i> %>

<%= link_to feedbacks_path do %>
  <%= icon_with_text("inbox", "Feedbacks") %>
<% end %>
```
</pattern>

<pattern name="status-badge-helper">
<description>Display status badges with consistent styling</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
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
end
```

**In Views:**
```erb
<div class="feedback-status">
  <%= status_badge(@feedback.status) %>
</div>
```

**With Icon:**
```ruby
def status_badge(status)
  icons = {
    "pending" => "clock",
    "reviewed" => "eye",
    "responded" => "check-circle",
    "archived" => "archive"
  }

  content_tag :span, class: "badge badge-#{variant}" do
    icon(icons[status]) + " " + status.titleize
  end
end
```
</pattern>

<pattern name="avatar-helper">
<description>Display user avatars with fallback</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
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
end
```

**In User Model:**
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar

  def initials
    name.split.map(&:first).join.upcase[0..1]
  end
end
```

**In Views:**
```erb
<div class="user-info">
  <%= avatar_for(@user, size: 50) %>
  <span class="user-name"><%= @user.name %></span>
</div>
```
</pattern>

<pattern name="breadcrumbs-helper">
<description>Generate breadcrumb navigation</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
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
end
```

**In Controller:**
```ruby
class FeedbacksController < ApplicationController
  def show
    @feedback = Feedback.find(params[:id])
    @breadcrumbs = [
      ["Home", root_path],
      ["Feedbacks", feedbacks_path],
      [@feedback.title, feedback_path(@feedback)]
    ]
  end
end
```

**In Views:**
```erb
<%= breadcrumbs %>
```
</pattern>

## Module-Specific Helpers

Organize domain-specific helpers in dedicated modules.

<pattern name="feedback-helpers">
<description>Feedback-specific helper methods</description>

```ruby
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

  # Character count with color coding
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

  # Feedback excerpt with search highlight
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
```

**In Views:**
```erb
<div class="feedback-card">
  <div class="header">
    <%= sender_display(@feedback) %>
    <%= ai_improved_badge(@feedback) %>
    <%= status_badge(@feedback.status) %>
  </div>

  <div class="content">
    <%= feedback_excerpt(@feedback, query: params[:q]) %>
  </div>

  <div class="footer">
    <span>Response time: <%= response_time_display(@feedback) %></span>
    <%= character_count_display(@feedback.content) %>
  </div>
</div>
```
</pattern>

## Helper Concerns

Share functionality across multiple helpers using concerns.

<pattern name="date-formatting-concern">
<description>Reusable date formatting logic</description>

```ruby
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

  # Smart date format (today/yesterday/date)
  def smart_date(date)
    return "" if date.nil?

    if date.to_date == Date.current
      "Today"
    elsif date.to_date == Date.yesterday
      "Yesterday"
    else
      l(date.to_date, format: :short)
    end
  end
end
```

**Include in Helpers:**
```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  include DateFormatting

  # Now has access to format_relative_date, format_date_range, etc.
end

# app/helpers/feedbacks_helper.rb
module FeedbacksHelper
  include DateFormatting

  # Also has access to date formatting methods
end
```

**In Views:**
```erb
<div class="timestamp">
  <%= format_relative_date(@feedback.created_at) %>
</div>

<div class="report-period">
  <%= format_date_range(@report.start_date, @report.end_date) %>
</div>
```
</pattern>

<pattern name="conditional-wrapper">
<description>Conditionally wrap content in HTML</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def conditional_wrapper(condition, tag: :div, **options, &block)
    content = capture(&block)

    if condition
      content_tag(tag, content, options)
    else
      content
    end
  end

  # With link wrapper
  def link_wrapper(url, **options, &block)
    conditional_wrapper(url.present?, tag: :a, href: url, **options, &block)
  end
end
```

**In Views:**
```erb
<%# Only wrap in link if URL present %>
<%= link_wrapper(@product.url, class: "product-link") do %>
  <%= image_tag @product.image %>
  <h3><%= @product.name %></h3>
<% end %>

<%# Only wrap in div if condition met %>
<%= conditional_wrapper(@user.admin?, tag: :div, class: "admin-badge") do %>
  <%= icon("shield") %> Admin
<% end %>
```
</pattern>

## Advanced Patterns

<pattern name="cacheable-helpers">
<description>Cache expensive helper output</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def cached_user_info(user)
    cache ["user_info", user] do
      render partial: "users/info", locals: { user: user }
    end
  end

  def cached_stats(resource)
    cache ["stats", resource] do
      content_tag :div, class: "stats" do
        safe_join([
          content_tag(:div, "#{resource.views} views", class: "stat"),
          content_tag(:div, "#{resource.likes} likes", class: "stat"),
          content_tag(:div, "#{resource.shares} shares", class: "stat")
        ])
      end
    end
  end
end
```

**In Views:**
```erb
<%= cached_user_info(@user) %>
<%= cached_stats(@post) %>
```

**Cache expires when:**
- User/resource is updated (cache key includes updated_at)
- Manual cache clearing: `user.touch`
</pattern>

<pattern name="component-style-helpers">
<description>Render partials as components</description>

```ruby
# app/helpers/component_helper.rb
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

  def button_component(text, href: nil, method: :get, **options)
    render partial: "shared/button",
      locals: { text: text, href: href, method: method, options: options }
  end
end
```

**In Views:**
```erb
<%= alert_component(type: "success", message: "Feedback saved!") %>

<%= card_component(title: "User Profile") do %>
  <p>User information goes here</p>
<% end %>

<%= button_component("Save Changes", href: @feedback, method: :patch, class: "btn-primary") %>
```

**Note:** For complex components, prefer ViewComponent over this pattern.
</pattern>

<pattern name="markdown-helper">
<description>Safely render markdown content</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def markdown(text)
    return "" if text.blank?

    # Using Redcarpet gem
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        hard_wrap: true,
        filter_html: true,    # Strip HTML
        no_styles: true,      # Strip style attributes
        safe_links_only: true # Only http/https links
      ),
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true
    )

    # Sanitize output for safety
    sanitized = sanitize(
      markdown.render(text),
      tags: %w[p br strong em a ul ol li pre code h1 h2 h3 h4 h5 h6 blockquote table thead tbody tr th td],
      attributes: %w[href title]
    )

    sanitized.html_safe
  end
end
```

**Gemfile:**
```ruby
gem "redcarpet"
```

**In Views:**
```erb
<div class="markdown-content">
  <%= markdown(@post.body) %>
</div>
```
</pattern>

<antipatterns>
<antipattern>
<description>Using html_safe on user input</description>
<reason>Creates XSS vulnerability - allows script execution</reason>
<bad-example>
```ruby
# ❌ DANGEROUS - Allows malicious scripts
def render_content(content)
  content.html_safe
end
```
</bad-example>
<good-example>
```ruby
# ✅ SAFE - Auto-escaped or sanitized
def render_content(content)
  content  # Auto-escaped by Rails
end

# ✅ SAFE - Sanitized with allowlist
def render_html_content(content)
  sanitize(content, tags: %w[p br strong em], attributes: %w[])
end
```
</good-example>
</antipattern>

<antipattern>
<description>Bloated ApplicationHelper with unrelated methods</description>
<reason>Hard to maintain, test, and navigate</reason>
<bad-example>
```ruby
# ❌ BAD - Everything in ApplicationHelper
module ApplicationHelper
  def format_feedback_status(feedback)
    # ...
  end

  def user_avatar(user)
    # ...
  end

  def product_price_display(product)
    # ...
  end

  def order_tracking_link(order)
    # ...
  end

  # ... 50 more methods
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Organized by domain
# app/helpers/feedbacks_helper.rb
module FeedbacksHelper
  def format_feedback_status(feedback)
    # ...
  end
end

# app/helpers/users_helper.rb
module UsersHelper
  def user_avatar(user)
    # ...
  end
end

# app/helpers/products_helper.rb
module ProductsHelper
  def product_price_display(product)
    # ...
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Complex business logic in helpers</description>
<reason>Helpers should format/present data, not contain business logic</reason>
<bad-example>
```ruby
# ❌ BAD - Business logic in helper
module FeedbacksHelper
  def process_feedback(feedback)
    if feedback.ai_improved?
      feedback.score = calculate_ai_score(feedback)
      feedback.save!
      FeedbackMailer.ai_processed(feedback).deliver_later
    end
    feedback
  end

  private

  def calculate_ai_score(feedback)
    # Complex calculation logic...
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Business logic in model/service
# app/models/feedback.rb
class Feedback < ApplicationRecord
  def process_with_ai
    return unless ai_improved?

    self.score = calculate_ai_score
    save!
    FeedbackMailer.ai_processed(self).deliver_later
  end

  private

  def calculate_ai_score
    # Complex calculation logic...
  end
end

# ✅ GOOD - Helper only for presentation
module FeedbacksHelper
  def ai_improved_badge(feedback)
    return unless feedback.ai_improved?

    content_tag :span, "AI Enhanced", class: "badge badge-primary"
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not testing custom helpers</description>
<reason>Helpers are code too - they need tests</reason>
<bad-example>
```ruby
# ❌ BAD - No tests for helper methods
module FeedbacksHelper
  def response_time_display(feedback)
    # Complex logic with no tests
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Comprehensive helper tests
# test/helpers/feedbacks_helper_test.rb
require "test_helper"

class FeedbacksHelperTest < ActionView::TestCase
  test "response_time_display shows hours for same day" do
    feedback = Feedback.new(
      created_at: 3.hours.ago,
      responded_at: Time.current
    )

    result = response_time_display(feedback)

    assert_equal "3 hours", result
  end

  test "response_time_display shows days for multiple days" do
    feedback = Feedback.new(
      created_at: 2.days.ago,
      responded_at: Time.current
    )

    result = response_time_display(feedback)

    assert_equal "2 days", result
  end

  test "response_time_display handles no response" do
    feedback = Feedback.new(created_at: 1.day.ago, responded_at: nil)

    result = response_time_display(feedback)

    assert_equal "No response yet", result
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Returning raw strings instead of safe HTML</description>
<reason>Forces view to call html_safe, easy to forget</reason>
<bad-example>
```ruby
# ❌ BAD - Returns raw string
def icon(name)
  "<i class='icon icon-#{name}'></i>"
end
```

**View must remember to call html_safe:**
```erb
<%= icon("user").html_safe %>  <%# Easy to forget! %>
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Returns safe HTML
def icon(name)
  content_tag :i, "", class: "icon icon-#{name}"
end

# Or with tag builder
def icon(name)
  tag.i class: "icon icon-#{name}"
end
```

**View just uses it:**
```erb
<%= icon("user") %>  <%# Works correctly %>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test helpers thoroughly using ActionView::TestCase:

```ruby
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

  test "character_count_display shows correct color for different percentages" do
    # Under 75% - normal color
    result = character_count_display("a" * 500, max_length: 1000)
    assert_includes result, "text-base-content"
    assert_includes result, "500 / 1000"

    # 75-90% - warning color
    result = character_count_display("a" * 800, max_length: 1000)
    assert_includes result, "text-warning"

    # Over 90% - error color
    result = character_count_display("a" * 950, max_length: 1000)
    assert_includes result, "text-error"
  end

  test "response_time_display formats correctly for different durations" do
    # Less than 1 hour
    feedback = Feedback.new(
      created_at: 30.minutes.ago,
      responded_at: Time.current
    )
    assert_equal "Less than 1 hour", response_time_display(feedback)

    # Multiple hours
    feedback.created_at = 5.hours.ago
    assert_equal "5 hours", response_time_display(feedback)

    # Multiple days
    feedback.created_at = 3.days.ago
    assert_equal "3 days", response_time_display(feedback)

    # No response
    feedback.responded_at = nil
    assert_equal "No response yet", response_time_display(feedback)
  end

  test "feedback_excerpt truncates and highlights query" do
    feedback = Feedback.new(content: "This is a long feedback message that should be truncated")

    # Without query
    result = feedback_excerpt(feedback, length: 30)
    assert_equal "This is a long feedback...", result

    # With query highlighting
    result = feedback_excerpt(feedback, query: "feedback", length: 100)
    assert_includes result, "<mark>feedback</mark>"
  end

  test "sender_display shows name or anonymous" do
    # With name
    feedback = Feedback.new(sender_name: "John Doe")
    result = sender_display(feedback)
    assert_includes result, "John Doe"
    assert_includes result, "icon-user"

    # Anonymous
    feedback = Feedback.new(sender_name: nil)
    result = sender_display(feedback)
    assert_includes result, "Anonymous"
    assert_includes result, "icon-user-secret"
  end
end

# test/helpers/application_helper_test.rb
require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "page_title with custom title" do
    result = page_title("Dashboard")
    assert_equal "Dashboard | The Feedback Agent", result
  end

  test "page_title without custom title" do
    result = page_title
    assert_equal "The Feedback Agent", result
  end

  test "page_title with nil" do
    result = page_title(nil)
    assert_equal "The Feedback Agent", result
  end

  test "status_badge returns correct variant" do
    result = status_badge("pending")
    assert_includes result, "badge-warning"
    assert_includes result, "Pending"

    result = status_badge("responded")
    assert_includes result, "badge-success"
  end

  test "active_link_to adds active class for current page" do
    # Mock current_page? helper
    def current_page?(path)
      path == "/dashboard"
    end

    result = active_link_to("Dashboard", "/dashboard", class: "nav-link")
    assert_includes result, 'class="nav-link active"'

    result = active_link_to("Settings", "/settings", class: "nav-link")
    assert_not_includes result, "active"
  end
end
```

**Test Fixtures:**
```yaml
# test/fixtures/feedbacks.yml
regular:
  content: "Regular feedback"
  ai_improved: false

ai_improved:
  content: "AI improved feedback"
  ai_improved: true
```

**Running Tests:**
```bash
rails test test/helpers/feedbacks_helper_test.rb
rails test test/helpers  # All helper tests
```
</testing>

<related-skills>
- viewcomponent-basics - Modern component-based alternative to helpers
- security-xss - Preventing XSS vulnerabilities in helpers
- hotwire-turbo - Turbo integration with helpers (data attributes)
- tailwind-utility-first - Styling helper-generated HTML
</related-skills>

<resources>
- [Rails Guides - Action View Helpers](https://guides.rubyonrails.org/action_view_helpers.html)
- [Rails API - ActionView::Helpers](https://api.rubyonrails.org/classes/ActionView/Helpers.html)
- [Tag Builder Documentation](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html)
- [Testing Helpers](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
</resources>
