---
name: TEAM_RULES
description: Engineering standards and best practices for Rails development (37signals-inspired)
version: 2.0
last_updated: 2025-10-29

# Machine-readable metadata for LLM optimization
type: enforcement_rules
priority: critical
scope: all_agents

# Rule categories
categories:
  - stack_architecture
  - testing
  - routing
  - code_quality
  - workflow
  - performance

# Violation detection triggers (for instant rule checking)
violation_keywords:
  rule_1: [sidekiq, redis, memcached, resque]
  rule_2: [rspec, describe, context, let, subject]
  rule_3: [member, collection, custom action]
  rule_4: [skip tests, tests later, no tests]
  rule_9: [service object, validator service, complex abstraction]
  rule_14: [premature optimization, just in case]
  rule_18: [live http, external request in test, disable webmock]

# Quick enforcement lookup
enforcement:
  automatic: [bin/ci, rubocop, brakeman, bundler-audit, webmock]
  manual: [architect_review, peer_review]
  severity:
    critical: [rule_1, rule_2, rule_3, rule_4, rule_17, rule_18]
    high: [rule_6, rule_11, rule_15]
    moderate: [rule_7, rule_8, rule_9, rule_10, rule_12, rule_13, rule_14, rule_16]
---

# TEAM_RULES.md - Engineering Standards

**Project:** The Feedback Agent
**Philosophy:** 37signals-inspired Rails development - Simple, pragmatic, conventional
**Last Updated:** 2025-10-29

---

<quick-lookup id="rule-index">

## Quick Rule Lookup (Machine-Readable)

```yaml
rule_index:
  1:
    name: "Solid Stack Only"
    severity: critical
    triggers: [sidekiq, redis, memcached]
    action: REJECT
    redirect: Use SolidQueue/SolidCache/SolidCable

  2:
    name: "Minitest Only"
    severity: critical
    triggers: [rspec, describe, context]
    action: REJECT
    redirect: Use Minitest only

  3:
    name: "REST Routes Only"
    severity: critical
    triggers: [member, collection, custom action]
    action: REJECT
    redirect: Create child controller

  4:
    name: "TDD Always"
    severity: critical
    triggers: [skip tests, tests later, no tests]
    action: REJECT
    redirect: Write tests FIRST

  17:
    name: "bin/ci Must Pass"
    severity: critical
    triggers: [skip ci, fix later, ignore warnings]
    action: REJECT
    redirect: Fix CI failures immediately

  18:
    name: "WebMock: No Live HTTP in Tests"
    severity: critical
    triggers: [live http, external request, disable webmock]
    action: REJECT
    redirect: Stub external HTTP requests with WebMock
```

</quick-lookup>

---

## Core Principles

1. **Convention over Configuration** - Follow Rails conventions religiously
2. **Simplicity over Cleverness** - Obvious code beats clever code
3. **Delete code, don't add it** - Best code is no code
4. **Reduce complexity always** - Simpler is better, every time
5. **Ship working software** - Done is better than perfect

---

## The Rules

<rule id="1" priority="critical" category="stack_architecture">

### 1. Use the Solid Stack (Rails 8 Defaults)

<violation-triggers>
Keywords: sidekiq, redis, memcached, resque, delayed_job
Patterns: `gem "sidekiq"`, `Redis.new`, `Dalli::Client`
</violation-triggers>

✅ **DO:**
- SolidQueue for background jobs
- SolidCache for caching
- SolidCable for ActionCable

❌ **DON'T:**
- ❌ Sidekiq (use SolidQueue)
- ❌ Redis (use Solid Stack)
- ❌ Memcached (use SolidCache)

<enforcement action="REJECT" severity="critical">
**Action:** Immediately reject request
**Response:** "We use Rails 8 Solid Stack per TEAM_RULES.md Rule #1"
**Redirect:** "SolidQueue/SolidCache/SolidCable already configured"
</enforcement>

**Why:** Rails 8 provides excellent defaults. Don't add complexity unless absolutely necessary.

</rule>

---

<rule id="2" priority="critical" category="testing">

