---
skill: jobs
category: reference
description: Mission Control Jobs setup and authentication patterns
---

# Mission Control Jobs - Complete Setup Guide

Mission Control Jobs provides a production-ready web dashboard for monitoring and managing SolidQueue background jobs. This guide covers complete setup for development through production deployment with team access.

## Quick Start

### 1. Add Gem

```ruby
# Gemfile
gem "mission_control-jobs"
```

```bash
bundle install
```

### 2. Mount Engine with Authentication

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Production: Require admin authentication
  if Rails.env.production?
    authenticate :user, ->(user) { user.admin? } do
      mount MissionControl::Jobs::Engine, at: "/jobs"
    end
  else
    # Development/Staging: Open access or HTTP Basic Auth
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
end
```

### 3. Configure (Optional)

```ruby
# config/initializers/mission_control.rb
MissionControl::Jobs.configure do |config|
  # Job retention periods
  config.finished_jobs_retention_period = 14.days  # Default: 7 days
  config.failed_jobs_retention_period = 90.days    # Default: 30 days

  # Filter sensitive arguments from dashboard display
  config.filter_parameters = [:password, :token, :secret, :api_key]
end
```

### 4. Access Dashboard

Visit `http://localhost:3000/jobs` in your browser (development) or `https://yourapp.com/jobs` (production).

---

## Production Authentication Patterns

### Pattern 1: Devise Admin Users (Recommended)

```ruby
# config/routes.rb
Rails.application.routes.draw do
  authenticate :user, ->(user) { user.admin? } do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
end
```

**Requirements:**
- User model with `admin?` method or `admin` boolean field
- Devise authentication already configured

**Example User Model:**

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Option 1: Boolean field
  def admin?
    admin # Assumes `admin` boolean column exists
  end

  # Option 2: Role-based
  enum role: { user: 0, admin: 1, superadmin: 2 }

  def admin?
    admin? || superadmin?
  end
end
```

### Pattern 2: Custom Authentication Logic

```ruby
# config/routes.rb
Rails.application.routes.draw do
  authenticate :user, ->(user) { user.can_access_mission_control? } do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
end

# app/models/user.rb
class User < ApplicationRecord
  def can_access_mission_control?
    admin? || role == "operations" || email.end_with?("@yourcompany.com")
  end
end
```

### Pattern 3: HTTP Basic Auth (Staging/Internal Tools)

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Add constraint for HTTP Basic Auth
  constraints(->(req) { authenticate_mission_control(req) }) do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
end

# config/application.rb or initializer
def authenticate_mission_control(request)
  return true if Rails.env.development?

  authenticate_or_request_with_http_basic do |username, password|
    username == ENV['MISSION_CONTROL_USERNAME'] &&
    password == ENV['MISSION_CONTROL_PASSWORD']
  end
end
```

**Set environment variables:**

```bash
# .env or production secrets
MISSION_CONTROL_USERNAME=admin
MISSION_CONTROL_PASSWORD=secure_random_password_here
```

### Pattern 4: IP Whitelist (Internal Networks)

```ruby
# config/routes.rb
Rails.application.routes.draw do
  constraints(->(req) { internal_ip?(req.remote_ip) }) do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
end

# config/application.rb
def internal_ip?(ip)
  allowed_ips = ENV.fetch('MISSION_CONTROL_IPS', '').split(',')
  allowed_ips.include?(ip) || ip.start_with?('10.', '192.168.')
end
```

### Pattern 5: Multi-Environment Configuration

```ruby
# config/routes.rb
Rails.application.routes.draw do
  case Rails.env
  when "production"
    # Production: Require admin user
    authenticate :user, ->(user) { user.admin? } do
      mount MissionControl::Jobs::Engine, at: "/jobs"
    end
  when "staging"
    # Staging: HTTP Basic Auth
    constraints(->(req) { authenticate_basic(req) }) do
      mount MissionControl::Jobs::Engine, at: "/jobs"
    end
  else
    # Development: Open access
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
end
```

---

## Team Access Management

### Granting Admin Access

```ruby
# Rails console (production)
rails console

# Grant admin access to user
user = User.find_by(email: "teammate@company.com")
user.update!(admin: true)

# Or using role enum
user.update!(role: :admin)
```

### Bulk Admin Creation

```ruby
# db/seeds.rb or migration
admin_emails = [
  "ops_lead@company.com",
  "dev_lead@company.com",
  "support_manager@company.com"
]

admin_emails.each do |email|
  user = User.find_or_create_by(email: email)
  user.update!(admin: true)
end
```

### Team Roles Pattern

