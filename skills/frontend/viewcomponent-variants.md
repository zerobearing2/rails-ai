---
name: viewcomponent-variants
domain: frontend
dependencies:
  - viewcomponent-basics
  - tailwind-utility-first
version: 1.0
rails_version: 8.1+
gem_requirements:
  - view_component: 4.1.0+
  - view_component-contrib: 0.2.0+
---

# ViewComponent Style Variants

Advanced component styling with declarative variant management using the `view_component-contrib` gem, providing a CVA-like (Class Variance Authority) API for Rails ViewComponents.

<when-to-use>
- Building design system components with multiple visual variants
- Need type-safe variant definitions (size, color, style combinations)
- Managing complex variant combinations (compound variants)
- Want declarative variant DSL instead of conditional logic
- Composing Tailwind CSS classes systematically
- Creating reusable UI component libraries
</when-to-use>

<benefits>
- **Declarative** - Define all variants upfront with clear DSL
- **Type-safe** - Variants are defined and validated
- **Composable** - Combine multiple variants systematically
- **Compound Variants** - Handle complex variant combinations
- **Defaults** - Set sensible default variant values
- **Inheritance** - Extend and merge variants across component hierarchies
- **Tailwind-optimized** - Built specifically for Tailwind CSS class composition
- **Cleaner Code** - Eliminates conditional class logic sprawl
</benefits>

<standards>
- Install `view_component-contrib` gem for variant support
- Include `ViewComponentContrib::StyleVariants` in component class
- Define variants using `style` block with DSL
- Use `base {}` for classes applied to all variants
- Define variant groups in `variants {}` block
- Set defaults with `defaults {}` block
- Call `style()` helper in template to generate class string
- Use compound variants for complex combinations
- Support multiple independent style sets per component
- Never mix inline conditional class logic with variant system
</standards>

## Installation

<pattern name="setup-style-variants">
<description>Install and configure view_component-contrib gem</description>

**Gemfile:**
```ruby
# Gemfile
gem "view_component"
gem "view_component-contrib"
```

**Install:**
```bash
bundle install
```

**No additional configuration needed** - include module in components that need variants.
</pattern>

## Basic Variant Patterns

<pattern name="simple-button-variants">
<description>Basic button component with color and size variants</description>

**Component Class:**
```ruby
# app/components/ui/button_component.rb
module Ui
  class ButtonComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    style do
      base { %w[font-medium rounded-lg transition-colors focus:ring-2] }

      variants {
        color {
          primary { %w[bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500] }
          secondary { %w[bg-purple-600 text-white hover:bg-purple-700 focus:ring-purple-500] }
          danger { %w[bg-red-600 text-white hover:bg-red-700 focus:ring-red-500] }
        }

        size {
          sm { %w[px-3 py-1.5 text-sm] }
          md { %w[px-4 py-2 text-base] }
          lg { %w[px-6 py-3 text-lg] }
        }
      }

      defaults { { color: :primary, size: :md } }
    end

    def initialize(color: nil, size: nil, disabled: false)
      @color, @size, @disabled = color, size, disabled
    end

    private

    attr_reader :color, :size, :disabled
  end
end
```

**Component Template:**
```erb
<!-- app/components/ui/button_component.html.erb -->
<button
  class="<%= style(color:, size:) %>"
  <%= "disabled" if disabled %>
>
  <%= content %>
</button>
```

**Usage:**
```erb
<%# Uses defaults: primary color, md size %>
<%= render Ui::ButtonComponent.new { "Save" } %>

<%# Custom variants %>
<%= render Ui::ButtonComponent.new(color: :danger, size: :lg) { "Delete" } %>
```
</pattern>

<pattern name="badge-variants">
<description>Badge component with status-based color variants</description>

