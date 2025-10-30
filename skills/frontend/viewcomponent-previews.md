---
name: viewcomponent-previews
domain: frontend
dependencies: [viewcomponent-basics]
version: 1.0
rails_version: 8.1+
gem_requirements:
  - view_component: 4.1.0+
---

# ViewComponent Previews

Previews provide a way to view and test components in isolation during development. Similar to Storybook for React, previews let you see all component states without navigating your app.

<when-to-use>
- Visual development - Need to see components in isolation
- State exploration - Want to preview all variants and states
- Component documentation - Create a living catalog of components
- Development workflow - Iterate on UI without running full app
- Testing preparation - Use previews as basis for automated tests
- Designer handoff - Share component states with design team
</when-to-use>

<benefits>
- **Visual Development** - See components instantly without page navigation
- **State Exploration** - Preview all variants, sizes, and edge cases
- **Living Documentation** - Auto-generated component catalog at `/rails/view_components`
- **Testing Support** - Use previews in tests with `render_preview`
- **Dynamic Params** - Pass parameters via URL query strings
- **Custom Layouts** - Configure preview-specific layouts
- **Fast Iteration** - No need to set up database fixtures or full page context
</benefits>

<standards>
- Preview files go in `test/components/previews/` directory
- Preview classes inherit from `ViewComponent::Preview`
- Each public method in preview class is an example
- Use `@param` annotations for dynamic, interactive previews
- Name preview methods descriptively (`default`, `with_icon`, `disabled_state`)
- Enable previews in development environment only
- Access previews at `http://localhost:3000/rails/view_components`
- Use `render_with_template` for complex preview layouts
</standards>

## Configuration

<pattern name="preview-configuration">
<description>Enable and configure ViewComponent previews in development</description>

**Enable Previews:**
```ruby
# config/environments/development.rb
Rails.application.configure do
  # Enable ViewComponent previews
  config.view_component.previews.enabled = true

  # Set preview path (default: test/components/previews)
  config.view_component.previews.paths << Rails.root.join("test/components/previews")

  # Set default preview layout (optional)
  config.view_component.default_preview_layout = "component_preview"

  # Configure preview route (default: /rails/view_components)
  config.view_component.preview_route = "/components"
end
```

**Preview Index:**
- Visit `http://localhost:3000/rails/view_components` to see all previews
- Each preview class creates a page with all its example methods
- Click any example to view it in isolation
</pattern>

## Basic Previews

<pattern name="simple-preview">
<description>Basic preview showing multiple component states</description>

**Preview Class:**
```ruby
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
```

**Access Examples:**
```
http://localhost:3000/rails/view_components/button_component/default
http://localhost:3000/rails/view_components/button_component/secondary_variant
http://localhost:3000/rails/view_components/button_component/large_size
http://localhost:3000/rails/view_components/button_component/disabled_state
```

**Benefits:**
- Each method shows a specific state
- Easy to see all component variations
- No database setup required
</pattern>

<pattern name="preview-with-template">
<description>Use custom template for complex preview layouts</description>

**Preview Class:**
```ruby
# test/components/previews/badge_component_preview.rb
class BadgeComponentPreview < ViewComponent::Preview
  def all_variants
    render_with_template
  end
end
```

**Preview Template:**
```erb
<!-- test/components/previews/badge_component_preview/all_variants.html.erb -->
<div class="space-y-8">
  <section>
    <h2 class="text-2xl font-bold mb-4">Badge Variants</h2>
    <div class="flex gap-2 flex-wrap">
      <%= render BadgeComponent.new(variant: :primary) { "Primary" } %>
      <%= render BadgeComponent.new(variant: :secondary) { "Secondary" } %>
      <%= render BadgeComponent.new(variant: :success) { "Success" } %>
      <%= render BadgeComponent.new(variant: :error) { "Error" } %>
      <%= render BadgeComponent.new(variant: :warning) { "Warning" } %>
      <%= render BadgeComponent.new(variant: :info) { "Info" } %>
    </div>
  </section>

  <section>
    <h3 class="text-xl font-bold mb-4">Badge Sizes</h3>
    <div class="flex gap-2 items-center">
      <%= render BadgeComponent.new(size: :xs) { "Extra Small" } %>
      <%= render BadgeComponent.new(size: :sm) { "Small" } %>
      <%= render BadgeComponent.new(size: :md) { "Medium" } %>
      <%= render BadgeComponent.new(size: :lg) { "Large" } %>
    </div>
  </section>
</div>
```

