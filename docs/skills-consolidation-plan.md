# Skills Consolidation Plan

**Goal:** Consolidate 38 fragmented skills into 9 domain-organized, minimal skills that are easier to maintain and use.

**Status:** Analysis Complete
**Date:** 2025-11-15

---

## 1. Current State Analysis

### All 38 Skills with Line Counts and Content Summary

| # | Skill Name | Lines | Domain | Summary |
|---|---|---|---|---|
| 1 | using-rails-ai | 147 | Meta | How to use Rails-AI CLI and skills |
| 2 | debugging-rails | 589 | Debug | Logs, console, byebug, SQL logging, browser debugging, Playwright |
| 3 | tdd-minitest | 889 | Testing | TDD red-green-refactor, test structure, assertions |
| 4 | model-testing | 761 | Testing | Advanced model tests (validations, associations, scopes, callbacks) |
| 5 | minitest-mocking | 652 | Testing | Stubs, mocks, spies, integration with external services |
| 6 | test-helpers | 507 | Testing | Custom test helpers, fixtures shortcuts, assertions |
| 7 | fixtures | 633 | Testing | Fixture design, associations, YAML best practices |
| 8 | activerecord-patterns | 810 | Models | Validations, callbacks, scopes, associations, enums |
| 9 | concerns-models | 518 | Models | Model concerns for shared behavior |
| 10 | custom-validators | 463 | Models | Custom ActiveModel validators |
| 11 | query-objects | 380 | Models | Extract complex queries into query objects |
| 12 | form-objects | 450 | Models | Form objects for complex form logic |
| 13 | controller-restful | 586 | Controllers | RESTful actions (index, show, new, create, edit, update, destroy) |
| 14 | nested-resources | 580 | Controllers | Nested routing and controllers |
| 15 | antipattern-fat-controllers | 373 | Controllers | Skinny controllers, service objects |
| 16 | concerns-controllers | 425 | Controllers | Controller concerns for shared behavior |
| 17 | security-strong-params | 431 | Controllers | Mass assignment protection with expect()/permit() |
| 18 | partials | 329 | Views | Partials, layouts, content_for |
| 19 | view-helpers | 289 | Views | View helpers for reusable HTML/formatting |
| 20 | forms-nested | 354 | Views | Nested forms with accepts_nested_attributes_for |
| 21 | accessibility | 472 | Views | WCAG 2.1 AA compliance, ARIA, keyboard navigation |
| 22 | hotwire-turbo | 825 | Views | Turbo Drive, Frames, Streams |
| 23 | hotwire-stimulus | 714 | Views | Stimulus controllers for JavaScript behavior |
| 24 | turbo-morph | 407 | Views | Turbo 8 page refreshes with morphing |
| 25 | tailwind | 566 | Views | Tailwind CSS utilities and conventions |
| 26 | daisyui | 374 | Views | DaisyUI component library |
| 27 | security-xss | 664 | Security | XSS prevention (output escaping, CSP, sanitization) |
| 28 | security-sql-injection | 291 | Security | SQL injection prevention (parameterized queries) |
| 29 | security-csrf | 500 | Security | CSRF protection with authenticity tokens |
| 30 | security-file-uploads | 621 | Security | Secure file uploads (validation, storage, serving) |
| 31 | security-command-injection | 456 | Security | Command injection prevention (array args, validation) |
| 32 | initializers | 292 | Config | Rails initializers, load order, configuration |
| 33 | credentials | 417 | Config | Encrypted credentials, master key, per-environment |
| 34 | environment-config | 515 | Config | Development, test, production environment configs |
| 35 | docker | 571 | Config | Docker setup, Dockerfile, docker-compose |
| 36 | rubocop | 589 | Config | RuboCop rules, custom cops, configuration |
| 37 | solid-stack | 502 | Jobs | SolidQueue, SolidCache, SolidCable (Rails 8 defaults) |
| 38 | action-mailer | 546 | Jobs | Email delivery, templates, letter_opener |

**Total Lines:** ~20,000+ lines across 38 skills

### Key Observations

1. **Heavy Fragmentation:** 6 security skills, 5 testing skills, 8 view-related skills - excessive splitting
2. **Duplication:** Security patterns repeated across multiple skills
3. **Inconsistent Depth:** Some skills 150 lines, others 900 lines
4. **Domain Scatter:** Related concepts spread across multiple files
5. **Maintenance Burden:** 38 separate files to update when Rails conventions change
6. **Discovery Challenge:** Users must know which of 38 skills to invoke

---

## 2. Consolidation Strategy (Ultrathink Analysis)

