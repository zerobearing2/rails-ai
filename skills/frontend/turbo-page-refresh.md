---
name: turbo-page-refresh
domain: frontend
dependencies: [hotwire-turbo]
version: 1.0
rails_version: 8.1+
gem_requirements:
  - turbo-rails: 2.0.0+
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
<description>Broadcast full page refreshes to all connected users</description>

**Model:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  belongs_to :user

  after_create_commit -> { broadcast_page_refresh }
  after_update_commit -> { broadcast_page_refresh }
  after_destroy_commit -> { broadcast_page_refresh }

  private

  def broadcast_page_refresh
    # Broadcast to all users viewing feedbacks
    broadcast_refresh_to "feedbacks"
  end
end
```

**View:**
```erb
<%# app/views/feedbacks/index.html.erb %>
<%= turbo_stream_from "feedbacks" %>

<div class="feedbacks-list">
  <h1>Feedback</h1>

  <% @feedbacks.each do |feedback| %>
    <div class="feedback-card" id="<%= dom_id(feedback) %>">
      <p><%= feedback.content %></p>
      <span class="author"><%= feedback.user.name %></span>
      <%= link_to "Edit", edit_feedback_path(feedback) %>
    </div>
  <% end %>
</div>
```

**How it works:**
- `broadcast_refresh_to "feedbacks"` sends a refresh stream action
- All users subscribed to "feedbacks" channel get a page refresh
- Turbo morphs the page, preserving scroll and state
- No need to target specific elements or frames
</pattern>

## Selective Broadcasting

<pattern name="conditional-broadcast">
<description>Broadcast page refreshes only to specific users or contexts</description>

**Model with Scoped Broadcasting:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  belongs_to :user
  belongs_to :project

  after_create_commit :broadcast_to_project_viewers
  after_update_commit :broadcast_to_project_viewers

  private

  def broadcast_to_project_viewers
    # Only refresh for users viewing this specific project
    broadcast_refresh_to [project, "feedbacks"]
  end
end
```

**View with Scoped Subscription:**
```erb
<%# app/views/projects/show.html.erb %>
<%= turbo_stream_from [@project, "feedbacks"] %>

<div class="project-details">
  <h1><%= @project.name %></h1>

  <div class="feedbacks">
    <% @project.feedbacks.each do |feedback| %>
      <%= render feedback %>
    <% end %>
  </div>
</div>
```

**Conditional Refresh:**
```ruby
# app/models/feedback.rb
def broadcast_to_project_viewers
  # Only broadcast if feedback is published
  return unless published?

  broadcast_refresh_to([project, "feedbacks"], **options_for_broadcast)
end

def options_for_broadcast
  {
    # Include request_id to prevent echo on the originating client
    request_id: Current.request_id
  }
end
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
<description>Customize which elements get morphed and how</description>

**Prevent Specific Element Morphing:**
```javascript
// app/javascript/controllers/morph_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Prevent morphing elements with .no-morph class
    document.addEventListener("turbo:before-morph-element", this.preventMorph)
  }

  disconnect() {
    document.removeEventListener("turbo:before-morph-element", this.preventMorph)
  }

  preventMorph = (event) => {
    const { currentElement } = event.detail

    // Skip morphing for specific elements
    if (currentElement.classList.contains("no-morph")) {
      event.preventDefault()
    }

    // Skip morphing for elements with animations running
    if (currentElement.getAnimations().length > 0) {
      event.preventDefault()
    }
  }
}
```

**Reinitialize JavaScript After Morph:**
```javascript
// app/javascript/application.js
import { Turbo } from "@hotwired/turbo-rails"

// Reinitialize components after morphing
document.addEventListener("turbo:morph-element", (event) => {
  const { currentElement, newElement } = event.detail

  // Reinitialize tooltips
  if (currentElement.hasAttribute("data-tooltip")) {
    initializeTooltip(currentElement)
  }

  // Trigger custom event for third-party libraries
  currentElement.dispatchEvent(new CustomEvent("element-morphed"))
})
```

**Prevent Attribute Changes:**
```javascript
// Preserve specific attributes during morph
document.addEventListener("turbo:before-morph-attribute", (event) => {
  const { attributeName } = event.detail

  // Don't change data-state attributes
  if (attributeName.startsWith("data-state-")) {
    event.preventDefault()
  }

  // Preserve Stimulus controller values
  if (attributeName.includes("-value")) {
    event.preventDefault()
  }
})
```
</pattern>

## Real-Time List Updates

<pattern name="real-time-list-example">
<description>Complete example: Real-time feedback list with page refresh</description>

**Controller:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  def index
    @feedbacks = Feedback.includes(:user).order(created_at: :desc)
  end

  def create
    @feedback = current_user.feedbacks.build(feedback_params)

    if @feedback.save
      # No need to manually broadcast - model callback handles it
      redirect_to feedbacks_path, notice: "Feedback created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.expect(feedback: [:content, :rating])
  end
end
```

