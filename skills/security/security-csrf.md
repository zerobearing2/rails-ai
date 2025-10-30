---
name: security-csrf
domain: security
dependencies: []
version: 1.0
rails_version: 8.1+
criticality: CRITICAL
---

# CSRF (Cross-Site Request Forgery) Protection

Prevent unauthorized actions by validating that requests originate from your application, not malicious external sites.

<when-to-use>
- ANY state-changing action (POST, PATCH, PUT, DELETE)
- Session-based authentication (cookie-based)
- Form submissions that modify data
- AJAX requests that change server state
- ALWAYS - CSRF protection is ALWAYS required for session-based apps
- EXCEPT for stateless API endpoints using token authentication
</when-to-use>

<attack-vectors>
- **Hidden Form Attack** - Malicious site auto-submits form to your app
- **Image Tag Attack** - `<img src="https://yourapp.com/account/delete">`
- **AJAX Attack** - JavaScript fetch/XHR to your endpoints
- **Link Attack** - `<a href="https://yourapp.com/transfer?amount=1000">`
- **Auto-Submit Form** - JavaScript automatically submits hidden form
- **Credential Stuffing** - Browser includes cookies automatically
</attack-vectors>

<standards>
- Rails enables CSRF protection by default (`protect_from_forgery`)
- ALWAYS include `csrf_meta_tags` in application layout
- Use `form_with` which includes authenticity token automatically
- For JavaScript: Extract token from meta tags and include in headers
- NEVER skip CSRF for session-based authentication
- Skip CSRF ONLY for stateless API endpoints with token auth
- Set `SameSite` cookie attribute for defense-in-depth
- Handle `InvalidAuthenticityToken` gracefully
- Use `:exception` strategy (default) for failures
</standards>

## Rails Default Protection

<pattern name="default-csrf-protection">
<description>Rails enables CSRF protection by default in ApplicationController</description>

**ApplicationController:**
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Rails 8 enables this by default
  protect_from_forgery with: :exception
  # Raises ActionController::InvalidAuthenticityToken if token invalid
end
```

**Alternative Strategies:**
```ruby
# Reset session to empty hash (keeps user logged in)
protect_from_forgery with: :null_session

# Clear entire session (logs user out)
protect_from_forgery with: :reset_session

# Raise exception (RECOMMENDED - most secure)
protect_from_forgery with: :exception
```

**Why :exception is Best:**
- Makes failures immediately visible
- Prevents silent security bypasses
- Forces proper error handling
- Fails secure (denies access rather than allowing)
</pattern>

## Form Protection

<pattern name="automatic-token-in-forms">
<description>form_with automatically includes CSRF token</description>

**ERB Form:**
```erb
<%# ✅ SECURE - Token included automatically %>
<%= form_with model: @feedback do |form| %>
  <%= form.text_field :content %>
  <%= form.text_field :recipient_email %>
  <%= form.submit "Submit" %>
<% end %>
```

**Generated HTML:**
```html
<form action="/feedbacks" method="post">
  <input type="hidden" name="authenticity_token"
         value="RANDOM_SECURE_TOKEN_HERE">
  <input type="text" name="feedback[content]">
  <input type="text" name="feedback[recipient_email]">
  <input type="submit" value="Submit">
</form>
```

**Turbo Frame Forms:**
```erb
<%# ✅ SECURE - Turbo includes token automatically %>
<%= turbo_frame_tag "feedback_form" do %>
  <%= form_with model: @feedback do |form| %>
    <%= form.text_field :content %>
    <%= form.submit %>
  <% end %>
<% end %>
```

**Why Secure:**
Rails validates token matches session, proving request originated from your app.
</pattern>

## JavaScript Protection

<pattern name="csrf-meta-tags">
<description>Include CSRF meta tags for JavaScript access</description>

**Layout:**
```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
  <head>
    <title>My App</title>
    <%= csrf_meta_tags %>
    <%# Generates:
    <meta name="csrf-param" content="authenticity_token">
    <meta name="csrf-token" content="THE-TOKEN">
    %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

**Why Required:**
JavaScript needs access to CSRF token for AJAX requests.
</pattern>

<pattern name="fetch-with-csrf-token">
<description>Include CSRF token in fetch/XHR requests</description>

**Vanilla JavaScript:**
```javascript
// ✅ SECURE - Extract token from meta tag
const csrfToken = document.head.querySelector("meta[name=csrf-token]")?.content;

// Include in fetch request
fetch("/feedbacks", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-CSRF-Token": csrfToken
  },
  body: JSON.stringify({
    feedback: { content: "test", recipient_email: "user@example.com" }
  })
});
```

