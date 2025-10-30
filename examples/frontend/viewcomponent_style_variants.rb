# ViewComponent Style Variants Comprehensive Patterns
# Reference: view_component-contrib (palkan/view_component-contrib)
# Category: FRONTEND - VIEWCOMPONENT

#
# ============================================================================
# What are Style Variants?
# ============================================================================
#
# Style Variants provide a structured way to manage component styling with
# Tailwind CSS, similar to CVA (Class Variance Authority) in React or
# Stitches in JavaScript. It's provided by the view_component-contrib gem.
#
# Installation:
# gem "view_component-contrib"
#
# Benefits:
# ✅ Declarative - Define variants in a clean DSL
# ✅ Type-safe - Variants are defined upfront
# ✅ Composable - Combine multiple variants
# ✅ Defaults - Set default variant values
# ✅ Compound variants - Complex variant combinations
# ✅ Tailwind-optimized - Built for Tailwind CSS
#
# Note: This is an optional advanced pattern. Standard component classes
# work perfectly fine for most use cases.
#

#
# ============================================================================
# ✅ BASIC STYLE VARIANTS
# ============================================================================
#

# app/components/ui/button_component.rb
module Ui
  class ButtonComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    style do
      base {
        %w[
          font-medium
          rounded-lg
          transition-colors
          duration-200
        ]
      }

      variants {
        color {
          primary { %w[bg-blue-600 text-white hover:bg-blue-700] }
          secondary { %w[bg-purple-600 text-white hover:bg-purple-700] }
          danger { %w[bg-red-600 text-white hover:bg-red-700] }
        }

        size {
          sm { %w[px-3 py-1.5 text-sm] }
          md { %w[px-4 py-2 text-base] }
          lg { %w[px-6 py-3 text-lg] }
        }
      }

      defaults {
        { color: :primary, size: :md }
      }
    end

    def initialize(color: nil, size: nil, disabled: false)
      @color = color
      @size = size
      @disabled = disabled
    end

    private

    attr_reader :color, :size, :disabled
  end
end

# app/components/ui/button_component.html.erb
# <button class="<%= style(color:, size:) %>" <%= "disabled" if disabled %>>
#   <%= content %>
# </button>

# Usage:
# <%= render Ui::ButtonComponent.new(color: :primary, size: :lg) do %>
#   Click Me
# <% end %>
#
# Renders with classes:
# "font-medium rounded-lg transition-colors duration-200 bg-blue-600 text-white hover:bg-blue-700 px-6 py-3 text-lg"

#
# ============================================================================
# ✅ COMPOUND VARIANTS
# ============================================================================
#

