---
name: viewcomponent-slots
domain: frontend
dependencies: [viewcomponent-basics]
version: 1.0
rails_version: 8.1+
gem_requirements:
  - view_component: 4.1.0+
---

# ViewComponent Slots

Slots allow ViewComponents to accept multiple named content areas, providing structured and flexible component composition.

<when-to-use>
- Component needs multiple distinct content areas (e.g., header, body, footer)
- Building layout components that wrap varying content
- Creating collection-based components (e.g., tabs, lists, cards)
- Need conditional rendering of specific content sections
- Want type-safe content areas with predicate methods
</when-to-use>

<benefits>
- **Structured Content** - Multiple named content areas instead of single block
- **Type Safety** - Slots can specify component types for consistency
- **Flexibility** - Polymorphic slots support variant rendering
- **Predicate Methods** - Check slot presence with `slot_name?`
- **Nested Components** - Slots can render other components
</benefits>

<standards>
- Use `renders_one` for single-occurrence slots (header, footer)
- Use `renders_many` for collection slots (items, tabs, options)
- Provide predicate methods automatically: `header?`, `footer?`
- Define slot component classes inline or reference external components
- Use `with_#{slot_name}` to populate slots from parent
- Check slot presence with `#{slot_name}?` before rendering
</standards>

## Patterns

<pattern name="single-slot-renders-one">
<description>Basic slot usage with renders_one for single content areas</description>

**Component Class:**
```ruby
# app/components/modal_component.rb
class ModalComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer

  def initialize(size: :md, open: false)
    @size = size
    @open = open
  end

  private

  attr_reader :size, :open

  def modal_classes
    classes = ["modal"]
    classes << "modal-open" if open
    classes.join(" ")
  end

  def modal_box_classes
    case size
    when :sm
      "modal-box w-96"
    when :lg
      "modal-box w-11/12 max-w-5xl"
    else
      "modal-box"
    end
  end
end
```

**Component Template:**
```erb
<!-- app/components/modal_component.html.erb -->
<dialog class="<%= modal_classes %>">
  <div class="<%= modal_box_classes %>">
    <% if header? %>
      <div class="modal-header">
        <%= header %>
      </div>
    <% end %>

    <div class="modal-body py-4">
      <%= content %>
    </div>

    <% if footer? %>
      <div class="modal-footer modal-action">
        <%= footer %>
      </div>
    <% end %>
  </div>
</dialog>
```

**Usage:**
```erb
<%= render ModalComponent.new(size: :lg) do |modal| %>
  <% modal.with_header do %>
    <h3 class="font-bold text-lg">Feedback Details</h3>
  <% end %>

  <p>This is the modal content</p>

  <% modal.with_footer do %>
    <button class="btn btn-primary">Close</button>
  <% end %>
<% end %>
```
</pattern>

<pattern name="collection-slot-renders-many">
<description>Collection slots with renders_many for repeating content</description>

**Component Class:**
```ruby
# app/components/tab_container_component.rb
class TabContainerComponent < ViewComponent::Base
  renders_many :tabs, "TabComponent"

  class TabComponent < ViewComponent::Base
    def initialize(name:, active: false, **html_options)
      @name = name
      @active = active
      @html_options = html_options
    end

    attr_reader :name, :active, :html_options

    def tab_classes
      classes = ["tab"]
      classes << "tab-active" if active
      classes << html_options[:class] if html_options[:class]
      classes.join(" ")
    end

    def call
      content_tag :a, content, class: tab_classes, **html_options.except(:class)
    end
  end

  def before_render
    @has_active = tabs.any?(&:active)
  end
end
```

**Component Template:**
```erb
<!-- app/components/tab_container_component.html.erb -->
<div role="tablist" class="tabs tabs-bordered">
  <% tabs.each do |tab| %>
    <%= tab %>
  <% end %>
</div>
```

**Usage:**
```erb
<%= render TabContainerComponent.new do |c| %>
  <% c.with_tab(name: "Overview", active: true) do %>
    Overview Content
  <% end %>
  <% c.with_tab(name: "Details") do %>
    Details Content
  <% end %>
  <% c.with_tab(name: "Settings") do %>
    Settings Content
  <% end %>
<% end %>
```
</pattern>

<pattern name="typed-slot-component">
<description>Slots that render specific component types for consistency</description>

**Component Class:**
```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  # Slot must render ButtonComponent
  renders_one :action, ButtonComponent
  renders_one :icon, IconComponent

  def initialize(title:, variant: :default)
    @title = title
    @variant = variant
  end

  private

  attr_reader :title, :variant
end
```

**Component Template:**
```erb
<!-- app/components/card_component.html.erb -->
<div class="card">
  <div class="card-body">
    <% if icon? %>
      <div class="card-icon">
        <%= icon %>
      </div>
    <% end %>

    <h2 class="card-title"><%= title %></h2>
    <%= content %>

    <% if action? %>
      <div class="card-actions">
        <%= action %>
      </div>
    <% end %>
  </div>
</div>
```

**Usage:**
```erb
<%= render CardComponent.new(title: "Welcome") do |card| %>
  <% card.with_icon(name: "star") %>

  <p>Card content goes here</p>

  <% card.with_action(text: "Learn More", variant: :primary) %>
<% end %>
```
</pattern>

<pattern name="polymorphic-slots">
<description>Slots that can render different component variants</description>

