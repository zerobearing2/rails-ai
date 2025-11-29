# Rails 8+ Best Practices Checklists Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add `<rails-8-checklist>` sections to all skills and update the reviewer agent to enforce Rails 8+ best practices during code reviews.

**Architecture:** Each skill file gets a new `<rails-8-checklist>` section inserted before `<related-skills>`. The reviewer agent gets updated instructions to always check these sections. Checklists contain DO patterns (modern), AVOID patterns (legacy), and specific REVIEWER CHECKS.

**Tech Stack:** Markdown skill files, YAML-based reviewer output

---

## Task 1: Update models/SKILL.md

**Files:**
- Modify: `skills/models/SKILL.md:1207` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag (line 1208):

```markdown
<rails-8-checklist>
## Rails 8+ Model Best Practices

### DO (Modern Patterns)

**Attribute Normalization (Rails 7.1+)**
```ruby
class User < ApplicationRecord
  normalizes :email, with: -> e { e.strip.downcase }
  normalizes :phone, with: -> p { p.delete("^0-9") }
end
# Normalization applies automatically to queries too:
# User.find_by(email: " FOO@BAR.COM ") finds normalized record
```

**String-Backed Enums with Options (Rails 7.1+)**
```ruby
class Article < ApplicationRecord
  enum :status, { draft: "draft", published: "published", archived: "archived" },
       prefix: true,    # status_draft?, status_published!
       validate: true   # Raises on invalid values
end
```

**Secure Token Generation (Rails 7.1+)**
```ruby
class User < ApplicationRecord
  has_secure_password

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt&.last(10)  # Invalidates when password changes
  end

  generates_token_for :email_confirmation, expires_in: 24.hours do
    email
  end
end

# Usage:
token = user.generate_token_for(:password_reset)
User.find_by_token_for(:password_reset, token) # => user or nil
```

**Strict Loading for N+1 Prevention**
```ruby
class Author < ApplicationRecord
  has_many :books, strict_loading: true  # Raises if lazy loaded
end

# Query-level strict loading
User.strict_loading.includes(:posts).find(id)

# N+1 only mode (allows belongs_to lazy load, prevents has_many)
user.strict_loading!(mode: :n_plus_one_only)
```

**Deprecated Associations (Rails 8.1)**
```ruby
class User < ApplicationRecord
  has_many :legacy_orders, deprecated: true           # Warns on use
  has_many :old_subscriptions, deprecated: :raise     # Raises on use
  has_many :v1_tokens, deprecated: :notify            # Notifies via Rails.event
end
```

**Transaction Callbacks (Rails 7.2+)**
```ruby
Article.transaction do |t|
  article.update!(published: true)
  t.after_commit do
    PublishNotificationMailer.with(article: article).deliver_later
  end
end
```

**Explicit Ordering for first/last**
```ruby
User.order(:created_at).first      # Deterministic
Message.order(id: :desc).last      # Deterministic
Feedback.order(:id).take(5)        # Deterministic
```

### AVOID (Legacy Patterns)

**before_save for Normalization**
```ruby
# AVOID - Legacy callback pattern
class User < ApplicationRecord
  before_save :normalize_email
  private
  def normalize_email
    self.email = email&.strip&.downcase
  end
end
# USE INSTEAD: normalizes :email, with: -> e { e.strip.downcase }
```

**Integer-Backed Enums**
```ruby
# AVOID - Integers can shift if order changes
enum status: [:draft, :published, :archived]
# USE INSTEAD: enum :status, { draft: "draft", published: "published" }
```

**Enums Without Prefix**
```ruby
# AVOID - Creates collision-prone methods like user.active?
enum :status, { active: "active", inactive: "inactive" }
# USE INSTEAD: enum :status, { ... }, prefix: true
```

**Order-Dependent Finders**
```ruby
# AVOID - Deprecated in Rails 8+, undefined behavior
User.first   # Which user? Database-dependent!
User.last    # Inconsistent across databases
# USE INSTEAD: User.order(:id).first
```

**Manual Token Generation**
```ruby
# AVOID - Manual, error-prone, no expiration
user.update!(reset_token: SecureRandom.urlsafe_base64, reset_sent_at: Time.current)
# USE INSTEAD: generates_token_for :password_reset, expires_in: 15.minutes
```

**Model-Level after_commit for Cross-Cutting Concerns**
```ruby
# AVOID - Hard to trace, can cause issues
class Article < ApplicationRecord
  after_commit :send_notification, on: :update
end
# USE INSTEAD: Transaction block callbacks where the logic is triggered
```

### REVIEWER CHECKS
- [ ] No `before_save`/`before_validation` callbacks for attribute normalization — use `normalizes`
- [ ] All enums use string values (not integer arrays) with `prefix: true`
- [ ] No `Model.first` or `Model.last` without explicit `order()` clause
- [ ] `strict_loading: true` on has_many associations used in serializers/APIs
- [ ] `generates_token_for` used for password reset and email confirmation tokens
- [ ] Deprecated associations marked with `deprecated: true` option
- [ ] Transaction callbacks use block form for cross-model notification concerns
- [ ] `validate: true` option on enums to catch invalid assignments
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/models/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/models/SKILL.md
git commit -m "feat(models): add Rails 8+ best practices checklist"
```

