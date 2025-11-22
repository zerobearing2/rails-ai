---
name: TEAM_RULES
description: Engineering standards and governance for Rails development (37signals-inspired)
version: 3.0
last_updated: 2025-10-30

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
  - style

# Violation detection triggers (for instant rule checking)
violation_keywords:
  rule_1: [sidekiq, redis, memcached, resque]
  rule_2: [rspec, describe, context, let, subject]
  rule_3: [member, collection, custom action]
  rule_4: [skip tests, tests later, no tests]
  rule_9: [service object, validator service, complex abstraction]
  rule_14: [premature optimization, just in case]
  rule_18: [live http, external request in test, disable webmock]
  rule_20: [nested bracket access, chained fetch]

# Quick enforcement lookup
enforcement:
  automatic: [bin/ci, rubocop, brakeman, bundler-audit, webmock]
  manual: [architect_review, peer_review]
  severity:
    critical: [rule_1, rule_2, rule_3, rule_4, rule_17, rule_18]
    high: [rule_6, rule_7, rule_11, rule_15]
    moderate: [rule_5, rule_8, rule_9, rule_10, rule_12, rule_13, rule_14, rule_19, rule_20]
    low: [rule_16]
---

# TEAM_RULES.md - Engineering Standards & Governance

**Project:** The Feedback Agent
**Philosophy:** 37signals-inspired Rails development - Simple, pragmatic, conventional
**Version:** 3.0 - Governance-focused (implementation details in skills/)

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
    skills: [solid-stack-setup]

  2:
    name: "Minitest Only"
    severity: critical
    triggers: [rspec, describe, context]
    action: REJECT
    skills: [tdd-minitest, fixtures-test-data, minitest-mocking]

  3:
    name: "REST Routes Only"
    severity: critical
    triggers: [member, collection, custom action]
    action: REJECT
    skills: [controller-restful, nested-resources]

  4:
    name: "TDD Always"
    severity: critical
    triggers: [skip tests, tests later, no tests]
    action: REJECT
    skills: [tdd-minitest, model-testing-advanced, viewcomponent-testing]

  17:
    name: "bin/ci Must Pass"
    severity: critical
    triggers: [skip ci, fix later, ignore warnings]
    action: REJECT

  18:
    name: "WebMock: No Live HTTP in Tests"
    severity: critical
    triggers: [live http, external request, disable webmock]
    action: REJECT
    skills: [minitest-mocking]

  20:
    name: "Hash#dig for Nested Access"
    severity: moderate
    triggers: [nested bracket access, chained fetch]
    action: SUGGEST
    skills: [rubocop-setup]
    enforcement: rubocop
