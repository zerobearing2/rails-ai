# XSS (Cross-Site Scripting) Prevention Examples
# Reference: TEAM_RULES.md Rule #15 (ViewComponent), Rails Security Guide
# Category: CRITICAL SECURITY

# ============================================================================
# Rails Auto-Escaping (Default Protection)
# ============================================================================

# ✅ SECURE: Rails automatically escapes output in ERB
# views/feedbacks/show.html.erb
<%= @feedback.content %>
# If content = "<script>alert('XSS')</script>"
# Output: &lt;script&gt;alert('XSS')&lt;/script&gt;
# Browser displays the text, doesn't execute it

# ============================================================================
# ❌ DANGEROUS: html_safe and raw
# ============================================================================

# NEVER use html_safe on user input
<%= @feedback.content.html_safe %>
# If content = "<script>alert('XSS')</script>"
# Browser executes the script! ❌

# NEVER use raw on user input
<%= raw @feedback.content %>
# Same danger - executes malicious scripts

# ============================================================================
# ✅ SECURE: Sanitize User Content
# ============================================================================

# Use sanitize with permitted tags/attributes
tags = %w(p br strong em a)
attributes = %w(href title)
<%= sanitize(@feedback.content, tags: tags, attributes: attributes) %>
# Strips all HTML except permitted tags
# Safest approach for rich user content

# Default Rails sanitizer (more permissive)
<%= sanitize(@feedback.content) %>
# Allows standard formatting tags
# Removes script, object, embed, etc.

# ============================================================================
# ✅ SECURE: Content Security Policy (CSP)
# ============================================================================

# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https  # Blocks inline scripts
  policy.style_src   :self, :https

  # Report violations
  policy.report_uri "/csp-violation-report-endpoint"
end

# Use nonces for inline scripts (if absolutely necessary)
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# In view with nonce
<%= javascript_tag nonce: true do %>
  alert('Hello, World!');
<% end %>
# Generates: <script nonce="random_value">alert('Hello, World!');</script>

# ============================================================================
# ❌ VULNERABLE: Common XSS Attack Vectors
# ============================================================================

# Basic script injection
<script>alert('XSS')</script>

# Image tag with javascript
<img src="javascript:alert('XSS')">

# Event handlers
<div onload="alert('XSS')">
<img src="x" onerror="alert('XSS')">

# CSS-based injection
<div style="background:url('javascript:alert(1)')">

# HTML entity encoding (Rails sanitize blocks this)
<img src=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>

# ============================================================================
# ✅ BEST PRACTICE: ViewComponent + Sanitization
# ============================================================================

# app/components/feedback_components/content_component.rb
module FeedbackComponents
  class ContentComponent < ViewComponent::Base
    ALLOWED_TAGS = %w(p br strong em ul ol li a blockquote).freeze
    ALLOWED_ATTRS = %w(href title).freeze

    def initialize(content:)
      @content = content
    end

    private

    attr_reader :content

    def sanitized_content
      helpers.sanitize(content, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRS)
    end
  end
end

# app/components/feedback_components/content_component.html.erb
<div class="feedback-content prose">
  <%= sanitized_content.html_safe %>
</div>
# Safe because sanitize removes all dangerous content

# ============================================================================
# ✅ SECURE: JSON Rendering
# ============================================================================

# Rails automatically escapes JSON
def show
  render json: { feedback: @feedback.content }
end
# Safe - Rails escapes for JSON context

# ============================================================================
# ✅ SECURE: JavaScript Context
# ============================================================================

# NEVER pass user input directly to JavaScript
# ❌ DANGEROUS:
<script>
  var content = "<%= @feedback.content %>";
</script>

# ✅ SECURE: Use JSON + data attributes
<div data-feedback-content="<%= @feedback.content.to_json %>">
</div>

<script>
  const content = JSON.parse(element.dataset.feedbackContent);
  // Safely parsed, special characters escaped
</script>

# ============================================================================
# RULE: NEVER use html_safe or raw on user input
# ALWAYS: Let Rails auto-escape or use sanitize with permitted list
# CONSIDER: ViewComponents for reusable, safe rendering
# ENABLE: Content Security Policy to block inline scripts
# ============================================================================
