# ViewComponent Basic Patterns
# Reference: ViewComponent Documentation, Rails 8.1
# Category: FRONTEND - VIEWCOMPONENT

#
# ============================================================================
# What is ViewComponent?
# ============================================================================
#
# ViewComponent is a framework for building reusable, testable, and
# encapsulated view components in Ruby on Rails. It brings a component-based
# architecture to Rails views, similar to React or Vue components.
#
# Key Benefits:
# ✅ Encapsulation - Components are self-contained units
# ✅ Reusability - Build once, use everywhere
# ✅ Testability - Test components in isolation with ViewComponent::TestCase
# ✅ Performance - Up to 10x faster than partials
# ✅ Type Safety - Ruby methods instead of local variables
# ✅ Organization - Clear structure for complex UIs
#
# Rails 8.1 Compatibility:
# - ViewComponent 4.1.0+ required for Rails 8.1
# - Fully compatible with Hotwire (Turbo + Stimulus)
# - Works seamlessly with Tailwind CSS v4 + DaisyUI v5
#

#
# ============================================================================
# ✅ BASIC COMPONENT STRUCTURE
# ============================================================================
#

# Simplest possible component
# app/components/hello_component.rb
class HelloComponent < ViewComponent::Base
  def initialize(name:)
    @name = name
  end
end

# app/components/hello_component.html.erb
# <div class="greeting">
#   Hello, <%= @name %>!
# </div>

# Usage in views:
# <%= render HelloComponent.new(name: "World") %>

#
# ============================================================================
# ✅ COMPONENT WITH CONTENT BLOCK
# ============================================================================
#

# Components can accept content via blocks
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

# app/components/card_component.html.erb
# <div class="<%= card_classes %>">
#   <div class="card-body">
#     <h2 class="card-title"><%= title %></h2>
#     <div class="card-content">
#       <%= content %>
#     </div>
#   </div>
# </div>

# Usage with content block:
# <%= render CardComponent.new(title: "My Card") do %>
#   <p>This is the card content!</p>
# <% end %>

#
# ============================================================================
# ✅ COMPONENT WITH HELPERS
# ============================================================================
#

# Components can define helper methods
# app/components/user_avatar_component.rb
class UserAvatarComponent < ViewComponent::Base
  def initialize(user:, size: :md)
    @user = user
    @size = size
  end

  private

  attr_reader :user, :size

  def avatar_classes
    base = "avatar"
    base += " avatar-#{size}" if size != :md
    base
  end

  def avatar_url
    user.avatar_url || default_avatar_url
  end

  def default_avatar_url
    "https://ui-avatars.com/api/?name=#{CGI.escape(user.name)}&size=#{avatar_size}"
  end

  def avatar_size
    case size
    when :sm then 32
    when :md then 64
    when :lg then 128
    else 64
    end
  end

  def initials
    user.name.split.map(&:first).join.upcase[0, 2]
  end
end

# app/components/user_avatar_component.html.erb
# <div class="<%= avatar_classes %>">
#   <% if avatar_url %>
#     <img src="<%= avatar_url %>" alt="<%= user.name %>" class="rounded-full">
#   <% else %>
#     <div class="placeholder">
#       <div class="bg-neutral text-neutral-content rounded-full w-16">
#         <span><%= initials %></span>
#       </div>
#     </div>
#   <% end %>
# </div>

#
# ============================================================================
# ✅ COMPONENT WITH BEFORE_RENDER HOOK
# ============================================================================
#

# Use before_render for setup logic
# app/components/stats_component.rb
class StatsComponent < ViewComponent::Base
  def initialize(feedbacks:)
    @feedbacks = feedbacks
  end

  def before_render
    @total_count = @feedbacks.count
    @pending_count = @feedbacks.where(status: "pending").count
    @responded_count = @feedbacks.where(status: "responded").count
    @average_rating = @feedbacks.average(:rating).to_f.round(1)
  end

  private

  attr_reader :total_count, :pending_count, :responded_count, :average_rating
end

