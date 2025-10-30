---
name: tailwind-utility-first
domain: frontend
dependencies: []
version: 1.0
rails_version: 8.1+
css_framework: tailwind-css-4.0+
---

# Tailwind CSS Utility-First Design

Tailwind CSS is a utility-first CSS framework that provides low-level utility classes to build custom designs without writing custom CSS.

<when-to-use>
- Building any user interface in Rails 8.1+
- Need rapid UI development without custom CSS
- Want consistent spacing, colors, and sizing across app
- Building responsive layouts (mobile-first approach)
- Creating custom designs (not using pre-built components)
- Need maintainable, reusable styling patterns
</when-to-use>

<benefits>
- **No Custom CSS** - Build entire UIs using utility classes
- **Mobile-First** - Responsive design built-in with breakpoint prefixes
- **Consistency** - Design tokens (spacing, colors) prevent arbitrary values
- **Performance** - Only used utilities are included in production CSS
- **Maintainability** - Styles live with markup, easy to change
- **Developer Experience** - IntelliSense support, fast iteration
- **Composability** - Combine utilities to create any design
</benefits>

<standards>
- Use utility classes directly in HTML/ERB (no custom CSS files)
- Follow mobile-first responsive design (base → sm → md → lg → xl)
- Prefer Tailwind utilities over inline styles ALWAYS
- Use `@apply` sparingly, only in components with repeated patterns
- Configure design tokens in `tailwind.config.js` for brand consistency
- Keep class lists readable with proper formatting/line breaks
- Use ViewComponent for complex components with many utilities
- Never mix Tailwind utilities with custom CSS in same element
</standards>

## Core Utility Patterns

<pattern name="spacing-utilities">
<description>Consistent spacing using Tailwind's spacing scale</description>

**Padding:**
```erb
<%# ✅ Tailwind spacing utilities %>
<div class="p-4">Padding all sides (1rem)</div>
<div class="px-6 py-4">Horizontal 6, Vertical 4</div>
<div class="pt-8 pb-4">Top 8, Bottom 4</div>

<%# Spacing scale: 0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 56, 64 %>
<div class="p-0">No padding</div>
<div class="p-px">1px padding</div>
```

**Margin:**
```erb
<div class="m-4">Margin all sides</div>
<div class="mx-auto">Center horizontally</div>
<div class="mt-8 mb-4">Top 8, Bottom 4</div>
<div class="-mt-4">Negative margin (overlap)</div>
```

**Gap (for flex/grid):**
```erb
<div class="flex gap-4">
  <div>Item 1</div>
  <div>Item 2</div>
</div>

<div class="grid grid-cols-3 gap-6">
  <%# Grid with gaps %>
</div>
```

**❌ NEVER use inline styles:**
```erb
<%# ❌ BAD - Inline styles %>
<div style="padding: 16px;">Content</div>

<%# ✅ GOOD - Tailwind utilities %>
<div class="p-4">Content</div>
```
</pattern>

<pattern name="flexbox-layout">
<description>Flexbox utilities for layouts and alignment</description>

**Basic Flex:**
```erb
<%# Horizontal layout %>
<div class="flex items-center gap-4">
  <span>Left</span>
  <span>Right</span>
</div>

<%# Vertical layout %>
<div class="flex flex-col gap-2">
  <div>Item 1</div>
  <div>Item 2</div>
</div>
```

**Justify & Align:**
```erb
<%# Space between items %>
<div class="flex justify-between items-center">
  <span>Left</span>
  <span>Right</span>
</div>

<%# Center content %>
<div class="flex justify-center items-center h-screen">
  <div>Centered content</div>
</div>

<%# Align end %>
<div class="flex justify-end items-end">
  <button class="btn">Action</button>
</div>
```

**Flex Wrap:**
```erb
<div class="flex flex-wrap gap-4">
  <div class="w-32">Item 1</div>
  <div class="w-32">Item 2</div>
  <div class="w-32">Item 3</div>
</div>
```

