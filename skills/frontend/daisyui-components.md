---
name: daisyui-components
domain: frontend
dependencies: [tailwind-utility-first]
version: 1.0
rails_version: 8.1+
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
<button class="btn btn-secondary">Secondary</button>
<button class="btn btn-accent">Accent</button>
<button class="btn btn-ghost">Ghost</button>
<button class="btn btn-link">Link Style</button>
```

**Button Sizes:**
```erb
<button class="btn btn-xs">Tiny</button>
<button class="btn btn-sm">Small</button>
<button class="btn btn-md">Normal</button>
<button class="btn btn-lg">Large</button>
```

**Button States:**
```erb
<%# Loading state %>
<button class="btn btn-primary">
  <span class="loading loading-spinner loading-sm"></span>
  Loading...
</button>

<%# Disabled state %>
<button class="btn btn-disabled">Disabled</button>

<%# Outline variant %>
<button class="btn btn-outline btn-primary">Outline</button>

<%# Full width %>
<button class="btn btn-block btn-primary">Full Width</button>

<%# Wide button %>
<button class="btn btn-wide">Wide Button</button>
```

**Button with Icons:**
```erb
<button class="btn btn-primary">
  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
  </svg>
  Add Feedback
</button>
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

**Card with Image:**
```erb
<div class="card bg-base-100 shadow-xl">
  <figure>
    <%= image_tag @feedback.image_url, alt: "Feedback image" %>
  </figure>
  <div class="card-body">
    <h2 class="card-title">
      <%= @feedback.title %>
      <div class="badge badge-secondary">New</div>
    </h2>
    <p><%= @feedback.content %></p>
    <div class="card-actions justify-end">
      <%= link_to "Read More", feedback_path(@feedback), class: "btn btn-primary" %>
    </div>
  </div>
</div>
```

**Card Variants:**
```erb
<%# Compact card (less padding) %>
<div class="card card-compact bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">Compact Card</h2>
    <p>Less padding for dense layouts</p>
  </div>
</div>

<%# Bordered card %>
<div class="card card-bordered">
  <div class="card-body">
    <p>Card with border instead of shadow</p>
  </div>
</div>

<%# Colored card %>
<div class="card bg-primary text-primary-content">
  <div class="card-body">
    <h2 class="card-title">Primary Card</h2>
    <p>Colored background with contrasting text</p>
  </div>
</div>

<%# Glass effect card %>
<div class="card glass">
  <div class="card-body">
    <h2 class="card-title">Glass Card</h2>
    <p>Frosted glass effect</p>
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

    <div class="divider"></div>

    <div class="flex items-center justify-between text-sm">
      <div class="flex items-center gap-2">
        <div class="avatar placeholder">
          <div class="bg-neutral text-neutral-content rounded-full w-8">
            <span class="text-xs"><%= @feedback.sender_name&.first %></span>
          </div>
        </div>
        <span><%= @feedback.sender_name || "Anonymous" %></span>
      </div>
      <span class="text-base-content/60">
        <%= time_ago_in_words(@feedback.created_at) %> ago
      </span>
    </div>

    <div class="card-actions justify-end mt-4">
      <%= link_to "View", feedback_path(@feedback), class: "btn btn-primary btn-sm" %>
      <%= link_to "Respond", respond_feedback_path(@feedback), class: "btn btn-ghost btn-sm" %>
    </div>
  </div>
</div>
```
</pattern>

## Forms

<pattern name="form-components">
<description>Use DaisyUI form controls for consistent form styling</description>

**Input Fields:**
```erb
<%# ✅ DaisyUI form controls %>
<div class="form-control">
  <label class="label">
    <span class="label-text">Email</span>
  </label>
  <input type="email" placeholder="email@example.com" class="input input-bordered" />
  <label class="label">
    <span class="label-text-alt">Required field</span>
  </label>
</div>

<%# Input variants %>
<input type="text" placeholder="Normal" class="input input-bordered" />
<input type="text" placeholder="Primary" class="input input-bordered input-primary" />
<input type="text" placeholder="Secondary" class="input input-bordered input-secondary" />
<input type="text" placeholder="Accent" class="input input-bordered input-accent" />

<%# Input sizes %>
<input type="text" placeholder="Extra Small" class="input input-bordered input-xs" />
<input type="text" placeholder="Small" class="input input-bordered input-sm" />
<input type="text" placeholder="Normal" class="input input-bordered input-md" />
<input type="text" placeholder="Large" class="input input-bordered input-lg" />
```

