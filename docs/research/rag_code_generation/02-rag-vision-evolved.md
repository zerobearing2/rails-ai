# RAG Vision: Beyond Retrieval — Toward Contextual Intelligence

**Date:** January 2025
**Status:** Vision Document
**Purpose:** Evolve RAG from simple code retrieval into an intelligent contextual system that understands intent, learns from usage, and becomes the missing link between human thought and Rails code generation

---

## Executive Summary

The research identifies RAG + SQLite as a promising approach (70-85% Pass@1, $7k-15k first year). But we're thinking too small.

RAG isn't just about finding similar code—it's about **understanding context at every layer of abstraction**, from architectural intent down to implementation details. It's about building a system that doesn't just retrieve patterns but **reasons about them**, learns from developer feedback, and evolves with the codebase.

This document proposes a multi-dimensional RAG architecture that:

1. **Multi-Stage Retrieval** - Different granularities for different needs (architectural, pattern-level, implementation)
2. **Intent-Based Indexing** - Index not just what code does, but why it exists and when to use it
3. **Dynamic Pattern Synthesis** - Combine retrieved patterns intelligently rather than copy-paste
4. **Self-Improving Loop** - Learn from every generation, test result, and PR review
5. **AST-Aware Generation** - Retrieve and manipulate at the AST level for surgical precision
6. **Living Style Guide** - Patterns that evolve as the codebase and team conventions evolve
7. **Transparent Reasoning** - Show developers exactly what influenced each generation

**The Goal:** Not just better code generation, but a system that makes Rails developers feel like they have a senior architect pair programming with them who has read every great Rails codebase and remembers every pattern they've used.

---

## Part I: Challenging the Current RAG Thinking

### What the Research Got Right

The research correctly identifies:
- SQLite + sqlite-vec is the right foundation (Rails 8 aligned, local-first)
- Quality filtering is critical (RuboCop > 90, coverage > 70%)
- Neighbor gem provides the right Rails-native abstractions
- AST-based chunking is superior to text-based approaches
- Combining RAG with style enforcement multiplies effectiveness

### What the Research Missed

#### 1. The Context Problem

**Research assumes:** Retrieve k similar snippets and feed to LLM
**Reality:** Different types of questions need different contexts

When a developer asks "Create a user authentication endpoint", what do they actually need?

- **Architectural level**: How authentication fits into the app structure
- **Pattern level**: Common authentication patterns (before_action chains, token handling)
- **Implementation level**: Actual code for authentication
- **Testing level**: How to test authentication
- **Security level**: Common vulnerabilities to avoid
- **Integration level**: How this connects to other parts of the system

A single vector similarity search can't capture this multi-dimensional context.

#### 2. The Intent Gap

**Research assumes:** Similar code = relevant code
**Reality:** Intent matters more than similarity

Consider these two queries:
- "Create a REST API for products"
- "Create a high-performance bulk API for products"

Simple similarity search might return the same results. But the intent is radically different:
- First needs standard CRUD with proper status codes
- Second needs batching, streaming, N+1 prevention, caching strategies

The retrieval system needs to understand **why** code exists, not just **what** it does.

#### 3. The Static Pattern Problem

**Research assumes:** Index great codebases once, retrieve forever
**Reality:** Patterns evolve, conventions change, new approaches emerge

Rails 8 introduces Solid Queue. Your indexed codebase has Sidekiq everywhere. How does RAG handle this transition?

The system needs to:
- Recognize deprecated patterns (Sidekiq)
- Map them to modern equivalents (Solid Queue)
- Learn new patterns as they emerge in the team's code
- Retire outdated patterns gracefully
- Track pattern evolution over time

Static indexing isn't enough. We need **living, evolving pattern recognition**.

#### 4. The Quality Paradox

**Research assumes:** High RuboCop scores = good code to learn from
**Reality:** Passing linters doesn't mean it's the right pattern

Code can be:
- Syntactically perfect but architecturally wrong
- Well-tested but solving the wrong problem
- Following conventions but outdated for Rails 8
- Working but not idiomatic for the specific domain

Quality metrics need to go beyond static analysis:
- How often is this pattern used in production codebases?
- How often is it modified or refactored later?
- What percentage of codebases favor this approach vs alternatives?
- Does this pattern appear in codebases with low bug rates?
- How does the community evaluate this pattern (blog posts, conference talks)?

#### 5. The Context Window Constraint

**Research assumes:** Retrieve top-k snippets, fit in context window
**Reality:** Context windows are a bottleneck that forces compression

GPT-4 Turbo: 128k tokens (~100k usable)
Claude Sonnet: 200k tokens (~180k usable)

Sounds like a lot until you try to include:
- 5 retrieved code examples (10k tokens)
- System prompt with rails-ai agent instructions (5k tokens)
- TEAM_RULES.md and style guides (3k tokens)
- User's conversation history (5k tokens)
- Current codebase context (10k tokens)

We're already at 33k tokens before generation.

**Solution:** Don't just retrieve and dump. **Synthesize and compress** retrieved patterns into dense, actionable guidance.

#### 6. The Trust Problem

**Research assumes:** If Pass@1 improves, developers will trust it
**Reality:** Developers need to understand WHY the system chose these patterns

Black box retrieval + black box generation = double black box.

Developers need:
- "I retrieved this controller pattern from Discourse's authentication system"
- "This approach is used in 87% of production Rails apps"
- "The team used this pattern in app/controllers/admin/users_controller.rb"
- "This test pattern matches your test_helper.rb conventions"

Trust comes from **transparency and explainability**.

---

## Part II: The Evolved RAG Architecture

### Core Insight: Multi-Dimensional Context Retrieval

RAG shouldn't be one vector database. It should be a **contextual intelligence layer** with multiple specialized retrieval systems working together.

```
User Query: "Add user authentication"
    │
    ├─> Architectural Retriever
    │   └─> Returns: Auth system design patterns (high-level structure)
    │
    ├─> Pattern Retriever
    │   └─> Returns: before_action chains, JWT handling, session management
    │
    ├─> Implementation Retriever
    │   └─> Returns: Actual controller/model/service code
    │
    ├─> Test Retriever
    │   └─> Returns: Test patterns for authentication
    │
    ├─> Security Retriever
    │   └─> Returns: Common auth vulnerabilities, security best practices
    │
    ├─> Team Retriever
    │   └─> Returns: How THIS team does authentication
    │
    └─> Integration Retriever
        └─> Returns: How auth connects to other systems in THIS codebase
```

### Architecture: The Seven Retrieval Layers

#### Layer 1: Architectural Retrieval

**Purpose:** Understand high-level structure and system design

**What gets indexed:**
- Architectural decision records (ADRs)
- README architecture sections
- System diagrams and documentation
- Rails Guides architectural patterns
- Conference talks and blog posts about architecture

**Embeddings optimized for:**
- Conceptual similarity (not code similarity)
- Problem-solution mapping
- System design patterns

**Example Query → Retrieval:**
```
Query: "Add background job processing"

Retrieved Architecture:
1. Rails 8 Solid Stack approach (SolidQueue, not Sidekiq)
2. Job hierarchy patterns (base job -> specific jobs)
3. Error handling and retry strategies
4. Monitoring and observability patterns
5. How jobs integrate with transactional workflows
```

**Storage:**
```ruby
class ArchitecturalPattern < ApplicationRecord
  has_neighbors :embedding, dimensions: 1536

  # What makes this different from code retrieval
  store_accessor :metadata, :abstraction_level, :problem_domain,
                 :solution_approach, :tradeoffs, :when_to_use
end
```

#### Layer 2: Intent-Based Pattern Retrieval

**Purpose:** Understand the "why" behind code patterns

**What gets indexed:**
- Code patterns WITH their contextual intent
- Comments explaining WHY this approach was chosen
- Commit messages and PR descriptions
- Code review feedback showing pattern evolution
- Anti-patterns with explanations of why they're wrong

**The Key Innovation: Intent Tagging**

```ruby
class PatternIndex
  def index_with_intent(code_snippet)
    {
      code: code_snippet.code,

      # What does this code do?
      function: extract_function(code_snippet),

      # Why was this approach chosen?
      intent: extract_intent(code_snippet),

      # When should this be used?
      use_cases: extract_use_cases(code_snippet),

      # When should this NOT be used?
      anti_patterns: extract_alternatives(code_snippet),

      # What problem does this solve?
      problem_domain: classify_domain(code_snippet),

      # What tradeoffs does this make?
      tradeoffs: extract_tradeoffs(code_snippet)
    }
  end

  private

  def extract_intent(snippet)
    # Use LLM to analyze comments, context, and usage
    # "This uses delegate to avoid N+1 queries when loading associations"
  end

  def extract_use_cases(snippet)
    # Analyze where/how this pattern is used
    # "Use when you need read-only access to associated records"
  end
end
```

**Example: Two Similar Patterns, Different Intents**

