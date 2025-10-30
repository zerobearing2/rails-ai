# ViewComponent Previews & Collections Comprehensive Patterns
# Reference: ViewComponent Documentation
# Category: FRONTEND - VIEWCOMPONENT

#
# ============================================================================
# What are ViewComponent Previews?
# ============================================================================
#
# Previews provide a way to view and test components in isolation during
# development. Similar to Storybook for React, previews let you see all
# component states without navigating your app.
#
# Benefits:
# ✅ Visual development - See components in isolation
# ✅ State exploration - Preview all variants and states
# ✅ Living documentation - Auto-generated component catalog
# ✅ Testing - Use previews in tests with render_preview
# ✅ Dynamic params - Pass parameters via URL query strings
#
# Preview URL: http://localhost:3000/rails/view_components
#

#
# ============================================================================
# ✅ BASIC PREVIEW SETUP
# ============================================================================
#

# Enable previews in development (config/environments/development.rb):
# config.view_component.previews.enabled = true
# config.view_component.previews.paths << Rails.root.join("test/components/previews")

# Default preview path: test/components/previews/

# Simple preview file
# test/components/previews/button_component_preview.rb
class ButtonComponentPreview < ViewComponent::Preview
  def default
    render(ButtonComponent.new(variant: :primary, size: :md)) do
      "Click Me"
    end
  end

  def secondary_variant
    render(ButtonComponent.new(variant: :secondary, size: :md)) do
      "Secondary Button"
    end
  end

  def large_size
    render(ButtonComponent.new(variant: :primary, size: :lg)) do
      "Large Button"
    end
  end

  def disabled_state
    render(ButtonComponent.new(variant: :primary, disabled: true)) do
      "Disabled Button"
    end
  end

  def loading_state
    render(ButtonComponent.new(variant: :primary, loading: true)) do
      "Loading..."
    end
  end
end

# Access previews:
# http://localhost:3000/rails/view_components/button_component/default
# http://localhost:3000/rails/view_components/button_component/secondary_variant
# http://localhost:3000/rails/view_components/button_component/large_size

#
# ============================================================================
# ✅ PREVIEWS WITH DYNAMIC PARAMETERS
# ============================================================================
#

# Previews can accept parameters from URL query strings
# test/components/previews/alert_component_preview.rb
class AlertComponentPreview < ViewComponent::Preview
  # @param type select { choices: [success, error, warning, info] }
  # @param message text
  def default(type: "success", message: "Operation completed successfully")
    render(Ui::AlertComponent.new(type: type.to_sym)) do
      message
    end
  end

  # @param dismissible toggle
  def with_dismiss_button(dismissible: true)
    render(Ui::AlertComponent.new(type: :info, dismissible: dismissible)) do
      "This alert can be dismissed"
    end
  end
end

# Access with params:
# /rails/view_components/alert_component/default?type=error&message=Something+went+wrong
# /rails/view_components/alert_component/with_dismiss_button?dismissible=false

# Parameter annotations:
# @param name text                  - Text input
# @param count number                - Number input
# @param active toggle               - Checkbox
# @param type select { choices: [...] } - Dropdown
# @param size radio { choices: [...] }  - Radio buttons

#
# ============================================================================
# ✅ PREVIEW WITH CUSTOM LAYOUT
# ============================================================================
#

# Use custom layout for previews
# test/components/previews/modal_component_preview.rb
class ModalComponentPreview < ViewComponent::Preview
  layout "component_preview"

  def default
    render(ModalComponent.new(size: :md, open: true)) do |modal|
      modal.with_header do
        content_tag :h3, "Preview Modal", class: "font-bold text-lg"
      end

      content_tag :p, "This is a modal preview with custom layout."

      modal.with_footer do
        content_tag :button, "Close", class: "btn"
      end
    end
  end
end

# Create custom preview layout:
# app/views/layouts/component_preview.html.erb
# <!DOCTYPE html>
# <html>
# <head>
#   <%= stylesheet_link_tag "application" %>
#   <%= javascript_importmap_tags %>
# </head>
# <body class="p-8">
#   <%= yield %>
# </body>
# </html>