**Textarea:**
```erb
<div class="form-control">
  <label class="label">
    <span class="label-text">Feedback</span>
  </label>
  <textarea class="textarea textarea-bordered h-24" placeholder="Share your feedback..."></textarea>
  <label class="label">
    <span class="label-text-alt">Min 10 characters</span>
  </label>
</div>
```

**Select:**
```erb
<div class="form-control">
  <label class="label">
    <span class="label-text">Category</span>
  </label>
  <select class="select select-bordered">
    <option disabled selected>Pick category</option>
    <option>Bug Report</option>
    <option>Feature Request</option>
    <option>General Feedback</option>
  </select>
</div>
```

**Checkbox and Radio:**
```erb
<%# Checkbox %>
<div class="form-control">
  <label class="label cursor-pointer">
    <span class="label-text">Remember me</span>
    <input type="checkbox" class="checkbox checkbox-primary" />
  </label>
</div>

<%# Radio buttons %>
<div class="form-control">
  <label class="label cursor-pointer">
    <span class="label-text">Public</span>
    <input type="radio" name="visibility" class="radio radio-primary" checked />
  </label>
</div>
<div class="form-control">
  <label class="label cursor-pointer">
    <span class="label-text">Private</span>
    <input type="radio" name="visibility" class="radio radio-primary" />
  </label>
</div>
```

**Toggle and Range:**
```erb
<%# Toggle switch %>
<div class="form-control">
  <label class="label cursor-pointer">
    <span class="label-text">Enable notifications</span>
    <input type="checkbox" class="toggle toggle-primary" checked />
  </label>
</div>

<%# Range slider %>
<div class="form-control">
  <label class="label">
    <span class="label-text">Priority</span>
  </label>
  <input type="range" min="0" max="100" value="50" class="range range-primary" />
  <div class="w-full flex justify-between text-xs px-2">
    <span>Low</span>
    <span>Medium</span>
    <span>High</span>
  </div>
</div>
```

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

  <div class="form-control">
    <%= f.label :category, class: "label" do %>
      <span class="label-text">Category</span>
    <% end %>
    <%= f.select :category,
      options_for_select([["Bug", "bug"], ["Feature", "feature"], ["Other", "other"]]),
      {},
      class: "select select-bordered" %>
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
<div class="alert">
  <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
  </svg>
  <span>Info: New feedback available</span>
</div>

<div class="alert alert-success">
  <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
  </svg>
  <span>Success! Your feedback was submitted.</span>
</div>

<div class="alert alert-warning">
  <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
  </svg>
  <span>Warning: You have pending feedback.</span>
</div>

<div class="alert alert-error">
  <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/>
  </svg>
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

<% if flash[:alert] %>
  <div class="alert alert-error">
    <span><%= flash[:alert] %></span>
  </div>
<% end %>
```

**Badge Components:**
```erb
<%# ✅ DaisyUI badges %>
<div class="badge">Neutral</div>
<div class="badge badge-primary">Primary</div>
<div class="badge badge-secondary">Secondary</div>
<div class="badge badge-accent">Accent</div>
<div class="badge badge-ghost">Ghost</div>

<%# Status badges %>
<div class="badge badge-info">Info</div>
<div class="badge badge-success">Success</div>
<div class="badge badge-warning">Warning</div>
<div class="badge badge-error">Error</div>

<%# Badge sizes %>
<div class="badge badge-xs">Tiny</div>
<div class="badge badge-sm">Small</div>
<div class="badge badge-md">Normal</div>
<div class="badge badge-lg">Large</div>

<%# Badge variants %>
<div class="badge badge-outline">Outline</div>
<div class="badge badge-outline badge-primary">Primary Outline</div>
```

**Status Badge Helper:**
```ruby
# app/helpers/feedback_helper.rb
module FeedbackHelper
  def status_badge(status)
    badge_class = case status.to_s
    when "pending" then "badge-warning"
    when "in_progress" then "badge-info"
    when "resolved" then "badge-success"
    when "closed" then "badge-ghost"
    else "badge-neutral"
    end

    tag.div status.to_s.titleize, class: "badge #{badge_class}"
  end
end
```

**Usage:**
```erb
<h2 class="card-title">
  <%= @feedback.title %>
  <%= status_badge(@feedback.status) %>
</h2>
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

