# ViewComponent Testing Comprehensive Patterns
# Reference: ViewComponent Testing Documentation
# Category: TESTS - VIEWCOMPONENT

#
# ============================================================================
# What is ViewComponent Testing?
# ============================================================================
#
# ViewComponent provides robust testing support through ViewComponent::TestCase,
# allowing you to unit test components in isolation, test previews, and perform
# system tests with Capybara.
#
# Testing Levels:
# 1. Unit Tests - Test component rendering and logic
# 2. Preview Tests - Test preview examples
# 3. System Tests - Test component behavior in browser
#
# Benefits:
# ✅ Fast - Unit tests are extremely fast
# ✅ Isolated - Test components without controllers/routes
# ✅ Capybara support - Use familiar Capybara assertions
# ✅ Preview testing - Render and assert against previews
# ✅ System tests - Full browser testing with JavaScript
#

#
# ============================================================================
# ✅ BASIC COMPONENT UNIT TEST
# ============================================================================
#

require "test_helper"

class HelloComponentTest < ViewComponent::TestCase
  def test_renders_component
    render_inline(HelloComponent.new(name: "World"))

    # Assert component rendered successfully
    assert_component_rendered

    # Assert against text content
    assert_text("Hello, World!")
  end

  def test_renders_with_html
    render_inline(HelloComponent.new(name: "Alice"))

    # Capybara selector assertions
    assert_selector("div.greeting", text: "Hello, Alice!")
  end

  def test_component_with_custom_attributes
    render_inline(HelloComponent.new(name: "Bob"))

    assert_selector("div.greeting[data-testid='greeting']")
  end
end

#
# ============================================================================
# ✅ TESTING COMPONENT WITH CONTENT BLOCK
# ============================================================================
#

class CardComponentTest < ViewComponent::TestCase
  def test_renders_card_with_content
    render_inline(CardComponent.new(title: "My Card")) do
      "Card body content"
    end

    assert_selector(".card-title", text: "My Card")
    assert_text("Card body content")
  end

  def test_card_variant_classes
    render_inline(CardComponent.new(title: "Test", variant: :bordered)) do
      "Content"
    end

    assert_selector(".card.card-bordered")
  end

  def test_default_variant
    render_inline(CardComponent.new(title: "Test")) do
      "Content"
    end

    assert_selector(".card")
    assert_no_selector(".card-bordered")
  end
end

#
# ============================================================================
# ✅ TESTING COMPONENT SLOTS
# ============================================================================
#

class ModalComponentTest < ViewComponent::TestCase
  def test_renders_without_slots
    render_inline(ModalComponent.new)

    assert_selector(".modal")
    assert_no_selector(".modal-header")
    assert_no_selector(".modal-footer")
  end

  def test_renders_with_header_slot
    render_inline(ModalComponent.new) do |modal|
      modal.with_header { "Modal Title" }
      "Modal body"
    end

    assert_selector(".modal-header", text: "Modal Title")
  end

  def test_renders_with_footer_slot
    render_inline(ModalComponent.new) do |modal|
      modal.with_footer { "Footer content" }
      "Modal body"
    end

    assert_selector(".modal-footer", text: "Footer content")
  end

  def test_renders_with_all_slots
    render_inline(ModalComponent.new(size: :lg)) do |modal|
      modal.with_header { "Complete Modal" }
      modal.with_footer do
        content_tag :button, "Close", class: "btn"
      end

      "Body content"
    end

    assert_selector(".modal-header", text: "Complete Modal")
    assert_text("Body content")
    assert_selector(".modal-footer button.btn", text: "Close")
  end
end

#
# ============================================================================
# ✅ TESTING COLLECTION SLOTS (renders_many)
# ============================================================================
#

class TabContainerComponentTest < ViewComponent::TestCase
  def test_renders_multiple_tabs
    render_inline(TabContainerComponent.new) do |container|
      container.with_tab(name: "Tab 1", active: true) { "Content 1" }
      container.with_tab(name: "Tab 2") { "Content 2" }
      container.with_tab(name: "Tab 3") { "Content 3" }
    end

    assert_selector(".tab", count: 3)
    assert_selector(".tab.tab-active", text: "Content 1")
  end

  def test_renders_with_no_tabs
    render_inline(TabContainerComponent.new)

    assert_selector("[role='tablist']")
    assert_no_selector(".tab")
  end
