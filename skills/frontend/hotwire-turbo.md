---
name: hotwire-turbo
domain: frontend
dependencies: []
version: 1.0
rails_version: 8.1+
gem_requirements:
  - turbo-rails: 2.0.0+
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

**Enabled by Default:**
Turbo Drive automatically intercepts link clicks and form submissions.

**Basic Usage:**
```erb
<%# Regular link - automatically accelerated %>
<%= link_to "View Feedback", feedback_path(@feedback) %>

<%# Disable Turbo for specific link %>
<%= link_to "Download PDF", feedback_pdf_path(@feedback), data: { turbo: false } %>

<%# Force full page reload %>
<%= link_to "Admin Panel", admin_path, data: { turbo: "false" } %>

<%# Replace instead of push (no browser history entry) %>
<%= link_to "Dismiss", dismiss_path, data: { turbo_action: "replace" } %>
```
</pattern>

## Turbo Frames

<pattern name="basic-turbo-frame">
<description>Scoped page updates with Turbo Frames</description>

**Component:**
```erb
<%# List view - feedbacks/index.html.erb %>
<div class="feedbacks">
  <% @feedbacks.each do |feedback| %>
    <%= turbo_frame_tag dom_id(feedback) do %>
      <%= render "feedback", feedback: feedback %>
    <% end %>
  <% end %>
</div>

<%# Partial - feedbacks/_feedback.html.erb %>
<div class="feedback-card">
  <h3><%= feedback.content %></h3>
  <%= link_to "Edit", edit_feedback_path(feedback) %>
  <%= link_to "Delete", feedback_path(feedback), data: { turbo_method: :delete } %>
</div>

<%# Edit form - feedbacks/edit.html.erb %>
<%= turbo_frame_tag dom_id(@feedback) do %>
  <%= form_with model: @feedback do |form| %>
    <%= form.text_area :content %>
    <%= form.submit "Save" %>
    <%= link_to "Cancel", feedback_path(@feedback) %>
  <% end %>
<% end %>
```

**How it works:**
- Click "Edit" replaces only that frame's content
- Submit form replaces frame with updated content
- No full page reload required
</pattern>

<pattern name="lazy-loading-frame">
<description>Lazy-load content with Turbo Frames</description>

**View:**
```erb
<%# Lazy load expensive content %>
<%= turbo_frame_tag "statistics", src: statistics_path, loading: :lazy do %>
  <p class="loading">Loading statistics...</p>
<% end %>
```

**Controller:**
```ruby
# app/controllers/statistics_controller.rb
class StatisticsController < ApplicationController
  def show
    @stats = expensive_statistics_calculation

    render turbo_frame: "statistics"
  end
end
```

**Partial:**
```erb
<%# app/views/statistics/show.html.erb %>
<%= turbo_frame_tag "statistics" do %>
  <div class="stats">
    <div class="stat">
      <div class="stat-value"><%= @stats[:total] %></div>
      <div class="stat-title">Total Feedbacks</div>
    </div>
  </div>
<% end %>
```
</pattern>

<pattern name="frame-targeting">
<description>Target specific frames or break out of frame context</description>

**View:**
```erb
<%# Form that breaks out of frame %>
<%= turbo_frame_tag "feedback_form" do %>
  <%= form_with model: @feedback, data: { turbo_frame: "_top" } do |form| %>
    <%= form.text_area :content %>
    <%= form.submit %>
  <% end %>
<% end %>

<%# Link that targets different frame %>
<%= turbo_frame_tag "sidebar" do %>
  <%= link_to "Load Details", details_path, data: { turbo_frame: "main_content" } %>
<% end %>

<%# Link that replaces entire page %>
<%= turbo_frame_tag "card" do %>
  <%= link_to "View All", feedbacks_path, data: { turbo_frame: "_top" } %>
<% end %>
```

**Frame Targets:**
- `_top` - Replace entire page
- `_self` - Replace current frame (default)
- `"frame_id"` - Target specific frame by ID
</pattern>

<pattern name="modal-with-frame">
<description>Modal dialogs using Turbo Frames</description>

**Layout:**
```erb
<%# app/views/layouts/application.html.erb %>
<%= turbo_frame_tag "modal" %>
```

**Link to open modal:**
```erb
<%= link_to "New Feedback", new_feedback_path, data: { turbo_frame: "modal" } %>
```

**Form view:**
```erb
<%# app/views/feedbacks/new.html.erb %>
<%= turbo_frame_tag "modal" do %>
  <div class="modal modal-open">
    <div class="modal-box">
      <h3>New Feedback</h3>
      <%= form_with model: @feedback do |form| %>
        <%= form.text_area :content %>
        <div class="modal-action">
          <%= form.submit "Create", class: "btn btn-primary" %>
          <%= link_to "Cancel", "#", class: "btn", data: { turbo_frame: "modal", turbo_action: "advance" } %>
        </div>
      <% end %>
    </div>
  </div>
<% end %>
```

**Controller:**
```ruby
# Close modal on success
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    render turbo_stream: turbo_stream.remove("modal")
  else
    render :new, status: :unprocessable_entity
  end
end
```
</pattern>

## Turbo Streams

<pattern name="turbo-stream-actions">
<description>Seven Turbo Stream actions for dynamic updates</description>