**Modal with Form:**
```erb
<button class="btn btn-primary" onclick="edit_modal.showModal()">
  Edit Feedback
</button>

<dialog id="edit_modal" class="modal">
  <div class="modal-box">
    <h3 class="font-bold text-lg mb-4">Edit Feedback</h3>

    <%= form_with model: @feedback, class: "space-y-4" do |f| %>
      <div class="form-control">
        <%= f.label :title, class: "label" do %>
          <span class="label-text">Title</span>
        <% end %>
        <%= f.text_field :title, class: "input input-bordered" %>
      </div>

      <div class="form-control">
        <%= f.label :content, class: "label" do %>
          <span class="label-text">Content</span>
        <% end %>
        <%= f.text_area :content, class: "textarea textarea-bordered h-24" %>
      </div>

      <div class="modal-action">
        <button type="button" onclick="edit_modal.close()" class="btn btn-ghost">
          Cancel
        </button>
        <%= f.submit "Save Changes", class: "btn btn-primary" %>
      </div>
    <% end %>
  </div>
</dialog>
```

**Confirmation Modal:**
```erb
<button class="btn btn-error" onclick="delete_modal.showModal()">
  Delete
</button>

<dialog id="delete_modal" class="modal">
  <div class="modal-box">
    <h3 class="font-bold text-lg">Confirm Deletion</h3>
    <p class="py-4">Are you sure you want to delete this feedback? This action cannot be undone.</p>
    <div class="modal-action">
      <form method="dialog">
        <button class="btn btn-ghost">Cancel</button>
      </form>
      <%= button_to "Delete", feedback_path(@feedback),
        method: :delete,
        class: "btn btn-error" %>
    </div>
  </div>
  <form method="dialog" class="modal-backdrop">
    <button>close</button>
  </form>
</dialog>
```

**Turbo Frame Modal:**
```erb
<%# List view %>
<%= link_to "Edit", edit_feedback_path(@feedback),
  class: "btn btn-primary",
  data: { turbo_frame: "modal" } %>

<%# Modal frame in layout %>
<turbo-frame id="modal" class="modal" target="_top">
  <%# Modal content loaded here %>
</turbo-frame>

<%# Edit view %>
<turbo-frame id="modal">
  <dialog class="modal modal-open">
    <div class="modal-box">
      <h3 class="font-bold text-lg">Edit Feedback</h3>
      <%= form_with model: @feedback do |f| %>
        <%# Form fields %>
      <% end %>
    </div>
  </dialog>
</turbo-frame>
```
</pattern>

## Navigation

<pattern name="navigation-components">
<description>Use navbar, menu, and dropdown components for navigation</description>

**Navbar:**
```erb
<%# ✅ DaisyUI navbar with responsive menu %>
<div class="navbar bg-base-100 shadow-lg">
  <div class="navbar-start">
    <div class="dropdown">
      <div tabindex="0" role="button" class="btn btn-ghost lg:hidden">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
        </svg>
      </div>
      <ul tabindex="0" class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52">
        <li><%= link_to "Feedbacks", feedbacks_path %></li>
        <li><%= link_to "Submit", new_feedback_path %></li>
        <li><%= link_to "Settings", settings_path %></li>
      </ul>
    </div>
    <%= link_to "Feedback App", root_path, class: "btn btn-ghost text-xl" %>
  </div>

  <div class="navbar-center hidden lg:flex">
    <ul class="menu menu-horizontal px-1">
      <li><%= link_to "Feedbacks", feedbacks_path %></li>
      <li><%= link_to "Submit", new_feedback_path %></li>
      <li><%= link_to "Settings", settings_path %></li>
    </ul>
  </div>

  <div class="navbar-end">
    <button class="btn btn-ghost btn-circle" onclick="theme_toggle.showModal()">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
      </svg>
    </button>
    <%= link_to "Sign In", new_session_path, class: "btn btn-primary" %>
  </div>
</div>
```

**Menu:**
```erb
<%# Sidebar menu %>
<ul class="menu bg-base-200 w-56 rounded-box">
  <li class="menu-title">Navigation</li>
  <li><a><%= icon("home") %> Home</a></li>
  <li><a><%= icon("feedback") %> Feedbacks</a></li>

  <li class="menu-title">Settings</li>
  <li><a><%= icon("user") %> Profile</a></li>
  <li><a><%= icon("settings") %> Preferences</a></li>

  <div class="divider"></div>

  <li><a class="text-error"><%= icon("logout") %> Sign Out</a></li>
</ul>
```