**Flex Grow/Shrink:**
```erb
<div class="flex gap-4">
  <div class="flex-1">Takes remaining space</div>
  <div class="flex-none w-32">Fixed width</div>
</div>
```
</pattern>

<pattern name="grid-layout">
<description>Grid utilities for complex layouts</description>

**Basic Grid:**
```erb
<%# 3-column grid %>
<div class="grid grid-cols-3 gap-4">
  <% @items.each do |item| %>
    <div class="bg-white p-4 rounded-lg shadow">
      <%= item.name %>
    </div>
  <% end %>
</div>

<%# Auto-fit columns %>
<div class="grid grid-cols-[repeat(auto-fit,minmax(250px,1fr))] gap-4">
  <%# Responsive grid without breakpoints %>
</div>
```

**Grid Span:**
```erb
<div class="grid grid-cols-4 gap-4">
  <div class="col-span-2">Spans 2 columns</div>
  <div class="col-span-1">1 column</div>
  <div class="col-span-1">1 column</div>
  <div class="col-span-4">Full width</div>
</div>
```

**Grid Template Areas:**
```erb
<div class="grid grid-cols-3 grid-rows-3 gap-4 h-screen">
  <header class="col-span-3 bg-gray-100">Header</header>
  <aside class="row-span-2 bg-gray-50">Sidebar</aside>
  <main class="col-span-2 row-span-2">Content</main>
  <footer class="col-span-3 bg-gray-100">Footer</footer>
</div>
```
</pattern>

<pattern name="responsive-design">
<description>Mobile-first responsive utilities with breakpoints</description>

**Breakpoints:**
```
sm: 640px   (tablets)
md: 768px   (small laptops)
lg: 1024px  (laptops)
xl: 1280px  (desktops)
2xl: 1536px (large desktops)
```

**Responsive Grid:**
```erb
<%# Mobile: 1 column, Tablet: 2 columns, Desktop: 3 columns %>
<div class="
  grid
  grid-cols-1
  sm:grid-cols-2
  lg:grid-cols-3
  gap-4
">
  <% @feedbacks.each do |feedback| %>
    <%= render feedback %>
  <% end %>
</div>
```

**Responsive Spacing:**
```erb
<%# Padding increases on larger screens %>
<div class="
  p-4
  md:p-8
  lg:p-12
">
  <h1 class="
    text-2xl
    md:text-3xl
    lg:text-4xl
    font-bold
  ">
    Responsive Heading
  </h1>
</div>
```

**Hide/Show by Breakpoint:**
```erb
<%# Mobile only %>
<div class="block md:hidden">
  <button class="btn">Mobile Menu</button>
</div>

<%# Desktop only %>
<nav class="hidden md:block">
  <a href="#">Nav Item 1</a>
  <a href="#">Nav Item 2</a>
</nav>

<%# Tablet and up %>
<div class="hidden sm:flex gap-4">
  Desktop navigation
</div>
```

**Responsive Flexbox:**
```erb
<%# Vertical on mobile, horizontal on tablet+ %>
<div class="
  flex
  flex-col
  md:flex-row
  gap-4
  md:items-center
  md:justify-between
">
  <div>Content</div>
  <button class="btn">Action</button>
</div>
```
</pattern>

<pattern name="typography-utilities">
<description>Text styling, sizing, and formatting</description>

**Font Size:**
```erb
<p class="text-xs">Extra small (0.75rem)</p>
<p class="text-sm">Small (0.875rem)</p>
<p class="text-base">Base (1rem)</p>
<p class="text-lg">Large (1.125rem)</p>
<p class="text-xl">Extra large (1.25rem)</p>
<p class="text-2xl">2x large (1.5rem)</p>
<p class="text-3xl">3x large (1.875rem)</p>
<p class="text-4xl">4x large (2.25rem)</p>
```

