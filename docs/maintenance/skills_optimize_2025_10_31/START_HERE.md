# Skills Optimization - Start Here

**Branch:** `feature/skills-optimization`
**Ready to begin:** Phase 0 (Pre-work & Validation)

---

## 📋 What You Need to Know

You're starting a **4-week skills optimization project** to reduce token count by 17% (from ~175k to ~145k tokens) across 40 skill files.

The plan is **conservative**, **pilot-validated**, and addresses all Codex concerns.

---

## 🚀 Quick Start (1 minute)

```bash
# 1. Verify you're on the right branch
git branch
# Should show: * feature/skills-optimization

# 2. Read the status file for current state
cat docs/SKILLS_OPTIMIZE_STATUS.md

# 3. Read the full plan for details
cat docs/SKILLS_OPTIMIZE_PLAN.md
```

---

## ✅ What's Already Done

1. ✅ **Comprehensive plan created** (docs/SKILLS_OPTIMIZE_PLAN.md)
2. ✅ **Feature branch created** (feature/skills-optimization)
3. ✅ **Status tracker created** (docs/SKILLS_OPTIMIZE_STATUS.md)
4. ✅ **Codex feedback incorporated**
5. ✅ **Build system removed** (keeping it simple - direct optimization)

---

## 📝 Phase 0 Checklist (Start Here!)

**Estimated time:** 3-4 hours

### 0.1 Reconcile Inventory (30 min)
```bash
# Count actual skills
find skills -name "*.md" -type f | wc -l

# Check AGENTS.md line 34 (says 33, but we have 40?)
grep -n "33 modular skills" AGENTS.md

# Validate SKILLS_REGISTRY.yml
cat skills/SKILLS_REGISTRY.yml
```

### 0.2 Measure Actual Tokens (1 hour)
```bash
# Install tiktoken
pip install tiktoken

# Create bin/count_tokens script
# (Script is in docs/SKILLS_OPTIMIZE_PLAN.md Appendix C)

# Make executable
chmod +x bin/count_tokens

# Run baseline
bin/count_tokens > baseline_tokens.txt
cat baseline_tokens.txt
```

### 0.3 Review Test Structure (1 hour)
```bash
# Read example test
cat test/skills/unit/turbo_page_refresh_test.rb

# Identify patterns across all tests
ls test/skills/unit/*.rb | head -5 | xargs grep -l "assert_pattern_present"
```

### 0.4 Document Findings (30 min)
```bash
# Commit baseline
git add baseline_tokens.txt
git commit -m "Add baseline token measurements"

# Update status file with findings
# (Edit docs/SKILLS_OPTIMIZE_STATUS.md)
```

---

## 🎯 Key Metrics

| Metric | Current | Target | Change |
|--------|---------|--------|--------|
| Tokens | ~174,605 | 145,000 | -17% |
| Lines | 34,921 | 27,600 | -21% |
| Files | 40 | 40 | 0 |

---

## 🛠️ Approach Summary

**What we're doing:**
- Condense testing sections (30% → 15% of files)
- Use `...` for boilerplate code
- Remove verbose antipatterns
- Keep 2-3 focused examples per pattern

**What we're NOT doing:**
- ❌ External references (breaks agents)
- ❌ Build systems (too complex)
- ❌ Removing critical info
- ❌ Making skills interdependent

---

## 📚 Important Files

| File | Purpose |
|------|---------|
| `docs/SKILLS_OPTIMIZE_PLAN.md` | Full detailed plan (716 lines) |
| `docs/SKILLS_OPTIMIZE_STATUS.md` | Current status & checklists |
| `START_HERE.md` | This file (quick start guide) |
| `skills/**/*.md` | 40 skill files to optimize |
| `test/skills/unit/*.rb` | 40 test files to update |

---

## 🔍 Next Actions

1. **Read** `docs/SKILLS_OPTIMIZE_STATUS.md` (5 min)
2. **Start** Phase 0.1 (inventory reconciliation)
3. **Install** tiktoken and create counting script
4. **Run** baseline measurements
5. **Commit** findings

---

## 💡 Tips for Fresh Context

- Start with the **status file** for current state
- The **plan file** has all the details
- Phase 0 is just **pre-work** - no optimization yet
- We **pilot with 2 skills** before scaling (Phase 1)
- All **tests must pass** at every stage

---

## 📞 Need Help?

- Full plan: `docs/SKILLS_OPTIMIZE_PLAN.md`
- Status tracker: `docs/SKILLS_OPTIMIZE_STATUS.md`
- Original analysis: Removed (consolidated into plan)

---

**Ready to optimize! Start with Phase 0.1** 🎉