```ruby
# app/models/user.rb
class User < ApplicationRecord
  enum role: {
    user: 0,
    developer: 1,
    operations: 2,
    admin: 3
  }

  def can_access_jobs_dashboard?
    developer? || operations? || admin?
  end
end

# config/routes.rb
authenticate :user, ->(user) { user.can_access_jobs_dashboard? } do
  mount MissionControl::Jobs::Engine, at: "/jobs"
end
```

---

## Dashboard Features & Usage

### Jobs Overview Tab

**Features:**
- View all jobs across all queues
- Filter by status: pending, running, finished, failed
- Real-time updates (auto-refresh)
- Queue performance metrics

**Common Operations:**
- Search jobs by class name
- Filter by date range
- Sort by created/finished time

### Queues Tab

**Metrics Displayed:**
- Pending job count per queue
- Active workers per queue
- Throughput (jobs/minute)
- Latency (average wait time)

**Use Cases:**
- Identify bottlenecked queues
- Verify queue priority configuration
- Monitor worker capacity

### Failed Jobs Tab

**Features:**
- Full error backtraces
- Job arguments and context
- Retry history and attempt counts
- Bulk retry/discard operations

**Workflows:**

1. **Investigating Failures:**
   - Click failed job to see full backtrace
   - Review job arguments for invalid data
   - Check retry history for transient vs persistent failures

2. **Bulk Recovery:**
   - Select multiple failed jobs
   - Click "Retry Selected" to requeue
   - Or "Discard Selected" for jobs that can't be fixed

3. **Pattern Detection:**
   - Group by error type to find systemic issues
   - Filter by time range to correlate with deployments
   - Search by class name to find job-specific problems

### Individual Job Details

**Information Displayed:**
- Job class and queue name
- Enqueued/started/finished timestamps
- Duration and execution time
- Full arguments (with sensitive params filtered)
- Error message and backtrace (if failed)
- Retry count and next retry time

**Available Actions:**
- Retry job (failed jobs only)
- Discard job (remove from queue)
- View full execution context

---

## Configuration Options

### Job Retention

Control how long finished and failed jobs are kept in the database:

```ruby
# config/initializers/mission_control.rb
MissionControl::Jobs.configure do |config|
  # Keep finished jobs for 2 weeks (default: 7 days)
  config.finished_jobs_retention_period = 14.days

  # Keep failed jobs for 3 months (default: 30 days)
  config.failed_jobs_retention_period = 90.days
end
```

**Automatic Cleanup:**

SolidQueue automatically cleans up old jobs based on these settings. No manual intervention needed.

**Manual Cleanup:**

```ruby
# Rails console
SolidQueue::Job.finished.where("finished_at < ?", 14.days.ago).delete_all
SolidQueue::Job.failed.where("failed_at < ?", 90.days.ago).delete_all
```

### Parameter Filtering

Prevent sensitive data from appearing in the dashboard:

```ruby
MissionControl::Jobs.configure do |config|
  # Filter these parameter keys from display
  config.filter_parameters = [
    :password,
    :token,
    :secret,
    :api_key,
    :private_key,
    :access_token,
    :refresh_token,
    :credit_card,
    :ssn
  ]
end
```

**Example Job Arguments:**

```ruby
# Job enqueued with:
SendEmailJob.perform_later(
  user_id: 123,
  password: "secret123",
  api_token: "sk_live_abc123"
)

# Displayed in Mission Control as:
{
  user_id: 123,
  password: "[FILTERED]",
  api_token: "[FILTERED]"
}
```

### Custom Routes

Mount at a different path:

```ruby
# config/routes.rb
mount MissionControl::Jobs::Engine, at: "/admin/background-jobs"
```

Access at: `https://yourapp.com/admin/background-jobs`

---

## Production Deployment Checklist

- [ ] `mission_control-jobs` gem added to Gemfile
- [ ] Bundle installed and Gemfile.lock committed
- [ ] Routes configured with authentication
- [ ] Authentication tested in staging environment
- [ ] Admin users granted access
- [ ] Parameter filtering configured for sensitive data
- [ ] Job retention periods configured
- [ ] Team members notified of dashboard URL
- [ ] Dashboard access verified in production
- [ ] Monitoring alerts configured (optional)

---

## Monitoring & Alerting Integration

### Health Check Endpoint

Expose job queue health for external monitoring:

```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  skip_before_action :authenticate_user! # Public endpoint

  def jobs
    pending_count = SolidQueue::Job.pending.count
    failed_count = SolidQueue::Job.failed.count
    oldest_pending = oldest_pending_job_age

    status = if oldest_pending > 30 || failed_count > 100
               :service_unavailable
             else
               :ok
             end

    render json: {
      status: status == :ok ? "healthy" : "degraded",
      pending_jobs: pending_count,
      failed_jobs: failed_count,
      oldest_pending_minutes: oldest_pending
    }, status: status
  end

  private

  def oldest_pending_job_age
    oldest = SolidQueue::Job.pending.order(:created_at).first
    return 0 unless oldest
    ((Time.current - oldest.created_at) / 60).round
  end
end

# config/routes.rb
get '/health/jobs', to: 'health#jobs'
```

