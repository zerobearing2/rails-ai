---
name: accessibility-patterns
domain: frontend
dependencies: []
version: 1.0
rails_version: 8.1+

# Team rules enforcement
enforces_team_rule:
  - rule_id: 13
    rule_name: "Progressive Enhancement"
    severity: moderate
    enforcement_action: SUGGEST
    note: "Keyboard navigation and fallbacks required"
---

# Web Accessibility (a11y) Patterns

Ensure your Rails application is usable by everyone, including people with disabilities who use assistive technologies like screen readers, keyboard navigation, and voice control.

<when-to-use>
- Building ANY user interface or interactive element
- Creating forms, buttons, navigation, or modals
- Displaying dynamic content or status updates
- Implementing tables, images, or media content
- ALWAYS - Accessibility is not optional
</when-to-use>

<benefits>
- **Inclusive Design** - Usable by everyone, regardless of ability
- **Legal Compliance** - Meets ADA, Section 508, and WCAG requirements
- **Better SEO** - Semantic HTML improves search engine indexing
- **Improved UX** - Keyboard navigation and clear labels benefit all users
- **Future-Proof** - Works with emerging assistive technologies
- **Broader Reach** - 15% of the world's population has some form of disability
</benefits>

<standards>
Follow WCAG 2.1 Level AA compliance:
- Use semantic HTML as the foundation
- Provide text alternatives for non-text content
- Ensure 4.5:1 color contrast ratio for normal text
- Make all functionality keyboard accessible
- Provide clear focus indicators for interactive elements
- Label all form inputs and controls
- Use ARIA attributes only when semantic HTML is insufficient
- Test with keyboard navigation and screen readers
- Never rely on color alone to convey information
- Manage focus for dynamic content and modals
</standards>

## Semantic HTML Foundation

<pattern name="semantic-structure">
<description>Use semantic HTML5 elements for proper document structure</description>

**Proper Page Structure:**
```erb
<%# ✅ ACCESSIBLE - Semantic landmarks %>
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
    <%# Content %>
  </section>

  <aside aria-label="Related information">
    <h3>Help & Support</h3>
    <%# Sidebar content %>
  </aside>
</main>

<footer>
  <p>&copy; 2025 Feedback App</p>
</footer>
```

**Heading Hierarchy:**
```erb
<%# ✅ GOOD - Logical hierarchy %>
<h1>Main Page Title</h1>
  <h2>Section Title</h2>
    <h3>Subsection</h3>
    <h3>Another Subsection</h3>
  <h2>Another Section</h2>

<%# ❌ BAD - Skipping levels %>
<h1>Main Title</h1>
  <h4>Skipped to h4</h4>  <%# Don't skip heading levels %>
```

**Why:** Screen readers use landmarks and headings to navigate. Proper structure allows users to jump directly to content sections.
</pattern>

<pattern name="skip-navigation">
<description>Provide skip links for keyboard users</description>

**Skip to Main Content:**
```erb
<%# app/views/layouts/application.html.erb %>
<body>
  <%# Skip link - hidden until focused %>
  <a href="#main-content"
     class="sr-only focus:not-sr-only focus:absolute focus:top-0 focus:left-0 focus:z-50 focus:p-4 focus:bg-blue-600 focus:text-white">
    Skip to main content
  </a>

  <header>
    <%# Navigation with many links %>
    <nav>
      <%= link_to "Home", root_path %>
      <%= link_to "About", about_path %>
      <%= link_to "Feedbacks", feedbacks_path %>
      <%# ... more links ... %>
    </nav>
  </header>

  <main id="main-content" tabindex="-1">
    <%= yield %>
  </main>
</body>
```

**Tailwind CSS for Skip Link:**
```css
/* Ensures skip link is visible when focused */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}

.focus\:not-sr-only:focus {
  position: static;
  width: auto;
  height: auto;
  padding: 1rem;
  margin: 0;
  overflow: visible;
  clip: auto;
  white-space: normal;
}
```

**Why:** Keyboard users can skip repetitive navigation and jump directly to main content.
</pattern>

