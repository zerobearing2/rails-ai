# Rails AI Agents System

**Version:** 1.0
**Last Updated:** 2025-10-30
**Status:** Phase 2 - Agent Integration

This document governs the agents and skills architecture for the Rails AI project. It defines how we iterate on agents, manage skills, and maintain the system.

---

## System Overview

The Rails AI project uses a **skills-based architecture** where specialized agents dynamically load modular skills to perform tasks. This approach provides:

- **Modularity** - Skills are independent, reusable knowledge units
- **Scalability** - Easy to add new skills without modifying agents
- **Maintainability** - Update one skill, all agents benefit
- **Dynamic Loading** - Agents load skills on-demand based on task context

### Architecture

```
rails-ai/
├── agents/                 # 6 specialized agents
│   ├── rails.md            # Coordinator (architect/skills registry)
│   ├── rails-backend.md    # Backend API + config + refactoring
│   ├── rails-frontend.md   # Frontend UI + design/UX
│   ├── rails-security.md   # Security auditing and fixes
│   ├── rails-debug.md      # Testing and debugging
│   └── rails-tests.md      # Test writing and coverage
├── skills/                 # 33 modular skills
│   ├── frontend/           # 13 UI/UX skills
│   ├── backend/            # 10 server-side skills
│   ├── testing/            # 6 test-related skills
│   ├── security/           # 6 security skills
│   └── config/             # 4 configuration skills
├── rules/                  # Team conventions
└── AGENTS.md               # This file (governance)
```

---

## Skills Management

### Skill Format

All skills use the **hybrid format** (YAML + Markdown + XML tags):

```markdown
---
name: skill-name
domain: frontend|backend|testing|security|config
dependencies: [other-skill-names]
version: 1.0
rails_version: 8.1+
---

# Skill Title

Brief description.

<when-to-use>
- Condition 1
- Condition 2
</when-to-use>

<benefits>
- Benefit 1
- Benefit 2
</benefits>

<standards>
- Standard 1
- Standard 2
</standards>

<pattern name="pattern-name">
<description>Pattern description</description>

**Code Example:**
\`\`\`ruby
# ✅ Good example
\`\`\`
</pattern>

<antipatterns>
<antipattern>
<description>Antipattern description</description>
<reason>Why it's bad</reason>
<bad-example>
\`\`\`ruby
# ❌ Bad example
\`\`\`
</bad-example>
<good-example>
\`\`\`ruby
# ✅ Good example
\`\`\`
</good-example>
</antipattern>
</antipatterns>

<testing>
Test examples
</testing>

<related-skills>
- skill-1
- skill-2
</related-skills>

<resources>
- [Resource 1](url)
</resources>
```

### Adding a New Skill

1. **Identify the need** - Is this a recurring pattern that needs documentation?
2. **Choose domain** - frontend, backend, testing, security, or config
3. **Check for overlap** - Does this duplicate or complement existing skills?
4. **Create skill file** - Use the hybrid format template
5. **Include patterns** - Both good examples (✅) and antipatterns (❌)
6. **Add testing examples** - Show how to test the pattern
7. **Link related skills** - Create connections between skills
8. **Update dependencies** - Add to skill YAML front matter
9. **Commit with description** - Clear commit message explaining the skill

### Updating an Existing Skill

1. **Read the skill** - Understand current content and patterns
2. **Identify changes** - What needs to be added, updated, or removed?
3. **Maintain format** - Keep hybrid format (YAML + Markdown + XML)
4. **Update version** - Increment version if breaking changes
5. **Test examples** - Ensure all code examples are current for Rails 8.1+
6. **Update dependencies** - If skill relationships change
7. **Commit clearly** - Describe what changed and why

### Removing a Skill

**Caution:** Removing skills affects agents that depend on them.

1. **Check dependencies** - Use `grep -r "skill-name" skills/` to find references
2. **Update dependent skills** - Remove from `dependencies` arrays
3. **Update agent presets** - Remove from agent configurations
4. **Archive first** - Consider moving to `skills/archived/` before deleting
5. **Document removal** - Update this file and commit message

---

## Agent Roles and Presets

Each agent has a **specialized role** and loads a **preset** of skills automatically.

### 1. Coordinator (`agents/rails.md`)

**Role:** Skills registry and librarian. Routes tasks to specialized agents.

**Preset Skills:** ALL (registry of 33 skills)
- Maintains master skills registry
- Suggests which skills to use for tasks
- Delegates to specialized agents

**When to use:**
- Starting a new task (coordinator routes it)
- Need help finding the right skill
- Unsure which agent should handle the work

---

### 2. Backend Agent (`agents/rails-backend.md`)

**Role:** Backend API development, data modeling, business logic, configuration, and refactoring.

**Preset Skills:**
- **Backend:** ALL 10 backend skills
  - controller-restful, activerecord-patterns, form-objects, query-objects
  - concerns-models, concerns-controllers, custom-validators
  - action-mailer, nested-resources, antipattern-fat-controllers
