# Skills-Based Architecture Design

**Date:** 2025-10-30
**Status:** Design Phase - Not Yet Implemented
**Purpose:** Document the shift from monolithic agents to skill-based modular system

---

## Overview

Transform the current agent system from having knowledge hardcoded into agents to a **skills-based architecture** where agents dynamically load modular "skills" as needed.

## Problem Statement

Current architecture has limitations:
- **Redundancy**: Multiple agents contain similar ViewComponent, testing, or security patterns
- **Maintenance**: Updating a pattern requires editing multiple agent files
- **Scalability**: Adding new capabilities means modifying agents directly
- **Inflexibility**: Users can't easily extend or customize agent knowledge

## Proposed Solution: Skills as Modular Knowledge Units

### Core Concept

**Skills** = Focused, reusable knowledge modules that agents load dynamically

- **Agents** = Execution engines with personalities/roles
- **Skills** = Domain knowledge, patterns, standards, examples
- **Coordinator** = Registry/librarian that manages skill discovery

### Benefits

1. **Separation of Concerns**: Agents handle orchestration, skills provide knowledge
2. **Reduced Redundancy**: Single source of truth for each domain
3. **Dynamic Loading**: Load skills on-demand during execution
4. **Scalability**: Add skills without modifying agents
5. **Maintainability**: Update one skill file instead of multiple agents
6. **Extensibility**: Users and community can add custom skills

---

## Architecture Design

### 1. Skills Structure

```
skills/
├── viewcomponent-basics.md
├── viewcomponent-slots.md
├── viewcomponent-previews.md
├── hotwire-turbo.md
├── hotwire-stimulus.md
├── tailwind-utility-first.md
├── daisyui-components.md
├── minitest-fixtures.md
├── minitest-mocking.md
├── solid-queue-jobs.md
├── security-xss.md
├── security-sql-injection.md
└── ... (start with 10-15 core skills)
```

**Key Principles:**
- **One file per skill** - Keep skills tight and focused
- **Single responsibility** - Each skill covers ONE domain/pattern
- **Standalone** - Skills should be independently understandable
- **Composable** - Skills can reference other skills if needed

### 2. Skill Format

**Decision:** Hybrid format - YAML front matter + Markdown + XML tags

**Rationale:**
- **Machine-first optimization**: XML tags provide semantic anchors for LLM extraction
- **Human-friendly**: Markdown remains readable and familiar for editing
- **Best of both**: Structure where needed, readability where wanted
- **LLM can precisely target**: `<pattern name="X">` or all `<antipattern>` sections

Each skill file uses this hybrid format:

```markdown
---
name: viewcomponent-basics
domain: frontend
dependencies: [rails-conventions]
version: 1.0
---

# ViewComponent Basics

<when-to-use>
- Building reusable UI components
- Need component testing in isolation
- Want to encapsulate view logic
</when-to-use>

<standards>
- Components go in `app/components/`
- One component per file
- Use erb or slim for templates
- Inherit from `ViewComponent::Base`
</standards>

## Patterns

<pattern name="basic-component">
<description>Simple component with template</description>

```ruby
class ButtonComponent < ViewComponent::Base
  def initialize(text:, variant: :primary)
    @text = text
    @variant = variant
  end
end
```

```erb
<button class="btn-<%= @variant %>">
  <%= @text %>
</button>
```
</pattern>

<antipatterns>
<antipattern>
<description>Don't put business logic in components</description>
<reason>Components should be presentational only - use services/models for logic</reason>
</antipattern>
</antipatterns>

<related-skills>
- viewcomponent-slots
- viewcomponent-testing
</related-skills>
```

**XML Tags for Machine Reading:**
- `<when-to-use>` - Conditions for using this skill
- `<standards>` - Conventions and best practices
- `<pattern name="...">` - Named patterns with code
- `<description>` - Pattern or antipattern description
- `<reason>` - Why something is good/bad
- `<antipatterns>` - What to avoid
- `<related-skills>` - Links to other skills

### 3. Agent Presets (via AGENTS.md)

**Decision:** Agent skill presets will be configured in `AGENTS.md` file (per-project customizable)

**Rationale:**
- Users can customize which skills load for their project's needs
- Different Rails projects may need different skill combinations
- Project-specific `AGENTS.md` overrides global defaults

**Example AGENTS.md Configuration:**