**Font Weight & Style:**
```erb
<p class="font-thin">Thin (100)</p>
<p class="font-light">Light (300)</p>
<p class="font-normal">Normal (400)</p>
<p class="font-medium">Medium (500)</p>
<p class="font-semibold">Semibold (600)</p>
<p class="font-bold">Bold (700)</p>
<p class="font-extrabold">Extra bold (800)</p>

<p class="italic">Italic text</p>
<p class="not-italic">Not italic</p>
```

**Text Alignment & Transform:**
```erb
<p class="text-left">Left aligned</p>
<p class="text-center">Center aligned</p>
<p class="text-right">Right aligned</p>
<p class="text-justify">Justified</p>

<p class="uppercase">UPPERCASE</p>
<p class="lowercase">lowercase</p>
<p class="capitalize">Capitalize Each Word</p>
```

**Line Height & Letter Spacing:**
```erb
<p class="leading-tight">Tight line height</p>
<p class="leading-normal">Normal line height</p>
<p class="leading-relaxed">Relaxed line height</p>
<p class="leading-loose">Loose line height</p>

<p class="tracking-tight">Tight spacing</p>
<p class="tracking-wide">Wide spacing</p>
```

**Text Decoration:**
```erb
<a href="#" class="underline">Underlined link</a>
<p class="line-through">Strikethrough</p>
<p class="no-underline">No underline</p>
```

**Text Truncation:**
```erb
<%# Single line truncate %>
<p class="truncate">
  <%= feedback.content %>
</p>

<%# Multi-line clamp %>
<p class="line-clamp-2">
  <%= feedback.content %>
</p>
```
</pattern>

<pattern name="colors-and-backgrounds">
<description>Color utilities for text, backgrounds, and borders</description>

**Text Colors:**
```erb
<p class="text-gray-900">Dark gray text</p>
<p class="text-gray-600">Medium gray text</p>
<p class="text-gray-400">Light gray text</p>

<p class="text-blue-600">Blue text</p>
<p class="text-red-600">Red text</p>
<p class="text-green-600">Green text</p>

<%# Opacity variants %>
<p class="text-gray-900/50">50% opacity</p>
<p class="text-blue-600/75">75% opacity</p>
```

**Background Colors:**
```erb
<div class="bg-white">White background</div>
<div class="bg-gray-50">Very light gray</div>
<div class="bg-gray-100">Light gray</div>
<div class="bg-blue-600 text-white">Blue with white text</div>

<%# Gradient backgrounds %>
<div class="bg-gradient-to-r from-blue-500 to-purple-600 text-white">
  Gradient background
</div>
```

**Border Colors:**
```erb
<div class="border border-gray-300">Gray border</div>
<div class="border-2 border-blue-500">Blue border</div>
<div class="divide-y divide-gray-200">
  <div>Item 1</div>
  <div>Item 2</div>
</div>
```

**❌ NEVER hardcode colors:**
```erb
<%# ❌ BAD - Hardcoded color values %>
<div style="color: #1a202c;">Text</div>

<%# ✅ GOOD - Tailwind color utilities %>
<div class="text-gray-900">Text</div>
```
</pattern>

<pattern name="hover-focus-states">
<description>Interactive states using state modifiers</description>

**Hover States:**
```erb
<button class="
  bg-blue-600
  hover:bg-blue-700
  text-white
  px-4 py-2
  rounded
">
  Hover me
</button>

<a href="#" class="
  text-blue-600
  hover:text-blue-800
  hover:underline
">
  Hover link
</a>
```

**Focus States:**
```erb
<input
  type="text"
  class="
    border
    border-gray-300
    focus:border-blue-500
    focus:ring-2
    focus:ring-blue-200
    rounded
    px-3 py-2
  "
/>

<button class="
  btn
  focus:outline-none
  focus:ring-2
  focus:ring-blue-500
  focus:ring-offset-2
">
  Focus me
</button>
```

