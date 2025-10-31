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
resources :feedbacks do
  resource :sending, only: [:create], module: :feedbacks     # Singular for single action
  resources :responses, only: [:index, :create, :destroy], module: :feedbacks  # Plural for CRUD
end

# Generates:
# POST   /feedbacks/:feedback_id/sending           feedbacks/sendings#create
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

    def index
      @responses = @feedback.responses.order(created_at: :desc)
    end

    def create
      @response = @feedback.responses.build(response_params)
      if @response.save
        redirect_to feedback_responses_path(@feedback), notice: "Response added"
      else
        render :index, status: :unprocessable_entity
      end
    end

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
</pattern>

<pattern name="domain-specific-controllers">
<description>Controllers for managing singular aspects of a parent entity using singular namespace</description>

**When to Use:**
- Managing settings/profiles/preferences (has_one relationship)
- Controller manages an aspect of the parent, not a separate collection

**Routes:**
```ruby
# config/routes.rb
namespace :users do
  resource :settings, only: [:show, :edit, :update]
  resource :profile, only: [:show, :edit, :update]
end

# Generates:
# GET    /users/settings           users/settings#show
# GET    /users/settings/edit      users/settings#edit
# PATCH  /users/settings           users/settings#update
```

**Domain Controller:**
```ruby
# app/controllers/users/settings_controller.rb
module Users
  class SettingsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_setting

    def show; end
    def edit; end

    def update
      if @setting.update(setting_params)
        redirect_to users_settings_path, notice: "Settings updated"
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
  end
end

# app/models/user.rb
class User < ApplicationRecord
  has_one :setting, class_name: "User::Setting", dependent: :destroy
end
```

**Comparison:**
```ruby
# Domain Controller (SINGULAR) - has_one relationship
Users::SettingsController       # Manages user's settings
route: /users/settings          # No parent ID needed

# Child Controller (PLURAL) - has_many relationship
Users::PostsController          # Manages user's posts collection
route: /users/:user_id/posts    # Parent ID required
```
</pattern>

<pattern name="nested-child-models">
<description>Child models with module namespacing and proper associations</description>

**Child Model:**
```ruby
# app/models/feedbacks/response.rb
module Feedbacks
  class Response < ApplicationRecord
    # Table: feedbacks_responses, Foreign key: feedback_id
    belongs_to :feedback
    validates :content, presence: true, length: { minimum: 10 }
    scope :recent, -> { order(created_at: :desc) }
  end
end
```

**Parent Model:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  has_many :responses, class_name: "Feedbacks::Response", dependent: :destroy
  validates :content, presence: true

  def ready_to_send?
    ai_processed? && improved_content.present?
  end
end
```

**Migration:**
```ruby
# db/migrate/20251030000001_create_feedbacks_responses.rb
class CreateFeedbacksResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks_responses do |t|
      t.references :feedback, null: false, foreign_key: true
      t.text :content, null: false
      t.timestamps
    end
  end
end
```
</pattern>

<pattern name="shallow-nesting">
<description>Shallow nesting for resources that need parent context only on creation</description>

**When to Use:**
- Parent context needed only for `index` and `create`
- Other actions (show/edit/update/destroy) work with child ID alone

**Routes:**
```ruby
resources :projects do
  resources :tasks, shallow: true, module: :projects
end

# Generates:
# GET    /projects/:project_id/tasks    projects/tasks#index
# POST   /projects/:project_id/tasks    projects/tasks#create
# GET    /tasks/:id                     projects/tasks#show
# PATCH  /tasks/:id                     projects/tasks#update
# DELETE /tasks/:id                     projects/tasks#destroy
```

**Controller:**
```ruby
# app/controllers/projects/tasks_controller.rb
module Projects
  class TasksController < ApplicationController
    before_action :set_project, only: [:index, :create]
    before_action :set_task, only: [:show, :update, :destroy]

    def index
      @tasks = @project.tasks.includes(:assignee)
    end

    def create
      @task = @project.tasks.build(task_params)
      if @task.save
        redirect_to @task, notice: "Task created"
      else
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      project = @task.project
      @task.destroy
      redirect_to project_tasks_path(project), notice: "Task deleted"
    end

    private
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :description)
    end
  end
end
```
</pattern>

<pattern name="directory-structure">
<description>Complete directory structure for nested resources</description>

```
app/
  controllers/
    feedbacks_controller.rb              # FeedbacksController
    feedbacks/
      sendings_controller.rb             # Feedbacks::SendingsController
      responses_controller.rb            # Feedbacks::ResponsesController
  models/
    feedback.rb                          # Feedback
    feedbacks/
      response.rb                        # Feedbacks::Response
  views/
    feedbacks/
      show.html.erb
      responses/
        index.html.erb

test/
  controllers/feedbacks/
    responses_controller_test.rb
  models/feedbacks/
    response_test.rb
  fixtures/feedbacks/
    responses.yml
```

**Key Points:**
- PLURAL parent directory (feedbacks/, not feedback/)
- Tests and fixtures mirror code structure
</pattern>

<antipatterns>
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
# Results in: /organizations/:org_id/projects/:proj_id/tasks/:task_id/comments
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use shallow nesting
resources :projects do
  resources :tasks, shallow: true
end

resources :tasks do
  resources :comments, shallow: true
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
class Response < ApplicationRecord
  belongs_to :feedback
end
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
  @response.destroy  # User can delete any response!
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Scope through parent
before_action :set_feedback
before_action :set_response, only: [:destroy]

def set_response
  @response = @feedback.responses.find(params[:id])  # Scoped to parent
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test nested resources with controller tests that verify parent scoping:

```ruby
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

    test "should only destroy responses belonging to feedback" do
      other_response = Feedbacks::Response.create!(feedback: feedbacks(:two), content: "Other", author_name: "Jane")
      assert_raises(ActiveRecord::RecordNotFound) do
        delete "/feedbacks/#{@feedback.id}/responses/#{other_response.id}"
      end
    end
  end
end

# test/models/feedbacks/response_test.rb
require "test_helper"

module Feedbacks
  class ResponseTest < ActiveSupport::TestCase
    test "belongs to feedback" do
      assert_instance_of Feedback, feedbacks_responses(:one).feedback
    end

    test "validates content presence" do
      response = Feedbacks::Response.new(author_name: "John")
      assert_not response.valid?
    end
  end
end
```

**Fixtures:**
```yaml
# test/fixtures/feedbacks/responses.yml
one:
  feedback: one
  content: "Response content"
  author_name: "John Doe"
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
