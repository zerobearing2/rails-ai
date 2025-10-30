# Rails Credentials Management (Secure Secrets)
# Reference: Rails Security Guide
# Category: CRITICAL SECURITY

# ============================================================================
# Rails Credentials vs Environment Variables
# ============================================================================

# Rails Credentials (config/credentials.yml.enc):
# ✅ Encrypted with config/master.key
# ✅ Version controlled (encrypted file)
# ✅ Per-environment support
# ✅ Structured YAML
#
# Environment Variables:
# ✅ Platform-agnostic
# ✅ Standard for Docker/Heroku/etc
# ✅ No encryption needed
# ❌ Less structured

# Best Practice: Use BOTH
# - Credentials for API keys, secrets
# - ENV vars for configuration (URLs, flags, etc.)

# ============================================================================
# Editing Credentials
# ============================================================================

# Edit master credentials (all environments)
bin/rails credentials:edit

# Edit environment-specific credentials
bin/rails credentials:edit --environment production
bin/rails credentials:edit --environment development

# ============================================================================
# Credentials File Structure
# ============================================================================

# config/credentials.yml.enc (decrypted content):
```yaml
# Master credentials (shared across environments)

secret_key_base: abc123...

# AWS S3 for ActiveStorage
aws:
  access_key_id: AKIAIOSFODNN7EXAMPLE
  secret_access_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  region: us-east-1
  bucket: my-app-production

# Email delivery
smtp:
  domain: example.com
  username: <%= ENV['SENDGRID_USERNAME'] %>  # Can reference ENV
  password: abc123xyz

# AI API Keys
anthropic:
  api_key: sk-ant-abc123...

openai:
  api_key: sk-abc123...

# Stripe payment processing
stripe:
  publishable_key: pk_test_abc123
  secret_key: sk_test_xyz789
  webhook_secret: whsec_abc123

# Database encryption
active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz

# ActionMailbox ingress
action_mailbox:
  ingress_password: strong_password_here

# Mandrill (if using)
  mandrill_api_key: md-abc123...
```

# ============================================================================
# Accessing Credentials in Code
# ============================================================================

# Access nested credentials
Rails.application.credentials.aws[:access_key_id]
Rails.application.credentials.dig(:aws, :access_key_id)

# Accessing in configuration files
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: <%= Rails.application.credentials.dig(:aws, :region) %>
  bucket: <%= Rails.application.credentials.dig(:aws, :bucket) %>

# Accessing in initializers
# config/initializers/stripe.rb
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

# Accessing in controllers/models
class FeedbacksController < ApplicationController
  def create
    # Use credentials for API calls
    api_key = Rails.application.credentials.dig(:anthropic, :api_key)
    # ...
  end
end

# ============================================================================
# Per-Environment Credentials
# ============================================================================

# Generate encryption keys
bin/rails credentials:edit --environment production
# Creates:
# - config/credentials/production.key (keep secret!)
# - config/credentials/production.yml.enc (version control)

bin/rails credentials:edit --environment development
# Creates:
# - config/credentials/development.key
# - config/credentials/development.yml.enc

# Precedence: Environment-specific > Master credentials
# Rails loads: config/credentials/production.yml.enc
# Falls back to: config/credentials.yml.enc

# ============================================================================
# Master Key Management
# ============================================================================

# config/master.key - CRITICAL SECURITY
# ❌ NEVER commit to version control
# ❌ NEVER share publicly
# ✅ Store in password manager
# ✅ Share securely with team (1Password, encrypted channel)
# ✅ Store in CI/CD secrets (GitHub Secrets, etc.)

