---
name: viewcomponent-basics
domain: frontend
dependencies: []
version: 1.0
rails_version: 8.1+
gem_requirements:
  - view_component: 4.1.0+

# Team rules enforcement
enforces_team_rule:
  - rule_id: 15
    rule_name: "ViewComponent for All UI"
    severity: high
    enforcement_action: SUGGEST
---

# ViewComponent Basics

ViewComponent is a framework for building reusable, testable, and encapsulated view components in Ruby on Rails.

<when-to-use>
- Building reusable UI components
- Testing view logic in isolation
- Type-safe view code (Ruby methods vs local variables)
- Performance-critical UIs (10x faster than partials)
</when-to-use>

<benefits>
- **Encapsulation** - Self-contained units
- **Reusability** - Build once, use everywhere
- **Testability** - Test with ViewComponent::TestCase
- **Performance** - Significantly faster than partials
- **Type Safety** - Ruby methods over local variables
</benefits>

<standards>
- Components in `app/components/` directory
- Inherit from `ViewComponent::Base`
- Template is `component_name.html.erb` (sidecar file)
- Pass parameters via `initialize` (not locals)
- Use `attr_reader` for instance variables
- Naming: `FooComponent` → `foo_component.rb` + `foo_component.html.erb`
- Compatible with Hotwire, Tailwind, DaisyUI
</standards>

## Patterns

<pattern name="simple-component">
<description>Simplest possible ViewComponent with parameter</description>

**Component Class:**
```ruby
# app/components/hello_component.rb
class HelloComponent < ViewComponent::Base
  def initialize(name:)
    @name = name
  end
end
```

**Component Template:**
```erb
<!-- app/components/hello_component.html.erb -->
<div class="greeting">
  Hello, <%= @name %>!
</div>
```

**Usage:**
```erb
<%= render HelloComponent.new(name: "World") %>
```
</pattern>

<pattern name="component-with-content">
<description>Component accepting content via block</description>

```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  def initialize(title:, variant: :default)
    @title = title
    @variant = variant
  end

  private

  attr_reader :title, :variant

  def card_classes
    base = "card bg-base-100 shadow-xl"
    variant == :bordered ? "#{base} card-bordered" : base
  end
end
```

```erb
<!-- app/components/card_component.html.erb -->
<div class="<%= card_classes %>">
  <div class="card-body">
    <h2 class="card-title"><%= title %></h2>
    <%= content %>
  </div>
</div>
```

```erb
<!-- Usage -->
<%= render CardComponent.new(title: "My Card", variant: :bordered) do %>
  <p>Card content here</p>
<% end %>
```
</pattern>

<pattern name="component-with-helpers">
<description>Component with helper methods for view logic</description>

```ruby
# app/components/button_component.rb
class ButtonComponent < ViewComponent::Base
  def initialize(text:, variant: :primary, disabled: false)
    @text = text
    @variant = variant
    @disabled = disabled
  end

  private

  attr_reader :text, :variant, :disabled

  def button_classes
    classes = ["btn", "btn-#{variant}"]
    classes << "btn-disabled" if disabled
    classes.join(" ")
  end
end
```

```erb
<!-- app/components/button_component.html.erb -->
<button class="<%= button_classes %>" <%= "disabled" if disabled %>>
  <%= text %>
</button>
```

```erb
<!-- Usage -->
<%= render ButtonComponent.new(text: "Save", variant: :primary) %>
```
</pattern>

<pattern name="component-generator">
<description>Rails generator for components</description>

```bash
rails generate component Example title:string
# Creates: component class, template, and test
```
</pattern>

<antipatterns>
<antipattern>
<description>Business logic in components</description>
<reason>Components are presentational. Business logic belongs in models/services.</reason>
<bad-example>
```ruby
# ❌ Business logic in component
def should_show_premium_badge?
  @user.subscription_active? && @user.paid_last_month?
end
```
</bad-example>
<good-example>
```ruby
# ✅ Business logic in model
class User < ApplicationRecord
  def premium?
    subscription_active? && paid_last_month?
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using locals instead of initialize</description>
<reason>Instance variables provide type safety and easier testing.</reason>
<bad-example>
```ruby
<%= render ButtonComponent.new, text: "Click me" %>
```
</bad-example>
<good-example>
```ruby
<%= render ButtonComponent.new(text: "Click me") %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not using attr_reader</description>
<reason>Makes code cleaner and testing easier.</reason>
<bad-example>
```ruby
def formatted_title
  @title.upcase
end
```
</bad-example>
<good-example>
```ruby
private
attr_reader :title

def formatted_title
  title.upcase
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test components with `ViewComponent::TestCase`:

```ruby
# test/components/button_component_test.rb
class ButtonComponentTest < ViewComponent::TestCase
  test "renders button" do
    render_inline(ButtonComponent.new(text: "Save"))
    assert_selector "button", text: "Save"
  end

  test "applies classes" do
    render_inline(ButtonComponent.new(text: "Save", variant: :primary))
    assert_selector "button.btn-primary"
  end
end
```
</testing>

<related-skills>
- viewcomponent-slots - Multiple content areas
- viewcomponent-previews - Development and documentation
- viewcomponent-variants - Style variants
- hotwire-turbo - Dynamic updates
- tailwind-utility-first - Styling
</related-skills>

<resources>
- [ViewComponent Docs](https://viewcomponent.org/)
- [GitHub](https://github.com/ViewComponent/view_component)
</resources>
