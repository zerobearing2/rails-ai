---
name: rails-ai:jobs-mailers
description: Use when setting up background jobs and email - SolidQueue, SolidCache, SolidCable, ActionMailer (TEAM RULE #1 - NEVER Sidekiq/Redis)
---

# Background Jobs and Email (Solid Stack + ActionMailer)

Configure background job processing, caching, WebSockets, and email delivery using Rails 8 defaults - SolidQueue, SolidCache, SolidCable, and ActionMailer. Zero external dependencies.

<when-to-use>
- Setting up ANY new Rails 8+ application
- Background job processing (TEAM RULE #1: NEVER Sidekiq/Redis)
- Application caching (TEAM RULE #1: NEVER Redis/Memcached)
- WebSocket/ActionCable setup (TEAM RULE #1: NEVER Redis)
- Sending transactional or notification emails
- Delivering emails asynchronously via background jobs
</when-to-use>

<benefits>
- **Zero External Dependencies** - No Redis, Memcached, or external services required
- **Simpler Deployments** - Database-backed, persistent, survives restarts
- **Rails 8 Convention** - Official defaults, production-ready out of the box
- **Easier Monitoring** - Query databases directly for job and cache status
- **Integrated Email** - ActionMailer works seamlessly with SolidQueue for async delivery
- **Testable** - Full test suite support for jobs and mailers
</benefits>

<standards>
- **TEAM RULE #1:** ALWAYS use Solid Stack (SolidQueue, SolidCache, SolidCable) - NEVER Sidekiq, Redis, or Memcached
- Use dedicated databases for queue, cache, and cable (separate from primary)
- Configure separate migration paths for each database (db/queue_migrate, db/cache_migrate, db/cable_migrate)
- ALWAYS deliver emails asynchronously with deliver_later (NOT deliver_now)
- Provide both HTML and text email templates
- Use *_url helpers (NOT *_path) for links in emails
- Implement queue prioritization in production
- Run migrations for ALL databases (primary, queue, cache, cable)
- Set default 'from' address in ApplicationMailer
- Create email previews for development
</standards>

## SolidQueue (TEAM RULE #1: NO Sidekiq/Redis)

<pattern name="solidqueue-basic-setup">
<description>Configure SolidQueue for background job processing</description>

<implementation>
**Environment Configuration:**
```ruby
# config/environments/{development,production}.rb
Rails.application.configure do
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
end
```

**Database Configuration:**
```yaml
# config/database.yml
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

production:
  primary:
    <<: *default
    database: storage/production.sqlite3
  queue:
    <<: *default
    database: storage/production_queue.sqlite3
    migrations_paths: db/queue_migrate
```

**Queue Configuration (Production Prioritization):**
```yaml
# config/queue.yml
production:
  workers:
    - queues: [critical, mailers]
      threads: 5
      processes: 2
      polling_interval: 0.1
    - queues: [default]
      threads: 3
      processes: 2
      polling_interval: 1
```
</implementation>

<why>Database-backed job processing with no external dependencies. Jobs are persistent and survive restarts. Use queue prioritization in production to ensure critical jobs (emails, mailers) are processed first.</why>
</pattern>

<antipattern>
<description>Using Sidekiq/Redis instead of Solid Stack - VIOLATES TEAM RULE #1</description>

<bad-example>
```ruby
# ❌ WRONG - VIOLATES TEAM RULE #1
gem 'sidekiq'
gem 'redis'

# config/environments/production.rb
config.active_job.queue_adapter = :sidekiq
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }

# config/cable.yml
production:
  adapter: redis
  url: <%= ENV['REDIS_URL'] %>
```
</bad-example>

<good-example>
```ruby
# ✅ CORRECT - Solid Stack (TEAM RULE #1)
# No gems needed - built into Rails 8

# config/environments/production.rb
config.active_job.queue_adapter = :solid_queue
config.cache_store = :solid_cache_store
config.solid_queue.connects_to = { database: { writing: :queue } }

# config/cable.yml
production:
  adapter: solid_cable
```
</good-example>

<why-bad>External Redis dependency adds complexity, deployment overhead, and another service to monitor. Violates TEAM RULE #1. Solid Stack is production-ready, persistent, and simpler to operate.</why-bad>
</antipattern>

<pattern name="job-monitoring">
<description>Monitor SolidQueue job status and health</description>

<implementation>
**Rails Console:**
```ruby
SolidQueue::Job.pending.count  # => 42
SolidQueue::Job.failed.count   # => 3
SolidQueue::Job.failed.each { |job| puts "#{job.class_name}: #{job.error}" }
```

**Health Check:**
```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def show
    render json: {
      queue_pending: SolidQueue::Job.pending.count,
      queue_failed: SolidQueue::Job.failed.count,
      oldest_pending_minutes: oldest_pending_age
    }
  end

  private

  def oldest_pending_age
    oldest = SolidQueue::Job.pending.order(:created_at).first
    return 0 unless oldest
    ((Time.current - oldest.created_at) / 60).round
  end
end
```
</implementation>

<why>Direct database access makes monitoring simple - no special tools needed. Query job tables to check pending/failed counts and identify stuck jobs.</why>
</pattern>

## SolidCache

<pattern name="solidcache-setup">
<description>Configure SolidCache for application caching</description>

<implementation>
**Configuration:**
```ruby
# config/environments/{development,production}.rb
config.cache_store = :solid_cache_store

# config/database.yml
production:
  cache:
    <<: *default
    database: storage/production_cache.sqlite3
    migrations_paths: db/cache_migrate
```

**Usage:**
```ruby
Rails.cache.fetch("user_#{user.id}", expires_in: 1.hour) { expensive_computation(user) }

# Fragment caching
<% cache @post do %><%= render @post %><% end %>
```

**Migrations:**
```bash
rails db:migrate:cache
```
</implementation>

<why>Database-backed caching with no Redis dependency. Persistent across restarts, easy to inspect and debug.</why>
</pattern>

## SolidCable

<pattern name="solidcable-setup">
<description>Configure SolidCable for ActionCable/WebSockets</description>

<implementation>
**Configuration:**
```yaml
# config/cable.yml
production:
  adapter: solid_cable

# config/database.yml
production:
  cable:
    <<: *default
    database: storage/production_cable.sqlite3
    migrations_paths: db/cable_migrate
```

**Usage:**
```ruby
# app/channels/notifications_channel.rb
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications_#{current_user.id}"
  end
end

# Broadcasting
ActionCable.server.broadcast("notifications_#{user.id}", { message: "New notification" })
```
</implementation>

<why>Database-backed WebSocket connections with no Redis dependency. Simple to deploy and monitor.</why>
</pattern>

<antipattern>
<description>Sharing database between primary and Solid Stack components</description>

<bad-example>
```yaml
# ❌ WRONG - All on same database creates contention
production:
  primary:
    database: storage/production.sqlite3
  queue:
    database: storage/production.sqlite3  # Same database!
  cache:
    database: storage/production.sqlite3  # Same database!
```
</bad-example>

<good-example>
```yaml
# ✅ CORRECT - Separate databases for isolation
production:
  primary:
    database: storage/production.sqlite3
  queue:
    database: storage/production_queue.sqlite3
    migrations_paths: db/queue_migrate
  cache:
    database: storage/production_cache.sqlite3
    migrations_paths: db/cache_migrate
  cable:
    database: storage/production_cable.sqlite3
    migrations_paths: db/cable_migrate
```
</good-example>

<why-bad>Sharing databases creates performance contention, makes it harder to scale, and couples concerns that should be isolated. Separate databases allow independent optimization and scaling.</why-bad>
</antipattern>

## Multi-Database Management

<pattern name="multi-database-operations">
<description>Manage migrations across all Solid Stack databases</description>

<implementation>
**Setup:**
```bash
rails db:create  # Creates all databases
rails db:migrate  # Migrates primary, queue, cache, cable
rails db:prepare  # Production: creates + migrates
```

**Individual Operations:**
```bash
rails db:migrate:{queue,cache,cable}
rails db:migrate:status:{queue,cache,cable}
rails db:rollback:queue
```
</implementation>

<why>Each database has independent migration path, allowing separate versioning and rollback per component.</why>
</pattern>

## ActionMailer Setup

<pattern name="actionmailer-basic-setup">
<description>Configure ActionMailer for email delivery</description>

<implementation>
**Mailer Class:**
```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "noreply@example.com"
  layout "mailer"
end

# app/mailers/notification_mailer.rb
class NotificationMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @login_url = login_url
    mail(to: user.email, subject: "Welcome to Our App")
  end

  def password_reset(user)
    @user = user
    @reset_url = password_reset_url(user.reset_token)
    mail(to: user.email, subject: "Password Reset Instructions")
  end
end
```

**HTML Template:**
```erb
<%# app/views/notification_mailer/welcome_email.html.erb %>
<h1>Welcome, <%= @user.name %>!</h1>
<p>Thanks for signing up. Get started by logging in:</p>
<%= link_to "Login Now", @login_url, class: "button" %>
```

**Text Template:**
```erb
<%# app/views/notification_mailer/welcome_email.text.erb %>
Welcome, <%= @user.name %>!

Thanks for signing up. Get started by logging in:
<%= @login_url %>
```

**Usage (Async with SolidQueue):**
```ruby
# In controller or service
NotificationMailer.welcome_email(@user).deliver_later
NotificationMailer.password_reset(@user).deliver_later(queue: :mailers)
```
</implementation>

<why>ActionMailer integrates seamlessly with SolidQueue for async delivery. Always use deliver_later to avoid blocking requests. Provide both HTML and text versions for compatibility.</why>
</pattern>

<antipattern>
<description>Using deliver_now in production (blocks HTTP request)</description>

<bad-example>
```ruby
# ❌ WRONG - Blocks HTTP request thread
def create
  @user = User.create!(user_params)
  NotificationMailer.welcome_email(@user).deliver_now  # Blocks!
  redirect_to @user
end
```
</bad-example>

<good-example>
```ruby
# ✅ CORRECT - Async delivery via SolidQueue
def create
  @user = User.create!(user_params)
  NotificationMailer.welcome_email(@user).deliver_later  # Non-blocking
  redirect_to @user
end
```
</good-example>

<why-bad>deliver_now blocks the HTTP request until SMTP completes, creating slow response times and poor user experience. deliver_later uses SolidQueue to send email in background.</why-bad>
</antipattern>

<pattern name="parameterized-mailers">
<description>Use .with() to pass parameters cleanly to mailers</description>

<implementation>
```ruby
class NotificationMailer < ApplicationMailer
  def custom_notification
    @user = params[:user]
    @message = params[:message]
    mail(to: @user.email, subject: params[:subject])
  end
end

# Usage
NotificationMailer.with(user: user, message: "Update", subject: "Alert").custom_notification.deliver_later
```
</implementation>

<why>Cleaner syntax, easier to read and modify, and works seamlessly with background jobs.</why>
</pattern>

## Email Templates

<pattern name="email-layouts">
<description>Shared layouts for consistent email branding</description>

<implementation>
```erb
<%# app/views/layouts/mailer.html.erb %>
<!DOCTYPE html>
<html>
  <head>
    <style>
      body { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; }
      .header { background-color: #4F46E5; color: white; padding: 20px; }
      .button { padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; }
    </style>
  </head>
  <body>
    <div class="header"><h1>Your App</h1></div>
    <%= yield %>
  </body>
</html>

<%# app/views/layouts/mailer.text.erb %>
<%= yield %>
```
</implementation>

<why>Consistent branding across all emails. Inline CSS ensures styling works across email clients.</why>
</pattern>

<pattern name="email-attachments">
<description>Attach files to emails (PDFs, CSVs, images)</description>

<implementation>
```ruby
class ReportMailer < ApplicationMailer
  def monthly_report(user, data)
    @user = user
    attachments["report.pdf"] = { mime_type: "application/pdf", content: generate_pdf(data) }
    attachments.inline["logo.png"] = File.read(Rails.root.join("app/assets/images/logo.png"))
    mail(to: user.email, subject: "Monthly Report")
  end
end

# In template: <%= image_tag attachments["logo.png"].url %>
```
</implementation>

<why>Attach reports, exports, or inline images. Inline attachments can be referenced in email body with image_tag.</why>
</pattern>

<antipattern>
<description>Using *_path helpers instead of *_url in emails (broken links)</description>

<bad-example>
```ruby
# ❌ WRONG - Relative path doesn't work in emails
def welcome_email(user)
  @user = user
  @login_url = login_path  # => "/login" (relative path)
  mail(to: user.email, subject: "Welcome")
end
```
</bad-example>

<good-example>
```ruby
# ✅ CORRECT - Full URL works in emails
def welcome_email(user)
  @user = user
  @login_url = login_url  # => "https://example.com/login" (absolute URL)
  mail(to: user.email, subject: "Welcome")
end

# Required configuration
# config/environments/production.rb
config.action_mailer.default_url_options = { host: "example.com", protocol: "https" }
```
</good-example>

<why-bad>Emails are viewed outside your application context, so relative paths don't work. Always use *_url helpers to generate absolute URLs.</why-bad>
</antipattern>

## Email Testing (letter_opener)

<pattern name="letter-opener-setup">
<description>Preview emails in browser during development without sending</description>

<implementation>
**Configuration:**
```ruby
# Gemfile
group :development do
  gem "letter_opener"
end

# config/environments/development.rb
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: "smtp.sendgrid.net",
  port: 587,
  user_name: Rails.application.credentials.dig(:smtp, :username),
  password: Rails.application.credentials.dig(:smtp, :password),
  authentication: :plain
}
config.action_mailer.default_url_options = { host: "example.com", protocol: "https" }
```

**Mailer Previews:**
```ruby
# test/mailers/previews/notification_mailer_preview.rb
class NotificationMailerPreview < ActionMailer::Preview
  # Preview at http://localhost:3000/rails/mailers/notification_mailer/welcome_email
  def welcome_email
    NotificationMailer.welcome_email(User.first || User.new(name: "Test", email: "test@example.com"))
  end
end
```
</implementation>

<why>letter_opener opens emails in browser during development - no SMTP setup needed. Mailer previews at /rails/mailers let you see all email variations without sending.</why>
</pattern>

<pattern name="mailer-testing">
<description>Test email delivery and content with ActionMailer::TestCase</description>

<implementation>
```ruby
# test/mailers/notification_mailer_test.rb
class NotificationMailerTest < ActionMailer::TestCase
  test "welcome_email sends with correct attributes" do
    email = NotificationMailer.welcome_email(users(:alice))
    assert_emails 1 { email.deliver_now }
    assert_equal [users(:alice).email], email.to
    assert_includes email.html_part.body.to_s, users(:alice).name
  end

  test "delivers via background job" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, queue: "mailers") do
      NotificationMailer.welcome_email(users(:alice)).deliver_later(queue: :mailers)
    end
  end
end
```
</implementation>

<why>Test email delivery, content, and background job enqueuing. Verify recipients, subjects, and that emails are queued properly.</why>
</pattern>

## Job Monitoring

<pattern name="production-monitoring">
<description>Monitor job queue health in production</description>

<implementation>
```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def show
    render json: {
      queue_pending: SolidQueue::Job.pending.count,
      queue_failed: SolidQueue::Job.failed.count,
      oldest_pending_minutes: oldest_pending_age
    }
  end

  private

  def oldest_pending_age
    oldest = SolidQueue::Job.pending.order(:created_at).first
    return 0 unless oldest
    ((Time.current - oldest.created_at) / 60).round
  end
end

# app/jobs/metrics_job.rb
class MetricsJob < ApplicationJob
  def perform
    pending = SolidQueue::Job.pending.count
    failed = SolidQueue::Job.failed.count
    Rails.logger.info("Queue: pending=#{pending} failed=#{failed}")
    Rails.logger.warn("High backlog") if pending > 1000
    Rails.logger.error("Many failures") if failed > 50
  end
end
```
</implementation>

<why>Monitor queue health via database queries. Alert on high pending counts or failures. No special monitoring tools needed.</why>
</pattern>

<testing>
```ruby
# test/integration/solid_stack_test.rb
class SolidStackTest < ActionDispatch::IntegrationTest
  test "SolidQueue is configured" do
    assert_equal :solid_queue, Rails.configuration.active_job.queue_adapter
  end

  test "SolidCache is configured" do
    assert_instance_of ActiveSupport::Cache::SolidCacheStore, Rails.cache
  end

  test "cache read/write works" do
    Rails.cache.write("test_key", "test_value")
    assert_equal "test_value", Rails.cache.read("test_key")
  end

  test "jobs are persisted in queue database" do
    TestJob.perform_later
    assert SolidQueue::Job.pending.exists?
  end

  test "failed jobs are recorded" do
    assert_raises(StandardError) do
      perform_enqueued_jobs { FailingJob.perform_later }
    end
    assert SolidQueue::Job.failed.exists?
  end
end

# test/jobs/sample_job_test.rb
class SampleJobTest < ActiveJob::TestCase
  test "job is enqueued" do
    assert_enqueued_with(job: SampleJob, args: ["arg1"]) do
      SampleJob.perform_later("arg1")
    end
  end

  test "job is performed" do
    perform_enqueued_jobs do
      SampleJob.perform_later("test")
    end
    # Assert side effects
  end
end
```
</testing>

<related-skills>
- rails-ai:configuration - Environment-specific configuration
- rails-ai:testing - Testing jobs and mailers
- rails-ai:models - Background jobs for model operations
</related-skills>

<resources>
- [SolidQueue GitHub](https://github.com/rails/solid_queue)
- [SolidCache GitHub](https://github.com/rails/solid_cache)
- [SolidCable GitHub](https://github.com/rails/solid_cable)
- [Rails Guides - Action Mailer Basics](https://guides.rubyonrails.org/action_mailer_basics.html)
- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
</resources>
