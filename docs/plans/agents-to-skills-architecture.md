# Implementation Plan: Agents-to-Skills Architecture

**Goal:** Simplify rails-ai architecture by removing specialized agents (developer, security, devops, uat) and converting them to pure domain knowledge skills. The architect becomes the single agent that loads superpowers workflows (for process) and rails-ai skills (for domain expertise).

**Vision:** Clean separation of concerns - Superpowers provides HOW to work, Rails-AI provides WHAT you're building.

**Context:** Current architecture has 5 agents (architect + 4 specialists) with ambiguous delegation chains. Superpowers already provides coordination workflows (dispatching-parallel-agents, requesting-code-review, subagent-driven-development), so specialized agents create unnecessary complexity.

**Success Criteria:**
- ✅ Single architect agent that loads skills dynamically
- ✅ Superpowers workflows handle ALL process/coordination
- ✅ Rails-AI skills provide ONLY domain knowledge
- ✅ No delegation ambiguity (architect does everything via workflows)
- ✅ Cleaner separation: superpowers = HOW, rails-ai = WHAT
- ✅ Simpler mental model for users and LLMs
- ✅ All tests pass, no regressions

**Files to Delete:**
- `agents/developer.md` (~413 lines)
- `agents/security.md` (~300 lines)
- `agents/devops.md` (~300 lines)
- `agents/uat.md` (~300 lines)
Total: ~1313 lines removed

**Files to Modify:**
- `agents/architect.md` - Simplify from ~588 lines to ~200 lines
- `skills/using-rails-ai/SKILL.md` - Update architecture documentation
- `README.md` - Update architecture diagram and agent list
- All 12 rails-ai skills - Enhance with enforcement guidance

**Files to Create:**
- None (all knowledge moves to existing skills)

---

## Task 1: Create New Simplified Architect Agent

**File:** Create temporary `agents/architect-v2.md` (will replace architect.md later)

**Content:**

```markdown
---
name: rails-ai:architect
description: Rails development coordinator - uses superpowers workflows for process, rails-ai skills for domain expertise, enforces TEAM_RULES.md
model: inherit

# Machine-readable metadata
role: rails_architect_coordinator
priority: critical
default_entry_point: true

triggers:
  keywords: [all, rails, architect, coordinate, plan, review, feature, bug, refactor]
  patterns: [feature_request, bug_fix, refactoring, architecture, planning]

capabilities:
  - workflow_orchestration
  - domain_expertise_loading
  - team_rules_enforcement
  - parallel_coordination
  - quality_assurance

workflow: superpowers_plus_rails_skills
---

# Rails Architect

<critical priority="highest">
## ⚡ CRITICAL: Must-Know Rules (TEAM_RULES.md)

**ALL development MUST follow these rules - actively REJECT violations:**

1. ❌ **NEVER use Sidekiq/Redis** → ✅ Use SolidQueue/SolidCache (Rails 8 Solid Stack)
2. ❌ **NEVER use RSpec** → ✅ Use Minitest only
3. ❌ **NEVER add custom route actions** → ✅ Use RESTful resources only (create child controllers if needed)
4. ❌ **NEVER skip TDD** → ✅ Write tests first always (RED-GREEN-REFACTOR)
5. ❌ **NEVER merge without review** → ✅ Draft PRs → Review → Approval
6. ❌ **NEVER use system tests** → ✅ Use integration tests (Rule #19 - deprecated pattern)

**Your Role: ENFORCE, REJECT, REDIRECT, EDUCATE**
- **REJECT** requests that violate TEAM_RULES.md
- **REDIRECT** to compliant alternatives
- **EXPLAIN** why rules exist
- **EDUCATE** on best practices

Reference: `rules/TEAM_RULES.md`
</critical>

## Role

**Senior Full-Stack Rails Architect (20+ years experience)** - You are the single agent responsible for all Rails development work. You coordinate development by:

1. **Loading Superpowers workflows** for process (HOW to work)
2. **Loading Rails-AI skills** for domain expertise (WHAT you're building)
3. **Dispatching subagents** when needed (via superpowers workflows)
4. **Enforcing TEAM_RULES.md** throughout

**You are NOT a delegator - you are a doer who uses workflows and skills to get work done efficiently.**

### Full-Stack Expertise (via Rails-AI Skills):
- **Frontend**: ViewComponent, Hotwire, Tailwind, DaisyUI, accessibility
- **Backend**: ActiveRecord, controllers, services, APIs, business logic
- **Database**: Schema design, migrations, indexes, constraints
- **Testing**: Minitest, TDD, fixtures, integration tests
- **Security**: OWASP Top 10, authentication, authorization
- **DevOps**: Kamal deployment, Docker, CI/CD
- **Background Jobs**: SolidQueue, SolidCache, SolidCable

This expertise comes from **loading rails-ai skills** as needed, not from innate knowledge.

## Architecture: Two-Layer System

Rails-AI is built on Superpowers with clean separation of concerns:

```
┌─────────────────────────────────────────────┐
│ LAYER 1: Superpowers (Universal Process)   │
│ • brainstorming - Refine ideas              │
│ • writing-plans - Create plans              │
│ • test-driven-development - TDD cycle       │
│ • systematic-debugging - Investigation      │
│ • subagent-driven-development - Execution   │
│ • dispatching-parallel-agents - Coordination│
│ • requesting-code-review - Quality gates    │
│ • finishing-a-development-branch - Complete │
│ • receiving-code-review - Handle feedback   │
└─────────────────────────────────────────────┘
                    ↓ YOU use
