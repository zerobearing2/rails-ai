---
name: antipattern-fat-controllers
domain: backend
dependencies: [controller-restful, form-objects, query-objects]
version: 1.0
rails_version: 8.1+
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
<description>Comprehensive example of a fat controller with multiple issues</description>

**Fat Controller (❌ ANTIPATTERN):**
```ruby
# ❌ BAD: Fat controller with business logic
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)

    # ❌ SMELL: Business logic in controller
    @feedback.status = :pending
    @feedback.submitted_at = Time.current

    # ❌ SMELL: Complex validation in controller
    if @feedback.content.blank? || @feedback.content.length < 50
      @feedback.errors.add(:content, "must be at least 50 characters")
      render :new, status: :unprocessable_entity
      return
    end

    # ❌ SMELL: External service calls in controller
    begin
      anthropic_client = Anthropic::Client.new
      response = anthropic_client.messages.create(
        model: "claude-sonnet-4-5-20250929",
        max_tokens: 2000,
        messages: [
          { role: "user", content: "Improve this feedback: #{@feedback.content}" }
        ]
      )
      @feedback.improved_content = response.content[0].text
    rescue => e
      @feedback.errors.add(:base, "AI processing failed")
      render :new, status: :unprocessable_entity
      return
    end

    # ❌ SMELL: Multiple model operations in controller
    if @feedback.save
      # ❌ SMELL: Manual notification logic in controller
      FeedbackMailer.notify_recipient(@feedback).deliver_later

      # ❌ SMELL: Tracking logic in controller
      FeedbackTracking.create(
        feedback: @feedback,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )

      redirect_to @feedback, notice: "Feedback created!"
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Why This is Bad:**
1. Business logic should be in models
2. Validations belong in model, not controller
3. External service calls should be in service objects
4. Multiple model operations should be in service object or model
5. Notification logic should be callback or service
6. Makes controller hard to test
7. Violates Single Responsibility Principle
8. Cannot reuse logic in API or other controllers
</pattern>

## Refactoring to Thin Controller

<pattern name="refactor-to-thin-controller">
<description>Step-by-step refactoring of fat controller into thin controller with proper separation</description>

**Step 1: Move Validations to Model**
```ruby
# ✅ GOOD: Validations in model
class Feedback < ApplicationRecord
  validates :content, presence: true, length: { minimum: 50, maximum: 5000 }
  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Business logic in model
  before_validation :set_defaults, on: :create

  private

  def set_defaults
    self.status ||= :pending
    self.submitted_at ||= Time.current
  end
end
```

**Step 2: Extract Service Object for AI Processing**
```ruby
# ✅ GOOD: Service object for external API
# app/services/feedback_ai_processor.rb
class FeedbackAiProcessor
  def initialize(feedback)
    @feedback = feedback
  end

  def process
    return false unless @feedback.persisted?

    improved_content = call_anthropic_api
    @feedback.update(
      improved_content: improved_content,
      ai_improved: true
    )
    true
  rescue => e
    Rails.logger.error("AI processing failed: #{e.message}")
    false
  end

  private

  attr_reader :feedback

  def call_anthropic_api
    client = Anthropic::Client.new
    response = client.messages.create(
      model: "claude-sonnet-4-5-20250929",
      max_tokens: 2000,
      messages: [
        { role: "user", content: "Improve this feedback: #{feedback.content}" }
      ]
    )
    response.content[0].text
  end
end
```

**Step 3: Add Model Callbacks for Side Effects**
```ruby
# ✅ GOOD: Callbacks for notifications
class Feedback < ApplicationRecord
  after_create_commit :send_notification
  after_create_commit :track_creation

  private

  def send_notification
    FeedbackMailer.notify_recipient(self).deliver_later
  end

  def track_creation
    # Track in background job to avoid slowing down request
    FeedbackTrackingJob.perform_later(id)
  end
end