### 2. Minitest Only

<violation-triggers>
Keywords: rspec, describe, context, let, subject, before, it
Patterns: `gem "rspec-rails"`, `RSpec.describe`, `context "when"`
</violation-triggers>

✅ **DO:**
- Write tests with Minitest
- Use standard assertions (`assert`, `assert_equal`, etc.)
- Follow Rails testing conventions

❌ **DON'T:**
- ❌ RSpec (never)
- ❌ Custom test frameworks
- ❌ Over-complicated test DSLs

<enforcement action="REJECT" severity="critical">
**Action:** Immediately reject request
**Response:** "We use Minitest only per TEAM_RULES.md Rule #2"
**Redirect:** "Delegating to @rails-tests to help with Minitest"
</enforcement>

**Why:** Minitest is simple, fast, and part of Ruby stdlib. RSpec adds unnecessary complexity.

</rule>

---

<rule id="3" priority="critical" category="routing">

### 3. RESTful Routes Only

<violation-triggers>
Keywords: member, collection, custom action
Patterns: `member do`, `collection do`, `post :publish`, `get :archive`
</violation-triggers>

✅ **DO:**
```ruby
# Good: Standard REST actions
resources :feedbacks, only: [:index, :show, :new, :create, :edit, :update, :destroy]

# Good: Nested resources for additional actions (child controllers)
resources :feedbacks do
  resource :sending, only: [:create], module: :feedbacks      # POST /feedbacks/:id/sending
  resource :retry, only: [:create], module: :feedbacks        # POST /feedbacks/:id/retry
  resource :publication, only: [:create, :destroy], module: :feedbacks
end

# IMPORTANT: Use `module: :feedbacks` to tell Rails where to find the controller
# This maps the route to the correct module namespace:
#   Route: feedbacks/sendings#create  →  Controller: Feedbacks::SendingsController

# Controllers are nested in subdirectories with module namespacing:
# app/controllers/feedbacks/sendings_controller.rb  → module Feedbacks; class SendingsController
# app/controllers/feedbacks/retries_controller.rb   → module Feedbacks; class RetriesController
# app/controllers/feedbacks/publications_controller.rb → module Feedbacks; class PublicationsController

# Tests follow the same structure:
# test/controllers/feedbacks/sendings_controller_test.rb → module Feedbacks; class SendingsControllerTest
```

❌ **DON'T:**
```ruby
# Bad: Custom actions
resources :feedbacks do
  member do
    post :publish
    post :archive
  end
end

# Bad: Flat controller structure without proper namespacing
# app/controllers/feedback_sendings_controller.rb  → class FeedbackSendingsController
```

<enforcement action="REJECT" severity="critical">
**Action:** Immediately reject request
**Response:** "We use RESTful resources only per TEAM_RULES.md Rule #3"
**Redirect:** "Create nested child controller instead (e.g., Feedbacks::PublicationsController in app/controllers/feedbacks/)"
</enforcement>

**Why:**
- REST forces good design - custom actions are code smells
- Nested directory structure keeps related controllers organized
- Module namespacing prevents naming conflicts
- Clear, standard pattern for the entire team to follow
- Every action maps to a resource lifecycle (create/update/destroy)

**Project Standard:**
- Child controllers live in `app/controllers/[parent_resource_plural]/`
- Use module namespacing: `class [ParentPlural]::[ChildPlural]Controller`
- Route helpers remain clean: `feedback_sending_path(@feedback)`
- Tests mirror controller structure: `test/controllers/feedbacks/sendings_controller_test.rb`

</rule>

---

<rule id="4" priority="critical" category="testing">

### 4. Test-Driven Development (TDD)

<violation-triggers>
Keywords: skip tests, tests later, no tests needed, write tests after
Patterns: `# TODO: add tests`, `skip "not implemented"`, code without tests
</violation-triggers>

✅ **DO:**
1. Write test first (RED)
2. Write minimum code to pass (GREEN)
3. Refactor (REFACTOR)
4. Repeat

