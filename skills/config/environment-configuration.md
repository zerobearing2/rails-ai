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
# Get current environment
Rails.env                    # => "development", "test", "production"
Rails.env.development?       # => true/false
Rails.env.test?             # => true/false
Rails.env.production?       # => true/false

# Set environment via ENV var
ENV["RAILS_ENV"] = "production"

# Or via command line
# RAILS_ENV=production rails server
# RAILS_ENV=test rails test
```

**Standard Environments:**
- **development** - Local development (verbose errors, auto-reload)
- **test** - Automated testing (fast, isolated, deterministic)
- **production** - Live application (optimized, secure, cached)
- **staging** - Optional pre-production (production-like but with test data)

**Load Order:**
1. `config/application.rb` (shared configuration)
2. `config/environments/#{Rails.env}.rb` (environment-specific)
3. `config/initializers/*.rb` (alphabetically)
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

  # Mailer settings for development
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Open emails in browser instead of sending (requires letter_opener gem)
  config.action_mailer.delivery_method = :letter_opener

  # Print deprecation notices to Rails logger
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations
  config.active_support.disallowed_deprecation = :raise

  # Highlight code that enqueued background jobs in logs
  config.active_job.verbose_enqueue_logs = true

  # Raise error on missing translations
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered views with file names (helpful for debugging)
  config.action_view.annotate_rendered_view_with_filenames = true

  # Highlight code that triggered database queries in logs
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

  # Mailer: Don't send real emails, store in ActionMailer::Base.deliveries
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to stderr
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations
  config.active_support.disallowed_deprecation = :raise

  # Raise on missing translations
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered views with file names
  config.action_view.annotate_rendered_view_with_filenames = true

  # Use null cache (no caching in tests)
  config.cache_store = :null_store

  # Background jobs: Test adapter (runs inline, synchronously)
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

  # Set log level (default: info)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Don't log any deprecations in production
  config.active_support.report_deprecations = false

  # Background jobs: SolidQueue with dedicated database
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Don't dump schema after migrations in production
  config.active_record.dump_schema_after_migration = false

  # Enable locale fallbacks for I18n
  config.i18n.fallbacks = true

  # Action Mailer configuration
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
  config.action_mailer.default_url_options = {
    host: "example.com",
    protocol: "https"
  }
  config.action_mailer.asset_host = "https://cdn.example.com"

  # DNS rebinding protection: Allow specific hosts
  config.hosts = [
    "example.com",
    /.*\.example\.com/  # Allow all subdomains
  ]

  # Optional: CDN for assets
  # config.asset_host = "https://cdn.example.com"
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
# Start with production configuration
require_relative "production"

Rails.application.configure do
  # Staging-specific overrides

  # Allow test credit cards for payment testing
  config.x.stripe.publishable_key = Rails.application.credentials.dig(:stripe, :test_publishable_key)

  # Enable letter_opener_web for email preview
  config.action_mailer.delivery_method = :letter_opener_web

  # Less strict CSP for testing (report only mode)
  config.content_security_policy_report_only = true

  # More verbose logging for debugging
  config.log_level = :debug

  # Allow staging hosts
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

**Application Configuration:**
```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # Custom configuration namespace
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries = 3
    config.x.super_debugger = true

    # Per-environment settings
    config.x.features.ai_assistant = Rails.env.production? || ENV["ENABLE_AI"] == "true"
  end
end
```

**Access Anywhere:**
```ruby
# In models, controllers, views, jobs, etc.
Rails.configuration.x.payment_processing.schedule  # => :daily
Rails.configuration.x.super_debugger                # => true

# Environment-specific logic
if Rails.configuration.x.features.ai_assistant
  # Enable AI features
end
```

**Benefits:**
- Organized custom settings
- Type-safe access (no string keys)
- Environment-aware configuration
- Avoids global constants
</pattern>

<pattern name="environment-variables">
<description>Use ENV vars for deployment-specific configuration</description>

**Reading ENV Vars:**
```ruby
# config/environments/production.rb
Rails.application.configure do
  # With default value
  config.max_upload_size = ENV.fetch("MAX_UPLOAD_SIZE", 10.megabytes)

  # Boolean flag
  config.feature_enabled = ENV["FEATURE_FLAG_NEW_UI"] == "true"

  # Required value (raises error if missing)
  config.api_key = ENV.fetch("API_KEY")

  # With fallback to credentials
  config.stripe_key = ENV.fetch("STRIPE_SECRET_KEY") {
    Rails.application.credentials.dig(:stripe, :secret_key)
  }
end
```

