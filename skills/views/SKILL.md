---
name: rails-ai:views
description: Use when building Rails views - partials, helpers, forms, accessibility, Hotwire (Turbo/Stimulus), Tailwind, DaisyUI
---

# Rails Views

Complete guide to building accessible, interactive, and maintainable Rails views using partials, helpers, forms, Hotwire, Tailwind CSS, and DaisyUI components.

<when-to-use>
- Building ANY user interface or view in Rails
- Creating reusable view components and partials
- Implementing forms (simple or nested)
- Adding interactivity without heavy JavaScript frameworks
- Styling with utility-first CSS and component libraries
- Ensuring accessibility compliance (WCAG 2.1 AA)
- Building real-time, SPA-like experiences with server-rendered HTML
</when-to-use>

<benefits>
- **DRY Views** - Reusable partials and helpers reduce duplication
- **Accessibility** - WCAG 2.1 AA compliance built-in (TEAM RULE #13: Progressive Enhancement)
- **Interactive UIs** - Hotwire provides SPA-like speed without JavaScript frameworks
- **Rapid Development** - Tailwind + DaisyUI enable fast UI iteration
- **Maintainability** - Clear separation of concerns and organized code
- **Progressive Enhancement** - Works without JavaScript, enhanced with it
- **Real-time Updates** - Turbo Streams for live updates via ActionCable
</benefits>

<standards>
- ALWAYS ensure WCAG 2.1 Level AA accessibility compliance
- Use semantic HTML as foundation (header, nav, main, section, footer)
- Prefer local variables over instance variables in partials
- Use Hotwire Turbo for interactivity (TEAM RULE #7: Turbo Morph, TEAM RULE #13: Progressive Enhancement)
- Style with Tailwind utilities first, DaisyUI components for complex UI
- Provide keyboard navigation and focus management for all interactive elements
- Test with screen readers and keyboard-only navigation
- Use aria attributes only when semantic HTML is insufficient
- Ensure 4.5:1 color contrast ratio for text
- Thread accessibility through all patterns
</standards>

---

## Partials & Layouts

Partials are reusable view fragments. Layouts define page structure. Together they create maintainable, consistent UIs.

### Basic Partials

<pattern name="simple-partial">
<description>Render partials with explicit local variables</description>

```erb
<%# Shared directory %>
<%= render "shared/header" %>

<%# Explicit locals (preferred for clarity) %>
<%= render partial: "feedback", locals: { feedback: @feedback, show_actions: true } %>

<%# Partial definition: app/views/feedbacks/_feedback.html.erb %>
<div id="<%= dom_id(feedback) %>" class="card">
  <h3><%= feedback.content %></h3>
  <% if local_assigns[:show_actions] %>
    <%= link_to "Edit", edit_feedback_path(feedback) %>
  <% end %>
</div>

```

**Why local_assigns?** Prevents `NameError` when variable not passed. Allows optional parameters with defaults.
</pattern>

<pattern name="collection-rendering">
<description>Efficiently render partials for collections</description>

```erb
<%# Shorthand - automatic partial lookup %>
<%= render @feedbacks %>

<%# Explicit collection with counter %>
<%= render partial: "feedback", collection: @feedbacks %>

<%# Partial with counters %>
<%# app/views/feedbacks/_feedback.html.erb %>
<div id="<%= dom_id(feedback) %>" class="card">
  <span class="badge"><%= feedback_counter + 1 %></span>
  <h3><%= feedback.content %></h3>
  <% if feedback_iteration.first? %>
    <span class="label">First</span>
  <% end %>
</div>

```

**Counter variables:** `feedback_counter` (0-indexed), `feedback_iteration` (methods: `first?`, `last?`, `index`, `size`)
</pattern>

### Layouts & Content Blocks

<pattern name="content-for">
<description>Customize layout sections from individual views</description>

```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title><%= content_for?(:title) ? yield(:title) : "App Name" %></title>
  <%= csrf_meta_tags %>
  <%= stylesheet_link_tag "application" %>
  <%= yield :head %>
</head>
<body data-turbo-refresh-method="morph" data-turbo-refresh-scroll="preserve">
  <%= render "shared/header" %>
  <main id="main-content">
    <%= render "shared/flash_messages" %>
    <%= yield %>
  </main>
  <%= yield :scripts %>
</body>
</html>

<%# app/views/feedbacks/show.html.erb %>
<% content_for :title, "#{@feedback.content.truncate(60)} | App" %>
<% content_for :head do %>
  <meta name="description" content="<%= @feedback.content.truncate(160) %>">
<% end %>
<div class="feedback-detail"><%= @feedback.content %></div>

```

</pattern>

<antipattern>
<description>Using instance variables in partials</description>
<reason>Creates implicit dependencies, makes partials hard to reuse and test</reason>
<bad-example>

```erb
<%# ❌ BAD - Coupled to controller %>
<div class="feedback"><%= @feedback.content %></div>

```

</bad-example>
<good-example>

```erb
<%# ✅ GOOD - Explicit dependencies %>
<div class="feedback"><%= feedback.content %></div>
<%= render "feedback", feedback: @feedback %>

```

</good-example>
</antipattern>

---

## View Helpers

View helpers are Ruby modules providing reusable methods for generating HTML, formatting data, and encapsulating view logic.

### Custom Helpers

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

  def page_title(title = nil)
    base = "The Feedback Agent"
    title.present? ? "#{title} | #{base}" : base
  end
end

```

```erb
<%# Usage %>
<%= status_badge(@feedback.status) %>
<title><%= page_title(yield(:title)) %></title>

```

</pattern>

<pattern name="text-helpers">
<description>Use built-in Rails text helpers for formatting</description>

```erb
<%= truncate(@feedback.content, length: 150) %>
<%= time_ago_in_words(@feedback.created_at) %> ago
<%= pluralize(@feedbacks.count, "feedback") %>
<%= sanitize(user_content, tags: %w[p br strong em]) %>

```

</pattern>

<antipattern>
<description>Using html_safe on user input</description>
<reason>XSS vulnerability - allows script execution</reason>
<bad-example>

```ruby
# ❌ DANGEROUS
def render_content(content)
  content.html_safe  # XSS risk!
end

```

</bad-example>
<good-example>

```ruby
# ✅ SAFE - Auto-escaped or sanitized
def render_content(content)
  content  # Auto-escaped by Rails
end

def render_html(content)
  sanitize(content, tags: %w[p br strong])
end

```

</good-example>
</antipattern>

---

## Nested Forms

Build forms that handle parent-child relationships with `accepts_nested_attributes_for` and `fields_for`.

### Basic Nested Forms

<pattern name="has-many-nested-form">
<description>Form with has_many relationship using fields_for</description>

**Model:**

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments,
    allow_destroy: true,
    reject_if: :all_blank

  validates :content, presence: true
end

```

**Controller:**

```ruby
class FeedbacksController < ApplicationController
  def new
    @feedback = Feedback.new
    3.times { @feedback.attachments.build }  # Build empty attachments
  end

  private

  def feedback_params
    params.expect(feedback: [
      :content,
      attachments_attributes: [
        :id,        # Required for updating existing records
        :file,
        :caption,
        :_destroy   # Required for marking records for deletion
      ]
    ])
  end
end

```

**View:**

```erb
<%= form_with model: @feedback do |form| %>
  <%= form.text_area :content, class: "textarea" %>

  <div class="space-y-4">
    <h3>Attachments</h3>
    <%= form.fields_for :attachments do |f| %>
      <div class="nested-fields card">
        <%= f.file_field :file, class: "file-input" %>
        <%= f.text_field :caption, class: "input" %>
        <%= f.hidden_field :id if f.object.persisted? %>
        <%= f.check_box :_destroy %> <%= f.label :_destroy, "Remove" %>
      </div>
    <% end %>
  </div>

  <%= form.submit class: "btn btn-primary" %>
<% end %>

```

</pattern>

### Dynamic Nested Forms with Stimulus

<pattern name="dynamic-nested-stimulus">
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
<description>Missing :id in strong parameters for updates</description>
<reason>Rails can't identify which existing records to update, creates duplicates instead</reason>
<bad-example>

```ruby
# ❌ BAD - Missing :id
def feedback_params
  params.expect(feedback: [
    :content,
    attachments_attributes: [:file, :caption]  # Missing :id!
  ])
end

```

</bad-example>
<good-example>

```ruby
# ✅ GOOD - Include :id for existing records
def feedback_params
  params.expect(feedback: [
    :content,
    attachments_attributes: [:id, :file, :caption, :_destroy]
  ])
end

```

</good-example>
</antipattern>

---

## Accessibility (WCAG 2.1 AA)

Ensure your Rails application is usable by everyone, including people with disabilities. Accessibility is threaded through ALL view patterns.

### Semantic HTML & ARIA

<pattern name="semantic-structure">
<description>Use semantic HTML5 elements with proper ARIA labels</description>

```erb
<%# Semantic landmarks with skip link %>
<a href="#main-content" class="sr-only focus:not-sr-only">
  Skip to main content
</a>

<header>
  <h1>Feedback Application</h1>
  <nav aria-label="Main navigation">
    <ul>
      <li><%= link_to "Home", root_path %></li>
      <li><%= link_to "Feedbacks", feedbacks_path %></li>
    </ul>
  </nav>
</header>

<main id="main-content">
  <h2>Recent Feedback</h2>
  <section aria-labelledby="pending-heading">
    <h3 id="pending-heading">Pending Items</h3>
  </section>
</main>

```

**Why:** Screen readers use landmarks (header, nav, main, footer) and headings to navigate. Logical h1-h6 hierarchy (don't skip levels).
</pattern>

<pattern name="aria-labels">
<description>Provide accessible names for elements without visible text</description>

```erb
<%# Icon-only button %>
<button aria-label="Close modal" class="btn btn-ghost btn-sm">
  <svg class="w-4 h-4">...</svg>
</button>

<%# Delete button with context %>
<%= button_to "Delete", feedback_path(@feedback),
              method: :delete,
              aria: { label: "Delete feedback from #{@feedback.sender_name}" },
              class: "btn btn-error btn-sm" %>

<%# Modal with labelledby %>
<dialog aria-labelledby="modal-title" aria-modal="true">
  <h3 id="modal-title">Feedback Details</h3>
</dialog>

<%# Form field with hint %>
<%= form.text_field :email, aria: { describedby: "email-hint" } %>
<span id="email-hint">We'll never share your email</span>

```

</pattern>

<pattern name="aria-live-regions">
<description>Announce dynamic content changes to screen readers</description>

```erb
<%# Flash messages with live region %>
<div aria-live="polite" aria-atomic="true">
  <% if flash[:notice] %>
    <div role="status" class="alert alert-success">
      <%= flash[:notice] %>
    </div>
  <% end %>
  <% if flash[:alert] %>
    <div role="alert" class="alert alert-error">
      <%= flash[:alert] %>
    </div>
  <% end %>
</div>

<%# Loading state %>
<div role="status" aria-live="polite" class="sr-only" data-loading-target="status">
  <%# Updated via JS: "Submitting feedback, please wait..." %>
</div>

```

**Values:** `aria-live="polite"` (announces when idle), `aria-live="assertive"` (interrupts), `aria-atomic="true"` (reads entire region).
</pattern>

### Keyboard Navigation & Focus Management

<pattern name="keyboard-accessibility">
<description>Ensure all interactive elements are keyboard accessible</description>

```erb
<%# Native elements - keyboard works by default %>
<button type="button" data-action="click->modal#open">Open Modal</button>
<%= button_to "Delete", feedback_path(@feedback), method: :delete %>

<%# Custom interactive element needs full keyboard support %>
<div tabindex="0" role="button"
     data-action="click->controller#action keydown.enter->controller#action keydown.space->controller#action">
  Custom Button
</div>

```

```css
/* Always provide visible focus indicators */
button:focus, a:focus, input:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

```

**Key Events:** Enter and Space activate buttons. Tab navigates. Escape closes modals.
</pattern>

<pattern name="focus-management-modals">
<description>Trap and manage focus in modal dialogs</description>

```erb
<dialog id="feedback-modal" aria-labelledby="modal-title" aria-modal="true"
        data-controller="modal-focus">
  <div class="modal-box">
    <button aria-label="Close" data-action="modal-focus#close">✕</button>
    <h3 id="modal-title">Feedback Details</h3>
    <p><%= @feedback.content %></p>
    <button class="btn" data-action="modal-focus#close">Close</button>
  </div>
</dialog>

```

```javascript
// app/javascript/controllers/modal_focus_controller.js
export default class extends Controller {
  open() {
    this.previousFocus = document.activeElement
    this.element.showModal()
    this.element.querySelector('button').focus()
    this.element.addEventListener("keydown", this.trapFocus.bind(this))
  }

  close() {
    this.element.removeEventListener("keydown", this.trapFocus.bind(this))
    this.element.close()
    this.previousFocus?.focus()  // Return focus to trigger
  }

  trapFocus(event) {
    if (event.key !== "Tab") return
    const focusable = this.element.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])')
    const first = focusable[0]
    const last = focusable[focusable.length - 1]

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }
}

```

**Why:** Modal dialogs must trap focus. Always return focus to trigger element on close.
</pattern>

### Accessible Forms

<pattern name="form-labels-errors">
<description>Associate labels with inputs and display errors accessibly</description>

```erb
<%= form_with model: @feedback do |form| %>
  <%# Error summary %>
  <% if @feedback.errors.any? %>
    <div role="alert" id="error-summary" tabindex="-1">
      <h2><%= pluralize(@feedback.errors.count, "error") %> prohibited saving:</h2>
      <ul>
        <% @feedback.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-control">
    <%= form.label :content, "Your Feedback" %>
    <%= form.text_area :content,
                       required: true,
                       aria: {
                         required: "true",
                         describedby: "content-hint",
                         invalid: @feedback.errors[:content].any? ? "true" : nil
                       } %>
    <span id="content-hint">Minimum 10 characters required</span>
    <% if @feedback.errors[:content].any? %>
      <span id="content-error" role="alert">
        <%= @feedback.errors[:content].first %>
      </span>
    <% end %>
  </div>

  <fieldset>
    <legend>Sender Information</legend>
    <%= form.label :sender_name, "Name" %>
    <%= form.text_field :sender_name %>
    <%= form.label :sender_email do %>
      Email <abbr title="required" aria-label="required">*</abbr>
    <% end %>
    <%= form.email_field :sender_email, required: true, autocomplete: "email" %>
  </fieldset>

  <%= form.submit "Submit", data: { disable_with: "Submitting..." } %>
<% end %>

```

**Why:** Labels provide accessible names. `role="alert"` announces errors. `aria-invalid` marks problematic fields.
</pattern>

### Color Contrast & Images

<pattern name="color-contrast">
<description>Ensure sufficient color contrast and accessible images</description>

**WCAG AA Requirements:**
- Normal text (< 18px): 4.5:1 ratio minimum
- Large text (≥ 18px or bold ≥ 14px): 3:1 ratio minimum

```erb
<%# ✅ GOOD - High contrast + icon + text (not color alone) %>
<span class="text-error">
  <svg aria-hidden="true">...</svg>
  <strong>Error:</strong> This field is required
</span>

<%# Images - descriptive alt text %>
<%= image_tag "chart.png", alt: "Bar chart: 85% positive feedback in March 2025" %>

<%# Decorative images - empty alt %>
<%= image_tag "decoration.svg", alt: "", role: "presentation" %>

<%# Functional images - describe action %>
<%= link_to feedback_path(@feedback) do %>
  <%= image_tag "view-icon.svg", alt: "View feedback details" %>
<% end %>

```

</pattern>

<antipattern>
<description>Using placeholder as label</description>
<reason>Placeholders disappear when typing and have insufficient contrast</reason>
<bad-example>

```erb
<%# ❌ No label %>
<input type="email" placeholder="Enter your email">

```

</bad-example>
<good-example>

```erb
<%# ✅ Label + placeholder %>
<label for="email">Email Address</label>
<input type="email" id="email" placeholder="you@example.com">

```

</good-example>
</antipattern>

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

## Tailwind CSS

Tailwind CSS is a utility-first CSS framework for building custom designs without writing custom CSS.

### Core Utilities

<pattern name="spacing-layout">
<description>Consistent spacing and layout with Tailwind utilities</description>

```erb
<%# Spacing: p-{size}, m-{size}, gap-{size} %>
<div class="p-4">Padding all sides</div>
<div class="px-6 py-4">Horizontal/Vertical padding</div>
<div class="mx-auto max-w-4xl">Centered container</div>

<%# Flexbox layout %>
<div class="flex items-center justify-between gap-4">
  <span>Left</span>
  <span>Right</span>
</div>

<%# Grid layout %>
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
  <% @items.each do |item| %>
    <div class="bg-white p-4 rounded-lg shadow"><%= item.name %></div>
  <% end %>
</div>

```

</pattern>

<pattern name="responsive-design">
<description>Mobile-first responsive utilities (sm:640px, md:768px, lg:1024px, xl:1280px)</description>

```erb
<%# Pattern: base (mobile) → sm: → md: → lg: → xl: %>
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
  <% @feedbacks.each do |feedback| %>
    <%= render feedback %>
  <% end %>
</div>

<%# Responsive spacing/typography %>
<div class="p-4 md:p-8">
  <h1 class="text-2xl md:text-4xl font-bold">Heading</h1>
</div>

<%# Hide/show based on breakpoint %>
<div class="block md:hidden">Mobile menu</div>
<nav class="hidden md:flex gap-4">Desktop nav</nav>

```

</pattern>

<pattern name="typography-colors">
<description>Text styling and color utilities</description>

```erb
<%# Typography %>
<p class="text-sm font-medium">Small medium text</p>
<h1 class="text-4xl font-bold">Large heading</h1>
<p class="leading-relaxed tracking-wide">Spaced text</p>
<p class="truncate"><%= feedback.content %></p>

<%# Colors: text-{color}-{shade}, bg-{color}-{shade} %>
<div class="bg-white text-gray-900">Dark text on white</div>
<div class="bg-blue-600 text-white">White on blue</div>
<p class="text-red-600/50">Red with 50% opacity</p>

<%# Interactive states %>
<button class="bg-blue-600 hover:bg-blue-700 active:bg-blue-800 text-white px-4 py-2 rounded">
  Hover me
</button>
<input type="text" class="border border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 rounded px-3 py-2" />

```

</pattern>

<pattern name="feedback-card-example">
<description>Complete feedback card using Tailwind utilities</description>

```erb
<div class="bg-white rounded-lg shadow-md hover:shadow-xl transition-shadow p-6">
  <%# Header %>
  <div class="flex items-start justify-between mb-4">
    <div class="flex items-center gap-3">
      <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white font-semibold">
        <%= @feedback.sender_name&.first&.upcase || "A" %>
      </div>
      <div>
        <h3 class="font-semibold text-gray-900"><%= @feedback.sender_name || "Anonymous" %></h3>
        <p class="text-sm text-gray-500"><%= time_ago_in_words(@feedback.created_at) %> ago</p>
      </div>
    </div>
    <span class="px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
      <%= @feedback.status.titleize %>
    </span>
  </div>

  <%# Content %>
  <p class="text-gray-700 leading-relaxed line-clamp-3 mb-4"><%= @feedback.content %></p>

  <%# Footer %>
  <div class="flex items-center justify-between pt-4 border-t border-gray-100">
    <span class="text-sm text-gray-500"><%= @feedback.responses_count %> responses</span>
    <div class="flex gap-2">
      <%= link_to "View", feedback_path(@feedback), class: "px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-700 hover:bg-gray-50" %>
      <%= link_to "Respond", respond_feedback_path(@feedback), class: "px-3 py-1.5 rounded-md text-sm text-white bg-blue-600 hover:bg-blue-700" %>
    </div>
  </div>
</div>

```

</pattern>

<antipattern>
<description>Using inline styles instead of Tailwind utilities</description>
<reason>Bypasses design system consistency and reduces maintainability</reason>
<bad-example>

```erb
<%# ❌ BAD %>
<div style="padding: 16px; background: #3b82f6;">Content</div>

```

</bad-example>
<good-example>

```erb
<%# ✅ GOOD %>
<div class="p-4 bg-blue-500">Content</div>

```

</good-example>
</antipattern>

---

## DaisyUI Components

Semantic component library built on Tailwind providing 70+ accessible components with built-in theming and dark mode.

### Buttons & Forms

<pattern name="daisyui-buttons">
<description>Use DaisyUI button classes for consistent interactive elements</description>

```erb
<%# DaisyUI button components %>
<button class="btn btn-primary">Primary Action</button>
<button class="btn btn-ghost">Ghost</button>
<button class="btn btn-outline btn-primary">Outline</button>

<%# Rails form integration %>
<%= form_with model: @feedback do |f| %>
  <div class="form-control">
    <%= f.label :content, class: "label" do %>
      <span class="label-text">Feedback</span>
    <% end %>
    <%= f.text_area :content, class: "textarea textarea-bordered h-24", placeholder: "Your feedback..." %>
  </div>
  <div class="flex gap-2 justify-end">
    <%= link_to "Cancel", feedbacks_path, class: "btn btn-ghost" %>
    <%= f.submit "Submit", class: "btn btn-primary" %>
  </div>
<% end %>

```

</pattern>

<pattern name="daisyui-cards">
<description>Use card component for content containers</description>

```erb
<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <div class="flex items-start justify-between">
      <h2 class="card-title"><%= @feedback.title %></h2>
      <div class="badge badge-<%= @feedback.status %>">
        <%= @feedback.status.titleize %>
      </div>
    </div>
    <p class="text-base-content/70"><%= @feedback.content %></p>
    <div class="card-actions justify-end mt-4">
      <%= link_to "View", feedback_path(@feedback), class: "btn btn-primary btn-sm" %>
    </div>
  </div>
</div>

```

</pattern>

<pattern name="daisyui-alerts">
<description>Use alerts and badges for notifications and status</description>

```erb
<%# Alerts %>
<div class="alert alert-success">
  <span>Success! Your feedback was submitted.</span>
</div>

<div class="alert alert-error">
  <span>Error! Unable to submit feedback.</span>
</div>

<%# Flash messages %>
<% if flash[:notice] %>
  <div class="alert alert-success">
    <span><%= flash[:notice] %></span>
  </div>
<% end %>

<%# Badges %>
<div class="badge badge-primary">Primary</div>
<div class="badge badge-success">Success</div>
<div class="badge badge-warning">Warning</div>

```

</pattern>

<pattern name="daisyui-modal">
<description>Use modal component for dialogs</description>

```erb
<button class="btn btn-primary" onclick="feedback_modal.showModal()">
  View Details
</button>

<dialog id="feedback_modal" class="modal">
  <div class="modal-box">
    <h3 class="font-bold text-lg">Feedback Details</h3>
    <p class="py-4"><%= @feedback.content %></p>
    <div class="modal-action">
      <form method="dialog">
        <button class="btn">Close</button>
      </form>
    </div>
  </div>
  <form method="dialog" class="modal-backdrop">
    <button>close</button>
  </form>
</dialog>

```

</pattern>

### Theme Switching

<pattern name="daisyui-theme-toggle">
<description>Implement dark mode and theme switching</description>

```javascript
// app/javascript/controllers/theme_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const savedTheme = localStorage.getItem("theme") || "light"
    this.setTheme(savedTheme)
  }

  toggle() {
    const currentTheme = document.documentElement.getAttribute("data-theme")
    const newTheme = currentTheme === "light" ? "dark" : "light"
    this.setTheme(newTheme)
  }

  setTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
    localStorage.setItem("theme", theme)
  }
}

```

```erb
<%# Layout %>
<html data-theme="light">
  <body>
    <div data-controller="theme">
      <button class="btn btn-ghost btn-circle" data-action="click->theme#toggle">
        Toggle Theme
      </button>
    </div>
  </body>
</html>

```

</pattern>

<antipattern>
<description>Building custom buttons with Tailwind instead of DaisyUI components</description>
<reason>Duplicates effort, loses accessibility features</reason>
<bad-example>

```erb
<%# ❌ Custom button with Tailwind utilities %>
<button class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
  Submit
</button>

```

</bad-example>
<good-example>

```erb
<%# ✅ DaisyUI button component %>
<button class="btn btn-primary">Submit</button>

```

</good-example>
</antipattern>

---

## Testing Views

<testing>
**System Tests with Accessibility:**

```ruby
# test/system/accessibility_test.rb
class AccessibilityTest < ApplicationSystemTestCase
  test "form has accessible labels and ARIA" do
    visit new_feedback_path
    assert_selector "label[for='feedback_content']"
    assert_selector "textarea#feedback_content[required][aria-required='true']"
  end

  test "errors are announced with role=alert" do
    visit new_feedback_path
    click_button "Submit"
    assert_selector "[role='alert']"
    assert_selector "[aria-invalid='true']"
  end

  test "keyboard navigation works" do
    visit feedbacks_path
    page.send_keys(:tab)  # Should focus first interactive element
    page.send_keys(:enter)  # Should activate element
  end
end

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

**View Component Tests:**

```ruby
# test/components/alert_component_test.rb
class AlertComponentTest < ViewComponent::TestCase
  test "renders variant with correct classes" do
    render_inline(AlertComponent.new(message: "Info", variant: :info))
    assert_selector "div.alert.alert-info"
    assert_text "Info"
  end
end

# test/helpers/application_helper_test.rb
class ApplicationHelperTest < ActionView::TestCase
  test "status_badge returns correct badge" do
    assert_includes status_badge("pending"), "badge-warning"
    assert_includes status_badge("responded"), "badge-success"
  end
end

# test/views/feedbacks/_feedback_test.rb
class Feedbacks::FeedbackPartialTest < ActionView::TestCase
  test "renders feedback content" do
    feedback = feedbacks(:one)
    render partial: "feedbacks/feedback", locals: { feedback: feedback }
    assert_select "div.card"
    assert_select "h3", text: feedback.content
  end
end

```

**Manual Testing Checklist:**
- Test with keyboard only (Tab, Enter, Space, Escape)
- Test with screen reader (NVDA, JAWS, VoiceOver)
- Test browser zoom (200%, 400%)
- Run axe DevTools or Lighthouse accessibility audit
- Validate HTML (W3C validator)
- Test responsive breakpoints (mobile, tablet, desktop)
- Test dark mode theme switching
- Test with JavaScript disabled (progressive enhancement)
</testing>

---

<related-skills>
- rails-ai:controllers - RESTful actions and strong parameters for form handling
- rails-ai:models - ActiveRecord models used in views
- rails-ai:security - XSS prevention, output escaping, CSRF tokens in forms
</related-skills>

<resources>
**Rails & Hotwire:**
- [Rails Guides - Layouts and Rendering](https://guides.rubyonrails.org/layouts_and_rendering.html)
- [Rails Guides - Action View Helpers](https://guides.rubyonrails.org/action_view_helpers.html)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)

**Accessibility:**
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Rails Accessibility Guide](https://guides.rubyonrails.org/accessibility.html)
- [WebAIM WCAG Checklist](https://webaim.org/standards/wcag/checklist)
- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [axe DevTools Browser Extension](https://www.deque.com/axe/devtools/)

**CSS & Components:**
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [DaisyUI Documentation](https://daisyui.com/)
- [Tailwind UI Components](https://tailwindui.com/)
</resources>
