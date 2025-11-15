---
name: rails-ai:forms-nested
description: Build forms that handle parent-child relationships with accepts_nested_attributes_for and fields_for, including dynamic field management with Stimulus.
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

## Dynamic Nested Forms

<pattern name="dynamic-nested-turbo">
<description>Dynamic add/remove nested fields using Stimulus</description>

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
```
</bad-example>
<good-example>
```ruby
# ✅ GOOD - Build nested records for form display
def new
  @feedback = Feedback.new
  3.times { @feedback.attachments.build }  # Build empty records
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

  test "dynamically adds attachment field" do
    visit new_feedback_path
    initial_count = all(".nested-fields").count

    click_button "Add Attachment"

    assert_equal initial_count + 1, all(".nested-fields").count
  end
end
```
</testing>

<related-skills>
- rails-ai:hotwire-stimulus: JavaScript framework for dynamic behavior
- rails-ai:hotwire-turbo: Turbo Frames for inline nested resource editing
</related-skills>

<resources>
- [Rails Guides - Nested Forms](https://guides.rubyonrails.org/form_helpers.html#nested-forms)
- [Rails API - accepts_nested_attributes_for](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
</resources>