**Benefits:**
- Show multiple variants in one preview
- Create visual component documentation
- Better for comprehensive overview
</pattern>

## Dynamic Previews

<pattern name="dynamic-parameters">
<description>Interactive previews with URL parameters</description>

**Preview with Params:**
```ruby
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
  # @param title text
  def with_dismiss_button(dismissible: true, title: "Alert Title")
    render(Ui::AlertComponent.new(type: :info, dismissible: dismissible)) do
      content_tag(:h4, title, class: "font-bold") +
      content_tag(:p, "This alert can be dismissed")
    end
  end

  # @param count number
  # @param show_icon toggle
  def notification_badge(count: 5, show_icon: true)
    render(BadgeComponent.new(variant: :error, show_icon: show_icon)) do
      count.to_s
    end
  end
end
```

**Parameter Annotations:**
```ruby
# @param name text                      # Text input field
# @param count number                    # Number input field
# @param active toggle                   # Checkbox (true/false)
# @param type select { choices: [...] }  # Dropdown select
# @param size radio { choices: [...] }   # Radio button group
```

**Access with Query Params:**
```
/rails/view_components/alert_component/default?type=error&message=Something+went+wrong
/rails/view_components/alert_component/with_dismiss_button?dismissible=false&title=Important
/rails/view_components/badge_component/notification_badge?count=10&show_icon=false
```

**Benefits:**
- Test different inputs without code changes
- Share specific component states via URL
- Quickly explore edge cases
</pattern>

## Custom Layouts

<pattern name="custom-preview-layout">
<description>Use custom layout for preview pages</description>

**Preview with Layout:**
```ruby
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

  def full_screen
    render(ModalComponent.new(size: :full, open: true)) do |modal|
      modal.with_header { "Full Screen Modal" }
      content_tag :div, "Content fills the screen", class: "p-8"
    end
  end
end
```

**Custom Layout Template:**
```erb
<!-- app/views/layouts/component_preview.html.erb -->
<!DOCTYPE html>
<html data-theme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Component Preview</title>
  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  <%= javascript_importmap_tags %>
</head>
<body class="p-8 bg-base-200">
  <div class="max-w-6xl mx-auto">
    <%= yield %>
  </div>
</body>
</html>
```

**Set Default Layout:**
```ruby
# config/application.rb
config.view_component.default_preview_layout = "component_preview"
```

**Benefits:**
- Include necessary JavaScript and CSS
- Add preview-specific styling
- Create consistent preview environment
</pattern>

## Preview Collections

<pattern name="collection-preview">
<description>Preview components rendered as collections</description>

**Preview with Collection:**
```ruby
# test/components/previews/feedback_item_component_preview.rb
class FeedbackItemComponentPreview < ViewComponent::Preview
  def collection
    feedbacks = sample_feedbacks
    render(FeedbackItemComponent.with_collection(feedbacks))
  end

  def with_spacer
    feedbacks = sample_feedbacks
    render(
      FeedbackItemComponent.with_collection(
        feedbacks,
        spacer_component: DividerComponent.new
      )
    )
  end

  def with_iteration_context
    feedbacks = sample_feedbacks
    render_with_template(locals: { feedbacks: feedbacks })
  end

  private

  def sample_feedbacks
    [
      Struct.new(:id, :content, :status, :created_at).new(
        1,
        "Great service!",
        "pending",
        1.day.ago
      ),
      Struct.new(:id, :content, :status, :created_at).new(
        2,
        "Could be better",
        "reviewed",
        2.days.ago
      ),
      Struct.new(:id, :content, :status, :created_at).new(
        3,
        "Excellent experience",
        "responded",
        3.days.ago
      )
    ]
  end
end
```

**Preview Template for Iteration:**
```erb
<!-- test/components/previews/feedback_item_component_preview/with_iteration_context.html.erb -->
<div class="space-y-2">
  <%= render(FeedbackItemComponent.with_collection(feedbacks)) %>
</div>
```

**Benefits:**
- Test collection rendering
- Preview spacing and dividers
- See iteration context in action
</pattern>

<pattern name="real-world-list-preview">
<description>Comprehensive preview for list component with multiple states</description>