**With Error Handling:**
```javascript
// ✅ SECURE - Handle missing token
const csrfToken = document.head.querySelector("meta[name=csrf-token]")?.content;

if (!csrfToken) {
  console.error("CSRF token not found - ensure csrf_meta_tags is in layout");
  return;
}

fetch("/feedbacks", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-CSRF-Token": csrfToken
  },
  body: JSON.stringify({ feedback: { content: "test" } })
})
.catch(error => {
  if (error.response?.status === 422) {
    console.error("CSRF token validation failed");
  }
});
```

**Why Secure:**
Rails checks `X-CSRF-Token` header matches session token.
</pattern>

<pattern name="rails-request-js">
<description>Use @rails/request.js for automatic CSRF handling</description>

**Installation:**
```bash
npm install @rails/request.js
# or
yarn add @rails/request.js
```

**Usage:**
```javascript
// ✅ SECURE - Token automatically included
import { post, patch, destroy } from '@rails/request.js'

// POST request
await post('/feedbacks', {
  body: JSON.stringify({
    feedback: { content: "test" }
  }),
  contentType: 'application/json',
  responseKind: 'json'
})

// PATCH request
await patch('/feedbacks/123', {
  body: JSON.stringify({
    feedback: { status: "reviewed" }
  }),
  contentType: 'application/json'
})

// DELETE request
await destroy('/feedbacks/123', {
  responseKind: 'json'
})
```

**Why Recommended:**
- Automatic CSRF token handling
- Consistent API
- Rails-aware error handling
- Simpler than manual fetch
</pattern>

## Attack Example

<pattern name="csrf-attack-scenario">
<description>How CSRF attacks work without protection</description>

**Attacker's Malicious Site (evil.com):**
```html
<!-- ❌ VULNERABLE if CSRF protection disabled -->
<html>
  <body>
    <h1>Click here for free money!</h1>

    <!-- Hidden form that submits to victim app -->
    <form action="https://yourapp.com/account/destroy"
          method="POST"
          id="csrf-attack">
      <input type="hidden" name="confirmed" value="true">
    </form>

    <script>
      // Auto-submit when page loads
      document.getElementById('csrf-attack').submit();
    </script>
  </body>
</html>
```

**Attack Flow:**
1. User logs into yourapp.com (gets session cookie)
2. User visits evil.com (while still logged in)
3. evil.com's form auto-submits POST to yourapp.com/account/destroy
4. Browser automatically includes yourapp.com session cookie
5. WITHOUT CSRF protection: Request succeeds, account destroyed
6. WITH CSRF protection: Request rejected (missing authenticity token)

**Why CSRF Protection Works:**
Attacker cannot access CSRF token (Same-Origin Policy blocks it), so cannot include valid token in malicious request.
</pattern>

## API Controllers

<pattern name="api-skip-csrf">
<description>Skip CSRF for stateless API endpoints with token auth</description>

**API Base Controller:**
```ruby
# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ApplicationController
  # Skip CSRF for stateless token-based authentication
  skip_before_action :verify_authenticity_token

  # Use token authentication instead
  before_action :authenticate_api_token

  private

  def authenticate_api_token
    token = request.headers["Authorization"]&.split(" ")&.last
    @current_api_user = User.find_by(api_token: token)

    head :unauthorized unless @current_api_user
  end
end
```

**API Endpoint:**
```ruby
# app/controllers/api/v1/feedbacks_controller.rb
class Api::V1::FeedbacksController < Api::V1::BaseController
  def create
    feedback = @current_api_user.feedbacks.create!(feedback_params)
    render json: feedback, status: :created
  end

  private

  def feedback_params
    params.require(:feedback).permit(:content, :recipient_email)
  end
end
```

**Why Skip CSRF for APIs:**
- API clients use Bearer tokens (not cookies)
- Tokens must be explicitly sent (no automatic inclusion)
- CSRF only affects cookie-based authentication
- Token theft requires different attack vectors
</pattern>

## Error Handling

<pattern name="graceful-csrf-failure">
<description>Handle CSRF failures with user-friendly error messages</description>

**ApplicationController:**
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Handle CSRF failures gracefully
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    # Log for security monitoring
    Rails.logger.warn(
      "CSRF failure: #{exception.message} " \
      "IP: #{request.remote_ip} " \
      "Path: #{request.fullpath}"
    )

    # Clear potentially stale cookies
    sign_out_user if user_signed_in?

    # Redirect with helpful message
    redirect_to root_path,
                alert: "Your session has expired. Please log in again."
  end

  private

  def sign_out_user
    cookies.delete(:user_token)
    reset_session
  end
