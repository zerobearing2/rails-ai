# Skills Optimization Plan (Revised)

**Status:** Planning Phase - Ready for Pilot
**Date:** 2025-10-31
**Authors:** Claude Code + Codex Review
**Current:** ~174,605 tokens (34,921 lines, 40 files)
**Target:** ~145,000 tokens (17% reduction)
**Estimated Savings:** ~29,600 tokens

---

## Executive Summary

This plan addresses Codex's concerns about the original 21% reduction target by adopting a **more pragmatic, risk-aware approach** that prioritizes:

1. **Self-contained skills** - No external references that break agent loading
2. **Direct optimization** - Condense verbose sections in-place
3. **Test compatibility** - Update unit tests alongside content changes
4. **Validation-first** - Pilot with 2 skills before scaling
5. **Actual token measurement** - Use tiktoken for accurate baselines

### Revised Strategy

Instead of extracting content to separate reference files (which risks agent effectiveness), we'll:
- **Condense verbose sections** using ellipses (`...`) for boilerplate
- **Reduce redundancy** directly in skill files (no external dependencies)
- **Update tests** alongside every content change
- Keep all skills self-contained and complete

---

## Key Risks Addressed (From Codex Review)

### ✅ Risk 1: Breaking Unit Tests
**Codex Concern:** Tests assert specific strings that would disappear with external references.

**Solution:**
- Update tests **before** or **alongside** content changes
- Pilot approach: Modify 2 skills + their tests, run `rake test:skills:unit`
- Only scale after validation

### ✅ Risk 2: Agent Loading Model
**Codex Concern:** Agents consume individual files; external references reduce effectiveness.

**Solution:**
- **No external references** - All optimizations done in-place
- Skills remain complete and self-contained
- No build step required
- Agents see complete, cohesive skills directly

### ✅ Risk 3: Inventory Drift
**Codex Concern:** AGENTS.md shows 33 skills, but we have 40 files.

**Solution:**
- Reconcile SKILLS_REGISTRY.yml (shows 40) with AGENTS.md (shows 33)
- Update documentation to reflect actual state
- Add this to Phase 0 (Pre-work)

### ✅ Risk 4: Token Estimation Accuracy
**Codex Concern:** Line-count heuristics may not match actual tokenization.

**Solution:**
- Measure with tiktoken (cl100k_base encoder)
- Create baseline report before any changes
- Track actual vs. estimated savings
- Add to CI as "token budget" report

---

## Phase 0: Pre-work & Validation (Week 1)

### 0.1 Reconcile Inventory
- [ ] Count actual skill files: `ls skills/**/*.md | wc -l`
- [ ] Validate SKILLS_REGISTRY.yml lists all 40 files
- [ ] Update AGENTS.md line 34 to reflect 40 skills (not 33)
- [ ] Document any missing/extra files

### 0.2 Measure Actual Tokens
- [ ] Install tiktoken: `pip install tiktoken`
- [ ] Create script: `bin/count_tokens`
  ```python
  import tiktoken
  import glob

  enc = tiktoken.get_encoding("cl100k_base")
  total = 0

  for file in glob.glob("skills/**/*.md", recursive=True):
      with open(file) as f:
          tokens = len(enc.encode(f.read()))
          total += tokens
          print(f"{file}: {tokens} tokens")

  print(f"\\nTotal: {total} tokens")
  ```
- [ ] Establish baseline: Record actual token count
- [ ] Compare with 174,605 line-based estimate
- [ ] Adjust savings targets based on actual numbers

### 0.3 Review Unit Test Structure
- [ ] Read test/skills/unit/turbo_page_refresh_test.rb (example test)
- [ ] Identify common assertions across all 40 test files
- [ ] Map which tests check for specific strings vs. patterns
- [ ] Create "test update checklist" for pilot

**Estimated Time:** 3-4 hours

---

## Phase 1: Pilot (Week 1-2)

### Goal
Validate the optimization approach on 2 skills (1 backend, 1 frontend) before scaling to all 40.

### 1.1 Select Pilot Skills

**Backend Pilot:** `backend/custom-validators.md`
- Current: 1103 lines (5,515 tokens)
- Has 7 validator examples (can reduce to 4)
- Verbose testing section
- **Target:** 850 lines (15% reduction)