```ruby
# Pattern A: Indexed with Intent
{
  code: "before_action :authenticate_user!",
  intent: "Require authentication for all actions in this controller",
  use_cases: ["Protected admin areas", "User-specific resources"],
  anti_patterns: "Don't use for public API endpoints",
  frequency: "Used in 89% of admin controllers",
  quality_score: 95
}

# Pattern B: Indexed with Intent
{
  code: "before_action :authenticate_user!, except: [:index, :show]",
  intent: "Mix public read access with authenticated write access",
  use_cases: ["Public listings with private actions", "Blog with admin edits"],
  anti_patterns: "Don't use if ANY action needs auth (use Pattern A)",
  frequency: "Used in 34% of public-facing controllers",
  quality_score: 92
}
```

Now when a query comes in, we can match not just code similarity but **intent similarity**.

#### Layer 3: AST-Aware Code Retrieval

**Purpose:** Retrieve at the structural level, not just text similarity

**Why AST matters:**

Text-based retrieval treats code as a bag of words. AST-based retrieval understands structure:

```ruby
# These are semantically identical but text-wise very different:

# Style 1
def create
  @user = User.new(user_params)
  if @user.save
    redirect_to @user
  else
    render :new
  end
end

# Style 2
def create
  @user = User.new(user_params)
  return render :new unless @user.save
  redirect_to @user
end
```

AST retrieval recognizes both as the same pattern: "Create → Save → Success/Failure branching"

**Implementation Strategy:**

```ruby
class ASTIndexer
  def index_method(method_node)
    {
      # Full code text
      code: method_node.source,

      # AST pattern signature
      ast_signature: extract_signature(method_node),

      # Structural elements
      structure: {
        method_name: method_node.method_name,
        parameters: extract_params(method_node),
        branches: count_branches(method_node),
        returns: extract_return_patterns(method_node),
        calls: extract_method_calls(method_node),
        complexity: calculate_complexity(method_node)
      },

      # Embeddings for similarity
      embedding: embed_ast_structure(method_node)
    }
  end

  def extract_signature(node)
    # Extract the structural pattern regardless of variable names
    # "def method(params) -> conditional -> success_path + failure_path"
  end
end
```

**Retrieval Benefits:**

1. **Style-invariant matching** - Find patterns regardless of coding style
2. **Structural similarity** - Match control flow patterns
3. **Refactoring awareness** - Recognize equivalent implementations
4. **Pattern composition** - Understand how patterns combine

**Example: Query with AST Understanding**

```
Query: "Create endpoint that validates input and handles errors"

AST Pattern Matched:
- Method with parameter validation
- Conditional branching on validation result
- Success path returns/redirects
- Failure path renders with errors

Retrieved:
- Controller create actions with strong params
- Service objects with validation logic
- API endpoints with error handling
- Similar control flow patterns
```

#### Layer 4: Test Pattern Retrieval

**Purpose:** Generate tests that match how this team tests

**The Problem:** Generic test patterns don't capture team conventions

Every team has unique testing patterns:
- Custom test helpers
- Shared contexts
- Assertion styles
- Setup/teardown patterns
- Factory patterns

**Solution: Team-Aware Test Retrieval**

```ruby
class TestPatternRetrieval
  def retrieve_test_patterns(code_snippet, project_path)
    # 1. Analyze existing test suite to understand team patterns
    team_patterns = analyze_existing_tests(project_path)

    # 2. Retrieve similar tests from production codebases
    similar_tests = retrieve_similar(code_snippet)

    # 3. SYNTHESIZE: Adapt retrieved tests to match team patterns
    synthesize_tests(similar_tests, team_patterns)
  end

  private

  def analyze_existing_tests(project_path)
    {
      # What test framework? (Minitest, RSpec, etc)
      framework: detect_framework(project_path),

      # What's in test_helper.rb?
      helpers: extract_helpers(project_path),

      # Common setup patterns?
      setup_patterns: extract_setup_patterns(project_path),

      # How are factories/fixtures used?
      factory_patterns: analyze_factories(project_path),

      # What assertion style? (assert vs assert_equal vs must_equal)
      assertion_style: analyze_assertions(project_path),

      # Custom matchers/helpers?
      custom_methods: extract_custom_methods(project_path),

      # Test organization (describe/context vs class/test)?
      organization: analyze_organization(project_path)
    }
  end

  def synthesize_tests(similar_tests, team_patterns)
    # Don't just return similar tests
    # ADAPT them to match team conventions

    similar_tests.map do |test|
      adapt_test(test, team_patterns)
    end
  end
end
```

**Example: Team-Aware Test Generation**

```ruby
# Retrieved test from Discourse (RSpec style)
describe UsersController do
  let(:user) { create(:user) }

  it "creates a new user" do
    expect {
      post :create, params: { user: attributes_for(:user) }
    }.to change(User, :count).by(1)
  end
end

# Team uses Minitest with specific patterns
# SYNTHESIZED test (adapted to team conventions)
class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should create user" do
    assert_difference -> { User.count }, 1 do
      post users_path, params: { user: user_attributes }
    end

    assert_redirected_to user_path(User.last)
    assert_equal "User created", flash[:notice]
  end

  private

  def user_attributes
    # Uses team's test helper pattern
    build_user_params(email: "test@example.com")
  end
end
```

#### Layer 5: Security-Aware Retrieval

**Purpose:** Proactively prevent security issues

**The Opportunity:** Rails has 20+ years of security lessons. Capture them.

**What gets indexed:**

1. **Known Vulnerabilities:**
   - Brakeman warning patterns
   - CVE databases for Rails/gems
   - Security advisories
   - OWASP Top 10 for Rails

2. **Secure Patterns:**
   - Strong parameter usage
   - SQL injection prevention
   - XSS prevention
   - CSRF token handling
   - Mass assignment protection
   - Authentication/authorization patterns

3. **Security Reviews:**
   - Code review comments about security
   - Security-focused PRs
   - Security audit findings

**Implementation:**

```ruby
class SecurityPatternIndex
  def analyze_for_security(generated_code)
    vulnerabilities = detect_vulnerabilities(generated_code)

    if vulnerabilities.any?
      secure_alternatives = retrieve_secure_patterns(vulnerabilities)

      {
        unsafe: generated_code,
        issues: vulnerabilities,
        fixes: secure_alternatives,
        explanation: explain_vulnerabilities(vulnerabilities)
      }
    end
  end

  private

  def detect_vulnerabilities(code)
    [
      detect_sql_injection(code),
      detect_mass_assignment(code),
      detect_missing_authentication(code),
      detect_xss_vectors(code),
      detect_timing_attacks(code)
    ].flatten.compact
  end

  def retrieve_secure_patterns(vulnerabilities)
    vulnerabilities.map do |vuln|
      SecurePattern
        .nearest_neighbors(:embedding, embed(vuln.description))
        .where(vulnerability_type: vuln.type)
        .first(3)
    end
  end
end
```

**Example: Security-Guided Generation**

```ruby
# LLM generates:
def search
  @results = User.where("name LIKE '%#{params[:query]}%'")
end

# Security retrieval detects SQL injection risk
# Retrieves secure alternative:
def search
  @results = User.where("name LIKE ?", "%#{params[:query]}%")
end

# With explanation:
"Detected: SQL injection via string interpolation in WHERE clause
Fixed: Use parameterized query with ? placeholder
Pattern: This fix appears in 99.8% of production Rails codebases
Security Impact: Critical - prevents arbitrary SQL execution"
```

#### Layer 6: Team Context Retrieval

**Purpose:** Learn and apply THIS team's conventions

**The Critical Insight:** The codebase itself is the most important training data

Every team has unique patterns:
- Custom service objects
- Specific controller structures
- Preferred gem choices
- Naming conventions
- File organization

**Solution: Codebase-Specific Indexing**

```ruby
class TeamContextIndex
  def index_codebase(project_path)
    # Extract team-specific patterns
    patterns = {
      service_objects: analyze_service_pattern(project_path),
      controller_structure: analyze_controllers(project_path),
      model_patterns: analyze_models(project_path),
      concern_usage: analyze_concerns(project_path),
      helper_patterns: analyze_helpers(project_path),
      naming_conventions: extract_naming(project_path),
      gem_preferences: analyze_gemfile(project_path),
      test_patterns: analyze_tests(project_path),

      # Most important: pattern frequency
      pattern_frequency: calculate_frequencies(project_path)
    }

    # Index with high priority
    patterns.each do |pattern|
      TeamPattern.create!(
        pattern: pattern,
        priority: :team_convention, # Highest priority in retrieval
        source: :this_codebase
      )
    end
  end

  def calculate_frequencies(project_path)
    # How often does this team use each pattern?
    # This should influence retrieval ranking

    {
      "before_action :authenticate_user!": 0.89,  # 89% of controllers
      "include Callable": 0.95,                    # 95% of service objects
      "delegate :name, to: :user": 0.67,          # 67% of decorators
      # etc...
    }
  end
end
```

