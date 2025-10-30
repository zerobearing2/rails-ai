---
name: controller-restful
domain: backend
dependencies: []
version: 1.0
rails_version: 8.1+

# Team rules enforcement
enforces_team_rule:
  - rule_id: 3
    rule_name: "RESTful Routes Only"
    severity: critical
    enforcement_action: REJECT
---

# RESTful Controllers

Rails controllers following REST conventions with standard CRUD actions, strong parameters, and proper HTTP semantics.

<when-to-use>
- Building standard CRUD interfaces for resources
- Following Rails conventions for resource management
- Need predictable, RESTful URL structure
- Creating APIs that follow REST principles
- Standard create, read, update, delete operations
</when-to-use>

<benefits>
- **Convention Over Configuration** - Predictable URL patterns
- **REST Compliance** - Standard HTTP verbs and status codes
- **Route Helpers** - Automatic `resource_path` methods
- **Scaffolding** - Rails generators understand REST
- **API Compatibility** - Easy to build RESTful APIs
</benefits>

<standards>
- Use only 7 standard actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`
- NO custom actions - use nested resources or services instead
- Always use strong parameters with `require` and `permit`
- Return proper HTTP status codes (200, 201, 422, 404, etc.)
- Use `before_action` for common setup (finding records)
- Eager load associations to prevent N+1 queries
- Use `redirect_to` for successful mutations
- Use `render` with `status:` for failures
- Rate limit sensitive actions (Rails 8.1+)
</standards>

## Patterns

<pattern name="standard-restful-controller">
<description>Complete RESTful controller with all 7 standard actions</description>

**Controller:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]

  # Rate limiting (Rails 8.1)
  rate_limit to: 10, within: 1.minute, only: [:create, :update]

  # GET /feedbacks
  def index
    @feedbacks = Feedback.includes(:recipient).recent
  end

  # GET /feedbacks/:id
  def show
    # @feedback set by before_action
  end

  # GET /feedbacks/new
  def new
    @feedback = Feedback.new
  end

  # POST /feedbacks
  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      redirect_to @feedback, notice: "Feedback was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /feedbacks/:id/edit
  def edit
    # @feedback set by before_action
  end

  # PATCH/PUT /feedbacks/:id
  def update
    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: "Feedback was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /feedbacks/:id
  def destroy
    @feedback.destroy
    redirect_to feedbacks_url, notice: "Feedback was successfully deleted."
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def feedback_params
    params.require(:feedback).permit(:content, :recipient_email, :sender_name)
  end
end
```

**Routes:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :feedbacks
  # Generates:
  # GET    /feedbacks          => feedbacks#index
  # GET    /feedbacks/new      => feedbacks#new
  # POST   /feedbacks          => feedbacks#create
  # GET    /feedbacks/:id      => feedbacks#show
  # GET    /feedbacks/:id/edit => feedbacks#edit
  # PATCH  /feedbacks/:id      => feedbacks#update
  # DELETE /feedbacks/:id      => feedbacks#destroy
