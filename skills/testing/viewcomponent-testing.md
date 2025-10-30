---
name: viewcomponent-testing
domain: testing
dependencies: [viewcomponent-basics, tdd-minitest]
version: 1.0
rails_version: 8.1+
---

# ViewComponent Testing

Test ViewComponents in isolation with fast unit tests, preview testing, and system tests with JavaScript support.

<when-to-use>
- Testing component rendering and output
- Verifying component slots work correctly
- Testing component variants and conditional rendering
- Testing components that use view helpers
- Testing component interactions with JavaScript
- Validating component previews
- Testing collections of components
- TDD/BDD workflows for UI components
</when-to-use>

<benefits>
- **Fast Tests** - Unit tests run in milliseconds without full Rails stack
- **Isolated** - Test components without controllers, routes, or browser
- **Capybara Support** - Use familiar Capybara assertions and selectors
- **Preview Testing** - Test and assert against preview examples
- **System Tests** - Full browser testing with JavaScript interactions
- **TDD-Friendly** - Write tests first, components second
- **Regression Prevention** - Catch UI bugs before production
</benefits>

<standards>
- Inherit from `ViewComponent::TestCase` for unit tests
- Use `render_inline` for testing component rendering
- Use Capybara assertions (`assert_selector`, `assert_text`)
- Test all component slots and variants
- Use `render_preview` to test preview examples
- Use `ViewComponent::SystemTestCase` for JavaScript testing
- Test conditional rendering with `refute_component_rendered`
- Use `setup` method for test fixtures and data
- Test collections with `Component.with_collection`
- Keep tests focused on component behavior, not implementation
</standards>

## Basic Component Testing

<pattern name="basic-unit-test">
<description>Test component rendering and text output</description>

**Component:**
```ruby
# app/components/hello_component.rb
class HelloComponent < ViewComponent::Base
  def initialize(name:)
    @name = name
  end
end
```

**Template:**
```erb
<%# app/components/hello_component.html.erb %>
<div class="greeting" data-testid="greeting">
  Hello, <%= @name %>!
</div>
```

**Test:**
```ruby
# test/components/hello_component_test.rb
require "test_helper"

class HelloComponentTest < ViewComponent::TestCase
  test "renders component with name" do
    render_inline(HelloComponent.new(name: "World"))

    # ✅ Assert component rendered successfully
    assert_component_rendered

    # ✅ Assert text content
    assert_text("Hello, World!")
  end

  test "renders with correct HTML structure" do
    render_inline(HelloComponent.new(name: "Alice"))

    # ✅ Capybara selector assertions
    assert_selector("div.greeting", text: "Hello, Alice!")
  end

  test "includes data attributes" do
    render_inline(HelloComponent.new(name: "Bob"))

    # ✅ Test attributes
    assert_selector("div[data-testid='greeting']")
  end
end
```

**Key Methods:**
- `render_inline(component)` - Render component for testing
- `assert_component_rendered` - Verify component rendered
- `assert_text(text)` - Check text content
- `assert_selector(selector)` - Check HTML elements
</pattern>

## Testing Content Blocks

<pattern name="content-block-testing">
<description>Test components that accept content blocks</description>

**Component:**
```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  def initialize(title:, variant: :default)
    @title = title
    @variant = variant
  end

  def variant_class
    "card-#{@variant}" unless @variant == :default
  end
end
```

**Test:**
```ruby
# test/components/card_component_test.rb
class CardComponentTest < ViewComponent::TestCase
  test "renders card with title and content" do
    render_inline(CardComponent.new(title: "My Card")) do
      "Card body content"
    end

    # ✅ Test title
    assert_selector(".card-title", text: "My Card")

    # ✅ Test block content
    assert_text("Card body content")
  end

  test "applies variant classes" do
    render_inline(CardComponent.new(title: "Test", variant: :bordered)) do
      "Content"
    end

    # ✅ Test CSS classes
    assert_selector(".card.card-bordered")
  end

  test "default variant has no extra class" do
    render_inline(CardComponent.new(title: "Test")) do
      "Content"
    end

    assert_selector(".card")
    # ✅ Negative assertion
    assert_no_selector(".card-bordered")
  end
end
```
</pattern>

## Testing Component Slots

