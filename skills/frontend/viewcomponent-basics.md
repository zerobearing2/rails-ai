---
name: viewcomponent-basics
domain: frontend
dependencies: []
version: 1.0
rails_version: 8.1+
gem_requirements:
  - view_component: 4.1.0+
---

# ViewComponent Basics

ViewComponent is a framework for building reusable, testable, and encapsulated view components in Ruby on Rails.

<when-to-use>
- Building reusable UI components across your application
- Need to test view logic in isolation
- Want type-safe view code (Ruby methods vs local variables)
- Performance matters (ViewComponent is up to 10x faster than partials)
- Complex UI that benefits from component-based architecture
</when-to-use>

<benefits>
- **Encapsulation** - Components are self-contained units
- **Reusability** - Build once, use everywhere
- **Testability** - Test components in isolation with ViewComponent::TestCase
- **Performance** - Significantly faster than partials
- **Type Safety** - Ruby methods instead of local variables
- **Organization** - Clear structure for complex UIs
</benefits>

<standards>
- Components go in `app/components/` directory
- Component class inherits from `ViewComponent::Base`
- Component template is `component_name.html.erb` in same directory
- Use `initialize` to accept parameters (not locals)
- Make instance variables available to template via `attr_reader` or directly
- Follow Rails naming conventions: `FooComponent` → `foo_component.rb` + `foo_component.html.erb`
- Compatible with Hotwire (Turbo + Stimulus)
- Works seamlessly with Tailwind CSS + DaisyUI
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
<description>Component that accepts content via block</description>

**Component Class:**
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
    case variant
    when :bordered
      "#{base} card-bordered"
    when :compact
      "#{base} card-compact"
    else
      base
    end
  end
end
```

**Component Template:**
```erb
<!-- app/components/card_component.html.erb -->
<div class="<%= card_classes %>">
  <div class="card-body">
    <h2 class="card-title"><%= title %></h2>
    <div class="card-content">
      <%= content %>
    </div>
  </div>
</div>
```

**Usage:**
```erb
<%= render CardComponent.new(title: "My Card", variant: :bordered) do %>
  <p>This is the card content!</p>
<% end %>
```
</pattern>

<pattern name="component-with-helpers">
<description>Component with private helper methods for view logic</description>

**Component Class:**
```ruby
# app/components/button_component.rb
class ButtonComponent < ViewComponent::Base
  def initialize(text:, variant: :primary, size: :md, disabled: false)
    @text = text
    @variant = variant
    @size = size
    @disabled = disabled
  end

  private

  attr_reader :text, :variant, :size, :disabled

  def button_classes
    classes = ["btn"]
    classes << variant_class
    classes << size_class
    classes << "btn-disabled" if disabled
    classes.join(" ")
  end

  def variant_class
    {
      primary: "btn-primary",
      secondary: "btn-secondary",
      accent: "btn-accent",
      ghost: "btn-ghost"
    }.fetch(variant, "btn-primary")
  end

  def size_class
    {
      xs: "btn-xs",
      sm: "btn-sm",
      md: "",
      lg: "btn-lg"
    }.fetch(size, "")
  end
end
```

**Component Template:**
```erb
<!-- app/components/button_component.html.erb -->
<button class="<%= button_classes %>" <%= "disabled" if disabled %>>
  <%= text %>
</button>
```

**Usage:**
```erb
<%= render ButtonComponent.new(text: "Save", variant: :primary, size: :lg) %>
<%= render ButtonComponent.new(text: "Cancel", variant: :ghost) %>
```
</pattern>

<pattern name="component-generator">
<description>Using Rails generator to create components</description>

**Generate Component:**
```bash
# Generate component with template
rails generate component Example title:string

# Creates:
# - app/components/example_component.rb
# - app/components/example_component.html.erb
# - test/components/example_component_test.rb
```

**Generated Component:**
```ruby
# app/components/example_component.rb
class ExampleComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Putting business logic in components</description>
<reason>Components should be presentational only. Business logic belongs in models, services, or form objects.</reason>
<bad-example>
```ruby
# ❌ BAD - Business logic in component
class UserCardComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
  end

  def should_show_premium_badge?
    @user.subscription_active? && @user.paid_last_month?
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Business logic in model
class User < ApplicationRecord
  def premium?
    subscription_active? && paid_last_month?
  end
end

class UserCardComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
  end
end

# Template: <%= "Premium" if @user.premium? %>
```
</good-example>
</antipattern>

<antipattern>
<description>Using local variables instead of instance variables</description>
<reason>Instance variables provide type safety and make testing easier. Avoid passing data as locals.</reason>
<bad-example>
```ruby
# ❌ BAD - Using locals (like partials)
<%= render ButtonComponent.new, text: "Click me" %>
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Pass data via initialize
<%= render ButtonComponent.new(text: "Click me") %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not using attr_reader for instance variables</description>
<reason>Using attr_reader makes code cleaner and enables better testing.</reason>
<bad-example>
```ruby
# ❌ BAD - Direct instance variable access in methods
class CardComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end

  def formatted_title
    @title.upcase
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use attr_reader
class CardComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end

  private

  attr_reader :title

  def formatted_title
    title.upcase
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Components are tested using `ViewComponent::TestCase`:

```ruby
# test/components/button_component_test.rb
require "test_helper"

class ButtonComponentTest < ViewComponent::TestCase
  test "renders button with text" do
    render_inline(ButtonComponent.new(text: "Click me"))

    assert_selector "button", text: "Click me"
  end

  test "applies variant classes" do
    render_inline(ButtonComponent.new(text: "Save", variant: :primary))

    assert_selector "button.btn-primary"
  end

  test "renders disabled state" do
    render_inline(ButtonComponent.new(text: "Submit", disabled: true))

    assert_selector "button[disabled]"
  end
end
```
</testing>

<related-skills>
- viewcomponent-slots - For components with multiple content areas
- viewcomponent-previews - For component development and documentation
- viewcomponent-variants - For style variants and polymorphic rendering
- hotwire-turbo - For dynamic updates with Turbo Frames/Streams
- tailwind-utility-first - For styling components with Tailwind
- daisyui-components - For using DaisyUI component classes
</related-skills>

<resources>
- [ViewComponent Documentation](https://viewcomponent.org/)
- [ViewComponent GitHub](https://github.com/ViewComponent/view_component)
- [Rails Guides - ViewComponent](https://guides.rubyonrails.org/view_component.html)
</resources>