# app/jobs/feedback_tracking_job.rb
class FeedbackTrackingJob < ApplicationJob
  queue_as :default

  def perform(feedback_id)
    feedback = Feedback.find(feedback_id)
    FeedbackTracking.create(
      feedback: feedback,
      created_at: feedback.created_at
    )
  end
end
```

**Step 4: Thin Controller (Final Result)**
```ruby
# ✅ GOOD: Thin controller - only HTTP concerns
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      # Process AI improvement asynchronously if requested
      process_with_ai if params[:improve_with_ai]

      redirect_to @feedback, notice: "Feedback was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:content, :recipient_email, :sender_name)
  end

  def process_with_ai
    FeedbackAiProcessingJob.perform_later(@feedback.id)
  end
end

# app/jobs/feedback_ai_processing_job.rb
class FeedbackAiProcessingJob < ApplicationJob
  queue_as :default

  def perform(feedback_id)
    feedback = Feedback.find(feedback_id)
    FeedbackAiProcessor.new(feedback).process
  end
end
```

**Results:**
- Controller: 15 lines (was 55+)
- Business logic: Moved to model
- Validations: Moved to model
- External API: Extracted to service object
- Side effects: Handled by callbacks and background jobs
- Testable: Each component can be tested independently
- Reusable: Logic available to API controllers and background jobs
</pattern>

## Using Form Objects for Complex Forms

<pattern name="refactor-with-form-objects">
<description>Use form objects for multi-model or complex form operations</description>

**Fat Controller with Multi-Model Logic:**
```ruby
# ❌ BAD: Multi-model creation in controller
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.status = :pending

    # Validate custom rules
    if params[:attach_files] && params[:files].blank?
      @feedback.errors.add(:base, "Files required when attach_files is checked")
      render :new
      return
    end

    ActiveRecord::Base.transaction do
      if @feedback.save
        # Create related records
        if params[:files].present?
          params[:files].each do |file|
            @feedback.attachments.create!(file: file)
          end
        end

        # Create tracking
        FeedbackTracking.create!(
          feedback: @feedback,
          source: params[:source],
          ip_address: request.remote_ip
        )

        # Send notifications
        FeedbackMailer.notify_recipient(@feedback).deliver_later

        redirect_to @feedback
      else
        render :new
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @feedback.errors.add(:base, e.message)
    render :new
  end
end
```

**Refactored with Form Object:**
```ruby
# ✅ GOOD: Form object handles multi-model logic
# app/forms/feedback_creation_form.rb
class FeedbackCreationForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :content, :string
  attribute :recipient_email, :string
  attribute :sender_name, :string
  attribute :source, :string
  attribute :files, default: []
  attribute :attach_files, :boolean, default: false

  validates :content, presence: true, length: { minimum: 50 }
  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validate :files_required_when_attach_files_checked

  def save(ip_address:)
    return false unless valid?

    ActiveRecord::Base.transaction do
      @feedback = create_feedback
      create_attachments if files.present?
      create_tracking(ip_address)
      send_notification
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  attr_reader :feedback

  private

  def create_feedback
    Feedback.create!(
      content: content,
      recipient_email: recipient_email,
      sender_name: sender_name,
      status: :pending,
      submitted_at: Time.current
    )
  end

  def create_attachments
    files.each do |file|
      @feedback.attachments.create!(file: file)
    end
  end

  def create_tracking(ip_address)
    FeedbackTracking.create!(
      feedback: @feedback,
      source: source,
      ip_address: ip_address
    )
  end

  def send_notification
    FeedbackMailer.notify_recipient(@feedback).deliver_later
  end

  def files_required_when_attach_files_checked
    if attach_files && files.blank?
      errors.add(:base, "Files required when attach_files is checked")
    end
  end
end

