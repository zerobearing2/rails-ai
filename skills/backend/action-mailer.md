---
name: action-mailer
domain: backend
dependencies: []
version: 1.0
rails_version: 8.1+
---

# Action Mailer

Send emails from your Rails application using mailer classes and views. Deliver immediately or via background jobs with SolidQueue.

<when-to-use>
- Sending transactional emails (welcome, password reset, confirmation)
- Sending notification emails (new feedback, responses, alerts)
- Sending digest emails (weekly summaries, reports)
- Delivering reports or exports via email with attachments
- Any asynchronous email communication from your application
- ALWAYS deliver emails via background jobs (.deliver_later) in production
</when-to-use>

<benefits>
- **Testable** - Full test suite with ActionMailer::TestCase
- **Previewable** - Preview emails in development without sending
- **Template Support** - Use ERB templates (HTML + text versions)
- **Layout Support** - Shared layouts for consistent branding
- **Background Jobs** - Automatic integration with SolidQueue
- **Parameterized** - Pass parameters cleanly using .with()
- **Interceptors/Observers** - Hook into delivery for logging or redirection
- **Attachments** - Easily attach files (PDFs, CSVs, images)
</benefits>

<standards>
- Mailer classes inherit from ApplicationMailer
- Place mailers in app/mailers/ directory
- ALWAYS provide both HTML and text email templates
- Use *_url helpers (NOT *_path) for links in emails
- Deliver emails asynchronously with deliver_later (not deliver_now)
- Set default 'from' address in ApplicationMailer
- Test emails with ActionMailer::TestCase
- Create previews for visual development
- Use consistent layouts across all mailers
- Set proper SMTP configuration per environment
</standards>

## Basic Mailer

<pattern name="basic-mailer">
<description>Simple mailer class with email action methods</description>

**Mailer Class:**
```ruby
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
```

**HTML View:**
```erb
<%# app/views/feedback_mailer/notify_recipient.html.erb %>
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
```

**Text View:**
```erb
<%# app/views/feedback_mailer/notify_recipient.text.erb %>
You've Received Anonymous Feedback
===================================

Someone has sent you feedback:

<%= @feedback.content %>

View and respond to feedback:
<%= @view_url %>

This feedback was submitted <%= time_ago_in_words(@feedback.created_at) %> ago.
```

**Usage:**
```ruby
# Controller or model
FeedbackMailer.notify_recipient(feedback).deliver_later
```
</pattern>

## Mailer with Attachments

<pattern name="attachments">
<description>Attach files to emails (PDFs, CSVs, images, etc.)</description>

**Mailer with Attachments:**
```ruby
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

    # Attach inline image (for use in email body)
    attachments.inline["logo.png"] = File.read(
      Rails.root.join("app/assets/images/logo.png")
    )

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
```

**Using Inline Images:**
```erb
<%# app/views/report_mailer/monthly_report.html.erb %>
<%= image_tag attachments["logo.png"].url, alt: "Company Logo" %>

<h1>Your Monthly Report</h1>
<p>See attached files for details.</p>
```
</pattern>

## Parameterized Mailers

<pattern name="parameterized">
<description>Use .with() to pass parameters cleanly</description>

**Parameterized Mailer:**
```ruby
# app/mailers/feedback_mailer.rb
class FeedbackMailer < ApplicationMailer
  # Use `params` to access parameters passed via .with()
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
```

**Usage:**
```ruby
# Clean, named parameters
FeedbackMailer.with(
  feedback: feedback,
  recipient: user,
  custom_message: "This is important"
).notification.deliver_later

# Instead of positional arguments:
# FeedbackMailer.notification(feedback, user, "This is important").deliver_later
```

**Benefits:**
- More readable and self-documenting
- Easier to add/remove parameters
- Parameters are accessible via `params` hash
- Works seamlessly with background jobs
</pattern>

## Advanced Options

<pattern name="advanced-options">
<description>Customize email headers, priority, reply-to, cc, bcc</description>

**Mailer with Options:**
```ruby
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
```

