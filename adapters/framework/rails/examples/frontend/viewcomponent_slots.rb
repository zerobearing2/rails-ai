# ViewComponent Slots Comprehensive Patterns
# Reference: ViewComponent Slots Documentation
# Category: FRONTEND - VIEWCOMPONENT

#
# ============================================================================
# What are Slots in ViewComponent?
# ============================================================================
#
# Slots allow components to accept multiple named content areas, similar to
# named yields in layouts or slots in Vue/React. They provide a way to pass
# structured content to components.
#
# Slot Types:
# - renders_one: Single slot (e.g., header, footer)
# - renders_many: Collection of slots (e.g., items, tabs)
# - Polymorphic slots: Slots that can render different component types
#
# Benefits:
# ✅ Structured content - Multiple named areas
# ✅ Type safety - Slots can specify component types
# ✅ Flexibility - Polymorphic slots for variants
# ✅ Predicate methods - Check if slot is present with slot_name?
# ✅ Block support - Slots can accept blocks
#

#
# ============================================================================
# ✅ BASIC SLOTS - renders_one
# ============================================================================
#

# Single slot for one piece of content
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

# app/components/modal_component.html.erb
# <dialog class="<%= modal_classes %>">
#   <div class="<%= modal_box_classes %>">
#     <% if header? %>
#       <div class="modal-header">
#         <%= header %>
#       </div>
#     <% end %>
#
#     <div class="modal-body py-4">
#       <%= content %>
#     </div>
#
#     <% if footer? %>
#       <div class="modal-footer modal-action">
#         <%= footer %>
#       </div>
#     <% end %>
#   </div>
# </dialog>

# Usage:
# <%= render ModalComponent.new(size: :lg) do |modal| %>
#   <% modal.with_header do %>
#     <h3 class="font-bold text-lg">Feedback Details</h3>
#   <% end %>
#
#   <p>This is the modal content</p>
#
#   <% modal.with_footer do %>
#     <%= render Ui::ButtonComponent.new(variant: :primary) { "Close" } %>
#   <% end %>
# <% end %>

#
# ============================================================================
# ✅ COLLECTION SLOTS - renders_many
# ============================================================================
#

# Multiple slots for collections
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

# app/components/tab_container_component.html.erb
# <div role="tablist" class="tabs tabs-bordered">
#   <% tabs.each do |tab| %>
#     <%= tab %>
#   <% end %>
# </div>

# Usage:
# <%= render TabContainerComponent.new do |c| %>
#   <% c.with_tab(name: "Overview", active: true) do %>
#     Overview Content
#   <% end %>
#   <% c.with_tab(name: "Details") do %>
#     Details Content
#   <% end %>
#   <% c.with_tab(name: "Settings") do %>
#     Settings Content
#   <% end %>
# <% end %>

#
# ============================================================================
# ✅ NESTED COMPONENT SLOTS
# ============================================================================
#

# Slots can render other ViewComponents
# app/components/blog_component.rb
class BlogComponent < ViewComponent::Base
  # Nested component defined as string (since it's in same file)
  renders_one :header, "HeaderComponent"

  # External component referenced by class
  renders_many :posts, PostComponent

  class HeaderComponent < ViewComponent::Base
    def initialize(classes: "")
      @classes = classes
    end

    attr_reader :classes

    def call
      content_tag :h1, content, class: classes
    end
  end
end

# app/components/post_component.rb
class PostComponent < ViewComponent::Base
  def initialize(title:, classes: "")
    @title = title
    @classes = classes
  end

  attr_reader :title, :classes
end

# app/components/post_component.html.erb
# <article class="<%= classes %>">
#   <h2><%= title %></h2>
#   <%= content %>
# </article>

# app/components/blog_component.html.erb
# <% if header? %>
#   <%= header %>
# <% end %>
#
# <% if posts? %>
#   <div class="posts">
#     <% posts.each do |post| %>
#       <%= post %>
#     <% end %>
#   </div>
# <% else %>
#   <p>No posts yet.</p>
# <% end %>

