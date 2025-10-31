# Skills Optimization - Current Status

**Branch:** `feature/skills-optimization`
**Status:** Ready to start Phase 0
**Last Updated:** 2025-10-31

---

## Quick Start

Ready to begin skills optimization! Start with:

```bash
# 1. Ensure on correct branch
git checkout feature/skills-optimization

# 2. Read the plan
cat docs/SKILLS_OPTIMIZE_PLAN.md

# 3. Begin Phase 0 (Pre-work)
# See checklist below
```

---

## Current State

### What's Done
✅ Comprehensive optimization plan created (`docs/SKILLS_OPTIMIZE_PLAN.md`)
✅ Feature branch created (`feature/skills-optimization`)
✅ Plan committed (d5dc9e1)
✅ Codex feedback incorporated
✅ Build system complexity removed (keeping it simple)

### What's Next
📋 **Phase 0: Pre-work & Validation** (3-4 hours)

---

## Phase 0 Checklist

### 0.1 Reconcile Inventory
- [ ] Count actual skill files: `find skills -name "*.md" -type f | wc -l`
- [ ] Validate SKILLS_REGISTRY.yml lists all files
- [ ] Check AGENTS.md line 34 (says 33 skills, but we have 40)
- [ ] Document any discrepancies

### 0.2 Measure Actual Tokens
- [ ] Install tiktoken: `pip install tiktoken`
- [ ] Create `bin/count_tokens` script (from plan Appendix C)
- [ ] Make executable: `chmod +x bin/count_tokens`
- [ ] Run baseline: `bin/count_tokens > baseline_tokens.txt`
- [ ] Record actual token count (compare with ~174,605 estimate)
- [ ] Adjust targets if needed

### 0.3 Review Unit Test Structure
- [ ] Read `test/skills/unit/turbo_page_refresh_test.rb` (example)
- [ ] Identify common assertion patterns
- [ ] Map string-specific vs. pattern-based tests
- [ ] Create "test update checklist" for pilot

### 0.4 Document Baseline
- [ ] Commit baseline measurements
- [ ] Update this status file with findings

---

## Key Numbers

| Metric | Current (Estimate) | Target | Reduction |
|--------|-------------------|--------|-----------|
| Total Tokens | ~174,605 | 145,000 | -29,605 (-17%) |
| Total Lines | 34,921 | 27,600 | -7,321 |
| Avg per File | 873 lines | 690 lines | -183 |
| Files | 40 | 40 | 0 |

---

## Optimization Approach

### What We're Doing
1. **Condense testing sections** - Reduce from 30-35% to 15-20% of file
2. **Use ellipsis** - Replace boilerplate with `# ... (standard setup)`
3. **Reduce antipatterns** - Keep 2-3 most important, remove others
4. **Remove duplication** - Condense repeated patterns in-place
5. **Focus on unique content** - Each skill shows only what's unique to it

### What We're NOT Doing
❌ External reference files (breaks agent loading)
❌ Build system / snippet injection (complexity)
❌ Removing critical information
❌ Making skills interdependent

### Files to Keep As-Is (Already Optimal)
- security-sql-injection.md (416 lines)
- security-xss.md (423 lines)
- controller-restful.md (478 lines)
- hotwire-stimulus.md (510 lines)
- hotwire-turbo.md (492 lines)
- viewcomponent-basics.md (351 lines)
- docker-rails-setup.md (345 lines)

---

## Pilot Skills (Phase 1)

**Backend:** `backend/custom-validators.md`
- Current: 1103 lines
- Target: 850 lines (-23%)
- Why: Has 7 validator examples (reduce to 4), verbose testing

**Frontend:** `frontend/forms-nested.md`
- Current: 1097 lines
- Target: 900 lines (-18%)
- Why: Turbo duplication, extensive testing section

---

## Timeline

| Phase | Duration | Hours | Deliverable |
|-------|----------|-------|-------------|
| Phase 0 | Week 1 | 4 | Baseline established |
| Phase 1 | Week 1-2 | 8 | 2 skills optimized, approach validated |
| Phase 2 | Week 2-3 | 20 | All 40 skills optimized |
| Phase 3 | Week 4 | 6 | Style guide, CI checks |
| **Total** | **4 weeks** | **38 hours** | **17% token reduction** |

---

## Success Criteria

### Must Pass
- [ ] All 40 unit tests pass after optimization
- [ ] Token count ≤ 145,000
- [ ] No critical information removed
- [ ] Skills remain self-contained

### Validation
- [ ] Pilot successful (tests pass, tokens reduced)
- [ ] Sample agent tasks work correctly
- [ ] Human review confirms clarity maintained

---

## Important Files

- **Plan:** `docs/SKILLS_OPTIMIZE_PLAN.md` (full detailed plan)
- **Status:** `docs/SKILLS_OPTIMIZE_STATUS.md` (this file)
- **Skills:** `skills/**/*.md` (40 files to optimize)
- **Tests:** `test/skills/unit/**/*_test.rb` (40 test files)
- **Registry:** `skills/SKILLS_REGISTRY.yml`

---

## Commands Reference

```bash
# Count skills
find skills -name "*.md" -type f | wc -l

# Count tokens (after creating script)
bin/count_tokens

# Run skill tests
rake test:skills:unit

# Run specific test
rake test:skills:unit TEST=test/skills/unit/custom_validators_test.rb

# Check branch
git branch

# View plan
cat docs/SKILLS_OPTIMIZE_PLAN.md | less
```

---

## Notes for Fresh Context

When resuming work:

1. **Read this file first** to understand current state
2. **Check Phase 0 checklist** to see what's next
3. **Review plan** at `docs/SKILLS_OPTIMIZE_PLAN.md` for details
4. **Start with inventory** reconciliation (easy first step)

The plan is conservative, pilot-validated, and addresses all Codex concerns. We're optimizing in-place with no build system complexity.

---

**Ready to start Phase 0!** 🚀
