# Shared Context for All Rails Agents

**Purpose**: Common workflows, patterns, and rules shared across all agents to reduce redundancy and ensure consistency.

---

## Universal Team Rules (TEAM_RULES.md)

<team-rules id="universal" ref="TEAM_RULES.md">

**ALL agents MUST enforce these rules - NO EXCEPTIONS:**

### Rule #1: Solid Stack Only
❌ **NEVER** use Sidekiq, Redis, or Memcached
✅ **ALWAYS** use SolidQueue, SolidCache, SolidCable (Rails 8 Solid Stack)

**When violated:**
- **REJECT** request immediately
- **REDIRECT** to Solid Stack alternative
- **EXPLAIN** why: Rails 8 convention, simpler, no external dependencies

### Rule #2: Minitest Only
❌ **NEVER** use RSpec
✅ **ALWAYS** use Minitest (Minitest::Test, ActiveSupport::TestCase, ViewComponent::TestCase)

**When violated:**
- **REJECT** RSpec usage immediately
- **REQUIRE** Minitest for all tests

### Rule #3: REST Routes Only
❌ **NEVER** add custom route actions (member/collection)
✅ **ALWAYS** use RESTful resources (index, show, new, create, edit, update, destroy)

**When custom action needed:**
- Create child controller with RESTful actions
- Example: `/feedbacks/:id/approve` → `Feedbacks::ApprovalsController#create`

### Rule #4: TDD Always
❌ **NEVER** write code without tests first
✅ **ALWAYS** follow RED-GREEN-REFACTOR cycle

**Process:**
1. Write test first (RED - fails)
2. Write minimum code (GREEN - passes)
3. Refactor (improve while keeping green)

### Rule #5: bin/ci Must Pass
❌ **NEVER** commit with failing CI
✅ **ALWAYS** ensure all checks pass: tests, RuboCop, Brakeman

### Rule #6: Draft PRs First
❌ **NEVER** open PR for immediate review
✅ **ALWAYS** open as draft, complete work, then mark ready

Full reference: `TEAM_RULES.md`

</team-rules>

---

## Standard TDD Workflow

<tdd-workflow id="standard" type="red-green-refactor" steps="6">

**Use for**: Backend models, controllers, services, frontend components

### Step-by-Step Process:

1. **Write Test First** (RED)
   - Define expected behavior
   - Write test that fails
   - Verify test actually runs and fails

2. **Write Minimum Code** (GREEN)
   - Implement just enough to pass
   - No over-engineering
   - Keep it simple

3. **Refactor** (REFACTOR)
   - Improve code quality
   - Reduce duplication
   - Maintain test passing

4. **Repeat**
   - Move to next feature/test
   - Small incremental steps

5. **Peer Review**
   - Request review from relevant agents
   - Frontend ↔ Backend
   - Tests reviews both

6. **Verify bin/ci**
   - Run full CI suite
   - All checks must pass
   - Fix any issues immediately

### Test Types by Layer:

| Layer | Test Type | Tool | Coverage Goal |
|-------|-----------|------|---------------|
| Models | Unit | Minitest | 100% |
| Controllers | Functional | ActionDispatch | 95%+ |
| Components | Component | ViewComponent::TestCase | 100% |
| System | Integration | Capybara | Critical paths |

</tdd-workflow>

---

## WebMock Testing Pattern

<webmock-pattern id="external-http" type="stubbing">

**Purpose**: Block all external HTTP requests in tests, ensuring no data leaks and deterministic test behavior

### Configuration (test_helper.rb):

```ruby
require "webmock/minitest"
WebMock.disable_net_connect!(
  allow_localhost: true,  # Allow Capybara/Puma/Selenium
  allow: ["127.0.0.1", "localhost", /\.local$/]
)
```

### Stubbing External APIs:

```ruby
# Stub Anthropic API
WebMock.stub_request(:post, "https://api.anthropic.com/v1/messages")
  .with(
    body: hash_including({ model: "claude-sonnet-4-20250514" }),
    headers: { "x-api-key" => "test-key" }
  )
  .to_return(
    status: 200,
    body: { content: [{ text: "AI response" }] }.to_json,
    headers: { "Content-Type" => "application/json" }
  )

# Stub OpenAI API
WebMock.stub_request(:post, "https://api.openai.com/v1/chat/completions")
  .to_return(
    status: 200,
    body: { choices: [{ message: { content: "GPT response" } }] }.to_json
  )
```

### Testing HTTP Errors:

```ruby
# Stub API failure
WebMock.stub_request(:post, "https://api.example.com/endpoint")
  .to_return(status: 500, body: "Internal Server Error")

# Test error handling
assert_raises(ApiError) do
  ExternalClient.call_api
end
```

### Pattern Benefits:

- ✅ **No live API calls** - Tests never hit production APIs
- ✅ **Deterministic** - Same inputs always produce same outputs
- ✅ **Fast** - No network latency
- ✅ **Secure** - No test data leaks to external services
- ✅ **Cost-effective** - No metered API charges during testing

### Common Patterns:

```ruby
# Pattern 1: Stub in setup
class FeedbackTest < ActiveSupport::TestCase
  setup do
    WebMock.stub_request(:post, /api\.anthropic\.com/)
      .to_return(status: 200, body: { content: "test" }.to_json)
  end

  test "processes feedback with AI" do
    feedback = Feedback.create!(content: "test", ai_enabled: true)
    assert feedback.ai_processed?
  end
end

# Pattern 2: Verify request was made
test "calls external API with correct parameters" do
  stub = WebMock.stub_request(:post, "https://api.example.com/v1/messages")
    .with(body: hash_including({ prompt: "test" }))
    .to_return(status: 200, body: "success")

  perform_api_call("test")

  assert_requested stub
end
```

**Reference**: TEAM_RULES.md Rule #18

</webmock-pattern>

---

## Peer Review Process

<peer-review id="standard" participants="3">

**When**: After agent completes implementation, before architect approval

### Review Flow:

```
Implementation Complete
         ↓
    Peer Reviews (Parallel)
         ↓
   ┌──────┴──────┐
   ↓             ↓
Frontend      Backend
   ↓             ↓
   └──────┬──────┘
         ↓
    Tests Agent
         ↓
   Issues Found?
    ↙         ↘
  YES         NO
   ↓           ↓
Fix &      Architect
Resubmit    Approval
```

### Review Responsibilities:

**@rails-frontend reviews @rails-backend:**
- Controller provides all data needed for views?
- JSON responses match expected format?
- No N+1 queries affecting view rendering?
- Strong parameters allow necessary attributes?
- Error messages user-friendly?
- Status codes appropriate for Turbo handling?

**@rails-backend reviews @rails-frontend:**
- UI correctly uses backend API?
- Forms submit correct parameters?
- Error handling complete?
- Loading states for async operations?
- Accessibility attributes present?

**@rails-tests reviews both:**
- TDD followed (tests written first)?
- Test coverage adequate (85%+)?
- Edge cases tested?
- Error paths tested?
- Assertions meaningful?
- Test quality high?

### Review Output Format:

```markdown
## Peer Review: [Agent] reviewing [Agent]'s [Feature]

### ✅ Approved Items:
- [Specific item] looks good
- [Specific item] well-implemented

### ⚠️ Suggestions:
- [Specific file:line] - [Improvement suggestion]

### ❌ Required Changes:
- [Specific file:line] - [Critical issue that must be fixed]

### Overall Assessment:
[APPROVED | APPROVED_WITH_SUGGESTIONS | CHANGES_REQUIRED]
```

</peer-review>

---

## Code Quality Gates

<quality-gates id="standard">

**ALL code must pass these gates before merge:**

### 1. Tests (bin/rails test)
- ✅ All tests passing
- ✅ No skipped tests (unless documented)
- ✅ 85%+ coverage goal
- ✅ System tests pass (critical paths)

### 2. Style (bin/rubocop)
- ✅ 0 offenses
- ✅ Rails Omakase style
- ✅ Double quotes for strings
- ✅ 2-space indentation

### 3. Security (bin/brakeman)
- ✅ 0 warnings
- ✅ 0 security vulnerabilities
- ✅ All user input validated
- ✅ CSRF protection enabled