**Frontend Pilot:** `frontend/forms-nested.md`
- Current: 1097 lines (5,485 tokens)
- Has Turbo integration duplication
- Extensive testing section
- **Target:** 900 lines (18% reduction)

### 1.2 Optimization Actions

For each pilot skill:

1. **Reduce testing section**
   - Keep 2-3 most important test examples
   - Use `...` to collapse repetitive setup
   - Focus on unique assertions for this pattern
   - **Before:** ~30-35% of file
   - **After:** ~15-20% of file

2. **Condense verbose examples**
   - Identify boilerplate setup code
   - Replace with `# ... (standard Rails setup)`
   - Keep the critical assertion/pattern
   - Example:
     ```ruby
     # ❌ Before (30 lines)
     class CustomValidatorTest < ActiveSupport::TestCase
       setup do
         @user = User.new
         @user.email = "test@example.com"
         # ... 25 more lines of setup
       end

       test "validates email format" do
         assert @user.valid?
       end
     end

     # ✅ After (8 lines)
     class CustomValidatorTest < ActiveSupport::TestCase
       test "validates email format" do
         user = User.new(email: "test@example.com")
         # ... (standard test setup)

         assert user.valid?
       end
     end
     ```

3. **Reduce antipattern examples**
   - custom-validators.md: 4 antipatterns → 2
   - forms-nested.md: 3 antipatterns → 2
   - Keep most common pitfalls only

4. **Remove obvious duplication**
   - forms-nested.md: Remove Turbo boilerplate (keep 1 reference)
   - custom-validators.md: Remove 3 of 7 validator types

### 1.3 Update Unit Tests

For each pilot skill's test file:

1. **Review assertions**
   - Read test/skills/unit/custom_validators_test.rb
   - Read test/skills/unit/forms_nested_test.rb
   - Identify which tests check specific strings

2. **Update or remove tests**
   - If test checks for removed content: Remove test
   - If test checks pattern (regex): May still pass
   - If test checks section exists: Should still pass

3. **Run tests**
   ```bash
   rake test:skills:unit TEST=test/skills/unit/custom_validators_test.rb
   rake test:skills:unit TEST=test/skills/unit/forms_nested_test.rb
   ```

4. **Fix failures**
   - Update test expectations
   - Ensure new content still validates

### 1.4 Measure Results

After pilot:
- [ ] Run `bin/count_tokens` on pilot files
- [ ] Compare actual vs. estimated savings
- [ ] Validate all tests pass
- [ ] Check skill files are still self-contained
- [ ] Review for clarity/completeness

**Success Criteria:**
- ✅ Tests pass
- ✅ 15-18% token reduction achieved
- ✅ Skills remain self-contained
- ✅ No loss of critical information
- ✅ Code examples still clear

**Estimated Time:** 6-8 hours

---

## Phase 2: Scale to All Skills (Week 2-3)

### 2.1 Prioritize by Token Savings

Apply optimizations in order of impact:

| Priority | Files | Est. Savings | Actions |
|----------|-------|--------------|---------|
| 1 | Top 10 largest | 12,000 tokens | Reduce tests, condense examples |
| 2 | Files with Turbo duplication | 3,000 tokens | Condense in-place |
| 3 | Files with strong params duplication | 1,600 tokens | Condense in-place |
| 4 | Remaining 28 files | 8,000 tokens | Minor condensing |

### 2.2 Batch Processing

Process in batches of 5 skills:
- Optimize 5 skills
- Update 5 test files
- Run tests
- Measure tokens
- Fix issues before next batch

**Top 10 Files to Optimize:**

1. **model-testing-advanced.md** (1413 lines → 1100, -313 lines)
2. **concerns-models.md** (1328 lines → 1100, -228 lines)
3. **activerecord-patterns.md** (1283 lines → 1050, -233 lines)
4. **viewcomponent-variants.md** (1176 lines → 950, -226 lines)
5. **initializers-best-practices.md** (1150 lines → 950, -200 lines)
6. **daisyui-components.md** (1075 lines → 900, -175 lines)
7. **viewcomponent-testing.md** (1063 lines → 900, -163 lines)
8. **antipattern-fat-controllers.md** (1028 lines → 850, -178 lines)
9. **view-helpers.md** (1354 lines → 1150, -204 lines)
10. **accessibility-patterns.md** (1242 lines → 1050, -192 lines)

**Total from Top 10:** 2,102 lines ≈ 10,500 tokens

