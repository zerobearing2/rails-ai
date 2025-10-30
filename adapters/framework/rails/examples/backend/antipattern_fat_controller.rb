# Anti-Pattern Example: Fat Controller with Business Logic
# Reference: backend/antipattern_fat_controller
# ❌ DON'T DO THIS

class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)

    # ❌ BAD: Business logic in controller
    @feedback.status = :pending
    @feedback.submitted_at = Time.current

    # ❌ BAD: Complex validation in controller
    if @feedback.content.blank? || @feedback.content.length < 50
      @feedback.errors.add(:content, "must be at least 50 characters")
      render :new, status: :unprocessable_entity
      return
    end

    # ❌ BAD: External service calls in controller
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

    # ❌ BAD: Multiple model operations in controller
    if @feedback.save
      # ❌ BAD: Manual notification logic in controller
      FeedbackMailer.notify_recipient(@feedback).deliver_later

      # ❌ BAD: Tracking logic in controller
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

# Why This is Bad:
# 1. Business logic should be in models
# 2. Validations belong in model, not controller
# 3. External service calls should be in service objects
# 4. Multiple model operations should be in service object or model
# 5. Notification logic should be callback or service
# 6. Makes controller hard to test
# 7. Violates Single Responsibility Principle

# ✅ CORRECT APPROACH:
#
# 1. Move validations to Feedback model
# 2. Extract AI processing to AiProcessingService
# 3. Use after_create callback for notifications
# 4. Extract tracking to TrackingService
# 5. Controller only handles HTTP concerns:
#
# def create
#   @feedback = Feedback.new(feedback_params)
#
#   if @feedback.save
#     redirect_to @feedback, notice: "Feedback created!"
#   else
#     render :new, status: :unprocessable_entity
#   end
# end
#
# See: backend/controller_restful.rb for correct pattern
# See: backend/service_multi_model.rb for service object pattern