## ARIA Attributes

<pattern name="aria-labels">
<description>Provide accessible names for elements without visible text</description>

**Icon-Only Buttons:**
```erb
<%# ✅ ACCESSIBLE - aria-label provides name %>
<button aria-label="Close modal" class="btn btn-ghost btn-sm">
  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
  </svg>
</button>

<%= button_to "Delete", feedback_path(@feedback),
              method: :delete,
              aria: { label: "Delete feedback from #{@feedback.sender_name}" },
              data: { turbo_confirm: "Are you sure?" },
              class: "btn btn-error btn-sm" %>

<%# ❌ BAD - No accessible name %>
<button class="btn">
  <%= icon("edit") %>  <%# Screen reader announces nothing useful %>
</button>
```

**aria-labelledby for Complex Labels:**
```erb
<%# References another element's ID %>
<div id="modal-title" class="text-lg font-bold">
  Feedback Details
</div>
<dialog aria-labelledby="modal-title" aria-modal="true">
  <%# Modal content %>
</dialog>
```

**aria-describedby for Additional Context:**
```erb
<%= form.text_field :email,
                    aria: { describedby: "email-hint" },
                    class: "input input-bordered" %>
<span id="email-hint" class="text-sm text-gray-600">
  We'll never share your email with anyone
</span>
```

**Why:** Screen readers need text alternatives for visual-only elements. ARIA provides accessible names and descriptions.
</pattern>

<pattern name="aria-live-regions">
<description>Announce dynamic content changes to screen readers</description>

**Status Messages:**
```erb
<%# app/views/layouts/application.html.erb %>
<div aria-live="polite"
     aria-atomic="true"
     class="fixed top-4 right-4 z-50">
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
```

**Loading States:**
```erb
<div data-controller="loading">
  <button data-action="loading#submit"
          data-loading-target="button"
          class="btn btn-primary">
    <span data-loading-target="text">Submit Feedback</span>
    <span data-loading-target="spinner"
          class="loading loading-spinner hidden"
          aria-hidden="true"></span>
  </button>

  <div role="status"
       aria-live="polite"
       data-loading-target="status"
       class="sr-only">
    <%# Announces to screen readers %>
  </div>
</div>
```

**Stimulus Controller:**
```javascript
// app/javascript/controllers/loading_controller.js
export default class extends Controller {
  static targets = ["button", "text", "spinner", "status"]

  submit() {
    this.buttonTarget.disabled = true
    this.textTarget.textContent = "Submitting..."
    this.spinnerTarget.classList.remove("hidden")
    this.statusTarget.textContent = "Submitting feedback, please wait..."
  }
}
```

**ARIA Live Values:**
- `aria-live="polite"` - Announces when screen reader is idle
- `aria-live="assertive"` - Interrupts current announcement (use sparingly)
- `aria-atomic="true"` - Reads entire region, not just changes

**Why:** Screen readers don't automatically detect dynamic content changes. ARIA live regions announce updates.
</pattern>

<pattern name="aria-current">
<description>Indicate the current item in navigation</description>

**Navigation with Current Page:**
```erb
<nav aria-label="Main navigation">
  <ul class="menu menu-horizontal">
    <li>
      <%= link_to "Home",
                  root_path,
                  aria: { current: current_page?(root_path) ? "page" : nil },
                  class: "#{current_page?(root_path) ? 'active' : ''}" %>
    </li>
    <li>
      <%= link_to "Feedbacks",
                  feedbacks_path,
                  aria: { current: current_page?(feedbacks_path) ? "page" : nil },
                  class: "#{current_page?(feedbacks_path) ? 'active' : ''}" %>
    </li>
  </ul>
</nav>
```

**Breadcrumbs:**
```erb
<nav aria-label="Breadcrumb">
  <ol class="breadcrumbs">
    <li><%= link_to "Home", root_path %></li>
    <li><%= link_to "Feedbacks", feedbacks_path %></li>
    <li aria-current="page">
      <span>Edit Feedback #<%= @feedback.id %></span>
    </li>
  </ol>
</nav>
```