### Principles

**Domain-Driven Organization:** Group by Rails architectural layer (MVC + infrastructure)
- Controllers: All controller concerns in one place
- Models: All data layer patterns together
- Views: All frontend/presentation in one skill
- Testing: Complete testing story in one place
- Security: Centralized security knowledge
- Configuration: Environment and deployment setup
- Jobs/Mailers: Background processing and email
- Debugging: Comprehensive debugging toolkit
- Meta: Rails-AI usage (team-specific, keep separate)

**Minimal and Practical:**
- Developer thinks "I need to test models" → One skill, not 5
- Developer thinks "I need to secure file uploads" → One security skill, not 6
- Reduce cognitive load: 9 skills vs 38 skills

**Content Quality Over Quantity:**
- Keep: Critical patterns, security requirements, team rules, anti-patterns
- Remove: Redundant explanations, excessive examples, duplicated standards
- Simplify: Consolidate related patterns, streamline prose

### Analysis by Domain

#### Controllers (Consolidate 5 → 1)
**Current:** controller-restful, nested-resources, antipattern-fat-controllers, concerns-controllers, security-strong-params
**Strategy:** All controller patterns belong together. Strong params is fundamentally a controller concern (parameter filtering at the boundary). Natural flow: RESTful basics → nested resources → keeping controllers skinny → concerns → strong params.
**Overlap:** All discuss controller responsibilities and parameter handling
**Result:** Single comprehensive controllers skill (~1,800 lines → ~1,200 lines)

#### Models (Consolidate 6 → 1)
**Current:** activerecord-patterns, concerns-models, custom-validators, query-objects, form-objects
**Strategy:** All model/data layer patterns. ActiveRecord is foundation, concerns/validators/query objects/form objects are organizational patterns that extend it.
**Overlap:** All discuss model design and data access
**Result:** Single comprehensive models skill (~2,600 lines → ~1,500 lines)

#### Views (Consolidate 8 → 1)
**Current:** partials, view-helpers, forms-nested, accessibility, hotwire-turbo, hotwire-stimulus, turbo-morph, tailwind, daisyui
**Strategy:** Complete frontend stack in one place. Partials/helpers are basics, nested forms build on that, Hotwire adds interactivity, Tailwind/DaisyUI provide styling. Accessibility threads through everything.
**Overlap:** All discuss view layer and user interface
**Result:** Single comprehensive views skill (~4,300 lines → ~2,000 lines) - will be largest skill but that's appropriate for frontend

#### Testing (Consolidate 5 → 1)
**Current:** tdd-minitest, model-testing, minitest-mocking, test-helpers, fixtures
**Strategy:** Complete testing story. TDD process → writing tests → using fixtures → mocking external services → custom helpers. All part of one testing workflow.
**Overlap:** All discuss Minitest and testing patterns
**Result:** Single comprehensive testing skill (~3,400 lines → ~1,800 lines)

#### Security (Consolidate 5 → 1)
**Current:** security-xss, security-sql-injection, security-csrf, security-file-uploads, security-command-injection
**Strategy:** All security vulnerabilities in one reference. Common structure: attack vectors → secure patterns → anti-patterns. Developer needs holistic security view, not fragmented.
**Overlap:** All follow same pattern structure, all discuss input validation
**Result:** Single comprehensive security skill (~2,500 lines → ~1,500 lines)

#### Configuration (Consolidate 5 → 1)
**Current:** initializers, credentials, environment-config, docker, rubocop
**Strategy:** All infrastructure/deployment setup. Environment configs → credentials → initializers → Docker deployment → RuboCop quality. Natural setup sequence.
**Overlap:** All discuss application configuration and deployment
**Result:** Single comprehensive configuration skill (~2,400 lines → ~1,400 lines)

#### Jobs & Mailers (Consolidate 2 → 1)
**Current:** solid-stack, action-mailer
**Strategy:** Both are asynchronous operations. SolidQueue for jobs, ActionMailer uses jobs. Natural pairing.
**Overlap:** Both discuss background processing
**Result:** Single jobs-mailers skill (~1,000 lines → ~700 lines)

#### Debugging (Keep Standalone)
**Current:** debugging-rails (589 lines)
**Strategy:** Already focused and comprehensive. No consolidation needed.
**Result:** Keep as-is (~600 lines)

#### Meta (Keep Standalone)
**Current:** using-rails-ai (147 lines)
**Strategy:** Team-specific usage guide. Unique purpose, keep separate.
**Result:** Keep as-is (~150 lines)

### Expected Consolidation Benefits

