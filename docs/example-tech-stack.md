## Tech Stack

### Framework & Core

**Rails 8.1.0.rc1**
- **Why:** Battle-tested full-stack framework with excellent conventions, strong AI training data representation
- **Features Used:** ActionController, ActiveRecord, ActionMailer, ActiveJob, Hotwire
- **Rationale:** Convention over configuration, rapid development, proven at scale, excellent AI-assisted development support
- **Deployment:** Kamal 2 with SQLite + Litestream for simplicity and reliability
- **Note:** Using 8-1-stable branch from GitHub (8.1.0.rc1) until official 8.1 release

**Ruby 3.3.x**
- **Why:** Modern Ruby with performance improvements, YJIT compiler, pattern matching
- **Configuration:** Strict mode for all classes, consistent code style with RuboCop

**Hotwire (Turbo + Stimulus)**
- **Why:** Modern interactive UI without heavy JavaScript frameworks
- **Turbo:** Server-rendered HTML updates with Turbo Streams and Turbo Frames
- **Stimulus:** Lightweight JavaScript controllers for progressive enhancement
- **Features Used:** Turbo Streams for real-time updates, Stimulus controllers for form interactions

### UI & Styling

**ViewComponent**
- **Why:** Component encapsulation, testability, Rails 8.1 compatible (v4.1.0+)
- **Architecture:** Components in `app/components/`, tests in `test/components/`
- **Benefits:** Co-located logic/templates/tests, slot-based composition, isolated testing
- **Integration:** Native Rails integration, works seamlessly with Hotwire/Turbo
- **Rationale:** Modern component architecture without the overhead of full frontend frameworks

**DaisyUI v5**
- **Why:** Production-ready Tailwind CSS component library, accessible by default
- **Integration:** Tailwind CSS v4 plugin via `@plugin "daisyui"` directive
- **Components:** Buttons, cards, forms, alerts, badges, modals with consistent design
- **Benefits:** Beautiful UI out of the box, WCAG 2.1 AA compliant, extensive theming
- **Rationale:** Faster development with pre-built accessible components

**Tailwind CSS v4**
- **Why:** Utility-first CSS framework, rapid development, consistent design
- **Integration:** Built-in with Rails 8.1 via Tailwind standalone CLI
- **Configuration:** DaisyUI plugin + custom utilities in `app/assets/stylesheets/application.tailwind.css`
- **Benefits:** Fast builds, no Node.js dependencies for Tailwind itself (DaisyUI via npm)

**Component Architecture:**
- **Base UI Components:** ViewComponents wrapping DaisyUI (Button, Card, FormField, Alert, Badge)
- **Domain Components:** Higher-level components for feedback-specific features
- **Slot-based Composition:** `renders_one`, `renders_many` for flexible component APIs
- **ViewComponent Testing:** Unit tests with `ViewComponent::TestCase`
- **Optional Previews:** Built-in preview system at `/rails/view_components` (no Lookbook overhead)

**Example ViewComponent:**
```ruby
# app/components/ui/button_component.rb
class Ui::ButtonComponent < ViewComponent::Base
  def initialize(variant: :primary, size: :md, **options)
    @variant = variant
    @size = size
    @options = options
  end

  def call
    tag.button(content, class: button_classes, **@options)
  end

  private

  def button_classes
    ["btn", "btn-#{@variant}", size_class].compact.join(" ")
  end

  def size_class
    { xs: "btn-xs", sm: "btn-sm", md: "", lg: "btn-lg" }[@size]
  end
end
```

**Usage:**
```erb
<%= render Ui::ButtonComponent.new(variant: :primary, size: :lg) do %>
  Submit Feedback
<% end %>
```

### Forms & Validation

**Rails Form Helpers**
- **Why:** Built-in form helpers with CSRF protection, server-side validation
- **Integration:** `form_with` for Turbo-compatible forms, strong parameters for security

**ActiveModel Validations**
- **Why:** Comprehensive validation framework, custom validators
- **Usage:** Model-level validations, custom validators for complex rules
- **Benefits:** Automatic error handling, I18n support, composable validators