**Why:** Screen readers announce the current location, helping users understand where they are in the application.
</pattern>

## Keyboard Navigation

<pattern name="keyboard-accessibility">
<description>Ensure all interactive elements are keyboard accessible</description>

**Native Buttons (Already Accessible):**
```erb
<%# ✅ ACCESSIBLE - Keyboard works by default %>
<button type="button"
        data-action="click->modal#open"
        class="btn btn-primary">
  Open Modal
</button>

<%= button_to "Delete",
              feedback_path(@feedback),
              method: :delete,
              class: "btn btn-error" %>
```

**Custom Interactive Elements:**
```erb
<%# Making a div act like a button %>
<div tabindex="0"
     role="button"
     data-action="click->controller#action keydown.enter->controller#action keydown.space->controller#action"
     class="custom-button">
  Custom Button
</div>
```

**Stimulus Controller for Keyboard Events:**
```javascript
// app/javascript/controllers/custom_button_controller.js
export default class extends Controller {
  action(event) {
    // Handle both click and keyboard activation
    if (event.type === "click" ||
        event.key === "Enter" ||
        event.key === " ") {
      event.preventDefault()
      // Perform action
      console.log("Button activated")
    }
  }
}
```

**Focus Indicators:**
```css
/* Ensure visible focus indicators */
button:focus,
a:focus,
input:focus,
select:focus,
textarea:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

/* Never remove focus indicators without providing alternative */
/* ❌ BAD */
*:focus {
  outline: none;
}
```

**Why:** Not all users can use a mouse. Keyboard accessibility is essential for many assistive technologies.
</pattern>

<pattern name="focus-management-modals">
<description>Trap and manage focus in modal dialogs</description>

**Accessible Modal:**
```erb
<dialog id="feedback-modal"
        class="modal"
        aria-labelledby="modal-title"
        aria-modal="true"
        data-controller="modal-focus">

  <div class="modal-box" role="document">
    <%# First focusable element %>
    <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2"
            aria-label="Close dialog"
            data-action="modal-focus#close"
            data-modal-focus-target="firstFocusable">
      ✕
    </button>

    <h3 id="modal-title" class="font-bold text-lg">
      Feedback Details
    </h3>

    <div class="py-4">
      <%= @feedback.content %>
    </div>

    <div class="modal-action">
      <button class="btn" data-action="modal-focus#close">
        Close
      </button>
      <button class="btn btn-primary"
              data-modal-focus-target="lastFocusable">
        Respond
      </button>
    </div>
  </div>
</dialog>
```

**Stimulus Controller:**
```javascript
// app/javascript/controllers/modal_focus_controller.js
export default class extends Controller {
  static targets = ["firstFocusable", "lastFocusable"]

  connect() {
    this.previousFocus = null
    this.boundTrapFocus = this.trapFocus.bind(this)
  }

  open() {
    // Save current focus
    this.previousFocus = document.activeElement

    // Show modal
    this.element.showModal()

    // Focus first element
    this.firstFocusableTarget.focus()

    // Trap focus
    this.element.addEventListener("keydown", this.boundTrapFocus)
  }

  close() {
    // Remove focus trap
    this.element.removeEventListener("keydown", this.boundTrapFocus)

    // Close modal
    this.element.close()

    // Return focus to trigger element
    this.previousFocus?.focus()
  }

  trapFocus(event) {
    if (event.key !== "Tab") return

    const focusableElements = this.element.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    const firstElement = focusableElements[0]
    const lastElement = focusableElements[focusableElements.length - 1]

    // Shift+Tab on first element -> focus last
    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault()
      lastElement.focus()
    }
    // Tab on last element -> focus first
    else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault()
      firstElement.focus()
    }
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.boundTrapFocus)
  }
}
```

**Why:** Modal dialogs must trap focus to prevent keyboard users from accidentally interacting with background content.
</pattern>

## Accessible Forms

<pattern name="form-labels">
<description>Associate labels with form inputs</description>