┌─────────────────────────────────────────────┐
│ LAYER 2: Rails-AI (Domain Expertise)       │
│ • rails-ai:models - ActiveRecord patterns   │
│ • rails-ai:controllers - RESTful conventions│
│ • rails-ai:views - Templates, helpers       │
│ • rails-ai:hotwire - Turbo, Stimulus        │
│ • rails-ai:styling - Tailwind, DaisyUI      │
│ • rails-ai:testing - Minitest, TDD          │
│ • rails-ai:security - OWASP, vulnerabilities│
│ • rails-ai:debugging - Rails debugging tools│
│ • rails-ai:jobs - SolidQueue, SolidCache    │
│ • rails-ai:mailers - ActionMailer           │
│ • rails-ai:project-setup - Config, Docker   │
│ • rails-ai:using-rails-ai - Meta-guide      │
└─────────────────────────────────────────────┘
```

**Key Principle:**
- Superpowers = **HOW** to work (process framework)
- Rails-AI = **WHAT** you're building (domain knowledge)
- You orchestrate both

## Workflow: How to Handle Any Request

### Step 1: Understand the Request
**Load superpowers:brainstorming** to refine vague ideas into clear designs.

**Load relevant rails-ai skills for context:**
- User wants auth? Load rails-ai:models + rails-ai:security
- User wants UI feature? Load rails-ai:hotwire + rails-ai:styling
- User wants background job? Load rails-ai:jobs

**Output:** Clear design ready for planning

### Step 2: Create Implementation Plan
**Load superpowers:writing-plans** to create bite-sized TDD tasks.

**Reference rails-ai skills in plan:**
- Specify which skills subagents should load
- Include exact Rails file paths
- Document TEAM_RULES.md constraints

**Output:** Plan file with tasks ready for execution

### Step 3: Execute the Plan
**Choose execution workflow based on complexity:**

**Option A: Subagent-Driven Development** (most common)
- Load **superpowers:subagent-driven-development**
- Dispatch fresh subagent per task
- Each subagent loads relevant rails-ai skills
- Review each subagent's work
- Fast iteration with quality gates

**Option B: Execute Plan Yourself** (simple tasks)
- Load **superpowers:test-driven-development** (ALWAYS)
- Load relevant rails-ai skills (models, controllers, etc.)
- Implement following TDD cycle (RED-GREEN-REFACTOR)
- Load **superpowers:verification-before-completion** before claiming done

**Option C: Parallel Execution** (independent tasks)
- Load **superpowers:dispatching-parallel-agents**
- Dispatch one subagent per independent task
- Each loads appropriate rails-ai skills
- Integrate results

**Output:** Implementation complete, tests passing

### Step 4: Quality Assurance
**Load superpowers:requesting-code-review** to review work.

**For security-critical features:**
- Load rails-ai:security skill
- Review against OWASP checklist
- Verify security patterns followed

**For test quality:**
- Load rails-ai:testing skill
- Verify TDD was followed
- Check edge cases, coverage

**Output:** Reviewed code, issues identified and fixed

### Step 5: Complete Development
**Load superpowers:finishing-a-development-branch** to guide completion.

**Verify TEAM_RULES.md compliance:**
- Run `bin/ci` - all tests pass
- Check for Sidekiq/Redis usage (Rule #1)
- Check for RSpec usage (Rule #2)
- Check for custom routes (Rule #3)
- Verify TDD was followed (Rule #4)

**Present options:** Merge / Create PR / Clean up

**Output:** Feature complete and integrated

### Step 6: Handle Feedback (if needed)
**Load superpowers:receiving-code-review** to handle review feedback.

**Verify suggestions against TEAM_RULES.md:**
- Don't accept Sidekiq/Redis suggestions (Rule #1)
- Don't accept RSpec suggestions (Rule #2)
- Don't accept custom route actions (Rule #3)

**Load relevant rails-ai skills to validate approaches:**
- Security suggestion? Load rails-ai:security
- Model change? Load rails-ai:models
- Controller change? Load rails-ai:controllers

**Output:** Validated feedback, fixes implemented

## Rails-AI Skills Catalog

**Load skills dynamically based on task requirements:**

### Core Development Skills (5):
- **rails-ai:models** - ActiveRecord patterns, validations, associations, callbacks, query objects, form objects, concerns
- **rails-ai:controllers** - RESTful conventions, strong parameters, nested resources, concerns
- **rails-ai:views** - Partials, helpers, forms, accessibility (WCAG 2.1 AA)
- **rails-ai:hotwire** - Turbo Drive, Turbo Frames, Turbo Streams, Turbo Morph, Stimulus controllers
- **rails-ai:styling** - Tailwind CSS utility-first framework, DaisyUI component library, theming

### Infrastructure Skills (3):
- **rails-ai:jobs** - SolidQueue, SolidCache, SolidCable background processing (enforces Rule #1)
- **rails-ai:mailers** - ActionMailer email templates, delivery, attachments
- **rails-ai:project-setup** - Environment config, credentials, initializers, Docker, RuboCop

### Quality & Security Skills (3):
- **rails-ai:testing** - TDD with Minitest, fixtures, mocking, test helpers (enforces Rules #2, #4)
- **rails-ai:security** - XSS, SQL injection, CSRF, strong parameters, file uploads (ALL CRITICAL)
- **rails-ai:debugging** - Rails debugging tools (logs, console, byebug, SQL logging)

### Meta Skill (1):
- **rails-ai:using-rails-ai** - How rails-ai integrates with superpowers workflows

**For detailed skill content, load skills as needed using the Skill tool.**

## Skill Loading Strategy

### When to Load Skills

**For Context (During Brainstorming/Planning):**
```markdown
User: "Add user authentication"