**Component Class:**
```ruby
# app/components/alert_component.rb
class AlertComponent < ViewComponent::Base
  # Polymorphic slot - can render different icon types
  renders_one :icon, types: {
    info: {
      renders: IconComponent,
      as: :info_icon
    },
    warning: {
      renders: IconComponent,
      as: :warning_icon
    },
    error: {
      renders: IconComponent,
      as: :error_icon
    }
  }

  def initialize(variant: :info)
    @variant = variant
  end

  private

  attr_reader :variant

  def alert_classes
    base = "alert"
    case variant
    when :info
      "#{base} alert-info"
    when :warning
      "#{base} alert-warning"
    when :error
      "#{base} alert-error"
    else
      base
    end
  end
end
```

**Component Template:**
```erb
<!-- app/components/alert_component.html.erb -->
<div class="<%= alert_classes %>">
  <% if icon? %>
    <%= icon %>
  <% end %>
  <span><%= content %></span>
</div>
```

**Usage:**
```erb
<%= render AlertComponent.new(variant: :warning) do |alert| %>
  <% alert.with_warning_icon(name: "alert-triangle") %>
  This is a warning message
<% end %>
```
</pattern>

<pattern name="slot-with-parameters">
<description>Passing parameters to slot components</description>

**Component Class:**
```ruby
# app/components/list_component.rb
class ListComponent < ViewComponent::Base
  renders_many :items, "ItemComponent"

  class ItemComponent < ViewComponent::Base
    def initialize(title:, subtitle: nil, icon: nil, active: false)
      @title = title
      @subtitle = subtitle
      @icon = icon
      @active = active
    end

    private

    attr_reader :title, :subtitle, :icon, :active

    def item_classes
      classes = ["list-item"]
      classes << "active" if active
      classes.join(" ")
    end
  end
end
```

**Component Template:**
```erb
<!-- app/components/list_component.html.erb -->
<ul class="menu">
  <% items.each do |item| %>
    <%= item %>
  <% end %>
</ul>

<!-- app/components/list_component/item_component.html.erb -->
<li class="<%= item_classes %>">
  <% if icon %>
    <span class="icon"><%= icon %></span>
  <% end %>
  <div>
    <div class="title"><%= title %></div>
    <% if subtitle %>
      <div class="subtitle"><%= subtitle %></div>
    <% end %>
  </div>
</li>
```

**Usage:**
```erb
<%= render ListComponent.new do |list| %>
  <% list.with_item(title: "Home", icon: "🏠", active: true) %>
  <% list.with_item(title: "Profile", icon: "👤", subtitle: "View your profile") %>
  <% list.with_item(title: "Settings", icon: "⚙️") %>
<% end %>
```
</pattern>

<antipatterns>
<antipattern>
<description>Not checking slot presence before rendering</description>
<reason>Causes empty divs and unnecessary markup when slots aren't provided</reason>
<bad-example>
```erb
<!-- ❌ BAD - Always renders header div even if empty -->
<div class="header">
  <%= header %>
</div>
```
</bad-example>
<good-example>
```erb
<!-- ✅ GOOD - Only renders when header slot is provided -->
<% if header? %>
  <div class="header">
    <%= header %>
  </div>
<% end %>
```
</good-example>
</antipattern>

<antipattern>
<description>Using content instead of slots for structured data</description>
<reason>Makes component inflexible and harder to maintain</reason>
<bad-example>
```ruby
# ❌ BAD - Passing everything as single content block
<%= render ModalComponent.new do %>
  <div class="header">Title</div>
  <div class="body">Content</div>
  <div class="footer">Actions</div>
<% end %>
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use slots for structured content
<%= render ModalComponent.new do |modal| %>
  <% modal.with_header { "Title" } %>
  <p>Content</p>
  <% modal.with_footer { "Actions" } %>
<% end %>
```
</good-example>
</antipattern>

<antipattern>
<description>Defining slot components outside parent component</description>
<reason>Breaks encapsulation and makes components harder to understand</reason>
<bad-example>
```ruby
# ❌ BAD - Separate file for slot component
class TabComponent < ViewComponent::Base
  # ...
end

class TabContainerComponent < ViewComponent::Base
  renders_many :tabs, TabComponent
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Inline slot component for better encapsulation
class TabContainerComponent < ViewComponent::Base
  renders_many :tabs, "TabComponent"

  class TabComponent < ViewComponent::Base
    # ...
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test slots using ViewComponent::TestCase:

```ruby
# test/components/modal_component_test.rb
require "test_helper"

class ModalComponentTest < ViewComponent::TestCase
  test "renders with header slot" do
    render_inline(ModalComponent.new) do |modal|
      modal.with_header { "Test Header" }
    end

    assert_selector ".modal-header", text: "Test Header"
  end

  test "does not render header without slot" do
    render_inline(ModalComponent.new)

    assert_no_selector ".modal-header"
  end

  test "renders multiple tab slots" do
    render_inline(TabContainerComponent.new) do |tabs|
      tabs.with_tab(name: "Tab 1", active: true) { "Content 1" }
      tabs.with_tab(name: "Tab 2") { "Content 2" }
    end

    assert_selector ".tab", count: 2
    assert_selector ".tab-active", text: "Tab 1"
  end

  test "predicate methods work correctly" do
    component = ModalComponent.new
    component.with_header { "Test" }

    assert component.header?
    refute component.footer?
  end
end
```
</testing>

<related-skills>
- viewcomponent-basics - Foundation for understanding components
- viewcomponent-previews - Preview components with different slot configurations
- viewcomponent-variants - Polymorphic rendering with slots
- hotwire-turbo - Update slot content dynamically with Turbo
</related-skills>

<resources>
- [ViewComponent Slots Documentation](https://viewcomponent.org/guide/slots.html)
- [ViewComponent Polymorphic Slots](https://viewcomponent.org/guide/slots.html#polymorphic-slots)
</resources>
