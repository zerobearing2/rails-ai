---
name: form-objects
domain: backend
dependencies: []
version: 1.0
rails_version: 8.1+
---

# Form Objects Pattern

Encapsulate complex form logic, validation, and data processing using ActiveModel::API without requiring database-backed models.

<when-to-use>
- Multi-model forms (user registration creating User + Company + Membership)
- Non-database forms (contact, search, filters)
- Complex validation logic not belonging in models
- Virtual attributes not backed by database
- Wizard/multi-step forms with conditional validations
- API input validation and processing
</when-to-use>

<benefits>
- **Single Responsibility** - Each form handles one form's logic
- **Testable** - Test in isolation without database
- **Reusable** - Share across web and API controllers
- **Clean Models** - Keep ActiveRecord focused on persistence
- **Thin Controllers** - Extract complex form logic
- **Type Safety** - ActiveModel::Attributes provides type casting
</benefits>

<standards>
- Include `ActiveModel::API` and `ActiveModel::Attributes`
- Place in `app/forms/` directory
- Use `attribute` to define typed fields
- Provide action methods (`save`, `deliver`, `submit`) not `create`
- Wrap multi-model operations in transactions
- Return boolean from action methods
- Make created records available via attr_reader
</standards>

## Patterns

<pattern name="contact-form">
<description>Basic form object for non-database form (contact form)</description>

**Form Object:**
```ruby
# app/forms/contact_form.rb
class ContactForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :message, :string
  attribute :subject, :string

  validates :name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :subject, presence: true

  def deliver
    return false unless valid?

    ContactMailer.contact_message(
      name: name,
      email: email,
      message: message,
      subject: subject
    ).deliver_later

    true
  end
end
```

**Controller:**
```ruby
# app/controllers/contacts_controller.rb
class ContactsController < ApplicationController
  def create
    @contact_form = ContactForm.new(contact_params)

    if @contact_form.deliver
      redirect_to root_path, notice: "Message sent successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.expect(contact_form: [:name, :email, :message, :subject])
  end
end
```
</pattern>

<pattern name="multi-model-form">
<description>Form object that creates multiple related models in a transaction</description>

**Form Object:**
```ruby
# app/forms/user_registration_form.rb
class UserRegistrationForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :name, :string
  attribute :company_name, :string
  attribute :company_size, :string
  attribute :role, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }
  validates :password_confirmation, presence: true
  validates :name, presence: true
  validates :company_name, presence: true

  validate :passwords_match

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @user = create_user
      @company = create_company
      @membership = create_membership

      send_welcome_email
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  attr_reader :user, :company, :membership

  private

  def create_user
    User.create!(
      email: email,
      password: password,
      name: name
    )
  end

  def create_company
    Company.create!(
      name: company_name,
      size: company_size,
      owner: @user
    )
  end

  def create_membership
    Membership.create!(
      user: @user,
      company: @company,
      role: role || "admin"
    )
  end

  def send_welcome_email
    UserMailer.welcome(@user).deliver_later
  end

  def passwords_match
    return if password.blank?

    unless password == password_confirmation
      errors.add(:password_confirmation, "doesn't match password")
    end
  end
end
```

**Controller:**
```ruby
# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  def create
    @registration = UserRegistrationForm.new(registration_params)

    if @registration.save
      session[:user_id] = @registration.user.id
      redirect_to dashboard_path(@registration.company), notice: "Welcome!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.expect(user_registration_form: [
      :email, :password, :password_confirmation,
      :name, :company_name, :company_size, :role
    ])
  end
end
```
</pattern>

<pattern name="search-form">
<description>Form object for complex search/filter functionality</description>

**Form Object:**
```ruby
# app/forms/feedback_search_form.rb
class FeedbackSearchForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :query, :string
  attribute :status, :string
  attribute :date_from, :date
  attribute :date_to, :date
  attribute :recipient_email, :string
  attribute :sort_by, :string, default: "created_at"
  attribute :sort_direction, :string, default: "desc"

  validates :sort_by, inclusion: {
    in: %w[created_at updated_at status],
    message: "is not a valid sort field"
  }

  validates :sort_direction, inclusion: {
    in: %w[asc desc],
    message: "must be 'asc' or 'desc'"
  }

  def results
    return Feedback.none unless valid?

    scope = Feedback.all
    scope = apply_query(scope)
    scope = apply_status_filter(scope)
    scope = apply_date_range(scope)
    scope = apply_email_filter(scope)
    apply_sorting(scope)
  end

  private

  def apply_query(scope)
    query.present? ? scope.where("content ILIKE ? OR response ILIKE ?", "%#{query}%", "%#{query}%") : scope
  end

  def apply_status_filter(scope)
    status.present? ? scope.where(status: status) : scope
  end

  def apply_date_range(scope)
    scope = scope.where("created_at >= ?", date_from) if date_from.present?
    scope = scope.where("created_at <= ?", date_to) if date_to.present?
    scope
  end

  def apply_email_filter(scope)
    recipient_email.present? ? scope.where("recipient_email ILIKE ?", "%#{recipient_email}%") : scope
  end

  def apply_sorting(scope)
    scope.order("#{sort_by} #{sort_direction}")
  end
end
```

