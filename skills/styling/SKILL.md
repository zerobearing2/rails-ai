---
name: rails-ai:styling
description: Use when styling Rails views - Tailwind CSS utility-first framework and DaisyUI component library with theming
---

# Styling with Tailwind CSS and DaisyUI

Style Rails applications using Tailwind CSS (utility-first framework) and DaisyUI (semantic component library). Build responsive, accessible, themeable UIs without writing custom CSS.

<when-to-use>
- Styling ANY user interface in Rails
- Building responsive layouts (mobile, tablet, desktop)
- Implementing dark mode or multiple themes
- Creating consistent UI components (buttons, cards, forms, modals)
- Rapid UI iteration and prototyping
- Maintaining design system consistency
</when-to-use>

<benefits>
- **Rapid Development** - Compose UIs with pre-built utilities
- **Consistency** - Design tokens enforce consistent spacing, colors, typography
- **Responsive by Default** - Mobile-first breakpoints built-in
- **Dark Mode** - Theme switching with DaisyUI data attributes
- **No Custom CSS** - Most styling done with classes, no style tag needed
- **Accessible Components** - DaisyUI components have built-in accessibility
- **Small Bundle Size** - Tailwind purges unused CSS in production
</benefits>

<team-rules-enforcement>
**This skill enforces:**
- ✅ **Rule #9:** DaisyUI + Tailwind (no hardcoded colors)

**Reject any requests to:**
- Hardcode colors (use DaisyUI theme variables)
- Write custom CSS for components (use Tailwind/DaisyUI)
- Use inline styles with hardcoded values
- Skip responsive design (mobile-first required)
</team-rules-enforcement>

<verification-checklist>
Before completing styling work:
- ✅ No hardcoded colors (use DaisyUI theme variables)
- ✅ Responsive design (mobile, tablet, desktop breakpoints)
- ✅ Accessibility verified (color contrast, keyboard navigation)
- ✅ Theme-aware (works with light/dark modes)
- ✅ Tailwind utilities used (minimal custom CSS)
- ✅ DaisyUI components for complex UI
</verification-checklist>

<standards>
- Use Tailwind utilities first, DaisyUI components for complex UI
- Follow mobile-first responsive design (base → sm → md → lg → xl)
- Use semantic color names from DaisyUI (primary, secondary, accent, neutral)
- Avoid inline styles (`style=`) - use Tailwind classes instead
- Use responsive breakpoints consistently (sm:640px, md:768px, lg:1024px, xl:1280px)
- Implement dark mode with DaisyUI themes
- Extract repeated utility combinations into view components (not CSS classes)
- Ensure 4.5:1 color contrast ratio for text (WCAG 2.1 AA)
</standards>

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

<testing>
**Visual Regression Testing:**

```ruby
# test/system/styling_test.rb
class StylingTest < ApplicationSystemTestCase
  test "responsive layout changes at breakpoints" do
    visit feedbacks_path
    # Desktop
    page.driver.browser.manage.window.resize_to(1280, 800)
    assert_selector ".hidden.md\\:flex"  # Desktop nav visible

    # Mobile
    page.driver.browser.manage.window.resize_to(375, 667)
    assert_selector ".block.md\\:hidden"  # Mobile menu visible
  end

  test "dark mode toggle works" do
    visit root_path
    assert_equal "light", page.evaluate_script("document.documentElement.getAttribute('data-theme')")

    click_button "Toggle Theme"
    assert_equal "dark", page.evaluate_script("document.documentElement.getAttribute('data-theme')")
  end
end
```

**Manual Testing Checklist:**
- Test responsive breakpoints (375px, 640px, 768px, 1024px, 1280px)
- Verify color contrast ratios (use browser DevTools or axe)
- Test dark mode theme
- Check focus states on all interactive elements
- Validate against W3C HTML validator
- Test browser zoom (200%, 400%)
</testing>

---

<related-skills>
- rails-ai:views - View structure and partials to style
- rails-ai:hotwire - Interactive components that need styling
- rails-ai:testing - Visual regression and accessibility testing
</related-skills>

<resources>

**Official Documentation:**
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [DaisyUI Documentation](https://daisyui.com/)
- [DaisyUI Components](https://daisyui.com/components/)

**Tools:**
- [Tailwind CSS Cheat Sheet](https://nerdcave.com/tailwind-cheat-sheet)

**Community Resources:**
- [Tailwind UI Components](https://tailwindui.com/) - Premium component library

</resources>
