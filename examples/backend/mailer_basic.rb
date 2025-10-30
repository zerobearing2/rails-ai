# ActionMailer Best Practices
# Reference: Rails Guides - Action Mailer
# Category: MAILERS

# ============================================================================
# What Are ActionMailers?
# ============================================================================

# ActionMailer allows you to send emails from your Rails application using
# mailer classes and views. Emails are sent via background jobs (SolidQueue).

# Key concepts:
# ✅ Mailer classes inherit from ApplicationMailer
# ✅ Use views for email templates (HTML + text)
# ✅ Deliver emails immediately (.deliver_now) or later (.deliver_later)
# ✅ Test emails with ActionMailer::TestCase

# ============================================================================
# ✅ RECOMMENDED: Basic Mailer
# ============================================================================

# app/mailers/feedback_mailer.rb
class FeedbackMailer < ApplicationMailer
  # Default 'from' address for all emails
  default from: "noreply@example.com"

  # Send notification to recipient when feedback is submitted
  def notify_recipient(feedback)
    @feedback = feedback
    @view_url = feedback_url(feedback.token)

    mail(
      to: @feedback.recipient_email,
      subject: "You've received anonymous feedback"
    )
  end

  # Send notification to sender when recipient responds
  def notify_sender_of_response(feedback)
    @feedback = feedback
    @view_url = sender_feedback_url(feedback.sender_token)

    mail(
      to: @feedback.sender_email,
      subject: "Response to your feedback"
    )
  end

  # Weekly digest of feedback for recipients
  def weekly_digest(user, feedbacks)
    @user = user
    @feedbacks = feedbacks
    @total_count = feedbacks.size

    mail(
      to: user.email,
      subject: "Your weekly feedback digest"
    )
  end
end

# View templates:
# app/views/feedback_mailer/notify_recipient.html.erb
# app/views/feedback_mailer/notify_recipient.text.erb
# app/views/feedback_mailer/notify_sender_of_response.html.erb
# app/views/feedback_mailer/notify_sender_of_response.text.erb

# ============================================================================
# Email Views
# ============================================================================

# app/views/feedback_mailer/notify_recipient.html.erb
<h1>You've Received Anonymous Feedback</h1>

<p>Someone has sent you feedback:</p>

<blockquote>
  <%= simple_format(@feedback.content) %>
</blockquote>

<p>
  <%= link_to "View and Respond to Feedback", @view_url, class: "button" %>
</p>

<p>
  <small>
    This feedback was submitted <%= time_ago_in_words(@feedback.created_at) %> ago.
  </small>
</p>

# app/views/feedback_mailer/notify_recipient.text.erb
You've Received Anonymous Feedback
===================================

Someone has sent you feedback:

<%= @feedback.content %>

View and respond to feedback:
<%= @view_url %>

This feedback was submitted <%= time_ago_in_words(@feedback.created_at) %> ago.

# ============================================================================
# ✅ EXAMPLE: Mailer with Attachments
# ============================================================================

# app/mailers/report_mailer.rb
class ReportMailer < ApplicationMailer
  def monthly_report(user, report_data)
    @user = user
    @report_data = report_data

    # Attach PDF report
    attachments["monthly_report.pdf"] = {
      mime_type: "application/pdf",
      content: generate_pdf_report(report_data)
    }

    # Attach CSV export
    attachments["feedback_export.csv"] = {
      mime_type: "text/csv",
      content: generate_csv_export(report_data)
    }

    mail(
      to: user.email,
      subject: "Your Monthly Feedback Report"
    )
  end

  private

  def generate_pdf_report(data)
    # Generate PDF using a gem like Prawn or WickedPDF
    # PdfGenerator.new(data).generate
  end

  def generate_csv_export(data)
    CSV.generate do |csv|
      csv << ["Date", "Feedback", "Status"]
      data.each do |feedback|
        csv << [feedback.created_at, feedback.content, feedback.status]
      end
    end
  end