---

## Task 2: Update security/SKILL.md

**Files:**
- Modify: `skills/security/SKILL.md` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag:

```markdown
<rails-8-checklist>
## Rails 8+ Security Best Practices

### DO (Modern Patterns)

**params.expect() for Strong Parameters (Rails 8+)**
```ruby
class ArticlesController < ApplicationController
  private
  def article_params
    params.expect(article: [:title, :body, :status])
  end
end

# Nested parameters
def user_params
  params.expect(user: [:name, :email, addresses: [[:street, :city, :zip]]])
end

# Scalar parameters
id = params.expect(:id)
```

**authenticate_by for Timing-Safe Auth (Rails 7.1+)**
```ruby
class SessionsController < ApplicationController
  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Credentials with Bang Method**
```ruby
# Raises KeyError if missing - fail fast
api_key = Rails.application.credentials.stripe_api_key!
secret = Rails.application.credentials.dig!(:aws, :secret_key)
```

**allow_browser for Modern Security Features (Rails 8)**
```ruby
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
end

class PaymentsController < ApplicationController
  allow_browser versions: { safari: 17.0, chrome: 120, ie: false }, only: [:create]
end
```

**Session Reset on Auth State Change**
```ruby
def create
  if user = User.authenticate_by(...)
    reset_session  # CRITICAL: Prevent session fixation
    session[:user_id] = user.id
    redirect_to root_path
  end
end

def destroy
  reset_session  # Clear everything on logout
  redirect_to root_path
end
```

**SameSite Cookie Configuration**
```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: '_myapp_session',
  same_site: :lax,
  secure: Rails.env.production?,
  httponly: true
```

### AVOID (Legacy Patterns)

**params.require().permit()**
```ruby
# AVOID - Less strict, doesn't validate structure
def article_params
  params.require(:article).permit(:title, :body)
end
# USE INSTEAD: params.expect(article: [:title, :body])
```

**Manual find_by + authenticate**
```ruby
# AVOID - Timing attack vulnerable
user = User.find_by(email: params[:email])
if user&.authenticate(params[:password])
  # ...
end
# USE INSTEAD: User.authenticate_by(email:, password:)
```

**Credentials Without Bang**
```ruby
# AVOID - Returns nil silently, may cause runtime errors later
api_key = Rails.application.credentials.stripe_api_key
# USE INSTEAD: Rails.application.credentials.stripe_api_key!
```

**Missing reset_session**
```ruby
# AVOID - Session fixation vulnerability
def create
  session[:user_id] = user.id  # Reuses attacker's session!
end
# USE INSTEAD: reset_session before setting user_id
```

### REVIEWER CHECKS
- [ ] All strong parameters use `params.expect()` not `params.require().permit()`
- [ ] Authentication uses `User.authenticate_by()` not manual find + authenticate
- [ ] Credential access uses bang methods (`credentials.key!`)
- [ ] `reset_session` called before setting session[:user_id] on login
- [ ] `reset_session` called on logout
- [ ] `allow_browser versions: :modern` in ApplicationController or sensitive controllers
- [ ] Session cookies configured with `same_site: :lax` and `httponly: true`
- [ ] No hardcoded secrets — all in credentials or environment
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/security/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/security/SKILL.md
git commit -m "feat(security): add Rails 8+ best practices checklist"
```

---

## Task 3: Update controllers/SKILL.md

**Files:**
- Modify: `skills/controllers/SKILL.md` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag:

```markdown
<rails-8-checklist>
## Rails 8+ Controller Best Practices

### DO (Modern Patterns)

**Turbo Stream Responses**
```ruby
class MessagesController < ApplicationController
  def create
    @message = @room.messages.build(message_params)
    if @message.save
      respond_to do |format|
        format.turbo_stream  # Renders create.turbo_stream.erb
        format.html { redirect_to @room }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Markdown Rendering (Rails 8.1)**
```ruby
class DocsController < ApplicationController
  def show
    @doc = Document.find(params[:id])
    respond_to do |format|
      format.html
      format.markdown { render markdown: @doc.content }
    end
  end
end
```

**Variant Responses**
```ruby
class ProductsController < ApplicationController
  before_action :set_variant

  def show
    respond_to do |format|
      format.html.phone { render :show_phone }
      format.html.tablet { render :show_tablet }
      format.html { render :show }
    end
  end

  private
  def set_variant
    request.variant = :phone if browser.device.mobile?
    request.variant = :tablet if browser.device.tablet?
  end
end
```

**RESTful-Only Actions**
```ruby
class ArticlesController < ApplicationController
  # Standard 7 actions only: index, show, new, create, edit, update, destroy
  def index; end
  def show; end
  def new; end
  def create; end
  def edit; end
  def update; end
  def destroy; end
