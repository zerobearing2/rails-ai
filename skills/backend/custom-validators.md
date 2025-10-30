---
name: custom-validators
domain: backend
dependencies: [activerecord-patterns]
version: 1.0
rails_version: 8.1+
---

# Custom Validators

Create reusable validation logic for ActiveRecord models using ActiveModel::EachValidator for single attributes or ActiveModel::Validator for multi-attribute validation.

<when-to-use>
- Validating email addresses, URLs, phone numbers across multiple models
- Complex validation logic that doesn't fit into built-in validators
- Business rules that need to be applied consistently
- Validations requiring external data or API calls
- Content validation (profanity, length in words, format checking)
- Multi-attribute validations (date ranges, conditional requirements)
- When the same validation is needed across 3+ models
- File type, size, or content validation
</when-to-use>

<benefits>
- **Reusability** - Write once, use across multiple models
- **Testability** - Test validators in isolation from models
- **Maintainability** - Centralize validation logic in one place
- **Readability** - Clear, declarative validation in models
- **Consistency** - Same rules applied everywhere
- **Configurability** - Support options like :allow_blank, :message
- **Single Responsibility** - Validators handle one concern
</benefits>

<standards>
- Place validators in `app/validators/` directory
- Inherit from `ActiveModel::EachValidator` for single-attribute validation
- Inherit from `ActiveModel::Validator` for multi-attribute validation
- Name validators with `Validator` suffix (EmailValidator, UrlValidator)
- Support `:allow_blank` option for optional fields
- Support `:message` option for custom error messages
- Keep validators focused on one validation concern
- Use descriptive error messages that help users fix issues
- Return early for blank values when `:allow_blank` is true
- Test validators independently with test models
</standards>

## Single-Attribute Validators

<pattern name="email-validator">
<description>Validate email addresses with configurable regex pattern</description>

**Validator:**
```ruby
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
```

**Usage in Models:**
```ruby
class Feedback < ApplicationRecord
  # ✅ Required email
  validates :recipient_email, email: true

  # ✅ Optional email
  validates :sender_email, email: { allow_blank: true }

  # ✅ Custom error message
  validates :email, email: { message: "must be a valid company email" }
end

class User < ApplicationRecord
  validates :email, email: true
  validates :backup_email, email: { allow_blank: true }
end
```

**Benefits:**
- Single source of truth for email validation
- Consistent validation across all models
- Easy to update regex in one place
- Support for optional vs required emails
</pattern>

<pattern name="url-validator">
<description>Validate URLs with protocol and domain restrictions</description>

**Validator:**
```ruby
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
```

**Usage in Models:**
```ruby
class Profile < ApplicationRecord
  # ✅ Basic URL validation
  validates :website, url: { allow_blank: true }

  # ✅ Require protocol
  validates :blog_url, url: {
    allow_blank: true,
    require_protocol: true
  }

  # ✅ Restrict to specific domains
  validates :avatar_url, url: {
    allowed_domains: ["example.com", "cdn.example.com"]
  }
end
```

**Benefits:**
- Validates URL format and protocol
- Restrict to trusted domains for security
- Handles malformed URLs gracefully
- Configurable requirements per use case
</pattern>

<pattern name="phone-validator">
<description>Validate phone numbers with normalization</description>

**Validator:**
```ruby
# app/validators/phone_validator.rb
class PhoneValidator < ActiveModel::EachValidator
  # E.164 format: +[country code][number]
  PHONE_REGEX = /\A\+?[1-9]\d{1,14}\z/

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
    # Remove common separators: spaces, dashes, parentheses, dots
    phone.to_s.gsub(/[\s\-\(\)\.]/,' ')
  end
end
```

**Usage in Models:**
```ruby
class User < ApplicationRecord
  # ✅ Required phone number
  validates :phone, phone: true

  # ✅ Optional mobile number
  validates :mobile, phone: { allow_blank: true }

  # ✅ Custom message
  validates :emergency_contact, phone: {
    message: "must be a valid international phone number"
  }
end
```

**Benefits:**
- Normalizes phone numbers before validation
- Accepts various formats (with/without separators)
- E.164 standard compliance
- Handles international numbers
</pattern>

<pattern name="content-length-validator">
<description>Validate content by word count instead of character count</description>

**Validator:**
```ruby
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
```

**Usage in Models:**
```ruby
class Feedback < ApplicationRecord
  # ✅ Word count validation
  validates :content, content_length: {
    minimum_words: 10,
    maximum_words: 500
  }
end

class Article < ApplicationRecord
  # ✅ Minimum words only
  validates :body, content_length: {
    minimum_words: 100
  }
end

class Comment < ApplicationRecord
  # ✅ Maximum words only
  validates :text, content_length: {
    maximum_words: 100,
    allow_blank: true
  }
end
```