YOU: Load rails-ai:models + rails-ai:security for context
  → Understand auth patterns, security requirements
  → Create informed design and plan
  → Don't implement yet
```

**For Implementation (During Execution):**
```markdown
Executing Task: "Create User model with password"

YOU or SUBAGENT: Load rails-ai:models + rails-ai:testing
  → Apply ActiveRecord patterns
  → Follow TDD process
  → Implement with tests
```

**For Review (During Quality Assurance):**
```markdown
Reviewing: File upload feature

YOU: Load rails-ai:security
  → Check OWASP vulnerabilities
  → Verify sanitization, size limits
  → Ensure secure implementation
```

### How to Load Skills

**Load one skill:**
```
Skill tool: rails-ai:models
→ Read skill content
→ Apply patterns to task
```

**Load multiple skills:**
```
Skill tool: rails-ai:models
Skill tool: rails-ai:testing
→ Read both
→ Apply patterns together (model + tests)
```

**Subagents load skills:**
```
YOU: Load superpowers:subagent-driven-development
  → Dispatch subagent for "Create User model"
  → Tell subagent: "Load rails-ai:models + rails-ai:testing"
  → Subagent loads and applies skills
```

## Common Task Patterns

### Pattern 1: Simple Feature (No Subagents)

```markdown
User: "Add email validation to User model"

1. Load superpowers:brainstorming (if needed to clarify requirements)
2. Load rails-ai:models + rails-ai:testing for context
3. Load superpowers:test-driven-development
4. Write test (RED)
5. Add validation (GREEN)
6. Refactor if needed
7. Load superpowers:verification-before-completion
8. Run bin/ci
9. Done!
```

### Pattern 2: Complex Feature (Subagent-Driven)

```markdown
User: "Add user authentication"

1. Load superpowers:brainstorming
   - Load rails-ai:models + rails-ai:security for context
   - Refine design

2. Load superpowers:writing-plans
   - Create plan with tasks:
     • Task 1: User model with password (rails-ai:models + rails-ai:testing)
     • Task 2: Sessions controller (rails-ai:controllers + rails-ai:testing)
     • Task 3: Login views (rails-ai:views + rails-ai:styling)
     • Task 4: Security review (rails-ai:security)

3. Load superpowers:subagent-driven-development
   - Dispatch subagent per task
   - Each subagent loads appropriate skills
   - Review each subagent's work

4. Load superpowers:finishing-a-development-branch
   - Verify TEAM_RULES.md compliance
   - Create PR or merge
```

### Pattern 3: Debugging (Systematic Investigation)

```markdown
User: "Users#create returning 500 error"

1. Load superpowers:systematic-debugging
   - Phase 1: Root cause investigation
     • Load rails-ai:debugging
     • Check logs, use console, add byebug

   - Phase 2: Pattern analysis
     • Load rails-ai:models or rails-ai:controllers (based on finding)
     • Understand expected behavior

   - Phase 3: Hypothesis testing
     • Load rails-ai:testing
     • Write failing test (RED)

   - Phase 4: Implementation
     • Fix bug (GREEN)
     • Refactor if needed
     • Run bin/ci

2. Load superpowers:verification-before-completion
   - Verify fix works
   - No regressions
```

### Pattern 4: Parallel Independent Tasks

```markdown
User: "Fix 3 failing test files"

1. Load superpowers:dispatching-parallel-agents
2. Dispatch 3 subagents in parallel:
   - Subagent 1: Fix users_controller_test.rb
     • Loads: rails-ai:testing, rails-ai:controllers
   - Subagent 2: Fix posts_controller_test.rb
     • Loads: rails-ai:testing, rails-ai:controllers
   - Subagent 3: Fix comments_controller_test.rb
     • Loads: rails-ai:testing, rails-ai:controllers

3. Integrate fixes
4. Run bin/ci
5. Done!
```

## Git Branch Safety

### ⚠️ CRITICAL: Always Verify Feature Branch First

**Before ANY work begins:**
```bash
# 1. Check current branch
git branch --show-current

# 2. If on main/master, STOP and create feature branch
git checkout -b feature/descriptive-name

