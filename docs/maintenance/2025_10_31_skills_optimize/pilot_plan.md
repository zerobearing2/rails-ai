# Phase 1 Pilot Plan - Three-Tier Optimization Test

**Date:** 2025-10-31
**Branch:** feature/skills-optimization
**Goal:** Test 3 different reduction targets to determine optimal approach

---

## Pilot Skills Selected

| # | Skill | Domain | Lines | Tokens | Target Tokens | Reduction | Rationale |
|---|-------|--------|-------|--------|---------------|-----------|-----------|
| 1 | view-helpers.md | Frontend | 1,354 | 8,401 | 6,721 | -20% | Moderate - lots of built-in Rails examples |
| 2 | concerns-models.md | Backend | 1,328 | 8,028 | 6,021 | -25% | Balanced - pattern-based content |
| 3 | daisyui-components.md | Frontend | 1,075 | 8,760 | 5,870 | -33% | Aggressive - component library reference |

**Total Impact:**
- Combined current: 24,189 tokens (11% of total)
- Combined target: 18,612 tokens
- Pilot savings: 5,577 tokens

---

## Optimization Strategy Per Pilot

### Pilot #1: view-helpers.md (-20% = 1,680 tokens)

**Current structure analysis needed:**
- Built-in Rails helpers section (likely verbose)
- Custom helper examples
- Testing section
- Antipatterns

**Optimization approach:**
- Reduce built-in helper examples from ~8 to ~5
- Condense testing section (likely 200+ lines → 100 lines)
- Keep all custom helper patterns (core value)
- Reduce antipatterns from ~5 to ~3

**Risk:** Low - lots of redundant built-in Rails API examples

---

### Pilot #2: concerns-models.md (-25% = 2,007 tokens)

**Current structure analysis needed:**
- ActiveSupport::Concern pattern
- Multiple concern examples
- Testing section
- Antipatterns

**Optimization approach:**
- Reduce concern examples from ~5 to ~3
- Aggressive testing section compression (200+ → 80 lines)
- Use `# ... (standard setup)` in boilerplate
- Keep core ActiveSupport::Concern mechanics
- Reduce antipatterns

**Risk:** Medium - need to preserve enough examples to show pattern variety

---

### Pilot #3: daisyui-components.md (-33% = 2,890 tokens)

**Current structure analysis needed:**
- DaisyUI component catalog
- Component variants
- Theming examples
- Integration with ViewComponents

**Optimization approach:**
- Reduce component examples from full catalog to most-used (~15 → ~10)
- Aggressive variant reduction (show 1-2 variants per component, not all)
- Compress theming section significantly
- Minimal testing section (~50 lines)
- Remove or heavily compress antipatterns

**Risk:** High - may lose valuable component reference material

---

## Success Criteria

### Must Pass (All Pilots)
- [ ] Unit tests pass (`rake test:skills:unit TEST=test/skills/unit/<skill>_test.rb`)
- [ ] YAML front matter valid
- [ ] All required sections present (`<when-to-use>`, `<benefits>`, `<standards>`, etc.)
- [ ] Code examples are complete and valid
- [ ] No critical information removed

### Quality Assessment (Manual Review)
- [ ] **Pilot #1 (20%)**: Still comprehensive? Good teaching quality?
- [ ] **Pilot #2 (25%)**: Acceptable trade-off? Missing critical patterns?
- [ ] **Pilot #3 (33%)**: Too aggressive? Lost essential content?

---

## Execution Plan

### Step 1: Baseline Measurement
```bash
# Save individual baselines
echo "=== view-helpers.md ===" > pilot_baseline.txt
./bin/count_tokens 2>&1 | grep view-helpers >> pilot_baseline.txt
echo "=== concerns-models.md ===" >> pilot_baseline.txt
./bin/count_tokens 2>&1 | grep concerns-models >> pilot_baseline.txt
echo "=== daisyui-components.md ===" >> pilot_baseline.txt
./bin/count_tokens 2>&1 | grep daisyui-components >> pilot_baseline.txt
```

### Step 2: Optimize Each Skill
1. Create backup: `cp skills/frontend/view-helpers.md skills/frontend/view-helpers.md.backup`
2. Optimize content to target
3. Measure tokens: `./bin/count_tokens 2>&1 | grep view-helpers`
4. Run tests: `rake test:skills:unit TEST=test/skills/unit/view_helpers_test.rb`
5. Manual review
6. Repeat for other 2 pilots

### Step 3: Comparison & Decision
```bash
# Generate comparison report
./bin/count_tokens 2>&1 | grep -E "view-helpers|concerns-models|daisyui-components" > pilot_results.txt
```

Review side-by-side:
- Token savings achieved
- Quality retained
- Information density
- Teaching effectiveness

### Step 4: Choose Path Forward
Based on pilot results, decide:
- **Option A**: 20% reduction (if 20% pilot looks great, 25%/33% too aggressive)
- **Option B**: 25% reduction (if 25% pilot is sweet spot)
- **Option C**: 33% reduction (if all 3 pilots maintain quality)
- **Option D**: Variable reduction (different targets for different skill types)

---

## Timeline

| Task | Time | Status |
|------|------|--------|
| Select pilots | 15 min | ✅ DONE |
| Analyze current structure | 30 min | PENDING |
| Optimize pilot #1 (20%) | 45 min | PENDING |
| Optimize pilot #2 (25%) | 60 min | PENDING |
| Optimize pilot #3 (33%) | 75 min | PENDING |
| Run tests & review | 30 min | PENDING |
| Decision & documentation | 20 min | PENDING |
| **Total** | **~4 hours** | - |

---

## Tracking

### Pilot #1: view-helpers.md (20% reduction)
- [ ] Backup created
- [ ] Current structure analyzed
- [ ] Content optimized
- [ ] Token target met (≤6,721)
- [ ] Tests passing
- [ ] Manual quality review
- [ ] Notes documented

### Pilot #2: concerns-models.md (25% reduction)
- [ ] Backup created
- [ ] Current structure analyzed
- [ ] Content optimized
- [ ] Token target met (≤6,021)
- [ ] Tests passing
- [ ] Manual quality review
- [ ] Notes documented

### Pilot #3: daisyui-components.md (33% reduction)
- [ ] Backup created
- [ ] Current structure analyzed
- [ ] Content optimized
- [ ] Token target met (≤5,870)
- [ ] Tests passing
- [ ] Manual quality review
- [ ] Notes documented

---

## Notes & Learnings

### What Worked Well
(To be filled during pilot execution)

### What Was Challenging
(To be filled during pilot execution)

### Unexpected Findings
(To be filled during pilot execution)

---

**Status:** Ready to begin
**Next Step:** Analyze current structure of all 3 pilot files
