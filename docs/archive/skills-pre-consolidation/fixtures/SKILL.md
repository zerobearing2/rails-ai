---
name: rails-ai:fixtures
description: Use when testing Rails models/controllers with fixtures - provides consistent test data with automatic association handling (YAML-based, faster than factories)
---

# Fixtures and Test Data

Fixtures are YAML files that define sample data for tests. They're loaded into the test database before each test runs, providing consistent, predictable test data.

<superpowers-integration>
**REQUIRED BACKGROUND:** Use superpowers:test-driven-development for TDD process
  - That skill defines RED-GREEN-REFACTOR cycle
  - This skill provides Rails-specific fixture patterns for test data
</superpowers-integration>

<when-to-use>
- Model and controller tests requiring reference data
- Testing associations between models
- System tests needing baseline data
- Testing scopes and query methods
- When you need fast, repeatable test data
</when-to-use>

<benefits>
- **Consistency** - Same data for every test run
- **Speed** - Faster than creating records in setup
- **Relationships** - Automatic association handling
- **Transactional** - Rolled back after each test
- **Referenced** - Access via helper methods
</benefits>

<standards>
- Store fixtures in `test/fixtures/*.yml`
- Use descriptive names (alice, bob) not generic (one, two)
- Keep minimal - only essential data
- Use ERB for dynamic values (dates, calculations)
- Reference associations by name, never hardcoded IDs
- Validate all fixtures are valid records
- Clean up Active Storage fixtures after tests
</standards>

## Basic Fixtures

<pattern name="basic-yaml-fixtures">
<description>Define simple fixture data in YAML format</description>

**Fixture File:**
```yaml
# test/fixtures/users.yml
alice:
  name: Alice Johnson
  email: alice@example.com
  active: true
  created_at: <%= 1.week.ago %>

bob:
  name: Bob Smith
  email: bob@example.com
  active: true
  created_at: <%= 2.weeks.ago %>

carol:
  name: Carol Williams
  email: carol@example.com
  active: false
```

**Accessing Fixtures:**
```ruby
# test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "accessing fixtures by name" do
    alice = users(:alice)
    assert_equal "Alice Johnson", alice.name
    assert alice.persisted?
  end

  test "fixtures have auto-generated IDs" do
    alice, bob = users(:alice, :bob)
    assert alice.id && bob.id
    refute_equal alice.id, bob.id
  end

  test "accessing multiple fixtures at once" do
    alice, bob = users(:alice, :bob)
    assert_equal "Alice Johnson", alice.name
  end
end
```
</pattern>

## Fixtures with Associations

<pattern name="association-fixtures">
<description>Define associations between fixtures using names</description>

**Fixture Files:**
```yaml
# test/fixtures/users.yml
alice:
  name: Alice Johnson
  email: alice@example.com

bob:
  name: Bob Smith
  email: bob@example.com
```

```yaml
# test/fixtures/feedbacks.yml
one:
  content: This is great feedback!
  recipient_email: alice@example.com
  sender: alice  # ✅ References users fixture by name
  status: pending
  created_at: <%= 1.day.ago %>

two:
  content: Could be improved
  recipient_email: bob@example.com
  sender: bob
  status: responded
  created_at: <%= 3.days.ago %>
```

**Testing Associations:**
```ruby
class AssociationFixturesTest < ActiveSupport::TestCase
  test "fixtures handle associations automatically" do
    feedback = feedbacks(:one)
    assert_equal users(:alice), feedback.sender
    assert_equal "alice@example.com", feedback.sender.email
  end

  test "has_many associations work through fixtures" do
    alice = users(:alice)
    assert alice.feedbacks.exists?
    assert_includes alice.feedbacks, feedbacks(:one)
  end
end
```
</pattern>

## ERB in Fixtures

<pattern name="erb-dynamic-values">
<description>Use ERB for dynamic values and calculations</description>

**Fixture with ERB:**
```yaml
# test/fixtures/products.yml
tshirt:
  name: T-Shirt
  price: <%= 19.99 %>
  inventory_count: 15
  sku: <%= "TSH-#{SecureRandom.hex(4)}" %>
  created_at: <%= Time.current %>
  updated_at: <%= Time.current %>

shoes:
  name: Running Shoes
  price: <%= 89.99 %>
  inventory_count: 0
  on_sale: <%= true %>
  sale_price: <%= 89.99 * 0.8 %>  # 20% off
  created_at: <%= 3.months.ago %>

laptop:
  name: Laptop
  price: <%= 1299.99 %>
  category: electronics
  available_at: <%= 1.week.from_now %>
```

**Testing Dynamic Values:**
```ruby
class ERBFixturesTest < ActiveSupport::TestCase
  test "ERB is evaluated in fixtures" do
    tshirt = products(:tshirt)
    assert_equal 19.99, tshirt.price
    assert tshirt.created_at
    assert tshirt.sku.present?
  end

  test "dynamic calculations work" do
    shoes = products(:shoes)
    assert shoes.on_sale?
    assert_in_delta 71.99, shoes.sale_price, 0.01
  end
end
```

