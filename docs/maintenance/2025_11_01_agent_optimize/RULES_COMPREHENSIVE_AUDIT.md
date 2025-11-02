# Comprehensive Rules Folder Audit

**Date:** 2025-11-01
**Purpose:** Deep audit of rules folder structure, naming, pair programming integration, and domain organization

---

## Executive Summary

### Files Audited
1. **DECISION_MATRICES.yml** (338 lines) - Architect-specific decision logic
2. **RULES_TO_SKILLS_MAPPING.yml** (472 lines) - Bidirectional rule-skill mapping
3. **TEAM_RULES.md** (799 lines) - Team governance rules

### Key Findings
1. ✅ **DECISION_MATRICES.yml naming is misleading** - Only used by architect, should be ARCHITECT_DECISIONS.yml
2. ⚠️ **Pair programming NOT in DECISION_MATRICES** - Major gap in decision logic
3. ❓ **RULES_TO_SKILLS_MAPPING completeness** - Need to verify all 41 skills and 19 rules covered
4. ❓ **TEAM_RULES organization** - No domain grouping, could improve navigation

---

## 1. DECISION_MATRICES.yml Audit

### Current State
- **Name:** `DECISION_MATRICES.yml`
- **Lines:** 338
- **Purpose:** Architect delegation decision logic
- **Used by:** Only @architect (2 references in architect.md)

### Issues Found

#### Issue 1: Misleading Name
**Problem:** Name suggests general decision matrices for all agents, but it's architect-specific.

**Evidence:**
```bash
$ grep -r "DECISION_MATRICES" agents/
agents/architect.md:**Machine-Readable Decision Logic**: [DECISION_MATRICES.yml](../DECISION_MATRICES.yml)
agents/architect.md:**Quick Agent Selection**: Use keyword lookup in DECISION_MATRICES.yml for instant routing.
```

**Only @architect uses this file.**

**Recommendation:** Rename to `ARCHITECT_DECISIONS.yml` for clarity.

---

#### Issue 2: Pair Programming Missing
**Problem:** File has "parallel_vs_sequential" section but NO pair programming patterns.

**What's Missing:**
- When to use pair programming vs sequential delegation
- Pair programming patterns (from architect.md):
  - Security pairing: @security + @backend/@frontend
  - Full-stack pairing: @backend + @frontend
  - Testing pairing: @tests + @backend/@frontend
  - Debugging pairing: @debug + @backend/@frontend

**What Exists in architect.md but NOT in DECISION_MATRICES.yml:**

```yaml
# From agents/architect.md - NOT in DECISION_MATRICES.yml

Multi-Agent Tasks (Use Pair Programming):
  security_critical:
    agents: [@backend/@frontend, @security]
    strategy: "Pair: Build security in from design"

  full_stack:
    agents: [@backend, @frontend]
    strategy: "Pair: Agree on API contract first"

  complex_testing:
    agents: [@backend/@frontend, @tests]
    strategy: "Pair: Test strategy and edge cases"

  performance_debug:
    agents: [@debug, @backend/@frontend]
    strategy: "Pair: Investigate and fix together"
```

**Recommendation:** Add pair programming section to DECISION_MATRICES.yml with structured patterns.

---

#### Issue 3: Inconsistent with Phases 2 & 3
**Problem:** Phases 2 & 3 removed duplicate skills and added pairing guidance, but DECISION_MATRICES doesn't reflect this.

**Example:** Security task section still shows sequential pattern, not pairing:
```yaml
security_task:
  strategy: "security_first_then_fix"  # OLD: Sequential
  phase_1:
    delegates_to: "security"
  phase_2_if_issues:
    delegates_to: "backend"
```

**Should be:**
```yaml
security_task:
  strategy: "pair_programming"  # NEW: Real-time collaboration
  when: "user_input OR auth OR file_uploads OR database_queries"
  pattern:
    agents: ["security", "backend"]  # or "frontend"
    coordination: "Build security in from design, not review after"
```

---

### Proposed Structure for ARCHITECT_DECISIONS.yml

```yaml
# ARCHITECT_DECISIONS.yml
# Decision logic for @architect agent coordination

delegation_strategy:
  simple_single_domain:
    # Current "simple_task", "ui_task", "config_task" patterns

  pair_programming:
    # NEW SECTION - Core pairing patterns
    security_critical:
      when: ["user_input", "auth", "file_uploads", "database_queries"]
      agents: ["security", "backend"]  # or "frontend"
      pattern: "Build security in from design"

    full_stack:
      when: ["backend_and_frontend", "api_contract", "data_flow"]
      agents: ["backend", "frontend"]
      pattern: "Agree on API contract first"

    complex_testing:
      when: ["mocking_needed", "edge_cases", "test_strategy"]
      agents: ["tests", "backend"]  # or "frontend"
      pattern: "Design test strategy together"

    performance_debug:
      when: ["n+1_queries", "memory_issues", "slow_endpoints"]
      agents: ["debug", "backend"]  # or "frontend"
      pattern: "Investigate and fix together"

  parallel_coordination:
    # Current "complex_task" patterns

  sequential_coordination:
    # Current "debug_task", planning phases
```