```

</quick-lookup>

---

<domain-index id="rules-by-domain">

## Rules by Domain

**Quick navigation by technical concern - all 20 rules organized by domain.**

### Stack Architecture & Technology
Rules governing technology choices and infrastructure.

- **Rule #1:** [Solid Stack Only](#1-solid-stack-only) - Use SolidQueue/SolidCache/SolidCable (no Redis/Sidekiq)
- **Rule #2:** [Minitest Only](#2-minitest-only-no-rspec) - Use Minitest for all tests (no RSpec)

### Routing & Controllers
Rules for URL structure and controller organization.

- **Rule #3:** [RESTful Routes Only](#3-restful-routes-only-no-custom-actions) - REST resources only (create child controllers for custom actions)
- **Rule #12:** [Fat Models, Thin Controllers](#12-fat-models-thin-controllers) - Business logic in models, controllers coordinate

### Testing
Rules for test methodology and quality standards.

- **Rule #4:** [TDD Always](#4-tdd-always-red-green-refactor) - Write tests FIRST (RED-GREEN-REFACTOR)
- **Rule #18:** [WebMock: No Live HTTP in Tests](#18-webmock-no-live-http-in-tests) - Mock external requests (use WebMock)
- **Rule #19:** [No System Tests](#19-no-system-tests-deprecated) - Use integration tests instead

### Frontend
Rules for UI components and interaction patterns.

- **Rule #7:** [Turbo Morph Default](#7-turbo-morph-default-stream-only-when-needed) - Prefer Turbo Morph over Streams
- **Rule #13:** [Progressive Enhancement](#13-progressive-enhancement) - Features work without JavaScript
- **Rule #15:** [ViewComponent for All UI](#15-viewcomponent-for-all-ui) - Use ViewComponent for reusable UI

### Backend & Data Layer
Rules for business logic and data organization.

- **Rule #5:** [Proper Namespacing](#5-proper-namespacing) - Use module namespacing (Feedbacks::, not FeedbacksHelper)
- **Rule #12:** [Fat Models, Thin Controllers](#12-fat-models-thin-controllers) - Business logic in models

### Workflow & Process
Rules for development process and team coordination.

- **Rule #6:** [Verification Before Completion](#6-verification-before-completion) - Verify work before claiming done
- **Rule #11:** [Draft PRs & Code Reviews](#11-draft-prs-code-reviews) - Open PRs as drafts, request reviews
- **Rule #17:** [bin/ci Must Pass](#17-binci-must-pass) - All checks pass before merge

### Philosophy & Principles
Guiding principles for code quality and decision-making.

- **Rule #8:** [Be Concise](#8-be-concise-resist-over-engineering) - Simple solutions over complex abstractions
- **Rule #9:** [Don't Over-Engineer](#9-dont-over-engineer-yagni) - YAGNI - build what you need now
- **Rule #10:** [Reduce Complexity Always](#10-reduce-complexity-always) - Simplicity over cleverness
- **Rule #14:** [No Premature Optimization](#14-no-premature-optimization) - Optimize what you measure, not imagine

### Code Quality & Style
Standards for consistency and maintainability.

- **Rule #16:** [Double Quotes Always](#16-double-quotes-always) - Use double quotes for strings (enforced by Rubocop)
- **Rule #20:** [Hash#dig for Nested Access](#20-hashdig-for-nested-access) - Use Hash#dig for safe nested access (enforced by Rubocop)

</domain-index>

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

✅ **REQUIRE:** SolidQueue, SolidCache, SolidCable
❌ **REJECT:** Sidekiq, Redis, Memcached, Resque

<enforcement action="REJECT" severity="critical">
**Action:** Immediately reject request
**Response:** "We use Rails 8 Solid Stack per TEAM_RULES.md Rule #1"
**Redirect:** "SolidQueue/SolidCache/SolidCable already configured - delegating to @backend for implementation"
</enforcement>

<implementation-skills>
- **Primary:** `skills/config/solid-stack-setup.md` - Full Solid Stack configuration
- **Related:** `skills/backend/action-mailer.md` - Background email delivery with SolidQueue
</implementation-skills>

**Why:** Rails 8 provides excellent defaults. Don't add external dependencies unless absolutely necessary.

</rule>

---

<rule id="2" priority="critical" category="testing">

### 2. Minitest Only

<violation-triggers>
Keywords: rspec, describe, context, let, subject, before, it
Patterns: `gem "rspec-rails"`, `RSpec.describe`, `context "when"`
</violation-triggers>

✅ **REQUIRE:** Minitest (Minitest::Test, ActiveSupport::TestCase)
❌ **REJECT:** RSpec, custom test frameworks

<enforcement action="REJECT" severity="critical">
**Action:** Immediately reject request
**Response:** "We use Minitest only per TEAM_RULES.md Rule #2"
**Redirect:** "Delegating to @tests to help with Minitest"
</enforcement>

<implementation-skills>
- **Primary:** `skills/testing/tdd-minitest.md` - TDD with Minitest workflow
- **Related:** `skills/testing/fixtures-test-data.md` - Test data management
- **Related:** `skills/testing/minitest-mocking.md` - Mocking and stubbing
- **Related:** `skills/testing/test-helpers.md` - Reusable test utilities
</implementation-skills>

**Why:** Minitest is simple, fast, and part of Ruby stdlib. RSpec adds unnecessary complexity.

</rule>

---

<rule id="3" priority="critical" category="routing">

### 3. RESTful Routes Only

<violation-triggers>
Keywords: member, collection, custom action
Patterns: `member do`, `collection do`, `post :publish`, `get :archive`
</violation-triggers>

✅ **REQUIRE:** Standard REST actions (index, show, new, create, edit, update, destroy)
✅ **ALTERNATIVE:** Nested child controllers for additional actions
❌ **REJECT:** Custom route actions (member/collection)

<enforcement action="REJECT" severity="critical">
**Action:** Immediately reject request
**Response:** "We use RESTful resources only per TEAM_RULES.md Rule #3"
**Redirect:** "Create nested child controller (e.g., `Feedbacks::PublicationsController` in `app/controllers/feedbacks/`) - delegating to @backend"
</enforcement>

<implementation-skills>
- **Primary:** `skills/backend/controller-restful.md` - RESTful conventions
- **Primary:** `skills/backend/nested-resources.md` - Child controller pattern
</implementation-skills>

**Why:**
- REST forces good design - custom actions are code smells
- Nested directory structure keeps controllers organized
- Module namespacing prevents conflicts
- Every action maps to a resource lifecycle

**Pattern:**
- Child controllers: `app/controllers/[parent_plural]/[child_controller].rb`
- Module namespace: `module [ParentPlural]; class [ChildController]`
- Route: `/feedbacks/:id/sending` → `Feedbacks::SendingsController#create`

