---
name: hotwire-turbo
domain: frontend
dependencies: []
version: 1.0
rails_version: 8.1+
gem_requirements:
  - turbo-rails: 2.0.0+

# Team rules enforcement
enforces_team_rule:
  - rule_id: 7
    rule_name: "Turbo Morph by Default"
    severity: high
    enforcement_action: SUGGEST
    note: "Turbo Frames valid for modals, inline editing, tabs"
  - rule_id: 13
    rule_name: "Progressive Enhancement"
    severity: moderate
    enforcement_action: SUGGEST
---

# Hotwire Turbo

Turbo provides fast, SPA-like navigation and real-time updates using server-rendered HTML without JavaScript frameworks.

<when-to-use>
- Building interactive UIs without heavy JavaScript frameworks
- Need fast page navigation with browser history support
- Want to update specific page sections without full reload
- Implementing real-time features (notifications, live updates)
- Creating modal dialogs and inline editing interfaces
- Progressive enhancement is important
</when-to-use>

<benefits>
- **Fast Navigation** - SPA-like speed with Turbo Drive
- **Scoped Updates** - Update specific page sections with Turbo Frames
- **Real-time** - Live updates via Turbo Streams
- **Server-Rendered** - No client-side templates or state management
- **Progressive Enhancement** - Works without JavaScript
- **Mobile-Friendly** - Reduces data transfer
</benefits>

<standards>
- Turbo Drive is enabled automatically in Rails 8.1
- Use `turbo_frame_tag` for scoped page updates
- Use Turbo Streams for real-time updates (7 actions: append, prepend, replace, update, remove, before, after)
- Turbo Frames require matching IDs between request and response
- Use `data: { turbo: false }` to disable Turbo for specific links
- Broadcast updates via ActionCable with `turbo_stream_from`
- Handle form submissions within frames using `data: { turbo_frame: }`
</standards>

## Turbo Drive

<pattern name="turbo-drive-basics">
<description>Automatic page acceleration with Turbo Drive</description>

Turbo Drive intercepts links and forms automatically. Control behavior with `data` attributes:

```erb
<%# Disable Turbo %>
<%= link_to "Download PDF", pdf_path, data: { turbo: false } %>

<%# Replace (no history) %>
<%= link_to "Dismiss", dismiss_path, data: { turbo_action: "replace" } %>
```
</pattern>

## Turbo Frames

<pattern name="basic-turbo-frame">
<description>Scoped page updates with Turbo Frames</description>

```erb
<%# List with frames %>
<% @feedbacks.each do |feedback| %>
  <%= turbo_frame_tag dom_id(feedback) do %>
    <h3><%= feedback.content %></h3>
    <%= link_to "Edit", edit_feedback_path(feedback) %>
  <% end %>
<% end %>

<%# Edit form with matching ID %>
<%= turbo_frame_tag dom_id(@feedback) do %>
  <%= form_with model: @feedback do |form| %>
    <%= form.text_area :content %>
    <%= form.submit %>
  <% end %>
<% end %>
```

Click "Edit" replaces only that frame's content—no full page reload.
</pattern>

<pattern name="lazy-loading-frame">
<description>Lazy-load content with Turbo Frames</description>

```erb
<%# Lazy load expensive content %>
<%= turbo_frame_tag "statistics", src: statistics_path, loading: :lazy do %>
  <p>Loading statistics...</p>
<% end %>
```

```ruby
# Controller
def show
  @stats = expensive_calculation
  render turbo_frame: "statistics"
end
```

```erb
<%# Partial %>
<%= turbo_frame_tag "statistics" do %>
  <div><%= @stats[:total] %> Feedbacks</div>
<% end %>
```
</pattern>

<pattern name="frame-targeting">
<description>Target specific frames or break out of frame context</description>

```erb
<%# Break out of frame to full page %>
<%= form_with model: @feedback, data: { turbo_frame: "_top" } %>

<%# Target different frame %>
<%= link_to "Details", details_path, data: { turbo_frame: "main_content" } %>
```

**Targets:** `_top` (full page), `_self` (current frame), `"frame_id"` (specific frame)
</pattern>

<pattern name="modal-with-frame">
<description>Modal dialogs using Turbo Frames</description>

