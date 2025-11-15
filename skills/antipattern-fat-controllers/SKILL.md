---
name: rails-ai:antipattern-fat-controllers
description: Identify and refactor fat controllers that violate Single Responsibility Principle by moving business logic, validations, and external service calls to appropriate layers.
---

# Fat Controllers Antipattern

Identify and refactor fat controllers that violate Single Responsibility Principle by moving business logic, validations, and external service calls to appropriate layers.

<when-to-use>
- Refactoring existing controllers with too much logic
- Code reviews to identify controller bloat
- When controllers exceed 100 lines or have methods over 20 lines
- Controllers performing multiple model operations
- Controllers with external service integrations
- Controllers with complex validation or business rules
- Planning new features to avoid controller bloat from the start
</when-to-use>

<benefits>
- **Testability** - Isolated business logic is easier to test
- **Reusability** - Logic extracted to services can be reused
- **Maintainability** - Thin controllers are easier to understand
- **Single Responsibility** - Each class has one clear purpose
- **Performance** - Business logic can be optimized independently
- **API Consistency** - Same logic used across web and API endpoints
</benefits>

<standards>
- Controllers should ONLY handle HTTP concerns (params, redirects, renders)
- Move business logic to models or service objects
- Move validations to models or form objects
- Move complex queries to query objects or model scopes
- Extract external service calls to service objects
- Use callbacks or service objects for side effects (emails, notifications)
- Keep controller actions under 10 lines ideally, max 20 lines
- Use `before_action` for common setup, not business logic
</standards>

## Identifying Fat Controllers

<pattern name="fat-controller-smells">
<description>Warning signs that a controller needs refactoring</description>

**Red Flags:**
```ruby
# ❌ SMELL: Controller has too many lines (100+)
class FeedbacksController < ApplicationController
  # ... 150 lines of code
end

# ❌ SMELL: Action method exceeds 20 lines
def create
  # 45 lines of logic
end

# ❌ SMELL: Business logic in controller
def create
  @feedback.status = :pending
  @feedback.submitted_at = Time.current
  # ... more business logic
end

# ❌ SMELL: Complex validation in controller
if @feedback.content.blank? || @feedback.content.length < 50
  @feedback.errors.add(:content, "must be at least 50 characters")
  render :new
  return
end

# ❌ SMELL: External service calls in controller
anthropic_client = Anthropic::Client.new
response = anthropic_client.messages.create(...)

# ❌ SMELL: Multiple model operations in controller
@feedback.save
FeedbackTracking.create(...)
UserActivity.log(...)

# ❌ SMELL: Manual notification logic
FeedbackMailer.notify_recipient(@feedback).deliver_later
SlackNotifier.new.send_message(...)

# ❌ SMELL: Conditional logic and branching
if @feedback.urgent?
  # ... complex urgent handling
elsif @feedback.requires_approval?
  # ... complex approval logic
else
  # ... default handling
end
```

**Good Signs:**
```ruby
# ✅ GOOD: Thin controller (under 50 lines)
class FeedbacksController < ApplicationController
  # ... 30 lines total
end

# ✅ GOOD: Simple action method (5-10 lines)
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    redirect_to @feedback, notice: "Feedback created!"
  else
    render :new, status: :unprocessable_entity
  end
end
```
</pattern>

## Fat Controller Example

<pattern name="fat-controller-example">
<description>Example of a fat controller with multiple issues</description>

**Fat Controller (❌ ANTIPATTERN):**
```ruby
# ❌ BAD: 50+ lines with business logic, validations, API calls
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.status = :pending  # Business logic
    @feedback.submitted_at = Time.current

    # Manual validation
    if @feedback.content.blank? || @feedback.content.length < 50
      @feedback.errors.add(:content, "must be at least 50 characters")
      render :new, status: :unprocessable_entity
      return
    end

    # External API call
    begin
      response = Anthropic::Client.new.messages.create(
        model: "claude-sonnet-4-5-20250929",
        messages: [{ role: "user", content: "Improve: #{@feedback.content}" }]
      )
      @feedback.improved_content = response.content[0].text
    rescue => e
      @feedback.errors.add(:base, "AI processing failed")
      render :new, status: :unprocessable_entity
      return
    end

    if @feedback.save
      FeedbackMailer.notify_recipient(@feedback).deliver_later  # Notifications
      FeedbackTracking.create(feedback: @feedback, ip_address: request.remote_ip)  # Tracking
      redirect_to @feedback, notice: "Feedback created!"
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Problems:** Violates Single Responsibility, hard to test, cannot reuse in APIs, external dependencies in controller
</pattern>

## Refactoring to Thin Controller

<pattern name="refactor-to-thin-controller">
<description>Refactoring fat controller with proper separation of concerns</description>

**Step 1: Move Validations & Business Logic to Model**
```ruby
# ✅ GOOD: Model handles validations and defaults
class Feedback < ApplicationRecord
  validates :content, presence: true, length: { minimum: 50, maximum: 5000 }
  validates :recipient_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :set_defaults, on: :create
  after_create_commit :send_notification, :track_creation

  private

  def set_defaults
    self.status ||= :pending
    self.submitted_at ||= Time.current
  end

  def send_notification
    FeedbackMailer.notify_recipient(self).deliver_later
  end

  def track_creation
    FeedbackTrackingJob.perform_later(id)
  end
