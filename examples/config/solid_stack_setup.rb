# Solid Stack Configuration (Rails 8 Defaults)
# Reference: TEAM_RULES.md Rule #1, Rails Guides
# Category: CRITICAL CONFIGURATION

# ============================================================================
# TEAM_RULES.md Rule #1: ALWAYS use Solid Stack (SolidQueue, SolidCache, SolidCable)
# NEVER use: Sidekiq, Redis, Memcached
# ============================================================================

# ============================================================================
# SolidQueue Configuration
# ============================================================================

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

# ============================================================================
# Database Configuration for SolidQueue
# ============================================================================

# config/database.yml
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

# ============================================================================
# SolidQueue Configuration File
# ============================================================================

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

# ============================================================================
# SolidCache Configuration
# ============================================================================

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

# ============================================================================
# Database Configuration for SolidCache
# ============================================================================

# config/database.yml
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

# ============================================================================
# SolidCable Configuration (ActionCable)
# ============================================================================

# config/cable.yml
development:
  adapter: solid_cable  # Use SolidCable instead of async

test:
  adapter: test

production:
  adapter: solid_cable  # Use SolidCable instead of Redis

# ============================================================================
# Database Configuration for SolidCable
# ============================================================================

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

# ============================================================================
# Running Migrations for All Databases
# ============================================================================

# Migrate all databases at once
rails db:migrate
# This automatically migrates:
# - primary (db/migrate/)
# - queue (db/queue_migrate/)
# - cache (db/cache_migrate/)
# - cable (db/cable_migrate/)

# Migrate specific database
rails db:migrate:queue
rails db:migrate:cache
rails db:migrate:cable

# ============================================================================
# Active Job Queue Naming
# ============================================================================

# config/application.rb
module FeedbackApp
  class Application < Rails::Application
    # Prefix queue names with environment
    config.active_job.queue_name_prefix = Rails.env
  end
end

# Development: development_default, development_mailers
# Production: production_default, production_mailers

# ============================================================================
# Monitoring SolidQueue
# ============================================================================

# Check SolidQueue status
rails solid_queue:status

# View pending jobs
rails console
SolidQueue::Job.pending.count
SolidQueue::Job.failed.count

# ============================================================================
# Benefits of Solid Stack
# ============================================================================

# ✅ No external dependencies (Redis, Memcached)
# ✅ Simpler deployment (fewer moving parts)
# ✅ Database-backed (persistent, durable)
# ✅ Rails 8 convention (official default)
# ✅ Easier local development (no Redis to install)
# ✅ Better for small-medium apps
# ✅ SQLite compatible (perfect for Kamal deployments)

# ============================================================================
# RULE: ALWAYS use Solid Stack (TEAM_RULES.md Rule #1)
# NEVER: Add Sidekiq, Redis, or Memcached gems
# ENFORCE: rails-config agent will reject non-Solid Stack proposals
# ============================================================================
