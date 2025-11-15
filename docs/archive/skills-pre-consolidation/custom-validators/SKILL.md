---
name: rails-ai:custom-validators
description: Create reusable validation logic for ActiveRecord models using ActiveModel::EachValidator for single attributes or ActiveModel::Validator for multi-attribute validation.
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
      record.errors.add(attribute, options[:message] || "is not a valid email address")
    end
  end
end
```

**Usage:**
```ruby
validates :email, email: true
validates :backup_email, email: { allow_blank: true }
validates :email, email: { message: "must be a valid company email" }
```
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

    add_error(record, attribute, "must include http:// or https://") if options[:require_protocol] && uri.scheme.blank?
    add_error(record, attribute, "domain is not allowed") if options[:allowed_domains] && !allowed_domain?(uri, options[:allowed_domains])
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

**Usage:**
```ruby
validates :website, url: { allow_blank: true }
validates :blog_url, url: { allow_blank: true, require_protocol: true }
validates :avatar_url, url: { allowed_domains: ["example.com", "cdn.example.com"] }
```
</pattern>

<pattern name="phone-validator">
<description>Validate phone numbers with normalization</description>

**Validator:**
```ruby
# app/validators/phone_validator.rb
class PhoneValidator < ActiveModel::EachValidator
  PHONE_REGEX = /\A\+?[1-9]\d{1,14}\z/ # E.164 format

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    normalized = value.to_s.gsub(/[\s\-\(\)\.]/, '')
    unless normalized =~ PHONE_REGEX
      record.errors.add(attribute, options[:message] || "is not a valid phone number")
    end
  end
end
```

**Usage:**
```ruby
validates :phone, phone: true
validates :mobile, phone: { allow_blank: true }
validates :emergency_contact, phone: { message: "must be a valid international phone number" }
```
</pattern>

<pattern name="content-length-validator">
<description>Validate content by word count instead of character count</description>

**Validator:**
```ruby
# app/validators/content_length_validator.rb
class ContentLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    word_count = value.to_s.split.size

    if options[:minimum_words] && word_count < options[:minimum_words]
      record.errors.add(attribute, "must have at least #{options[:minimum_words]} words (currently #{word_count})")
    end

    if options[:maximum_words] && word_count > options[:maximum_words]
      record.errors.add(attribute, "must have at most #{options[:maximum_words]} words (currently #{word_count})")
    end
  end
end
```

**Usage:**
```ruby
validates :content, content_length: { minimum_words: 10, maximum_words: 500 }
validates :body, content_length: { minimum_words: 100 }
validates :text, content_length: { maximum_words: 100, allow_blank: true }
```
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
    value.is_a?(Hash) ? value : JSON.parse(value.to_s)
  rescue JSON::ParserError
    record.errors.add(attribute, "must be valid JSON")
    nil
  end

  def validate_schema(parsed, record, attribute)
    options[:schema].each do |key, type|
      next unless parsed.key?(key.to_s)
      record.errors.add(attribute, "#{key} must be a #{type}") unless valid_type?(parsed[key.to_s], type)
    end
  end

  def validate_required_keys(parsed, record, attribute)
    options[:required_keys].each do |key|
      record.errors.add(attribute, "must include #{key}") unless parsed.key?(key.to_s)
    end
  end

  def valid_type?(value, type)
    case type
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

**Usage:**
```ruby
validates :settings, json: true
validates :metadata, json: { required_keys: [:version, :author] }
validates :config, json: { schema: { timeout: :integer, enabled: :boolean, endpoints: :array } }
```
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

    attachments = value.is_a?(ActiveStorage::Attached::Many) ? value : [value]
    attachments.each do |attachment|
      unless allowed_types.include?(attachment.content_type)
        record.errors.add(attribute, options[:message] || "must be one of: #{allowed_types.join(', ')}")
      end
    end
  end
end
```

**Usage:**
```ruby
validates :file, file_type: { in: %w[application/pdf image/png image/jpeg] }
validates :image, file_type: { in: %w[image/png image/jpeg image/gif], message: "must be a PNG, JPEG, or GIF image" }
validates :photos, file_type: { in: %w[image/png image/jpeg] }
```
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

    record.errors.add(:end_date, "must be after start date") if record.start_date >= record.end_date

    if options[:maximum_duration]
      duration = (record.end_date - record.start_date).to_i
      record.errors.add(:base, "Duration cannot exceed #{options[:maximum_duration]} days") if duration > options[:maximum_duration]
    end

    if options[:allow_past] == false && record.start_date < Date.current
      record.errors.add(:start_date, "cannot be in the past")
    end
  end
end
```

**Usage:**
```ruby
validates_with DateRangeValidator
validates_with DateRangeValidator, maximum_duration: 30, allow_past: false
validates_with DateRangeValidator, maximum_duration: 365, allow_past: true
```
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

    record.errors.add(attribute, options[:message] || "can't be blank") if condition_met && value.blank?
  end
end
```