end

# ============================================================================
# ✅ EXAMPLE: Mailer with Options
# ============================================================================

# app/mailers/notification_mailer.rb
class NotificationMailer < ApplicationMailer
  def custom_notification(user, options = {})
    @user = user
    @title = options[:title] || "Notification"
    @message = options[:message]
    @action_url = options[:action_url]
    @action_text = options[:action_text] || "View Details"

    mail(
      to: user.email,
      subject: @title,
      reply_to: options[:reply_to],
      cc: options[:cc],
      bcc: options[:bcc],
      priority: options[:priority] || "normal"
    )
  end
end

# Usage
NotificationMailer.custom_notification(
  user,
  title: "Important Update",
  message: "Your feedback has been reviewed",
  action_url: feedback_url(feedback),
  action_text: "View Feedback",
  reply_to: "support@example.com",
  priority: "high"
).deliver_later

# ============================================================================
# ✅ EXAMPLE: Mailer with Previews
# ============================================================================

# test/mailers/previews/feedback_mailer_preview.rb
class FeedbackMailerPreview < ActionMailer::Preview
  # Preview at http://localhost:3000/rails/mailers/feedback_mailer/notify_recipient
  def notify_recipient
    feedback = Feedback.first || Feedback.new(
      content: "This is sample feedback content for preview",
      recipient_email: "recipient@example.com",
      token: "preview-token"
    )

    FeedbackMailer.notify_recipient(feedback)
  end

  # Preview with different content
  def notify_recipient_long_content
    feedback = Feedback.new(
      content: "This is a much longer feedback message that demonstrates " \
               "how the email will look with extended content. " * 10,
      recipient_email: "recipient@example.com",
      token: "preview-token"
    )

    FeedbackMailer.notify_recipient(feedback)
  end

  def weekly_digest
    user = User.first || User.new(email: "user@example.com", name: "Test User")
    feedbacks = Feedback.limit(5)

    FeedbackMailer.weekly_digest(user, feedbacks)
  end
end

# ============================================================================
# ✅ EXAMPLE: Mailer with Layouts
# ============================================================================

# app/views/layouts/mailer.html.erb
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <style>
      body {
        font-family: Arial, sans-serif;
        line-height: 1.6;
        color: #333;
        max-width: 600px;
        margin: 0 auto;
        padding: 20px;
      }

      .header {
        background-color: #4F46E5;
        color: white;
        padding: 20px;
        text-align: center;
      }

      .content {
        padding: 30px;
        background-color: #f9fafb;
      }

      .button {
        display: inline-block;
        padding: 12px 24px;
        background-color: #4F46E5;
        color: white !important;
        text-decoration: none;
        border-radius: 6px;
        margin: 20px 0;
      }

      .footer {
        text-align: center;
        padding: 20px;
        color: #6b7280;
        font-size: 12px;
      }
    </style>
  </head>
  <body>
    <div class="header">
      <h1>The Feedback Agent</h1>
    </div>

    <div class="content">
      <%= yield %>
    </div>

    <div class="footer">
      <p>© 2025 The Feedback Agent. All rights reserved.</p>
      <p>
        <a href="<%= unsubscribe_url %>">Unsubscribe</a> |
        <a href="<%= privacy_url %>">Privacy Policy</a>
      </p>
    </div>
  </body>
</html>

# app/views/layouts/mailer.text.erb
===============================================
THE FEEDBACK AGENT
===============================================

<%= yield %>

---
© 2025 The Feedback Agent. All rights reserved.
Unsubscribe: <%= unsubscribe_url %>

# ============================================================================
# ✅ EXAMPLE: Mailer with Parameterized Actions
# ============================================================================

