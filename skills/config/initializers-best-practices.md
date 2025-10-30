---
name: initializers-best-practices
domain: config
dependencies: []
version: 1.0
rails_version: 8.1+
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

## Gem Configuration

<pattern name="solid-stack-configuration">
<description>Configure Rails 8+ Solid Stack components</description>

**Solid Cache:**
```ruby
# config/initializers/solid_cache.rb
Rails.application.config.solid_cache.connects_to = {
  database: { writing: :cache }
}

# Optional: Configure cache store
Rails.application.configure do
  config.cache_store = :solid_cache_store
end
```

**Solid Queue:**
```ruby
# config/initializers/solid_queue.rb
Rails.application.config.solid_queue.connects_to = {
  database: { writing: :queue }
}

# Configure job processing
Rails.application.configure do
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.silence_polling = true
end
```

**Solid Cable:**
```ruby
# config/initializers/solid_cable.rb
Rails.application.configure do
  config.action_cable.adapter = :solid_cable
end
```
</pattern>

<pattern name="action-mailer-configuration">
<description>Configure email delivery with secure credentials</description>

**SMTP Configuration:**
```ruby
# config/initializers/action_mailer.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = Rails.env.development?

  config.action_mailer.smtp_settings = {
    address: "smtp.sendgrid.net",
    port: 587,
    domain: Rails.application.credentials.dig(:smtp, :domain),
    user_name: Rails.application.credentials.dig(:smtp, :username),
    password: Rails.application.credentials.dig(:smtp, :password),
    authentication: :plain,
    enable_starttls_auto: true
  }

  # Default URL options (required for mailer links)
  config.action_mailer.default_url_options = {
    host: Rails.env.production? ? "example.com" : "localhost:3000",
    protocol: Rails.env.production? ? "https" : "http"
  }
end
```

**Environment-Specific Mailer:**
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
    # Use letter_opener to preview emails in browser
    config.action_mailer.delivery_method = :letter_opener
    config.action_mailer.perform_deliveries = true
  else
    # Test environment - don't send real emails
    config.action_mailer.delivery_method = :test
  end
end
```
</pattern>

<pattern name="viewcomponent-configuration">
<description>Configure ViewComponent for component-driven development</description>

```ruby
# config/initializers/view_component.rb
Rails.application.configure do
  # Preview layout
  config.view_component.default_preview_layout = "component_preview"

  # Enable previews in development
  config.view_component.show_previews = Rails.env.development?

  # Preview paths
  config.view_component.preview_paths << Rails.root.join("test/components/previews")

  # Generate matching test files
  config.view_component.generate.preview = true
  config.view_component.generate.stimulus_controller = false
  config.view_component.generate.locale = false

  # Preview controller (for custom preview routes)
  config.view_component.preview_controller = "ComponentsController"

  # Test framework
  config.view_component.test_controller = "ApplicationController"
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
    # Default: Only load resources from same origin and HTTPS
    policy.default_src :self, :https

    # Font sources
    policy.font_src :self, :https, :data

    # Images
    policy.img_src :self, :https, :data, "https://cdn.example.com"

    # Prevent embedding in iframes
    policy.frame_ancestors :none

    # Block objects (Flash, Java, etc.)
    policy.object_src :none

    # Scripts - only from self and trusted CDNs
    policy.script_src :self, :https, "https://cdn.jsdelivr.net"

    # Styles
    policy.style_src :self, :https

    # Form submissions
    policy.form_action :self

    # Report violations to this endpoint
    policy.report_uri "/csp-violation-report"
  end

  # Generate nonces for inline scripts (when absolutely necessary)
  config.content_security_policy_nonce_generator = ->(request) {
    SecureRandom.base64(16)
  }

  # Apply nonces to these directives
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing (testing phase)
  # config.content_security_policy_report_only = true
end
```

**Development vs Production:**
```ruby
# config/initializers/content_security_policy.rb
Rails.application.configure do
  config.content_security_policy do |policy|
    if Rails.env.development?
      # Relaxed CSP for development (hot reloading, etc.)
      policy.default_src :self, :https, :unsafe_eval, :unsafe_inline, "ws://localhost:*"
      policy.connect_src :self, :https, "http://localhost:*", "ws://localhost:*"
    else
      # Strict CSP for production
      policy.default_src :self, :https
      policy.connect_src :self, :https
    end

    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https
  end