**Model:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  belongs_to :user

  validates :content, presence: true
  validates :rating, inclusion: { in: 1..5 }

  # Broadcast page refresh to all viewers
  after_create_commit -> { broadcast_refresh }
  after_update_commit -> { broadcast_refresh }
  after_destroy_commit -> { broadcast_refresh }

  private

  def broadcast_refresh
    broadcast_refresh_to "feedbacks"
  end
end
```

**View:**
```erb
<%# app/views/feedbacks/index.html.erb %>
<%= turbo_stream_from "feedbacks" %>

<div class="container">
  <h1>Customer Feedback</h1>

  <%# This form stays focused while list updates %>
  <%= form_with model: Feedback.new, class: "mb-4" do |form| %>
    <div data-turbo-permanent id="feedback-form">
      <%= form.text_area :content,
                         placeholder: "Share your feedback...",
                         class: "form-control mb-2" %>
      <%= form.select :rating,
                      1..5,
                      { prompt: "Rating" },
                      class: "form-select mb-2" %>
      <%= form.submit "Submit", class: "btn btn-primary" %>
    </div>
  <% end %>

  <%# List updates automatically via page refresh %>
  <div class="feedbacks-list">
    <% @feedbacks.each do |feedback| %>
      <div class="feedback-card mb-3">
        <div class="rating">
          <%= "⭐" * feedback.rating %>
        </div>
        <p><%= feedback.content %></p>
        <small class="text-muted">
          <%= feedback.user.name %> •
          <%= time_ago_in_words(feedback.created_at) %> ago
        </small>
      </div>
    <% end %>
  </div>
</div>
```

**Result:**
- New feedback appears for all users instantly
- Form stays focused and preserves content
- Scroll position maintained
- No Turbo Frames needed
- Clean, simple code
</pattern>

## Scroll Behavior

<pattern name="scroll-control">
<description>Control scroll behavior during page refresh</description>

**Preserve Scroll (Default):**
```erb
<%# Maintains scroll position during refresh %>
<body data-turbo-refresh-method="morph"
      data-turbo-refresh-scroll="preserve">
  <%= yield %>
</body>
```

**Reset to Top:**
```erb
<%# Scrolls to top after refresh %>
<body data-turbo-refresh-method="morph"
      data-turbo-refresh-scroll="reset">
  <%= yield %>
</body>
```

**Per-Link Scroll Control:**
```erb
<%# Override scroll behavior for specific links %>
<%= link_to "View All", feedbacks_path,
            data: { turbo_refresh_scroll: "reset" } %>

<%# Preserve scroll for pagination %>
<%= link_to "Next Page", feedbacks_path(page: @page + 1),
            data: { turbo_refresh_scroll: "preserve" } %>
```

**Programmatic Scroll Control:**
```javascript
// Control scroll from JavaScript
document.addEventListener("turbo:before-visit", (event) => {
  const { url } = event.detail

  // Reset scroll for navigation to different sections
  if (url.includes("#")) {
    event.target.setAttribute("data-turbo-refresh-scroll", "reset")
  }
})
```
</pattern>

<antipatterns>
<antipattern>
<description>Using Turbo Frames when Page Refresh would be simpler</description>
<reason>Adds unnecessary complexity with frame tags and targeting logic</reason>
<bad-example>
```erb
<%# ❌ Complex frame setup for simple list updates %>
<%= turbo_frame_tag "feedbacks-list" do %>
  <% @feedbacks.each do |feedback| %>
    <%= turbo_frame_tag dom_id(feedback) do %>
      <%= render feedback %>
    <% end %>
  <% end %>
<% end %>

<%# Requires complex broadcasting logic %>
<% # broadcast_replace_to "feedbacks", target: dom_id(@feedback), partial: "feedback", locals: { feedback: @feedback } %>
```
</bad-example>
<good-example>
```erb
<%# ✅ Simple page refresh with morph %>
<%= turbo_stream_from "feedbacks" %>

<% @feedbacks.each do |feedback| %>
  <%= render feedback %>
<% end %>

<%# Simple model callback %>
<% # after_create_commit -> { broadcast_refresh_to "feedbacks" } %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not using data-turbo-permanent for stateful elements</description>
<reason>Loses form input, focus, video playback state during refresh</reason>
<bad-example>
```erb
<%# ❌ Form loses focus when page refreshes %>
<%= form_with model: @feedback do |form| %>
  <%= form.text_area :content %>
  <%= form.submit %>
<% end %>

<%# ❌ Video restarts on every refresh %>
<video src="<%= @video.url %>" controls autoplay></video>
```
</bad-example>
<good-example>
```erb
<%# ✅ Form preserves focus and content %>
<div data-turbo-permanent id="feedback-form">
  <%= form_with model: @feedback do |form| %>
    <%= form.text_area :content %>
    <%= form.submit %>
  <% end %>
</div>

<%# ✅ Video continues playing %>
<div data-turbo-permanent id="video-player">
  <video src="<%= @video.url %>" controls autoplay></video>
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Broadcasting page refresh for every tiny change</description>
<reason>Causes unnecessary page refreshes and poor user experience</reason>
<bad-example>
```ruby
# ❌ Refreshes entire page on every attribute change
class Feedback < ApplicationRecord
  after_update_commit -> { broadcast_refresh_to "feedbacks" }
