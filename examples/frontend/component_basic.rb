# Example: Basic ViewComponent with DaisyUI
# Reference: frontend/component_basic

module Ui
  class ButtonComponent < ViewComponent::Base
    def initialize(variant: :primary, size: :md, **options)
      @variant = variant
      @size = size
      @options = options
    end

    private

    attr_reader :variant, :size, :options

    def component_classes
      [
        "btn",                    # DaisyUI base class
        variant_class,            # btn-primary, btn-secondary, etc.
        size_class                # btn-sm, btn-md, btn-lg
      ].compact.join(" ")
    end

    def variant_class
      case variant
      when :primary then "btn-primary"
      when :secondary then "btn-secondary"
      when :accent then "btn-accent"
      when :ghost then "btn-ghost"
      when :link then "btn-link"
      when :error then "btn-error"
      when :warning then "btn-warning"
      when :success then "btn-success"
      when :info then "btn-info"
      end
    end

    def size_class
      case size
      when :xs then "btn-xs"
      when :sm then "btn-sm"
      when :lg then "btn-lg"
      else nil  # :md is default, no class needed
      end
    end
  end
end

# Template: app/components/ui/button_component.html.erb
# <button class="<%= component_classes %>" <%= tag.attributes(options) %>>
#   <%= content %>
# </button>

# Usage:
# <%= render Ui::ButtonComponent.new(variant: :primary, size: :lg) do %>
#   Submit Feedback
# <% end %>

# Test: test/components/ui/button_component_test.rb
# require "test_helper"
#
# class Ui::ButtonComponentTest < ViewComponent::TestCase
#   def test_renders_with_primary_variant
#     render_inline(Ui::ButtonComponent.new(variant: :primary)) { "Click Me" }
#
#     assert_selector "button.btn.btn-primary", text: "Click Me"
#   end
# end

# Key Patterns Demonstrated:
# 1. Clean initialization with defaults
# 2. DaisyUI class wrapping
# 3. Private helper methods
# 4. Options pass-through with **options
# 5. Slot-based content with block