end

# For additional actions, create a new controller:
class Articles::PublicationsController < ApplicationController
  def create  # POST /articles/:article_id/publication
    @article.publish!
  end

  def destroy  # DELETE /articles/:article_id/publication
    @article.unpublish!
  end
end
```

**params.expect() in Private Method**
```ruby
class ArticlesController < ApplicationController
  private
  def article_params
    params.expect(article: [:title, :body, :status, tag_ids: []])
  end
end
```

### AVOID (Legacy Patterns)

**Custom Actions When REST Suffices**
```ruby
# AVOID
class ArticlesController < ApplicationController
  def publish
    @article.update!(published: true)
  end

  def unpublish
    @article.update!(published: false)
  end
end
# USE INSTEAD: Articles::PublicationsController with create/destroy
```

**respond_to Without Turbo Stream**
```ruby
# AVOID - Missing turbo_stream format in Rails 8
def create
  if @message.save
    redirect_to @room
  end
end
# USE INSTEAD: respond_to with format.turbo_stream
```

**params.require().permit()**
```ruby
# AVOID
def article_params
  params.require(:article).permit(:title, :body)
end
# USE INSTEAD: params.expect(article: [:title, :body])
```

**Logic in Actions**
```ruby
# AVOID - Fat controller
def create
  @order = Order.new(order_params)
  @order.calculate_tax
  @order.apply_discount(current_user.discount_rate)
  @order.reserve_inventory
  # ... more logic
end
# USE INSTEAD: Service object or model method
```

### REVIEWER CHECKS
- [ ] All create/update actions have `respond_to` with `format.turbo_stream`
- [ ] Only 7 RESTful actions per controller (index, show, new, create, edit, update, destroy)
- [ ] Custom actions extracted to nested resource controllers
- [ ] Strong parameters use `params.expect()` not `params.require().permit()`
- [ ] No business logic in controller actions — delegate to models or services
- [ ] `status: :unprocessable_entity` on validation failure renders
- [ ] `redirect_to` used for HTML format after successful create/update
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/controllers/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/controllers/SKILL.md
git commit -m "feat(controllers): add Rails 8+ best practices checklist"
```

---

## Task 4: Update hotwire/SKILL.md

**Files:**
- Modify: `skills/hotwire/SKILL.md` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag:

```markdown
<rails-8-checklist>
## Rails 8+ Hotwire Best Practices

### DO (Modern Patterns)

**Turbo Morph for Page Refreshes (Rails 8)**
```erb
<%# app/views/layouts/application.html.erb %>
<head>
  <meta name="turbo-refresh-method" content="morph">
  <meta name="turbo-refresh-scroll" content="preserve">
</head>
```

```erb
<%# Or per-page in view %>
<% turbo_refreshes_with method: :morph, scroll: :preserve %>
```

**broadcasts_refreshes with Morph (Rails 8)**
```ruby
class Board < ApplicationRecord
  has_many :cards
  broadcasts_refreshes  # Broadcasts refresh instead of replace
end

# View subscribes to refreshes
<%= turbo_stream_from @board %>
<div id="board_<%= @board.id %>">
  <%= render @board.cards %>
</div>
```

**Hierarchical Refresh via touch**
```ruby
class Card < ApplicationRecord
  belongs_to :board, touch: true
end

class Board < ApplicationRecord
  broadcasts_refreshes
end
# Card updates trigger board.touch, which broadcasts refresh
```

**broadcast_refresh_later (Debounced)**
```ruby
class Comment < ApplicationRecord
  belongs_to :post

  after_update_commit do
    broadcast_refresh_later_to(post)  # Debounced, async
  end
end
```

**Turbo Frame Lazy Loading**
```erb
<%= turbo_frame_tag "notifications",
    src: notifications_path,
    loading: :lazy %>
```

**Turbo Stream Actions**
```erb
<%# app/views/messages/create.turbo_stream.erb %>
<%= turbo_stream.append "messages", @message %>
<%= turbo_stream.update "message_count", Message.count %>
<%= turbo_stream.replace "new_message_form" do %>
  <%= render "form", message: Message.new %>
<% end %>
```

**Stimulus Values API**
```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    seconds: { type: Number, default: 60 },
    url: String
  }
  static targets = ["display"]

  connect() {
    this.start()
  }

  secondsValueChanged() {
    this.displayTarget.textContent = this.secondsValue
  }
}
```

**Stimulus Outlets for Controller Communication**
```javascript
export default class extends Controller {
  static outlets = ["filter", "result"]

  search() {
    this.filterOutlets.forEach(filter => filter.apply())
    this.resultOutlet.refresh()
  }
}
```

```html
<div data-controller="search"
     data-search-filter-outlet=".filter"
     data-search-result-outlet="#results">
```

**Turbo Confirm Dialog**
```erb
<%= button_to "Delete", post_path(@post),
    method: :delete,
    form: { data: { turbo_confirm: "Are you sure?" } } %>