**Retrieval Strategy: Team Patterns First**

```ruby
def retrieve_with_priority(query)
  # 1. Check team's own codebase first (highest priority)
  team_results = TeamPattern.search(query).limit(3)

  # 2. Check high-quality production codebases
  community_results = CommunityPattern.search(query).limit(3)

  # 3. Check Rails core/guides
  framework_results = FrameworkPattern.search(query).limit(2)

  # 4. Merge with priority weighting
  [
    team_results.map { |r| r.merge(priority: 1.0) },
    community_results.map { |r| r.merge(priority: 0.7) },
    framework_results.map { |r| r.merge(priority: 0.5) }
  ].flatten
end
```

**Example: Team-Aware Generation**

```ruby
# Query: "Create a service object for user registration"

# Without team context (generic pattern):
class UserRegistrationService
  def self.call(params)
    user = User.new(params)
    user.save
  end
end

# With team context (learns from project's other service objects):
class UserRegistrationService
  include Callable  # Team always uses Callable concern
  include Loggable  # Team logs all service actions

  def initialize(params, current_user:)
    @params = params
    @current_user = current_user  # Team always tracks who initiated
  end

  def call
    user = User.new(@params)

    ActiveRecord::Base.transaction do  # Team uses explicit transactions
      user.save!
      AuditLog.create!(action: "user_created", user: @current_user)
    end

    ServiceResult.success(user: user)  # Team uses ServiceResult pattern
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(errors: e.record.errors)
  end
end
```

#### Layer 7: Integration Context Retrieval

**Purpose:** Understand how new code connects to existing systems

**The Challenge:** Code doesn't exist in isolation

When generating a new controller, we need to know:
- What authentication system does this app use?
- What does the base controller include?
- How are errors handled globally?
- What JSON serialization approach is used?
- What's the routing structure?

**Solution: Relationship Indexing**

```ruby
class IntegrationContextIndex
  def analyze_integration_points(project_path)
    {
      # How do controllers connect?
      base_controller: analyze_base_controller(project_path),

      # How does auth work?
      auth_system: detect_auth_system(project_path),

      # How are errors handled?
      error_handling: analyze_error_patterns(project_path),

      # What concerns are available?
      available_concerns: list_concerns(project_path),

      # How is JSON serialized?
      serialization: detect_serializer(project_path),

      # What's the routing structure?
      routing_patterns: analyze_routes(project_path),

      # How are jobs enqueued?
      job_patterns: analyze_jobs(project_path),

      # What mailer patterns exist?
      mailer_patterns: analyze_mailers(project_path)
    }
  end

  def retrieve_integration_context(query, project_path)
    # Don't just retrieve similar code
    # Retrieve code that shows HOW to integrate

    integration_points = analyze_integration_points(project_path)

    {
      must_inherit_from: integration_points[:base_controller],
      must_use_auth: integration_points[:auth_system],
      should_handle_errors: integration_points[:error_handling],
      can_include_concerns: integration_points[:available_concerns],
      must_serialize_with: integration_points[:serialization]
    }
  end
end
```

**Example: Integration-Aware Generation**

```ruby
# Query: "Create an API endpoint for products"

# System analyzes codebase:
# - app/controllers/api/base_controller.rb exists
# - Uses Pundit for authorization
# - Uses ActiveModel::Serializers
# - Has RateLimitable concern
# - Returns JSON with status codes

# Generated code integrates perfectly:
class Api::ProductsController < Api::BaseController
  include RateLimitable  # Found in codebase

  before_action :authenticate_user!  # Found in base controller
  before_action :set_product, only: [:show, :update, :destroy]

  def index
    authorize Product  # Pundit pattern found in codebase
    @products = Product.accessible_by(current_user)

    render json: @products, each_serializer: ProductSerializer  # Serializer pattern
  end

  private

  def set_product
    @product = Product.find(params[:id])
    authorize @product  # Consistent with codebase patterns
  end
end
```

### Synthesis: Multi-Layer Retrieval in Action

**Query: "Add Stripe payment processing"**

```ruby
class MultiLayerRetrieval
  def retrieve_all(query, project_path)
    {
      # Layer 1: Architecture
      architecture: retrieve_architecture(query),
      # Returns: Payment processing architecture patterns, event flow, webhook handling

      # Layer 2: Intent
      intent: retrieve_intent(query),
      # Returns: "Payment processing with idempotency, webhook verification, error handling"

      # Layer 3: AST Patterns
      code_structure: retrieve_ast_patterns(query),
      # Returns: Controller → Service → External API → Webhook patterns

      # Layer 4: Tests
      test_patterns: retrieve_tests(query, project_path),
      # Returns: How to test payment flows, mock Stripe, test webhooks

      # Layer 5: Security
      security: retrieve_security(query),
      # Returns: Webhook signature verification, idempotency keys, PCI compliance

      # Layer 6: Team Context
      team_patterns: retrieve_team_patterns(query, project_path),
      # Returns: How THIS team structures external integrations

      # Layer 7: Integration
      integration: retrieve_integration(query, project_path)
      # Returns: Where this fits in existing payment flow, base classes, concerns
    }
  end

  def synthesize_guidance(layers)
    # Don't dump all layers to LLM
    # SYNTHESIZE into dense, actionable guidance

    <<~GUIDANCE
      ARCHITECTURAL APPROACH:
      #{layers[:architecture].synthesize}

      IMPLEMENTATION PATTERN:
      #{layers[:intent].synthesize}

      CODE STRUCTURE:
      #{layers[:code_structure].synthesize}

      SECURITY REQUIREMENTS:
      #{layers[:security].synthesize}

      TEAM CONVENTIONS:
      #{layers[:team_patterns].synthesize}

      INTEGRATION POINTS:
      #{layers[:integration].synthesize}

      TEST STRATEGY:
      #{layers[:test_patterns].synthesize}
    GUIDANCE
  end
end
```

This gives the LLM dense, multi-dimensional context instead of raw code dumps.

---

## Part III: Self-Improving RAG System

### The Vision: Learn From Every Interaction

RAG shouldn't be static. It should improve with every:
- Code generation
- Test run
- PR review
- Developer edit
- Production deployment

**Feedback Loop Architecture:**

```ruby
class SelfImprovingRAG
  def generate_and_learn(query, project_path)
    # 1. Generate code with current RAG
    generation = generate_with_rag(query, project_path)

    # 2. Track what was retrieved and used
    tracking = track_retrieval(generation)

    # 3. Run tests
    test_results = run_tests(generation.code)

    # 4. Learn from results
    learn_from_feedback(tracking, test_results)

    generation
  end

  private

  def track_retrieval(generation)
    {
      query: generation.query,
      retrieved_patterns: generation.retrieved,
      generated_code: generation.code,
      patterns_used: analyze_which_patterns_used(generation),
      timestamp: Time.current
    }
  end

  def learn_from_feedback(tracking, test_results)
    if test_results.passed?
      # Success: Boost these patterns
      tracking[:patterns_used].each do |pattern|
        pattern.increment_success_count
        pattern.update_success_rate
      end

      # Index the successful generation
      index_as_successful_pattern(tracking[:generated_code])
    else
      # Failure: Reduce confidence in these patterns
      tracking[:patterns_used].each do |pattern|
        pattern.increment_failure_count
        pattern.update_success_rate
      end

      # Don't index failed generation
    end
  end
end
```

### Learning Signals

#### Signal 1: Test Results

**Strong Signal:** Did the generated code pass tests?

```ruby
class TestFeedbackLearner
  def learn_from_test(generation, test_result)
    if test_result.passed?
      # Strong positive signal
      boost_pattern_confidence(generation.patterns, boost: 0.1)

      # Index as successful pattern
      index_successful_generation(generation)
    elsif test_result.failed?
      # Strong negative signal
      reduce_pattern_confidence(generation.patterns, penalty: 0.2)

      # Analyze what went wrong
      failure_analysis = analyze_failure(test_result)

      # Learn from the failure
      index_failure_pattern(generation, failure_analysis)
    end
  end

  private

  def analyze_failure(test_result)
    {
      failure_type: classify_failure(test_result.error),
      missing_patterns: what_should_have_been_retrieved(test_result),
      incorrect_patterns: what_should_not_have_been_used(test_result)
    }
  end
end
```

#### Signal 2: Developer Edits

**Medium Signal:** How did the developer modify generated code?