<pattern name="slot-testing">
<description>Test components with optional slots (renders_one)</description>

**Component:**
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

**Test:**
```ruby
# test/components/modal_component_test.rb
class ModalComponentTest < ViewComponent::TestCase
  test "renders without slots" do
    render_inline(ModalComponent.new)

    # ✅ Base component renders
    assert_selector(".modal")

    # ✅ Optional slots absent
    assert_no_selector(".modal-header")
    assert_no_selector(".modal-footer")
  end

  test "renders with header slot" do
    render_inline(ModalComponent.new) do |modal|
      modal.with_header { "Modal Title" }
      "Modal body"
    end

    # ✅ Slot content present
    assert_selector(".modal-header", text: "Modal Title")
  end

  test "renders with footer slot" do
    render_inline(ModalComponent.new) do |modal|
      modal.with_footer { "Footer content" }
      "Modal body"
    end

    assert_selector(".modal-footer", text: "Footer content")
  end

  test "renders with all slots" do
    render_inline(ModalComponent.new(size: :lg)) do |modal|
      modal.with_header { "Complete Modal" }
      modal.with_footer do
        content_tag :button, "Close", class: "btn"
      end

      "Body content"
    end

    # ✅ All slots present
    assert_selector(".modal-header", text: "Complete Modal")
    assert_text("Body content")
    assert_selector(".modal-footer button.btn", text: "Close")
  end
end
```
</pattern>

## Testing Collection Slots

<pattern name="collection-slot-testing">
<description>Test components with collection slots (renders_many)</description>

**Component:**
```ruby
# app/components/tab_container_component.rb
class TabContainerComponent < ViewComponent::Base
  renders_many :tabs, "TabComponent"

  class TabComponent < ViewComponent::Base
    def initialize(name:, active: false)
      @name = name
      @active = active
    end
  end
end
```

**Test:**
```ruby
# test/components/tab_container_component_test.rb
class TabContainerComponentTest < ViewComponent::TestCase
  test "renders multiple tabs" do
    render_inline(TabContainerComponent.new) do |container|
      container.with_tab(name: "Tab 1", active: true) { "Content 1" }
      container.with_tab(name: "Tab 2") { "Content 2" }
      container.with_tab(name: "Tab 3") { "Content 3" }
    end

    # ✅ Count collection items
    assert_selector(".tab", count: 3)

    # ✅ Check active state
    assert_selector(".tab.tab-active", text: "Content 1")
  end

  test "renders with no tabs" do
    render_inline(TabContainerComponent.new)

    # ✅ Container renders
    assert_selector("[role='tablist']")

    # ✅ No collection items
    assert_no_selector(".tab")
  end
end
```
</pattern>

## Testing Conditional Rendering

<pattern name="conditional-rendering-testing">
<description>Test components that conditionally render with #render?</description>

**Component:**
```ruby
# app/components/flash_message_component.rb
class FlashMessageComponent < ViewComponent::Base
  def initialize(type:, message:)
    @type = type
    @message = message
  end

  def render?
    @message.present?
  end
end
```

**Test:**
```ruby
# test/components/flash_message_component_test.rb
class FlashMessageComponentTest < ViewComponent::TestCase
  test "renders when message present" do
    render_inline(FlashMessageComponent.new(type: :success, message: "Done!"))

    # ✅ Component renders
    assert_selector(".alert.alert-success", text: "Done!")
  end

  test "does not render when message blank" do
    render_inline(FlashMessageComponent.new(type: :success, message: ""))

    # ✅ Component did not render
    refute_component_rendered
  end

  test "does not render when message nil" do
    render_inline(FlashMessageComponent.new(type: :success, message: nil))

    # ✅ Use custom assertion
    refute_component_rendered
  end
end
```

**Custom Assertion:**
```ruby
# test/test_helper.rb
class ViewComponent::TestCase < ActiveSupport::TestCase
  def refute_component_rendered
    refute page.has_selector?("*"), "Expected component not to render"
  end
end
```
</pattern>

## Testing Component Variants

<pattern name="variant-testing">
<description>Test component visual variants and states</description>

**Component:**
```ruby
# app/components/button_component.rb
class ButtonComponent < ViewComponent::Base
  def initialize(variant: :primary, size: :md, disabled: false, loading: false)
    @variant = variant
    @size = size
    @disabled = disabled
    @loading = loading
  end
end
```

