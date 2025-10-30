# frozen_string_literal: true

source "https://rubygems.org"

ruby ">= 3.3.0"

# Task automation
gem "rake", "~> 13.2"

group :test do
  # Core testing framework
  gem "minitest", "~> 5.25"
  gem "minitest-reporters", "~> 1.7" # Better test output formatting
end

group :development do
  # Ruby linting
  gem "rubocop", "~> 1.68", require: false
  gem "rubocop-minitest", "~> 0.36", require: false
  gem "rubocop-rake", "~> 0.6", require: false

  # Markdown linting for skill files
  gem "mdl", "~> 0.13.0", require: false
end

group :development, :test do
  # YAML validation
  gem "yaml-lint", "~> 0.1.2", require: false

  # Optional: HTTP clients for LLM judge integration tests
  # gem "http", "~> 5.2"
  # gem "anthropic", "~> 0.1"
end