end
```
</pattern>

<pattern name="api-restful-controller">
<description>RESTful API controller with JSON responses</description>

**Controller:**
```ruby
# app/controllers/api/v1/feedbacks_controller.rb
module Api
  module V1
    class FeedbacksController < ApiController
      before_action :set_feedback, only: [:show, :update, :destroy]

      # GET /api/v1/feedbacks
      def index
        @feedbacks = Feedback.includes(:recipient).recent

        render json: @feedbacks
      end

      # GET /api/v1/feedbacks/:id
      def show
        render json: @feedback
      end

      # POST /api/v1/feedbacks
      def create
        @feedback = Feedback.new(feedback_params)

        if @feedback.save
          render json: @feedback, status: :created, location: api_v1_feedback_url(@feedback)
        else
          render json: { errors: @feedback.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/feedbacks/:id
      def update
        if @feedback.update(feedback_params)
          render json: @feedback
        else
          render json: { errors: @feedback.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/feedbacks/:id
      def destroy
        @feedback.destroy
        head :no_content
      end

      private

      def set_feedback
        @feedback = Feedback.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Feedback not found" }, status: :not_found
      end

      def feedback_params
        params.require(:feedback).permit(:content, :recipient_email, :sender_name)
      end
    end
  end
end
```
</pattern>

<pattern name="nested-resources">
<description>RESTful controllers for nested resources</description>

**Routes:**
```ruby
# config/routes.rb
resources :projects do
  resources :tasks, only: [:index, :create, :destroy]
end
# Generates:
# GET    /projects/:project_id/tasks          => tasks#index
# POST   /projects/:project_id/tasks          => tasks#create
# DELETE /projects/:project_id/tasks/:id      => tasks#destroy
```

**Controller:**
```ruby
# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [:destroy]

  # GET /projects/:project_id/tasks
  def index
    @tasks = @project.tasks.includes(:assignee)
  end

  # POST /projects/:project_id/tasks
  def create
    @task = @project.tasks.build(task_params)

    if @task.save
      redirect_to project_tasks_path(@project), notice: "Task created."
    else
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:project_id/tasks/:id
  def destroy
    @task.destroy
    redirect_to project_tasks_path(@project), notice: "Task deleted."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :assignee_id)
  end
end
```
</pattern>

<pattern name="turbo-stream-responses">
<description>RESTful controller with Turbo Stream support</description>

**Controller:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("feedbacks", partial: "feedback", locals: { feedback: @feedback }),
            turbo_stream.replace("feedback_form", partial: "form", locals: { feedback: Feedback.new })
          ]
        end
        format.html { redirect_to feedbacks_path, notice: "Feedback created." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "feedback_form",
            partial: "form",
            locals: { feedback: @feedback }
          )
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@feedback) }
      format.html { redirect_to feedbacks_path, notice: "Feedback deleted." }
    end
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Adding custom actions instead of using nested resources</description>
<reason>Breaks REST conventions and makes routing unpredictable</reason>
<bad-example>
```ruby
# ❌ BAD - Custom actions
class FeedbacksController < ApplicationController
  def archive
    # Custom action
  end

  def mark_as_read
    # Custom action
  end
end

# routes.rb
resources :feedbacks do
  member do
    post :archive
    post :mark_as_read
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use nested resources
class Feedback::ArchivalsController < ApplicationController
  def create
    @feedback = Feedback.find(params[:feedback_id])
    @feedback.archive!
    redirect_to feedbacks_path
  end
end

# routes.rb
resources :feedbacks do
  resource :archival, only: [:create], module: :feedback
  resource :read_status, only: [:create], module: :feedback
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not using strong parameters</description>
<reason>Security vulnerability - mass assignment attacks</reason>
<bad-example>
```ruby
# ❌ BAD - Unsafe mass assignment
def create
  @feedback = Feedback.new(params[:feedback])
  @feedback.save
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Strong parameters
def create
  @feedback = Feedback.new(feedback_params)
  @feedback.save
end

private

def feedback_params
  params.require(:feedback).permit(:content, :recipient_email)
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not returning proper HTTP status codes</description>
<reason>Breaks API contracts and Turbo expectations</reason>
<bad-example>
```ruby
# ❌ BAD - Always returns 200
def create
  @feedback = Feedback.new(feedback_params)
  if @feedback.save
    render :show
  else
    render :new  # Still returns 200 OK!
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Proper status codes
def create
  @feedback = Feedback.new(feedback_params)
  if @feedback.save
    redirect_to @feedback  # 302 redirect
  else
    render :new, status: :unprocessable_entity  # 422
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test RESTful controllers with request or controller tests:

```ruby
# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get feedbacks_url
    assert_response :success
  end

  test "should create feedback" do
    assert_difference("Feedback.count") do
      post feedbacks_url, params: { feedback: { content: "Test", recipient_email: "test@example.com" } }
    end

    assert_redirected_to feedback_url(Feedback.last)
  end

  test "should not create invalid feedback" do
    assert_no_difference("Feedback.count") do
      post feedbacks_url, params: { feedback: { content: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should update feedback" do
    feedback = feedbacks(:one)

    patch feedback_url(feedback), params: { feedback: { content: "Updated" } }

    assert_redirected_to feedback_url(feedback)
    assert_equal "Updated", feedback.reload.content
  end

  test "should destroy feedback" do
    feedback = feedbacks(:one)

    assert_difference("Feedback.count", -1) do
      delete feedback_url(feedback)
    end

    assert_redirected_to feedbacks_url
  end
end
```
</testing>

<related-skills>
- strong-parameters - Secure parameter filtering
- activerecord-queries - Efficient database queries
- hotwire-turbo - Turbo Frame/Stream responses
- rate-limiting - Protect endpoints
</related-skills>

<resources>
- [Rails Guides - Controllers](https://guides.rubyonrails.org/action_controller_overview.html)
- [Rails Routing Guide](https://guides.rubyonrails.org/routing.html)
- [RESTful Web Services](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm)
</resources>
