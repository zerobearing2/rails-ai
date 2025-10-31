---
name: nested-resources
domain: backend
dependencies: [controller-restful]
version: 1.0
rails_version: 8.1+

# Team rules enforcement
enforces_team_rule:
  - rule_id: 3
    rule_name: "RESTful Routes Only"
    severity: critical
    enforcement_action: REJECT
    note: "Provides alternative to custom route actions"
  - rule_id: 5
    rule_name: "Proper Namespacing"
    severity: moderate
    enforcement_action: SUGGEST
---

# Nested Resources

Organize Rails routes and controllers using nested resource patterns with proper module namespacing and directory structure for parent-child relationships.

<when-to-use>
- Resources that belong to a parent resource (comments belong to posts)
- Actions that only make sense in the context of a parent (project tasks)
- Enforcing scope through URL structure (/feedbacks/:id/responses)
- Creating RESTful child controllers without custom actions
- Organizing related models and controllers in subdirectories
- Building hierarchical data structures with clear ownership
</when-to-use>

<benefits>
- **Clear Hierarchy** - URL structure reflects data relationships
- **Scoped Access** - Parent context automatically available
- **Organization** - Related controllers/models grouped in directories
- **REST Compliance** - Maintains RESTful patterns for child resources
- **Namespace Safety** - Prevents naming conflicts with module namespacing
- **Discoverability** - Directory structure matches route structure
</benefits>

<standards>
- Use PLURAL parent directory for child controllers (feedbacks/, not feedback/) - e.g., Feedbacks::ResponsesController
- Use SINGULAR parent directory for domain controllers (user/, not users/) - e.g., Users::SettingsController
- Always use module namespacing (`module Feedbacks; class ResponsesController` or `module Users; class SettingsController`)
- Use `module:` parameter in routes for automatic namespace mapping
- Limit nesting to 1 level deep (use shallow nesting for deeper hierarchies)
- Scope child resources through parent associations in controllers
- Mirror directory structure in tests and fixtures
- Prefer `resource` (singular) for single child actions like archival, publishing
- Use `resources` (plural) for full CRUD child resources
</standards>

## Controller Naming Patterns

### Child Controllers (PLURAL namespace)
Use for resources that belong to a parent resource:
- `Feedbacks::ResponsesController` - responses belong to feedbacks
- `Orders::LineItemsController` - line items belong to orders
- `Projects::TasksController` - tasks belong to projects

### Domain Controllers (SINGULAR namespace)
Use for managing aspects/settings of the parent entity itself:
- `Users::SettingsController` - manage user settings (not a separate "settings" entity)
- `Users::ProfilesController` - manage user profile (singular aspect of user)
- `Accounts::BillingController` - manage account billing (singular aspect)

**Decision Guide:**
- **Child Controller (PLURAL)**: If the resource can have multiple instances per parent → use plural
  - User has many Posts → `Users::PostsController`
  - Feedback has many Responses → `Feedbacks::ResponsesController`

- **Domain Controller (SINGULAR)**: If managing a singular aspect of the parent → use singular
  - User has one Setting → `Users::SettingsController`
  - User has one Profile → `Users::ProfilesController`

## Patterns

<pattern name="nested-child-controllers">
<description>Child controllers using module namespacing and nested routes</description>

**Routes:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :feedbacks do
    # Singular resources for single actions
    resource :sending, only: [:create], module: :feedbacks
    resource :retry, only: [:create], module: :feedbacks
    resource :publication, only: [:create, :destroy], module: :feedbacks

    # Plural resources for full CRUD
    resources :responses, only: [:index, :create, :destroy], module: :feedbacks
    resources :attachments, only: [:index, :create, :destroy], module: :feedbacks
  end
end

