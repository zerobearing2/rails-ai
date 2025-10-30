# Examples Index

**Purpose**: Master index of all code examples referenced by agents. Organized by domain for quick lookup.

**Usage**: Agents reference examples using `<example-ref id="category/example_name" />` tags.

---

## Backend Examples (`backend/`)

### Models

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/model_basic` | `model_basic.rb` | Basic model with validations | Validations, associations, basic methods |
| `backend/model_with_scopes` | `model_with_scopes.rb` | Model with query scopes | Common query patterns |
| `backend/model_with_callbacks` | `model_with_callbacks.rb` | Model using callbacks | after_create, before_destroy |
| `backend/model_state_machine` | `model_state_machine.rb` | Status/state management | Enum status, state transitions |

### Concerns (Model & Controller)

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/concern_namespaced_model` | `concern_namespaced_model.rb` | Namespaced model concerns | Feedback::Notifications, Taggable, SoftDeletable, StatusTrackable |
| `backend/concern_namespaced_controller` | `concern_namespaced_controller.rb` | Namespaced controller concerns | Authentication, Api::ResponseHandler, Paginatable, Filterable |

**Key Topics:**
- Model concerns: Notifications, tagging, soft delete, status tracking
- Controller concerns: Authentication, API responses, pagination, filtering
- ActiveSupport::Concern patterns with `included`, `class_methods`
- Testing concerns in isolation
- File organization: `app/models/concerns/feedback/`, `app/controllers/concerns/`

### Controllers

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/controller_restful` | `controller_restful.rb` | RESTful controller | 7 standard actions, strong params |
| `backend/nested_resources_comprehensive` | `nested_resources_comprehensive.rb` | **Nested resources pattern (TEAM_RULES #3 & #5)** | Child controllers, child models, routes, testing, complete project standard |
| `backend/controller_with_rate_limit` | `controller_with_rate_limit.rb` | Controller with rate limiting | Rails 8.1 rate_limit DSL |
| `backend/controller_api` | `controller_api.rb` | JSON API controller | API responses, status codes |

**Key Topics for Nested Resources:**
- Child controllers: `app/controllers/feedbacks/sendings_controller.rb` (module Feedbacks)
- Child models: `app/models/feedbacks/response.rb` (module Feedbacks)
- Routes: `resource :sending, only: [:create], module: :feedbacks`
- PLURAL parent namespace (Feedbacks::, not Feedback::) for both controllers and models
- Directory structure, module namespacing, testing, migrations
- Complete working examples with routes, views, tests, and fixtures
- **Project standard** for all nested resources (TEAM_RULES.md Rule #3 & #5)

### Custom Validators

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/validator_custom` | `validator_custom.rb` | Custom validators | ActiveModel::EachValidator, ActiveModel::Validator, complex validation logic |

**Key Topics:**
- EmailValidator, UrlValidator, PhoneValidator, ProfanityValidator
- Multi-attribute validation with ActiveModel::Validator
- Plain Ruby object validators with instance variables
- Conditional validation logic
- Testing custom validators

### Mailers

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/mailer_basic` | `mailer_basic.rb` | ActionMailer patterns | Email views, attachments, previews, layouts, testing |

**Key Topics:**
- Sending feedback notifications, weekly digests
- HTML + text templates
- Attachments (PDF, CSV)
- Mailer previews for development
- Layouts for consistent email design
- Testing with ActionMailer::TestCase
- Configuration for development/production

### Form Objects

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/form_object` | `form_object.rb` | ActiveModel::API form objects | Contact forms, multi-model forms, search forms, wizard forms, API forms |

**Key Topics:**
- ActiveModel::API for non-database forms
- Multi-step wizard forms with session state
- Search/filter form objects
- Multi-model registration forms with transactions
- API form objects with JSON serialization
- Testing form objects in isolation

### Query Objects

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/query_object` | `query_object.rb` | Query encapsulation patterns | Chainable queries, aggregations, multi-model queries, subqueries |

**Key Topics:**
- Basic chainable query objects
- Advanced filtering with scopes
- Aggregation and stats queries
- Multi-model activity queries
- Join queries with tags
- Subquery patterns for analytics
- Callable query objects with params
- Testing query objects with database

### Services

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/service_basic` | `service_basic.rb` | Basic service object | When to extract to service |
| `backend/service_multi_model` | `service_multi_model.rb` | Complex multi-model operation | Transaction, error handling |