# Usage:
# <%= render BlogComponent.new do |blog| %>
#   <% blog.with_header(classes: "text-4xl font-bold") do %>
#     <%= link_to "My Blog", root_path %>
#   <% end %>
#
#   <% blog.with_post(title: "First Post", classes: "mb-4") do %>
#     Really interesting content.
#   <% end %>
#
#   <% blog.with_post(title: "Second Post", classes: "mb-4") do %>
#     Even more interesting!
#   <% end %>
# <% end %>

#
# ============================================================================
# ✅ POLYMORPHIC SLOTS
# ============================================================================
#

# Slots that can render different component types
# app/components/list_item_component.rb
class ListItemComponent < ViewComponent::Base
  renders_one :visual, types: {
    icon: IconComponent,
    avatar: lambda { |**system_arguments|
      AvatarComponent.new(size: 16, **system_arguments)
    }
  }

  def initialize(title:)
    @title = title
  end

  attr_reader :title
end

# app/components/icon_component.rb
class IconComponent < ViewComponent::Base
  def initialize(icon:, size: :md)
    @icon = icon
    @size = size
  end

  attr_reader :icon, :size

  def icon_classes
    case size
    when :sm
      "w-4 h-4"
    when :lg
      "w-8 h-8"
    else
      "w-6 h-6"
    end
  end
end

# app/components/avatar_component.rb
class AvatarComponent < ViewComponent::Base
  def initialize(src:, alt: "", size: 64)
    @src = src
    @alt = alt
    @size = size
  end

  attr_reader :src, :alt, :size
end

# app/components/list_item_component.html.erb
# <li class="flex items-center gap-2">
#   <% if visual? %>
#     <%= visual %>
#   <% end %>
#   <span><%= title %></span>
# </li>

# Usage - With icon:
# <%= render ListItemComponent.new(title: "Settings") do |item| %>
#   <% item.with_visual_icon(icon: :gear) %>
# <% end %>

# Usage - With avatar:
# <%= render ListItemComponent.new(title: "Profile") do |item| %>
#   <% item.with_visual_avatar(src: "avatar.jpg", alt: "User") %>
# <% end %>

#
# ============================================================================
# ✅ POLYMORPHIC SLOTS WITH CUSTOM NAMES
# ============================================================================
#

# Customize polymorphic slot setter names
# app/components/nav_item_component.rb
class NavItemComponent < ViewComponent::Base
  renders_one :leading_visual, types: {
    icon: {
      renders: IconComponent,
      as: :icon_visual
    },
    avatar: {
      renders: lambda { |**args| AvatarComponent.new(size: 24, **args) },
      as: :avatar_visual
    }
  }

  def initialize(label:, href:)
    @label = label
    @href = href
  end

  attr_reader :label, :href
end

# Usage with custom setter names:
# <%= render NavItemComponent.new(label: "Home", href: "/") do |item| %>
#   <% item.with_icon_visual(icon: :home) %>
# <% end %>
#
# <%= render NavItemComponent.new(label: "Profile", href: "/profile") do |item| %>
#   <% item.with_avatar_visual(src: "user.jpg") %>
# <% end %>

#
# ============================================================================
# ✅ LAMBDA SLOTS
# ============================================================================
#

# Slots can use lambdas for simple cases
# app/components/card_advanced_component.rb
class CardAdvancedComponent < ViewComponent::Base
  # Lambda slot returning HTML
  renders_one :header, ->(classes: "") do
    content_tag :h1, content, class: "card-title #{classes}"
  end

  # Lambda slot with block
  renders_one :footer, ->(classes: "", &block) do
    content_tag :div, class: "card-actions #{classes}", &block
  end

  # Lambda slot with access to parent state
  renders_many :actions, lambda { |**options|
    ButtonComponent.new(**options.merge(size: @button_size))
  }

  def initialize(title: nil, button_size: :md)
    @title = title
    @button_size = button_size
  end

  attr_reader :title, :button_size
end

# Usage:
# <%= render CardAdvancedComponent.new do |card| %>
#   <% card.with_header(classes: "text-2xl") do %>
#     Card Title
#   <% end %>
#
#   <p>Card body content</p>
#
#   <% card.with_footer(classes: "justify-end") do %>
#     <%= render ButtonComponent.new(variant: :ghost) { "Cancel" } %>
#     <%= render ButtonComponent.new(variant: :primary) { "Submit" } %>
#   <% end %>
# <% end %>