### 2.3 Testing Strategy

For each batch:
1. Run full test suite: `rake test:skills:unit`
2. Fix failures immediately
3. Measure token reduction
4. Track actual vs. estimated

**Estimated Time:** 16-20 hours over 2 weeks

---

## Phase 3: Additional Optimizations (Week 4)

### 3.1 Style Guidelines

Create `docs/SKILLS_STYLE_GUIDE.md`:

**Bullet Count Caps:**
- `<when-to-use>`: Max 5 bullets
- `<benefits>`: Max 6 bullets
- `<standards>`: Max 8 bullets

**Code Sample Guidelines:**
- Use `...` for standard Rails setup
- Show only the pattern-specific code
- Include 1 complete example, then abbreviated examples

**Example:**
```ruby
# Pattern 1: Complete example
class UserValidator < ActiveModel::Validator
  def validate(record)
    # ... full implementation
  end
end

# Pattern 2: Abbreviated
class EmailValidator < ActiveModel::Validator
  # ... (standard validator setup)

  def validate(record)
    # Critical part only
    record.errors.add(:email, "invalid") unless email_valid?
  end
end
```

### 3.2 Automated Linting

Add to `bin/ci`:
```ruby
# Check token budget
current_tokens = `bin/count_tokens | tail -1`.match(/(\d+)/)[1].to_i
MAX_TOKENS = 150_000

if current_tokens > MAX_TOKENS
  puts "❌ Token budget exceeded: #{current_tokens} > #{MAX_TOKENS}"
  exit 1
end
```

**Estimated Time:** 4-6 hours

---

## Revised Token Targets

### By Domain

| Domain | Current | Target | Savings | % Reduction |
|--------|---------|--------|---------|-------------|
| Testing | 27,865 | 23,000 | -4,865 | -17% |
| Frontend | 58,270 | 49,000 | -9,270 | -16% |
| Backend | 50,475 | 42,000 | -8,475 | -17% |
| Security | 20,125 | 19,000 | -1,125 | -6% (minimal) |
| Config | 19,320 | 16,000 | -3,320 | -17% |
| **TOTAL** | **174,605** | **145,000** | **-29,605** | **-17%** |

### Conservative vs. Original

|  | Original Plan | Revised Plan | Difference |
|--|---------------|--------------|------------|
| **Approach** | External references | Direct condensing | Simpler |
| **Target Reduction** | 21% | 17% | -4% (safer) |
| **Risk Level** | High | Low | Lower |
| **Agent Impact** | May reduce effectiveness | No impact | Better |
| **Test Updates** | After the fact | Alongside changes | Synchronized |

---

## Files to Keep As-Is (7 files)

These are already optimized and should not be changed:

1. ✅ security-sql-injection.md (416 lines, 2,080 tokens)
2. ✅ security-xss.md (423 lines, 2,115 tokens)
3. ✅ controller-restful.md (478 lines, 2,390 tokens)
4. ✅ hotwire-stimulus.md (510 lines, 2,550 tokens)
5. ✅ hotwire-turbo.md (492 lines, 2,460 tokens)
6. ✅ viewcomponent-basics.md (351 lines, 1,755 tokens)
7. ✅ docker-rails-setup.md (345 lines, 1,725 tokens)

**Total:** 3,015 lines (15,075 tokens) - Already efficient

---

## Optimization Techniques (Codex-Approved)

### Technique 1: Ellipsis Condensing

**Before (50 lines):**
```ruby
class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference("Project.count") do
      post projects_url, params: { project: { name: "Test" } }
    end
    assert_redirected_to project_url(Project.last)
  end

  # ... 30 more lines
end
```

**After (20 lines):**
```ruby
class ProjectsControllerTest < ActionDispatch::IntegrationTest
  # ... (standard Rails test setup)

  test "should create project" do
    assert_difference("Project.count") do
      post projects_url, params: { project: { name: "Test" } }
    end
    assert_redirected_to project_url(Project.last)
  end

  # ... (additional CRUD tests)
end
```

**Savings:** 60% reduction with no information loss

### Technique 2: Focus on Unique Testing

**Before:**
```ruby
# test/controllers/projects_controller_test.rb (150 lines)
# - Full CRUD tests
# - Authentication tests
# - Authorization tests
# - Validation tests
# - Error handling tests
```

