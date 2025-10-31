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
- ALWAYS - XSS prevention is ALWAYS required
</when-to-use>

<attack-vectors>
- **Script Injection** - `<script>alert('XSS')</script>`
- **Event Handlers** - `<img src=x onerror="alert('XSS')">`
- **JavaScript URLs** - `<a href="javascript:alert('XSS')">Click</a>`
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
<%# ❌ Executes malicious scripts %>
<%= @feedback.content.html_safe %>
<%= raw(@feedback.content) %>
```

**Safe usage:**
```erb
<%# ✅ Developer-controlled HTML %>
<%= content_tag(:div, "Hello", class: "message").html_safe %>

<%# ✅ Sanitized user content %>
<%= sanitize(@feedback.content, tags: %w[p br strong em]).html_safe %>
```

Only use `html_safe` on developer-written HTML, sanitized content, or trusted Rails helpers.
</pattern>

## Sanitizing User Content

<pattern name="sanitize-with-allowlist">
<description>Allow specific HTML tags while stripping dangerous content</description>

```erb
<%# ✅ Only allow specific tags %>
<%= sanitize(@feedback.content,
    tags: %w[p br strong em a ul ol li],
    attributes: %w[href title]) %>
```

**Input:** `<p>Hello <strong>world</strong></p><script>alert('XSS')</script>`

**Output:** `<p>Hello <strong>world</strong></p>` (script stripped)

Scripts and javascript: URLs are automatically removed.
</pattern>

<pattern name="markdown-safe-rendering">
<description>Safely render markdown user content</description>

**Model Method:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  def content_html
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        filter_html: true, no_styles: true, safe_links_only: true
      ),
      autolink: true, tables: true, fenced_code_blocks: true
    )

    html = markdown.render(content)
    ActionController::Base.helpers.sanitize(
      html,
      tags: %w[p br strong em a ul ol li pre code h1 h2 h3 blockquote],
      attributes: %w[href title]
    )
  end
end
```

**View:**
```erb
<div class="markdown-content">
  <%= @feedback.content_html.html_safe %>
</div>
```
</pattern>

## Content Security Policy

<pattern name="csp-configuration">
<description>Implement Content Security Policy to block inline scripts</description>

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src :self, :https, :data
  policy.img_src :self, :https, :data, "https://cdn.example.com"
  policy.frame_ancestors :none
  policy.object_src :none
  policy.script_src :self, :https, "https://cdn.jsdelivr.net"
  policy.style_src :self, :https
  policy.report_uri "/csp-violation-report"
end

Rails.application.config.content_security_policy_nonce_generator = ->(request) {
  SecureRandom.base64(16)
}
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]
```

**View with Nonce:**
```erb
<%= javascript_tag nonce: true do %>
  console.log('This is allowed');
<% end %>
```
</pattern>

<pattern name="csp-violation-reporting">
<description>Log CSP violations for security monitoring</description>

```ruby
# app/controllers/csp_reports_controller.rb
class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    violation = JSON.parse(request.body.read)["csp-report"]
    Rails.logger.warn(
      "CSP Violation: document-uri=#{violation['document-uri']} " \
      "blocked-uri=#{violation['blocked-uri']}"
    )
    head :no_content
  end
end
```

Route: `post "/csp-violation-report", to: "csp_reports#create"`
</pattern>

## ViewComponent Safety

<pattern name="viewcomponent-escaping">
<description>ViewComponents automatically escape content</description>

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

```erb
<%# app/components/user_comment_component.html.erb %>
<div class="comment">
  <div class="author"><%= comment.author_name %></div>
  <div class="content"><%= comment.content %></div>
</div>
```

Benefits: Automatic escaping, encapsulated logic, testable, no accidental `html_safe`.
</pattern>

<antipatterns>
<antipattern>
<description>Using html_safe on user input</description>
<reason>Allows malicious script execution - CRITICAL vulnerability</reason>
<bad-example>
```erb
<%# ❌ CRITICAL VULNERABILITY %>
<%= @comment.html_safe %>
```
</bad-example>
<good-example>
```erb
<%# ✅ SECURE - Auto-escaped or sanitized %>
<%= @comment %>
<%= sanitize(@comment, tags: %w[p br strong em]) %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not sanitizing rich user content</description>
<reason>Allows HTML injection attacks</reason>
<bad-example>
```erb
<%# ❌ VULNERABLE %>
<%= @post.body.html_safe %>
```
</bad-example>
<good-example>
```erb
<%# ✅ SECURE - Explicit allowlist %>
<%= sanitize(@post.body, tags: %w[p br strong em a], attributes: %w[href]) %>
```
</good-example>
</antipattern>

<antipattern>
<description>Allowing javascript: URLs</description>
<reason>Enables XSS through link clicks</reason>
<bad-example>
```ruby
# ❌ Without URL validation
sanitize(content, tags: %w[a], attributes: %w[href])
```
</bad-example>
<good-example>
```ruby
# ✅ Rails sanitizer blocks javascript: by default
sanitize(content, tags: %w[a], attributes: %w[href])

# Or validate explicitly
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
```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "content_html sanitizes malicious scripts" do
    feedback = Feedback.new(content: "<script>alert('XSS')</script>Hello")
    assert_not_includes feedback.content_html, "<script>"
    assert_includes feedback.content_html, "Hello"
  end

  test "content_html allows safe markdown" do
    feedback = Feedback.new(content: "**bold** and *italic*")
    assert_includes feedback.content_html, "<strong>bold</strong>"
  end
end

# test/system/xss_prevention_test.rb
class XssPreventionTest < ApplicationSystemTestCase
  test "user cannot inject scripts via comment" do
    visit new_comment_path
    fill_in "Comment", with: "<script>alert('XSS')</script>"
    click_button "Submit"

    assert_text "<script>alert('XSS')</script>"  # Script escaped, not executed
  end
end
```
</testing>

<related-skills>
- security-csrf - CSRF protection
- security-sql-injection - SQL injection prevention
- viewcomponent-basics - Safe component rendering
</related-skills>

<resources>
- [Rails Security Guide - XSS](https://guides.rubyonrails.org/security.html#cross-site-scripting-xss)
- [OWASP XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
</resources>
