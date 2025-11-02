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
  default from: "noreply@example.com"

  def notify_recipient(feedback)
    @feedback = feedback
    @view_url = feedback_url(feedback.token)
    mail(to: @feedback.recipient_email, subject: "You've received anonymous feedback")
  end

  def weekly_digest(user, feedbacks)
    @user = user
    @feedbacks = feedbacks
    mail(to: user.email, subject: "Your weekly feedback digest")
  end
end
```

**HTML View:**
```erb
<%# app/views/feedback_mailer/notify_recipient.html.erb %>
<h1>You've Received Anonymous Feedback</h1>
<blockquote><%= simple_format(@feedback.content) %></blockquote>
<%= link_to "View and Respond", @view_url, class: "button" %>
```

**Text View:**
```erb
<%# app/views/feedback_mailer/notify_recipient.text.erb %>
You've Received Anonymous Feedback
===================================
<%= @feedback.content %>

View and respond: <%= @view_url %>
```

**Usage:**
```ruby
FeedbackMailer.notify_recipient(feedback).deliver_later
```
</pattern>

## Mailer with Attachments

<pattern name="attachments">
<description>Attach files to emails (PDFs, CSVs, images, etc.)</description>

```ruby
# app/mailers/report_mailer.rb
class ReportMailer < ApplicationMailer
  def monthly_report(user, report_data)
    @user = user

    # Attach files
    attachments["report.pdf"] = { mime_type: "application/pdf", content: generate_pdf(report_data) }
    attachments["export.csv"] = { mime_type: "text/csv", content: generate_csv(report_data) }

    # Inline image (for email body)
    attachments.inline["logo.png"] = File.read(Rails.root.join("app/assets/images/logo.png"))

    mail(to: user.email, subject: "Monthly Report")
  end

  private

  def generate_csv(data)
    CSV.generate { |csv| data.each { |f| csv << [f.created_at, f.content, f.status] } }
  end
end
```

**Using inline images:**
```erb
<%= image_tag attachments["logo.png"].url, alt: "Logo" %>
```
</pattern>

## Parameterized Mailers

<pattern name="parameterized">
<description>Use .with() to pass parameters cleanly</description>

```ruby
# app/mailers/feedback_mailer.rb
class FeedbackMailer < ApplicationMailer
  def notification
    @feedback = params[:feedback]
    @recipient = params[:recipient]
    mail(to: @recipient.email, subject: "New Feedback Notification")
  end
end

# Usage - clean named parameters
FeedbackMailer.with(feedback: feedback, recipient: user).notification.deliver_later
```

**Benefits:** More readable, easier to modify, works with background jobs
</pattern>

## Advanced Options

<pattern name="advanced-options">
<description>Customize email headers, priority, reply-to, cc, bcc</description>

```ruby
# app/mailers/notification_mailer.rb
class NotificationMailer < ApplicationMailer
  def custom_notification(user, options = {})
    @user = user
    @message = options[:message]

    mail(
      to: user.email,
      subject: options[:title] || "Notification",
      reply_to: options[:reply_to],
      cc: options[:cc],
      bcc: options[:bcc],
      priority: options[:priority] || "normal"  # high/normal/low
    )
  end
end
```
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
      body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
      .header { background-color: #4F46E5; color: white; padding: 20px; text-align: center; }
      .content { padding: 30px; background-color: #f9fafb; }
      .button { display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white !important; text-decoration: none; border-radius: 6px; }
      .footer { text-align: center; padding: 20px; color: #6b7280; font-size: 12px; }
    </style>
  </head>
  <body>
    <div class="header"><h1>Your App</h1></div>
    <div class="content"><%= yield %></div>
    <div class="footer">
      <p>&copy; 2025 Your Company</p>
      <p><a href="<%= unsubscribe_url %>">Unsubscribe</a></p>
    </div>
  </body>
</html>
```

**Text Layout:**
```erb
<%# app/views/layouts/mailer.text.erb %>
<%= yield %>
---
&copy; 2025 Your Company
Unsubscribe: <%= unsubscribe_url %>
```

**Custom layout per mailer:**
```ruby
class FeedbackMailer < ApplicationMailer
  layout "feedback_mailer"
end
```
</pattern>

## Mailer Previews

<pattern name="previews">
<description>Preview emails in browser during development</description>

