# Custom Validators Pattern
# Reference: Rails Guides - Active Record Validations
# Category: MODELS - VALIDATIONS

# ============================================================================
# What Are Custom Validators?
# ============================================================================

# Custom validators allow you to create reusable validation logic that can be
# applied across multiple models. Rails provides two main approaches:
# 1. ActiveModel::EachValidator - For single attribute validation
# 2. ActiveModel::Validator - For multi-attribute or object-level validation

# ============================================================================
# ✅ RECOMMENDED: ActiveModel::EachValidator
# ============================================================================

# app/validators/email_validator.rb
class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    unless value =~ EMAIL_REGEX
      record.errors.add(
        attribute,
        options[:message] || "is not a valid email address"
      )
    end
  end
end

# Usage in models
class Feedback < ApplicationRecord
  validates :recipient_email, email: true
  validates :sender_email, email: { allow_blank: true }
end

class User < ApplicationRecord
  validates :email, email: { message: "must be a valid company email" }
end

# ============================================================================
# ✅ EXAMPLE: URL Validator
# ============================================================================

# app/validators/url_validator.rb
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    uri = URI.parse(value)

    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      add_error(record, attribute, "must be a valid HTTP or HTTPS URL")
      return
    end

    if options[:require_protocol] && uri.scheme.blank?
      add_error(record, attribute, "must include http:// or https://")
    end

    if options[:allowed_domains] && !allowed_domain?(uri, options[:allowed_domains])
      add_error(record, attribute, "domain is not allowed")
    end
  rescue URI::InvalidURIError
    add_error(record, attribute, "is not a valid URL")
  end

  private

  def allowed_domain?(uri, domains)
    domains.any? { |domain| uri.host&.end_with?(domain) }
  end

  def add_error(record, attribute, message)
    record.errors.add(attribute, options[:message] || message)
  end
end

# Usage
class Profile < ApplicationRecord
  validates :website, url: {
    allow_blank: true,
    require_protocol: true
  }

  validates :avatar_url, url: {
    allowed_domains: ["example.com", "cdn.example.com"]
  }
end

# ============================================================================
# ✅ EXAMPLE: Phone Number Validator
# ============================================================================

# app/validators/phone_validator.rb
class PhoneValidator < ActiveModel::EachValidator
  PHONE_REGEX = /\A\+?[1-9]\d{1,14}\z/ # E.164 format

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    normalized = normalize_phone(value)

    unless normalized =~ PHONE_REGEX
      record.errors.add(
        attribute,
        options[:message] || "is not a valid phone number"
      )
    end
  end

  private

  def normalize_phone(phone)
    phone.to_s.gsub(/[\s\-\(\)\.]/,' ')
  end
end

# Usage
class User < ApplicationRecord
  validates :phone, phone: true
  validates :mobile, phone: { allow_blank: true }
end

# ============================================================================
# ✅ EXAMPLE: Content Length Validator (Words/Characters)
# ============================================================================

# app/validators/content_length_validator.rb
class ContentLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    if options[:minimum_words]
      word_count = value.to_s.split.size

      if word_count < options[:minimum_words]
        record.errors.add(
          attribute,
          "must have at least #{options[:minimum_words]} words " \
          "(currently #{word_count})"
        )
      end
    end

    if options[:maximum_words]
      word_count = value.to_s.split.size

      if word_count > options[:maximum_words]
        record.errors.add(
          attribute,
          "must have at most #{options[:maximum_words]} words " \
          "(currently #{word_count})"
        )
      end
    end
  end
end

# Usage
class Feedback < ApplicationRecord
  validates :content, content_length: {
    minimum_words: 10,
    maximum_words: 500
  }
end

# ============================================================================
# ✅ EXAMPLE: Profanity Validator
# ============================================================================

# app/validators/profanity_validator.rb
class ProfanityValidator < ActiveModel::EachValidator
  PROFANITY_LIST = %w[bad inappropriate offensive].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    found_words = find_profanity(value)

    if found_words.any?
      record.errors.add(
        attribute,
        options[:message] || "contains inappropriate language: #{found_words.join(', ')}"
      )
    end
  end

  private

  def find_profanity(text)
    words = text.downcase.split(/\W+/)
    PROFANITY_LIST & words
  end
end

# Usage
class Feedback < ApplicationRecord
  validates :content, profanity: {
    message: "must not contain offensive language"
  }
end

# ============================================================================
# ✅ EXAMPLE: ActiveModel::Validator (Multi-Attribute)
# ============================================================================

# app/validators/date_range_validator.rb
class DateRangeValidator < ActiveModel::Validator
  def validate(record)
    return if record.start_date.blank? || record.end_date.blank?

    if record.start_date >= record.end_date
      record.errors.add(:end_date, "must be after start date")
    end

    if options[:maximum_duration]
      duration = (record.end_date - record.start_date).to_i

      if duration > options[:maximum_duration]
        record.errors.add(
          :base,
          "Duration cannot exceed #{options[:maximum_duration]} days"
        )
      end
    end

    if options[:allow_past] == false && record.start_date < Date.current
      record.errors.add(:start_date, "cannot be in the past")
    end
  end