# Generated routes:
# POST   /feedbacks/:feedback_id/sending           feedbacks/sendings#create
# POST   /feedbacks/:feedback_id/retry             feedbacks/retries#create
# POST   /feedbacks/:feedback_id/publication       feedbacks/publications#create
# DELETE /feedbacks/:feedback_id/publication       feedbacks/publications#destroy
# GET    /feedbacks/:feedback_id/responses         feedbacks/responses#index
# POST   /feedbacks/:feedback_id/responses         feedbacks/responses#create
# DELETE /feedbacks/:feedback_id/responses/:id     feedbacks/responses#destroy
```

**Singular Resource Controller:**
```ruby
# app/controllers/feedbacks/sendings_controller.rb
module Feedbacks
  class SendingsController < ApplicationController
    before_action :set_feedback

    # POST /feedbacks/:feedback_id/sending
    def create
      if @feedback.ready_to_send?
        @feedback.start_sending!
        SendFeedbackEmailJob.perform_later(@feedback.id)

        redirect_to @feedback, notice: "Feedback is being sent"
      else
        redirect_to @feedback, alert: "Feedback is not ready to send"
      end
    end

    private

    def set_feedback
      @feedback = Feedback.find(params[:feedback_id])
    end
  end
end
```

**Full CRUD Child Controller:**
```ruby
# app/controllers/feedbacks/responses_controller.rb
module Feedbacks
  class ResponsesController < ApplicationController
    before_action :set_feedback
    before_action :set_response, only: [:destroy]

    # GET /feedbacks/:feedback_id/responses
    def index
      @responses = @feedback.responses.order(created_at: :desc)
    end

    # POST /feedbacks/:feedback_id/responses
    def create
      @response = @feedback.responses.build(response_params)

      if @response.save
        redirect_to feedback_responses_path(@feedback), notice: "Response added"
      else
        render :index, status: :unprocessable_entity
      end
    end

    # DELETE /feedbacks/:feedback_id/responses/:id
    def destroy
      @response.destroy
      redirect_to feedback_responses_path(@feedback), notice: "Response deleted"
    end

    private

    def set_feedback
      @feedback = Feedback.find(params[:feedback_id])
    end

    def set_response
      @response = @feedback.responses.find(params[:id])
    end

    def response_params
      params.require(:response).permit(:content, :author_name)
    end
  end
end
```

**View Usage:**
```erb
<%# app/views/feedbacks/show.html.erb %>
<%= button_to "Send Feedback", feedback_sending_path(@feedback), method: :post %>
<%= button_to "Retry AI", feedback_retry_path(@feedback), method: :post %>
<%= link_to "View Responses", feedback_responses_path(@feedback) %>
<%= link_to "Manage Attachments", feedback_attachments_path(@feedback) %>
```
</pattern>

<pattern name="domain-specific-controllers">
<description>Controllers for managing singular aspects of a parent entity using singular namespace</description>

**When to Use:**
- Managing settings, profiles, or preferences for a parent entity
- The parent has_one relationship (not has_many)
- Controller manages an aspect of the parent, not a separate collection
- Avoid flat naming like UsersSettingsController or UserSettingsController

**Routes:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Domain-specific controllers use singular parent path
  scope :users do
    resource :settings, only: [:show, :edit, :update], controller: "users/settings"
    resource :profile, only: [:show, :edit, :update], controller: "users/profile"
    resource :preferences, only: [:show, :update], controller: "users/preferences"
  end

  # Or namespace approach (cleaner for multiple domain controllers)
  namespace :users do
    resource :settings, only: [:show, :edit, :update]
    resource :profile, only: [:show, :edit, :update]
    resource :preferences, only: [:show, :update]
  end
end

# Generated routes:
# GET    /users/settings           users/settings#show
# GET    /users/settings/edit      users/settings#edit
# PATCH  /users/settings           users/settings#update
# GET    /users/profile            users/profile#show
# GET    /users/profile/edit       users/profile#edit
# PATCH  /users/profile            users/profile#update
```

**Domain Controller:**
```ruby
# app/controllers/users/settings_controller.rb
module Users
  class SettingsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_setting

    # GET /users/settings
    def show
      # @setting set by before_action
    end

    # GET /users/settings/edit
    def edit
      # @setting set by before_action
    end

    # PATCH /users/settings
    def update
      if @setting.update(setting_params)
        redirect_to users_settings_path, notice: "Settings updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_setting
      @setting = current_user.setting || current_user.build_setting
    end

    def setting_params
      params.require(:user_setting).permit(:theme, :notifications_enabled, :language)
    end
  end
end
```