**Component Class:**
```ruby
# app/components/ui/badge_component.rb
module Ui
  class BadgeComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    style do
      base { %w[inline-flex items-center rounded-full font-medium] }

      variants {
        status {
          pending { %w[bg-yellow-100 text-yellow-800 border border-yellow-200] }
          active { %w[bg-green-100 text-green-800 border border-green-200] }
          inactive { %w[bg-gray-100 text-gray-800 border border-gray-200] }
        }

        size {
          sm { %w[text-xs px-2 py-0.5] }
          md { %w[text-sm px-3 py-1] }
          lg { %w[text-base px-4 py-1.5] }
        }
      }

      defaults { { status: :inactive, size: :md } }
    end

    def initialize(status:, size: nil)
      @status, @size = status.to_sym, size
    end

    private

    attr_reader :status, :size
  end
end
```

**Component Template:**
```erb
<!-- app/components/ui/badge_component.html.erb -->
<span class="<%= style(status:, size:) %>">
  <%= content %>
</span>
```

**Usage:**
```erb
<%= render Ui::BadgeComponent.new(status: :active) { "Active" } %>
<%= render Ui::BadgeComponent.new(status: :pending, size: :lg) { "Pending" } %>
```
</pattern>

## Compound Variants

<pattern name="compound-variant-button">
<description>Advanced button with compound variants for complex combinations</description>

**Component Class:**
```ruby
# app/components/ui/advanced_button_component.rb
module Ui
  class AdvancedButtonComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    style do
      base {
        %w[font-medium rounded-lg transition-all duration-200]
      }

      variants {
        size {
          sm { %w[px-3 py-1.5 text-sm] }
          md { %w[px-4 py-2 text-base] }
          lg { %w[px-6 py-3 text-lg] }
        }

        theme {
          primary { %w[bg-blue-600 text-white] }
          secondary { %w[bg-purple-600 text-white] }
          outline { %w[bg-transparent border-2] }
        }

        disabled {
          yes { %w[opacity-50 cursor-not-allowed] }
          no { %w[hover:shadow-md cursor-pointer] }
        }
      }

      # Compound variant: Large primary buttons get special styling
      compound(size: :lg, theme: :primary) {
        %w[uppercase font-bold tracking-wide]
      }

      # Compound variant: Enabled outline buttons get hover effects
      compound(theme: :outline, disabled: :no) {
        %w[border-blue-600 text-blue-600 hover:bg-blue-50]
      }

      # Compound variant: Disabled outline buttons
      compound(theme: :outline, disabled: :yes) {
        %w[border-gray-300 text-gray-400]
      }

      defaults {
        { size: :md, theme: :primary, disabled: :no }
      }
    end

    def initialize(size: nil, theme: nil, disabled: false)
      @size = size
      @theme = theme
      @disabled = disabled ? :yes : :no
    end

    private

    attr_reader :size, :theme, :disabled
  end
end
```

**Component Template:**
```erb
<!-- app/components/ui/advanced_button_component.html.erb -->
<button class="<%= style(size:, theme:, disabled:) %>">
  <%= content %>
</button>
```

**Usage:**
```erb
<%# Large primary button gets uppercase + bold from compound variant %>
<%= render Ui::AdvancedButtonComponent.new(size: :lg, theme: :primary) { "CTA" } %>

<%# Outline button with hover effects %>
<%= render Ui::AdvancedButtonComponent.new(theme: :outline) { "Secondary" } %>
```
</pattern>

<pattern name="feedback-status-badge">
<description>Real-world feedback status badge with compound variants</description>

**Component Class:**
```ruby
# app/components/feedback_components/status_badge_component.rb
module FeedbackComponents
  class StatusBadgeComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    style do
      base { %w[inline-flex items-center rounded-full font-medium] }

      variants {
        status {
          pending { %w[bg-yellow-100 text-yellow-800] }
          reviewed { %w[bg-blue-100 text-blue-800] }
          responded { %w[bg-green-100 text-green-800] }
          archived { %w[bg-gray-100 text-gray-800] }
        }

        size {
          sm { %w[text-xs px-2 py-0.5] }
          md { %w[text-sm px-3 py-1] }
          lg { %w[text-base px-4 py-1.5] }
        }

        with_icon {
          yes { %w[pl-2] }
          no { %w[] }
        }
      }

      compound(size: :lg) { %w[font-bold] }
      compound(status: :pending, size: :lg) { %w[animate-pulse] }

      defaults { { size: :md, with_icon: :no } }
    end

    def initialize(status:, size: nil, with_icon: false)
      @status, @size = status.to_sym, size
      @with_icon = with_icon ? :yes : :no
    end

    private

    attr_reader :status, :size, :with_icon

    def icon
      { pending: "⏳", reviewed: "👀", responded: "✓", archived: "📦" }[status]
    end
  end
end
```

