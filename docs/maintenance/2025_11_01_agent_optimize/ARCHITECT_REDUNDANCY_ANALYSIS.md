# Architect Redundancy Analysis

**Date:** 2025-11-01
**Issue:** Decision logic exists in both agents/architect.md AND rules/ARCHITECT_DECISIONS.yml

---

## Current State

### agents/architect.md (1,316 lines)
Contains:
- Decision Tree (lines 435-463)
- Pair Programming Decision Matrix (lines 519-531)
- Pairing Patterns (lines 534-555)
- Decision Framework section (lines 611-662)
- Multiple examples throughout

### rules/ARCHITECT_DECISIONS.yml (471 lines)
Contains:
- architect_delegation section with task types
- parallel_vs_sequential decision logic
- **pair_programming_patterns** (comprehensive, ~130 lines)
- team_rules_enforcement
- agent_selection_quick_lookup

---

## Redundancy Analysis

### 1. Decision Tree (architect.md lines 435-463)

**In architect.md:**
```
User Request
    ├─ Configuration/Setup?
    │   └─ @backend (has config skills)
    │
    ├─ Security audit/issue?
    │   └─ @security (or pair with implementer)
    │
    ├─ Test failure/debugging?
    │   └─ @debug (or pair with @backend/@frontend)
```

**In ARCHITECT_DECISIONS.yml:**
```yaml
agent_selection_quick_lookup:
  keywords_to_agent:
    config: "backend"
    security: "security"
    debug: "debug"
```

**Redundancy:** ~30% overlap
**Different purpose:**
- architect.md: Human-readable decision flow
- ARCHITECT_DECISIONS.yml: Machine-parseable keyword lookup

**Verdict:** **COMPLEMENTARY, NOT DUPLICATE**

---

### 2. Pair Programming Decision Matrix (architect.md lines 519-531)

**In architect.md:**
```markdown
**Pair when:**
- Security-critical (user input, auth, file uploads)
- Full-stack (backend + frontend)
- Complex testing (mocking, edge cases)
- Performance-critical (N+1, caching)

**Sequential when:**
- Simple CRUD
- Single domain only
- Low risk (read-only)
```

**In ARCHITECT_DECISIONS.yml:**
```yaml
pair_programming_patterns:
  decision_criteria:
    use_pairing_when:
      - "Security-critical features (user input, auth, file uploads, database queries)"
      - "Full-stack features requiring API contract coordination"
      - "Complex testing scenarios (mocking, edge cases, test strategy)"
      - "Performance-critical work (N+1, caching, optimization)"

    use_sequential_when:
      - "Simple CRUD operations (single domain)"
      - "Read-only features (low risk)"
      - "Single-agent expertise sufficient"
      - "No cross-domain coordination needed"
```

**Redundancy:** ~90% DUPLICATE
**Verdict:** **REDUNDANT - Should consolidate**

---

### 3. Pairing Patterns (architect.md lines 534-555)

**In architect.md:**
```markdown
**1. Security-Critical**
- Trigger: User input, auth, file uploads
- Agents: @backend/@frontend + @security
- Prompt: "@backend + @security, pair on [feature]. @security guides security from design phase."

**2. Full-Stack**
- Trigger: Backend + frontend needed
- Agents: @backend + @frontend
- Prompt: "@backend + @frontend, pair on [feature]. Agree on API contract first."

**3. Complex Testing**
- Trigger: Mocking, edge cases, external APIs
- Agents: Implementer + @tests
- Prompt: "@backend + @tests, pair on [feature]. @tests guides test strategy."

**4. Performance/Debugging**
- Trigger: N+1, bugs, optimization
- Agents: @debug + implementer
- Prompt: "@debug + @backend, pair on [issue]. @debug identifies root cause."
```

**In ARCHITECT_DECISIONS.yml:**
```yaml
  security_critical_pairing:
    when:
      - "User input processing (forms, search, filters)"
      - "Authentication or authorization features"
      - "File upload handling"
      - "Database queries with user data"
      - "System command execution"
      - "API endpoints accepting external data"

    agents: ["security", "backend"]  # or "frontend" depending on implementation layer
    coordination_strategy: "Build security in from design, not review after"

    execution_pattern: "Single Task tool call with both agents"

    examples:
      - request: "Add file upload for user avatars"
        agents: ["security", "backend"]
        task: "Implement secure file upload with validation, sanitization, and storage"
        why: "File uploads are security-critical (OWASP A04:2021)"
```