**Associated Model:**
```ruby
# app/models/user/setting.rb
module User
  class Setting < ApplicationRecord
    belongs_to :user

    validates :theme, inclusion: { in: %w[light dark auto] }
    validates :notifications_enabled, inclusion: { in: [true, false] }
    validates :language, inclusion: { in: I18n.available_locales.map(&:to_s) }
  end
end

# app/models/user.rb
class User < ApplicationRecord
  has_one :setting, class_name: "User::Setting", dependent: :destroy

  after_create :create_default_setting

  private

  def create_default_setting
    create_setting(theme: "light", notifications_enabled: true, language: "en")
  end
end
```

**File Organization:**
```
app/
├── controllers/
│   └── users/
│       ├── settings_controller.rb    # module Users; class SettingsController
│       ├── profile_controller.rb     # module Users; class ProfileController
│       └── preferences_controller.rb # module Users; class PreferencesController
├── models/
│   ├── user.rb
│   └── user/
│       ├── setting.rb                # module User; class Setting
│       ├── profile.rb                # module User; class Profile
│       └── preference.rb             # module User; class Preference
└── views/
    └── users/
        ├── settings/
        │   ├── show.html.erb
        │   └── edit.html.erb
        └── profile/
            ├── show.html.erb
            └── edit.html.erb
```

**View Helpers:**
```ruby
# In views
<%= link_to "Settings", users_settings_path %>
<%= link_to "Edit Profile", edit_users_profile_path %>

# Forms
<%= form_with model: @setting, url: users_settings_path, method: :patch do |f| %>
  <%= f.select :theme, %w[light dark auto] %>
  <%= f.check_box :notifications_enabled %>
  <%= f.submit "Save Settings" %>
<% end %>
```

**Good Examples:**
```ruby
# ✅ GOOD - Domain controllers with singular namespace
Users::SettingsController      # app/controllers/users/settings_controller.rb
Users::ProfileController        # app/controllers/users/profile_controller.rb
Accounts::BillingController     # app/controllers/accounts/billing_controller.rb
Companies::ConfigurationController

# ❌ BAD - Flat naming obscures relationship
UserSettingsController          # Flat, unclear namespace
UsersSettingsController         # Wrong plural on parent
SettingsController              # Too generic, namespace missing
```

**Comparison with Child Controllers:**
```ruby
# Domain Controller (SINGULAR parent) - manages aspect of parent
# User has_one Setting
Users::SettingsController       # Manages THE user's settings
route: /users/settings          # Singular path
model: User::Setting            # Singular namespace

# Child Controller (PLURAL parent) - manages collection
# User has_many Posts
Users::PostsController          # Manages user's posts collection
route: /users/:user_id/posts    # Plural path with parent ID
model: Users::Post              # Plural namespace
```
</pattern>

<pattern name="nested-child-models">
<description>Child models with module namespacing and proper associations</description>

**Child Model:**
```ruby
# app/models/feedbacks/response.rb
module Feedbacks
  class Response < ApplicationRecord
    # Table name: feedbacks_responses (automatically inferred)
    # Foreign key: feedback_id (singular parent name)

    belongs_to :feedback

    validates :content, presence: true, length: { minimum: 10 }
    validates :author_name, presence: true

    scope :recent, -> { order(created_at: :desc) }
    scope :by_author, ->(name) { where(author_name: name) }

    def summary
      content.truncate(100)
    end
  end
end
```

**Another Child Model:**
```ruby
# app/models/feedbacks/attachment.rb
module Feedbacks
  class Attachment < ApplicationRecord
    # Table name: feedbacks_attachments
    # Foreign key: feedback_id

    belongs_to :feedback

    has_one_attached :file

    validates :file, presence: true
    validates :filename, presence: true

    def image?
      file.content_type.start_with?("image/")
    end

    def pdf?
      file.content_type == "application/pdf"
    end
  end
end
```