**Component Template:**
```erb
<!-- app/components/feedback_components/status_badge_component.html.erb -->
<span class="<%= style(status:, size:, with_icon:) %>">
  <% if with_icon == :yes %>
    <span class="mr-1"><%= icon %></span>
  <% end %>
  <%= content || status.to_s.titleize %>
</span>
```

**Usage:**
```erb
<%# Large pending badge with icon - gets pulse animation %>
<%= render FeedbackComponents::StatusBadgeComponent.new(
  status: :pending, size: :lg, with_icon: true
) %>
```
</pattern>

## Multiple Style Sets

<pattern name="card-with-multiple-style-sets">
<description>Component with multiple independent style sets for different elements</description>

**Component Class:**
```ruby
# app/components/ui/card_with_image_component.rb
module Ui
  class CardWithImageComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    # Default style set for card container
    style do
      base { %w[rounded-lg shadow-lg overflow-hidden] }

      variants {
        variant {
          default { %w[bg-white] }
          bordered { %w[bg-white border-2 border-gray-200] }
          glass { %w[bg-white/80 backdrop-blur-sm] }
        }
      }

      defaults { { variant: :default } }
    end

    # Separate style set for image
    style :image do
      base { %w[object-cover] }

      variants {
        orient {
          portrait { %w[w-32 h-48] }
          landscape { %w[w-64 h-32] }
          square { %w[w-32 h-32] }
        }
      }

      defaults { { orient: :landscape } }
    end

    # Separate style set for content area
    style :content do
      variants {
        padding {
          sm { %w[p-2] }
          md { %w[p-4] }
          lg { %w[p-6] }
        }
      }

      defaults { { padding: :md } }
    end

    def initialize(variant: nil, image_orient: nil, content_padding: nil, image_src:)
      @variant = variant
      @image_orient = image_orient
      @content_padding = content_padding
      @image_src = image_src
    end

    private

    attr_reader :variant, :image_orient, :content_padding, :image_src
  end
end
```

**Component Template:**
```erb
<!-- app/components/ui/card_with_image_component.html.erb -->
<div class="<%= style(variant:) %>">
  <img src="<%= image_src %>" class="<%= style(:image, orient: image_orient) %>">
  <div class="<%= style(:content, padding: content_padding) %>">
    <%= content %>
  </div>
</div>
```

**Usage:**
```erb
<%= render Ui::CardWithImageComponent.new(
  variant: :glass, image_orient: :portrait, image_src: "/product.jpg"
) do %>
  <h3>Product Name</h3>
  <p>Description...</p>
<% end %>
```
</pattern>

## Dynamic Variants with Ruby Blocks

<pattern name="dynamic-variant-logic">
<description>Use Ruby blocks for dynamic variant logic based on other variants</description>

**Component Class:**
```ruby
# app/components/ui/dynamic_button_component.rb
module Ui
  class DynamicButtonComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    style do
      base { %w[rounded-lg transition-colors] }

      variants {
        size {
          sm { "text-sm" }
          md { "text-base" }
          lg { "px-6 py-3 text-lg" }
        }

        theme {
          # Ruby block receives all variant values
          primary do |size:, **|
            classes = %w[bg-blue-600 text-white hover:bg-blue-700]
            classes.concat(%w[uppercase font-bold]) if size == :lg
            classes
          end

          secondary do |size:, **|
            classes = %w[bg-purple-600 text-white hover:bg-purple-700]
            classes << "px-8" if size == :lg
            classes
          end
        }
      }

      defaults { { size: :md, theme: :primary } }
    end

    def initialize(size: nil, theme: nil)
      @size, @theme = size, theme
    end

    private

    attr_reader :size, :theme
  end
end
```
</pattern>