<%= link_to "Remove", item_path(@item),
    data: { turbo_method: :delete, turbo_confirm: "Delete this item?" } %>
```

### AVOID (Legacy Patterns)

**broadcast_replace Without Morph**
```ruby
# AVOID - Full replacement causes flicker
after_update_commit do
  broadcast_replace_to(board)
end
# USE INSTEAD: broadcasts_refreshes with morph meta tag
```

**Custom JavaScript DOM Manipulation**
```javascript
// AVOID
document.getElementById('messages').innerHTML += newMessageHtml
// USE INSTEAD: Turbo Stream append action
```

**Global Events for Controller Communication**
```javascript
// AVOID
window.dispatchEvent(new CustomEvent('filter-changed'))
// USE INSTEAD: Stimulus outlets
```

**querySelector in Stimulus**
```javascript
// AVOID
this.element.querySelector('.item')
// USE INSTEAD: static targets = ["item"] then this.itemTarget
```

**Hardcoded Values**
```javascript
// AVOID
if (this.element.dataset.seconds) { ... }
// USE INSTEAD: static values = { seconds: Number }
```

**link_to with method: :delete**
```erb
<%# AVOID - Deprecated in Rails 7+ with Turbo %>
<%= link_to "Delete", post_path(@post), method: :delete %>
<%# USE INSTEAD: button_to or data-turbo-method %>
```

### REVIEWER CHECKS
- [ ] Turbo Morph meta tags present in application layout
- [ ] `broadcasts_refreshes` used instead of `broadcasts` for collections
- [ ] `broadcast_refresh_later_to` used for debounced updates in callbacks
- [ ] `loading: :lazy` on turbo_frame_tag for below-fold content
- [ ] Stimulus controllers use `static values` not manual dataset access
- [ ] Stimulus controllers use `static targets` not querySelector
- [ ] Stimulus controllers use `static outlets` for cross-controller communication
- [ ] `button_to` or `data-turbo-method` used for destructive actions (not link_to method:)
- [ ] `data-turbo-confirm` on destructive actions
- [ ] Turbo Stream responses include all affected DOM updates
- [ ] Stable DOM IDs for morphing (no random/dynamic IDs)
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/hotwire/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/hotwire/SKILL.md
git commit -m "feat(hotwire): add Rails 8+ best practices checklist"
```

---

## Task 5: Update jobs/SKILL.md

**Files:**
- Modify: `skills/jobs/SKILL.md` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag:

```markdown
<rails-8-checklist>
## Rails 8+ Jobs Best Practices

### DO (Modern Patterns)

**Solid Queue Configuration (Rails 8 Default)**
```ruby
# config/environments/production.rb
config.active_job.queue_adapter = :solid_queue
config.solid_queue.connects_to = { database: { writing: :queue } }
```

```yaml
# config/database.yml
production:
  primary:
    <<: *default
    database: storage/production.sqlite3
  queue:
    <<: *default
    database: storage/production_queue.sqlite3
    migrations_paths: db/queue_migrate
```

**Job Continuations (Rails 8.1)**
```ruby
class LargeExportJob < ApplicationJob
  performs_in_segments

  def perform(export)
    segment do
      export.prepare_data
    end

    segment do
      export.generate_file
    end

    segment do
      export.upload_to_storage
    end

    segment do
      ExportMailer.with(export: export).completed.deliver_later
    end
  end
end
```

**Cursor-Based Batch Processing (Rails 8.1)**
```ruby
class ProcessRecordsJob < ApplicationJob
  performs_in_segments

  def perform
    User.find_each do |user|
      segment(cursor: user.id) do
        user.process_something
      end
    end
  end
end
```

**deliver_later Always**
```ruby
# In controllers and models
UserMailer.with(user: @user).welcome.deliver_later

# In jobs that send mail
def perform(user)
  NotificationMailer.with(user: user).daily_digest.deliver_later
end
```

**Idempotent Jobs**
```ruby
class ProcessPaymentJob < ApplicationJob
  def perform(payment_id)
    payment = Payment.find(payment_id)
    return if payment.processed?  # Idempotency check

    payment.process!
  end
end
```

### AVOID (Legacy Patterns)

**Sidekiq/Redis**
```ruby
# AVOID - External dependency
config.active_job.queue_adapter = :sidekiq
# USE INSTEAD: :solid_queue (Rails 8 default)
```

**Long-Running Single perform**
```ruby
# AVOID - Can't resume on deploy, blocks workers
def perform(export)
  export.prepare_data      # 5 minutes
  export.generate_file     # 10 minutes
  export.upload_to_storage # 5 minutes
  export.notify_user       # 1 second
end
# USE INSTEAD: performs_in_segments with segment blocks
```

**deliver_now in Jobs**
```ruby
# AVOID - Blocks the job
def perform(user)
  UserMailer.with(user: user).welcome.deliver_now
end
# USE INSTEAD: deliver_later (even in jobs)
```

**Non-Idempotent Jobs**
```ruby
# AVOID - Double-processing on retry
def perform(user_id)
  User.find(user_id).charge_subscription!  # May charge twice
