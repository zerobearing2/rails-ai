# Secure File Uploads
# Reference: Rails Security Guide, ActiveStorage
# Category: HIGH SECURITY

# ============================================================================
# ❌ VULNERABLE: Unsanitized Filenames
# ============================================================================

# NEVER trust user-provided filenames
def upload_file
  filename = params[:file].original_filename
  File.open("uploads/#{filename}", "wb") do |f|
    f.write(params[:file].read)
  end
end
# Attack: filename = "../../../config/database.yml"
# Result: Overwrites database configuration!

# Attack: filename = "../../public/index.html"
# Result: Overwrites homepage!

# ============================================================================
# ✅ SECURE: Sanitize Filenames
# ============================================================================

# Remove path components and dangerous characters
def sanitize_filename(filename)
  filename.strip.tap do |name|
    # Get only the filename, not the whole path
    name.sub!(/\A.*(\\|\/)/, "")

    # Replace all non-alphanumeric, underscore, dash, or period with underscore
    name.gsub!(/[^\w.-]/, "_")
  end
end

def safe_upload
  original_filename = params[:file].original_filename
  safe_filename = sanitize_filename(original_filename)

  # Still use unique name to avoid collisions
  unique_filename = "#{SecureRandom.uuid}_#{safe_filename}"

  File.open("uploads/#{unique_filename}", "wb") do |f|
    f.write(params[:file].read)
  end
end

# ============================================================================
# ✅ BEST PRACTICE: Use ActiveStorage (Recommended)
# ============================================================================

# ActiveStorage handles all security concerns automatically

# Model with attachment
class Feedback < ApplicationRecord
  has_one_attached :screenshot
  has_many_attached :documents

  # Validate file types
  validates :screenshot, content_type: ["image/png", "image/jpeg", "image/gif"],
                         size: { less_than: 5.megabytes }

  validates :documents, content_type: ["application/pdf", "text/plain"],
                        size: { less_than: 10.megabytes }
end

# Controller
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)
    if @feedback.save
      redirect_to @feedback, notice: "Created with attachments"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.expect(feedback: [:content, :recipient_email, :screenshot, documents: []])
  end
end

# View
<%= form_with model: @feedback do |f| %>
  <%= f.file_field :screenshot, accept: "image/*" %>
  <%= f.file_field :documents, multiple: true, accept: ".pdf,.txt" %>
  <%= f.submit %>
<% end %>

# ============================================================================
# ✅ ActiveStorage Content Type Validation
# ============================================================================

# config/initializers/active_storage.rb
Rails.application.config.active_storage.content_types_to_serve_as_binary.tap do |types|
  # Force download (not display) for these types
  types << "image/svg+xml"  # SVG can contain JavaScript
  types << "text/html"      # HTML can contain scripts
end

# Model validation
class Feedback < ApplicationRecord
  has_one_attached :image

  validate :acceptable_image_type

  private

  def acceptable_image_type
    return unless image.attached?

    # Check content type
    unless image.content_type.in?(%w(image/jpeg image/png image/gif))
      errors.add(:image, "must be a JPEG, PNG, or GIF")
    end

    # Check file extension
    unless image.filename.to_s.match?(/\.(jpe?g|png|gif)\z/i)
      errors.add(:image, "must have a valid extension (.jpg, .png, .gif)")
    end

    # Check magic bytes (file signature)
    unless image_file_valid?
      errors.add(:image, "file signature doesn't match declared type")
    end
  end

  def image_file_valid?
    # Read first few bytes to verify file type
    image.open do |file|
      magic_bytes = file.read(8)
      return false unless magic_bytes

      # JPEG: FF D8 FF
      # PNG: 89 50 4E 47
      # GIF: 47 49 46 38
      magic_bytes[0..2] == "\xFF\xD8\xFF" ||  # JPEG
        magic_bytes[0..3] == "\x89PNG" ||      # PNG
        magic_bytes[0..3] == "GIF8"            # GIF
    end
  end
end

# ============================================================================
# ✅ Virus Scanning (Production)
# ============================================================================

