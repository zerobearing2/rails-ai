# Rails Initializers Best Practices
# Reference: Rails Configuration Guide
# Category: CONFIGURATION

# ============================================================================
# What Are Initializers?
# ============================================================================

# Initializers are Ruby files in config/initializers/ that run ONCE during
# application boot. They configure gems, set up constants, and customize Rails.

# Load order: Alphabetically by filename
# Files in config/initializers/ run AFTER config/application.rb and
# config/environments/*.rb

# ============================================================================
# ✅ GOOD: Gem Configuration
# ============================================================================

# config/initializers/solid_cache.rb
Rails.application.config.solid_cache.connects_to = {
  database: { writing: :cache }
}

# config/initializers/solid_queue.rb
Rails.application.config.solid_queue.connects_to = {
  database: { writing: :queue }
}

# config/initializers/action_mailer.rb
Rails.application.configure do
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
end

# ============================================================================
# ✅ GOOD: ViewComponent Configuration
# ============================================================================

# config/initializers/view_component.rb
Rails.application.configure do
  # Configure ViewComponent settings
  config.view_component.default_preview_layout = "component_preview"
  config.view_component.show_previews = Rails.env.development?
  config.view_component.preview_paths << Rails.root.join("test/components/previews")
end

# ============================================================================
# ✅ GOOD: Content Security Policy
# ============================================================================

# config/initializers/content_security_policy.rb
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https

    # Report violations
    policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate nonce for inline scripts
  config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src)
end

# ============================================================================
# ✅ GOOD: Session Store Configuration
# ============================================================================

# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: "_feedback_app_session",
  same_site: :lax,  # CSRF protection
  secure: Rails.env.production?,  # HTTPS only in production
  httponly: true  # Not accessible via JavaScript

# ============================================================================
# ❌ BAD: Referencing Reloadable Constants
# ============================================================================

# NEVER reference app/ code in initializers (it's reloadable)
# config/initializers/bad_example.rb
# ApiGateway.endpoint = "https://example.com"  # ❌ NameError in development!
# User.admin_emails = ["admin@example.com"]    # ❌ Becomes stale on reload!

# ✅ GOOD: Use to_prepare for Reloadable Code
Rails.application.config.to_prepare do
  # This block runs on every code reload in development
  # Safe for referencing app/ code
  ApiGateway.endpoint = Rails.application.credentials.dig(:api_gateway, :endpoint)
end

# ============================================================================
# ✅ GOOD: after_initialize for Post-Boot Setup
# ============================================================================

# config/initializers/post_initialization.rb
Rails.application.config.after_initialize do
  # Runs AFTER all initializers and frameworks are loaded
  # Safe for code that depends on full Rails stack
  ActionView::Base.sanitized_allowed_tags.delete "div"
end

# ============================================================================
# ✅ GOOD: Autoload Configuration
# ============================================================================

# config/initializers/autoload_paths.rb
Rails.application.configure do
  # Add custom autoload paths
  config.autoload_paths << Rails.root.join("lib")

  # Autoload once (doesn't reload in development)
  config.autoload_once_paths << Rails.root.join("app/serializers")
end

# ============================================================================
# ✅ GOOD: Zeitwerk Autoloader Configuration
# ============================================================================

# config/initializers/zeitwerk.rb
Rails.autoloaders.each do |autoloader|
  # Configure inflections for acronyms
  autoloader.inflector.inflect(
    "api" => "API",
    "html" => "HTML",
    "json" => "JSON",
    "xml" => "XML",
    "pdf" => "PDF"
  )
end

# Log autoloading (useful for debugging)
# NOTE: Rails.logger not available in config/application.rb
Rails.autoloaders.logger = Rails.logger if Rails.env.development?

# ============================================================================
# ✅ GOOD: CORS Configuration
# ============================================================================

# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "example.com", "localhost:3000"
    resource "/api/*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end

# ============================================================================
# ✅ GOOD: Custom Console Configuration
# ============================================================================

# config/initializers/console.rb
Rails.application.console do
  # Only runs when rails console is started
  require "pry"
  config.console = Pry

  # Custom prompt
  Pry.config.prompt_name = Rails.application.class.module_parent_name.underscore
end

# ============================================================================
# ✅ GOOD: Bullet (N+1 Query Detection)
# ============================================================================

# config/initializers/bullet.rb
if Rails.env.development?
  Rails.application.config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
end

# ============================================================================
# ✅ GOOD: Custom Mime Types
# ============================================================================

# config/initializers/mime_types.rb
Mime::Type.register "application/vnd.api+json", :jsonapi

# ============================================================================
# ✅ GOOD: Filter Sensitive Parameters
# ============================================================================

# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]

# ============================================================================
# ✅ GOOD: Time Zone and Locale Configuration
# ============================================================================

# config/initializers/time_zone.rb
Rails.application.configure do
  config.time_zone = "Pacific Time (US & Canada)"
  config.active_record.default_timezone = :utc  # Store in UTC
end

# config/initializers/locale.rb
Rails.application.configure do
  config.i18n.default_locale = :en
  config.i18n.available_locales = [:en, :es, :fr]
  config.i18n.fallbacks = [:en]
end

# ============================================================================
# ✅ GOOD: Active Storage Configuration
# ============================================================================

# config/initializers/active_storage.rb
Rails.application.configure do
  # Content types to serve as binary (force download)
  config.active_storage.content_types_to_serve_as_binary += [
    "image/svg+xml",  # SVG can contain JavaScript
    "text/html"       # HTML can contain scripts
  ]

  # Prevent malicious redirects
  config.active_storage.resolve_model_to_route = :rails_storage_proxy
end

# ============================================================================
# ✅ GOOD: Conditional Initialization
# ============================================================================

# config/initializers/redis.rb (if you MUST use Redis for something)
if Rails.env.production?
  # Only configure in production
  REDIS = Redis.new(url: ENV["REDIS_URL"])
end

# config/initializers/development_tools.rb
if Rails.env.development? || Rails.env.test?
  # Development/test-only configuration
  require "pry-rails"
  require "amazing_print"
end

# ============================================================================
# ❌ BAD: Modifying Load Path Too Late
# ============================================================================

# DON'T do this in initializers (too late!)
# $LOAD_PATH.unshift Rails.root.join("lib")  # ❌

# ✅ DO this in config/application.rb instead
# config.autoload_paths << Rails.root.join("lib")

# ============================================================================
# ❌ BAD: Hardcoded Secrets
# ============================================================================

# NEVER hardcode secrets in initializers
# config.stripe_key = "sk_live_abc123"  # ❌ SECURITY VIOLATION

# ✅ ALWAYS use Rails credentials or ENV vars
config.stripe_key = Rails.application.credentials.stripe_key

# Or
config.stripe_key = ENV["STRIPE_SECRET_KEY"]

# ============================================================================
# RULE: Use initializers for gem configuration and app-wide settings
# NEVER: Reference reloadable constants (app/ code) directly
# ALWAYS: Use to_prepare or after_initialize for reloadable code
# SECURITY: Never hardcode secrets, use credentials or ENV vars
# LOCATION: All custom config goes in config/initializers/
# ORDER: Files load alphabetically, use numbered prefixes if order matters
# ============================================================================
