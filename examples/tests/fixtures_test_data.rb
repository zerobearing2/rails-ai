# Fixtures and Test Data Comprehensive Patterns
# Reference: Rails Testing Guide, Fixtures Documentation
# Category: TESTS - FIXTURES

#
# ============================================================================
# What are Fixtures?
# ============================================================================
#
# Fixtures are YAML files that define sample data for your tests. They're
# loaded into the test database before each test runs, providing consistent,
# predictable test data.
#
# Benefits:
# ✅ Consistency - Same data for every test run
# ✅ Speed - Faster than creating records in setup
# ✅ Relationships - Automatic association handling
# ✅ Transactional - Rolled back after each test
# ✅ Referenced - Access via helper methods
#
# Location: test/fixtures/*.yml
#

#
# ============================================================================
# ✅ BASIC FIXTURES - YAML FORMAT
# ============================================================================
#

# test/fixtures/users.yml
# alice:
#   name: Alice Johnson
#   email: alice@example.com
#   created_at: <%= 1.week.ago %>
#
# bob:
#   name: Bob Smith
#   email: bob@example.com
#   created_at: <%= 2.weeks.ago %>
#
# carol:
#   name: Carol Williams
#   email: carol@example.com
#   active: true

require "test_helper"

class BasicFixturesTest < ActiveSupport::TestCase
  # Fixtures are automatically loaded if you have this in test_helper.rb:
  # fixtures :all

  test "accessing fixtures by name" do
    # Access fixtures using helper method: model_name(:fixture_name)
    alice = users(:alice)

    assert_equal "Alice Johnson", alice.name
    assert_equal "alice@example.com", alice.email
    assert alice.persisted?
  end

  test "fixtures have auto-generated IDs" do
    alice = users(:alice)
    bob = users(:bob)

    # IDs are automatically generated and unique
    assert alice.id
    assert bob.id
    refute_equal alice.id, bob.id
  end

  test "accessing multiple fixtures at once" do
    alice, bob = users(:alice, :bob)

    assert_equal "Alice Johnson", alice.name
    assert_equal "Bob Smith", bob.name
  end
end

#
# ============================================================================
# ✅ FIXTURES WITH ASSOCIATIONS
# ============================================================================
#

# test/fixtures/feedbacks.yml
# one:
#   content: This is great feedback!
#   recipient_email: alice@example.com
#   sender: alice  # References users fixture
#   status: pending
#   created_at: <%= 1.day.ago %>
#
# two:
#   content: Could be improved
#   recipient_email: bob@example.com
#   sender: bob
#   status: responded
#   created_at: <%= 3.days.ago %>

class AssociationFixturesTest < ActiveSupport::TestCase
  test "fixtures handle associations automatically" do
    feedback = feedbacks(:one)

    # Association is automatically set up
    assert_equal users(:alice), feedback.sender
  end

  test "has_many associations work through fixtures" do
    alice = users(:alice)

    # Alice's feedbacks from fixtures
    assert alice.feedbacks.exists?
    assert_includes alice.feedbacks, feedbacks(:one)
  end
end

#
# ============================================================================
# ✅ ERB IN FIXTURES
# ============================================================================
#

# test/fixtures/products.yml
# tshirt:
#   name: T-Shirt
#   price: <%= 19.99 %>
#   inventory_count: 15
#   sku: <%= "TSH-#{SecureRandom.hex(4)}" %>
#   created_at: <%= Time.current %>
#
# shoes:
#   name: Running Shoes
#   price: <%= 89.99 %>
#   inventory_count: 0
#   on_sale: <%= true %>
#   sale_price: <%= 89.99 * 0.8 %>  # 20% off

class ERBFixturesTest < ActiveSupport::TestCase
  test "ERB is evaluated in fixtures" do
    tshirt = products(:tshirt)

    assert_equal 19.99, tshirt.price
    assert tshirt.created_at  # ERB Time.current was evaluated
  end

  test "dynamic values with ERB" do
    shoes = products(:shoes)

    assert shoes.on_sale?
    assert_in_delta 71.99, shoes.sale_price, 0.01  # 20% off
  end
end

#
# ============================================================================
# ✅ FIXTURE HELPER METHODS
# ============================================================================
#