# Use gem like 'clamby' for virus scanning
# Gemfile: gem 'clamby'

class Feedback < ApplicationRecord
  has_one_attached :file

  validate :file_not_infected

  private

  def file_not_infected
    return unless file.attached?

    file.open do |temp_file|
      unless Clamby.safe?(temp_file.path)
        errors.add(:file, "contains malware")
      end
    end
  end
end

# ============================================================================
# ✅ Image Processing Security
# ============================================================================

# Use ActiveStorage variants for safe image processing
class Feedback < ApplicationRecord
  has_one_attached :image

  # Define safe variants
  def thumbnail
    image.variant(resize_to_limit: [100, 100])
  end

  def large
    image.variant(resize_to_limit: [800, 600])
  end
end

# View
<%= image_tag @feedback.thumbnail %>

# ============================================================================
# ❌ VULNERABLE: Direct File Serving
# ============================================================================

# NEVER serve uploaded files directly from public/
# uploads/user_supplied_name.html <- Contains JavaScript!
# Accessed at: /uploads/user_supplied_name.html
# Result: XSS attack!

# ============================================================================
# ✅ SECURE: Controller-Based File Serving with Headers
# ============================================================================

class DownloadsController < ApplicationController
  def show
    feedback = Feedback.find(params[:feedback_id])
    attachment = feedback.documents.find(params[:id])

    # Force download with safe filename
    send_data attachment.download,
              filename: sanitize_filename(attachment.filename.to_s),
              type: attachment.content_type,
              disposition: "attachment"  # Force download, don't display
  end
end

# ============================================================================
# ✅ Direct Upload Security (S3, etc.)
# ============================================================================

# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: us-east-1
  bucket: my-app-uploads

# ActiveStorage::Blob generates signed URLs automatically
<%= url_for(@feedback.image) %>
# Generates signed URL that expires, preventing hotlinking

# ============================================================================
# ✅ File Size Limits
# ============================================================================

# Application-wide limit in config
# config/application.rb
config.active_storage.max_file_size = 100.megabytes

# Model-specific limits
class Feedback < ApplicationRecord
  has_one_attached :image
  has_one_attached :document

  validates :image, size: { less_than: 5.megabytes,
                            message: "must be less than 5MB" }

  validates :document, size: { less_than: 10.megabytes,
                               message: "must be less than 10MB" }
end

# ============================================================================
# ✅ Testing File Uploads
# ============================================================================

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "accepts valid image" do
    feedback = Feedback.new(content: "test", recipient_email: "user@example.com")
    feedback.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/valid.jpg")),
      filename: "valid.jpg",
      content_type: "image/jpeg"
    )
    assert feedback.valid?
  end

  test "rejects invalid content type" do
    feedback = Feedback.new(content: "test", recipient_email: "user@example.com")
    feedback.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/malicious.exe")),
      filename: "malicious.exe",
      content_type: "application/x-msdownload"
    )
    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "must be a JPEG, PNG, or GIF"
  end

  test "rejects file with wrong extension" do
    feedback = Feedback.new(content: "test", recipient_email: "user@example.com")
    feedback.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/script.php")),
      filename: "script.php",
      content_type: "image/jpeg"  # Lying about content type
    )
    assert_not feedback.valid?
    assert_includes feedback.errors[:image], "must have a valid extension"
  end

  test "rejects oversized file" do
    feedback = Feedback.new(content: "test", recipient_email: "user@example.com")

    # Create large file
    large_file = Tempfile.new("large")
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
end

# ============================================================================
# RULE: NEVER trust user-provided filenames
# ALWAYS: Sanitize filenames (remove path components, special characters)
# PREFER: ActiveStorage for automatic security handling
# VALIDATE: Content type, file extension, AND file signature (magic bytes)
# LIMIT: File sizes to prevent DoS
# SCAN: For viruses in production (Clamby + ClamAV)
# SERVE: Via controller with Content-Disposition: attachment
# STORE: Outside public/ directory, use signed URLs
# ============================================================================