```ruby
class DeveloperEditLearner
  def learn_from_edit(original, edited)
    # Calculate diff
    diff = calculate_diff(original, edited)

    # Classify edits
    edit_types = classify_edits(diff)

    # Learn patterns
    edit_types.each do |edit|
      case edit.type
      when :added_missing_code
        # We missed something - what pattern should we have retrieved?
        missing_pattern = extract_pattern(edit.added_code)
        index_missing_pattern(missing_pattern, original_query)

      when :removed_incorrect_code
        # We generated something wrong - reduce confidence
        incorrect_pattern = extract_pattern(edit.removed_code)
        reduce_pattern_confidence(incorrect_pattern)

      when :style_fix
        # Our style doesn't match - update style patterns
        style_fix = extract_style_pattern(edit)
        update_style_preferences(style_fix)

      when :refactoring
        # Developer preferred different approach - learn preference
        alternative_pattern = extract_pattern(edit.refactored_code)
        boost_alternative_confidence(alternative_pattern)
      end
    end
  end
end
```

#### Signal 3: PR Reviews

**Strong Signal:** What do code reviewers say about generated code?

```ruby
class PRReviewLearner
  def learn_from_review(pr, comments)
    comments.each do |comment|
      sentiment = analyze_sentiment(comment)

      if sentiment.positive?
        # "Great pattern!" - boost this
        pattern = extract_pattern_from_context(comment)
        boost_pattern_confidence(pattern)

      elsif sentiment.negative?
        # "This shouldn't use X, use Y instead" - learn correction
        correction = extract_correction(comment)

        # Learn: X is wrong, Y is right
        create_anti_pattern(correction.wrong, explanation: comment.text)
        boost_pattern(correction.right, explanation: comment.text)
      end
    end
  end

  private

  def extract_correction(comment)
    # Use LLM to parse code review comments
    # "This should use delegate instead of def method"
    # => { wrong: "def method", right: "delegate" }
  end
end
```

#### Signal 4: Production Performance

**Long-term Signal:** How does generated code perform in production?

```ruby
class ProductionFeedbackLearner
  def learn_from_production(deployed_code)
    metrics = gather_production_metrics(deployed_code)

    {
      # Performance metrics
      response_time: metrics[:avg_response_time],
      error_rate: metrics[:error_count] / metrics[:request_count],

      # Database metrics
      n_plus_one_queries: metrics[:query_count_per_request],

      # Memory usage
      memory_allocation: metrics[:memory_allocated],

      # Modifications over time
      times_modified: count_modifications(deployed_code),
      bug_reports: count_related_bugs(deployed_code)
    }

    # Learn from metrics
    if metrics[:error_rate] > 0.01
      # High error rate - maybe this pattern is problematic
      reduce_pattern_confidence(deployed_code.patterns)
    end

    if metrics[:n_plus_one_queries] > 10
      # N+1 detected - need better eager loading patterns
      flag_for_improvement(deployed_code, issue: :n_plus_one)
    end
  end
end
```

### Continuous Improvement Loop

```ruby
class RAGImprovement
  # Run nightly
  def improve_rag_system
    # 1. Analyze all generations from past 24 hours
    generations = Generation.past_24_hours

    # 2. Calculate pattern success rates
    patterns = Pattern.all
    patterns.each do |pattern|
      pattern.update_metrics!(
        success_rate: calculate_success_rate(pattern),
        usage_frequency: count_usage(pattern),
        avg_edit_distance: calculate_avg_edits(pattern),
        avg_test_pass_rate: calculate_test_rate(pattern)
      )
    end

    # 3. Identify underperforming patterns
    underperforming = patterns.where("success_rate < ?", 0.5)
    underperforming.each do |pattern|
      # Reduce retrieval priority or remove
      pattern.update!(priority: pattern.priority * 0.5)
    end

    # 4. Identify high-performing patterns
    high_performing = patterns.where("success_rate > ?", 0.9)
    high_performing.each do |pattern|
      # Boost retrieval priority
      pattern.update!(priority: pattern.priority * 1.2)
    end

    # 5. Identify missing patterns
    # What queries had low success but no good retrieval?
    missing = find_missing_patterns(generations)
    missing.each do |query|
      # TODO: Extract pattern from manual solutions
      suggest_new_pattern(query)
    end

    # 6. Update embeddings for evolved patterns
    reindex_changed_patterns
  end
end
```

---

## Part IV: AST-Aware Generation

### Beyond Retrieval: AST Manipulation

RAG typically works at the text level:
1. Retrieve code as text
2. Feed text to LLM
3. LLM generates text
4. Parse text to check syntax

**Better approach: Work at AST level throughout**

```ruby
class ASTAwareRAG
  def generate_with_ast(query, project_path)
    # 1. Retrieve AST patterns, not text
    ast_patterns = retrieve_ast_patterns(query)

    # 2. Analyze target codebase structure
    codebase_ast = parse_codebase(project_path)

    # 3. Generate AST structure (not text)
    # LLM generates structural description, we build AST
    structure = llm_generate_structure(query, ast_patterns)
    target_ast = build_ast_from_structure(structure)

    # 4. Adapt AST to match codebase conventions
    adapted_ast = adapt_to_codebase(target_ast, codebase_ast)

    # 5. Generate code from AST
    code = unparse_ast(adapted_ast)

    # 6. Validate at AST level
    validate_ast_semantics(adapted_ast)

    code
  end

  private

  def build_ast_from_structure(structure)
    # Instead of asking LLM to write code,
    # ask it to describe structure, then build AST

    # Example structure:
    # {
    #   type: :class,
    #   name: "UsersController",
    #   inherits: "ApplicationController",
    #   methods: [
    #     {
    #       name: "create",
    #       params: ["user_params"],
    #       structure: {
    #         type: :conditional,
    #         condition: "@user.save",
    #         true_branch: { type: :redirect },
    #         false_branch: { type: :render }
    #       }
    #     }
    #   ]
    # }

    Parser::Ruby31.parse(generate_code_from_structure(structure))
  end

  def adapt_to_codebase(target_ast, codebase_ast)
    # Make surgical AST modifications to match codebase style

    # Example: Codebase uses early returns
    if codebase_prefers_early_returns?(codebase_ast)
      transform_to_early_returns(target_ast)
    end

    # Example: Codebase uses specific method naming
    naming_conventions = extract_naming(codebase_ast)
    rename_methods(target_ast, naming_conventions)

    target_ast
  end
end
```

### AST-Based Refactoring

**The Opportunity:** Surgically modify generated code

```ruby
class ASTRefactorer
  def apply_codebase_conventions(generated_code, codebase_path)
    ast = parse(generated_code)
    conventions = extract_conventions(codebase_path)

    conventions.each do |convention|
      ast = apply_convention(ast, convention)
    end

    unparse(ast)
  end

  private

  def apply_convention(ast, convention)
    case convention.type
    when :prefer_early_returns
      transform_to_early_returns(ast)

    when :prefer_guard_clauses
      add_guard_clauses(ast)

    when :prefer_delegation
      extract_to_delegation(ast)

    when :prefer_query_objects
      extract_to_query_object(ast)

    when :prefer_service_objects
      extract_to_service_object(ast)
    end
  end

  def transform_to_early_returns(ast)
    # Find: if condition then A else B end
    # Transform: return B unless condition; A

    RuboCop::AST::NodePattern.new("(if $_ $_ $_)").match(ast) do |cond, true_branch, false_branch|
      build_early_return(cond, true_branch, false_branch)
    end
  end
end
```

**Example: AST-Level Adaptation**

```ruby
# LLM generates:
def create
  @user = User.new(user_params)
  if @user.save
    redirect_to @user, notice: "User created"
  else
    render :new, status: :unprocessable_entity
  end
end

# AST analyzer detects codebase uses early returns
# AST transformation:
def create
  @user = User.new(user_params)

  unless @user.save
    render :new, status: :unprocessable_entity
    return
  end

  redirect_to @user, notice: "User created"
end

# No LLM involved - pure AST transformation
```

---

## Part V: Living Style Guide

### The Problem with Static Style Guides

Current approach:
1. Extract patterns from codebase
2. Create style guide document
3. Include in LLM prompt
4. Hope LLM follows it

**Problems:**
- Style guides get outdated
- Don't capture pattern evolution
- Can't represent "this is preferred NOW"
- No feedback loop

### Solution: Dynamic Pattern Tracking

```ruby
class LivingStyleGuide
  def current_preferences(project_path)
    # Analyze recent commits (last 3 months)
    recent_patterns = analyze_recent_code(project_path, months: 3)

    # Compare to older code
    historical_patterns = analyze_historical_code(project_path)

    # Detect pattern evolution
    evolution = detect_evolution(recent_patterns, historical_patterns)

    {
      # What's trending up?
      emerging_patterns: evolution.trending_up,

      # What's being phased out?
      deprecated_patterns: evolution.trending_down,

      # What's stable?
      stable_patterns: evolution.stable,

      # What's the current preference?
      current_preference: recent_patterns.most_common
    }
  end

  def detect_evolution(recent, historical)
    patterns = (recent.keys + historical.keys).uniq

    patterns.map do |pattern|
      recent_frequency = recent[pattern] || 0
      historical_frequency = historical[pattern] || 0

      {
        pattern: pattern,
        recent: recent_frequency,
        historical: historical_frequency,
        trend: calculate_trend(recent_frequency, historical_frequency)
      }
    end
  end

  def calculate_trend(recent, historical)
    if historical.zero?
      :new_pattern
    elsif recent > historical * 1.5
      :trending_up
    elsif recent < historical * 0.5
      :trending_down
    else
      :stable
    end
  end
end
```

