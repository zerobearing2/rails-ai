---
name: environment-configuration
domain: config
dependencies: []
version: 1.0
rails_version: 8.1+
---

# Environment-Specific Configuration

Configure Rails applications for different deployment environments (development, test, production, staging).

<when-to-use>
- Setting up new Rails applications
- Configuring environment-specific behavior (caching, logging, error handling)
- Optimizing development workflow (debugging, error reports, hot reloading)
- Preparing production deployments (SSL, asset compilation, eager loading)
- Creating staging environments for pre-production testing
- Managing feature flags and environment-specific settings
- Configuring background jobs, mailers, and storage per environment
</when-to-use>

<benefits>
- **Environment Isolation**: Separate configs prevent production bugs from dev settings
- **Development Speed**: Fast feedback with caching toggle, verbose logs, auto-reloading
- **Production Safety**: Eager loading, SSL enforcement, optimized caching
- **Testing Reliability**: Isolated test environment prevents flaky tests
- **Deployment Flexibility**: Environment variables for deployment-specific configuration
- **Security**: Encrypted credentials per environment, no secrets in code
</benefits>

<standards>
- Use `config/environments/` for environment-specific configuration
- Load order: application.rb → environment file → initializers
- Development: Prioritize developer experience (verbose errors, hot reload)
- Test: Fast, isolated, deterministic (inline jobs, null cache)
- Production: Optimized for performance and security (eager load, SSL, caching)
- Use `Rails.env` checks for environment-specific logic in code
- Store deployment configs in ENV vars, not hardcoded values
- Keep credentials encrypted in `config/credentials/` per environment
- Never commit production secrets to version control
</standards>

## Standard Rails Environments

<pattern name="environment-detection">
<description>Detect and check the current Rails environment</description>

**Environment Detection:**
```ruby
Rails.env                    # => "development", "test", "production"
Rails.env.development?       # => true/false
Rails.env.test?             # => true/false
Rails.env.production?       # => true/false

# Set via ENV var or command line
ENV["RAILS_ENV"] = "production"
# RAILS_ENV=production rails server
```

**Standard Environments:**
- **development** - Local development (verbose errors, auto-reload)
- **test** - Automated testing (fast, isolated, deterministic)
- **production** - Live application (optimized, secure, cached)
- **staging** - Optional pre-production (production-like but with test data)

**Load Order:** `config/application.rb` → `config/environments/#{Rails.env}.rb` → `config/initializers/*.rb`
</pattern>

## Development Configuration

<pattern name="development-config">
<description>Configure development environment for optimal developer experience</description>

**config/environments/development.rb:**
```ruby
Rails.application.configure do
  # Show full error reports with backtraces
  config.consider_all_requests_local = true

  # Enable server timing headers for performance insights
  config.server_timing = true

  # Enable/disable caching (toggle with: rails dev:cache)
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.cache_store = :solid_cache_store
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Mailer: Open emails in browser (requires letter_opener gem)
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  config.action_mailer.delivery_method = :letter_opener

  # Deprecations and debugging
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_job.verbose_enqueue_logs = true
  config.i18n.raise_on_missing_translations = true
  config.action_view.annotate_rendered_view_with_filenames = true
  config.active_record.verbose_query_logs = true

  # Background jobs: SolidQueue with dedicated database
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Suppress asset pipeline logs for cleaner output
  config.assets.quiet = true

  # Allow all hosts in development (no DNS rebinding protection)
  config.hosts.clear

  # Optional: Bullet gem for N+1 query detection
  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
end
```

**Key Development Features:**
- **Full error reports**: See detailed backtraces and variable values
- **Auto-reloading**: Code changes take effect without restart
- **Caching toggle**: Test caching behavior with `rails dev:cache`
- **Verbose logging**: SQL queries, job enqueueing, deprecations
- **Email preview**: Open emails in browser with letter_opener
- **N+1 detection**: Bullet gem alerts for query optimization opportunities
</pattern>

## Test Configuration

<pattern name="test-config">
<description>Configure test environment for fast, isolated, deterministic tests</description>

**config/environments/test.rb:**
```ruby
Rails.application.configure do
  # Eager load code in CI for accurate test coverage
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache headers
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{1.hour.to_i}" }

  # Show full error reports in test failures
  config.consider_all_requests_local = true

  # Disable request forgery protection in tests
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files in temporary directory
  config.active_storage.service = :test

  # Mailer: Store emails in ActionMailer::Base.deliveries
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test

  # Debugging and deprecations
  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecation = :raise
  config.i18n.raise_on_missing_translations = true
  config.action_view.annotate_rendered_view_with_filenames = true

  # No caching, inline jobs for determinism
  config.cache_store = :null_store
  config.active_job.queue_adapter = :test
end
```