## Variant Inheritance

<pattern name="inheritance-strategies">
<description>Extend, merge, or override parent component variants</description>

**Base Component:**
```ruby
# app/components/ui/base_card_component.rb
module Ui
  class BaseCardComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    style do
      base { %w[rounded-lg shadow] }

      variants {
        size {
          sm { %w[p-2] }
          md { %w[p-4] }
          lg { %w[p-6] }
        }

        color {
          white { %w[bg-white] }
          gray { %w[bg-gray-100] }
        }
      }

      defaults { { size: :md, color: :white } }
    end

    def initialize(size: nil, color: nil)
      @size = size
      @color = color
    end

    private

    attr_reader :size, :color
  end
end
```

**Override Strategy (Default):**
```ruby
# Completely replaces parent variants
module Ui
  class OverrideCardComponent < BaseCardComponent
    style do
      variants {
        size {
          md { %w[p-5] }  # Overrides parent's md: p-4
          lg { %w[p-8] }  # Overrides parent's lg: p-6
          # sm is removed
        }
        # color variant is completely removed
      }
    end
  end
end
```

**Merge Strategy:**
```ruby
# Deep merges with parent variants
module Ui
  class MergedCardComponent < BaseCardComponent
    style do
      variants(strategy: :merge) {
        size {
          md { %w[p-5] }   # Overrides parent's md
          xl { %w[p-10] }  # Adds new xl variant
          # sm and lg are inherited from parent
        }
        # color variant is fully inherited
      }
    end
  end
end
```

**Extend Strategy:**
```ruby
# Shallow merge - adds new variants, keeps parent's
module Ui
  class ExtendedCardComponent < BaseCardComponent
    style do
      variants(strategy: :extend) {
        size {
          xl { %w[p-10] }  # Adds xl, keeps sm/md/lg from parent unchanged
        }

        bordered {
          yes { %w[border-2 border-gray-300] }
        }
        # Adds entirely new variant group
      }
    end

    def initialize(size: nil, color: nil, bordered: false)
      super(size:, color:)
      @bordered = bordered ? :yes : :no
    end

    private

    attr_reader :bordered
  end
end
```
</pattern>

## Additional Class Composition

<pattern name="custom-classes">
<description>Add additional CSS classes alongside variants</description>

**Component Template:**
```erb
<!-- Can add custom classes via class: parameter -->
<button class="<%= style(size:, theme:, class: 'extra-class hover:scale-105') %>">
  <%= content %>
</button>
```

**Usage:**
```erb
<%= render Ui::ButtonComponent.new(size: :lg, color: :primary) { "Button" } %>
```
</pattern>

## DaisyUI Integration

<pattern name="daisyui-variants">
<description>Use style variants with DaisyUI component classes</description>

**Component Class:**
```ruby
# app/components/ui/daisy_button_component.rb
module Ui
  class DaisyButtonComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    style do
      base { %w[btn] }  # DaisyUI base class

      variants {
        variant {
          primary { "btn-primary" }
          secondary { "btn-secondary" }
          accent { "btn-accent" }
          ghost { "btn-ghost" }
          link { "btn-link" }
        }

        size {
          xs { "btn-xs" }
          sm { "btn-sm" }
          md { "" }  # Default DaisyUI size
          lg { "btn-lg" }
        }

        state {
          loading { "btn-loading" }
          disabled { "btn-disabled" }
          active { "btn-active" }
        }
      }

      defaults {
        { variant: :primary, size: :md }
      }
    end

    def initialize(variant: nil, size: nil, state: nil)
      @variant = variant
      @size = size
      @state = state
    end

    private

    attr_reader :variant, :size, :state
  end
end
```