end
```

**Why Important:**
- Users see helpful error, not 422 status page
- Security event is logged for monitoring
- Stale sessions are cleared
- User can recover by logging in again
</pattern>

## Advanced Configuration

<pattern name="per-form-tokens">
<description>Generate unique tokens per form for enhanced security</description>

**ApplicationController:**
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception,
                       prepend: true

  # Generate action-specific tokens
  def form_authenticity_token(**options)
    options[:form_options] ||= {}
    options[:form_options][:action] = request.fullpath
    options[:form_options][:method] = request.request_method
    super(**options)
  end
end
```

**Benefits:**
- Token only valid for specific action
- Prevents token reuse across different forms
- Enhanced security for high-value actions
- Still transparent to developers
</pattern>

<pattern name="samesite-cookies">
<description>Use SameSite cookie attribute for defense-in-depth</description>

**Session Configuration:**
```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: '_myapp_session',
  same_site: :lax,      # Prevents CSRF from external sites
  secure: Rails.env.production?,  # HTTPS only in production
  httponly: true,       # Not accessible via JavaScript
  expire_after: 24.hours

# SameSite options:
# :strict - Most secure, blocks ALL cross-site requests (may break OAuth)
# :lax - Balances security and usability (RECOMMENDED)
# :none - Allows cross-site requests (requires secure: true)
```

**SameSite Behavior:**
```ruby
# :lax (RECOMMENDED)
# ✅ Allows: Top-level navigation (clicking link from external site)
# ❌ Blocks: Embedded requests (forms, AJAX from external sites)

# :strict
# ❌ Blocks: ALL cross-site requests including top-level navigation

# :none
# ✅ Allows: ALL cross-site requests (use with caution)
```

**Why Use SameSite:**
- Defense-in-depth (complements CSRF tokens)
- Blocks many CSRF attacks even without token
- Modern browser support is excellent
- Minimal compatibility issues with :lax
</pattern>

<pattern name="webhook-endpoints">
<description>Skip CSRF for webhook endpoints that don't use sessions</description>

**Webhook Controller:**
```ruby
# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  # Skip CSRF - webhooks don't use session cookies
  skip_before_action :verify_authenticity_token

  # Use signature verification instead
  before_action :verify_webhook_signature

  def stripe
    payload = request.body.read
    event = Stripe::Webhook.construct_event(
      payload,
      request.headers['Stripe-Signature'],
      ENV['STRIPE_WEBHOOK_SECRET']
    )

    # Process webhook event
    case event.type
    when 'payment_intent.succeeded'
      handle_successful_payment(event.data.object)
    end

    head :ok
  rescue Stripe::SignatureVerificationError => e
    head :bad_request
  end

  private

  def verify_webhook_signature
    # Service-specific signature verification
    # This replaces CSRF protection for webhooks
  end

  def handle_successful_payment(payment_intent)
    # Handle payment...
  end
end
```

**Why Skip CSRF:**
- Webhooks use signature verification, not sessions
- External services cannot access CSRF tokens
- Signature verification is more appropriate
- Still secure through cryptographic signatures
</pattern>

<antipatterns>
<antipattern>
<description>Skipping CSRF for session-based authentication</description>
<reason>CRITICAL - Allows attackers to perform actions as authenticated users</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY
class FeedbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    # Uses session-based auth but no CSRF protection
    @feedback = current_user.feedbacks.create!(feedback_params)
    redirect_to @feedback
  end
end

# Attack scenario:
# 1. User logs into app (session cookie set)
# 2. Attacker tricks user to visit malicious site
# 3. Malicious site submits form to /feedbacks
# 4. Browser includes session cookie
# 5. Feedback created as authenticated user
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Keep CSRF protection enabled
class FeedbacksController < ApplicationController
  # Don't skip CSRF for session-based auth
  # protect_from_forgery is inherited from ApplicationController

  def create
    @feedback = current_user.feedbacks.create!(feedback_params)
    redirect_to @feedback
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Forgetting csrf_meta_tags in layout</description>
<reason>JavaScript requests will fail CSRF validation</reason>
<bad-example>
```erb
<%# ❌ MISSING CSRF META TAGS %>
<!DOCTYPE html>
<html>
  <head>
    <title>My App</title>
    <%= stylesheet_link_tag "application" %>
    <%= javascript_include_tag "application" %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

```javascript
// JavaScript cannot find CSRF token
const token = document.querySelector("meta[name=csrf-token]")?.content;
// token is undefined - fetch requests will fail
```
</bad-example>
<good-example>
```erb
<%# ✅ INCLUDES CSRF META TAGS %>
<!DOCTYPE html>
<html>
  <head>
    <title>My App</title>
    <%= csrf_meta_tags %>
    <%= stylesheet_link_tag "application" %>
    <%= javascript_include_tag "application" %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```
</good-example>
</antipattern>

<antipattern>
<description>Using form_tag without authenticity_token</description>
<reason>Form submission will fail CSRF validation</reason>
<bad-example>
```erb
<%# ❌ DEPRECATED form_tag without token %>
<%= form_tag feedbacks_path do %>
  <%= text_field_tag :content %>
  <%= submit_tag "Submit" %>
