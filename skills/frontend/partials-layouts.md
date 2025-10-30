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

**From Same Directory:**
```erb
<%# app/views/feedbacks/index.html.erb %>
<%= render "form" %>
<%# Looks for app/views/feedbacks/_form.html.erb %>
```

**From Shared Directory:**
```erb
<%= render "shared/header" %>
<%# Looks for app/views/shared/_header.html.erb %>
```

**With Local Variables:**
```erb
<%= render "feedback", feedback: @feedback %>
<%# Implicit: partial name matches local variable name %>
```

**Explicit Locals:**
```erb
<%= render partial: "feedback", locals: { feedback: @feedback, show_actions: true } %>
<%# Clearer when passing multiple locals %>
```
</pattern>

<pattern name="collection-rendering">
<description>Efficiently render partials for collections</description>

**Collection Shorthand:**
```erb
<%# Most concise - automatic partial lookup %>
<%= render @feedbacks %>
<%# Looks for app/views/feedbacks/_feedback.html.erb %>
<%# Creates local variable 'feedback' for each item %>
```

**Explicit Collection:**
```erb
<%= render partial: "feedback", collection: @feedbacks %>
```

**Custom Variable Name:**
```erb
<%= render partial: "feedback", collection: @feedbacks, as: :item %>
<%# Creates 'item' instead of 'feedback' in the partial %>
```

**With Spacer Template:**
```erb
<%= render partial: "feedback",
           collection: @feedbacks,
           spacer_template: "separator" %>
<%# Renders app/views/feedbacks/_separator.html.erb between items %>
```

**Partial Definition:**
```erb
<%# app/views/feedbacks/_feedback.html.erb %>
<div id="<%= dom_id(feedback) %>" class="card">
  <div class="card-body">
    <h3 class="card-title"><%= feedback.content %></h3>
    <p class="text-sm text-muted">
      Submitted <%= time_ago_in_words(feedback.created_at) %> ago
    </p>

    <div class="card-actions">
      <%= link_to "View", feedback_path(feedback), class: "btn btn-primary" %>
      <%= link_to "Edit", edit_feedback_path(feedback), class: "btn btn-ghost" %>
    </div>
  </div>
</div>
```
</pattern>

<pattern name="collection-counters">
<description>Use automatic counter and iteration variables in collection partials</description>

**Partial with Counters:**
```erb
<%# app/views/feedbacks/_feedback.html.erb %>
<div class="feedback" data-index="<%= feedback_counter %>">
  <span class="badge"><%= feedback_counter + 1 %></span>
  <%= feedback.content %>

  <% if feedback_iteration.first? %>
    <span class="label label-primary">First</span>
  <% end %>

  <% if feedback_iteration.last? %>
    <span class="label label-secondary">Last</span>
  <% end %>

  <p class="text-muted">
    Item <%= feedback_iteration.index + 1 %> of <%= feedback_iteration.size %>
  </p>
</div>
```

**Available Variables:**
- `feedback_counter` - 0-indexed counter (0, 1, 2, ...)
- `feedback_iteration` - Iteration object with methods:
  - `first?` - true for first item
  - `last?` - true for last item
  - `index` - 0-indexed position
  - `size` - total collection size
</pattern>

## Partials with Blocks

<pattern name="partial-with-yield">
<description>Create flexible partials that accept block content</description>

**Partial Definition:**
```erb
<%# app/views/shared/_card.html.erb %>
<div class="card <%= local_assigns[:variant] %>">
  <% if local_assigns[:title].present? %>
    <div class="card-header">
      <h3 class="card-title"><%= title %></h3>
    </div>
  <% end %>

  <div class="card-body">
    <%= yield %>
  </div>
</div>
```

**Usage:**
```erb
<%= render "shared/card", title: "Feedback Details", variant: "bg-base-200" do %>
  <p><%= @feedback.content %></p>
  <p class="text-muted">
    Submitted by <%= @feedback.sender_name || "Anonymous" %>
  </p>
<% end %>
```
</pattern>

<pattern name="partial-multiple-content-areas">
<description>Create partials with multiple named yield blocks</description>

**Partial with Named Yields:**
```erb
<%# app/views/shared/_panel.html.erb %>
<div class="panel">
  <div class="panel-header">
    <%= yield :header %>
  </div>

  <div class="panel-body">
    <%= yield %>
  </div>

  <% if content_for?(:footer) %>
    <div class="panel-footer">
      <%= yield :footer %>
    </div>
  <% end %>
</div>
```