```ruby
# test/mailers/previews/feedback_mailer_preview.rb
class FeedbackMailerPreview < ActionMailer::Preview
  # Preview at http://localhost:3000/rails/mailers/feedback_mailer/notify_recipient
  def notify_recipient
    feedback = Feedback.first || Feedback.new(
      content: "Sample feedback for preview",
      recipient_email: "recipient@example.com",
      token: "preview-token"
    )
    FeedbackMailer.notify_recipient(feedback)
  end

  def weekly_digest
    FeedbackMailer.weekly_digest(User.first || User.new(email: "test@example.com"), Feedback.limit(5))
  end
end
```

**Access at:** http://localhost:3000/rails/mailers (no emails sent)
</pattern>

## Interceptors

<pattern name="interceptors">
<description>Intercept emails before delivery (modify or redirect)</description>

```ruby
# lib/development_mail_interceptor.rb
class DevelopmentMailInterceptor
  def self.delivering_email(message)
    original_to = message.to.join(", ")
    message.subject = "[TO: #{original_to}] #{message.subject}"
    message.to = "dev@example.com"
  end
end

# config/initializers/mail_interceptor.rb
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
```

**Use cases:** Redirect emails in dev/staging, add prefixes, filter content, block domains
</pattern>

## Observers

<pattern name="observers">
<description>Observe email delivery for logging or tracking</description>

```ruby
# app/mailers/mail_observer.rb
class MailObserver
  def self.delivered_email(message)
    Rails.logger.info("Email sent: #{message.subject} to #{message.to.join(', ')}")
    EmailMetric.create!(to: message.to.first, subject: message.subject, delivered_at: Time.current)
  end
end

# config/initializers/mail_observer.rb
ActionMailer::Base.register_observer(MailObserver)
```

**Use cases:** Log deliveries, track metrics, trigger webhooks, monitor volume
</pattern>

## Configuration

<pattern name="configuration">
<description>Environment-specific email configuration</description>

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
end

# config/environments/production.rb (SMTP)
Rails.application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "smtp.sendgrid.net",
    port: 587,
    domain: Rails.application.credentials.dig(:smtp, :domain),
    user_name: Rails.application.credentials.dig(:smtp, :username),
    password: Rails.application.credentials.dig(:smtp, :password),
    authentication: :plain,
    enable_starttls_auto: true
  }
  config.action_mailer.default_url_options = { host: "example.com", protocol: "https" }
end

# config/environments/test.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: "example.com" }
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Using deliver_now in production (blocks request)</description>
<bad-example>
```ruby
# ❌ Blocks HTTP request
FeedbackMailer.notify_recipient(@feedback).deliver_now
```
</bad-example>
<good-example>
```ruby
# ✅ Async delivery
FeedbackMailer.notify_recipient(@feedback).deliver_later
```
</good-example>
</antipattern>

<antipattern>
<description>Using *_path helpers instead of *_url (broken links)</description>
<bad-example>
```ruby
# ❌ Relative path: "/feedbacks/abc123"
@view_url = feedback_path(feedback.token)
```
</bad-example>
<good-example>
```ruby
# ✅ Full URL: "https://example.com/feedbacks/abc123"
@view_url = feedback_url(feedback.token)
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# test/mailers/feedback_mailer_test.rb
class FeedbackMailerTest < ActionMailer::TestCase
  test "notify_recipient sends email with correct attributes" do
    email = FeedbackMailer.notify_recipient(@feedback)

    assert_emails 1 { email.deliver_now }
    assert_equal [@feedback.recipient_email], email.to
    assert_equal ["noreply@example.com"], email.from
    assert_includes email.html_part.body.to_s, @feedback.content
    assert_includes email.text_part.body.to_s, feedback_url(@feedback.token)
  end

  test "delivers via background job" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      FeedbackMailer.notify_recipient(@feedback).deliver_later
    end
  end

  test "attachments" do
    email = ReportMailer.monthly_report(user, data)
    assert_equal 2, email.attachments.size
    assert_equal "report.pdf", email.attachments[0].filename
  end
end
```
</testing>

<related-skills>
- solid-stack-setup - Using SolidQueue for email delivery

- form-objects - Sending emails from form objects
- tdd-minitest - Testing strategies for mailers
- security-xss - Preventing XSS in email templates
</related-skills>

<resources>
- [Rails Guides - Action Mailer Basics](https://guides.rubyonrails.org/action_mailer_basics.html)
- [Rails API - ActionMailer::Base](https://api.rubyonrails.org/classes/ActionMailer/Base.html)
- [Rails API - ActionMailer::TestCase](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
</resources>