**Benefits:**
- More meaningful than character limits for text content
- Shows current word count in error message
- Helps users understand content requirements
- Flexible min/max configuration
</pattern>

<pattern name="json-validator">
<description>Validate JSON structure and required fields</description>

**Validator:**
```ruby
# app/validators/json_validator.rb
class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    parsed = parse_json(value, record, attribute)
    return unless parsed

    validate_schema(parsed, record, attribute) if options[:schema]
    validate_required_keys(parsed, record, attribute) if options[:required_keys]
  end

  private

  def parse_json(value, record, attribute)
    if value.is_a?(Hash)
      value
    elsif value.is_a?(String)
      JSON.parse(value)
    else
      record.errors.add(attribute, "must be valid JSON")
      nil
    end
  rescue JSON::ParserError
    record.errors.add(attribute, "must be valid JSON")
    nil
  end

  def validate_schema(parsed, record, attribute)
    schema = options[:schema]

    schema.each do |key, expected_type|
      next unless parsed.key?(key.to_s)

      actual_value = parsed[key.to_s]
      unless valid_type?(actual_value, expected_type)
        record.errors.add(
          attribute,
          "#{key} must be a #{expected_type}"
        )
      end
    end
  end

  def validate_required_keys(parsed, record, attribute)
    options[:required_keys].each do |key|
      unless parsed.key?(key.to_s)
        record.errors.add(attribute, "must include #{key}")
      end
    end
  end

  def valid_type?(value, expected_type)
    case expected_type
    when :string then value.is_a?(String)
    when :integer then value.is_a?(Integer)
    when :boolean then [true, false].include?(value)
    when :array then value.is_a?(Array)
    when :hash then value.is_a?(Hash)
    else true
    end
  end
end
```

**Usage in Models:**
```ruby
class Configuration < ApplicationRecord
  # ✅ Basic JSON validation
  validates :settings, json: true

  # ✅ Require specific keys
  validates :metadata, json: {
    required_keys: [:version, :author]
  }

  # ✅ Validate schema
  validates :config, json: {
    schema: {
      timeout: :integer,
      enabled: :boolean,
      endpoints: :array
    }
  }
end
```

**Benefits:**
- Validates JSON parsing before saving
- Ensures required fields are present
- Type checking for expected values
- Prevents invalid JSON in database
</pattern>

<pattern name="file-type-validator">
<description>Validate file types for Active Storage attachments</description>

**Validator:**
```ruby
# app/validators/file_type_validator.rb
class FileTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.attached?

    allowed_types = options[:in] || options[:with]
    return unless allowed_types

    if value.is_a?(ActiveStorage::Attached::Many)
      value.each do |attachment|
        validate_content_type(record, attribute, attachment, allowed_types)
      end
    else
      validate_content_type(record, attribute, value, allowed_types)
    end
  end

  private

  def validate_content_type(record, attribute, attachment, allowed_types)
    return if allowed_types.include?(attachment.content_type)

    record.errors.add(
      attribute,
      options[:message] || "must be one of: #{allowed_types.join(', ')}"
    )
  end
end
```

**Usage in Models:**
```ruby
class Document < ApplicationRecord
  has_one_attached :file

  # ✅ Validate file type
  validates :file, file_type: {
    in: %w[application/pdf image/png image/jpeg]
  }
end

class Avatar < ApplicationRecord
  has_one_attached :image

  # ✅ Images only with custom message
  validates :image, file_type: {
    in: %w[image/png image/jpeg image/gif],
    message: "must be a PNG, JPEG, or GIF image"
  }
end

class Gallery < ApplicationRecord
  has_many_attached :photos

  # ✅ Multiple attachments
  validates :photos, file_type: {
    in: %w[image/png image/jpeg]
  }
end
```

**Benefits:**
- Prevents invalid file uploads
- Works with single and multiple attachments
- Clear error messages about allowed types
- Security: block executable files
</pattern>

## Multi-Attribute Validators

<pattern name="date-range-validator">
<description>Validate that end date is after start date with duration limits</description>

**Validator:**
```ruby
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
```

**Usage in Models:**
```ruby
class Event < ApplicationRecord
  # ✅ Basic date range validation
  validates_with DateRangeValidator

  # ✅ With maximum duration
  validates_with DateRangeValidator,
    maximum_duration: 30,
    allow_past: false
end

class Booking < ApplicationRecord
  validates_with DateRangeValidator,
    maximum_duration: 365,
    allow_past: true
end
```

