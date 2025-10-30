---
name: forms-nested
domain: frontend
dependencies: [controller-restful]
version: 1.0
rails_version: 8.1+
---

# Nested Forms

Build forms that handle parent-child relationships with `accepts_nested_attributes_for` and `fields_for`, including dynamic field management with Stimulus.

<when-to-use>
- Forms where parent and child records are created/updated together
- Has_many relationships (invoice with line items, post with comments)
- Has_one relationships (user with profile, order with shipping address)
- Dynamic forms where users can add/remove nested records
- Complex forms that need to maintain associations on submit
- Building forms where children are created inline with parent
</when-to-use>

<benefits>
- **Single Transaction** - All records saved together or rolled back
- **Validation** - Parent and child validations happen in one pass
- **UX** - Users complete entire form without navigation
- **Consistency** - Associations guaranteed to be valid
- **Simplicity** - No separate API calls for each record
- **Turbo Compatible** - Works seamlessly with Turbo Drive
</benefits>

<standards>
- Use `accepts_nested_attributes_for` in parent model
- Use `fields_for` helper in views for nested fields
- Include `:id` in strong parameters for existing records
- Use `:_destroy` for marking records for deletion
- Use `reject_if: :all_blank` to ignore empty nested forms
- Build nested records in controller `new` action
- Use Stimulus for dynamic add/remove functionality
- Keep nested forms to one level deep for maintainability
</standards>

## Basic Nested Forms

<pattern name="has-many-nested-form">
<description>Form with has_many relationship using fields_for</description>

**Model Setup:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  has_many :attachments, dependent: :destroy

  # Enable nested attributes
  accepts_nested_attributes_for :attachments,
    allow_destroy: true,        # Allow marking records for deletion
    reject_if: :all_blank       # Ignore empty nested forms

  validates :content, presence: true
  validates :recipient_email, presence: true
end

# app/models/attachment.rb
class Attachment < ApplicationRecord
  belongs_to :feedback

  validates :file, presence: true
  validates :caption, length: { maximum: 200 }
end
```

**Controller Setup:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  def new
    @feedback = Feedback.new
    # Build empty attachments for form
    3.times { @feedback.attachments.build }
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      redirect_to @feedback, notice: "Feedback created with attachments"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @feedback = Feedback.find(params[:id])
    # Ensure at least one empty attachment for adding more
    @feedback.attachments.build if @feedback.attachments.empty?
  end

  def update
    @feedback = Feedback.find(params[:id])

    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: "Feedback updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.expect(feedback: [
      :content,
      :recipient_email,
      attachments_attributes: [
        :id,           # Required for updating existing records
        :file,
        :caption,
        :_destroy      # Required for marking records for deletion
      ]
    ])
  end
end
```

**Form View:**
```erb
<%# app/views/feedbacks/_form.html.erb %>
<%= form_with model: @feedback do |form| %>
  <%# Show validation errors %>
  <% if @feedback.errors.any? %>
    <div class="alert alert-error mb-4">
      <h3 class="font-bold">
        <%= pluralize(@feedback.errors.count, "error") %> prevented this feedback from being saved:
      </h3>
      <ul class="list-disc list-inside">
        <% @feedback.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-control mb-4">
    <%= form.label :content, class: "label" %>
    <%= form.text_area :content,
                       rows: 5,
                       class: "textarea textarea-bordered w-full" %>
  </div>

  <div class="form-control mb-4">
    <%= form.label :recipient_email, class: "label" %>
    <%= form.email_field :recipient_email,
                         class: "input input-bordered w-full" %>
  </div>

  <div class="space-y-4 mb-6">
    <h3 class="text-lg font-semibold">Attachments</h3>

    <%= form.fields_for :attachments do |attachment_form| %>
      <div class="card bg-base-100 border">
        <div class="card-body">
          <div class="form-control mb-2">
            <%= attachment_form.label :file, class: "label" %>
            <%= attachment_form.file_field :file,
                                          class: "file-input file-input-bordered w-full" %>
          </div>

          <div class="form-control mb-2">
            <%= attachment_form.label :caption, class: "label" %>
            <%= attachment_form.text_field :caption,
                                          class: "input input-bordered w-full" %>
          </div>

          <%# Hidden field for existing record ID (required for updates) %>
          <%= attachment_form.hidden_field :id if attachment_form.object.persisted? %>

          <%# Checkbox to mark for deletion %>
          <div class="form-control">
            <%= attachment_form.check_box :_destroy,
                                         class: "checkbox checkbox-error" %>
            <%= attachment_form.label :_destroy,
                                     "Remove this attachment",
                                     class: "label cursor-pointer" %>
          </div>
        </div>
      </div>
    <% end %>
  </div>

  <div class="form-control">
    <%= form.submit class: "btn btn-primary" %>
  </div>
<% end %>
```
</pattern>