# .gitignore (Rails default)
/config/master.key
/config/credentials/*.key

# ============================================================================
# Production Deployment
# ============================================================================

# Set RAILS_MASTER_KEY environment variable
export RAILS_MASTER_KEY=abc123...

# Or provide key file
# Mount config/master.key on server

# Kamal deployment (config/deploy.yml)
env:
  secret:
    - RAILS_MASTER_KEY

# Docker environment
docker run -e RAILS_MASTER_KEY=abc123... myapp

# ============================================================================
# Generating Encryption Keys
# ============================================================================

# Generate Active Record Encryption keys
bin/rails db:encryption:init
# Add this entry to the credentials of the target environment:
#
# active_record_encryption:
#   primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
#   deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
#   key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz

# Generate secret_key_base
bin/rails secret
# Outputs: abc123xyz789...

# ============================================================================
# Alternative: Environment Variables
# ============================================================================

# For non-sensitive config or when credentials aren't practical

# Access environment variables
ENV["DATABASE_URL"]
ENV.fetch("REDIS_URL", "redis://localhost:6379/0")

# Use in configuration
# config/environments/production.rb
config.action_mailer.smtp_settings = {
  address: ENV["SMTP_HOST"],
  port: ENV.fetch("SMTP_PORT", 587),
  user_name: ENV["SMTP_USERNAME"],
  password: ENV["SMTP_PASSWORD"]
}

# Use in Active Record Encryption
# config/application.rb
config.active_record.encryption.primary_key = ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"]
config.active_record.encryption.deterministic_key = ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"]
config.active_record.encryption.key_derivation_salt = ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"]

# ============================================================================
# Combining Credentials + ENV
# ============================================================================

# Best of both worlds
# config/credentials.yml.enc
```yaml
smtp:
  domain: example.com
  username: <%= ENV['SENDGRID_USERNAME'] %>  # From ENV
  password: abc123xyz  # Encrypted in credentials
```

# Or fallback pattern
Stripe.api_key = ENV["STRIPE_SECRET_KEY"] ||
                 Rails.application.credentials.dig(:stripe, :secret_key)

# ============================================================================
# Testing Credentials Access
# ============================================================================

# Rails console
rails console
Rails.application.credentials.aws
# => {:access_key_id=>"AKIA...", :secret_access_key=>"wJal..."}

Rails.application.credentials.dig(:stripe, :secret_key)
# => "sk_test_xyz789"

# ============================================================================
# CI/CD Setup (GitHub Actions)
# ============================================================================

# .github/workflows/ci.yml
env:
  RAILS_ENV: test
  RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}

# GitHub Repository Secrets:
# Settings > Secrets and variables > Actions > New repository secret
# Name: RAILS_MASTER_KEY
# Value: <content of config/master.key>

# ============================================================================
# Credential Rotation
# ============================================================================

# When rotating secrets (API keys, passwords):
# 1. Edit credentials
bin/rails credentials:edit

# 2. Update the secret
# 3. Save and close editor (auto-encrypts)
# 4. Commit encrypted file
git add config/credentials.yml.enc
git commit -m "Rotate Stripe API key"

# 5. Deploy to update production

# ============================================================================
# Common Mistakes
# ============================================================================

# ❌ Committing master.key
git add config/master.key  # NEVER DO THIS!

# ❌ Hardcoding secrets in code
class User
  ADMIN_PASSWORD = "secret123"  # ❌ SECURITY VIOLATION
end

# ✅ Use credentials
class User
  def self.admin_password
    Rails.application.credentials.admin_password
  end
end

# ❌ Sharing credentials in plain text
# Email: "Here's the master key: abc123..."  # ❌

# ✅ Use secure channels
# 1Password shared vault, encrypted file, secure chat

# ============================================================================
# RULE: NEVER commit config/master.key or credentials/*.key
# ALWAYS: Use credentials for sensitive data (API keys, passwords)
# PREFER: Environment variables for non-sensitive configuration
# DEPLOY: Set RAILS_MASTER_KEY environment variable in production
# ROTATE: Update credentials regularly, especially after exposure
# SHARE: Use secure channels (password managers, encrypted communication)
# ============================================================================