**In Application Code:**
```ruby
# app/models/upload.rb
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

**Credential Files:**
```
config/credentials.yml.enc                    # Default credentials
config/credentials/development.yml.enc        # Development overrides
config/credentials/production.yml.enc         # Production secrets
config/credentials/staging.yml.enc            # Staging secrets
```

**Access Credentials:**
```ruby
# Rails automatically loads the correct file based on Rails.env

# In production, loads config/credentials/production.yml.enc
# Falls back to config/credentials.yml.enc if not found
Rails.application.credentials.stripe_key
Rails.application.credentials.dig(:aws, :access_key_id)

# In config files
config.action_mailer.smtp_settings = {
  user_name: Rails.application.credentials.dig(:smtp, :username),
  password: Rails.application.credentials.dig(:smtp, :password)
}
```

**Edit Credentials:**
```bash
# Edit production credentials
EDITOR=vim rails credentials:edit --environment production

# Edit development credentials
EDITOR=vim rails credentials:edit --environment development
```

**Benefits:**
- Secrets encrypted in version control
- Different secrets per environment
- No secrets in ENV vars or code
- Automatic environment detection
</pattern>

<pattern name="feature-flags">
<description>Implement environment-based feature flags</description>

**Configuration:**
```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # Feature flags based on environment
    config.x.features.new_editor = Rails.env.development? || ENV["ENABLE_NEW_EDITOR"] == "true"
    config.x.features.ai_content = !Rails.env.test?
    config.x.features.beta_ui = ENV["BETA_FEATURES"] == "true"
  end
end
```

**Usage in Code:**
```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def edit
    @post = Post.find(params[:id])

    if Rails.configuration.x.features.new_editor
      render :edit_new
    else
      render :edit
    end
  end
end
```

**Usage in Views:**
```erb
<% if Rails.configuration.x.features.beta_ui %>
  <%= render "posts/beta_form", post: @post %>
<% else %>
  <%= render "posts/form", post: @post %>
<% end %>
```

**Benefits:**
- Gradual feature rollout
- A/B testing capabilities
- Easy feature toggling per environment
- No code changes to enable/disable features
</pattern>

<antipatterns>
<antipattern>
<description>Hardcoding environment-specific values in application code</description>
<reason>Makes code brittle, difficult to test, and hard to deploy across environments</reason>
<bad-example>
```ruby
# ❌ BAD - Hardcoded production URL in model
class ApiClient
  BASE_URL = "https://api.production.com"

  def fetch_data
    HTTParty.get("#{BASE_URL}/data")
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Environment-specific configuration
# config/environments/production.rb
config.api_base_url = "https://api.production.com"

# config/environments/development.rb
config.api_base_url = "http://localhost:4000"

# app/models/api_client.rb
class ApiClient
  def fetch_data
    HTTParty.get("#{Rails.configuration.api_base_url}/data")
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using production credentials in development/test</description>
<reason>Security risk - can accidentally send real emails, charge real cards, modify production data</reason>
<bad-example>
```ruby
# ❌ BAD - Same credentials for all environments
# config/credentials.yml.enc (shared by all environments)
stripe:
  secret_key: sk_live_XXXXXXXXXXXX  # Production key!

aws:
  access_key_id: AKIAXXXXXXXX
  secret_access_key: XXXXXXXX  # Production bucket!
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Separate credentials per environment

# config/credentials/production.yml.enc
stripe:
  secret_key: sk_live_XXXXXXXXXXXX
aws:
  bucket: my-app-production

# config/credentials/development.yml.enc
stripe:
  secret_key: sk_test_XXXXXXXXXXXX  # Test mode
aws:
  bucket: my-app-development
```
</good-example>
</antipattern>

<antipattern>
<description>Enabling eager loading in development</description>
<reason>Slows down development by loading all code on every change</reason>
<bad-example>
```ruby
# ❌ BAD - Eager load in development
# config/environments/development.rb
Rails.application.configure do
  config.eager_load = true  # Slow startup, defeats auto-reload
  config.cache_classes = true  # No auto-reload!
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Fast feedback in development
# config/environments/development.rb
Rails.application.configure do
  config.eager_load = false  # Fast startup
  config.enable_reloading = true  # Auto-reload on changes
end
```
</good-example>
</antipattern>