### Background Jobs

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/job_basic` | `job_basic.rb` | Basic SolidQueue job | Job structure, perform method |
| `backend/job_with_retry` | `job_with_retry.rb` | Job with retry logic | Error handling, retries |

### Migrations

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/migration_create_table` | `migration_create_table.rb` | Create new table | Table structure, indexes, constraints |
| `backend/migration_add_column` | `migration_add_column.rb` | Add column safely | Safe column addition |

### Anti-Patterns

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `backend/antipattern_fat_controller` | `antipattern_fat_controller.rb` | ❌ Business logic in controller | What NOT to do |
| `backend/antipattern_n_plus_one` | `antipattern_n_plus_one.rb` | ❌ N+1 query problem | What causes N+1 |

---

## Frontend Examples (`frontend/`)

### Hotwire (Turbo + Stimulus)

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `frontend/hotwire_turbo_comprehensive` | `hotwire_turbo_comprehensive.erb` | Complete Turbo patterns | Turbo Drive, Frames, Streams, Morph, Broadcasts, Events |
| `frontend/hotwire_stimulus_comprehensive` | `hotwire_stimulus_comprehensive.js` | Complete Stimulus patterns | Controllers, Targets, Actions, Values, Classes, Outlets, Lifecycle |

**Key Topics:**
- Turbo Drive: Automatic page acceleration
- Turbo Frames: Scoped updates, lazy loading, nested frames
- Turbo Streams: 7 actions (append, prepend, replace, update, remove, before, after)
- Turbo Broadcasts: Real-time updates with ActionCable
- Turbo Morph: Page refreshes preserving scroll/focus (Rails 8 default)
- Stimulus: Controllers, targets, actions, values, outlets
- Real-world examples: Modal, auto-save, infinite scroll, clipboard, dropdown
- Testing Turbo and Stimulus

### View Helpers

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `frontend/view_helpers_comprehensive` | `view_helpers_comprehensive.rb` | Complete helper patterns | Built-in helpers, custom helpers, module helpers, testing |

**Key Topics:**
- Built-in Rails helpers: text, link, asset, tag, date/time helpers
- Custom application helpers: page title, flash messages, active links, icons
- Module-specific helpers: feedback helpers, status badges, character count
- Helper concerns: date formatting, reusable modules
- Testing helpers with ActionView::TestCase
- Advanced patterns: cacheable, component-style, presenter-style helpers

### Partials & Layouts

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `frontend/partials_layouts_comprehensive` | `partials_layouts_comprehensive.erb` | Complete partial/layout patterns | Partials, layouts, content_for, yield, nested layouts |

**Key Topics:**
- Basic partials: render, locals, collections
- Partials with blocks: yield, multiple content areas
- Application layouts: yield, content_for, custom head/body content
- Nested layouts: admin layout, conditional layouts
- Shared partials: header, footer, flash messages
- Empty state and loading partials
- Collection rendering with fallbacks
- Testing partials with ActionView::TestCase

### Tailwind + DaisyUI

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `frontend/tailwind_daisyui_comprehensive` | `tailwind_daisyui_comprehensive.erb` | Complete styling patterns | Tailwind v4, DaisyUI v5, responsive design, dark mode |

**Key Topics:**
- DaisyUI components: buttons, cards, forms, alerts, badges, modals, navbar, menu, dropdown, loading
- Tailwind v4: @import, @plugin syntax, utility classes
- Responsive design: mobile-first, breakpoints, hide/show
- Dark mode: theme switcher, data-theme attribute
- Layout patterns: sticky header, sidebar, grid layouts
- Common utilities: spacing, flexbox, text, colors, borders, shadows
- Real-world card example with DaisyUI

### Accessibility

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `frontend/accessibility_comprehensive` | `accessibility_comprehensive.erb` | Complete a11y patterns | WCAG 2.1, ARIA, keyboard nav, screen readers |

