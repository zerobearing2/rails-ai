---
name: rails-ai:hotwire
description: Use when adding interactivity to Rails views - Hotwire Turbo (Drive, Frames, Streams, Morph) and Stimulus controllers
---

# Hotwire (Turbo + Stimulus)

Build fast, interactive, SPA-like experiences using server-rendered HTML with Hotwire. Turbo provides navigation and real-time updates without writing JavaScript. Stimulus enhances HTML with lightweight JavaScript controllers.

<when-to-use>
- Adding interactivity without heavy JavaScript frameworks
- Building real-time, SPA-like experiences with server-rendered HTML
- Implementing live updates, infinite scroll, or dynamic content
- Creating modals, inline editing, or interactive UI components
- Replacing traditional AJAX with modern, declarative patterns
</when-to-use>

<benefits>
- **SPA-Like Speed** - Turbo Drive accelerates navigation without full page reloads
- **Real-time Updates** - Turbo Streams deliver live changes via ActionCable
- **Progressive Enhancement** - Works without JavaScript, enhanced with it (TEAM RULE #13)
- **Simpler Architecture** - Server-rendered HTML reduces client-side complexity
- **Turbo Morph** - Intelligent DOM updates preserve scroll, focus, form state (TEAM RULE #7)
- **Less JavaScript** - Stimulus provides just enough JS for interactivity
</benefits>

<team-rules-enforcement>
**This skill enforces:**
- ✅ **Rule #5:** Turbo Morph by default (Frames only for modals, inline editing, pagination, tabs)
- ✅ **Rule #6:** Progressive enhancement (must work without JavaScript)

**Reject any requests to:**
- Use Turbo Frames everywhere (use Turbo Morph for general CRUD)
- Skip progressive enhancement (features that require JavaScript to function)
- Build non-functional UIs without JavaScript fallbacks
</team-rules-enforcement>

<verification-checklist>
Before completing Hotwire features:
- ✅ Works without JavaScript (progressive enhancement verified)
- ✅ Turbo Morph used for CRUD operations (not Frames)
- ✅ Turbo Frames only for: modals, inline editing, pagination, tabs
- ✅ Stimulus controllers clean up in disconnect()
- ✅ All interactive features tested
- ✅ All tests passing
</verification-checklist>

<standards>
- **TEAM RULE #7:** Prefer Turbo Morph over Turbo Frames/Stimulus for general CRUD
- **TEAM RULE #13:** Ensure progressive enhancement (works without JavaScript)
- Use Turbo Drive for automatic page acceleration
- Use Turbo Morph for list updates and CRUD operations (preserves state)
- Use Turbo Frames ONLY for: modals, inline editing, tabs, pagination, lazy loading
- Use Turbo Streams for real-time updates via ActionCable
- Use Stimulus for client-side interactions (dropdowns, character counters, dynamic forms)
- Always clean up in Stimulus disconnect() to prevent memory leaks
- Test with JavaScript disabled to verify progressive enhancement
</standards>

---

## Hotwire Turbo

Turbo provides fast, SPA-like navigation and real-time updates using server-rendered HTML. Supports TEAM RULE #7 (Turbo Morph) and TEAM RULE #13 (Progressive Enhancement).

### TEAM RULE #7: Prefer Turbo Morph over Turbo Frames/Stimulus

✅ **DEFAULT APPROACH:** Use Turbo Morph (page refresh with morphing) with standard Rails controllers
✅ **ALLOW Turbo Frames ONLY for:** Modals, inline editing, tabs, pagination
❌ **AVOID:** Turbo Frames for general list updates, custom Stimulus controllers for basic CRUD

**Why Turbo Morph?** Preserves scroll position, focus, form state, and video playback. Works with stock Rails scaffolds. Simpler than Frames/Stimulus in 90% of cases.

### Turbo Drive

<pattern name="turbo-drive-basics">
<description>Automatic page acceleration with Turbo Drive</description>

Turbo Drive intercepts links and forms automatically. Control with `data` attributes:

```erb
<%# Disable Turbo for specific links %>
<%= link_to "Download PDF", pdf_path, data: { turbo: false } %>

<%# Replace without history %>
<%= link_to "Dismiss", dismiss_path, data: { turbo_action: "replace" } %>
```

</pattern>

### Turbo Morphing (Page Refresh) - PREFERRED

**Use Turbo Morph by default with standard Rails controllers.** Morphing intelligently updates only changed DOM elements while preserving scroll position, focus, form state, and media playback.

<pattern name="enable-morphing-layout">
<description>Enable Turbo Morph in your layout (one-time setup)</description>

```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
<head>
  <title><%= content_for?(:title) ? yield(:title) : "App" %></title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  <%= javascript_importmap_tags %>

  <%# Enable Turbo Morph for page refreshes %>
  <meta name="turbo-refresh-method" content="morph">
  <meta name="turbo-refresh-scroll" content="preserve">
</head>
<body>
  <%= yield %>
</body>
</html>
```

**That's it!** Standard Rails controllers now work with morphing. No custom JavaScript needed.

**Reference:** [Turbo Page Refreshes Documentation](https://turbo.hotwired.dev/handbook/page_refreshes)
</pattern>

<pattern name="standard-rails-crud-with-morph">
<description>Standard Rails CRUD works automatically with Turbo Morph</description>

**Controller (stock Rails scaffold):**

```ruby
class FeedbacksController < ApplicationController
  def index
    @feedbacks = Feedback.all
  end

  def create
    @feedback = Feedback.new(feedback_params)
    if @feedback.save
      redirect_to feedbacks_path, notice: "Feedback created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @feedback.update(feedback_params)
      redirect_to feedbacks_path, notice: "Feedback updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @feedback.destroy
    redirect_to feedbacks_path, notice: "Feedback deleted"
  end
end
```

**View (standard Rails):**

```erb
<%# app/views/feedbacks/index.html.erb %>
<h1>Feedbacks</h1>
<%= link_to "New Feedback", new_feedback_path, class: "btn btn-primary" %>

<div id="feedbacks">
  <% @feedbacks.each do |feedback| %>
    <%= render feedback %>
  <% end %>
</div>

<%# app/views/feedbacks/_feedback.html.erb %>
<div id="<%= dom_id(feedback) %>" class="card">
  <h3><%= feedback.content %></h3>
  <div class="actions">
    <%= link_to "Edit", edit_feedback_path(feedback), class: "btn btn-sm" %>
    <%= button_to "Delete", feedback_path(feedback), method: :delete,
                  class: "btn btn-sm btn-error",
                  form: { data: { turbo_confirm: "Are you sure?" } } %>
  </div>
</div>
```

**What happens:** Create/update/delete triggers redirect → Turbo intercepts → morphs only changed elements → scroll/focus preserved. No custom code needed!
</pattern>

<pattern name="permanent-elements-morph">
<description>Prevent specific elements from morphing with data-turbo-permanent</description>

```erb
<%# Flash messages persist during morphing %>
<div id="flash-messages" data-turbo-permanent>
  <% flash.each do |type, message| %>
    <div class="alert alert-<%= type %>"><%= message %></div>
  <% end %>
</div>

<%# Video/audio won't restart on page morph %>
<video id="tutorial" data-turbo-permanent src="tutorial.mp4" controls></video>

<%# Form preserves input focus during live updates %>
<%= form_with model: @feedback, id: "feedback-form",
              data: { turbo_permanent: true } do |form| %>
  <%= form.text_area :content %>
  <%= form.submit %>
<% end %>
```

**Use cases:** Flash messages, video/audio players, forms with unsaved input, chat messages being typed.
</pattern>

<pattern name="broadcast-refresh-realtime">
<description>Real-time updates with broadcasts_refreshes (morphs all connected clients)</description>

```ruby
# Model broadcasts page refresh to all subscribers (Rails 8+)
class Feedback < ApplicationRecord
  broadcasts_refreshes
end
```

```erb
<%# View subscribes to stream - morphs when model changes %>
<%= turbo_stream_from @feedback %>

<div id="feedbacks">
  <% @feedbacks.each do |feedback| %>
    <%= render feedback %>
  <% end %>
</div>
```

**What happens:** User A creates feedback → server broadcasts `<turbo-stream action="refresh">` → all connected users' pages morph to show new feedback → scroll/focus preserved.

**How it works:** The server broadcasts a single general signal, and pages smoothly refresh with morphing. No need to manually manage individual Turbo Stream actions.

**Reference:** [Broadcasting Page Refreshes](https://turbo.hotwired.dev/handbook/page_refreshes#broadcasting-page-refreshes)
</pattern>

<pattern name="turbo-stream-morph-method">
<description>Use method="morph" in Turbo Streams for intelligent updates</description>

```ruby
# Controller - respond with Turbo Stream using morph
def create
  @feedback = Feedback.new(feedback_params)
  if @feedback.save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "feedbacks",
          partial: "feedbacks/list",
          locals: { feedbacks: Feedback.all },
          method: :morph  # Morphs instead of replacing
        )
      end
      format.html { redirect_to feedbacks_path }
    end
  end
end
```

```erb
<%# Or in .turbo_stream.erb view %>
<turbo-stream action="replace" target="feedback_<%= @feedback.id %>" method="morph">
  <template>
    <%= render @feedback %>
  </template>
</turbo-stream>
```

**Difference:** `method: :morph` preserves form state and focus. Without it, content is fully replaced.
</pattern>

<antipattern>
<description>Using Turbo Frames for simple CRUD lists</description>
<reason>Turbo Morph is simpler and preserves more state. Frames are overkill for basic updates.</reason>
<bad-example>

```erb
<%# ❌ BAD - Unnecessary Turbo Frame complexity %>
<% @feedbacks.each do |feedback| %>
  <%= turbo_frame_tag dom_id(feedback) do %>
    <%= render feedback %>
  <% end %>
<% end %>
```

</bad-example>
<good-example>

```erb
<%# ✅ GOOD - Simple rendering, Turbo Morph handles updates %>
<% @feedbacks.each do |feedback| %>
  <%= render feedback %>
<% end %>
```

</good-example>
</antipattern>

### Turbo Frames - Use Sparingly

**ONLY use Turbo Frames for:** modals, inline editing, tabs, pagination, lazy loading. For general CRUD, use Turbo Morph instead.

<pattern name="turbo-frame-inline-edit">
<description>Inline editing with Turbo Frame (valid use case)</description>

```erb
<%# Show view with inline edit frame %>
<%= turbo_frame_tag dom_id(@feedback) do %>
  <h3><%= @feedback.content %></h3>
  <%= link_to "Edit", edit_feedback_path(@feedback) %>
<% end %>

<%# Edit view with matching frame ID %>
<%= turbo_frame_tag dom_id(@feedback) do %>
  <%= form_with model: @feedback do |form| %>
    <%= form.text_area :content %>
    <%= form.submit "Save" %>
  <% end %>
<% end %>
```

**Why this is OK:** Inline editing without leaving the page. Frame scopes the update.
</pattern>

<pattern name="lazy-loading-frame">
<description>Lazy-load expensive content with Turbo Frames</description>

```erb
<%# Lazy load stats when scrolled into view %>
<%= turbo_frame_tag "statistics", src: statistics_path, loading: :lazy do %>
  <p>Loading statistics...</p>
<% end %>

<%# Frame that reloads with morphing on page refresh %>
<%= turbo_frame_tag "live-stats", src: live_stats_path, refresh: "morph" do %>
  <p>Loading live statistics...</p>
<% end %>
```

```ruby
# Controller renders just the frame
def statistics
  @stats = expensive_calculation
  render layout: false  # Or use turbo_frame layout
end
```

**Why this is OK:** Defers expensive computation until needed. Valid performance optimization. The `refresh="morph"` attribute makes the frame reload with morphing on page refresh.

**Reference:** [Turbo Frames with Morphing](https://turbo.hotwired.dev/handbook/page_refreshes#turbo-frames)
</pattern>

### Turbo Streams

<pattern name="turbo-stream-actions">
<description>Seven Turbo Stream actions for dynamic updates</description>

```ruby
def create
  if @feedback.save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("feedbacks", @feedback),
          turbo_stream.update("count", html: "10"),
          turbo_stream.remove("flash")
        ]
      end
      format.html { redirect_to feedbacks_path }
    end
  end
end
```

**Actions:** `append`, `prepend`, `replace`, `update`, `remove`, `before`, `after`, `refresh`

**Note:** For most cases, prefer `refresh` action with Turbo Morph over granular stream actions. See `broadcast-refresh-realtime` pattern above.
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

</pattern>

---

## Hotwire Stimulus

Stimulus is a modest JavaScript framework that connects JavaScript objects to HTML elements using data attributes, enhancing server-rendered HTML.

**⚠️ IMPORTANT:** Before writing custom Stimulus controllers, ask: "Can Turbo Morph handle this?" Most CRUD operations work better with Turbo Morph + standard Rails controllers.

**Use Stimulus for:**
- Client-side interactions (dropdowns, tooltips, character counters)
- Form enhancements (dynamic fields, auto-save)
- UI behavior (modals, tabs, accordions)

**Don't use Stimulus for:**
- Basic CRUD operations (use Turbo Morph)
- Simple list updates (use Turbo Morph)
- Navigation (use Turbo Drive)

### Core Concepts

<pattern name="stimulus-controller-basics">
<description>Simple Stimulus controller with targets, actions, and values</description>

**Controller:**

```javascript
// app/javascript/controllers/feedback_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "charCount"]
  static values = { maxLength: { type: Number, default: 1000 } }

  connect() {
    this.updateCharCount()
  }

  updateCharCount() {
    const count = this.contentTarget.value.length
    this.charCountTarget.textContent = `${count} / ${this.maxLengthValue}`
  }

  disconnect() {
    // Clean up (important for memory leaks)
  }
}
```

**HTML:**

```erb
<div data-controller="feedback" data-feedback-max-length-value="1000">
  <textarea data-feedback-target="content"
            data-action="input->feedback#updateCharCount"></textarea>
  <div data-feedback-target="charCount">0 / 1000</div>
</div>
```

**Syntax:** `event->controller#method` (default event based on element type)
</pattern>

<pattern name="stimulus-values">
<description>Typed data attributes for controller configuration</description>

```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    seconds: { type: Number, default: 60 },
    autostart: Boolean
  }

  connect() {
    if (this.autostartValue) this.start()
  }

  start() {
    this.timer = setInterval(() => {
      this.secondsValue--
      if (this.secondsValue === 0) this.stop()
    }, 1000)
  }

  secondsValueChanged() {
    this.element.textContent = this.secondsValue
  }

  disconnect() {
    clearInterval(this.timer)
  }
}
```

```erb
<div data-controller="countdown"
     data-countdown-seconds-value="120"
     data-countdown-autostart-value="true">60</div>
```

**Types:** Array, Boolean, Number, Object, String
</pattern>

<pattern name="stimulus-outlets">
<description>Reference and communicate with other controllers</description>

```javascript
// app/javascript/controllers/search_controller.js
export default class extends Controller {
  static outlets = ["results"]

  search(event) {
    fetch(`/search?q=${event.target.value}`)
      .then(r => r.text())
      .then(html => this.resultsOutlet.update(html))
  }
}

// results_controller.js
export default class extends Controller {
  update(html) { this.element.innerHTML = html }
}
```

```erb
<div data-controller="search" data-search-results-outlet="#results">
  <input data-action="input->search#search">
</div>
<div id="results" data-controller="results"></div>
```

</pattern>

<pattern name="nested-form-dynamic-stimulus">
<description>Dynamic add/remove nested fields using Stimulus</description>

**Form:**

```erb
<div data-controller="nested-form">
  <%= form_with model: @feedback do |form| %>
    <div class="mb-6">
      <button type="button" class="btn btn-sm" data-action="nested-form#add">
        Add Attachment
      </button>
      <div data-nested-form-target="container" class="space-y-4">
        <%= form.fields_for :attachments do |f| %>
          <%= render "attachment_fields", form: f %>
        <% end %>
      </div>

      <template data-nested-form-target="template">
        <%= form.fields_for :attachments, Attachment.new, child_index: "NEW_RECORD" do |f| %>
          <%= render "attachment_fields", form: f %>
        <% end %>
      </template>
    </div>
  <% end %>
</div>
```

**Stimulus Controller:**

```javascript
// app/javascript/controllers/nested_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML
      .replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    const field = event.target.closest(".nested-fields")
    const destroyInput = field.querySelector("input[name*='_destroy']")
    const idInput = field.querySelector("input[name*='[id]']")

    if (idInput && idInput.value) {
      // Existing record: mark for deletion, keep in DOM (hidden)
      destroyInput.value = "1"
      field.style.display = "none"
    } else {
      // New record: remove from DOM entirely
      field.remove()
    }
  }
}
```

</pattern>

<antipattern>
<description>Not cleaning up in disconnect()</description>
<reason>Memory leaks from timers, event listeners</reason>
<bad-example>

```javascript
// ❌ BAD - Memory leak
connect() {
  this.timer = setInterval(() => this.update(), 1000)
}
```

</bad-example>
<good-example>

```javascript
// ✅ GOOD - Clean up
disconnect() {
  clearInterval(this.timer)
}
```

</good-example>
</antipattern>

---

<testing>
**System Tests for Turbo and Stimulus:**

```ruby
# test/system/turbo_test.rb
class TurboTest < ApplicationSystemTestCase
  test "updates without full page reload" do
    visit feedbacks_path
    fill_in "Content", with: "New feedback"
    click_button "Create"
    assert_selector "#feedbacks", text: "New feedback"
  end

  test "edits within frame" do
    feedback = feedbacks(:one)
    visit feedbacks_path
    within "##{dom_id(feedback)}" do
      click_link "Edit"
      fill_in "Content", with: "Updated"
      click_button "Save"
      assert_text "Updated"
    end
  end
end

# test/system/stimulus_test.rb
class StimulusTest < ApplicationSystemTestCase
  test "character counter updates on input" do
    visit new_feedback_path
    fill_in "Content", with: "Test"
    assert_selector "[data-feedback-target='charCount']", text: "4 / 1000"
  end

  test "nested form add/remove works" do
    visit new_feedback_path
    initial_count = all(".nested-fields").count
    click_button "Add Attachment"
    assert_equal initial_count + 1, all(".nested-fields").count
  end
end
```

**Manual Testing:**
- Test with JavaScript disabled (progressive enhancement)
- Verify scroll position preservation with Turbo Morph
- Check focus management in modals and inline editing
- Test real-time updates in multiple browser tabs
</testing>

---

<related-skills>
- rails-ai:views - Partials, helpers, forms, and view structure
- rails-ai:styling - Tailwind/DaisyUI for styling Hotwire components
- rails-ai:controllers - RESTful actions that work with Turbo
- rails-ai:testing - System tests for Turbo and Stimulus
</related-skills>

<resources>

**Official Documentation:**
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Turbo Page Refreshes (Morph)](https://turbo.hotwired.dev/handbook/page_refreshes)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)

**Community Resources:**
- [Hotwire Discussion Forum](https://discuss.hotwired.dev/)

</resources>