end
```
</pattern>

<pattern name="cors-configuration">
<description>Configure Cross-Origin Resource Sharing for API endpoints</description>

```ruby
# config/initializers/cors.rb
# Requires: gem "rack-cors"

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Allow requests from specific origins
  allow do
    origins "example.com",
            "www.example.com",
            /\Ahttps:\/\/.*\.example\.com\z/  # Subdomains

    resource "/api/*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      max_age: 86400  # Cache preflight for 24 hours
  end

  # Development: Allow localhost
  if Rails.env.development?
    allow do
      origins "localhost:3000", "127.0.0.1:3000"
      resource "*",
        headers: :any,
        methods: :any,
        credentials: true
    end
  end
end
```

**Public API (No Credentials):**
```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"  # Any origin

    resource "/api/public/*",
      headers: :any,
      methods: [:get, :options, :head],
      credentials: false  # No cookies/auth
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
  same_site: :lax,               # CSRF protection (can use :strict for higher security)
  secure: Rails.env.production?, # HTTPS only in production
  httponly: true,                # Not accessible via JavaScript
  expire_after: 2.weeks          # Session timeout

# Alternative: Database sessions (more secure, scalable)
# Rails.application.config.session_store :active_record_store,
#   key: "_myapp_session",
#   secure: Rails.env.production?,
#   httponly: true,
#   same_site: :lax
```
</pattern>

<pattern name="parameter-filtering">
<description>Filter sensitive parameters from logs</description>

```ruby
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [
  # Passwords
  :passw, :password, :password_confirmation,

  # Authentication
  :secret, :token, :api_key, :access_token, :refresh_token,
  :_key, :apikey, :auth,

  # Personal information
  :email, :ssn, :social_security_number,

  # Security
  :crypt, :salt, :certificate, :otp, :private_key,

  # Payment
  :cvv, :cvc, :card_number, :account_number
]

# Custom filter for credit cards (partial masking)
Rails.application.config.filter_parameters << lambda do |key, value|
  if key.to_s.match?(/card.*number/i) && value.is_a?(String)
    value.gsub(/.(?=.{4})/, "*")  # Show last 4 digits
  end
end
```
</pattern>

## Framework Customization

<pattern name="zeitwerk-autoloader">
<description>Configure Zeitwerk autoloader and inflections</description>

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.each do |autoloader|
  # Configure inflections for acronyms
  autoloader.inflector.inflect(
    "api" => "API",
    "html" => "HTML",
    "json" => "JSON",
    "xml" => "XML",
    "pdf" => "PDF",
    "csv" => "CSV",
    "url" => "URL",
    "oauth" => "OAuth"
  )

  # Ignore specific files/directories
  autoloader.ignore(
    Rails.root.join("app/services/legacy"),
    Rails.root.join("app/models/concerns/deprecated.rb")
  )

  # Custom inflection for irregular names
  autoloader.inflector.inflect(
    "html_to_pdf" => "HTMLToPDF",
    "csv_importer" => "CSVImporter"
  )
end

# Enable autoloading logging in development (debugging)
if Rails.env.development?
  Rails.autoloaders.logger = Rails.logger
  Rails.autoloaders.log!
end
```
</pattern>

<pattern name="active-storage-configuration">
<description>Configure Active Storage for secure file handling</description>

```ruby
# config/initializers/active_storage.rb
Rails.application.configure do
  # Content types to serve as binary (force download, not inline)
  config.active_storage.content_types_to_serve_as_binary += [
    "image/svg+xml",  # SVG can contain JavaScript
    "text/html",      # HTML can contain scripts
    "text/javascript",
    "application/javascript"
  ]

  # Prevent malicious redirects
  config.active_storage.resolve_model_to_route = :rails_storage_proxy

  # Allowed content types (blocklist everything else)
  config.active_storage.content_types_allowed_inline = [
    "image/png",
    "image/jpeg",
    "image/gif",
    "image/webp",
    "application/pdf"
  ]

  # Video preview settings
  config.active_storage.video_preview_arguments =
    "-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015),loop=loop=-1:size=2,trim=start_frame=1' -frames:v 1 -f image2"

  # Variant processor
  config.active_storage.variant_processor = :vips  # Faster than mini_magick

  # Previewers
  config.active_storage.previewers = [
    ActiveStorage::Previewer::PopplerPDFPreviewer,
    ActiveStorage::Previewer::MuPDFPreviewer,
    ActiveStorage::Previewer::VideoPreviewer
  ]
end
```
</pattern>

<pattern name="custom-mime-types">
<description>Register custom MIME types for specialized responses</description>