**Usage:**
```ruby
NotificationMailer.custom_notification(
  user,
  title: "Important Update",
  message: "Your feedback has been reviewed",
  action_url: feedback_url(feedback),
  action_text: "View Feedback",
  reply_to: "support@example.com",
  cc: "manager@example.com",
  bcc: "archive@example.com",
  priority: "high"
).deliver_later
```

**Priority Levels:**
- `high` - X-Priority: 1
- `normal` - X-Priority: 3 (default)
- `low` - X-Priority: 5
</pattern>

## Email Layouts

<pattern name="layouts">
<description>Shared layouts for consistent email styling</description>

**HTML Layout:**
```erb
<%# app/views/layouts/mailer.html.erb %>
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
      <p>&copy; 2025 The Feedback Agent. All rights reserved.</p>
      <p>
        <a href="<%= unsubscribe_url %>">Unsubscribe</a> |
        <a href="<%= privacy_url %>">Privacy Policy</a>
      </p>
    </div>
  </body>
</html>
```

**Text Layout:**
```erb
<%# app/views/layouts/mailer.text.erb %>
===============================================
THE FEEDBACK AGENT
===============================================

<%= yield %>

---
&copy; 2025 The Feedback Agent. All rights reserved.
Unsubscribe: <%= unsubscribe_url %>
```

**Custom Layout per Mailer:**
```ruby
class FeedbackMailer < ApplicationMailer
  layout "feedback_mailer"  # Uses app/views/layouts/feedback_mailer.html.erb
end
```
</pattern>

## Mailer Previews

<pattern name="previews">
<description>Preview emails in browser during development</description>

**Preview Class:**
```ruby
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

  # Preview with different scenarios
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

  # Preview with parameterized mailer
  def notification
    FeedbackMailer.with(
      feedback: Feedback.first,
      recipient: User.first,
      custom_message: "Preview message"
    ).notification
  end
end
```

**Accessing Previews:**
- Visit http://localhost:3000/rails/mailers
- Select mailer and preview method
- View HTML and text versions
- Test links and styling
- No emails are actually sent
</pattern>

## Interceptors

<pattern name="interceptors">
<description>Intercept emails before delivery (modify or redirect)</description>

**Development Interceptor:**
```ruby
# lib/development_mail_interceptor.rb
class DevelopmentMailInterceptor
  def self.delivering_email(message)
    # Redirect all emails to a single address in development
    original_to = message.to.join(", ")
    message.subject = "[TO: #{original_to}] #{message.subject}"
    message.to = "dev@example.com"
  end
end
```

**Registration:**
```ruby
# config/initializers/mail_interceptor.rb
if Rails.env.development?
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)
end
```

**Use Cases:**
- Redirect all emails in development/staging
- Add prefixes to subjects
- Filter sensitive content
- Block emails to certain domains
- Add custom headers
</pattern>

## Observers

<pattern name="observers">
<description>Observe email delivery for logging or tracking</description>

**Email Observer:**
```ruby
# app/mailers/mail_observer.rb
class MailObserver
  def self.delivered_email(message)
    # Log email delivery
    Rails.logger.info(
      "Email sent: #{message.subject} to #{message.to.join(', ')}"
    )

    # Track email metrics
    EmailMetric.create!(
      to: message.to.first,
      subject: message.subject,
      delivered_at: Time.current
    )
  end
end
```

**Registration:**
```ruby
# config/initializers/mail_observer.rb
ActionMailer::Base.register_observer(MailObserver)
```

**Use Cases:**
- Log all email deliveries
- Track email metrics
- Trigger webhooks on delivery
- Update database records
- Monitor email volume
</pattern>

## Configuration

<pattern name="configuration">
<description>Environment-specific email configuration</description>

**Development Configuration:**
```ruby
# config/environments/development.rb
Rails.application.configure do
  # Use letter_opener to preview emails in browser
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  # Set URL options for email links
  config.action_mailer.default_url_options = {
    host: "localhost",
    port: 3000
  }
end
```

**Production Configuration (SMTP):**
```ruby
# config/environments/production.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_caching = false
  config.action_mailer.raise_delivery_errors = false

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
```