**Explicit Labels:**
```erb
<%= form_with model: @feedback, html: { class: "space-y-4" } do |form| %>
  <div class="form-control">
    <%# ✅ ACCESSIBLE - Explicit label association %>
    <%= form.label :content, "Your Feedback", class: "label" %>
    <%= form.text_area :content,
                       required: true,
                       aria: { required: "true", describedby: "content-hint" },
                       class: "textarea textarea-bordered" %>
    <span id="content-hint" class="label-text-alt">
      Minimum 10 characters required
    </span>
  </div>

  <%# Grouping related fields %>
  <fieldset class="border p-4 rounded">
    <legend class="text-lg font-semibold px-2">Sender Information</legend>

    <div class="form-control">
      <%= form.label :sender_name, "Name" %>
      <%= form.text_field :sender_name, class: "input input-bordered" %>
    </div>

    <div class="form-control">
      <%= form.label :sender_email, "Email" %>
      <%= form.email_field :sender_email,
                           autocomplete: "email",
                           class: "input input-bordered" %>
    </div>
  </fieldset>

  <%# Required field indicator %>
  <div class="form-control">
    <%= form.label :recipient_email do %>
      Recipient Email
      <abbr title="required" aria-label="required" class="text-error">*</abbr>
    <% end %>
    <%= form.email_field :recipient_email,
                         required: true,
                         aria: { required: "true" },
                         autocomplete: "email",
                         class: "input input-bordered" %>
  </div>

  <%= form.submit "Submit Feedback",
                  class: "btn btn-primary",
                  data: { disable_with: "Submitting..." } %>
<% end %>
```

**Why:** Labels provide accessible names for inputs and create larger click targets for mouse users.
</pattern>

<pattern name="form-errors">
<description>Display and announce form errors accessibly</description>

**Error Summary:**
```erb
<% if @feedback.errors.any? %>
  <div role="alert"
       class="alert alert-error mb-4"
       tabindex="-1"
       id="error-summary">
    <h2 class="font-bold">
      <%= pluralize(@feedback.errors.count, "error") %>
      prohibited this feedback from being saved:
    </h2>
    <ul class="list-disc list-inside">
      <% @feedback.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  </div>

  <%# Focus error summary after page load %>
  <script>
    document.addEventListener("DOMContentLoaded", () => {
      document.getElementById("error-summary")?.focus()
    })
  </script>
<% end %>
```

**Inline Field Errors:**
```erb
<div class="form-control">
  <%= form.label :content, "Feedback Content", class: "label" %>
  <%= form.text_area :content,
                     class: "textarea textarea-bordered #{@feedback.errors[:content].any? ? 'textarea-error' : ''}",
                     aria: {
                       describedby: @feedback.errors[:content].any? ? "content-error" : "content-hint",
                       invalid: @feedback.errors[:content].any? ? "true" : nil
                     } %>

  <% if @feedback.errors[:content].any? %>
    <span id="content-error"
          class="label-text-alt text-error"
          role="alert">
      <%= @feedback.errors[:content].first %>
    </span>
  <% else %>
    <span id="content-hint" class="label-text-alt">
      Share your thoughts (minimum 10 characters)
    </span>
  <% end %>
</div>
```

**Why:** Screen readers need to be notified of errors. `role="alert"` announces changes, and `aria-invalid` identifies problematic fields.
</pattern>

<pattern name="form-autocomplete">
<description>Use autocomplete attributes to help users fill forms</description>

**Autocomplete for Common Fields:**
```erb
<%= form_with model: @user do |form| %>
  <%= form.text_field :name,
                      autocomplete: "name" %>

  <%= form.email_field :email,
                       autocomplete: "email" %>

  <%= form.tel_field :phone,
                     autocomplete: "tel" %>

  <%= form.text_field :street_address,
                      autocomplete: "street-address" %>

  <%= form.text_field :city,
                      autocomplete: "address-level2" %>

  <%= form.text_field :postal_code,
                      autocomplete: "postal-code" %>

  <%= form.password_field :password,
                          autocomplete: "new-password" %>
<% end %>
```