- **Security:** security-sql-injection, security-strong-parameters, security-csrf
- **Config:** solid-stack-setup, credentials-management
- **Testing:** tdd-minitest

**When to use:**
- Building REST APIs
- Data modeling and ActiveRecord
- Business logic and service objects
- Background jobs and mailers
- Configuration and deployment setup
- Refactoring backend code

---

### 3. Frontend Agent (`agents/rails-frontend.md`)

**Role:** Frontend development, UI/UX implementation, styling, and design.

**Preset Skills:**
- **Frontend:** ALL 14 frontend skills
  - viewcomponent-basics, viewcomponent-slots, viewcomponent-previews, viewcomponent-variants
  - hotwire-turbo, hotwire-stimulus, turbo-page-refresh
  - tailwind-utility-first, daisyui-components
  - view-helpers, forms-nested, accessibility-patterns, partials-layouts
- **Testing:** viewcomponent-testing

**When to use:**
- Building UI components
- Styling and responsive design
- Accessibility improvements
- Hotwire/Turbo implementations
- Design and UX work

---

### 4. Security Agent (`agents/rails-security.md`)

**Role:** Security auditing, vulnerability detection, and security fixes.

**Preset Skills:**
- **Security:** security-xss, security-sql-injection, security-csrf, security-strong-parameters, security-file-uploads, security-command-injection
- **Backend:** controller-restful, custom-validators
- **Config:** credentials-management

**When to use:**
- Security audit needed
- Vulnerability detected
- Implementing authentication/authorization
- Handling sensitive data

---

### 5. Debugger Agent (`agents/rails-debug.md`)

**Role:** Debugging, error analysis, and test failure resolution.

**Preset Skills:**
- **Testing:** tdd-minitest, fixtures-test-data, minitest-mocking, test-helpers, model-testing-advanced, viewcomponent-testing
- **Backend:** activerecord-patterns, antipattern-fat-controllers

**When to use:**
- Tests are failing
- Production errors need investigation
- Performance issues
- Need help understanding error messages

---

### 6. Test Agent (`agents/rails-tests.md`)

**Role:** Writing tests, improving coverage, test refactoring.

**Preset Skills:**
- **Testing:** ALL 6 testing skills
  - tdd-minitest, fixtures-test-data, minitest-mocking, test-helpers
  - viewcomponent-testing, model-testing-advanced

**When to use:**
- Need to write tests for existing code
- Improving test coverage
- Refactoring test suite
- Test organization and helpers

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

---

## Agent Integration Protocol

### How Agents Load Skills

**Phase 2 Implementation (TODO):**

1. **Agent receives task** - User provides a request
2. **Agent analyzes task** - Determines which skills are needed
3. **Agent loads skills** - Reads relevant skill files from `skills/` directory
4. **Agent applies patterns** - Uses skill knowledge to complete task
5. **Agent outputs result** - Applies learned patterns

**Future: Dynamic Loading**
```ruby
# Pseudocode for agent skill loading
def load_skill(skill_name)
  skill_path = "skills/#{domain}/#{skill_name}.md"
  skill_content = File.read(skill_path)
  parse_skill(skill_content)
end

def apply_skill(skill_name, context)
  skill = load_skill(skill_name)
  patterns = skill.patterns.select { |p| p.matches?(context) }
  patterns.each { |pattern| apply_pattern(pattern, context) }
end
```

---

## Skill Dependency Graph

Understanding skill relationships helps with updates and agent configuration.

### Core Dependencies

```
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

## Next Steps (Phase 2)

1. ✅ **Skills Migration Complete** - All 33 skills ported
2. **Update Coordinator** - Add skills registry to `agents/rails.md`
3. **Update All Agents** - Add skill loading protocol and presets
4. **Test Skill Loading** - Verify agents can access and use skills
5. **Create Install Script** - Global symlink installation (`install.sh`)
6. **Production Testing** - Use agents on real Rails projects
7. **Iterate and Refine** - Improve based on usage

---

## Contributing

### Adding New Skills

All contributors should follow the skill format and conventions documented here.

**Steps:**
1. Create new skill file in appropriate domain folder
2. Follow hybrid format (YAML + Markdown + XML)
3. Include practical examples from Rails 8.1+
4. Add testing examples
5. Link related skills
6. Update this document if adding new domain
7. Submit with clear commit message

### Updating Agents

Agent updates should maintain backward compatibility where possible.

**Guidelines:**
- Keep agent role focused and clear
- Update skill presets to match role
- Test with real tasks before committing
- Document changes in commit message

---

## Resources

- **Skills Architecture:** `docs/skills-architecture.md`
- **Migration Progress:** `docs/skills-migration-progress.md`
- **Plan:** `docs/plan.md`
- **Team Rules:** `rules/TEAM_RULES.md`

---

**Version History:**
- **1.0** (2025-10-30) - Initial AGENTS.md governance document