**Active States:**
```erb
<button class="
  bg-blue-600
  hover:bg-blue-700
  active:bg-blue-800
  text-white
  px-4 py-2
">
  Click me
</button>
```

**Disabled States:**
```erb
<button
  disabled
  class="
    bg-gray-400
    text-gray-700
    disabled:opacity-50
    disabled:cursor-not-allowed
    px-4 py-2
  "
>
  Disabled
</button>
```

**Group Hover:**
```erb
<div class="group hover:bg-gray-100 p-4 rounded">
  <h3 class="group-hover:text-blue-600">Title</h3>
  <p class="text-gray-600 group-hover:text-gray-900">Description</p>
</div>
```
</pattern>

<pattern name="borders-and-shadows">
<description>Border radius, width, and shadow utilities</description>

**Border Radius:**
```erb
<div class="rounded-none">No rounding</div>
<div class="rounded-sm">Small rounding</div>
<div class="rounded">Default rounding (0.25rem)</div>
<div class="rounded-md">Medium rounding</div>
<div class="rounded-lg">Large rounding</div>
<div class="rounded-xl">Extra large rounding</div>
<div class="rounded-2xl">2x large rounding</div>
<div class="rounded-full">Fully rounded (pill/circle)</div>

<%# Specific corners %>
<div class="rounded-t-lg">Top corners rounded</div>
<div class="rounded-l-lg">Left corners rounded</div>
<div class="rounded-br-lg">Bottom right corner</div>
```

**Border Width:**
```erb
<div class="border">1px border all sides</div>
<div class="border-2">2px border</div>
<div class="border-4">4px border</div>
<div class="border-8">8px border</div>

<%# Specific sides %>
<div class="border-t">Top border only</div>
<div class="border-b-2">2px bottom border</div>
<div class="border-x">Left and right borders</div>
```

**Shadows:**
```erb
<div class="shadow-sm">Small shadow</div>
<div class="shadow">Default shadow</div>
<div class="shadow-md">Medium shadow</div>
<div class="shadow-lg">Large shadow</div>
<div class="shadow-xl">Extra large shadow</div>
<div class="shadow-2xl">2x large shadow</div>

<%# Colored shadows %>
<div class="shadow-lg shadow-blue-500/50">Blue shadow</div>

<%# Remove shadow on hover %>
<div class="shadow-lg hover:shadow-none">Shadow disappears</div>
```
</pattern>

<pattern name="sizing-utilities">
<description>Width and height utilities</description>

**Fixed Width:**
```erb
<div class="w-32">Width 8rem (128px)</div>
<div class="w-64">Width 16rem (256px)</div>
<div class="w-96">Width 24rem (384px)</div>
```

**Percentage Width:**
```erb
<div class="w-1/2">50% width</div>
<div class="w-1/3">33.33% width</div>
<div class="w-2/3">66.66% width</div>
<div class="w-1/4">25% width</div>
<div class="w-full">100% width</div>
```

**Viewport & Container Width:**
```erb
<div class="w-screen">Full viewport width</div>
<div class="max-w-md">Max width 28rem</div>
<div class="max-w-4xl">Max width 56rem</div>
<div class="max-w-7xl mx-auto">Centered container</div>

<div class="container mx-auto px-4">
  <%# Responsive container with padding %>
</div>
```

**Height:**
```erb
<div class="h-64">Height 16rem</div>
<div class="h-screen">Full viewport height</div>
<div class="min-h-screen">Min height viewport</div>

<%# Percentage height (requires parent height) %>
<div class="h-full">100% of parent height</div>
```
</pattern>

## ViewComponent Integration

<pattern name="component-with-tailwind">
<description>Using Tailwind utilities in ViewComponent</description>