**Why:** Autocomplete helps users with cognitive disabilities and makes forms faster for everyone. Password managers rely on these attributes.
</pattern>

## Buttons and Links

<pattern name="buttons-vs-links">
<description>Use buttons for actions, links for navigation</description>

**Correct Usage:**
```erb
<%# ✅ LINK - Navigates to a different page %>
<%= link_to "View Feedback Details", feedback_path(@feedback), class: "btn" %>

<%# ✅ BUTTON - Performs an action %>
<button type="button"
        data-action="modal#open"
        class="btn btn-primary">
  Open Modal
</button>

<%# ✅ BUTTON - Submits a form %>
<%= form.submit "Save Feedback", class: "btn btn-success" %>

<%# ✅ BUTTON - Destructive action %>
<%= button_to "Delete",
              feedback_path(@feedback),
              method: :delete,
              form: { data: { turbo_confirm: "Are you sure?" } },
              class: "btn btn-error" %>

<%# ❌ BAD - Link performing an action %>
<a href="#" onclick="deleteItem()">Delete</a>

<%# ❌ BAD - Button for navigation %>
<button onclick="window.location='/feedbacks'">View Feedbacks</button>
```

**Descriptive Link Text:**
```erb
<%# ❌ BAD - Generic text %>
<%= link_to "Click here", feedback_path(@feedback) %>
<%= link_to "Read more", article_path(@article) %>

<%# ✅ GOOD - Descriptive text %>
<%= link_to "View feedback details", feedback_path(@feedback) %>
<%= link_to "Read the full article: #{@article.title}", article_path(@article) %>

<%# ✅ GOOD - Context from surrounding text %>
<div class="card">
  <h3><%= @feedback.title %></h3>
  <p><%= @feedback.content.truncate(100) %></p>
  <%= link_to "Read more",
              feedback_path(@feedback),
              aria: { label: "Read more about #{@feedback.title}" } %>
</div>
```

**Why:** Screen readers can list all links or buttons on a page. "Click here" appears dozens of times with no context.
</pattern>

## Images and Media

<pattern name="image-alt-text">
<description>Provide meaningful alternative text for images</description>

**Informative Images:**
```erb
<%# ✅ GOOD - Describes the content %>
<%= image_tag "user-profile.jpg",
              alt: "Sarah Johnson's profile photo" %>

<%= image_tag "feedback-chart.png",
              alt: "Bar chart showing 85% positive feedback in March 2025",
              aria: { describedby: "chart-details" } %>
<div id="chart-details" class="sr-only">
  Detailed description: The chart displays monthly feedback ratings...
</div>
```

**Decorative Images:**
```erb
<%# ✅ GOOD - Empty alt for decorative images %>
<%= image_tag "decorative-pattern.svg",
              alt: "",
              role: "presentation" %>

<%# Background images are automatically decorative %>
<div class="hero" style="background-image: url('<%= asset_path('hero-bg.jpg') %>')">
  <h1>Welcome to Feedback App</h1>
</div>
```

**Functional Images (Links/Buttons):**
```erb
<%# ✅ GOOD - Describes the action %>
<%= link_to feedback_path(@feedback) do %>
  <%= image_tag "view-icon.svg", alt: "View feedback details" %>
<% end %>

<button aria-label="Close modal">
  <%= image_tag "close-icon.svg", alt: "", aria: { hidden: "true" } %>
</button>
```

**Complex Images:**
```erb
<%# Use longdesc or aria-describedby for complex diagrams %>
<%= image_tag "workflow-diagram.png",
              alt: "Feedback processing workflow",
              aria: { describedby: "workflow-description" } %>
<div id="workflow-description" class="sr-only">
  The workflow begins with user submission, proceeds through validation,
  then automated categorization, followed by assignment to a team member,
  and concludes with resolution and notification.
</div>
```

**Why:** Screen reader users rely on alt text to understand image content. Empty alt for decorative images prevents clutter.
</pattern>

<pattern name="video-captions">
<description>Provide captions and transcripts for video content</description>