---

## 2. RULES_TO_SKILLS_MAPPING.yml Audit

### Current State
- **Lines:** 472
- **Rules covered:** 19 (matches TEAM_RULES.md)
- **Format:** Machine-readable YAML
- **Organization:** Flat structure (rules_with_skills, rules_without_skills)

### Completeness Check

#### Rules Coverage: ✅ COMPLETE
```
Total rules in TEAM_RULES.md: 19
Rules in mapping: 19
Coverage: 100%
```

**Rules with skills:** 10
**Rules without skills:** 9 (workflow/philosophy rules)

---

#### Skills Coverage: ❓ NEED TO VERIFY

**Skills in registry:** 41 actual skill files
**Skills in mapping:** Need to count references

Let me check which skills are referenced in RULES_TO_SKILLS_MAPPING.yml...

**Questions:**
1. Are all 41 skills referenced in at least one rule?
2. Or do some skills exist without rule enforcement? (That's OK)
3. Are there orphaned skill references (skills mentioned but don't exist)?

---

### Organization Issues

#### Issue 1: No Domain Grouping
**Current:** Rules organized by "with skills" vs "without skills"
**Problem:** Hard to find rules by domain (backend, frontend, testing, security)

**Proposed Structure:**
```yaml
rules_by_domain:
  stack_architecture:
    - rule_1_solid_stack
    - rule_2_minitest

  routing:
    - rule_3_rest_routes

  testing:
    - rule_4_tdd
    - rule_18_webmock
    - rule_19_no_system_tests

  frontend:
    - rule_7_turbo_morph
    - rule_13_progressive_enhancement
    - rule_15_viewcomponent

  backend:
    - rule_5_namespacing
    - rule_12_fat_models

  workflow:
    - rule_6_architect_review
    - rule_11_draft_prs
    - rule_17_ci_must_pass

  philosophy:
    - rule_8_be_concise
    - rule_9_dont_overengineer
    - rule_10_reduce_complexity
    - rule_14_no_premature_optimization
```

This would be IN ADDITION to existing structure, for easier lookups.

---

## 3. TEAM_RULES.md Audit

### Current State
- **Lines:** 799
- **Rules:** 19
- **Organization:** Linear (Rule #1 through #19)
- **Format:** Markdown with XML tags

### Pair Programming Conflicts Check

#### Potential Conflict 1: Rule #6 - Architect Reviews Everything
**Current text:**
> "Architect reviews everything before implementation"

**Question:** Does this conflict with pair programming where agents collaborate in real-time?

**Analysis:**
- @architect still orchestrates and assigns work ✅
- But review is now DURING (pairing) not AFTER (sequential) ✅
- No conflict if we interpret "reviews" as "coordinates" ✅

**Recommendation:** Clarify that architect COORDINATES, not necessarily reviews sequentially.

---

#### Potential Conflict 2: SHARED_CONTEXT Peer Review References
**Status:** ✅ Already resolved in previous audit - SHARED_CONTEXT deleted

---

#### No Other Conflicts Found
- Rules focus on technical standards (Solid Stack, Minitest, REST)
- Philosophy rules (YAGNI, simplicity) don't conflict
- Pair programming is a coordination mechanism, not a rule violation

---

### Organization Issues

#### Issue 1: No Domain Grouping in TEAM_RULES.md
**Current:** Rules numbered 1-19 in linear order
**Problem:** Hard to find all testing rules, all frontend rules, etc.

**Proposed Addition:** Add domain index at top
```markdown
## Rules by Domain

### Stack Architecture
- Rule #1: Solid Stack Only (SolidQueue/SolidCache/SolidCable)
- Rule #2: Minitest Only (no RSpec)

### Routing & Controllers
- Rule #3: RESTful Routes Only (no custom actions)
- Rule #12: Fat Models, Thin Controllers

### Testing
- Rule #4: TDD Always (RED-GREEN-REFACTOR)
- Rule #18: WebMock: No Live HTTP in Tests
- Rule #19: No System Tests (use integration tests)

### Frontend
- Rule #7: Turbo Morph Default (stream only when needed)
- Rule #13: Progressive Enhancement (work without JS)
- Rule #15: ViewComponent for All UI

### Workflow
- Rule #6: Architect Reviews Everything
- Rule #11: Draft PRs & Code Reviews
- Rule #17: bin/ci Must Pass

### Philosophy
- Rule #8: Be Concise (resist over-engineering)
- Rule #9: Don't Over-Engineer (YAGNI)
- Rule #10: Reduce Complexity Always
- Rule #14: No Premature Optimization

### Code Quality
- Rule #5: Proper Namespacing (Feedbacks:: not FeedbacksHelper)
- Rule #16: Double Quotes Always (enforced by Rubocop)
```

This would make rules easier to navigate while keeping numbered format.

---

## Recommendations Summary

### High Priority

#### 1. Rename DECISION_MATRICES.yml → ARCHITECT_DECISIONS.yml
**Rationale:**
- Only used by architect
- Misleading name suggests general-purpose
- Clarity improves maintainability

**Impact:** Update 2 references in architect.md

---

#### 2. Add Pair Programming to ARCHITECT_DECISIONS.yml
**Rationale:**
- Major architectural pattern missing from decision logic
- Phases 2 & 3 centralized expertise around pairing
- Current sequential patterns outdated

**Proposed Structure:**
```yaml
pair_programming_patterns:
  security_critical:
    when: ["user_input", "auth", "file_uploads", "sql_queries", "system_commands"]
    agents: ["security", "backend"]  # or "frontend"
    coordination: "Build security in from design, not review after"
    examples:
      - "Add file upload feature"
      - "Implement user authentication"
      - "Create search with user input"

  full_stack:
    when: ["api_and_ui", "data_contract", "end_to_end_feature"]
    agents: ["backend", "frontend"]
    coordination: "Agree on API contract first, then implement in parallel"
    examples:
      - "Add categories with filtering UI"
      - "Create dashboard with data visualization"

  complex_testing:
    when: ["complex_mocking", "edge_cases", "test_strategy_needed"]
    agents: ["tests", "backend"]  # or "frontend"
    coordination: "Design test approach together, especially mocking"
    examples:
      - "Test external API integration"
      - "Test time-dependent business logic"

  performance_debugging:
    when: ["n+1_queries", "memory_leaks", "slow_endpoints", "timeout_issues"]
    agents: ["debug", "backend"]  # or "frontend"
    coordination: "Investigate together, fix with domain knowledge"
    examples:
      - "Fix N+1 query in reports"
      - "Debug slow page load"
```

---

### Medium Priority

#### 3. Add Domain Organization to RULES_TO_SKILLS_MAPPING.yml
**Rationale:**
- Easier to find rules by concern
- Mirrors agent specialization
- Improves navigation

**Implementation:** Add `rules_by_domain` section (in addition to existing structure)

---

#### 4. Add Domain Index to TEAM_RULES.md
**Rationale:**
- Quick reference for finding rules
- Groups related rules together
- Maintains existing numbered format

**Implementation:** Add "Rules by Domain" section at top

---

### Low Priority

#### 5. Verify Skills Coverage in RULES_TO_SKILLS_MAPPING.yml
**Rationale:**
- Ensure no orphaned skill references
- Understand which skills have rule enforcement vs. optional patterns

**Action:** Audit all skill references against actual skill files

---

#### 6. Update Security Task Pattern in ARCHITECT_DECISIONS.yml
**Rationale:**
- Current "sequential" pattern contradicts pair programming
- Should show pairing as primary strategy

**Current:**
```yaml
security_task:
  strategy: "security_first_then_fix"  # Sequential
```

**Should be:**
```yaml
security_task:
  strategy: "pair_programming"  # Real-time collaboration
  primary_pattern: "security + implementer pair"
  fallback_pattern: "security review then fix (rare)"
```

---

## Questions to Resolve

1. **DECISION_MATRICES → ARCHITECT_DECISIONS rename:** Proceed? ✓
2. **Add pair programming section:** What level of detail?
3. **Domain organization:** Keep flat structure + add domain index, or reorganize entirely?
4. **Rule #6 clarification:** Change "reviews everything" to "coordinates everything"?
5. **Skills coverage audit:** Should every skill have a rule, or are some "optional patterns"?

---

## Impact Analysis

### Renaming DECISION_MATRICES.yml
- **Files affected:** 2 references in agents/architect.md
- **Difficulty:** Low (find-replace)
- **Risk:** Low (internal file)
- **Benefit:** High (clarity)

### Adding Pair Programming Section
- **Files affected:** rules/ARCHITECT_DECISIONS.yml (or DECISION_MATRICES.yml)
- **Difficulty:** Medium (need to structure patterns)
- **Risk:** Low (additive change)
- **Benefit:** High (fills major gap, aligns with Phases 2-3)

### Domain Organization
- **Files affected:** TEAM_RULES.md, RULES_TO_SKILLS_MAPPING.yml
- **Difficulty:** Low (additive index)
- **Risk:** Low (don't remove existing structure)
- **Benefit:** Medium (easier navigation)

---

## Status

- [x] Audit DECISION_MATRICES.yml structure
- [x] Check pair programming coverage
- [x] Identify naming issues
- [ ] Verify skills coverage completeness
- [ ] Draft pair programming patterns
- [ ] Propose domain organization structure
- [ ] Get user approval for changes

---

## Next Steps

1. Get user feedback on findings
2. Prioritize which changes to implement
3. Draft pair programming patterns for ARCHITECT_DECISIONS.yml
4. Implement approved changes
5. Test with bin/ci
6. Update documentation
7. Commit changes

---

**Audit Status:** ✅ ANALYSIS COMPLETE, AWAITING USER DIRECTION
