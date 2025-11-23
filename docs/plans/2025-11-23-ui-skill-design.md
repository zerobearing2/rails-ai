# UI Skill Design: Unified Frontend Workflow

**Date:** 2025-11-23
**Status:** Approved

## Overview

Rename `rails-ai:views` to `rails-ai:ui` and establish it as the unified frontend skill that orchestrates the designer → developer workflow. The UI skill owns the full frontend flow: aesthetic direction (via `frontend-design` plugin), styling (Tailwind/DaisyUI), interactivity (Hotwire), and accessibility.

## Problem

Current architecture fragments the frontend workflow across multiple skills:
- `frontend-design:frontend-design` (external) — aesthetics
- `rails-ai:styling` — CSS/Tailwind/DaisyUI
- `rails-ai:views` — HTML structure/accessibility
- `rails-ai:hotwire` — Turbo/Stimulus interactivity

Users must manually decide which skills to load and in what order. This doesn't match how real teams work (designer → frontend dev handoff).

## Solution

### Real Team Dynamic → Skill Architecture

```
Real Team:
  Designer (UI/UX)              →  Frontend Dev (Implementation)
  ├── Aesthetics (visual)           ├── HTML (structure)
  ├── Behavior (interactions)       ├── CSS (styling)
  └── Usability (accessibility)     └── JS (interactivity)

Skill Architecture:
  frontend-design:frontend-design  →  rails-ai:ui
  (aesthetic direction)                ├── HTML + accessibility
                                       ├── rails-ai:styling (CSS)
                                       └── rails-ai:hotwire (JS)
```

### Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Skill scope | Aesthetic direction only (for frontend-design) | Keep responsibilities clear |
| Plugin strategy | Assume available, document as dependency | Same pattern as Superpowers |
| Trigger logic | Detection-based | Commands detect UI work automatically |
| Design dependency | UI skill owns loading frontend-design | Separation of concerns |
| New vs existing UI | Skill decides | Smart assessment, not rigid rules |
| Styling/Hotwire integration | Reference as dependencies | Keep modular |
| Loading flow | Sequential, explicit | Mirrors real designer → dev handoff |

### Detection Criteria

Feature/refactor commands detect UI work via:

| Signal Type | Examples |
|-------------|----------|
| View-related words | page, form, UI, interface, dashboard, layout, modal, component |
| User-facing actions | display, show, render, present, list, table, card |
| Interaction words | click, submit, toggle, filter, search, drag, dropdown |
| File paths | `app/views/`, `app/javascript/controllers/` |

### Sequential Loading Flow

When `rails-ai:ui` is loaded, it instructs:

```
Step 1: Assess scope
        - New page/component? → Full design flow
        - Tweak/fix? → Skip to implementation

Step 2: Load frontend-design:frontend-design (if new/significant UI)
        - Establish aesthetic direction
        - Define typography, color, layout, motion

Step 3: Load rails-ai:styling
        - Translate design to Tailwind utilities
        - Use DaisyUI components

Step 4: Load rails-ai:hotwire
        - Add interactivity with Turbo/Stimulus
        - Implement behavior from design

Step 5: Implement with rails-ai:ui patterns
        - HTML structure and partials
        - WCAG 2.1 AA accessibility
        - Form patterns and helpers
```

## Changes Required

### 1. Rename Skill

```bash
mv skills/views/ skills/ui/
```

Update YAML front matter:
```yaml
name: rails-ai:ui
description: Use when building Rails frontend - orchestrates design, styling, and interactivity into accessible, production-ready UI
```

### 2. Update UI Skill Content

Add to `skills/ui/SKILL.md`:

```markdown
<frontend-workflow>
**This skill orchestrates the complete frontend workflow.**

When loaded, follow this sequence:

### Step 1: Assess Scope

Determine if this is:
- **New/significant UI** (new page, new component, major redesign) → Full flow
- **Tweak/fix** (spacing, colors, bug fix, small change) → Skip to Step 3

### Step 2: Creative Direction (New UI Only)

Use Skill tool to load `frontend-design:frontend-design`.

This establishes:
- Typography choices
- Color palette and theme
- Layout and spatial composition
- Motion and interactions
- Overall aesthetic direction

Capture the design direction before proceeding.

### Step 3: Styling

Use Skill tool to load `rails-ai:styling`.

Translate the design direction to:
- Tailwind CSS utilities
- DaisyUI components
- Theme variables (no hardcoded colors)
- Responsive breakpoints

### Step 4: Interactivity

Use Skill tool to load `rails-ai:hotwire`.

Implement interactions with:
- Turbo Drive (navigation)
- Turbo Frames (partial updates)
- Turbo Streams (real-time)
- Stimulus controllers (behavior)

### Step 5: Implementation

Use this skill's patterns for:
- Semantic HTML structure
- Accessible forms and navigation
- Partials and helpers
- WCAG 2.1 AA compliance

</frontend-workflow>
```

### 3. Update Feature/Refactor Commands

Add UI detection to `commands/feature.md` and `commands/refactor.md`:

```markdown
<ui-detection>
**Detect frontend work and load UI skill.**

Check if the task involves UI by looking for:
- Keywords: page, form, UI, interface, dashboard, layout, modal, component, display, show, render, list, table, card, click, submit, toggle, filter, search
- File paths: `app/views/`, `app/javascript/controllers/`, `app/helpers/`

If UI work detected:
1. Load `rails-ai:ui` skill
2. UI skill will orchestrate the full frontend workflow
</ui-detection>
```

### 4. Update README

Add `frontend-design` as recommended dependency:

```markdown
## Installation

```bash
# 1. Install Superpowers (required)
claude
/plugin marketplace add obra/superpowers
/plugin install superpowers

# 2. Install frontend-design (recommended for UI work)
/plugin marketplace add claude-code-plugins
/plugin install frontend-design

# 3. Install rails-ai
/plugin marketplace add zerobearing2/rails-ai
/plugin install rails-ai
```
```

### 5. Update Documentation

- AGENTS.md: Update skill list (views → ui)
- CHANGELOG.md: Document rename and new workflow
- Test files: Rename `views_test.rb` → `ui_test.rb`

### 6. Cleanup

- Delete `feature/frontend-design-integration` branch (superseded by this design)

## File Changes

| File | Change |
|------|--------|
| `skills/views/SKILL.md` | Rename to `skills/ui/SKILL.md`, add frontend-workflow section |
| `commands/feature.md` | Add UI detection logic |
| `commands/refactor.md` | Add UI detection logic |
| `README.md` | Add frontend-design as recommended dependency |
| `AGENTS.md` | Update skill name (views → ui) |
| `CHANGELOG.md` | Document changes |
| `test/unit/skills/views_test.rb` | Rename to `ui_test.rb` |

## Out of Scope

- Creating a separate `rails-ai:design` skill (using external plugin instead)
- Merging styling/hotwire into ui skill (keeping modular)
- Automatic skill loading (explicit sequential loading is intentional)

## Success Criteria

1. User runs `/rails-ai:feature build a user dashboard`
2. Command detects "dashboard" as UI work
3. Loads `rails-ai:ui`
4. UI skill guides through: frontend-design → styling → hotwire → implementation
5. Result: Production-ready, accessible UI with cohesive design