**Usage:**
```erb
<%= render "shared/panel" do %>
  <% content_for :header do %>
    <h2>Feedback List</h2>
    <p class="text-muted">Recent submissions</p>
  <% end %>

  <%= render @feedbacks %>

  <% content_for :footer do %>
    <%= link_to "View All", feedbacks_path, class: "btn btn-primary" %>
  <% end %>
<% end %>
```
</pattern>

## Local Variables Best Practices

<pattern name="local-assigns">
<description>Safely check for optional local variables</description>

**Check Variable Presence:**
```erb
<%# app/views/shared/_user_badge.html.erb %>
<div class="badge <%= local_assigns[:size] || 'badge-md' %>">
  <%= user.name %>

  <% if local_assigns[:show_email] %>
    <span class="text-muted"><%= user.email %></span>
  <% end %>

  <% if local_assigns[:badge_color].present? %>
    <span class="badge-color" style="background: <%= badge_color %>"></span>
  <% end %>
</div>
```

**Usage:**
```erb
<%# With some locals %>
<%= render "shared/user_badge", user: current_user, show_email: true %>

<%# With different locals %>
<%= render "shared/user_badge", user: current_user, size: "badge-lg", badge_color: "#ff0000" %>
```

**Why local_assigns?**
- Prevents `NameError` when variable not passed
- Allows optional parameters with defaults
- Makes partial interface clear and flexible
</pattern>

<pattern name="locals-vs-instance-variables">
<description>Prefer explicit local variables over implicit instance variables</description>

**BAD - Instance Variables:**
```erb
<%# ❌ Couples partial to controller implementation %>
<%# app/views/feedbacks/_feedback.html.erb %>
<div class="feedback">
  <%= @feedback.content %>
  <%= @current_user.name %>
</div>

<%# Requires controller to set @feedback and @current_user %>
<%# Hard to reuse in different contexts %>
```

**GOOD - Local Variables:**
```erb
<%# ✅ Explicit dependencies, easy to test and reuse %>
<%# app/views/feedbacks/_feedback.html.erb %>
<div class="feedback">
  <%= feedback.content %>
  <% if local_assigns[:current_user] %>
    <p>Viewing as: <%= current_user.name %></p>
  <% end %>
</div>
```

**Usage:**
```erb
<%# Clear what data the partial needs %>
<%= render "feedback", feedback: @feedback, current_user: current_user %>

<%# Easy to test %>
render partial: "feedbacks/feedback", locals: { feedback: feedback, current_user: user }
```
</pattern>

## Application Layouts

<pattern name="application-layout">
<description>Define main page structure with yield and content_for</description>

**Layout Definition:**
```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title><%= content_for?(:title) ? yield(:title) : "The Feedback Agent" %></title>

  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  <%= javascript_importmap_tags %>

  <%# Custom head content from views %>
  <%= yield :head %>
</head>
<body class="<%= content_for?(:body_class) ? yield(:body_class) : '' %>">
  <%= render "shared/header" %>

  <main class="container mx-auto px-4 py-8">
    <%= render "shared/flash_messages" %>
    <%= yield %>
  </main>

  <%= render "shared/footer" %>

  <%# Scripts at end of body %>
  <%= yield :scripts %>
</body>
</html>
```
</pattern>

<pattern name="content-for">
<description>Customize layout sections from individual views</description>

**View with content_for:**
```erb
<%# app/views/feedbacks/show.html.erb %>
<% content_for :title do %>
  <%= @feedback.content.truncate(60) %> | The Feedback Agent
<% end %>

<% content_for :head do %>
  <meta name="description" content="<%= @feedback.content.truncate(160) %>">
  <meta property="og:title" content="<%= @feedback.content.truncate(60) %>">
  <%= auto_discovery_link_tag :rss, feedbacks_path(format: :rss) %>
<% end %>

<% content_for :body_class, "feedback-page dark-mode" %>

<div class="feedback-detail">
  <h1><%= @feedback.content %></h1>
  <p class="text-muted">
    Submitted <%= time_ago_in_words(@feedback.created_at) %> ago
  </p>
</div>

<% content_for :scripts do %>
  <%= javascript_tag do %>
    console.log("Page-specific JavaScript");
    initFeedbackInteractions();
  <% end %>
<% end %>
```