# Configure default preview layout (config/application.rb):
# config.view_component.default_preview_layout = "component_preview"

#
# ============================================================================
# ✅ PREVIEW WITH RENDER_WITH_TEMPLATE
# ============================================================================
#

# Use custom template for complex previews
# test/components/previews/feedback_card_component_preview.rb
class FeedbackCardComponentPreview < ViewComponent::Preview
  def default
    feedback = Struct.new(:id, :content, :status, :sender_name, :created_at).new(
      1,
      "Great product! Would recommend to others.",
      "pending",
      "John Doe",
      2.days.ago
    )

    render_with_template(locals: { feedback: feedback })
  end

  def with_response
    feedback = Struct.new(:id, :content, :status, :sender_name, :created_at, :response).new(
      2,
      "Could be improved in several areas.",
      "responded",
      "Jane Smith",
      5.days.ago,
      "Thank you for your feedback! We're working on improvements."
    )

    render_with_template(locals: { feedback: feedback })
  end
end

# Create preview template:
# test/components/previews/feedback_card_component_preview/default.html.erb
# <div class="max-w-2xl">
#   <%= render FeedbackComponents::CardComponent.new(feedback: feedback) do |card| %>
#     <% card.with_header do %>
#       <h3 class="card-title">From <%= feedback.sender_name %></h3>
#     <% end %>
#
#     <% card.with_metadata do %>
#       <%= time_ago_in_words(feedback.created_at) %> ago
#     <% end %>
#   <% end %>
# </div>

#
# ============================================================================
# ✅ PREVIEW EXAMPLES - ALL STATES
# ============================================================================
#

# Comprehensive preview showing all component states
# test/components/previews/badge_component_preview.rb
class BadgeComponentPreview < ViewComponent::Preview
  def all_variants
    render_with_template
  end
end

# test/components/previews/badge_component_preview/all_variants.html.erb
# <div class="space-y-4">
#   <h2 class="text-2xl font-bold">Badge Variants</h2>
#
#   <div class="flex gap-2 flex-wrap">
#     <%= render BadgeComponent.new(variant: :primary) { "Primary" } %>
#     <%= render BadgeComponent.new(variant: :secondary) { "Secondary" } %>
#     <%= render BadgeComponent.new(variant: :success) { "Success" } %>
#     <%= render BadgeComponent.new(variant: :error) { "Error" } %>
#     <%= render BadgeComponent.new(variant: :warning) { "Warning" } %>
#     <%= render BadgeComponent.new(variant: :info) { "Info" } %>
#   </div>
#
#   <h3 class="text-xl font-bold">Badge Sizes</h3>
#   <div class="flex gap-2 items-center">
#     <%= render BadgeComponent.new(size: :xs) { "Extra Small" } %>
#     <%= render BadgeComponent.new(size: :sm) { "Small" } %>
#     <%= render BadgeComponent.new(size: :md) { "Medium" } %>
#     <%= render BadgeComponent.new(size: :lg) { "Large" } %>
#   </div>
# </div>

#
# ============================================================================
# COLLECTIONS - Rendering Multiple Components
# ============================================================================
#
# Collections allow you to render the same component multiple times with
# different data, optimized for performance.
#
# Benefits:
# ✅ Performance - Faster than rendering in a loop
# ✅ Automatic counter - Access item index automatically
# ✅ Iteration context - first?, last?, index, size
# ✅ Spacer components - Insert separators between items
# ✅ Custom parameters - Pass additional arguments
#

#
# ============================================================================
# ✅ BASIC COLLECTION RENDERING
# ============================================================================
#

# Component designed for collection rendering
# app/components/product_component.rb
class ProductComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end

  attr_reader :product
end

# app/components/product_component.html.erb
# <div class="product-card">
#   <h3><%= product.name %></h3>
#   <p class="price"><%= number_to_currency(product.price) %></p>
# </div>

# Render collection in view:
# <%= render(ProductComponent.with_collection(@products)) %>

# This is equivalent to but more efficient than:
# <% @products.each do |product| %>
#   <%= render ProductComponent.new(product: product) %>
# <% end %>

#
# ============================================================================
# ✅ COLLECTION WITH CUSTOM PARAMETER NAME
# ============================================================================
#

