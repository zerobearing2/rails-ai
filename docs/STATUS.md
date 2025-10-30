# Rails AI - Project Status & Handoff

**Last Updated:** 2025-10-30
**Branch:** `feature/external-yaml-registries`
**PR:** https://github.com/zerobearing2/rails-ai/pull/2 (Draft)
**Status:** Phase 1 Complete ✅ | Phase 2 In Progress (50% complete)

---

## Executive Summary

Successfully transformed rails-ai from an examples-based system to a **skills-based architecture** with comprehensive testing infrastructure and machine-first optimization. Phase 1 (skills migration and testing) is complete. Phase 2 (agent integration) is 50% complete.

### What's Complete ✅

**Phase 1:**
- 33 modular skills created (migrated from 39 examples)
- Two-tier Minitest testing framework implemented
- Development infrastructure (bin/setup, bin/ci)
- GitHub Actions CI/CD workflow
- Comprehensive documentation
- All tests passing, all checks green

**Phase 2 (Coordinator Update):**
- ✅ External YAML registries created (skills + rules mapping)
- ✅ Coordinator agent updated with skills registry
- ✅ Bidirectional linking (rules ↔ skills)
- ✅ TEAM_RULES.md simplified (30% reduction)
- ✅ 11 skills updated with enforcement metadata
- ✅ Coordinator cleaned up (DRY compliant)
- ✅ Meta README intro added (AI building tools for AI)

### What's Next 📋

**Phase 2 (Remaining):**
- Update 7 specialized agents to load skills dynamically
- Test agent skill loading with real tasks
- Scale test coverage from 2.6% to 20%+ (7+ skills tested)

---

## Phase 1: Skills Migration & Testing (COMPLETE)

### 1.1 Skills Architecture

**Goal:** Transform from examples to modular, reusable skills.

**What We Did:**
- Migrated 39 examples → 33 skills
- Organized by domain: frontend (13), backend (10), testing (6), security (6), config (4)
- Deleted `examples/` directory
- Created hybrid format: YAML front matter + Markdown + XML semantic tags

**Key Decision: Hybrid Format**
- **YAML front matter:** Machine-parseable metadata (name, domain, version, dependencies)
- **Markdown:** Human-readable documentation
- **XML tags:** Semantic structure for LLM targeting (`<when-to-use>`, `<benefits>`, `<standards>`, `<pattern>`, `<antipatterns>`, etc.)

**Why:** Balance between human readability and machine-first optimization for LLM consumption.

**Example Skill Structure:**
```markdown
---
name: turbo-page-refresh
domain: frontend
dependencies: [hotwire-turbo]
version: 1.0
rails_version: 8.1+
---

# Turbo Page Refresh (Morphing)

Brief description.

<when-to-use>
- Condition 1
- Condition 2
</when-to-use>

<benefits>
- Benefit 1
</benefits>

<standards>
- Standard 1
</standards>

<pattern name="enable-page-refresh">
<description>Enable page refresh with morphing</description>

**Code Example:**
```erb
<body data-turbo-refresh-method="morph" data-turbo-refresh-scroll="preserve">
  <%= yield %>
</body>
```
</pattern>

<antipatterns>
<antipattern>
<description>Using frames when page refresh is simpler</description>
<reason>Adds unnecessary complexity</reason>
<bad-example>
```ruby
# ❌ Bad
turbo_frame_tag "feedbacks"
```
</bad-example>
<good-example>
```ruby
# ✅ Good
broadcast_refresh_to "feedbacks"
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test examples
</testing>

<related-skills>
- hotwire-turbo
</related-skills>