**Usage:**
```ruby
validates :response, conditional_presence: { if: :responded_status?, message: "is required when status is 'responded'" }
validates :rejection_reason, conditional_presence: { if: ->(r) { r.status == "rejected" } }
validates :shipping_address, conditional_presence: { if: :requires_shipping? }
```
</pattern>

<pattern name="business-logic-validator">
<description>Complex multi-field validation with business rules</description>

**Validator:**
```ruby
# app/validators/feedback_completeness_validator.rb
class FeedbackCompletenessValidator < ActiveModel::Validator
  def validate(record)
    validate_sender_info(record) if record.content.present? && critical_content?(record.content)
    validate_category(record) if record.content.present? && record.content.length > 500
    validate_ai_requirements(record) if record.ai_improved?
  end

  private

  def critical_content?(content)
    %w[urgent critical important asap].any? { |k| content.downcase.include?(k) }
  end

  def validate_sender_info(record)
    if record.sender_email.blank? && record.sender_name.blank?
      record.errors.add(:base, "Critical feedback requires sender identification")
    end
  end

  def validate_category(record)
    record.errors.add(:category, "is required for detailed feedback") if record.category.blank?
  end

  def validate_ai_requirements(record)
    record.errors.add(:original_content, "must be present for AI-improved feedback") unless record.original_content.present?
  end
end
```

**Usage:**
```ruby
validates_with FeedbackCompletenessValidator
```
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
    record.errors.add(field, "#{field.to_s.humanize} is required") if required && value.blank?
    record.errors.add(field, "#{field.to_s.humanize} format is invalid") if format && value.present? && !(value =~ format)
  end
end
```

**Usage:**
```ruby
validate { |address| AddressValidator.new(address).validate }
```
</pattern>

<antipatterns>
<antipattern>
<description>Duplicating validation logic across models</description>
<reason>Hard to maintain, inconsistent validation, violates DRY principle</reason>
<bad-example>
```ruby
# ❌ BAD - Duplicated email validation
class User < ApplicationRecord
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }
end

class Feedback < ApplicationRecord
  validates :recipient_email, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }
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
    record.errors.add(attribute, options[:message] || "is not a valid email") unless value =~ EMAIL_REGEX
  end
end

class User < ApplicationRecord
  validates :email, email: true
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not supporting :allow_blank and :message options</description>
<reason>Forces validation on optional fields, prevents custom error messages</reason>
<bad-example>
```ruby
# ❌ BAD - No allow_blank or message support
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    uri = URI.parse(value)
    record.errors.add(attribute, "must be a valid URL") unless uri.is_a?(URI::HTTP)
  end
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Supports standard options
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    uri = URI.parse(value)
    record.errors.add(attribute, options[:message] || "must be a valid URL") unless uri.is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    record.errors.add(attribute, options[:message] || "is not a valid URL")
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test validators in isolation with simple test models:

```ruby
# test/validators/email_validator_test.rb
class EmailValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, email: true
  end

  test "validates email format" do
    assert TestModel.new(email: "user@example.com").valid?
    assert_not TestModel.new(email: "invalid").valid?
  end

  test "supports allow_blank option" do
    TestModel.class_eval { validates :email, email: { allow_blank: true } }
    assert TestModel.new(email: "").valid?
  end

  test "supports custom messages" do
    TestModel.class_eval { validates :email, email: { message: "must be valid" } }
    model = TestModel.new(email: "invalid")
    assert_not model.valid?
    assert_includes model.errors[:email], "must be valid"
  end
end

# test/validators/content_length_validator_test.rb
class ContentLengthValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Validations
    attr_accessor :content
    validates :content, content_length: { minimum_words: 5, maximum_words: 10 }
  end

  test "validates word count" do
    assert TestModel.new(content: "This has exactly five words").valid?
    assert_not TestModel.new(content: "Short").valid?
    assert_match(/at least 5 words/, TestModel.new(content: "Short").errors[:content].first)
  end
end

# test/validators/date_range_validator_test.rb
class DateRangeValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Validations
    attr_accessor :start_date, :end_date
    validates_with DateRangeValidator
  end

  test "validates date range" do
    assert TestModel.new(start_date: Date.current, end_date: Date.current + 5.days).valid?
    model = TestModel.new(start_date: Date.current, end_date: Date.current - 1.day)
    assert_not model.valid?
    assert_includes model.errors[:end_date], "must be after start date"
  end
end
```
</testing>

<related-skills>
- rails-ai:activerecord-patterns - Model validation basics
- rails-ai:form-objects - Using validators in form objects
</related-skills>

<resources>
- [Rails Guides - Custom Validators](https://guides.rubyonrails.org/active_record_validations.html#custom-validators)
- [ActiveModel::EachValidator API](https://api.rubyonrails.org/classes/ActiveModel/EachValidator.html)
- [ActiveModel::Validator API](https://api.rubyonrails.org/classes/ActiveModel/Validator.html)
</resources>