```ruby
# config/initializers/mime_types.rb
# JSON:API format
Mime::Type.register "application/vnd.api+json", :jsonapi

# Excel formats
Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
Mime::Type.register "application/vnd.ms-excel", :xls

# Custom formats
Mime::Type.register "text/calendar", :ics
Mime::Type.register "application/vnd.myapp.custom+json", :custom_json
```

**Usage in Controller:**
```ruby
# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.jsonapi { render jsonapi: @user }  # Uses registered MIME type
      format.json { render json: @user }
    end
  end
end
```
</pattern>

<pattern name="time-zone-and-locale">
<description>Configure time zones and internationalization</description>

```ruby
# config/initializers/time_zone.rb
Rails.application.configure do
  # Application time zone (for display)
  config.time_zone = "Pacific Time (US & Canada)"

  # Database time zone (ALWAYS use UTC)
  config.active_record.default_timezone = :utc

  # Raise on assignment to attributes in different time zones
  config.active_record.time_zone_aware_attributes = true
end

# config/initializers/locale.rb
Rails.application.configure do
  # Default locale
  config.i18n.default_locale = :en

  # Available locales
  config.i18n.available_locales = [:en, :es, :fr, :de]

  # Fallback chain
  config.i18n.fallbacks = [:en]

  # Load path for custom locales
  config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]

  # Raise errors for missing translations in development
  config.i18n.raise_on_missing_translations = Rails.env.development?
end
```
</pattern>

## Reloadable Code Patterns

<pattern name="to-prepare-callback">
<description>Use to_prepare for code that references app/ classes</description>

**Problem - Direct Reference:**
```ruby
# ❌ BAD - Initializers run before app/ code loads
# config/initializers/bad_example.rb
ApiGateway.endpoint = "https://api.example.com"  # NameError!
User.admin_email = "admin@example.com"           # Breaks on reload!
```

**Solution - Use to_prepare:**
```ruby
# ✅ GOOD - Runs on every code reload in development
# config/initializers/api_gateway.rb
Rails.application.config.to_prepare do
  # This block executes:
  # - Once in production (after boot)
  # - On every code reload in development
  # Safe for referencing models, controllers, etc.

  ApiGateway.endpoint = Rails.application.credentials.dig(:api_gateway, :endpoint)
  ApiGateway.timeout = 30

  # Can reference app/ code safely
  User.admin_email = Rails.application.credentials.admin_email
  OrderProcessor.configure do |config|
    config.payment_gateway = PaymentGateway.new
  end
end
```

**When to Use to_prepare:**
- Configuring classes in `app/` directory
- Setting up constants that reference models/controllers
- Registering callbacks on app classes
- Initializing services that depend on app code
</pattern>

<pattern name="after-initialize-callback">
<description>Use after_initialize for post-boot setup</description>

```ruby
# config/initializers/post_initialization.rb
Rails.application.config.after_initialize do
  # Runs AFTER all initializers and frameworks are loaded
  # Use for setup that depends on full Rails stack

  # Modify framework defaults
  ActionView::Base.sanitized_allowed_tags.delete "div"
  ActionView::Base.sanitized_allowed_attributes.delete "style"

  # Register custom validators (depends on ActiveModel being loaded)
  ActiveModel::Validations.register_validator(:custom_email, CustomEmailValidator)

  # Configure third-party gem that needs Rails fully loaded
  Paperclip.configure do |config|
    config.use_rails_storage = true
  end
end
```

**Boot Sequence:**
```ruby
# 1. config/application.rb
# 2. config/environments/*.rb
# 3. Gems are loaded
# 4. config/initializers/*.rb (alphabetically)
# 5. after_initialize callbacks ← We are here
# 6. Application ready to serve requests
```
</pattern>

## Development Tools

<pattern name="bullet-n-plus-one-detection">
<description>Configure Bullet gem to detect N+1 queries</description>

```ruby
# config/initializers/bullet.rb
if Rails.env.development?
  Rails.application.config.after_initialize do
    Bullet.enable = true

    # Notification methods
    Bullet.alert = true           # JavaScript alert
    Bullet.bullet_logger = true   # Log to bullet.log
    Bullet.console = true          # Output to browser console
    Bullet.rails_logger = true     # Output to Rails log
    Bullet.add_footer = true       # Add footer to page with details

    # Slack notifications (optional)
    # Bullet.slack = {
    #   webhook_url: Rails.application.credentials.dig(:slack, :webhook_url),
    #   channel: "#development"
    # }

    # Configure which ActiveRecord associations to watch
    Bullet.raise = false  # Don't raise exceptions, just notify
  end
end
```
</pattern>