**Component Class:**
```ruby
# app/components/alert_component.rb
class AlertComponent < ViewComponent::Base
  def initialize(message:, variant: :info)
    @message = message
    @variant = variant
  end

  private

  attr_reader :message, :variant

  def alert_classes
    base = "flex items-center gap-3 p-4 rounded-lg"
    variant_classes = {
      info: "bg-blue-50 text-blue-900 border border-blue-200",
      success: "bg-green-50 text-green-900 border border-green-200",
      warning: "bg-yellow-50 text-yellow-900 border border-yellow-200",
      error: "bg-red-50 text-red-900 border border-red-200"
    }

    "#{base} #{variant_classes.fetch(variant, variant_classes[:info])}"
  end

  def icon_color
    {
      info: "text-blue-600",
      success: "text-green-600",
      warning: "text-yellow-600",
      error: "text-red-600"
    }.fetch(variant, "text-blue-600")
  end
end
```

**Component Template:**
```erb
<!-- app/components/alert_component.html.erb -->
<div class="<%= alert_classes %>" role="alert">
  <svg class="w-5 h-5 flex-shrink-0 <%= icon_color %>" fill="currentColor" viewBox="0 0 20 20">
    <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
  </svg>
  <p class="text-sm font-medium"><%= message %></p>
</div>
```

**Usage:**
```erb
<%= render AlertComponent.new(message: "Feedback submitted!", variant: :success) %>
<%= render AlertComponent.new(message: "Error occurred", variant: :error) %>
```

**Benefits:**
- Tailwind classes stay in template
- Helper methods manage conditional classes
- Easy to maintain and test
- No custom CSS files needed
</pattern>

<pattern name="dynamic-classes">
<description>Conditionally applying Tailwind classes</description>

**Using Class Concatenation:**
```erb
<%# Simple conditional classes %>
<div class="<%= "bg-blue-500" if @selected %> p-4">
  Content
</div>

<%# Multiple conditions %>
<button class="
  btn
  <%= "btn-primary" if @primary %>
  <%= "btn-disabled" if @disabled %>
  <%= "btn-lg" if @large %>
">
  Click me
</button>
```

**Using Array Join:**
```ruby
# In component or helper
def button_classes(variant, size, disabled)
  classes = ["btn"]
  classes << "btn-#{variant}" if variant
  classes << "btn-#{size}" if size != :md
  classes << "opacity-50 cursor-not-allowed" if disabled
  classes.join(" ")
end
```

**Using Hash for Conditional Classes:**
```ruby
# app/helpers/component_helper.rb
module ComponentHelper
  def class_names(*classes)
    classes.flatten.compact.join(" ")
  end
end
```

**Usage:**
```erb
<div class="<%= class_names(
  "p-4 rounded-lg",
  "bg-blue-500" => @selected,
  "bg-gray-100" => !@selected,
  "shadow-lg" => @elevated
) %>">
  Content
</div>
```
</pattern>

## Custom Configuration

<pattern name="tailwind-config">
<description>Customizing Tailwind with config file</description>

**config/tailwind.config.js:**
```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/components/**/*.rb',
    './app/components/**/*.html.erb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        // Brand colors
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',
          600: '#2563eb',
          900: '#1e3a8a'
        },
        // Custom colors
        brand: {
          light: '#f0f9ff',
          DEFAULT: '#0284c7',
          dark: '#075985'
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['Fira Code', 'monospace']
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem'
      },
      maxWidth: {
        '8xl': '88rem',
        '9xl': '96rem'
      }
    }
  },
  plugins: []
}
```

**Usage:**
```erb
<div class="bg-brand text-white p-4">
  Brand color
</div>

<div class="max-w-8xl mx-auto">
  Custom max width
</div>

<div class="font-mono text-sm">
  Monospace font
</div>
```
</pattern>

## Real-World Examples

<pattern name="feedback-card">
<description>Complete feedback card using only Tailwind utilities</description>