1. **Cognitive Load:** 9 skills vs 38 (77% reduction)
2. **Line Count:** ~20,000 → ~11,000 lines (45% reduction)
3. **Discoverability:** Clear domain mapping
4. **Maintenance:** Update one file per domain vs hunting across 5-8 files
5. **Comprehensiveness:** Complete story per domain, no fragmentation

---

## 3. Proposed New Structure (9 Skills)

### 1. `controllers` (~1,200 lines)
**Description:** Use when building Rails controllers - RESTful actions, nested resources, skinny controllers, concerns, strong parameters (expect/permit)

**Content:**
- RESTful CRUD actions (index, show, new, create, edit, update, destroy)
- Nested resource routing and controllers
- Skinny controller patterns (avoid fat controllers)
- Controller concerns for shared behavior
- Strong parameters (expect/permit) for mass assignment protection
- Respond_to formats (HTML, JSON, Turbo Stream)
- Before/after actions
- Flash messages

**Consolidates:** controller-restful, nested-resources, antipattern-fat-controllers, concerns-controllers, security-strong-params

---

### 2. `models` (~1,500 lines)
**Description:** Use when designing Rails models - ActiveRecord patterns, validations, callbacks, scopes, associations, concerns, query objects, form objects

**Content:**
- Validations (presence, format, uniqueness, custom)
- Associations (belongs_to, has_many, has_one, has_and_belongs_to_many)
- Callbacks (before_save, after_create, etc.)
- Scopes and class methods
- Enums
- Model concerns for shared behavior
- Custom validators
- Query objects for complex queries
- Form objects for complex form logic
- ActiveRecord query interface
- Database best practices (indexes, N+1 prevention)

**Consolidates:** activerecord-patterns, concerns-models, custom-validators, query-objects, form-objects

---

### 3. `views` (~2,000 lines)
**Description:** Use when building Rails views - partials, helpers, forms, accessibility, Hotwire (Turbo/Stimulus), Tailwind, DaisyUI

**Content:**
- Partials and layouts (content_for, yield)
- View helpers (built-in and custom)
- Nested forms (accepts_nested_attributes_for, fields_for)
- Accessibility (WCAG 2.1 AA, ARIA, keyboard navigation, semantic HTML)
- Hotwire Turbo (Drive, Frames, Streams, morphing)
- Hotwire Stimulus (controllers, targets, actions, values)
- Tailwind CSS utilities and conventions
- DaisyUI components and theming
- Form building best practices
- Progressive enhancement

**Consolidates:** partials, view-helpers, forms-nested, accessibility, hotwire-turbo, hotwire-stimulus, turbo-morph, tailwind, daisyui

---

### 4. `testing` (~1,800 lines)
**Description:** Use when testing Rails applications - TDD, Minitest, fixtures, model testing, mocking, test helpers

**Content:**
- TDD red-green-refactor workflow
- Test structure and organization
- Minitest assertions and refutations
- Model testing (validations, associations, scopes, callbacks, edge cases)
- Controller/integration testing
- System tests with Capybara
- Fixtures design and associations
- Mocking and stubbing (stubs, mocks, external services)
- Custom test helpers and shared setup
- Test isolation and determinism
- Performance testing considerations

**Consolidates:** tdd-minitest, model-testing, minitest-mocking, test-helpers, fixtures

---

### 5. `security` (~1,500 lines)
**Description:** Use when securing Rails applications - CRITICAL patterns for XSS, SQL injection, CSRF, file uploads, command injection

**Content:**
- XSS prevention (output escaping, sanitization, CSP)
- SQL injection prevention (parameterized queries, ActiveRecord methods)
- CSRF protection (authenticity tokens, form_with, AJAX headers)
- Secure file uploads (validation, storage, serving, virus scanning)
- Command injection prevention (array args, input validation)
- Security headers and best practices
- Common attack vectors and defenses
- Testing security patterns

**Consolidates:** security-xss, security-sql-injection, security-csrf, security-file-uploads, security-command-injection

---

### 6. `configuration` (~1,400 lines)
**Description:** Use when configuring Rails applications - environment config, credentials, initializers, Docker, RuboCop

**Content:**
- Environment-specific configuration (development, test, production, staging)
- Encrypted credentials and secrets management (master key, per-environment)
- Initializers (load order, configuration, to_prepare)
- Docker setup (Dockerfile, docker-compose, multi-stage builds)
- RuboCop configuration (rules, custom cops, team standards)
- Feature flags and environment variables
- CI/CD integration
- Deployment best practices

**Consolidates:** initializers, credentials, environment-config, docker, rubocop

