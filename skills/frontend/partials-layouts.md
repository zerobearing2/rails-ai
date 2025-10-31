---
name: partials-layouts
domain: frontend
dependencies: []
version: 1.0
rails_version: 8.1+
---

# Partials and Layouts

Partials are reusable view fragments that help keep your views DRY (Don't Repeat Yourself). Layouts define the overall page structure that wraps your views. Together they create maintainable, consistent UIs.

<when-to-use>
- Extracting repeated UI elements across multiple views
- Creating reusable components without ViewComponent complexity
- Building page structure with headers, footers, and navigation
- Rendering collections of similar items
- Organizing complex views into smaller, focused pieces
- Sharing form error messages, flash notifications, and empty states
- Using content_for to customize layouts per-page (titles, meta tags, scripts)
</when-to-use>

<benefits>
- **DRY Code** - Write once, use everywhere
- **Maintainability** - Update in one place, reflects everywhere
- **Consistency** - Ensures uniform UI patterns
- **Testability** - Test partials in isolation with ActionView::TestCase
- **Organization** - Break complex views into manageable chunks
- **Performance** - Easy to add fragment caching to partials
- **Flexibility** - Pass locals for customization without coupling to instance variables
</benefits>

<standards>
- Prefix partial filenames with underscore (_partial.html.erb)
- PREFER local variables over instance variables in partials
- Use explicit `locals:` for clarity in complex partials
- Keep shared partials in app/views/shared/
- Use `content_for` for layout customization (titles, scripts, meta tags)
- Use partials for simple reuse, ViewComponents for complex logic
- Test complex partials with ActionView::TestCase
- Add fragment caching to expensive partials
- Use collection rendering for lists (automatic, optimized)
- Always check for local variable presence with `local_assigns`
</standards>

## Basic Partials

<pattern name="simple-partial">
<description>Render a partial from the same or different directory</description>

```erb
<%# Same directory %>
<%= render "form" %>

<%# Shared directory %>
<%= render "shared/header" %>

<%# With locals (implicit) %>
<%= render "feedback", feedback: @feedback %>

<%# Explicit locals (clearer for multiple variables) %>
<%= render partial: "feedback", locals: { feedback: @feedback, show_actions: true } %>
```
</pattern>

<pattern name="collection-rendering">
<description>Efficiently render partials for collections</description>

```erb
<%# Shorthand - automatic partial lookup %>
<%= render @feedbacks %>

<%# Explicit collection %>
<%= render partial: "feedback", collection: @feedbacks %>

<%# Custom variable name %>
<%= render partial: "feedback", collection: @feedbacks, as: :item %>

<%# Partial definition with counters %>
<%# app/views/feedbacks/_feedback.html.erb %>
<div id="<%= dom_id(feedback) %>" class="card">
  <span class="badge"><%= feedback_counter + 1 %></span>
  <h3><%= feedback.content %></h3>

  <% if feedback_iteration.first? %>
    <span class="label">First</span>
  <% end %>
</div>
```

**Counter variables:**
- `feedback_counter` - 0-indexed (0, 1, 2...)
- `feedback_iteration` - methods: `first?`, `last?`, `index`, `size`
</pattern>

## Partials with Blocks

<pattern name="partial-with-yield">
<description>Create flexible partials that accept block content</description>

```erb
<%# app/views/shared/_card.html.erb %>
<div class="card <%= local_assigns[:variant] %>">
  <% if local_assigns[:title].present? %>
    <div class="card-header">
      <h3><%= title %></h3>
    </div>
  <% end %>
  <div class="card-body">
    <%= yield %>
  </div>
</div>

<%# Usage %>
<%= render "shared/card", title: "Feedback Details" do %>
  <p><%= @feedback.content %></p>
<% end %>
```
</pattern>

## Local Variables Best Practices

<pattern name="local-assigns">
<description>Prefer explicit local variables over instance variables</description>

```erb
<%# ✅ GOOD - Explicit dependencies %>
<%# app/views/feedbacks/_feedback.html.erb %>
<div class="feedback">
  <%= feedback.content %>
  <% if local_assigns[:current_user] %>
    <p>Viewing as: <%= current_user.name %></p>
  <% end %>
</div>

<%# Usage %>
<%= render "feedback", feedback: @feedback, current_user: current_user %>

<%# Optional locals with defaults %>
<div class="badge <%= local_assigns[:size] || 'badge-md' %>">
  <%= user.name %>
</div>
```

**Why use local_assigns?**
- Prevents `NameError` when variable not passed
- Allows optional parameters with defaults
- Makes partials reusable and testable
</pattern>

## Application Layouts

<pattern name="application-layout">
<description>Define main page structure with yield and content_for</description>

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
  <main>
    <%= render "shared/flash_messages" %>
    <%= yield %>
  </main>
  <%= yield :scripts %>
</body>
</html>
```
</pattern>

<pattern name="content-for">
<description>Customize layout sections from individual views</description>

```erb
<%# app/views/feedbacks/show.html.erb %>
<% content_for :title, "#{@feedback.content.truncate(60)} | App" %>

<% content_for :head do %>
  <meta name="description" content="<%= @feedback.content.truncate(160) %>">
<% end %>

<div class="feedback-detail">
  <h1><%= @feedback.content %></h1>
</div>

<% content_for :scripts do %>
  <%= javascript_tag do %>
    initFeedbackInteractions();
  <% end %>
<% end %>
```
</pattern>

## Shared Partials

<pattern name="shared-partials">
<description>Common partials used across the application</description>

```erb
<%# Form Errors - app/views/shared/_form_errors.html.erb %>
<% if object.errors.any? %>
  <div class="alert alert-error">
    <h3><%= pluralize(object.errors.count, "error") %> prohibited saving:</h3>
    <ul>
      <% object.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  </div>
<% end %>

<%# Flash Messages - app/views/shared/_flash_messages.html.erb %>
<% flash.each do |type, message| %>
  <div class="alert alert-<%= type %>" role="alert">
    <span><%= message %></span>
  </div>
<% end %>

<%# Empty State - app/views/shared/_empty_state.html.erb %>
<div class="empty-state">
  <h3><%= local_assigns[:title] || "No items found" %></h3>
  <p><%= local_assigns[:message] || "Get started by creating a new item" %></p>
  <% if local_assigns[:action_url] && local_assigns[:action_text] %>
    <%= link_to action_text, action_url, class: "btn btn-primary" %>
  <% end %>
</div>

<%# Usage %>
<%= render "shared/form_errors", object: @feedback %>
<%= render(@feedbacks) || render("shared/empty_state", title: "No feedback yet") %>
```
</pattern>

## Partials vs ViewComponents

<pattern name="when-to-use-partials">
<description>Choose between partials and ViewComponents based on complexity</description>

**Use Partials When:**
- Simple view extraction (headers, footers, forms)
- No complex logic or state management
- Rendering collections with minimal customization
- Quick prototyping

**Use ViewComponents When:**
- Complex rendering logic or state
- Need isolated unit testing
- Component variants and slots
- Performance-critical rendering
- Reusable component library

```erb
<%# Simple Partial - app/views/shared/_header.html.erb %>
<header class="navbar">
  <%= link_to "App Name", root_path, class: "btn" %>
  <% if user_signed_in? %>
    <%= link_to "Sign Out", sign_out_path %>
  <% end %>
</header>
```
</pattern>

<antipatterns>
<antipattern>
<description>Using instance variables in partials</description>
<reason>Creates implicit dependencies, makes partials hard to reuse and test</reason>
<bad-example>
```erb
<%# ❌ BAD - Coupled to controller %>
<div class="feedback">
  <%= @feedback.content %>
</div>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Explicit dependencies %>
<div class="feedback">
  <%= feedback.content %>
</div>
<%= render "feedback", feedback: @feedback %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not using collection rendering</description>
<reason>Slower, misses automatic optimizations</reason>
<bad-example>
```erb
<%# ❌ BAD - Manual iteration %>
<% @feedbacks.each do |feedback| %>
  <%= render partial: "feedback", locals: { feedback: feedback } %>
<% end %>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Collection rendering %>
<%= render @feedbacks %>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test partials with ActionView::TestCase:

```ruby
# test/views/feedbacks/_feedback_test.rb
require "test_helper"

class Feedbacks::FeedbackPartialTest < ActionView::TestCase
  test "renders feedback content" do
    feedback = feedbacks(:one)
    render partial: "feedbacks/feedback", locals: { feedback: feedback }

    assert_select "div.card"
    assert_select "h3", text: feedback.content
  end

  test "handles optional locals gracefully" do
    feedback = feedbacks(:one)
    render partial: "feedbacks/feedback", locals: { feedback: feedback }
    assert_select "div.card"
  end
end

# test/views/shared/_form_errors_test.rb
class Shared::FormErrorsPartialTest < ActionView::TestCase
  test "renders errors for invalid object" do
    feedback = Feedback.new
    feedback.valid?

    render partial: "shared/form_errors", locals: { object: feedback }
    assert_select "div.alert.alert-error"
    assert_select "ul li", count: feedback.errors.count
  end
end
```
</testing>

<related-skills>
- viewcomponent-basics - For complex reusable components
- hotwire-turbo - Turbo Frames use partials for updates
- tailwind-utility-first - Styling partials with Tailwind
- daisyui-components - Using DaisyUI in partials
- security-xss - Safe rendering in partials
</related-skills>

<resources>
- [Rails Guides - Layouts and Rendering](https://guides.rubyonrails.org/layouts_and_rendering.html)
- [Rails API - ActionView::PartialRenderer](https://api.rubyonrails.org/classes/ActionView/PartialRenderer.html)
- [Rails API - ActionView::Layouts](https://api.rubyonrails.org/classes/ActionView/Layouts.html)
- [Best Practices for Partials](https://evilmartians.com/chronicles/better-partials)
</resources>