**Parent Model:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  # Associations to namespaced child models
  has_many :responses, class_name: "Feedbacks::Response", dependent: :destroy
  has_many :attachments, class_name: "Feedbacks::Attachment", dependent: :destroy

  validates :content, presence: true
  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # State management methods for child controllers
  def ready_to_send?
    ai_processed? && improved_content.present?
  end

  def can_retry_ai?
    ai_failed? || ai_processing_timeout?
  end

  def start_sending!
    update!(status: :sending, sending_started_at: Time.current)
  end
end
```

**Migrations:**
```ruby
# db/migrate/20251030000001_create_feedbacks_responses.rb
class CreateFeedbacksResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks_responses do |t|
      t.references :feedback, null: false, foreign_key: true
      t.text :content, null: false
      t.string :author_name, null: false

      t.timestamps
    end

    add_index :feedbacks_responses, [:feedback_id, :created_at]
  end
end

# db/migrate/20251030000002_create_feedbacks_attachments.rb
class CreateFeedbacksAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks_attachments do |t|
      t.references :feedback, null: false, foreign_key: true
      t.string :filename, null: false
      t.string :content_type
      t.integer :file_size

      t.timestamps
    end
  end
end
```
</pattern>

<pattern name="shallow-nesting">
<description>Shallow nesting for resources that need parent context only on creation</description>

**When to Use Shallow:**
- Child resources that need parent context only for `index` and `create`
- `show`, `edit`, `update`, `destroy` actions where child ID is sufficient
- Keeps URLs shorter and more RESTful

**Routes:**
```ruby
# config/routes.rb
resources :projects do
  resources :tasks, shallow: true, module: :projects
end

# Generates:
# GET    /projects/:project_id/tasks          projects/tasks#index
# POST   /projects/:project_id/tasks          projects/tasks#create
# GET    /tasks/:id                           projects/tasks#show
# GET    /tasks/:id/edit                      projects/tasks#edit
# PATCH  /tasks/:id                           projects/tasks#update
# DELETE /tasks/:id                           projects/tasks#destroy
```

**Controller:**
```ruby
# app/controllers/projects/tasks_controller.rb
module Projects
  class TasksController < ApplicationController
    before_action :set_project, only: [:index, :create]
    before_action :set_task, only: [:show, :edit, :update, :destroy]

    # GET /projects/:project_id/tasks
    def index
      @tasks = @project.tasks.includes(:assignee)
    end

    # POST /projects/:project_id/tasks
    def create
      @task = @project.tasks.build(task_params)

      if @task.save
        redirect_to @task, notice: "Task created."
      else
        render :index, status: :unprocessable_entity
      end
    end

    # GET /tasks/:id
    def show
      # @task set by before_action
    end

    # PATCH /tasks/:id
    def update
      if @task.update(task_params)
        redirect_to @task, notice: "Task updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /tasks/:id
    def destroy
      project = @task.project  # Save for redirect
      @task.destroy
      redirect_to project_tasks_path(project), notice: "Task deleted."
    end

    private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :description, :assignee_id)
    end
  end
end
```
</pattern>

<pattern name="directory-structure">
<description>Complete directory structure for nested resources</description>

**Project Layout:**
```
app/
  controllers/
    feedbacks_controller.rb              # FeedbacksController
    feedbacks/
      sendings_controller.rb             # Feedbacks::SendingsController
      retries_controller.rb              # Feedbacks::RetriesController
      publications_controller.rb         # Feedbacks::PublicationsController
      responses_controller.rb            # Feedbacks::ResponsesController
      attachments_controller.rb          # Feedbacks::AttachmentsController
  models/
    feedback.rb                          # Feedback
    feedbacks/
      response.rb                        # Feedbacks::Response
      attachment.rb                      # Feedbacks::Attachment
  views/
    feedbacks/
      index.html.erb
      show.html.erb
      new.html.erb
      edit.html.erb
      responses/
        index.html.erb
      attachments/
        index.html.erb

test/
  controllers/
    feedbacks_controller_test.rb
    feedbacks/
      sendings_controller_test.rb
      responses_controller_test.rb
      attachments_controller_test.rb
  models/
    feedback_test.rb
    feedbacks/
      response_test.rb
      attachment_test.rb
  fixtures/
    feedbacks.yml
    feedbacks/
      responses.yml
      attachments.yml