end
```

**Step 2: Extract Service Object for External APIs**
```ruby
# ✅ GOOD: Service object isolates external dependencies
# app/services/feedback_ai_processor.rb
class FeedbackAiProcessor
  def initialize(feedback)
    @feedback = feedback
  end

  def process
    return false unless @feedback.persisted?

    improved = call_anthropic_api
    @feedback.update(improved_content: improved, ai_improved: true)
    true
  rescue => e
    Rails.logger.error("AI processing failed: #{e.message}")
    false
  end

  private

  def call_anthropic_api
    response = Anthropic::Client.new.messages.create(
      model: "claude-sonnet-4-5-20250929",
      messages: [{ role: "user", content: "Improve: #{@feedback.content}" }]
    )
    response.content[0].text
  end
end
```

**Step 3: Thin Controller (Final Result)**
```ruby
# ✅ GOOD: 10 lines - only HTTP concerns
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      FeedbackAiProcessingJob.perform_later(@feedback.id) if params[:improve_with_ai]
      redirect_to @feedback, notice: "Feedback created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:content, :recipient_email, :sender_name)
  end
end
```

**Results:** Controller reduced from 55+ to 10 lines. Logic testable, reusable across web/API.
</pattern>

## Using Form Objects for Complex Forms

<pattern name="refactor-with-form-objects">
<description>Use form objects for multi-model operations</description>

**Form Object Handles Multi-Model Logic:**
```ruby
# ✅ GOOD: Form object encapsulates complex creation
# app/forms/feedback_creation_form.rb
class FeedbackCreationForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :content, :string
  attribute :recipient_email, :string
  attribute :files, default: []
  attribute :attach_files, :boolean, default: false

  validates :content, presence: true, length: { minimum: 50 }
  validate :files_required_when_attach_files_checked

  def save(ip_address:)
    return false unless valid?

    ActiveRecord::Base.transaction do
      @feedback = Feedback.create!(content: content, recipient_email: recipient_email)
      files.each { |f| @feedback.attachments.create!(file: f) } if files.present?
      FeedbackTracking.create!(feedback: @feedback, ip_address: ip_address)
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  attr_reader :feedback

  private

  def files_required_when_attach_files_checked
    errors.add(:base, "Files required") if attach_files && files.blank?
  end
end

# ✅ GOOD: Thin controller delegates to form object
class FeedbacksController < ApplicationController
  def create
    @form = FeedbackCreationForm.new(form_params)

    if @form.save(ip_address: request.remote_ip)
      redirect_to @form.feedback, notice: "Feedback created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def form_params
    params.require(:feedback_creation_form).permit(:content, :recipient_email, :attach_files, files: [])
  end
end
```
</pattern>

## Using Query Objects for Complex Queries

<pattern name="refactor-with-query-objects">
<description>Extract complex query logic to query objects</description>

**Query Object Encapsulates Filtering:**
```ruby
# ✅ GOOD: Chainable query object
# app/queries/feedback_query.rb
class FeedbackQuery
  def initialize(relation = Feedback.all)
    @relation = relation
  end

  def filter_by_recipient(email)
    return self if email.blank?
    @relation = @relation.where("recipient_email ILIKE ?", "%#{email}%")
    self
  end

  def filter_by_status(status)
    return self if status.blank?
    @relation = @relation.where(status: status)
    self
  end

  def filter_by_date_range(from: nil, to: nil)
    @relation = @relation.where("created_at >= ?", from) if from.present?
    @relation = @relation.where("created_at <= ?", to) if to.present?
    self
  end

  def search(query)
    return self if query.blank?
    @relation = @relation.where("content ILIKE ? OR response ILIKE ?", "%#{query}%", "%#{query}%")
    self
  end

  def sort_by(column, direction = :desc)
    @relation = @relation.order(column => direction)
    self
  end

  def results
    @relation
  end
end