**After:**
```ruby
# test/controllers/projects_controller_test.rb (80 lines)
# - Pattern-specific tests only (nested resources)
# ... (unique tests for this pattern)
```

**Approach:**
- Keep 2-3 complete examples
- Use `...` for standard patterns
- Focus on what's unique about THIS skill
- Remove duplication between similar skills

---

## Success Metrics

### Quantitative
- [ ] Achieve 17% token reduction (145,000 tokens)
- [ ] All 40 unit tests pass
- [ ] Token budget report integrated

### Qualitative
- [ ] Skills remain self-contained (agent-friendly)
- [ ] No critical information lost
- [ ] Clarity maintained or improved
- [ ] Source files easier to maintain

### Validation Tests

After completion:
1. **Agent Effectiveness Test**
   - Run architect agent through 10 common tasks
   - Measure skill retrieval accuracy
   - Compare code quality before/after
   - Check for confusion or missing patterns

2. **Human Review**
   - Read 5 random optimized skills
   - Verify clarity and completeness
   - Check code examples work

3. **Token Budget**
   - Run `bin/count_tokens`
   - Verify 145,000 target met
   - Document actual savings

---

## Risk Mitigation

### Risk: Tests Fail After Optimization
**Mitigation:** Update tests alongside content changes in same commit

### Risk: Agents Less Effective
**Mitigation:** Keep skills self-contained, optimize in-place, no external references

### Risk: Information Loss
**Mitigation:** Pilot with 2 skills first, validate before scaling

### Risk: Token Estimate Inaccurate
**Mitigation:** Use tiktoken for actual measurement, adjust targets accordingly

### Risk: Duplication Returns
**Mitigation:** Add style guide and token budget check to prevent regression

---

## Timeline

| Week | Phase | Tasks | Hours | Milestone |
|------|-------|-------|-------|-----------|
| 1 | Phase 0 | Pre-work, inventory, token measurement | 4 | Baseline established |
| 1-2 | Phase 1 | Pilot 2 skills | 8 | Approach validated |
| 2-3 | Phase 2 | Scale to all 40 skills | 20 | All skills optimized |
| 4 | Phase 3 | Style guide, CI integration | 6 | Complete |
| **Total** | | | **38 hours** | 17% token reduction |

**Calendar Time:** 4 weeks (assuming ~10 hours/week)

---

## Implementation Checklist

### Week 1: Pre-work
- [ ] Reconcile SKILLS_REGISTRY.yml with actual files
- [ ] Update AGENTS.md to reflect 40 skills (not 33)
- [ ] Install tiktoken
- [ ] Create `bin/count_tokens` script
- [ ] Measure actual baseline tokens
- [ ] Adjust targets based on actual numbers

### Week 1-2: Pilot
- [ ] Optimize backend/custom-validators.md
- [ ] Update test/skills/unit/custom_validators_test.rb
- [ ] Run tests, fix failures
- [ ] Optimize frontend/forms-nested.md
- [ ] Update test/skills/unit/forms_nested_test.rb
- [ ] Run tests, fix failures
- [ ] Measure actual token savings
- [ ] Validate approach successful

### Week 2-3: Scale
- [ ] Batch 1: Top 5 files (optimize + test)
- [ ] Batch 2: Next 5 files
- [ ] Batch 3: Files with Turbo duplication
- [ ] Batch 4: Files with strong params duplication
- [ ] Batch 5-8: Remaining 20 files
- [ ] Run full test suite
- [ ] Measure final token count

### Week 4: Finalize
- [ ] Create docs/SKILLS_STYLE_GUIDE.md
- [ ] Add token budget check to CI
- [ ] Update documentation
- [ ] Run final validation tests
- [ ] Document actual savings
- [ ] Create before/after report

---

## Appendix A: Codex Recommendations Implemented

| Recommendation | Status | Implementation |
|----------------|--------|----------------|
| Style guideline with bullet caps | ✅ Implemented | Phase 3: SKILLS_STYLE_GUIDE.md |
| Token budget report in CI | ✅ Implemented | Phase 3: bin/ci check |
| Pilot with 2 skills first | ✅ Implemented | Phase 1: custom-validators + forms-nested |
| Update tests alongside content | ✅ Implemented | All phases require test updates |
| Use tiktoken for measurement | ✅ Implemented | Phase 0: bin/count_tokens |
| Reconcile inventory drift | ✅ Implemented | Phase 0: Update AGENTS.md |
| Keep skills self-contained | ✅ Implemented | Direct in-place optimization |

