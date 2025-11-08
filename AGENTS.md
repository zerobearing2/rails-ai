# Rails AI Agents System

**Version:** 2.0
**Last Updated:** 2025-11-08
**Status:** Open Source & Production Ready

This document is **internal documentation** for contributors who want to understand or modify the rails-ai agent architecture. This file is NOT used by the Claude Code plugin system - it's for humans only.

When users install the rails-ai plugin, they get the individual agent files from `agents/` directory, not this document.

> **⚠️ IMPORTANT FOR CONTRIBUTORS:**
> Before adding new rules, skills, or agents, **ALWAYS consult the [Contributor Checklists](#contributor-checklists)** section below.
> Failing to update all required files will cause test failures and system inconsistencies.

---

## System Overview

The Rails AI project uses a **skills-based architecture** where specialized agents dynamically load modular skills to perform tasks. This approach provides:

- **Modularity** - Skills are independent, reusable knowledge units
- **Scalability** - Easy to add new skills without modifying agents
- **Maintainability** - Update one skill, all agents benefit
- **Dynamic Loading** - Agents load skills on-demand based on task context

### Architecture

```text
rails-ai/
├── agents/                     # 7 specialized agents (loaded by Claude Code plugin)
│   ├── architect.md            # Coordinator (main entry point)
│   ├── plan.md                 # Planning (Specification Pyramid framework)
│   ├── backend.md              # Backend API + business logic
│   ├── frontend.md             # Frontend UI + Hotwire/Tailwind
│   ├── tests.md                # Test writing (TDD with Minitest)
│   ├── security.md             # Security auditing
│   └── debug.md                # Debugging and error resolution
├── skills/                     # 40 modular skills (referenced by agents)
│   └── SKILLS_REGISTRY.yml     # Central catalog of all skills
├── rules/                      # Team conventions (referenced by agents)
├── test/                       # Testing framework
│   ├── agents/unit/            # Agent structure tests
│   └── skills/unit/            # Skill validation tests
├── bin/                        # Development scripts
│   ├── setup                   # One-time setup
│   └── ci                      # CI checks (lint + tests)
├── docs/                       # Documentation
├── AGENTS.md                   # This file (internal docs for contributors)
├── README.md                   # Public documentation
├── CONTRIBUTING.md             # Contribution guidelines
└── LICENSE                     # MIT License
```

---

## Skills Management

### Skills Registry

All 41 skills are defined in **`skills/SKILLS_REGISTRY.yml`** - a single centralized catalog that agents reference. This registry-based approach provides:

- **Single source of truth** - All skills in one file
- **Fast agent loading** - Agents read one file instead of 33
- **Easy discovery** - Skills are organized by domain
- **Metadata-rich** - Each skill has name, description, dependencies, when_to_use
- **Version tracking** - Registry tracks total skill count and domain breakdown

### Skill Format in Registry

Each skill in SKILLS_REGISTRY.yml follows this structure:

```yaml
viewcomponent-basics:
  name: "ViewComponent Basics"
  domain: frontend
  dependencies: []
  description: "Build reusable, testable, encapsulated view components"
  when_to_use:
    - "Building reusable UI components"
    - "Need testable view logic"
    - "Performance matters (10x faster than partials)"
  patterns:
    component_class:
      description: "Define component class inheriting from ViewComponent::Base"
      example: |
        class AlertComponent < ViewComponent::Base
          def initialize(type:, message:)
            @type = type
            @message = message
          end
        end
    component_template:
      description: "Create companion template file"
      example: |
        # app/components/alert_component.html.erb
        <div class="alert alert-<%= @type %>">
          <%= @message %>
        </div>
  antipatterns:
    - name: "Complex logic in templates"
      reason: "Violates component encapsulation"
      solution: "Move logic to component class methods"
  testing:
    example: |
      class AlertComponentTest < ViewComponent::TestCase
        def test_renders_warning_alert
          render_inline(AlertComponent.new(type: :warning, message: "Test"))
          assert_selector(".alert.alert-warning", text: "Test")
        end
      end
  related_skills:
    - viewcomponent-slots
    - viewcomponent-previews
  enforces_rules: [15]  # Rule 15: Use ViewComponent for reusable UI
```

---

## Contributor Checklists

**CRITICAL:** When adding new rules, skills, or agents, use these comprehensive checklists to ensure ALL files are updated. Missing even one step can cause test failures and system inconsistencies.

### ✅ Adding a New Rule

Use this checklist when creating a new team rule (e.g., Rule #21).

#### Core Rule Files
- [ ] **`rules/TEAM_RULES.md`**
  - [ ] Add to YAML front matter:
    - [ ] Add to `categories` list if new category
    - [ ] Add to `violation_keywords` (rule_N: [keywords])
    - [ ] Add to `enforcement.severity` (critical/high/moderate)
  - [ ] Add to Quick Rule Lookup (`<quick-lookup>` section):
    - [ ] Add rule entry with name, severity, triggers, action, skills (if applicable)
  - [ ] Add to Domain Index (e.g., "Code Quality & Style"):
    - [ ] Add bullet point with rule number and name
  - [ ] Add full rule definition section (### N. Rule Name):
    - [ ] `<violation-triggers>` - Keywords and patterns
    - [ ] `<enforcement>` - Action and severity
    - [ ] Why section explaining rationale
    - [ ] Examples (❌ Bad, ✅ Good)
    - [ ] When to use guidance
  - [ ] Update Rules Summary table:
    - [ ] Add row with rule number, name, severity, category, has_skill
    - [ ] Update total count
    - [ ] Update coverage percentages
  - [ ] Update Enforcement Strategy section:
    - [ ] Add to appropriate severity list (Critical/High/Moderate)
  - [ ] Update Quick Reference section:
    - [ ] Add trigger patterns to lookup list

#### Mapping Files
- [ ] **`rules/RULES_TO_SKILLS_MAPPING.yml`**
  - [ ] Update `metadata`:
    - [ ] Increment `total_rules` count
    - [ ] Update `rules_with_skills` or `rules_without_skills` count
    - [ ] Recalculate `coverage_percent`
  - [ ] Add to `rules_by_domain`:
    - [ ] Add `rule_N_name` to appropriate domain's rules array
  - [ ] Add to either `rules_with_skills` or `rules_without_skills`:
    - [ ] Create full entry with id, name, severity, category
    - [ ] Add `violation_triggers` (keywords, patterns)
    - [ ] Add `skills` section if rule has implementation skills
    - [ ] Add `enforced_by` if automated (rubocop, etc.)
    - [ ] Add `why` explanation
  - [ ] Add to `enforcement_patterns`:
    - [ ] Add rule number to appropriate severity array
  - [ ] Add to `keyword_to_rule`:
    - [ ] Map each violation keyword to `rule_N_name`
  - [ ] Update `statistics`:
    - [ ] Update `rules_by_severity` counts
    - [ ] Update `rules_by_type` counts

#### Agent Files (if applicable)
- [ ] **`AGENTS.md`**
  - [ ] Update rule count references throughout document
  - [ ] Add to relevant agent descriptions if rule is agent-specific

- [ ] **`agents/*.md`** (if rule affects specific agents)
  - [ ] Update agent's rules list if they enforce this rule
  - [ ] Add to agent's examples if relevant

#### Configuration Files (if rule is enforced by tooling)
- [ ] **`.rubocop.yml`** (for RuboCop-enforced rules)
  - [ ] Enable relevant cops
  - [ ] Add comment linking to rule

- [ ] **Other config files** as needed (brakeman.yml, etc.)

#### Tests
- [ ] **`test/unit/rules/rules_to_skills_mapping_test.rb`**
  - [ ] Update all hardcoded rule counts (19 → 20, etc.)
  - [ ] Update `test_metadata_counts_are_correct` (total_rules)
  - [ ] Update `test_all_N_rules_are_accounted_for` (range 1..N)
  - [ ] Update coverage calculation divisor

- [ ] **`test/unit/rules/team_rules_test.rb`**
  - [ ] Update `test_rules_are_sequential` (1..N range)
  - [ ] Update any other tests with hardcoded counts

- [ ] **`test/unit/rules/rules_consistency_test.rb`**
  - [ ] Update `test_rule_count_consistency` (counts)
  - [ ] Verify keyword lookup tests pass

#### Final Verification
- [ ] Run `bin/ci` - All tests must pass
- [ ] Run `rake lint:fix` - Fix any style issues
- [ ] Verify YAML is valid: `ruby -ryaml -e "YAML.safe_load_file('rules/TEAM_RULES.md')"`
- [ ] Commit with clear message: "Add Rule #N: [Rule Name]"

---

### ✅ Adding a New Skill

Use this checklist when creating a new skill (e.g., `my-new-skill`).

#### Core Skill Files
- [ ] **Create skill file: `skills/[domain]/[skill-name].md`**
  - [ ] Add YAML front matter:
    - [ ] `name`, `domain`, `dependencies`, `version`, `rails_version`
    - [ ] `criticality` (REQUIRED/CRITICAL/RECOMMENDED)
    - [ ] `applies_to` (file patterns)
  - [ ] Add required sections:
    - [ ] `<when-to-use>` - When to apply this skill
    - [ ] `<benefits>` - Why use this skill
    - [ ] `<standards>` - Core standards/requirements
    - [ ] `<pattern>` blocks with code examples
    - [ ] `<antipatterns>` - What to avoid
    - [ ] `<best-practices>` - Recommended approaches
    - [ ] `<troubleshooting>` - Common issues
  - [ ] Include code examples with proper syntax highlighting
  - [ ] Reference TEAM_RULES.md if skill enforces rules
  - [ ] Add related skills section

#### Registry and Mapping Files
- [ ] **`skills/SKILLS_REGISTRY.yml`**
  - [ ] Update `metadata`:
    - [ ] Increment `total_skills` count
    - [ ] Increment domain count (e.g., `frontend: 13 → 14`)
  - [ ] Add to `domains.[domain].skills`:
    - [ ] Add skill name to domain's array (alphabetically)
  - [ ] Add to `skills` section:
    - [ ] Create full entry with name, domain, dependencies
    - [ ] Add `description`, `when_to_use`, `location`
    - [ ] Add `enforces_rules` array if applicable
    - [ ] Add `criticality` level
  - [ ] Add to `dependency_graph`:
    - [ ] Add to `no_dependencies` OR
    - [ ] Add to `depends_on_others` with dependency array
  - [ ] Add to `keyword_index`:
    - [ ] Add relevant keywords that should trigger this skill

- [ ] **`rules/RULES_TO_SKILLS_MAPPING.yml`** (if skill enforces a rule)
  - [ ] Add skill to appropriate rule's `skills` section
  - [ ] Update `primary` skill or add to `related` skills

#### Agent Files
- [ ] **`AGENTS.md`**
  - [ ] Update all skill count references (40 → 41, etc.)
  - [ ] Update coverage statistics

- [ ] **`agents/*.md`** (for agents that should have this skill)
  - [ ] Add to agent's `<skills-manifest>` section:
    - [ ] Add numbered entry with name, location, description
    - [ ] Add to appropriate category (frontend/backend/config/etc.)
    - [ ] Update category count (e.g., "Frontend Skills (13)" → "(14)")
  - [ ] Update total preset skills count in header
  - [ ] Add to agent's skill loading examples if relevant

#### Tests
- [ ] **Create unit test: `test/unit/skills/[skill_name]_test.rb`**
  - [ ] Inherit from `SkillTestCase`
  - [ ] Set `self.skill_domain` and `self.skill_name`
  - [ ] Test file exists
  - [ ] Test YAML front matter
  - [ ] Test required metadata
  - [ ] Test required sections
  - [ ] Test code examples validity

- [ ] **Update test counts** (if hardcoded anywhere)
  - [ ] Verify coverage report shows new skill

#### Final Verification
- [ ] Run `rake test:unit:skills` - Skill tests pass
- [ ] Run `bin/ci` - All tests pass
- [ ] Run `rake lint:fix` - Fix any style issues
- [ ] Verify skill loads in SKILLS_REGISTRY.yml
- [ ] Test skill manually by having an agent load it
- [ ] Commit with clear message: "Add [domain] skill: [skill-name]"

---

### ✅ Adding a New Agent

Use this checklist when creating a new agent (e.g., `performance.md`).

#### Core Agent Files
- [ ] **Create agent file: `agents/[agent-name].md`**
  - [ ] Add agent role and description
  - [ ] Add `@agent-rails-ai:[name]` access instruction
  - [ ] Add `<skills-manifest>` section:
    - [ ] List preset skills by category
    - [ ] Include skill count per category
  - [ ] Add "When to use" section
  - [ ] Add coordination guidance (which agents to pair with)
  - [ ] Add skill loading workflow instructions
  - [ ] Include examples of common tasks
  - [ ] Add references to TEAM_RULES.md and SKILLS_REGISTRY.yml

#### Documentation Files
- [ ] **`AGENTS.md`**
  - [ ] Update agent count (7 → 8, etc.)
  - [ ] Add new agent section:
    - [ ] Role description
    - [ ] Access instructions
    - [ ] Preset skills list
    - [ ] Coordination guidance
    - [ ] When to use
  - [ ] Update System Overview architecture diagram
  - [ ] Add to agent comparison table (if exists)

- [ ] **`README.md`**
  - [ ] Update agent count
  - [ ] Add agent to features list
  - [ ] Update installation/usage if needed

#### Test Files
- [ ] **Create test file: `test/unit/agents/[agent_name]_test.rb`** (optional)
  - [ ] Test agent file structure
  - [ ] Test required sections exist
  - [ ] Test skill references are valid

- [ ] **Update existing agent tests** (if they check agent counts)
  - [ ] Update hardcoded agent counts

#### Integration
- [ ] **Test agent manually**
  - [ ] Install locally and test with `@agent-rails-ai:[name]`
  - [ ] Verify skill loading works
  - [ ] Verify coordination with other agents works
  - [ ] Test common use cases

#### Final Verification
- [ ] Run `bin/ci` - All tests pass
- [ ] Run `rake lint:fix` - Fix any style issues
- [ ] Test agent in real scenario
- [ ] Document any special setup requirements
- [ ] Commit with clear message: "Add [agent-name] agent for [purpose]"

---

### 🔧 Updating Existing Resources

#### Updating an Existing Skill
- [ ] Update skill file content
- [ ] Update SKILLS_REGISTRY.yml if metadata changes
- [ ] Update dependent agents if preset skills change
- [ ] Update tests if structure changes
- [ ] Run `bin/ci` to verify

#### Updating an Existing Rule
- [ ] Update TEAM_RULES.md
- [ ] Update RULES_TO_SKILLS_MAPPING.yml if mappings change
- [ ] Update affected agent files
- [ ] Update tests if structure changes
- [ ] Run `bin/ci` to verify

#### Removing a Resource (Caution!)
- [ ] Check all dependencies first
- [ ] Update all referencing files
- [ ] Update all tests
- [ ] Decrement all counts
- [ ] Document removal reason in commit message

---

### 💡 Tips for Contributors

1. **Always use the checklists** - Don't skip steps, even if they seem minor
2. **Run tests frequently** - Catch issues early with `bin/ci`
3. **Update counts everywhere** - Many files have hardcoded counts that need updating
4. **Test YAML validity** - Use `ruby -ryaml -e "YAML.safe_load_file('file.yml')"` to verify
5. **Check for special characters** - Brackets `[]`, parentheses `()`, colons `:` in YAML can cause parsing issues
6. **Commit atomically** - One rule/skill/agent per commit for clean history
7. **Ask for review** - Complex changes benefit from a second pair of eyes

---

---

## Agent Roles and Presets

Each agent has a **specialized role** and loads a **preset** of skills automatically.

### 1. Architect (`agents/architect.md`)

**Role:** Senior full-stack Rails architect and coordinator. Main entry point for complex tasks.

**Access:** `@agent-rails-ai:architect`

**Capabilities:**
- Team coordination and agent delegation
- Architecture oversight and code review
- Parallel execution of multiple agents
- Enforces team rules and best practices
- Has access to all 41 skills via SKILLS_REGISTRY.yml

**When to use:**
- Complex multi-step features requiring multiple agents
- Code reviews and architecture decisions
- Coordinating frontend + backend + tests together
- Need guidance on which agent/skill to use

---

### 2. Planning Agent (`agents/plan.md`)

**Role:** Senior Rails product strategist specialized in Specification Pyramid framework. Creates and maintains Vision, Architecture, Features, and Tasks documentation.

**Access:** `@agent-rails-ai:plan`

**Capabilities:**
- Specification Pyramid documentation (Vision → Architecture → Features → Tasks)
- Rails 8+ fullstack architecture planning
- Web and mobile application design
- Decision recording (ADRs)
- Documentation maintenance
- Progressive refinement from strategic to tactical

**When to use:**
- New project planning (Vision + Architecture docs)
- Feature specification creation
- Task breakdown for implementation
- Architecture decision documentation
- Updating specs as features are completed
- Recording known issues and technical direction

---

### 3. Backend Agent (`agents/backend.md`)

**Role:** Backend API development, data modeling, business logic, and configuration.

**Access:** `@agent-rails-ai:backend`

**Preset Skills:** (14 total: 10 backend + 4 config)
- **Backend (10):** controller-restful, activerecord-patterns, form-objects, query-objects, concerns-models, concerns-controllers, custom-validators, action-mailer, nested-resources, antipattern-fat-controllers
- **Config (4):** solid-stack-setup, rubocop-setup, credentials-management, docker-rails-setup

**Coordination:**
- **Security:** Pairs with @security for security-critical features (user input, auth, file uploads, database queries)
- **Testing:** Pairs with @tests for complex testing scenarios (mocking, edge cases, test strategy)

**When to use:**
- Building REST APIs and controllers
- Data modeling with ActiveRecord
- Business logic (form objects, query objects, service objects)
- Background jobs (SolidQueue) and mailers
- Rails configuration and credentials
- Refactoring fat controllers

---

### 4. Frontend Agent (`agents/frontend.md`)

**Role:** Frontend development, UI/UX, Hotwire, and styling with Tailwind/DaisyUI.

**Access:** `@agent-rails-ai:frontend`

**Preset Skills:** (13 total: frontend only)
- **Frontend (13):** viewcomponent-basics, viewcomponent-slots, viewcomponent-previews, viewcomponent-variants, hotwire-turbo, hotwire-stimulus, turbo-page-refresh, tailwind-utility-first, daisyui-components, view-helpers, forms-nested, accessibility-patterns, partials-layouts

**Coordination:**
- **Security:** Pairs with @security for security-critical frontend features (forms with user input, file uploads)
- **Testing:** Pairs with @tests for ViewComponent testing and complex test scenarios

**When to use:**
- Building ViewComponent UI components
- Hotwire/Turbo/Stimulus implementations
- Tailwind CSS and DaisyUI styling
- Forms and nested forms
- Accessibility (ARIA, semantic HTML)
- Responsive design and UX

---

### 5. Tests Agent (`agents/tests.md`)

**Role:** Test writing, TDD, coverage improvement, and test refactoring (Minitest only).

**Access:** `@agent-rails-ai:tests`

**Preset Skills:** (6 testing)
- **Testing (6):** tdd-minitest, fixtures-test-data, minitest-mocking, test-helpers, viewcomponent-testing, model-testing-advanced

**When to use:**
- Writing tests for new code (TDD: RED-GREEN-REFACTOR)
- Adding tests for existing code
- Improving test coverage
- Refactoring test suite
- Test organization and test helpers
- ViewComponent testing

---

### 6. Security Agent (`agents/security.md`)

**Role:** Security auditing, vulnerability detection, and security fixes.

**Access:** `@agent-rails-ai:security`

**Preset Skills:** (6 security + 2 backend + 1 config)
- **Security (6):** security-xss, security-sql-injection, security-csrf, security-strong-parameters, security-file-uploads, security-command-injection
- **Backend (2):** controller-restful, custom-validators
- **Config (1):** credentials-management

**When to use:**
- Security audits and vulnerability scanning
- Fixing XSS, SQL injection, CSRF issues
- Handling file uploads securely
- Strong parameters and input validation
- Authentication/authorization implementation
- Sensitive data and credentials management

---

### 7. Debug Agent (`agents/debug.md`)

**Role:** Debugging, error analysis, test failures, and performance issues.

**Access:** `@agent-rails-ai:debug`

**Preset Skills:** (6 testing + 2 backend)
- **Testing (6):** tdd-minitest, fixtures-test-data, minitest-mocking, test-helpers, model-testing-advanced, viewcomponent-testing
- **Backend (2):** activerecord-patterns, antipattern-fat-controllers

**When to use:**
- Tests are failing
- Production errors and stack traces
- Performance bottlenecks
- Understanding error messages
- Debugging ActiveRecord queries
- Console debugging sessions

---

## Development Workflow

### Iterating on Skills

1. **Identify improvement area** - What skill needs updating?
2. **Read current version** - Understand existing content
3. **Make changes** - Update patterns, add examples, fix errors
4. **Test examples** - Ensure code examples work in Rails 8.1+
5. **Update version** - Increment if breaking changes
6. **Commit** - Clear message: "Update skill-name: description of changes"
7. **Test with agents** - Verify agents can load and use updated skill

### Iterating on Agents

1. **Read agent file** - Understand current role and instructions
2. **Identify changes needed** - What should agent do differently?
3. **Update instructions** - Modify agent's behavior and approach
4. **Update skill presets** - Add/remove skills from auto-load list
5. **Test with real tasks** - Give agent actual work to verify changes
6. **Commit** - Clear message: "Update agent-name: description of changes"

### Testing Skills

We use a **two-tier Minitest strategy** for testing skills:

#### Tier 1: Unit Tests (Fast - Required)
**Purpose:** Validate skill structure and content
**Speed:** < 1 second per skill
**When:** Every skill change, every commit

```bash
# Run all unit tests
rake test:unit:skills

# Run specific skill test
ruby -Itest test/skills/unit/turbo_page_refresh_test.rb

# Generate test for new skill
rake test:new_skill[skill-name,domain]
```

**What unit tests validate:**
- ✅ Valid YAML front matter
- ✅ Required metadata (name, domain, version, rails_version)
- ✅ Required sections (when-to-use, benefits, standards, antipatterns, testing, related-skills, resources)
- ✅ Named patterns present
- ✅ Code examples exist
- ✅ Good (✅) and bad (❌) examples marked
- ✅ Key patterns documented (attributes, methods, callbacks)

#### Tier 2: Integration Tests (Slow - Manual Only)
**Purpose:** Validate agent planning capabilities using 4-domain judging
**Speed:** ~90 seconds per scenario (agent + 4 judges)
**When:** Manually before releases or after significant agent/skill changes

```bash
# Run bootstrap test (fast verification, ~40s)
rake test:integration:bootstrap

# Run specific scenario
rake test:integration:scenario[simple_model_plan]

# List available scenarios
rake test:integration:list

# NOTE: Integration tests must be run individually (no bulk run due to cost/time)
```

**What integration tests validate:**
- ✅ Agent produces implementation plans (not questions for clarification)
- ✅ Backend planning (models, migrations, validations, Rails conventions)
- ✅ Frontend planning (views, Hotwire, Tailwind, forms, accessibility)
- ✅ Test planning (coverage, Minitest, fixtures)
- ✅ Security planning (authorization, validation, sensitive data)
- ✅ Score threshold: 140/200 points (70%)

#### Linting & Quality

```bash
# Run all quality checks
rake                # Default: lint + unit tests

# Run linters
rake lint           # Ruby, Markdown, YAML
rake lint:ruby      # Rubocop
rake lint:markdown  # Markdown linting
rake lint:yaml      # YAML validation
rake lint:fix       # Auto-fix Ruby issues
```

#### Before Committing

**Required:**
1. ✅ Unit tests pass (`rake test:unit` - includes skills, agents, rules)
2. ✅ Linters pass (`rake lint`)
3. ✅ YAML front matter valid
4. ✅ Code examples syntactically correct
5. ✅ XML tags properly closed

**Recommended:**
6. Integration tests pass (`rake test:integration:scenario[NAME]`)
7. Manual test: Ask an agent to use the skill on a real task
8. Verify output matches expectations

**See:** `docs/skill-testing-methodology.md` for full testing documentation

### Testing Agents

We use **fast unit tests** to validate agent structure and consistency:

#### Agent Unit Tests (Fast - Required)
**Purpose:** Validate agent structure, conventions, and cross-references
**Speed:** < 1 second for all agents
**When:** Every agent change, every commit

```bash
# Run all agent tests
rake test:unit:agents

# Run specific test file
ruby -Itest test/agents/unit/agent_structure_test.rb

# Run full CI with agent tests
bin/ci
```

**What agent tests validate:**
- ✅ Valid YAML front matter in all agents
- ✅ Required metadata (name, description, role, coordinates_with)
- ✅ Agent name matches filename
- ✅ All 7 agents exist (1 coordinator + 1 planning + 5 specialized)
- ✅ No legacy agents remain (rails-config, rails-design, etc.)
- ✅ All agents have `rails-` prefix except coordinator
- ✅ Skills Preset section exists in specialized agents
- ✅ References to SKILLS_REGISTRY.yml present
- ✅ Cross-references valid (coordinates_with only references existing agents)
- ✅ Skill references valid (only references skills in SKILLS_REGISTRY.yml)
- ✅ No references to deleted agents
- ✅ Documentation matches reality (AGENTS.md, ARCHITECT_DECISIONS.yml)

#### Agent Integration Tests (Deferred for Post-MVP)
**Purpose:** Validate agent behavior and coordination using LLM calls
**Status:** Not yet implemented
**Future:** Will test actual agent task completion and skill application

#### Before Committing Agent Changes

**Required:**
1. ✅ All unit tests pass (`rake test:unit` - includes agents, skills, rules)
2. ✅ Linters pass (`rake lint`)
3. ✅ YAML front matter valid
4. ✅ All cross-references exist
5. ✅ CI passes (`bin/ci`)

**Recommended:**
6. Manual test: Give agent a real task to verify changes
7. Check coordination with other agents works
8. Verify skill loading works as expected

---

## How Agents Work

### Plugin Installation

When a user installs rails-ai as a Claude Code plugin:

1. **Plugin installed** - `/plugin install rails-ai`
2. **Agents registered** - All 7 agents from `agents/*.md` become available
3. **Access via @-mention** - Users invoke agents with `@agent-rails-ai:architect`, `@agent-rails-ai:backend`, etc.
4. **Skills loaded** - Agents read SKILLS_REGISTRY.yml to access skill knowledge
5. **Rules enforced** - Agents reference team rules from `rules/` directory

### How Agents Load Skills

Each agent's markdown file includes a "Skills Preset" section that:

1. **Lists skill names** - References skills by name (e.g., "viewcomponent-basics")
2. **Organizes by domain** - Groups skills (frontend, backend, testing, security, config)
3. **Instructs agent** - Tells agent which skills to apply for different tasks
4. **Points to registry** - References SKILLS_REGISTRY.yml for full skill details

When an agent processes a task:

1. **Agent receives task** - User provides request via `@agent-rails-ai:name`
2. **Agent reads preset** - Checks which skills are relevant for its role
3. **Agent references registry** - Looks up skill details in SKILLS_REGISTRY.yml
4. **Agent applies patterns** - Uses skill knowledge (patterns, antipatterns, examples)
5. **Agent enforces rules** - Follows team rules (Solid Stack, Minitest, REST-only, TDD)
6. **Agent outputs result** - Generates code following best practices

---

## Skill Dependency Graph

Understanding skill relationships helps with updates and agent configuration.

### Core Dependencies

```text
frontend/
  ├── viewcomponent-basics
  │   ├── viewcomponent-slots (depends on basics)
  │   ├── viewcomponent-previews (depends on basics)
  │   └── viewcomponent-variants (depends on basics + tailwind)
  ├── hotwire-turbo
  │   └── turbo-page-refresh (depends on turbo)
  └── tailwind-utility-first
      ├── daisyui-components (depends on tailwind)
      └── viewcomponent-variants (depends on tailwind + basics)

backend/
  ├── activerecord-patterns (foundation)
  │   ├── concerns-models (depends on activerecord)
  │   ├── custom-validators (depends on activerecord)
  │   └── form-objects (depends on activerecord)
  └── controller-restful (foundation)
      ├── concerns-controllers (depends on controller-restful)
      ├── nested-resources (depends on controller-restful)
      └── antipattern-fat-controllers (depends on controller + form-objects + query-objects)

testing/
  ├── tdd-minitest (foundation)
  │   ├── fixtures-test-data (depends on tdd)
  │   ├── minitest-mocking (depends on tdd)
  │   ├── test-helpers (depends on tdd)
  │   └── viewcomponent-testing (depends on tdd + viewcomponent-basics)
  └── model-testing-advanced (depends on activerecord + tdd)
```

---

## Conventions

### File Naming
- Skills: `domain/skill-name.md` (kebab-case)
- Agents: `agents/agent-name.md` (kebab-case)

### Version Numbering
- **1.0** - Initial version
- **1.1** - Minor updates (new patterns, examples)
- **2.0** - Breaking changes (structure, dependencies)

### Commit Messages

**Skills:**
```
Add skill-name: Brief description
Update skill-name: What changed and why
Remove skill-name: Reason for removal
```

**Agents:**
```
Update agent-name: What changed and why
Add skill preset to agent-name: skill-name
Remove skill preset from agent-name: skill-name
```

---

## Project Status

### Completed ✅
- ✅ Skills-based architecture with SKILLS_REGISTRY.yml
- ✅ 7 specialized agents (architect, plan, backend, frontend, tests, security, debug)
- ✅ 40 modular skills across 5 domains
- ✅ Claude Code plugin support
- ✅ Specification Pyramid framework integration
- ✅ Testing framework (unit tests for agents and skills)
- ✅ CI/CD with GitHub Actions
- ✅ Open source release (MIT License)
- ✅ Comprehensive documentation (README, CONTRIBUTING, SECURITY)

### In Progress 🔄
- Integration tests for skills (LLM-as-judge validation)
- Enhanced Cursor support
- Expanding skill coverage based on real-world usage

### Future Roadmap 🚀
- Additional skills (authentication, APIs, deployment)
- Agent coordination improvements
- Performance optimization
- Community contributions and feedback

---

## Contributing to Agents and Skills

See [CONTRIBUTING.md](CONTRIBUTING.md) for full contribution guidelines.

### Quick Links for Contributors

- **Adding skills** - Edit `skills/SKILLS_REGISTRY.yml` and add new skill entry
- **Updating agents** - Edit agent markdown files in `agents/` directory
- **Running tests** - `bin/ci` runs all checks (linting + unit tests)
- **Testing skills** - `rake test:unit:skills` for fast skill validation
- **Testing agents** - `rake test:unit:agents` for agent structure tests
- **Testing rules** - `rake test:unit:rules` for rules consistency tests
- **Linting** - `rake lint` or `rake lint:fix` to auto-fix issues

### Key Files

| File | Purpose |
|------|---------|
| `skills/SKILLS_REGISTRY.yml` | Central catalog of all 41 skills |
| `agents/*.md` | 7 agent definitions (loaded by Claude Code plugin) |
| `rules/` | Team conventions and decision matrices |
| `test/unit/skills/` | Unit tests for skill structure validation |
| `test/unit/agents/` | Unit tests for agent structure validation |
| `test/unit/rules/` | Unit tests for rules consistency validation |
| `AGENTS.md` | This file - internal documentation for contributors |
| `README.md` | Public documentation for users |
| `CONTRIBUTING.md` | Contribution guidelines and workflow |

---

## Resources

- **Main Docs:** [README.md](README.md)
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **Skills Registry:** [skills/SKILLS_REGISTRY.yml](skills/SKILLS_REGISTRY.yml)
- **Testing Guide:** [docs/skill-testing-methodology.md](docs/skill-testing-methodology.md)
- **GitHub Actions:** [docs/github-actions-setup.md](docs/github-actions-setup.md)

---

**Version History:**
- **2.0** (2025-10-31) - Updated for open source release, SKILLS_REGISTRY.yml architecture
- **1.0** (2025-10-30) - Initial AGENTS.md governance document