**Dropdown:**
```erb
<%# User menu dropdown %>
<div class="dropdown dropdown-end">
  <div tabindex="0" role="button" class="btn btn-ghost btn-circle avatar">
    <div class="w-10 rounded-full">
      <%= image_tag current_user.avatar_url, alt: current_user.name %>
    </div>
  </div>
  <ul tabindex="0" class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52">
    <li>
      <a class="justify-between">
        Profile
        <span class="badge">New</span>
      </a>
    </li>
    <li><a>Settings</a></li>
    <li><%= button_to "Logout", session_path, method: :delete %></li>
  </ul>
</div>
```
</pattern>

## Loading States

<pattern name="loading-components">
<description>Use loading component for async operations</description>

**Loading Spinners:**
```erb
<%# ✅ DaisyUI loading indicators %>
<span class="loading loading-spinner"></span>
<span class="loading loading-dots"></span>
<span class="loading loading-ring"></span>
<span class="loading loading-ball"></span>
<span class="loading loading-bars"></span>
<span class="loading loading-infinity"></span>

<%# Loading sizes %>
<span class="loading loading-spinner loading-xs"></span>
<span class="loading loading-spinner loading-sm"></span>
<span class="loading loading-spinner loading-md"></span>
<span class="loading loading-spinner loading-lg"></span>

<%# Loading colors %>
<span class="loading loading-spinner text-primary"></span>
<span class="loading loading-spinner text-secondary"></span>
<span class="loading loading-spinner text-accent"></span>
```

**Loading Button:**
```erb
<button class="btn btn-primary" disabled>
  <span class="loading loading-spinner loading-sm"></span>
  Submitting...
</button>
```

**Turbo Frame Loading:**
```erb
<%# Show loading state while Turbo Frame loads %>
<turbo-frame id="feedbacks" src="<%= feedbacks_path %>">
  <div class="flex justify-center items-center p-8">
    <span class="loading loading-spinner loading-lg"></span>
  </div>
</turbo-frame>
```

**Skeleton Loading:**
```erb
<%# Loading placeholder %>
<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <div class="skeleton h-4 w-28 mb-4"></div>
    <div class="skeleton h-4 w-full"></div>
    <div class="skeleton h-4 w-full"></div>
    <div class="skeleton h-4 w-2/3"></div>
  </div>
</div>
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

**Multi-Theme Selector:**
```erb
<div class="dropdown dropdown-end">
  <div tabindex="0" role="button" class="btn btn-ghost">
    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
      <path d="M4 3a2 2 0 100 4h12a2 2 0 100-4H4z"/>
    </svg>
    Theme
  </div>
  <ul tabindex="0" class="dropdown-content z-[1] p-2 shadow-2xl bg-base-300 rounded-box w-52">
    <li><button class="btn btn-sm btn-block btn-ghost justify-start" data-set-theme="light">Light</button></li>
    <li><button class="btn btn-sm btn-block btn-ghost justify-start" data-set-theme="dark">Dark</button></li>
    <li><button class="btn btn-sm btn-block btn-ghost justify-start" data-set-theme="cupcake">Cupcake</button></li>
    <li><button class="btn btn-sm btn-block btn-ghost justify-start" data-set-theme="cyberpunk">Cyberpunk</button></li>
  </ul>
</div>

<script>
  document.querySelectorAll('[data-set-theme]').forEach(button => {
    button.addEventListener('click', () => {
      const theme = button.getAttribute('data-set-theme')
      document.documentElement.setAttribute('data-theme', theme)
      localStorage.setItem('theme', theme)
    })
  })
</script>
```
</pattern>

<antipatterns>
<antipattern>
<description>Building custom buttons with Tailwind utilities instead of DaisyUI components</description>
<reason>Duplicates effort, inconsistent styling, loses accessibility features</reason>
<bad-example>
```erb
<%# ❌ Custom button with Tailwind utilities %>
<button class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500">
  Submit
</button>
```
</bad-example>
<good-example>
```erb
<%# ✅ DaisyUI button component %>
<button class="btn btn-primary">
  Submit