### 4. Dependencies (bin/bundler-audit)
- ✅ No vulnerable gems
- ✅ Up-to-date security patches

### 5. Architecture
- ✅ No N+1 queries
- ✅ RESTful routes only
- ✅ Proper separation of concerns
- ✅ No TEAM_RULES.md violations

### 6. Peer Review
- ✅ Relevant agents reviewed
- ✅ Feedback addressed
- ✅ No blocking issues

### Running All Gates:

```bash
bin/ci  # Runs all checks
```

**Result must be**: ✅ Continuous Integration passed

</quality-gates>

---

## Rails Conventions (Standard)

<rails-conventions id="standard">

**Follow these conventions across all Rails code:**

### MVC Separation:
- **Models**: Business logic, validations, associations, scopes
- **Views**: Presentation only, no logic (use ViewComponents)
- **Controllers**: Thin, route handling, delegate to models/services

### RESTful Design:
- **7 standard actions**: index, show, new, create, edit, update, destroy
- **No custom actions**: Create child controllers instead
- **Nested resources**: Max 1 level deep (`/posts/:post_id/comments`)

### Naming Conventions:
- **Models**: Singular (`Feedback`, `User`)
- **Controllers**: Plural (`FeedbacksController`, `UsersController`)
- **Tables**: Plural (`feedbacks`, `users`)
- **Files**: Snake case (`feedback_submission_form_component.rb`)
- **Classes**: Camel case (`FeedbackSubmissionFormComponent`)

### Database:
- **Foreign keys**: `user_id`, `feedback_id`
- **Timestamps**: Always include `created_at`, `updated_at`
- **Indexes**: On foreign keys, frequent query columns
- **Constraints**: Add NOT NULL, uniqueness at DB level

### Configuration:
- **Initializers**: All custom config in `config/initializers/`
- **Secrets**: Use Rails credentials or ENV vars
- **Never**: Modify `config/application.rb`

</rails-conventions>

---

## Common Anti-Patterns (All Agents)

<antipatterns id="universal">

### 🚫 Critical Violations (Immediate Rejection):

1. **Using Sidekiq/Redis/Memcached**
   - Violates Rule #1
   - Use SolidQueue/SolidCache/SolidCable

2. **Using RSpec**
   - Violates Rule #2
   - Use Minitest only

3. **Custom Route Actions**
   - Violates Rule #3
   - Create child controllers

4. **Skipping TDD**
   - Violates Rule #4
   - Write tests first always

5. **Committing without bin/ci passing**
   - Violates Rule #5
   - Fix all CI failures

### ⚠️ Common Mistakes (Should Fix):

1. **N+1 Queries**
   - Use `includes`, `preload`, or `eager_load`
   - Verify with bullet gem or logs

2. **Business Logic in Controllers**
   - Move to models (fat models, thin controllers)
   - Extract to service objects if complex

3. **Missing Validations**
   - Validate all user input at model layer
   - Add database constraints

4. **Skipping Edge Cases**
   - Test happy path AND error paths
   - Test boundary conditions

5. **Poor Error Messages**
   - User-friendly messages
   - Specific, actionable guidance

</antipatterns>

---

## MCP Integration Pattern

<mcp-integration id="context7">

**Use Context7 MCP for version-specific documentation:**

### When to Query:

1. Before implementing new features with unfamiliar APIs
2. When uncertain about version-specific syntax
3. For breaking changes between versions
4. To provide accurate docs to other agents

### How to Query:

```ruby
# Step 1: Resolve library ID
mcp__context7__resolve-library-id("rails")
# Returns: /rails/rails

# Step 2: Get documentation
mcp__context7__get-library-docs(
  "/rails/rails",
  topic: "rate_limit",  # Optional: focus on specific topic
  tokens: 5000          # Optional: token limit
)
```

### Common Queries:

| Library | ID | Common Topics |
|---------|----|----|
| Rails 8.1 | `/rails/rails` | rate_limit, solid_queue, activerecord |
| Ruby 3.3+ | `/ruby/ruby` | pattern matching, syntax |
| ViewComponent | `/viewcomponent/view_component` | slots, rendering |
| DaisyUI | `/saadeghi/daisyui` | components, themes |
| Turbo | `/hotwired/turbo` | frames, streams, morph |
| Stimulus | `/hotwired/stimulus` | controllers, actions |

</mcp-integration>

---

## Git Workflow (Standard)

<git-workflow id="standard">

### Branch Naming:

- `feature/description` - New features
- `fix/description` - Bug fixes
- `chore/description` - Maintenance

### Commit Process:

1. **Make changes**
2. **Run bin/ci** (must pass)
3. **Stage files**: `git add .`
4. **Commit**: Use descriptive message
5. **Push**: `git push origin branch-name`

### PR Process:

1. **Open as draft**: `gh pr create --draft`
2. **Continue work**, push commits
3. **When complete**:
   - Ensure bin/ci passes
   - Request peer reviews
   - Address feedback
4. **Mark ready**: `gh pr ready <pr-number>`
5. **Architect approval**
6. **Merge**

### Commit Message Format:

```
Brief summary (50 chars or less)

Detailed explanation of what and why:
- What changed
- Why it was needed
- Any trade-offs considered

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

</git-workflow>

---

## HTTP Status Codes (Controllers)

<http-status-codes id="standard">

**Use appropriate status codes for controller responses:**

### Success (2xx):

| Code | Use Case | Rails Method |
|------|----------|--------------|
| 200 OK | Successful GET, PATCH, PUT | Default |
| 201 Created | Successful POST (created resource) | `status: :created` |
| 204 No Content | Successful DELETE | `head :no_content` |

### Client Errors (4xx):

| Code | Use Case | Rails Method |
|------|----------|--------------|
| 400 Bad Request | Invalid request format | `status: :bad_request` |
| 401 Unauthorized | Not authenticated | `status: :unauthorized` |
| 403 Forbidden | Authenticated but no permission | `status: :forbidden` |
| 404 Not Found | Resource not found | `status: :not_found` |
| 422 Unprocessable Entity | Validation failed | `status: :unprocessable_entity` |

### Example:

```ruby
def create
  @feedback = Feedback.new(feedback_params)

  if @feedback.save
    render json: @feedback, status: :created
  else
    render json: { errors: @feedback.errors }, status: :unprocessable_entity
  end
end
```

</http-status-codes>

---

## Performance Optimization Patterns

<performance id="n-plus-one-prevention">

### N+1 Query Prevention:

**Problem:**
```ruby
# N+1: Queries database for each feedback's recipient
@feedbacks = Feedback.all
@feedbacks.each do |feedback|
  puts feedback.recipient.email  # N+1!
end
```

**Solution:**
```ruby
# Eager loading: Single query with JOIN
@feedbacks = Feedback.includes(:recipient)
@feedbacks.each do |feedback|
  puts feedback.recipient.email  # No additional query
end
```

### Choosing the Right Method:

| Method | Use When | SQL Generated |
|--------|----------|---------------|
| `includes` | Accessing associated records | Separate queries (default) or LEFT JOIN |
| `preload` | Separate queries always | Two separate SELECT queries |
| `eager_load` | Force LEFT JOIN | Single query with LEFT JOIN |
| `joins` | Filtering only (don't access assoc) | INNER JOIN |

</performance>

---

## Usage in Agent Files

**To reference shared context in agent files:**

```markdown
<import src=".claude/SHARED_CONTEXT.md#tdd-workflow" />
<import src=".claude/SHARED_CONTEXT.md#peer-review" />
<import src=".claude/SHARED_CONTEXT.md#team-rules" />
```

**Or reference specific sections:**

```markdown
See: [TDD Workflow](.claude/SHARED_CONTEXT.md#standard-tdd-workflow)
See: [Peer Review Process](.claude/SHARED_CONTEXT.md#peer-review-process)
See: [Team Rules](.claude/SHARED_CONTEXT.md#universal-team-rules-team_rulesmd)
```

---

**This shared context eliminates redundancy across all agent files and ensures consistency in workflows, standards, and enforcement.**