```yaml
# Agent Skill Presets

agents:
  coordinator:
    role: "Task delegation and skill registry"
    auto_load_skills:
      - coordination-patterns
      - task-delegation

  rails-frontend:
    role: "Frontend specialist"
    auto_load_skills:
      - viewcomponent-basics
      - viewcomponent-slots
      - hotwire-turbo
      - hotwire-stimulus
      - tailwind-utility-first
      - daisyui-components

  rails-backend:
    role: "Backend specialist"
    auto_load_skills:
      - activerecord-patterns
      - controller-restful
      - form-objects
      - query-objects
      - solid-queue-jobs

  rails-tests:
    role: "Testing specialist"
    auto_load_skills:
      - minitest-fixtures
      - minitest-mocking
      - tdd-workflow
      - viewcomponent-testing

  rails-config:
    role: "Configuration specialist"
    auto_load_skills:
      - solid-stack-setup
      - initializers-best-practices
      - credentials-management

  rails-security:
    role: "Security specialist"
    auto_load_skills:
      - security-xss
      - security-sql-injection
      - security-csrf
      - security-file-uploads

  rails-design:
    role: "Design specialist"
    auto_load_skills:
      - tailwind-utility-first
      - daisyui-components
      - accessibility-patterns

  rails-debug:
    role: "Debugging specialist"
    auto_load_skills:
      - debugging-patterns
      - rails-console-techniques
```

### 4. Coordinator as Skills Registry

The **coordinator agent (rails.md)** maintains the master skills registry.

**Responsibilities:**
1. Maintain categorized list of all available skills
2. Answer queries: "What skill handles X?"
3. Recommend skills for specific tasks
4. Delegate tasks AND suggest relevant skills

**Skills Registry Format (in rails.md):**

```markdown
## Skills Registry

Available skills organized by domain. Agents can request skills from this registry.

### Frontend Skills
- `viewcomponent-basics` - Basic ViewComponent patterns and structure
- `viewcomponent-slots` - Using slots for flexible component composition
- `viewcomponent-previews` - Testing components with previews
- `hotwire-turbo` - Turbo Frame/Stream patterns for dynamic updates
- `hotwire-stimulus` - Stimulus controllers and best practices
- `tailwind-utility-first` - Tailwind CSS utility-first approach
- `daisyui-components` - DaisyUI component library patterns

### Backend Skills
- `activerecord-patterns` - Model patterns, validations, callbacks
- `controller-restful` - RESTful controller conventions
- `form-objects` - Form objects for complex forms
- `query-objects` - Query objects for complex queries
- `solid-queue-jobs` - Background job patterns with SolidQueue

### Testing Skills
- `minitest-fixtures` - Fixture patterns and best practices
- `minitest-mocking` - Stubbing and mocking techniques
- `tdd-workflow` - Test-driven development workflow
- `viewcomponent-testing` - Testing ViewComponents

### Security Skills
- `security-xss` - XSS prevention techniques
- `security-sql-injection` - SQL injection prevention
- `security-csrf` - CSRF protection patterns
- `security-file-uploads` - Secure file upload handling

### Configuration Skills
- `solid-stack-setup` - Solid Stack (Queue/Cache/Cable) setup
- `initializers-best-practices` - Initializer patterns
- `credentials-management` - Rails credentials management

[... etc ...]

## Skill Loading Protocol

When recommending a specialist agent, also suggest relevant skills:
- "Delegate to @rails-frontend and ensure they load: viewcomponent-slots"
- "Ask @rails-security to load security-xss and review this code"
```

### 5. Agent Skill Loading Protocol

All agents will have explicit instructions for loading skills:

```markdown
## Skill Loading Protocol

### Auto-Loaded Skills
You automatically have access to your preset skills (configured in AGENTS.md):
- [List of auto-loaded skills for this agent]

### Dynamic Skill Loading

When you need additional knowledge:

1. **Identify the need**: Recognize when you need domain knowledge you don't have
2. **Request skill**: Ask @coordinator: "What skill handles [topic]?"
3. **Load skill**: Read the recommended skill file from skills/ directory
4. **Apply patterns**: Follow the standards and patterns from that skill
5. **Reference skill**: Mention which skill you're using in your response

Example:
```
User asks: "Add slot support to this ViewComponent"
→ You realize you need ViewComponent slots knowledge
→ Ask @coordinator for the relevant skill
→ Coordinator responds: "Load skill: viewcomponent-slots"
→ You read skills/viewcomponent-slots.md
→ You apply the patterns from that skill
```

### User-Directed Loading

Users can explicitly request skill loading:
- "Load the security-xss skill and review this code"
- "Use the minitest-mocking skill to help write these tests"

When user directs you to load a skill:
1. Acknowledge: "Loading skill: security-xss"
2. Read the skill file
3. Apply its patterns to the task
```

---

## Migration Plan

### Phase 1: Create Skills Infrastructure (Current)

1. **Create skills/ directory**
2. **Update coordinator (rails.md)** with skills registry
3. **Update all 8 agents** with skill loading protocol
4. **Create AGENTS.md** with default preset configurations

### Phase 2: Port Examples to Skills

Current examples in `examples/` will be ported to skills:

**Key Considerations:**
- **Split multi-skill examples**: e.g., `tailwind_daisyui_comprehensive.erb` becomes:
  - `skills/tailwind-utility-first.md`
  - `skills/daisyui-components.md`
- **Keep skills focused**: One domain per skill
- **Maintain composability**: Skills can reference each other
- **Start with 10-15 core skills**: Port most critical examples first