<pattern name="has-one-nested-form">
<description>Form with has_one relationship for single nested record</description>

**Model Setup:**
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one :profile, dependent: :destroy

  accepts_nested_attributes_for :profile

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end

# app/models/profile.rb
class Profile < ApplicationRecord
  belongs_to :user

  validates :bio, length: { maximum: 500 }
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
end
```

**Controller:**
```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def new
    @user = User.new
    @user.build_profile  # Build associated profile for form
  end

  def edit
    @user = User.find(params[:id])
    @user.build_profile unless @user.profile  # Create if doesn't exist
  end

  private

  def user_params
    params.expect(user: [
      :name,
      :email,
      profile_attributes: [
        :id,
        :bio,
        :website,
        :twitter_handle,
        :github_username
      ]
    ])
  end
end
```

**Form View:**
```erb
<%= form_with model: @user do |form| %>
  <div class="form-control mb-4">
    <%= form.label :name, class: "label" %>
    <%= form.text_field :name, class: "input input-bordered w-full" %>
  </div>

  <div class="form-control mb-4">
    <%= form.label :email, class: "label" %>
    <%= form.email_field :email, class: "input input-bordered w-full" %>
  </div>

  <div class="divider">Profile Information</div>

  <%= form.fields_for :profile do |profile_form| %>
    <div class="form-control mb-4">
      <%= profile_form.label :bio, class: "label" %>
      <%= profile_form.text_area :bio,
                                 rows: 4,
                                 class: "textarea textarea-bordered w-full" %>
    </div>

    <div class="form-control mb-4">
      <%= profile_form.label :website, class: "label" %>
      <%= profile_form.url_field :website,
                                 placeholder: "https://example.com",
                                 class: "input input-bordered w-full" %>
    </div>

    <div class="form-control mb-4">
      <%= profile_form.label :twitter_handle, class: "label" %>
      <%= profile_form.text_field :twitter_handle,
                                  placeholder: "@username",
                                  class: "input input-bordered w-full" %>
    </div>
  <% end %>

  <%= form.submit class: "btn btn-primary" %>
<% end %>
```
</pattern>

## Dynamic Nested Forms

<pattern name="dynamic-nested-stimulus">
<description>Dynamic add/remove nested fields using Stimulus controller</description>

**Model & Controller (same as has-many example above)**

**Form with Stimulus:**
```erb
<%# app/views/feedbacks/_form.html.erb %>
<div data-controller="nested-form">
  <%= form_with model: @feedback do |form| %>
    <div class="form-control mb-4">
      <%= form.label :content, class: "label" %>
      <%= form.text_area :content,
                         rows: 5,
                         class: "textarea textarea-bordered w-full" %>
    </div>

    <div class="mb-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold">Attachments</h3>
        <button type="button"
                class="btn btn-sm btn-primary"
                data-action="nested-form#add">
          Add Attachment
        </button>
      </div>

      <div data-nested-form-target="container" class="space-y-4">
        <%= form.fields_for :attachments do |attachment_form| %>
          <%= render "attachment_fields", form: attachment_form %>
        <% end %>
      </div>

      <%# Template for new attachments %>
      <template data-nested-form-target="template">
        <%= form.fields_for :attachments,
                           Attachment.new,
                           child_index: "NEW_RECORD" do |attachment_form| %>
          <%= render "attachment_fields", form: attachment_form %>
        <% end %>
      </template>
    </div>

    <%= form.submit class: "btn btn-primary" %>
  <% end %>