# app/mailers/feedback_mailer.rb
class FeedbackMailer < ApplicationMailer
  # Use `with` to pass parameters
  def notification
    @feedback = params[:feedback]
    @recipient = params[:recipient]
    @custom_message = params[:custom_message]

    mail(
      to: @recipient.email,
      subject: "New Feedback Notification"
    )
  end
end

# Usage
FeedbackMailer.with(
  feedback: feedback,
  recipient: user,
  custom_message: "This is important"
).notification.deliver_later

# ============================================================================
# ✅ EXAMPLE: Mailer Interceptors
# ============================================================================

# config/initializers/mail_interceptor.rb
class DevelopmentMailInterceptor
  def self.delivering_email(message)
    # Redirect all emails to a single address in development
    message.subject = "[#{message.to}] #{message.subject}"
    message.to = "dev@example.com"
  end
end

if Rails.env.development?
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)
end

# ============================================================================
# ✅ EXAMPLE: Mailer Observers
# ============================================================================

# app/mailers/mail_observer.rb
class MailObserver
  def self.delivered_email(message)
    # Log email delivery
    Rails.logger.info("Email sent: #{message.subject} to #{message.to}")

    # Track email metrics
    EmailMetric.create!(
      to: message.to.first,
      subject: message.subject,
      delivered_at: Time.current
    )
  end
end

# config/initializers/mail_observer.rb
ActionMailer::Base.register_observer(MailObserver)

# ============================================================================
# ✅ TESTING MAILERS
# ============================================================================

# test/mailers/feedback_mailer_test.rb
require "test_helper"

class FeedbackMailerTest < ActionMailer::TestCase
  setup do
    @feedback = feedbacks(:one)
  end

  test "notify_recipient sends email with correct attributes" do
    email = FeedbackMailer.notify_recipient(@feedback)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@feedback.recipient_email], email.to
    assert_equal ["noreply@example.com"], email.from
    assert_equal "You've received anonymous feedback", email.subject
  end

  test "email contains feedback content" do
    email = FeedbackMailer.notify_recipient(@feedback)

    assert_includes email.html_part.body.to_s, @feedback.content
    assert_includes email.text_part.body.to_s, @feedback.content
  end

  test "email contains view link" do
    email = FeedbackMailer.notify_recipient(@feedback)
    view_url = feedback_url(@feedback.token)

    assert_includes email.html_part.body.to_s, view_url
    assert_includes email.text_part.body.to_s, view_url
  end

  test "delivers email via background job" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      FeedbackMailer.notify_recipient(@feedback).deliver_later
    end
  end

  test "weekly digest includes all feedbacks" do
    user = users(:one)
    feedbacks = Feedback.limit(3)

    email = FeedbackMailer.weekly_digest(user, feedbacks)

    feedbacks.each do |feedback|
      assert_includes email.html_part.body.to_s, feedback.content
    end
  end
end

# ============================================================================
# Configuration
# ============================================================================

# config/environments/development.rb
Rails.application.configure do
  # Use letter_opener to preview emails in browser
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true

  # Set URL options for email links
  config.action_mailer.default_url_options = {
    host: "localhost",
    port: 3000
  }
end

# config/environments/production.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_caching = false

  config.action_mailer.smtp_settings = {
    address: "smtp.sendgrid.net",
    port: 587,
    domain: Rails.application.credentials.dig(:smtp, :domain),
    user_name: Rails.application.credentials.dig(:smtp, :username),
    password: Rails.application.credentials.dig(:smtp, :password),
    authentication: :plain,
    enable_starttls_auto: true
  }

  config.action_mailer.default_url_options = {
    host: "example.com",
    protocol: "https"
  }
end

# ============================================================================
# RULE: Always provide both HTML and text email templates
# DELIVER: Use deliver_later for background job processing (SolidQueue)
# TEST: Write tests for email delivery and content
# PREVIEW: Create previews for visual development
# LAYOUT: Use consistent email layouts across all mailers
# URLs: Always use *_url helpers (not *_path) in emails
# ============================================================================
