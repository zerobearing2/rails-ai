---
name: rails-ai:view-helpers
description: View helpers are Ruby modules that provide reusable methods for generating HTML, formatting data, and encapsulating view logic to keep views clean, DRY, and maintainable.
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

<pattern name="text-helpers">
<description>Format and manipulate text content</description>

```ruby
truncate("Long text...", length: 20)  # => "Long text..."
pluralize(5, "feedback")  # => "5 feedbacks"
time_ago_in_words(3.days.ago)  # => "3 days"
sanitize("<script>alert('xss')</script><p>Safe</p>")  # => "<p>Safe</p>"
```

```erb
<%= truncate(@feedback.content, length: 150) %>
<%= time_ago_in_words(@feedback.created_at) %> ago
<%= pluralize(@feedbacks.count, "feedback") %>
```
</pattern>

<pattern name="number-helpers">
<description>Format numbers, currency, and percentages</description>

```ruby
number_to_currency(1234.56)  # => "$1,234.56"
number_to_percentage(85.5, precision: 0)  # => "86%"
number_with_delimiter(1234567)  # => "1,234,567"
number_to_human_size(1234567890)  # => "1.15 GB"
```

```erb
<%= number_to_currency(@plan.price) %>
<%= number_to_percentage(@project.completion_rate, precision: 1) %>
<%= number_with_delimiter(@app.user_count) %> users
```
</pattern>

<pattern name="tag-builder">
<description>Build HTML tags programmatically</description>

```ruby
tag.div class: "card" do
  tag.h2("Title") + tag.p("Content")
end

tag.button "Click", data: { action: "click->controller#method" }
tag.ul { safe_join([tag.li("Item 1"), tag.li("Item 2")]) }
```

```erb
<%= tag.div class: "status-#{@feedback.status}" do %>
  <%= tag.span @feedback.status.titleize %>
<% end %>
```
</pattern>

## Custom Application Helpers

<pattern name="page-title-helper">
<description>Manage page titles consistently</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def page_title(title = nil)
    base = "The Feedback Agent"
    title.present? ? "#{title} | #{base}" : base
  end
end
```

```erb
# Layout
<title><%= page_title(yield(:title)) %></title>

# View
<% content_for :title, "Dashboard" %>
```
</pattern>

<pattern name="flash-messages-helper">
<description>Display flash messages with consistent styling</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def flash_messages
    flash.map do |type, msg|
      alert_type = { notice: "success", alert: "warning", error: "error" }[type.to_sym] || "info"
      content_tag :div, class: "alert alert-#{alert_type}" do
        content_tag(:span, msg) + button_tag("×", type: "button", data: { dismiss: "alert" })
      end
    end.join.html_safe
  end
end
```

```erb
<%= flash_messages %>
```
</pattern>

<pattern name="status-badge-helper">
<description>Display status badges with consistent styling</description>

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def status_badge(status)
    variants = { "pending" => "warning", "reviewed" => "info",
                 "responded" => "success", "archived" => "neutral" }
    variant = variants[status] || "neutral"
    content_tag :span, status.titleize, class: "badge badge-#{variant}"
  end
end
```

```erb
<%= status_badge(@feedback.status) %>
```
</pattern>

## Module-Specific Helpers

<pattern name="feedback-helpers">
<description>Feedback-specific helper methods</description>

```ruby
# app/helpers/feedbacks_helper.rb
module FeedbacksHelper
  def ai_improved_badge(feedback)
    return unless feedback.ai_improved?
    content_tag :span, class: "badge badge-primary" do
      icon("sparkles") + " AI Enhanced"
    end
  end

  def character_count_display(content, max_length: 1000)
    count = content.to_s.length
    pct = (count.to_f / max_length * 100).round
    color = pct > 90 ? "text-error" : pct > 75 ? "text-warning" : "text-base"
    content_tag :span, "#{count} / #{max_length}", class: color
  end

  def response_time_display(feedback)
    return "No response" unless feedback.responded_at
    hours = ((feedback.responded_at - feedback.created_at) / 3600).round
    hours < 1 ? "< 1 hour" : hours < 24 ? "#{hours}h" : "#{(hours/24).round}d"
  end
end
```

```erb
<%= ai_improved_badge(@feedback) %>
<%= character_count_display(@feedback.content) %>
```
</pattern>

<antipatterns>
<antipattern>
<description>Using html_safe on user input</description>
<reason>XSS vulnerability - allows script execution</reason>
<bad-example>
```ruby
# ❌ DANGEROUS
def render_content(content)
  content.html_safe
end
```
</bad-example>
<good-example>
```ruby
# ✅ SAFE - Auto-escaped or sanitized
def render_content(content)
  content  # Auto-escaped
end

def render_html(content)
  sanitize(content, tags: %w[p br strong])
end
```
</good-example>
</antipattern>

<antipattern>
<description>Bloated ApplicationHelper</description>
<reason>Hard to maintain and test</reason>
<bad-example>
```ruby
# ❌ BAD - Everything in ApplicationHelper
module ApplicationHelper
  def format_feedback_status(...)
  def user_avatar(...)
  def product_price(...)
  # ... 50 more methods
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Organized by domain
module FeedbacksHelper
  def format_feedback_status(...)
end

module UsersHelper
  def user_avatar(...)
end
```
</good-example>
</antipattern>

</antipatterns>

<testing>
```ruby
# test/helpers/feedbacks_helper_test.rb
require "test_helper"

class FeedbacksHelperTest < ActionView::TestCase
  test "ai_improved_badge" do
    assert_includes ai_improved_badge(feedbacks(:ai_improved)), "AI Enhanced"
  end

  test "character_count_display color" do
    assert_includes character_count_display("a" * 500, max_length: 1000), "text-base"
    assert_includes character_count_display("a" * 950, max_length: 1000), "text-error"
  end
end

# test/helpers/application_helper_test.rb
class ApplicationHelperTest < ActionView::TestCase
  test "page_title" do
    assert_equal "Dashboard | The Feedback Agent", page_title("Dashboard")
  end

  test "status_badge" do
    assert_includes status_badge("pending"), "badge-warning"
  end
end
```
</testing>

<related-skills>
- rails-ai:hotwire-turbo: Turbo integration with helpers (data attributes)
- rails-ai:tailwind: Styling helper generated HTML
</related-skills>

<resources>
- [Rails Guides - Action View Helpers](https://guides.rubyonrails.org/action_view_helpers.html)
- [Rails API - ActionView::Helpers](https://api.rubyonrails.org/classes/ActionView/Helpers.html)
</resources>
