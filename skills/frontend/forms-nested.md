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

**Model:**
```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments,
    allow_destroy: true,
    reject_if: :all_blank

  validates :content, presence: true
end

# app/models/attachment.rb
class Attachment < ApplicationRecord
  belongs_to :feedback
  validates :file, presence: true
end
```

**Controller:**
```ruby
# app/controllers/feedbacks_controller.rb
class FeedbacksController < ApplicationController
  def new
    @feedback = Feedback.new
    # Build empty attachments for form display
    3.times { @feedback.attachments.build }
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      redirect_to @feedback, notice: "Feedback created"
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

**View:**
```erb
<%= form_with model: @feedback do |form| %>
  <%# Display parent validation errors %>
  <% if @feedback.errors.any? %>
    <div class="alert alert-error">
      <h3><%= pluralize(@feedback.errors.count, "error") %></h3>
      <ul>
        <% @feedback.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-control">
    <%= form.label :content %>
    <%= form.text_area :content, class: "textarea" %>
  </div>

  <div class="space-y-4">
    <h3>Attachments</h3>
    <%= form.fields_for :attachments do |f| %>
      <div class="nested-fields card">
        <%= f.file_field :file, class: "file-input" %>
        <%= f.text_field :caption, class: "input" %>

        <%# Required hidden fields %>
        <%= f.hidden_field :id if f.object.persisted? %>
        <%= f.check_box :_destroy, class: "checkbox" %>
        <%= f.label :_destroy, "Remove" %>
      </div>
    <% end %>
  </div>

  <%= form.submit class: "btn" %>
<% end %>
```
</pattern>

<pattern name="has-one-nested-form">
<description>Form with has_one relationship</description>

**Model:**
```ruby
class User < ApplicationRecord
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile
end
```

**Controller:**
```ruby
def new
  @user = User.new
  @user.build_profile
end

def user_params
  params.expect(user: [:name, :email, profile_attributes: [:id, :bio, :website]])
end
```

**View:**
```erb
<%= form_with model: @user do |form| %>
  <div class="form-control">
    <%= form.label :name %>
    <%= form.text_field :name, class: "input" %>
  </div>

  <div class="form-control">
    <%= form.label :email %>
    <%= form.email_field :email, class: "input" %>
  </div>

  <div class="divider">Profile Information</div>

  <%= form.fields_for :profile do |pf| %>
    <div class="form-control">
      <%= pf.label :bio %>
      <%= pf.text_area :bio, rows: 4, class: "textarea" %>
    </div>

    <div class="form-control">
      <%= pf.label :website %>
      <%= pf.url_field :website, placeholder: "https://example.com", class: "input" %>
    </div>

    <div class="form-control">
      <%= pf.label :twitter_handle %>
      <%= pf.text_field :twitter_handle, placeholder: "@username", class: "input" %>
    </div>
  <% end %>

  <%= form.submit class: "btn btn-primary" %>
<% end %>
```
</pattern>

## Dynamic Nested Forms

<pattern name="dynamic-nested-turbo">
<description>Dynamic add/remove nested fields using Turbo Frames</description>

**Form:**
```erb
<%# app/views/feedbacks/_form.html.erb %>
<div data-controller="nested-form">
  <%= form_with model: @feedback do |form| %>
    <div class="form-control mb-4">
      <%= form.label :content %>
      <%= form.text_area :content, rows: 5, class: "textarea" %>
    </div>

    <div class="mb-6">
      <div class="flex justify-between mb-4">
        <h3 class="font-semibold">Attachments</h3>
        <button type="button"
                class="btn btn-sm"
                data-action="nested-form#add">
          Add Attachment
        </button>
      </div>

      <div data-nested-form-target="container" class="space-y-4">
        <%= form.fields_for :attachments do |f| %>
          <%= render "attachment_fields", form: f %>
        <% end %>
      </div>

      <%# Template for new attachments %>
      <template data-nested-form-target="template">
        <%= form.fields_for :attachments, Attachment.new, child_index: "NEW_RECORD" do |f| %>
          <%= render "attachment_fields", form: f %>
        <% end %>
      </template>
    </div>

    <%= form.submit class: "btn btn-primary" %>
  <% end %>