### Database & ORM

**SQLite 3.x**
- **Why:** Simple, reliable, single-file database perfect for moderate-scale applications
- **Performance:** Excellent read performance, sufficient for feedback platform scale
- **Backup:** Litestream for continuous replication to S3-compatible storage
- **Alternative:** Can upgrade to PostgreSQL if needed (same ActiveRecord interface)

**Litestream**
- **Why:** Continuous SQLite replication to DigitalOcean Spaces (S3-compatible)
- **Benefits:** Point-in-time recovery, disaster recovery, zero downtime backups
- **Configuration:** Replicates every 1-10 seconds to object storage

**ActiveRecord 8.1**
- **Why:** Rails ORM with excellent conventions, query interface, associations
- **Features Used:** Models, migrations, validations, callbacks, associations
- **Rationale:** Best ORM for Rails, AI-friendly patterns, comprehensive documentation

### Caching & Background Jobs

**Solid Stack (SolidQueue, SolidCache, SolidCable)**
- **Why:** SQLite-backed replacements for Redis, simpler deployment, no external dependencies
- **SolidQueue:** Background job processing (email delivery, AI processing)
- **SolidCache:** Application caching (rate limits, temporary data)
- **SolidCable:** WebSocket support for real-time features (future use)
- **Benefits:** Single database for entire stack, easier debugging, simpler deployment

**ActiveJob**
- **Why:** Rails abstraction for background jobs
- **Adapter:** SolidQueue (default in Rails 8.1)
- **Usage:** Email delivery, AI content processing, cleanup tasks

### External Services

**Resend** (SMTP)
- **Why:** Modern email API, excellent deliverability, great developer experience
- **Integration:** ActionMailer with SMTP configuration
- **Rationale:** Best email service for Rails developers, simple setup

**Anthropic SDK** (anthropic-ruby gem)
- **Model:** Claude Sonnet 4 (claude-sonnet-4-20250514)
- **Why:** Superior safety/moderation, excellent at content improvement
- **Usage:** Content safety checks, constructiveness improvement, style transformation
- **Alternative:** OpenAI GPT-4 (openai-ruby gem)

**OpenAI SDK** (ruby-openai gem)
- **Model:** GPT-4 (gpt-4)
- **Why:** Alternative AI provider for flexibility
- **Usage:** Same as Anthropic (safety checks, content improvement)
- **Auto-detection:** System checks for available API keys (Anthropic → OpenAI → Mock)

**Cloudflare Edge Protection**
- **Why:** Edge-level bot management without user friction
- **Integration:** Automatic with Cloudflare DNS/CDN setup
- **Features:** Bot Management, IP reputation, challenge pages, rate limiting
- **Rationale:** Handles all bot detection at edge, no application-level CAPTCHA needed

### Security

**Rails Built-in Security**
- **CSRF Protection:** Automatic with Rails form helpers
- **SQL Injection Prevention:** ActiveRecord parameterized queries
- **XSS Protection:** Automatic HTML escaping in ERB templates
- **Mass Assignment Protection:** Strong parameters

**Custom Security**
- **AES-256-GCM Encryption:** Email encryption at rest (`attr_encrypted` gem or custom implementation)
- **SHA-256 Hashing:** Email hashing for privacy-preserving lookups
- **SecureRandom:** UUID token generation for access control
- **Rate Limiting:** SolidCache-backed sliding window algorithm

### Monitoring & Logging

**Rails Logger**
- **Why:** Built-in structured logging with tagged logging support
- **Configuration:** Log level per environment, structured JSON logs in production
- **Usage:** Request logging, error tracking, debugging

**Error Tracking & APM Alternatives:**

*Option 1: AppSignal (Recommended for Rails)*
- **Gems:** `appsignal`
- **Features:** Rails-native APM, error tracking, performance monitoring, host metrics, custom dashboards
- **Pricing:** $49/month for 100k events
- **Best for:** Rails-first approach, simple setup, excellent Rails-specific insights
- **Integration:** One gem, automatic instrumentation, no code changes needed
- **Why:** Built specifically for Rails/Ruby, best developer experience for Rails apps