db/
  migrate/
    20251030000001_create_feedbacks.rb
    20251030000002_create_feedbacks_responses.rb
    20251030000003_create_feedbacks_attachments.rb
```

**Key Points:**
- PLURAL parent directory (feedbacks/, not feedback/)
- Tests mirror code structure
- Fixtures mirror model structure
- Views can be flat or nested (preference)
</pattern>

<antipatterns>
<antipattern>
<description>Using singular parent directory name</description>
<reason>Inconsistent with controller namespacing and Rails conventions</reason>
<bad-example>
```ruby
# ❌ BAD - Singular parent directory
# app/models/feedback/response.rb
module Feedback  # Singular
  class Response < ApplicationRecord
    belongs_to :feedback
  end
end

# app/controllers/feedbacks/responses_controller.rb
module Feedbacks  # Plural
  class ResponsesController < ApplicationController
    # Inconsistent with model namespace!
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Consistent plural parent directory
# app/models/feedbacks/response.rb
module Feedbacks  # Plural
  class Response < ApplicationRecord
    belongs_to :feedback
  end
end

# app/controllers/feedbacks/responses_controller.rb
module Feedbacks  # Plural
  class ResponsesController < ApplicationController
    # Consistent!
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Deep nesting (more than 1 level)</description>
<reason>Creates overly long URLs and complex routing</reason>
<bad-example>
```ruby
# ❌ BAD - Too deeply nested
resources :organizations do
  resources :projects do
    resources :tasks do
      resources :comments
    end
  end
end

# Results in: /organizations/:organization_id/projects/:project_id/tasks/:task_id/comments
# Too long, too complex!
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use shallow nesting
resources :organizations do
  resources :projects, shallow: true
end

resources :projects do
  resources :tasks, shallow: true
end

resources :tasks do
  resources :comments, shallow: true
end

# Or scope child resources without nesting:
resources :organizations
resources :projects
resources :tasks
resources :comments

# Filter in controller/queries instead:
# @project.tasks, @task.comments, etc.
```
</good-example>
</antipattern>

<antipattern>
<description>Using custom controller parameter instead of module</description>
<reason>Doesn't leverage Rails conventions, harder to maintain</reason>
<bad-example>
```ruby
# ❌ BAD - Custom controller parameter
resources :feedbacks do
  resource :sending, only: [:create], controller: "feedback_sendings"
end

# app/controllers/feedback_sendings_controller.rb (flat structure)
class FeedbackSendingsController < ApplicationController
  # ...
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Module parameter with nested directory
resources :feedbacks do
  resource :sending, only: [:create], module: :feedbacks
end

# app/controllers/feedbacks/sendings_controller.rb (nested structure)
module Feedbacks
  class SendingsController < ApplicationController
    # ...
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Forgetting module namespacing in class definition</description>
<reason>Rails won't find the class correctly, causes routing errors</reason>
<bad-example>
```ruby
# ❌ BAD - Missing module wrapper
# app/models/feedbacks/response.rb
class Response < ApplicationRecord  # Missing module Feedbacks
  belongs_to :feedback
end

# Rails looks for Feedbacks::Response but finds ::Response
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Proper module namespacing
# app/models/feedbacks/response.rb
module Feedbacks
  class Response < ApplicationRecord
    belongs_to :feedback
  end
end

# Rails correctly finds Feedbacks::Response
```
</good-example>
</antipattern>

<antipattern>
<description>Mixing flat and nested structures</description>
<reason>Inconsistent codebase, confusing for team members</reason>
<bad-example>
```ruby
# ❌ BAD - Inconsistent structure
# app/controllers/feedback_sendings_controller.rb (flat)
class FeedbackSendingsController < ApplicationController
end

# app/controllers/feedbacks/retries_controller.rb (nested)
module Feedbacks
  class RetriesController < ApplicationController
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Consistent nested structure
# app/controllers/feedbacks/sendings_controller.rb
module Feedbacks
  class SendingsController < ApplicationController
  end
end