<resources>
- [Turbo Docs](https://turbo.hotwired.dev)
</resources>
```

**Location:** All skills in `skills/` organized by domain folder.

### 1.2 Testing Framework

**Goal:** Validate skills produce expected outcomes when used by agents.

**What We Did:**
- Implemented two-tier Minitest strategy
- Created 19 unit tests for turbo-page-refresh skill (proven working)
- Built LLM-as-judge integration test framework (with mock for dev)
- Added cross-validation support (multiple LLMs judge same output)

**Tier 1: Unit Tests (Fast - < 1 second)**
- Purpose: Validate skill structure and content
- What they test:
  - ✅ Valid YAML front matter
  - ✅ Required metadata present
  - ✅ Required sections exist (`<when-to-use>`, `<benefits>`, `<standards>`, etc.)
  - ✅ Named patterns documented
  - ✅ Code examples present
  - ✅ Good (✅) and bad (❌) examples marked
  - ✅ Key patterns documented (attributes, methods, callbacks)
- Location: `test/skills/unit/`
- Run with: `rake test:skills:unit`
- **Status:** 1/33 skills have tests (turbo-page-refresh)

**Tier 2: Integration Tests (Slow - ~2-5 seconds)**
- Purpose: Validate agents apply skills correctly using LLM-as-judge
- What they test:
  - ✅ Generated code contains expected patterns
  - ✅ Generated code avoids antipatterns
  - ✅ LLM judge scores >= 4.0/5.0
  - ✅ Multiple LLMs agree (cross-validation)
- Location: `test/skills/integration/`
- Run with: `INTEGRATION=1 rake test:skills:integration`
- **Status:** 1/33 skills have tests (turbo-page-refresh)
- **Note:** Currently use mock LLM client; real LLM integration pending

**Test Infrastructure:**
- Base class: `test/skills/skill_test_case.rb`
- Helpers: `test/test_helper.rb` (SkillTestHelpers, LLMJudgeHelpers)
- Mock LLM client for dev (no API costs)
- Test template generator: `rake test:skills:new[skill-name,domain]`

**Key Files:**
- `test/skills/skill_test_case.rb` - Base class with common assertions
- `test/skills/unit/turbo_page_refresh_test.rb` - Example unit test (19 tests)
- `test/skills/integration/turbo_page_refresh_integration_test.rb` - Example integration test (5 tests)
- `test/test_helper.rb` - Setup, helpers, mock LLM client
- `test/README.md` - Complete testing documentation

### 1.3 Development Infrastructure

**What We Did:**
- Created `Gemfile` with all dependencies
- Set up linting (Rubocop, mdl, yaml-lint)
- Built Rails 8.1-style development scripts
- Created GitHub Actions CI/CD workflow

**Dependencies (Gemfile):**
- minitest (~> 5.25) - Testing framework
- minitest-reporters (~> 1.7) - Better test output
- rubocop (~> 1.68) + plugins - Ruby linting
- mdl (~> 0.13) - Markdown linting
- yaml-lint (~> 0.1.2) - YAML validation
- rake (~> 13.2) - Task automation

**Scripts:**
- `bin/setup` - One-time development setup
  - Checks Ruby version (3.3+)
  - Installs Bundler
  - Installs dependencies
  - Verifies installation
  - Runs quick test

- `bin/ci` - Complete CI pipeline (Rails 8.1 style)
  - Installs dependencies
  - Runs all linters (Ruby, Markdown, YAML)
  - Runs unit tests (always)
  - Runs integration tests (if INTEGRATION=1)
  - Shows coverage report
  - Color-coded output
  - Exit code 0 on success, 1 on failure

**Linting:**
- `.rubocop.yml` - Ruby style guide (120 char lines, lenient for tests)
- `.mdl_style.rb` - Markdown rules (200 char lines, allows XML tags)
- `rake lint` - Run all linters
- `rake lint:fix` - Auto-fix Ruby issues

**GitHub Actions:**
- `.github/workflows/ci.yml` - Three-job CI pipeline
  - Job 1: Lint & Unit Tests (runs on all PRs and master)
  - Job 2: Integration Tests (manual-only via workflow_dispatch)
  - Job 3: All Checks Passed (single status check for branch protection)
- Features:
  - Concurrency control (cancels old runs)
  - Bundle caching (speeds up by ~30s)
  - Draft PR skipping (saves CI minutes)
  - Test artifacts uploaded
- **Current Status:** All checks passing ✅

### 1.4 Documentation

**What We Created:**
- `AGENTS.md` - System governance (487 lines)
  - 8 agent roles with skill presets
  - Skill management workflow (add/update/remove)
  - Development workflow
  - Testing requirements
  - Skill dependency graph

- `docs/skill-testing-methodology.md` - Testing approach (677 lines)
  - Version 2.0 (implemented, not just proposal)
  - Two-tier Minitest strategy explained
  - Complete examples and usage
  - Writing new tests guide
  - Troubleshooting

- `docs/development-setup.md` - Setup instructions (180+ lines)
  - Installation
  - Running tests
  - Linting
  - Pre-commit hooks
  - CI/CD integration
  - Troubleshooting

- `docs/github-actions-setup.md` - CI/CD guide (350+ lines)
  - When workflows run
  - What they check
  - Setup instructions
  - Branch protection
  - API keys (for future)
  - Manual triggering
  - Troubleshooting
  - Cost estimation

- `test/README.md` - Testing documentation (413 lines)
  - Test structure
  - Running tests
  - Test types
  - LLM judge evaluation
  - Configuration
  - Writing new tests
  - Helpers available

- `README.md` - Updated with Development section
  - Setup, testing, quality checks
  - CI/CD overview
  - Documentation links

### 1.5 Governance

**What We Created:**
- `AGENTS.md` - Central governance document
  - Defines 8 specialized agents with roles
  - Specifies skill presets for each agent
  - Documents skill management workflow
  - Establishes testing requirements
  - Shows skill dependency graph

**8 Agents Defined:**
1. **Coordinator** (`agents/rails.md`) - Skills registry/librarian, routes tasks
2. **Feature** (`agents/feature.md`) - Full-stack feature development
3. **Debugger** (`agents/debugger.md`) - Testing and debugging
4. **Refactor** (`agents/refactor.md`) - Code quality and patterns
5. **Security** (`agents/security.md`) - Security auditing and fixes
6. **Test** (`agents/test.md`) - Test writing and coverage
7. **UI** (`agents/ui.md`) - Frontend/UI development
8. **API** (`agents/api.md`) - Backend API development

**Agent Skill Presets (examples):**
- Coordinator: ALL skills (registry)
- Feature: 13 skills (frontend + backend + testing + security + config)
- UI: 13 skills (all frontend)
- API: 17 skills (backend + security)
- Test: 6 skills (all testing)

**Key Decision: Coordinator as Registry**
The coordinator agent will maintain a master registry of all skills and suggest which skills to use for tasks. Specialized agents load skill subsets automatically.

---

## Current State

### File Structure

```
rails-ai/
├── .github/
│   └── workflows/
│       └── ci.yml                          # GitHub Actions CI/CD
├── agents/                                  # 8 specialized agents
│   ├── rails.md                            # Coordinator (TODO: update with registry)
│   ├── feature.md                          # (TODO: update with skill loading)
│   ├── debugger.md                         # (TODO: update with skill loading)
│   ├── refactor.md                         # (TODO: update with skill loading)
│   ├── security.md                         # (TODO: update with skill loading)
│   ├── test.md                             # (TODO: update with skill loading)
│   ├── ui.md                               # (TODO: update with skill loading)
│   └── api.md                              # (TODO: update with skill loading)
├── skills/                                  # 33 modular skills ✅
│   ├── frontend/                           # 13 skills
│   │   ├── turbo-page-refresh.md          # ✅ Has tests (19 unit, 5 integration)
│   │   ├── viewcomponent-basics.md
│   │   ├── viewcomponent-slots.md
│   │   ├── viewcomponent-previews.md
│   │   ├── viewcomponent-variants.md
│   │   ├── hotwire-turbo.md
│   │   ├── hotwire-stimulus.md
│   │   ├── tailwind-utility-first.md
│   │   ├── daisyui-components.md
│   │   ├── view-helpers.md
│   │   ├── forms-nested.md
│   │   ├── accessibility-patterns.md
│   │   └── partials-layouts.md
│   ├── backend/                            # 10 skills
│   │   ├── controller-restful.md
│   │   ├── activerecord-patterns.md
│   │   ├── form-objects.md
│   │   ├── query-objects.md
│   │   ├── concerns-models.md
│   │   ├── concerns-controllers.md
│   │   ├── custom-validators.md
│   │   ├── action-mailer.md
│   │   ├── nested-resources.md
│   │   └── antipattern-fat-controllers.md
│   ├── testing/                            # 6 skills
│   │   ├── tdd-minitest.md
│   │   ├── fixtures-test-data.md
│   │   ├── minitest-mocking.md
│   │   ├── test-helpers.md
│   │   ├── viewcomponent-testing.md
│   │   └── model-testing-advanced.md
│   ├── security/                           # 6 skills
│   │   ├── security-xss.md
│   │   ├── security-sql-injection.md
│   │   ├── security-csrf.md
│   │   ├── security-strong-parameters.md
│   │   ├── security-file-uploads.md
│   │   └── security-command-injection.md
│   └── config/                             # 4 skills
│       ├── solid-stack-setup.md
│       ├── initializers-best-practices.md
│       ├── credentials-management.md
│       └── environment-configuration.md
├── test/                                    # Testing framework ✅
│   ├── test_helper.rb                      # Setup, helpers, mock LLM
│   ├── README.md                           # Testing documentation
│   ├── skills/
│   │   ├── skill_test_case.rb             # Base class for tests
│   │   ├── unit/
│   │   │   └── turbo_page_refresh_test.rb # Example unit test (19 tests)
│   │   └── integration/
│   │       └── turbo_page_refresh_integration_test.rb # Example integration test (5 tests)
├── bin/                                     # Development scripts ✅
│   ├── setup                               # One-time setup
│   └── ci                                  # CI pipeline
├── docs/                                    # Documentation ✅
│   ├── skill-testing-methodology.md       # Testing approach (v2.0)
│   ├── development-setup.md               # Setup guide
│   ├── github-actions-setup.md            # CI/CD guide
│   ├── skills-architecture.md             # Design doc
│   ├── skills-migration-progress.md       # Migration tracking
│   └── STATUS.md                          # This file
├── rules/                                   # Team conventions
├── Gemfile                                  # Dependencies ✅
├── Rakefile                                 # Task automation ✅
├── .rubocop.yml                            # Ruby linting config ✅
├── .mdl_style.rb                           # Markdown linting config ✅
├── .gitignore                              # Git ignore rules ✅
├── AGENTS.md                               # System governance ✅
└── README.md                               # Project overview ✅
```

### Test Coverage

**Current:** 3.0% (1 skill out of 33)
- ✅ turbo-page-refresh: 19 unit tests + 5 integration tests
- ❌ Remaining 32 skills: No tests yet

**To check coverage:**
```bash
rake test:skills:report
```

### CI/CD Status

**GitHub Actions:** ✅ All checks passing
- PR #2: https://github.com/zerobearing2/rails-ai/pull/2 (Draft)
- Branch: `feature/external-yaml-registries`
- Latest run: All tests pass in ~17 seconds

**What CI Runs:**
- Lint & Unit Tests: On every push to master, every PR (not drafts)
- Integration Tests: Manual-only via workflow_dispatch (disabled for automated runs)

**Local Testing:**
```bash
bin/ci                      # Full local CI (< 10 seconds)
INTEGRATION=1 bin/ci        # Include integration tests (requires API keys)
```

### Git Status

**Branch:** `feature/external-yaml-registries` (3 commits ahead of master)
**Remote:** `origin/feature/external-yaml-registries`
**Master:** Renamed from `main` to `master` on GitHub ✅

**Latest Commits (Current PR #2):**
1. `2202a76` - Refactor: Extract skills registry and rules mapping to external YAML files
2. `3637358` - Clean up rails coordinator: Remove duplicates and optimize for DRY
3. `c277d55` - Add cheeky meta intro: AI building tools for AI

**Previous Commits (From PR #1 - Merged to Master):**
1. Initial commit: Move agents and dependencies
2. Migrate 39 examples to 33 skills
3. Organize skills by domain
4. Add turbo-page-refresh skill
5. Add Minitest testing framework
6. Add Gemfile and linting
7. Add documentation and CI scripts
8. Add GitHub Actions workflow
9. Change main → master
10. Fix CI for draft PRs
11. Disable automated integration tests

---

## Key Decisions & Rationale

### 1. Hybrid Format (YAML + Markdown + XML)

**Decision:** Use YAML front matter for metadata, Markdown for content, XML tags for semantic structure.

**Why:**
- YAML: Easy to parse for metadata (name, domain, version, dependencies)
- Markdown: Human-readable, familiar to developers
- XML tags: Semantic structure for LLM targeting (`<when-to-use>`, `<pattern>`, etc.)
- Balance: Human readability + machine-first optimization

**Alternative Considered:** Pure YAML or JSON
**Rejected Because:** Less readable for humans, harder to write/maintain

### 2. Two-Tier Testing Strategy

**Decision:** Unit tests (fast, structure) + Integration tests (slow, LLM-as-judge)

**Why:**
- Unit tests: Fast feedback (< 1s), deterministic, no API costs
- Integration tests: Comprehensive quality assessment, validates LLM understanding
- Separation: Run unit tests always, integration tests when needed
- Cost control: Integration tests manual-only for now

**Alternative Considered:** Pattern assertions only (bash scripts with grep)
**Rejected Because:** Too brittle, can't validate understanding or quality

### 3. Minitest (Not RSpec)

**Decision:** Use Minitest for testing framework.

**Why:**
- Rails default since 8.0+
- Simple, minimal, fast
- Team preference (per project rules)
- Consistent with Rails conventions

**Alternative Considered:** RSpec
**Rejected Because:** Team rule: "Minitest (no RSpec)"

### 4. Integration Tests: Manual-Only

**Decision:** Disable automated integration test runs, keep manual-only.

**Why:**
- LLM integration strategy still being figured out
- Prevents unexpected API costs (~$0.01 per run)
- Full control over when to spend API credits
- Can be enabled later when ready

**Cost:** Manual runs only = $0-0.10/month (vs $0.54/month automated)

### 5. Master (Not Main)

**Decision:** Use `master` as default branch name.

**Why:** User preference, explicitly requested.

**Changed:**
- Workflow triggers
- Documentation
- All references

### 6. Draft PRs by Default

**Decision:** Open PRs in draft mode automatically.

**Why:** User's CLAUDE.md setting: "always open new PR's in draft mode"

**Benefit:** Saves CI minutes while working

### 7. Turbo Page Refresh Priority

**Decision:** Added turbo-page-refresh skill (not in original 39 examples).

**Why:**
- Team preference for morph over frames
- Simplifies Rails apps vs complex Turbo Frame setups
- Common pattern worth documenting

**Key Patterns:**
- `data-turbo-refresh-method="morph"`
- `broadcast_refresh_to` (not `broadcast_append_to`)
- `data-turbo-permanent` for stateful elements

### 8. Coordinator as Registry

**Decision:** Coordinator agent maintains master skills registry.

**Why:**
- Single source of truth for all skills
- Can suggest which skills to use for tasks
- Routes to specialized agents
- Librarian pattern

**Status:** ✅ IMPLEMENTED (Phase 2)

### 9. Machine-First Optimization with External YAML

**Decision:** Extract skills registry and rules mapping to external YAML files.

**Why:**
- **DRY compliance:** Single source of truth, no duplication in agent files
- **Machine-first parsing:** Structured YAML is faster for LLMs to parse than embedded markdown
- **Separation of concerns:** Data (YAML) vs instructions (agent prompts)
- **Maintainability:** Update metadata in one place
- **Bidirectional linking:** Rules know which skills enforce them, skills know which rules they enforce

**Implementation:**
- Created `skills/SKILLS_REGISTRY.yml` (590 lines)
- Created `rules/RULES_TO_SKILLS_MAPPING.yml` (472 lines)
- Updated coordinator to reference external files
- Added `enforces_team_rule` metadata to 11 skills

**Benefits:**
- 30% reduction in TEAM_RULES.md (1,115 → 774 lines)
- 5% reduction in agents/rails.md (1,227 → 1,163 lines)
- Consistent enforcement patterns
- Automatic skill loading on rule violations

---

## Phase 2: Agent Integration (IN PROGRESS - 50% Complete)

### Overview

Update all 8 agents to dynamically load and use skills. The coordinator agent has been fully updated with machine-first optimization, external YAML registries, and bidirectional linking. Specialized agents are pending.

### Completed Tasks ✅

#### 2.1 Update Coordinator Agent (COMPLETE)

**File:** `agents/rails.md`

**Goal:** Transform coordinator into skills registry/librarian with machine-first optimization.

**What We Accomplished:**

1. **Created External YAML Registries** (Machine-First Optimization)
   - `skills/SKILLS_REGISTRY.yml` (590 lines) - Single source of truth for all 33 skills
     - Complete metadata: domains, dependencies, descriptions, when-to-use
     - Keyword index for fast lookup
     - Dependency graph
   - `rules/RULES_TO_SKILLS_MAPPING.yml` (472 lines) - Bidirectional rules ↔ skills mapping
     - 10/19 rules with implementation skills (53% coverage)
     - Violation triggers (keywords, patterns)
     - Enforcement actions (REJECT vs SUGGEST)
     - Keyword-to-rule quick lookup
     - Usage instructions for coordinator

2. **Updated Coordinator Agent** (`agents/rails.md`)
   - Added skills registry reference section
   - Added bidirectional linking documentation
   - Added task analysis & skill recommendation workflows
   - Added agent routing logic
   - References external YAML files (DRY compliance)
   - Removed references to deleted `.claude/examples/` folder
   - Removed duplicate "Standards Enforcement" section
   - File size: 1,227 → 1,163 lines (-5%)

3. **Simplified TEAM_RULES.md** (30% Reduction)
   - Removed code examples (moved to skills)
   - Added machine-readable XML tags
   - Added `<implementation-skills>` links to skills
   - Clear separation: governance (not implementation)
   - File size: 1,115 → 774 lines (-30%)

4. **Updated 11 Skills with Enforcement Metadata**
   - Added `enforces_team_rule` to YAML front matter
   - Bidirectional linking: skills know which rules they enforce
   - Skills updated:
     - `solid-stack-setup.md` (Rule #1)
     - `tdd-minitest.md` (Rules #2, #4)
     - `controller-restful.md` (Rule #3)
     - `nested-resources.md` (Rules #3, #5)
     - `turbo-page-refresh.md` (Rule #7)
     - `viewcomponent-basics.md` (Rule #15)
     - `minitest-mocking.md` (Rule #18)
     - `antipattern-fat-controllers.md` (Rule #12)
     - `concerns-models.md` (Rule #5)
     - `hotwire-turbo.md` (Rules #7, #13)
     - `accessibility-patterns.md` (Rule #13)

5. **Added Meta README Intro**
   - "100% written by AI, for AI" section
   - Skynet reference with ASCII cow art
   - Witty "side effects" of sentient CI
   - Embraces recursive absurdity

**Benefits Achieved:**
- ✅ Machine-first optimization (fast LLM parsing)
- ✅ DRY compliance (single source of truth)
- ✅ Clear separation of concerns (rules = governance, skills = implementation)
- ✅ Bidirectional linking (rules ↔ skills)
- ✅ Automatic skill loading on rule violations
- ✅ Consistent enforcement patterns
- ✅ Educational (shows WHY rules exist AND HOW to comply)

**Stats:**
- 16 files changed
- +1,839 / -727 lines (net +1,112)
- All tests passing (bin/ci green)

### Pending Tasks 📋

#### 2.2 Update Specialized Agents (Priority 2 - PENDING)

**Files:** `agents/{feature,debugger,refactor,security,test,ui,api}.md` (7 agents)

**Goal:** Each agent loads its skill preset automatically.

**What to Add:**
1. **Skill Loading Section**
   - List skills this agent loads automatically
   - Explain when each skill is relevant

2. **Skill Application Instructions**
   - How to read and apply skill patterns
   - When to load additional skills
   - How to handle skill dependencies

**Format (example for Feature Agent):**
```markdown
# Feature Agent

You build full-stack Rails features...

## Your Skills

You automatically load these 13 skills:

### Frontend Skills
- turbo-page-refresh (morphing updates)
- viewcomponent-basics (reusable components)
- hotwire-turbo (Turbo Drive, Frames, Streams)
- tailwind-utility-first (utility-first CSS)
- daisyui-components (UI component library)

### Backend Skills
- controller-restful (REST controllers)
- activerecord-patterns (AR best practices)
- form-objects (complex form handling)
- query-objects (complex queries)

### Testing Skills
- tdd-minitest (TDD with Minitest)
- fixtures-test-data (test data)

### Security Skills
- security-csrf (CSRF protection)
- security-strong-parameters (strong params)

### Config Skills
- solid-stack-setup (Rails 8 Solid Stack)

## How to Use Skills

When starting a feature:
1. Load relevant skills from your preset
2. Read the <when-to-use> section
3. Apply patterns from <pattern> sections
4. Avoid <antipatterns>
5. Follow <standards>

Example: Building a real-time feedback feature

1. Read skills/frontend/turbo-page-refresh.md
2. Apply enable-page-refresh pattern:
   ```erb
   <body data-turbo-refresh-method="morph">
   ```
3. Read skills/backend/activerecord-patterns.md
4. Apply callback pattern:
   ```ruby
   after_create_commit -> { broadcast_refresh_to "feedbacks" }
   ```
5. Avoid antipattern: Using Turbo Frames when page refresh is simpler
```

**Template for Each Agent:**
1. Feature: 13 skills (frontend + backend + testing + security + config)
2. Debugger: 8 skills (testing + backend + frontend + security debugging)
3. Refactor: 8 skills (code quality, concerns, query objects, antipatterns)
4. Security: 9 skills (all security + testing + strong params)
5. Test: 6 skills (all testing)
6. UI: 13 skills (all frontend)
7. API: 17 skills (all backend + all security)

**Presets are already documented in AGENTS.md** - copy them into agent files.

#### 2.3 Skill Loading Protocol (Design)

**Goal:** Define how agents read and apply skills.

**Pseudocode:**
```ruby
def load_skill(skill_path)
  content = File.read("skills/#{skill_path}.md")

  # Parse YAML front matter
  metadata = extract_yaml(content)

  # Extract sections
  when_to_use = extract_section(content, "when-to-use")
  benefits = extract_section(content, "benefits")
  standards = extract_section(content, "standards")
  patterns = extract_patterns(content)
  antipatterns = extract_section(content, "antipatterns")
  testing = extract_section(content, "testing")

  # Return parsed skill
  {
    metadata: metadata,
    when_to_use: when_to_use,
    benefits: benefits,
    standards: standards,
    patterns: patterns,
    antipatterns: antipatterns,
    testing: testing
  }
end

def apply_skill(skill, context)
  # Read when-to-use
  if matches_context?(skill.when_to_use, context)
    # Apply patterns
    skill.patterns.each do |pattern|
      apply_pattern(pattern, context)
    end

    # Avoid antipatterns
    check_antipatterns(skill.antipatterns, context)
  end
end
```

**Note:** This is conceptual. Agents are LLM-based, so "loading" means reading the skill file and understanding it. The actual implementation will be in the agent instructions, not code.

#### 2.4 Testing Agent Integration

**Goal:** Verify agents can load and use skills.

**Test Scenarios:**
1. Give coordinator a task → Verify it suggests correct skills and agent
2. Give specialized agent a task → Verify it loads and applies correct patterns
3. Test skill dependencies → Verify agents load dependent skills
4. Test antipattern avoidance → Verify agents don't use antipatterns

**How to Test:**
1. Use agents in real Rails projects
2. Check generated code for correct patterns
3. Check for antipattern avoidance
4. Compare with expected skill patterns

**Document Findings:** Create `docs/agent-testing-notes.md`

#### 2.5 Scale Test Coverage (Parallel Work)

**Goal:** Add unit tests for remaining 32 skills.

**Priority Order:**
1. **High Priority** (security, core patterns): 8 skills
   - security-xss
   - security-sql-injection
   - security-csrf
   - security-strong-parameters
   - viewcomponent-basics
   - hotwire-turbo
   - tdd-minitest
   - controller-restful

2. **Medium Priority** (common patterns): 12 skills
   - All remaining frontend skills
   - activerecord-patterns
   - form-objects
   - query-objects

3. **Low Priority** (nice to have): 12 skills
   - Remaining backend skills
   - Config skills
   - Advanced testing skills

**How to Add Tests:**
```bash
# Generate test template
rake test:skills:new[skill-name,domain]

# Edit test file
# test/skills/unit/skill_name_test.rb

# Run test
ruby -Itest test/skills/unit/skill_name_test.rb

# Verify
rake test:skills:unit
```

**Goal:** Get to 100% coverage (33/33 skills with unit tests)

---

## Important Context for Continuation

### What NOT to Change

1. **Skill files** - They're complete, don't refactor them
2. **Testing framework** - It's working, don't change it
3. **CI/CD workflow** - It's passing, don't modify it
4. **Documentation** - It's comprehensive, don't rewrite it

### What NEEDS to Change

1. **Agent files** (`agents/*.md`) - Add skill loading and application instructions
2. **Coordinator specifically** - Add skills registry and routing logic
3. **Testing** - Scale coverage to more skills (currently 1/33)

### Critical Files to Read Before Starting Phase 2

1. **AGENTS.md** - Understand system governance and agent roles
2. **docs/skills-architecture.md** - Understand design decisions
3. **skills/frontend/turbo-page-refresh.md** - Example of complete skill format
4. **agents/rails.md** - Current coordinator agent (needs updating)
5. **One other agent file** - To understand current format

### Gotchas & Important Notes

1. **Skill format is final** - Don't change the hybrid format
2. **Integration tests use mock** - Real LLM integration pending
3. **Branch is `master` not `main`** - Everywhere
4. **Draft PRs by default** - Per user's CLAUDE.md
5. **Integration tests manual-only** - Don't enable automated runs
6. **Test template works** - Use `rake test:skills:new[name,domain]`
7. **All tests must pass** - Run `bin/ci` before committing
8. **Agents are instructions** - Not executable code, they're LLM instructions

### How to Pick Up

1. **Read this file** - Understand where we are
2. **Read AGENTS.md** - Understand system governance
3. **Check PR #1** - See what's been merged (it's still draft)
4. **Run `bin/setup`** - Verify local environment
5. **Run `bin/ci`** - Verify tests pass
6. **Read `agents/rails.md`** - See current coordinator format
7. **Start with Task 2.1** - Update coordinator agent first
8. **Test as you go** - Use agents in real scenarios

### Commands You'll Need

```bash
# Development
bin/setup                    # One-time setup
bin/ci                       # Run all checks

# Testing
rake test:skills:unit        # Run unit tests
rake test:skills:report      # Coverage report
rake test:skills:new[name,domain]  # Generate test template
ruby -Itest test/skills/unit/skill_test.rb  # Run specific test

# Linting
rake lint                    # All linters
rake lint:fix                # Auto-fix Ruby

# Git
git status                   # Check status
git add -A                   # Stage all
git commit -m "message"      # Commit
git push                     # Push to feature branch

# CI
gh pr checks 1               # Check PR CI status
gh pr view 1                 # View PR details
```

### Success Criteria for Phase 2

✅ Coordinator agent has skills registry
✅ Coordinator can suggest skills for tasks
✅ Coordinator routes to appropriate agents
✅ All 8 agents have skill loading instructions
✅ All 8 agents reference their skill presets
✅ Agents tested with real tasks
✅ Agent testing notes documented
✅ Test coverage increased (target: 20%+ = 7+ skills)
✅ All tests passing
✅ CI green
✅ Documentation updated

---

## Questions for Continuation

When picking up this work, consider:

1. **Skill loading format** - How should agents "read" skills? Copy entire skill into context? Reference patterns? Extract specific sections?

2. **Dependency handling** - If a skill depends on another, should agents load both automatically? Or just mention it?

3. **Context limits** - Loading all skills for coordinator = large context. Should coordinator just reference skills, not load full content?

4. **Testing agents** - How do we test agent skill loading? Real Rails projects? Simulated scenarios?

5. **Integration tests** - When should we enable automated integration tests? After agent integration? Or later?

6. **Test coverage goal** - Is 100% necessary? Or is 50% (high-priority skills) good enough?

7. **Agent format** - Should agents have a standard template for skill loading? Or customize per agent?

---

## Appendix: Useful Links

**GitHub:**
- Repository: https://github.com/zerobearing2/rails-ai
- PR #1: https://github.com/zerobearing2/rails-ai/pull/1
- Actions: https://github.com/zerobearing2/rails-ai/actions

**Documentation:**
- AGENTS.md - System governance
- docs/skill-testing-methodology.md - Testing approach
- docs/development-setup.md - Setup guide
- docs/github-actions-setup.md - CI/CD guide
- docs/skills-architecture.md - Design doc
- test/README.md - Testing documentation

**Key Skills (Examples):**
- skills/frontend/turbo-page-refresh.md - Complete skill example
- skills/backend/form-objects.md - Backend pattern example
- skills/testing/tdd-minitest.md - Testing pattern example
- skills/security/security-xss.md - Security pattern example

**Tests:**
- test/skills/unit/turbo_page_refresh_test.rb - Example unit test
- test/skills/integration/turbo_page_refresh_integration_test.rb - Example integration test

---

## Final Notes

This is a **clean stopping point**. Phase 1 is complete, tested, documented, and committed. Phase 2 is clearly defined and ready to start.

The foundation is solid:
- ✅ Skills architecture proven
- ✅ Testing framework working
- ✅ Development workflow smooth
- ✅ CI/CD automated
- ✅ Documentation comprehensive

Next step is straightforward: **Update agents to use skills**.

Good luck! 🚀

---

**Document History:**
- 2025-10-30: Initial version (Phase 1 complete, Phase 2 pending)