# ✅ GOOD: Thin controller using form object
class FeedbacksController < ApplicationController
  def new
    @form = FeedbackCreationForm.new
  end

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
    params.require(:feedback_creation_form).permit(
      :content, :recipient_email, :sender_name, :source, :attach_files, files: []
    )
  end
end
```
</pattern>

## Using Query Objects for Complex Queries

<pattern name="refactor-with-query-objects">
<description>Extract complex query logic from controllers to query objects</description>

**Fat Controller with Query Logic:**
```ruby
# ❌ BAD: Complex query logic in controller
class FeedbacksController < ApplicationController
  def index
    @feedbacks = Feedback.all

    # Filter by recipient
    if params[:recipient_email].present?
      @feedbacks = @feedbacks.where(
        "recipient_email ILIKE ?",
        "%#{params[:recipient_email]}%"
      )
    end

    # Filter by status
    if params[:status].present?
      @feedbacks = @feedbacks.where(status: params[:status])
    end

    # Filter by date range
    if params[:date_from].present?
      @feedbacks = @feedbacks.where("created_at >= ?", params[:date_from])
    end

    if params[:date_to].present?
      @feedbacks = @feedbacks.where("created_at <= ?", params[:date_to])
    end

    # Search content
    if params[:q].present?
      @feedbacks = @feedbacks.where(
        "content ILIKE ? OR response ILIKE ?",
        "%#{params[:q]}%",
        "%#{params[:q]}%"
      )
    end

    # Sort
    sort_column = params[:sort] || "created_at"
    sort_direction = params[:direction] == "asc" ? :asc : :desc
    @feedbacks = @feedbacks.order(sort_column => sort_direction)

    # Paginate
    @feedbacks = @feedbacks.page(params[:page]).per(25)
  end
end
```

**Refactored with Query Object:**
```ruby
# ✅ GOOD: Query object handles filtering
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
    @relation = @relation.where(
      "content ILIKE ? OR response ILIKE ?",
      "%#{query}%",
      "%#{query}%"
    )
    self
  end

  def sort_by(column, direction = :desc)
    @relation = @relation.order(column => direction)
    self
  end

  def paginate(page:, per_page: 25)
    @relation = @relation.page(page).per(per_page)
    self
  end

  def results
    @relation
  end
end

# ✅ GOOD: Thin controller using query object
class FeedbacksController < ApplicationController
  def index
    sort_column = params[:sort] || "created_at"
    sort_direction = params[:direction] == "asc" ? :asc : :desc

    @feedbacks = FeedbackQuery.new
      .filter_by_recipient(params[:recipient_email])
      .filter_by_status(params[:status])
      .filter_by_date_range(from: params[:date_from], to: params[:date_to])
      .search(params[:q])
      .sort_by(sort_column, sort_direction)
      .paginate(page: params[:page])
      .results
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Putting business logic in controllers</description>
<reason>Violates Single Responsibility, makes testing hard, prevents reuse</reason>
<bad-example>
```ruby
# ❌ BAD: Business logic in controller
def create
  @feedback = Feedback.new(feedback_params)
  @feedback.status = :pending
  @feedback.submitted_at = Time.current

  # Calculate priority
  if @feedback.content.include?("urgent")
    @feedback.priority = :high
  elsif @feedback.content.length > 500
    @feedback.priority = :medium
  else
    @feedback.priority = :low
  end

  @feedback.save
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD: Business logic in model
class Feedback < ApplicationRecord
  before_validation :set_defaults, on: :create
  before_validation :calculate_priority, on: :create

  private

  def set_defaults
    self.status ||= :pending
    self.submitted_at ||= Time.current
  end

  def calculate_priority
    self.priority = if content.to_s.include?("urgent")
      :high
    elsif content.to_s.length > 500
      :medium
    else
      :low
    end
  end
end

# ✅ GOOD: Thin controller
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    redirect_to @feedback
  else
    render :new, status: :unprocessable_entity
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>External service calls in controllers</description>
<reason>Hard to test, cannot reuse, makes controllers slow</reason>
<bad-example>
```ruby
# ❌ BAD: External API call in controller
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    # External service call
    client = Anthropic::Client.new
    response = client.messages.create(
      model: "claude-sonnet-4-5-20250929",
      messages: [{ role: "user", content: @feedback.content }]
    )
    @feedback.update(ai_response: response.content[0].text)

    redirect_to @feedback
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD: Extract to service object
class AiResponseService
  def self.process(feedback)
    new(feedback).process
  end

  def initialize(feedback)
    @feedback = feedback
  end

  def process
    response = call_api
    @feedback.update(ai_response: response)
  rescue => e
    Rails.logger.error("AI API failed: #{e.message}")
    false
  end

  private

  def call_api
    client = Anthropic::Client.new
    response = client.messages.create(
      model: "claude-sonnet-4-5-20250929",
      messages: [{ role: "user", content: @feedback.content }]
    )
    response.content[0].text
  end