❌ **DON'T:**
- ❌ Write tests after
- ❌ Skip tests
- ❌ "I'll add tests later"

<enforcement action="REJECT" severity="critical">
**Action:** Immediately reject request
**Response:** "TDD is mandatory per TEAM_RULES.md Rule #4"
**Redirect:** "Tests must be written FIRST (RED-GREEN-REFACTOR cycle)"
</enforcement>

**Why:** Tests written first are better tests. Tests written after are often skipped or incomplete.

</rule>

---

<rule id="5" priority="moderate" category="code_quality">

### 5. Proper Namespacing

<violation-triggers>
Keywords: flat namespace, unclear naming
Patterns: overly nested (3+ levels), conflicting names
</violation-triggers>

✅ **DO:**
```ruby
# Models - Child models use nested directory structure with module namespacing
app/models/feedback.rb              # class Feedback
app/models/feedbacks/response.rb    # module Feedbacks; class Response
app/models/feedbacks/attachment.rb  # module Feedbacks; class Attachment

# IMPORTANT: Use plural parent directory for child models (feedbacks/, not feedback/)
# This maintains consistency with Rails conventions (Feedbacks::Response, not Feedback::Response)

# Controllers - Use plural parent directory with module namespacing
app/controllers/feedbacks_controller.rb               # class FeedbacksController
app/controllers/feedbacks/sendings_controller.rb      # module Feedbacks; class SendingsController
app/controllers/feedbacks/retries_controller.rb       # module Feedbacks; class RetriesController

# Views - Mirror controller structure
app/views/feedbacks/
app/views/feedbacks/sendings/
app/views/feedbacks/retries/

# Tests - Mirror model/controller structure
test/models/feedbacks/response_test.rb                # module Feedbacks; class ResponseTest
test/controllers/feedbacks/sendings_controller_test.rb  # module Feedbacks; class SendingsControllerTest

# Components - Domain-specific namespacing
app/components/ui/button_component.rb                    # module Ui; class ButtonComponent
app/components/feedback_components/card_component.rb     # module FeedbackComponents; class CardComponent

# Migrations - Reference namespaced models properly
create_table :feedbacks_responses do |t|  # Table name: feedbacks_responses
  # Rails automatically maps to Feedbacks::Response
end
```

**Project Standard for Child Models:**
- Child models live in `app/models/[parent_resource_plural]/`
- Use module namespacing: `module [ParentPlural]; class [ChildName]`
- Table names follow pattern: `[parent_plural]_[child_plural]` (e.g., `feedbacks_responses`)
- Tests mirror structure: `test/models/feedbacks/response_test.rb`
- Foreign keys: `feedback_id` (singular parent, per Rails convention)

**Examples:**
```ruby
# Model: app/models/feedbacks/response.rb
module Feedbacks
  class Response < ApplicationRecord
    belongs_to :feedback  # Uses feedback_id foreign key
  end
end

# Parent model: app/models/feedback.rb
class Feedback < ApplicationRecord
  has_many :responses, class_name: "Feedbacks::Response"
end

# Usage in code:
Feedbacks::Response.create(feedback: @feedback, content: "Reply")
@feedback.responses.create(content: "Reply")
```

❌ **DON'T:**
```ruby
# Bad: Flat structure for child models
app/models/feedback_response.rb     # class FeedbackResponse

# Bad: Singular parent directory
app/models/feedback/response.rb     # module Feedback; class Response

# Bad: Inconsistent naming
app/models/feedbacks/response.rb    # class FeedbackResponse (missing module)
```

<enforcement action="SUGGEST" severity="moderate">
**Action:** Suggest better namespacing
**Response:** "Consider proper namespacing per TEAM_RULES.md Rule #5"
</enforcement>

**Why:**
- Clear organization - related models grouped in subdirectories
- Prevents naming conflicts - `Response` is scoped to `Feedbacks`
- Consistency - matches controller namespacing pattern (both use plural parent)
- Scalability - easy to add more related child models
- Rails conventions - works seamlessly with ActiveRecord associations

</rule>

---

<rule id="6" priority="high" category="workflow">