**Key Test Features:**
- **Deterministic**: Same results every run (no caching, inline jobs)
- **Fast**: No network calls, no real emails, no background processing
- **Isolated**: Each test runs in a transaction, rolled back after
- **Eager loading in CI**: Catches autoload errors before production
- **Test adapter**: Jobs run synchronously, no async complexity
</pattern>

## Production Configuration

<pattern name="production-config">
<description>Configure production environment for performance, security, and reliability</description>

**config/environments/production.rb:**
```ruby
Rails.application.configure do
  # Disable code reloading and enable eager loading
  config.enable_reloading = false
  config.eager_load = true

  # Don't show full error reports to users
  config.consider_all_requests_local = false

  # Ensure requests are served from a single host
  config.action_controller.default_url_options = { host: "example.com", protocol: "https" }

  # Enable caching
  config.action_controller.perform_caching = true
  config.cache_store = :solid_cache_store

  # Disable serving static files from public/ (nginx/Apache handles this)
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Don't fallback to assets pipeline if precompiled asset is missed
  config.assets.compile = false

  # Active Storage: Use cloud storage (S3, GCS, Azure)
  config.active_storage.service = :amazon

  # Force all access to the app over SSL
  config.force_ssl = true

  # Log to STDOUT for container/cloud deployments
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with request ID for tracing
  config.log_tags = [:request_id]

  # Logging and deprecations
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.active_support.report_deprecations = false

  # Background jobs: SolidQueue with dedicated database
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Production optimizations
  config.active_record.dump_schema_after_migration = false
  config.i18n.fallbacks = true

  # Action Mailer: SMTP with credentials
  config.action_mailer.perform_caching = false
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
  config.action_mailer.default_url_options = { host: "example.com", protocol: "https" }
  config.action_mailer.asset_host = "https://cdn.example.com"

  # DNS rebinding protection
  config.hosts = ["example.com", /.*\.example\.com/]
end
```

**Key Production Features:**
- **Eager loading**: All code loaded at startup for performance
- **SSL enforcement**: Force HTTPS for all requests
- **Optimized caching**: SolidCache for fast, persistent caching
- **Cloud storage**: S3/GCS for Active Storage uploads
- **Structured logging**: JSON logs with request IDs for tracing
- **Security headers**: DNS rebinding protection, host allowlist
- **No error details**: Generic error pages prevent information leakage
</pattern>

## Staging Environment

<pattern name="staging-config">
<description>Create staging environment that mirrors production with test-friendly overrides</description>

**config/environments/staging.rb:**
```ruby
# Start with production config, override for testing
require_relative "production"

Rails.application.configure do
  config.x.stripe.publishable_key = Rails.application.credentials.dig(:stripe, :test_publishable_key)
  config.action_mailer.delivery_method = :letter_opener_web
  config.content_security_policy_report_only = true
  config.log_level = :debug
  config.hosts << "staging.example.com"
end
```

**When to Use Staging:**
- Pre-production testing with production-like environment
- Customer demos with test data
- QA testing before release
- Integration testing with external services (test mode)
</pattern>

## Custom Configuration

<pattern name="custom-config-namespace">
<description>Store custom application settings in config.x namespace</description>

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries = 3
    config.x.super_debugger = true
    config.x.features.ai_assistant = Rails.env.production? || ENV["ENABLE_AI"] == "true"
  end
end

# Access anywhere
Rails.configuration.x.payment_processing.schedule  # => :daily
Rails.configuration.x.super_debugger                # => true
```

**Benefits:** Organized settings, type-safe access, environment-aware, avoids globals
</pattern>

<pattern name="environment-variables">
<description>Use ENV vars for deployment-specific configuration</description>

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.max_upload_size = ENV.fetch("MAX_UPLOAD_SIZE", 10.megabytes)
  config.feature_enabled = ENV["FEATURE_FLAG_NEW_UI"] == "true"
  config.api_key = ENV.fetch("API_KEY")  # Required, raises if missing
  config.stripe_key = ENV.fetch("STRIPE_SECRET_KEY") {
    Rails.application.credentials.dig(:stripe, :secret_key)
  }
end

# In application code
class Upload < ApplicationRecord
  validates :file_size, numericality: {
    less_than: ENV.fetch("MAX_UPLOAD_SIZE", 10.megabytes).to_i
  }
end
```