**Result:**
- Custom title in `<title>` tag
- Additional meta tags in `<head>`
- Custom body class for page-specific styling
- Page-specific JavaScript at end of body
</pattern>

## Nested Layouts

<pattern name="nested-layouts">
<description>Create specialized layouts that inherit from base layout</description>

**Admin Layout:**
```erb
<%# app/views/layouts/admin.html.erb %>
<%= render template: "layouts/application" do %>
  <div class="admin-layout">
    <aside class="admin-sidebar">
      <%= render "admin/sidebar" %>
    </aside>

    <div class="admin-content">
      <%= yield %>
    </div>
  </div>
<% end %>
```

**Controller:**
```ruby
# app/controllers/admin/base_controller.rb
module Admin
  class BaseController < ApplicationController
    layout "admin"

    # All admin controllers inherit this layout
  end
end
```
</pattern>

<pattern name="conditional-layouts">
<description>Dynamically choose layouts based on context</description>

**Dynamic Layout Method:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  layout :choose_layout

  private

  def choose_layout
    if request.xhr? || turbo_frame_request?
      false  # No layout for AJAX/Turbo Frame requests
    elsif current_user&.admin?
      "admin"
    else
      "application"
    end
  end
end
```

**Per-Action Layout:**
```ruby
class FeedbacksController < ApplicationController
  layout "special", only: [:show, :edit]
  layout "print", only: [:print]
end
```
</pattern>

## Shared Partials

<pattern name="shared-partials">
<description>Common partials used across the application</description>

**Form Errors:**
```erb
<%# app/views/shared/_form_errors.html.erb %>
<% if object.errors.any? %>
  <div class="alert alert-error mb-4">
    <div>
      <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current flex-shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <div>
        <h3 class="font-bold">
          <%= pluralize(object.errors.count, "error") %> prohibited this
          <%= object.class.model_name.human.downcase %> from being saved:
        </h3>
        <ul class="list-disc list-inside mt-2">
          <% object.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    </div>
  </div>
<% end %>
```

**Usage:**
```erb
<%# In any form %>
<%= form_with model: @feedback do |form| %>
  <%= render "shared/form_errors", object: @feedback %>

  <%# form fields ... %>
<% end %>
```

**Flash Messages:**
```erb
<%# app/views/shared/_flash_messages.html.erb %>
<% flash.each do |type, message| %>
  <div class="alert alert-<%= flash_class(type) %> mb-4" role="alert">
    <span><%= message %></span>
  </div>
<% end %>

<%# app/helpers/application_helper.rb %>
<%# def flash_class(type)
  case type.to_sym
  when :notice then "info"
  when :success then "success"
  when :error, :alert then "error"
  when :warning then "warning"
  else "info"
  end
end %>
```

**Empty State:**
```erb
<%# app/views/shared/_empty_state.html.erb %>
<div class="empty-state text-center py-12">
  <% if local_assigns[:image_path] %>
    <%= image_tag image_path, alt: "No items", class: "mx-auto mb-4", width: 200 %>
  <% end %>

  <h3 class="text-2xl font-bold mb-2">
    <%= local_assigns[:title] || "No items found" %>
  </h3>

  <p class="text-muted mb-6">
    <%= local_assigns[:message] || "Get started by creating a new item" %>
  </p>

  <% if local_assigns[:action_url] && local_assigns[:action_text] %>
    <%= link_to action_text, action_url, class: "btn btn-primary" %>
  <% end %>
</div>
```

**Usage:**
```erb
<% if @feedbacks.empty? %>
  <%= render "shared/empty_state",
             image_path: "empty-state.svg",
             title: "No feedback yet",
             message: "Submit your first feedback to get started",
             action_url: new_feedback_path,
             action_text: "Create Feedback" %>
<% else %>
  <%= render @feedbacks %>
<% end %>
```

**Loading Spinner:**
```erb
<%# app/views/shared/_loading_spinner.html.erb %>
<div class="flex justify-center items-center <%= local_assigns[:class] %>">
  <span class="loading loading-spinner loading-lg"></span>
  <% if local_assigns[:message].present? %>
    <span class="ml-2"><%= message %></span>
  <% end %>
</div>

<%# Usage in Turbo Frame %>
<%= turbo_frame_tag "feedbacks", src: feedbacks_path do %>
  <%= render "shared/loading_spinner", message: "Loading feedbacks..." %>