### Pattern Evolution Examples

```ruby
# Example 1: Service Object Pattern Evolution

# Historical (2 years ago): Simple class methods
class UserRegistrationService
  def self.call(params)
    User.create(params)
  end
end

# Recent (3 months): Callable concern, explicit transactions, result objects
class UserRegistrationService
  include Callable

  def initialize(params)
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      user = User.create!(@params)
      ServiceResult.success(user: user)
    end
  rescue => e
    ServiceResult.failure(error: e.message)
  end
end

# Living Style Guide tracks:
{
  pattern: "service_objects",
  historical_style: "class methods",
  current_style: "Callable + transactions + ServiceResult",
  trend: :evolved,
  recommendation: "Use current style for new code",
  migration_status: "78% migrated to new style"
}
```

### Deprecation Detection

```ruby
class DeprecationDetector
  def detect_deprecated_patterns(project_path)
    # Patterns that used to be common but are disappearing

    patterns_over_time = analyze_pattern_frequency_over_time(project_path)

    patterns_over_time.select do |pattern, timeline|
      # Used to be common (>50% usage)
      was_common = timeline.first > 0.5

      # Now rare (<10% usage)
      now_rare = timeline.last < 0.1

      # Declining trend
      declining = timeline.each_cons(2).all? { |a, b| b <= a }

      was_common && now_rare && declining
    end
  end
end

# Example detected deprecations:
{
  "Sidekiq": {
    peak_usage: "2023-01: 89%",
    current_usage: "2025-01: 3%",
    status: :deprecated,
    replacement: "SolidQueue",
    migration_guide: "..."
  },

  "before_filter": {
    peak_usage: "2021-01: 67%",
    current_usage: "2025-01: 0%",
    status: :obsolete,
    replacement: "before_action"
  }
}
```

### Proactive Pattern Recommendations

```ruby
class PatternRecommendation
  def recommend_for_query(query, project_path)
    # Analyze what the query needs
    query_intent = classify_intent(query)

    # Find current team preference for this intent
    current_approach = find_current_approach(query_intent, project_path)

    # Find alternative approaches
    alternatives = find_alternatives(query_intent)

    # Compare
    {
      recommended: current_approach,
      reason: "Your team currently uses this in #{current_approach.usage_percent}% of similar cases",

      alternatives: alternatives.map do |alt|
        {
          approach: alt,
          usage: alt.usage_percent,
          pros: alt.advantages,
          cons: alt.disadvantages,
          migration_effort: alt.migration_cost
        }
      end,

      community_trend: community_preference(query_intent)
    }
  end
end

# Example recommendation:
{
  query: "Add background job for email sending",

  recommended: {
    approach: "SolidQueue with perform_later",
    reason: "Your team uses this in 95% of background jobs",
    example: "UserMailer.welcome_email(user).deliver_later"
  },

  alternatives: [
    {
      approach: "Sidekiq",
      usage: "5% (legacy code)",
      status: :deprecated,
      message: "Team is migrating away from Sidekiq"
    }
  ],

  community_trend: {
    approach: "SolidQueue",
    adoption: "Growing rapidly in Rails 8+",
    reason: "Rails 8 default, zero-dependency"
  }
}
```

---

## Part VI: Explainable RAG

### The Trust Problem

Black box systems don't build trust. Developers need to know:
- Why did RAG retrieve these patterns?
- Where did they come from?
- How confident should I be?
- What alternatives exist?

### Solution: Retrieval Provenance

```ruby
class ExplainableRetrieval
  def retrieve_with_explanation(query)
    results = retrieve(query)

    results.map do |result|
      {
        code: result.code,

        # Provenance: Where did this come from?
        source: {
          repository: result.repo_name,
          file: result.file_path,
          url: github_url(result),
          stars: result.repo_stars,
          quality_score: result.quality
        },

        # Relevance: Why was this retrieved?
        relevance: {
          similarity_score: result.similarity,
          matched_intent: result.intent_match,
          matched_patterns: result.pattern_matches,
          ranking_factors: explain_ranking(result)
        },

        # Usage: How common is this?
        usage: {
          frequency: "Used in #{result.usage_percent}% of production Rails apps",
          examples: result.example_repos,
          community_rating: result.community_score
        },

        # Confidence: How sure are we?
        confidence: {
          retrieval_confidence: result.retrieval_score,
          quality_confidence: result.quality_score,
          applicability_confidence: estimate_applicability(result, query),
          overall: calculate_overall_confidence(result)
        },

        # Alternatives: What else could work?
        alternatives: find_alternatives(result),

        # Context: What else should I know?
        context: {
          when_to_use: result.use_cases,
          when_not_to_use: result.anti_patterns,
          tradeoffs: result.tradeoffs,
          related_patterns: result.related
        }
      }
    end
  end

  private

  def explain_ranking(result)
    [
      "Semantic similarity: #{result.similarity_score}",
      "Quality score: #{result.quality_score}",
      "Usage frequency: #{result.usage_frequency}",
      "Recency: #{result.recency_score}",
      "Team preference: #{result.team_score}"
    ]
  end
end
```

### Generation Trace

```ruby
class GenerationTrace
  def trace_generation(query, generated_code)
    {
      query: query,
      generated: generated_code,

      # What was retrieved?
      retrieved_patterns: trace_retrieval,

      # What patterns were actually used?
      patterns_used: analyze_pattern_usage(generated_code),

      # What influenced the generation?
      influences: [
        {
          source: "Discourse app/controllers/users_controller.rb",
          influence: "Authentication pattern",
          confidence: 0.89,
          lines: [12, 15, 18]  # Which lines came from this?
        },
        {
          source: "Your team's BaseController",
          influence: "Error handling",
          confidence: 0.95,
          lines: [25, 28]
        },
        {
          source: "Rails Guides",
          influence: "Strong parameters pattern",
          confidence: 0.92,
          lines: [34, 38]
        }
      ],

      # What alternatives were considered?
      alternatives_considered: [
        {
          approach: "Service object instead of controller logic",
          reason_not_chosen: "Query was specifically for controller",
          would_use_if: "Query asked for business logic extraction"
        }
      ],

      # What decisions were made?
      decisions: [
        {
          decision: "Used before_action for authentication",
          rationale: "Team uses this in 89% of controllers",
          alternatives: ["Inline authentication check"]
        },
        {
          decision: "Used strong parameters",
          rationale: "Required by Rails security best practices",
          alternatives: ["Manual parameter filtering"]
        }
      ]
    }
  end
end
```

### Visualization: Show the Retrieval Process

```ruby
class RetrievalVisualization
  def visualize(query, results)
    <<~VISUALIZATION
    Query: "#{query}"

    🔍 Retrieval Process:

    1. Intent Analysis
       └─ Detected: "Create authenticated REST endpoint"
       └─ Confidence: 94%

    2. Multi-Layer Retrieval
       ├─ Architecture Layer
       │  └─ Found: REST resource patterns (3 results)
       ├─ Pattern Layer
       │  └─ Found: Authentication patterns (5 results)
       ├─ Implementation Layer
       │  └─ Found: Controller create actions (8 results)
       └─ Team Layer
          └─ Found: Your team's controller patterns (4 results)

    3. Ranking & Selection
       ├─ Top Result: Discourse UsersController#create
       │  ├─ Similarity: 0.89
       │  ├─ Quality: 95/100
       │  ├─ Usage: 87% of production apps
       │  └─ Team Match: High (uses same base controller)
       │
       ├─ Second: Your team's ProductsController#create
       │  ├─ Similarity: 0.92
       │  ├─ Quality: 88/100
       │  ├─ Usage: N/A (internal)
       │  └─ Team Match: Perfect (same codebase)
       │
       └─ Third: Rails Guides controller example
          ├─ Similarity: 0.85
          ├─ Quality: 90/100
          ├─ Usage: Reference implementation
          └─ Team Match: Medium

    4. Pattern Synthesis
       └─ Combined: Team structure + Discourse auth + Rails conventions

    5. Generation
       └─ Created 48 lines of code
       └─ Used patterns from: 3 sources
       └─ Confidence: 91%

    📊 Breakdown by Source:
    ┌─────────────────────────────┬──────┬────────────┐
    │ Source                      │Lines │ Confidence │
    ├─────────────────────────────┼──────┼────────────┤
    │ Your team (ProductsCtrl)    │  65% │      95%   │
    │ Discourse (UsersCtrl)       │  25% │      89%   │
    │ Rails Guides                │  10% │      90%   │
    └─────────────────────────────┴──────┴────────────┘

    ✅ Validation: All patterns verified against TEAM_RULES.md
    ✅ Security: Passed Brakeman static analysis
    ✅ Style: RuboCop score 94/100 (2 minor offenses auto-fixed)
    VISUALIZATION
  end
end
```