# app/components/stats_component.html.erb
# <div class="stats shadow">
#   <div class="stat">
#     <div class="stat-title">Total Feedback</div>
#     <div class="stat-value"><%= total_count %></div>
#   </div>
#
#   <div class="stat">
#     <div class="stat-title">Pending</div>
#     <div class="stat-value text-warning"><%= pending_count %></div>
#   </div>
#
#   <div class="stat">
#     <div class="stat-title">Responded</div>
#     <div class="stat-value text-success"><%= responded_count %></div>
#   </div>
#
#   <div class="stat">
#     <div class="stat-title">Avg Rating</div>
#     <div class="stat-value"><%= average_rating %></div>
#   </div>
# </div>

#
# ============================================================================
# ✅ COMPONENT WITH CONDITIONAL RENDERING
# ============================================================================
#

# Use #render? to control when component renders
# app/components/flash_message_component.rb
class FlashMessageComponent < ViewComponent::Base
  def initialize(type:, message:)
    @type = type
    @message = message
  end

  # Only render if message is present
  def render?
    @message.present?
  end

  private

  attr_reader :type, :message

  def alert_class
    base = "alert"
    case type.to_sym
    when :notice, :success
      "#{base} alert-success"
    when :alert, :error
      "#{base} alert-error"
    when :warning
      "#{base} alert-warning"
    else
      "#{base} alert-info"
    end
  end

  def icon
    case type.to_sym
    when :notice, :success
      "✓"
    when :alert, :error
      "✕"
    when :warning
      "⚠"
    else
      "ℹ"
    end
  end
end

# app/components/flash_message_component.html.erb
# <div class="<%= alert_class %>">
#   <span><%= icon %></span>
#   <span><%= message %></span>
# </div>

# Usage:
# <% flash.each do |type, message| %>
#   <%= render FlashMessageComponent.new(type: type, message: message) %>
# <% end %>

#
# ============================================================================
# ✅ COMPONENT WITH DEFAULT PARAMETER VALUES
# ============================================================================
#

# app/components/button_component.rb
class ButtonComponent < ViewComponent::Base
  def initialize(
    variant: :primary,
    size: :md,
    disabled: false,
    loading: false,
    **html_options
  )
    @variant = variant
    @size = size
    @disabled = disabled
    @loading = loading
    @html_options = html_options
  end

  private

  attr_reader :variant, :size, :disabled, :loading, :html_options

  def button_classes
    classes = ["btn"]

    # Variant
    classes << case variant
    when :primary then "btn-primary"
    when :secondary then "btn-secondary"
    when :ghost then "btn-ghost"
    when :outline then "btn-outline"
    else "btn-primary"
    end

    # Size
    classes << case size
    when :xs then "btn-xs"
    when :sm then "btn-sm"
    when :lg then "btn-lg"
    when :xl then "btn-xl"
    else ""
    end

    # Additional classes from html_options
    classes << html_options[:class] if html_options[:class]

    classes.compact.join(" ")
  end

  def button_attributes
    attrs = html_options.except(:class)
    attrs[:disabled] = true if disabled || loading
    attrs
  end
end

# app/components/button_component.html.erb
# <button class="<%= button_classes %>" <%= tag.attributes(button_attributes) %>>
#   <% if loading %>
#     <span class="loading loading-spinner loading-sm"></span>
#   <% end %>
#   <%= content %>
# </button>

# Usage:
# <%= render ButtonComponent.new(variant: :primary, size: :lg) do %>
#   Submit Feedback
# <% end %>
#
# <%= render ButtonComponent.new(variant: :ghost, loading: true) do %>
#   Processing...
# <% end %>

#
# ============================================================================
# ✅ INLINE COMPONENT (ERB TEMPLATE IN RUBY)
# ============================================================================
#