</rule>

---

<rule id="4" priority="critical" category="testing">

### 4. Test-Driven Development (TDD)

<violation-triggers>
Keywords: skip tests, tests later, no tests needed, write tests after
Patterns: `# TODO: add tests`, `skip "not implemented"`, code without tests
</violation-triggers>

✅ **REQUIRE:** RED-GREEN-REFACTOR cycle
❌ **REJECT:** Writing code before tests, skipping tests

<enforcement action="REJECT" severity="critical">
**Action:** Immediately reject request
**Response:** "TDD is mandatory per TEAM_RULES.md Rule #4"
**Redirect:** "Tests must be written FIRST (RED-GREEN-REFACTOR cycle)"
</enforcement>

<implementation-skills>
- **Primary:** `skills/testing/tdd-minitest.md` - TDD workflow and patterns
- **Related:** `skills/testing/model-testing-advanced.md` - Comprehensive model testing
- **Related:** `skills/testing/viewcomponent-testing.md` - Component testing
- **Related:** `skills/testing/fixtures-test-data.md` - Test data setup
</implementation-skills>

**Why:** Tests written first are better tests. Tests written after are often skipped or incomplete.

**Process:**
1. Write test first (RED - fails)
2. Write minimum code (GREEN - passes)
3. Refactor (improve while keeping green)
4. Repeat

</rule>

---

<rule id="5" priority="moderate" category="code_quality">

### 5. Proper Namespacing

<violation-triggers>
Keywords: flat namespace, unclear naming, UserSetting, OrderItem, UserSettingsController, UsersSettingsController
Patterns: overly nested (3+ levels), conflicting names, class UserSetting, class UserSettingsController, class UsersSettingsController
</violation-triggers>

✅ **REQUIRE:**
- Namespaced models for nested entities (User::Setting, not UserSetting)
- Namespaced controllers for domain management (Users::SettingsController, not UserSettingsController)
- Plural parent directories for child models/controllers (Feedbacks::ResponsesController)
- Singular parent directories for domain controllers (Users::SettingsController)
- Module namespacing always (e.g., `module Feedbacks; class Response`)
- Max 2 nesting levels

❌ **REJECT:**
- Flat naming for nested entities (UserSetting instead of User::Setting)
- Flat naming for domain controllers (UserSettingsController instead of Users::SettingsController)
- Inconsistent naming (singular vs plural)
- Deep nesting (3+ levels)