</div>
```

**Nested Fields Partial:**
```erb
<%# app/views/feedbacks/_attachment_fields.html.erb %>
<div class="card bg-base-100 border nested-fields"
     data-nested-form-target="field">
  <div class="card-body">
    <div class="form-control mb-2">
      <%= form.label :file, class: "label" %>
      <%= form.file_field :file,
                         class: "file-input file-input-bordered w-full" %>
    </div>

    <div class="form-control mb-2">
      <%= form.label :caption, class: "label" %>
      <%= form.text_field :caption,
                         class: "input input-bordered w-full" %>
    </div>

    <%# Hidden fields %>
    <%= form.hidden_field :id if form.object.persisted? %>
    <%= form.hidden_field :_destroy %>

    <button type="button"
            class="btn btn-sm btn-error"
            data-action="nested-form#remove">
      Remove Attachment
    </button>
  </div>
</div>
```

**Stimulus Controller:**
```javascript
// app/javascript/controllers/nested_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "field"]

  add(event) {
    event.preventDefault()

    // Get template content and replace NEW_RECORD with unique timestamp
    const content = this.templateTarget.innerHTML
      .replace(/NEW_RECORD/g, new Date().getTime())

    // Insert new fields at the end of container
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()

    const field = event.target.closest(".nested-fields")
    const destroyInput = field.querySelector("input[name*='_destroy']")

    if (destroyInput) {
      const idInput = field.querySelector("input[name*='[id]']")

      if (idInput && idInput.value) {
        // Existing record: mark for deletion but keep in DOM (hidden)
        destroyInput.value = "1"
        field.style.display = "none"
      } else {
        // New record (not yet saved): remove from DOM entirely
        field.remove()
      }
    } else {
      // No destroy input: just remove from DOM
      field.remove()
    }
  }
}
```
</pattern>

<pattern name="nested-validation-errors">
<description>Display validation errors for nested attributes</description>

**Enhanced Form with Error Display:**
```erb
<%= form_with model: @feedback do |form| %>
  <%# Parent model errors %>
  <% if @feedback.errors.any? %>
    <div class="alert alert-error mb-4">
      <h3 class="font-bold">
        <%= pluralize(@feedback.errors.count, "error") %> prevented this feedback from being saved:
      </h3>
      <ul class="list-disc list-inside">
        <% @feedback.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-control mb-4">
    <%= form.label :content, class: "label" %>
    <%= form.text_area :content,
                       class: ["textarea textarea-bordered w-full",
                               ("input-error" if @feedback.errors[:content].any?)] %>
    <% if @feedback.errors[:content].any? %>
      <label class="label">
        <span class="label-text-alt text-error">
          <%= @feedback.errors[:content].first %>
        </span>
      </label>
    <% end %>
  </div>

  <div class="mb-6">
    <h3 class="text-lg font-semibold mb-4">Attachments</h3>

    <%= form.fields_for :attachments do |attachment_form| %>
      <div class="card bg-base-100 border mb-4">
        <div class="card-body">
          <%# Show nested model errors %>
          <% if attachment_form.object.errors.any? %>
            <div class="alert alert-warning mb-2">
              <span class="text-sm">
                Attachment <%= attachment_form.index + 1 %> has errors:
                <%= attachment_form.object.errors.full_messages.join(", ") %>
              </span>
            </div>
          <% end %>

          <div class="form-control mb-2">
            <%= attachment_form.label :file, class: "label" %>
            <%= attachment_form.file_field :file,
                                          class: ["file-input file-input-bordered w-full",
                                                  ("input-error" if attachment_form.object.errors[:file].any?)] %>
            <% if attachment_form.object.errors[:file].any? %>
              <label class="label">
                <span class="label-text-alt text-error">
                  <%= attachment_form.object.errors[:file].first %>
                </span>
              </label>
            <% end %>
          </div>

          <div class="form-control">
            <%= attachment_form.label :caption, class: "label" %>
            <%= attachment_form.text_field :caption,
                                          class: "input input-bordered w-full" %>
          </div>
        </div>
      </div>
    <% end %>
  </div>

  <%= form.submit class: "btn btn-primary" %>
