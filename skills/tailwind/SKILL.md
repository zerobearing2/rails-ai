---
name: rails-ai:tailwind
description: Tailwind CSS is a utility-first CSS framework that provides low-level utility classes to build custom designs without writing custom CSS.
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
<description>Consistent spacing using Tailwind's spacing scale (0, 1, 2, 4, 8, 12, 16, 24, 32)</description>

```erb
<%# Padding: p-{size}, px-{size}, py-{size}, pt/pr/pb/pl-{size} %>
<div class="p-4">Padding all sides</div>
<div class="px-6 py-4">Horizontal/Vertical</div>

<%# Margin: m-{size}, mx-auto for centering, negative with - %>
<div class="mx-auto">Center horizontally</div>
<div class="mt-8 -mb-4">Top margin, negative bottom</div>

<%# Gap for flex/grid %>
<div class="flex gap-4">Items</div>
<div class="grid grid-cols-3 gap-6">Grid items</div>
```
</pattern>

<pattern name="flexbox-layout">
<description>Flexbox utilities for layouts and alignment</description>

```erb
<%# Direction: flex (row), flex-col (column) %>
<div class="flex items-center gap-4">Horizontal</div>
<div class="flex flex-col gap-2">Vertical</div>

<%# Justify: justify-start/center/end/between/around %>
<%# Align: items-start/center/end/stretch %>
<div class="flex justify-between items-center">
  <span>Left</span>
  <span>Right</span>
</div>

<%# Grow/shrink: flex-1, flex-none %>
<div class="flex gap-4">
  <div class="flex-1">Grows</div>
  <div class="flex-none w-32">Fixed</div>
</div>
```
</pattern>

<pattern name="grid-layout">
<description>Grid utilities for complex layouts</description>

```erb
<%# Columns: grid-cols-{n}, responsive with sm:/md:/lg: %>
<div class="grid grid-cols-3 gap-4">
  <% @items.each do |item| %>
    <div class="bg-white p-4 rounded-lg shadow"><%= item.name %></div>
  <% end %>
</div>

<%# Spanning: col-span-{n}, row-span-{n} %>
<div class="grid grid-cols-4 gap-4">
  <div class="col-span-2">Spans 2 columns</div>
  <div class="col-span-4">Full width</div>
</div>
```
</pattern>

<pattern name="responsive-design">
<description>Mobile-first responsive utilities with breakpoints (sm:640px, md:768px, lg:1024px, xl:1280px)</description>

```erb
<%# Pattern: base (mobile) → sm: → md: → lg: → xl: %>
<%# Mobile: 1 col, Tablet: 2 cols, Desktop: 3 cols %>
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
  <% @feedbacks.each do |feedback| %>
    <%= render feedback %>
  <% end %>
</div>

<%# Responsive spacing/typography %>
<div class="p-4 md:p-8">
  <h1 class="text-2xl md:text-4xl font-bold">Heading</h1>
</div>

<%# Hide/show: hidden, block, flex with breakpoint prefixes %>
<div class="block md:hidden">Mobile menu</div>
<nav class="hidden md:flex gap-4">Desktop nav</nav>
```
</pattern>

<pattern name="typography-utilities">
<description>Text styling, sizing, and formatting</description>

```erb
<%# Size: text-xs/sm/base/lg/xl/2xl/3xl/4xl %>
<p class="text-sm">Small</p>
<h1 class="text-4xl">Heading</h1>

<%# Weight: font-light/normal/medium/semibold/bold %>
<p class="font-semibold">Semibold</p>

<%# Align: text-left/center/right %>
<%# Transform: uppercase/lowercase/capitalize %>
<p class="text-center uppercase">Centered</p>

<%# Leading/tracking: leading-tight/normal/loose, tracking-tight/wide %>
<p class="leading-relaxed tracking-wide">Spaced text</p>

<%# Decoration: underline, line-through, no-underline %>
<a href="#" class="underline hover:no-underline">Link</a>

<%# Truncation: truncate (single line), line-clamp-{n} (multi-line) %>
<p class="truncate"><%= feedback.content %></p>
```
</pattern>

<pattern name="colors-and-backgrounds">
<description>Color utilities for text, backgrounds, and borders</description>

```erb
<%# Text: text-{color}-{shade} (50-950) %>
<p class="text-gray-900">Dark text</p>
<p class="text-blue-600">Blue text</p>
<p class="text-red-600/50">Red with 50% opacity</p>

<%# Background: bg-{color}-{shade} %>
<div class="bg-white">White</div>
<div class="bg-gray-100">Light gray</div>
<div class="bg-blue-600 text-white">Blue background</div>

<%# Gradients: bg-gradient-to-{direction} from-{color} to-{color} %>
<div class="bg-gradient-to-r from-blue-500 to-purple-600">Gradient</div>

<%# Borders: border-{color}-{shade} %>
<div class="border border-gray-300">Gray border</div>
```
</pattern>

<pattern name="hover-focus-states">
<description>Interactive states using state modifiers (hover:, focus:, active:, disabled:)</description>

