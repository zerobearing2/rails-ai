---
name: rails-ai:daisyui
description: Semantic component library built on TailwindCSS providing 70+ accessible components with built-in theming and dark mode support.
---

# DaisyUI Components

Semantic component library built on TailwindCSS providing 70+ accessible components with built-in theming and dark mode support.

<when-to-use>
- Building UI components quickly without custom CSS
- Need consistent design system across application
- Implementing forms, buttons, cards, modals, alerts
- Adding dark mode support with themes
- Creating responsive layouts with pre-built components
- Need accessible components by default (ARIA attributes)
- Building admin panels, dashboards, or content-heavy UIs
</when-to-use>

<benefits>
- **Rapid Development** - Pre-built semantic components (btn, card, modal)
- **Built-in Theming** - 32 themes including light/dark modes
- **Accessible by Default** - ARIA attributes and keyboard navigation
- **No Custom CSS** - Combine with Tailwind utilities for customization
- **Mobile-First** - Responsive components work across all devices
- **Small Bundle** - Only includes components you use
- **Consistent Design** - Unified design language across application
</benefits>

<standards>
- Use DaisyUI semantic components over custom Tailwind combinations
- Combine DaisyUI components with Tailwind utilities for customization
- Use `data-theme` attribute for theme switching (not manual classes)
- Follow mobile-first approach with responsive modifiers
- Leverage component variants (btn-primary, card-compact) over custom classes
- Use form-control wrapper for consistent form layouts
- Test components in both light and dark themes
- Keep DaisyUI for components, Tailwind for layout/spacing
</standards>

## Setup

<pattern name="daisyui-installation">
<description>Install and configure DaisyUI v5 with Tailwind v4</description>

**Installation:**
```bash
npm install -D daisyui@latest
```

**Tailwind Configuration:**
```css
/* app/assets/stylesheets/application.css */
@import "tailwindcss";
@plugin "daisyui";

/* Optional: Custom theme configuration */
@config "./tailwind.config.js";
```

**Theme Configuration:**
```javascript
// tailwind.config.js
export default {
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["light", "dark", "cupcake", "cyberpunk"], // Choose themes
    darkTheme: "dark", // Default dark theme
    base: true, // Apply base styles
    styled: true, // Include component styles
    utils: true, // Add utility classes
  },
}
```

**Layout with Theme Support:**
```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html data-theme="light">
  <head>
    <title>My App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```
</pattern>

## Buttons

<pattern name="button-components">
<description>Use DaisyUI button classes for consistent interactive elements</description>

**Basic Buttons:**
```erb
<%# ✅ DaisyUI button components %>
<button class="btn">Normal</button>
<button class="btn btn-primary">Primary Action</button>
<button class="btn btn-ghost">Ghost</button>
<button class="btn btn-outline btn-primary">Outline</button>
```

**Rails Form Integration:**
```erb
<%= form_with model: @feedback do |f| %>
  <%= f.text_field :content, class: "input input-bordered" %>
  <%= f.submit "Submit", class: "btn btn-primary" %>
  <%= link_to "Cancel", feedbacks_path, class: "btn btn-ghost" %>
<% end %>
```
</pattern>

## Cards

<pattern name="card-components">
<description>Use card component for content containers</description>

**Basic Card:**
```erb
<%# ✅ DaisyUI card with consistent structure %>
<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">Feedback Title</h2>
    <p>Feedback content goes here...</p>
    <div class="card-actions justify-end">
      <button class="btn btn-primary">View Details</button>
    </div>
  </div>
</div>
```

**Feedback Card Example:**
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

## Forms

<pattern name="form-components">
<description>Use DaisyUI form controls for consistent form styling</description>

**Complete Form Example:**
```erb
<%= form_with model: @feedback, class: "space-y-4" do |f| %>
  <div class="form-control">
    <%= f.label :title, class: "label" do %>
      <span class="label-text">Title</span>
    <% end %>
    <%= f.text_field :title, class: "input input-bordered", placeholder: "Brief description" %>
  </div>

  <div class="form-control">
    <%= f.label :content, class: "label" do %>
      <span class="label-text">Feedback</span>
    <% end %>
    <%= f.text_area :content, class: "textarea textarea-bordered h-24", placeholder: "Detailed feedback..." %>
  </div>

  <div class="flex gap-2 justify-end">
    <%= link_to "Cancel", feedbacks_path, class: "btn btn-ghost" %>
    <%= f.submit "Submit Feedback", class: "btn btn-primary" %>
  </div>
<% end %>
```
</pattern>

## Alerts and Badges

<pattern name="alert-badge-components">
<description>Use alerts for notifications and badges for status indicators</description>

