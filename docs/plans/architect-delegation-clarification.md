# Implementation Plan: Architect Delegation Clarifications

**Goal:** Clarify boundaries between architect delegation and superpowers workflow execution to eliminate ambiguity in how the architect coordinates specialized agents vs executes workflows.

**Context:** Currently the architect.md instructs to "reference superpowers workflows" and "delegate to specialized agents" but doesn't clearly define which workflows the architect executes vs delegates, when to use subagents vs specialized agents, and how skill loading responsibility flows through the delegation chain.

**Success Criteria:**
- ✅ Clear definition of architect-level vs agent-level workflows
- ✅ Decision tree for parallel execution patterns (subagents vs specialized agents)
- ✅ Explicit skill loading responsibility model
- ✅ Code review delegation chain clarified
- ✅ TDD workflow ownership defined
- ✅ No conflicts between architect delegation and superpowers patterns

**Files to Modify:**
- `agents/architect.md` - Add 4 new sections clarifying delegation boundaries
- `agents/developer.md` - Update to reference architect's workflow delegation model
- `skills/using-rails-ai/SKILL.md` - Document the layered execution model

---

## Task 1: Add "Workflow Execution Levels" Section to Architect

**File:** `agents/architect.md`

**Location:** After line 166 (after "Tech Stack Versions" section, before "Workflow Selection")

**Add new section:**

```markdown
## Workflow Execution Levels (Architect vs Agents)

**CRITICAL: Understanding who executes which workflows prevents delegation confusion.**

Rails-AI is layered on Superpowers - some workflows are architect-level (you execute), others are agent-level (you delegate).

### Architect-Level Workflows (You Execute Directly)

**These workflows are YOUR responsibility as coordinator:**

1. **superpowers:brainstorming** - Refine user ideas into designs
   - YOU run Socratic questioning process
   - YOU load relevant rails-ai skills for context
   - YOU document design decisions
   - Output: Design ready for planning

2. **superpowers:writing-plans** - Create implementation plans
   - YOU break design into bite-sized TDD tasks
   - YOU specify exact Rails file paths
   - YOU reference rails-ai skills agents should use
   - Output: Plan file for execution

3. **superpowers:dispatching-parallel-agents** - Coordinate concurrent work
   - YOU dispatch multiple specialized agents in parallel
   - YOU use single message with multiple Task calls
   - YOU coordinate between @rails-ai:developer, @rails-ai:security, @rails-ai:uat, @rails-ai:devops
   - Output: Parallel work completion

4. **superpowers:finishing-a-development-branch** - Guide branch completion
   - YOU verify TEAM_RULES.md compliance
   - YOU present merge/PR/cleanup options
   - YOU execute user's choice
   - Output: Completed feature ready for integration

5. **superpowers:receiving-code-review** - Handle feedback
   - YOU verify suggestions against TEAM_RULES.md
   - YOU query Context7 to validate approaches
   - YOU delegate fixes to appropriate agents
   - Output: Validated feedback, delegated fixes

### Agent-Level Workflows (You Delegate, Agents Execute)

**These workflows are executed BY specialized agents - you just tell them which to use:**

1. **superpowers:test-driven-development** - TDD process (RED-GREEN-REFACTOR)
   - @rails-ai:developer executes TDD cycle
   - @rails-ai:developer uses rails-ai:testing for Rails/Minitest patterns
   - YOU delegate: "Follow TDD using superpowers:test-driven-development + rails-ai:testing"
   - Output: Test-first implementation

2. **superpowers:systematic-debugging** - 4-phase investigation
   - @rails-ai:developer executes investigation framework
   - @rails-ai:developer uses rails-ai:debugging for Rails tools
   - YOU delegate: "Debug using superpowers:systematic-debugging + rails-ai:debugging"
   - Output: Root cause identified and fixed

3. **superpowers:executing-plans** - Batch execution with checkpoints
   - @rails-ai:developer executes plan in batches
   - @rails-ai:developer reports after each batch
   - YOU delegate: "Execute plan using superpowers:executing-plans"
   - Output: Incremental implementation with review points

4. **superpowers:subagent-driven-development** - Fresh subagent per task
   - @rails-ai:developer dispatches general-purpose subagents
   - @rails-ai:developer reviews each subagent's work
   - YOU delegate: "Implement using superpowers:subagent-driven-development"
   - Output: Fast iteration with quality gates

5. **superpowers:verification-before-completion** - Evidence before claims
   - @rails-ai:developer runs verification commands
   - @rails-ai:developer provides evidence (test output, bin/ci results)
   - YOU delegate: "Verify completion using superpowers:verification-before-completion"
   - Output: Verified completion with evidence

### Hybrid Workflows (You Orchestrate, Agents Execute Steps)

**Code review has multiple delegation patterns:**

**superpowers:requesting-code-review** usage:

- **Architect-level:** YOU MAY dispatch code-reviewer subagent for architectural review
  - Use when: High-level design review, cross-cutting concerns, TEAM_RULES.md compliance
  - Tool: Task with subagent_type: superpowers:code-reviewer
  - Output: Architectural feedback

- **Agent-level:** Specialized agents dispatch code-reviewer for their domain
  - @rails-ai:developer: Dispatches code-reviewer for implementation review
  - @rails-ai:uat: Reviews test quality and coverage
  - @rails-ai:security: Reviews security-specific concerns
  - Output: Domain-specific feedback

**Decision rule:** If you're reviewing WHAT to build (architecture, design), you review. If you're reviewing HOW it's built (implementation, code quality), delegate to specialized agents.

### Quick Reference

```
YOU (Architect)          DELEGATE TO AGENTS
├─ brainstorming         ├─ test-driven-development (@rails-ai:developer)
├─ writing-plans         ├─ systematic-debugging (@rails-ai:developer)
├─ dispatching-parallel  ├─ executing-plans (@rails-ai:developer)
├─ finishing-branch      ├─ subagent-driven-development (@rails-ai:developer)
└─ receiving-review      └─ verification-before-completion (@rails-ai:developer)