**Test:**
```ruby
# test/components/button_component_test.rb
class ButtonComponentTest < ViewComponent::TestCase
  test "primary variant" do
    render_inline(ButtonComponent.new(variant: :primary)) { "Click" }

    # ✅ Test variant class
    assert_selector(".btn.btn-primary", text: "Click")
  end

  test "secondary variant" do
    render_inline(ButtonComponent.new(variant: :secondary)) { "Click" }

    assert_selector(".btn.btn-secondary", text: "Click")
  end

  test "ghost variant" do
    render_inline(ButtonComponent.new(variant: :ghost)) { "Click" }

    assert_selector(".btn.btn-ghost", text: "Click")
  end

  test "size variations" do
    # ✅ Test multiple variants in loop
    %i[xs sm md lg xl].each do |size|
      render_inline(ButtonComponent.new(size: size)) { "Button" }

      if size == :md
        # Default size has no modifier class
        assert_selector(".btn:not(.btn-xs):not(.btn-sm):not(.btn-lg):not(.btn-xl)")
      else
        assert_selector(".btn.btn-#{size}")
      end
    end
  end

  test "disabled state" do
    render_inline(ButtonComponent.new(disabled: true)) { "Disabled" }

    # ✅ Test HTML attributes
    assert_selector("button[disabled]")
  end

  test "loading state" do
    render_inline(ButtonComponent.new(loading: true)) { "Loading" }

    # ✅ Multiple assertions
    assert_selector("button[disabled]")
    assert_selector(".loading.loading-spinner")
  end
end
```
</pattern>

## Testing with Fixtures

<pattern name="fixture-testing">
<description>Test components with Rails fixtures and model data</description>

**Test:**
```ruby
# test/components/feedback_card_component_test.rb
class FeedbackCardComponentTest < ViewComponent::TestCase
  def setup
    # ✅ Load fixture in setup
    @feedback = feedbacks(:one)
  end

  test "renders feedback card" do
    render_inline(FeedbackComponents::CardComponent.new(feedback: @feedback))

    # ✅ Test with fixture data
    assert_text(@feedback.content)
    assert_selector(".card")
  end

  test "status badge color" do
    # ✅ Modify fixture state
    @feedback.status = "pending"
    render_inline(FeedbackComponents::CardComponent.new(feedback: @feedback))

    assert_selector(".badge.badge-warning")
  end

  test "resolved status" do
    @feedback.status = "resolved"
    render_inline(FeedbackComponents::CardComponent.new(feedback: @feedback))

    assert_selector(".badge.badge-success")
  end
end
```
</pattern>

## Testing Collections

<pattern name="collection-testing">
<description>Test components rendered as collections</description>

**Test:**
```ruby
# test/components/product_component_test.rb
class ProductCollectionComponentTest < ViewComponent::TestCase
  test "renders collection of products" do
    products = [
      Struct.new(:id, :name).new(1, "Product 1"),
      Struct.new(:id, :name).new(2, "Product 2"),
      Struct.new(:id, :name).new(3, "Product 3")
    ]

    # ✅ Render collection
    render_inline(ProductComponent.with_collection(products))

    # ✅ Count rendered items
    assert_selector(".product-card", count: 3)
    assert_text("Product 1")
    assert_text("Product 2")
    assert_text("Product 3")
  end

  test "empty collection" do
    render_inline(ProductComponent.with_collection([]))

    # ✅ No items rendered
    assert_no_selector(".product-card")
  end

  test "collection with counter" do
    products = 5.times.map { |i| Struct.new(:id, :name).new(i, "Product #{i}") }

    render_inline(ProductComponent.with_collection(products))

    # ✅ Test collection counter
    assert_selector(".product-card:first-child[data-index='0']")
    assert_selector(".product-card:last-child[data-index='4']")
  end
end
```
</pattern>

## Testing with Preview

<pattern name="preview-testing">
<description>Test component previews defined in preview classes</description>

**Preview:**
```ruby
# test/components/previews/button_component_preview.rb
class ButtonComponentPreview < ViewComponent::Preview
  def default
    render(ButtonComponent.new(variant: :primary)) { "Click Me" }
  end

  def secondary_variant
    render(ButtonComponent.new(variant: :secondary)) { "Secondary" }
  end

  def loading_state
    render(ButtonComponent.new(loading: true)) { "Loading..." }
  end
end
```