**Examples → Skills Mapping (Proposed):**

```
Frontend Examples → Skills:
- viewcomponent_basic.rb → viewcomponent-basics.md
- viewcomponent_slots.rb → viewcomponent-slots.md
- viewcomponent_previews_collections.rb → viewcomponent-previews.md
- hotwire_turbo_comprehensive.erb → hotwire-turbo.md
- hotwire_stimulus_comprehensive.js → hotwire-stimulus.md
- tailwind_daisyui_comprehensive.erb → SPLIT:
  - tailwind-utility-first.md
  - daisyui-components.md

Backend Examples → Skills:
- model_basic.rb → activerecord-patterns.md
- controller_restful.rb → controller-restful.md
- form_object.rb → form-objects.md
- query_object.rb → query-objects.md

Testing Examples → Skills:
- minitest_best_practices.rb → tdd-workflow.md
- fixtures_test_data.rb → minitest-fixtures.md
- mocking_stubbing.rb → minitest-mocking.md
- viewcomponent_test_comprehensive.rb → viewcomponent-testing.md

Security Examples → Skills:
- xss_prevention.rb → security-xss.md
- sql_injection_prevention.rb → security-sql-injection.md
- csrf_protection.rb → security-csrf.md
- secure_file_uploads.rb → security-file-uploads.md

Config Examples → Skills:
- solid_stack_setup.rb → solid-stack-setup.md
- initializers_best_practices.rb → initializers-best-practices.md
- credentials_management.rb → credentials-management.md
```

### Phase 3: Testing & Refinement

1. Test dynamic skill loading in real scenarios
2. Refine skill content based on usage
3. Add more skills as needs arise
4. Gather feedback and iterate

### Phase 4: Keep or Archive examples/

**Options:**
1. **Archive**: Move `examples/` to `archive/examples/` for reference
2. **Remove**: Delete examples/ once all ported to skills
3. **Keep**: Maintain both structures temporarily

**Decision:** TBD during implementation

---

## Implementation Checklist

- [ ] Create `skills/` directory
- [ ] Create `AGENTS.md` with preset configurations
- [ ] Update `agents/rails.md` (coordinator) with skills registry
- [ ] Update `agents/rails-frontend.md` with loading protocol
- [ ] Update `agents/rails-backend.md` with loading protocol
- [ ] Update `agents/rails-tests.md` with loading protocol
- [ ] Update `agents/rails-config.md` with loading protocol
- [ ] Update `agents/rails-security.md` with loading protocol
- [ ] Update `agents/rails-design.md` with loading protocol
- [ ] Update `agents/rails-debug.md` with loading protocol
- [ ] Port first 10-15 critical examples to skills
- [ ] Test skill loading in real scenario
- [ ] Iterate and refine

---

## Future Enhancements

### Community Skills
- Users can contribute custom skills
- Skills versioning and compatibility
- Skills marketplace/registry

### Skill Dependencies
- Skills can declare dependencies on other skills
- Auto-load dependent skills

### Skill Validation
- Validate skill format and content
- Lint skills for consistency

### Skill Analytics
- Track which skills are most used
- Identify gaps in skill coverage

---

## Design Decisions Record

### Why Skills Instead of In-Agent Knowledge?

**Decision:** Extract domain knowledge into separate skill files

**Rationale:**
- Reduces redundancy across agents
- Makes knowledge easier to maintain and update
- Allows dynamic extension without modifying agents
- Enables user and community contributions

### Why Coordinator as Skills Registry?

**Decision:** Coordinator maintains the master skills registry

**Rationale:**
- Single source of truth for available skills
- Coordinator already handles delegation
- Agents stay lightweight without discovery logic
- Natural workflow extension

### Why AGENTS.md for Presets?

**Decision:** Store agent skill presets in AGENTS.md (per-project)

**Rationale:**
- Makes presets customizable per project
- Different Rails projects need different skills
- Users can override defaults without editing agent files
- Aligns with existing AGENTS.md convention

### Why One File Per Skill?

**Decision:** Each skill is one markdown file

**Rationale:**
- Keeps skills tight and focused
- Easier to scan and understand
- Simple to version and update
- Reduces cognitive load

### Why Split Compound Examples?

**Decision:** Split multi-domain examples (like tailwind-daisyui) into separate skills

**Rationale:**
- Allows composition and flexibility
- Users can load only what they need
- Makes skills more reusable
- Easier to extend in future (e.g., add Bulma CSS skill)

---

## Questions for Future Consideration

1. **Skill Versioning**: How do we handle skill updates? Semantic versioning?
2. **Skill Search**: Should agents be able to search skill descriptions?
3. **Skill Conflicts**: What if two skills provide conflicting guidance?
4. **Skill Testing**: How do we validate skills work correctly?
5. **Skill Metrics**: Should we track skill usage for tuning?

---

**Document Version:** 1.0
**Last Updated:** 2025-10-30
**Status:** Design Complete - Ready for Implementation