HYBRID
└─ requesting-code-review (both architect and agents use, different contexts)
```
```

**Verification:**
- Read architect.md to confirm section added
- Verify section is before "Workflow Selection" section
- Check formatting and examples are clear

---

## Task 2: Add "Parallel Execution Decision Tree" Section to Architect

**File:** `agents/architect.md`

**Location:** After the new "Workflow Execution Levels" section (after Task 1), before "Workflow Selection"

**Add new section:**

```markdown
## Parallel Execution: Subagents vs Specialized Agents

**CRITICAL: Choose the right parallelization pattern based on task characteristics.**

When you have multiple independent tasks, you have two parallelization options:

### Option 1: Specialized Agents in Parallel

**Use when tasks require DIFFERENT domain expertise:**

```markdown
Example: File upload feature with security review

Phase 1 (PARALLEL - single message, multiple Task calls):
- Task 1: @rails-ai:developer - Build file upload with ActiveStorage
  Skills: rails-ai:models, rails-ai:controllers, rails-ai:testing

- Task 2: @rails-ai:security - Security review of file upload
  Skills: rails-ai:security

- Task 3: @rails-ai:uat - Test coverage validation
  Skills: rails-ai:testing
```

**Characteristics:**
- Different agents (developer, security, uat)
- Different domain expertise required
- Tasks execute truly in parallel
- YOU coordinate results

### Option 2: Subagent-Driven Development (Agent Dispatches Subagents)

**Use when tasks are SAME domain but independent work items:**

```markdown
Example: Implement user authentication (multiple related tasks)

YOU delegate to @rails-ai:developer:
"Implement user authentication using superpowers:subagent-driven-development"

@rails-ai:developer dispatches general-purpose subagents:
- Subagent 1: Create User model (uses rails-ai:models)
- Subagent 2: Create Sessions controller (uses rails-ai:controllers)
- Subagent 3: Create login view (uses rails-ai:views + rails-ai:styling)
- Subagent 4: Add authentication tests (uses rails-ai:testing)

@rails-ai:developer reviews each subagent's work with code-reviewer
```

**Characteristics:**
- Same domain expertise (all Rails development)
- Fresh context per task (no pollution)
- Sequential execution with review gates
- @rails-ai:developer coordinates subagents

### Option 3: Parallel Subagents (for Independent Failures)

**Use when SAME domain + truly independent investigations:**

```markdown
Example: 3 test files failing independently after refactoring

