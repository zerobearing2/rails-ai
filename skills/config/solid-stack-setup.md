---
name: solid-stack-setup
domain: config
dependencies: []
version: 1.0
rails_version: 8.1+
criticality: CRITICAL
---

# Solid Stack Setup (Rails 8 Defaults)

Configure SolidQueue, SolidCache, and SolidCable - the Rails 8 default stack for background jobs, caching, and WebSockets. No Redis, no external dependencies.

<when-to-use>
- Setting up ANY new Rails 8+ application
- Configuring background job processing
- Implementing application-level caching
- Setting up ActionCable for real-time features
- Deploying to production (especially with Kamal)
- TEAM RULE #1: ALWAYS use Solid Stack (NEVER Sidekiq, Redis, Memcached)
</when-to-use>

<benefits>
- **Zero External Dependencies** - No Redis, Memcached, or external services
- **Simpler Deployments** - Fewer moving parts, easier to manage
- **Database-Backed** - Persistent, durable, survives restarts
- **Rails 8 Convention** - Official default, best-practice stack
- **Local Development** - No service installation required
- **SQLite Compatible** - Perfect for Kamal deployments
- **Production Ready** - Battle-tested by Rails core team
- **Easier Monitoring** - Query databases directly for job status
</benefits>

<standards>
- ALWAYS use SolidQueue for background jobs (NOT Sidekiq)
- ALWAYS use SolidCache for caching (NOT Redis/Memcached)
- ALWAYS use SolidCable for ActionCable (NOT Redis)
- Use dedicated databases for queue, cache, and cable
- Configure separate migration paths for each database
- Implement queue prioritization in production
- Monitor job failures and queue depths
- Use environment-prefixed queue names
- Run migrations for ALL databases
</standards>

## SolidQueue Configuration

<pattern name="solidqueue-basic-setup">
<description>Configure SolidQueue for background job processing</description>

**Environment Configuration:**
```ruby
# config/environments/development.rb
Rails.application.configure do
  # Use SolidQueue for background jobs
  config.active_job.queue_adapter = :solid_queue

  # Connect to dedicated queue database
  config.solid_queue.connects_to = { database: { writing: :queue } }
end

# config/environments/production.rb
Rails.application.configure do
  # Replace default in-process queuing with Solid Queue
  config.active_job.queue_adapter = :solid_queue

  # Connect to queue database
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

development:
  primary:
    <<: *default
    database: storage/development.sqlite3

  # Dedicated database for SolidQueue
  queue:
    <<: *default
    database: storage/development_queue.sqlite3
    migrations_paths: db/queue_migrate

production:
  primary:
    <<: *default
    database: storage/production.sqlite3

  # Dedicated queue database
  queue:
    <<: *default
    database: storage/production_queue.sqlite3
    migrations_paths: db/queue_migrate
```
</pattern>

<pattern name="solidqueue-worker-configuration">
<description>Configure queue workers and dispatchers</description>

**Queue Configuration File:**
```yaml
# config/queue.yml
default: &default
  dispatchers:
    - polling_interval: 1
      batch_size: 500

  workers:
    - queues: "*"  # Process all queues
      threads: 3
      processes: <%= ENV.fetch("JOB_CONCURRENCY", 1) %>
      polling_interval: 0.1

development:
  <<: *default

production:
  <<: *default
  workers:
    # Prioritize specific queues
    - queues: [active_storage_analysis, active_storage_purge]
      threads: 3
      polling_interval: 5

    - queues: [mailers]
      threads: 3
      polling_interval: 1

    - queues: ["*"]  # All other queues
      threads: 3
      processes: <%= ENV.fetch("JOB_CONCURRENCY", 2) %>
      polling_interval: 0.1
```

**Application Configuration:**
```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Prefix queue names with environment
    config.active_job.queue_name_prefix = Rails.env
  end
end

# Development: development_default, development_mailers
# Production: production_default, production_mailers
```
</pattern>

<pattern name="solidqueue-monitoring">
<description>Monitor SolidQueue job status and health</description>

**Command Line:**
```bash
# Check SolidQueue status
rails solid_queue:status

# Run migrations for queue database
rails db:migrate:queue
```

**Rails Console:**
```ruby
# View pending jobs
SolidQueue::Job.pending.count
# => 42

# View failed jobs
SolidQueue::Job.failed.count
# => 3

# Inspect failed jobs
SolidQueue::Job.failed.each do |job|
  puts "Job: #{job.class_name}, Error: #{job.error}"
end

# View jobs by queue
SolidQueue::Job.where(queue_name: "mailers").count
# => 15

# Clear failed jobs (after fixing issue)
SolidQueue::Job.failed.destroy_all
```

