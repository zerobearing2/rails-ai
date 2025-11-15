---
name: rails-ai:turbo-morph
description: Turbo Page Refresh provides SPA-like behavior by intelligently updating only the parts of the page that changed, using morphing to preserve scroll position, form state, and focus without Turbo Frames.
---

# Turbo Page Refresh (Morph)

Turbo Page Refresh provides SPA-like behavior by intelligently updating only the parts of the page that changed, using morphing to preserve scroll position, form state, and focus without Turbo Frames.

<when-to-use>
- Want SPA-like experience without complex Turbo Frame setup
- Need to preserve scroll position and form state across updates
- Building real-time features that update the full page
- Want simpler codebase than nested Turbo Frames
- Need to maintain focus state during live updates
- Broadcasting changes that affect multiple page sections
</when-to-use>

<benefits>
- **Simpler Architecture** - No need to wrap everything in Turbo Frames
- **State Preservation** - Keeps scroll position, form state, focus automatically
- **Clean SPA Behavior** - Page updates feel instant and smooth
- **Less Code** - Remove frame tags and targeting logic
- **Automatic Updates** - Morphing algorithm detects and applies minimal changes
- **Progressive Enhancement** - Falls back gracefully without JavaScript
</benefits>

<standards>
- Enable morph refresh with `data-turbo-refresh-method="morph"` on body
- Use `data-turbo-refresh-scroll="preserve"` to maintain scroll position
- Mark elements with `data-turbo-permanent` to prevent morphing
- Use `turbo:before-morph-element` to customize morphing behavior
- Broadcast full page renders via Turbo Streams with `refresh` action
- Use `turbo:morph-element` to reinitialize JavaScript after morph
- Prefer page refresh over Turbo Frames for simpler use cases
</standards>

## Basic Page Refresh

<pattern name="enable-page-refresh">
<description>Enable Turbo Page Refresh with morphing for the entire page</description>

**Application Layout:**
```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
  <head>
    <title>Feedback App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body data-turbo-refresh-method="morph" data-turbo-refresh-scroll="preserve">
    <%= yield %>
  </body>
</html>
```

**How it works:**
- `data-turbo-refresh-method="morph"` - Uses morphing instead of full replace
- `data-turbo-refresh-scroll="preserve"` - Maintains scroll position after updates
- Turbo automatically detects changes and applies minimal DOM updates
- Form state, focus, and scroll position are preserved
</pattern>

## Broadcasting Page Updates

<pattern name="broadcast-page-refresh">
<description>Broadcast full page refreshes to connected users</description>

**Model:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  belongs_to :user
  after_commit -> { broadcast_refresh_to "feedbacks" }
end
```

**View:**
```erb
<%= turbo_stream_from "feedbacks" %>
<% @feedbacks.each do |feedback| %>
  <div id="<%= dom_id(feedback) %>">
    <p><%= feedback.content %></p>
  </div>
<% end %>
```

**Scoped Broadcasting:**
```ruby
# Scope to specific project
class Feedback < ApplicationRecord
  belongs_to :project
  after_commit -> { broadcast_refresh_to [project, "feedbacks"] }
end
```

```erb
<%= turbo_stream_from [@project, "feedbacks"] %>
```
</pattern>

## Permanent Elements

<pattern name="permanent-elements">
<description>Prevent specific elements from being morphed during refresh</description>

**Flash Messages (Persist):**
```erb
<%# app/views/layouts/application.html.erb %>
<body data-turbo-refresh-method="morph" data-turbo-refresh-scroll="preserve">
  <%# Flash messages stay visible during page refresh %>
  <div id="flash-messages" data-turbo-permanent>
    <% flash.each do |type, message| %>
      <div class="alert alert-<%= type %>"><%= message %></div>
    <% end %>
  </div>

  <%= yield %>
</body>
```

**Video Player (Preserve State):**
```erb
<%# Video player continues playing during refresh %>
<div id="video-player" data-turbo-permanent>
  <video src="<%= @video.url %>" controls autoplay>
    Your browser doesn't support video.
  </video>
</div>
```

**Form with Focus:**
```erb
<%# Preserve form input and focus during live updates %>
<%= form_with model: @feedback do |form| %>
  <%# Input fields with data-turbo-permanent preserve focus %>
  <%= form.text_area :content,
                     id: "feedback-content",
                     data: { turbo_permanent: true } %>
  <%= form.submit "Save" %>