**Alert Components:**
```erb
<%# ✅ DaisyUI alerts %>
<div class="alert alert-success">
  <span>Success! Your feedback was submitted.</span>
</div>

<div class="alert alert-error">
  <span>Error! Unable to submit feedback.</span>
</div>
```

**Flash Messages:**
```erb
<%# app/views/layouts/application.html.erb %>
<% if flash[:notice] %>
  <div class="alert alert-success">
    <span><%= flash[:notice] %></span>
  </div>
<% end %>
```

**Badge Components:**
```erb
<%# ✅ DaisyUI badges %>
<div class="badge badge-primary">Primary</div>
<div class="badge badge-success">Success</div>
<div class="badge badge-warning">Warning</div>
<div class="badge badge-error">Error</div>
```
</pattern>

## Modals

<pattern name="modal-components">
<description>Use modal component for dialogs and overlays</description>

**Basic Modal:**
```erb
<%# ✅ DaisyUI modal with native dialog %>
<button class="btn btn-primary" onclick="feedback_modal.showModal()">
  View Details
</button>

<dialog id="feedback_modal" class="modal">
  <div class="modal-box">
    <h3 class="font-bold text-lg">Feedback Details</h3>
    <p class="py-4">Modal content goes here...</p>
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

## Theme Switching

<pattern name="theme-management">
<description>Implement dark mode and theme switching with DaisyUI</description>

**Theme Toggle Helper:**
```javascript
// app/javascript/controllers/theme_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { default: { type: String, default: "light" } }

  connect() {
    const savedTheme = localStorage.getItem("theme") || this.defaultValue
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

**Theme Toggle Button:**
```erb
<div data-controller="theme">
  <button class="btn btn-ghost btn-circle" data-action="click->theme#toggle">
    <svg class="swap-on fill-current w-5 h-5" viewBox="0 0 24 24">
      <path d="M21.64,13a1,1,0,0,0-1.05-.14,8.05,8.05,0,0,1-3.37.73A8.15,8.15,0,0,1,9.08,5.49a8.59,8.59,0,0,1,.25-2A1,1,0,0,0,8,2.36,10.14,10.14,0,1,0,22,14.05,1,1,0,0,0,21.64,13Zm-9.5,6.69A8.14,8.14,0,0,1,7.08,5.22v.27A10.15,10.15,0,0,0,17.22,15.63a9.79,9.79,0,0,0,2.1-.22A8.11,8.11,0,0,1,12.14,19.73Z"/>
    </svg>
  </button>
</div>
```
</pattern>

<antipatterns>
<antipattern>
<description>Building custom buttons with Tailwind utilities instead of DaisyUI components</description>
<reason>Duplicates effort, inconsistent styling, loses accessibility features</reason>
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

<antipattern>
<description>Manually managing theme classes instead of data-theme attribute</description>
<reason>Error-prone, verbose, doesn't leverage DaisyUI theming system</reason>
<bad-example>
```erb
<%# ❌ Manual dark mode classes %>
<div class="bg-white dark:bg-gray-900 text-black dark:text-white">
  <button class="bg-blue-500 dark:bg-blue-700">Button</button>
</div>
```
</bad-example>
<good-example>
```erb
<%# ✅ DaisyUI theme system %>
<html data-theme="light">
<div class="bg-base-100 text-base-content">
  <button class="btn btn-primary">Button</button>
</div>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test DaisyUI components in system tests:

```ruby
# test/system/feedback_form_test.rb
class FeedbackFormTest < ApplicationSystemTestCase
  test "submit feedback with DaisyUI form" do
    visit new_feedback_path
    fill_in "Title", with: "Great app"
    fill_in "Feedback", with: "Really enjoying the new features"
    click_button "Submit Feedback"
    assert_selector ".alert.alert-success", text: "Feedback submitted"
  end

  test "theme toggle switches between light and dark" do
    visit root_path
    assert_equal "light", page.evaluate_script("document.documentElement.getAttribute('data-theme')")
    find("button[data-action='click->theme#toggle']").click
    assert_equal "dark", page.evaluate_script("document.documentElement.getAttribute('data-theme')")
  end
end
```
</testing>

<related-skills>
- rails-ai:tailwind - Tailwind utility classes for custom styling
- rails-ai:hotwire-turbo - Turbo for dynamic content loading
- rails-ai:hotwire-stimulus - Stimulus for interactive components
</related-skills>

<resources>
- [DaisyUI v5 Documentation](https://daisyui.com/)
- [DaisyUI Components](https://daisyui.com/components/)
- [DaisyUI Themes](https://daisyui.com/docs/themes/)
- [Tailwind CSS v4 Documentation](https://tailwindcss.com/)
</resources>