end
# USE INSTEAD: Check if already processed before executing
```

### REVIEWER CHECKS
- [ ] `config.active_job.queue_adapter = :solid_queue` (NOT sidekiq, resque, delayed_job)
- [ ] No Redis dependencies for job queuing
- [ ] Long-running jobs (>30s) use `performs_in_segments`
- [ ] Batch processing uses cursor-based segments
- [ ] All mailer calls use `deliver_later` (never `deliver_now`)
- [ ] Jobs are idempotent (safe to retry)
- [ ] Jobs accept IDs not full objects (serialization safety)
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/jobs/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/jobs/SKILL.md
git commit -m "feat(jobs): add Rails 8+ best practices checklist"
```

---

## Task 6: Update mailers/SKILL.md

**Files:**
- Modify: `skills/mailers/SKILL.md` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag:

```markdown
<rails-8-checklist>
## Rails 8+ Mailer Best Practices

### DO (Modern Patterns)

**Parameterized Mailers**
```ruby
class NotificationMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    @account = params[:account]
    mail(to: @user.email, subject: "Welcome to #{@account.name}")
  end
end

# Usage
NotificationMailer.with(user: @user, account: @account).welcome.deliver_later
```

**deliver_later Always**
```ruby
# Controllers
UserMailer.with(user: @user).welcome.deliver_later

# Models (after_commit)
after_create_commit do
  UserMailer.with(user: self).welcome.deliver_later
end

# Jobs
def perform(user)
  DigestMailer.with(user: user).weekly.deliver_later
end
```

**Mailer Previews**
```ruby
# test/mailers/previews/user_mailer_preview.rb
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.with(user: User.first).welcome
  end

  def password_reset
    UserMailer.with(user: User.first, token: "preview_token").password_reset
  end
end
```

**SolidQueue for Async Delivery**
```ruby
# config/environments/production.rb
config.active_job.queue_adapter = :solid_queue
config.action_mailer.deliver_later_queue_name = :default
```

### AVOID (Legacy Patterns)

**deliver_now in Web Requests**
```ruby
# AVOID - Blocks request, fails silently if SMTP down
def create
  @user = User.create!(user_params)
  UserMailer.welcome(@user).deliver_now
end
# USE INSTEAD: deliver_later
```

**Instance Variables Instead of params**
```ruby
# AVOID - Old pattern
class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email)
  end
end
UserMailer.welcome(@user).deliver_later
# USE INSTEAD: Parameterized syntax with params[:user]
```

**No Previews**
```ruby
# AVOID - No way to visually test emails
# USE INSTEAD: Create preview class for every mailer method
```

### REVIEWER CHECKS
- [ ] All mailer calls use `deliver_later` (never `deliver_now` in controllers)
- [ ] Mailers use parameterized syntax (`params[:user]` not method arguments)
- [ ] Every mailer method has a corresponding preview class
- [ ] Mailers triggered from `after_create_commit` not `after_create`
- [ ] Queue adapter is SolidQueue (not Sidekiq/Redis)
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/mailers/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/mailers/SKILL.md
git commit -m "feat(mailers): add Rails 8+ best practices checklist"
```

---

## Task 7: Update testing/SKILL.md

**Files:**
- Modify: `skills/testing/SKILL.md` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag:

```markdown
<rails-8-checklist>
## Rails 8+ Testing Best Practices

### DO (Modern Patterns)

**Local CI DSL (Rails 8.1)**
```ruby
# config/ci.rb
step "Setup" do
  run "bundle install"
  run "bin/rails db:prepare"
end

step "Lint" do
  run "bundle exec rubocop"
end

step "Test" do
  run "bin/rails test"
end

step "Security" do
  run "bundle exec brakeman --no-pager"
end if success?
```

```bash
bin/ci              # Run full pipeline
bin/ci --continue   # Resume from failure
bin/ci --step 3     # Run specific step
```

**Turbo Stream Broadcast Assertions**
```ruby
class MessageTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  test "broadcasts append on create" do
    board = boards(:one)
    assert_broadcasts_to(board, :messages) do
      Message.create!(board: board, content: "New message")
    end
  end

  test "broadcasts refresh on update" do
    board = boards(:one)
    assert_broadcasts_to(board) do
      board.update!(name: "Updated")
    end
  end
end
```

**System Test Cable Connection**
```ruby
class MessagesSystemTest < ApplicationSystemTestCase
  test "receives broadcasted messages" do
    visit room_path(@room)
    connect_turbo_cable_stream_sources  # Wait for WebSocket

    Message.create!(room: @room, content: "Hello")
    assert_text "Hello"
  end
end
```

**Integration Tests Over System Tests**
```ruby
class MessagesControllerTest < ActionDispatch::IntegrationTest
  include Capybara::DSL  # For DOM assertions

  test "creates message with turbo stream" do
    post room_messages_path(@room), params: { message: { content: "Hi" } }
    assert_response :success
    assert_match /turbo-stream/, response.body
  end