<% end %>
```
</pattern>

<pattern name="nested-with-custom-validation">
<description>Custom validation logic for nested attributes</description>

**Model with Custom Validation:**
```ruby
# app/models/invoice.rb
class Invoice < ApplicationRecord
  has_many :line_items, dependent: :destroy

  accepts_nested_attributes_for :line_items,
    allow_destroy: true,
    reject_if: :all_blank

  validates :customer_name, presence: true
  validates :line_items, presence: { message: "must have at least one item" }
  validate :validate_total_amount

  private

  def validate_total_amount
    total = line_items.reject(&:marked_for_destruction?).sum(&:total)

    if total <= 0
      errors.add(:base, "Invoice must have a total greater than $0")
    end

    if total > 100_000
      errors.add(:base, "Invoice total cannot exceed $100,000")
    end
  end
end

# app/models/line_item.rb
class LineItem < ApplicationRecord
  belongs_to :invoice

  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def total
    (quantity || 0) * (unit_price || 0)
  end
end
```

**Form:**
```erb
<%= form_with model: @invoice do |form| %>
  <div class="form-control mb-4">
    <%= form.label :customer_name, class: "label" %>
    <%= form.text_field :customer_name, class: "input input-bordered w-full" %>
  </div>

  <div class="mb-6">
    <h3 class="text-lg font-semibold mb-4">Line Items</h3>

    <%= form.fields_for :line_items do |item_form| %>
      <div class="card bg-base-100 border mb-4">
        <div class="card-body">
          <div class="grid grid-cols-3 gap-4">
            <div class="col-span-3">
              <%= item_form.label :description, class: "label" %>
              <%= item_form.text_field :description,
                                      class: "input input-bordered w-full" %>
            </div>

            <div>
              <%= item_form.label :quantity, class: "label" %>
              <%= item_form.number_field :quantity,
                                        min: 1,
                                        class: "input input-bordered w-full" %>
            </div>

            <div>
              <%= item_form.label :unit_price, class: "label" %>
              <%= item_form.number_field :unit_price,
                                        step: 0.01,
                                        min: 0,
                                        class: "input input-bordered w-full" %>
            </div>

            <div class="flex items-end">
              <%= item_form.check_box :_destroy, class: "checkbox checkbox-error" %>
              <%= item_form.label :_destroy, "Remove", class: "label cursor-pointer" %>
            </div>
          </div>
        </div>
      </div>
    <% end %>
  </div>

  <%= form.submit class: "btn btn-primary" %>
<% end %>
```
</pattern>

<pattern name="nested-conditional-fields">
<description>Conditionally show/hide nested fields based on parent value</description>

**Model:**
```ruby
# app/models/order.rb
class Order < ApplicationRecord
  has_one :shipping_address, dependent: :destroy
  has_one :billing_address, dependent: :destroy

  accepts_nested_attributes_for :shipping_address
  accepts_nested_attributes_for :billing_address

  validates :order_type, inclusion: { in: %w[pickup delivery] }