</button>
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
<html data-theme="light">  <%# or "dark" %>
<div class="bg-base-100 text-base-content">
  <button class="btn btn-primary">Button</button>
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Not using form-control wrapper for form fields</description>
<reason>Inconsistent spacing, label alignment issues, harder to maintain</reason>
<bad-example>
```erb
<%# ❌ Form without form-control wrapper %>
<label class="text-sm">Email</label>
<input type="email" class="input input-bordered w-full" />
<span class="text-xs text-gray-500">Required</span>
```
</bad-example>
<good-example>
```erb
<%# ✅ Proper form-control structure %>
<div class="form-control">
  <label class="label">
    <span class="label-text">Email</span>
  </label>
  <input type="email" class="input input-bordered" />
  <label class="label">
    <span class="label-text-alt">Required</span>
  </label>
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Using onclick with complex JavaScript instead of Stimulus controllers</description>
<reason>Inline JavaScript is hard to test, maintain, and reuse</reason>
<bad-example>
```erb
<%# ❌ Inline JavaScript for theme toggle %>
<button onclick="
  const html = document.querySelector('html');
  const theme = html.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
  html.setAttribute('data-theme', theme);
  localStorage.setItem('theme', theme);
">
  Toggle Theme
</button>
```
</bad-example>
<good-example>
```erb
<%# ✅ Stimulus controller %>
<div data-controller="theme">
  <button class="btn" data-action="click->theme#toggle">
    Toggle Theme
  </button>
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Mixing DaisyUI component classes with conflicting Tailwind utilities</description>
<reason>Can break component styling, override important defaults</reason>
<bad-example>
```erb
<%# ❌ Overriding DaisyUI component styles %>
<button class="btn btn-primary p-8 rounded-none bg-red-500">
  Button
</button>
```
</bad-example>
<good-example>
```erb
<%# ✅ Use DaisyUI variants or complementary utilities %>
<button class="btn btn-primary btn-lg">
  Button
</button>

<%# Or create custom variant if needed %>
<button class="btn btn-primary shadow-xl">
  Button with shadow
</button>
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

    # DaisyUI form controls
    fill_in "Title", with: "Great app"
    fill_in "Feedback", with: "Really enjoying the new features"
    select "Feature Request", from: "Category"

    # DaisyUI button
    click_button "Submit Feedback"

    # DaisyUI alert
    assert_selector ".alert.alert-success", text: "Feedback submitted"
  end

  test "theme toggle switches between light and dark" do
    visit root_path

    # Start with light theme
    assert_equal "light", page.evaluate_script("document.documentElement.getAttribute('data-theme')")

    # Click theme toggle (DaisyUI button)
    find("button[data-action='click->theme#toggle']").click

    # Verify dark theme applied
    assert_equal "dark", page.evaluate_script("document.documentElement.getAttribute('data-theme')")
  end

  test "modal opens and closes" do
    visit feedback_path(@feedback)

    # Modal initially closed
    assert_no_selector "dialog.modal-open"

    # Open modal with DaisyUI button
    click_button "Edit"

    # DaisyUI modal visible
    assert_selector "dialog.modal[open]"
    assert_selector ".modal-box", text: "Edit Feedback"

    # Close modal
    click_button "Close"

    assert_no_selector "dialog.modal[open]"
  end

  test "responsive navbar shows mobile menu" do
    visit root_path
    page.driver.resize_window(375, 667) # Mobile viewport

    # Mobile menu toggle visible
    assert_selector ".btn.btn-ghost.lg\\:hidden"

    # Desktop menu hidden
    assert_no_selector ".navbar-center.lg\\:flex", visible: :all
  end
end

# test/components/feedback_card_component_test.rb
class FeedbackCardComponentTest < ViewComponent::TestCase
  test "renders DaisyUI card with feedback" do
    feedback = feedbacks(:one)

    render_inline(FeedbackCardComponent.new(feedback: feedback))

    # DaisyUI card structure
    assert_selector ".card.bg-base-100.shadow-xl"
    assert_selector ".card-body"
    assert_selector ".card-title", text: feedback.title
    assert_selector ".badge", text: feedback.status.titleize

    # DaisyUI buttons
    assert_selector ".btn.btn-primary", text: "View"
    assert_selector ".btn.btn-ghost", text: "Respond"
  end
end
```
</testing>

<related-skills>
- tailwind-utility-first - Tailwind utility classes for custom styling
- hotwire-turbo - Turbo for dynamic content loading
- hotwire-stimulus - Stimulus for interactive components
- viewcomponent-basics - Building reusable components
</related-skills>

<resources>
- [DaisyUI v5 Documentation](https://daisyui.com/)
- [DaisyUI Components](https://daisyui.com/components/)
- [DaisyUI Themes](https://daisyui.com/docs/themes/)
- [Tailwind CSS v4 Documentation](https://tailwindcss.com/)
</resources>