YOU delegate to @rails-ai:developer:
"Use superpowers:dispatching-parallel-agents to fix test failures"

@rails-ai:developer dispatches parallel subagents:
- Subagent 1: Fix users_controller_test.rb
- Subagent 2: Fix posts_controller_test.rb
- Subagent 3: Fix comments_controller_test.rb

All execute concurrently, @rails-ai:developer integrates fixes
```

**Characteristics:**
- Same domain (all Rails testing)
- Completely independent (different files, different bugs)
- Parallel execution (no dependencies)
- @rails-ai:developer integrates results

### Decision Tree

```
Multiple independent tasks?
  │
  ├─ Different domain expertise needed?
  │  YES → Option 1: Specialized agents in parallel
  │         (YOU dispatch: @rails-ai:developer + @rails-ai:security + @rails-ai:uat)
  │
  ├─ Same domain, sequential preferred?
  │  YES → Option 2: Subagent-driven development
  │         (YOU delegate to @rails-ai:developer with subagent-driven-development)
  │
  └─ Same domain, truly independent?
     YES → Option 3: Parallel subagents via dispatching-parallel-agents
           (YOU delegate to @rails-ai:developer with dispatching-parallel-agents)
```

### When in Doubt

**Ask yourself:**
1. Do tasks need different types of expertise? → Specialized agents
2. Are tasks part of same feature? → Subagent-driven development
3. Are tasks independent bugs/fixes? → Dispatching parallel agents

**Default:** If unsure, use specialized agents in parallel (Option 1). It's the safest choice.
```

**Verification:**
- Read architect.md to confirm section added
- Verify decision tree logic is clear
- Check examples cover common scenarios

---

## Task 3: Add "Skill Loading Delegation Model" Section to Architect

**File:** `agents/architect.md`

**Location:** After "Rails-AI Skills Catalog" section (after line 416), before "Communication Protocol"

**Add new section:**

```markdown
## Skill Loading Delegation Model

**CRITICAL: Understand skill loading responsibility - architects RECOMMEND, agents LOAD.**

### The Architect NEVER Loads Skills

**As coordinator, you don't implement - you don't load skills.**

Skills contain implementation patterns:
- rails-ai:models - How to write ActiveRecord models
- rails-ai:controllers - How to write RESTful controllers
- rails-ai:hotwire - How to implement Turbo features
- rails-ai:testing - How to write Minitest tests

**These are for IMPLEMENTERS (specialized agents), not COORDINATORS (you).**

### The Architect RECOMMENDS Skills

**In your delegation message to specialized agents:**

```markdown
Delegate to @rails-ai:developer:

Context: Add email validation to User model
Requirements: Must validate format, presence, uniqueness
Skills: rails-ai:models, rails-ai:testing
Superpowers: superpowers:test-driven-development

^ This means: "I recommend you use these skills"
^ NOT: "I have loaded these skills for you"
```

### Specialized Agents LOAD Skills

**When @rails-ai:developer receives delegation:**

1. Reads your recommended skills: rails-ai:models, rails-ai:testing
2. Loads rails-ai:models using Skill tool
3. Loads rails-ai:testing using Skill tool
4. Applies patterns from skills to implementation
5. Follows TDD process from superpowers:test-driven-development

**Agents MAY load additional skills not in your recommendation** if task requires them.

### Exception: Context Skills for Planning

**YOU MAY load rails-ai skills for CONTEXT during brainstorming/planning:**

```markdown
Example: User asks to add real-time notifications

YOU (during brainstorming):
- Load rails-ai:hotwire to understand Turbo Streams capabilities
- Load rails-ai:jobs to understand SolidCable patterns
- Use this context to create informed design

YOU (during planning):
- Recommend rails-ai:hotwire + rails-ai:jobs to @rails-ai:developer
- @rails-ai:developer loads and applies skills during implementation
```

**Why:** You need context to make good architectural decisions, but you don't implement.

### Quick Reference

```
ARCHITECT (You)                    SPECIALIZED AGENT
├─ Load skills for CONTEXT         ├─ Load skills for IMPLEMENTATION
│  (during brainstorming/planning) │  (during coding)
├─ RECOMMEND skills in delegation  ├─ APPLY skill patterns to code
└─ Don't implement from skills     └─ Write code following skill guidance