<implementation-skills>
- **Primary:** `skills/backend/activerecord-patterns.md` - Model naming conventions
- **Primary:** `skills/backend/nested-resources.md` - Controller and route organization
- **Primary:** `skills/backend/concerns-models.md` - Concern organization
- **Primary:** `skills/backend/concerns-controllers.md` - Controller concerns
</implementation-skills>

**Pattern:**
```
# Namespaced models (SINGULAR parent) - entities owned by parent
app/models/user/setting.rb           # class User::Setting (belongs to User)
app/models/order/line_item.rb        # class Order::LineItem (part of Order)

# Domain controllers (SINGULAR parent) - manage aspects of parent
app/controllers/users/settings_controller.rb  # module Users; class SettingsController
app/controllers/accounts/billing_controller.rb # module Accounts; class BillingController

# Child models and controllers use PLURAL parent namespace
app/models/feedbacks/response.rb    # module Feedbacks; class Response
app/controllers/feedbacks/responses_controller.rb  # module Feedbacks; class ResponsesController

# Domain-specific concerns use SINGULAR parent namespace
app/models/user/authenticatable.rb  # module User; module Authenticatable (concern)
app/models/feedback/notifications.rb # module Feedback; module Notifications (concern)

# Generic/shared concerns go in concerns/ directory
app/models/concerns/taggable.rb      # module Taggable (shared across models)
app/controllers/concerns/api/response_handler.rb  # module Api; module ResponseHandler

# Test structure mirrors implementation
test/models/user/setting_test.rb
test/controllers/users/settings_controller_test.rb
test/controllers/feedbacks/responses_controller_test.rb
```

**Why:** Clear organization, prevents naming conflicts, maintainable structure. Namespacing shows ownership and aggregation relationships clearly.

</rule>

---

<rule id="6" priority="high" category="workflow">

### 6. Verification Before Completion

**Type:** Workflow governance (no implementation skill)

✅ **REQUIRE:** Verify all work before claiming completion
❌ **REJECT:** Claiming work is done without evidence

**Why:** Ensures quality, prevents regressions, maintains standards.

**Process:**
1. Complete implementation
2. Run `bin/ci` - must pass
3. Update CHANGELOG.md (for features/refactors)
4. Use `superpowers:verification-before-completion` skill
5. Evidence before claims - always

</rule>

---

<rule id="7" priority="high" category="frontend">

### 7. Turbo Morph by Default

<violation-triggers>
Keywords: turbo frame without reason, replace entire content
Patterns: `turbo_frame_tag` without justification
</violation-triggers>

✅ **PREFER:** Turbo Morph (page refresh with morphing)
✅ **ALLOW:** Turbo Frames ONLY for: modals, inline editing, tabs, pagination

❌ **AVOID:** Turbo Frames for general list updates

<enforcement action="SUGGEST" severity="high">
**Action:** Suggest Turbo Morph instead
**Response:** "Use Turbo Morph by default per TEAM_RULES.md Rule #7"
</enforcement>

<implementation-skills>
- **Primary:** `skills/frontend/turbo-page-refresh.md` - Morphing implementation
- **Related:** `skills/frontend/hotwire-turbo.md` - Turbo Frames for valid use cases
</implementation-skills>

**Why:** Turbo Morph preserves scroll, focus, and state. Frames replace content and lose state. Morph is simpler and better in 90% of cases.

</rule>

---

<rule id="8" priority="moderate" category="code_quality">

### 8. Be Concise

**Type:** Code philosophy (no implementation skill)

<violation-triggers>
Keywords: overly verbose, unnecessary comments, redundant documentation
Patterns: Comments explaining obvious code
</violation-triggers>

✅ **PREFER:** Self-documenting code, minimal comments
❌ **AVOID:** Verbose comments, obvious documentation, redundant explanations

