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
  protect_from_forgery with: :exception
  # Raises ActionController::InvalidAuthenticityToken if token invalid
end
```

**Alternative Strategies:**
```ruby
protect_from_forgery with: :null_session  # Reset session to empty hash
protect_from_forgery with: :reset_session  # Clear entire session
protect_from_forgery with: :exception      # RECOMMENDED - raise exception
```

**Why :exception is Best:**
Makes failures visible, prevents silent bypasses, forces proper error handling, fails secure.
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
<head>
  <title>My App</title>
  <%= csrf_meta_tags %>
  <%# Generates: <meta name="csrf-token" content="THE-TOKEN"> %>
</head>
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

**Why Secure:**
Rails checks `X-CSRF-Token` header matches session token.
</pattern>

<pattern name="rails-request-js">
<description>Use @rails/request.js for automatic CSRF handling</description>

**Installation:**
```bash
npm install @rails/request.js
```

**Usage:**
```javascript
// ✅ SECURE - Token automatically included
import { post, patch, destroy } from '@rails/request.js'

await post('/feedbacks', {
  body: JSON.stringify({ feedback: { content: "test" } }),
  contentType: 'application/json',
  responseKind: 'json'
})

await patch('/feedbacks/123', {
  body: JSON.stringify({ feedback: { status: "reviewed" } })
})

await destroy('/feedbacks/123', { responseKind: 'json' })
```

**Why Recommended:**
Automatic CSRF token handling, consistent API, Rails-aware error handling.
</pattern>

## Attack Example

<pattern name="csrf-attack-scenario">
<description>How CSRF attacks work without protection</description>

**Attacker's Malicious Site (evil.com):**
```html
<!-- ❌ VULNERABLE if CSRF protection disabled -->
<form action="https://yourapp.com/account/destroy" method="POST" id="attack">
  <input type="hidden" name="confirmed" value="true">
</form>
<script>document.getElementById('attack').submit();</script>
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
  skip_before_action :verify_authenticity_token
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
class Api::V1::FeedbacksController < Api::V1::BaseController
  def create
    feedback = @current_api_user.feedbacks.create!(feedback_params)
    render json: feedback, status: :created
  end
  # ...
end
```

**Why Skip CSRF for APIs:**
API clients use Bearer tokens (not cookies), tokens must be explicitly sent (no automatic inclusion), CSRF only affects cookie-based authentication.
</pattern>

## Error Handling

<pattern name="graceful-csrf-failure">
<description>Handle CSRF failures with user-friendly error messages</description>

**ApplicationController:**
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    Rails.logger.warn(
      "CSRF failure: #{exception.message} IP: #{request.remote_ip} Path: #{request.fullpath}"
    )

    sign_out_user if user_signed_in?
    redirect_to root_path, alert: "Your session has expired. Please log in again."
  end

  private

  def sign_out_user
    cookies.delete(:user_token)
    reset_session
  end
end
```

**Why Important:**
Users see helpful error, security event is logged, stale sessions cleared, user can recover by logging in.
</pattern>

## Advanced Configuration

<pattern name="per-form-tokens">
<description>Generate unique tokens per form for enhanced security</description>

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true

  def form_authenticity_token(**options)
    options[:form_options] ||= {}
    options[:form_options][:action] = request.fullpath
    options[:form_options][:method] = request.request_method
    super(**options)
  end
end
```

**Benefits:**
Token only valid for specific action, prevents token reuse across forms, enhanced security for high-value actions.
</pattern>

<pattern name="samesite-cookies">
<description>Use SameSite cookie attribute for defense-in-depth</description>

**Session Configuration:**
```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: '_myapp_session',
  same_site: :lax,                    # Prevents CSRF from external sites
  secure: Rails.env.production?,      # HTTPS only in production
  httponly: true,                     # Not accessible via JavaScript
  expire_after: 24.hours
```

**SameSite Options:**
- `:lax` (RECOMMENDED) - Allows top-level navigation, blocks embedded requests
- `:strict` - Most secure, blocks ALL cross-site requests (may break OAuth)
- `:none` - Allows all cross-site requests (requires secure: true)

**Why Use SameSite:**
Defense-in-depth complements CSRF tokens, blocks many attacks even without token, excellent modern browser support.
</pattern>

<pattern name="webhook-endpoints">
<description>Skip CSRF for webhook endpoints that don't use sessions</description>

**Webhook Controller:**
```ruby
# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature

  def stripe
    payload = request.body.read
    event = Stripe::Webhook.construct_event(
      payload,
      request.headers['Stripe-Signature'],
      ENV['STRIPE_WEBHOOK_SECRET']
    )

    case event.type
    when 'payment_intent.succeeded'
      handle_successful_payment(event.data.object)
    end

    head :ok
  rescue Stripe::SignatureVerificationError
    head :bad_request
  end

  private

  def verify_webhook_signature
    # Service-specific signature verification replaces CSRF protection
  end
end
```

**Why Skip CSRF:**
Webhooks use signature verification (not sessions), external services cannot access CSRF tokens, signature verification is more appropriate.
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
    @feedback = current_user.feedbacks.create!(feedback_params)
    redirect_to @feedback
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Keep CSRF protection enabled
class FeedbacksController < ApplicationController
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
<head>
  <title>My App</title>
  <%= stylesheet_link_tag "application" %>
</head>
```
</bad-example>
<good-example>
```erb
<%# ✅ INCLUDES CSRF META TAGS %>
<head>
  <title>My App</title>
  <%= csrf_meta_tags %>
  <%= stylesheet_link_tag "application" %>
</head>
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
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ feedback: { content: "test" } })
});
```
</bad-example>
<good-example>
```javascript
// ✅ INCLUDES CSRF TOKEN
const csrfToken = document.head.querySelector("meta[name=csrf-token]")?.content;
fetch("/feedbacks", {
  method: "POST",
  headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
  body: JSON.stringify({ feedback: { content: "test" } })
});
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "rejects POST without CSRF token" do
    assert_raises(ActionController::InvalidAuthenticityToken) do
      post feedbacks_url,
           params: { feedback: { content: "test" } },
           headers: { "X-CSRF-Token" => "invalid_token" }
    end
  end

  test "accepts POST with valid CSRF token" do
    post feedbacks_url, params: { feedback: { content: "test" } }
    assert_response :redirect
  end

  test "rejects DELETE without CSRF token" do
    feedback = feedbacks(:one)
    assert_raises(ActionController::InvalidAuthenticityToken) do
      delete feedback_url(feedback), headers: { "X-CSRF-Token" => "invalid" }
    end
    assert Feedback.exists?(feedback.id)
  end
end

# test/system/csrf_protection_test.rb
class CsrfProtectionTest < ApplicationSystemTestCase
  test "form includes CSRF token" do
    visit new_feedback_path
    assert_selector "input[name='authenticity_token'][type='hidden']"
  end

  test "AJAX request includes CSRF token" do
    visit feedbacks_path
    assert_selector "meta[name='csrf-token']", visible: false
    click_button "Add Feedback"
    assert_text "Feedback created"
  end
end
```
</testing>

<related-skills>
- security-xss - XSS prevention
- security-sql-injection - SQL injection prevention
- authentication-session - Session-based authentication
- authentication-token - Token-based API authentication
- security-strong-parameters - Parameter filtering
</related-skills>

<resources>
- [Rails Security Guide - CSRF](https://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)
- [OWASP CSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [@rails/request.js Documentation](https://github.com/rails/request.js)
</resources>