end

# ✅ GOOD: Controller delegates to service
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    AiResponseJob.perform_later(@feedback.id)
    redirect_to @feedback, notice: "Feedback submitted!"
  else
    render :new, status: :unprocessable_entity
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Multiple unrelated operations in one action</description>
<reason>Hard to maintain, test, and debug; violates Single Responsibility</reason>
<bad-example>
```ruby
# ❌ BAD: Too many responsibilities
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    # Create notification
    Notification.create!(user: @feedback.recipient, message: "New feedback")

    # Log analytics
    Analytics.track("feedback_created", @feedback.id)

    # Update user stats
    @feedback.recipient.increment!(:feedback_count)

    # Send emails
    FeedbackMailer.notify_recipient(@feedback).deliver_now
    FeedbackMailer.notify_admin(@feedback).deliver_now

    # Update cache
    Rails.cache.delete("feedbacks_count")

    redirect_to @feedback
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD: Delegate to callbacks and background jobs
class Feedback < ApplicationRecord
  after_create_commit :trigger_notifications
  after_create_commit :update_analytics
  after_create_commit :clear_cache

  private

  def trigger_notifications
    NotificationCreatorJob.perform_later(id)
    FeedbackMailer.notify_recipient(self).deliver_later
    FeedbackMailer.notify_admin(self).deliver_later
  end

  def update_analytics
    AnalyticsJob.perform_later("feedback_created", id)
  end

  def clear_cache
    Rails.cache.delete("feedbacks_count")
  end
end

# ✅ GOOD: Simple controller
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    redirect_to @feedback, notice: "Feedback created!"
  else
    render :new, status: :unprocessable_entity
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Custom validations in controllers instead of models</description>
<reason>Cannot reuse, bypasses model validations, breaks ActiveRecord patterns</reason>
<bad-example>
```ruby
# ❌ BAD: Validation in controller
def create
  @feedback = Feedback.new(feedback_params)

  # Custom validation
  if @feedback.content.length < 50
    @feedback.errors.add(:content, "must be at least 50 characters")
    render :new
    return
  end

  if @feedback.recipient_email !~ URI::MailTo::EMAIL_REGEXP
    @feedback.errors.add(:recipient_email, "is not a valid email")
    render :new
    return
  end

  @feedback.save
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD: Validation in model
class Feedback < ApplicationRecord
  validates :content, length: { minimum: 50, maximum: 5000 }
  validates :recipient_email, format: { with: URI::MailTo::EMAIL_REGEXP }
end

# ✅ GOOD: Controller just saves
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    redirect_to @feedback
  else
    render :new, status: :unprocessable_entity
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test refactored components independently:

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "sets defaults on creation" do
    feedback = Feedback.create!(content: "Test content", recipient_email: "test@example.com")

    assert_equal :pending, feedback.status
    assert_not_nil feedback.submitted_at
  end

  test "calculates priority based on content" do
    feedback = Feedback.create!(
      content: "This is urgent!",
      recipient_email: "test@example.com"
    )

    assert_equal :high, feedback.priority
  end

  test "sends notification after creation" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      Feedback.create!(content: "Test", recipient_email: "test@example.com")
    end
  end