# ✅ GOOD: Controller chains query methods
class FeedbacksController < ApplicationController
  def index
    @feedbacks = FeedbackQuery.new
      .filter_by_recipient(params[:recipient_email])
      .filter_by_status(params[:status])
      .filter_by_date_range(from: params[:date_from], to: params[:date_to])
      .search(params[:q])
      .sort_by(params[:sort] || "created_at", params[:direction]&.to_sym || :desc)
      .results
      .page(params[:page])
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Business logic in controllers</description>
<reason>Violates Single Responsibility, hard to test, prevents reuse</reason>
<bad-example>
```ruby
# ❌ BAD: Priority calculation in controller
def create
  @feedback = Feedback.new(feedback_params)
  @feedback.status = :pending
  @feedback.priority = @feedback.content.include?("urgent") ? :high : :low
  @feedback.save
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD: Logic in model callbacks
class Feedback < ApplicationRecord
  before_validation :set_defaults, :calculate_priority, on: :create

  def calculate_priority
    self.priority = content.to_s.include?("urgent") ? :high : :low
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>External service calls in controllers</description>
<reason>Hard to test, cannot reuse, slow requests</reason>
<bad-example>
```ruby
# ❌ BAD: API call blocks request
def create
  @feedback = Feedback.new(feedback_params)
  if @feedback.save
    response = Anthropic::Client.new.messages.create(...)
    @feedback.update(ai_response: response.content[0].text)
    redirect_to @feedback
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD: Service object + background job
class AiResponseService
  def process
    response = Anthropic::Client.new.messages.create(...)
    @feedback.update(ai_response: response.content[0].text)
  rescue => e
    Rails.logger.error("AI failed: #{e.message}")
  end
end

def create
  @feedback = Feedback.new(feedback_params)
  if @feedback.save
    AiResponseJob.perform_later(@feedback.id)
    redirect_to @feedback
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Multiple operations in one action</description>
<reason>Violates Single Responsibility, hard to test</reason>
<bad-example>
```ruby
# ❌ BAD: Notifications, analytics, cache in controller
def create
  if @feedback.save
    Notification.create!(...)
    Analytics.track(...)
    FeedbackMailer.notify_recipient(@feedback).deliver_now
    Rails.cache.delete("feedbacks_count")
    redirect_to @feedback
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD: Callbacks handle side effects
class Feedback < ApplicationRecord
  after_create_commit :send_notifications, :track_analytics, :clear_cache

  def send_notifications
    FeedbackMailer.notify_recipient(self).deliver_later
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Validations in controllers</description>
<reason>Cannot reuse, breaks ActiveRecord patterns</reason>
<bad-example>
```ruby
# ❌ BAD: Manual validation
def create
  @feedback = Feedback.new(feedback_params)
  if @feedback.content.length < 50
    @feedback.errors.add(:content, "too short")
    render :new
    return
  end
  @feedback.save
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD: Model validations
class Feedback < ApplicationRecord
  validates :content, length: { minimum: 50 }
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test each layer independently:

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "sets defaults and calculates priority" do
    feedback = Feedback.create!(content: "urgent issue!", recipient_email: "test@example.com")
    assert_equal :pending, feedback.status
    assert_equal :high, feedback.priority
  end

  test "enqueues notifications after creation" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      Feedback.create!(content: "Test content", recipient_email: "test@example.com")
    end
  end
end

# test/services/feedback_ai_processor_test.rb
class FeedbackAiProcessorTest < ActiveSupport::TestCase
  test "processes with AI and handles errors" do
    feedback = feedbacks(:one)
    stub_request(:post, /api.anthropic.com/).to_return(body: { content: [{ text: "Improved" }] }.to_json)

    assert FeedbackAiProcessor.new(feedback).process
    assert_equal "Improved", feedback.reload.improved_content
  end
end

# test/queries/feedback_query_test.rb
class FeedbackQueryTest < ActiveSupport::TestCase
  test "chains filters" do
    results = FeedbackQuery.new
      .filter_by_status(:pending)
      .search("test")
      .results

    assert_kind_of ActiveRecord::Relation, results
  end
end

# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "creates feedback and handles validation errors" do
    assert_difference "Feedback.count" do
      post feedbacks_url, params: { feedback: { content: "Valid content here", recipient_email: "test@example.com" } }
    end
    assert_redirected_to feedback_path(Feedback.last)
  end
end
```
</testing>

<related-skills>
- rails-ai:controller-restful - Building thin RESTful controllers
- rails-ai:form-objects - Extracting complex form logic
- rails-ai:query-objects - Extracting complex query logic
- rails-ai:activerecord-patterns - Proper use of callbacks and validations

- rails-ai:solid-stack-setup - Moving slow operations to background
</related-skills>

<resources>
- [Rails Guides - Action Controller](https://guides.rubyonrails.org/action_controller_overview.html)
- [Skinny Controllers, Fat Models](https://weblog.jamisbuck.org/2006/10/18/skinny-controller-fat-model)
- [7 Patterns to Refactor Fat ActiveRecord Models](https://codeclimate.com/blog/7-ways-to-decompose-fat-activerecord-models/)
- [Service Objects in Rails](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial)
</resources>