# By default, parameter name is derived from component name
# For ProductComponent, it expects product:

# Customize the parameter name:
# app/components/item_component.rb
class ItemComponent < ViewComponent::Base
  def initialize(record:)  # Custom parameter name
    @record = record
  end

  attr_reader :record
end

# Render with collection_parameter:
# <%= render(ItemComponent.with_collection(@products, collection_parameter: :record)) %>

#
# ============================================================================
# ✅ COLLECTION WITH COUNTER
# ============================================================================
#

# Access the counter variable (0-indexed)
# app/components/numbered_item_component.rb
class NumberedItemComponent < ViewComponent::Base
  def initialize(item:, item_counter:)  # Counter must be in initialize
    @item = item
    @counter = item_counter
  end

  attr_reader :item, :counter
end

# app/components/numbered_item_component.html.erb
# <li>
#   <span class="number"><%= @counter + 1 %>.</span>
#   <%= @item.name %>
# </li>

# Render collection:
# <ol>
#   <%= render(NumberedItemComponent.with_collection(@items)) %>
# </ol>

#
# ============================================================================
# ✅ COLLECTION WITH ITERATION CONTEXT
# ============================================================================
#

# Access full iteration context
# app/components/feedback_item_component.rb
class FeedbackItemComponent < ViewComponent::Base
  def initialize(feedback:, feedback_iteration:)
    @feedback = feedback
    @iteration = feedback_iteration
  end

  attr_reader :feedback, :iteration

  def item_classes
    classes = ["feedback-item"]
    classes << "first" if @iteration.first?
    classes << "last" if @iteration.last?
    classes << "even" if @iteration.index.even?
    classes << "odd" if @iteration.index.odd?
    classes.join(" ")
  end
end

# app/components/feedback_item_component.html.erb
# <div class="<%= item_classes %>">
#   <p><%= feedback.content %></p>
#   <small>
#     Item <%= @iteration.index + 1 %> of <%= @iteration.size %>
#   </small>
# </div>

# Iteration object provides:
# - index: Current index (0-based)
# - size: Total number of items
# - first?: Is this the first item?
# - last?: Is this the last item?

#
# ============================================================================
# ✅ COLLECTION WITH ADDITIONAL ARGUMENTS
# ============================================================================
#

# Pass additional arguments to all items
# app/components/card_item_component.rb
class CardItemComponent < ViewComponent::Base
  def initialize(item:, show_actions: false, highlight: false)
    @item = item
    @show_actions = show_actions
    @highlight = highlight
  end

  attr_reader :item, :show_actions, :highlight
end

# Render with additional args:
# <%= render(CardItemComponent.with_collection(@items, show_actions: true, highlight: false)) %>

#
# ============================================================================
# ✅ COLLECTION WITH SPACER COMPONENT
# ============================================================================
#

# Insert separator component between items
# app/components/divider_component.rb
class DividerComponent < ViewComponent::Base
  erb_template <<~ERB
    <hr class="divider" />
  ERB
end

# Render with spacer:
# <%= render(
#   ProductComponent.with_collection(@products, spacer_component: DividerComponent.new)
# ) %>

# Result:
# <product 1>
# <divider>
# <product 2>
# <divider>
# <product 3>

#
# ============================================================================
# ✅ COLLECTION PREVIEW
# ============================================================================
#

# Preview component with collection
# test/components/previews/feedback_item_component_preview.rb
class FeedbackItemComponentPreview < ViewComponent::Preview
  def collection
    feedbacks = [
      Struct.new(:id, :content, :status, :created_at).new(
        1, "Great service!", "pending", 1.day.ago
      ),
      Struct.new(:id, :content, :status, :created_at).new(
        2, "Could be better", "reviewed", 2.days.ago
      ),
      Struct.new(:id, :content, :status, :created_at).new(
        3, "Excellent experience", "responded", 3.days.ago
      )
    ]

    render(FeedbackItemComponent.with_collection(feedbacks))
  end

  def with_spacer
    feedbacks = [
      Struct.new(:id, :content).new(1, "First feedback"),
      Struct.new(:id, :content).new(2, "Second feedback"),
      Struct.new(:id, :content).new(3, "Third feedback")
    ]

    render(
      FeedbackItemComponent.with_collection(
        feedbacks,
        spacer_component: DividerComponent.new
      )
    )
  end