end
```

### AVOID (Legacy Patterns)

**System Tests for Everything**
```ruby
# AVOID - Slow, flaky
class EverythingSystemTest < ApplicationSystemTestCase
  test "user can create message" do
    # Full browser test for simple CRUD
  end
end
# USE INSTEAD: Integration test with Capybara::DSL when possible
```

**No Broadcast Testing**
```ruby
# AVOID - Turbo broadcasts not verified
test "creates message" do
  assert_difference("Message.count") { post messages_path, params: {...} }
end
# USE INSTEAD: assert_broadcasts_to for Turbo Stream apps
```

**Race Conditions in System Tests**
```ruby
# AVOID - May fail intermittently
test "shows new message" do
  visit room_path(@room)
  Message.create!(room: @room, content: "Hello")  # WebSocket not ready!
  assert_text "Hello"
end
# USE INSTEAD: connect_turbo_cable_stream_sources before triggering broadcasts
```

### REVIEWER CHECKS
- [ ] `config/ci.rb` exists with step DSL for local CI
- [ ] `bin/ci` used for running tests locally
- [ ] Turbo Stream broadcasts tested with `assert_broadcasts_to`
- [ ] System tests use `connect_turbo_cable_stream_sources` before broadcast assertions
- [ ] Integration tests preferred over system tests for non-JS functionality
- [ ] `Turbo::Broadcastable::TestHelper` included in model tests
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/testing/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/testing/SKILL.md
git commit -m "feat(testing): add Rails 8+ best practices checklist"
```

---

## Task 8: Update styling/SKILL.md

**Files:**
- Modify: `skills/styling/SKILL.md` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag:

```markdown
<rails-8-checklist>
## Rails 8+ Styling Best Practices

### DO (Modern Patterns)

**Propshaft (Rails 8 Default)**
```ruby
# Gemfile - Rails 8 default
gem "propshaft"
```

```erb
<%# app/views/layouts/application.html.erb %>
<%= stylesheet_link_tag "application" %>
<%= javascript_include_tag "application" %>
```

**Import Maps for JavaScript**
```ruby
# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin_all_from "app/javascript/controllers", under: "controllers"
```

**#NOBUILD Philosophy**
```erb
<%# Serve CSS and JS directly - no build step %>
<%= stylesheet_link_tag "application", data: { turbo_track: "reload" } %>
```

**Tailwind with DaisyUI Components**
```erb
<%# Use semantic DaisyUI components %>
<button class="btn btn-primary">Submit</button>
<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">Title</h2>
  </div>
</div>
```

**@apply Sparingly**
```css
/* app/assets/stylesheets/components.css */
/* Only for truly reusable component classes */
.btn-brand {
  @apply bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded;
}
```

### AVOID (Legacy Patterns)

**Sprockets in New Apps**
```ruby
# AVOID
gem "sprockets-rails"
# USE INSTEAD: propshaft (Rails 8 default)
```

**Webpack/esbuild When Not Needed**
```ruby
# AVOID for simple apps
gem "jsbundling-rails"
# USE INSTEAD: Import maps for most Rails 8 apps
```

**@apply for Everything**
```css
/* AVOID - Defeats purpose of utility-first */
.header { @apply flex items-center justify-between p-4 bg-white shadow; }
.nav-item { @apply text-gray-600 hover:text-gray-900 px-3 py-2; }
/* USE INSTEAD: Utilities directly in HTML, @apply only for true components */
```

**Custom CSS Files**
```css
/* AVOID - Reinventing Tailwind */
.my-button {
  background-color: blue;
  color: white;
  padding: 8px 16px;
}
/* USE INSTEAD: Tailwind utilities or DaisyUI components */
```

### REVIEWER CHECKS
- [ ] Propshaft used (not Sprockets) for new Rails 8 apps
- [ ] Import maps used for JavaScript (not Webpack/esbuild unless justified)
- [ ] No build step required (#NOBUILD philosophy where possible)
- [ ] DaisyUI semantic components used for common UI patterns
- [ ] `@apply` used sparingly — only for truly reusable components
- [ ] No custom CSS that duplicates Tailwind utilities
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/styling/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/styling/SKILL.md
git commit -m "feat(styling): add Rails 8+ best practices checklist"
```

---

## Task 9: Update setup/SKILL.md

**Files:**
- Modify: `skills/setup/SKILL.md` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag:

```markdown
<rails-8-checklist>
## Rails 8+ Setup Best Practices

### DO (Modern Patterns)

**Solid Stack Configuration**
```ruby
# config/environments/production.rb
config.active_job.queue_adapter = :solid_queue
config.solid_queue.connects_to = { database: { writing: :queue } }
config.cache_store = :solid_cache_store
```

```yaml
# config/database.yml
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

**Environment-Specific Credentials**
```bash
# Edit production credentials
rails credentials:edit --environment production

# Fetch specific credential (Rails 8.1)
rails credentials:fetch kamal.registry_password
```

