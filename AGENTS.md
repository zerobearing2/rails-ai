# Rails AI Agents System

**Version:** 2.0
**Last Updated:** 2025-10-31
**Status:** Open Source & Production Ready

This document is **internal documentation** for contributors who want to understand or modify the rails-ai agent architecture. This file is NOT used by the Claude Code plugin system - it's for humans only.

When users install the rails-ai plugin, they get the individual agent files from `agents/` directory, not this document.

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
├── skills/                     # 33 modular skills (referenced by agents)
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

All 33 skills are defined in **`skills/SKILLS_REGISTRY.yml`** - a single centralized catalog that agents reference. This registry-based approach provides:

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

### Adding a New Skill

1. **Identify the need** - Is this a recurring pattern that needs documentation?
2. **Choose domain** - frontend, backend, testing, security, or config
3. **Check for overlap** - Does this duplicate or complement existing skills?
4. **Add to SKILLS_REGISTRY.yml** - Add skill entry in appropriate domain section
5. **Include all required fields**:
   - name, domain, dependencies, description
   - when_to_use (array of conditions)
   - patterns (with examples)
   - antipatterns (with reasons and solutions)
   - testing (with example)
   - related_skills (array)
6. **Write unit test** - Use `rake test:skills:new[skill-name,domain]` to generate test
7. **Update metadata** - Increment skill count and domain count in registry header
8. **Commit with description** - Clear commit message explaining the skill

### Updating an Existing Skill

1. **Read the skill** - Understand current content in SKILLS_REGISTRY.yml
2. **Identify changes** - What needs to be added, updated, or removed?
3. **Maintain format** - Keep YAML structure consistent
4. **Test examples** - Ensure all code examples are current for Rails 8+
5. **Update dependencies** - If skill relationships change
6. **Run tests** - Ensure `rake test:skills:unit` passes
7. **Commit clearly** - Describe what changed and why

### Removing a Skill

**Caution:** Removing skills affects agents that depend on them.

1. **Check dependencies** - Search SKILLS_REGISTRY.yml for references
2. **Update dependent skills** - Remove from `dependencies` and `related_skills` arrays
3. **Update agent presets** - Check agent markdown files for references
4. **Remove from registry** - Delete skill entry from SKILLS_REGISTRY.yml
5. **Update metadata** - Decrement skill count and domain count in registry header
6. **Update tests** - Remove or update any tests that reference the skill
7. **Document removal** - Clear commit message explaining why skill was removed

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
- Has access to all 33 skills via SKILLS_REGISTRY.yml

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

**Preset Skills:** (10 backend + 3 security + 2 config + 1 testing)
- **Backend (10):** controller-restful, activerecord-patterns, form-objects, query-objects, concerns-models, concerns-controllers, custom-validators, action-mailer, nested-resources, antipattern-fat-controllers
- **Security (3):** security-sql-injection, security-strong-parameters, security-csrf
- **Config (2):** solid-stack-setup, credentials-management
- **Testing (1):** tdd-minitest

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

**Preset Skills:** (13 frontend + 1 testing)
- **Frontend (13):** viewcomponent-basics, viewcomponent-slots, viewcomponent-previews, viewcomponent-variants, hotwire-turbo, hotwire-stimulus, turbo-page-refresh, tailwind-utility-first, daisyui-components, view-helpers, forms-nested, accessibility-patterns, partials-layouts
- **Testing (1):** viewcomponent-testing

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
rake test:skills:unit

# Run specific skill test
ruby -Itest test/skills/unit/turbo_page_refresh_test.rb

# Generate test for new skill
rake test:skills:new[skill-name,domain]
```

**What unit tests validate:**
- ✅ Valid YAML front matter
- ✅ Required metadata (name, domain, version, rails_version)
- ✅ Required sections (when-to-use, benefits, standards, antipatterns, testing, related-skills, resources)
- ✅ Named patterns present
- ✅ Code examples exist
- ✅ Good (✅) and bad (❌) examples marked
- ✅ Key patterns documented (attributes, methods, callbacks)

#### Tier 2: Integration Tests (Slow - Optional)
**Purpose:** Validate agents apply skills correctly using LLM-as-judge
**Speed:** ~2-5 seconds per test case
**When:** Before commits, weekly, or on major changes

```bash
# Run all integration tests (requires LLM APIs)
INTEGRATION=1 rake test:skills:integration

# Set API keys
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."

# Run with cross-validation
INTEGRATION=1 CROSS_VALIDATE=1 rake test:skills:integration
```

**What integration tests validate:**
- ✅ Generated code contains expected patterns
- ✅ Generated code avoids antipatterns
- ✅ LLM judge scores >= 4.0/5.0
- ✅ Multiple LLMs agree (cross-validation)

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
1. ✅ Unit tests pass (`rake test:skills:unit`)
2. ✅ Linters pass (`rake lint`)
3. ✅ YAML front matter valid
4. ✅ Code examples syntactically correct
5. ✅ XML tags properly closed

**Recommended:**
6. Integration tests pass (`INTEGRATION=1 rake test:skills:integration`)
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
rake test:agents:unit

# Run specific test file
ruby -Itest test/agents/unit/agent_structure_test.rb

# Run full CI with agent tests
bin/ci
```

**What agent tests validate:**
- ✅ Valid YAML front matter in all agents
- ✅ Required metadata (name, description, role, coordinates_with)
- ✅ Agent name matches filename
- ✅ All 6 agents exist (1 coordinator + 5 specialized)
- ✅ No legacy agents remain (rails-config, rails-design, etc.)
- ✅ All agents have `rails-` prefix except coordinator
- ✅ Skills Preset section exists in specialized agents
- ✅ References to SKILLS_REGISTRY.yml present
- ✅ Cross-references valid (coordinates_with only references existing agents)
- ✅ Skill references valid (only references skills in SKILLS_REGISTRY.yml)
- ✅ No references to deleted agents
- ✅ Documentation matches reality (AGENTS.md, DECISION_MATRICES.yml)

#### Agent Integration Tests (Deferred for Post-MVP)
**Purpose:** Validate agent behavior and coordination using LLM calls
**Status:** Not yet implemented
**Future:** Will test actual agent task completion and skill application

#### Before Committing Agent Changes

**Required:**
1. ✅ Agent unit tests pass (`rake test:agents:unit`)
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
2. **Agents registered** - All 6 agents from `agents/*.md` become available
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
- ✅ 33 modular skills across 5 domains
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
- **Testing skills** - `rake test:skills:unit` for fast skill validation
- **Testing agents** - `rake test:agents:unit` for agent structure tests
- **Linting** - `rake lint` or `rake lint:fix` to auto-fix issues

### Key Files

| File | Purpose |
|------|---------|
| `skills/SKILLS_REGISTRY.yml` | Central catalog of all 33 skills |
| `agents/*.md` | 6 agent definitions (loaded by Claude Code plugin) |
| `rules/` | Team conventions and decision matrices |
| `test/skills/unit/` | Unit tests for skill structure validation |
| `test/agents/unit/` | Unit tests for agent structure validation |
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