### 6. Architect Reviews Everything

<violation-triggers>
Keywords: bypass architect, skip review, quick fix without review
Patterns: direct agent invocation without @rails coordination
</violation-triggers>

✅ **DO:**
- All work goes through @rails architect
- Architect coordinates peer reviews
- Architect validates final work

❌ **DON'T:**
- ❌ Bypass architect for "quick fixes"
- ❌ Skip peer reviews
- ❌ Merge without architect approval

<enforcement action="ENFORCE" severity="high">
**Action:** Route through architect
**Response:** "All work must go through @rails architect per TEAM_RULES.md Rule #6"
</enforcement>

**Why:** Maintains consistency, standards, and architectural integrity.

</rule>

---

<rule id="7" priority="moderate" category="frontend">

### 7. Turbo Morph by Default

<violation-triggers>
Keywords: turbo frame without reason, replace entire content
Patterns: `turbo_frame_tag` without `data: { turbo_action: "morph" }`
</violation-triggers>

✅ **DO:**
```erb
<%# Default: Use Turbo Morph (morphs DOM, preserves state) %>
<%= turbo_frame_tag "feedback_list", data: { turbo_action: "morph" } do %>
  <%= render @feedbacks %>
<% end %>
```

❌ **DON'T:**
```erb
<%# Only use Frames when you have a REALLY good reason %>
<%= turbo_frame_tag "feedback_list" do %>
  <%= render @feedbacks %>
<% end %>
```

**Valid exceptions for Turbo Frames:**
- Modal dialogs
- Inline editing
- Pagination within a specific section
- Tabs navigation

<enforcement action="SUGGEST" severity="moderate">
**Action:** Suggest Turbo Morph instead
**Response:** "Use Turbo Morph by default per TEAM_RULES.md Rule #7"
</enforcement>

**Why:** Turbo Morph preserves scroll position, focus, and component state. Frames replace entire content and lose state. Morph is almost always better.

</rule>

---

<rule id="8" priority="moderate" category="code_quality">

### 8. Be Concise

<violation-triggers>
Keywords: overly verbose, unnecessary comments, redundant documentation
Patterns: Comments explaining obvious code, verbose method names
</violation-triggers>

✅ **DO:**
```ruby
# Good: Clear and concise
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    redirect_to @feedback, notice: "Created"
  else
    render :new, status: :unprocessable_entity
  end
end
```

❌ **DON'T:**
```ruby
# Bad: Overly verbose
def create
  # Initialize a new feedback object with the parameters
  # that were passed in from the form submission
  @feedback = Feedback.new(feedback_params)

  # Attempt to save the feedback to the database
  # If it saves successfully, redirect to the show page
  # Otherwise, render the new form again with errors
  if @feedback.save
    redirect_to feedback_path(@feedback), notice: "Feedback was successfully created"
  else
    render action: :new, status: :unprocessable_entity
  end
end
```

<enforcement action="SUGGEST" severity="moderate">
**Action:** Suggest removing verbose comments
**Response:** "Be concise per TEAM_RULES.md Rule #8 - code should be self-documenting"
</enforcement>

**Why:** Good code is self-documenting. Comments should explain "why", not "what".

</rule>

---

<rule id="9" priority="moderate" category="code_quality">

### 9. Don't Over-Engineer

<violation-triggers>
Keywords: service object, validator service, abstract factory, design pattern
Patterns: Unnecessary abstractions, premature extraction, complex inheritance
</violation-triggers>

✅ **DO:**
```ruby
# Good: Simple validation
class Feedback < ApplicationRecord
  validates :content, presence: true, length: { minimum: 50 }
end
```

❌ **DON'T:**
```ruby
# Bad: Over-engineered
class Feedback < ApplicationRecord
  validates :content, presence: true

  validate :content_length_validator
  validate :content_quality_validator

  private

  def content_length_validator
    ContentLengthValidatorService.new(self).validate
  end

  def content_quality_validator
    ContentQualityValidatorService.new(self).validate
  end
end

# And then separate service classes...
```

