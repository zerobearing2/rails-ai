# CSRF (Cross-Site Request Forgery) Protection
# Reference: Rails Security Guide
# Category: CRITICAL SECURITY

# ============================================================================
# Rails Built-in CSRF Protection (Automatic)
# ============================================================================

# ApplicationController (default protection)
class ApplicationController < ActionController::Base
  # Rails 8 enables this by default
  protect_from_forgery with: :exception
  # Raises ActionController::InvalidAuthenticityToken if token invalid
end

# Alternative strategies
protect_from_forgery with: :null_session  # Resets session instead of exception
protect_from_forgery with: :reset_session # Resets entire session

# ============================================================================
# ✅ SECURE: Forms with Automatic CSRF Token
# ============================================================================

# views/feedbacks/new.html.erb
<%= form_with model: @feedback do |form| %>
  <%= form.text_field :content %>
  <%= form.text_field :recipient_email %>
  <%= form.submit "Submit" %>
<% end %>

# Generated HTML includes hidden authenticity token automatically:
# <input type="hidden" name="authenticity_token" value="RANDOM_TOKEN_HERE">

# ============================================================================
# ✅ CSRF Meta Tags for JavaScript
# ============================================================================

# views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <%= csrf_meta_tags %>
    <!-- Generates:
    <meta name="csrf-param" content="authenticity_token" />
    <meta name="csrf-token" content="THE-TOKEN" />
    -->
  </head>
  <body>
    <%= yield %>
  </body>
</html>

# ============================================================================
# ✅ SECURE: JavaScript Fetch with CSRF Token
# ============================================================================

// Get CSRF token from meta tag
const csrfToken = document.head.querySelector("meta[name=csrf-token]")?.content;

// Include in fetch request
fetch("/feedbacks", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-CSRF-Token": csrfToken
  },
  body: JSON.stringify({ feedback: { content: "test" } })
});

# ============================================================================
# ✅ SECURE: Turbo Frame Forms (Automatic)
# ============================================================================

# Turbo automatically includes CSRF token
<%= turbo_frame_tag "feedback_form" do %>
  <%= form_with model: @feedback do |form| %>
    <%= form.text_field :content %>
    <%= form.submit %>
  <% end %>
<% end %>
# CSRF token included automatically in Turbo submissions

# ============================================================================
# ✅ SECURE: Using @rails/request.js
# ============================================================================

// @rails/request.js automatically includes CSRF token
import { post } from '@rails/request.js'

post('/feedbacks', {
  body: JSON.stringify({ feedback: { content: "test" } }),
  contentType: 'application/json',
  responseKind: 'json'
})
// CSRF token automatically added to headers

# ============================================================================
# ❌ VULNERABLE: CSRF Attack Example
# ============================================================================

# Attacker's malicious site (evil.com)
<html>
  <body>
    <!-- Hidden form that submits to your app -->
    <form action="https://yourapp.com/account/destroy" method="POST" id="csrf">
      <input type="hidden" name="confirmed" value="true">
    </form>
    <script>
      document.getElementById('csrf').submit();
    </script>
  </body>
</html>

# When logged-in user visits evil.com:
# 1. Form auto-submits to yourapp.com
# 2. Browser includes user's session cookie
# 3. WITHOUT CSRF protection: Request succeeds, account destroyed
# 4. WITH CSRF protection: Request rejected (missing authenticity token)

# ============================================================================
# ⚠️ API Controllers: Skip CSRF for Token-Based Auth
# ============================================================================

class Api::V1::BaseController < ApplicationController
  # Skip CSRF for API endpoints using token authentication
  skip_before_action :verify_authenticity_token

  # Use token-based auth instead
  before_action :authenticate_api_token

  private

  def authenticate_api_token
    token = request.headers["Authorization"]&.split(" ")&.last
    @current_api_user = User.find_by(api_token: token)
    head :unauthorized unless @current_api_user
  end
end

# ============================================================================
# ✅ SECURE: Handling InvalidAuthenticityToken
# ============================================================================

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Handle CSRF failures gracefully
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    # Clear persistent cookies on CSRF failure
    sign_out_user  # Custom method to clear cookies
    redirect_to root_path, alert: "Your session has expired. Please log in again."
  end

  private

  def sign_out_user
    cookies.delete(:user_token)
    session.clear
  end
end

# ============================================================================
# ✅ SECURE: External Forms with Custom Token
# ============================================================================

# When posting to external API that requires specific token
<%= form_with url: 'http://external-api.com/endpoint',
              authenticity_token: 'external_token' do %>
  Form contents
<% end %>

# Or disable CSRF for specific external form
<%= form_with url: 'http://external-api.com/endpoint',
              authenticity_token: false do %>
  Form contents
<% end %>

# ============================================================================
# ✅ Testing CSRF Protection
# ============================================================================

# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "rejects POST without CSRF token" do
    # Manually bypass automatic CSRF token
    assert_raises(ActionController::InvalidAuthenticityToken) do
      post feedbacks_url, params: { feedback: { content: "test" } },
           headers: { "X-CSRF-Token" => "invalid" }
    end
  end

  test "accepts POST with valid CSRF token" do
    # Rails test helpers include CSRF token automatically
    post feedbacks_url, params: { feedback: { content: "test", recipient_email: "user@example.com" } }
    assert_response :redirect  # Success
  end
end

# ============================================================================
# ✅ SECURE: Per-Form Tokens (Enhanced Security)
# ============================================================================

# Generate unique token per form (Rails default is per-session)
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception,
                       prepend: true,
                       except: [:webhook]  # Webhook endpoints don't use session

  # Custom token generation for high-security forms
  def form_authenticity_token(**options)
    options[:form_options] ||= {}
    options[:form_options][:action] = request.fullpath
    super(**options)
  end
end

# ============================================================================
# ⚠️ SameSite Cookies for Additional Protection
# ============================================================================

# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: '_feedback_app_session',
  same_site: :lax,  # Prevents CSRF from external sites
  secure: Rails.env.production?,  # HTTPS only in production
  httponly: true  # Not accessible via JavaScript

# SameSite options:
# :strict - Most secure, can break some OAuth flows
# :lax - Balances security and usability (recommended)
# :none - Least secure, allows all cross-site requests (requires secure: true)

# ============================================================================
# RULE: NEVER skip CSRF protection for session-based authentication
# ALWAYS: Include csrf_meta_tags in layout
# ALWAYS: Use form_with which includes token automatically
# FOR APIs: Use token-based auth, skip CSRF verification
# COOKIES: Set SameSite attribute for defense-in-depth
# ============================================================================