**Accessible Video:**
```erb
<video controls class="w-full">
  <source src="<%= asset_path('tutorial.mp4') %>" type="video/mp4">
  <source src="<%= asset_path('tutorial.webm') %>" type="video/webm">

  <%# Captions for deaf/hard of hearing %>
  <track kind="captions"
         src="<%= asset_path('tutorial-captions-en.vtt') %>"
         srclang="en"
         label="English"
         default>

  <track kind="captions"
         src="<%= asset_path('tutorial-captions-es.vtt') %>"
         srclang="es"
         label="Spanish">

  <%# Descriptions for blind users %>
  <track kind="descriptions"
         src="<%= asset_path('tutorial-descriptions.vtt') %>"
         srclang="en"
         label="English descriptions">

  <p>
    Your browser doesn't support HTML5 video.
    <a href="<%= asset_path('tutorial.mp4') %>">Download the video</a> instead.
  </p>
</video>

<%# Transcript below video %>
<details class="mt-4">
  <summary class="font-semibold cursor-pointer">Video Transcript</summary>
  <div class="prose mt-2">
    <%= render "videos/tutorial_transcript" %>
  </div>
</details>
```

**Why:** Captions help deaf/hard of hearing users, descriptions help blind users, and transcripts help everyone (searchable, translatable).
</pattern>

## Tables

<pattern name="accessible-tables">
<description>Create accessible data tables with proper markup</description>

**Simple Data Table:**
```erb
<table class="table w-full">
  <caption class="text-lg font-semibold mb-2">
    Feedback Submissions - March 2025
  </caption>
  <thead>
    <tr>
      <th scope="col">Date</th>
      <th scope="col">Sender</th>
      <th scope="col">Content</th>
      <th scope="col">Status</th>
      <th scope="col">Actions</th>
    </tr>
  </thead>
  <tbody>
    <% @feedbacks.each do |feedback| %>
      <tr>
        <td><%= l(feedback.created_at, format: :short) %></td>
        <td><%= feedback.sender_name || "Anonymous" %></td>
        <td><%= feedback.content.truncate(50) %></td>
        <td>
          <span class="badge <%= status_badge_class(feedback.status) %>">
            <%= feedback.status.titleize %>
          </span>
        </td>
        <td>
          <%= link_to "View",
                      feedback_path(feedback),
                      aria: { label: "View feedback from #{feedback.sender_name || 'anonymous sender'}" },
                      class: "btn btn-sm btn-ghost" %>
          <%= link_to "Edit",
                      edit_feedback_path(feedback),
                      aria: { label: "Edit feedback from #{feedback.sender_name || 'anonymous sender'}" },
                      class: "btn btn-sm btn-ghost" %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>
```

**Complex Table with Row/Column Headers:**
```erb
<table class="table">
  <caption class="sr-only">Quarterly feedback statistics by category</caption>
  <thead>
    <tr>
      <th scope="col">Category</th>
      <th scope="col">Q1 2025</th>
      <th scope="col">Q2 2025</th>
      <th scope="col">Q3 2025</th>
      <th scope="col">Total</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Bug Reports</th>
      <td>45</td>
      <td>38</td>
      <td>29</td>
      <td>112</td>
    </tr>
    <tr>
      <th scope="row">Feature Requests</th>
      <td>23</td>
      <td>31</td>
      <td>42</td>
      <td>96</td>
    </tr>
  </tbody>
</table>
```

**Why:** Screen readers use `scope` attributes to associate data cells with headers, making complex tables understandable.
</pattern>

## Color and Contrast

<pattern name="color-contrast">
<description>Ensure sufficient color contrast for text readability</description>

**WCAG AA Requirements:**
- Normal text (< 18px): 4.5:1 contrast ratio
- Large text (≥ 18px or bold ≥ 14px): 3:1 contrast ratio
- UI components and graphics: 3:1 contrast ratio