---

## Appendix B: Rejected Approaches (From Original Plan)

### ❌ External Reference Files
**Original:** Create `testing/testing-patterns-reference.md` and link from skills

**Why Rejected:**
- Agents load individual skill files
- External links reduce agent effectiveness
- Breaks self-contained principle
- Codex identified as high risk

**Alternative:** Direct in-place condensing

### ❌ "See Reference Guide" Links
**Original:** Replace content with "See: hotwire-integration-cookbook.md#form-submission"

**Why Rejected:**
- Tests assert specific strings
- Would require extensive test refactoring
- Agents wouldn't see complete skills
- High risk, low benefit

**Alternative:** Direct in-place condensing

### ❌ Build-Time Snippet Injection
**Original:** Create build system with snippet library and injection script

**Why Rejected:**
- Adds complexity for little value (per user feedback)
- Requires maintaining build system
- Source and published files diverge
- Extra CI overhead

**Alternative:** Direct in-place condensing (simpler, same result)

### ❌ 21% Reduction Target
**Original:** Aggressive 36,600 token reduction

**Why Adjusted:**
- Too risky without validation
- Based on line-count heuristics
- Didn't account for test compatibility
- Codex recommended more conservative approach

**Alternative:** 17% reduction (29,600 tokens) with pilot validation

---

## Appendix C: Token Measurement Script

Create `bin/count_tokens`:

```python
#!/usr/bin/env python3
"""
Count tokens in skills/ directory using tiktoken (cl100k_base)
Usage: bin/count_tokens
"""

import tiktoken
import glob
import sys

def count_tokens_in_file(filepath, encoding):
    """Count tokens in a single file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            tokens = len(encoding.encode(content))
            return tokens
    except Exception as e:
        print(f"Error reading {filepath}: {e}", file=sys.stderr)
        return 0

def main():
    # Use cl100k_base (GPT-4/Claude encoding)
    enc = tiktoken.get_encoding("cl100k_base")

    # Find all skill files
    skill_files = sorted(glob.glob("skills/**/*.md", recursive=True))

    # Exclude special files
    skill_files = [f for f in skill_files if not f.endswith("SKILLS_REGISTRY.yml")]

    total_tokens = 0
    file_counts = []

    print("Token Count Report")
    print("=" * 70)

    for filepath in skill_files:
        tokens = count_tokens_in_file(filepath, enc)
        total_tokens += tokens
        file_counts.append((filepath, tokens))

    # Sort by token count (descending)
    file_counts.sort(key=lambda x: x[1], reverse=True)

    # Print top 10
    print("\nTop 10 Largest Files:")
    print("-" * 70)
    for filepath, tokens in file_counts[:10]:
        print(f"{tokens:>6} tokens  {filepath}")

    # Print summary
    print("\n" + "=" * 70)
    print(f"Total files: {len(skill_files)}")
    print(f"Total tokens: {total_tokens:,}")
    print(f"Average per file: {total_tokens // len(skill_files):,}")
    print("=" * 70)

    # Check against budget
    MAX_TOKENS = 150_000
    if total_tokens > MAX_TOKENS:
        print(f"\n⚠️  Warning: Exceeds token budget by {total_tokens - MAX_TOKENS:,} tokens")
        sys.exit(1)
    else:
        print(f"\n✅ Within token budget ({MAX_TOKENS - total_tokens:,} tokens remaining)")
        sys.exit(0)

if __name__ == "__main__":
    main()
```

Make executable:
```bash
chmod +x bin/count_tokens
```

---

## Questions for Review

1. **Pilot Skills:** Agree with custom-validators.md + forms-nested.md for pilot?
2. **Token Target:** Is 17% reduction (145,000 tokens) appropriate?
3. **Timeline:** 4 weeks realistic? Need to adjust?
4. **Test Strategy:** Update tests alongside content, or update all tests at end?

---

## Next Steps

1. **Approve this plan** ← You are here
2. **Run Phase 0** (Pre-work: inventory, tokens, baseline)
3. **Execute Phase 1** (Pilot with 2 skills)
4. **Review pilot results** (Did tests pass? Token savings achieved?)
5. **Decide:** Continue to Phase 2 (Scale) or adjust approach

---

**End of Optimization Plan (Revised)**