**Redundancy:** ~70% DUPLICATE, but ARCHITECT_DECISIONS.yml has MORE detail
**Verdict:** **REDUNDANT - ARCHITECT_DECISIONS.yml is more comprehensive**

---

### 4. Decision Framework Examples (architect.md lines 618-662)

**In architect.md:**
```markdown
#### Simple, Single-Concern Tasks → Delegate to One Agent
User: "Add email field to Feedback model"
@architect: Delegates to @backend - Add email validation to Feedback model

#### UI/Styling Tasks → Delegate to Frontend
User: "Create a notification card component"
@architect: Delegates to @frontend - Create notification card with DaisyUI styling
```

**In ARCHITECT_DECISIONS.yml:**
```yaml
  simple_task:
    condition: "single_concern AND well_defined"
    strategy: "delegate_to_single_agent"
    examples:
      - request: "Add email field to Feedback model"
        delegates_to: "backend"
        task: "Add email validation to Feedback model"

  ui_task:
    condition: "involves_visual OR involves_interaction OR involves_styling"
    strategy: "delegate_to_frontend"
    examples:
      - request: "Create a notification card component"
        delegates_to: "frontend"
        task: "Create notification card with DaisyUI styling"
```

**Redundancy:** ~80% DUPLICATE, EXACT SAME EXAMPLES
**Verdict:** **HIGHLY REDUNDANT**

---

### 5. Multi-Agent Tasks Table (architect.md lines 425-433)

**In architect.md:**
```markdown
| Full-stack features | **@backend** + **@frontend** | Pair: Agree on API contract first |
| Security-critical features | **@backend**/**@frontend** + **@security** | Pair: Build security in from design |
| Complex testing | **@backend**/**@frontend** + **@tests** | Pair: Test strategy and edge cases |
| Performance debugging | **@debug** + **@backend**/**@frontend** | Pair: Investigate and fix together |
```

**In ARCHITECT_DECISIONS.yml:**
```yaml
  full_stack_pairing:
    agents: ["backend", "frontend"]
    coordination_strategy: "Agree on API contract first, then implement in parallel"

  security_critical_pairing:
    agents: ["security", "backend"]  # or "frontend"
    coordination_strategy: "Build security in from design, not review after"

  testing_pairing:
    agents: ["tests", "backend"]  # or "frontend"
    coordination_strategy: "Design test approach together, especially mocking strategy"

  performance_debug_pairing:
    agents: ["debug", "backend"]  # or "frontend"
    coordination_strategy: "Investigate together, fix with domain expertise"
```

**Redundancy:** ~90% DUPLICATE
**Verdict:** **HIGHLY REDUNDANT**

---

## Summary of Redundancy

| Section | architect.md Lines | ARCHITECT_DECISIONS.yml | Redundancy | Verdict |
|---------|-------------------|------------------------|------------|---------|
| Decision Tree | 435-463 (29 lines) | agent_selection_quick_lookup | 30% | Complementary |
| Pair Decision Matrix | 519-531 (13 lines) | pair_programming_patterns.decision_criteria | 90% | **DUPLICATE** |
| Pairing Patterns | 534-555 (22 lines) | pair_programming_patterns (all 4 patterns) | 70% | **DUPLICATE** |
| Multi-Agent Table | 425-433 (9 lines) | pair_programming_patterns (all 4 patterns) | 90% | **DUPLICATE** |
| Decision Examples | 618-662 (45 lines) | architect_delegation examples | 80% | **DUPLICATE** |
| **TOTAL** | **~118 lines** | **~200 lines in YAML** | **~75% overlap** | **HIGH REDUNDANCY** |

---

## Problem Statement

**Issue:** Decision logic is duplicated between two files:
1. **architect.md:** Human-readable markdown with examples
2. **ARCHITECT_DECISIONS.yml:** Machine-readable YAML with structured data