<enforcement action="SUGGEST" severity="moderate">
**Action:** Suggest simpler approach
**Response:** "Don't over-engineer per TEAM_RULES.md Rule #9 - start simple"
</enforcement>

**Why:** Rails validations work great. Don't create abstractions until you need them.

**Rule:** No service objects until you have a good reason. No design patterns until complexity demands it. Start simple.

</rule>

---

<rule id="10" priority="moderate" category="code_quality">

### 10. Reduce Complexity Always

<violation-triggers>
Keywords: add gem, new abstraction, complex pattern, future-proofing
Patterns: Unnecessary dependencies, hypothetical features
</violation-triggers>

✅ **DO:**
- Delete code whenever possible
- Merge similar code paths
- Use Rails conventions (less custom code)
- Prefer boring, obvious solutions

❌ **DON'T:**
- ❌ Add gems unnecessarily
- ❌ Create abstractions prematurely
- ❌ Use design patterns "because we should"
- ❌ Build for hypothetical future needs

**Questions to ask:**
- Can I delete this?
- Can I use a Rails convention instead?
- Am I solving a problem I actually have?
- Is there a simpler way?

<enforcement action="SUGGEST" severity="moderate">
**Action:** Challenge complexity
**Response:** "Can this be simpler per TEAM_RULES.md Rule #10?"
</enforcement>

**Why:** Every line of code is a liability. Less code = less bugs = less maintenance.

</rule>

---

<rule id="11" priority="high" category="workflow">

### 11. Draft PRs & Code Reviews

<violation-triggers>
Keywords: open for review immediately, skip peer review, merge without approval
Patterns: Non-draft PR without reviews, merging without architect approval
</violation-triggers>

✅ **DO:**
1. Open PR as **draft** initially
2. Request peer reviews (frontend ↔ backend, tests)
3. Address all review feedback
4. Run `bin/ci` (must pass)
5. Convert to **ready for review**
6. Architect gives final approval
7. Merge

❌ **DON'T:**
- ❌ Open PR for review before ready
- ❌ Skip peer reviews
- ❌ Merge without architect approval
- ❌ Merge with failing `bin/ci`

<enforcement action="ENFORCE" severity="high">
**Action:** Enforce draft PR workflow
**Response:** "Follow draft PR workflow per TEAM_RULES.md Rule #11"
</enforcement>

**Why:** Draft PRs set expectations. Reviews catch issues early. Architect ensures consistency.

</rule>

---

<rule id="12" priority="moderate" category="code_quality">

### 12. Fat Models, Thin Controllers

<violation-triggers>
Keywords: business logic in controller, complex controller methods
Patterns: Multiple model operations in controller, validation in controller
</violation-triggers>

✅ **DO:**
```ruby
# Good: Business logic in model
class Feedback < ApplicationRecord
  def mark_as_delivered!
    update!(status: :delivered, delivered_at: Time.current)
  end
end

class FeedbacksController < ApplicationController
  def deliver
    @feedback.mark_as_delivered!
    redirect_to @feedback
  end
end
```

❌ **DON'T:**
```ruby
# Bad: Business logic in controller
class FeedbacksController < ApplicationController
  def deliver
    @feedback.status = :delivered
    @feedback.delivered_at = Time.current
    @feedback.save!
    redirect_to @feedback
  end
end
```

<enforcement action="SUGGEST" severity="moderate">
**Action:** Suggest moving to model
**Response:** "Move business logic to model per TEAM_RULES.md Rule #12"
</enforcement>

**Exception:** When logic gets too complex in models, extract to service objects. But start with models.

</rule>

---

<rule id="13" priority="moderate" category="frontend">

### 13. Progressive Enhancement

<violation-triggers>
Keywords: requires javascript, client-side only, no fallback
Patterns: Forms without server-side validation, JS-only features
</violation-triggers>

✅ **DO:**
- Always works without JavaScript
- Enhance with Turbo/Stimulus
- Test with JS disabled

❌ **DON'T:**
- ❌ Require JavaScript for basic functionality
- ❌ Client-side only validation
- ❌ Skip the HTML-only version

