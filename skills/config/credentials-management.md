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
- API keys (Stripe, OpenAI, Anthropic, AWS)
- Database encryption keys
- SMTP passwords and OAuth secrets
- Webhook secrets and ActiveStorage credentials
- ALWAYS for any sensitive data
</when-to-use>

<benefits>
- **Encrypted at Rest** - AES-256 encryption
- **Version Controlled** - Safe to commit encrypted files
- **Structured Storage** - YAML format
- **Per-Environment Support** - Different credentials per environment
- **Team Collaboration** - Share encrypted files, key stays secret
</benefits>

<standards>
- NEVER commit config/master.key or config/credentials/*.key
- ALWAYS use encrypted credentials for API keys/passwords
- Store master.key in password manager and CI/CD secrets
- Use per-environment credentials for production
- Set RAILS_MASTER_KEY environment variable for deployment
</standards>

## Editing Credentials

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

## Credentials File Structure

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
  username: <%= ENV['SENDGRID_USERNAME'] %>  # Can reference ENV
  password: SG.abc123xyz789

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz
```

**Guidelines:** Use nested keys, group by service, add comments, support ERB fallbacks.
</pattern>

## Accessing Credentials

<pattern name="accessing-credentials">
<description>Read credentials safely in application code</description>

**Basic Access:**
```ruby
# Dig method (safer - returns nil if missing)
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

## Master Key Management

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

**.gitignore:** Rails excludes `/config/master.key` and `/config/credentials/*.key` by default.
</pattern>

## Production Deployment

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

**AWS ECS:**
```json
{
  "containerDefinitions": [{
    "environment": [{"name": "RAILS_MASTER_KEY", "value": "abc123..."}]
  }]
}
```
</pattern>

## Per-Environment Credentials

<pattern name="environment-specific">
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

**Access:** Same code works everywhere - Rails auto-loads correct environment.
```ruby
Rails.application.credentials.dig(:stripe, :secret_key)
```
</pattern>

## Generating Encryption Keys

<pattern name="key-generation">
<description>Generate secure keys for credentials and encryption</description>

**Generate secret_key_base:**
```bash
bin/rails secret
```

**Generate Active Record Encryption keys:**
```bash
bin/rails db:encryption:init
# Add output to: bin/rails credentials:edit --environment production
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
smtp:
  username: <%= ENV['SENDGRID_USERNAME'] %>
  password: SG.abc123xyz  # Encrypted
```

**Fallback Pattern:**
```ruby
api_key = Rails.application.credentials.dig(:openai, :api_key) ||
          ENV["OPENAI_API_KEY"]
```

**Configuration:**
```ruby
config.action_mailer.smtp_settings = {
  address: ENV.fetch("SMTP_HOST", "smtp.sendgrid.net"),  # Non-sensitive
  password: Rails.application.credentials.dig(:smtp, :password)  # Sensitive
}
```
</pattern>

## CI/CD Setup

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
      - run: bin/rails test
```

**GitHub Setup:** Settings > Secrets > Actions > Add `RAILS_MASTER_KEY`

**GitLab CI:**
```yaml
test:
  variables:
    RAILS_MASTER_KEY: $RAILS_MASTER_KEY
  script:
    - bin/rails test
```

**GitLab Setup:** Settings > CI/CD > Variables > Add `RAILS_MASTER_KEY` (Protected + Masked)
</pattern></invoke>

## Credential Rotation

<pattern name="credential-rotation">
<description>Safely rotate compromised or expired credentials</description>

**Rotation Process:**
```bash
bin/rails credentials:edit --environment production
# Update compromised secret
# Save and commit encrypted file
git add config/credentials/production.yml.enc
git commit -m "Rotate Stripe API key"
git push
# Deploy to production
```

**When to Rotate:**
- After security breach or exposure
- Regularly for high-value credentials (90 days)
- When team member leaves or third-party breach occurs

**Checklist:**
- [ ] Generate new credential at provider
- [ ] Update encrypted credentials file
- [ ] Deploy and verify
- [ ] Revoke old credential
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

<testing>
```ruby
# test/models/credentials_test.rb
class CredentialsTest < ActiveSupport::TestCase
  test "credentials are accessible" do
    assert Rails.application.credentials.secret_key_base.present?
    assert Rails.application.credentials.dig(:stripe, :secret_key).present?
  end

  test "credentials have expected structure" do
    aws_creds = Rails.application.credentials.aws
    assert_not_nil aws_creds
    assert aws_creds.key?(:access_key_id)
  end
end
```

**Console Testing:**
```ruby
rails console
Rails.application.credentials.dig(:stripe, :secret_key)
# => "sk_test_xyz789"
```
</testing>

<related-skills>
- security-strong-parameters
- security-csrf
- config-environment-variables
- docker-rails-setup
</related-skills>

<resources>
- [Rails Credentials Guide](https://guides.rubyonrails.org/security.html#custom-credentials)
- [Rails Encrypted Credentials](https://edgeguides.rubyonrails.org/security.html#environmental-security)
- [Best Practices](https://www.honeybadger.io/blog/rails-credentials/)
</resources>