*Option 2: Honeybadger*
- **Gems:** `honeybadger`
- **Features:** Error tracking, uptime monitoring, cron monitoring, check-ins
- **Pricing:** $39/month for 100k events
- **Best for:** Ruby-focused teams, lightweight solution, affordable pricing
- **Integration:** Simple configuration, built-in queue monitoring
- **Why:** Ruby-native, focuses on core features without bloat

*Option 3: Sentry*
- **Gems:** `sentry-ruby`, `sentry-rails`
- **Features:** Full-featured APM, error tracking, performance, releases, session replay
- **Pricing:** $26/month for 100k events
- **Best for:** Multi-language teams, comprehensive features, larger organizations
- **Integration:** Automatic Rails integration with breadcrumbs, filters for sensitive data
- **Why:** Most mature platform, excellent for polyglot teams

**Kamal Healthchecks**
- **Why:** Built-in HTTP health checks for zero-downtime deployments
- **Configuration:** Custom health endpoint at `/up`

### Development Tools

**RuboCop**
- **Why:** Ruby linter and formatter, enforces style guide
- **Config:** Rails-specific rules, custom configurations
- **Plugins:** rubocop-rails, rubocop-performance, rubocop-minitest

**Brakeman**
- **Why:** Static security analysis for Rails applications
- **Usage:** Pre-deployment security scans, CI/CD integration

**Bullet**
- **Why:** Detects N+1 queries in development
- **Integration:** Alerts in logs and browser console

**Debug** (Ruby 3.1+ built-in)
- **Why:** Modern Ruby debugger, replaces pry
- **Usage:** Breakpoints, step debugging, REPL

**Minitest 5.x**
- **Why:** Rails default testing framework, simple, fast
- **Features Used:** Test cases, fixtures, assertions
- **Plugins:** minitest-reporters for better output

**Capybara 3.x**
- **Why:** Integration testing with browser simulation
- **Driver:** Selenium WebDriver for JavaScript tests
- **Usage:** End-to-end flows (submit feedback, view feedback, respond)

**Letter Opener** (development)
- **Why:** Preview emails in browser without sending
- **Integration:** Automatic in development mode
- **Usage:** Test email templates and content

### Deployment

**Kamal 2.x**
- **Why:** Zero-downtime deployments, Docker-based, simple configuration
- **Features:** Health checks, rolling deploys, accessories (Litestream)
- **Target:** Any VPS with SSH (DigitalOcean, Hetzner, AWS Lightsail)

**Docker**
- **Why:** Containerization for consistent environments
- **Image:** Ruby 3.3-slim with minimal dependencies
- **Size:** Optimized for fast deployments

**DigitalOcean Spaces** (S3-compatible)
- **Why:** SQLite backup storage via Litestream
- **Alternative:** Any S3-compatible storage (AWS S3, Backblaze B2, etc.)

---

## Version Matrix

| Technology | Version | Purpose |
|------------|---------|---------|
| Rails | 8.1.0.rc1 | Core framework |
| Ruby | 3.3.x | Language runtime |
| SQLite | 3.x | Primary database |
| Litestream | Latest | Database replication |
| SolidQueue | 1.x | Background jobs |
| SolidCache | 1.x | Application cache |
| Hotwire | Latest | Interactive UI |
| ViewComponent | 4.1.0+ | Component framework |
| DaisyUI | 5.x | UI component library |
| Tailwind CSS | v4 | Styling |
| Minitest | 5.x | Testing |
| Kamal | 2.x | Deployment |

---

## Development vs Production Parity

Rails 8.1 with Solid Stack provides excellent dev/prod parity:

✅ **Database:** SQLite in both environments (same adapter, same queries)
✅ **Cache:** SolidCache in both (no Redis required)
✅ **Jobs:** SolidQueue in both (no separate job server)
✅ **Email:** Letter Opener (dev) → Resend SMTP (prod), same ActionMailer interface
✅ **AI:** Mock provider (dev) → Anthropic/OpenAI (prod), same service object interface

This eliminates "works on my machine" issues and simplifies deployment.

---
