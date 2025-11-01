# @backend Agent Audit - Machine-First Optimization

**Date:** 2025-11-01
**Agent:** @backend (`agents/backend.md`)
**Total Lines:** 943
**Estimated Tokens:** ~6,600 (943 lines × 7 tokens/line avg)

---

## Audit Criteria

**Remove:**
- ❌ Benefits lists (why it's good)
- ❌ Verbose examples (multiple showing same pattern)
- ❌ Justification/motivational text
- ❌ Philosophical explanations
- ❌ Redundant sections

**Keep:**
- ✅ Decision logic (when to do X vs Y)
- ✅ Patterns and templates
- ✅ One concise example per pattern
- ✅ Rules and constraints
- ✅ Tool usage instructions

---

## Section-by-Section Analysis

### ✅ KEEP: Lines 1-65 - YAML Front Matter, Critical Rules, TDD Workflow
**Decision:** Keep as-is - concise, machine-readable metadata and critical rules

**Lines:** 65
**Tokens:** ~455

---

### ✅ KEEP: Lines 66-148 - Skills Preset & Manifest
**Decision:** Keep as-is - essential skill metadata, already concise

**Lines:** 83
**Tokens:** ~581

---

### ✅ KEEP: Lines 149-192 - Testing & Security Pairing Sections
**Decision:** Keep as-is - recently optimized in Phases 2 & 3, already machine-first

**Lines:** 44
**Tokens:** ~308

---

### ⚠️ OPTIMIZE: Lines 193-245 - Skill Application Instructions
**Current Issues:**
- Lines 226-227: "Frontend integration needed → Pair with @frontend" - good
- Line 228: "Advanced testing needed → Pair with @tests" - good
- Section is actually pretty lean

**Decision:** Keep as-is - already concise

**Lines:** 53
**Tokens:** ~371

---

### ⚠️ OPTIMIZE: Lines 246-257 - External File References
**Decision:** Keep as-is - DRY principle enforcement

**Lines:** 12
**Tokens:** ~84

---

### ⚠️ OPTIMIZE: Lines 258-287 - Expertise Areas
**Current:** Verbose descriptions of what the agent does
**Issue:** This is human documentation - LLM doesn't need to be told its own capabilities
**Examples:**
- "Design database schemas and migrations"
- "Define associations (has_many, belongs_to, has_one, habtm)"

**Action:** Remove entire section - redundant with skills manifest and critical rules

**Lines to Remove:** 30
**Tokens Saved:** ~210

---

### ✅ KEEP: Lines 288-311 - Skills Reference
**Decision:** Keep as-is - useful quick reference to available skills

**Lines:** 24
**Tokens:** ~168

---

### ⚠️ OPTIMIZE: Lines 312-360 - MCP Integration
**Current:** Examples and guidance on querying Context7
**Decision:** Keep section, it's concise and actionable

**Lines:** 49
**Tokens:** ~343

---

### ❌ REMOVE: Lines 361-432 - Development Approach / TDD Examples
**Current Issues:**
- Lines 362-417: Two complete TDD examples (model + controller) - VERBOSE
- Lines 419-425: "TDD Benefits" list - HUMAN DOCUMENTATION
- Lines 427-429: "When NOT to Write Tests First" - redundant with critical rules

**Why Remove:**
- TDD workflow already in lines 52-60 (concise)
- TDD already in critical rules (line 44: "NEVER skip TDD")
- Examples are verbose and repetitive
- Benefits list is human justification

**Decision:** Remove entire section

**Lines to Remove:** 72
**Tokens Saved:** ~504

---

### ❌ REMOVE: Lines 433-606 - Core Responsibilities (Verbose Examples)
**Current Issues:**
- Lines 433-485: Model Development - 53 lines of example Feedback model
- Lines 486-532: Controller Development - 47 lines of example FeedbacksController
- Lines 533-600: Service Object Pattern - 68 lines of example FeedbackSubmissionService
- Lines 603-625: Migration Development - 23 lines of example migration

**Why Remove:**
- Examples are overly detailed and specific to Feedback domain
- Skills already contain patterns and examples
- Agent can reference skills for patterns
- One example per pattern would suffice, not 4 verbose ones

**Decision:** Remove entire "Core Responsibilities" section

**Lines to Remove:** 174
**Tokens Saved:** ~1,218

---

### ⚠️ OPTIMIZE: Lines 627-660 - Standards & Best Practices
**Current:** Lists of standards for models, controllers, services, database
**Analysis:**
- These are DECISION LOGIC not justification
- Concise bullet points
- Actionable rules

**Decision:** Keep as-is - this IS machine-first (rules, not explanations)

**Lines:** 34
**Tokens:** ~238

---

### ⚠️ OPTIMIZE: Lines 661-695 - Common Tasks
**Current:** Step-by-step task lists
**Analysis:**
- Creating a New Model (7 steps)
- Adding Controller Actions (7 steps)
- Creating Service Objects (6 steps)
- Optimizing Queries (5 steps)

**Decision:** Keep as-is - concise checklists, machine-actionable

**Lines:** 35
**Tokens:** ~245

---

### ❌ REMOVE: Lines 696-747 - Query Optimization Patterns
**Current Issues:**
- Lines 698-710: N+1 Query Prevention with before/after examples
- Lines 711-727: Efficient Counting with examples
- Lines 728-744: Batch Processing with examples

**Why Remove:**
- Redundant with "Common Tasks > Optimizing Queries" (lines 690-695)
- Examples are verbose
- Skills contain this knowledge
- Agent can reference ActiveRecord patterns skill

**Decision:** Remove entire section

**Lines to Remove:** 52
**Tokens Saved:** ~364

---

### ❌ REMOVE: Lines 748-861 - Testing Standards (Verbose Examples)
**Current Issues:**
- Lines 749-780: Model Tests example (32 lines)
- Lines 781-824: Controller Tests example (44 lines)
- Lines 825-860: Service Object Tests example (36 lines)

**Why Remove:**
- Testing expertise is owned by @tests (Phase 3 decision)
- Verbose examples not needed - agent pairs with @tests for complex scenarios
- TDD workflow already covered in critical rules

**Decision:** Remove entire "Testing Standards" section

**Lines to Remove:** 114
**Tokens Saved:** ~798

---

### ⚠️ OPTIMIZE: Lines 862-892 - Integration with Other Agents
**Current:** Describes peer review and coordination
**Analysis:**
- Lines 867-891: Useful coordination info with @frontend, @tests, @security
- Concise bullet points on code review responsibilities

**Decision:** Keep as-is - machine-actionable coordination logic

**Lines:** 31
**Tokens:** ~217

---

### ⚠️ OPTIMIZE: Lines 893-910 - Deliverables
**Current:** Checklist of what to provide when completing a task
**Decision:** Keep as-is - actionable checklist

**Lines:** 18
**Tokens:** ~126

---

### ⚠️ OPTIMIZE: Lines 911-943 - Anti-Patterns
**Current:** Lists of what NOT to do
**Decision:** Keep as-is - critical rules enforcement

**Lines:** 33
**Tokens:** ~231

---

## Summary of Changes

### Sections to Remove

| Section | Lines | Estimated Tokens |
|---------|-------|-----------------|
| Expertise Areas (258-287) | 30 | ~210 |
| Development Approach / TDD Examples (361-432) | 72 | ~504 |
| Core Responsibilities Examples (433-606) | 174 | ~1,218 |
| Query Optimization Patterns (696-747) | 52 | ~364 |
| Testing Standards Examples (748-861) | 114 | ~798 |
| **TOTAL** | **442** | **~3,094** |

### Sections to Keep

| Section | Lines | Estimated Tokens | Reason |
|---------|-------|-----------------|--------|
| YAML + Critical Rules | 65 | ~455 | Essential metadata |
| Skills Preset | 83 | ~581 | Skill definitions |
| Testing/Security Pairing | 44 | ~308 | Phase 2/3 optimization |
| Skill Application Instructions | 53 | ~371 | Decision logic |
| External File References | 12 | ~84 | DRY principle |
| Skills Reference | 24 | ~168 | Quick lookup |
| MCP Integration | 49 | ~343 | Tool usage |
| Standards & Best Practices | 34 | ~238 | Rules |
| Common Tasks | 35 | ~245 | Checklists |
| Integration with Agents | 31 | ~217 | Coordination |
| Deliverables | 18 | ~126 | Checklist |
| Anti-Patterns | 33 | ~231 | Rules |
| **TOTAL KEPT** | **481** | **~3,367** |

---

## Results

**Before:**
- Lines: 943
- Estimated tokens: ~6,600

**After:**
- Lines: 501 (943 - 442)
- Estimated tokens: ~3,506 (kept sections + overhead)

**Savings:**
- Lines removed: 442 (47% reduction)
- Tokens saved: ~3,094 (47% reduction)

---

## Rationale

### Why Remove "Expertise Areas"?
- Redundant with skills manifest
- Human description of capabilities
- LLM doesn't need to be told what it can do

### Why Remove TDD Examples?
- TDD already in critical rules (line 44)
- TDD workflow already defined (lines 52-60)
- Benefits list is human justification
- Verbose examples not needed

### Why Remove "Core Responsibilities" Examples?
- 4 verbose examples (174 lines!)
- Specific to Feedback domain
- Skills contain patterns
- Agent can generate code from skills, doesn't need templates

### Why Remove "Query Optimization Patterns"?
- Redundant with "Common Tasks > Optimizing Queries"
- Verbose before/after examples
- ActiveRecord patterns skill contains this

### Why Remove "Testing Standards" Examples?
- Testing owned by @tests agent (Phase 3)
- Verbose examples (114 lines!)
- Agent pairs with @tests for complex scenarios

---

## Implementation Plan

1. Remove lines 258-287 (Expertise Areas)
2. Remove lines 361-432 (Development Approach / TDD Examples)
3. Remove lines 433-606 (Core Responsibilities Examples)
4. Remove lines 696-747 (Query Optimization Patterns)
5. Remove lines 748-861 (Testing Standards Examples)
6. Verify file structure intact
7. Test agent can still function properly

---

## Risk Assessment

**Risk Level:** LOW

**Mitigations:**
- All removed content is either redundant or human documentation
- Decision logic preserved in:
  - Critical rules
  - Standards & Best Practices
  - Common Tasks checklists
- Skills contain detailed patterns and examples
- Agent can pair with @tests for testing guidance

**Rollback Plan:**
- Git history preserves all removed content
- Can restore any section if needed

---

## Next Steps

After @backend optimization:
1. Apply same pattern to @frontend
2. Apply to @tests, @security, @debug, @plan
3. Measure cumulative savings
4. Document Phase 6 complete