**Key Topics:**
- Semantic HTML: proper element usage, heading hierarchy
- ARIA labels and roles: aria-label, aria-labelledby, aria-describedby, aria-live
- Keyboard navigation: tabindex, focus management, skip links
- Forms accessibility: labels, error messages, required fields
- Buttons & links: descriptive text, icon buttons
- Images & media: alt text, captions
- Tables: caption, scope, accessible headers
- Modals: focus trap, aria-modal, keyboard escape
- Color & contrast: WCAG AA compliance (4.5:1)
- Screen reader utilities: sr-only, aria-hidden
- Loading & dynamic content: role="status", progressbar
- Accessibility checklist and testing

### Forms & Nested Forms

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `frontend/forms_nested_comprehensive` | `forms_nested_comprehensive.erb` | Complete form patterns | form_with, fields_for, nested attributes, validation |

**Key Topics:**
- Basic forms: form_with model, URL-based, namespaced
- Form input types: text, email, textarea, select, checkboxes, radio, date/time, file upload, range
- Nested forms (has_many): accepts_nested_attributes_for, fields_for, _destroy
- Dynamic nested forms: Add/remove with Stimulus controller
- Nested forms (has_one): building associated records
- Form validation: error display, field-level errors, error helpers
- Custom form builders: DaisyUI form builder
- Multi-step forms: wizard pattern with step tracking
- File uploads: ActiveStorage, direct upload, multiple files
- Testing forms: system tests, integration tests

### ViewComponent

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `frontend/viewcomponent_basic` | `viewcomponent_basic.rb` | Basic ViewComponent patterns | Component structure, initialization, content blocks, helpers, before_render |
| `frontend/viewcomponent_slots` | `viewcomponent_slots.rb` | Comprehensive slot patterns | renders_one, renders_many, polymorphic slots, lambda slots, predicate methods |
| `frontend/viewcomponent_previews_collections` | `viewcomponent_previews_collections.rb` | Previews and collections | ViewComponent::Preview, dynamic params, collection rendering, iteration context |
| `frontend/viewcomponent_style_variants` | `viewcomponent_style_variants.rb` | Style variant management | view_component-contrib, Tailwind variants, compound variants, inheritance |

**Key Topics:**
- **Basic Components**: Component structure, initialization, content blocks
- **Slots**: renders_one (single slot), renders_many (collection slots), polymorphic slots
- **Previews**: Visual development at /rails/view_components, dynamic parameters, custom layouts
- **Collections**: with_collection, counter access, iteration context (first?, last?, index, size)
- **Style Variants**: Declarative Tailwind CSS variant management (optional, requires view_component-contrib)
- **Testing**: ViewComponent::TestCase, render_inline, render_preview, system tests
- **Organization**: Namespacing (Ui::, FeedbackComponents::), sidecar assets
- **Lifecycle**: before_render hook for setup logic
- **Conditional rendering**: #render? method to control component rendering
- **Real-world examples**: Button, Card, Modal, Badge, Feedback components

**Related Test Examples:**
- `tests/viewcomponent_test_comprehensive` - Complete testing patterns

---

## Test Examples (`tests/`)

### Model Tests

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `tests/model_test_basic` | `model_test_basic.rb` | Basic model test | Minitest structure |
| `tests/model_test_validations` | `model_test_validations.rb` | Validation testing | Testing validations |
| `tests/model_test_associations` | `model_test_associations.rb` | Association testing | Testing relationships |

### Controller Tests

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `tests/controller_test_basic` | `controller_test_basic.rb` | Basic controller test | GET, POST, PATCH, DELETE |
| `tests/controller_test_auth` | `controller_test_auth.rb` | Authentication testing | before_action tests |

### Component Tests

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `tests/viewcomponent_test_comprehensive` | `viewcomponent_test_comprehensive.rb` | Comprehensive ViewComponent testing | Unit tests, preview tests, system tests, slots, collections, variants |

**Key Topics:**
- Unit tests: render_inline, assert_selector, assert_text, assert_component_rendered
- Slot testing: Testing renders_one, renders_many, polymorphic slots
- Preview testing: render_preview with parameters
- Conditional rendering: Testing #render? method
- Collections: Testing with_collection rendering
- Variants: Testing Action Pack variants, request formats
- Test helpers: ViewComponent::TestCase
- Fixtures: Using Rails fixtures in component tests
- Custom assertions: Building reusable test helpers