# app/controllers/feedbacks/retries_controller.rb
module Feedbacks
  class RetriesController < ApplicationController
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not scoping child resources through parent</description>
<reason>Security issue - users can access any child by guessing IDs</reason>
<bad-example>
```ruby
# ❌ BAD - No parent scoping
def destroy
  @response = Feedbacks::Response.find(params[:id])
  @response.destroy
  # User can delete any response by ID!
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Scope through parent
before_action :set_feedback
before_action :set_response, only: [:destroy]

def destroy
  @response.destroy
  redirect_to feedback_responses_path(@feedback)
end

private

def set_feedback
  @feedback = Feedback.find(params[:feedback_id])
end

def set_response
  # Scoped to parent - can only access responses for this feedback
  @response = @feedback.responses.find(params[:id])
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test nested resources with controller tests that verify parent scoping:

```ruby
# test/controllers/feedbacks/sendings_controller_test.rb
require "test_helper"

module Feedbacks
  class SendingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @feedback = feedbacks(:one)
      @feedback.update!(status: :ai_processed, improved_content: "Improved")
    end

    test "should send feedback when ready" do
      assert_enqueued_with job: SendFeedbackEmailJob do
        post feedback_sending_url(@feedback)
      end

      assert_redirected_to @feedback
      assert_equal "Feedback is being sent", flash[:notice]

      @feedback.reload
      assert @feedback.sending?
    end

    test "should not send when not ready" do
      @feedback.update!(status: :draft)

      post feedback_sending_url(@feedback)

      assert_redirected_to @feedback
      assert_equal "Feedback is not ready to send", flash[:alert]
    end
  end
end

# test/controllers/feedbacks/responses_controller_test.rb
require "test_helper"

module Feedbacks
  class ResponsesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @feedback = feedbacks(:one)
      @response = feedbacks_responses(:one)
    end

    test "should get index scoped to feedback" do
      get feedback_responses_url(@feedback)
      assert_response :success
    end

    test "should create response" do
      assert_difference("Feedbacks::Response.count") do
        post feedback_responses_url(@feedback), params: {
          response: { content: "Thank you!", author_name: "John" }
        }
      end

      assert_redirected_to feedback_responses_url(@feedback)
    end

    test "should destroy only responses belonging to feedback" do
      other_feedback = feedbacks(:two)
      other_response = Feedbacks::Response.create!(
        feedback: other_feedback,
        content: "Other response",
        author_name: "Jane"
      )

      # Try to delete other feedback's response - should raise error
      assert_raises(ActiveRecord::RecordNotFound) do
        delete feedback_response_url(@feedback, other_response)
      end
    end

    private

    def feedback_response_url(feedback, response)
      "/feedbacks/#{feedback.id}/responses/#{response.id}"
    end
  end
end

# test/models/feedbacks/response_test.rb
require "test_helper"

module Feedbacks
  class ResponseTest < ActiveSupport::TestCase
    test "belongs to feedback" do
      response = feedbacks_responses(:one)
      assert_instance_of Feedback, response.feedback
    end

    test "requires content" do
      response = Feedbacks::Response.new(author_name: "John")
      assert_not response.valid?
      assert_includes response.errors[:content], "can't be blank"
    end

    test "recent scope orders by created_at desc" do
      responses = Feedbacks::Response.recent.to_a
      assert_equal responses, responses.sort_by(&:created_at).reverse
    end
  end
end
```

**Fixtures:**
```yaml
# test/fixtures/feedbacks/responses.yml
one:
  feedback: one
  content: "This is a response to the feedback"
  author_name: "John Doe"
  created_at: <%= 1.day.ago %>

two:
  feedback: one
  content: "Another response"
  author_name: "Jane Smith"
  created_at: <%= 2.days.ago %>
```
</testing>

<related-skills>
- controller-restful - Base RESTful controller patterns
- activerecord-patterns - Association and validation patterns
- hotwire-turbo - Turbo frame/stream responses for nested resources
- strong-parameters - Secure parameter filtering
</related-skills>

<resources>
- [Rails Routing Guide - Nested Resources](https://guides.rubyonrails.org/routing.html#nested-resources)
- [Rails Guides - Controllers](https://guides.rubyonrails.org/action_controller_overview.html)
- [Rails Guides - Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
</resources>