**Controller:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  def index
    @search_form = FeedbackSearchForm.new(search_params)
    @feedbacks = @search_form.results.page(params[:page])
  end

  private

  def search_params
    params.fetch(:feedback_search_form, {}).permit(
      :query, :status, :date_from, :date_to, :recipient_email,
      :sort_by, :sort_direction
    )
  end
end
```
</pattern>

<pattern name="wizard-form">
<description>Multi-step wizard form with conditional validations per step</description>

**Form Object:**
```ruby
# app/forms/feedback_wizard_form.rb
class FeedbackWizardForm
  include ActiveModel::API
  include ActiveModel::Attributes

  # Step 1: Recipient
  attribute :recipient_email, :string
  attribute :sender_name, :string

  # Step 2: Content
  attribute :content, :string
  attribute :category, :string

  # Step 3: Options
  attribute :allow_ai_improvement, :boolean, default: false
  attribute :sender_email, :string

  # Wizard state
  attribute :current_step, :integer, default: 1

  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :step_1?
  validates :sender_name, presence: true, if: :step_1?

  validates :content, presence: true, length: { minimum: 10 }, if: :step_2?
  validates :category, presence: true, if: :step_2?

  validates :sender_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }, if: :step_3?

  def next_step
    return false unless valid_for_current_step?

    self.current_step += 1
    true
  end

  def previous_step
    self.current_step -= 1 if current_step > 1
  end

  def complete?
    current_step > 3
  end

  def save
    return false unless valid?

    feedback = Feedback.create!(
      recipient_email: recipient_email,
      sender_name: sender_name,
      content: content,
      category: category,
      allow_ai_improvement: allow_ai_improvement,
      sender_email: sender_email
    )

    feedback.improve_with_ai if allow_ai_improvement

    true
  end

  private

  def valid_for_current_step?
    validate_context(:"step_#{current_step}")
  end

  %i[step_1 step_2 step_3].each do |step|
    define_method(:"#{step}?") { validation_context == step }
  end

  def validate_context(context)
    self.validation_context = context
    valid?
  ensure
    self.validation_context = nil
  end
end
```

**Controller:**
```ruby
# app/controllers/feedback_wizard_controller.rb
class FeedbackWizardController < ApplicationController
  def update
    @form = FeedbackWizardForm.new(session[:wizard_data] || {})
    @form.assign_attributes(form_params)

    if @form.next_step
      if @form.complete?
        @form.save ? (session.delete(:wizard_data); redirect_to success_path) : render(:show, status: :unprocessable_entity)
      else
        session[:wizard_data] = @form.attributes
        redirect_to feedback_wizard_path
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def form_params
    params.expect(feedback_wizard_form: [:recipient_email, :sender_name, :content, :category, :allow_ai_improvement, :sender_email])
  end
end
```
</pattern>

<pattern name="api-form">
<description>Form object for API endpoints with JSON serialization</description>

**Form Object:**
```ruby
# app/forms/api/feedback_submission_form.rb
module Api
  class FeedbackSubmissionForm
    include ActiveModel::API
    include ActiveModel::Attributes
    include ActiveModel::Serialization

    attribute :recipient_email, :string
    attribute :content, :string
    attribute :sender_name, :string
    attribute :sender_email, :string
    attribute :category, :string
    attribute :metadata, :json, default: {}

    validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :content, presence: true, length: { minimum: 10, maximum: 5000 }
    validates :sender_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

    validate :validate_metadata

    def submit
      return false unless valid?

      @feedback = Feedback.create!(attributes.except("metadata"))
      @feedback.update(metadata: metadata) if metadata.present?

      FeedbackMailer.notify_recipient(@feedback).deliver_later

      true
    end

    attr_reader :feedback

    def as_json(options = {})
      feedback ? { success: true, feedback: { id: feedback.id, token: feedback.token, created_at: feedback.created_at } } : { success: false, errors: errors.as_json }
    end

    private

    def validate_metadata
      errors.add(:metadata, "must be a valid JSON object") if metadata.present? && !metadata.is_a?(Hash)
    end
  end
end
```

**API Controller:**
```ruby
# app/controllers/api/feedbacks_controller.rb
module Api
  class FeedbacksController < ApiController
    def create
      form = FeedbackSubmissionForm.new(feedback_params)
      form.submit ? render(json: form, status: :created) : render(json: form, status: :unprocessable_entity)
    end

    private

    def feedback_params
      params.expect(feedback: [:recipient_email, :content, :sender_name, :sender_email, :category, :metadata])
    end
  end
end
```
</pattern>

## When to Use Form Objects vs ActiveRecord

<pattern name="decision-guide">
<description>Guidelines for choosing between form objects and ActiveRecord</description>

**Use ActiveRecord directly when:**
```ruby
# ✅ Simple CRUD on single model
class ArticlesController < ApplicationController
  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Use Form Objects when:**
