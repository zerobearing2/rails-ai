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

```ruby
# test/components/previews/button_component_preview.rb
class ButtonComponentPreview < ViewComponent::Preview
  def default
    render(ButtonComponent.new(variant: :primary, size: :md)) { "Click Me" }
  end

  def disabled_state
    render(ButtonComponent.new(variant: :primary, disabled: true)) { "Disabled" }
  end

  def loading_state
    render(ButtonComponent.new(variant: :primary, loading: true)) { "Loading..." }
  end
end
```

Access at `/rails/view_components/button_component/default`. Each method shows a specific state without database setup.
</pattern>

<pattern name="preview-with-template">
<description>Use custom template for complex preview layouts</description>

```ruby
# test/components/previews/badge_component_preview.rb
class BadgeComponentPreview < ViewComponent::Preview
  def all_variants
    render_with_template
  end
end
```

```erb
<!-- test/components/previews/badge_component_preview/all_variants.html.erb -->
<div class="space-y-4">
  <div class="flex gap-2 flex-wrap">
    <%= render BadgeComponent.new(variant: :primary) { "Primary" } %>
    <%= render BadgeComponent.new(variant: :success) { "Success" } %>
    <%= render BadgeComponent.new(variant: :error) { "Error" } %>
  </div>
  <div class="flex gap-2 items-center">
    <%= render BadgeComponent.new(size: :sm) { "Small" } %>
    <%= render BadgeComponent.new(size: :md) { "Medium" } %>
    <%= render BadgeComponent.new(size: :lg) { "Large" } %>
  </div>
</div>
```

Use templates for complex layouts with multiple variants.
</pattern>

## Dynamic Previews

<pattern name="dynamic-parameters">
<description>Interactive previews with URL parameters</description>

```ruby
# test/components/previews/alert_component_preview.rb
class AlertComponentPreview < ViewComponent::Preview
  # @param type select { choices: [success, error, warning, info] }
  # @param message text
  def default(type: "success", message: "Operation completed successfully")
    render(Ui::AlertComponent.new(type: type.to_sym)) { message }
  end

  # @param dismissible toggle
  def with_dismiss(dismissible: true)
    render(Ui::AlertComponent.new(type: :info, dismissible: dismissible)) do
      "This alert can be dismissed"
    end
  end
end
```

**Parameter Types:**
- `text` - Text input
- `number` - Number input
- `toggle` - Checkbox (true/false)
- `select { choices: [...] }` - Dropdown
- `radio { choices: [...] }` - Radio buttons

Access with params: `/rails/view_components/alert_component/default?type=error&message=Error+text`
</pattern>

## Custom Layouts

<pattern name="custom-preview-layout">
<description>Use custom layout for preview pages</description>

```ruby
# test/components/previews/modal_component_preview.rb
class ModalComponentPreview < ViewComponent::Preview
  layout "component_preview"

  def default
    render(ModalComponent.new(size: :md, open: true)) do |modal|
      modal.with_header { "Preview Modal" }
      "Modal content with custom layout."
    end
  end
end
```

```erb
<!-- app/views/layouts/component_preview.html.erb -->
<!DOCTYPE html>
<html>
<head>
  <%= stylesheet_link_tag "application" %>
  <%= javascript_importmap_tags %>
</head>
<body class="p-8">
  <%= yield %>
</body>
</html>
```

Set globally: `config.view_component.default_preview_layout = "component_preview"`
</pattern>

## Preview Collections

<pattern name="collection-preview">
<description>Preview components rendered as collections</description>

```ruby
# test/components/previews/feedback_item_component_preview.rb
class FeedbackItemComponentPreview < ViewComponent::Preview
  def collection
    render(FeedbackItemComponent.with_collection(sample_feedbacks))
  end

  def with_spacer
    render(
      FeedbackItemComponent.with_collection(
        sample_feedbacks,
        spacer_component: DividerComponent.new
      )
    )
  end

  private

  def sample_feedbacks
    [
      Struct.new(:id, :content, :status).new(1, "Great service!", "pending"),
      Struct.new(:id, :content, :status).new(2, "Could be better", "reviewed")
    ]
  end
end
```