```erb
<div class="bg-white rounded-lg shadow-md hover:shadow-xl transition-shadow duration-200 overflow-hidden">
  <div class="p-6">
    <%# Header %>
    <div class="flex items-start justify-between mb-4">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white font-semibold">
          <%= @feedback.sender_name&.first&.upcase || "A" %>
        </div>
        <div>
          <h3 class="font-semibold text-gray-900">
            <%= @feedback.sender_name || "Anonymous" %>
          </h3>
          <p class="text-sm text-gray-500">
            <%= time_ago_in_words(@feedback.created_at) %> ago
          </p>
        </div>
      </div>

      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
        <%= @feedback.status.titleize %>
      </span>
    </div>

    <%# Content %>
    <div class="mb-4">
      <p class="text-gray-700 leading-relaxed line-clamp-3">
        <%= @feedback.content %>
      </p>
    </div>

    <%# Footer %>
    <div class="flex items-center justify-between pt-4 border-t border-gray-100">
      <div class="flex items-center gap-4 text-sm text-gray-500">
        <span class="flex items-center gap-1">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"/>
          </svg>
          <%= @feedback.responses_count %> responses
        </span>
      </div>

      <div class="flex gap-2">
        <%= link_to "View", feedback_path(@feedback),
          class: "inline-flex items-center px-3 py-1.5 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500" %>

        <%= link_to "Respond", respond_feedback_path(@feedback),
          class: "inline-flex items-center px-3 py-1.5 border border-transparent rounded-md text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500" %>
      </div>
    </div>
  </div>
</div>
```
</pattern>

<pattern name="responsive-layout">
<description>Full responsive layout with Tailwind</description>

```erb
<!-- app/views/layouts/application.html.erb -->
<div class="min-h-screen flex flex-col bg-gray-50">
  <%# Header %>
  <header class="bg-white border-b border-gray-200 sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <%# Logo %>
        <%= link_to root_path, class: "flex items-center" do %>
          <span class="text-xl font-bold text-gray-900">Feedback App</span>
        <% end %>

        <%# Desktop Navigation %>
        <nav class="hidden md:flex items-center gap-6">
          <%= link_to "Dashboard", dashboard_path,
            class: "text-gray-700 hover:text-gray-900 font-medium" %>
          <%= link_to "Feedback", feedbacks_path,
            class: "text-gray-700 hover:text-gray-900 font-medium" %>
        </nav>

        <%# Mobile Menu Button %>
        <button class="md:hidden p-2 rounded-md text-gray-700 hover:bg-gray-100">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
          </svg>
        </button>
      </div>
    </div>
  </header>

  <%# Main Content %>
  <main class="flex-1">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <%= yield %>
    </div>
  </main>

  <%# Footer %>
  <footer class="bg-white border-t border-gray-200 mt-auto">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <p class="text-center text-sm text-gray-500">
        &copy; <%= Time.current.year %> Feedback App. All rights reserved.
      </p>
    </div>
  </footer>
</div>
```
</pattern>

