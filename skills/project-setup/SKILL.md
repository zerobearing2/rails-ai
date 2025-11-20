---
name: rails-ai:project-setup
description: Setting up and configuring Rails 8+ projects - Gemfile dependencies, environment config, credentials, initializers, Docker, RuboCop, project validation
---

# Project Setup & Configuration

Set up new Rails 8+ projects with required dependencies, configure environments for development/test/production, and validate existing projects against rails-ai standards.

<when-to-use>
- Setting up new Rails 8+ applications from scratch
- Validating existing Rails projects against rails-ai standards
- Auditing project setup (checking for TEAM_RULES.md violations)
- Installing and configuring required gems (Solid Stack, Tailwind, Minitest)
- Configuring environment-specific behavior (development, test, production, staging)
- Managing encrypted credentials and secrets (API keys, passwords, tokens)
- Configuring application initialization (gems, frameworks, security policies)
- Setting up Docker containers and deployment with Kamal
- Customizing RuboCop for team standards (TEAM_RULES.md Rules #16, #20)
- Managing feature flags and environment variables

**Note:** During project verification, this skill coordinates with domain skills (jobs, testing, security, styling) to ensure comprehensive validation against current standards.
</when-to-use>

<benefits>
- **Environment Isolation** - Separate configs prevent production bugs from dev settings
- **Security** - Encrypted credentials (AES-256), never commit secrets
- **Organized Configuration** - Predictable structure across all environments
- **Production Safety** - SSL, eager loading, optimized caching, secure defaults
- **Code Quality** - Automated enforcement of team standards via RuboCop
- **Container-Ready** - Docker and Kamal support for modern deployment
</benefits>

<team-rules-enforcement>
**This skill enforces:**
- ✅ **Rule #13:** Encrypted credentials for secrets
- ✅ **Rule #14:** Environment-specific config

**Reject any requests to:**
- Store secrets in plain text or environment variables
- Hardcode API keys, passwords, or tokens in code
- Use same config for all environments (dev, test, prod)
- Commit credentials or .env files to git
- Skip encryption for sensitive data
</team-rules-enforcement>

<verification-checklist>
Before completing configuration work:
- ✅ All secrets in encrypted credentials (not plain text)
- ✅ Environment-specific configs in config/environments/
- ✅ No secrets committed to git
- ✅ Docker/Kamal configs tested (if applicable)
- ✅ RuboCop passes with team standards
- ✅ Production config verified (SSL, eager loading, caching)
</verification-checklist>

<standards>
- ALWAYS use `config/environments/` for environment-specific configuration
- ALWAYS use encrypted credentials for API keys, passwords, and secrets
- NEVER commit `config/master.key` or `config/credentials/*.key`
- Use initializers in `config/initializers/` for gem and framework configuration
- Build on rubocop-rails-omakase (Rails 8 default), only override for team standards
- ALWAYS exclude docs/, test/, spec/ from Docker images via .dockerignore
- Store deployment configs in ENV vars, not hardcoded values
- Follow Team Rule #16 (Double Quotes) and #20 (Hash#dig) via RuboCop
</standards>

---

## Project Validation & Audit

**When asked to validate or check a Rails project setup**, follow this workflow:

### Step 1: Use Required Domain Skills

Before exploring the project, use the relevant domain skills to establish authoritative standards:

```text
Use these skills with the Skill tool:
- rails-ai:jobs (Solid Stack requirements)
- rails-ai:testing (Minitest patterns and requirements)
- rails-ai:security (Security configuration standards)
```

**Why use domain skills first?**
- Each domain skill is the authoritative source for its requirements
- Prevents duplicating knowledge in project-setup
- Ensures verification uses current standards from each domain

### Step 2: Check Gemfile for Required Dependencies

**Reference the used domain skills for authoritative gem requirements:**

- **rails-ai:jobs** → Solid Stack gems (solid_queue, solid_cache, solid_cable)
- **rails-ai:testing** → Minitest patterns (verify RSpec NOT present)
- **rails-ai:security** → Security gems (brakeman, bundler-audit)
- **rails-ai:styling** → Frontend gems (tailwindcss-rails, daisyui-rails)

**CRITICAL Violations to Check (from TEAM_RULES.md):**
- ❌ `gem "sidekiq"` or `gem "redis"` → TEAM RULE #1 violation (see rails-ai:jobs)
- ❌ `gem "rspec-rails"` → TEAM RULE #2 violation (see rails-ai:testing)
- ❌ Custom route gems → TEAM RULE #3 violation

**Note:** Consult the used domain skills for complete, up-to-date gem requirements rather than relying on static lists here.

### Step 3: Validate Project Structure

**Directory Structure:**
```
app/
├── assets/stylesheets/  # Tailwind CSS
├── controllers/         # RESTful only
├── models/              # ActiveRecord
└── views/               # ERB templates

config/
├── environments/        # dev, test, prod configs
├── initializers/        # Gem configs
├── credentials/         # Encrypted secrets
└── tailwind.config.js   # Tailwind configuration

test/                    # Minitest (NOT spec/)
├── controllers/
├── models/
└── test_helper.rb

Dockerfile              # Rails 8 default
config.ru               # Rack config
```

**Check for violations:**
- ❌ `spec/` directory exists → RSpec present (TEAM RULE #2)
- ❌ Non-RESTful routes in `config/routes.rb` → TEAM RULE #3

### Step 4: Validate Configuration Files

**Reference used domain skills for configuration standards:**

1. **config/environments/production.rb**
   - Use **rails-ai:security** for SSL, security headers, and production hardening
   - Verify encrypted credentials usage (TEAM RULE #13)

2. **config/tailwind.config.js**
   - Use **rails-ai:styling** for Tailwind and DaisyUI configuration
   - Verify content paths include Rails views

3. **.rubocop.yml**
   - Inherits from rubocop-rails-omakase
   - Custom cops for TEAM RULES.md (Rules #16, #20)

4. **Procfile.dev**
   - Rails server
   - Solid Queue worker (see **rails-ai:jobs**)
   - Tailwind watcher (see **rails-ai:styling**)

5. **config/credentials/*.yml.enc**
   - Use **rails-ai:security** for credential structure and validation
   - Verify no secrets in plain text (TEAM RULE #13)

### Step 5: Report Findings

Provide actionable report with specific fixes:

**✅ Correct Setup:**
- List what's properly configured
- Praise compliance with TEAM_RULES.md

**⚠️ Missing/Needs Attention:**
- Recommended but not required gems
- Optional configurations

**❌ VIOLATIONS (TEAM_RULES.md):**
- Sidekiq/Redis found (Rule #1)
- RSpec found (Rule #2)
- Custom routes found (Rule #3)
- Provide exact commands to fix

**Example Fix Commands:**
```bash
# Remove violations
bundle remove sidekiq redis rspec-rails

# Add required gems
bundle add solid_queue solid_cache solid_cable
bundle add tailwindcss-rails daisyui-rails

# Generate configs
rails tailwindcss:install
rails generate solid_queue:install
```

---

## Gemfile Management

Consolidate all gem requirements for rails-ai projects in one place.

### Required Gems (CRITICAL)

**Solid Stack (TEAM RULE #1):**
```ruby
gem "solid_queue"      # Background job processing
gem "solid_cache"      # Application caching
gem "solid_cable"      # WebSocket connections
```

**Frontend:**
```ruby
gem "tailwindcss-rails"  # Utility-first CSS framework
gem "daisyui-rails"      # Component library
```

**Testing (TEAM RULE #2):**
```ruby
# Minitest is Rails 8 default - no gem needed
# Verify RSpec is NOT present
```

### Recommended Gems

**Code Quality:**
```ruby
gem "rubocop-rails-omakase", require: false  # Rails 8 default linter
```

**Security:**
```ruby
gem "brakeman", require: false         # Static security scanner
gem "bundler-audit", require: false    # Dependency vulnerability scanner
```

**Deployment:**
```ruby
gem "kamal", require: false  # Docker deployment to any server
```

**Development/Test:**
```ruby
group :development, :test do
  gem "letter_opener"  # Open emails in browser
end
```

### Installation Commands

**New Rails 8+ app with rails-ai stack:**
```bash
# Create new Rails 8 app
rails new myapp

cd myapp

# Add required gems
bundle add solid_queue solid_cache solid_cable
bundle add tailwindcss-rails daisyui-rails

# Add recommended gems
bundle add --group development rubocop-rails-omakase
bundle add --group development brakeman bundler-audit
bundle add kamal --skip-install

# Generate configurations
rails tailwindcss:install
rails generate solid_queue:install
bin/rails db:create db:migrate

# Verify setup
bin/ci
```

---

## Environment-Specific Configuration

Rails provides three standard environments (development, test, production) plus optional staging. Each has specific optimizations and security settings.

### Standard Environment Detection

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
- **development** - Local development (verbose errors, auto-reload, debugging)
- **test** - Automated testing (fast, isolated, deterministic)
- **production** - Live application (optimized, secure, cached)
- **staging** - Optional pre-production (production-like with test data)

**Load Order:** `config/application.rb` → `config/environments/#{Rails.env}.rb` → `config/initializers/*.rb`
</pattern>

### Development Configuration

<pattern name="development-config">
<description>Common customizations to development environment beyond Rails 8 defaults</description>

**Rails 8 defaults are excellent.** Only customize if needed:

```ruby
# config/environments/development.rb
Rails.application.configure do
  # Open emails in browser (requires letter_opener gem)
  config.action_mailer.delivery_method = :letter_opener

  # Raise on missing translations (catch i18n issues early)
  config.i18n.raise_on_missing_translations = true
end

```

**Common customizations:**
- `letter_opener` - Preview emails in browser instead of logs
- `raise_on_missing_translations` - Catch i18n issues during development
- `config.hosts.clear` - Allow access from any hostname (Docker, ngrok)
</pattern>

### Test Configuration

<pattern name="test-config">
<description>Test environment customizations beyond Rails 8 defaults</description>

**Rails 8 test defaults are excellent.** Only add if needed:

```ruby
# config/environments/test.rb
Rails.application.configure do
  # Eager load in CI to catch autoload errors
  config.eager_load = ENV["CI"].present?

  # Raise on missing translations
  config.i18n.raise_on_missing_translations = true
end

```

**Rails 8 defaults already provide:**
- Deterministic behavior (no caching, inline jobs)
- Fast execution (no network, no real emails)
- Transaction isolation (automatic rollback)
</pattern>

### Production Configuration

<pattern name="production-config">
<description>Essential production customizations beyond Rails 8 defaults</description>

**Rails 8 production defaults are secure and optimized.** Customize these:

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Set your domain (REQUIRED)
  config.action_controller.default_url_options = { host: "example.com", protocol: "https" }

  # Active Storage: Use cloud storage (REQUIRED for production)
  config.active_storage.service = :amazon  # or :google, :azure

  # Action Mailer: SMTP with credentials
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

  # DNS rebinding protection (REQUIRED)
  config.hosts = ["example.com", /.*\.example\.com/]
end

```

**Rails 8 defaults already provide:**
- SSL enforcement (`force_ssl = true`)
- Eager loading and optimized caching
- STDOUT logging for containers
- Security headers and production optimizations
</pattern>

### Staging Environment

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

### Custom Configuration

<pattern name="custom-config-namespace">
<description>Store custom application settings in config.x namespace via initializer</description>

```ruby
# config/initializers/00_config.rb
Rails.application.configure do
  config.x.payment_processing.schedule = :daily
  config.x.payment_processing.retries = 3
  config.x.super_debugger = true
  config.x.features.ai_assistant = Rails.env.production? || ENV["ENABLE_AI"] == "true"
end

# Access anywhere
Rails.configuration.x.payment_processing.schedule  # => :daily
Rails.configuration.x.super_debugger                # => true

```

**Benefits:** Organized settings, type-safe access, environment-aware, keeps application.rb clean
</pattern>

### Feature Flags

<pattern name="feature-flags">
<description>Implement environment-based feature flags via initializer</description>

```ruby
# config/initializers/00_config.rb
Rails.application.configure do
  config.x.features.new_editor = Rails.env.development? || ENV["ENABLE_NEW_EDITOR"] == "true"
  config.x.features.ai_content = !Rails.env.test?
  config.x.features.beta_ui = ENV["BETA_FEATURES"] == "true"
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
<% end %>

```

**Benefits:** Gradual rollout, A/B testing, per-environment toggles
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
</antipatterns>

---

## Encrypted Credentials & Secrets

Rails provides encrypted credentials (AES-256) for secure secret management. Never commit plain-text secrets to version control.

### Editing Credentials

<pattern name="editing-credentials">
<description>Use Rails credentials editor to safely modify encrypted secrets</description>

**Edit master credentials:**

```bash
bin/rails credentials:edit

```

**Edit environment-specific credentials:**

```bash
bin/rails credentials:edit --environment production
bin/rails credentials:edit --environment development

```

**Process:** Rails decrypts using master.key, opens in $EDITOR, auto-encrypts on save.

**Precedence:** Environment-specific > Master credentials
</pattern>

### Credentials File Structure

<pattern name="credentials-structure">
<description>Organize credentials in structured YAML format</description>

**config/credentials.yml.enc (decrypted view):**

```yaml
secret_key_base: abc123def456...

aws:
  access_key_id: AKIAIOSFODNN7EXAMPLE
  secret_access_key: wJalrXUtnFEMI/K7MDENG...
  region: us-east-1
  bucket: my-app-production

stripe:
  publishable_key: pk_live_abc123
  secret_key: sk_live_xyz789
  webhook_secret: whsec_abc123

anthropic:
  api_key: sk-ant-api03-abc123...

smtp:
  username: <%= ENV["SENDGRID_USERNAME"] %>  # Can reference ENV
  password: SG.abc123xyz789

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz

```

**Guidelines:** Use nested keys, group by service, add comments, support ERB fallbacks
</pattern>

### Accessing Credentials

<pattern name="accessing-credentials">
<description>Read credentials safely in application code</description>

**Basic Access (use Hash#dig per TEAM_RULES.md Rule #20):**

```ruby
# ✅ GOOD - Safe nested access with dig
Rails.application.credentials.dig(:aws, :access_key_id)
Rails.application.credentials.secret_key_base

```

**In Configuration Files:**

```yaml
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  ...

```

**In Initializers:**

```ruby
# config/initializers/stripe.rb
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

```

**In Models/Services:**

```ruby
class AiService
  def initialize
    @api_key = Rails.application.credentials.dig(:openai, :api_key)
  end
end

```
</pattern>

### Master Key Management

<pattern name="master-key-security">
<description>Protect master.key with extreme security measures</description>

**Key Locations:**

```

config/master.key                    # Master key
config/credentials/production.key    # Production key
config/credentials/development.key   # Development key

```

**Security Rules:**
- ❌ NEVER commit to version control, share via email/chat, or hardcode
- ✅ Store in password manager (1Password, LastPass)
- ✅ Store in CI/CD secrets (GitHub Secrets)
- ✅ Set as RAILS_MASTER_KEY environment variable

**.gitignore:** Rails excludes `/config/master.key` and `/config/credentials/*.key` by default
</pattern>

### Production Deployment

<pattern name="production-deployment">
<description>Deploy encrypted credentials securely to production</description>

**Environment Variable Method (Preferred):**

```bash
export RAILS_MASTER_KEY=abc123def456...

```

**Kamal:**

```yaml
# config/deploy.yml
env:
  secret:
    - RAILS_MASTER_KEY

```

**Docker:**

```bash
docker run -e RAILS_MASTER_KEY=abc123... myapp

```

**Heroku:**

```bash
heroku config:set RAILS_MASTER_KEY=abc123def456...

```
</pattern>

### Per-Environment Credentials

<pattern name="environment-specific-credentials">
<description>Use different credentials for each environment</description>

**Generate Environment Credentials:**

```bash
bin/rails credentials:edit --environment production
# Creates: config/credentials/production.key (DON'T COMMIT)
#          config/credentials/production.yml.enc (SAFE TO COMMIT)

bin/rails credentials:edit --environment development

```

**Production Credentials:**

```yaml
aws:
  access_key_id: AKIAPROD...
  bucket: myapp-production

stripe:
  secret_key: sk_live_...

```

**Development Credentials:**

```yaml
aws:
  access_key_id: AKIADEV...
  bucket: myapp-development

stripe:
  secret_key: sk_test_...

```

**Access:** Same code works everywhere - Rails auto-loads correct environment

```ruby
Rails.application.credentials.dig(:stripe, :secret_key)

```
</pattern>

<antipatterns>
<antipattern>
<description>Committing master.key to version control</description>
<reason>Exposes all encrypted credentials - CRITICAL security breach</reason>
<bad-example>

```bash
# ❌ CRITICAL SECURITY VIOLATION
git add config/master.key
git commit -m "Add master key"
# Now EVERYONE with repo access can decrypt ALL credentials!

```
</bad-example>
<good-example>

```bash
# ✅ SECURE - Never commit keys (.gitignore excludes them)
# Share via password manager, encrypted channels, or CI/CD secrets

```
</good-example>
</antipattern>

<antipattern>
<description>Hardcoding secrets in code</description>
<reason>Exposes secrets in version control forever</reason>
<bad-example>

```ruby
# ❌ SECURITY VIOLATION
class PaymentService
  STRIPE_SECRET_KEY = "sk_live_abc123xyz789"
end

```
</bad-example>
<good-example>

```ruby
# ✅ SECURE - Use encrypted credentials
class PaymentService
  def initialize
    @stripe_key = Rails.application.credentials.dig(:stripe, :secret_key)
  end
end

```
</good-example>
</antipattern>
</antipatterns>

---

## Initializers (Application Initialization)

Configure gems, customize Rails behavior, and set up application-wide settings using initialization files that run once during boot.

### Initialization Lifecycle

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

**When Order Matters:** Use numbered prefixes (00_, 01_, etc.) to control load sequence
</pattern>

### Common Initializers

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

### Security Configuration

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

### Reloadable Code Patterns

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
</antipatterns>

---

## Docker Setup (Containerization & Deployment)

Rails 8 includes Docker support by default with Kamal deployment. Essential configuration focuses on .dockerignore to exclude development files.

### .dockerignore Configuration

<pattern name="dockerignore-rails-8">
<description>Essential .dockerignore for Rails 8 projects</description>

```gitignore
# Planning and Documentation
docs/
*.md
README*

# Development Files
.git/
.github/
.gitignore
.dockerignore

# Environment Files
.env*
config/master.key
config/credentials/*.key

# Test Files
spec/
test/
coverage/

# Dependencies
.bundle/
vendor/cache/

# Logs and Temp
log/*
tmp/*
*.log

# Development Databases
*.sqlite3
db/*.sqlite3*
storage/*

# Node
node_modules/

# IDE Files
.vscode/
.idea/
*.swp
.DS_Store

```

**Why exclude docs/:**
- Created by planning agent (@plan) with vision, architecture, features, tasks, and ADRs
- Not needed for runtime
- Can be several MB of markdown
- Significantly reduces image size and build time

**CRITICAL:** Always exclude `docs/` from production Docker images
</pattern>

### Stock Rails 8 Dockerfile

<pattern name="rails-8-stock-dockerfile">
<description>Rails 8 generates production-ready Dockerfiles automatically</description>

**Rails 8 includes Dockerfile by default** - no configuration needed:

```bash
rails new myapp  # Creates Dockerfile + .dockerignore automatically
docker build -t app .
docker run -p 3000:3000 --env RAILS_MASTER_KEY=<key> app

```

**Stock Dockerfile provides:** Multi-stage builds, health checks, Kamal compatibility
</pattern>

### Kamal Deployment

<pattern name="kamal-rails-8">
<description>Kamal is Rails 8's default deployment tool</description>

**Rails 8 includes Kamal by default** with `config/deploy.yml`:

```bash
kamal deploy                              # Deploy to production
kamal app logs                            # Check logs
kamal app exec 'bin/rails db:migrate'    # Remote commands

```

**Already configured:** Dockerfile, health check at `/up`, zero-downtime deploys
</pattern>

<antipatterns>
<antipattern>
<description>Skip .dockerignore</description>
<reason>Bloated images, longer builds, wasted CI/CD bandwidth</reason>
<bad-example>

```dockerfile
# BAD: No .dockerignore → copies docs/, test/, spec/
COPY . .

```
</bad-example>
<good-example>

```bash
# Create comprehensive .dockerignore
docs/
spec/
test/
.git/
.env*

```
</good-example>
</antipattern>
</antipatterns>

---

## RuboCop & Code Quality

RuboCop is a Ruby static code analyzer and formatter. Rails 8 comes with rubocop-rails-omakase pre-configured. This section covers customizing that base to enforce TEAM_RULES.md standards.

### Rails 8 Default Configuration

<pattern name="rails-8-rubocop-default">
<description>Rails 8 includes rubocop-rails-omakase by default</description>

**Rails 8 includes `.rubocop.yml` automatically** - excellent defaults, minimal overrides needed.

**Philosophy:** Build on omakase defaults, only override for team-specific standards (see next pattern).
</pattern>

### Team-Specific Customizations

<pattern name="team-overrides">
<description>Add TEAM_RULES.md-specific overrides to .rubocop.yml</description>

Customize the stock Rails configuration by adding overrides to `.rubocop.yml`:

```yaml
# .rubocop.yml

# Omakase Ruby styling for Rails
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Team-specific overrides (TEAM_RULES.md)

# Rule #16: Double Quotes Always
# Override omakase if it uses single quotes
Style/StringLiterals:
  EnforcedStyle: double_quotes

# Rule #20: Hash#dig for Nested Access
Style/HashFetchChain:
  Enabled: true

Style/DigChain:
  Enabled: true

# Additional team preferences (optional)
# Add any other team-specific rules here

```

**Key Points:**
- Inherit from rubocop-rails-omakase first
- Add overrides below inheritance
- Only override rules that conflict with team standards
- Comment each override with TEAM_RULES.md reference
</pattern>

### TEAM_RULES.md Enforcement

<pattern name="team-rules-cops">
<description>RuboCop cops that directly enforce TEAM_RULES.md</description>

| Rule | Cop | Enforcement | Auto-correctable |
|------|-----|-------------|------------------|
| Rule #16: Double Quotes | `Style/StringLiterals` | ✅ Always | Yes |
| Rule #20: Hash#dig | `Style/HashFetchChain`, `Style/DigChain` | ✅ Always | Yes |
| Rule #17: bin/ci Must Pass | RuboCop integrated in bin/ci | ✅ CI blocker | N/A |

**How it works:**

1. **Style/StringLiterals** - Enforces double quotes (Rule #16)

   ```ruby
   # Bad (detected and auto-corrected)
   name = 'John'

   # Good
   name = "John"

   ```

2. **Style/HashFetchChain** - Detects chained fetch calls (Rule #20)

   ```ruby
   # Bad (detected)
   hash.fetch(:a, nil)&.fetch(:b, nil)

   # Good (suggested)
   hash.dig(:a, :b)

   ```

3. **Style/DigChain** - Collapses chained dig calls (Rule #20)

   ```ruby
   # Bad (detected)
   hash.dig(:a).dig(:b).dig(:c)

   # Good (suggested)
   hash.dig(:a, :b, :c)

   ```
</pattern>

### Integration with bin/ci

<pattern name="rubocop-bin-ci">
<description>Integrate RuboCop into CI pipeline (TEAM_RULES.md Rule #17)</description>

**Add RuboCop to bin/ci:**

```bash
#!/usr/bin/env bash
set -e
bin/rails test
bin/rubocop              # Add this line
bin/brakeman -q

```

**Usage:**

```bash
bin/ci           # Run all checks (must pass before commit)
bin/rubocop -a   # Auto-fix safe violations

```

**IMPORTANT:** bin/ci must pass before committing (TEAM_RULES.md Rule #17)
</pattern>

### Common Commands

<pattern name="rubocop-commands">
<description>Essential RuboCop commands for daily workflow</description>

```bash
bin/rubocop              # Check all code
bin/rubocop -a           # Auto-fix safe violations
bin/rubocop -A           # Auto-fix all (including unsafe)
bin/rubocop app/models/  # Check specific directory

```

**Best practice:** Run `bin/rubocop -a` before committing
</pattern>

### Custom Cops for Team-Specific Rules

<pattern name="custom-cops">
<description>Create custom RuboCop cops to enforce team-specific patterns</description>

**When to Use Custom Cops:**
- Team has coding standards not covered by existing RuboCop cops
- Need to enforce project-specific patterns or anti-patterns
- Want to catch common mistakes specific to your codebase

**Example: Detecting Nested Hash Bracket Access (Rule #20 Enhancement)**

While `Style/HashFetchChain` and `Style/DigChain` handle chained `.fetch()` and `.dig()` calls, they **don't detect** nested bracket access like `hash[:a][:b][:c]`.

This project includes a custom RuboCop cop to detect unsafe nested hash bracket access:

- **Location:** `lib/rails_ai/cops/style/nested_bracket_access.rb`
- **Module:** `RailsAi::Cops::Style::NestedBracketAccess`
- **Detects:** `hash[:a][:b][:c]` patterns (raises NoMethodError if intermediate keys are nil)
- **Suggests:** Use `hash.dig(:a, :b, :c)` (safe) or chained `fetch` (raises explicit errors)

**Example violations:**

```ruby
# ❌ VIOLATION: Unsafe nested bracket access
user[:profile][:theme][:color]        # NoMethodError if :profile is nil
data[:metadata][:created_at][:date]   # NoMethodError if :metadata is nil

# ✅ CORRECT: Safe nested access with dig
user.dig(:profile, :theme, :color)    # Returns nil safely
data.dig(:metadata, :created_at, :date)

# ✅ ALTERNATIVE: Explicit error handling with fetch
user.fetch(:profile).fetch(:theme).fetch(:color)  # Raises KeyError with clear message

```

**Enable in .rubocop.yml:**

```yaml
# .rubocop.yml
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Load custom cops
require:
  - ./lib/rails_ai/cops/style/nested_bracket_access.rb

# Team overrides
Style/StringLiterals:
  EnforcedStyle: double_quotes

Style/HashFetchChain:
  Enabled: true

Style/DigChain:
  Enabled: true

# Custom cop configuration
Style/NestedBracketAccess:
  Enabled: true
  Severity: warning  # Warn only, don't fail CI yet
  Description: 'Detects nested hash bracket access and suggests Hash#dig'

```
</pattern>

<antipatterns>
<antipattern>
<description>Replace rubocop-rails-omakase entirely</description>
<reason>Lose Rails defaults, have to maintain everything yourself</reason>
<bad-example>

```yaml
# BAD: Throwing away Rails defaults
# inherit_gem: { rubocop-rails-omakase: rubocop.yml }

plugins:
  - rubocop-minitest
  - rubocop-rake

AllCops:
  NewCops: enable
  # ... 200 lines of custom configuration

```
</bad-example>
<good-example>

```yaml
# GOOD: Build on Rails defaults
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Only override team-specific rules
Style/StringLiterals:
  EnforcedStyle: double_quotes

```
</good-example>
</antipattern>

<antipattern>
<description>Skip RuboCop in CI</description>
<reason>Violations slip into codebase, inconsistent style</reason>
<bad-example>

```bash
# BAD: bin/ci without RuboCop
#!/usr/bin/env bash
bin/rails test  # Missing RuboCop check!

```
</bad-example>
<good-example>

```bash
#!/usr/bin/env bash
set -e
bin/rails test
bin/rubocop      # ✅ Included
bin/brakeman -q

```
</good-example>
</antipattern>
</antipatterns>

---

## CI/CD Integration

Integrate configuration checks into continuous integration pipelines.

### GitHub Actions

<pattern name="cicd-github-actions">
<description>Configure CI/CD to access encrypted credentials</description>

**GitHub Actions:**

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    env:
      RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
      - run: bin/ci

```

**Setup:** Settings > Secrets > Actions > Add `RAILS_MASTER_KEY`
</pattern>

---

<testing>

```ruby
# test/config/credentials_test.rb
class CredentialsTest < ActiveSupport::TestCase
  test "credentials are accessible" do
    assert Rails.application.credentials.secret_key_base.present?
    assert Rails.application.credentials.dig(:stripe, :secret_key).present?
  end
end

```
</testing>

<related-skills>
**Must use during project verification:**
- rails-ai:jobs - SolidQueue, SolidCache, SolidCable requirements (TEAM RULE #1)
- rails-ai:testing - Minitest patterns and anti-patterns (TEAM RULE #2)
- rails-ai:security - Security configuration, credentials, SSL, CSP (TEAM RULE #13)
- rails-ai:styling - Tailwind CSS and DaisyUI configuration

**May use for specific checks:**
- rails-ai:models - Database configuration and migrations
- rails-ai:debugging - Rails debugging tools and logging configuration
- rails-ai:controllers - RESTful routing verification (TEAM RULE #3)
</related-skills>

<resources>

**Official Documentation:**
- [Rails Guides - Configuring Rails Applications](https://guides.rubyonrails.org/configuring.html)
- [Rails Guides - Encrypted Credentials](https://guides.rubyonrails.org/security.html#custom-credentials)
- [Rails Guides - Getting Started with Docker](https://guides.rubyonrails.org/getting_started_with_docker.html)

**Gems & Libraries:**
- [rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase) - Rails Omakase RuboCop config

**Tools:**
- [Kamal](https://kamal-deploy.org/) - Deploy web apps anywhere
- [RuboCop](https://docs.rubocop.org/) - Ruby static code analyzer

**Community Resources:**
- [Rails 8 Solid Stack Overview](https://fly.io/ruby-dispatch/solid-cache-solid-queue-solid-cable/) - Solid Queue, Solid Cache, Solid Cable

</resources>