**Local CI Configuration**
```ruby
# config/ci.rb
step "Setup" do
  run "bundle install"
  run "bin/rails db:prepare"
end

step "Lint" do
  run "bundle exec rubocop"
end

step "Test" do
  run "bin/rails test"
end

step "Security" do
  run "bundle exec brakeman --no-pager"
end if success?
```

**Kamal Deployment (Rails 8)**
```yaml
# config/deploy.yml
service: myapp
image: myapp

servers:
  web:
    hosts:
      - 192.168.1.1
    labels:
      traefik.http.routers.myapp.rule: Host(`myapp.com`)

env:
  secret:
    - RAILS_MASTER_KEY
```

**Authentication Generator**
```bash
# Generate Rails 8 authentication scaffold
rails generate authentication
# Creates: User model, Session model, controllers, views
```

### AVOID (Legacy Patterns)

**Redis/Sidekiq Dependencies**
```ruby
# AVOID
gem "sidekiq"
gem "redis"
# USE INSTEAD: Solid Stack (solid_queue, solid_cache, solid_cable)
```

**Single Credentials File**
```bash
# AVOID - Same secrets for all environments
rails credentials:edit
# USE INSTEAD: Environment-specific credentials
rails credentials:edit --environment production
```

**Manual CI Scripts**
```bash
# AVOID - Inconsistent local vs CI
#!/bin/bash
bundle install && rails test && rubocop
# USE INSTEAD: config/ci.rb with step DSL
```

**Devise for Authentication**
```ruby
# AVOID - Heavy dependency
gem "devise"
# USE INSTEAD: rails generate authentication (Rails 8)
```

### REVIEWER CHECKS
- [ ] Solid Stack gems in Gemfile (solid_queue, solid_cache, solid_cable)
- [ ] No Redis/Sidekiq/Memcached dependencies
- [ ] Environment-specific credentials files used
- [ ] `config/ci.rb` exists with step DSL
- [ ] Rails 8 authentication generator used (not Devise)
- [ ] Kamal configured for deployment (if self-hosting)
- [ ] SQLite configured for queue and cache databases
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/setup/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/setup/SKILL.md
git commit -m "feat(setup): add Rails 8+ best practices checklist"
```

---

## Task 10: Update debugging/SKILL.md

**Files:**
- Modify: `skills/debugging/SKILL.md` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag:

```markdown
<rails-8-checklist>
## Rails 8+ Debugging Best Practices

### DO (Modern Patterns)

**Structured Event Reporting (Rails 8.1)**
```ruby
# Emit structured events for debugging/monitoring
Rails.event.notify("user.signup", user_id: user.id, source: "web")
Rails.event.notify("payment.failed", amount: 100, error: e.message)

# With tags for categorization
Rails.event.notify("api.request",
  tags: [:external, :payment],
  endpoint: "/charge",
  duration: 150
)

# With context for correlation
Rails.event.with_context(request_id: request.uuid) do
  Rails.event.notify("order.created", order_id: order.id)
  Rails.event.notify("inventory.reserved", items: 5)
end
```

**Strict Loading for N+1 Detection**
```ruby
# Development config
config.active_record.strict_loading_by_default = true

# Or per-query
User.strict_loading.includes(:posts).find(id)
```

**Query Logging**
```ruby
# config/environments/development.rb
config.active_record.verbose_query_logs = true
```

### AVOID (Legacy Patterns)

**puts Debugging**
```ruby
# AVOID
puts "User: #{user.inspect}"
# USE INSTEAD: Rails.logger.debug or debugger
```

**Unstructured Logging**
```ruby
# AVOID
Rails.logger.info "Payment failed for user #{user.id}"
# USE INSTEAD: Rails.event.notify("payment.failed", user_id: user.id)
```

### REVIEWER CHECKS
- [ ] `Rails.event.notify` used for structured debugging events
- [ ] No `puts` or `p` statements in production code
- [ ] `strict_loading_by_default` enabled in development
- [ ] `verbose_query_logs` enabled in development
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/debugging/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/debugging/SKILL.md
git commit -m "feat(debugging): add Rails 8+ best practices checklist"
```

---

## Task 11: Update ui/SKILL.md

**Files:**
- Modify: `skills/ui/SKILL.md` (insert before `<related-skills>`)

**Step 1: Add Rails 8+ checklist section**

Insert the following before the `<related-skills>` tag:

```markdown
<rails-8-checklist>
## Rails 8+ UI Best Practices

### DO (Modern Patterns)

**form_with (Not form_for or form_tag)**
```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.submit %>
<% end %>
```

**button_to for Destructive Actions**
```erb
<%= button_to "Delete", article_path(@article),
    method: :delete,
    form: { data: { turbo_confirm: "Are you sure?" } } %>
```

**Turbo Frame for Partial Updates**
```erb
<%= turbo_frame_tag @article do %>
  <%= render @article %>
  <%= link_to "Edit", edit_article_path(@article) %>
<% end %>
```

**Direct Upload for Files**
```erb
<%= form.file_field :avatar, direct_upload: true %>
```