<antipatterns>
<antipattern>
<description>Using inline styles instead of Tailwind utilities</description>
<reason>Inline styles bypass Tailwind's design system, break consistency, and aren't purgeable</reason>
<bad-example>
```erb
<%# ❌ BAD - Inline styles %>
<div style="display: flex; padding: 16px; background-color: #3b82f6;">
  Content
</div>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Tailwind utilities %>
<div class="flex p-4 bg-blue-500">
  Content
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Creating custom CSS files instead of using utilities</description>
<reason>Custom CSS defeats the purpose of utility-first approach and reduces maintainability</reason>
<bad-example>
```css
/* ❌ BAD - Custom CSS file */
.feedback-card {
  padding: 1.5rem;
  border-radius: 0.5rem;
  background-color: white;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.feedback-card:hover {
  box-shadow: 0 10px 15px rgba(0,0,0,0.1);
}
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Tailwind utilities %>
<div class="p-6 rounded-lg bg-white shadow hover:shadow-lg">
  Feedback card content
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Using arbitrary values unnecessarily</description>
<reason>Arbitrary values bypass design system consistency and should be rare</reason>
<bad-example>
```erb
<%# ❌ BAD - Arbitrary values for everything %>
<div class="p-[13px] text-[#1a4d8f] mt-[27px]">
  Content
</div>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Use design system values %>
<div class="p-4 text-blue-700 mt-6">
  Content
</div>

<%# ✅ ACCEPTABLE - Arbitrary values for one-off cases %>
<div class="w-[calc(100%-3rem)]">
  Specific calculation needed
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Overusing @apply in CSS</description>
<reason>@apply defeats utility-first benefits and creates abstraction layer</reason>
<bad-example>
```css
/* ❌ BAD - Extracting every component to @apply */
.btn {
  @apply px-4 py-2 rounded bg-blue-500 text-white hover:bg-blue-600;
}

.card {
  @apply p-6 bg-white rounded-lg shadow;
}
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Use utilities directly %>
<button class="px-4 py-2 rounded bg-blue-500 text-white hover:bg-blue-600">
  Submit
</button>

<%# ✅ BETTER - Use ViewComponent for reusability %>
<%= render ButtonComponent.new(text: "Submit", variant: :primary) %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not using responsive utilities</description>
<reason>Breaks mobile experience and ignores Tailwind's mobile-first approach</reason>
<bad-example>
```erb
<%# ❌ BAD - Desktop-only design %>
<div class="grid grid-cols-4 gap-6">
  <%# Broken on mobile %>
</div>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Mobile-first responsive %>
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6">
  <%# Works on all screen sizes %>
</div>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Testing Tailwind styling typically focuses on testing ViewComponents that use Tailwind classes:

```ruby
# test/components/alert_component_test.rb
require "test_helper"

class AlertComponentTest < ViewComponent::TestCase
  test "renders info variant with correct classes" do
    render_inline(AlertComponent.new(message: "Info", variant: :info))

    assert_selector "div.bg-blue-50.text-blue-900"
    assert_text "Info"
  end

  test "renders success variant with correct classes" do
    render_inline(AlertComponent.new(message: "Success", variant: :success))

    assert_selector "div.bg-green-50.text-green-900"
  end

  test "renders error variant with correct classes" do
    render_inline(AlertComponent.new(message: "Error", variant: :error))

    assert_selector "div.bg-red-50.text-red-900"
  end
end

# test/system/responsive_design_test.rb
class ResponsiveDesignTest < ApplicationSystemTestCase
  test "mobile navigation displays on small screens" do
    visit root_path
    # Resize viewport to mobile
    page.driver.browser.manage.window.resize_to(375, 667)

    assert_selector "button.md\\:hidden", text: "Menu"
    assert_no_selector "nav.hidden.md\\:flex"
  end

  test "desktop navigation displays on large screens" do
    visit root_path
    # Resize viewport to desktop
    page.driver.browser.manage.window.resize_to(1920, 1080)

    assert_selector "nav.hidden.md\\:flex"
    assert_no_selector "button.md\\:hidden"
  end
end
```
</testing>

<related-skills>
- viewcomponent-basics - Component architecture for reusable Tailwind components
- viewcomponent-slots - Multi-slot components with Tailwind styling
- hotwire-turbo - Dynamic updates without losing Tailwind styles
- hotwire-stimulus - JavaScript behavior with Tailwind classes
- daisyui-components - Pre-built components (separate from pure Tailwind)
</related-skills>

<resources>
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Tailwind CSS v4 Beta](https://tailwindcss.com/docs/v4-beta)
- [Tailwind UI Components](https://tailwindui.com/)
- [Tailwind Play (Interactive Playground)](https://play.tailwindcss.com/)
- [Tailwind CSS IntelliSense](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)
</resources>