### Interactive Exploration

```ruby
# CLI interaction to explore retrieval

$ rails-ai generate "Create admin user endpoint" --explain

Generated code: app/controllers/admin/users_controller.rb

📋 Press 'e' to explain retrieval process
📋 Press 's' to show alternative patterns
📋 Press 'c' to compare with community approaches
📋 Press 't' to see test patterns
📋 Press 'q' to continue

> e

🔍 Retrieval Explanation:

This code was generated by combining patterns from:

1. Your team's app/controllers/admin/base_controller.rb (95% match)
   Why: Provides admin authentication and authorization pattern
   Lines influenced: 1-3, 12-15

2. Discourse admin/users_controller.rb (87% match)
   Why: Similar functionality (admin user management)
   Lines influenced: 18-25, 34-40

3. Rails Guides: Admin namespace pattern (82% match)
   Why: Best practice for admin controller structure
   Lines influenced: 1-2, namespace structure

Alternative patterns considered but not used:
- Service object approach (reason: query was controller-specific)
- Pundit policy (reason: team uses custom authorization)

> c

🌍 Community Comparison:

Your generated code vs community approaches:

✅ Same: RESTful structure (98% of prod apps)
✅ Same: Admin namespace (91% of admin interfaces)
✅ Same: Strong parameters (99.8% of controllers)
⚠️  Different: Authorization method
   └─ Your team: custom authorize_admin!
   └─ Community: Pundit/CanCanCan (76% of apps)
   └─ Rationale: Respecting team conventions

📊 Community pattern adoption:
- Admin namespacing: 91%
- Authentication before_action: 96%
- Strong params: 99.8%
- Service objects for complex logic: 67%

> t

🧪 Test Patterns:

For this generated controller, recommended test patterns:

1. Your team's pattern (from test/controllers/admin/products_controller_test.rb):
   - Uses test helpers: sign_in_as_admin
   - Tests authorization explicitly
   - Uses assert_difference for creation
   - Checks flash messages

2. Alternative patterns:
   - RSpec style (not used: team uses Minitest)
   - FactoryBot (not used: team uses fixtures)

Generated test file: test/controllers/admin/users_controller_test.rb
Based on: 95% team conventions + 5% Rails testing guide

```

---

## Part VII: Integration with Existing rails-ai Architecture

### How RAG Enhances Each Agent

#### 1. Architect Agent

**Current:** Coordinates other agents, enforces TEAM_RULES.md
**With RAG:** Architect becomes pattern-aware coordinator

```ruby
# Before RAG
@architect: "Create user authentication"
└─> Delegates to @backend, @frontend, @tests
└─> Checks against TEAM_RULES.md
└─> Reviews output

# After RAG
@architect: "Create user authentication"
├─> Queries RAG for architectural patterns
│   └─> Retrieves: "Auth architecture from Discourse, GitLab, Team codebase"
│   └─> Synthesizes: "Use Devise + Pundit, team pattern"
├─> Creates enhanced delegation plan
│   ├─> @backend: "Implement auth with Devise per team pattern"
│   ├─> @frontend: "Add login form matching team's auth pages"
│   └─> @tests: "Test auth matching team's auth_test_helper.rb"
├─> Each agent receives RAG-enhanced context
└─> Validates against TEAM_RULES.md + RAG quality checks
```

**Integration:**

```ruby
class ArchitectAgent
  def initialize
    @rag = MultiLayerRAG.new
    @team_rules = TeamRules.load
  end

  def process(user_request)
    # 1. Get architectural context from RAG
    architecture = @rag.retrieve_architecture(user_request)

    # 2. Check against team rules
    validate_against_rules(architecture, @team_rules)

    # 3. Create enhanced delegation plan
    plan = create_delegation_plan(user_request, architecture)

    # 4. Delegate with RAG context
    plan.tasks.each do |task|
      agent = select_agent(task)
      rag_context = @rag.retrieve_for_task(task)

      agent.execute(task, context: rag_context)
    end

    # 5. Review with RAG quality checks
    validate_output_quality(plan)
  end
end
```

#### 2. Backend Agent

**Current:** Implements models, controllers, services
**With RAG:** Retrieves implementation patterns

```ruby
class BackendAgent
  def initialize
    @rag = MultiLayerRAG.new
  end

  def generate_controller(specification)
    # Retrieve relevant patterns
    patterns = @rag.retrieve_all(
      specification.description,
      project_path: specification.project_path,
      layers: [:pattern, :implementation, :team, :integration]
    )

    # Synthesize guidance
    guidance = @rag.synthesize_guidance(patterns)

    # Generate with RAG context
    code = generate_with_context(specification, guidance)

    # Validate against retrieved patterns
    validate_pattern_match(code, patterns)

    code
  end
end
```

#### 3. Frontend Agent

**Current:** Generates views, Hotwire components
**With RAG:** Learns team's UI patterns

```ruby
class FrontendAgent
  def initialize
    @rag = MultiLayerRAG.new
  end

  def generate_view(specification)
    # Retrieve team's frontend patterns
    patterns = @rag.retrieve_all(
      specification.description,
      project_path: specification.project_path,
      layers: [:pattern, :team, :integration],
      focus: :frontend  # Frontend-specific retrieval
    )

    # Analyze team's view patterns
    team_patterns = analyze_team_views(specification.project_path)

    # Generate matching team's style
    view_code = generate_with_context(
      specification,
      patterns: patterns,
      team_style: team_patterns
    )

    view_code
  end

  private

  def analyze_team_views(project_path)
    {
      # What helpers does team use?
      helpers: extract_common_helpers(project_path),

      # What layout patterns?
      layouts: analyze_layouts(project_path),

      # What component library? (ViewComponent, Phlex, etc)
      component_library: detect_component_library(project_path),

      # What CSS framework? (Tailwind, Bootstrap, etc)
      css_framework: detect_css_framework(project_path),

      # How are forms structured?
      form_patterns: analyze_form_patterns(project_path)
    }
  end
end
```

#### 4. Tests Agent

**Current:** Generates Minitest tests
**With RAG:** Matches team's test patterns exactly

```ruby
class TestsAgent
  def initialize
    @rag = MultiLayerRAG.new
  end

  def generate_tests(code, specification)
    # Retrieve test patterns
    test_patterns = @rag.retrieve_all(
      "tests for #{specification.description}",
      project_path: specification.project_path,
      layers: [:test, :team],
      focus: :testing
    )

    # CRITICAL: Analyze team's test suite
    team_test_style = analyze_team_tests(specification.project_path)

    # Generate tests matching team's exact style
    tests = generate_tests_with_style(
      code: code,
      patterns: test_patterns,
      style: team_test_style
    )

    tests
  end

  private

  def analyze_team_tests(project_path)
    {
      # Minitest or RSpec? (from TEAM_RULES: must be Minitest)
      framework: :minitest,

      # What's in test_helper.rb?
      test_helper: parse_test_helper(project_path),

      # What custom assertions/helpers?
      custom_helpers: extract_test_helpers(project_path),

      # How are tests organized?
      organization: analyze_test_organization(project_path),

      # What assertion style?
      assertion_style: detect_assertion_style(project_path),

      # How are factories/fixtures used?
      fixtures: analyze_fixtures(project_path),

      # Integration test patterns?
      integration_patterns: analyze_integration_tests(project_path)
    }
  end
end
```

#### 5. Security Agent

**Current:** Runs Brakeman, checks for vulnerabilities
**With RAG:** Proactive security pattern enforcement

```ruby
class SecurityAgent
  def initialize
    @rag = MultiLayerRAG.new
  end

  def audit_code(code, specification)
    # Standard security scan
    brakeman_results = run_brakeman(code)

    # RAG-enhanced security check
    security_patterns = @rag.retrieve_all(
      "security issues in #{specification.description}",
      project_path: specification.project_path,
      layers: [:security],
      focus: :vulnerabilities
    )

    # Check against known vulnerability patterns
    vulnerability_analysis = analyze_against_known_issues(
      code,
      security_patterns
    )

    # Suggest secure alternatives if issues found
    if vulnerability_analysis.issues.any?
      secure_alternatives = retrieve_secure_alternatives(
        vulnerability_analysis.issues
      )

      {
        issues: vulnerability_analysis.issues,
        fixes: secure_alternatives,
        explanation: explain_security_issues(vulnerability_analysis)
      }
    else
      { status: :secure }
    end
  end
end
```

#### 6. Debug Agent

**Current:** Analyzes errors, suggests fixes
**With RAG:** Retrieves similar error patterns and solutions

