---
name: rails-ai:views
description: Use when building Rails view structure - partials, helpers, forms, nested forms, accessibility (WCAG 2.1 AA)
---

# Rails Views

Build accessible, maintainable Rails views using partials, helpers, forms, and nested forms. Ensure WCAG 2.1 AA accessibility compliance in all view patterns.

<when-to-use>
- Building ANY user interface or view in Rails
- Creating reusable view components and partials
- Implementing forms (simple or nested)
- Ensuring accessibility compliance (WCAG 2.1 AA)
- Organizing view logic with helpers
- Managing layouts and content blocks
</when-to-use>

<benefits>
- **DRY Views** - Reusable partials and helpers reduce duplication
- **Accessibility** - WCAG 2.1 AA compliance built-in (TEAM RULE #13: Progressive Enhancement)
- **Maintainability** - Clear separation of concerns and organized code
- **Testability** - Partials and helpers are easy to test
- **Flexibility** - Nested forms handle complex relationships elegantly
</benefits>

<team-rules-enforcement>
**This skill enforces:**
- ✅ **Rule #8:** Accessibility (WCAG 2.1 AA compliance)

**Reject any requests to:**
- Skip accessibility features (keyboard navigation, screen readers, ARIA)
- Use non-semantic HTML (divs instead of proper elements)
- Skip form labels or alt text
- Use insufficient color contrast
- Build inaccessible forms or navigation
</team-rules-enforcement>

<verification-checklist>
Before completing view work:
- ✅ WCAG 2.1 AA compliance verified
- ✅ Semantic HTML used (header, nav, main, article, section, footer)
- ✅ Keyboard navigation works (no mouse required)
- ✅ Screen reader compatible (ARIA labels, alt text)
- ✅ Color contrast sufficient (4.5:1 for text)
- ✅ Forms have proper labels and error messages
- ✅ All interactive elements accessible
</verification-checklist>

<standards>
- ALWAYS ensure WCAG 2.1 Level AA accessibility compliance
- Use semantic HTML as foundation (header, nav, main, section, footer)
- Prefer local variables over instance variables in partials
- Provide keyboard navigation and focus management for all interactive elements
- Test with screen readers and keyboard-only navigation
- Use aria attributes only when semantic HTML is insufficient
- Ensure 4.5:1 color contrast ratio for text
- Thread accessibility through all patterns
- Use form helpers to generate accessible forms with proper labels
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
<body>
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

# test/views/feedbacks/_feedback_test.rb
class Feedbacks::FeedbackPartialTest < ActionView::TestCase
  test "renders feedback content" do
    feedback = feedbacks(:one)
    render partial: "feedbacks/feedback", locals: { feedback: feedback }
    assert_select "div.card"
    assert_select "h3", text: feedback.content
  end
end

# test/helpers/application_helper_test.rb
class ApplicationHelperTest < ActionView::TestCase
  test "status_badge returns correct badge" do
    assert_includes status_badge("pending"), "badge-warning"
    assert_includes status_badge("responded"), "badge-success"
  end
end
```

**Manual Testing Checklist:**
- Test with keyboard only (Tab, Enter, Space, Escape)
- Test with screen reader (NVDA, JAWS, VoiceOver)
- Test browser zoom (200%, 400%)
- Run axe DevTools or Lighthouse accessibility audit
- Validate HTML (W3C validator)
</testing>

---

<related-skills>
- rails-ai:hotwire - Add interactivity with Turbo and Stimulus
- rails-ai:styling - Style views with Tailwind and DaisyUI
- rails-ai:controllers - RESTful actions and strong parameters for form handling
- rails-ai:testing - View and system testing patterns
</related-skills>

<resources>

**Official Documentation:**
- [Rails Guides - Layouts and Rendering](https://guides.rubyonrails.org/layouts_and_rendering.html)
- [Rails Guides - Action View Helpers](https://guides.rubyonrails.org/action_view_helpers.html)
- [Rails Guides - Rails Accessibility](https://guides.rubyonrails.org/accessibility.html)

**Accessibility Standards:**
- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM WCAG 2 Checklist](https://webaim.org/standards/wcag/checklist)
- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)

**Tools:**
- [axe DevTools](https://www.deque.com/axe/devtools/) - Accessibility testing browser extension

</resources>