end
```

**Form with Conditional Fields:**
```erb
<%= form_with model: @order, data: { controller: "order-form" } do |form| %>
  <div class="form-control mb-4">
    <%= form.label :order_type, class: "label" %>
    <%= form.select :order_type,
                    [["Pickup", "pickup"], ["Delivery", "delivery"]],
                    {},
                    class: "select select-bordered",
                    data: { action: "order-form#toggleShipping" } %>
  </div>

  <%# Billing address always shown %>
  <div class="mb-6">
    <h3 class="text-lg font-semibold mb-4">Billing Address</h3>
    <%= form.fields_for :billing_address do |address_form| %>
      <%= render "address_fields", form: address_form %>
    <% end %>
  </div>

  <%# Shipping address only for delivery %>
  <div data-order-form-target="shippingSection"
       class="mb-6"
       style="<%= 'display: none;' if @order.order_type == 'pickup' %>">
    <h3 class="text-lg font-semibold mb-4">Shipping Address</h3>
    <%= form.fields_for :shipping_address do |address_form| %>
      <%= render "address_fields", form: address_form %>
    <% end %>
  </div>

  <%= form.submit class: "btn btn-primary" %>
<% end %>
```

**Stimulus Controller:**
```javascript
// app/javascript/controllers/order_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["shippingSection"]

  toggleShipping(event) {
    const orderType = event.target.value

    if (orderType === "delivery") {
      this.shippingSectionTarget.style.display = "block"
    } else {
      this.shippingSectionTarget.style.display = "none"
    }
  }
}
```
</pattern>

<antipatterns>
<antipattern>
<description>Not including :id in strong parameters for updates</description>
<reason>Rails can't identify which existing records to update, creates duplicates</reason>
<bad-example>
```ruby
# ❌ BAD - Missing :id in nested params
def feedback_params
  params.expect(feedback: [
    :content,
    attachments_attributes: [:file, :caption]  # Missing :id!
  ])
end

# Result: Every update creates new attachment records instead of updating existing ones
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Include :id for existing records
def feedback_params
  params.expect(feedback: [
    :content,
    attachments_attributes: [
      :id,        # Required to update existing records
      :file,
      :caption,
      :_destroy   # Required to delete records
    ]
  ])
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not building nested records in new/edit actions</description>
<reason>fields_for won't render if no records exist, form appears broken</reason>
<bad-example>
```ruby
# ❌ BAD - No nested records built
def new
  @feedback = Feedback.new
  # No attachments built - fields_for won't render!
end

def edit
  @feedback = Feedback.find(params[:id])
  # No way to add new attachments on edit
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Build nested records for form display
def new
  @feedback = Feedback.new
  3.times { @feedback.attachments.build }  # Build empty records
end

def edit
  @feedback = Feedback.find(params[:id])
  @feedback.attachments.build  # Allow adding new attachments
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not using reject_if for optional nested forms</description>
<reason>Creates invalid empty records when users don't fill nested fields</reason>
<bad-example>
```ruby
# ❌ BAD - No reject_if, creates empty records
class Feedback < ApplicationRecord
  has_many :attachments
  accepts_nested_attributes_for :attachments  # No reject_if!
end

# If user doesn't fill attachment fields, creates Attachment with all nil values
# Causes validation errors if fields are required
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Use reject_if to ignore blank nested forms
class Feedback < ApplicationRecord
  has_many :attachments
  accepts_nested_attributes_for :attachments,
    reject_if: :all_blank  # Ignores if all fields are blank
end

# Alternative: Custom rejection logic
class Feedback < ApplicationRecord
  has_many :attachments
  accepts_nested_attributes_for :attachments,
    reject_if: ->(attrs) { attrs[:file].blank? }  # Only reject if file is blank