# Complex styling based on variant combinations
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
          no { %w[hover:shadow-md] }
        }
      }

      # Compound variants - Apply when specific combination is used
      compound(size: :lg, theme: :primary) {
        %w[uppercase font-bold]
      }

      compound(theme: :outline, disabled: :no) {
        %w[border-blue-600 text-blue-600 hover:bg-blue-50]
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

    attr_reader :size, :theme, :disabled
  end
end

#
# ============================================================================
# ✅ DEPENDENT STYLES WITH RUBY BLOCKS
# ============================================================================
#

# Dynamic styling with Ruby logic
# app/components/ui/dynamic_button_component.rb
module Ui
  class DynamicButtonComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    style do
      variants {
        size {
          sm { "text-sm" }
          md { "text-base" }
          lg { "px-4 py-3 text-lg" }
        }

        theme {
          # Ruby block receives all variant values
          primary do |size:, **|
            %w[bg-blue-500 text-white].tap do |classes|
              classes << "uppercase" if size == :lg
              classes << "font-bold" if size == :lg
            end
          end

          secondary { %w[bg-purple-500 text-white] }
        }
      }
    end

    def initialize(size: :md, theme: :primary)
      @size = size
      @theme = theme
    end

    attr_reader :size, :theme
  end
end

# Usage:
# <%= render Ui::DynamicButtonComponent.new(size: :lg, theme: :primary) do %>
#   Large Primary
# <% end %>
# Result includes "uppercase font-bold" because size is :lg

#
# ============================================================================
# ✅ MULTIPLE STYLE SETS
# ============================================================================
#

# Define multiple independent style sets for different elements
# app/components/ui/card_with_image_component.rb
module Ui
  class CardWithImageComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    # Default component styles for the card container
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

    # Separate style set for the image
    style :image do
      variants {
        orient {
          portrait { %w[w-32 h-48 object-cover] }
          landscape { %w[w-64 h-32 object-cover] }
          square { %w[w-32 h-32 object-cover] }
        }
      }

      defaults { { orient: :landscape } }
    end

    def initialize(variant: nil, image_orient: nil)
      @variant = variant
      @image_orient = image_orient
    end

    attr_reader :variant, :image_orient
  end
end

# app/components/ui/card_with_image_component.html.erb
# <div class="<%= style(variant:) %>">
#   <img src="..." class="<%= style(:image, orient: image_orient) %>">
#   <div class="p-4">
#     <%= content %>
#   </div>
# </div>

# Usage:
# <%= render Ui::CardWithImageComponent.new(variant: :glass, image_orient: :portrait) do %>
#   Card content
# <% end %>

#
# ============================================================================
# ✅ CUSTOM CSS CLASSES
# ============================================================================
#

# Add additional classes alongside variants
# Usage in template:
# <button class="<%= style(size:, theme:, class: 'extra-class another-class') %>">

# The `class:` parameter merges additional classes with variant classes

#
# ============================================================================
# ✅ STYLE VARIANT INHERITANCE
# ============================================================================
#

# Parent component with base variants
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
  end
end

# Child component - OVERRIDE strategy (default)
# Completely replaces parent variants
module Ui
  class OverrideCardComponent < BaseCardComponent
    style do
      variants {
        size {
          md { %w[p-5] }  # Overrides parent's md: p-4
          lg { %w[p-8] }  # Overrides parent's lg: p-6
        }
        # color variant is completely removed
      }
    end
  end
end

# Child component - MERGE strategy
# Deep merges with parent variants
module Ui
  class MergedCardComponent < BaseCardComponent
    style do
      variants(strategy: :merge) {
        size {
          md { %w[p-5] }  # Overrides parent's md
          xl { %w[p-10] } # Adds new xl variant
        }
        # color variant is inherited
      }
    end
  end
end

# Child component - EXTEND strategy
# Shallow merge, adds new variants but keeps parent's
module Ui
  class ExtendedCardComponent < BaseCardComponent
    style do
      variants(strategy: :extend) {
        size {
          xl { %w[p-10] }  # Adds xl, keeps sm/md/lg from parent
        }
        bordered {
          yes { %w[border-2 border-gray-300] }
        }
      }
    end
  end
end

#
# ============================================================================
# ✅ CUSTOM POSTPROCESSING (TailwindMerge-like)
# ============================================================================
#

# Apply custom postprocessing to optimize class list
# app/components/ui/optimized_button_component.rb
module Ui
  class OptimizedButtonComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    # Custom postprocessor to remove duplicate/conflicting classes
    style_config.postprocess_with do |classes|
      # classes is an array of CSS classes
      # You can use a library like tailwind_merge gem here
      # or implement custom logic to remove conflicts

      # Example: Simple deduplication
      classes.uniq.join(" ")
    end

    style do
      base { %w[font-medium rounded] }
      variants {
        color {
          primary { %w[bg-blue-600 text-white] }
        }
      }
    end
  end
end

#
# ============================================================================
# ✅ REAL-WORLD EXAMPLE: FEEDBACK STATUS BADGE
# ============================================================================
#

# app/components/feedback_components/status_badge_component.rb
module FeedbackComponents
  class StatusBadgeComponent < ViewComponent::Base
    include ViewComponentContrib::StyleVariants

    style do
      base {
        %w[
          inline-flex
          items-center
          rounded-full
          px-3
          py-1
          font-medium
          transition-colors
        ]
      }

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
          yes { %w[pl-2] }  # Extra padding for icon
          no { %w[] }
        }
      }

      # Make large badges bold
      compound(size: :lg) {
        %w[font-bold]
      }

      # Pending large badges get pulse animation
      compound(status: :pending, size: :lg) {
        %w[animate-pulse]
      }

      defaults {
        { size: :md, with_icon: :no }
      }
    end

    def initialize(status:, size: nil, with_icon: false)
      @status = status.to_sym
      @size = size
      @with_icon = with_icon ? :yes : :no
    end

    attr_reader :status, :size, :with_icon

    def icon
      case status
      when :pending then "⏳"
      when :reviewed then "👀"
      when :responded then "✓"
      when :archived then "📦"
      end
    end
  end