<% end %>
```
</pattern>

## Partial Layouts

<pattern name="partial-with-layout">
<description>Apply a layout wrapper to a partial</description>

**Box Layout:**
```erb
<%# app/views/shared/_box.html.erb %>
<div class="box shadow-lg rounded-lg p-4 bg-white">
  <%= yield %>
</div>
```

**Usage:**
```erb
<%# Wrap partial with layout %>
<%= render layout: "shared/box" do %>
  <%= render "feedback", feedback: @feedback %>
<% end %>

<%# Collection with layout %>
<% @feedbacks.each do |feedback| %>
  <%= render layout: "shared/box" do %>
    <%= render "feedback", feedback: feedback %>
  <% end %>
<% end %>
```
</pattern>

## Collection with Fallback

<pattern name="collection-fallback">
<description>Render collection or show fallback if empty</description>

**Simple Fallback:**
```erb
<%= render(@feedbacks) || render("shared/empty_state") %>
```

**With Spacer:**
```erb
<%= render partial: "feedback",
           collection: @feedbacks,
           spacer_template: "separator" %>

<%# app/views/feedbacks/_separator.html.erb %>
<hr class="my-4 border-base-300">
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
- Shared across a few views
- No need for isolated testing

**Use ViewComponents When:**
- Complex rendering logic or state
- Need isolated unit testing
- Component variants and slots
- Reusable component library
- Performance-critical rendering (components are faster)
- Need preview system for documentation
- Team collaboration on components

**Example - Simple Partial (Good):**
```erb
<%# app/views/shared/_header.html.erb %>
<header class="navbar bg-base-100">
  <div class="navbar-start">
    <%= link_to "The Feedback Agent", root_path, class: "btn btn-ghost text-xl" %>
  </div>

  <div class="navbar-end">
    <% if user_signed_in? %>
      <%= link_to "Sign Out", sign_out_path, class: "btn btn-ghost" %>
    <% else %>
      <%= link_to "Sign In", sign_in_path, class: "btn btn-primary" %>
    <% end %>
  </div>
</header>
```

**Example - Complex Component (Better as ViewComponent):**
```ruby
# If your partial needs this much logic, use ViewComponent instead
# app/components/feedback_card_component.rb
class FeedbackCardComponent < ViewComponent::Base
  attr_reader :feedback, :current_user, :variant

  def initialize(feedback:, current_user:, variant: :default)
    @feedback = feedback
    @current_user = current_user
    @variant = variant
  end

  def can_edit?
    current_user&.id == feedback.user_id || current_user&.admin?
  end

  def card_classes
    base = "card shadow-lg"
    case variant
    when :compact then "#{base} card-compact"
    when :wide then "#{base} card-wide"
    else base
    end
  end

  def status_badge_color
    feedback.resolved? ? "badge-success" : "badge-warning"
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Using instance variables in partials</description>
<reason>Creates implicit dependencies, makes partials hard to reuse and test</reason>
<bad-example>
```erb
<%# ❌ BAD - Coupled to controller %>
<%# app/views/feedbacks/_feedback.html.erb %>
<div class="feedback">
  <%= @feedback.content %>
  <%= @current_user.name %>
</div>

<%# Must ensure @feedback and @current_user are set everywhere %>
<%= render "feedback" %>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Explicit dependencies %>
<%# app/views/feedbacks/_feedback.html.erb %>
<div class="feedback">
  <%= feedback.content %>
  <% if local_assigns[:current_user] %>
    <%= current_user.name %>
  <% end %>
</div>

<%# Clear what data is needed %>
<%= render "feedback", feedback: @feedback, current_user: current_user %>
```
</good-example>
</antipattern>

<antipattern>
<description>Deeply nested partials</description>
<reason>Hard to follow rendering flow, performance overhead</reason>
<bad-example>
```erb
<%# ❌ BAD - Too many nested partials %>
<%# app/views/feedbacks/index.html.erb %>
<%= render "container" %>
  <%# _container.html.erb %>
  <%= render "wrapper" %>
    <%# _wrapper.html.erb %>
    <%= render "inner" %>
      <%# _inner.html.erb %>
      <%= render "content" %>
        <%# _content.html.erb %>
        <%= render @feedbacks %>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Flatter structure %>
<%# app/views/feedbacks/index.html.erb %>
<div class="container">
  <div class="feedbacks-wrapper">
    <%= render @feedbacks %>
  </div>
</div>

