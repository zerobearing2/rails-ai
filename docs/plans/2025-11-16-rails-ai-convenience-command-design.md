# Rails-AI Convenience Command Design

**Date:** 2025-11-16
**Status:** Validated

## Overview

Create a `/rails-ai` slash command as the primary user interface for invoking the Rails-AI architect agent. This provides a simpler, more intuitive alternative to `@agent-rails-ai:architect`.

## Goals

- Simplify invocation: `/rails-ai <request>` instead of `@agent-rails-ai:architect <request>`
- Provide single general command for all architect interactions (features, debugging, planning, refactoring)
- Bundle with plugin for automatic availability
- Document as the recommended primary interface

## Design

### 1. Command Implementation

**File location:** `commands/rails-ai.md` (at plugin root, like superpowers)

**Content:**

```markdown
<!--
/rails-ai - Convenience command for invoking the Rails AI architect

This is a shortcut for @agent-rails-ai:architect. Use it for:
- Adding features: /rails-ai add user authentication
- Debugging: /rails-ai fix failing test in user_test.rb
- Planning: /rails-ai plan payment processing feature
- Refactoring: /rails-ai refactor UserController
- Any other Rails development task

The architect loads superpowers workflows (process) and rails-ai skills
(domain expertise) as needed.
-->

@agent-rails-ai:architect {{ARGS}}

Note: The architect loads superpowers workflows (process) and rails-ai skills (domain expertise) as needed.
```

**Behavior:**
- Direct passthrough to architect agent
- No additional processing or routing logic
- Brief context reminder about how architect works

### 2. Documentation Updates

#### README.md - Usage Section (lines ~119-127)

**Replace existing usage section with:**

```markdown
## Usage

In any Rails project with Claude Code:

```text
# Use the convenience command (recommended)
/rails-ai Add user authentication feature

# Or invoke the architect agent directly
@agent-rails-ai:architect Add user authentication feature
```

The `/rails-ai` command is a shortcut that invokes the architect agent. Use it for features, debugging, planning, refactoring, or any Rails development task.

The architect will analyze requirements, load relevant superpowers workflows (for process) and rails-ai skills (for domain expertise), and deliver a complete implementation with tests.
```

#### README.md - Installation Section (step 3, lines ~108-117)

**Replace step 3 with:**

```markdown
3. **Start using Rails-AI:**

   Once installed, you can use the `/rails-ai` convenience command in any Claude Code session:

   ```
   /rails-ai add user authentication
   /rails-ai debug failing test
   /rails-ai plan new feature
   ```

   The command invokes `@agent-rails-ai:architect`, which loads superpowers workflows (process) and rails-ai skills (domain expertise) as needed.

   For complete details on available skills and usage patterns, see `skills/using-rails-ai/SKILL.md`.
```

#### skills/using-rails-ai/SKILL.md - Getting Started Section (lines ~108-131)

**Replace "Getting Started" section with:**

```markdown
## Getting Started

**Primary interface:** `/rails-ai` command

The simplest way to use Rails-AI is the `/rails-ai` convenience command:

```text
/rails-ai add user authentication
/rails-ai fix failing test in user_test.rb
/rails-ai plan payment processing feature
/rails-ai refactor UserController
```

This command invokes `@agent-rails-ai:architect`, which:
- Analyzes requests
- Loads superpowers workflows (for process)
- Loads rails-ai skills (for domain expertise)
- Executes work directly or via subagent-driven-development
- Enforces TEAM_RULES.md

**Example:**

```text

User: "/rails-ai Add email validation to User model"

@rails-ai:architect:
1. Determines this is model work requiring TDD
2. Loads superpowers:test-driven-development for process
3. Loads rails-ai:testing for Minitest patterns
4. Loads rails-ai:models for validation patterns
5. Follows TDD cycle: write test → RED → implement → GREEN → refactor
6. Verifies TEAM_RULES.md compliance

```

**Alternative:** You can also invoke the architect directly with `@agent-rails-ai:architect <request>`
```

### 3. Directory Structure

```
rails-ai/
├── commands/
│   └── rails-ai.md              # NEW: Convenience command (plugin-level)
├── agents/
│   └── architect.md             # Existing architect agent
├── skills/
│   └── using-rails-ai/
│       └── SKILL.md             # Updated: Document command
└── README.md                    # Updated: Show command in usage
```

## Implementation Checklist

- [ ] Create `commands/rails-ai.md` with passthrough content (plugin root level)
- [ ] Update README.md Usage section to introduce `/rails-ai` as recommended
- [ ] Update README.md Installation step 3 to mention the command
- [ ] Update skills/using-rails-ai/SKILL.md Getting Started section
- [ ] Test command works: `/rails-ai add simple test feature`
- [ ] Run tests and linters (`bin/ci`)
- [ ] Commit changes

## Benefits

1. **Simpler invocation** - 9 characters (`/rails-ai`) vs 26 (`@agent-rails-ai:architect`)
2. **Discoverable** - Shows up in `/` command autocomplete
3. **Familiar pattern** - Matches superpowers commands (`/superpowers:brainstorm`, etc.)
4. **Zero learning curve** - Direct passthrough means no new behavior to learn
5. **Bundled with plugin** - Available immediately after installation

## Trade-offs

**Chosen approach (minimal passthrough):**
- ✅ Simple, no magic behavior
- ✅ Easy to understand and maintain
- ✅ No breaking changes to architect
- ❌ Doesn't provide enhanced context or smart routing

**Alternative considered (smart routing):**
- ✅ Could auto-load appropriate workflows/skills
- ✅ Could provide context-aware defaults
- ❌ More complex to implement and maintain
- ❌ Creates different behavior than direct agent invocation
- ❌ Users need to learn command-specific behavior

**Decision:** Start simple with passthrough. Can always add intelligence later if needed.

## Future Enhancements (Not Now)

Potential future additions if user feedback indicates need:

- Specialized shortcuts: `/rails-ai:debug`, `/rails-ai:plan`
- Auto-detection of Rails project and load appropriate context
- Integration with project-specific configuration
- Command aliases or shortcuts for common patterns

These are explicitly out of scope for initial implementation.