</div>
```

**Partial:**
```erb
<%# app/views/feedbacks/_attachment_fields.html.erb %>
<div class="card border nested-fields" data-nested-form-target="field">
  <div class="card-body">
    <div class="form-control mb-2">
      <%= form.label :file %>
      <%= form.file_field :file, class: "file-input" %>
    </div>

    <div class="form-control mb-2">
      <%= form.label :caption %>
      <%= form.text_field :caption, class: "input" %>
    </div>

    <%# Hidden fields for Rails %>
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

**Stimulus:**
```javascript
// app/javascript/controllers/nested_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "field"]

  add(event) {
    event.preventDefault()

    // Get template HTML and replace NEW_RECORD with unique timestamp
    const content = this.templateTarget.innerHTML
      .replace(/NEW_RECORD/g, new Date().getTime())

    // Insert new fields at end of container
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()

    const field = event.target.closest(".nested-fields")
    const destroyInput = field.querySelector("input[name*='_destroy']")

    if (destroyInput) {
      const idInput = field.querySelector("input[name*='[id]']")

      if (idInput && idInput.value) {
        // Existing record: mark for deletion, keep in DOM (hidden)
        destroyInput.value = "1"
        field.style.display = "none"
      } else {
        // New record: remove from DOM entirely
        field.remove()
      }
    } else {
      field.remove()
    }
  }
}
```
</pattern>

<pattern name="nested-validation">
<description>Validation errors for nested attributes</description>

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

**View with Error Display:**
```erb
<%= form_with model: @invoice do |form| %>
  <%# Parent model errors %>
  <% if @invoice.errors.any? %>
    <div class="alert alert-error mb-4">
      <h3><%= pluralize(@invoice.errors.count, "error") %> prevented saving:</h3>
      <ul>
        <% @invoice.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-control mb-4">
    <%= form.label :customer_name %>
    <%= form.text_field :customer_name, class: "input" %>
  </div>

  <div class="mb-6">
    <h3>Line Items</h3>

    <%= form.fields_for :line_items do |f| %>
      <div class="card border mb-4">
        <%# Show nested model errors %>
        <% if f.object.errors.any? %>
          <div class="alert alert-warning">
            Item errors: <%= f.object.errors.full_messages.join(", ") %>
          </div>
        <% end %>

        <div class="grid grid-cols-3 gap-4">
          <div class="col-span-3">
            <%= f.label :description %>
            <%= f.text_field :description, class: "input" %>
          </div>

          <div>
            <%= f.label :quantity %>
            <%= f.number_field :quantity, min: 1, class: "input" %>
          </div>

          <div>
            <%= f.label :unit_price %>
            <%= f.number_field :unit_price, step: 0.01, min: 0, class: "input" %>
          </div>

          <div>
            <%= f.check_box :_destroy %>
            <%= f.label :_destroy, "Remove" %>
          </div>
        </div>
      </div>
    <% end %>
  </div>

  <%= form.submit class: "btn btn-primary" %>
<% end %>
```
</pattern>

<antipatterns>
<antipattern>
<description>Missing :id in strong parameters for updates</description>
<reason>Rails can't identify which existing records to update, creates duplicates instead</reason>
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
<description>Using remove() for existing persisted records in JavaScript</description>
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
</antipatterns>

<testing>
```ruby
# test/system/nested_forms_test.rb
require "application_system_test_case"

class NestedFormsTest < ApplicationSystemTestCase
  test "creates feedback with attachments" do
    visit new_feedback_path

    fill_in "Content", with: "Test feedback"
    within all(".nested-fields").first do
      attach_file "File", Rails.root.join("test/fixtures/files/document.pdf")
      fill_in "Caption", with: "Important document"
    end

    click_button "Create Feedback"

    assert_text "Feedback was successfully created"
    assert_equal 1, Feedback.last.attachments.count
  end

  test "updates and removes attachment" do
    feedback = feedbacks(:one)
    attachment = feedback.attachments.create!(
      file: fixture_file_upload("document.pdf"),
      caption: "Old doc"
    )

    visit edit_feedback_path(feedback)
    check "Remove"
    click_button "Update Feedback"

    assert_equal 0, feedback.reload.attachments.count
  end

  test "dynamically adds attachment field" do
    visit new_feedback_path
    initial_count = all(".nested-fields").count

    click_button "Add Attachment"

    assert_equal initial_count + 1, all(".nested-fields").count
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

  test "destroys attachment via nested attributes" do
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
            "0" => { id: attachment.id, _destroy: "1" }
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
          attachments_attributes: {
            "0" => { file: nil, caption: "" }  # All blank
          }
        }
      }
    end
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