# Define shared helper methods for fixtures
# test/test_helper.rb
# module FixtureFileHelpers
#   def default_avatar_url
#     "https://example.com/default-avatar.png"
#   end
#
#   def formatted_date(date)
#     date.strftime("%Y-%m-%d")
#   end
# end
#
# ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers

# test/fixtures/users.yml (using helpers)
# david:
#   name: David
#   email: david@example.com
#   avatar_url: <%= default_avatar_url %>
#   registered_on: <%= formatted_date(1.month.ago) %>

class FixtureHelpersTest < ActiveSupport::TestCase
  test "uses fixture helper methods" do
    david = users(:david)

    assert_equal "https://example.com/default-avatar.png", david.avatar_url
  end
end

#
# ============================================================================
# ✅ NAMESPACED MODEL FIXTURES
# ============================================================================
#

# For namespaced models like Feedback::Response
# test/fixtures/feedback/responses.yml
# helpful:
#   feedback: one  # References feedbacks(:one)
#   content: Thank you for the feedback!
#   created_at: <%= 1.hour.ago %>

# Configure fixture class if needed:
# class FeedbackResponseTest < ActiveSupport::TestCase
#   set_fixture_class "feedback/responses": Feedback::Response
#   fixtures "feedback/responses"
# end

#
# ============================================================================
# ✅ ACTIVE STORAGE FIXTURES
# ============================================================================
#

# Configure Active Storage test service
# config/storage.yml
# test_fixtures:
#   service: Disk
#   root: <%= Rails.root.join("tmp/storage_fixtures") %>

# test/fixtures/active_storage/blobs.yml
# avatar_blob:
#   key: <%= ActiveStorage::Blob.generate_unique_secure_token %>
#   filename: avatar.jpg
#   content_type: image/jpeg
#   metadata: '{"identified":true}'
#   service_name: test_fixtures
#   byte_size: 1000
#   checksum: <%= OpenSSL::Digest::MD5.base64digest("avatar content") %>

# test/fixtures/active_storage/attachments.yml
# david_avatar:
#   name: avatar
#   record: david (User)
#   blob: avatar_blob

class ActiveStorageFixturesTest < ActiveSupport::TestCase
  # Clean up after tests (in test_helper.rb):
  # Minitest.after_run do
  #   FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  # end

  test "accessing attached files from fixtures" do
    david = users(:david)
    avatar = david.avatar

    assert avatar.attached?
    assert_equal "avatar.jpg", avatar.filename.to_s
    assert_equal 1000, avatar.byte_size
  end
end

#
# ============================================================================
# ✅ ACTION TEXT FIXTURES
# ============================================================================
#

# test/fixtures/action_text/rich_texts.yml
# article_content:
#   record: first_article (Article)
#   name: content
#   body: |
#     <div>
#       <h1>Hello World</h1>
#       <p>This is <strong>rich text</strong> content.</p>
#     </div>

class ActionTextFixturesTest < ActiveSupport::TestCase
  test "accessing rich text from fixtures" do
    article = articles(:first_article)

    assert article.content.present?
    assert_includes article.content.to_s, "Hello World"
    assert_includes article.content.to_s, "<strong>rich text</strong>"
  end
end

#
# ============================================================================
# ✅ POLYMORPHIC ASSOCIATIONS IN FIXTURES
# ============================================================================
#

# test/fixtures/comments.yml
# feedback_comment:
#   content: Great feedback!
#   commentable: one (Feedback)  # Polymorphic association
#   user: alice
#
# article_comment:
#   content: Interesting article
#   commentable: first_article (Article)
#   user: bob

class PolymorphicFixturesTest < ActiveSupport::TestCase
  test "polymorphic associations in fixtures" do
    feedback_comment = comments(:feedback_comment)
    article_comment = comments(:article_comment)

    assert_instance_of Feedback, feedback_comment.commentable
    assert_instance_of Article, article_comment.commentable
  end
end

#
# ============================================================================
# ✅ LOADING SPECIFIC FIXTURES
# ============================================================================
#

class SpecificFixturesTest < ActiveSupport::TestCase
  # Load only specific fixtures for this test class
  fixtures :users, :feedbacks

  # Don't load all fixtures
  self.use_transactional_tests = true

  test "only users and feedbacks are loaded" do
    assert users(:alice)
    assert feedbacks(:one)

    # Other models' fixtures are not loaded
    # assert_raises(StandardError) { products(:tshirt) }
  end