**Monitoring in Application:**
```ruby
# app/models/job_monitor.rb
class JobMonitor
  def self.queue_health
    {
      pending: SolidQueue::Job.pending.count,
      failed: SolidQueue::Job.failed.count,
      oldest_pending: SolidQueue::Job.pending.order(:created_at).first&.created_at,
      queues: queue_breakdown
    }
  end

  def self.queue_breakdown
    SolidQueue::Job.pending.group(:queue_name).count
  end
end
```
</pattern>

## SolidCache Configuration

<pattern name="solidcache-setup">
<description>Configure SolidCache for application caching</description>

**Environment Configuration:**
```ruby
# config/environments/development.rb
Rails.application.configure do
  # Use SolidCache for caching
  config.cache_store = :solid_cache_store
end

# config/environments/production.rb
Rails.application.configure do
  # Use SolidCache in production
  config.cache_store = :solid_cache_store
end
```

**Database Configuration:**
```yaml
# config/database.yml (add to existing configuration)
development:
  primary:
    <<: *default
    database: storage/development.sqlite3

  queue:
    <<: *default
    database: storage/development_queue.sqlite3
    migrations_paths: db/queue_migrate

  # Dedicated database for SolidCache
  cache:
    <<: *default
    database: storage/development_cache.sqlite3
    migrations_paths: db/cache_migrate

production:
  primary:
    <<: *default
    database: storage/production.sqlite3

  queue:
    <<: *default
    database: storage/production_queue.sqlite3
    migrations_paths: db/queue_migrate

  # Dedicated cache database
  cache:
    <<: *default
    database: storage/production_cache.sqlite3
    migrations_paths: db/cache_migrate
```

**Usage:**
```ruby
# Standard Rails caching works automatically
Rails.cache.fetch("user_#{user.id}", expires_in: 1.hour) do
  expensive_computation(user)
end

# Fragment caching in views
<%# app/views/posts/show.html.erb %>
<% cache @post do %>
  <%= render @post %>
<% end %>
```
</pattern>

<pattern name="solidcache-migrations">
<description>Run cache database migrations</description>

**Migration Commands:**
```bash
# Migrate cache database
rails db:migrate:cache

# Check cache database status
rails db:migrate:status:cache

# Rollback cache migrations
rails db:rollback:cache
```
</pattern>

## SolidCable Configuration

<pattern name="solidcable-setup">
<description>Configure SolidCable for ActionCable/WebSockets</description>

**Cable Configuration:**
```yaml
# config/cable.yml
development:
  adapter: solid_cable  # Use SolidCable instead of async

test:
  adapter: test

production:
  adapter: solid_cable  # Use SolidCable instead of Redis
```

**Database Configuration:**
```yaml
# config/database.yml (complete 4-database setup)
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  primary:
    <<: *default
    database: storage/development.sqlite3

  queue:
    <<: *default
    database: storage/development_queue.sqlite3
    migrations_paths: db/queue_migrate

  cache:
    <<: *default
    database: storage/development_cache.sqlite3
    migrations_paths: db/cache_migrate

  cable:
    <<: *default
    database: storage/development_cable.sqlite3
    migrations_paths: db/cable_migrate

production:
  primary:
    <<: *default
    database: storage/production.sqlite3

  queue:
    <<: *default
    database: storage/production_queue.sqlite3
    migrations_paths: db/queue_migrate

  cache:
    <<: *default
    database: storage/production_cache.sqlite3
    migrations_paths: db/cache_migrate

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

# Broadcasting to channel
ActionCable.server.broadcast(
  "notifications_#{user.id}",
  { message: "New notification" }
)
```
</pattern>

## Multi-Database Management

<pattern name="multi-database-migrations">
<description>Manage migrations across all Solid Stack databases</description>

**Migrate All Databases:**
```bash
# Run migrations for ALL databases at once
rails db:migrate

# This automatically migrates:
# - primary (db/migrate/)
# - queue (db/queue_migrate/)
# - cache (db/cache_migrate/)
# - cable (db/cable_migrate/)
```

**Migrate Specific Databases:**
```bash
# Migrate individual databases
rails db:migrate:queue
rails db:migrate:cache
rails db:migrate:cable

# Check migration status
rails db:migrate:status:queue
rails db:migrate:status:cache
rails db:migrate:status:cable

# Rollback specific database
rails db:rollback:queue
```

**Create Database Migrations:**
```bash
# SolidQueue migrations go to db/queue_migrate/
# SolidCache migrations go to db/cache_migrate/
# SolidCable migrations go to db/cable_migrate/

# Initial setup runs automatically via generators
```
</pattern>