**ViewComponent for Complex UI**
```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  def initialize(title:, body:)
    @title = title
    @body = body
  end
end
```

```erb
<%# app/components/card_component.html.erb %>
<div class="card">
  <h2><%= @title %></h2>
  <p><%= @body %></p>
</div>
```

### AVOID (Legacy Patterns)

**form_for / form_tag**
```erb
<%# AVOID - Deprecated %>
<%= form_for @article do |f| %>
<%= form_tag articles_path do %>
<%# USE INSTEAD: form_with %>
```

**link_to with method:**
```erb
<%# AVOID - Requires rails-ujs, deprecated with Turbo %>
<%= link_to "Delete", article_path(@article), method: :delete %>
<%# USE INSTEAD: button_to %>
```

**Remote Forms**
```erb
<%# AVOID - Old Ajax pattern %>
<%= form_with model: @article, remote: true do |f| %>
<%# USE INSTEAD: Turbo Stream responses (remote: true is default now) %>
```

### REVIEWER CHECKS
- [ ] `form_with` used (not form_for or form_tag)
- [ ] `button_to` used for DELETE/POST actions (not link_to with method:)
- [ ] Turbo Frames wrap editable/updatable content
- [ ] `direct_upload: true` on file fields
- [ ] ViewComponent used for complex reusable UI
- [ ] No `remote: true` (it's default in Rails 7+)
</rails-8-checklist>

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" skills/ui/SKILL.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add skills/ui/SKILL.md
git commit -m "feat(ui): add Rails 8+ best practices checklist"
```

---

## Task 12: Update reviewer.md Agent

**Files:**
- Modify: `agents/reviewer.md:35` (insert new section after Context7 section)

**Step 1: Add Rails 8+ checklist instruction**

Insert the following after line 35 (after the Context7 section, before `## Your Mode`):

```markdown
---

## Rails 8+ Best Practices Enforcement

**Every skill contains a `<rails-8-checklist>` section.** When reviewing code, you MUST:

1. **Check the checklist** in each loaded skill
2. **Flag violations** from the "AVOID" section as issues
3. **Suggest alternatives** from the "DO" section
4. **Complete all REVIEWER CHECKS** items

**Severity for Rails 8+ violations:**
- Using deprecated patterns (AVOID section): `important`
- Missing modern patterns when beneficial: `minor`
- Security-related Rails 8+ patterns: `critical`

**Example finding:**
```yaml
- severity: important
  tag: "[MODELS]"
  file: "app/models/user.rb"
  line: 15
  issue: "Using before_save callback for email normalization"
  fix: "Use `normalizes :email, with: -> e { e.strip.downcase }` instead"
  reference: "rails-ai:models <rails-8-checklist> AVOID section"
```

```

**Step 2: Verify the edit**

Run: `grep -n "rails-8-checklist" agents/reviewer.md`
Expected: Shows line numbers where the new section was added

**Step 3: Commit**

```bash
git add agents/reviewer.md
git commit -m "feat(reviewer): add Rails 8+ best practices enforcement instructions"
```

---

## Task 13: Final Verification

**Step 1: Verify all skills have checklists**

Run:
```bash
for skill in models security controllers hotwire jobs mailers testing styling setup debugging ui; do
  echo "=== $skill ===" && grep -c "rails-8-checklist" skills/$skill/SKILL.md
done
```

Expected: Each skill shows `2` (opening and closing tags)

**Step 2: Verify reviewer has instructions**

Run: `grep -c "rails-8-checklist" agents/reviewer.md`
Expected: `3` or more occurrences

**Step 3: Run tests**

Run: `bin/ci` or `rake test`
Expected: All tests pass

**Step 4: Final commit**

```bash
git add -A
git commit -m "docs: add Rails 8+ best practices checklists to all skills

- Added <rails-8-checklist> sections to 11 skills
- Updated reviewer agent to enforce checklist items
- Covers: params.expect, Solid Stack, normalizes, enums, Turbo Morph,
  broadcasts_refreshes, job continuations, authenticate_by, and more

Closes #XX"
```

---

## Summary

| Task | Skill/File | Items Added |
|------|------------|-------------|
| 1 | models/SKILL.md | ~20 checklist items |
| 2 | security/SKILL.md | ~15 checklist items |
| 3 | controllers/SKILL.md | ~12 checklist items |
| 4 | hotwire/SKILL.md | ~25 checklist items |
| 5 | jobs/SKILL.md | ~10 checklist items |
| 6 | mailers/SKILL.md | ~8 checklist items |
| 7 | testing/SKILL.md | ~10 checklist items |
| 8 | styling/SKILL.md | ~8 checklist items |
| 9 | setup/SKILL.md | ~10 checklist items |
| 10 | debugging/SKILL.md | ~6 checklist items |
| 11 | ui/SKILL.md | ~10 checklist items |
| 12 | reviewer.md | Enforcement instructions |
| 13 | Verification | Final checks |

**Total: ~134 Rails 8+ best practice checks across 11 skills**