<% end %>
```

**Why Use Permanent:**
- Video/audio players won't restart
- Form inputs won't lose focus or content
- Flash messages persist across refreshes
- Loading indicators stay visible
</pattern>

## Custom Morph Behavior

<pattern name="customize-morphing">
<description>Customize morphing with event listeners</description>

**Prevent Morphing:**
```javascript
// Skip morphing specific elements
document.addEventListener("turbo:before-morph-element", (event) => {
  const { currentElement } = event.detail
  if (currentElement.classList.contains("no-morph")) {
    event.preventDefault()
  }
})
```

**Reinitialize After Morph:**
```javascript
// Reinitialize components after morphing
document.addEventListener("turbo:morph-element", (event) => {
  const { currentElement } = event.detail
  if (currentElement.hasAttribute("data-tooltip")) {
    initializeTooltip(currentElement)
  }
})
```
</pattern>

## Real-Time List Updates

<pattern name="real-time-list-example">
<description>Complete example: Real-time feedback list</description>

**Model:**
```ruby
class Feedback < ApplicationRecord
  belongs_to :user
  after_commit -> { broadcast_refresh_to "feedbacks" }
end
```

**View:**
```erb
<%= turbo_stream_from "feedbacks" %>

<%= form_with model: Feedback.new do |form| %>
  <div data-turbo-permanent id="feedback-form">
    <%= form.text_area :content %>
    <%= form.submit "Submit" %>
  </div>
<% end %>

<div class="feedbacks-list">
  <% @feedbacks.each do |feedback| %>
    <div class="feedback-card">
      <p><%= feedback.content %></p>
      <small><%= feedback.user.name %></small>
    </div>
  <% end %>
</div>
```

**Result:** Form stays focused, list updates instantly, no Frames needed
</pattern>

## Scroll Behavior

<pattern name="scroll-control">
<description>Control scroll behavior during page refresh</description>

**Global Scroll Control:**
```erb
<%# Preserve scroll position %>
<body data-turbo-refresh-scroll="preserve"><%= yield %></body>

<%# Reset to top %>
<body data-turbo-refresh-scroll="reset"><%= yield %></body>
```

**Per-Link Control:**
```erb
<%= link_to "View All", feedbacks_path, data: { turbo_refresh_scroll: "reset" } %>
```
</pattern>

<antipatterns>
<antipattern>
<description>Using Turbo Frames when Page Refresh would be simpler</description>
<bad-example>
```erb
<%# ❌ Complex nested frames %>
<%= turbo_frame_tag "feedbacks-list" do %>
  <% @feedbacks.each do |feedback| %>
    <%= turbo_frame_tag dom_id(feedback) do %>
      <%= render feedback %>
    <% end %>
  <% end %>
<% end %>
```
</bad-example>
<good-example>
```erb
<%# ✅ Simple page refresh %>
<%= turbo_stream_from "feedbacks" %>
<% @feedbacks.each do |feedback| %>
  <%= render feedback %>
<% end %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not using data-turbo-permanent for stateful elements</description>
<bad-example>
```erb
<%# ❌ Form loses focus %>
<%= form_with model: @feedback do |form| %>
  <%= form.text_area :content %>
<% end %>
```
</bad-example>
<good-example>
```erb
<%# ✅ Form preserves state %>
<div data-turbo-permanent id="feedback-form">
  <%= form_with model: @feedback do |form| %>
    <%= form.text_area :content %>
  <% end %>
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Broadcasting on every attribute change</description>
<bad-example>
```ruby
# ❌ Refreshes on all updates
after_update_commit -> { broadcast_refresh_to "feedbacks" }
```
</bad-example>
<good-example>
```ruby
# ✅ Only refresh for meaningful changes
after_commit :broadcast_if_content_changed, on: :update

def broadcast_if_content_changed
  broadcast_refresh_to("feedbacks") if saved_change_to_content?
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# test/system/page_refresh_test.rb
require "application_system_test_case"

class PageRefreshTest < ApplicationSystemTestCase
  test "broadcasts refresh to all users" do
    using_session :user1 do
      visit feedbacks_path
      assert_text "No feedback yet"
    end

    using_session :user2 do
      visit feedbacks_path
      fill_in "Content", with: "Great product!"
      click_button "Submit"
    end

    using_session :user1 do
      assert_text "Great product!", wait: 2
    end
  end

  test "preserves form focus during refresh" do
    visit feedbacks_path
    fill_in "Content", with: "My feedback"

    Feedback.create!(content: "New", user: users(:other))

    assert_field "Content", with: "My feedback", wait: 2
  end
end
```
</testing>

<related-skills>
- rails-ai:hotwire-turbo: Turbo Drive, Frames, Streams basics
- rails-ai:hotwire-stimulus: JavaScript controllers for interactivity
</related-skills>

<resources>
- [Turbo Handbook: Page Refreshes](https://turbo.hotwired.dev/handbook/page_refreshes)
- [Turbo Handbook: Streams](https://turbo.hotwired.dev/handbook/streams)
- [Rails Turbo Documentation](https://github.com/hotwired/turbo-rails)
- [Hotwire Discussion Forum](https://discuss.hotwired.dev/)
</resources>