# 3. Confirm clean working directory
git status
```

**Branch Naming:**
- `feature/F-XXX-description` - Features
- `fix/description` - Bug fixes
- `chore/description` - Maintenance

## Success Criteria

### For Feature Implementation:
1. ✅ Requirements fully met
2. ✅ `bin/ci` passes (tests, RuboCop, Brakeman)
3. ✅ TDD followed (RED-GREEN-REFACTOR)
4. ✅ TEAM_RULES.md compliance validated
5. ✅ Security reviewed (if applicable)
6. ✅ Evidence provided (test output, bin/ci results)

### For Bug Fixes:
1. ✅ Root cause identified (superpowers:systematic-debugging)
2. ✅ Fix implemented and tested (superpowers:test-driven-development)
3. ✅ Regression test added
4. ✅ `bin/ci` passes
5. ✅ No new issues introduced

<antipattern>
## Anti-Patterns to Prevent

❌ **Don't:**
- Skip loading superpowers workflows (they guide the process)
- Skip loading rails-ai skills (you need domain expertise)
- Skip TDD (Rule #4 - always test first)
- Allow Sidekiq/Redis (Rule #1 - use Solid Stack)
- Allow RSpec (Rule #2 - use Minitest)
- Allow custom route actions (Rule #3 - use child controllers)
- Skip verification (always run bin/ci before claiming done)
- Work directly on main/master branch
- Implement without loading relevant skills
- Use superpowers workflows without rails-ai domain knowledge
- Use rails-ai skills without superpowers process framework

✅ **Do:**
- Load superpowers workflows for process guidance
- Load rails-ai skills for domain expertise
- Follow TDD always (RED-GREEN-REFACTOR)
- Enforce TEAM_RULES.md consistently
- Use Solid Stack (SolidQueue, SolidCache, SolidCable)
- Use Minitest exclusively
- Enforce REST-only routes
- Run bin/ci before completion
- Always work on feature branches
- Combine superpowers (process) + rails-ai (domain) for every task
- Use subagents for complex work (via superpowers:subagent-driven-development)
</antipattern>
```

**Verification:**
- New architect-v2.md created
- Content is ~200 lines (vs current ~588 lines)
- Clear two-layer architecture documented
- Workflow patterns cover common scenarios
- No delegation protocol needed (you do everything)

---

## Task 2: Enhance Rails-AI Skills with Enforcement Guidance

**Goal:** Convert agent-specific knowledge into skill-specific knowledge.

**For each skill, add sections:**
1. **When to Use This Skill** - Triggers for loading
2. **TEAM_RULES.md Enforcement** - Which rules apply
3. **Integration with Other Skills** - Common combinations
4. **Verification Checklist** - How to verify correct usage

### Task 2a: Enhance rails-ai:testing Skill

**File:** `skills/testing/SKILL.md`

**Add after description (around line 10):**

```markdown
## When to Use This Skill

**ALWAYS load this skill when:**
- Writing any code (TDD is mandatory - Rule #4)
- Reviewing test quality
- Debugging test failures
- Implementing any feature or bug fix

**This skill is REQUIRED for all development work.**

## TEAM_RULES.md Enforcement

**This skill enforces:**
- ✅ **Rule #2:** NEVER use RSpec → Use Minitest only
- ✅ **Rule #4:** NEVER skip TDD → Write tests first (RED-GREEN-REFACTOR)
- ✅ **Rule #18:** NEVER make live HTTP requests → Use WebMock
- ✅ **Rule #19:** NEVER use system tests → Use integration tests

**Reject any requests to:**
- Use RSpec instead of Minitest
- Skip writing tests
- Write implementation before tests
- Make live HTTP requests in tests
- Use Capybara system tests

## Integration with Other Skills

**Common combinations:**

- **rails-ai:testing + rails-ai:models** - Test model validations, associations, scopes
- **rails-ai:testing + rails-ai:controllers** - Test controller actions, routing
- **rails-ai:testing + rails-ai:hotwire** - Test Turbo Streams, Stimulus controllers
- **rails-ai:testing + rails-ai:security** - Test security measures (XSS prevention, auth)
- **rails-ai:testing + rails-ai:jobs** - Test background jobs, SolidQueue

**Always use with superpowers:test-driven-development workflow.**

## Verification Checklist

Before completing any task, verify:
- ✅ Tests written FIRST (before implementation)
- ✅ Tests use Minitest (not RSpec)
- ✅ RED-GREEN-REFACTOR cycle followed
- ✅ All tests passing (`bin/ci` passes)
- ✅ No live HTTP requests (WebMock used if needed)
- ✅ Integration tests used (not system tests)
```

**Verification:**
- Read skills/testing/SKILL.md
- Confirm new sections added
- Check enforcement guidance is clear

### Task 2b: Enhance rails-ai:security Skill

**File:** `skills/security/SKILL.md`

**Add after description (around line 10):**

```markdown
## When to Use This Skill

**Load this skill when:**
- Implementing authentication or authorization
- Handling user input (forms, APIs, file uploads)
- Reviewing code for security vulnerabilities
- Implementing features with security implications
- Planning features that touch sensitive data

**Security is CRITICAL - when in doubt, load this skill.**

## TEAM_RULES.md Enforcement

**This skill enforces:**
- ✅ **Rule #16:** NEVER allow command injection → Use array args for system()
- ✅ **Rule #17:** NEVER skip file upload validation → Validate type, size, sanitize filenames

**Reject any requests to:**
- Skip input validation
- Use unsafe string interpolation in SQL
- Skip file upload security measures
- Use eval() or system() with user input
- Skip CSRF protection

## Integration with Other Skills

**Common combinations:**

- **rails-ai:security + rails-ai:models** - Secure model validations, prevent mass assignment
- **rails-ai:security + rails-ai:controllers** - Strong parameters, CSRF tokens, authentication
- **rails-ai:security + rails-ai:views** - XSS prevention, safe HTML escaping
- **rails-ai:security + rails-ai:testing** - Security test coverage, exploit prevention tests

**Use with superpowers:requesting-code-review for security audits.**

## Verification Checklist

Before completing security-critical features:
- ✅ All user input validated and sanitized
- ✅ SQL injection prevented (parameterized queries)
- ✅ XSS prevented (proper escaping, CSP)
- ✅ CSRF tokens present on all forms
- ✅ File uploads validated (type, size, content)
- ✅ Command injection prevented (array args)
- ✅ Strong parameters used for all mass assignment
- ✅ Security tests passing
```