**Test:**
```ruby
# test/components/button_component_preview_test.rb
class ButtonComponentPreviewTest < ViewComponent::TestCase
  test "default preview" do
    # ✅ Render preview by name
    render_preview(:default)

    assert_selector(".btn.btn-primary", text: "Click Me")
  end

  test "secondary variant preview" do
    render_preview(:secondary_variant)

    assert_selector(".btn.btn-secondary")
  end

  test "loading state preview" do
    render_preview(:loading_state)

    assert_selector("button[disabled]")
    assert_selector(".loading")
  end
end
```
</pattern>

## Testing with Formats and Variants

<pattern name="format-variant-testing">
<description>Test components with multiple request formats and ActionPack variants</description>

**Multiple Formats Test:**
```ruby
# test/components/multiple_formats_component_test.rb
class MultipleFormatsComponentTest < ViewComponent::TestCase
  test "renders HTML format" do
    # ✅ Specify request format
    with_format :html do
      render_inline(MultipleFormatsComponent.new)

      assert_selector("div", text: "HTML content")
    end
  end

  test "renders JSON format" do
    with_format :json do
      render_inline(MultipleFormatsComponent.new)

      # ✅ Parse JSON response
      assert_equal(rendered_json["hello"], "world")
      assert_equal(rendered_json["format"], "json")
    end
  end
end
```

**ActionPack Variants Test:**
```ruby
# test/components/responsive_component_test.rb
class ResponsiveComponentTest < ViewComponent::TestCase
  test "renders desktop variant" do
    render_inline(ResponsiveComponent.new(title: "Desktop"))

    # ✅ Default variant
    assert_selector(".desktop-layout", text: "Desktop")
  end

  test "renders tablet variant" do
    # ✅ Set request variant
    with_variant :tablet do
      render_inline(ResponsiveComponent.new(title: "Tablet"))

      assert_selector(".tablet-layout", text: "Tablet")
    end
  end

  test "renders phone variant" do
    with_variant :phone do
      render_inline(ResponsiveComponent.new(title: "Phone"))

      assert_selector(".phone-layout", text: "Phone")
    end
  end
end
```

**Helper for JSON:**
```ruby
# test/test_helper.rb
class ViewComponent::TestCase < ActiveSupport::TestCase
  def rendered_json
    JSON.parse(page.text)
  end
end
```
</pattern>

## Testing with View Context

<pattern name="view-context-testing">
<description>Test components that use view helpers and route helpers</description>

**Test:**
```ruby
# test/components/helper_dependent_component_test.rb
class HelperDependentComponentTest < ViewComponent::TestCase
  test "component using date helpers" do
    # ✅ Render in view context for helper access
    render_in_view_context do
      render(HelperDependentComponent.new(date: Date.new(2024, 1, 15)))
    end

    # Component can use time_ago_in_words, number_to_currency, etc.
    assert_selector(".formatted-date")
  end

  test "component with route helpers" do
    render_in_view_context do
      render(LinkComponent.new(path: root_path, label: "Home"))
    end

    # ✅ Route helper resolves
    assert_selector("a[href='/']", text: "Home")
  end

  test "component with custom helper" do
    render_in_view_context do
      render(PriceComponent.new(amount: 99.99))
    end

    # Uses ApplicationHelper methods
    assert_selector(".price", text: "$99.99")
  end
end
```
</pattern>

## System Tests with JavaScript

<pattern name="system-test-javascript">
<description>Test components with JavaScript interactions in a browser</description>

**Test:**
```ruby
# test/components/system/button_component_system_test.rb
require "test_helper"

class ButtonComponentSystemTest < ViewComponent::SystemTestCase
  test "button click interaction" do
    # ✅ Render component and get test path
    with_rendered_component_path(
      render_inline(InteractiveButtonComponent.new)
    ) do |path|
      visit(path)

      # ✅ Interact with component
      click_button("Click Me")

      # ✅ Assert JavaScript changes
      assert_text("Button was clicked!")
    end
  end

  test "modal interaction" do
    with_rendered_component_path(
      render_inline(ModalComponent.new) do |modal|
        modal.with_header { "Test Modal" }
        "Modal content"
      end
    ) do |path|
      visit(path)

      # ✅ Test modal open/close
      click_button("Open Modal")
      assert_selector("dialog[open]")

      click_button("Close")
      assert_no_selector("dialog[open]")
    end
  end
end
```

