# Example: RESTful Controller with Standard Actions
# Reference: backend/controller_restful

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

# Key Patterns Demonstrated:
# 1. 7 standard RESTful actions only
# 2. Strong parameters
# 3. Rate limiting (Rails 8.1)
# 4. Proper HTTP status codes
# 5. before_action for DRY code
# 6. Eager loading with includes (no N+1)
# 7. Turbo-compatible redirects and renders