#
# ============================================================================
# ✅ SLOT PREDICATE METHODS
# ============================================================================
#

# Check if slot is present with slot_name?
# app/components/page_header_component.rb
class PageHeaderComponent < ViewComponent::Base
  renders_one :title
  renders_one :subtitle
  renders_many :actions

  def initialize(breadcrumbs: [])
    @breadcrumbs = breadcrumbs
  end

  attr_reader :breadcrumbs
end

# app/components/page_header_component.html.erb
# <header class="page-header">
#   <% if breadcrumbs.any? %>
#     <nav class="breadcrumbs">
#       <%= breadcrumbs.join(" / ") %>
#     </nav>
#   <% end %>
#
#   <div class="header-content">
#     <div class="header-text">
#       <% if title? %>
#         <%= title %>
#       <% end %>
#
#       <% if subtitle? %>
#         <div class="subtitle">
#           <%= subtitle %>
#         </div>
#       <% end %>
#     </div>
#
#     <% if actions? %>
#       <div class="header-actions">
#         <% actions.each do |action| %>
#           <%= action %>
#         <% end %>
#       </div>
#     <% end %>
#   </div>
# </header>

# Usage:
# <%= render PageHeaderComponent.new(breadcrumbs: ["Home", "Feedbacks"]) do |c| %>
#   <% c.with_title { content_tag :h1, "Feedback List" } %>
#   <% c.with_subtitle { "Manage all feedback submissions" } %>
#   <% c.with_action { render ButtonComponent.new { "New Feedback" } } %>
#   <% c.with_action { render ButtonComponent.new(variant: :ghost) { "Export" } } %>
# <% end %>

#
# ============================================================================
# ✅ SLOT CONTENT WITH #with_content
# ============================================================================
#

# Set slot content without a block
# Usage of with_SLOT_NAME_content method:
# <%= render BlogComponent.new.with_header_content("My Blog") %>

# Or with arguments:
# <%= render ModalComponent.new do |modal| %>
#   <% modal.with_header(classes: "text-2xl").with_content("Modal Title") %>
#   <p>Modal body</p>
# <% end %>

#
# ============================================================================
# ✅ ACCESSING SLOT CONTENT IN before_render
# ============================================================================
#

# Access slot content in before_render hook
# app/components/gallery_component.rb
class GalleryComponent < ViewComponent::Base
  renders_one :featured_image
  renders_many :images

  def before_render
    # Set CSS class based on whether featured image is present
    @gallery_classes = "gallery"
    @gallery_classes += " gallery--with-featured" if featured_image.present?

    # Count images
    @image_count = images.size
  end

  attr_reader :gallery_classes, :image_count
end

# app/components/gallery_component.html.erb
# <div class="<%= gallery_classes %>">
#   <% if featured_image? %>
#     <div class="featured">
#       <%= featured_image %>
#     </div>
#   <% end %>
#
#   <div class="images-grid">
#     <% images.each do |image| %>
#       <%= image %>
#     <% end %>
#   </div>
#
#   <p class="image-count"><%= image_count %> images</p>
# </div>

#
# ============================================================================
# ✅ COLLECTION SLOT WITH ARRAY INPUT
# ============================================================================
#

# Pass collection as array to renders_many slot
# app/components/navigation_component.rb
class NavigationComponent < ViewComponent::Base
  renders_many :links, "LinkComponent"

  class LinkComponent < ViewComponent::Base
    def initialize(name:, href:)
      @name = name
      @href = href
    end

    attr_reader :name, :href
  end
end

# app/components/navigation_component.html.erb
# <nav class="menu">
#   <% links.each do |link| %>
#     <%= link_to link.name, link.href, class: "menu-item" %>
#   <% end %>
# </nav>

# Usage with array:
# <%= render NavigationComponent.new do |nav| %>
#   <% nav.with_links([
#     { name: "Home", href: "/" },
#     { name: "Feedbacks", href: "/feedbacks" },
#     { name: "About", href: "/about" }
#   ]) %>
# <% end %>