end

# Even trivial updates like view counts trigger full refresh
feedback.increment!(:views_count) # Triggers page refresh
```
</bad-example>
<good-example>
```ruby
# ✅ Only refresh for meaningful changes
class Feedback < ApplicationRecord
  after_commit :broadcast_if_content_changed, on: :update

  private

  def broadcast_if_content_changed
    # Only refresh if content or status changed
    if saved_change_to_content? || saved_change_to_status?
      broadcast_refresh_to "feedbacks"
    end
  end
end

# Or use Turbo Streams for granular updates
feedback.increment!(:views_count)
broadcast_update_to("feedbacks",
                    target: "feedback_#{id}_views",
                    html: views_count)
```
</good-example>
</antipattern>

<antipattern>
<description>Not scoping broadcasts to relevant users</description>
<reason>Causes unnecessary refreshes for users not viewing affected content</reason>
<bad-example>
```ruby
# ❌ Broadcasts to ALL users on any feedback change
class Feedback < ApplicationRecord
  after_commit -> { broadcast_refresh_to "feedbacks" }
end

# User viewing Project A gets refresh when Project B changes
```
</bad-example>
<good-example>
```ruby
# ✅ Scope broadcasts to project viewers
class Feedback < ApplicationRecord
  belongs_to :project

  after_commit :broadcast_to_project_viewers

  private

  def broadcast_to_project_viewers
    broadcast_refresh_to([project, "feedbacks"])
  end
end

# Only users viewing this project get refreshed
```
</good-example>
</antipattern>

<antipattern>
<description>Missing scroll preservation for long pages</description>
<reason>User loses their place when page refreshes</reason>
<bad-example>
```erb
<%# ❌ Scroll jumps to top on every refresh %>
<body data-turbo-refresh-method="morph">
  <div class="long-list">
    <%= render @feedbacks %>
  </div>
</body>
```
</bad-example>
<good-example>
```erb
<%# ✅ Maintains scroll position %>
<body data-turbo-refresh-method="morph"
      data-turbo-refresh-scroll="preserve">
  <div class="long-list">
    <%= render @feedbacks %>
  </div>
</body>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test Turbo Page Refresh behavior:

```ruby
# test/system/page_refresh_test.rb
require "application_system_test_case"

class PageRefreshTest < ApplicationSystemTestCase
  test "page refreshes automatically when feedback created" do
    # Open two browser sessions
    using_session :user1 do
      visit feedbacks_path
      assert_text "No feedback yet"
    end

    using_session :user2 do
      visit feedbacks_path
      fill_in "Content", with: "Great product!"
      click_button "Submit"
      assert_text "Feedback created!"
    end

    # User 1 sees new feedback without manual refresh
    using_session :user1 do
      assert_text "Great product!", wait: 2
    end
  end

  test "form preserves focus during page refresh" do
    visit feedbacks_path

    # Start typing in form
    fill_in "Content", with: "This is my feedback"

    # Simulate broadcast from another user
    Feedback.create!(content: "New feedback", user: users(:other))

    # Form should preserve content and focus
    assert_field "Content", with: "This is my feedback", wait: 2
    assert_equal "feedback_content", page.evaluate_script("document.activeElement.id")
  end

  test "scroll position maintained during refresh" do
    # Create many feedbacks to make page scrollable
    50.times { |i| create(:feedback, content: "Feedback #{i}") }

    visit feedbacks_path

    # Scroll down
    page.execute_script("window.scrollTo(0, 1000)")
    scroll_position = page.evaluate_script("window.scrollY")

    # Trigger refresh
    create(:feedback, content: "New feedback")

    # Wait for refresh and check scroll maintained
    assert_text "New feedback", wait: 2
    assert_in_delta scroll_position, page.evaluate_script("window.scrollY"), 50
  end
end
```
</testing>

<related-skills>
- hotwire-turbo - Turbo Drive, Frames, Streams basics
- hotwire-stimulus - JavaScript controllers for interactivity
- viewcomponent-basics - Component-based view architecture
- action-mailer - Email notifications for updates
</related-skills>

<resources>
- [Turbo Handbook: Page Refreshes](https://turbo.hotwired.dev/handbook/page_refreshes)
- [Turbo Handbook: Streams](https://turbo.hotwired.dev/handbook/streams)
- [Rails Turbo Documentation](https://github.com/hotwired/turbo-rails)
- [Hotwire Discussion Forum](https://discuss.hotwired.dev/)
</resources>