<antipattern>
<description>Disabling SSL in production</description>
<reason>Exposes user data, session cookies, and passwords to network attacks</reason>
<bad-example>
```ruby
# ❌ BAD - No SSL enforcement
# config/environments/production.rb
Rails.application.configure do
  config.force_ssl = false  # SECURITY RISK!
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Force SSL in production
# config/environments/production.rb
Rails.application.configure do
  config.force_ssl = true  # Redirect HTTP to HTTPS
  config.ssl_options = {
    hsts: { expires: 1.year, subdomains: true }
  }
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using different job adapters in test vs production</description>
<reason>Hides bugs related to job serialization, timing, and error handling</reason>
<bad-example>
```ruby
# ❌ BAD - Different behavior in test
# config/environments/test.rb
config.active_job.queue_adapter = :inline  # Runs synchronously

# config/environments/production.rb
config.active_job.queue_adapter = :sidekiq  # Runs asynchronously

# Bug: This works in test but fails in production
class ProcessUploadJob < ApplicationJob
  def perform(upload)  # Upload model instance
    upload.process!
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use :test adapter and serialize properly
# config/environments/test.rb
config.active_job.queue_adapter = :test  # Queue jobs for testing

# Jobs use serializable arguments (IDs, not objects)
class ProcessUploadJob < ApplicationJob
  def perform(upload_id)  # Serializable ID
    upload = Upload.find(upload_id)
    upload.process!
  end
end

# test/jobs/process_upload_job_test.rb
test "enqueues job with upload ID" do
  upload = uploads(:one)

  assert_enqueued_with(job: ProcessUploadJob, args: [upload.id]) do
    ProcessUploadJob.perform_later(upload.id)
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not caching in production</description>
<reason>Severe performance impact - every request regenerates views, queries duplicated</reason>
<bad-example>
```ruby
# ❌ BAD - No caching in production
# config/environments/production.rb
Rails.application.configure do
  config.action_controller.perform_caching = false
  config.cache_store = :null_store  # Caching disabled!
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Enable caching in production
# config/environments/production.rb
Rails.application.configure do
  config.action_controller.perform_caching = true
  config.cache_store = :solid_cache_store  # Rails 8 default

  # Or Redis for distributed caching
  # config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test environment-specific behavior and configuration:

```ruby
# test/config/environments_test.rb
require "test_helper"

class EnvironmentsTest < ActiveSupport::TestCase
  test "development shows full error reports" do
    Rails.stub :env, "development".inquiry do
      assert Rails.application.config.consider_all_requests_local
    end
  end

  test "production hides error details from users" do
    Rails.stub :env, "production".inquiry do
      assert_not Rails.application.config.consider_all_requests_local
    end
  end

  test "production enforces SSL" do
    Rails.stub :env, "production".inquiry do
      # Load production config
      require Rails.root.join("config/environments/production.rb")
      assert Rails.application.config.force_ssl
    end
  end
end

# test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "sends welcome email in production only" do
    Rails.stub :env, "production".inquiry do
      user = User.create!(email: "test@example.com")
      assert_enqueued_emails 1
    end
  end

  test "skips welcome email in test environment" do
    user = User.create!(email: "test@example.com")
    assert_enqueued_emails 0
  end
end

# test/integration/caching_test.rb
class CachingTest < ActionDispatch::IntegrationTest
  test "caching works in production mode" do
    # Temporarily enable caching
    Rails.cache.clear

    with_caching do
      get posts_path
      assert_response :success

      # Second request should hit cache
      get posts_path
      assert_response :success
    end
  end

  private

  def with_caching
    original = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = true
    yield
  ensure
    ActionController::Base.perform_caching = original
    Rails.cache.clear
  end
end
```
</testing>

<related-skills>
- credentials-management - Managing encrypted secrets
- initializers-best-practices - Application initialization
- solid-stack-setup - SolidQueue, SolidCache, SolidCable configuration
- deployment-railway - Deploying to Railway
- deployment-heroku - Deploying to Heroku
</related-skills>

<resources>
- [Rails Configuration Guide](https://guides.rubyonrails.org/configuring.html)
- [Rails Environment Settings](https://guides.rubyonrails.org/configuring.html#rails-environment-settings)
- [Encrypted Credentials](https://guides.rubyonrails.org/security.html#custom-credentials)
- [Rails 8 Solid Stack](https://fly.io/ruby-dispatch/solid-cache-solid-queue-solid-cable/)
</resources>