**Production Configuration (SendGrid API):**
```ruby
# config/environments/production.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :sendgrid_actionmailer
  config.action_mailer.sendgrid_actionmailer_settings = {
    api_key: Rails.application.credentials.dig(:sendgrid, :api_key),
    raise_delivery_errors: true
  }
end
```

**Test Configuration:**
```ruby
# config/environments/test.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: "example.com" }
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Using deliver_now in production code</description>
<reason>Blocks request until email is sent, causing slow response times</reason>
<bad-example>
```ruby
# app/controllers/feedbacks_controller.rb
# ❌ BAD - Blocks the HTTP request
def create
  @feedback = Feedback.new(feedback_params)
  if @feedback.save
    FeedbackMailer.notify_recipient(@feedback).deliver_now  # BLOCKS!
    redirect_to @feedback
  end
end
```
</bad-example>
<good-example>
```ruby
# app/controllers/feedbacks_controller.rb
# ✅ GOOD - Delivers via background job
def create
  @feedback = Feedback.new(feedback_params)
  if @feedback.save
    FeedbackMailer.notify_recipient(@feedback).deliver_later  # Async
    redirect_to @feedback
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using *_path helpers instead of *_url helpers</description>
<reason>Paths don't include domain/protocol, resulting in broken links</reason>
<bad-example>
```ruby
# app/mailers/feedback_mailer.rb
# ❌ BAD - Generates relative path without domain
def notify_recipient(feedback)
  @feedback = feedback
  @view_url = feedback_path(feedback.token)  # "/feedbacks/abc123"

  mail(to: feedback.recipient_email, subject: "New Feedback")
end
```
</bad-example>
<good-example>
```ruby
# app/mailers/feedback_mailer.rb
# ✅ GOOD - Generates full URL with domain
def notify_recipient(feedback)
  @feedback = feedback
  @view_url = feedback_url(feedback.token)  # "https://example.com/feedbacks/abc123"

  mail(to: feedback.recipient_email, subject: "New Feedback")
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not providing text email version</description>
<reason>Some email clients don't support HTML or users prefer plain text</reason>
<bad-example>
```ruby
# ❌ BAD - Only HTML version
# app/views/feedback_mailer/notify_recipient.html.erb exists
# app/views/feedback_mailer/notify_recipient.text.erb missing
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Both HTML and text versions
# app/views/feedback_mailer/notify_recipient.html.erb
<h1>You've Received Feedback</h1>
<p><%= @feedback.content %></p>

# app/views/feedback_mailer/notify_recipient.text.erb
You've Received Feedback
========================
<%= @feedback.content %>
```
</good-example>
</antipattern>

<antipattern>
<description>Hardcoding email addresses in mailers</description>
<reason>Makes testing difficult and requires code changes for different environments</reason>
<bad-example>
```ruby
# app/mailers/feedback_mailer.rb
# ❌ BAD - Hardcoded email addresses
class FeedbackMailer < ApplicationMailer
  default from: "noreply@production-domain.com"  # Hardcoded!

  def notification(feedback)
    mail(
      to: feedback.recipient_email,
      cc: "admin@production-domain.com"  # Hardcoded!
    )
  end
end
```
</bad-example>
<good-example>
```ruby
# app/mailers/application_mailer.rb
# ✅ GOOD - Use environment variables or config
class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "noreply@example.com")
  layout "mailer"
end

# app/mailers/feedback_mailer.rb
class FeedbackMailer < ApplicationMailer
  def notification(feedback)
    mail(
      to: feedback.recipient_email,
      cc: Rails.application.config.admin_email
    )
  end
end

# config/environments/production.rb
config.admin_email = "admin@production-domain.com"
```
</good-example>
</antipattern>

<antipattern>
<description>Including large attachments in emails</description>
<reason>Email servers reject large emails, and attachments increase delivery time</reason>
<bad-example>
```ruby
# app/mailers/report_mailer.rb
# ❌ BAD - Attaching large file (50MB video)
def monthly_report(user)
  attachments["large_video.mp4"] = File.read("large_file.mp4")  # 50MB!
  mail(to: user.email)
