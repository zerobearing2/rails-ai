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
├── agents/           # 8 specialized agents
│   ├── rails.md      # Coordinator (skills registry/librarian)
│   ├── feature.md    # Full-stack feature development
│   ├── debugger.md   # Testing and debugging
│   ├── refactor.md   # Code quality and patterns
│   ├── security.md   # Security auditing and fixes
│   ├── test.md       # Test writing and coverage
│   ├── ui.md         # Frontend/UI development
│   └── api.md        # Backend API development
├── skills/           # 33 modular skills
│   ├── frontend/     # 13 UI/UX skills
│   ├── backend/      # 10 server-side skills
│   ├── testing/      # 6 test-related skills
│   ├── security/     # 4 security skills (6 originally)
│   └── config/       # 4 configuration skills
├── rules/            # Team conventions
└── AGENTS.md         # This file (governance)
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

### 2. Feature Agent (`agents/feature.md`)

**Role:** Full-stack feature development from design to deployment.

**Preset Skills:**
- **Frontend:** viewcomponent-basics, hotwire-turbo, turbo-page-refresh, tailwind-utility-first, daisyui-components
- **Backend:** controller-restful, activerecord-patterns, form-objects, query-objects
- **Testing:** tdd-minitest, fixtures-test-data
- **Security:** security-csrf, security-strong-parameters
- **Config:** solid-stack-setup

**When to use:**
- Building new features end-to-end
- Need both frontend and backend work
- Want cohesive full-stack implementation

---

### 3. Debugger Agent (`agents/debugger.md`)

**Role:** Debugging, error analysis, and test failure resolution.

**Preset Skills:**
- **Testing:** tdd-minitest, fixtures-test-data, minitest-mocking, test-helpers
- **Backend:** activerecord-patterns, query-objects
- **Frontend:** viewcomponent-testing, hotwire-turbo
- **Security:** security-sql-injection, security-xss

**When to use:**
- Tests are failing
- Production errors need investigation
- Performance issues
- Need help understanding error messages

---

### 4. Refactor Agent (`agents/refactor.md`)

**Role:** Code quality improvement, pattern implementation, technical debt reduction.

**Preset Skills:**
- **Backend:** antipattern-fat-controllers, form-objects, query-objects, concerns-models, concerns-controllers
- **Frontend:** viewcomponent-basics, viewcomponent-variants, partials-layouts
- **Testing:** tdd-minitest, model-testing-advanced

**When to use:**
- Code smells or antipatterns detected
- Need to extract patterns (service objects, form objects, etc.)
- Improving test coverage
- Reducing duplication

---

### 5. Security Agent (`agents/security.md`)

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

### 6. Test Agent (`agents/test.md`)

**Role:** Writing tests, improving coverage, test refactoring.

**Preset Skills:**
- **Testing:** tdd-minitest, fixtures-test-data, minitest-mocking, test-helpers, viewcomponent-testing, model-testing-advanced
- **Backend:** activerecord-patterns
- **Frontend:** viewcomponent-basics

**When to use:**
- Need to write tests for existing code
- Improving test coverage
- Refactoring test suite
- Test organization and helpers

---

### 7. UI Agent (`agents/ui.md`)

**Role:** Frontend development, UI/UX implementation, styling.

**Preset Skills:**
- **Frontend:** ALL 13 frontend skills
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

---

### 8. API Agent (`agents/api.md`)

**Role:** Backend API development, data modeling, business logic.

**Preset Skills:**
- **Backend:** ALL 10 backend skills
  - controller-restful, activerecord-patterns, form-objects, query-objects
  - concerns-models, concerns-controllers, custom-validators
  - action-mailer, nested-resources, antipattern-fat-controllers
- **Security:** security-sql-injection, security-strong-parameters, security-csrf
- **Testing:** model-testing-advanced, fixtures-test-data
- **Config:** solid-stack-setup

**When to use:**
- Building REST APIs
- Data modeling and ActiveRecord
- Business logic and service objects
- Background jobs and mailers

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

### Testing Changes

**Before committing:**
1. Read the modified skill/agent file
2. Ask the agent to use the skill on a real task
3. Verify the output matches expectations
4. Check for any confusion or errors
5. Iterate if needed

**Quality checks:**
- Code examples are syntactically correct
- Examples use Rails 8.1+ conventions
- XML tags are properly closed
- Related skills are linked
- No broken dependencies

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
