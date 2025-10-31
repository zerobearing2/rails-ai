---
name: solid-stack-setup
domain: config
dependencies: []
version: 1.0
rails_version: 8.1+
criticality: CRITICAL

# Team rules enforcement
enforces_team_rule:
  - rule_id: 1
    rule_name: "Solid Stack Only"
    severity: critical
    violation_triggers: [sidekiq, redis, memcached, resque]
    enforcement_action: REJECT
---

# Solid Stack Setup (Rails 8 Defaults)

Configure SolidQueue, SolidCache, and SolidCable - the Rails 8 default stack for background jobs, caching, and WebSockets. No Redis, no external dependencies.

<when-to-use>
- Setting up ANY new Rails 8+ application
- Background jobs, caching, or ActionCable configuration
- TEAM RULE #1: ALWAYS use Solid Stack (NEVER Sidekiq, Redis, Memcached)
</when-to-use>

<benefits>
- **Zero External Dependencies** - No Redis, Memcached, or external services
- **Simpler Deployments** - Database-backed, persistent, survives restarts
- **Rails 8 Convention** - Official default, production-ready
- **Easier Monitoring** - Query databases directly for job status
</benefits>

<standards>
- ALWAYS use SolidQueue for background jobs (NOT Sidekiq)
- ALWAYS use SolidCache for caching (NOT Redis/Memcached)
- ALWAYS use SolidCable for ActionCable (NOT Redis)
- Use dedicated databases for queue, cache, and cable
- Configure separate migration paths for each database
- Implement queue prioritization in production
- Run migrations for ALL databases
</standards>

## SolidQueue Configuration

<pattern name="solidqueue-basic-setup">
<description>Configure SolidQueue for background job processing</description>

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

development:
  primary:
    <<: *default
    database: storage/development.sqlite3
  queue:
    <<: *default
    database: storage/development_queue.sqlite3
    migrations_paths: db/queue_migrate

production:
  primary:
    <<: *default
    database: storage/production.sqlite3
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
    - queues: "*"
      threads: 3
      processes: <%= ENV.fetch("JOB_CONCURRENCY", 1) %>
      polling_interval: 0.1

development:
  <<: *default

production:
  <<: *default
  workers:
    - queues: [mailers, active_storage_analysis]
      threads: 3
      polling_interval: 1
    - queues: ["*"]
      threads: 3
      processes: <%= ENV.fetch("JOB_CONCURRENCY", 2) %>
      polling_interval: 0.1
```

**Application Configuration:**
```ruby
# config/application.rb
config.active_job.queue_name_prefix = Rails.env
# Creates: development_default, production_mailers, etc.
```
</pattern>
</invoke>

<pattern name="solidqueue-monitoring">
<description>Monitor SolidQueue job status and health</description>

**Command Line:**
```bash
rails solid_queue:status
rails db:migrate:queue
```

**Rails Console:**
```ruby
SolidQueue::Job.pending.count  # => 42
SolidQueue::Job.failed.count   # => 3
SolidQueue::Job.failed.each { |job| puts "#{job.class_name}: #{job.error}" }
SolidQueue::Job.where(queue_name: "mailers").count
SolidQueue::Job.failed.destroy_all  # After fixing issue
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
      queues: SolidQueue::Job.pending.group(:queue_name).count
    }
  end
end
```
</pattern>

## SolidCache Configuration

<pattern name="solidcache-setup">
<description>Configure SolidCache for application caching</description>

**Environment Configuration:**
```ruby
# config/environments/{development,production}.rb
config.cache_store = :solid_cache_store
```

**Database Configuration:**
```yaml
# config/database.yml (add to existing)
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
```

**Usage:**
```ruby
Rails.cache.fetch("user_#{user.id}", expires_in: 1.hour) { expensive_computation(user) }

# Fragment caching
<% cache @post do %>
  <%= render @post %>
<% end %>
```
</pattern>

<pattern name="solidcache-migrations">
<description>Run cache database migrations</description>

```bash
rails db:migrate:cache
rails db:migrate:status:cache
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
  adapter: solid_cable
test:
  adapter: test
