---
description: Brainstorm ideas and optionally produce formal implementation plans
---

# Rails Planning Workflow

## Purpose

Use this workflow when:
- Brainstorming a new feature or improvement
- Refining a rough idea into a concrete design
- Creating a formal implementation plan for later execution
- Exploring approaches before committing to implementation

**This workflow produces plans, not code. Implementation is handed off to `/rails-ai:feature` or `/rails-ai:fix`.**

## Superpowers Workflows

This workflow uses:
- `superpowers:brainstorming` — refine ideas through collaborative questioning
- `superpowers:writing-plans` — produce formal implementation plan

## Process

### Step 1: Understand the Idea

Ask clarifying questions:
- What problem are you solving?
- Who is this for?
- What does success look like?
- Any constraints or requirements?

Track which domains are discussed (models, controllers, jobs, etc.) for Step 2.

### Step 2: Load Relevant Skills

**BEFORE brainstorming**, load skills based on domains discussed in Step 1.

Use the Skill tool to load each relevant skill:

| Discussion involves | Load this skill |
|---------------------|-----------------|
| Models, databases, validations | `rails-ai:models` |
| Controllers, routes, REST | `rails-ai:controllers` |
| Views, components, forms | `rails-ai:ui` |
| Hotwire, Turbo, Stimulus | `rails-ai:hotwire` |
| CSS, Tailwind, DaisyUI | `rails-ai:styling` |
| Background jobs, caching | `rails-ai:jobs` |
| Email functionality | `rails-ai:mailers` |
| Security concerns | `rails-ai:security` |

**Always load `rails-ai:testing`** — TDD is non-negotiable.

**Load skills NOW using the Skill tool.** This puts domain rules, patterns, and team rules into context so the plan is written correctly.

### Step 3: Brainstorm

Use `superpowers:brainstorming` skill:
- Ask questions one at a time
- Prefer multiple choice when possible
- Explore 2-3 different approaches with trade-offs
- Present design in small sections (200-300 words)
- Validate each section before continuing

The loaded skills ensure you propose correct patterns during brainstorming.

### Step 4: Write Formal Plan

Use `superpowers:writing-plans` to create:
- Detailed implementation tasks
- Exact file paths and code examples (using patterns from loaded skills)
- Verification steps per task
- Save to `docs/plans/YYYY-MM-DD-<topic>-plan.md`

### Step 5: Implementation Handoff

After plan is saved, ask:

**"Plan saved. Ready to implement?"**

A) **Yes, implement now** → Continue to Step 6
B) **No, keep as design notes** → Done

### Step 6: Auto-Dispatch to Implementation

**Do NOT implement directly in this context.** The feature/fix workflow ensures proper skill loading and developer agent dispatch.

**Determine mode** by scanning plan content:
- **Fix signals:** restructure, extract, improve, clean up, move, rename, refactor, reorganize, fix, address
- **Feature signals:** add, create, new, implement, build, introduce

Default to `feature` if unclear.

**USE THE SlashCommand TOOL to invoke the appropriate workflow:**

For new functionality:
```
SlashCommand tool with command: "/rails-ai:feature implement the plan at docs/plans/YYYY-MM-DD-<topic>-plan.md"
```

For fixing or improving existing code:
```
SlashCommand tool with command: "/rails-ai:fix implement the plan at docs/plans/YYYY-MM-DD-<topic>-plan.md"
```

**You MUST use the SlashCommand tool. Do not implement directly. Do not tell the user to run the command. YOU run it.**

## Critical Rules

1. **Skills before brainstorming** — Load domain skills BEFORE proposing approaches
2. **No direct implementation** — Always hand off to `/rails-ai:feature` or `/rails-ai:fix`
3. **Plan reflects patterns** — Plans must use patterns from loaded skills, not generic code

---

**Now handle the planning request: {{ARGS}}**