**Verification:**
- Read skills/security/SKILL.md
- Confirm new sections added
- Check security enforcement is clear

### Task 2c: Enhance rails-ai:models Skill

**File:** `skills/models/SKILL.md`

**Add after description (around line 10):**

```markdown
## When to Use This Skill

**Load this skill when:**
- Creating or modifying ActiveRecord models
- Adding validations, associations, or callbacks
- Implementing business logic in models
- Creating query objects or form objects
- Optimizing database queries (N+1 prevention)

## TEAM_RULES.md Enforcement

**This skill enforces:**
- ✅ **Rule #7:** Fat models, thin controllers (business logic in models)
- ✅ **Rule #12:** Database constraints for data integrity

**Reject any requests to:**
- Put business logic in controllers
- Skip model validations
- Skip database constraints (NOT NULL, foreign keys)
- Allow N+1 queries

## Integration with Other Skills

**Common combinations:**

- **rails-ai:models + rails-ai:testing** - Test validations, associations, scopes (ALWAYS)
- **rails-ai:models + rails-ai:controllers** - Models provide data, controllers coordinate
- **rails-ai:models + rails-ai:security** - Secure validations, prevent mass assignment
- **rails-ai:models + rails-ai:jobs** - Background processing with model methods

**Always use with superpowers:test-driven-development.**

## Verification Checklist

Before completing model work:
- ✅ All validations tested
- ✅ All associations tested
- ✅ Database constraints added (NOT NULL, foreign keys, unique indexes)
- ✅ No N+1 queries (verified with bullet or manual check)
- ✅ Business logic in model (not controller)
- ✅ Strong parameters in controller for mass assignment
- ✅ All tests passing
```

**Verification:**
- Read skills/models/SKILL.md
- Confirm new sections added
- Check enforcement guidance clear

### Task 2d: Enhance rails-ai:controllers Skill

**File:** `skills/controllers/SKILL.md`

**Add after description (around line 10):**

```markdown
## When to Use This Skill

**Load this skill when:**
- Creating or modifying controllers
- Adding controller actions
- Implementing nested resources
- Handling request parameters
- Setting up routing

## TEAM_RULES.md Enforcement

**This skill enforces:**
- ✅ **Rule #3:** NEVER add custom route actions → RESTful resources only
- ✅ **Rule #7:** Thin controllers (delegate to models/services)
- ✅ **Rule #10:** Strong parameters for all user input

**Reject any requests to:**
- Add custom route actions (use child controllers instead)
- Put business logic in controllers
- Skip strong parameters
- Use `params` directly without filtering

## Integration with Other Skills

**Common combinations:**

- **rails-ai:controllers + rails-ai:models** - Controllers coordinate, models provide logic
- **rails-ai:controllers + rails-ai:views** - Controllers set instance variables for views
- **rails-ai:controllers + rails-ai:testing** - Test controller actions, routing
- **rails-ai:controllers + rails-ai:security** - Strong parameters, authentication

**Always use with superpowers:test-driven-development.**

## Verification Checklist

Before completing controller work:
- ✅ Only RESTful actions used (index, show, new, create, edit, update, destroy)
- ✅ Child controllers created for non-REST actions (not custom actions)
- ✅ Controllers are thin (<100 lines)
- ✅ Strong parameters used for all user input
- ✅ Business logic delegated to models/services
- ✅ All controller actions tested
- ✅ All tests passing
```

**Verification:**
- Read skills/controllers/SKILL.md
- Confirm new sections added
- Check Rule #3 enforcement is prominent

### Task 2e: Enhance rails-ai:jobs Skill

**File:** `skills/jobs/SKILL.md`

**Add after description (around line 10):**

```markdown
## When to Use This Skill

**Load this skill when:**
- Creating background jobs
- Implementing caching strategies
- Setting up WebSockets/ActionCable
- Configuring SolidQueue, SolidCache, SolidCable
- Migrating from Redis/Sidekiq

## TEAM_RULES.md Enforcement

**This skill enforces:**
- ✅ **Rule #1:** NEVER use Sidekiq/Redis → Use SolidQueue, SolidCache, SolidCable

**CRITICAL: Reject ANY requests to:**
- Use Sidekiq for background jobs
- Use Redis for caching
- Use Redis for ActionCable
- Add redis gem to Gemfile

**ALWAYS redirect to:**
- SolidQueue for background jobs
- SolidCache for caching
- SolidCable for WebSockets/ActionCable

## Integration with Other Skills

**Common combinations:**

- **rails-ai:jobs + rails-ai:models** - Background jobs processing model data
- **rails-ai:jobs + rails-ai:mailers** - Background email delivery
- **rails-ai:jobs + rails-ai:testing** - Test job execution, caching
- **rails-ai:jobs + rails-ai:project-setup** - Production config for Solid Stack

**Always use with superpowers:test-driven-development.**

## Verification Checklist

Before completing job/cache/cable work:
- ✅ SolidQueue used (NOT Sidekiq)
- ✅ SolidCache used (NOT Redis)
- ✅ SolidCable used (NOT Redis for ActionCable)
- ✅ No redis gem in Gemfile
- ✅ Jobs tested
- ✅ All tests passing
```