**With Layout:**
```ruby
# test/components/system/javascript_component_test.rb
class ComponentWithJavaScriptTest < ViewComponent::SystemTestCase
  test "with application layout" do
    with_rendered_component_path(
      render_inline(JavaScriptComponent.new),
      layout: "application"  # ✅ Include JS from layout
    ) do |path|
      visit(path)

      click_button("Toggle")
      assert_selector(".hidden-content", visible: true)
    end
  end
end
```

**System Test Configuration:**
```ruby
# test/test_helper.rb
require "view_component/system_test_helpers"

class ViewComponent::SystemTestCase < ActionDispatch::SystemTestCase
  include ViewComponent::SystemTestHelpers

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
```
</pattern>

## Custom Test Assertions

<pattern name="custom-assertions">
<description>Create reusable custom assertions for component testing</description>

**Test Helper:**
```ruby
# test/test_helper.rb
class ViewComponent::TestCase < ActiveSupport::TestCase
  include ViewComponent::TestHelpers
  include Capybara::Minitest::Assertions

  def before_setup
    super
    @page = nil
  end

  def after_teardown
    super
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  # ✅ Custom assertion for component not rendering
  def refute_component_rendered
    refute page.has_selector?("*"), "Expected component not to render"
  end

  # ✅ Custom assertion for JSON responses
  def rendered_json
    JSON.parse(page.text)
  end

  # ✅ Custom badge assertions
  def assert_badge_variant(variant)
    assert_selector(".badge.badge-#{variant}")
  end

  def assert_badge_text(text)
    assert_selector(".badge", text: text)
  end
end
```

**Usage:**
```ruby
class ComponentTestWithCustomAssertions < ViewComponent::TestCase
  test "with custom assertion" do
    render_inline(BadgeComponent.new(variant: :success)) { "Active" }

    # ✅ Use custom assertions
    assert_badge_variant(:success)
    assert_badge_text("Active")
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Testing implementation details instead of behavior</description>
<reason>Tests become brittle and break with refactoring</reason>
<bad-example>
```ruby
# ❌ BAD - Testing private methods
test "variant_class returns correct value" do
  component = ButtonComponent.new(variant: :primary)
  assert_equal "btn-primary", component.send(:variant_class)
end

# ❌ BAD - Testing CSS implementation
test "button has specific CSS classes" do
  render_inline(ButtonComponent.new) { "Click" }
  assert_equal "inline-flex items-center px-4 py-2", page.find(".btn")["class"]
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Testing rendered output
test "primary variant renders correctly" do
  render_inline(ButtonComponent.new(variant: :primary)) { "Click" }
  assert_selector(".btn.btn-primary", text: "Click")
end

# ✅ GOOD - Testing component behavior
test "disabled button cannot be clicked" do
  render_inline(ButtonComponent.new(disabled: true)) { "Click" }
  assert_selector("button[disabled]")
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not testing all component states and variants</description>
<reason>Incomplete test coverage leads to bugs in production</reason>
<bad-example>
```ruby
# ❌ BAD - Only testing happy path
class AlertComponentTest < ViewComponent::TestCase
  test "renders alert" do
    render_inline(AlertComponent.new(type: :success, message: "Done"))
    assert_selector(".alert")
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Testing all variants and edge cases
class AlertComponentTest < ViewComponent::TestCase
  test "renders success variant" do
    render_inline(AlertComponent.new(type: :success, message: "Done"))
    assert_selector(".alert.alert-success")
  end

  test "renders error variant" do
    render_inline(AlertComponent.new(type: :error, message: "Failed"))
    assert_selector(".alert.alert-error")
  end

  test "does not render with blank message" do
    render_inline(AlertComponent.new(type: :success, message: ""))
    refute_component_rendered
  end

  test "escapes HTML in message" do
    render_inline(AlertComponent.new(type: :info, message: "<script>alert('xss')</script>"))
    assert_text("<script>alert('xss')</script>")
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using full integration tests for simple component testing</description>
<reason>Slow tests, difficult to maintain, unnecessary overhead</reason>
<bad-example>
```ruby
# ❌ BAD - Using controller test for component
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "feedback card component renders" do
    feedback = feedbacks(:one)
    get feedback_path(feedback)
    assert_select ".feedback-card"
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Direct component test
class FeedbackCardComponentTest < ViewComponent::TestCase
  test "renders feedback card" do
    feedback = feedbacks(:one)
    render_inline(FeedbackComponents::CardComponent.new(feedback: feedback))

    assert_selector(".feedback-card")
    assert_text(feedback.content)
  end
