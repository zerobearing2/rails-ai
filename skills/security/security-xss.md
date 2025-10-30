---
name: security-xss
domain: security
dependencies: []
version: 1.0
rails_version: 8.1+
criticality: CRITICAL
---

# XSS (Cross-Site Scripting) Prevention

Prevent malicious JavaScript execution by properly escaping user input and implementing Content Security Policy.

<when-to-use>
- Displaying ANY user-generated content
- Rendering HTML from external sources
- Building rich text editors or comment systems
- Allowing formatted content (markdown, HTML)
- Implementing search results or user profiles
- ALWAYS - XSS prevention is ALWAYS required
</when-to-use>

<attack-vectors>
- **Script Injection** - `<script>alert('XSS')</script>`
- **Event Handlers** - `<img src=x onerror="alert('XSS')">`
- **JavaScript URLs** - `<a href="javascript:alert('XSS')">Click</a>`
- **Style Injection** - `<style>body{background:url('javascript:alert(1)')}</style>`
- **SVG Injection** - `<svg onload="alert('XSS')"></svg>`
- **Data URIs** - `<img src="data:text/html,<script>alert('XSS')</script>">`
</attack-vectors>

<standards>
- NEVER use `html_safe` or `raw` on user input
- Rails auto-escapes by default - rely on this
- Use `sanitize` with explicit allowlist for rich content
- Implement Content Security Policy (CSP) headers
- Validate and sanitize ALL user input
- Use ViewComponent for complex rendering (automatic escaping)
- Never trust data from cookies, URLs, or forms
- Encode output based on context (HTML, JavaScript, URL, CSS)
</standards>

## Rails Auto-Escaping

<pattern name="default-protection">
<description>Rails automatically escapes output in ERB templates</description>

**Secure by Default:**
```erb
<%# ✅ SECURE - Rails auto-escapes %>
<div class="content">
  <%= @feedback.content %>
</div>
```

**Input:**
```
<script>alert('XSS')</script>
```

**Output:**
```html
<div class="content">
  &lt;script&gt;alert('XSS')&lt;/script&gt;
</div>
```

Browser displays the text, doesn't execute it.
</pattern>

## Dangerous Methods

<pattern name="dangerous-html-safe">
<description>NEVER use html_safe or raw on user input</description>

**DANGEROUS:**
```erb
<%# ❌ DANGEROUS - Executes malicious scripts %>
<%= @feedback.content.html_safe %>
<%= raw(@feedback.content) %>
```

**When html_safe IS appropriate:**
```erb
<%# ✅ SAFE - Developer-controlled HTML %>
<%= content_tag(:div, "Hello", class: "message").html_safe %>

<%# ✅ SAFE - Sanitized user content %>
<%= sanitize(@feedback.content, tags: %w[p br strong em]).html_safe %>
```

**Rule:** Only use `html_safe` on:
- Developer-written HTML
- Content already sanitized with explicit allowlist
- Output from trusted Rails helpers
</pattern>

## Sanitizing User Content

<pattern name="sanitize-with-allowlist">
<description>Allow specific HTML tags while stripping dangerous content</description>

**Strict Allowlist:**
```erb
<%# ✅ SECURE - Only allow specific tags %>
<%
  allowed_tags = %w[p br strong em a ul ol li]
  allowed_attributes = %w[href title]
%>
<%= sanitize(@feedback.content, tags: allowed_tags, attributes: allowed_attributes) %>
```

**Input:**
```html
<p>Hello <strong>world</strong></p>
<script>alert('XSS')</script>
<a href="javascript:alert('XSS')">Click</a>
```

**Output:**
```html
<p>Hello <strong>world</strong></p>

<a>Click</a>
```

Scripts and javascript: URLs are stripped.
</pattern>

<pattern name="markdown-safe-rendering">
<description>Safely render markdown user content</description>

**Model Method:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  def content_html
    # Use a markdown parser with XSS protection
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        filter_html: true,  # Strip HTML tags
        no_styles: true,    # Strip style attributes
        safe_links_only: true  # Only allow http/https links
      ),
      autolink: true,
      tables: true,
      fenced_code_blocks: true
    )

    # Parse markdown and sanitize output
    html = markdown.render(content)
    ActionController::Base.helpers.sanitize(
      html,
      tags: %w[p br strong em a ul ol li pre code h1 h2 h3 h4 h5 h6 blockquote table thead tbody tr th td],
      attributes: %w[href title]
    )
  end
end
```

**View:**
```erb
<%# Safe to render - already sanitized %>
<div class="markdown-content">
  <%= @feedback.content_html.html_safe %>
</div>
```
</pattern>

## Content Security Policy

<pattern name="csp-configuration">
<description>Implement Content Security Policy to block inline scripts</description>

**Initializer:**
```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  # Only load resources from same origin and HTTPS
  policy.default_src :self, :https

  # Font sources
  policy.font_src :self, :https, :data

  # Image sources
  policy.img_src :self, :https, :data, "https://cdn.example.com"

  # Prevent embedding in iframes
  policy.frame_ancestors :none

  # Block objects (Flash, etc.)
  policy.object_src :none

  # Only allow scripts from self and specific CDNs
  policy.script_src :self, :https, "https://cdn.jsdelivr.net"

  # Only allow styles from self
  policy.style_src :self, :https

  # Report violations to this endpoint
  policy.report_uri "/csp-violation-report"
