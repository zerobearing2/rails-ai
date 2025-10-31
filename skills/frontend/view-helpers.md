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

# Sanitize HTML (removes dangerous tags/attributes)
sanitize("<script>alert('xss')</script><p>Safe</p>")
# => "<p>Safe</p>"
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

# Percentage
number_to_percentage(85.5, precision: 0) # => "86%"

# Delimiter (commas)
number_with_delimiter(1234567)        # => "1,234,567"

# Human readable size
number_to_human_size(1234567890)      # => "1.15 GB"
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
link_to "Home", root_path, class: "btn btn-primary"

# Link with data attributes (Turbo)
link_to "Delete", feedback_path(@feedback),
  data: { turbo_method: :delete, turbo_confirm: "Are you sure?" }

# Email link
mail_to "support@example.com", "Contact Us"

# Button (creates form with single button)
button_to "Delete", feedback_path(@feedback),
  method: :delete,
  data: { turbo_confirm: "Are you sure?" }
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
# Tag builder (modern Rails 8.1+)
tag.div class: "card" do
  tag.h2("Title") + tag.p("Content")
end

# Data attributes
tag.button "Click me",
  data: { action: "click->controller#method" }

# Nested tags
tag.ul class: "list" do
  safe_join([tag.li("Item 1"), tag.li("Item 2")])
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

# JavaScript (Rails 8.1+ with importmaps)
javascript_importmap_tags

# Images
image_tag "logo.png", alt: "Company Logo", size: "50x50"

# Favicon
favicon_link_tag
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
distance_of_time_in_words_to_now(3.hours.ago)
# => "about 3 hours"

# Localized date/time (uses I18n)
l(Date.today)                    # => "12/25/2025"
l(Time.current, format: :long)   # => "December 25, 2025 14:30"
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
  def ai_improved_badge(feedback)
    return unless feedback.ai_improved?

    content_tag :span, class: "badge badge-primary badge-sm" do
      icon("sparkles") + " AI Enhanced"
    end
  end

  def feedback_status_icon(status)
    icons = {
      "pending" => "clock", "reviewed" => "eye",
      "responded" => "check-circle", "archived" => "archive"
    }
    icon(icons[status] || "circle")
  end

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

    content_tag :span, "#{count} / #{max_length}", class: color_class
  end

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

  def feedback_excerpt(feedback, query: nil, length: 150)
    text = truncate(feedback.content, length: length)
    query.present? ? highlight(text, query, highlighter: '<mark>\1</mark>') : text
  end

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
```

**Include in Helpers:**
```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  include DateFormatting
end
```

**In Views:**
```erb
<div class="timestamp">
  <%= format_relative_date(@feedback.created_at) %>
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
          content_tag(:div, "#{resource.likes} likes", class: "stat")
        ])
      end
    end
  end
end
```

**In Views:**
```erb
<%= cached_user_info(@user) %>
```
</pattern>

<pattern name="component-style-helpers">
<description>Render partials as components</description>

```ruby
# app/helpers/component_helper.rb
module ComponentHelper
  def alert_component(type:, message:, dismissible: true)
    render partial: "shared/alert",
      locals: { type: type, message: message, dismissible: dismissible }
  end

  def card_component(title: nil, &block)
    render partial: "shared/card",
      locals: { title: title, content: capture(&block) }
  end
end
```

**In Views:**
```erb
<%= alert_component(type: "success", message: "Feedback saved!") %>

<%= card_component(title: "User Profile") do %>
  <p>User information goes here</p>
<% end %>
```
</pattern>

<pattern name="markdown-helper">
<description>Safely render markdown content</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def markdown(text)
    return "" if text.blank?

    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        hard_wrap: true, filter_html: true, safe_links_only: true
      ),
      autolink: true, tables: true, fenced_code_blocks: true
    )

    sanitize(
      markdown.render(text),
      tags: %w[p br strong em a ul ol li pre code h1 h2 h3],
      attributes: %w[href title]
    ).html_safe
  end
end
```

**In Views:**
```erb
<%= markdown(@post.body) %>
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
  end

  test "character_count_display shows correct color" do
    # Under 75%
    result = character_count_display("a" * 500, max_length: 1000)
    assert_includes result, "text-base-content"

    # Over 90%
    result = character_count_display("a" * 950, max_length: 1000)
    assert_includes result, "text-error"
  end

  test "response_time_display formats correctly" do
    feedback = Feedback.new(
      created_at: 30.minutes.ago,
      responded_at: Time.current
    )
    assert_equal "Less than 1 hour", response_time_display(feedback)

    feedback.created_at = 3.days.ago
    assert_equal "3 days", response_time_display(feedback)
  end
end

# test/helpers/application_helper_test.rb
require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "page_title with custom title" do
    result = page_title("Dashboard")
    assert_equal "Dashboard | The Feedback Agent", result
  end

  test "status_badge returns correct variant" do
    result = status_badge("pending")
    assert_includes result, "badge-warning"
  end

  test "active_link_to adds active class for current page" do
    def current_page?(path)
      path == "/dashboard"
    end

    result = active_link_to("Dashboard", "/dashboard", class: "nav-link")
    assert_includes result, 'class="nav-link active"'
  end
end
```

**Running Tests:**
```bash
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