<enforcement action="SUGGEST" severity="moderate">
**Action:** Suggest removing verbose comments
**Response:** "Be concise per TEAM_RULES.md Rule #8 - code should be self-documenting"
</enforcement>

**Why:** Good code is self-documenting. Comments should explain "why", not "what".

**Examples:**
- ✅ Good: `redirect_to @feedback, notice: "Created"`
- ❌ Bad: `# Redirect to the feedback page with a success message`

</rule>

---

<rule id="9" priority="moderate" category="code_quality">

### 9. Don't Over-Engineer

**Type:** Development philosophy (no implementation skill)

<violation-triggers>
Keywords: service object, validator service, complex abstraction, just in case
Patterns: Premature abstraction, unused patterns
</violation-triggers>

✅ **PREFER:** Start simple, extract patterns only when needed
❌ **AVOID:** Service objects, decorators, presenters unless clearly justified

<enforcement action="SUGGEST" severity="moderate">
**Action:** Challenge complexity
**Response:** "Can this be simpler? Rule #9: Don't over-engineer"
</enforcement>

**Why:** YAGNI (You Ain't Gonna Need It). Extract patterns when pain is real, not anticipated.

**Guidelines:**
- Start with fat models, thin controllers
- Extract to form objects when forms get complex (3+ models)
- Extract to query objects when queries get complex (3+ joins)
- Don't create abstractions "just in case"

</rule>

---

<rule id="10" priority="moderate" category="code_quality">

### 10. Reduce Complexity Always

**Type:** Guiding principle (no implementation skill)

✅ **PREFER:** Delete code, simplify logic, use Rails conventions
❌ **AVOID:** Adding dependencies, creating new patterns, complex solutions

<enforcement action="SUGGEST" severity="moderate">
**Action:** Suggest simpler alternative
**Response:** "Can we reduce complexity? Rule #10"
</enforcement>

**Why:** The best code is no code. Every line added is a line to maintain.

**Techniques:**
- Delete unused code
- Use Rails conventions (don't reinvent)
- Reduce conditional logic
- Flatten nested structures
- Consolidate similar code

</rule>

---

<rule id="11" priority="high" category="workflow">

### 11. Draft PRs & Code Reviews

**Type:** Git workflow (no implementation skill)

✅ **REQUIRE:**
1. Open PR in draft mode
2. Complete work (all checks passing)
3. Mark ready for review
4. Get code review approval
5. Merge

❌ **REJECT:** Opening PR for immediate review, merging without approval

**Why:** Avoids interrupting reviewers with incomplete work. Allows iteration before formal review.

**Process:**
```bash
gh pr create --title "Feature: X" --body "Details" --draft
# ... continue work ...
gh pr ready <pr-number>  # When complete and bin/ci passes
```

</rule>

---

<rule id="12" priority="moderate" category="code_quality">

### 12. Fat Models, Thin Controllers

<violation-triggers>
Keywords: controller with business logic, controller over 100 lines
Patterns: Complex conditional logic in controllers
</violation-triggers>

✅ **PREFER:** Business logic in models, controllers coordinate
✅ **EXTRACT:** To form objects (complex forms) or query objects (complex queries)

❌ **AVOID:** Controllers with business logic, validations, calculations

<enforcement action="SUGGEST" severity="moderate">
**Action:** Suggest extraction
**Response:** "Extract to form/query object per Rule #12"
</enforcement>

<implementation-skills>
- **Primary:** `skills/backend/antipattern-fat-controllers.md` - Refactoring guide
- **Related:** `skills/backend/form-objects.md` - Extract form logic
- **Related:** `skills/backend/query-objects.md` - Extract query logic
- **Related:** `skills/backend/concerns-controllers.md` - Extract shared behavior
</implementation-skills>

**Why:** Controllers should coordinate, not contain business logic. Logic in models is easier to test and reuse.

</rule>

---

<rule id="13" priority="moderate" category="frontend">

### 13. Progressive Enhancement

<violation-triggers>
Keywords: requires javascript, doesn't work without js
Patterns: Features that fail without JavaScript
</violation-triggers>

✅ **REQUIRE:** All features work without JavaScript
✅ **ENHANCE:** Add JavaScript for better UX

❌ **REJECT:** JavaScript-only features (except justified cases like real-time collaboration)

<implementation-skills>
- **Primary:** `skills/frontend/hotwire-turbo.md` - Server-rendered interactivity
- **Related:** `skills/frontend/accessibility-patterns.md` - Keyboard navigation, fallbacks
</implementation-skills>

**Why:** Accessibility, reliability, broader device support. JavaScript enhances, doesn't enable.

</rule>

---

<rule id="14" priority="moderate" category="performance">

### 14. No Premature Optimization

**Type:** Development principle (no implementation skill)

<violation-triggers>
Keywords: premature optimization, future-proofing, just in case, might need
Patterns: Complex caching before performance issues, indexing before slow queries
</violation-triggers>

✅ **PREFER:** Optimize when you measure a problem
❌ **AVOID:** Optimizing before there's evidence of need

<enforcement action="SUGGEST" severity="moderate">
**Action:** Ask for evidence
**Response:** "Is this optimization needed now? Rule #14: No premature optimization"
</enforcement>

**Why:** Premature optimization wastes time and adds complexity. Optimize what you measure, not what you imagine.

**When to optimize:**
- After measuring (slow query, high memory, etc.)
- When user experience suffers
- When data shows clear bottleneck

</rule>

---

<rule id="15" priority="high" category="frontend">

### 15. ViewComponent for All UI

<violation-triggers>
Keywords: partial for reusable component, helper for complex UI
Patterns: Partials used as components, complex helpers rendering HTML
</violation-triggers>

✅ **REQUIRE:** ViewComponent for all reusable UI elements
✅ **ALLOW:** Partials for simple, one-off view fragments

❌ **AVOID:** Partials as components, complex view helpers

<enforcement action="SUGGEST" severity="high">
**Action:** Suggest ViewComponent
**Response:** "Use ViewComponent for reusable UI per Rule #15"
</enforcement>

<implementation-skills>
- **Primary:** `skills/frontend/viewcomponent-basics.md` - Component patterns
- **Related:** `skills/frontend/viewcomponent-slots.md` - Flexible composition
- **Related:** `skills/frontend/viewcomponent-variants.md` - Variant management
- **Related:** `skills/frontend/viewcomponent-previews.md` - Development workflow
- **Related:** `skills/testing/viewcomponent-testing.md` - Testing components
</implementation-skills>

**Why:** ViewComponents are testable, performant (10x faster than partials), and encapsulated. Better developer experience.

</rule>

---

<rule id="16" priority="low" category="style">

### 16. Double Quotes Always

**Type:** Style preference (enforced by Rubocop)

✅ **REQUIRE:** Double quotes for all strings
❌ **REJECT:** Single quotes (unless string contains double quotes)

<enforcement action="AUTO" severity="low">
**Enforced by:** Rubocop
**Command:** `rake lint:fix` auto-corrects
</enforcement>

**Why:** Consistency. One less decision to make.

**Examples:**
- ✅ `"Hello world"`
- ❌ `'Hello world'`
- ✅ `'String with "quotes" inside'` (exception)

</rule>

---

<rule id="17" priority="critical" category="workflow">

### 17. bin/ci Must Pass

**Type:** CI/CD requirement (no implementation skill)

<violation-triggers>
Keywords: skip ci, fix later, ignore warnings, ci failing
Patterns: Committing with failing tests, ignoring Rubocop, Brakeman warnings
</violation-triggers>

✅ **REQUIRE:** All checks pass before commit/PR
❌ **REJECT:** Committing with failing CI, ignoring warnings

<enforcement action="REJECT" severity="critical">
**Action:** Block commit/merge
**Response:** "bin/ci must pass per Rule #17"
</enforcement>

**What bin/ci checks:**
- ✅ All tests passing (Minitest)
- ✅ Rubocop compliance (no offenses)
- ✅ Brakeman security scan (no warnings)
- ✅ YAML validation
- ✅ Markdown linting (informational)

**Why:** Prevents broken code from entering codebase. Maintains code quality.

</rule>

---

<rule id="18" priority="critical" category="testing">

### 18. WebMock: No Live HTTP Requests in Tests

<violation-triggers>
Keywords: live http, external request in test, disable webmock, allow real http
Patterns: `WebMock.allow_net_connect!`, making real API calls in tests
</violation-triggers>

✅ **REQUIRE:** Stub all external HTTP requests with WebMock
❌ **REJECT:** Live HTTP requests in tests

<enforcement action="REJECT" severity="critical">
**Action:** Reject test that makes live HTTP calls
**Response:** "Use WebMock to stub external requests per Rule #18"
</enforcement>

<implementation-skills>
- **Primary:** `skills/testing/minitest-mocking.md` - WebMock patterns
</implementation-skills>

**Why:** Tests must be fast, reliable, and not dependent on external services. Live HTTP = flaky tests.

**Pattern:**
```ruby
stub_request(:post, "https://api.example.com/webhooks")
  .with(body: hash_including(event: "feedback.created"))
  .to_return(status: 200, body: {success: true}.to_json)
```

</rule>

---

<rule id="19" priority="moderate" category="testing">

### 19. No System Tests (Deprecated Pattern)

<violation-triggers>
Keywords: system test, capybara system test, ApplicationSystemTestCase
Patterns: `class FeedbackSystemTest < ApplicationSystemTestCase`
</violation-triggers>

✅ **REQUIRE:** Integration tests with Capybara
❌ **REJECT:** System tests (`ApplicationSystemTestCase`)

<enforcement action="SUGGEST" severity="moderate">
**Action:** Suggest migration to integration tests
**Response:** "Use integration tests instead of system tests per Rule #19"
</enforcement>

**Why:** Integration tests with Capybara provide same coverage with better performance and simpler setup.

**Migration:**
```ruby
# ❌ Old: System test
class FeedbackSystemTest < ApplicationSystemTestCase
end

# ✅ New: Integration test with Capybara
class FeedbackFlowTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
end
```

</rule>

---

<rule id="20" priority="moderate" category="code_quality">

### 20. Hash#dig for Nested Access

<violation-triggers>
Keywords: nested bracket access, chained fetch
Patterns: `hash[:a][:b][:c]`, `hash.fetch(:a).fetch(:b)`, unsafe nested access
</violation-triggers>

✅ **REQUIRE:** `Hash#dig` for nested hash access where any level might be nil
✅ **ALLOW:** `Hash#fetch` for top-level keys with explicit error handling or defaults
✅ **ALLOW:** Direct bracket access for single-level access

❌ **AVOID:** Chained bracket access (`hash[:a][:b][:c]`) - raises NoMethodError if intermediate key is nil
❌ **AVOID:** Chained `fetch` calls (`hash.fetch(:a, nil)&.fetch(:b, nil)`)

<enforcement action="SUGGEST" severity="moderate">
**Action:** Suggest Hash#dig or Hash#fetch
**Response:** "Use Hash#dig for safe nested access per Rule #20"
**Enforced by:** RuboCop Style/HashFetchChain, Style/DigChain
</enforcement>

**Why:**
- `Hash#dig` returns `nil` safely instead of raising `NoMethodError`
- More readable than chained bracket access
- More maintainable - clear intent for optional nested access
- Ruby community standard (enforced by RuboCop)

**Examples:**

```ruby
# ❌ Bad: Raises NoMethodError if :profile or :settings is nil
theme = user[:profile][:settings][:theme]

# ❌ Bad: Verbose and unclear intent
theme = user.fetch(:profile, nil)&.fetch(:settings, nil)&.fetch(:theme, nil)

# ✅ Good: Returns nil safely
theme = user.dig(:profile, :settings, :theme)

# ✅ Good: Use fetch for required top-level keys
user_id = user.fetch(:id)  # Raises KeyError if missing

# ✅ Good: Use fetch with default for top-level keys
timeout = config.fetch(:timeout, 30)

# ✅ Good: Single-level access is fine
name = user[:name]
```

**When to use each:**
- **`dig`**: Nested access where intermediate keys might not exist
- **`fetch`**: Required keys (raises error if missing) or keys with defaults
- **`[]`**: Simple single-level access, or when nil is acceptable

</rule>

---

## Rules Summary

| ID | Rule | Severity | Type | Has Skills |
|----|------|----------|------|------------|
| 1 | Solid Stack Only | Critical | Technology | ✅ Yes |
| 2 | Minitest Only | Critical | Technology | ✅ Yes |
| 3 | RESTful Routes Only | Critical | Pattern | ✅ Yes |
| 4 | TDD Always | Critical | Workflow | ✅ Yes |
| 5 | Proper Namespacing | Moderate | Pattern | ✅ Yes |
| 6 | Architect Reviews | High | Workflow | ❌ No |
| 7 | Turbo Morph Default | High | Pattern | ✅ Yes |
| 8 | Be Concise | Moderate | Philosophy | ❌ No |
| 9 | Don't Over-Engineer | Moderate | Philosophy | ❌ No |
| 10 | Reduce Complexity | Moderate | Philosophy | ❌ No |
| 11 | Draft PRs | High | Workflow | ❌ No |
| 12 | Fat Models, Thin Controllers | Moderate | Pattern | ✅ Yes |
| 13 | Progressive Enhancement | Moderate | Pattern | ✅ Yes |
| 14 | No Premature Optimization | Moderate | Philosophy | ❌ No |
| 15 | ViewComponent for UI | High | Technology | ✅ Yes |
| 16 | Double Quotes | Low | Style | ✅ Yes |
| 17 | bin/ci Must Pass | Critical | Workflow | ❌ No |
| 18 | WebMock in Tests | Critical | Testing | ✅ Yes |
| 19 | No System Tests | Moderate | Deprecation | ❌ No |
| 20 | Hash#dig for Nested Access | Moderate | Style | ✅ Yes |

**Coverage:**
- **Total Rules:** 20
- **Rules with Skills:** 12 (60%)
- **Rules without Skills:** 8 (40% - workflow/philosophy)

**See:** `rules/RULES_TO_SKILLS_MAPPING.yml` for complete rule→skill mapping

---

## Enforcement Strategy

### Critical Rules (REJECT immediately)
- Rules #1, #2, #3, #4, #17, #18
- No exceptions, immediate rejection
- Redirect to compliant alternative or required skill

### High Rules (SUGGEST strongly)
- Rules #6, #7, #11, #15
- Strong recommendation with explanation
- Allow with justification in rare cases

### Moderate Rules (SUGGEST)
- Rules #5, #8, #9, #10, #12, #13, #14, #16, #19, #20
- Recommend best practice
- Guide toward better approach

---

## Quick Reference for Agents

**When you see these keywords, check these rules:**

- `sidekiq`, `redis` → Rule #1
- `rspec`, `describe` → Rule #2
- `member`, `collection` → Rule #3
- `skip tests`, `tests later` → Rule #4
- `turbo_frame_tag` (without reason) → Rule #7
- `service object`, `presenter` → Rule #9
- Controller > 100 lines → Rule #12
- Partial used as component → Rule #15
- Live HTTP in test → Rule #18
- `ApplicationSystemTestCase` → Rule #19
- Nested bracket access (`hash[:a][:b]`), chained fetch → Rule #20

**For implementation details, load the corresponding skill from `skills/` directory.**

---

**Version History:**
- **3.0** (2025-10-30): Governance-focused refactor, removed code examples, added skill links
- **2.0** (2025-10-29): Added machine-readable metadata, violation triggers
- **1.0** (2025-10-28): Initial team rules
