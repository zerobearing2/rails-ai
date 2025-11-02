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
- Creating APIs that follow REST principles
</when-to-use>

<benefits>
- **Convention Over Configuration** - Predictable URL patterns
- **REST Compliance** - Standard HTTP verbs and status codes
- **Route Helpers** - Automatic `resource_path` methods
- **API Compatibility** - Easy to build RESTful APIs
</benefits>

<standards>
- Use only 7 standard actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`
- NO custom actions - use nested resources or services instead
- Always use strong parameters with `require` and `permit`
- Return proper HTTP status codes (200, 201, 422, 404, etc.)
- Use `before_action` for common setup (finding records)
- Eager load associations to prevent N+1 queries
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
  rate_limit to: 10, within: 1.minute, only: [:create, :update]

  def index
    @feedbacks = Feedback.includes(:recipient).recent
  end

  def show; end  # @feedback set by before_action

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      redirect_to @feedback, notice: "Feedback was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end  # @feedback set by before_action

  def update
    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: "Feedback was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

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
resources :feedbacks
# Generates all 7 RESTful routes: index, show, new, create, edit, update, destroy
```
</pattern>

<pattern name="api-restful-controller">
<description>RESTful API controller with JSON responses</description>

**Controller:**
```ruby
# app/controllers/api/v1/feedbacks_controller.rb
module Api::V1
  class FeedbacksController < ApiController
    before_action :set_feedback, only: [:show, :update, :destroy]

    def index
      render json: Feedback.includes(:recipient).recent
    end

    def show
      render json: @feedback
    end

    def create
      @feedback = Feedback.new(feedback_params)

      if @feedback.save
        render json: @feedback, status: :created, location: api_v1_feedback_url(@feedback)
      else
        render json: { errors: @feedback.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @feedback.update(feedback_params)
        render json: @feedback
      else
        render json: { errors: @feedback.errors }, status: :unprocessable_entity
      end
    end

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
```
</pattern>

<pattern name="nested-resources">
<description>RESTful controllers for nested resources</description>

**Routes:**
```ruby
resources :projects do
  resources :tasks, only: [:index, :create, :destroy]
end
```

**Controller:**
```ruby
class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [:destroy]

  def index
    @tasks = @project.tasks.includes(:assignee)
  end

  def create
    @task = @project.tasks.build(task_params)

    if @task.save
      redirect_to project_tasks_path(@project), notice: "Task created."
    else
      render :index, status: :unprocessable_entity
    end
  end

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
      render :new, status: :unprocessable_entity
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
# ❌ BAD
resources :feedbacks do
  member { post :archive }
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use nested resources
resources :feedbacks do
  resource :archival, only: [:create], module: :feedback
end

class Feedback::ArchivalsController < ApplicationController
  def create
    @feedback = Feedback.find(params[:feedback_id])
    @feedback.archive!
    redirect_to feedbacks_path
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not using strong parameters</description>
<reason>Security vulnerability - mass assignment attacks</reason>
<bad-example>
```ruby
# ❌ BAD - Unsafe
def create
  @feedback = Feedback.new(params[:feedback])
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD
def create
  @feedback = Feedback.new(feedback_params)
end

private
def feedback_params
  params.require(:feedback).permit(:content, :recipient_email)
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test RESTful controllers with request or controller tests:

```ruby
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "should create feedback" do
    assert_difference("Feedback.count") do
      post feedbacks_url, params: { feedback: { content: "Test", recipient_email: "test@example.com" } }
    end
    assert_redirected_to feedback_url(Feedback.last)
  end

  test "should reject invalid feedback" do
    assert_no_difference("Feedback.count") do
      post feedbacks_url, params: { feedback: { content: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should update feedback" do
    feedback = feedbacks(:one)
    patch feedback_url(feedback), params: { feedback: { content: "Updated" } }
    assert_equal "Updated", feedback.reload.content
  end

  test "should destroy feedback" do
    assert_difference("Feedback.count", -1) do
      delete feedback_url(feedbacks(:one))
    end
  end
end
```
</testing>

<related-skills>
- strong-parameters - Secure parameter filtering
- activerecord-patterns - Efficient ActiveRecord patterns
- hotwire-turbo - Turbo Frame/Stream responses
</related-skills>

<resources>
- [Rails Guides - Controllers](https://guides.rubyonrails.org/action_controller_overview.html)
- [Rails Routing Guide](https://guides.rubyonrails.org/routing.html)
</resources>