<%# Or use ViewComponent for complex layouts %>
<%= render FeedbackListComponent.new(feedbacks: @feedbacks) %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not using collection rendering</description>
<reason>Slower, more verbose, misses automatic optimizations</reason>
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
<%# ✅ GOOD - Collection rendering (faster) %>
<%= render @feedbacks %>

<%# Or explicit collection %>
<%= render partial: "feedback", collection: @feedbacks %>
```
</good-example>
</antipattern>

<antipattern>
<description>Missing underscore prefix in partial filename</description>
<reason>Rails won't find the partial, causes errors</reason>
<bad-example>
```
❌ app/views/feedbacks/form.html.erb
❌ app/views/shared/header.html.erb
```
</bad-example>
<good-example>
```
✅ app/views/feedbacks/_form.html.erb
✅ app/views/shared/_header.html.erb
```
</good-example>
</antipattern>

<antipattern>
<description>Not checking for optional locals</description>
<reason>Raises NameError when variable not passed</reason>
<bad-example>
```erb
<%# ❌ BAD - Raises error if show_email not passed %>
<% if show_email %>
  <%= user.email %>
<% end %>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Safe check %>
<% if local_assigns[:show_email] %>
  <%= user.email %>
<% end %>

<%# Or with default %>
<% show_email = local_assigns.fetch(:show_email, false) %>
<% if show_email %>
  <%= user.email %>
<% end %>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test partials with ActionView::TestCase for isolated unit testing:

```ruby
# test/views/feedbacks/_feedback_test.rb
require "test_helper"

class Feedbacks::FeedbackPartialTest < ActionView::TestCase
  test "renders feedback content" do
    feedback = feedbacks(:one)

    render partial: "feedbacks/feedback", locals: { feedback: feedback }

    assert_select "div.card"
    assert_select "h3.card-title", text: feedback.content
    assert_select "a[href=?]", feedback_path(feedback)
  end

  test "shows edit link when user can edit" do
    feedback = feedbacks(:one)
    current_user = users(:admin)

    render partial: "feedbacks/feedback",
           locals: { feedback: feedback, current_user: current_user }

    assert_select "a[href=?]", edit_feedback_path(feedback), text: "Edit"
  end

  test "hides edit link when user cannot edit" do
    feedback = feedbacks(:one)
    current_user = users(:guest)

    render partial: "feedbacks/feedback",
           locals: { feedback: feedback, current_user: current_user }

    assert_select "a[href=?]", edit_feedback_path(feedback), count: 0
  end

  test "handles missing optional local gracefully" do
    feedback = feedbacks(:one)

    # No current_user passed
    render partial: "feedbacks/feedback", locals: { feedback: feedback }

    assert_select "div.card"
    # Should not raise error
  end
end

# test/views/shared/_form_errors_test.rb
require "test_helper"

class Shared::FormErrorsPartialTest < ActionView::TestCase
  test "renders errors for invalid object" do
    feedback = Feedback.new
    feedback.valid? # Generate errors

    render partial: "shared/form_errors", locals: { object: feedback }

    assert_select "div.alert.alert-error"
    assert_select "h3", text: /\d+ errors? prohibited/
    assert_select "ul li", count: feedback.errors.count
  end

  test "renders nothing for valid object" do
    feedback = feedbacks(:valid_one)

    render partial: "shared/form_errors", locals: { object: feedback }

    assert_select "div.alert", count: 0
  end
end

# test/system/layouts_test.rb
require "application_system_test_case"

class LayoutsTest < ApplicationSystemTestCase
  test "application layout includes header and footer" do
    visit root_path

    assert_selector "header.navbar"
    assert_selector "footer.footer"
    assert_selector "main.container"
  end

  test "custom page title appears" do
    visit feedback_path(feedbacks(:one))

    assert_title /#{feedbacks(:one).content.truncate(20)}/
  end

  test "flash messages appear in layout" do
    visit new_feedback_path
    click_button "Submit"

    assert_selector "div.alert.alert-error"
  end
end
```

**Testing Collection Partials:**
```ruby
test "renders collection with counters" do
  feedbacks = [feedbacks(:one), feedbacks(:two), feedbacks(:three)]

  render partial: "feedbacks/feedback", collection: feedbacks

  # Check for counter badges
  assert_select "span.badge", text: "1"
  assert_select "span.badge", text: "2"
  assert_select "span.badge", text: "3"

  # Check for first/last labels
  assert_select "span.label-primary", text: "First", count: 1
  assert_select "span.label-secondary", text: "Last", count: 1
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