### Minitest Best Practices

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `tests/minitest_best_practices` | `minitest_best_practices.rb` | Comprehensive Minitest patterns | TDD, assertions, setup/teardown, testing models/controllers/jobs/mailers, time travel, parallel testing |

**Key Topics:**
- Basic test structure (test_ prefix, test macro)
- Setup and teardown patterns
- Common assertions (equality, boolean, inclusion, pattern, exception, predicate, instance, empty)
- Rails-specific assertions (assert_difference, validation, query)
- Testing ActiveRecord models (validations, associations, scopes, callbacks)
- Testing with time (travel_to, freeze_time)
- Testing jobs (enqueued, performed, emails)
- Testing mailers (notification emails)
- Testing controllers (GET, POST, DELETE)
- Parallel testing (parallelize)
- Best practices (DO/DON'T lists)

### Fixtures & Test Data

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `tests/fixtures_test_data` | `fixtures_test_data.rb` | Comprehensive fixture patterns | YAML fixtures, ERB, associations, Active Storage, Action Text, polymorphic, verification |

**Key Topics:**
- Basic fixture structure (YAML format)
- Accessing fixtures by name
- Fixtures with associations (belongs_to, has_many)
- ERB in fixtures (dynamic values, SecureRandom, Time)
- Fixture helper methods
- Namespaced model fixtures
- Active Storage fixtures (blobs, attachments)
- Action Text fixtures (rich_texts)
- Polymorphic associations in fixtures
- Loading specific fixtures vs all fixtures
- Disabling fixtures for specific tests
- Best practices (minimal data, descriptive names, no hardcoded IDs)

### Test Setup & Helpers

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `tests/test_setup_helpers` | `test_setup_helpers.rb` | Reusable test helper patterns | Authentication helpers, API helpers, time helpers, assertion helpers, factory helpers, parallel setup |

**Key Topics:**
- Central test configuration (test_helper.rb)
- Authentication helpers (sign_in_as, sign_out, create_and_sign_in_user)
- API helpers (json_response, api_get, api_post, assert_json_response)
- Time travel helpers (at_time, yesterday, next_week, freeze_time)
- Assertion helpers (assert_visible, assert_hidden, assert_flash, assert_validation_error, assert_email_sent_to)
- Factory helpers (create_user, create_feedback, create_admin_user)
- Database helpers (disable_transactions, truncate_tables, count_where)
- File upload helpers (fixture_file, create_test_image, create_test_pdf)
- Request helpers (follow_and_return, post_and_follow, xhr_get, xhr_post)
- Helper inclusion patterns (global, per-class, parent class)
- Parallel test setup (parallelize_setup, parallelize_teardown)
- Test configuration (ActionCable, ActionMailer, Rails logger)

### Mocking & Stubbing

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `tests/mocking_stubbing` | `mocking_stubbing.rb` | Comprehensive mocking patterns | Minitest::Mock, stub method, WebMock for HTTP, stubbing external services, dependency injection |

**Key Topics:**
- Basic stubbing with stub method
- Minitest::Mock (expect, verify)
- Stubbing external dependencies (API clients, services)
- WebMock for HTTP requests (TEAM_RULES.md Rule #18)
- Stubbing Time (prefer travel_to)
- Mocking ActiveRecord (find, scopes, save, associations)
- Mocking mailers (prefer assert_enqueued_with)
- Mocking background jobs (prefer assert_enqueued_jobs)
- Partial stubbing (one method while keeping others real)
- Dependency injection for testability
- Fake objects (test doubles)
- Verifying method calls
- Common pitfalls (forgetting verify, argument mismatch, over-stubbing)
- Best practices (stub external dependencies only, prefer real objects)

---

## Config Examples (`config/`)

### Core Configuration

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `config/solid_stack_setup` | `solid_stack_setup.rb` | Solid Stack configuration (Rule #1) | SolidQueue, SolidCache, SolidCable, 4-database setup |
| `config/initializers_best_practices` | `initializers_best_practices.rb` | Initializer patterns | Gem config, to_prepare, after_initialize, reloadable constants |
| `config/credentials_management` | `credentials_management.rb` | Secrets management | Credentials vs ENV, master.key, per-environment, CI/CD |
| `config/environment_configuration` | `environment_configuration.rb` | Environment-specific config | Development/test/production, feature flags, staging |

**Key Topics:**
- Solid Stack: Complete SolidQueue/SolidCache/SolidCable setup (TEAM_RULES.md Rule #1)
- Initializers: When to use to_prepare, avoiding reloadable constants
- Credentials: Rails encrypted credentials vs ENV vars, master key management
- Environments: Development/test/production configs, feature flags, custom ENV vars

**Related TEAM_RULES:**
- Rule #1: Always use Solid Stack (enforced in config examples)
- All custom config goes in config/initializers/ (never application.rb)

### Deployment

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `config/kamal_deploy` | `kamal_deploy.yml` | Kamal deployment config | Production deployment |

---

## Security Examples (`security/`)

### Input Validation

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `security/strong_parameters` | `strong_parameters.rb` | Proper parameter filtering | Strong params |
| `security/validation_comprehensive` | `validation_comprehensive.rb` | Comprehensive validation | All validation types |

### Authentication/Authorization

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `security/authentication_basic` | `authentication_basic.rb` | Basic authentication | before_action pattern |
| `security/authorization_basic` | `authorization_basic.rb` | Authorization check | Permission checking |

### Anti-Patterns

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `security/antipattern_sql_injection` | `antipattern_sql_injection.rb` | ❌ SQL injection vulnerable code | What NOT to do |
| `security/antipattern_xss` | `antipattern_xss.erb` | ❌ XSS vulnerable template | What NOT to do |

---

## Design Examples (`design/`)

### UX Patterns

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `design/empty_state` | `empty_state.erb` | Empty state design | Helpful empty states |
| `design/loading_state` | `loading_state.erb` | Loading indicators | User feedback |
| `design/error_state` | `error_state.erb` | Error message display | Error handling UX |

### Responsive Design

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `design/responsive_grid` | `responsive_grid.erb` | Mobile-first grid | Tailwind responsive |

---

## Security Examples (`security/`)

### Critical Security Patterns

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `security/sql_injection_prevention` | `sql_injection_prevention.rb` | SQL injection prevention | Safe queries, placeholders, sanitization |
| `security/xss_prevention` | `xss_prevention.rb` | XSS attack prevention | Output escaping, sanitize, CSP |
| `security/strong_parameters` | `strong_parameters.rb` | Mass assignment protection | expect(), permit(), nested params |
| `security/csrf_protection` | `csrf_protection.rb` | CSRF attack prevention | Authenticity tokens, meta tags, SameSite |
| `security/command_injection_prevention` | `command_injection_prevention.rb` | Command injection prevention | system() safety, array args, Shellwords |
| `security/secure_file_uploads` | `secure_file_uploads.rb` | Secure file handling | Filename sanitization, ActiveStorage, validation |

**Key Security Topics:**
- SQL Injection: Positional/named placeholders, hash conditions
- XSS: Auto-escaping, sanitize(), Content Security Policy
- Mass Assignment: Strong parameters (expect/permit)
- CSRF: Authenticity tokens, csrf_meta_tags
- Command Injection: Array arguments, Ruby methods over shell
- File Uploads: Filename sanitization, content-type validation, magic bytes

**Related TEAM_RULES:**
- Rule #18: WebMock (no live HTTP in tests)
- All security validations enforced via RuboCop + Brakeman

---

## Debug Examples (`debug/`)

### Debugging Techniques

| ID | File | Description | Demonstrates |
|----|------|-------------|--------------|
| `debug/console_debugging` | `console_debugging.rb` | Rails console debugging | Debugging in console |
| `debug/log_analysis` | `log_analysis.rb` | Log file analysis | Reading logs |

---

## Usage in Agent Files

**Reference examples using:**

```markdown
<example-ref id="backend/model_basic" />
<antipattern-ref id="backend/antipattern_fat_controller" />
```

**Or inline:**

```markdown
See example: [Basic Model](../examples/backend/model_basic.rb)
```

---

**Note**: Examples are kept separate from agent files to:
1. Reduce agent file size (40% reduction)
2. Make examples reusable across agents
3. Allow examples to be updated without modifying agent prompts
4. Enable quick lookup via this index