<pattern name="database-setup-new-environments">
<description>Set up Solid Stack databases for new environments</description>

**Complete Setup:**
```bash
# Create all databases
rails db:create

# Run all migrations
rails db:migrate

# Seed primary database (if needed)
rails db:seed

# Verify all databases exist
rails db:migrate:status          # primary
rails db:migrate:status:queue    # queue
rails db:migrate:status:cache    # cache
rails db:migrate:status:cable    # cable
```

**Production Deployment:**
```bash
# In production (via Kamal or similar)
rails db:prepare  # Creates databases and runs migrations

# Verify setup
rails runner "puts SolidQueue::Job.count"     # Should not error
rails runner "puts Rails.cache.write('test', 'ok')"  # Should return true
```
</pattern>

## Production Configuration

<pattern name="production-optimization">
<description>Optimize Solid Stack for production workloads</description>

**Queue Concurrency:**
```bash
# Set via environment variables
export JOB_CONCURRENCY=4  # Number of worker processes

# Or in Kamal/deployment configuration
env:
  JOB_CONCURRENCY: 4
  RAILS_MAX_THREADS: 5
```

**Database Connection Pools:**
```yaml
# config/database.yml
production:
  primary:
    <<: *default
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

  queue:
    <<: *default
    pool: <%= ENV.fetch("QUEUE_POOL_SIZE") { 10 } %>  # Higher for workers

  cache:
    <<: *default
    pool: <%= ENV.fetch("CACHE_POOL_SIZE") { 5 } %>

  cable:
    <<: *default
    pool: <%= ENV.fetch("CABLE_POOL_SIZE") { 5 } %>
```

**Queue Prioritization:**
```yaml
# config/queue.yml (production)
production:
  <<: *default
  workers:
    # High priority - process immediately
    - queues: [critical, mailers]
      threads: 5
      processes: 2
      polling_interval: 0.1

    # Medium priority
    - queues: [default, active_storage_analysis]
      threads: 3
      processes: 2
      polling_interval: 1

    # Low priority - background cleanup
    - queues: [low_priority, active_storage_purge]
      threads: 2
      processes: 1
      polling_interval: 5
```
</pattern>

<pattern name="production-monitoring">
<description>Monitor Solid Stack health in production</description>

**Health Check Endpoint:**
```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def show
    health = {
      database: check_database,
      queue: check_queue,
      cache: check_cache,
      cable: check_cable
    }

    status = health.values.all? ? :ok : :service_unavailable
    render json: health, status: status
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue
    false
  end

  def check_queue
    SolidQueue::Job.pending.count >= 0
    true
  rescue
    false
  end

  def check_cache
    Rails.cache.write("health_check", Time.current)
    Rails.cache.read("health_check").present?
  rescue
    false
  end

  def check_cable
    # SolidCable is healthy if we can query its database
    ApplicationRecord.connected_to(role: :writing, database: :cable) do
      ActiveRecord::Base.connection.execute("SELECT 1")
    end
    true
  rescue
    false
  end
end
```

**Metrics Collection:**
```ruby
# app/jobs/metrics_job.rb
class MetricsJob < ApplicationJob
  queue_as :default

  def perform
    # Collect queue metrics
    pending_jobs = SolidQueue::Job.pending.count
    failed_jobs = SolidQueue::Job.failed.count

    # Log or send to monitoring service
    Rails.logger.info("Queue Metrics: pending=#{pending_jobs} failed=#{failed_jobs}")

    # Could integrate with Prometheus, Datadog, etc.
  end
end

# Schedule regularly
# every 1.minute do
#   MetricsJob.perform_later
# end
```
</pattern>

<antipatterns>
<antipattern>
<description>Using Sidekiq instead of SolidQueue</description>
<reason>Violates TEAM_RULES.md Rule #1 - adds Redis dependency unnecessarily</reason>
<bad-example>
```ruby
# ❌ WRONG - Do not use Sidekiq
# Gemfile
gem 'sidekiq'

# config/application.rb
config.active_job.queue_adapter = :sidekiq
```
</bad-example>
<good-example>
```ruby
# ✅ CORRECT - Use SolidQueue (Rails 8 default)
# config/application.rb
config.active_job.queue_adapter = :solid_queue
config.solid_queue.connects_to = { database: { writing: :queue } }
```
</good-example>
</antipattern>