<enforcement action="SUGGEST" severity="moderate">
**Action:** Ensure progressive enhancement
**Response:** "Ensure works without JS per TEAM_RULES.md Rule #13"
</enforcement>

**Why:** Accessibility, resilience, performance. Enhance, don't require.

</rule>

---

<rule id="14" priority="moderate" category="performance">

### 14. No Premature Optimization

<violation-triggers>
Keywords: optimize before measuring, cache just in case, performance assumption
Patterns: Caching without profiling, complex optimization without metrics
</violation-triggers>

✅ **DO:**
- Write clear code first
- Measure performance
- Optimize proven bottlenecks
- Prevent N+1 queries (this isn't premature)

❌ **DON'T:**
- ❌ Optimize before measuring
- ❌ Add caching "just in case"
- ❌ Complex solutions for hypothetical problems

<enforcement action="SUGGEST" severity="moderate">
**Action:** Challenge premature optimization
**Response:** "Avoid premature optimization per TEAM_RULES.md Rule #14"
</enforcement>

**Why:** Optimization makes code harder to understand. Only optimize what's actually slow.

**Exception:** Always prevent N+1 queries. Always use `includes`/`preload` for associations. This is basic competence, not premature optimization.

</rule>

---

<rule id="15" priority="high" category="frontend">

### 15. ViewComponent for All UI

<violation-triggers>
Keywords: raw html in views, inline styles, repeated markup
Patterns: `<button class="btn">` in ERB, duplicate HTML patterns
</violation-triggers>

✅ **DO:**
```erb
<%# Good: Reusable component %>
<%= render Ui::ButtonComponent.new(variant: :primary) { "Submit" } %>
```

❌ **DON'T:**
```erb
<%# Bad: Raw HTML in views %>
<button class="btn btn-primary">Submit</button>
```

<enforcement action="SUGGEST" severity="high">
**Action:** Suggest using ViewComponent
**Response:** "Use ViewComponent per TEAM_RULES.md Rule #15"
</enforcement>

**Why:** Components are testable, reusable, and maintainable. Raw HTML is none of these.

</rule>

---

<rule id="16" priority="moderate" category="code_quality">

### 16. Double Quotes Always

<violation-triggers>
Keywords: single quotes
Patterns: `'string'`, `'Name: ' + name`
</violation-triggers>

✅ **DO:**
```ruby
# Good
"Hello, world"
"Name: #{name}"
```

❌ **DON'T:**
```ruby
# Bad
'Hello, world'
'Name: ' + name
```

<enforcement action="AUTO" severity="moderate" tool="rubocop">
**Action:** RuboCop auto-corrects
**Response:** "Use double quotes per TEAM_RULES.md Rule #16"
</enforcement>

**Why:** Consistency. RuboCop Rails Omakase enforces this. One less decision to make.

</rule>

---

<rule id="17" priority="critical" category="workflow">

### 17. bin/ci Must Pass

<violation-triggers>
Keywords: skip ci, fix later, ignore warnings, commit anyway
Patterns: Committing with failing tests, ignoring RuboCop, bypassing Brakeman
</violation-triggers>

✅ **DO:**
- Run `bin/ci` before committing
- Run `bin/ci` before opening PR
- Run `bin/ci` after feedback addressed
- Never merge with failing `bin/ci`

**`bin/ci` includes:**
- All tests (models, controllers, components, system)
- RuboCop (linting)
- Brakeman (security)
- Bundler Audit (gem vulnerabilities)

❌ **DON'T:**
- ❌ Skip bin/ci
- ❌ "I'll fix it later"
- ❌ Ignore warnings

<enforcement action="REJECT" severity="critical">
**Action:** Block commit/merge
**Response:** "bin/ci must pass per TEAM_RULES.md Rule #17"
**Redirect:** "Fix all CI failures immediately"
</enforcement>

**Why:** CI failures compound. Fix them immediately.

</rule>

---

<rule id="18" priority="critical" category="testing">

### 18. WebMock: No Live HTTP Requests in Tests

<violation-triggers>
Keywords: live http, external request in test, disable webmock, allow real http
Patterns: `WebMock.allow_net_connect!`, `WebMock.disable!`, live API calls in tests
</violation-triggers>

✅ **DO:**
- Use WebMock to stub all external HTTP requests
- Keep `WebMock.disable_net_connect!` enabled (configured in test_helper.rb)
- Stub API responses for predictable testing

```ruby
# Good: Stubbed external API call
WebMock.stub_request(:post, "https://api.anthropic.com/v1/messages")
  .to_return(status: 200, body: { content: "response" }.to_json)

result = AnthropicClient.send_message("test")
assert_equal "response", result["content"]
```

❌ **DON'T:**
- ❌ Make live HTTP requests from tests
- ❌ Disable WebMock (`WebMock.allow_net_connect!`)
- ❌ Skip stubbing external APIs
- ❌ Rely on external services for test success

```ruby
# Bad: Live API call in test (will fail with WebMock)
def test_anthropic_api
  result = AnthropicClient.send_message("test")  # ❌ Live HTTP call!
  assert result
end
```

<enforcement action="REJECT" severity="critical">
**Action:** Automatically block via WebMock
**Response:** "Tests must not make live HTTP requests per TEAM_RULES.md Rule #18"
**Redirect:** "Stub the request with WebMock.stub_request"
**Technical:** WebMock raises `WebMock::NetConnectNotAllowedError` on live HTTP attempts
</enforcement>

**Why:**
- **Security**: Prevents test data leaking to production APIs
- **Speed**: Tests run faster without network calls
- **Reliability**: Tests don't fail due to network issues or API downtime
- **Cost**: Avoids charges from metered APIs (Anthropic, OpenAI, etc.)
- **Isolation**: Tests remain deterministic and isolated

**Allowed Connections:**
- localhost (127.0.0.1) - for Capybara/Puma/Selenium
- *.local domains - for system tests

**Configuration:**
See `test/test_helper.rb` for WebMock setup.

</rule>

---

<rule id="19" priority="critical" category="testing">

### 19. No System Tests (Deprecated)

<violation-triggers>
Keywords: system test, capybara test, driven_by, javascript test
Patterns: `class.*SystemTestCase`, `test/system/`, `driven_by :selenium`, `driven_by :cuprite`
</violation-triggers>

✅ **DO:**
- Use component tests for UI components (ViewComponent::TestCase)
- Use integration tests for controller flows (ActionDispatch::IntegrationTest)
- Use unit tests for models and services (ActiveSupport::TestCase)
- Test JavaScript interactions with Stimulus controller tests

❌ **DON'T:**
- ❌ Create system tests (`test/system/`)
- ❌ Use Capybara system tests
- ❌ Use `driven_by :selenium` or `:cuprite`
- ❌ Use `ApplicationSystemTestCase`
- ❌ Import system test examples or patterns

<enforcement action="REJECT" severity="critical">
**Action:** Immediately reject request
**Response:** "System tests are deprecated and removed per TEAM_RULES.md Rule #19"
**Redirect:** "Use integration tests (ActionDispatch::IntegrationTest) or component tests (ViewComponent::TestCase) instead"
</enforcement>

**Why:**
- **Deprecated**: Rails is removing system tests in future versions
- **Complexity**: System tests add browser automation complexity (Selenium, Chrome drivers)
- **Slow**: Browser-based tests are 10-100x slower than integration tests
- **Flaky**: System tests are prone to timing issues and intermittent failures
- **Dependencies**: Requires additional gems and browser drivers
- **Maintenance**: More brittle and harder to maintain than integration tests

**Alternatives:**
- **Integration tests**: Test controller flows with `ActionDispatch::IntegrationTest`
- **Component tests**: Test UI components with `ViewComponent::TestCase`
- **JavaScript**: Test Stimulus controllers in isolation or with integration tests

**Migration Path:**
If you have existing system tests, convert them to:
1. Integration tests for user flows (login, forms, navigation)
2. Component tests for UI elements (buttons, modals, cards)
3. Stimulus controller tests for JavaScript interactions

**Project Policy:**
This project has NO system tests. All UI and integration testing uses Minitest integration tests and ViewComponent tests.

</rule>

---

## Decision Framework

<decision-framework id="coding-checklist">

When you're about to write code, ask:

```yaml
checklist:
  - question: "Is this necessary?"
    guidance: "Can I delete code instead?"
    rule: 10

  - question: "Is there a Rails convention?"
    guidance: "Use it - don't reinvent"
    rule: 1

  - question: "Is this the simplest solution?"
    guidance: "Simplify before implementing"
    rule: 9

  - question: "Did I write tests first?"
    guidance: "TDD always - RED-GREEN-REFACTOR"
    rule: 4

  - question: "Will this add complexity?"
    guidance: "Reduce it - delete code"
    rule: 10
```

If you answer "no" to any of these, rethink your approach.

</decision-framework>

---

## The 37signals Way

These rules embody 37signals philosophy:

- **Convention over Configuration** - Rails conventions are good enough
- **Less is More** - Delete code, don't add it
- **Boring is Good** - Obvious > clever
- **Ship It** - Done > perfect
- **Programmer Happiness** - Simple code is happy code

### Recommended Reading

- [Rails Doctrine](https://rubyonrails.org/doctrine) - DHH's Rails philosophy
- [Getting Real](https://basecamp.com/gettingreal) - 37signals product philosophy
- [The Majestic Monolith](https://m.signalvnoise.com/the-majestic-monolith/) - Why Rails is enough

---

## Enforcement

<enforcement-hierarchy id="multi-layer">

```yaml
enforcement_layers:
  automated:
    - tool: bin/ci
      checks: [tests, rubocop, brakeman, bundler-audit]
      frequency: pre-commit, pre-PR, CI pipeline

    - tool: rubocop
      checks: [style, conventions, best_practices]
      auto_correct: true

    - tool: brakeman
      checks: [security_vulnerabilities]
      severity: critical

  manual:
    - agent: rails (architect)
      scope: all_work
      authority: final_approval

    - process: peer_review
      participants: [frontend, backend, tests, security, config, design]
      timing: after_implementation

    - process: git_hooks
      checks: [pre-commit, pre-push]
      enforcement: block_if_failing
```

**If you break these rules, expect pushback in code review.**

</enforcement-hierarchy>

---

## When to Break the Rules

<exceptions id="valid-rule-breaking">

Rules are guidelines, not laws. Break them when:

1. **You have a very good reason** (document it)
2. **The situation is exceptional** (truly unique)
3. **The architect agrees** (get approval first)

**Example valid exception:**
```ruby
# Exception: Using custom action because this is a webhook callback
# that doesn't fit REST semantics. Discussed with architect.
resource :stripe_webhook, only: [] do
  post :callback # External API requires this exact endpoint
end
```

**Bad exception:**
```ruby
# This is NOT a valid exception
resources :feedbacks do
  post :publish # Should be: resource :publication, only: [:create]
end
```

</exceptions>

---

## Summary (The Short Version)

<summary id="quick-reference">

```yaml
critical_rules:
  1: "Rails 8 Solid Stack only (no Sidekiq/Redis/Memcached)"
  2: "Minitest only (never RSpec)"
  3: "REST routes only (no custom actions)"
  4: "TDD always (tests first)"
  17: "bin/ci must pass (no exceptions)"
  18: "WebMock: No live HTTP requests in tests"

high_priority:
  6: "Architect reviews everything"
  11: "Draft PRs → Reviews → Architect approval"
  15: "ViewComponent for all UI"

moderate_priority:
  5: "Proper namespacing"
  7: "Turbo Morph by default"
  8: "Be concise"
  9: "Don't over-engineer"
  10: "Reduce complexity always"
  12: "Fat models, thin controllers"
  13: "Progressive enhancement"
  14: "No premature optimization"
  16: "Double quotes always"
```

**When in doubt: Simpler is better. Delete code. Follow Rails conventions.**

</summary>