Use `with_collection` to preview multiple items with optional spacers.
</pattern>

<pattern name="multiple-states-preview">
<description>Preview component with different states</description>

```ruby
# test/components/previews/feedback_components/list_component_preview.rb
module FeedbackComponents
  class ListComponentPreview < ViewComponent::Preview
    def default
      render(ListComponent.new(feedbacks: sample_feedbacks, show_actions: true))
    end

    def empty_state
      render(ListComponent.new(feedbacks: [], show_actions: false))
    end

    def large_dataset
      feedbacks = 50.times.map { |i|
        Struct.new(:id, :content, :status).new(i, "Feedback #{i}", "pending")
      }
      render(ListComponent.new(feedbacks: feedbacks, show_actions: true))
    end

    private

    def sample_feedbacks
      [
        Struct.new(:id, :content, :status).new(1, "Great feature!", "responded"),
        Struct.new(:id, :content, :status).new(2, "Found a bug", "reviewed")
      ]
    end
  end
end
```

Preview default, empty, and edge case states to validate behavior.
</pattern>

## Preview Organization

<pattern name="organized-previews">
<description>Organize previews by module and feature</description>

```
test/components/previews/
├── ui/
│   ├── button_component_preview.rb
│   └── badge_component_preview.rb
└── feedback_components/
    └── list_component_preview.rb
```

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

Match component directory structure for easier maintenance.
</pattern>

## Testing with Previews

<pattern name="preview-in-tests">
<description>Use previews in automated tests</description>

```ruby
# test/components/button_component_test.rb
class ButtonComponentTest < ViewComponent::TestCase
  test "renders preview correctly" do
    render_preview(:default, from: ButtonComponentPreview)
    assert_selector "button.btn-primary", text: "Click Me"
  end

  test "all previews render" do
    ButtonComponentPreview.public_instance_methods(false).each do |preview|
      render_preview(preview, from: ButtonComponentPreview)
      assert_selector "button"
    end
  end
end
```

Use `render_preview` to test components using preview data.
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
    render(CardComponent.new(title: "Card Title")) { "Normal content" }
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Shows multiple states and edge cases
class CardComponentPreview < ViewComponent::Preview
  def default
    render(CardComponent.new(title: "Card Title")) { "Normal content" }
  end

  def long_title
    render(CardComponent.new(
      title: "Very long title that might cause layout issues"
    )) { "Content" }
  end

  def empty_content
    render(CardComponent.new(title: "Empty Card")) { "" }
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

  def disabled_state
    render(ButtonComponent.new(disabled: true)) { "Disabled" }
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
        3.times.map { |i| content_tag(:div) { render(WidgetComponent.new) } }.join.html_safe
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

# Template: test/components/previews/dashboard_widget_preview/default.html.erb
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# test/components/previews_test.rb
class PreviewsTest < ViewComponent::TestCase
  ViewComponent::Preview.all.each do |preview_class|
    preview_class.public_instance_methods(false).each do |preview_method|
      test "#{preview_class}##{preview_method} renders" do
        render_preview(preview_method, from: preview_class)
        assert_not_empty page.text.strip
      end
    end
  end
end
```
</testing>

<related-skills>
- viewcomponent-basics - Foundation for creating components
- viewcomponent-slots - Components with multiple content areas
- viewcomponent-variants - Style variants and polymorphic rendering
- viewcomponent-testing - Comprehensive component testing
- hotwire-turbo - Dynamic updates with Turbo
</related-skills>

<resources>
- [ViewComponent Previews Documentation](https://viewcomponent.org/guide/previews.html)
- [Preview Parameters](https://viewcomponent.org/guide/previews.html#preview-parameters)
- [Testing Previews](https://viewcomponent.org/guide/testing.html#render_preview)
- [Lookbook Gem - Enhanced Previews](https://github.com/ViewComponent/lookbook)
</resources>