end
```
</good-example>
</antipattern>

<antipattern>
<description>Using remove() for existing persisted records</description>
<reason>Deletes from DOM but doesn't mark for database deletion</reason>
<bad-example>
```javascript
// ❌ BAD - Removes DOM element without marking for deletion
remove(event) {
  event.preventDefault()
  const field = event.target.closest(".nested-fields")
  field.remove()  // Just removes from DOM!
  // Record still exists in database and won't be deleted
}
```
</bad-example>
<good-example>
```javascript
// ✅ GOOD - Mark persisted records for deletion
remove(event) {
  event.preventDefault()
  const field = event.target.closest(".nested-fields")
  const destroyInput = field.querySelector("input[name*='_destroy']")

  if (destroyInput) {
    const idInput = field.querySelector("input[name*='[id]']")

    if (idInput && idInput.value) {
      // Existing record: mark for deletion
      destroyInput.value = "1"
      field.style.display = "none"
    } else {
      // New record: safe to remove
      field.remove()
    }
  }
}
```
</good-example>
</antipattern>

<antipattern>
<description>Not allowing destroy in accepts_nested_attributes_for</description>
<reason>Users cannot remove nested records, even if _destroy is in params</reason>
<bad-example>
```ruby
# ❌ BAD - allow_destroy not set
class Feedback < ApplicationRecord
  has_many :attachments
  accepts_nested_attributes_for :attachments
  # Missing: allow_destroy: true
end

# Controller has :_destroy in strong params
def feedback_params
  params.expect(feedback: [
    attachments_attributes: [:id, :_destroy]  # Will be ignored!
  ])
end
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Enable destroy functionality
class Feedback < ApplicationRecord
  has_many :attachments
  accepts_nested_attributes_for :attachments,
    allow_destroy: true  # Enable deletion via _destroy param
end

def feedback_params
  params.expect(feedback: [
    attachments_attributes: [:id, :_destroy]  # Now works!
  ])
end
```
</good-example>
</antipattern>

<antipattern>
<description>Deep nesting (nested forms within nested forms)</description>
<reason>Complex to maintain, confusing UX, difficult to validate</reason>
<bad-example>
```ruby
# ❌ BAD - Too deeply nested
class Order < ApplicationRecord
  has_many :line_items
  accepts_nested_attributes_for :line_items
end

class LineItem < ApplicationRecord
  belongs_to :order
  has_many :customizations
  accepts_nested_attributes_for :customizations  # Nested in nested!
end

# Form becomes extremely complex and error-prone
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Keep nesting shallow, use separate forms
class Order < ApplicationRecord
  has_many :line_items
  accepts_nested_attributes_for :line_items
end

class LineItem < ApplicationRecord
  belongs_to :order
  has_many :customizations
  # Don't use nested attributes here
end

# Create customizations in a separate form/step after line item is saved
# Or use Turbo Frames to load customization form dynamically
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test nested forms with system tests and controller tests:

```ruby
# test/system/nested_forms_test.rb
require "application_system_test_case"

class NestedFormsTest < ApplicationSystemTestCase
  test "creates feedback with attachments" do
    visit new_feedback_path

    fill_in "Content", with: "Test feedback"
    fill_in "Recipient email", with: "recipient@example.com"

    # Fill first attachment
    within all(".nested-fields").first do
      attach_file "File", Rails.root.join("test/fixtures/files/document.pdf")
      fill_in "Caption", with: "Important document"
    end

    click_button "Create Feedback"

    assert_text "Feedback was successfully created"
    assert_equal 1, Feedback.last.attachments.count
    assert_equal "Important document", Feedback.last.attachments.first.caption
  end

  test "updates feedback and removes attachment" do
    feedback = feedbacks(:one)
    attachment = feedback.attachments.create!(
      file: fixture_file_upload("document.pdf"),
      caption: "Old doc"
    )

    visit edit_feedback_path(feedback)

    within all(".nested-fields").first do
      check "Remove this attachment"
    end

    click_button "Update Feedback"

    assert_text "Feedback was successfully updated"
    assert_equal 0, feedback.reload.attachments.count
  end

  test "dynamically adds attachment field" do
    visit new_feedback_path

    initial_count = all(".nested-fields").count

    click_button "Add Attachment"

    assert_equal initial_count + 1, all(".nested-fields").count
  end

  test "dynamically removes new attachment field" do
    visit new_feedback_path

    click_button "Add Attachment"
    initial_count = all(".nested-fields").count

    within all(".nested-fields").last do
      click_button "Remove Attachment"
    end

    assert_equal initial_count - 1, all(".nested-fields").count
  end
end

# test/controllers/feedbacks_controller_test.rb
require "test_helper"

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "creates feedback with nested attachments" do
    assert_difference ["Feedback.count", "Attachment.count"], 1 do
      post feedbacks_path, params: {
        feedback: {
          content: "Test feedback",
          recipient_email: "test@example.com",
          attachments_attributes: {
            "0" => {
              file: fixture_file_upload("document.pdf"),
              caption: "Test attachment"
            }
          }
        }
      }
    end

    assert_redirected_to feedback_path(Feedback.last)
  end

  test "updates feedback and destroys attachment" do
    feedback = feedbacks(:one)
    attachment = feedback.attachments.create!(
      file: fixture_file_upload("document.pdf"),
      caption: "Old"
    )

    assert_difference "Attachment.count", -1 do
      patch feedback_path(feedback), params: {
        feedback: {
          content: "Updated",
          attachments_attributes: {
            "0" => {
              id: attachment.id,
              _destroy: "1"
            }
          }
        }
      }
    end
  end

  test "rejects blank nested attributes" do
    assert_no_difference "Attachment.count" do
      post feedbacks_path, params: {
        feedback: {
          content: "Test",
          recipient_email: "test@example.com",
          attachments_attributes: {
            "0" => { file: nil, caption: "" }  # All blank - should be rejected
          }
        }
      }
    end
  end

  test "shows validation errors for invalid nested attributes" do
    post feedbacks_path, params: {
      feedback: {
        content: "Test",
        recipient_email: "test@example.com",
        attachments_attributes: {
          "0" => { file: nil, caption: "Caption without file" }
        }
      }
    }

    assert_response :unprocessable_entity
    assert_select ".alert-error"
  end
end

# test/models/feedback_test.rb
require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "accepts nested attributes for attachments" do
    feedback = Feedback.new(
      content: "Test",
      recipient_email: "test@example.com",
      attachments_attributes: [
        { file: fixture_file_upload("doc1.pdf"), caption: "Doc 1" },
        { file: fixture_file_upload("doc2.pdf"), caption: "Doc 2" }
      ]
    )

    assert feedback.save
    assert_equal 2, feedback.attachments.count
  end

  test "destroys attachments when _destroy is true" do
    feedback = feedbacks(:one)
    attachment = feedback.attachments.create!(
      file: fixture_file_upload("doc.pdf"),
      caption: "Test"
    )

    feedback.update(
      attachments_attributes: [
        { id: attachment.id, _destroy: "1" }
      ]
    )

    assert_equal 0, feedback.reload.attachments.count
  end

  test "rejects blank nested attributes" do
    feedback = Feedback.new(
      content: "Test",
      recipient_email: "test@example.com",
      attachments_attributes: [
        { file: nil, caption: "" }  # All blank
      ]
    )

    assert feedback.save
    assert_equal 0, feedback.attachments.count  # Rejected
  end
end
```
</testing>

<related-skills>
- controller-restful - Base RESTful controller patterns
- hotwire-stimulus - JavaScript framework for dynamic behavior
- hotwire-turbo - Turbo Frames for inline nested resource editing
- viewcomponent-basics - Component-based form field rendering
- activerecord-patterns - Association and validation patterns
</related-skills>

<resources>
- [Rails Guides - Nested Forms](https://guides.rubyonrails.org/form_helpers.html#nested-forms)
- [Rails API - accepts_nested_attributes_for](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Rails Guides - Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
</resources>