# Or with individual items:
# <%= render NavigationComponent.new do |nav| %>
#   <% nav.with_link(name: "Home", href: "/") %>
#   <% nav.with_link(name: "Feedbacks", href: "/feedbacks") %>
#   <% nav.with_link(name: "About", href: "/about") %>
# <% end %>

#
# ============================================================================
# ✅ DEFAULT SLOT VALUES
# ============================================================================
#

# Provide default values for slots
# app/components/panel_component.rb
class PanelComponent < ViewComponent::Base
  renders_one :header

  def default_header
    content_tag :h3, "Default Panel Title", class: "panel-title"
  end
end

# app/components/panel_component.html.erb
# <div class="panel">
#   <div class="panel-header">
#     <%= header %>
#   </div>
#   <div class="panel-body">
#     <%= content %>
#   </div>
# </div>

# Default header renders if no header slot provided:
# <%= render PanelComponent.new do %>
#   Panel body content
# <% end %>
# Renders with "Default Panel Title"

# Override with custom header:
# <%= render PanelComponent.new do |panel| %>
#   <% panel.with_header do %>
#     <h3>Custom Title</h3>
#   <% end %>
#   Panel body content
# <% end %>

#
# ============================================================================
# ✅ DEFAULT SLOT COMPONENT INSTANCE
# ============================================================================
#

# Return component instance as default
# app/components/container_component.rb
class ContainerComponent < ViewComponent::Base
  renders_one :icon

  def default_icon
    IconComponent.new(icon: :info, size: :md)
  end
end

#
# ============================================================================
# ✅ REAL-WORLD EXAMPLE: FEEDBACK CARD WITH SLOTS
# ============================================================================
#

# app/components/feedback_components/card_component.rb
module FeedbackComponents
  class CardComponent < ViewComponent::Base
    renders_one :header
    renders_one :metadata
    renders_many :actions

    def initialize(feedback:, variant: :default)
      @feedback = feedback
      @variant = variant
    end

    attr_reader :feedback, :variant

    def card_classes
      base = "card bg-base-100 shadow-lg"
      base += " card-bordered" if variant == :bordered
      base
    end

    def status_badge_variant
      case feedback.status
      when "pending" then :warning
      when "reviewed" then :info
      when "responded" then :success
      else :neutral
      end
    end
  end
end

# app/components/feedback_components/card_component.html.erb
# <div class="<%= card_classes %>">
#   <div class="card-body">
#     <% if header? %>
#       <div class="card-header">
#         <%= header %>
#       </div>
#     <% end %>
#
#     <div class="card-content">
#       <p class="text-base"><%= feedback.content %></p>
#
#       <%= render Ui::BadgeComponent.new(variant: status_badge_variant) do %>
#         <%= feedback.status.titleize %>
#       <% end %>
#     </div>
#
#     <% if metadata? %>
#       <div class="card-metadata text-sm text-muted">
#         <%= metadata %>
#       </div>
#     <% end %>
#
#     <% if actions? %>
#       <div class="card-actions justify-end mt-4">
#         <% actions.each do |action| %>
#           <%= action %>
#         <% end %>
#       </div>
#     <% end %>
#   </div>
# </div>

# Usage:
# <%= render FeedbackComponents::CardComponent.new(feedback: @feedback) do |card| %>
#   <% card.with_header do %>
#     <h3 class="card-title">Feedback from <%= @feedback.sender_name || "Anonymous" %></h3>
#   <% end %>
#
#   <% card.with_metadata do %>
#     Submitted <%= time_ago_in_words(@feedback.created_at) %> ago
#   <% end %>
#
#   <% card.with_action do %>
#     <%= link_to "View", feedback_path(@feedback), class: "btn btn-primary btn-sm" %>
#   <% end %>
#
#   <% card.with_action do %>
#     <%= link_to "Respond", respond_feedback_path(@feedback), class: "btn btn-ghost btn-sm" %>
#   <% end %>
# <% end %>

#
# ============================================================================
# RULE: Use slots for structured content areas
# PREFER: renders_one for single slots, renders_many for collections
# POLYMORPHIC: Use polymorphic slots for variant component types
# PREDICATE: Check slot presence with slot_name? before rendering
# DEFAULTS: Provide sensible defaults with default_slot_name method
# LAMBDA: Use lambda slots for simple content transformation
# ============================================================================
#