end

# Usage
class Event < ApplicationRecord
  validates_with DateRangeValidator, maximum_duration: 30, allow_past: false
end

# ============================================================================
# ✅ EXAMPLE: Complex Business Logic Validator
# ============================================================================

# app/validators/feedback_completeness_validator.rb
class FeedbackCompletenessValidator < ActiveModel::Validator
  def validate(record)
    # Require sender identification if content is critical
    if record.content.present? && critical_content?(record.content)
      validate_sender_info(record)
    end

    # Require category for long feedback
    if record.content.present? && record.content.length > 500
      validate_category(record)
    end

    # Validate AI improvement compatibility
    if record.ai_improved?
      validate_ai_requirements(record)
    end
  end

  private

  def critical_content?(content)
    keywords = ["urgent", "critical", "important", "asap"]
    keywords.any? { |keyword| content.downcase.include?(keyword) }
  end

  def validate_sender_info(record)
    if record.sender_email.blank? && record.sender_name.blank?
      record.errors.add(
        :base,
        "Critical feedback requires sender identification"
      )
    end
  end

  def validate_category(record)
    if record.category.blank?
      record.errors.add(:category, "is required for detailed feedback")
    end
  end

  def validate_ai_requirements(record)
    unless record.original_content.present?
      record.errors.add(:original_content, "must be present for AI-improved feedback")
    end
  end
end

# Usage
class Feedback < ApplicationRecord
  validates_with FeedbackCompletenessValidator
end

# ============================================================================
# ✅ EXAMPLE: Plain Ruby Object Validator (Instance Variables)
# ============================================================================

# app/validators/address_validator.rb
class AddressValidator
  def initialize(record)
    @record = record
  end

  def validate
    validate_field(:house_number, required: true)
    validate_field(:street, required: true)
    validate_field(:postcode, required: true, format: /\A\d{5}\z/)
    validate_field(:city, required: true)
  end

  private

  attr_reader :record

  def validate_field(field, required: false, format: nil)
    value = record.send(field)

    if required && value.blank?
      record.errors.add(field, "#{field.to_s.humanize} is required")
    end

    if format && value.present? && !(value =~ format)
      record.errors.add(field, "#{field.to_s.humanize} format is invalid")
    end
  end
end

# Usage
class Address < ApplicationRecord
  validate do |address|
    AddressValidator.new(address).validate
  end
end

# ============================================================================
# ✅ EXAMPLE: Conditional Custom Validator
# ============================================================================

# app/validators/conditional_presence_validator.rb
class ConditionalPresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    condition_met = if options[:if].is_a?(Proc)
      options[:if].call(record)
    elsif options[:if].is_a?(Symbol)
      record.send(options[:if])
    else
      true
    end

    if condition_met && value.blank?
      record.errors.add(
        attribute,
        options[:message] || "can't be blank"
      )
    end
  end
end

# Usage
class Feedback < ApplicationRecord
  validates :response, conditional_presence: {
    if: :responded_status?,
    message: "is required when status is 'responded'"
  }

  def responded_status?
    status == "responded"
  end
end

# ============================================================================
# ✅ TESTING CUSTOM VALIDATORS
# ============================================================================

# test/validators/email_validator_test.rb
require "test_helper"

class EmailValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, email: true
  end

  test "accepts valid email addresses" do
    valid_emails = [
      "user@example.com",
      "user.name@example.co.uk",
      "user+tag@example.com"
    ]

    valid_emails.each do |email|
      model = TestModel.new(email: email)
      assert model.valid?, "Expected #{email} to be valid"
    end
  end

  test "rejects invalid email addresses" do
    invalid_emails = [
      "invalid",
      "@example.com",
      "user@",
      "user @example.com"
    ]

    invalid_emails.each do |email|
      model = TestModel.new(email: email)
      assert_not model.valid?, "Expected #{email} to be invalid"
      assert_includes model.errors[:email], "is not a valid email address"
    end
  end

  test "accepts blank when allow_blank is true" do
    TestModel.class_eval do
      validates :email, email: { allow_blank: true }
    end

    model = TestModel.new(email: "")
    assert model.valid?
  end
end

# ============================================================================
# File Organization
# ============================================================================

# app/validators/
# ├── email_validator.rb
# ├── url_validator.rb
# ├── phone_validator.rb
# ├── content_length_validator.rb
# ├── profanity_validator.rb
# ├── date_range_validator.rb
# ├── address_validator.rb
# └── feedback_completeness_validator.rb

# test/validators/
# ├── email_validator_test.rb
# ├── url_validator_test.rb
# └── ...

# ============================================================================
# RULE: Use ActiveModel::EachValidator for single-attribute validation
# USE: ActiveModel::Validator for multi-attribute or object-level validation
# TEST: Test validators in isolation with simple test models
# REUSABLE: Create validators that can be used across multiple models
# OPTIONS: Support options like :allow_blank, :message, custom options
# ============================================================================