end

#
# ============================================================================
# ✅ DISABLING FIXTURES
# ============================================================================
#

class NoFixturesTest < ActiveSupport::TestCase
  # Don't load any fixtures for this test class
  self.use_instantiated_fixtures = false

  test "creates data manually" do
    user = User.create!(
      name: "Manual User",
      email: "manual@example.com"
    )

    assert user.persisted?
  end
end

#
# ============================================================================
# ✅ FIXTURE FILE ORGANIZATION
# ============================================================================
#

# Organize fixtures by model:
# test/fixtures/
#   users.yml
#   feedbacks.yml
#   products.yml
#   active_storage/
#     blobs.yml
#     attachments.yml
#   action_text/
#     rich_texts.yml
#   feedback/
#     responses.yml

#
# ============================================================================
# ✅ BEST PRACTICES FOR FIXTURES
# ============================================================================
#

# DO:
# ✅ Use fixtures for reference data (users, categories, etc.)
# ✅ Keep fixtures minimal - only essential data
# ✅ Use descriptive fixture names (alice, bob, not one, two)
# ✅ Use ERB for dynamic values
# ✅ Create fixtures for edge cases
# ✅ Use fixture helper methods for reusable logic
# ✅ Clean up Active Storage fixtures after tests
# ✅ Use associations by name, not ID

# DON'T:
# ❌ Don't create hundreds of fixtures
# ❌ Don't use fixtures for temporary test data (use factories/setup)
# ❌ Don't hardcode IDs in fixtures
# ❌ Don't create complex fixture graphs
# ❌ Don't use fixtures for integration tests (use setup)
# ❌ Don't commit storage/fixtures directory

#
# ============================================================================
# ✅ ALTERNATIVES TO FIXTURES
# ============================================================================
#

# For complex scenarios, consider creating data in setup:
class SetupDataTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      name: "Test User",
      email: "test@example.com"
    )

    @feedback = @user.feedbacks.create!(
      content: "Test feedback",
      recipient_email: "recipient@example.com",
      status: "pending"
    )
  end

  test "uses setup data" do
    assert @user.persisted?
    assert @feedback.persisted?
    assert_equal @user, @feedback.sender
  end
end

#
# ============================================================================
# ✅ FIXTURE DATA VERIFICATION
# ============================================================================
#

class FixtureVerificationTest < ActiveSupport::TestCase
  test "all user fixtures are valid" do
    User.find_each do |user|
      assert user.valid?, "#{user.name} fixture is invalid: #{user.errors.full_messages}"
    end
  end

  test "all feedback fixtures have required associations" do
    Feedback.find_each do |feedback|
      assert feedback.sender, "Feedback #{feedback.id} missing sender"
      assert feedback.recipient_email.present?, "Feedback #{feedback.id} missing recipient"
    end
  end
end

#
# ============================================================================
# ✅ ACCESSING FIXTURE DATA
# ============================================================================
#

class AccessingFixturesTest < ActiveSupport::TestCase
  test "various ways to access fixtures" do
    # By name
    alice = users(:alice)

    # Multiple at once
    alice, bob = users(:alice, :bob)

    # Direct ID access (discouraged)
    # user = User.find(users(:alice).id)

    # Get ID without loading record
    alice_id = users(:alice).id
  end

  test "checking fixture properties" do
    alice = users(:alice)

    # Test individual attributes
    assert_equal "Alice Johnson", alice.name
    assert_match /@example\.com$/, alice.email

    # Test associations
    assert alice.feedbacks.any?

    # Test callbacks were triggered
    assert alice.encrypted_password if alice.respond_to?(:encrypted_password)
  end
end

#
# ============================================================================
# RULE: Use fixtures for reference data, setup for complex scenarios
# MINIMAL: Keep fixture data minimal and focused
# NAMING: Use descriptive names (alice, bob) not (one, two)
# ASSOCIATIONS: Reference by name, not hardcoded IDs
# VALIDATION: Ensure all fixtures are valid
# CLEANUP: Remove Active Storage fixtures after test runs
# ============================================================================
#