end

# app/components/feedback_components/status_badge_component.html.erb
# <span class="<%= style(status:, size:, with_icon:) %>">
#   <% if with_icon == :yes %>
#     <span class="mr-1"><%= icon %></span>
#   <% end %>
#   <%= content || status.to_s.titleize %>
# </span>

# Usage:
# <%= render FeedbackComponents::StatusBadgeComponent.new(status: :pending, size: :lg, with_icon: true) %>
# <%= render FeedbackComponents::StatusBadgeComponent.new(status: :responded) %>

#
# ============================================================================
# ✅ TESTING STYLE VARIANTS
# ============================================================================
#

require "test_helper"

class Ui::ButtonComponentTest < ViewComponent::TestCase
  def test_applies_default_variants
    render_inline(Ui::ButtonComponent.new) { "Click" }

    # Should have base classes
    assert_selector("button.font-medium.rounded-lg")

    # Should have default color (primary)
    assert_selector("button.bg-blue-600")

    # Should have default size (md)
    assert_selector("button.px-4.py-2")
  end

  def test_applies_custom_variants
    render_inline(Ui::ButtonComponent.new(color: :danger, size: :lg)) { "Delete" }

    assert_selector("button.bg-red-600")
    assert_selector("button.px-6.py-3.text-lg")
  end

  def test_compound_variants_apply
    render_inline(Ui::AdvancedButtonComponent.new(size: :lg, theme: :primary)) { "Large Primary" }

    # Should have uppercase from compound variant
    assert_selector("button.uppercase.font-bold")
  end
end

#
# ============================================================================
# ✅ WITHOUT STYLE VARIANTS (STANDARD APPROACH)
# ============================================================================
#

# You don't need style variants for simple components.
# Standard approach works great:

# app/components/ui/simple_badge_component.rb
module Ui
  class SimpleBadgeComponent < ViewComponent::Base
    def initialize(variant: :default)
      @variant = variant
    end

    private

    attr_reader :variant

    def badge_classes
      classes = ["badge"]

      classes << case variant
      when :primary then "badge-primary"
      when :secondary then "badge-secondary"
      when :success then "badge-success"
      else "badge-neutral"
      end

      classes.join(" ")
    end
  end
end

# This is perfectly valid and often simpler for basic components!
# Use Style Variants when:
# - You have complex variant combinations
# - You need compound variants
# - You want a declarative DSL
# - You're building a design system

#
# ============================================================================
# ✅ STYLE VARIANTS WITH DAISYUI
# ============================================================================
#

# Using DaisyUI component classes with style variants
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

    attr_reader :variant, :size, :state
  end
end

# Usage:
# <%= render Ui::DaisyButtonComponent.new(variant: :ghost, size: :lg) do %>
#   Ghost Button
# <% end %>

#
# ============================================================================
# RULE: Use style variants for complex variant management
# OPTIONAL: Standard class methods work great for simple cases
# DECLARATIVE: Define variants upfront with clear structure
# COMPOUND: Use compound variants for complex combinations
# INHERITANCE: Leverage inheritance strategies (override, merge, extend)
# TAILWIND: Optimized for Tailwind CSS class composition
# ============================================================================
#