end

#
# ============================================================================
# ✅ TESTING CONDITIONAL RENDERING (#render?)
# ============================================================================
#

class FlashMessageComponentTest < ViewComponent::TestCase
  def test_renders_when_message_present
    render_inline(FlashMessageComponent.new(type: :success, message: "Done!"))

    assert_selector(".alert.alert-success", text: "Done!")
  end

  def test_does_not_render_when_message_blank
    result = render_inline(FlashMessageComponent.new(type: :success, message: ""))

    # Component should not render at all
    refute_component_rendered
  end

  def test_does_not_render_when_message_nil
    result = render_inline(FlashMessageComponent.new(type: :success, message: nil))

    refute_component_rendered
  end
end

#
# ============================================================================
# ✅ TESTING COMPONENT VARIANTS
# ============================================================================
#

class ButtonComponentTest < ViewComponent::TestCase
  def test_primary_variant
    render_inline(ButtonComponent.new(variant: :primary)) { "Click" }

    assert_selector(".btn.btn-primary", text: "Click")
  end

  def test_secondary_variant
    render_inline(ButtonComponent.new(variant: :secondary)) { "Click" }

    assert_selector(".btn.btn-secondary", text: "Click")
  end

  def test_ghost_variant
    render_inline(ButtonComponent.new(variant: :ghost)) { "Click" }

    assert_selector(".btn.btn-ghost", text: "Click")
  end

  def test_size_variations
    %i[xs sm md lg xl].each do |size|
      render_inline(ButtonComponent.new(size: size)) { "Button" }

      if size == :md
        assert_selector(".btn:not(.btn-xs):not(.btn-sm):not(.btn-lg):not(.btn-xl)")
      else
        assert_selector(".btn.btn-#{size}")
      end
    end
  end

  def test_disabled_state
    render_inline(ButtonComponent.new(disabled: true)) { "Disabled" }

    assert_selector("button[disabled]")
  end

  def test_loading_state
    render_inline(ButtonComponent.new(loading: true)) { "Loading" }

    assert_selector("button[disabled]")
    assert_selector(".loading.loading-spinner")
  end
end

#
# ============================================================================
# ✅ TESTING WITH HELPER METHODS
# ============================================================================
#

class UserAvatarComponentTest < ViewComponent::TestCase
  def setup
    @user = Struct.new(:id, :name, :avatar_url).new(1, "John Doe", nil)
  end

  def test_renders_default_avatar_when_no_url
    render_inline(UserAvatarComponent.new(user: @user))

    assert_selector(".avatar")
    assert_selector("img[src*='ui-avatars.com']")
  end

  def test_renders_custom_avatar_url
    @user.avatar_url = "https://example.com/avatar.jpg"
    render_inline(UserAvatarComponent.new(user: @user))

    assert_selector("img[src='https://example.com/avatar.jpg']")
  end

  def test_different_sizes
    render_inline(UserAvatarComponent.new(user: @user, size: :lg))

    assert_selector(".avatar")
    assert_selector("img[src*='size=128']")
  end
end

#
# ============================================================================
# ✅ TESTING PREVIEWS WITH render_preview
# ============================================================================
#

class ButtonComponentPreviewTest < ViewComponent::TestCase
  def test_default_preview
    render_preview(:default)

    assert_selector(".btn.btn-primary", text: "Click Me")
  end

  def test_secondary_variant_preview
    render_preview(:secondary_variant)

    assert_selector(".btn.btn-secondary")
  end

  def test_loading_state_preview
    render_preview(:loading_state)

    assert_selector("button[disabled]")
    assert_selector(".loading")
  end
end

#
# ============================================================================
# ✅ TESTING PREVIEWS WITH PARAMETERS
# ============================================================================
#

class AlertComponentPreviewTest < ViewComponent::TestCase
  def test_preview_with_params
    render_preview(:default, params: { type: "error", message: "Test error" })

    assert_selector(".alert.alert-error", text: "Test error")
  end

  def test_preview_with_different_type
    render_preview(:default, params: { type: "success", message: "Success!" })

    assert_selector(".alert.alert-success", text: "Success!")
  end
end

#
# ============================================================================
# ✅ TESTING WITH EXPLICIT PREVIEW CLASS
# ============================================================================
#