end

#
# ============================================================================
# ✅ REAL-WORLD EXAMPLE: FEEDBACK LIST WITH COLLECTION
# ============================================================================
#

# app/components/feedback_components/list_component.rb
module FeedbackComponents
  class ListComponent < ViewComponent::Base
    def initialize(feedbacks:, show_actions: true)
      @feedbacks = feedbacks
      @show_actions = show_actions
    end

    attr_reader :feedbacks, :show_actions

    def empty_state?
      feedbacks.empty?
    end
  end
end

# app/components/feedback_components/list_component.html.erb
# <div class="feedback-list">
#   <% if empty_state? %>
#     <div class="empty-state">
#       <p>No feedback yet.</p>
#     </div>
#   <% else %>
#     <%= render(
#       FeedbackComponents::ItemComponent.with_collection(
#         feedbacks,
#         show_actions: show_actions
#       )
#     ) %>
#   <% end %>
# </div>

# app/components/feedback_components/item_component.rb
module FeedbackComponents
  class ItemComponent < ViewComponent::Base
    def initialize(feedback:, feedback_counter:, show_actions: false)
      @feedback = feedback
      @counter = feedback_counter
      @show_actions = show_actions
    end

    attr_reader :feedback, :counter, :show_actions

    def status_variant
      case feedback.status
      when "pending" then :warning
      when "reviewed" then :info
      when "responded" then :success
      else :neutral
      end
    end
  end
end

# app/components/feedback_components/item_component.html.erb
# <div class="feedback-item" data-feedback-id="<%= feedback.id %>">
#   <div class="feedback-content">
#     <span class="feedback-number">#<%= counter + 1 %></span>
#     <p><%= feedback.content %></p>
#
#     <%= render Ui::BadgeComponent.new(variant: status_variant) do %>
#       <%= feedback.status.titleize %>
#     <% end %>
#   </div>
#
#   <% if show_actions %>
#     <div class="feedback-actions">
#       <%= link_to "View", feedback_path(feedback), class: "btn btn-sm btn-primary" %>
#       <%= link_to "Edit", edit_feedback_path(feedback), class: "btn btn-sm btn-ghost" %>
#     </div>
#   <% end %>
# </div>

# Usage in views:
# <%= render FeedbackComponents::ListComponent.new(
#   feedbacks: @feedbacks,
#   show_actions: current_user&.admin?
# ) %>

#
# ============================================================================
# ✅ PREVIEW FOR LIST COMPONENT
# ============================================================================
#

# test/components/previews/feedback_components/list_component_preview.rb
module FeedbackComponents
  class ListComponentPreview < ViewComponent::Preview
    def default
      feedbacks = sample_feedbacks
      render(ListComponent.new(feedbacks: feedbacks, show_actions: true))
    end

    def empty_state
      render(ListComponent.new(feedbacks: [], show_actions: false))
    end

    def without_actions
      feedbacks = sample_feedbacks
      render(ListComponent.new(feedbacks: feedbacks, show_actions: false))
    end

    private

    def sample_feedbacks
      [
        Struct.new(:id, :content, :status, :created_at).new(
          1,
          "The new feature is working great! Thank you for implementing it so quickly.",
          "responded",
          2.days.ago
        ),
        Struct.new(:id, :content, :status, :created_at).new(
          2,
          "I found a small bug in the export functionality. It doesn't handle special characters.",
          "reviewed",
          1.day.ago
        ),
        Struct.new(:id, :content, :status, :created_at).new(
          3,
          "Would love to see dark mode support in the next update!",
          "pending",
          3.hours.ago
        )
      ]
    end
  end
end

#
# ============================================================================
# RULE: Use previews for visual development and testing
# ACCESS: Previews at /rails/view_components in development
# DYNAMIC: Use @param annotations for interactive previews
# COLLECTIONS: Use with_collection for rendering multiple items
# ITERATION: Access counter and iteration context in components
# SPACER: Use spacer_component to insert separators
# ============================================================================
#
