# Environment-Specific Configuration
# Reference: Rails Configuration Guide
# Category: CONFIGURATION

# ============================================================================
# Rails Environments
# ============================================================================

# Standard environments:
# - development (local development)
# - test (automated testing)
# - production (live application)
# - staging (optional, pre-production testing)

# Current environment
Rails.env
Rails.env.development?
Rails.env.test?
Rails.env.production?

# Set environment
ENV["RAILS_ENV"] = "production"
# Or via command: RAILS_ENV=production rails server

# ============================================================================
# Environment Files
# ============================================================================

# config/environments/development.rb
# config/environments/test.rb
# config/environments/production.rb

# Load order:
# 1. config/application.rb (shared config)
# 2. config/environments/#{Rails.env}.rb (environment-specific)
# 3. config/initializers/*.rb (alphabetically)

# ============================================================================
# Development Configuration
# ============================================================================

# config/environments/development.rb
Rails.application.configure do
  # Show full error reports
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.cache_store = :solid_cache_store
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Don't care if mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # Print deprecation notices to Rails logger
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations
  config.active_support.disallowed_deprecation = :raise

  # Highlight code that enqueued background job in logs
  config.active_job.verbose_enqueue_logs = true

  # Raise error on missing translations
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when page load hooks error
  config.action_view.raise_on_missing_translations = true

  # Highlight code that triggered database queries in logs
  config.active_record.verbose_query_logs = true

  # Background jobs: SolidQueue with dedicated database
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Asset debugging
  config.assets.quiet = true

  # Mailer default URL for development
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Open emails in browser instead of sending
  config.action_mailer.delivery_method = :letter_opener

  # Allow all hosts in development
  config.hosts.clear

  # Bullet gem for N+1 query detection
  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
end

# ============================================================================
# Test Configuration
# ============================================================================

# config/environments/test.rb
Rails.application.configure do
  # Eager load code for accurate test coverage
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{1.hour.to_i}" }

  # Show full error reports
  config.consider_all_requests_local = true

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on local disk in temporary directory
  config.active_storage.service = :test

  # Mailer settings
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to stderr
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations
  config.active_support.disallowed_deprecation = :raise

  # Raise on missing translations
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when testing views with missing translations
  config.action_view.raise_on_missing_translations = true

  # Use in-memory cache for tests
  config.cache_store = :null_store

  # Background jobs: Test adapter (runs inline)
  config.active_job.queue_adapter = :test
end

# ============================================================================
# Production Configuration
# ============================================================================

# config/environments/production.rb
Rails.application.configure do
  # Code loading and eager loading
  config.enable_reloading = false
  config.eager_load = true

  # Full error reports available only on standard error output
  config.consider_all_requests_local = false

  # Ensure requests are served from a single host
  config.action_controller.default_url_options = { host: "example.com", protocol: "https" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.asset_host = "https://cdn.example.com"

  # Caching
  config.action_controller.perform_caching = true
  config.cache_store = :solid_cache_store

  # Disable serving static files from `public/`, relying on nginx/Apache
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress CSS using a preprocessor
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.asset_host = "https://assets.example.com"

  # Active Storage
  config.active_storage.service = :amazon

  # Force all access to the app over SSL
  config.force_ssl = true

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags
  config.log_tags = [:request_id]

  # "info" includes generic and useful information about system operation
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Don't log any deprecations
  config.active_support.report_deprecations = false

  # Active Job: SolidQueue with dedicated database
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Do not dump schema after migrations
  config.active_record.dump_schema_after_migration = false

  # Enable locale fallbacks for I18n
  config.i18n.fallbacks = true

  # Don't log any deprecations
  config.active_support.report_deprecations = false

  # Action Mailer
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

  # DNS rebinding protection
  config.hosts = [
    "example.com",
    /.*\.example\.com/  # Allow all subdomains
  ]

  # Rate limiting (Rails 8.1)
  # Set in controller with: rate_limit to: 100, within: 1.minute
end

# ============================================================================
# Staging Environment (Optional)
# ============================================================================

# config/environments/staging.rb
require_relative "production"

Rails.application.configure do
  # Staging-specific overrides

  # Allow test credit cards
  config.x.stripe.publishable_key = Rails.application.credentials.dig(:stripe, :test_publishable_key)

  # Enable letter opener for email preview
  config.action_mailer.delivery_method = :letter_opener_web

  # Less strict CSP for testing
  config.content_security_policy_report_only = true

  # More verbose logging
  config.log_level = :debug
end

# ============================================================================
# Custom Environment Variables
# ============================================================================

# Access in config
ENV["FEATURE_FLAG_NEW_UI"]  # "true" or "false"
ENV.fetch("MAX_UPLOAD_SIZE", 10.megabytes)

# Use in application code
# config/application.rb
config.x.payment_processing.schedule = :daily
config.x.payment_processing.retries = 3
config.x.super_debugger = true

# Access anywhere
Rails.configuration.x.payment_processing.schedule
Rails.configuration.x.super_debugger

# ============================================================================
# Feature Flags
# ============================================================================

# Environment-based feature flags
# config/application.rb
config.x.features.new_editor = Rails.env.development? || ENV["ENABLE_NEW_EDITOR"] == "true"
config.x.features.ai_content_improvement = !Rails.env.test?

# Use in code
if Rails.configuration.x.features.new_editor
  # Show new editor
end

# ============================================================================
# Per-Environment Secrets
# ============================================================================

# Use credentials.yml.enc per environment
Rails.application.credentials.stripe_key
# Looks in: config/credentials/production.yml.enc (if in production)
# Falls back: config/credentials.yml.enc

# Or use ENV vars
config.stripe_key = ENV.fetch("STRIPE_SECRET_KEY") {
  Rails.application.credentials.dig(:stripe, :secret_key)
}

# ============================================================================
# Testing Environment-Specific Behavior
# ============================================================================

# test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "sends welcome email in production" do
    Rails.stub :env, "production".inquiry do
      user = User.create!(email: "test@example.com")
      assert_enqueued_emails 1
    end
  end

  test "skips email in test" do
    user = User.create!(email: "test@example.com")
    assert_enqueued_emails 0
  end
end

# ============================================================================
# RULE: Use environment files for environment-specific configuration
# NEVER: Put production secrets in development.rb or vice versa
# ALWAYS: Use Rails.env checks for environment-specific logic
# PREFER: ENV vars for deployment-specific config (URLs, flags)
# SECURE: Keep production credentials encrypted in credentials.yml.enc
# TEST: Verify behavior across all environments before deploying
# ============================================================================