```erb
<%# Hover: hover:{utility} %>
<button class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
  Hover me
</button>
<a href="#" class="text-blue-600 hover:underline">Link</a>

<%# Focus: focus:{utility} - common for forms %>
<input type="text" class="border border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 rounded px-3 py-2" />

<%# Active/disabled: active:{utility}, disabled:{utility} %>
<button class="bg-blue-600 hover:bg-blue-700 active:bg-blue-800">Click</button>
<button disabled class="disabled:opacity-50 disabled:cursor-not-allowed">Disabled</button>

<%# Group hover: group, group-hover:{utility} %>
<div class="group hover:bg-gray-100 p-4">
  <h3 class="group-hover:text-blue-600">Title</h3>
</div>
```
</pattern>

<pattern name="borders-shadows-sizing">
<description>Border radius, shadows, and sizing utilities</description>

```erb
<%# Rounded: rounded-none/sm/md/lg/xl/full %>
<div class="rounded-lg">Large rounding</div>
<div class="rounded-full">Pill/circle</div>

<%# Borders: border, border-{n}, border-{side} %>
<div class="border border-gray-300">1px border</div>
<div class="border-t-2 border-blue-500">Top border</div>

<%# Shadows: shadow-sm/md/lg/xl %>
<div class="shadow-md">Card shadow</div>
<div class="shadow-lg hover:shadow-xl">Interactive</div>

<%# Width: w-{size}/w-full/w-1/2, max-w-{size} %>
<div class="w-64">Fixed width (256px)</div>
<div class="w-full max-w-4xl mx-auto">Constrained width</div>

<%# Height: h-{size}/h-screen/min-h-screen %>
<div class="h-screen">Full viewport height</div>
```
</pattern>

## Real-World Examples

<pattern name="feedback-card">
<description>Complete feedback card using Tailwind utilities</description>

```erb
<div class="bg-white rounded-lg shadow-md hover:shadow-xl transition-shadow p-6">
  <%# Header %>
  <div class="flex items-start justify-between mb-4">
    <div class="flex items-center gap-3">
      <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white font-semibold">
        <%= @feedback.sender_name&.first&.upcase || "A" %>
      </div>
      <div>
        <h3 class="font-semibold text-gray-900"><%= @feedback.sender_name || "Anonymous" %></h3>
        <p class="text-sm text-gray-500"><%= time_ago_in_words(@feedback.created_at) %> ago</p>
      </div>
    </div>
    <span class="px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
      <%= @feedback.status.titleize %>
    </span>
  </div>

  <%# Content %>
  <p class="text-gray-700 leading-relaxed line-clamp-3 mb-4"><%= @feedback.content %></p>

  <%# Footer %>
  <div class="flex items-center justify-between pt-4 border-t border-gray-100">
    <span class="text-sm text-gray-500"><%= @feedback.responses_count %> responses</span>
    <div class="flex gap-2">
      <%= link_to "View", feedback_path(@feedback), class: "px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-700 hover:bg-gray-50" %>
      <%= link_to "Respond", respond_feedback_path(@feedback), class: "px-3 py-1.5 rounded-md text-sm text-white bg-blue-600 hover:bg-blue-700" %>
    </div>
  </div>
</div>
```
</pattern>

<antipatterns>
<antipattern>
<description>Using inline styles or custom CSS instead of Tailwind utilities</description>
<reason>Bypasses design system consistency and reduces maintainability</reason>
<bad-example>
```erb
<%# ❌ BAD %>
<div style="padding: 16px; background: #3b82f6;">Content</div>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD %>
<div class="p-4 bg-blue-500">Content</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Not using responsive utilities (mobile-first approach)</description>
<reason>Breaks mobile experience and ignores Tailwind's mobile-first design</reason>
<bad-example>
```erb
<%# ❌ BAD - Desktop-only design %>
<div class="grid grid-cols-4 gap-6">Items</div>
```
</bad-example>
<good-example>
```erb
<%# ✅ GOOD - Mobile-first responsive %>
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">Items</div>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test ViewComponents for correct Tailwind classes:

```ruby
# test/components/alert_component_test.rb
class AlertComponentTest < ViewComponent::TestCase
  test "renders variant with correct classes" do
    render_inline(AlertComponent.new(message: "Info", variant: :info))
    assert_selector "div.bg-blue-50.text-blue-900"
    assert_text "Info"
  end
end
```
</testing>

<related-skills>
- rails-ai:daisyui - Prebuilt components (separate from pure Tailwind)
- rails-ai:hotwire-turbo - Dynamic updates without losing Tailwind styles
- rails-ai:hotwire-stimulus - JavaScript behavior with Tailwind classes
</related-skills>

<resources>
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Tailwind CSS v4 Beta](https://tailwindcss.com/docs/v4-beta)
- [Tailwind UI Components](https://tailwindui.com/)
- [Tailwind Play (Interactive Playground)](https://play.tailwindcss.com/)
- [Tailwind CSS IntelliSense](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)
</resources>