```ruby
class DebugAgent
  def initialize
    @rag = MultiLayerRAG.new
  end

  def debug_error(error, context)
    # Classify error
    error_type = classify_error(error)

    # Retrieve similar errors and solutions
    similar_issues = @rag.retrieve_all(
      "error: #{error.message}",
      project_path: context.project_path,
      layers: [:implementation, :team],
      focus: :debugging
    )

    # Find how similar errors were solved
    solutions = analyze_solutions(similar_issues)

    # Generate fix
    fix = generate_fix(error, solutions, context)

    {
      error: error,
      diagnosis: explain_error(error, similar_issues),
      solution: fix,
      similar_cases: similar_issues,
      confidence: calculate_fix_confidence(fix, similar_issues)
    }
  end
end
```

### Integration with Skills System

**Current:** 41 modular skills (frontend, backend, testing, etc)
**With RAG:** Skills enhanced with retrieval

```ruby
module Skills
  class SkillWithRAG
    def initialize
      @rag = MultiLayerRAG.new
    end

    def execute(context)
      # Get skill-specific patterns from RAG
      patterns = @rag.retrieve_for_skill(
        skill_name: self.class.name,
        context: context
      )

      # Execute skill with RAG context
      execute_with_context(context, patterns)
    end
  end
end

# Example: Service Object Skill
module Skills
  module Backend
    class ServiceObjectSkill < SkillWithRAG
      def execute(context)
        # Retrieve service object patterns
        patterns = @rag.retrieve_all(
          "service object for #{context.description}",
          project_path: context.project_path,
          layers: [:pattern, :implementation, :team]
        )

        # Find team's service object conventions
        team_pattern = patterns.find { |p| p.source == :team }

        if team_pattern
          # Team has established pattern - use it
          generate_service_object_with_team_pattern(context, team_pattern)
        else
          # Team doesn't have pattern yet - use community best practice
          generate_service_object_with_community_pattern(context, patterns)
        end
      end
    end
  end
end
```

### Integration with TEAM_RULES.md

**Critical: RAG Must Enforce Rules**

```ruby
class RAGWithRules
  def initialize
    @rag = MultiLayerRAG.new
    @team_rules = TeamRules.load
  end

  def retrieve_and_validate(query, project_path)
    # Retrieve patterns
    patterns = @rag.retrieve_all(query, project_path)

    # Filter out rule violations
    compliant_patterns = patterns.select do |pattern|
      validate_against_rules(pattern)
    end

    # Add rule-enforcing context
    add_rule_context(compliant_patterns)
  end

  private

  def validate_against_rules(pattern)
    # Rule 1: No Sidekiq
    return false if pattern.code.include?("Sidekiq")

    # Rule 2: No RSpec
    return false if pattern.code.include?("RSpec")

    # Rule 3: No custom route actions
    return false if pattern.code.match?(/member|collection do/)

    # All other rules...
    true
  end

  def add_rule_context(patterns)
    patterns.map do |pattern|
      pattern.merge(
        rules_applied: applicable_rules(pattern),
        alternatives: find_rule_compliant_alternatives(pattern)
      )
    end
  end
end
```

---

## Part VIII: Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)

**Goal:** Basic multi-layer retrieval working

```ruby
# Milestone 1.1: Storage schema
rails generate model CodePattern \
  content:text \
  embedding:vector{1536} \
  layer:string \
  source_repo:string \
  quality_score:integer \
  metadata:jsonb

rails generate model TeamPattern \
  content:text \
  embedding:vector{1536} \
  frequency:float \
  last_used:datetime \
  success_rate:float \
  metadata:jsonb

# Milestone 1.2: Basic indexing
class IndexerService
  def index_repository(repo_url)
    # Clone repo
    # Parse code
    # Generate embeddings
    # Store in database
  end
end

# Milestone 1.3: Simple retrieval
class SimpleRetrieval
  def retrieve(query, k: 5)
    embedding = embed(query)
    CodePattern.nearest_neighbors(:embedding, embedding).limit(k)
  end
end

# Success criteria:
# - Can index Rails repository
# - Can retrieve similar code
# - Embeddings stored in SQLite
```

### Phase 2: Multi-Layer Retrieval (Weeks 3-4)

**Goal:** All 7 retrieval layers operational

```ruby
# Milestone 2.1: Layer-specific indexing
class ArchitecturalIndexer < BaseIndexer
  def index(content)
    # Extract architectural concepts
    # Store with layer: :architecture
  end
end

class PatternIndexer < BaseIndexer
  def index(content)
    # Extract patterns with intent
    # Store with layer: :pattern
  end
end

# ... 5 more indexers

# Milestone 2.2: Multi-layer retrieval
class MultiLayerRetrieval
  def retrieve_all(query, layers: LAYERS.all)
    layers.map do |layer|
      send("retrieve_#{layer}", query)
    end.flatten
  end
end

# Success criteria:
# - All 7 layers retrieving
# - Results ranked correctly
# - Layer-specific logic working
```

### Phase 3: Intent-Based Retrieval (Weeks 5-6)

**Goal:** Understand intent, not just similarity

```ruby
# Milestone 3.1: Intent extraction
class IntentAnalyzer
  def analyze(query)
    # Use LLM to extract intent
    # "Create API endpoint" → intent: [:rest, :api, :crud]
  end
end

# Milestone 3.2: Intent-based indexing
class IntentIndexer
  def index_with_intent(code)
    {
      code: code,
      intent: extract_intent(code),
      use_cases: extract_use_cases(code),
      when_to_use: extract_conditions(code)
    }
  end
end

# Milestone 3.3: Intent-aware retrieval
class IntentRetrieval
  def retrieve(query)
    query_intent = analyze_intent(query)

    patterns = CodePattern.where("metadata->'intent' @> ?", query_intent.to_json)

    rank_by_intent_match(patterns, query_intent)
  end
end

# Success criteria:
# - Intent extracted from queries
# - Intent-based ranking working
# - Higher accuracy than pure similarity
```

### Phase 4: Team Context (Weeks 7-8)

**Goal:** Learn and apply team-specific patterns

```ruby
# Milestone 4.1: Team pattern extraction
class TeamPatternExtractor
  def extract(project_path)
    # Analyze codebase
    # Extract patterns
    # Calculate frequencies
    # Store as high-priority patterns
  end
end

# Milestone 4.2: Team-aware retrieval
class TeamAwareRetrieval
  def retrieve(query, project_path)
    # Check team patterns first
    team_patterns = TeamPattern.where(project: project_path).search(query)

    # Then community patterns
    community_patterns = CodePattern.search(query)

    # Merge with priority
    merge_with_priority(team_patterns, community_patterns)
  end
end

# Success criteria:
# - Team patterns indexed
# - Team patterns prioritized
# - Generated code matches team style
```

### Phase 5: AST-Aware Generation (Weeks 9-10)

**Goal:** Generate and manipulate at AST level

```ruby
# Milestone 5.1: AST indexing
class ASTIndexer
  def index(code)
    ast = Parser::Ruby31.parse(code)
    signature = extract_ast_signature(ast)

    store_with_ast(code, ast, signature)
  end
end

# Milestone 5.2: AST retrieval
class ASTRetrieval
  def retrieve_by_structure(query)
    target_structure = extract_structure_intent(query)

    CodePattern.where("metadata->'ast_signature' @> ?", target_structure.to_json)
  end
end

# Milestone 5.3: AST transformation
class ASTTransformer
  def adapt_to_codebase(generated_ast, project_path)
    team_conventions = extract_ast_conventions(project_path)
    apply_conventions(generated_ast, team_conventions)
  end
end

# Success criteria:
# - AST-based retrieval working
# - Style-invariant matching
# - Automatic style adaptation
```

### Phase 6: Self-Improving Loop (Weeks 11-12)

**Goal:** Learn from every generation

```ruby
# Milestone 6.1: Feedback tracking
class FeedbackTracker
  def track_generation(generation)
    Generation.create!(
      query: generation.query,
      retrieved_patterns: generation.patterns,
      generated_code: generation.code,
      timestamp: Time.current
    )
  end

  def track_test_result(generation, test_result)
    generation.update!(
      test_passed: test_result.passed?,
      test_output: test_result.output
    )

    learn_from_result(generation, test_result)
  end
end

# Milestone 6.2: Pattern confidence tracking
class PatternConfidence
  def update_from_feedback(pattern, feedback)
    if feedback.positive?
      pattern.increment!(:success_count)
    else
      pattern.increment!(:failure_count)
    end

    pattern.update!(
      success_rate: calculate_success_rate(pattern)
    )
  end
end

# Milestone 6.3: Continuous improvement
class ContinuousImprovement
  def improve_daily
    # Analyze past 24 hours
    # Update pattern confidences
    # Identify gaps
    # Reindex if needed
  end
end

# Success criteria:
# - Feedback loop operational
# - Pattern confidence tracked
# - System improves over time
```

### Phase 7: Agent Integration (Weeks 13-14)

**Goal:** RAG fully integrated with all agents