class MyCustomTest < ViewComponent::TestCase
  def test_render_preview_with_explicit_class
    render_preview(:default, from: ButtonComponentPreview)

    assert_selector(".btn")
  end
end

#
# ============================================================================
# ✅ TESTING WITH REQUEST FORMATS
# ============================================================================
#

class MultipleFormatsComponentTest < ViewComponent::TestCase
  def test_renders_html_format
    with_format :html do
      render_inline(MultipleFormatsComponent.new)

      assert_selector("div", text: "HTML content")
    end
  end

  def test_renders_json_format
    with_format :json do
      render_inline(MultipleFormatsComponent.new)

      assert_equal(rendered_json["hello"], "world")
      assert_equal(rendered_json["format"], "json")
    end
  end
end

#
# ============================================================================
# ✅ TESTING WITH ACTION PACK VARIANTS
# ============================================================================
#

class ResponsiveComponentTest < ViewComponent::TestCase
  def test_renders_desktop_variant
    render_inline(ResponsiveComponent.new(title: "Desktop"))

    assert_selector(".desktop-layout", text: "Desktop")
  end

  def test_renders_tablet_variant
    with_variant :tablet do
      render_inline(ResponsiveComponent.new(title: "Tablet"))

      assert_selector(".tablet-layout", text: "Tablet")
    end
  end

  def test_renders_phone_variant
    with_variant :phone do
      render_inline(ResponsiveComponent.new(title: "Phone"))

      assert_selector(".phone-layout", text: "Phone")
    end
  end
end

#
# ============================================================================
# ✅ TESTING WITHOUT CAPYBARA (Nokogiri)
# ============================================================================
#

# If Capybara is not available, render_inline returns Nokogiri fragment
class NokogiriComponentTest < ViewComponent::TestCase
  def test_with_nokogiri
    result = render_inline(HelloComponent.new(name: "Nokogiri"))

    # result is a Nokogiri::HTML::DocumentFragment
    assert_includes result.css("div.greeting").to_html, "Hello, Nokogiri"
  end
end

#
# ============================================================================
# ✅ SYSTEM TESTS (Browser/JavaScript Testing)
# ============================================================================
#

require "test_helper"

class ButtonComponentSystemTest < ViewComponent::SystemTestCase
  def test_button_click_interaction
    # Render component and visit its path
    with_rendered_component_path(
      render_inline(InteractiveButtonComponent.new)
    ) do |path|
      visit(path)

      # Interact with component
      click_button("Click Me")

      # Assert changes
      assert_text("Button was clicked!")
    end
  end

  def test_modal_interaction
    with_rendered_component_path(
      render_inline(ModalComponent.new) do |modal|
        modal.with_header { "Test Modal" }
        "Modal content"
      end
    ) do |path|
      visit(path)

      # Modal interactions
      click_button("Open Modal")
      assert_selector("dialog[open]")

      click_button("Close")
      assert_no_selector("dialog[open]")
    end
  end
end

#
# ============================================================================
# ✅ SYSTEM TESTS WITH LAYOUT
# ============================================================================
#

class ComponentWithJavaScriptTest < ViewComponent::SystemTestCase
  def test_with_application_layout
    with_rendered_component_path(
      render_inline(JavaScriptComponent.new),
      layout: "application"  # Include JS from application layout
    ) do |path|
      visit(path)

      click_button("Toggle")
      assert_selector(".hidden-content", visible: true)
    end
  end
end

#
# ============================================================================
# ✅ TESTING PREVIEW IN SYSTEM TEST
# ============================================================================
#

class ComponentPreviewSystemTest < ApplicationSystemTestCase
  def test_preview_interaction
    visit("/rails/view_components/interactive_component/default")

    click_button("Interact")
    assert_text("Interaction successful")
  end

  def test_preview_with_params
    visit("/rails/view_components/alert_component/default?type=error")

    assert_selector(".alert.alert-error")
  end
end

#
# ============================================================================
# ✅ TESTING WITH FIXTURES
# ============================================================================
#

