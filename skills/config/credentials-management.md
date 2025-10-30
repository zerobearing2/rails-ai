---
name: credentials-management
domain: config
dependencies: []
version: 1.0
rails_version: 8.1+
criticality: CRITICAL
---

# Rails Credentials Management (Secure Secrets)

Securely manage API keys, passwords, and sensitive configuration using Rails encrypted credentials instead of plain-text environment variables.

<when-to-use>
- Storing API keys (Stripe, OpenAI, Anthropic, AWS, etc.)
- Managing database encryption keys
- Storing SMTP passwords and email credentials
- Handling OAuth client secrets
- Configuring webhook secrets
- Setting up ActiveStorage credentials
- Managing secret_key_base
- ALWAYS - for any sensitive data that should never be exposed
</when-to-use>

<benefits>
- **Encrypted at Rest** - Files are encrypted with AES-256
- **Version Controlled** - Safe to commit encrypted credentials
- **Structured Storage** - YAML format for organized secrets
- **Per-Environment Support** - Different credentials per environment
- **Team Collaboration** - Share encrypted files, only key stays secret
- **Audit Trail** - Git history tracks credential changes
- **No Key Sprawl** - Single master key for all credentials
</benefits>

<standards>
- NEVER commit config/master.key or config/credentials/*.key
- ALWAYS use encrypted credentials for API keys and passwords
- Use environment variables for non-sensitive configuration (URLs, flags)
- Store master.key in password manager and CI/CD secrets
- Use per-environment credentials for production
- Rotate credentials after exposure or compromise
- Share master.key only through secure channels (1Password, encrypted)
- Set RAILS_MASTER_KEY environment variable for deployment
</standards>

## Editing Credentials

<pattern name="editing-credentials">
<description>Use Rails credentials editor to safely modify encrypted secrets</description>

**Edit master credentials (all environments):**
```bash
bin/rails credentials:edit
```

**Edit environment-specific credentials:**
```bash
# Production credentials
bin/rails credentials:edit --environment production

# Development credentials
bin/rails credentials:edit --environment development

# Staging credentials
bin/rails credentials:edit --environment staging
```

**What happens:**
1. Rails decrypts credentials using master.key
2. Opens in $EDITOR (VS Code, vim, nano)
3. Auto-encrypts when you save and close
4. Creates encrypted .yml.enc file

**Precedence:** Environment-specific > Master credentials
- Rails loads: `config/credentials/production.yml.enc`
- Falls back to: `config/credentials.yml.enc`
</pattern>

## Credentials File Structure

<pattern name="credentials-structure">
<description>Organize credentials in structured YAML format</description>

**config/credentials.yml.enc (decrypted view):**
```yaml
# Secret key base (required)
secret_key_base: abc123def456...

# AWS S3 for ActiveStorage
aws:
  access_key_id: AKIAIOSFODNN7EXAMPLE
  secret_access_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  region: us-east-1
  bucket: my-app-production

# Email delivery
smtp:
  domain: example.com
  username: <%= ENV['SENDGRID_USERNAME'] %>  # Can reference ENV vars
  password: SG.abc123xyz789

# AI API Keys
anthropic:
  api_key: sk-ant-api03-abc123...

openai:
  api_key: sk-abc123...
  organization_id: org-abc123

# Stripe payment processing
stripe:
  publishable_key: pk_live_abc123
  secret_key: sk_live_xyz789
  webhook_secret: whsec_abc123

# Database encryption
active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz

# ActionMailbox ingress
action_mailbox:
  ingress_password: strong_password_here
```

**Structure Guidelines:**
- Use nested keys for related credentials
- Group by service (aws, stripe, anthropic)
- Include comments for context
- Use ERB for environment variable fallbacks
- Keep similar environments consistent
</pattern>

## Accessing Credentials

<pattern name="accessing-credentials">
<description>Read credentials safely in application code</description>

**Basic Access:**
```ruby
# Hash notation
Rails.application.credentials.aws[:access_key_id]

# Dig method (safer - returns nil if missing)
Rails.application.credentials.dig(:aws, :access_key_id)

# Direct access
Rails.application.credentials.secret_key_base
```

**In Configuration Files:**
```yaml
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: <%= Rails.application.credentials.dig(:aws, :region) %>
  bucket: <%= Rails.application.credentials.dig(:aws, :bucket) %>
```

**In Initializers:**
```ruby
# config/initializers/stripe.rb
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

# config/initializers/anthropic.rb
Anthropic.configure do |config|
  config.api_key = Rails.application.credentials.dig(:anthropic, :api_key)
end
```

**In Controllers:**
```ruby
class PaymentsController < ApplicationController
  def create
    # Access credentials for API calls
    Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

    charge = Stripe::Charge.create(
      amount: 2000,
      currency: "usd",
      source: params[:token]
    )
  end
end
```

**In Models:**
```ruby
class AiService
  def initialize
    @api_key = Rails.application.credentials.dig(:openai, :api_key)
  end

  def call_api
    # Use @api_key securely
  end
end
```
</pattern>

## Master Key Management

<pattern name="master-key-security">
<description>Protect master.key with extreme security measures</description>

**Master Key Location:**
```
config/master.key               # Master credentials key
config/credentials/production.key   # Production-specific key
config/credentials/development.key  # Development-specific key
```

**Security Rules:**
- ❌ NEVER commit to version control
- ❌ NEVER share via email or chat
- ❌ NEVER hardcode in scripts or code
- ✅ Store in password manager (1Password, LastPass)
- ✅ Share via secure encrypted channels
- ✅ Store in CI/CD secrets (GitHub Secrets, etc.)
- ✅ Set as environment variable in production

**.gitignore (Rails default):**
```gitignore
# Credentials keys - NEVER commit
/config/master.key
/config/credentials/*.key
```

**Verify keys are ignored:**
```bash
git status
# Should NOT show config/master.key
```
</pattern>

## Production Deployment

<pattern name="production-deployment">
<description>Deploy encrypted credentials securely to production</description>

**Environment Variable Method (Preferred):**
```bash
# Set RAILS_MASTER_KEY on production server
export RAILS_MASTER_KEY=abc123def456...

# Or in shell profile
echo 'export RAILS_MASTER_KEY=abc123def456...' >> ~/.bashrc
```

**Kamal Deployment:**
```yaml
# config/deploy.yml
env:
  secret:
    - RAILS_MASTER_KEY  # Reads from local environment
```

**Docker Deployment:**
```bash
# Pass as environment variable
docker run -e RAILS_MASTER_KEY=abc123... myapp

# Or in docker-compose.yml
services:
  web:
    environment:
      - RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
```

**Heroku:**
```bash
heroku config:set RAILS_MASTER_KEY=abc123def456...
```

**AWS ECS/Fargate:**
```json
{
  "containerDefinitions": [{
    "environment": [
      {
        "name": "RAILS_MASTER_KEY",
        "value": "abc123def456..."
      }
    ]
  }]
}
```

**Key File Method (Alternative):**
```bash
# Mount config/master.key on server
scp config/master.key user@server:/app/config/master.key

# Ensure proper permissions
chmod 600 /app/config/master.key
```
</pattern>

## Per-Environment Credentials

<pattern name="environment-specific">
<description>Use different credentials for each environment</description>

**Generate Environment Credentials:**
```bash
# Creates production key and encrypted file
bin/rails credentials:edit --environment production
# Files created:
#   config/credentials/production.key (DON'T COMMIT)
#   config/credentials/production.yml.enc (SAFE TO COMMIT)

# Creates development credentials
bin/rails credentials:edit --environment development
# Files created:
#   config/credentials/development.key
#   config/credentials/development.yml.enc
```

**Production Credentials Example:**
```yaml
# config/credentials/production.yml.enc (decrypted)
secret_key_base: production_secret_key_base

aws:
  access_key_id: AKIAPROD...
  secret_access_key: prod_secret
  bucket: myapp-production

stripe:
  publishable_key: pk_live_...
  secret_key: sk_live_...
  webhook_secret: whsec_live_...
```

**Development Credentials Example:**
```yaml
# config/credentials/development.yml.enc (decrypted)
aws:
  access_key_id: AKIADEV...
  secret_access_key: dev_secret
  bucket: myapp-development

stripe:
  publishable_key: pk_test_...
  secret_key: sk_test_...
  webhook_secret: whsec_test_...
```

**Access Pattern (same code works everywhere):**
```ruby
# Automatically loads production or development credentials
Rails.application.credentials.dig(:stripe, :secret_key)
```
</pattern>

## Generating Encryption Keys

<pattern name="key-generation">
<description>Generate secure keys for credentials and encryption</description>

**Generate secret_key_base:**
```bash
bin/rails secret
# Output: abc123def456xyz789...
```

**Generate Active Record Encryption keys:**
```bash
bin/rails db:encryption:init
```

**Output:**
```
Add this entry to the credentials of the target environment:

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz
```

**Add to credentials:**
```bash
bin/rails credentials:edit --environment production
# Paste the generated keys
```
</pattern>

## Combining Credentials + Environment Variables

<pattern name="hybrid-approach">
<description>Use both encrypted credentials and environment variables strategically</description>

**Best Practices:**
- ✅ **Credentials** for: API keys, passwords, secrets, tokens
- ✅ **ENV vars** for: URLs, flags, timeouts, non-sensitive config

**Credentials with ENV Fallback:**
```yaml
# config/credentials.yml.enc
smtp:
  domain: example.com
  username: <%= ENV['SENDGRID_USERNAME'] %>  # From ENV
  password: SG.abc123xyz  # Encrypted in credentials
```

**Code with Fallback Pattern:**
```ruby
# Try ENV first, fall back to credentials
Stripe.api_key = ENV["STRIPE_SECRET_KEY"] ||
                 Rails.application.credentials.dig(:stripe, :secret_key)

# Or prefer credentials
api_key = Rails.application.credentials.dig(:openai, :api_key) ||
          ENV["OPENAI_API_KEY"]
```

**Configuration File:**
```ruby
# config/environments/production.rb
config.action_mailer.smtp_settings = {
  address: ENV.fetch("SMTP_HOST", "smtp.sendgrid.net"),  # Non-sensitive
  port: ENV.fetch("SMTP_PORT", 587).to_i,                # Non-sensitive
  user_name: Rails.application.credentials.dig(:smtp, :username),  # Sensitive
  password: Rails.application.credentials.dig(:smtp, :password)    # Sensitive
}
```
</pattern>

## CI/CD Setup

<pattern name="cicd-github-actions">
<description>Configure CI/CD to access encrypted credentials</description>

**GitHub Actions:**
```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    env:
      RAILS_ENV: test
      RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      - name: Run tests
        run: bin/rails test
```

**GitHub Repository Setup:**
1. Go to repository Settings
2. Select "Secrets and variables" > "Actions"
3. Click "New repository secret"
4. Name: `RAILS_MASTER_KEY`
5. Value: (paste content of config/master.key)
6. Click "Add secret"

**GitLab CI:**
```yaml
# .gitlab-ci.yml
test:
  variables:
    RAILS_ENV: test
    RAILS_MASTER_KEY: $RAILS_MASTER_KEY
  script:
    - bundle install
    - bin/rails test
```

**Set in GitLab:**
- Settings > CI/CD > Variables
- Add variable: `RAILS_MASTER_KEY`
- Mark as "Protected" and "Masked"
</pattern>

## Credential Rotation

<pattern name="credential-rotation">
<description>Safely rotate compromised or expired credentials</description>

**Rotation Process:**
```bash
# 1. Edit credentials
bin/rails credentials:edit --environment production

# 2. Update the compromised secret
# Change: stripe.secret_key from sk_live_old to sk_live_new

# 3. Save and close editor (auto-encrypts)

# 4. Commit encrypted file
git add config/credentials/production.yml.enc
git commit -m "Rotate Stripe API key"

# 5. Push to repository
git push

# 6. Deploy to production
# (Deployment triggers app reload with new credentials)
```

**When to Rotate:**
- After security breach or exposure
- Regularly for high-value credentials (90 days)
- When team member leaves with access
- After third-party compromise (e.g., breach at Stripe)
- When credentials accidentally committed to repo

**Rotation Checklist:**
- [ ] Generate new credential at service provider
- [ ] Update encrypted credentials file
- [ ] Deploy to all environments
- [ ] Verify new credential works
- [ ] Revoke old credential at provider
- [ ] Update team password manager
- [ ] Document rotation in security log
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
git push

# Now EVERYONE with repo access can decrypt ALL credentials!
```
</bad-example>
<good-example>
```bash
# ✅ SECURE - Never commit keys
# .gitignore already excludes them

# Verify key is ignored
git status
# Should NOT show config/master.key

# Share key securely via:
# - Password manager (1Password shared vault)
# - Encrypted file transfer
# - Secure messaging with encryption
```
</good-example>
</antipattern>

<antipattern>
<description>Hardcoding secrets in code</description>
<reason>Exposes secrets in version control forever, even if later removed</reason>
<bad-example>
```ruby
# ❌ SECURITY VIOLATION
class PaymentService
  STRIPE_SECRET_KEY = "sk_live_abc123xyz789"  # Hardcoded!

  def charge(amount)
    Stripe.api_key = STRIPE_SECRET_KEY
    # ...
  end
end

# ❌ Also bad - in configuration
# config/environments/production.rb
config.stripe_key = "sk_live_abc123xyz789"
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use encrypted credentials
class PaymentService
  def charge(amount)
    Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
    # ...
  end
end

# ✅ Or initialize once
class PaymentService
  def initialize
    @stripe_key = Rails.application.credentials.dig(:stripe, :secret_key)
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using environment variables for sensitive secrets</description>
<reason>Not encrypted, easy to leak via logs/error reports, harder to rotate</reason>
<bad-example>
```bash
# ❌ Insecure - plain text secrets in ENV
export STRIPE_SECRET_KEY=sk_live_abc123xyz789
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG

# ❌ In .env file (often accidentally committed)
STRIPE_SECRET_KEY=sk_live_abc123xyz789
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG
```
</bad-example>
<good-example>
```bash
# ✅ SECURE - Use encrypted credentials
bin/rails credentials:edit --environment production
# Add secrets to encrypted file

# ✅ Only ENV var needed
export RAILS_MASTER_KEY=abc123def456

# ✅ ENV vars for non-sensitive config
export DATABASE_URL=postgresql://localhost/myapp
export REDIS_URL=redis://localhost:6379
export LOG_LEVEL=info
```
</good-example>
</antipattern>

<antipattern>
<description>Sharing credentials via insecure channels</description>
<reason>Credentials can be intercepted, logged, or leaked</reason>
<bad-example>
```text
❌ Email: "Here's the master key: abc123def456..."
❌ Slack DM: "master.key contents: abc123..."
❌ Google Doc: "Production credentials: ..."
❌ Text message: "RAILS_MASTER_KEY=abc123..."
❌ Zoom chat: "Can you paste the master key?"
```
</bad-example>
<good-example>
```text
✅ 1Password: Share via encrypted vault
✅ Bitwarden: Secure password sharing
✅ Encrypted file: GPG-encrypted attachment
✅ Secure chat: Signal/Wire end-to-end encrypted
✅ In person: Show on screen, don't send digitally
✅ CI/CD: Store in GitHub Secrets/GitLab Variables

# Best practice: Share key once, then:
"Master key is in 1Password vault 'Production Credentials'"
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test credentials access in console and automated tests:

```ruby
# test/models/credentials_test.rb
class CredentialsTest < ActiveSupport::TestCase
  test "credentials are accessible" do
    # Verify critical credentials exist
    assert Rails.application.credentials.secret_key_base.present?
    assert Rails.application.credentials.dig(:stripe, :secret_key).present?
  end

  test "credentials have expected structure" do
    aws_creds = Rails.application.credentials.aws

    assert_not_nil aws_creds
    assert aws_creds.key?(:access_key_id)
    assert aws_creds.key?(:secret_access_key)
    assert aws_creds.key?(:region)
  end
end

# test/integration/credential_usage_test.rb
class CredentialUsageTest < ActionDispatch::IntegrationTest
  test "Stripe initializer uses credentials" do
    # Verify Stripe is configured with credentials
    assert_equal(
      Rails.application.credentials.dig(:stripe, :secret_key),
      Stripe.api_key
    )
  end

  test "no hardcoded secrets in code" do
    # Simple grep check in test (better in CI)
    codebase = Dir.glob("app/**/*.rb").map { |f| File.read(f) }.join("\n")

    # Check for common secret patterns
    assert_no_match(/sk_live_[a-zA-Z0-9]{24}/, codebase, "Found hardcoded Stripe key")
    assert_no_match(/AKIA[A-Z0-9]{16}/, codebase, "Found hardcoded AWS key")
  end
end
```

**Manual Testing in Console:**
```ruby
rails console

# Test basic access
Rails.application.credentials.secret_key_base
# => "abc123def456..."

# Test nested access
Rails.application.credentials.dig(:stripe, :secret_key)
# => "sk_test_xyz789"

# Test environment-specific loading
Rails.env
# => "development"
Rails.application.credentials.dig(:aws, :bucket)
# => "myapp-development"

# Switch to production (if master key available)
RAILS_ENV=production rails console
Rails.application.credentials.dig(:aws, :bucket)
# => "myapp-production"
```
</testing>

<related-skills>
- security-strong-parameters - Input validation and security
- security-csrf - CSRF protection
- config-environment-variables - Non-sensitive configuration
- deployment-kamal - Production deployment with credentials
</related-skills>

<resources>
- [Rails Credentials Guide](https://guides.rubyonrails.org/security.html#custom-credentials)
- [Rails 7.1+ Encrypted Credentials](https://edgeguides.rubyonrails.org/security.html#environmental-security)
- [Best Practices for Credentials](https://www.honeybadger.io/blog/rails-credentials/)
- [Master Key Management](https://nandovieira.com/managing-credentials-in-rails)
</resources>