<pattern name="console-configuration">
<description>Customize Rails console behavior</description>

```ruby
# config/initializers/console.rb
Rails.application.console do
  # Only runs when rails console is started

  # Use Pry instead of IRB
  require "pry"
  config.console = Pry

  # Custom prompt showing app name and environment
  Pry.config.prompt_name = "#{Rails.application.class.module_parent_name}[#{Rails.env}]"

  # Load helper modules
  require "amazing_print"
  AmazingPrint.pry!

  # Custom helpers
  module ConsoleHelpers
    def reload!
      puts "Reloading..."
      ActionDispatch::Reloader.reload!
    end

    def current_user(id = 1)
      User.find(id)
    end
  end

  Rails::ConsoleMethods.include ConsoleHelpers

  # Welcome message
  puts "Rails #{Rails.version} console for #{Rails.env} environment"
  puts "Type 'reload!' to reload code"
end
```
</pattern>

<pattern name="generators-configuration">
<description>Configure Rails generators for your workflow</description>

```ruby
# config/initializers/generators.rb
Rails.application.config.generators do |g|
  # Test framework
  g.test_framework :minitest, fixture: true

  # Don't generate these files
  g.helper false
  g.assets false
  g.stylesheets false
  g.javascripts false

  # Use specific template engine
  g.template_engine :erb  # or :slim, :haml

  # Factory Bot instead of fixtures
  g.fixture_replacement :factory_bot, dir: "test/factories"

  # ViewComponent configuration
  g.view_component true
  g.view_component_path "app/components"

  # System tests
  g.system_tests "test/system"
end
```
</pattern>

## Environment-Specific Configuration

<pattern name="conditional-initialization">
<description>Configure features based on Rails environment</description>

```ruby
# config/initializers/environment_specific.rb

# Production-only configuration
if Rails.env.production?
  # Force SSL
  Rails.application.config.force_ssl = true

  # Configure external services
  STRIPE_KEY = Rails.application.credentials.dig(:stripe, :live_key)

  # Production Redis (if needed)
  REDIS = Redis.new(
    url: Rails.application.credentials.redis_url,
    reconnect_attempts: 3
  )
end

# Development and Test
if Rails.env.development? || Rails.env.test?
  # Load development tools
  require "pry-rails"
  require "amazing_print"

  # Test Stripe key
  STRIPE_KEY = Rails.application.credentials.dig(:stripe, :test_key)

  # Verbose query logging
  ActiveRecord::Base.logger = Logger.new(STDOUT) if Rails.env.development?
end

# Development-only
if Rails.env.development?
  # Rack Mini Profiler
  require "rack-mini-profiler"
  Rack::MiniProfiler.config.position = "bottom-right"

  # Annotate models
  Rails.application.config.after_initialize do
    if defined?(AnnotateModels)
      AnnotateModels.do_annotations
    end
  end
end

# Test-only
if Rails.env.test?
  # Faster tests
  Rails.application.config.action_mailer.delivery_method = :test
  Rails.application.config.active_job.queue_adapter = :test
end
```
</pattern>

<pattern name="feature-flags-initialization">
<description>Initialize feature flag system</description>

```ruby
# config/initializers/flipper.rb
require "flipper"
require "flipper/adapters/active_record"

Rails.application.config.to_prepare do
  Flipper.configure do |config|
    # Use database adapter
    config.adapter { Flipper::Adapters::ActiveRecord.new }

    # Default features (can be toggled later)
    config.default do
      {
        new_dashboard: false,
        beta_api: false,
        advanced_search: true
      }
    end
  end
end

# Helper method for controllers/views
module FlipperHelper
  def feature_enabled?(feature_name)
    Flipper.enabled?(feature_name, current_user)
  end
end

ActionController::Base.include FlipperHelper
ActionView::Base.include FlipperHelper
```
</pattern>