**List Component Preview:**
```ruby
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

    def large_dataset
      feedbacks = 50.times.map do |i|
        Struct.new(:id, :content, :status, :created_at).new(
          i + 1,
          "Feedback number #{i + 1}",
          %w[pending reviewed responded].sample,
          rand(1..30).days.ago
        )
      end
      render(ListComponent.new(feedbacks: feedbacks, show_actions: true))
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
```

**Benefits:**
- Preview all component states (default, empty, variations)
- Test with realistic data
- Check performance with large datasets
</pattern>

## Preview Organization

<pattern name="organized-previews">
<description>Organize previews by module and feature</description>

**Directory Structure:**
```
test/components/previews/
├── ui/
│   ├── button_component_preview.rb
│   ├── badge_component_preview.rb
│   ├── alert_component_preview.rb
│   └── modal_component_preview.rb
├── feedback_components/
│   ├── card_component_preview.rb
│   ├── list_component_preview.rb
│   └── item_component_preview.rb
└── layout/
    ├── header_component_preview.rb
    ├── footer_component_preview.rb
    └── sidebar_component_preview.rb
```

**Namespaced Preview:**
```ruby
# test/components/previews/ui/button_component_preview.rb
module Ui
  class ButtonComponentPreview < ViewComponent::Preview
    def default
      render(Ui::ButtonComponent.new(variant: :primary)) { "Click Me" }
    end
  end
end
```

**Configuration for Multiple Paths:**
```ruby
# config/environments/development.rb
config.view_component.previews.paths = [
  Rails.root.join("test/components/previews"),
  Rails.root.join("test/components/previews/ui"),
  Rails.root.join("test/components/previews/feedback_components")
]
```

**Benefits:**
- Keep previews organized by feature
- Match component directory structure
- Easier to find and maintain
</pattern>

## Testing with Previews

<pattern name="preview-in-tests">
<description>Use previews in automated tests</description>

**Component Test Using Preview:**
```ruby
# test/components/button_component_test.rb
class ButtonComponentTest < ViewComponent::TestCase
  test "renders preview states correctly" do
    # Test the default preview
    render_preview(:default, from: ButtonComponentPreview)
    assert_selector "button.btn-primary", text: "Click Me"
  end

  test "disabled preview renders correctly" do
    render_preview(:disabled_state, from: ButtonComponentPreview)
    assert_selector "button[disabled]"
  end

  test "all preview examples are valid" do
    ButtonComponentPreview.public_instance_methods(false).each do |preview|
      render_preview(preview, from: ButtonComponentPreview)
      assert_selector "button"
    end
  end
end
```

**System Test Using Preview:**
```ruby
# test/system/component_visual_test.rb
class ComponentVisualTest < ApplicationSystemTestCase
  test "button component looks correct" do
    visit rails_view_components_path("button_component", "default")

    assert_selector "button", text: "Click Me"
    take_screenshot
  end
end
```

**Benefits:**
- Reuse preview data in tests
- Ensure previews stay functional
- Visual regression testing
</pattern>

