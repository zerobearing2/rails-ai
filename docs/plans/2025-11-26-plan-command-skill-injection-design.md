# Plan Command Skill Injection Design

> Design document for ensuring `/rails-ai:plan` injects domain knowledge and forces proper implementation handoff.

**Goal:** Prevent plans from being implemented directly in main context, bypassing rails-ai skills and domain rules.

**Date:** 2025-11-26

---

## Problem Statement

When `/rails-ai:plan` produces a plan, it can get implemented directly in the main context, bypassing the rails-ai skill pipeline. This results in code that violates domain-specific rules (e.g., using wrong patterns, missing TDD, ignoring team rules).

### Root Causes

1. Plan command offered "implement now" as an option, which happens in main context without skills
2. Skills weren't always loaded before plan writing, so plans could contain wrong patterns
3. No forced handoff to `/rails-ai:feature` or `/rails-ai:refactor` after planning

## Solution

Modify `/rails-ai:plan` to:

1. **Load relevant rails-ai skills during brainstorming** — Inferred from discussion topics
2. **Inject that domain context before writing the plan** — Skills loaded before `superpowers:writing-plans`
3. **After plan is agreed, automatically dispatch to `/rails-ai:feature` or `/rails-ai:refactor`** — Infer mode from plan content, default to feature
4. **Remove the option to implement directly in main context**

## Implementation Flow

```
┌─────────────────────────────────────────────────────────┐
│ 1. UNDERSTAND THE IDEA                                  │
│    - Ask clarifying questions                           │
│    - Track which domains are discussed                  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 2. LOAD RELEVANT SKILLS                                 │
│    - Based on domains discussed, use Skill tool         │
│    - e.g., Skill: rails-ai:models, rails-ai:controllers │
│    - This injects team rules into context               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 3. BRAINSTORM WITH DOMAIN CONTEXT                       │
│    - Use superpowers:brainstorming                      │
│    - Propose approaches using correct patterns          │
│    - Present design in sections, validate each          │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 4. WRITE FORMAL PLAN                                    │
│    - Use superpowers:writing-plans                      │
│    - Plan now reflects rails-ai patterns (from step 2)  │
│    - Save to docs/plans/YYYY-MM-DD-<topic>-plan.md      │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 5. IMPLEMENTATION HANDOFF                               │
│    A) Implement now → Auto-dispatch to feature/refactor │
│    B) Keep as notes → Done                              │
└─────────────────────────────────────────────────────────┘
                          ↓ (if A)
┌─────────────────────────────────────────────────────────┐
│ 6. AUTO-DISPATCH                                        │
│    - Infer mode: feature vs refactor from plan content  │
│    - Invoke /rails-ai:feature or /rails-ai:refactor     │
│    - Pass plan file path as context                     │
└─────────────────────────────────────────────────────────┘
```

## Mode Detection

**Refactor signals:** restructure, extract, improve, clean up, move, rename, refactor, reorganize

**Feature signals:** add, create, new, implement, build, introduce

**Default:** feature (if unclear)

## Benefits

- Plans contain correct rails-ai patterns from the start
- Implementation always goes through developer agent with skill loading
- Domain rules are never bypassed
- Clean handoff from planning to implementation
