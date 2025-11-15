---
name: rails-ai:initializers
description: Use when configuring gems, customizing Rails behavior, or setting up application-wide settings - organize configs in config/initializers/ with predictable load order, environment awareness, secure credential access
---

# Initializers Best Practices

Configure gems, customize Rails behavior, and set up application-wide settings using initialization files that run once during boot.

<when-to-use>
- Configuring third-party gems and libraries
- Setting up Rails framework behavior (mailers, storage, sessions)
- Implementing security policies (CSP, CORS, parameter filtering)
- Customizing autoloading and inflections
- Registering custom MIME types
- Environment-specific setup that runs once at boot
- Application-wide constants and configuration
</when-to-use>

<benefits>
- **Organized Configuration** - Separate concerns into focused files
- **Predictable Load Order** - Alphabetical loading with override capability
- **Environment Awareness** - Conditional setup based on Rails.env
- **Credentials Integration** - Secure access to encrypted secrets
- **One-Time Execution** - Runs once at boot, not on each request
- **Framework Integration** - Configure Rails and gems properly
</benefits>

<standards>
- Place ALL custom initializers in `config/initializers/`
- Files load alphabetically - use numbered prefixes if order matters
- Use descriptive filenames: `action_mailer.rb`, `content_security_policy.rb`
- NEVER reference reloadable constants (app/ code) directly
- Use `to_prepare` for code that references models/controllers
- Use `after_initialize` for post-boot setup
- NEVER hardcode secrets - use credentials or ENV vars
- Wrap config in `Rails.application.configure do` blocks
- Use environment conditionals (`Rails.env.production?`) when needed
</standards>

## Initialization Lifecycle

<pattern name="initialization-order">
<description>Understanding when initializers run during application boot</description>

**Boot Sequence:**
```ruby
# 1. config/application.rb runs first
# 2. config/environments/*.rb runs second (based on RAILS_ENV)
# 3. config/initializers/*.rb run third (alphabetically)
# 4. after_initialize callbacks run last
```

**Load Order Example:**
```bash
config/initializers/
  00_first.rb           # Runs first (numbered prefix)
  action_mailer.rb      # Runs in alphabetical order
  cors.rb
  session_store.rb
  zzz_last.rb           # Runs last (numbered prefix)
```

**When Order Matters:**
```ruby
# config/initializers/00_redis.rb (must load before...)
REDIS = Redis.new(url: Rails.application.credentials.redis_url)

# config/initializers/01_sidekiq.rb (depends on REDIS constant)
Sidekiq.configure_server do |config|
  config.redis = { url: REDIS.url }
end
```
</pattern>

## Common Initializers

<pattern name="action-mailer-configuration">
<description>Configure email delivery with secure credentials</description>

```ruby
# config/initializers/action_mailer.rb
Rails.application.configure do
  if Rails.env.production?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: "smtp.sendgrid.net",
      port: 587,
      domain: Rails.application.credentials.dig(:smtp, :domain),
      user_name: Rails.application.credentials.dig(:smtp, :username),
      password: Rails.application.credentials.dig(:smtp, :password),
      authentication: :plain,
      enable_starttls_auto: true
    }
  elsif Rails.env.development?
    config.action_mailer.delivery_method = :letter_opener
  else
    config.action_mailer.delivery_method = :test
  end

  # Required for mailer links
  config.action_mailer.default_url_options = {
    host: Rails.env.production? ? "example.com" : "localhost:3000",
    protocol: Rails.env.production? ? "https" : "http"
  }
end
```
</pattern>

## Security Configuration

<pattern name="content-security-policy">
<description>Implement Content Security Policy to prevent XSS attacks</description>

```ruby
# config/initializers/content_security_policy.rb
Rails.application.configure do
  config.content_security_policy do |policy|
    if Rails.env.development?
      # Relaxed CSP for development (hot reloading)
      policy.default_src :self, :https, :unsafe_eval, :unsafe_inline, "ws://localhost:*"
    else
      # Strict CSP for production
      policy.default_src :self, :https
    end

    policy.font_src :self, :https, :data
    policy.img_src :self, :https, :data
    policy.object_src :none
    policy.script_src :self, :https
    policy.style_src :self, :https
    policy.frame_ancestors :none
  end

  # Generate nonces for inline scripts
  config.content_security_policy_nonce_generator = ->(request) {
    SecureRandom.base64(16)
  }
  config.content_security_policy_nonce_directives = %w[script-src]
end
```
</pattern>

<pattern name="cors-configuration">
<description>Configure Cross-Origin Resource Sharing for API endpoints</description>

```ruby
# config/initializers/cors.rb (requires gem "rack-cors")
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "example.com", /\Ahttps:\/\/.*\.example\.com\z/

    resource "/api/*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      max_age: 86400
  end

  # Development: Allow localhost
  if Rails.env.development?
    allow do
      origins "localhost:3000"
      resource "*", headers: :any, methods: :any, credentials: true
    end
  end
end
```
</pattern>

<pattern name="session-store-configuration">
<description>Configure secure session storage</description>

```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: "_myapp_session",
  same_site: :lax,
  secure: Rails.env.production?,
  httponly: true,
  expire_after: 2.weeks
```
</pattern>

## Framework Customization

<pattern name="inflections-and-acronyms">
<description>Configure custom inflections and acronyms for autoloading</description>

```ruby
# config/initializers/inflections.rb
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "api" => "API",
    "html" => "HTML",
    "json" => "JSON",
    "xml" => "XML",
    "pdf" => "PDF",
    "csv" => "CSV",
    "oauth" => "OAuth"
  )
end
```
</pattern>

## Reloadable Code Patterns

<pattern name="to-prepare-callback">
<description>Use to_prepare for code that references app/ classes</description>

```ruby
# ❌ BAD - Initializers run before app/ code loads
ApiGateway.endpoint = "https://api.example.com"  # NameError!

# ✅ GOOD - Use to_prepare
Rails.application.config.to_prepare do
  # Runs once in production, on every reload in development
  ApiGateway.endpoint = Rails.application.credentials.dig(:api_gateway, :endpoint)
  User.admin_email = Rails.application.credentials.admin_email
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Hardcoding secrets in initializers</description>
<reason>Security violation - secrets exposed in version control</reason>
<bad-example>
```ruby
# ❌ BAD
Stripe.api_key = "sk_live_abc123def456ghi789"  # NEVER!
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use encrypted credentials or ENV vars
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
```
</good-example>
</antipattern>

<antipattern>
<description>Complex business logic in initializers</description>
<reason>Initializers should configure, not perform operations</reason>
<bad-example>
```ruby
# ❌ BAD - Don't run migrations or HTTP requests at boot
if User.count.zero?
  User.create!(email: "admin@example.com", password: "temp123")
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use rake tasks for one-time operations
# lib/tasks/setup.rake
task :create_admin => :environment do
  User.create!(...) if User.count.zero?
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# test/initializers/content_security_policy_test.rb
class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "CSP header is set on responses" do
    get root_path
    assert_match /default-src/, response.headers["Content-Security-Policy"]
  end
end

# test/initializers/cors_test.rb
class CorsTest < ActionDispatch::IntegrationTest
  test "CORS headers allow configured origins" do
    get "/api/users", headers: { "Origin" => "https://example.com" }
    assert_equal "https://example.com", response.headers["Access-Control-Allow-Origin"]
  end
end
```
</testing>

<related-skills>
- rails-ai:credentials - Secure credential storage
- rails-ai:environment-config - Environment specific settings
- rails-ai:security-csrf - CSRF protection configuration
- rails-ai:security-xss - XSS prevention and CSP
</related-skills>