**Impact:**
- **Maintenance burden:** Update two places when decision logic changes
- **Risk of divergence:** Files can get out of sync
- **Redundant tokens:** ~800-1,000 tokens duplicated

**Current redundancy:** ~75% overlap (~118 lines in architect.md, ~200 lines in YAML)

---

## Solution Options

### Option 1: Keep YAML as Source of Truth, Reference from Architect ✅ RECOMMENDED

**Approach:**
- **ARCHITECT_DECISIONS.yml:** Complete decision logic (machine-readable)
- **architect.md:** Concise summary + reference to YAML file

**Changes to architect.md:**
```markdown
## Decision Framework

**Complete decision logic:** See [ARCHITECT_DECISIONS.yml](../rules/ARCHITECT_DECISIONS.yml)

**Quick Reference:**

### When to Pair Program
- Security-critical (user input, auth, file uploads) → @security + implementer
- Full-stack features → @backend + @frontend
- Complex testing → @tests + implementer
- Performance issues → @debug + implementer

See ARCHITECT_DECISIONS.yml for detailed patterns, examples, and execution strategies.

### When to Delegate Sequentially
- Simple CRUD operations
- Single domain tasks
- Low risk read-only features

See ARCHITECT_DECISIONS.yml for complete task type catalog and routing rules.
```

**Benefits:**
- ✅ Single source of truth (ARCHITECT_DECISIONS.yml)
- ✅ No duplication
- ✅ Easier maintenance
- ✅ architect.md stays readable (quick reference)
- ✅ Detailed logic in YAML (machine-parseable)
- ✅ ~80-100 lines removed from architect.md (~700-800 tokens saved)

**Drawbacks:**
- ⚠️ Requires jumping to YAML for details
- ⚠️ architect.md slightly less self-contained

**Verdict:** **BEST APPROACH** - Follows DRY principle, maintains readability

---

### Option 2: Keep Markdown as Source of Truth, Delete YAML

**Approach:**
- **architect.md:** Complete decision logic (human-readable)
- **Delete:** ARCHITECT_DECISIONS.yml entirely

**Benefits:**
- ✅ Single source of truth (architect.md)
- ✅ Everything in one file
- ✅ Human-readable format

**Drawbacks:**
- ❌ Loses machine-parseable structure
- ❌ Harder for programmatic access
- ❌ Inconsistent with other rules files (RULES_TO_SKILLS_MAPPING.yml, TEAM_RULES.md)
- ❌ Tests reference ARCHITECT_DECISIONS.yml
- ❌ Goes against "separate data from docs" principle

**Verdict:** **NOT RECOMMENDED** - Loses structured data benefits

---

### Option 3: Keep Both, Accept Duplication

**Approach:**
- Keep both files as-is
- Accept maintenance burden

**Benefits:**
- ✅ No changes needed
- ✅ architect.md fully self-contained

**Drawbacks:**
- ❌ Violates DRY principle
- ❌ Maintenance burden (update two places)
- ❌ Risk of divergence
- ❌ ~700-800 redundant tokens

**Verdict:** **NOT RECOMMENDED** - Violates optimization goals

---

## Recommended Implementation

### Step 1: Slim Down architect.md Decision Sections

**Remove from architect.md:**
1. Detailed pairing patterns (lines 534-555) - ~22 lines
2. Pair decision matrix details (lines 519-531) - ~13 lines
3. Decision framework examples (lines 618-662) - ~45 lines
4. Multi-agent tasks table details (lines 425-433) - ~9 lines

**Total removal:** ~89 lines (~600-700 tokens)

**Keep in architect.md:**
1. High-level decision tree (lines 435-463) - Quick visual reference
2. Brief summary of when to pair vs delegate
3. Reference link to ARCHITECT_DECISIONS.yml

---

### Step 2: Replace with Concise References

**New architect.md structure:**

