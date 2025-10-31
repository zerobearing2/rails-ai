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

```ruby
# app/components/modal_component.rb
class ModalComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer

  def initialize(size: :md)
    @size = size
  end
end
```

```erb
<!-- app/components/modal_component.html.erb -->
<dialog class="modal">
  <% if header? %>
    <div class="modal-header"><%= header %></div>
  <% end %>
  <div class="modal-body"><%= content %></div>
  <% if footer? %>
    <div class="modal-footer"><%= footer %></div>
  <% end %>
</dialog>

<!-- Usage -->
<%= render ModalComponent.new do |modal| %>
  <% modal.with_header { "Title" } %>
  <p>Content</p>
  <% modal.with_footer { "Actions" } %>
<% end %>
```
</pattern>

<pattern name="collection-slot-renders-many">
<description>Collection slots with renders_many for repeating content</description>

```ruby
# app/components/tab_container_component.rb
class TabContainerComponent < ViewComponent::Base
  renders_many :tabs, "TabComponent"

  class TabComponent < ViewComponent::Base
    def initialize(name:, active: false)
      @name = name
      @active = active
    end

    def call
      content_tag :a, content, class: "tab #{@active ? 'tab-active' : ''}"
    end
  end
end
```

```erb
<!-- app/components/tab_container_component.html.erb -->
<div class="tabs">
  <% tabs.each { |tab| <%= tab %> } %>
</div>

<!-- Usage -->
<%= render TabContainerComponent.new do |c| %>
  <% c.with_tab(name: "Overview", active: true) { "Content 1" } %>
  <% c.with_tab(name: "Details") { "Content 2" } %>
<% end %>
```
</pattern>

<pattern name="typed-slot-component">
<description>Slots that render specific component types for consistency</description>

```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  renders_one :action, ButtonComponent  # Type-safe slot
  renders_one :icon, IconComponent

  def initialize(title:)
    @title = title
  end
end
```

```erb
<!-- app/components/card_component.html.erb -->
<div class="card">
  <% if icon? %><%= icon %><% end %>
  <h2><%= @title %></h2>
  <%= content %>
  <% if action? %><%= action %><% end %>
</div>

<!-- Usage -->
<%= render CardComponent.new(title: "Welcome") do |card| %>
  <% card.with_icon(name: "star") %>
  <p>Content</p>
  <% card.with_action(text: "Learn More") %>
<% end %>
```
</pattern>

<pattern name="polymorphic-slots">
<description>Slots that can render different component variants</description>

```ruby
# app/components/alert_component.rb
class AlertComponent < ViewComponent::Base
  renders_one :icon, types: {
    info: { renders: IconComponent, as: :info_icon },
    warning: { renders: IconComponent, as: :warning_icon },
    error: { renders: IconComponent, as: :error_icon }
  }

  def initialize(variant: :info)
    @variant = variant
  end
end
```

```erb
<!-- app/components/alert_component.html.erb -->
<div class="alert alert-<%= @variant %>">
  <% if icon? %><%= icon %><% end %>
  <span><%= content %></span>
</div>

<!-- Usage -->
<%= render AlertComponent.new(variant: :warning) do |alert| %>
  <% alert.with_warning_icon(name: "alert-triangle") %>
  Warning message
<% end %>
```
</pattern>

<antipatterns>
<antipattern>
<description>Not checking slot presence before rendering</description>
<reason>Causes empty divs and unnecessary markup</reason>
<bad-example>
```erb
<!-- ❌ BAD -->
<div class="header"><%= header %></div>
```
</bad-example>
<good-example>
```erb
<!-- ✅ GOOD -->
<% if header? %>
  <div class="header"><%= header %></div>
<% end %>
```
</good-example>
</antipattern>

<antipattern>
<description>Using content instead of slots for structured data</description>
<reason>Makes component inflexible and harder to maintain</reason>
<bad-example>
```erb
<!-- ❌ BAD -->
<%= render ModalComponent.new do %>
  <div class="header">Title</div>
  <div class="body">Content</div>
<% end %>
```
</bad-example>
<good-example>
```erb
<!-- ✅ GOOD -->
<%= render ModalComponent.new do |m| %>
  <% m.with_header { "Title" } %>
  <p>Content</p>
<% end %>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# test/components/modal_component_test.rb
class ModalComponentTest < ViewComponent::TestCase
  test "renders with header slot" do
    render_inline(ModalComponent.new) { |m| m.with_header { "Test" } }
    assert_selector ".modal-header", text: "Test"
  end

  test "slot presence predicates" do
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