**Common ERB Patterns:**
```yaml
# Dates/times
created_at: <%= 1.day.ago %>
expires_at: <%= Time.current + 30.days %>

# Random values
token: <%= SecureRandom.hex(16) %>

# Calculations
discount: <%= 99.99 * 0.9 %>
```
</pattern>

## Fixture Helper Methods

<pattern name="fixture-helper-methods">
<description>Share reusable logic across fixtures with helper methods</description>

**Define Helpers:**
```ruby
# test/test_helper.rb
module FixtureFileHelpers
  def default_avatar_url
    "https://example.com/default-avatar.png"
  end

  def formatted_date(date)
    date.strftime("%Y-%m-%d")
  end

  def default_password_digest
    BCrypt::Password.create("password123", cost: 4)
  end

  def admin_permissions
    %w[read write delete admin].to_json
  end
end

# Make helpers available to fixtures
ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

**Use in Fixtures:**
```yaml
# test/fixtures/users.yml
david:
  name: David
  email: david@example.com
  avatar_url: <%= default_avatar_url %>
  registered_on: <%= formatted_date(1.month.ago) %>
  password_digest: <%= default_password_digest %>

admin:
  name: Admin User
  email: admin@example.com
  permissions: <%= admin_permissions %>
```

**Testing:**
```ruby
class FixtureHelpersTest < ActiveSupport::TestCase
  test "uses fixture helper methods" do
    david = users(:david)
    assert_equal "https://example.com/default-avatar.png", david.avatar_url
    assert BCrypt::Password.new(david.password_digest).is_password?("password123")
  end
end
```
</pattern>

## Polymorphic Associations

<pattern name="polymorphic-fixtures">
<description>Define fixtures with polymorphic associations</description>

**Fixtures:**
```yaml
# test/fixtures/comments.yml
feedback_comment:
  content: Great feedback!
  commentable: one (Feedback)  # Polymorphic association
  user: alice
  created_at: <%= 1.day.ago %>

article_comment:
  content: Interesting article
  commentable: first_article (Article)  # Different type
  user: bob
  created_at: <%= 2.days.ago %>

product_comment:
  content: Love this product!
  commentable: tshirt (Product)
  user: carol
```

**Testing:**
```ruby
class PolymorphicFixturesTest < ActiveSupport::TestCase
  test "polymorphic associations in fixtures" do
    feedback_comment = comments(:feedback_comment)
    article_comment = comments(:article_comment)

    assert_instance_of Feedback, feedback_comment.commentable
    assert_instance_of Article, article_comment.commentable
    assert_equal "Feedback", feedback_comment.commentable_type
  end
end
```
</pattern>

## Active Storage Fixtures

<pattern name="active-storage-fixtures">
<description>Define fixtures for file attachments</description>

**Storage Configuration:**
```yaml
# config/storage.yml
test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

**Fixtures:**
```yaml
# test/fixtures/active_storage/blobs.yml
avatar_blob:
  key: <%= ActiveStorage::Blob.generate_unique_secure_token %>
  filename: avatar.jpg
  content_type: image/jpeg
  metadata: '{"identified":true,"analyzed":true}'
  service_name: test_fixtures
  byte_size: 1024
  checksum: <%= OpenSSL::Digest::MD5.base64digest("avatar content") %>

document_blob:
  key: <%= ActiveStorage::Blob.generate_unique_secure_token %>
  filename: document.pdf
  content_type: application/pdf
  metadata: '{}'
  service_name: test_fixtures
  byte_size: 2048
  checksum: <%= OpenSSL::Digest::MD5.base64digest("document content") %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
alice_avatar:
  name: avatar
  record: alice (User)
  blob: avatar_blob

document_attachment:
  name: document
  record: one (Feedback)
  blob: document_blob
```

**Cleanup Configuration:**
```ruby
# test/test_helper.rb
class ActiveSupport::TestCase
  # Clean up after all tests
  Minitest.after_run do
    FileUtils.rm_rf(Rails.root.join("tmp/storage_fixtures"))
  end
end
```

**Testing:**
```ruby
class ActiveStorageFixturesTest < ActiveSupport::TestCase
  test "accessing attached files from fixtures" do
    alice = users(:alice)
    assert alice.avatar.attached?
    assert_equal "avatar.jpg", alice.avatar.filename.to_s
    assert_equal 1024, alice.avatar.byte_size
  end
end
```
</pattern>

## Action Text Fixtures

<pattern name="action-text-fixtures">
<description>Define rich text content fixtures</description>

**Fixtures:**
```yaml
# test/fixtures/action_text/rich_texts.yml
article_content:
  record: first_article (Article)
  name: content
  body: |
    <div>
      <h1>Article Title</h1>
      <p>This is <strong>rich text</strong> content with <em>formatting</em>.</p>
      <ul>
        <li>First item</li>
        <li>Second item</li>
      </ul>
    </div>

feedback_notes:
  record: one (Feedback)
  name: internal_notes
  body: |
    <p>Internal notes about this feedback.</p>
    <p>Contains <strong>important</strong> information.</p>
```

