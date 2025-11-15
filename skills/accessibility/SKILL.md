---
name: rails-ai:accessibility
description: Ensure your Rails application is usable by everyone, including people with disabilities who use assistive technologies like screen readers, keyboard navigation, and voice control. Supports Team Rule #13 (Progressive Enhancement).
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

```erb
<%# Semantic landmarks with proper hierarchy %>
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

<footer>
  <p>&copy; 2025 Feedback App</p>
</footer>

<%# Skip link - hidden until focused %>
<a href="#main-content" class="sr-only focus:not-sr-only">
  Skip to main content
</a>
```

**Why:** Screen readers use landmarks and headings to navigate. Use logical h1-h6 hierarchy (don't skip levels). Skip links let keyboard users bypass repetitive navigation.
</pattern>

## ARIA Attributes

<pattern name="aria-labels">
<description>Provide accessible names for elements without visible text</description>

```erb
<%# Icon-only button - aria-label provides name %>
<button aria-label="Close modal" class="btn btn-ghost btn-sm">
  <svg class="w-4 h-4">...</svg>
</button>

<%= button_to "Delete", feedback_path(@feedback),
              method: :delete,
              aria: { label: "Delete feedback from #{@feedback.sender_name}" },
              class: "btn btn-error btn-sm" %>

<%# aria-labelledby references another element %>
<dialog aria-labelledby="modal-title" aria-modal="true">
  <h3 id="modal-title">Feedback Details</h3>
</dialog>

<%# aria-describedby for hints %>
<%= form.text_field :email, aria: { describedby: "email-hint" } %>
<span id="email-hint">We'll never share your email</span>
```

**Why:** Screen readers need text alternatives for visual-only elements. Use aria-label for icon buttons, aria-labelledby for complex labels, aria-describedby for hints.
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

<%# Loading state announcement %>
<div role="status" aria-live="polite" class="sr-only" data-loading-target="status">
  <%# Updated via JS: "Submitting feedback, please wait..." %>
</div>
```

**Values:** `aria-live="polite"` (announces when idle), `aria-live="assertive"` (interrupts - use sparingly), `aria-atomic="true"` (reads entire region).

**Why:** Screen readers don't automatically detect dynamic content changes.
</pattern>

## Keyboard Navigation

<pattern name="keyboard-accessibility">
<description>Ensure all interactive elements are keyboard accessible</description>

```erb
<%# Use native elements - keyboard works by default %>
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

/* NEVER remove without alternative */
*:focus { outline: none; } /* ❌ BAD */
```

**Key Events:** Enter and Space must activate buttons. Tab navigates between elements. Escape closes modals.

**Why:** Many users rely on keyboard navigation. All functionality must be keyboard accessible.
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

**Why:** Modal dialogs must trap focus to prevent keyboard users from tabbing to background content. Always return focus to the trigger element on close.
</pattern>

## Accessible Forms

<pattern name="form-labels">
<description>Associate labels with form inputs</description>

```erb
<%= form_with model: @feedback do |form| %>
  <div class="form-control">
    <%= form.label :content, "Your Feedback" %>
    <%= form.text_area :content, required: true,
                       aria: { required: "true", describedby: "content-hint" } %>
    <span id="content-hint">Minimum 10 characters required</span>
  </div>

  <%# Group related fields %>
  <fieldset>
    <legend>Sender Information</legend>
    <%= form.label :sender_name, "Name" %>
    <%= form.text_field :sender_name %>
    <%= form.label :sender_email, "Email" %>
    <%= form.email_field :sender_email, autocomplete: "email" %>
  </fieldset>

  <%# Required field indicator %>
  <%= form.label :recipient_email do %>
    Email <abbr title="required" aria-label="required">*</abbr>
  <% end %>
  <%= form.email_field :recipient_email, required: true, autocomplete: "email" %>

  <%= form.submit "Submit", data: { disable_with: "Submitting..." } %>
<% end %>
```

**Why:** Labels provide accessible names and larger click targets. Never use placeholder as label.
</pattern>

<pattern name="form-errors">
<description>Display and announce form errors accessibly</description>

```erb
<% if @feedback.errors.any? %>
  <div role="alert" id="error-summary" tabindex="-1">
    <h2><%= pluralize(@feedback.errors.count, "error") %> prohibited saving:</h2>
    <ul>
      <% @feedback.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
    </ul>
  </div>
  <script>
    document.addEventListener("DOMContentLoaded", () => {
      document.getElementById("error-summary")?.focus()
    })
  </script>
<% end %>

<%# Inline field error %>
<%= form.text_area :content,
                   class: "#{@feedback.errors[:content].any? ? 'error' : ''}",
                   aria: {
                     describedby: @feedback.errors[:content].any? ? "content-error" : "content-hint",
                     invalid: @feedback.errors[:content].any? ? "true" : nil
                   } %>
<% if @feedback.errors[:content].any? %>
  <span id="content-error" role="alert">
    <%= @feedback.errors[:content].first %>
  </span>
<% end %>
```

**Why:** `role="alert"` announces errors. `aria-invalid` marks problematic fields. Focus error summary on page load.
</pattern>

## Buttons and Links

<pattern name="buttons-vs-links">
<description>Use buttons for actions, links for navigation</description>

```erb
<%# Links navigate to different pages %>
<%= link_to "View Feedback Details", feedback_path(@feedback) %>

<%# Buttons perform actions %>
<button type="button" data-action="modal#open">Open Modal</button>
<%= form.submit "Save Feedback" %>
<%= button_to "Delete", feedback_path(@feedback), method: :delete %>

<%# ❌ BAD - Don't use links for actions or buttons for navigation %>
<a href="#" onclick="deleteItem()">Delete</a>
<button onclick="window.location='/feedbacks'">View</button>

<%# Descriptive link text - avoid "click here" or "read more" %>
<%= link_to "View feedback details", feedback_path(@feedback) %>
<%= link_to "Read more", feedback_path(@feedback),
            aria: { label: "Read more about #{@feedback.title}" } %>
```

**Why:** Screen readers list all links/buttons. "Click here" provides no context. Use semantic elements for proper keyboard and screen reader behavior.
</pattern>

## Images and Media

<pattern name="image-alt-text">
<description>Provide meaningful alternative text for images</description>

```erb
<%# Informative images - describe the content %>
<%= image_tag "user-profile.jpg", alt: "Sarah Johnson's profile photo" %>
<%= image_tag "chart.png", alt: "Bar chart: 85% positive feedback in March 2025" %>

<%# Decorative images - empty alt %>
<%= image_tag "decoration.svg", alt: "", role: "presentation" %>

<%# Functional images - describe the action %>
<%= link_to feedback_path(@feedback) do %>
  <%= image_tag "view-icon.svg", alt: "View feedback details" %>
<% end %>

<button aria-label="Close modal">
  <%= image_tag "close.svg", alt: "", aria: { hidden: "true" } %>
</button>
```

**Why:** Screen readers rely on alt text. Informative images need descriptions, decorative images need empty alt to avoid clutter.
</pattern>

## Color and Contrast

<pattern name="color-contrast">
<description>Ensure sufficient color contrast for text readability</description>

**WCAG AA Requirements:**
- Normal text (< 18px): 4.5:1 ratio minimum
- Large text (≥ 18px or bold ≥ 14px): 3:1 ratio minimum
- UI components: 3:1 ratio minimum

```erb
<%# ✅ GOOD - High contrast %>
<div class="bg-gray-900 text-white">Dark bg with white text (21:1)</div>
<button class="bg-blue-600 text-white">Primary (4.5:1+)</button>

<%# ❌ BAD - Insufficient contrast %>
<div class="bg-gray-100 text-gray-300">Fails WCAG AA (1.7:1)</div>

<%# Don't rely on color alone - add icons/text/patterns %>
<%# ❌ BAD - Color only %>
<span class="text-error">Required</span>

<%# ✅ GOOD - Color + icon + text %>
<span class="text-error">
  <svg aria-hidden="true">...</svg>
  <strong>Error:</strong> This field is required
</span>
```

**Why:** Color-blind users (8% of men) cannot rely on color alone. Sufficient contrast helps low vision users. Test with [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/).
</pattern>

<antipatterns>
<antipattern>
<description>Using placeholder as label</description>
<reason>Placeholders disappear when typing and have insufficient contrast</reason>
<bad-example>
```erb
<input type="email" placeholder="Enter your email">  <%# ❌ No label %>
```
</bad-example>
<good-example>
```erb
<label for="email">Email Address</label>
<input type="email" id="email" placeholder="you@example.com">  <%# ✅ Label + placeholder %>
```
</good-example>
</antipattern>

<antipattern>
<description>Removing focus indicators</description>
<reason>Keyboard users cannot see where they are on the page</reason>
<bad-example>
```css
*:focus { outline: none; }  /* ❌ Removes all focus indicators */
```
</bad-example>
<good-example>
```css
button:focus, a:focus, input:focus {
  outline: 2px solid #3b82f6;  /* ✅ Visible focus */
  outline-offset: 2px;
}
```
</good-example>
</antipattern>

<antipattern>
<description>Using div/span for buttons</description>
<reason>No keyboard accessibility, wrong semantics</reason>
<bad-example>
```erb
<div onclick="submit()">Submit</div>  <%# ❌ Not keyboard accessible %>
```
</bad-example>
<good-example>
```erb
<button type="button" data-action="form#submit">Submit</button>  <%# ✅ Semantic %>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
**System Tests:**
```ruby
# test/system/accessibility_test.rb
class AccessibilityTest < ApplicationSystemTestCase
  test "form has accessible labels" do
    visit new_feedback_path
    assert_selector "label[for='feedback_content']"
    assert_selector "input#feedback_content[required][aria-required='true']"
  end

  test "errors are announced" do
    visit new_feedback_path
    click_button "Submit"
    assert_selector "[role='alert']"
    assert_selector "[aria-invalid='true']"
  end
end
```

**Manual Testing Checklist:**
- Test with keyboard only (Tab, Enter, Space, Escape)
- Test with screen reader (NVDA, JAWS, VoiceOver)
- Test browser zoom (200%, 400%)
- Run axe DevTools or Lighthouse audit
- Validate HTML (W3C validator)
</testing>

<related-skills>
- rails-ai:forms-nested: Accessible nested form patterns
- rails-ai:hotwire-turbo: Accessible dynamic content updates
- rails-ai:tailwind: Accessible utility first styling
- rails-ai:daisyui: Accessible component library
</related-skills>

<resources>
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Rails Accessibility Guide](https://guides.rubyonrails.org/accessibility.html)
- [WebAIM WCAG Checklist](https://webaim.org/standards/wcag/checklist)
- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [Color Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [axe DevTools Browser Extension](https://www.deque.com/axe/devtools/)
</resources>