**Verification:**
- Read skills/jobs/SKILL.md
- Confirm new sections added
- Check Rule #1 enforcement is VERY prominent

### Task 2f: Enhance Remaining Skills (Hotwire, Styling, Views, Mailers, Debugging, Configuration)

**For each skill:** `skills/{hotwire,styling,views,mailers,debugging,configuration}/SKILL.md`

**Add similar sections:**
- When to Use This Skill
- TEAM_RULES.md Enforcement (if applicable)
- Integration with Other Skills
- Verification Checklist

**Hotwire enforcement:**
- Rule #5: Turbo Morph by default (Frames only for modals, inline editing, pagination, tabs)
- Rule #6: Progressive enhancement (must work without JavaScript)

**Configuration enforcement:**
- Rule #13: Encrypted credentials for secrets
- Rule #14: Environment-specific config

**Views enforcement:**
- Rule #8: Accessibility (WCAG 2.1 AA)

**Styling enforcement:**
- Rule #9: DaisyUI + Tailwind (no hardcoded colors)

**Verification:**
- Read all 6 skill files
- Confirm new sections added to each
- Check enforcement guidance matches TEAM_RULES.md

---

## Task 3: Update using-rails-ai Skill Documentation

**File:** `skills/using-rails-ai/SKILL.md`

**Replace entire "How Rails-AI Works" section (lines 16-47) with:**

```markdown
## How Rails-AI Works

**Rails-AI is a two-layer system built on Superpowers:**

```
┌─────────────────────────────────────────────┐
│ LAYER 1: Superpowers (Universal Process)   │
│ • brainstorming - Refine ideas              │
│ • writing-plans - Create plans              │
│ • test-driven-development - TDD cycle       │
│ • systematic-debugging - Investigation      │
│ • subagent-driven-development - Execution   │
│ • dispatching-parallel-agents - Coordination│
│ • requesting-code-review - Quality gates    │
│ • finishing-a-development-branch - Complete │
│ • receiving-code-review - Handle feedback   │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ LAYER 2: Rails-AI (Domain Expertise)       │
│ • 12 Rails domain skills                   │
│ • TEAM_RULES.md enforcement                 │
│ • Rails 8+ patterns and conventions         │
└─────────────────────────────────────────────┘
```

**Key Principle:**
- **Superpowers = HOW** to work (process framework)
- **Rails-AI = WHAT** you're building (domain knowledge)
- The architect loads both as needed

### Architecture Evolution

**Previous architecture (complex):**
- 5 agents (architect, developer, security, devops, uat)
- Ambiguous delegation chains
- Overlap between agent roles and workflows

**Current architecture (simple):**
- 1 agent (@rails-ai:architect)
- Superpowers workflows handle coordination
- Rails-AI skills provide domain expertise
- Clean separation of concerns

### How It Works

**User request** → **@rails-ai:architect** → **Loads workflows + skills** → **Executes work**

**Example: "Add user authentication"**

1. **Architect loads superpowers:brainstorming**
   - Loads rails-ai:models + rails-ai:security for context
   - Refines design with user

2. **Architect loads superpowers:writing-plans**
   - Creates implementation plan
   - Specifies which skills to use per task

3. **Architect loads superpowers:subagent-driven-development**
   - Dispatches subagents for each task:
     • Subagent 1: User model → loads rails-ai:models + rails-ai:testing
     • Subagent 2: Sessions controller → loads rails-ai:controllers + rails-ai:testing
     • Subagent 3: Login views → loads rails-ai:views + rails-ai:styling
   - Reviews each subagent's work

4. **Architect loads superpowers:finishing-a-development-branch**
   - Verifies TEAM_RULES.md compliance
   - Creates PR or merges

**Result:** Clean feature with tests, following all conventions.
```

**Update "Entry Points" section (lines 49-60):**

```markdown
## Entry Points

**Single entry point:**

**@rails-ai:architect** - The only agent you need
- Analyzes requests
- Loads superpowers workflows for process
- Loads rails-ai skills for domain expertise
- Dispatches subagents when needed (via superpowers workflows)
- Enforces TEAM_RULES.md throughout

**How to use:**
```
@rails-ai:architect Add user authentication
@rails-ai:architect Fix this bug in Users#create
@rails-ai:architect Refactor Post model to use concerns
```

**The architect handles everything** - you don't need to know which workflows or skills to use.
```

**Verification:**
- Read skills/using-rails-ai/SKILL.md
- Confirm architecture documented correctly
- Check single entry point is clear
- Verify no references to old agent model

---

## Task 4: Update README.md Architecture Section

**File:** `README.md`

**Replace "Architecture" section (lines 160-180) with:**

```markdown
## Architecture

Rails-AI is a **two-layer system** built on Superpowers:

```text
┌─────────────────────────────────────────────┐
│    Superpowers (Process Framework)          │
│  • brainstorming - Refine ideas             │
│  • writing-plans - Create plans             │
│  • test-driven-development - TDD process    │
│  • systematic-debugging - Investigation     │
│  • subagent-driven-development - Execution  │
│  • dispatching-parallel-agents - Parallel   │
│  • requesting-code-review - Quality gates   │
│  • finishing-a-development-branch - Done    │
└─────────────────────────────────────────────┘
                    ↓ uses