**Testing:**
```ruby
class ActionTextFixturesTest < ActiveSupport::TestCase
  test "accessing rich text from fixtures" do
    article = articles(:first_article)
    assert article.content.present?
    assert_includes article.content.to_s, "Article Title"
  end
end
```
</pattern>

## Loading Specific Fixtures

<pattern name="selective-fixture-loading">
<description>Load only specific fixtures for test classes</description>

**Load All (Default):**
```ruby
# test/test_helper.rb
class ActiveSupport::TestCase
  fixtures :all  # Load all fixtures
  self.use_transactional_tests = true
end
```

**Load Specific:**
```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  fixtures :users, :feedbacks  # Only specific fixtures

  test "only users and feedbacks are loaded" do
    assert users(:alice)
    assert feedbacks(:one)
  end
end
```

**Disable Fixtures:**
```ruby
# test/models/manual_test.rb
class ManualTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = false

  def setup
    @user = User.create!(name: "Manual User", email: "manual@example.com")
  end

  test "uses manually created data" do
    assert @user.persisted?
  end
end
```
</pattern>

## Namespaced Model Fixtures

<pattern name="namespaced-fixtures">
<description>Define fixtures for namespaced models</description>

**Directory Structure:**
```
test/fixtures/
  feedback/
    responses.yml
    categories.yml
```

**Fixtures:**
```yaml
# test/fixtures/feedback/responses.yml
helpful:
  feedback: one  # References feedbacks(:one)
  content: Thank you for the feedback!
  created_at: <%= 1.hour.ago %>
  helpful: true

not_helpful:
  feedback: two
  content: We'll look into this.
  created_at: <%= 2.hours.ago %>
  helpful: false
```

**Test Configuration:**
```ruby
# test/models/feedback/response_test.rb
class Feedback::ResponseTest < ActiveSupport::TestCase
  set_fixture_class "feedback/responses": Feedback::Response
  fixtures "feedback/responses"

  test "response belongs to feedback" do
    response = feedback_responses(:helpful)
    assert_equal feedbacks(:one), response.feedback
    assert response.helpful?
  end
end
```
</pattern>

<antipatterns>
<antipattern>
<description>Hardcoding IDs in fixtures</description>
<reason>Brittle, causes test failures, defeats auto-generation</reason>
<bad-example>
```yaml
# ❌ BAD - Hardcoded IDs
alice:
  id: 1
  name: Alice Johnson
one:
  id: 100
  sender_id: 1  # ❌ Hardcoded FK
```
</bad-example>
<good-example>
```yaml
# ✅ GOOD - Let Rails generate IDs
alice:
  name: Alice Johnson
one:
  sender: alice  # ✅ Reference by name
```
</good-example>
</antipattern>

<antipattern>
<description>Creating hundreds of fixtures</description>
<reason>Makes tests slow and hard to maintain</reason>
<bad-example>
```yaml
# ❌ BAD - Too many fixtures
user_1:
  name: User 1
# ... 99 more
```
</bad-example>
<good-example>
```yaml
# ✅ GOOD - Minimal fixtures
alice:
  name: Alice Johnson
bob:
  name: Bob Smith
```

```ruby
# Create bulk data in tests when needed
test "handles many users" do
  100.times { |i| User.create!(name: "User #{i}", email: "user#{i}@example.com") }
  assert_equal 102, User.count
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not validating fixture data</description>
<reason>Invalid fixtures cause confusing test failures</reason>
<bad-example>
```yaml
# ❌ BAD - Missing required field
invalid_user:
  name: Alice
  # Missing required email
```
</bad-example>
<good-example>
```yaml
# ✅ GOOD - Valid fixture
alice:
  name: Alice Johnson
  email: alice@example.com
```

```ruby
# Validate all fixtures
test "all user fixtures are valid" do
  User.find_each do |user|
    assert user.valid?, "#{user.name} invalid: #{user.errors.full_messages.join(', ')}"
  end
end
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# test/models/fixture_validation_test.rb
class FixtureValidationTest < ActiveSupport::TestCase
  test "all user fixtures are valid" do
    User.find_each do |user|
      assert user.valid?, "#{user.name} invalid: #{user.errors.full_messages.join(', ')}"
    end
  end

  test "feedback fixtures have required associations" do
    Feedback.find_each do |feedback|
      assert feedback.sender.present?, "Feedback #{feedback.id} missing sender"
    end
  end

  test "fixture associations set correctly" do
    feedback = feedbacks(:one)
    assert_equal users(:alice), feedback.sender
    assert_equal users(:alice).id, feedback.sender_id
  end
end
```
</testing>

<related-skills>
- superpowers:test-driven-development (TDD process)
- rails-ai:tdd-minitest (Minitest patterns)
- rails-ai:minitest-mocking (Mocking strategies)
- rails-ai:test-helpers (Shared test setup)
</related-skills>

<resources>
- [Rails Testing Guide - Fixtures](https://guides.rubyonrails.org/testing.html#the-low-down-on-fixtures)
- [FixtureSet Documentation](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)
</resources>