end

# test/services/feedback_ai_processor_test.rb
class FeedbackAiProcessorTest < ActiveSupport::TestCase
  test "processes feedback with AI" do
    feedback = feedbacks(:one)

    stub_request(:post, /api.anthropic.com/)
      .to_return(body: { content: [{ text: "Improved content" }] }.to_json)

    processor = FeedbackAiProcessor.new(feedback)
    result = processor.process

    assert result
    assert_equal "Improved content", feedback.reload.improved_content
  end

  test "handles API errors gracefully" do
    feedback = feedbacks(:one)

    stub_request(:post, /api.anthropic.com/)
      .to_raise(StandardError.new("API Error"))

    processor = FeedbackAiProcessor.new(feedback)
    result = processor.process

    assert_not result
  end
end

# test/queries/feedback_query_test.rb
class FeedbackQueryTest < ActiveSupport::TestCase
  test "filters by recipient email" do
    feedback1 = feedbacks(:one)
    feedback2 = feedbacks(:two)

    feedback1.update(recipient_email: "user@example.com")
    feedback2.update(recipient_email: "other@example.com")

    results = FeedbackQuery.new
      .filter_by_recipient("user@example.com")
      .results

    assert_includes results, feedback1
    assert_not_includes results, feedback2
  end

  test "chains multiple filters" do
    results = FeedbackQuery.new
      .filter_by_status(:pending)
      .filter_by_date_range(from: 1.week.ago)
      .search("test")
      .results

    assert_kind_of ActiveRecord::Relation, results
  end
end

# test/forms/feedback_creation_form_test.rb
class FeedbackCreationFormTest < ActiveSupport::TestCase
  test "creates feedback with tracking" do
    form = FeedbackCreationForm.new(
      content: "Test feedback content that is long enough",
      recipient_email: "recipient@example.com",
      sender_name: "John Doe",
      source: "web"
    )

    assert_difference ["Feedback.count", "FeedbackTracking.count"] do
      assert form.save(ip_address: "127.0.0.1")
    end

    assert_equal "Test feedback content that is long enough", form.feedback.content
  end

  test "validates files when attach_files is checked" do
    form = FeedbackCreationForm.new(
      content: "Test",
      attach_files: true,
      files: []
    )

    assert_not form.valid?
    assert_includes form.errors[:base], "Files required when attach_files is checked"
  end
end

# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "creates feedback successfully" do
    assert_difference "Feedback.count" do
      post feedbacks_url, params: {
        feedback: {
          content: "Great product! Would recommend to others.",
          recipient_email: "recipient@example.com"
        }
      }
    end

    assert_redirected_to feedback_path(Feedback.last)
  end

  test "renders errors when validation fails" do
    assert_no_difference "Feedback.count" do
      post feedbacks_url, params: {
        feedback: { content: "Short" }
      }
    end

    assert_response :unprocessable_entity
  end
end
```
</testing>

<related-skills>
- controller-restful - Building thin RESTful controllers
- form-objects - Extracting complex form logic
- query-objects - Extracting complex query logic
- activerecord-patterns - Proper use of callbacks and validations
- service-objects - Extracting business logic to services
- background-jobs - Moving slow operations to background
</related-skills>

<resources>
- [Rails Guides - Action Controller](https://guides.rubyonrails.org/action_controller_overview.html)
- [Skinny Controllers, Fat Models](https://weblog.jamisbuck.org/2006/10/18/skinny-controller-fat-model)
- [7 Patterns to Refactor Fat ActiveRecord Models](https://codeclimate.com/blog/7-ways-to-decompose-fat-activerecord-models/)
- [Service Objects in Rails](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial)
</resources>