```erb
<%# Layout %>
<%= turbo_frame_tag "modal" %>

<%# Trigger %>
<%= link_to "New", new_feedback_path, data: { turbo_frame: "modal" } %>

<%# Modal view %>
<%= turbo_frame_tag "modal" do %>
  <div class="modal">
    <%= form_with model: @feedback do |form| %>
      <%= form.text_area :content %>
      <%= form.submit %>
    <% end %>
  </div>
<% end %>
```

```ruby
# Close on success
def create
  if @feedback.save
    render turbo_stream: turbo_stream.remove("modal")
  end
end
```
</pattern>

## Turbo Streams

<pattern name="turbo-stream-actions">
<description>Seven Turbo Stream actions for dynamic updates</description>

```ruby
def create
  if @feedback.save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append("feedbacks", @feedback),     # Add to end
          turbo_stream.prepend("feedbacks", @feedback),    # Add to start
          turbo_stream.replace("form", @feedback),          # Replace target
          turbo_stream.update("count", html: "10"),         # Replace content
          turbo_stream.remove("flash"),                     # Remove
          turbo_stream.before("first", @feedback),          # Insert before
          turbo_stream.after("last", @feedback)             # Insert after
        ]
      end
      format.html { redirect_to feedbacks_path }
    end
  end
end
```
</pattern>

<pattern name="broadcast-updates">
<description>Real-time updates via ActionCable with Turbo Streams</description>

```ruby
# Model broadcasts to subscribers
class Feedback < ApplicationRecord
  after_create_commit -> { broadcast_prepend_to "feedbacks" }
  after_update_commit -> { broadcast_replace_to "feedbacks" }
  after_destroy_commit -> { broadcast_remove_to "feedbacks" }
end
```

```erb
<%# View subscribes to stream %>
<%= turbo_stream_from "feedbacks" %>

<div id="feedbacks">
  <%= render @feedbacks %>
</div>
```

All subscribed users receive updates in real-time via ActionCable.
</pattern>

<pattern name="turbo-stream-partials">
<description>Reusable Turbo Stream partials</description>

```erb
<%# app/views/turbo_streams/_flash.turbo_stream.erb %>
<%= turbo_stream.update "flash" do %>
  <div class="alert"><%= message %></div>
<% end %>
```

```ruby
# Combine multiple streams
def create
  if @feedback.save
    format.turbo_stream do
      render turbo_stream: turbo_stream.replace("form", @feedback) +
        render_to_string(partial: "turbo_streams/flash", locals: { message: "Created!" })
    end
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Mismatched frame IDs between request and response</description>
<bad-example>
```erb
<%# ❌ Different IDs won't match %>
<%= turbo_frame_tag "feedback_#{@feedback.id}" %>
<%= turbo_frame_tag "edit_form" %>
```
</bad-example>
<good-example>
```erb
<%# ✅ Use dom_id for consistency %>
<%= turbo_frame_tag dom_id(@feedback) %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not handling turbo_stream format in controller</description>
<bad-example>
```ruby
# ❌ Only redirects
def create
  if @feedback.save
    redirect_to feedbacks_path
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ Handle turbo_stream
def create
  if @feedback.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to feedbacks_path }
    end
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Targeting non-existent DOM elements</description>
<bad-example>
```ruby
# ❌ Target must exist in DOM
turbo_stream.append("missing_element", @feedback)
```
</bad-example>
<good-example>
```erb
<%# ✅ Ensure target exists %>
<div id="feedbacks"></div>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# Controller test
test "creates with turbo stream" do
  post feedbacks_path, params: { feedback: { content: "Test" } }, as: :turbo_stream
  assert_match /turbo-stream/, response.body
end

# System test
test "updates without reload" do
  visit feedbacks_path
  fill_in "Content", with: "New"
  click_button "Create"
  assert_selector "#feedbacks", text: "New"
end

test "edits within frame" do
  within "##{dom_id(feedback)}" do
    click_link "Edit"
    fill_in "Content", with: "Updated"
    click_button "Save"
    assert_text "Updated"
  end
end
```
</testing>

<related-skills>
- hotwire-stimulus - Add JavaScript behavior to Turbo interactions
- viewcomponent-basics - Use components with Turbo Frames

</related-skills>

<resources>
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Rails Guides - Turbo](https://guides.rubyonrails.org/working_with_javascript_in_rails.html#turbo)
- [Turbo Rails Gem](https://github.com/hotwired/turbo-rails)
</resources>