---

### 7. `jobs-mailers` (~700 lines)
**Description:** Use when setting up background jobs and email - SolidQueue, SolidCache, SolidCable, ActionMailer (Rails 8 Solid Stack)

**Content:**
- SolidQueue setup and configuration (TEAM RULE #1: NEVER Sidekiq/Redis)
- SolidCache for application caching
- SolidCable for ActionCable/WebSockets
- Multi-database management (queue, cache, cable)
- Job design and testing
- ActionMailer setup and templates
- Email delivery (SMTP, letter_opener)
- Email testing and previews
- Job monitoring and error handling

**Consolidates:** solid-stack, action-mailer

---

### 8. `debugging` (~600 lines)
**Description:** Use when debugging Rails applications - logs, console, byebug, SQL logging, browser tools, Playwright

**Content:**
- Rails logs and log levels
- Rails console debugging
- Byebug breakpoints and commands
- SQL query logging and analysis
- Browser DevTools integration
- System tests with Playwright
- Performance debugging
- Security debugging
- Accessibility debugging
- Production debugging considerations

**Keeps:** debugging-rails (no consolidation needed)

---

### 9. `using-rails-ai` (~150 lines)
**Description:** How to use Rails-AI CLI and skills effectively - team-specific usage guide

**Content:**
- Rails-AI CLI commands
- Skill invocation patterns
- Best practices for AI-assisted development
- Team workflow integration
- Prompt engineering for Rails development
- Claude Code integration

**Keeps:** using-rails-ai (team-specific, no consolidation needed)

---

## 4. Skill Mapping (Before → After)

### Controllers Domain
```
controller-restful (586)       ┐
nested-resources (580)         │
antipattern-fat-controllers    ├──→ controllers (~1,200 lines)
concerns-controllers (425)     │
security-strong-params (431)   ┘
```

### Models Domain
```
activerecord-patterns (810)    ┐
concerns-models (518)          │
custom-validators (463)        ├──→ models (~1,500 lines)
query-objects (380)            │
form-objects (450)             ┘
```

### Views Domain
```
partials (329)                 ┐
view-helpers (289)             │
forms-nested (354)             │
accessibility (472)            ├──→ views (~2,000 lines)
hotwire-turbo (825)            │
hotwire-stimulus (714)         │
turbo-morph (407)              │
tailwind (566)                 │
daisyui (374)                  ┘
```

### Testing Domain
```
tdd-minitest (889)             ┐
model-testing (761)            │
minitest-mocking (652)         ├──→ testing (~1,800 lines)
test-helpers (507)             │
fixtures (633)                 ┘
```

### Security Domain
```
security-xss (664)             ┐
security-sql-injection (291)   │
security-csrf (500)            ├──→ security (~1,500 lines)
security-file-uploads (621)    │
security-command-injection     ┘
```

### Configuration Domain
```
initializers (292)             ┐
credentials (417)              │
environment-config (515)       ├──→ configuration (~1,400 lines)
docker (571)                   │
rubocop (589)                  ┘
```

### Jobs & Mailers Domain
```
solid-stack (502)              ┐
action-mailer (546)            ├──→ jobs-mailers (~700 lines)
                               ┘
```

### Standalone (No Changes)
```
debugging-rails (589)          →  debugging (~600 lines)
using-rails-ai (147)           →  using-rails-ai (~150 lines)
```

---

## 5. Content Decisions (Keep, Remove, Simplify)

### What to KEEP (Critical Content)

**1. Security Requirements (All)**
- Attack vectors and vulnerabilities
- ONE secure pattern with machine-parseable example
- ONE anti-pattern with clear good/bad comparison
- Team rules (e.g., TEAM RULE #1: Solid Stack only)

**2. Core Patterns**
- RESTful controller actions
- ActiveRecord associations and validations
- Hotwire Turbo/Stimulus fundamentals
- TDD red-green-refactor workflow
- Configuration best practices
- **ONE representative code example per pattern** (good example)
- **ONE anti-pattern example** (bad example, if needed to show what NOT to do)

**3. Anti-patterns**
- ONE anti-pattern per concept (critical for learning what NOT to do)
- Clear reasoning for why pattern is bad
- **Good vs bad examples consolidated into single comparison**

**4. Testing Patterns**
- Test structure and assertions
- Fixture design
- Mocking patterns
- **ONE test example per pattern**

**5. Team Rules**
- TEAM RULE #1: Solid Stack only (no Sidekiq/Redis)
- TEAM RULE #13: Progressive enhancement
- Custom RuboCop rules (Hash#dig, etc.)

**6. Machine-First Approach**
- Keep XML semantic tags (`<when-to-use>`, `<benefits>`, `<pattern>`, `<antipatterns>`, etc.)
- Structured, parseable code examples
- Clear pattern/antipattern boundaries for LLM extraction

### What to REMOVE (Duplication)

**1. Redundant Introductions**
- Each skill has "when to use", "benefits", "standards" - consolidate these at skill level, not per-pattern
- Reduce from 38 skill-level intros to 9

**2. Repeated Explanations**
- Example: SQL injection prevention repeated in security-sql-injection AND activerecord-patterns
- Example: Strong params explained in controllers AND security-strong-params
- Solution: Single authoritative explanation per concept

**3. Excessive Examples - MINIMIZE TO 1 GOOD + 1 BAD**
- **Keep ONLY 1 representative "good" example per pattern**
- **Keep ONLY 1 "bad" example if needed to show anti-pattern**
- Remove all variations that don't add new insights
- Example: security-xss has 8 sanitization examples → keep 1 good, 1 bad
- **Goal: Maximum clarity with minimum code**

**4. Verbose Prose**
- Tighten descriptions
- Use bullet points over paragraphs
- Example: "This pattern helps you..." → "Pattern provides..."
- **Machine-first: LLMs extract patterns, not prose**

**5. Redundant Resource Links**
- Consolidate external resources at skill level
- Remove duplicate links to same Rails guides across skills

**6. Multiple Code Variations**
- Remove alternative implementations of same pattern
- Keep the clearest, most idiomatic example only
- Trust LLM to adapt pattern to specific use cases

### What to SIMPLIFY (Streamline)

**1. Pattern Structure (Machine-First)**
```xml
<pattern name="pattern-name">
  <description>One-line description</description>
  <implementation>
    <!-- ONE good example -->
  </implementation>
  <why>Brief explanation (2-3 sentences max)</why>
</pattern>

<antipattern>
  <description>One-line description</description>
  <bad-example>
    <!-- ONE bad example -->
  </bad-example>
  <good-example>
    <!-- ONE good example -->
  </good-example>
  <why-bad>Brief explanation (2-3 sentences max)</why-bad>
</antipattern>
```
- **Standardize: XML tags for machine parseability**
- **Remove: Lengthy explanations, redundant benefits lists**
- **1 good + 1 bad example maximum**

**2. Related Skills References**
- Currently each skill lists 3-5 related skills
- After consolidation, most are internal sections - reduce cross-references
- Reference sections within consolidated skills instead

**3. Testing Sections**
- Each skill has testing examples
- **Consolidate to 1 test example per pattern**
- Keep unique testing insights only

**4. Standards Sections**
- Many skills list 8-10 standards
- Consolidate to 3-5 critical standards per skill
- Remove redundant "ALWAYS use X" statements that appear in multiple places

**5. When-to-Use Sections**
- Currently very detailed in each skill
- Simplify to 3-5 clear bullet points per consolidated skill
- Use XML `<when-to-use>` tag for machine parseability

### Expected Reduction Breakdown

**Strategy: 1 Good + 1 Bad Example Maximum**

| Domain | Current Lines | Reduction Source | Target Lines | Reduction |
|--------|--------------|------------------|--------------|-----------|
| Controllers | ~2,800 | Duplicate intros (800) + Excess examples (600) + Prose (200) | ~1,200 | -57% |
| Models | ~2,600 | Duplicate patterns (700) + Excess examples (400) | ~1,500 | -42% |
| Views | ~4,300 | Duplicate Hotwire (1,200) + Excess examples (900) + Prose (200) | ~2,000 | -53% |
| Testing | ~3,400 | Duplicate test patterns (1,100) + Excess examples (500) | ~1,800 | -47% |
| Security | ~2,500 | Duplicate vectors (600) + Excess examples (400) | ~1,500 | -40% |
| Config | ~2,400 | Duplicate configs (700) + Excess examples (300) | ~1,400 | -42% |
| Jobs | ~1,000 | Duplicate configs (200) + Excess examples (100) | ~700 | -30% |
| Debug | ~600 | None (already minimal) | ~600 | 0% |
| Meta | ~150 | None (team-specific) | ~150 | 0% |
| **Total** | **~20,000** | **~9,000 lines removed** | **~11,000** | **-45%** |

**Key Reduction Factors:**
- **Excess code examples:** ~3,600 lines (18% of total)
- **Duplicate explanations:** ~4,300 lines (21% of total)
- **Verbose prose:** ~1,100 lines (6% of total)

**1 Good + 1 Bad Rule = Maximum Clarity, Minimum Bloat**

---

## 6. Migration Plan (Step-by-Step Execution)

### Phase 1: Preparation (1 day)

**Step 1.1: Create New Skill Directories**
```bash
mkdir -p skills/{controllers,models,views,testing,security,configuration,jobs-mailers}
cp skills/debugging-rails skills/debugging -r
cp skills/using-rails-ai . -r  # Keep as-is
```

**Step 1.2: Set Up Git Branch**
```bash
git checkout -b skill-consolidation
git add -A
git commit -m "Checkpoint: Pre-consolidation state"
```

**Step 1.3: Create Template Structure**
- Create SKILL.md template with standard sections
- Define consistent frontmatter format
- Prepare pattern template structure

### Phase 2: Content Consolidation (3-4 days, one domain per session)

**Step 2.1: Controllers Consolidation**
```markdown
Target: skills/controllers/SKILL.md (~1,200 lines)

Process:
1. Start with controller-restful.md as base
2. Merge nested-resources patterns (section: "Nested Resources")
3. Integrate antipattern-fat-controllers (section: "Skinny Controllers")
4. Add concerns-controllers patterns (section: "Controller Concerns")
5. Merge security-strong-params (section: "Strong Parameters")
6. Remove duplicate when-to-use/benefits
7. Consolidate testing examples
8. Streamline anti-patterns (remove redundant examples)
9. Update frontmatter description
10. Test by invoking skill and reviewing output
```

**Step 2.2: Models Consolidation**
```markdown
Target: skills/models/SKILL.md (~1,500 lines)

Process:
1. Start with activerecord-patterns.md as base (most comprehensive)
2. Merge concerns-models (section: "Model Concerns")
3. Add custom-validators (section: "Custom Validators")
4. Integrate query-objects (section: "Query Objects")
5. Merge form-objects (section: "Form Objects")
6. Remove redundant validation examples
7. Consolidate association patterns
8. Streamline callback examples
9. Update frontmatter description
10. Test skill invocation
```

**Step 2.3: Views Consolidation**
```markdown
Target: skills/views/SKILL.md (~2,000 lines)

Process:
1. Start with new structure (largest consolidation)
2. Add partials patterns (section: "Partials & Layouts")
3. Merge view-helpers (section: "View Helpers")
4. Integrate forms-nested (section: "Nested Forms")
5. Add accessibility (section: "Accessibility") - thread through all patterns
6. Merge hotwire-turbo (section: "Hotwire Turbo")
7. Add hotwire-stimulus (section: "Hotwire Stimulus")
8. Integrate turbo-morph (section: "Turbo Morphing")
9. Add tailwind (section: "Tailwind CSS")
10. Merge daisyui (section: "DaisyUI Components")
11. Ensure accessibility considerations in each section
12. Remove duplicate Hotwire explanations
13. Consolidate Tailwind/DaisyUI examples
14. Update frontmatter description
15. Test skill invocation
```

**Step 2.4: Testing Consolidation**
```markdown
Target: skills/testing/SKILL.md (~1,800 lines)

Process:
1. Start with tdd-minitest.md as base (TDD process foundation)
2. Merge model-testing advanced patterns
3. Add minitest-mocking patterns (section: "Mocking & Stubbing")
4. Integrate test-helpers (section: "Custom Test Helpers")
5. Merge fixtures (section: "Fixtures Design")
6. Remove redundant test examples
7. Consolidate assertion patterns
8. Update frontmatter description
9. Test skill invocation
```

**Step 2.5: Security Consolidation**
```markdown
Target: skills/security/SKILL.md (~1,500 lines)

Process:
1. Create new structure with consistent format
2. Add security-xss (section: "XSS Prevention")
3. Merge security-sql-injection (section: "SQL Injection Prevention")
4. Add security-csrf (section: "CSRF Protection")
5. Integrate security-file-uploads (section: "Secure File Uploads")
6. Merge security-command-injection (section: "Command Injection Prevention")
7. Consolidate attack vector descriptions
8. Remove redundant secure pattern examples
9. Streamline anti-patterns (keep unique examples only)
10. Add security testing section
11. Update frontmatter description
12. Test skill invocation
```

**Step 2.6: Configuration Consolidation**
```markdown
Target: skills/configuration/SKILL.md (~1,400 lines)

Process:
1. Start with environment-config.md as base
2. Merge credentials (section: "Credentials & Secrets")
3. Add initializers (section: "Initializers")
4. Integrate docker (section: "Docker & Deployment")
5. Merge rubocop (section: "RuboCop & Code Quality")
6. Remove redundant environment examples
7. Consolidate Docker patterns
8. Update frontmatter description
9. Test skill invocation
```

**Step 2.7: Jobs & Mailers Consolidation**
```markdown
Target: skills/jobs-mailers/SKILL.md (~700 lines)

Process:
1. Start with solid-stack.md as base
2. Merge action-mailer (section: "ActionMailer")
3. Emphasize TEAM RULE #1 (Solid Stack only)
4. Remove redundant configuration examples
5. Consolidate testing patterns
6. Update frontmatter description
7. Test skill invocation
```

**Step 2.8: Keep Standalone Skills**
```markdown
- skills/debugging/ - Keep as-is (already focused, 600 lines)
- skills/using-rails-ai/ - Keep as-is (team-specific, 150 lines)
```

### Phase 3: Quality Assurance (1 day)

**Step 3.1: Consistency Check**
- Verify all 9 skills follow standard template
- Check frontmatter format consistency
- Ensure pattern structure consistency
- Validate markdown syntax

**Step 3.2: Content Review**
- Verify no critical content lost
- Check all team rules preserved
- Ensure all anti-patterns included
- Validate security patterns complete

**Step 3.3: Testing**
- Test each skill invocation via Rails-AI CLI
- Verify skill descriptions accurate
- Check related-skills references updated
- Test search functionality

**Step 3.4: Documentation Updates**
- Update README.md with new skill structure
- Update TEAM_RULES.md if needed
- Create migration notes for team

### Phase 4: Deployment (1 day)

**Step 4.1: Backup Old Skills**
```bash
mkdir -p archive/skills-pre-consolidation
mv skills/* archive/skills-pre-consolidation/
git add -A
git commit -m "Archive pre-consolidation skills"
```

**Step 4.2: Deploy New Skills**
```bash
mv skills-consolidated/* skills/
git add -A
git commit -m "Deploy consolidated skills (38 → 9)"
```

**Step 4.3: Validation**
- Test all 9 skills via CLI
- Run any automated tests
- Verify skill discovery works

**Step 4.4: Communication**
- Announce consolidation to team
- Provide before/after mapping
- Share migration notes

### Phase 5: Cleanup (ongoing)

**Step 5.1: Monitor Usage**
- Track which skills are used most
- Identify any missing content
- Gather team feedback

**Step 5.2: Iterate**
- Add missing patterns discovered in use
- Refine consolidation based on feedback
- Update related-skills references

**Step 5.3: Archive Cleanup**
```bash
# After 30 days of successful usage
rm -rf archive/skills-pre-consolidation
git commit -m "Remove archived skills after successful consolidation"
```

---

## 7. Expected Outcomes

### Quantitative Benefits

**Line Count Reduction:**
- Before: ~20,000 lines across 38 skills
- After: ~11,000 lines across 9 skills
- Reduction: 45% fewer lines (9,000 lines removed)

**Skill Count Reduction:**
- Before: 38 skills
- After: 9 skills
- Reduction: 77% fewer skills (29 skills consolidated)

**Maintenance Burden:**
- Before: 38 files to update when Rails conventions change
- After: 9 files to update
- Reduction: 76% fewer files to maintain

**Average Skill Size:**
- Before: ~526 lines per skill (high variance: 147-889)
- After: ~1,222 lines per skill (more consistent: 150-2,000)
- Result: More balanced, comprehensive skills

### Qualitative Benefits

**1. Improved Discoverability**
- "I need controller help" → One skill (controllers)
- "I need security help" → One skill (security)
- No more hunting across 5-6 related skills

**2. Better Comprehension**
- Complete domain story in one place
- Natural pattern progression (basics → advanced)
- Reduced context switching

**3. Easier Maintenance**
- Update one file per domain vs 5-8 fragmented files
- Easier to spot duplications and inconsistencies
- Clearer ownership per domain

**4. Consistent Quality**
- Standardized pattern structure across all skills
- Uniform anti-pattern documentation
- Consistent testing approach

**5. Reduced Cognitive Load**
- 9 skills vs 38 (77% reduction)
- Clear domain boundaries
- Less decision fatigue ("which skill do I need?")

**6. Team Efficiency**
- Faster onboarding (9 skills to learn vs 38)
- Clearer expertise areas
- Better knowledge sharing

### Success Metrics

**Week 1:**
- ✅ All 9 skills deployed
- ✅ No critical content lost
- ✅ Team can invoke all skills successfully
- ✅ All anti-patterns preserved
- ✅ All team rules enforced

**Week 2-4:**
- 📊 Monitor skill usage patterns
- 📊 Gather team feedback
- 📊 Track any "missing content" reports
- 📊 Measure developer satisfaction

**Month 2-3:**
- 🎯 Refine based on usage data
- 🎯 Add any discovered gaps
- 🎯 Further optimize if needed
- 🎯 Document lessons learned

### Risk Mitigation

**Risk: Critical content lost during consolidation**
- Mitigation: Archive old skills for 30 days, systematic content review checklist

**Risk: Skill too large to be useful**
- Mitigation: Target 1,200-2,000 line sweet spot, clear table of contents, good section headers

**Risk: Team resistance to change**
- Mitigation: Communicate benefits early, provide before/after mapping, migration guide

**Risk: Regression in skill quality**
- Mitigation: QA phase with content review, team testing period, rollback plan

---

## Appendices

### Appendix A: Skill Size Analysis

```
Proposed Skill Sizes (smallest to largest):

1. using-rails-ai:    ~150 lines   (meta, keep as-is)
2. debugging:         ~600 lines   (standalone, keep as-is)
3. jobs-mailers:      ~700 lines   (2 skills merged)
4. controllers:       ~1,200 lines (5 skills merged)
5. configuration:     ~1,400 lines (5 skills merged)
6. models:            ~1,500 lines (6 skills merged) - Note: Could add enums skill if discovered
7. security:          ~1,500 lines (5 skills merged)
8. testing:           ~1,800 lines (5 skills merged)
9. views:             ~2,000 lines (8 skills merged) - Largest but appropriate for frontend

Total: ~11,000 lines
Average: ~1,222 lines per skill
```

### Appendix B: Content Preservation Checklist

**Team Rules:**
- [ ] TEAM RULE #1: Solid Stack only (NO Sidekiq/Redis) - preserved in jobs-mailers
- [ ] TEAM RULE #13: Progressive enhancement - preserved in views
- [ ] TEAM RULE #20: Hash#dig enforcement - preserved in configuration (RuboCop)

**Security Patterns:**
- [ ] All XSS attack vectors documented
- [ ] SQL injection parameterized query patterns
- [ ] CSRF token handling (forms + AJAX)
- [ ] File upload validation (content type + magic bytes + extension)
- [ ] Command injection array args patterns

**Critical Anti-Patterns:**
- [ ] Fat controllers anti-pattern
- [ ] String interpolation in SQL (injection risk)
- [ ] Missing CSRF tokens
- [ ] Trusting user filenames
- [ ] Using backticks for commands

**Testing Patterns:**
- [ ] TDD red-green-refactor workflow
- [ ] Fixture associations and best practices
- [ ] Mocking external services
- [ ] Model validation testing edge cases

### Appendix C: Related Skills Migration Guide

**Old Reference → New Reference**

When updating related-skills sections:

```yaml
# OLD (38 skills)
related-skills:
  - rails-ai:controller-restful
  - rails-ai:security-strong-params
  - rails-ai:security-csrf

# NEW (9 skills)
related-skills:
  - rails-ai:controllers (see sections: RESTful Actions, Strong Parameters)
  - rails-ai:security (see sections: CSRF Protection)
```

---

## Conclusion

This consolidation plan reduces 38 fragmented skills to 9 domain-organized skills, cutting total lines by 45% while preserving all critical content. The new structure aligns with Rails MVC architecture, making skills more discoverable, maintainable, and comprehensive.

**Key Principles:**
- ✅ **Machine-first approach:** XML tags for LLM parseability
- ✅ **1 Good + 1 Bad rule:** Maximum clarity with minimum code examples
- ✅ **Domain-organized:** Rails MVC architecture alignment
- ✅ **Minimal and practical:** Only necessary content, no bloat
- ✅ **Team rules preserved:** All critical governance maintained

**Code Example Philosophy:**
- Every pattern gets **1 representative good example**
- Anti-patterns get **1 bad example + 1 good alternative**
- LLMs adapt patterns to use cases - no need for 5 variations
- Trust machine intelligence to extrapolate from minimal examples

**Next Steps:**
1. Review and approve plan
2. Begin Phase 1 (Preparation)
3. Execute Phase 2 (Consolidation) one domain at a time
   - Apply "1 good + 1 bad" rule rigorously
   - Keep XML semantic tags for machine parsing
   - Eliminate all redundant examples
4. QA and deploy (Phases 3-4)
5. Monitor and iterate (Phase 5)

**Timeline:** ~1 week focused effort, then ongoing refinement based on usage.
