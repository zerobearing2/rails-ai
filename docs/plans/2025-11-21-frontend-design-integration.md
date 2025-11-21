# Frontend Design Integration

## Overview

Integrate the `frontend-design` plugin from Anthropic's claude-code-plugins as a creative direction layer for UI work in rails-ai.

## Two-Layer Approach

- **frontend-design:frontend-design** — Creative direction (aesthetic choices, typography, color, motion, layout)
- **rails-ai:styling** — Implementation (Tailwind utilities, DaisyUI components, Rails patterns)

## When to Use Each

**Use both (frontend-design + rails-ai:styling):**
- New pages or components
- Significant UI redesigns
- User explicitly asks for "design" or "make it look good"

**Use rails-ai:styling only:**
- Tweaks to existing UI
- Adding a button, fixing spacing, adjusting colors
- Pure implementation tasks

## Conflict Resolution

- Frontend-design wins on *what* it should look like (vision)
- Rails-ai:styling wins on *how* to build it (Tailwind/DaisyUI, no custom CSS unless necessary)

## Changes

### 1. skills/using-rails-ai/SKILL.md

- Update "Planning Rails Features" table: split "User-facing forms/pages" into (new) and (tweaks)
- Add "External Dependencies" section documenting frontend-design plugin

### 2. skills/styling/SKILL.md

- Add `<creative-direction>` block after `<when-to-use>` explaining when to load frontend-design first

### 3. AGENTS.md

- Document frontend-design as optional dependency for UI work

### 4. README.md

- Add frontend-design to optional dependencies section

### 5. Tests

- Update any skill structure tests that validate using-rails-ai content
- Add test for frontend-design reference in styling skill

## External Dependency

**Plugin:** frontend-design@claude-code-plugins
**Source:** https://github.com/anthropics/claude-code
**Install:** `/plugin install frontend-design@claude-code-plugins`
**Status:** Optional but recommended for UI work