**Accessible Color Combinations:**
```erb
<%# ✅ GOOD - High contrast %>
<div class="bg-gray-900 text-white p-4">
  Dark background with white text (21:1 ratio)
</div>

<div class="bg-white text-gray-900 p-4">
  White background with dark text (21:1 ratio)
</div>

<button class="bg-blue-600 text-white hover:bg-blue-700">
  Primary Button (4.5:1+ ratio)
</button>

<%# ❌ BAD - Insufficient contrast %>
<div class="bg-gray-100 text-gray-300 p-4">
  Low contrast - fails WCAG AA (1.7:1 ratio)
</div>

<button class="bg-yellow-200 text-yellow-400">
  Insufficient contrast (1.4:1 ratio)
</button>
```

**Don't Rely on Color Alone:**
```erb
<%# ❌ BAD - Color only %>
<span class="text-error">Required field</span>
<span class="text-success">Valid</span>

<%# ✅ GOOD - Color + icon/text/pattern %>
<span class="text-error">
  <svg class="inline w-4 h-4" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
  </svg>
  <span class="font-semibold">Error:</span> This field is required
</span>

<span class="text-success">
  <svg class="inline w-4 h-4" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
  </svg>
  <span class="font-semibold">Valid</span> email address
</span>
```

**Status Indicators:**
```erb
<div class="flex items-center gap-2">
  <span class="badge badge-success">
    <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
    </svg>
    Completed
  </span>
</div>
```

**Why:** Color-blind users (8% of men, 0.5% of women) cannot rely on color alone. Sufficient contrast helps users with low vision.
</pattern>

<antipatterns>
<antipattern>
<description>Using placeholder as label</description>
<reason>Placeholders disappear when typing and have insufficient contrast</reason>
<bad-example>
```erb
<%# ❌ BAD - No label, only placeholder %>
<input type="email"
       placeholder="Enter your email"
       class="input input-bordered">
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Label + optional placeholder %>
<label for="email" class="label">
  <span class="label-text">Email Address</span>
</label>
<input type="email"
       id="email"
       name="email"
       placeholder="you@example.com"
       class="input input-bordered">
```
</good-example>
</antipattern>

<antipattern>
<description>Removing focus indicators</description>
<reason>Keyboard users cannot see where they are on the page</reason>
<bad-example>
```css
/* ❌ BAD - Removes all focus indicators */
*:focus {
  outline: none;
}

button:focus {
  outline: 0;
}
```
</bad-example>
<good-example>
```css
/* ✅ GOOD - Provide visible focus indicators */
button:focus,
a:focus,
input:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

/* Or use focus-visible for mouse vs keyboard */
button:focus-visible {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}
```
</good-example>
</antipattern>

<antipattern>
<description>Using div/span for buttons</description>
<reason>No keyboard accessibility, wrong semantics for screen readers</reason>
<bad-example>
```erb
<%# ❌ BAD - Not keyboard accessible, wrong role %>
<div class="btn" onclick="submitForm()">
  Submit
</div>

<span class="link" onclick="navigate()">
  Click here
</span>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Use semantic elements %>
<button type="button"
        data-action="form#submit"
        class="btn">
  Submit
</button>

<%= link_to "View Details",
            feedback_path(@feedback),
            class: "link" %>

<%# Only if absolutely necessary, add full keyboard support %>
<div tabindex="0"
     role="button"
     data-action="click->form#submit keydown.enter->form#submit keydown.space->form#submit"
     class="btn">
  Custom Submit Button
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Inaccessible modals without focus trap</description>
<reason>Keyboard users can tab to background elements, losing context</reason>
<bad-example>
```erb
<%# ❌ BAD - No focus management %>
<div id="modal" class="modal">
  <div class="modal-content">
    <h2>Modal Title</h2>
    <button onclick="closeModal()">Close</button>
  </div>
</div>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Proper modal with focus trap %>
<dialog id="modal"
        aria-labelledby="modal-title"
        aria-modal="true"
        data-controller="modal-focus">
  <div class="modal-box">
    <button aria-label="Close"
            data-action="modal-focus#close"
            data-modal-focus-target="firstFocusable">
      ×
    </button>
    <h2 id="modal-title">Modal Title</h2>
    <%# Content %>
  </div>