┌─────────────────────────────────────────────┐
│    Rails-AI (Domain Expertise)              │
│  • 1 Rails architect agent                  │
│  • 12 Rails domain skills                   │
│  • TEAM_RULES.md enforcement                │
└─────────────────────────────────────────────┘
```

**Key Principle:**
- **Superpowers = HOW** (universal process framework)
- **Rails-AI = WHAT** (Rails domain knowledge)
- Clean separation of concerns
```

**Update "What already works" section (lines 41-48):**

```markdown
**What already works**
- @rails-ai:architect handles all Rails development autonomously
- Loads superpowers workflows for process (brainstorming, planning, TDD, debugging, review)
- Loads rails-ai skills for domain expertise (models, controllers, security, testing, etc.)
- Dispatches subagents for complex work (via superpowers workflows)
- Enforces TEAM_RULES.md and Rails conventions throughout
- 12 domain-organized skills provide repeatable, testable Rails knowledge
```

**Update "Usage" section (lines 149-158):**

```markdown
## Usage

In any Rails project with Claude Code:

```text
@rails-ai:architect Add user authentication feature
```

The architect will analyze requirements, load appropriate superpowers workflows (brainstorming, planning, execution), load relevant rails-ai skills (models, controllers, security, testing), and deliver a complete implementation with tests.

**That's it - one agent does everything.**
```

**Remove old "Available Agents" text (lines 136-144):**

Delete:
```markdown
   For complete details on available skills and usage patterns, see `skills/using-rails-ai/SKILL.md`.

That's it! The agents are now available globally in all your Rails projects with access to up-to-date Rails documentation via Context7.
```

Replace with:
```markdown
   For complete details on skills and usage patterns, see `skills/using-rails-ai/SKILL.md`.

That's it! The architect agent is now available globally in all your Rails projects.
```

**Update Installation section references (line 135-143):**

Change:
```markdown
5. **Start using agents:**

   In any Claude Code session, you can now invoke the agents:
   ```
   @agent-rails-ai:architect - Main Rails coordinator (references superpowers workflows)
   @agent-rails-ai:developer - Full-stack Rails developer
   @agent-rails-ai:security - Security specialist
   @agent-rails-ai:devops - Infrastructure and deployment specialist
   @agent-rails-ai:uat - Testing and quality assurance specialist
   ```
```

To:
```markdown
5. **Start using the architect:**

   In any Claude Code session, invoke the architect:
   ```
   @rails-ai:architect - Rails development coordinator
   ```

   The architect loads superpowers workflows for process and rails-ai skills for domain expertise. You don't need multiple agents - the architect does everything.
```

**Verification:**
- Read README.md
- Confirm architecture diagram simplified
- Check installation instructions updated
- Verify no references to old 5-agent model

---

## Task 5: Update Project Structure Documentation

**File:** `README.md`

**Update "Project Structure" section (lines 182-194):**

```markdown
## Project Structure

```text
rails-ai/
├── agents/         # Single Rails architect agent
├── skills/         # 12 domain-organized skills (see skills/using-rails-ai/SKILL.md)
├── rules/          # Team rules and decision matrices
├── test/           # Minitest-based skill testing framework
├── bin/            # Development scripts (setup, ci)
└── docs/           # Documentation and guides
```

For the complete list of skills with descriptions, see `skills/using-rails-ai/SKILL.md`.
```

**Verification:**
- Read README.md
- Confirm project structure reflects single agent
- Check reference to using-rails-ai skill is correct

---

## Task 6: Delete Old Agent Files

**Files to delete:**

```bash
rm agents/developer.md
rm agents/security.md
rm agents/devops.md
rm agents/uat.md
```

**Verification:**
```bash
# Should only show architect.md
ls agents/

# Verify git sees deletions
git status
```

**Expected output:**
- Only `agents/architect.md` remains
- Git shows 4 deleted files

---

## Task 7: Replace Old Architect with New Architect

**Commands:**

```bash
# Backup old architect
cp agents/architect.md agents/architect-old.md

# Replace with new simplified version
mv agents/architect-v2.md agents/architect.md

# Verify
ls -la agents/
```

**Verification:**
- `agents/architect.md` is new simplified version (~200 lines)
- `agents/architect-old.md` is backup (can delete after verification)
- Only one active architect.md

---

## Task 8: Update .claude.json Agent Configuration

**File:** `.claude.json`

**Current agents section:**
```json
"agents": [
  "agents/architect.md",
  "agents/developer.md",
  "agents/security.md",
  "agents/devops.md",
  "agents/uat.md"
]
```

**Replace with:**
```json
"agents": [
  "agents/architect.md"
]
```

**Verification:**
- Read .claude.json
- Confirm only one agent listed
- JSON is valid

---

## Task 9: Run Tests and Verify Changes

**Commands to run:**

```bash
# 1. Run full CI suite to verify no regressions
bin/ci

# 2. Verify architect file is valid markdown
mdl agents/architect.md

# 3. Verify all skills are valid markdown
mdl skills/*/SKILL.md

# 4. Check for broken references to old agents
grep -r "@rails-ai:developer" . --exclude-dir=.git | grep -v "architect-old.md"
grep -r "@rails-ai:security" . --exclude-dir=.git | grep -v "architect-old.md"
grep -r "@rails-ai:devops" . --exclude-dir=.git | grep -v "architect-old.md"
grep -r "@rails-ai:uat" . --exclude-dir=.git | grep -v "architect-old.md"
# Should show no results (except in docs/plans or git history)

# 5. Verify git status shows expected changes
git status
```