```markdown
## Decision Framework

**Machine-Readable Decision Logic**: [ARCHITECT_DECISIONS.yml](../rules/ARCHITECT_DECISIONS.yml)

This YAML file contains:
- Complete delegation strategies for all task types
- Detailed pair programming patterns with examples
- Team rules enforcement logic
- Agent selection keyword lookup
- Parallel vs sequential execution patterns

### Quick Decision Guide

**Pair Programming (Real-Time Collaboration):**
- Security-critical → @security + @backend/@frontend
- Full-stack → @backend + @frontend
- Complex testing → @tests + @backend/@frontend
- Performance/debugging → @debug + @backend/@frontend

**Sequential Delegation:**
- Simple single-domain tasks → Single agent
- Low-risk read-only → Single agent
- When no cross-domain coordination needed

**For complete patterns, triggers, examples, and execution strategies:**
→ See [ARCHITECT_DECISIONS.yml](../rules/ARCHITECT_DECISIONS.yml)

### Decision Tree

[Keep existing tree - lines 435-463]
This provides visual flow for quick reference.
```

---

### Step 3: Ensure ARCHITECT_DECISIONS.yml is Complete

**Verify ARCHITECT_DECISIONS.yml has:**
- ✅ All task types (simple, ui, config, security, testing, debug, planning, complex)
- ✅ Pair programming patterns (4 patterns with examples)
- ✅ Decision criteria (when to pair vs delegate)
- ✅ Execution patterns (parallel vs sequential)
- ✅ Team rules enforcement
- ✅ Agent selection keyword lookup

**Currently complete** ✅ (added in recent optimization)

---

### Step 4: Update References

**Files that reference decision logic:**
- agents/architect.md - Update to reference YAML
- test/agents/unit/agent_consistency_test.rb - Already references YAML ✅

---

## Impact Analysis

### Token Savings
- **Remove from architect.md:** ~89 lines (~600-700 tokens)
- **System-wide impact:** ~0.25% additional savings
- **Maintenance improvement:** Single source of truth

### Readability Impact
- **architect.md:** Stays readable (quick reference + link to details)
- **ARCHITECT_DECISIONS.yml:** Complete source of truth
- **Trade-off:** Slight inconvenience jumping to YAML for details
- **Benefit:** No duplication, easier to maintain

### Consistency
- ✅ Follows pattern of other rules files (TEAM_RULES.md references RULES_TO_SKILLS_MAPPING.yml)
- ✅ Separation of concerns (docs vs data)
- ✅ DRY principle

---

## Recommendation

**YES, consolidate to ARCHITECT_DECISIONS.yml as source of truth**

**Actions:**
1. Remove detailed decision logic from architect.md (~89 lines)
2. Keep high-level decision tree (visual reference)
3. Add concise summary with reference to ARCHITECT_DECISIONS.yml
4. Verify ARCHITECT_DECISIONS.yml completeness ✅
5. Test and commit

**Expected savings:** ~600-700 tokens
**Maintenance improvement:** Single source of truth
**Risk:** Low (YAML file already complete)

---

## Alternative View: Keep Short Examples in Markdown

**Middle ground:** Keep 1-2 brief examples in architect.md for quick reference

```markdown
## Decision Framework

**Complete decision logic:** [ARCHITECT_DECISIONS.yml](../rules/ARCHITECT_DECISIONS.yml)

### Quick Examples

**Simple delegation:**
```
User: "Add email validation to User model"
→ Delegate to @backend
```

**Pair programming:**
```
User: "Add file upload feature"
→ Pair @security + @backend (security-critical)
```

**Complex coordination:**
```
User: "Add categories with filtering UI"
→ Parallel: @backend (model/controller) + @frontend (UI)
```

**For complete patterns and all task types, see ARCHITECT_DECISIONS.yml**
```

**Trade-off:** Keeps some examples (~15 lines) for quick reference, still references YAML for complete logic

**Verdict:** **REASONABLE COMPROMISE** if we want architect.md to stay more self-contained

---

## Final Recommendation

**Primary:** Option 1 - ARCHITECT_DECISIONS.yml as source of truth
**Alternative:** Keep 2-3 brief examples in architect.md for quick reference

**Either way:** Remove ~70-80 lines of duplicate decision logic from architect.md

**Savings:** ~500-700 tokens
**Benefit:** Single source of truth, easier maintenance
**Trade-off:** Minimal (YAML file is complete and referenced)

---

**Status:** ANALYSIS COMPLETE, AWAITING IMPLEMENTATION DECISION