```ruby
# ✅ Multiple models: UserRegistrationForm (creates User + Company + Membership)
# ✅ Non-database: ContactForm (sends email, no persistence)
# ✅ Virtual attributes: PriceCalculatorForm (calculates, doesn't save)
# ✅ Complex logic: OrderCheckoutForm (inventory, payment, order, confirmation)
```
</pattern>

<antipatterns>
<antipattern>
<description>Fat controllers with complex form logic</description>
<reason>Violates Single Responsibility Principle, hard to test and reuse</reason>
<bad-example>
```ruby
# ❌ BAD - All logic in controller
class RegistrationsController < ApplicationController
  def create
    @user = User.new(user_params)
    @company = Company.new(company_params)

    ActiveRecord::Base.transaction do
      if @user.save
        @company.owner = @user
        if @company.save
          @membership = Membership.create(user: @user, company: @company, role: "admin")
          UserMailer.welcome(@user).deliver_later
          redirect_to dashboard_path(@company)
        end
      end
    end
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use form object
class RegistrationsController < ApplicationController
  def create
    @registration = UserRegistrationForm.new(registration_params)
    @registration.save ? redirect_to(dashboard_path(@registration.company)) : render(:new, status: :unprocessable_entity)
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not wrapping multi-model operations in transactions</description>
<reason>Partial data corruption if one operation fails</reason>
<bad-example>
```ruby
# ❌ BAD - No transaction
def save
  return false unless valid?
  @user = User.create!(email: email, password: password)
  @company = Company.create!(name: company_name, owner: @user)
  @membership = Membership.create!(user: @user, company: @company) # If this fails, user and company already created!
  true
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use transaction
def save
  return false unless valid?
  ActiveRecord::Base.transaction do
    @user = User.create!(email: email, password: password)
    @company = Company.create!(name: company_name, owner: @user)
    @membership = Membership.create!(user: @user, company: @company)
    true
  end
rescue ActiveRecord::RecordInvalid => e
  errors.add(:base, e.message)
  false
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using form objects for simple single-model operations</description>
<reason>Unnecessary abstraction adds complexity without benefits</reason>
<bad-example>
```ruby
# ❌ BAD - Overkill for simple CRUD
class ArticleForm
  include ActiveModel::API
  include ActiveModel::Attributes
  attribute :title, :string
  attribute :content, :text
  def save; Article.create!(title: title, content: content); end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use ActiveRecord directly
@article = Article.new(article_params)
@article.save ? redirect_to(@article) : render(:new, status: :unprocessable_entity)
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test form objects in isolation without database dependencies:

```ruby
# test/forms/contact_form_test.rb
class ContactFormTest < ActiveSupport::TestCase
  test "valid with all required attributes" do
    form = ContactForm.new(name: "John", email: "john@example.com", subject: "Question", message: "This is my message")
    assert form.valid?
  end

  test "invalid without required fields" do
    form = ContactForm.new(email: "john@example.com")
    assert_not form.valid?
    assert_includes form.errors[:name], "can't be blank"
  end

  test "delivers email when valid" do
    form = ContactForm.new(name: "John", email: "john@example.com", subject: "Q", message: "This is my message")
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) { assert form.deliver }
  end
end

# test/forms/user_registration_form_test.rb
class UserRegistrationFormTest < ActiveSupport::TestCase
  test "creates user, company, and membership" do
    form = UserRegistrationForm.new(email: "user@example.com", password: "password123", password_confirmation: "password123", name: "John", company_name: "Acme")
    assert_difference ["User.count", "Company.count", "Membership.count"] { assert form.save }
    assert_equal "Acme", form.company.name
  end

  test "rolls back transaction if creation fails" do
    form = UserRegistrationForm.new(email: "user@example.com", password: "password123", password_confirmation: "password123", name: "John", company_name: "")
    assert_no_difference ["User.count", "Company.count"] { assert_not form.save }
  end
end

# test/forms/feedback_search_form_test.rb
class FeedbackSearchFormTest < ActiveSupport::TestCase
  test "filters by query text" do
    form = FeedbackSearchForm.new(query: feedbacks(:one).content)
    assert_includes form.results, feedbacks(:one)
  end

  test "filters by date range" do
    form = FeedbackSearchForm.new(date_from: 1.week.ago, date_to: Date.current)
    form.results.each { |fb| assert fb.created_at >= 1.week.ago }
  end
end
```
</testing>

<related-skills>
- custom-validators - Custom validations
- controller-restful - Using in controllers

</related-skills>

<resources>
- [Rails Guides - Active Model Basics](https://guides.rubyonrails.org/active_model_basics.html)
- [Rails API - ActiveModel::API](https://api.rubyonrails.org/classes/ActiveModel/API.html)
- [Rails API - ActiveModel::Attributes](https://api.rubyonrails.org/classes/ActiveModel/Attributes.html)
</resources>