### External Monitoring Setup

```bash
# Uptime monitoring (Pingdom, UptimeRobot, etc.)
GET https://yourapp.com/health/jobs

# Expected response (healthy):
{
  "status": "healthy",
  "pending_jobs": 42,
  "failed_jobs": 3,
  "oldest_pending_minutes": 2
}

# Alert on:
# - status != "healthy"
# - failed_jobs > threshold
# - oldest_pending_minutes > 30
```

---

## Common Operations

### Retry All Failed Jobs

```ruby
# Rails console
SolidQueue::Job.failed.find_each(&:retry!)

# Or with Mission Control UI:
# 1. Navigate to Failed Jobs tab
# 2. Select all jobs
# 3. Click "Retry Selected"
```

### Discard Specific Failed Jobs

```ruby
# Rails console - discard jobs older than 1 week
SolidQueue::Job.failed
  .where("failed_at < ?", 1.week.ago)
  .delete_all

# Or by job class
SolidQueue::Job.failed
  .where(class_name: "ProblematicJob")
  .delete_all
```

### Pause/Resume Queue Processing

```ruby
# Not directly supported by SolidQueue
# Instead, scale workers to 0 in queue.yml and restart

# config/queue.yml (temporary)
production:
  workers:
    - queues: [critical, mailers]
      threads: 5
      processes: 0  # Paused
```

### Monitor Specific Queue

```ruby
# Rails console
SolidQueue::Job.where(queue_name: "mailers").pending.count
SolidQueue::Job.where(queue_name: "mailers").failed.count
```

---

## Troubleshooting

### Dashboard Not Loading

**Symptom:** 404 or routing error

**Solutions:**
1. Verify gem is installed: `bundle list | grep mission_control`
2. Check routes: `rails routes | grep jobs`
3. Restart server after adding gem
4. Check authentication constraints aren't blocking access

### Authentication Loop/Redirect

**Symptom:** Redirected to login repeatedly

**Solutions:**
1. Verify user is logged in: `current_user` in console
2. Check authentication lambda: `user.admin?` returns true
3. Verify Devise configuration allows access to mounted engines
4. Check for conflicting before_action filters

### Slow Dashboard Performance

**Symptom:** Dashboard takes >5s to load

**Solutions:**
1. Clean up old finished jobs:
   ```ruby
   SolidQueue::Job.finished.where("finished_at < ?", 7.days.ago).delete_all
   ```
2. Add database indexes (if not present):
   ```ruby
   add_index :solid_queue_jobs, [:queue_name, :status]
   add_index :solid_queue_jobs, [:status, :created_at]
   ```
3. Reduce retention periods in initializer

### Jobs Not Appearing

**Symptom:** Dashboard shows 0 jobs but jobs are running

**Solutions:**
1. Verify SolidQueue is configured: `Rails.configuration.active_job.queue_adapter`
2. Check queue database connection in `config/database.yml`
3. Run queue migrations: `rails db:migrate:queue`
4. Verify jobs are using SolidQueue, not inline adapter

---

## Security Considerations

### Production Hardening

1. **Always require authentication:**
   ```ruby
   # ❌ NEVER do this in production
   mount MissionControl::Jobs::Engine, at: "/jobs"

   # ✅ Always authenticate
   authenticate :user, ->(user) { user.admin? } do
     mount MissionControl::Jobs::Engine, at: "/jobs"
   end
   ```

2. **Filter sensitive parameters:**
   ```ruby
   config.filter_parameters = [:password, :token, :secret, :api_key]
   ```

3. **Use HTTPS only:**
   ```ruby
   # config/environments/production.rb
   config.force_ssl = true
   ```

4. **Limit admin access:**
   - Grant admin rights only to operations team
   - Audit admin user list regularly
   - Use role-based access for granular control

5. **Monitor access logs:**
   ```ruby
   # Track who accesses Mission Control
   class ApplicationController < ActionController::Base
     before_action :log_mission_control_access, if: :mission_control_request?

     private

     def mission_control_request?
       request.path.start_with?('/jobs')
     end

     def log_mission_control_access
       Rails.logger.info(
         "Mission Control accessed by #{current_user&.email} " \
         "from #{request.remote_ip}"
       )
     end
   end
   ```

---

## Additional Resources

- [Mission Control Jobs GitHub](https://github.com/rails/mission_control-jobs)
- [SolidQueue Documentation](https://github.com/rails/solid_queue)
- [Rails Active Job Guide](https://guides.rubyonrails.org/active_job_basics.html)
- [Rails 8 Release Notes - Solid Stack](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