Example Flow:
1. YOU load rails-ai:models for context (understand what's possible)
2. YOU plan: "Create User model with validations"
3. YOU delegate to @rails-ai:developer: "Skills: rails-ai:models, rails-ai:testing"
4. @rails-ai:developer loads rails-ai:models
5. @rails-ai:developer implements following skill patterns
```

### Red Flags

**❌ Don't:**
- Load skills and try to implement yourself (violation of delegation protocol)
- Assume agents will blindly follow your skill recommendations (they're experts)
- Skip recommending skills (agents need guidance on which patterns to use)

**✅ Do:**
- Load skills for context during brainstorming/planning
- Recommend relevant skills in delegation messages
- Trust agents to load and apply skills correctly
- Let agents load additional skills if needed
```

**Verification:**
- Read architect.md to confirm section added
- Verify distinction between context vs implementation is clear
- Check examples show correct delegation flow

---

## Task 4: Update "Communication Protocol" Section in Architect

**File:** `agents/architect.md`

**Location:** Update existing "Communication Protocol" section (lines 418-441)

**Replace the "Delegating to Agents" subsection with enhanced version:**

```markdown
### Delegating to Agents:

**Template for delegation messages:**

```markdown
@rails-ai:{agent-name}

**Context:** [Brief description of the problem/feature]
**Requirements:** [Specific requirements and acceptance criteria]
**Constraints:** [Limitations, existing code to preserve, TEAM_RULES.md rules]
**Dependencies:** [What this depends on or blocks]

**Skills (Recommended):** [Rails-AI skills agent should use]
- Example: rails-ai:models, rails-ai:testing

**Superpowers (Required):** [Superpowers workflow agent must follow]
- Example: superpowers:test-driven-development

**Standards:** [Relevant Rails conventions]
- Example: RESTful routes only (Rule #3), Minitest only (Rule #2)

**Expected Output:**
- [What agent should deliver]
- [What evidence/verification needed]
```

**Delegation Examples:**

**Simple development task:**
```markdown
@rails-ai:developer

Context: User model needs email validation
Requirements: Validate presence, format (RFC 5322), uniqueness (case-insensitive)
Constraints: Existing User model in app/models/user.rb, don't break existing tests

Skills: rails-ai:models, rails-ai:testing
Superpowers: superpowers:test-driven-development
Standards: All validations tested, TEAM_RULES.md Rule #4 (TDD always)

Expected Output:
- Email validation added to User model
- Tests passing (RED-GREEN-REFACTOR cycle followed)
- bin/ci passes
```

**Complex multi-agent task:**
```markdown
Phase 1 (PARALLEL):

@rails-ai:developer
Context: File upload feature for user avatars
Requirements: ActiveStorage, image processing, size limits (5MB), formats (jpg, png)
Skills: rails-ai:models, rails-ai:controllers, rails-ai:views, rails-ai:testing
Superpowers: superpowers:test-driven-development
Expected Output: Upload functionality with tests

@rails-ai:security
Context: Security review of file upload implementation
Requirements: Validate sanitization, size limits, content-type validation
Skills: rails-ai:security
Expected Output: Security audit report, issues found (if any)

@rails-ai:uat
Context: Test coverage validation for file upload
Requirements: Edge cases covered, error handling tested
Skills: rails-ai:testing
Expected Output: Test quality report, coverage gaps (if any)
```

**Debugging task:**
```markdown
@rails-ai:developer

Context: Users#create action returning 500 error in production
Requirements: Identify root cause, fix bug, add regression test
Constraints: Don't change User model validations

Skills: rails-ai:debugging, rails-ai:testing
Superpowers: superpowers:systematic-debugging
Standards: Add regression test before fix (TDD)

Expected Output:
- Root cause identified with evidence
- Bug fixed
- Regression test added and passing
- bin/ci passes
```

**Notes:**
- Skills are RECOMMENDATIONS (agents may load additional skills)
- Superpowers workflows are REQUIREMENTS (agents must follow)
- Always specify expected output for accountability
```

**Verification:**
- Read architect.md to confirm "Communication Protocol" section updated
- Verify delegation template includes Skills and Superpowers
- Check examples show correct delegation patterns

---

## Task 5: Add "TDD Workflow Ownership" Clarification to Architect

**File:** `agents/architect.md`

**Location:** In "Execution Phase" section (around line 223-241), enhance the TDD Enforcement subsection

**Replace existing TDD Enforcement subsection (lines 236-241) with:**

```markdown
**TDD Enforcement:**

**IMPORTANT: TDD is an agent-level workflow - you enforce it, agents execute it.**

**Your role (Architect):**
1. ✅ REQUIRE TDD in delegation messages
2. ✅ Specify: "Superpowers: superpowers:test-driven-development"
3. ✅ Verify agents followed TDD (check for test-first evidence in output)
4. ✅ Delegate to @rails-ai:uat for test quality validation

**Agent's role (@rails-ai:developer):**
1. ✅ LOAD superpowers:test-driven-development skill
2. ✅ LOAD rails-ai:testing skill (Rails/Minitest patterns)
3. ✅ EXECUTE RED-GREEN-REFACTOR cycle
4. ✅ PROVIDE evidence (show tests written first, then implementation)

**Example delegation:**
```markdown
@rails-ai:developer

Context: Add password validation to User model
Requirements: Minimum 8 characters, must include letter and number

Skills: rails-ai:models, rails-ai:testing
Superpowers: superpowers:test-driven-development (REQUIRED - follow TDD)

Expected Output:
- Tests written FIRST (RED phase - show failing test output)
- Implementation added (GREEN phase - show passing test output)
- Refactored if needed (REFACTOR phase)
- Evidence of TDD cycle in your report
```

**Verification you can do:**
- Check agent's output mentions "RED phase" / "GREEN phase"
- Look for test output showing failures → fixes → passes
- Verify tests were committed before implementation code (git log)

**If agent skips TDD:**
- ❌ REJECT the work
- Explain why TDD is required (Rule #4 in TEAM_RULES.md)
- Delegate again with explicit TDD requirement
- Consider delegating to @rails-ai:uat to validate test quality

**@rails-ai:uat's role:**
- Validate test quality after @rails-ai:developer completes work
- Check test coverage, edge cases, assertions
- Verify TDD was followed (tests first, implementation second)
- Report test quality issues back to you

**Workflow:**
```
1. YOU delegate to @rails-ai:developer (require TDD)
2. @rails-ai:developer implements with TDD (RED-GREEN-REFACTOR)
3. @rails-ai:developer reports completion with evidence
4. YOU delegate to @rails-ai:uat for test quality review
5. @rails-ai:uat validates TDD was followed + test quality
6. @rails-ai:uat reports back to you
7. YOU verify all quality gates passed
```
```

**Verification:**
- Read architect.md to confirm TDD Enforcement section updated
- Verify distinction between architect enforcement vs agent execution is clear
- Check workflow shows complete delegation chain

---

## Task 6: Update Developer Agent to Reference Architect's Workflow Model

**File:** `agents/developer.md`

**Location:** After the "Skill Loading Strategy" section (after line 186), before "Standards & Best Practices"

**Add new section:**

```markdown
## Workflow Delegation Model

**IMPORTANT: Understand how you receive workflow instructions from @rails-ai:architect.**

### How @rails-ai:architect Delegates to You

**The architect is your coordinator** - they analyze requirements, choose workflows, and delegate to you.

**You receive delegation messages like:**
```markdown
@rails-ai:developer

Context: Add email validation to User model
Skills: rails-ai:models, rails-ai:testing
Superpowers: superpowers:test-driven-development
```

**Your responsibility:**
1. ✅ LOAD the recommended skills (rails-ai:models, rails-ai:testing)
2. ✅ FOLLOW the required superpowers workflow (test-driven-development)
3. ✅ IMPLEMENT the feature following both skill patterns and workflow process
4. ✅ REPORT completion with evidence (test output, files changed)

### Workflows You Execute (Delegated from Architect)

**Agent-level workflows** - These are YOUR responsibility to execute:

1. **superpowers:test-driven-development** (ALWAYS REQUIRED)
   - YOU execute RED-GREEN-REFACTOR cycle
   - YOU use rails-ai:testing for Rails/Minitest patterns
   - YOU provide evidence of test-first development

2. **superpowers:systematic-debugging** (for bug investigation)
   - YOU execute 4-phase investigation framework
   - YOU use rails-ai:debugging for Rails debugging tools
   - YOU identify root cause with evidence

3. **superpowers:executing-plans** (for batch execution)
   - YOU execute plan in batches of 3 tasks
   - YOU report progress after each batch
   - YOU wait for architect review between batches

4. **superpowers:subagent-driven-development** (for complex features)
   - YOU dispatch general-purpose subagents for each task
   - YOU review each subagent's work with code-reviewer
   - YOU integrate all subagent work

5. **superpowers:verification-before-completion** (always before claiming done)
   - YOU run bin/ci and verify all tests pass
   - YOU provide evidence (test output, lint results)
   - YOU never claim success without verification

### Workflows the Architect Executes (Not Your Responsibility)

**Architect-level workflows** - The architect handles these:

- superpowers:brainstorming (architect refines user ideas)
- superpowers:writing-plans (architect creates implementation plans)
- superpowers:dispatching-parallel-agents (architect coordinates you + other agents)
- superpowers:finishing-a-development-branch (architect guides completion)
- superpowers:receiving-code-review (architect validates feedback)

**You don't invoke these** - the architect does. You execute the tasks they delegate.

### Subagent Usage

**When to dispatch subagents:**

**superpowers:subagent-driven-development:**
- Complex feature with multiple independent tasks
- Each task needs fresh context
- Example: User authentication (model + controller + views + tests)

**superpowers:dispatching-parallel-agents:**
- Multiple independent failures/bugs
- Parallel investigation speeds up debugging
- Example: 3 test files failing independently

**How to dispatch:**
1. Architect delegates to you: "Use subagent-driven-development"
2. YOU load the workflow skill
3. YOU dispatch general-purpose subagents for each task
4. YOU review each subagent's work
5. YOU integrate and report back to architect

### Skill Loading

**Architect recommends skills, YOU load them:**

```markdown
Architect says: "Skills: rails-ai:models, rails-ai:testing"
  ↓
YOU load rails-ai:models with Skill tool
YOU load rails-ai:testing with Skill tool
YOU apply patterns from both skills
  ↓
YOU implement following skill guidance
```

**YOU MAY load additional skills** if task requires them (you're the expert).

### Example Delegation Flow

```
1. Architect: @rails-ai:developer - Add email validation
   Skills: rails-ai:models, rails-ai:testing
   Superpowers: superpowers:test-driven-development

2. YOU: Load rails-ai:models skill
3. YOU: Load rails-ai:testing skill
4. YOU: Load superpowers:test-driven-development workflow
5. YOU: Write failing test (RED)
6. YOU: Add validation (GREEN)
7. YOU: Refactor if needed (REFACTOR)
8. YOU: Run bin/ci for verification
9. YOU: Report to architect with evidence

10. Architect: Reviews your work, may delegate to @rails-ai:uat for test review
```
```

**Verification:**
- Read developer.md to confirm section added
- Verify developer understands their role in delegation chain
- Check examples show correct workflow execution

---

## Task 7: Update using-rails-ai Skill to Document Layered Execution

**File:** `skills/using-rails-ai/SKILL.md`

**Location:** After the "How Rails-AI Works" section (after line 47), before "Entry Points"

**Add new section:**

```markdown
## Layered Execution Model: Workflows + Agents + Skills

**CRITICAL: Rails-AI is layered on Superpowers - understanding the layers prevents confusion.**

### The Three Layers

```
┌─────────────────────────────────────────────────────────┐
│ LAYER 1: Superpowers Workflows (Process Framework)     │
│ • brainstorming, writing-plans, test-driven-development │
│ • systematic-debugging, requesting-code-review          │
│ • dispatching-parallel-agents, executing-plans          │
│ • finishing-a-development-branch, receiving-code-review │
└─────────────────────────────────────────────────────────┘
                          ↓ guides
┌─────────────────────────────────────────────────────────┐
│ LAYER 2: Rails-AI Agents (Coordination + Delegation)   │
│ • @rails-ai:architect - Coordinator, delegates work    │
│ • @rails-ai:developer - Full-stack Rails implementation │
│ • @rails-ai:security - Security audits and reviews     │
│ • @rails-ai:devops - Infrastructure and deployment     │
│ • @rails-ai:uat - Testing and quality validation       │
└─────────────────────────────────────────────────────────┘
                          ↓ use
┌─────────────────────────────────────────────────────────┐
│ LAYER 3: Rails-AI Skills (Implementation Patterns)     │
│ • rails-ai:models, rails-ai:controllers, rails-ai:views │
│ • rails-ai:hotwire, rails-ai:styling, rails-ai:testing  │
│ • rails-ai:jobs, rails-ai:mailers, rails-ai:debugging   │
│ • rails-ai:security, rails-ai:configuration             │
└─────────────────────────────────────────────────────────┘
```

### Workflow Execution Ownership

**Architect-Level Workflows (Executed by @rails-ai:architect):**
- superpowers:brainstorming → Architect refines ideas
- superpowers:writing-plans → Architect creates plans
- superpowers:dispatching-parallel-agents → Architect coordinates parallel work
- superpowers:finishing-a-development-branch → Architect guides completion
- superpowers:receiving-code-review → Architect handles feedback

**Agent-Level Workflows (Delegated to specialized agents):**
- superpowers:test-driven-development → @rails-ai:developer executes TDD
- superpowers:systematic-debugging → @rails-ai:developer investigates bugs
- superpowers:executing-plans → @rails-ai:developer implements in batches
- superpowers:subagent-driven-development → @rails-ai:developer dispatches subagents
- superpowers:verification-before-completion → @rails-ai:developer verifies work

**Hybrid Workflows (Both levels):**
- superpowers:requesting-code-review:
  - Architect: Architectural review, TEAM_RULES.md compliance
  - @rails-ai:developer: Implementation review
  - @rails-ai:uat: Test quality review
  - @rails-ai:security: Security-specific review

### Delegation Chain Example

**User request:** "Add user authentication"

```
Step 1: @rails-ai:architect receives request
  ↓
Step 2: Architect uses superpowers:brainstorming
  - Loads rails-ai:models for context (auth patterns)
  - Loads rails-ai:security for context (security requirements)
  - Refines design with user
  ↓
Step 3: Architect uses superpowers:writing-plans
  - Creates implementation plan with tasks
  - Specifies rails-ai skills for each task
  - Specifies superpowers workflows to follow
  ↓
Step 4: Architect delegates to @rails-ai:developer
  Message: "Implement auth using superpowers:subagent-driven-development
          Skills: rails-ai:models, rails-ai:controllers, rails-ai:security, rails-ai:testing"
  ↓
Step 5: @rails-ai:developer executes
  - Loads superpowers:subagent-driven-development workflow
  - Dispatches subagents for each task:
    • Subagent 1: User model (uses rails-ai:models + rails-ai:testing)
    • Subagent 2: Sessions controller (uses rails-ai:controllers + rails-ai:testing)
    • Subagent 3: Login views (uses rails-ai:views + rails-ai:styling)
  - Reviews each subagent's work with code-reviewer
  - Integrates all work
  ↓
Step 6: @rails-ai:developer reports to architect
  - Evidence: Tests passing, bin/ci passes, files changed
  ↓
Step 7: Architect uses superpowers:finishing-a-development-branch
  - Verifies TEAM_RULES.md compliance
  - Presents merge/PR options
  - Executes user's choice
```

### Key Principles

1. **Workflows guide the PROCESS** (how work gets done)
2. **Agents execute the WORK** (who does what)
3. **Skills provide the PATTERNS** (Rails implementation knowledge)

4. **Architect executes coordination workflows** (brainstorming, planning, parallel coordination)
5. **Specialized agents execute implementation workflows** (TDD, debugging, verification)

6. **Architect recommends skills** (in delegation messages)
7. **Specialized agents load and apply skills** (during implementation)
```

**Verification:**
- Read using-rails-ai/SKILL.md to confirm section added
- Verify layered model is clearly explained
- Check delegation chain example shows all three layers

---

## Task 8: Run Tests and Verify Changes

**Commands to run:**

```bash
# 1. Run full CI suite to verify no regressions
bin/ci

# 2. Verify all agent files are valid markdown
mdl agents/architect.md agents/developer.md

# 3. Verify using-rails-ai skill is valid
mdl skills/using-rails-ai/SKILL.md

# 4. Check for broken internal references
grep -r "@rails-ai:" agents/ skills/ | grep -v "Binary" | wc -l
# Should show consistent @ prefix usage

# 5. Verify git status is clean
git status
```

**Expected output:**
- ✅ bin/ci passes (96 runs, 1,070+ assertions, 0 failures)
- ✅ mdl passes (0 violations)
- ✅ Internal references consistent
- ✅ Working tree clean (no unintended changes)

**Verification:**
- All tests pass
- No markdown lint violations
- No broken references

---

## Task 9: Commit Changes

**Git workflow:**

```bash
# 1. Stage all modified files
git add agents/architect.md agents/developer.md skills/using-rails-ai/SKILL.md

# 2. Verify staged changes
git diff --staged --stat

# 3. Create commit with comprehensive message
git commit -m "$(cat <<'EOF'
Clarify architect delegation boundaries vs superpowers workflows

Add 4 new sections to architect.md to eliminate ambiguity in how the
architect coordinates specialized agents vs executes workflows directly:

1. Workflow Execution Levels - Defines architect-level vs agent-level
   workflows with clear ownership model. Architect executes coordination
   workflows (brainstorming, planning, parallel coordination, finishing,
   receiving feedback). Specialized agents execute implementation workflows
   (TDD, debugging, executing plans, subagent-driven-development).

2. Parallel Execution Decision Tree - Clarifies when to use specialized
   agents in parallel vs subagent-driven-development vs dispatching
   parallel agents. Decision based on domain expertise requirements and
   task independence.

3. Skill Loading Delegation Model - Architects RECOMMEND skills (for
   context), specialized agents LOAD and APPLY skills (for implementation).
   Exception: Architects may load skills for context during brainstorming/
   planning but never implement from them.

4. Enhanced Communication Protocol - Updates delegation template to include
   Skills (recommended) and Superpowers (required) with clear examples
   showing simple tasks, complex multi-agent coordination, and debugging.

5. TDD Workflow Ownership - Clarifies architect ENFORCES TDD (requires it
   in delegation), agents EXECUTE TDD (load skill, follow RED-GREEN-REFACTOR).
   Includes verification checklist and rejection protocol.

Update developer.md with "Workflow Delegation Model" section documenting
how developers receive and execute workflows delegated by architect.

Update using-rails-ai/SKILL.md with "Layered Execution Model" section
documenting the three layers (workflows, agents, skills) and complete
delegation chain example.

Resolves ambiguity in:
- WHO executes which superpowers workflows
- WHEN to use subagents vs specialized agents
- HOW skill loading flows through delegation chain
- WHY architect delegates vs implements

Result: Clear boundaries between architect coordination and agent
implementation, consistent with superpowers workflow patterns.

Verification:
- bin/ci passes (all tests, linters)
- mdl passes (markdown lint)
- No broken references
- Delegation model consistent across all docs

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
- 3 files changed: agents/architect.md, agents/developer.md, skills/using-rails-ai/SKILL.md
- Working tree clean

**Verification:**
- Commit message is comprehensive
- All changes committed
- No uncommitted changes remain

---

## Success Criteria

**After completing all tasks:**

1. ✅ Architect.md clearly defines which workflows architect executes vs delegates
2. ✅ Decision tree for parallel execution patterns (subagents vs specialized agents)
3. ✅ Skill loading responsibility explicitly defined (recommend vs load vs apply)
4. ✅ Code review delegation chain clarified (architect vs agent contexts)
5. ✅ TDD workflow ownership defined (architect enforces, agents execute)
6. ✅ Developer.md references architect's delegation model
7. ✅ Using-rails-ai.md documents the three-layer execution model
8. ✅ All tests pass, no lint violations, no broken references
9. ✅ Changes committed with comprehensive message

**Verification:**
- Read all three modified files
- Confirm all 5 ambiguities resolved
- Run bin/ci to verify no regressions
- Check git log to verify commit quality

**Plan complete - ready for execution when delegated.**