**Benefits:**
- Validates relationship between two dates
- Enforces business rules on duration
- Prevents invalid date ranges
- Configurable for different use cases
</pattern>

<pattern name="conditional-presence-validator">
<description>Require fields conditionally based on other attributes</description>

**Validator:**
```ruby
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
```

**Usage in Models:**
```ruby
class Feedback < ApplicationRecord
  # ✅ Conditional on method
  validates :response, conditional_presence: {
    if: :responded_status?,
    message: "is required when status is 'responded'"
  }

  # ✅ Conditional on proc
  validates :rejection_reason, conditional_presence: {
    if: ->(record) { record.status == "rejected" }
  }

  def responded_status?
    status == "responded"
  end
end

class Order < ApplicationRecord
  # ✅ Require shipping address if physical product
  validates :shipping_address, conditional_presence: {
    if: :requires_shipping?
  }

  def requires_shipping?
    product_type == "physical"
  end
end
```

**Benefits:**
- Flexible conditional validation
- Supports both methods and procs
- Clear error messages
- Avoids complex custom validate methods
</pattern>

<pattern name="business-logic-validator">
<description>Complex multi-field validation with business rules</description>

**Validator:**
```ruby
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
```

**Usage in Models:**
```ruby
class Feedback < ApplicationRecord
  validates_with FeedbackCompletenessValidator
end
```

**Benefits:**
- Encapsulates complex business rules
- Multiple validations in one class
- Testable business logic
- Clean model code
</pattern>

## Plain Ruby Object Validator

<pattern name="plain-validator">
<description>Plain Ruby object for custom validation logic</description>

**Validator:**
```ruby
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
```

**Usage in Models:**
```ruby
class Address < ApplicationRecord
  validate do |address|
    AddressValidator.new(address).validate
  end
end
```

**Benefits:**
- Full control over validation logic
- No framework dependencies
- Reusable validation patterns
- Easy to test independently
</pattern>

<antipatterns>
<antipattern>
<description>Duplicating validation logic across models</description>
<reason>Hard to maintain, inconsistent validation, violates DRY principle</reason>
<bad-example>
```ruby
# ❌ BAD - Duplicated email validation
class User < ApplicationRecord
  validates :email, format: {
    with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i,
    message: "is not a valid email"
  }
end

class Feedback < ApplicationRecord
  validates :recipient_email, format: {
    with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i,
    message: "is not a valid email"
  }
end

class Profile < ApplicationRecord
  validates :contact_email, format: {
    with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i,
    message: "is not a valid email"
  }
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Reusable email validator
class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    unless value =~ EMAIL_REGEX
      record.errors.add(attribute, options[:message] || "is not a valid email")
    end
  end
end

class User < ApplicationRecord
  validates :email, email: true
end

class Feedback < ApplicationRecord
  validates :recipient_email, email: true
end

class Profile < ApplicationRecord
  validates :contact_email, email: { allow_blank: true }
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not supporting :allow_blank option</description>
<reason>Forces validation even for optional fields, breaks user expectations</reason>
<bad-example>
```ruby
# ❌ BAD - No allow_blank support
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # Always validates, even if blank
    uri = URI.parse(value)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      record.errors.add(attribute, "must be a valid URL")
    end
  rescue URI::InvalidURIError
    record.errors.add(attribute, "is not a valid URL")
  end
end

# This will fail validation even though website is optional
class Profile < ApplicationRecord
  validates :website, url: { allow_blank: true } # Doesn't work!
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Supports allow_blank
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    uri = URI.parse(value)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      record.errors.add(attribute, "must be a valid URL")
    end
  rescue URI::InvalidURIError
    record.errors.add(attribute, "is not a valid URL")
  end
end

class Profile < ApplicationRecord
  validates :website, url: { allow_blank: true } # Works correctly
end
```
</good-example>
</antipattern>

<antipattern>
<description>Hardcoding error messages</description>
<reason>Cannot customize messages per use case, reduces flexibility</reason>
<bad-example>
```ruby
# ❌ BAD - Hardcoded message
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ EMAIL_REGEX
      record.errors.add(attribute, "is not a valid email address")
    end
  end
end

# Cannot customize the message
class User < ApplicationRecord
  validates :email, email: { message: "must be a company email" } # Ignored!
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Supports custom messages
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ EMAIL_REGEX
      record.errors.add(
        attribute,
        options[:message] || "is not a valid email address"
      )
    end
  end