**Best Practices:**
- Use ENV vars for deployment-specific settings (URLs, feature flags)
- Use credentials.yml.enc for secrets (API keys, passwords)
- Provide sensible defaults with `fetch(key, default)`
- Document required ENV vars in README
</pattern>

<pattern name="per-environment-credentials">
<description>Use environment-specific encrypted credentials</description>

```
config/credentials.yml.enc                    # Default
config/credentials/development.yml.enc        # Development
config/credentials/production.yml.enc         # Production
config/credentials/staging.yml.enc            # Staging
```

```ruby
# Access (auto-loads based on Rails.env)
Rails.application.credentials.stripe_key
Rails.application.credentials.dig(:aws, :access_key_id)

# In config files
config.action_mailer.smtp_settings = {
  user_name: Rails.application.credentials.dig(:smtp, :username),
  password: Rails.application.credentials.dig(:smtp, :password)
}
```

```bash
# Edit credentials
EDITOR=vim rails credentials:edit --environment production
EDITOR=vim rails credentials:edit --environment development
```

**Benefits:** Encrypted in git, per-environment secrets, auto-detection
</pattern>

<pattern name="feature-flags">
<description>Implement environment-based feature flags</description>

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    config.x.features.new_editor = Rails.env.development? || ENV["ENABLE_NEW_EDITOR"] == "true"
    config.x.features.ai_content = !Rails.env.test?
    config.x.features.beta_ui = ENV["BETA_FEATURES"] == "true"
  end
end

# In controllers
class PostsController < ApplicationController
  def edit
    @post = Post.find(params[:id])
    Rails.configuration.x.features.new_editor ? render(:edit_new) : render(:edit)
  end
end

# In views
<% if Rails.configuration.x.features.beta_ui %>
  <%= render "posts/beta_form", post: @post %>
<% else %>
  <%= render "posts/form", post: @post %>
<% end %>
```

**Benefits:** Gradual rollout, A/B testing, per-environment toggles, no code changes
</pattern>

<antipatterns>
<antipattern>
<description>Using production credentials in development/test</description>
<reason>Security risk - can accidentally send real emails, charge real cards, modify production data</reason>
<bad-example>
```ruby
# ❌ BAD - Same credentials for all environments
stripe:
  secret_key: sk_live_XXXXXXXXXXXX  # Production key in all environments!
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Separate credentials per environment
# config/credentials/production.yml.enc
stripe:
  secret_key: sk_live_XXXXXXXXXXXX

# config/credentials/development.yml.enc
stripe:
  secret_key: sk_test_XXXXXXXXXXXX  # Test mode
```
</good-example>
</antipattern>

<antipattern>
<description>Disabling SSL in production</description>
<reason>Exposes user data, session cookies, and passwords to network attacks</reason>
<bad-example>
```ruby
# ❌ BAD - No SSL enforcement
config.force_ssl = false  # SECURITY RISK!
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Force SSL in production
config.force_ssl = true
config.ssl_options = { hsts: { expires: 1.year, subdomains: true } }
```
</good-example>
</antipattern>

<antipattern>
<description>Using different job adapters in test vs production</description>
<reason>Hides bugs related to job serialization, timing, and error handling</reason>
<bad-example>
```ruby
# ❌ BAD - Bug: works in test but fails in production
class ProcessUploadJob < ApplicationJob
  def perform(upload)  # Non-serializable object
    upload.process!
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Serialize with IDs
class ProcessUploadJob < ApplicationJob
  def perform(upload_id)  # Serializable
    Upload.find(upload_id).process!
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# test/config/environments_test.rb
class EnvironmentsTest < ActiveSupport::TestCase
  test "development shows full error reports" do
    Rails.stub :env, "development".inquiry do
      assert Rails.application.config.consider_all_requests_local
    end
  end

  test "production enforces SSL" do
    Rails.stub :env, "production".inquiry do
      require Rails.root.join("config/environments/production.rb")
      assert Rails.application.config.force_ssl
    end
  end
end

# test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "sends welcome email in production only" do
    Rails.stub :env, "production".inquiry do
      User.create!(email: "test@example.com")
      assert_enqueued_emails 1
    end
  end
end
```
</testing>

<related-skills>
- credentials-management - Managing encrypted secrets
- initializers-best-practices - Application initialization
- solid-stack-setup - SolidQueue, SolidCache, SolidCable configuration
</related-skills>

<resources>
- [Rails Configuration Guide](https://guides.rubyonrails.org/configuring.html)
- [Encrypted Credentials](https://guides.rubyonrails.org/security.html#custom-credentials)
- [Rails 8 Solid Stack](https://fly.io/ruby-dispatch/solid-cache-solid-queue-solid-cable/)
</resources>
