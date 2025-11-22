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

**This workflow produces plans, not code.**

## Superpowers Workflows

This workflow uses:
- `superpowers:brainstorming` — refine ideas through collaborative questioning
- `superpowers:writing-plans` — (optional) produce formal implementation plan if requested

## Rails-AI Skills

Load based on what's being planned:

| Planning involves | Load these skills |
|-------------------|-------------------|
| Models, databases | `rails-ai:models` |
| Controllers, routes | `rails-ai:controllers` |
| Views, templates, forms | `rails-ai:views` |
| Hotwire, Turbo, Stimulus | `rails-ai:hotwire` |
| CSS, Tailwind, DaisyUI | `rails-ai:styling` |
| Background jobs, caching | `rails-ai:jobs` |
| Email functionality | `rails-ai:mailers` |
| Security concerns | `rails-ai:security` |
| Testing strategy | `rails-ai:testing` |

**Load domain skills BEFORE brainstorming** — you can't give expert advice without domain context.

## Process

### Step 1: Understand the Idea

Ask clarifying questions:
- What problem are you solving?
- Who is this for?
- What does success look like?
- Any constraints or requirements?

### Step 2: Load Relevant Skills

Based on what's being planned, load the appropriate rails-ai skills for domain context.

```
Use Skill tool to load:
- rails-ai:[relevant-domain-skill]
- rails-ai:[relevant-domain-skill]
```

### Step 3: Brainstorm

Use `superpowers:brainstorming` skill:
- Ask questions one at a time
- Prefer multiple choice when possible
- Explore 2-3 different approaches with trade-offs
- Present design in small sections (200-300 words)
- Validate each section before continuing

### Step 4: Decide Next Steps

At the end of brainstorming, ask:

**"What would you like to do next?"**

A) **Create formal implementation plan** — Use `superpowers:writing-plans` to produce detailed tasks
B) **Keep as design notes** — Document the design for future reference
C) **Start implementing now** — Switch to `/rails-ai:feature` workflow

### Step 5: If Formal Plan Requested

Use `superpowers:writing-plans` to create:
- Detailed implementation tasks
- Exact file paths and code examples
- Verification steps per task
- Save to `docs/plans/YYYY-MM-DD-<topic>-plan.md`

## Completion

**No completion checklist** — this workflow produces plans, not code.

Output is either:
- A refined design (from brainstorming)
- A formal plan document (if requested)

---

**Now handle the planning request: {{ARGS}}**
