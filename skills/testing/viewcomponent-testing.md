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
class HelloComponent < ViewComponent::Base
  def initialize(name:) = @name = name
end
```

**Test:**
```ruby
class HelloComponentTest < ViewComponent::TestCase
  test "renders component with name" do
    render_inline(HelloComponent.new(name: "World"))
    assert_component_rendered
    assert_text("Hello, World!")
  end

  test "renders with correct HTML structure" do
    render_inline(HelloComponent.new(name: "Alice"))
    assert_selector("div.greeting", text: "Hello, Alice!")
  end

  test "includes data attributes" do
    render_inline(HelloComponent.new(name: "Bob"))
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
class CardComponent < ViewComponent::Base
  def initialize(title:, variant: :default)
    @title, @variant = title, variant
  end

  def variant_class = "card-#{@variant}" unless @variant == :default
end
```

**Test:**
```ruby
class CardComponentTest < ViewComponent::TestCase
  test "renders card with title and content" do
    render_inline(CardComponent.new(title: "My Card")) { "Card body content" }
    assert_selector(".card-title", text: "My Card")
    assert_text("Card body content")
  end

  test "applies variant classes" do
    render_inline(CardComponent.new(title: "Test", variant: :bordered)) { "Content" }
    assert_selector(".card.card-bordered")
  end

  test "default variant has no extra class" do
    render_inline(CardComponent.new(title: "Test")) { "Content" }
    assert_selector(".card")
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
class ModalComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer

  def initialize(size: :md) = @size = size
end
```

**Test:**
```ruby
class ModalComponentTest < ViewComponent::TestCase
  test "renders without slots" do
    render_inline(ModalComponent.new)
    assert_selector(".modal")
    assert_no_selector(".modal-header")
    assert_no_selector(".modal-footer")
  end

  test "renders with header slot" do
    render_inline(ModalComponent.new) do |modal|
      modal.with_header { "Modal Title" }
      "Modal body"
    end
    assert_selector(".modal-header", text: "Modal Title")
  end

  test "renders with all slots" do
    render_inline(ModalComponent.new(size: :lg)) do |modal|
      modal.with_header { "Complete Modal" }
      modal.with_footer { content_tag :button, "Close", class: "btn" }
      "Body content"
    end
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
class TabContainerComponent < ViewComponent::Base
  renders_many :tabs, "TabComponent"

  class TabComponent < ViewComponent::Base
    def initialize(name:, active: false)
      @name, @active = name, active
    end
  end
end
```

**Test:**
```ruby
class TabContainerComponentTest < ViewComponent::TestCase
  test "renders multiple tabs" do
    render_inline(TabContainerComponent.new) do |container|
      container.with_tab(name: "Tab 1", active: true) { "Content 1" }
      container.with_tab(name: "Tab 2") { "Content 2" }
      container.with_tab(name: "Tab 3") { "Content 3" }
    end
    assert_selector(".tab", count: 3)
    assert_selector(".tab.tab-active", text: "Content 1")
  end

  test "renders with no tabs" do
    render_inline(TabContainerComponent.new)
    assert_selector("[role='tablist']")
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
class FlashMessageComponent < ViewComponent::Base
  def initialize(type:, message:)
    @type, @message = type, message
  end

  def render? = @message.present?
end
```

**Test:**
```ruby
class FlashMessageComponentTest < ViewComponent::TestCase
  test "renders when message present" do
    render_inline(FlashMessageComponent.new(type: :success, message: "Done!"))
    assert_selector(".alert.alert-success", text: "Done!")
  end

  test "does not render when message blank" do
    render_inline(FlashMessageComponent.new(type: :success, message: ""))
    refute_component_rendered
  end

  test "does not render when message nil" do
    render_inline(FlashMessageComponent.new(type: :success, message: nil))
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
class ButtonComponent < ViewComponent::Base
  def initialize(variant: :primary, size: :md, disabled: false, loading: false)
    @variant, @size, @disabled, @loading = variant, size, disabled, loading
  end
end
```

**Test:**
```ruby
class ButtonComponentTest < ViewComponent::TestCase
  test "primary variant" do
    render_inline(ButtonComponent.new(variant: :primary)) { "Click" }
    assert_selector(".btn.btn-primary", text: "Click")
  end

  test "secondary variant" do
    render_inline(ButtonComponent.new(variant: :secondary)) { "Click" }
    assert_selector(".btn.btn-secondary", text: "Click")
  end

  test "size variations" do
    %i[xs sm md lg xl].each do |size|
      render_inline(ButtonComponent.new(size: size)) { "Button" }
      if size == :md
        assert_selector(".btn:not(.btn-xs):not(.btn-sm):not(.btn-lg):not(.btn-xl)")
      else
        assert_selector(".btn.btn-#{size}")
      end
    end
  end

  test "disabled state" do
    render_inline(ButtonComponent.new(disabled: true)) { "Disabled" }
    assert_selector("button[disabled]")
  end

  test "loading state" do
    render_inline(ButtonComponent.new(loading: true)) { "Loading" }
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
class FeedbackCardComponentTest < ViewComponent::TestCase
  def setup
    @feedback = feedbacks(:one)
  end

  test "renders feedback card" do
    render_inline(FeedbackComponents::CardComponent.new(feedback: @feedback))
    assert_text(@feedback.content)
    assert_selector(".card")
  end

  test "status badge color" do
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
class ProductCollectionComponentTest < ViewComponent::TestCase
  test "renders collection of products" do
    products = [
      Struct.new(:id, :name).new(1, "Product 1"),
      Struct.new(:id, :name).new(2, "Product 2"),
      Struct.new(:id, :name).new(3, "Product 3")
    ]
    render_inline(ProductComponent.with_collection(products))
    assert_selector(".product-card", count: 3)
    assert_text("Product 1")
  end

  test "empty collection" do
    render_inline(ProductComponent.with_collection([]))
    assert_no_selector(".product-card")
  end

  test "collection with counter" do
    products = 5.times.map { |i| Struct.new(:id, :name).new(i, "Product #{i}") }
    render_inline(ProductComponent.with_collection(products))
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
class ButtonComponentPreview < ViewComponent::Preview
  def default
    render(ButtonComponent.new(variant: :primary)) { "Click Me" }
  end

  def loading_state
    render(ButtonComponent.new(loading: true)) { "Loading..." }
  end