</dialog>
```
</good-example>
</antipattern>

<antipattern>
<description>Auto-playing video or audio</description>
<reason>Disrupts screen reader users and violates WCAG</reason>
<bad-example>
```erb
<%# ❌ BAD - Auto-plays, no user control %>
<video autoplay>
  <source src="promo.mp4" type="video/mp4">
</video>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - User-controlled playback %>
<video controls>
  <source src="promo.mp4" type="video/mp4">
  <track kind="captions" src="captions.vtt" srclang="en" label="English">
</video>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test accessibility in system tests and with automated tools:

```ruby
# test/system/accessibility_test.rb
class AccessibilityTest < ApplicationSystemTestCase
  test "feedback form has accessible labels" do
    visit new_feedback_path

    # Check for label association
    assert_selector "label[for='feedback_content']"
    assert_selector "input#feedback_content"

    # Check for required attributes
    assert_selector "input[required][aria-required='true']"
  end

  test "keyboard navigation works" do
    visit feedbacks_path

    # Tab to first link
    page.execute_script("document.querySelector('a').focus()")
    focused_element = page.evaluate_script("document.activeElement.tagName")
    assert_equal "A", focused_element

    # Press Enter to activate
    page.send_keys(:enter)

    # Should navigate
    assert_current_path(/\/feedbacks\/\d+/)
  end

  test "modal traps focus" do
    visit feedbacks_path

    # Open modal
    click_button "View Details"
    assert_selector "dialog[open]"

    # First element should be focused
    focused = page.evaluate_script("document.activeElement.getAttribute('aria-label')")
    assert_equal "Close", focused

    # Tab through modal elements
    # (More complex test - ensure focus stays within modal)
  end

  test "error messages are announced" do
    visit new_feedback_path

    fill_in "Content", with: ""
    click_button "Submit"

    # Error should have alert role
    assert_selector "[role='alert']"
    assert_selector "[aria-invalid='true']"
  end

  test "images have alt text" do
    visit feedbacks_path

    # All images should have alt attribute
    images = page.all("img")
    images.each do |img|
      assert img[:alt].present?, "Image missing alt text: #{img[:src]}"
    end
  end
end

# Manual Testing Checklist:
# □ Test with keyboard only (unplug mouse)
# □ Test with screen reader (NVDA, JAWS, VoiceOver)
# □ Test with browser zoom (200%, 400%)
# □ Test with high contrast mode
# □ Run axe DevTools or Lighthouse accessibility audit
# □ Validate HTML (invalid HTML breaks accessibility)
```

**Automated Testing with axe-core:**
```ruby
# Gemfile
gem 'axe-core-rspec', group: :test

# test/system/axe_accessibility_test.rb
require 'axe/rspec'

class AxeAccessibilityTest < ApplicationSystemTestCase
  test "homepage is accessible" do
    visit root_path

    # Run axe accessibility audit
    expect(page).to be_axe_clean.according_to(:wcag2a, :wcag2aa)
  end

  test "feedback form is accessible" do
    visit new_feedback_path

    # Run audit with specific rules
    expect(page).to be_axe_clean
      .excluding('.third-party-widget')  # Exclude external widgets
      .according_to(:wcag2a, :wcag2aa)
  end
end
```
</testing>

<related-skills>
- forms-nested-comprehensive - Accessible nested form patterns
- hotwire-turbo-comprehensive - Accessible dynamic content updates
- viewcomponent-basics - Component-based accessible UI
- tailwind-daisyui-comprehensive - Accessible styling utilities
</related-skills>

<resources>
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Rails Accessibility Guide](https://guides.rubyonrails.org/accessibility.html)
- [WebAIM WCAG Checklist](https://webaim.org/standards/wcag/checklist)
- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [Color Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [axe DevTools Browser Extension](https://www.deque.com/axe/devtools/)
- [NVDA Screen Reader](https://www.nvaccess.org/) (Free, Windows)
- [HTML5 Accessibility](https://www.html5accessibility.com/)
</resources>