production:
  adapter: solid_cable
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
  # ... (same structure as development)
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
</pattern>

## Multi-Database Management

<pattern name="multi-database-migrations">
<description>Manage migrations across all Solid Stack databases</description>

**Migrate All Databases:**
```bash
rails db:migrate  # Migrates primary, queue, cache, cable
```

**Migrate Specific Databases:**
```bash
rails db:migrate:{queue,cache,cable}
rails db:migrate:status:{queue,cache,cable}
rails db:rollback:queue
```
</pattern>

<pattern name="database-setup-new-environments">
<description>Set up Solid Stack databases for new environments</description>

**Complete Setup:**
```bash
rails db:create
rails db:migrate
rails db:seed  # If needed

# Verify all databases
rails db:migrate:status:{primary,queue,cache,cable}
```

**Production Deployment:**
```bash
rails db:prepare  # Creates databases and runs migrations
rails runner "puts SolidQueue::Job.count"  # Verify
```
</pattern>

## Production Configuration

<pattern name="production-optimization">
<description>Optimize Solid Stack for production workloads</description>

**Queue Concurrency:**
```bash
export JOB_CONCURRENCY=4
export RAILS_MAX_THREADS=5
```

**Database Connection Pools:**
```yaml
# config/database.yml
production:
  primary:
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  queue:
    pool: <%= ENV.fetch("QUEUE_POOL_SIZE") { 10 } %>
  cache:
    pool: <%= ENV.fetch("CACHE_POOL_SIZE") { 5 } %>
  cable:
    pool: <%= ENV.fetch("CABLE_POOL_SIZE") { 5 } %>
```

**Queue Prioritization:**
```yaml
# config/queue.yml (production)
production:
  workers:
    - queues: [critical, mailers]
      threads: 5
      processes: 2
      polling_interval: 0.1
    - queues: [default, active_storage_analysis]
      threads: 3
      processes: 2
      polling_interval: 1
    - queues: [low_priority, active_storage_purge]
      threads: 2
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
      cache: check_cache
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
end
```

**Metrics Collection:**
```ruby
# app/jobs/metrics_job.rb
class MetricsJob < ApplicationJob
  def perform
    pending = SolidQueue::Job.pending.count
    failed = SolidQueue::Job.failed.count
    Rails.logger.info("Queue: pending=#{pending} failed=#{failed}")
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Using Sidekiq/Redis instead of Solid Stack</description>
<reason>Violates TEAM_RULES.md Rule #1 - adds unnecessary external dependencies</reason>
<bad-example>
```ruby
# ❌ WRONG
gem 'sidekiq'
config.active_job.queue_adapter = :sidekiq
config.cache_store = :redis_cache_store
```
</bad-example>
<good-example>
```ruby
# ✅ CORRECT
config.active_job.queue_adapter = :solid_queue
config.cache_store = :solid_cache_store
```
</good-example>
</antipattern>

<antipattern>
<description>Sharing database between primary and Solid Stack</description>
<reason>Reduces performance, creates contention, harder to scale</reason>
<bad-example>
```yaml
# ❌ WRONG
production:
  primary:
    database: storage/production.sqlite3
  queue:
    database: storage/production.sqlite3  # Same!
```
</bad-example>
<good-example>
```yaml
# ✅ CORRECT
production:
  primary:
    database: storage/production.sqlite3
  queue:
    database: storage/production_queue.sqlite3  # Separate
    migrations_paths: db/queue_migrate
```
</good-example>
</antipattern>
</antipatterns>

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
    TestJob.stub :perform, -> { raise "Error" } do
      assert_raises(StandardError) { perform_enqueued_jobs { TestJob.perform_later } }
    end
    assert SolidQueue::Job.failed.exists?
  end
end
```
</testing>

<related-skills>
- environment-configuration - Environment-specific settings
- credentials-management - Secrets and credentials
- kamal-deployment - Production deployment with Kamal
</related-skills>

<resources>
- [SolidQueue GitHub](https://github.com/rails/solid_queue)
- [SolidCache GitHub](https://github.com/rails/solid_cache)
- [SolidCable GitHub](https://github.com/rails/solid_cable)
- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
</resources>