**Usage:**
```erb
<%= render Ui::DaisyButtonComponent.new(variant: :ghost, size: :lg) { "Ghost" } %>
```
</pattern>

## Antipatterns

<antipatterns>
<antipattern>
<description>Using inline conditionals instead of variant system</description>
<reason>Unreadable and hard to maintain as complexity grows</reason>
<bad-example>
```ruby
# ❌ BAD - Inline conditional class logic
class ButtonComponent < ViewComponent::Base
  def button_classes
    classes = ["font-medium", "rounded-lg"]
    classes += ["bg-blue-600"] if color == :primary
    classes += ["px-4", "py-2"] if size == :md
    classes << "uppercase" if size == :lg && color == :primary
    classes.join(" ")
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Declarative variant system
class ButtonComponent < ViewComponent::Base
  include ViewComponentContrib::StyleVariants

  style do
    base { %w[font-medium rounded-lg] }
    variants {
      color { primary { %w[bg-blue-600 text-white] } }
      size { md { %w[px-4 py-2] } }
    }
    compound(size: :lg, color: :primary) { %w[uppercase font-bold] }
    defaults { { color: :primary, size: :md } }
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not setting defaults for required variants</description>
<reason>Forces explicit variant specification every time</reason>
<bad-example>
```ruby
# ❌ BAD - No defaults
class ButtonComponent < ViewComponent::Base
  include ViewComponentContrib::StyleVariants
  style do
    variants {
      color { primary { %w[bg-blue-600] } }
      size { md { %w[text-base] } }
    }
    # No defaults!
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Sensible defaults
class ButtonComponent < ViewComponent::Base
  include ViewComponentContrib::StyleVariants
  style do
    variants {
      color { primary { %w[bg-blue-600] } }
      size { md { %w[text-base] } }
    }
    defaults { { color: :primary, size: :md } }
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test variant class generation:

```ruby
# test/components/ui/button_component_test.rb
require "test_helper"

class Ui::ButtonComponentTest < ViewComponent::TestCase
  test "applies default variants" do
    render_inline(Ui::ButtonComponent.new) { "Click" }
    assert_selector("button.font-medium.rounded-lg.bg-blue-600.px-4.py-2")
  end

  test "applies custom variants" do
    render_inline(Ui::ButtonComponent.new(color: :danger, size: :lg)) { "Delete" }
    assert_selector("button.bg-red-600.px-6.py-3")
  end

  test "compound variants apply" do
    render_inline(Ui::AdvancedButtonComponent.new(size: :lg, theme: :primary)) { "CTA" }
    assert_selector("button.uppercase.font-bold")
  end

  test "multiple style sets" do
    render_inline(Ui::CardWithImageComponent.new(
      variant: :glass, image_orient: :portrait, image_src: "/test.jpg"
    )) { "Content" }
    assert_selector("div.bg-white\\/80.backdrop-blur-sm")
    assert_selector("img.w-32.h-48")
  end
end

# test/components/feedback_components/status_badge_component_test.rb
require "test_helper"

class FeedbackComponents::StatusBadgeComponentTest < ViewComponent::TestCase
  test "compound variant applies pulse to large pending badges" do
    render_inline(FeedbackComponents::StatusBadgeComponent.new(status: :pending, size: :lg))
    assert_selector("span.font-bold.animate-pulse")
  end
end
```
</testing>

<related-skills>
- viewcomponent-basics: Foundation for building ViewComponents
- viewcomponent-slots: Multi content area components
- tailwind-utility-first: Tailwind CSS utility first approach
- daisyui-components: DaisyUI component system integration
- hotwire-turbo: Dynamic updates with Turbo Frames
</related-skills>

<resources>
- [view_component-contrib](https://github.com/palkan/view_component-contrib)
- [Style Variants Docs](https://github.com/palkan/view_component-contrib#style-variants)
- [ViewComponent](https://viewcomponent.org/)
</resources>