# Small components can define templates inline
# app/components/badge_component.rb
class BadgeComponent < ViewComponent::Base
  erb_template <<~ERB
    <span class="<%= badge_classes %>">
      <%= content %>
    </span>
  ERB

  def initialize(variant: :default, size: :md)
    @variant = variant
    @size = size
  end

  private

  attr_reader :variant, :size

  def badge_classes
    classes = ["badge"]

    classes << case variant
    when :primary then "badge-primary"
    when :secondary then "badge-secondary"
    when :success then "badge-success"
    when :error then "badge-error"
    when :warning then "badge-warning"
    when :info then "badge-info"
    else "badge-neutral"
    end

    classes << case size
    when :xs then "badge-xs"
    when :sm then "badge-sm"
    when :lg then "badge-lg"
    else ""
    end

    classes.compact.join(" ")
  end
end

# Usage:
# <%= render BadgeComponent.new(variant: :success) do %>
#   Active
# <% end %>

#
# ============================================================================
# ✅ COMPONENT WITH HELPERS MODULE
# ============================================================================
#

# Components can include helper modules
# app/components/concerns/formattable.rb
module Formattable
  extend ActiveSupport::Concern

  private

  def format_date(date, format: :short)
    return "" if date.blank?

    case format
    when :short
      date.strftime("%b %d, %Y")
    when :long
      date.strftime("%B %d, %Y at %I:%M %p")
    when :relative
      time_ago_in_words(date) + " ago"
    else
      date.to_s
    end
  end

  def format_currency(amount)
    number_to_currency(amount)
  end
end

# app/components/feedback_card_component.rb
class FeedbackCardComponent < ViewComponent::Base
  include Formattable

  def initialize(feedback:)
    @feedback = feedback
  end

  private

  attr_reader :feedback
end

# app/components/feedback_card_component.html.erb
# <div class="card">
#   <div class="card-body">
#     <p><%= feedback.content %></p>
#     <p class="text-sm text-muted">
#       Submitted <%= format_date(feedback.created_at, format: :relative) %>
#     </p>
#   </div>
# </div>

#
# ============================================================================
# ✅ COMPONENT ORGANIZATION PATTERNS
# ============================================================================
#

# Recommended directory structure:
#
# app/components/
#   ui/                          # Base UI components
#     button_component.rb
#     button_component.html.erb
#     card_component.rb
#     card_component.html.erb
#
#   feedback_components/         # Domain-specific components
#     submission_form_component.rb
#     submission_form_component.html.erb
#     message_card_component.rb
#     message_card_component.html.erb
#
#   layouts/                     # Layout components
#     sidebar_component.rb
#     navbar_component.rb
#
# With sidecar organization (recommended):
#
# app/components/
#   ui/
#     button/
#       component.rb
#       component.html.erb
#       component.css
#       controller.js           # Stimulus controller (optional)
#     card/
#       component.rb
#       component.html.erb

#
# ============================================================================
# ✅ NAMESPACED COMPONENTS
# ============================================================================
#

# Organize components in namespaces
# app/components/ui/alert_component.rb
module Ui
  class AlertComponent < ViewComponent::Base
    def initialize(type: :info, dismissible: false)
      @type = type
      @dismissible = dismissible
    end

    private

    attr_reader :type, :dismissible

    def alert_classes
      classes = ["alert"]
      classes << case type
      when :success then "alert-success"
      when :error then "alert-error"
      when :warning then "alert-warning"
      else "alert-info"
      end
      classes.join(" ")
    end
  end
end

# app/components/ui/alert_component.html.erb
# <div class="<%= alert_classes %>" role="alert">
#   <%= content %>
#   <% if dismissible %>
#     <button class="btn btn-sm btn-circle btn-ghost" aria-label="Close">
#       ✕
#     </button>
#   <% end %>
# </div>

# Usage:
# <%= render Ui::AlertComponent.new(type: :success, dismissible: true) do %>
#   Feedback sent successfully!
# <% end %>

#
# ============================================================================
# RULE: Use ViewComponent for reusable UI elements
# ORGANIZE: Use namespaces (Ui::, FeedbackComponents::, etc.)
# PERFORMANCE: Components are 10x faster than partials
# TEST: Always write component tests with ViewComponent::TestCase
# ENCAPSULATE: Keep component logic self-contained
# SIDECAR: Co-locate CSS/JS with components when needed
# ============================================================================
#