**Controller Actions:**
```ruby
# app/controllers/feedbacks_controller.rb
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          # 1. APPEND - Add to end of target
          turbo_stream.append("feedbacks", partial: "feedback", locals: { feedback: @feedback }),

          # 2. PREPEND - Add to beginning of target
          turbo_stream.prepend("notifications", partial: "notification", locals: { message: "Created!" }),

          # 3. REPLACE - Replace entire target
          turbo_stream.replace("feedback_form", partial: "form", locals: { feedback: Feedback.new }),

          # 4. UPDATE - Replace content inside target
          turbo_stream.update("feedback_count", html: Feedback.count.to_s),

          # 5. REMOVE - Remove target
          turbo_stream.remove("flash_message"),

          # 6. BEFORE - Insert before target
          turbo_stream.before("first_feedback", partial: "feedback", locals: { feedback: @feedback }),

          # 7. AFTER - Insert after target
          turbo_stream.after("last_feedback", partial: "feedback", locals: { feedback: @feedback })
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

**Model:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  # Broadcast changes to all subscribed clients
  after_create_commit -> { broadcast_prepend_to "feedbacks", partial: "feedbacks/feedback", locals: { feedback: self }, target: "feedbacks" }
  after_update_commit -> { broadcast_replace_to "feedbacks", partial: "feedbacks/feedback", locals: { feedback: self } }
  after_destroy_commit -> { broadcast_remove_to "feedbacks" }
end
```

**View:**
```erb
<%# app/views/feedbacks/index.html.erb %>
<%# Subscribe to turbo stream broadcasts %>
<%= turbo_stream_from "feedbacks" %>

<div id="feedbacks">
  <%= render @feedbacks %>
</div>
```

**How it works:**
- User A creates a feedback
- `after_create_commit` broadcasts to "feedbacks" stream
- All users subscribed to "feedbacks" receive update
- New feedback automatically prepends to their list
</pattern>

<pattern name="turbo-stream-partials">
<description>Reusable Turbo Stream partials</description>

**Partial:**
```erb
<%# app/views/turbo_streams/_flash.turbo_stream.erb %>
<%= turbo_stream.update "flash" do %>
  <div class="alert alert-<%= type %>">
    <%= message %>
  </div>
<% end %>

<%= turbo_stream.append "body", "<script>setTimeout(() => document.getElementById('flash').remove(), 3000)</script>".html_safe %>
```

**Controller:**
```ruby
def create
  if @feedback.save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "feedback_form",
          partial: "form",
          locals: { feedback: Feedback.new }
        ) + render_to_string(
          partial: "turbo_streams/flash",
          locals: { type: "success", message: "Feedback created!" }
        )
      end
    end
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Forgetting matching frame IDs between request and response</description>
<reason>Turbo Frames require matching IDs to know where to inject content</reason>
<bad-example>
```erb
<%# ❌ BAD - Mismatched frame IDs %>
<%# index.html.erb %>
<%= turbo_frame_tag "feedback_#{@feedback.id}" do %>
  <%= link_to "Edit", edit_feedback_path(@feedback) %>
<% end %>

<%# edit.html.erb - WRONG ID %>
<%= turbo_frame_tag "edit_form" do %>
  <%= form_with model: @feedback %>
<% end %>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Matching frame IDs %>
<%# index.html.erb %>
<%= turbo_frame_tag dom_id(@feedback) do %>
  <%= link_to "Edit", edit_feedback_path(@feedback) %>
<% end %>

<%# edit.html.erb - MATCHING ID %>
<%= turbo_frame_tag dom_id(@feedback) do %>
  <%= form_with model: @feedback %>
<% end %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not handling turbo_stream format in controller</description>
<reason>Without turbo_stream format, Turbo falls back to HTML which may not work correctly</reason>
<bad-example>
```ruby
# ❌ BAD - No turbo_stream format
def create
  @feedback = Feedback.new(feedback_params)
  if @feedback.save
    redirect_to feedbacks_path
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Handle turbo_stream format explicitly
def create
  @feedback = Feedback.new(feedback_params)
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
<description>Using Turbo Streams without target element</description>
<reason>Turbo Stream actions need an existing DOM element to target</reason>
<bad-example>
```ruby
# ❌ BAD - Target doesn't exist in DOM
turbo_stream.append("non_existent_element", @feedback)
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Ensure target exists %>
<div id="feedbacks">
  <%# Turbo stream will append here %>
</div>

<%# Controller %>
turbo_stream.append("feedbacks", partial: "feedback", locals: { feedback: @feedback })
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test Turbo Frames and Streams in controller and system tests:

```ruby
# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "creates feedback with turbo stream" do
    assert_difference("Feedback.count") do
      post feedbacks_path, params: { feedback: { content: "Test" } }, as: :turbo_stream
    end

    assert_response :success
    assert_match /turbo-stream/, response.body
    assert_match /action="append"/, response.body
  end
end

# test/system/feedbacks_test.rb
class FeedbacksSystemTest < ApplicationSystemTestCase
  test "creating feedback updates list without reload" do
    visit feedbacks_path

    within "#feedback_form" do
      fill_in "Content", with: "New feedback"
      click_button "Create"
    end

    # Should appear in list without page reload
    assert_selector "#feedbacks", text: "New feedback"
  end

  test "editing feedback within frame" do
    feedback = feedbacks(:one)
    visit feedbacks_path

    within "##{dom_id(feedback)}" do
      click_link "Edit"
      fill_in "Content", with: "Updated content"
      click_button "Save"
    end

    # Frame updates without page reload
    within "##{dom_id(feedback)}" do
      assert_text "Updated content"
    end
  end
end
```
</testing>

<related-skills>
- hotwire-stimulus - Add JavaScript behavior to Turbo interactions
- viewcomponent-basics - Use components with Turbo Frames
- actioncable-basics - Understand WebSocket connection for broadcasts
</related-skills>

<resources>
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Rails Guides - Turbo](https://guides.rubyonrails.org/working_with_javascript_in_rails.html#turbo)
- [Turbo Rails Gem](https://github.com/hotwired/turbo-rails)
</resources>