end

# Generate nonces for inline scripts (if needed)
Rails.application.config.content_security_policy_nonce_generator = ->(request) {
  SecureRandom.base64(16)
}

# Apply nonces to script-src directive
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]
```

**View with Nonce:**
```erb
<%# Inline script with nonce (allowed by CSP) %>
<%= javascript_tag nonce: true do %>
  console.log('This is allowed');
<% end %>
<%# Generates: <script nonce="random_value">console.log('This is allowed');</script> %>
```
</pattern>

<pattern name="csp-violation-reporting">
<description>Log CSP violations for security monitoring</description>

**Controller:**
```ruby
# app/controllers/csp_reports_controller.rb
class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token  # CSP reports don't include CSRF token

  def create
    violation = JSON.parse(request.body.read)["csp-report"]

    Rails.logger.warn(
      "CSP Violation: " \
      "document-uri=#{violation['document-uri']} " \
      "blocked-uri=#{violation['blocked-uri']} " \
      "violated-directive=#{violation['violated-directive']}"
    )

    # Could also store in database for analysis
    # CspViolation.create!(violation_data: violation)

    head :no_content
  end
end
```

**Route:**
```ruby
# config/routes.rb
post "/csp-violation-report", to: "csp_reports#create"
```
</pattern>

## ViewComponent Safety

<pattern name="viewcomponent-escaping">
<description>ViewComponents automatically escape content</description>

**Component:**
```ruby
# app/components/user_comment_component.rb
class UserCommentComponent < ViewComponent::Base
  def initialize(comment:)
    @comment = comment
  end

  private

  attr_reader :comment
end
```

**Template:**
```erb
<%# app/components/user_comment_component.html.erb %>
<div class="comment">
  <div class="author"><%= comment.author_name %></div>
  <div class="content">
    <%# ✅ SECURE - Auto-escaped %>
    <%= comment.content %>
  </div>
</div>
```

**Benefits:**
- Automatic escaping like ERB
- Encapsulated logic
- Testable in isolation
- No accidental `html_safe` on user data
</pattern>

<antipatterns>
<antipattern>
<description>Using html_safe on user input</description>
<reason>Allows malicious script execution - CRITICAL vulnerability</reason>
<bad-example>
```erb
<%# ❌ CRITICAL VULNERABILITY %>
<div class="comment">
  <%= @comment.html_safe %>
</div>
```
</bad-example>
<good-example>
```erb
<%# ✅ SECURE - Auto-escaped or sanitized %>
<div class="comment">
  <%= @comment %>
  <%# Or with sanitization: %>
  <%= sanitize(@comment, tags: %w[p br strong em]) %>
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Not sanitizing rich user content</description>
<reason>Allows HTML injection attacks</reason>
<bad-example>
```erb
<%# ❌ VULNERABLE - Renders user HTML as-is %>
<div class="content">
  <%= @post.body.html_safe %>
</div>
```
</bad-example>
<good-example>
```erb
<%# ✅ SECURE - Sanitize with explicit allowlist %>
<div class="content">
  <%= sanitize(@post.body, tags: %w[p br strong em a], attributes: %w[href]) %>
</div>
```
</good-example>
</antipattern>

<antipattern>
<description>Allowing javascript: URLs in user content</description>
<reason>Enables XSS through link clicks</reason>
<bad-example>
```ruby
# ❌ VULNERABLE - Doesn't filter javascript: URLs
sanitize(user_content, tags: %w[a], attributes: %w[href])
# Allows: <a href="javascript:alert('XSS')">Click</a>
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Rails sanitizer blocks javascript: by default
sanitize(user_content, tags: %w[a], attributes: %w[href])
# Strips: <a href="javascript:alert('XSS')">Click</a>
# Result: <a>Click</a>

# Or validate URLs explicitly
def safe_url?(url)
  uri = URI.parse(url)
  %w[http https].include?(uri.scheme)
rescue URI::InvalidURIError
  false
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test XSS prevention in controller and system tests:

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "content_html sanitizes malicious scripts" do
    feedback = Feedback.new(content: "<script>alert('XSS')</script>Hello")

    html = feedback.content_html

    assert_not_includes html, "<script>"
    assert_includes html, "Hello"
  end

  test "content_html allows safe markdown" do
    feedback = Feedback.new(content: "**bold** and *italic*")

    html = feedback.content_html

    assert_includes html, "<strong>bold</strong>"
    assert_includes html, "<em>italic</em>"
  end
end

# test/system/xss_prevention_test.rb
class XssPreventionTest < ApplicationSystemTestCase
  test "user cannot inject scripts via comment" do
    visit new_comment_path

    fill_in "Comment", with: "<script>alert('XSS')</script>"
    click_button "Submit"

    # Script should be escaped, not executed
    assert_text "<script>alert('XSS')</script>"

    # No alert dialog should appear
    assert_no_selector "div.alert"  # If your app shows alerts this way
  end
end
```
</testing>

<related-skills>
- security-csrf - CSRF protection
- security-sql-injection - SQL injection prevention
- viewcomponent-basics - Safe component rendering
- content-security-policy - Advanced CSP configuration
</related-skills>

<resources>
- [Rails Security Guide - XSS](https://guides.rubyonrails.org/security.html#cross-site-scripting-xss)
- [OWASP XSS Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
</resources>