<antipattern>
<description>Using Redis for caching</description>
<reason>Violates TEAM_RULES.md Rule #1 - unnecessary external dependency</reason>
<bad-example>
```ruby
# ❌ WRONG - Do not use Redis
# Gemfile
gem 'redis'

# config/environments/production.rb
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
```
</bad-example>
<good-example>
```ruby
# ✅ CORRECT - Use SolidCache
# config/environments/production.rb
config.cache_store = :solid_cache_store

# config/database.yml
production:
  cache:
    adapter: sqlite3
    database: storage/production_cache.sqlite3
    migrations_paths: db/cache_migrate
```
</good-example>
</antipattern>

<antipattern>
<description>Using async adapter for ActionCable in production</description>
<reason>Loses messages on restart, doesn't scale across servers</reason>
<bad-example>
```yaml
# ❌ WRONG - Async adapter is not production-ready
# config/cable.yml
production:
  adapter: async
```
</bad-example>
<good-example>
```yaml
# ✅ CORRECT - Use SolidCable for production
# config/cable.yml
production:
  adapter: solid_cable
```
</good-example>
</antipattern>

<antipattern>
<description>Sharing database between primary and queue/cache/cable</description>
<reason>Reduces performance, creates contention, harder to scale</reason>
<bad-example>
```yaml
# ❌ WRONG - Using same database for everything
# config/database.yml
production:
  primary:
    database: storage/production.sqlite3

  queue:
    database: storage/production.sqlite3  # Same as primary!
```
</bad-example>
<good-example>
```yaml
# ✅ CORRECT - Dedicated databases
# config/database.yml
production:
  primary:
    database: storage/production.sqlite3

  queue:
    database: storage/production_queue.sqlite3  # Separate
    migrations_paths: db/queue_migrate
```
</good-example>
</antipattern>

<antipattern>
<description>Not configuring queue prioritization</description>
<reason>Critical jobs can get stuck behind low-priority bulk operations</reason>
<bad-example>
```yaml
# ❌ WRONG - All queues treated equally
# config/queue.yml
production:
  workers:
    - queues: "*"
      threads: 3
```
</bad-example>
<good-example>
```yaml
# ✅ CORRECT - Prioritize critical queues
# config/queue.yml
production:
  workers:
    - queues: [critical, mailers]  # Process first
      threads: 5
      polling_interval: 0.1

    - queues: ["*"]  # All other queues
      threads: 3
      polling_interval: 1
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test Solid Stack configuration in integration tests:

```ruby
# test/integration/solid_stack_test.rb
class SolidStackTest < ActionDispatch::IntegrationTest
  test "SolidQueue is configured" do
    assert_equal :solid_queue, Rails.configuration.active_job.queue_adapter
  end

  test "SolidCache is configured" do
    assert_instance_of ActiveSupport::Cache::SolidCacheStore,
                       Rails.cache
  end

  test "can write and read from cache" do
    Rails.cache.write("test_key", "test_value")
    assert_equal "test_value", Rails.cache.read("test_key")
  end

  test "can enqueue jobs" do
    assert_enqueued_with(job: TestJob) do
      TestJob.perform_later
    end
  end

  test "jobs are persisted in queue database" do
    TestJob.perform_later

    assert SolidQueue::Job.pending.exists?
  end
end

# test/jobs/solid_queue_job_test.rb
class SolidQueueJobTest < ActiveJob::TestCase
  test "job executes successfully" do
    result = nil

    perform_enqueued_jobs do
      TestJob.perform_later("test_arg")
    end

    # Verify job completed (check side effects)
    assert SolidQueue::Job.where(class_name: "TestJob").none? { |j| j.pending? }
  end

  test "failed jobs are recorded" do
    TestJob.stub :perform, -> { raise "Error" } do
      assert_raises(StandardError) do
        perform_enqueued_jobs do
          TestJob.perform_later
        end
      end
    end

    assert SolidQueue::Job.failed.exists?
  end
end

# test/system/cable_connection_test.rb
class CableConnectionTest < ApplicationSystemTestCase
  test "can subscribe to channels" do
    visit root_path

    # Verify ActionCable connection
    assert_selector "[data-cable-connected='true']"
  end
end
```
</testing>

<related-skills>
- environment-configuration - Environment-specific settings
- credentials-management - Secrets and credentials
- initializers-best-practices - Rails initialization
- kamal-deployment - Production deployment with Kamal
</related-skills>

<resources>
- [SolidQueue GitHub](https://github.com/rails/solid_queue)
- [SolidCache GitHub](https://github.com/rails/solid_cache)
- [SolidCable GitHub](https://github.com/rails/solid_cable)
- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
- [Rails Guides - Active Job](https://guides.rubyonrails.org/active_job_basics.html)
- [Rails Guides - Caching](https://guides.rubyonrails.org/caching_with_rails.html)
- [Rails Guides - Action Cable](https://guides.rubyonrails.org/action_cable_overview.html)
</resources>