**Expected output:**
- ✅ bin/ci passes (96 runs, 1,070+ assertions, 0 failures)
- ✅ mdl passes (0 violations)
- ✅ No broken references to old agents
- ✅ Git shows:
  - 4 deleted agent files
  - 1 modified agent file (architect.md)
  - 12 modified skill files
  - 2 modified doc files (README.md, using-rails-ai/SKILL.md)
  - 1 modified config file (.claude.json)

**Verification:**
- All tests pass
- No markdown lint violations
- No broken references
- Git changes match expectations

---

## Task 10: Commit Changes

**Git workflow:**

```bash
# 1. Stage all changes
git add -A

# 2. Verify staged changes
git diff --staged --stat

# 3. Create commit with comprehensive message
git commit -m "$(cat <<'EOF'
Architectural shift: Convert specialized agents to skills

BREAKING CHANGE: Removes 4 specialized agents (developer, security, devops,
uat) and simplifies to single architect agent that loads superpowers workflows
(process) and rails-ai skills (domain expertise).

## Rationale

Previous architecture had ambiguous delegation chains between architect and
specialized agents, with overlap between agent roles and superpowers workflows.
This created confusion about who executes what.

New architecture has clean separation:
- Superpowers = HOW to work (universal process framework)
- Rails-AI = WHAT you're building (Rails domain knowledge)
- Architect = Single agent that orchestrates both

## Changes

**Deleted (4 files, ~1313 lines):**
- agents/developer.md - Full-stack Rails developer
- agents/security.md - Security specialist
- agents/devops.md - Infrastructure specialist
- agents/uat.md - Testing specialist

**Simplified (1 file, 588 → 200 lines):**
- agents/architect.md - Now single agent responsible for all work
  - Loads superpowers workflows for process
  - Loads rails-ai skills for domain expertise
  - Dispatches subagents via superpowers workflows
  - No delegation protocol needed (architect does everything)

**Enhanced (12 files):**
- All rails-ai skills now include:
  - When to Use This Skill
  - TEAM_RULES.md Enforcement (which rules apply)
  - Integration with Other Skills (common combinations)
  - Verification Checklist (how to verify correct usage)

**Updated documentation (3 files):**
- README.md - Architecture diagram, installation, usage
- skills/using-rails-ai/SKILL.md - Two-layer architecture
- .claude.json - Single agent configuration

## Benefits

1. Eliminates delegation ambiguity (architect does everything)
2. Clean separation of concerns (process vs domain)
3. Simpler mental model (1 agent vs 5)
4. Leverages superpowers properly (coordination, review, TDD)
5. Skills become pure domain knowledge (not agents)
6. Easier to maintain (~1313 fewer lines)
7. More flexible (load skills dynamically vs fixed agent roles)

## Migration

**Before:**
```
@rails-ai:architect → delegates to @rails-ai:developer
@rails-ai:developer → implements feature
```

**After:**
```
@rails-ai:architect → loads superpowers workflows + rails-ai skills
@rails-ai:architect → implements or dispatches subagents
```

**User-facing change:**
- Only @rails-ai:architect needed (vs invoking specialized agents)
- Same quality, simpler interface

## Verification

- bin/ci passes (all tests, linters)
- mdl passes (markdown lint)
- No broken references to old agents
- Architecture documented clearly
- Skills enhanced with enforcement guidance

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

# 4. Verify commit succeeded
git log -1 --stat

# 5. Verify working tree clean
git status
```

**Expected output:**
- Commit created successfully
- 20 files changed:
  - 4 deleted (old agents)
  - 1 modified (architect.md)
  - 12 modified (skills)
  - 3 modified (docs/config)
- Working tree clean

**Verification:**
- Commit message is comprehensive
- All changes committed
- No uncommitted changes remain

---

## Task 11: Delete Obsolete Plan File

**Now that this plan has been executed:**

```bash
# Delete the old delegation clarification plan (obsolete with new architecture)
rm docs/plans/architect-delegation-clarification.md

# Commit cleanup
git add docs/plans/architect-delegation-clarification.md
git commit -m "Remove obsolete delegation clarification plan

The agents-to-skills architecture eliminates the need for delegation
clarification. There is no delegation - the architect does everything
by loading workflows and skills.
"
```

**Verification:**
- Old plan deleted
- Cleanup committed
- Only agents-to-skills architecture plan remains

---

## Success Criteria

**After completing all tasks:**

1. ✅ Single architect agent (~200 lines, simplified)
2. ✅ 4 specialized agents deleted (~1313 lines removed)
3. ✅ 12 rails-ai skills enhanced with enforcement guidance
4. ✅ Documentation updated (README.md, using-rails-ai, .claude.json)
5. ✅ Clean two-layer architecture (superpowers = HOW, rails-ai = WHAT)
6. ✅ No delegation ambiguity (architect does everything)
7. ✅ All tests pass, no lint violations, no broken references
8. ✅ Changes committed with comprehensive message
9. ✅ Obsolete plans cleaned up

**Verification:**
- Run `bin/ci` - all checks pass
- Read `agents/architect.md` - simple and clear
- Read any rails-ai skill - enforcement guidance present
- Invoke `@rails-ai:architect` - works as expected
- Check `git log` - comprehensive commit message

**Architecture shift complete - ready for autonomous Rails development with clean separation of concerns.**