end

class User < ApplicationRecord
  validates :email, email: { message: "must be a company email" } # Works!
end
```
</good-example>
</antipattern>

<antipattern>
<description>Creating validators for single-use cases</description>
<reason>Over-engineering, adds unnecessary files and complexity</reason>
<bad-example>
```ruby
# ❌ BAD - Validator used only once
class ArticleTitleValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && value.length < 5
      record.errors.add(attribute, "is too short")
    end
  end
end

class Article < ApplicationRecord
  validates :title, article_title: true
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use built-in validators for simple cases
class Article < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5 }
end

# ✅ GOOD - Or custom validate method if complex
class Article < ApplicationRecord
  validate :title_meets_requirements

  private

  def title_meets_requirements
    return if title.blank?

    if title.length < 5
      errors.add(:title, "is too short")
    end
  end
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not handling exceptions in validators</description>
<reason>Unexpected errors can crash validation instead of showing user-friendly messages</reason>
<bad-example>
```ruby
# ❌ BAD - No exception handling
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    uri = URI.parse(value) # Can raise URI::InvalidURIError
    unless uri.is_a?(URI::HTTP)
      record.errors.add(attribute, "must be a valid URL")
    end
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Handles exceptions gracefully
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    uri = URI.parse(value)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      record.errors.add(attribute, "must be a valid URL")
    end
  rescue URI::InvalidURIError
    record.errors.add(attribute, "is not a valid URL")
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test custom validators in isolation using simple test models:

```ruby
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

  test "supports custom error messages" do
    TestModel.class_eval do
      validates :email, email: { message: "must be valid" }
    end

    model = TestModel.new(email: "invalid")
    assert_not model.valid?
    assert_includes model.errors[:email], "must be valid"
  end
end

# test/validators/url_validator_test.rb
class UrlValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Validations
    attr_accessor :url
    validates :url, url: true
  end

  test "accepts valid URLs" do
    model = TestModel.new(url: "https://example.com")
    assert model.valid?
  end

  test "rejects invalid URLs" do
    model = TestModel.new(url: "not a url")
    assert_not model.valid?
  end

  test "validates allowed domains" do
    TestModel.class_eval do
      validates :url, url: { allowed_domains: ["example.com"] }
    end

    model = TestModel.new(url: "https://evil.com")
    assert_not model.valid?

    model = TestModel.new(url: "https://example.com")
    assert model.valid?
  end
end

# test/validators/content_length_validator_test.rb
class ContentLengthValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Validations
    attr_accessor :content
    validates :content, content_length: { minimum_words: 5, maximum_words: 10 }
  end

  test "accepts content within word limits" do
    model = TestModel.new(content: "This has exactly five words")
    assert model.valid?
  end

  test "rejects content with too few words" do
    model = TestModel.new(content: "Too short")
    assert_not model.valid?
    assert_match(/must have at least 5 words/, model.errors[:content].first)
  end

  test "rejects content with too many words" do
    model = TestModel.new(content: "This content has way too many words and exceeds the maximum limit")
    assert_not model.valid?
    assert_match(/must have at most 10 words/, model.errors[:content].first)
  end
end

# test/validators/date_range_validator_test.rb
class DateRangeValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Validations
    attr_accessor :start_date, :end_date
    validates_with DateRangeValidator
  end

  test "accepts valid date range" do
    model = TestModel.new(
      start_date: Date.current,
      end_date: Date.current + 5.days
    )
    assert model.valid?
  end

  test "rejects end date before start date" do
    model = TestModel.new(
      start_date: Date.current,
      end_date: Date.current - 1.day
    )
    assert_not model.valid?
    assert_includes model.errors[:end_date], "must be after start date"
  end

  test "enforces maximum duration" do
    TestModel.class_eval do
      validates_with DateRangeValidator, maximum_duration: 30
    end

    model = TestModel.new(
      start_date: Date.current,
      end_date: Date.current + 31.days
    )
    assert_not model.valid?
  end
end
```
</testing>

<related-skills>
- activerecord-patterns - Model validation basics
- form-objects - Using validators in form objects
- security-xss - Input validation for security
- api-validation - API request validation
</related-skills>

<resources>
- [Rails Guides - Active Record Validations](https://guides.rubyonrails.org/active_record_validations.html#custom-validators)
- [Rails API - ActiveModel::EachValidator](https://api.rubyonrails.org/classes/ActiveModel/EachValidator.html)
- [Rails API - ActiveModel::Validator](https://api.rubyonrails.org/classes/ActiveModel/Validator.html)
</resources>