<antipatterns>
<antipattern>
<description>Referencing reloadable constants directly in initializers</description>
<reason>App code (models, controllers) isn't loaded when initializers run, and becomes stale on reload in development</reason>
<bad-example>
```ruby
# ❌ BAD - config/initializers/bad_constants.rb
# This will fail or become stale
ApiGateway.endpoint = "https://api.example.com"  # NameError!
User.admin_emails = ["admin@example.com"]        # Stale on reload!
OrderProcessor.timeout = 30                      # Doesn't work!
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use to_prepare for reloadable code
# config/initializers/api_gateway.rb
Rails.application.config.to_prepare do
  # This runs on every code reload in development
  ApiGateway.endpoint = Rails.application.credentials.dig(:api_gateway, :endpoint)
  User.admin_emails = ["admin@example.com"]
  OrderProcessor.timeout = 30
end
```
</good-example>
</antipattern>

<antipattern>
<description>Hardcoding secrets in initializers</description>
<reason>Security violation - secrets exposed in version control</reason>
<bad-example>
```ruby
# ❌ CRITICAL SECURITY VIOLATION
# config/initializers/stripe.rb
Stripe.api_key = "sk_live_abc123def456ghi789"  # NEVER DO THIS!

# config/initializers/aws.rb
Aws.config.update({
  credentials: Aws::Credentials.new(
    "AKIAIOSFODNN7EXAMPLE",  # Exposed in git!
    "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"  # Security breach!
  )
})
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use encrypted credentials
# config/initializers/stripe.rb
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

# config/initializers/aws.rb
Aws.config.update({
  credentials: Aws::Credentials.new(
    Rails.application.credentials.dig(:aws, :access_key_id),
    Rails.application.credentials.dig(:aws, :secret_access_key)
  ),
  region: "us-east-1"
})

# Or use environment variables
Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
```
</good-example>
</antipattern>

<antipattern>
<description>Modifying load paths in initializers</description>
<reason>Too late in boot process - files already loaded</reason>
<bad-example>
```ruby
# ❌ BAD - config/initializers/load_paths.rb
# Too late - autoloading already configured!
$LOAD_PATH.unshift Rails.root.join("lib")
config.autoload_paths << Rails.root.join("app/services")
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Configure in config/application.rb
# config/application.rb
module MyApp
  class Application < Rails::Application
    # Load paths configured BEFORE initializers run
    config.autoload_paths << Rails.root.join("lib")
    config.autoload_paths << Rails.root.join("app/services")
    config.eager_load_paths << Rails.root.join("lib")
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Complex business logic in initializers</description>
<reason>Initializers should configure, not perform operations</reason>
<bad-example>
```ruby
# ❌ BAD - config/initializers/data_migration.rb
# Don't run migrations or seeding in initializers!
if User.count.zero?
  User.create!(
    email: "admin@example.com",
    password: "temporary123",
    role: :admin
  )
end

# Don't perform HTTP requests at boot
response = HTTParty.get("https://api.example.com/config")
CONFIG_DATA = JSON.parse(response.body)
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use rake tasks for one-time operations
# lib/tasks/setup.rake
namespace :setup do
  desc "Create default admin user"
  task admin: :environment do
    User.create!(
      email: "admin@example.com",
      password: SecureRandom.hex(16),
      role: :admin
    ) if User.count.zero?
  end
end

# ✅ GOOD - Cache external config, refresh as needed
# config/initializers/external_config.rb
Rails.application.config.to_prepare do
  ExternalConfig.refresh_if_stale  # Only fetch when needed
end
```
</good-example>
</antipattern>

<antipattern>
<description>Environment checks without fallbacks</description>
<reason>Breaks in unknown environments (staging, CI, etc.)</reason>
<bad-example>
```ruby
# ❌ BAD - Only handles production and development
# config/initializers/redis.rb
if Rails.env.production?
  REDIS = Redis.new(url: ENV["REDIS_URL"])
elsif Rails.env.development?
  REDIS = Redis.new(url: "redis://localhost:6379/0")
end
# Test and staging environments will crash with uninitialized constant REDIS!
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Handle all environments with sensible defaults
# config/initializers/redis.rb
redis_url = if Rails.env.production?
  ENV.fetch("REDIS_URL")
elsif Rails.env.development?
  "redis://localhost:6379/0"
elsif Rails.env.test?
  "redis://localhost:6379/1"  # Separate DB for tests
else
  # Staging, CI, or other environments
  ENV.fetch("REDIS_URL", "redis://localhost:6379/2")
end

REDIS = Redis.new(url: redis_url)
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test initializer behavior and configuration:

```ruby
# test/initializers/session_store_test.rb
require "test_helper"

class SessionStoreTest < ActiveSupport::TestCase
  test "session store is configured as cookie store" do
    assert_equal :cookie_store, Rails.application.config.session_store
  end

  test "session cookie is httponly" do
    options = Rails.application.config.session_options
    assert options[:httponly], "Session cookie should be httponly"
  end

  test "session cookie is secure in production" do
    # Mock production environment
    Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
      # Reload initializer
      load Rails.root.join("config/initializers/session_store.rb")

      options = Rails.application.config.session_options
      assert options[:secure], "Session cookie should be secure in production"
    end
  end
end

# test/initializers/content_security_policy_test.rb
require "test_helper"

class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "CSP header is set on responses" do
    get root_path

    assert_response :success
    assert_match /default-src/, response.headers["Content-Security-Policy"]
  end

  test "CSP blocks inline scripts" do
    get root_path

    csp = response.headers["Content-Security-Policy"]
    refute_match /unsafe-inline/, csp, "CSP should not allow unsafe-inline scripts"
  end

  test "CSP nonce is generated" do
    get root_path

    csp = response.headers["Content-Security-Policy"]
    assert_match /nonce-/, csp, "CSP should include nonce for inline scripts"
  end
end

# test/initializers/cors_test.rb
require "test_helper"

class CorsTest < ActionDispatch::IntegrationTest
  test "CORS headers allow configured origins" do
    get "/api/users", headers: { "Origin" => "https://example.com" }

    assert_equal "https://example.com", response.headers["Access-Control-Allow-Origin"]
    assert_equal "true", response.headers["Access-Control-Allow-Credentials"]
  end

  test "CORS headers reject unauthorized origins" do
    get "/api/users", headers: { "Origin" => "https://malicious.com" }

    assert_nil response.headers["Access-Control-Allow-Origin"]
  end

  test "CORS preflight handles OPTIONS request" do
    options "/api/users", headers: {
      "Origin" => "https://example.com",
      "Access-Control-Request-Method" => "POST"
    }

    assert_response :success
    assert_equal "https://example.com", response.headers["Access-Control-Allow-Origin"]
    assert_match /POST/, response.headers["Access-Control-Allow-Methods"]
  end
end

# test/initializers/filter_parameters_test.rb
require "test_helper"

class FilterParametersTest < ActiveSupport::TestCase
  test "passwords are filtered from logs" do
    params = ActionController::Parameters.new(
      email: "user@example.com",
      password: "secret123"
    )

    filtered = params.to_s

    assert_includes filtered, "email"
    refute_includes filtered, "secret123", "Password should be filtered"
    assert_includes filtered, "[FILTERED]"
  end

  test "credit card numbers are masked" do
    params = ActionController::Parameters.new(
      card_number: "4111111111111111"
    )

    filtered = params.to_s

    refute_includes filtered, "4111111111111111", "Card number should be filtered"
  end
end

# test/initializers/zeitwerk_test.rb
require "test_helper"

class ZeitwerkTest < ActiveSupport::TestCase
  test "API acronym is inflected correctly" do
    # Zeitwerk should load Api:: namespaced classes correctly
    assert_nothing_raised do
      Api::V1::UsersController
    end
  end

  test "custom inflections work" do
    inflector = Rails.autoloaders.main.inflector

    assert_equal "API", inflector.camelize("api", nil)
    assert_equal "JSON", inflector.camelize("json", nil)
    assert_equal "OAuth", inflector.camelize("oauth", nil)
  end
end
```

**Testing Initializer Load Order:**
```ruby
# test/initializers/load_order_test.rb
require "test_helper"

class LoadOrderTest < ActiveSupport::TestCase
  test "initializers load in alphabetical order" do
    # Check that constants are defined in expected order
    assert defined?(REDIS), "Redis should be initialized first (00_redis.rb)"
    assert defined?(Sidekiq), "Sidekiq should be initialized after Redis"
  end

  test "to_prepare callbacks can reference app code" do
    # This would fail if not using to_prepare
    assert_nothing_raised do
      User.admin_email
    end
  end
end
```
</testing>

<related-skills>
- credentials-management - Secure credential storage
- environment-configuration - Environment-specific settings
- solid-stack-setup - Rails 8+ Solid components
- security-csrf - CSRF protection configuration
- security-xss - XSS prevention and CSP
</related-skills>

<resources>
- [Rails Configuration Guide](https://guides.rubyonrails.org/configuring.html)
- [Rails Initialization Process](https://guides.rubyonrails.org/initialization.html)
- [Zeitwerk Autoloader](https://github.com/fxn/zeitwerk)
- [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [Rack::Cors Documentation](https://github.com/cyu/rack-cors)
</resources>