<antipatterns>
<antipattern>
<description>Creating previews with database dependencies</description>
<reason>Previews should work without database setup. Use Structs or fixtures instead.</reason>
<bad-example>
```ruby
# ❌ BAD - Requires database records
class UserCardComponentPreview < ViewComponent::Preview
  def default
    user = User.first # Fails if database is empty
    render(UserCardComponent.new(user: user))
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Uses Struct for sample data
class UserCardComponentPreview < ViewComponent::Preview
  def default
    user = Struct.new(:id, :name, :email, :premium).new(
      1,
      "John Doe",
      "john@example.com",
      true
    )
    render(UserCardComponent.new(user: user))
  end

  def non_premium_user
    user = Struct.new(:id, :name, :email, :premium).new(
      2,
      "Jane Smith",
      "jane@example.com",
      false
    )
    render(UserCardComponent.new(user: user))
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not showing edge cases in previews</description>
<reason>Previews are perfect for testing edge cases that are hard to create in regular usage.</reason>
<bad-example>
```ruby
# ❌ BAD - Only shows happy path
class CardComponentPreview < ViewComponent::Preview
  def default
    render(CardComponent.new(title: "Card Title")) do
      "Normal content"
    end
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Shows multiple states and edge cases
class CardComponentPreview < ViewComponent::Preview
  def default
    render(CardComponent.new(title: "Card Title")) do
      "Normal content"
    end
  end

  def long_title
    render(CardComponent.new(
      title: "This is a very long title that might cause layout issues in the card component"
    )) do
      "Content with long title"
    end
  end

  def empty_content
    render(CardComponent.new(title: "Empty Card")) do
      ""
    end
  end

  def with_html_content
    render(CardComponent.new(title: "Rich Content")) do
      content_tag(:div) do
        content_tag(:p, "Paragraph 1") +
        content_tag(:ul) do
          content_tag(:li, "Item 1") +
          content_tag(:li, "Item 2")
        end
      end
    end
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not using descriptive preview method names</description>
<reason>Method names appear in the preview UI - use clear, descriptive names.</reason>
<bad-example>
```ruby
# ❌ BAD - Unclear method names
class ButtonComponentPreview < ViewComponent::Preview
  def example1
    render(ButtonComponent.new(variant: :primary)) { "Button" }
  end

  def example2
    render(ButtonComponent.new(variant: :secondary)) { "Button" }
  end

  def test3
    render(ButtonComponent.new(disabled: true)) { "Button" }
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Clear, descriptive names
class ButtonComponentPreview < ViewComponent::Preview
  def default
    render(ButtonComponent.new(variant: :primary)) { "Click Me" }
  end

  def secondary_variant
    render(ButtonComponent.new(variant: :secondary)) { "Secondary" }
  end

  def disabled_state
    render(ButtonComponent.new(disabled: true)) { "Disabled" }
  end

  def loading_with_icon
    render(ButtonComponent.new(loading: true)) { "Loading..." }
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not using preview templates for complex layouts</description>
<reason>Complex HTML in Ruby is hard to read. Use templates for better organization.</reason>
<bad-example>
```ruby
# ❌ BAD - Complex HTML in Ruby
class DashboardWidgetPreview < ViewComponent::Preview
  def default
    render_inline do
      content_tag(:div, class: "grid grid-cols-3 gap-4") do
        content_tag(:div) do
          render(WidgetComponent.new(title: "Widget 1")) { "Content 1" }
        end +
        content_tag(:div) do
          render(WidgetComponent.new(title: "Widget 2")) { "Content 2" }
        end +
        content_tag(:div) do
          render(WidgetComponent.new(title: "Widget 3")) { "Content 3" }
        end
      end
    end
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use template for complex layouts
class DashboardWidgetPreview < ViewComponent::Preview
  def default
    render_with_template
  end
end

# test/components/previews/dashboard_widget_preview/default.html.erb
# <div class="grid grid-cols-3 gap-4">
#   <div><%= render WidgetComponent.new(title: "Widget 1") { "Content 1" } %></div>
#   <div><%= render WidgetComponent.new(title: "Widget 2") { "Content 2" } %></div>
#   <div><%= render WidgetComponent.new(title: "Widget 3") { "Content 3" } %></div>
# </div>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test that previews render correctly and remain functional:

```ruby
# test/components/previews_test.rb
require "test_helper"

class PreviewsTest < ViewComponent::TestCase
  # Test that all preview examples render without errors
  ViewComponent::Preview.all.each do |preview_class|
    preview_class.public_instance_methods(false).each do |preview_method|
      test "#{preview_class}##{preview_method} renders successfully" do
        render_preview(preview_method, from: preview_class)

        # Basic assertion that something was rendered
        assert_not_empty page.text.strip
      rescue => e
        flunk "Preview #{preview_class}##{preview_method} failed to render: #{e.message}"
      end
    end
  end
end

# test/system/preview_index_test.rb
class PreviewIndexTest < ApplicationSystemTestCase
  test "can access preview index" do
    visit rails_view_components_path

    assert_text "ViewComponent Previews"
    assert_selector "a", text: "ButtonComponent"
  end

  test "can view individual preview" do
    visit rails_view_components_path("button_component", "default")

    assert_selector "button", text: "Click Me"
  end
end
```
</testing>

<related-skills>
- viewcomponent-basics - Foundation for creating components
- viewcomponent-slots - Components with multiple content areas
- viewcomponent-variants - Style variants and polymorphic rendering
- testing-viewcomponents - Comprehensive component testing
- hotwire-turbo - Dynamic updates with Turbo
</related-skills>

<resources>
- [ViewComponent Previews Documentation](https://viewcomponent.org/guide/previews.html)
- [Preview Parameters](https://viewcomponent.org/guide/previews.html#preview-parameters)
- [Testing Previews](https://viewcomponent.org/guide/testing.html#render_preview)
- [Lookbook Gem - Enhanced Previews](https://github.com/ViewComponent/lookbook)
</resources>