<% end %>
```
</bad-example>
<good-example>
```erb
<%# ✅ Use form_with (includes token automatically) %>
<%= form_with url: feedbacks_path do |form| %>
  <%= form.text_field :content %>
  <%= form.submit "Submit" %>
<% end %>

<%# ✅ Or form_for with model %>
<%= form_with model: @feedback do |form| %>
  <%= form.text_field :content %>
  <%= form.submit "Submit" %>
<% end %>
```
</good-example>
</antipattern>

<antipattern>
<description>Not including CSRF token in JavaScript fetch</description>
<reason>AJAX requests will be rejected by server</reason>
<bad-example>
```javascript
// ❌ MISSING CSRF TOKEN
fetch("/feedbacks", {
  method: "POST",
  headers: {
    "Content-Type": "application/json"
  },
  body: JSON.stringify({ feedback: { content: "test" } })
});
// Server returns 422 Unprocessable Entity
```
</bad-example>
<good-example>
```javascript
// ✅ INCLUDES CSRF TOKEN
const csrfToken = document.head.querySelector("meta[name=csrf-token]")?.content;

fetch("/feedbacks", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-CSRF-Token": csrfToken
  },
  body: JSON.stringify({ feedback: { content: "test" } })
});

// ✅ BETTER - Use @rails/request.js
import { post } from '@rails/request.js';
post('/feedbacks', {
  body: JSON.stringify({ feedback: { content: "test" } }),
  contentType: 'application/json'
});
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test CSRF protection in controller and system tests:

```ruby
# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "rejects POST without CSRF token" do
    # Attempt request with invalid token
    assert_raises(ActionController::InvalidAuthenticityToken) do
      post feedbacks_url,
           params: { feedback: { content: "test" } },
           headers: { "X-CSRF-Token" => "invalid_token" }
    end
  end

  test "accepts POST with valid CSRF token" do
    # Rails test helpers include CSRF token automatically
    post feedbacks_url,
         params: {
           feedback: {
             content: "test",
             recipient_email: "user@example.com"
           }
         }

    assert_response :redirect
    assert_equal "Feedback created successfully", flash[:notice]
  end

  test "rejects DELETE without CSRF token" do
    feedback = feedbacks(:one)

    assert_raises(ActionController::InvalidAuthenticityToken) do
      delete feedback_url(feedback),
             headers: { "X-CSRF-Token" => "invalid" }
    end

    # Feedback should still exist
    assert Feedback.exists?(feedback.id)
  end
end

# test/system/csrf_protection_test.rb
class CsrfProtectionTest < ApplicationSystemTestCase
  test "form includes CSRF token" do
    visit new_feedback_path

    # Check for hidden authenticity_token field
    assert_selector "input[name='authenticity_token'][type='hidden']"
  end

  test "AJAX request includes CSRF token" do
    visit feedbacks_path

    # Check CSRF meta tags are present
    assert_selector "meta[name='csrf-token']", visible: false
    assert_selector "meta[name='csrf-param']", visible: false

    # Click button that triggers AJAX
    click_button "Add Feedback"

    # AJAX should succeed (token included automatically by Rails UJS)
    assert_text "Feedback created"
  end
end

# test/integration/csrf_error_handling_test.rb
class CsrfErrorHandlingTest < ActionDispatch::IntegrationTest
  test "handles CSRF failure gracefully" do
    # Simulate CSRF attack (bypass session)
    post feedbacks_url,
         params: { feedback: { content: "test" } },
         headers: { "X-CSRF-Token" => "forged_token" }

    # Should redirect to root with error message
    assert_redirected_to root_path
    follow_redirect!
    assert_select ".alert", text: /session has expired/i
  end
end
```
</testing>

<related-skills>
- security-xss - XSS prevention
- security-sql-injection - SQL injection prevention
- authentication-session - Session-based authentication
- authentication-token - Token-based API authentication
- strong-parameters - Parameter filtering
</related-skills>

<resources>
- [Rails Security Guide - CSRF](https://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)
- [OWASP CSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [SameSite Cookie Attribute](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite)
- [@rails/request.js Documentation](https://github.com/rails/request.js)
</resources>