end

# ✅ GOOD - System test only for JavaScript
class FeedbackSystemTest < ViewComponent::SystemTestCase
  test "feedback modal opens on click" do
    with_rendered_component_path(
      render_inline(FeedbackModalComponent.new(feedback: feedbacks(:one)))
    ) do |path|
      visit(path)
      click_button("View Details")
      assert_selector("dialog[open]")
    end
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not cleaning up test state between tests</description>
<reason>Tests can interfere with each other causing flaky failures</reason>
<bad-example>
```ruby
# ❌ BAD - Shared mutable state
class ComponentTest < ViewComponent::TestCase
  @user = User.new(name: "Test")

  test "first test" do
    @user.name = "Changed"
    render_inline(UserComponent.new(user: @user))
    # ...
  end

  test "second test" do
    # @user.name is still "Changed" from previous test
    render_inline(UserComponent.new(user: @user))
    # ...
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Fresh state in setup
class ComponentTest < ViewComponent::TestCase
  def setup
    @user = User.new(name: "Test")
  end

  test "first test" do
    @user.name = "Changed"
    render_inline(UserComponent.new(user: @user))
    # ...
  end

  test "second test" do
    # Fresh @user instance from setup
    render_inline(UserComponent.new(user: @user))
    # ...
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
ViewComponent testing IS testing, so this section describes testing the testing setup:

```ruby
# test/test_helper.rb - Verify test configuration
require_relative "../config/environment"
require "rails/test_help"
require "view_component/test_helpers"
require "capybara/rails"
require "capybara/minitest"

class ViewComponent::TestCase < ActiveSupport::TestCase
  include ViewComponent::TestHelpers
  include Capybara::Minitest::Assertions

  def before_setup
    super
    @page = nil
  end

  def after_teardown
    super
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def refute_component_rendered
    refute page.has_selector?("*"), "Expected component not to render"
  end

  def rendered_json
    JSON.parse(page.text)
  end
end

# Verify system test setup
require "view_component/system_test_helpers"

class ViewComponent::SystemTestCase < ActionDispatch::SystemTestCase
  include ViewComponent::SystemTestHelpers

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
```

**Test the Test Setup:**
```ruby
# test/test_helper_test.rb
class TestHelperTest < ActiveSupport::TestCase
  test "ViewComponent::TestCase is configured" do
    assert ViewComponent::TestCase.ancestors.include?(ViewComponent::TestHelpers)
    assert ViewComponent::TestCase.ancestors.include?(Capybara::Minitest::Assertions)
  end

  test "SystemTestCase is configured" do
    assert ViewComponent::SystemTestCase.ancestors.include?(ViewComponent::SystemTestHelpers)
  end
end
```

**Run Tests:**
```bash
# Run all component tests
bin/rails test:components

# Run specific component test
bin/rails test test/components/button_component_test.rb

# Run system tests
bin/rails test:system

# Run with coverage
COVERAGE=true bin/rails test:components
```
</testing>

<related-skills>
- viewcomponent-basics - Component creation and structure
- tdd-minitest - Test-driven development with Minitest
- fixtures-test-data - Using fixtures for test data
- minitest-mocking - Mocking and stubbing in tests
- capybara-testing - Browser-based testing with Capybara
- system-testing - Full-stack system tests
</related-skills>

<resources>
- [ViewComponent Testing Guide](https://viewcomponent.org/guide/testing.html)
- [ViewComponent Test Helpers API](https://viewcomponent.org/api.html#testhelpers)
- [Capybara Assertions](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Minitest/Assertions)
- [Minitest Documentation](https://docs.seattlerb.org/minitest/)
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
</resources>