class FeedbackCardComponentTest < ViewComponent::TestCase
  def setup
    @feedback = feedbacks(:one)  # From fixtures
  end

  def test_renders_feedback_card
    render_inline(FeedbackComponents::CardComponent.new(feedback: @feedback))

    assert_text(@feedback.content)
    assert_selector(".card")
  end

  def test_status_badge_color
    @feedback.status = "pending"
    render_inline(FeedbackComponents::CardComponent.new(feedback: @feedback))

    assert_selector(".badge.badge-warning")
  end
end

#
# ============================================================================
# ✅ TESTING COLLECTIONS
# ============================================================================
#

class ProductCollectionComponentTest < ViewComponent::TestCase
  def test_renders_collection
    products = [
      Struct.new(:id, :name).new(1, "Product 1"),
      Struct.new(:id, :name).new(2, "Product 2"),
      Struct.new(:id, :name).new(3, "Product 3")
    ]

    render_inline(ProductComponent.with_collection(products))

    assert_selector(".product-card", count: 3)
    assert_text("Product 1")
    assert_text("Product 2")
    assert_text("Product 3")
  end

  def test_empty_collection
    render_inline(ProductComponent.with_collection([]))

    assert_no_selector(".product-card")
  end
end

#
# ============================================================================
# ✅ TESTING RENDER_IN_VIEW_CONTEXT
# ============================================================================
#

class HelperDependentComponentTest < ViewComponent::TestCase
  def test_component_using_helpers
    render_in_view_context do
      render(HelperDependentComponent.new(date: Date.new(2024, 1, 15)))
    end

    # Component can use view helpers like time_ago_in_words, number_to_currency, etc.
    assert_selector(".formatted-date")
  end

  def test_component_with_route_helpers
    render_in_view_context do
      render(LinkComponent.new(path: root_path, label: "Home"))
    end

    assert_selector("a[href='/']", text: "Home")
  end
end

#
# ============================================================================
# ✅ CUSTOM ASSERTIONS
# ============================================================================
#

class ComponentTestWithCustomAssertions < ViewComponent::TestCase
  def test_with_custom_assertion
    render_inline(BadgeComponent.new(variant: :success)) { "Active" }

    assert_badge_variant(:success)
    assert_badge_text("Active")
  end

  private

  def assert_badge_variant(variant)
    assert_selector(".badge.badge-#{variant}")
  end

  def assert_badge_text(text)
    assert_selector(".badge", text: text)
  end
end

#
# ============================================================================
# ✅ TESTING COMPONENT INHERITANCE
# ============================================================================
#

class ChildComponentTest < ViewComponent::TestCase
  def test_inherits_parent_behavior
    render_inline(ChildComponent.new)

    # Inherits parent's base classes
    assert_selector(".parent-base-class")
    # Has child's additional classes
    assert_selector(".child-class")
  end
end

#
# ============================================================================
# ✅ TEST HELPER SETUP
# ============================================================================
#

# test/test_helper.rb
# ENV["RAILS_ENV"] ||= "test"
# require_relative "../config/environment"
# require "rails/test_help"
# require "view_component/test_helpers"
# require "capybara/rails"
# require "capybara/minitest"
#
# class ViewComponent::TestCase < ActiveSupport::TestCase
#   include ViewComponent::TestHelpers
#   include Capybara::Minitest::Assertions
#
#   def before_setup
#     super
#     @page = nil
#   end
#
#   def after_teardown
#     super
#     Capybara.reset_sessions!
#     Capybara.use_default_driver
#   end
#
#   # Custom helper method
#   def refute_component_rendered
#     refute page.has_selector?("*"), "Expected component not to render"
#   end
#
#   def rendered_json
#     JSON.parse(page.text)
#   end
# end

#
# ============================================================================
# ✅ SYSTEM TEST HELPER SETUP
# ============================================================================
#

# test/test_helper.rb
# require "view_component/system_test_helpers"
#
# class ViewComponent::SystemTestCase < ActionDispatch::SystemTestCase
#   include ViewComponent::SystemTestHelpers
#
#   driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
# end

#
# ============================================================================
# RULE: Test components in isolation with ViewComponent::TestCase
# UNIT: Use render_inline for fast unit tests
# PREVIEWS: Test previews with render_preview
# SYSTEM: Use system tests for JavaScript interactions
# CAPYBARA: Use familiar Capybara assertions (assert_selector, assert_text)
# FIXTURES: Use Rails fixtures for test data
# TDD: Write tests first (RED-GREEN-REFACTOR)
# ============================================================================
#