```ruby
# Milestone 7.1: Update each agent
# - architect.md
# - backend.md
# - frontend.md
# - tests.md
# - security.md
# - debug.md

# Milestone 7.2: RAG skill system
module Skills
  class RAGEnabledSkill
    def execute_with_rag(context)
      patterns = retrieve_patterns(context)
      execute_with_context(context, patterns)
    end
  end
end

# Milestone 7.3: End-to-end workflow
# User request → Architect (with RAG) → Specialist agents (with RAG) →
# Generation (RAG-enhanced) → Tests → Feedback → Learning

# Success criteria:
# - All agents using RAG
# - Improved Pass@1 rate
# - Better code quality scores
```

### Phase 8: Polish & Explainability (Weeks 15-16)

**Goal:** Production-ready with transparency

```ruby
# Milestone 8.1: Explainable retrieval
class ExplainableRAG
  def generate_with_explanation(query)
    # Generate
    result = generate(query)

    # Explain
    explanation = explain_generation(result)

    { code: result, explanation: explanation }
  end
end

# Milestone 8.2: CLI visualization
# Interactive exploration of retrieval process

# Milestone 8.3: Documentation
# - User guide
# - Integration guide
# - Customization guide

# Success criteria:
# - Developers understand retrieval
# - Trust in system improves
# - Adoption increases
```

---

## Part IX: Success Metrics

### Beyond Pass@1: Holistic Quality Measurement

#### Tier 1: Functional Correctness

```ruby
{
  pass_at_1: "Does generated code pass tests on first try?",
  target: "70-85%",

  pass_at_3: "Does it pass within 3 attempts?",
  target: "90%+",

  syntax_correctness: "Is Ruby syntax valid?",
  target: "99.9%",

  test_coverage: "Does generated code include tests?",
  target: "100%"
}
```

#### Tier 2: Code Quality

```ruby
{
  rubocop_score: "Does it pass RuboCop?",
  target: "90%+ first-pass",

  rubocop_auto_fixable: "Can violations be auto-fixed?",
  target: "95% of violations",

  complexity: "Cyclomatic complexity per method",
  target: "<10",

  duplication: "Code duplication percentage",
  target: "<5%"
}
```

#### Tier 3: Idiomatic Rails

```ruby
{
  rails_conventions: "Follows Rails conventions?",
  target: "95%+",
  measurement: "Manual review + pattern analysis",

  rest_compliance: "Uses RESTful routing only?",
  target: "100%",
  measurement: "Route analysis",

  solid_stack: "Uses Rails 8 Solid Stack?",
  target: "100%",
  measurement: "Dependency analysis"
}
```

#### Tier 4: Team Alignment

```ruby
{
  team_pattern_match: "Matches team's existing patterns?",
  target: "80%+",
  measurement: "AST similarity to existing code",

  naming_consistency: "Uses team's naming conventions?",
  target: "95%+",
  measurement: "Pattern analysis",

  structure_consistency: "Matches team's file organization?",
  target: "100%",
  measurement: "Directory structure analysis"
}
```

#### Tier 5: Developer Experience

```ruby
{
  edit_distance: "How much developer editing required?",
  target: "<20% of generated code",
  measurement: "Git diff analysis",

  time_to_working: "Time from generation to working code",
  target: "<5 minutes",
  measurement: "Timestamp tracking",

  developer_satisfaction: "Would you use this code?",
  target: "4+/5 average",
  measurement: "Developer surveys",

  pr_approval_rate: "Does code pass PR review?",
  target: "80%+",
  measurement: "PR outcome tracking"
}
```

#### Tier 6: System Learning

```ruby
{
  pattern_success_rate: "Are retrieved patterns used successfully?",
  target: "Improving over time",
  measurement: "Track pattern → outcome correlation",

  retrieval_accuracy: "Are retrieved patterns relevant?",
  target: "90%+ relevance",
  measurement: "Manual review + usage tracking",

  system_improvement: "Is Pass@1 improving?",
  target: "+5% per quarter",
  measurement: "Longitudinal tracking"
}
```

### Evaluation Protocol

```ruby
class EvaluationProtocol
  # Daily evaluation
  def evaluate_daily
    generations = Generation.where(created_at: 1.day.ago..Time.current)

    {
      total_generations: generations.count,
      pass_at_1_rate: calculate_pass_rate(generations),
      avg_rubocop_score: calculate_avg_rubocop(generations),
      avg_edit_distance: calculate_edit_distance(generations),
      pattern_success_rates: calculate_pattern_success(generations)
    }
  end

  # Weekly evaluation
  def evaluate_weekly
    generations = Generation.where(created_at: 1.week.ago..Time.current)

    {
      **evaluate_daily,
      developer_satisfaction: survey_developers(generations),
      pr_approval_rate: calculate_pr_rate(generations),
      system_learning_rate: calculate_improvement_rate
    }
  end

  # Monthly evaluation
  def evaluate_monthly
    {
      **evaluate_weekly,
      longitudinal_improvement: track_improvement_over_time,
      pattern_evolution: analyze_pattern_changes,
      codebase_alignment: measure_codebase_similarity,
      roi_analysis: calculate_time_saved
    }
  end
end
```

---

## Part X: The North Star

### What Success Looks Like

**6 Months:**
- RAG system operational across all agents
- Pass@1 rate: 70%+
- Developers trust the system
- Code matches team patterns 80%+ of the time
- System learning from feedback

**12 Months:**
- Pass@1 rate: 80%+
- Team patterns fully captured
- Living style guide updating automatically
- Developers rarely edit generated code
- System proactively suggests improvements

**18 Months:**
- Pass@1 rate: 85%+
- Rails code generation as good as Next.js
- System understands architectural intent
- Can generate complete features end-to-end
- Community-contributed pattern library

### The Ultimate Vision

RAG becomes **the missing link between developer intent and Rails code**.

Imagine:

```
Developer: "Add Stripe payments with webhooks"

Rails-AI (RAG-powered):
"I analyzed 147 production payment implementations.

Your team hasn't done payment processing yet, so I'll combine:
- Stripe integration from Discourse (87% similarity)
- Webhook handling from GitLab (92% similarity)
- Idempotency pattern from your OrdersController

I'll generate:
1. PaymentsController (RESTful, matches your admin pattern)
2. StripeWebhookController (with signature verification)
3. PaymentProcessor service (uses your Callable pattern)
4. Tests (matches your test_helper.rb patterns)
5. Migration (follows your schema conventions)

Security checks:
✅ Webhook signature verification
✅ Idempotency keys
✅ PCI compliance patterns
✅ No secrets in code

Confidence: 91%

Want me to:
[1] Generate this approach
[2] Show alternative patterns
[3] Explain security considerations
[4] Compare with community approaches

> 1

Generating... Done.

Generated 347 lines across 6 files.
Tests: 18/18 passing
RuboCop: 94/100 (2 minor issues auto-fixed)
Security: No issues found

Retrieval breakdown:
- 65% from your team's patterns
- 25% from Discourse
- 10% from Rails guides

Would you like me to explain any part of this?"
```

This isn't science fiction. Every piece described in this document is **buildable with current technology**.

### The Difference

**Before RAG:**
LLMs guessing based on training data, often outdated, inconsistent with team patterns

**After RAG:**
Contextual intelligence that knows:
- What your team does
- What production Rails apps do
- What the Rails core team recommends
- What security experts warn against
- When patterns are deprecated
- How to adapt patterns to your context

**The Result:**
Code that feels like it was written by a senior Rails developer who:
- Has read every great Rails codebase
- Knows your team's conventions
- Stays current with Rails 8
- Never forgets a pattern
- Explains every decision
- Learns from every mistake
- Gets better every day

---

## Conclusion: RAG as Contextual Intelligence

The research got us started. This vision takes us to the finish line.

RAG isn't just retrieval. It's:
- **Multi-dimensional context** at every layer of abstraction
- **Intent understanding** not just similarity matching
- **Living patterns** that evolve with your codebase
- **Self-improvement** from every generation
- **AST-aware** manipulation for surgical precision
- **Team-specific** learning and adaptation
- **Transparent** reasoning developers can trust

This is the foundation for Phase 4: Fully Autonomous Rails.

**Next Steps:**
1. Review this vision with the team
2. Prioritize which innovations to tackle first
3. Start with Phase 1 implementation
4. Iterate based on results
5. Build the future of Rails AI development

The pieces are all here. Let's build it.

---

**Document Status:** Vision - Ready for Implementation Planning

**Related Documents:**
- [Executive Summary](./01-rag-vision-executive-summary.md) - Quick overview of 10 innovations
- [Vision Overview](./00-vision-rag.md) - Consolidated vision document
- [Research Report](./llm-rails-accuracy-research-report.md) - Comprehensive research analysis

**Author:** Claude (Sr. LLM with delusions of grandeur)
**Review Required:** Human validation and prioritization
**Next Action:** Break into actionable tasks and begin Phase 1