end
```
</bad-example>
<good-example>
```ruby
# app/mailers/report_mailer.rb
# ✅ GOOD - Provide download link instead
def monthly_report(user, report)
  @user = user
  @download_url = download_report_url(report.token, expires: 7.days.from_now)

  mail(to: user.email, subject: "Your Monthly Report")
end

# View includes download link
# "Your report is ready: <%= link_to 'Download Report', @download_url %>"
```
</good-example>
</antipattern>

<antipattern>
<description>Not testing mailer content</description>
<reason>Email bugs often go unnoticed until customers complain</reason>
<bad-example>
```ruby
# ❌ BAD - Only testing that email is sent, not content
test "sends notification email" do
  assert_emails 1 do
    FeedbackMailer.notify_recipient(@feedback).deliver_now
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Test subject, recipients, and content
test "notify_recipient sends email with correct content" do
  email = FeedbackMailer.notify_recipient(@feedback)

  assert_emails 1 do
    email.deliver_now
  end

  # Test attributes
  assert_equal [@feedback.recipient_email], email.to
  assert_equal ["noreply@example.com"], email.from
  assert_equal "You've received anonymous feedback", email.subject

  # Test content
  assert_includes email.html_part.body.to_s, @feedback.content
  assert_includes email.text_part.body.to_s, @feedback.content
  assert_includes email.html_part.body.to_s, feedback_url(@feedback.token)
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test mailers using ActionMailer::TestCase:

```ruby
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

  test "email contains feedback content in both HTML and text" do
    email = FeedbackMailer.notify_recipient(@feedback)

    assert_includes email.html_part.body.to_s, @feedback.content
    assert_includes email.text_part.body.to_s, @feedback.content
  end

  test "email contains view link with correct URL" do
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

    assert_includes email.subject, "weekly"
    assert_equal [user.email], email.to
  end

  test "parameterized mailer receives correct params" do
    email = FeedbackMailer.with(
      feedback: @feedback,
      recipient: users(:one),
      custom_message: "Test message"
    ).notification

    assert_includes email.body.to_s, "Test message"
  end
end

# test/mailers/report_mailer_test.rb
class ReportMailerTest < ActionMailer::TestCase
  test "monthly report includes attachments" do
    user = users(:one)
    report_data = [feedbacks(:one), feedbacks(:two)]

    email = ReportMailer.monthly_report(user, report_data)

    assert_equal 2, email.attachments.size
    assert_equal "monthly_report.pdf", email.attachments[0].filename
    assert_equal "feedback_export.csv", email.attachments[1].filename
    assert_equal "application/pdf", email.attachments[0].mime_type
    assert_equal "text/csv", email.attachments[1].mime_type
  end
end
```

**System Tests for Email Delivery:**
```ruby
# test/system/feedback_submission_test.rb
class FeedbackSubmissionTest < ApplicationSystemTestCase
  test "submitting feedback sends notification email" do
    visit new_feedback_path

    fill_in "Recipient email", with: "recipient@example.com"
    fill_in "Content", with: "This is test feedback"

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      click_button "Submit Feedback"
    end

    assert_text "Feedback sent successfully"
  end
end
```

**Testing Mailer Previews:**
```ruby
# test/mailers/previews/feedback_mailer_preview_test.rb
require "test_helper"

class FeedbackMailerPreviewTest < ActionMailer::PreviewTestCase
  test "preview notify_recipient renders without errors" do
    preview = FeedbackMailerPreview.new
    email = preview.notify_recipient

    assert_not_nil email
    assert_not_nil email.subject
    assert_not_empty email.to
  end
end
```
</testing>

<related-skills>
- background-jobs - Using SolidQueue for email delivery
- activerecord-callbacks - Triggering emails from model callbacks
- form-objects - Sending emails from form objects
- testing-minitest - Testing strategies for mailers
- security-xss - Preventing XSS in email templates
</related-skills>

<resources>
- [Rails Guides - Action Mailer Basics](https://guides.rubyonrails.org/action_mailer_basics.html)
- [Rails API - ActionMailer::Base](https://api.rubyonrails.org/classes/ActionMailer/Base.html)
- [Rails API - ActionMailer::TestCase](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
- [Email on Rails](https://email-on-rails.com/) - Best practices guide
</resources>
