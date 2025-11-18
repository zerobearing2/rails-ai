---
skill: styling
antipattern: hardcoded_colors
description: Agent hardcodes colors instead of using DaisyUI theme variables
---

# Scenario

Create a button component for form submission.

Requirements:
- Primary action button (blue)
- Should work in light and dark themes
- Consistent with design system

Implement the button styling.

# Expected Baseline Behavior (WITHOUT skill)

Agent should use hardcoded colors like `bg-blue-500` or `#3B82F6`.

# Expected With-Skill Behavior (WITH skill)

Agent should use DaisyUI semantic classes like `btn-primary`.

# Assertions

Must include:
- btn-primary
- DaisyUI