end
```

**Test:**
```ruby
class ButtonComponentPreviewTest < ViewComponent::TestCase
  test "default preview" do
    render_preview(:default)
    assert_selector(".btn.btn-primary", text: "Click Me")
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
class MultipleFormatsComponentTest < ViewComponent::TestCase
  test "renders HTML format" do
    with_format(:html) do
      render_inline(MultipleFormatsComponent.new)
      assert_selector("div", text: "HTML content")
    end
  end

  test "renders JSON format" do
    with_format(:json) do
      render_inline(MultipleFormatsComponent.new)
      assert_equal rendered_json["hello"], "world"
    end
  end
end
```

**ActionPack Variants Test:**
```ruby
class ResponsiveComponentTest < ViewComponent::TestCase
  test "renders desktop variant" do
    render_inline(ResponsiveComponent.new(title: "Desktop"))
    assert_selector(".desktop-layout", text: "Desktop")
  end

  test "renders tablet variant" do
    with_variant(:tablet) do
      render_inline(ResponsiveComponent.new(title: "Tablet"))
      assert_selector(".tablet-layout", text: "Tablet")
    end
  end
end
```

**Helper for JSON:**
```ruby
# test/test_helper.rb
class ViewComponent::TestCase < ActiveSupport::TestCase
  def rendered_json = JSON.parse(page.text)
end
```
</pattern>

## Testing with View Context

<pattern name="view-context-testing">
<description>Test components that use view helpers and route helpers</description>

**Test:**
```ruby
class HelperDependentComponentTest < ViewComponent::TestCase
  test "component using date helpers" do
    render_in_view_context do
      render(HelperDependentComponent.new(date: Date.new(2024, 1, 15)))
    end
    assert_selector(".formatted-date")
  end

  test "component with route helpers" do
    render_in_view_context do
      render(LinkComponent.new(path: root_path, label: "Home"))
    end
    assert_selector("a[href='/']", text: "Home")
  end

  test "component with custom helper" do
    render_in_view_context do
      render(PriceComponent.new(amount: 99.99))
    end
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
class ButtonComponentSystemTest < ViewComponent::SystemTestCase
  test "button click interaction" do
    with_rendered_component_path(
      render_inline(InteractiveButtonComponent.new)
    ) do |path|
      visit(path)
      click_button("Click Me")
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
class ComponentWithJavaScriptTest < ViewComponent::SystemTestCase
  test "with application layout" do
    with_rendered_component_path(
      render_inline(JavaScriptComponent.new),
      layout: "application"
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

  def refute_component_rendered
    refute page.has_selector?("*"), "Expected component not to render"
  end

  def rendered_json = JSON.parse(page.text)

  def assert_badge_variant(variant)
    assert_selector(".badge.badge-#{variant}")
  end
end
```

**Usage:**
```ruby
class ComponentTestWithCustomAssertions < ViewComponent::TestCase
  test "with custom assertion" do
    render_inline(BadgeComponent.new(variant: :success)) { "Active" }
    assert_badge_variant(:success)
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Testing implementation details instead of behavior</description>
<bad-example>
```ruby
# ❌ Testing private methods
test "variant_class returns correct value" do
  component = ButtonComponent.new(variant: :primary)
  assert_equal "btn-primary", component.send(:variant_class)
end
```
</bad-example>
<good-example>
```ruby
# ✅ Test rendered output
test "primary variant renders correctly" do
  render_inline(ButtonComponent.new(variant: :primary)) { "Click" }
  assert_selector(".btn.btn-primary", text: "Click")
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using integration tests for simple component testing</description>
<bad-example>
```ruby
# ❌ Controller test for component
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "feedback card component renders" do
    get feedback_path(feedbacks(:one))
    assert_select ".feedback-card"
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ Direct component test
class FeedbackCardComponentTest < ViewComponent::TestCase
  test "renders feedback card" do
    render_inline(FeedbackComponents::CardComponent.new(feedback: feedbacks(:one)))
    assert_selector(".feedback-card")
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
**Test Configuration:**
```ruby
# test/test_helper.rb
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

  def rendered_json = JSON.parse(page.text)
end

require "view_component/system_test_helpers"

class ViewComponent::SystemTestCase < ActionDispatch::SystemTestCase
  include ViewComponent::SystemTestHelpers
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
```

**Run Tests:**
```bash
bin/rails test:components
bin/rails test test/components/button_component_test.rb
bin/rails test:system
```
</testing>

<related-skills>
- viewcomponent-basics: Component creation and structure
- tdd-minitest: Test driven development with Minitest
- fixtures-test-data: Using fixtures for test data
- minitest-mocking: Mocking and stubbing in tests
</related-skills>

<resources>
- [ViewComponent Testing Guide](https://viewcomponent.org/guide/testing.html)
- [ViewComponent Test Helpers API](https://viewcomponent.org/api.html#testhelpers)
- [Capybara Assertions](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Minitest/Assertions)
</resources>
