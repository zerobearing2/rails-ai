# File Categorization for Variable Reduction

**Strategy:** Apply different reduction targets based on content type and criticality

---

## Tier 1: Core Teaching (20-25% reduction)
**Focus:** Preserve comprehensive quality - these are fundamental learning resources

### Security Skills (6 files) - CRITICAL
- security-xss.md
- security-sql-injection.md
- security-csrf.md
- security-strong-parameters.md
- security-file-uploads.md
- security-command-injection.md

**Rationale:** Security is non-negotiable, must remain comprehensive

### Core Backend Patterns (4 files) - FOUNDATIONAL
- activerecord-patterns.md (8,099 tokens)
- controller-restful.md
- form-objects.md
- query-objects.md

**Rationale:** These are fundamental Rails patterns that developers reference frequently

### Core Testing (2 files) - ENFORCED
- tdd-minitest.md
- fixtures-test-data.md

**Rationale:** TDD is team rule #2, must be comprehensive

**Tier 1 Total:** 12 files

---

## Tier 2: Standard Skills (25-30% reduction)
**Focus:** Balanced coverage - good depth, remove redundancy

### ViewComponent Skills (4 files)
- viewcomponent-basics.md
- viewcomponent-slots.md
- viewcomponent-previews.md
- viewcomponent-variants.md (7,202 tokens)

### Hotwire Skills (3 files)
- hotwire-turbo.md
- hotwire-stimulus.md
- turbo-page-refresh.md

### Backend Patterns (4 files)
- ✅ concerns-models.md (DONE: 5,511 tokens)
- concerns-controllers.md
- nested-resources.md
- antipattern-fat-controllers.md

### Testing Skills (3 files)
- minitest-mocking.md
- test-helpers.md
- viewcomponent-testing.md
- model-testing-advanced.md (8,699 tokens)

### Config Skills (4 files)
- solid-stack-setup.md
- docker-rails-setup.md
- credentials-management.md
- environment-configuration.md

### Other Backend (2 files)
- action-mailer.md
- custom-validators.md (6,777 tokens)

**Tier 2 Total:** 20 files (including 1 done)

---

## Tier 3: Component Catalogs & API References (33-50% reduction)
**Focus:** Lean quick-references - breadth over depth

### Frontend Component Libraries (3 files)
- ✅ daisyui-components.md (DONE: 4,399 tokens)
- tailwind-utility-first.md (7,903 tokens) - CSS utility catalog
- accessibility-patterns.md (9,105 tokens) - ARIA/WCAG reference

### Helper/View References (3 files)
- ✅ view-helpers.md (DONE: 6,220 tokens)
- partials-layouts.md (6,734 tokens)
- forms-nested.md (7,433 tokens)

### Config Reference (1 file)
- initializers-best-practices.md (7,837 tokens) - Configuration catalog

**Tier 3 Total:** 7 files (including 2 done)

---

## Already Optimized (3 files)
- ✅ view-helpers.md (6,220 tokens, -26%)
- ✅ concerns-models.md (5,511 tokens, -31%)
- ✅ daisyui-components.md (4,399 tokens, -50%)

**Remaining to optimize:** 37 files

---

## Token Targets by Tier

### Tier 1 (12 files) - 20-25% reduction
Estimated current: ~70,000 tokens
Target after: ~53,000 tokens
Savings: ~17,000 tokens

### Tier 2 (19 files, excluding 1 done) - 25-30% reduction
Estimated current: ~100,000 tokens
Target after: ~72,000 tokens
Savings: ~28,000 tokens

### Tier 3 (5 files, excluding 2 done) - 33-50% reduction
Estimated current: ~39,000 tokens
Target after: ~22,000 tokens
Savings: ~17,000 tokens

### Already Done (3 files)
Current: 16,130 tokens

---

## Projected Final Totals

**Starting point:** 223,575 tokens
**Target savings:** ~62,000 tokens
**Projected final:** ~147,000-152,000 tokens
**Budget:** 150,000 tokens
**Status:** ✅ Should meet budget with buffer

---

## Execution Order

**Phase 2A:** Tier 3 (Finish quick-references) - 5 files
**Phase 2B:** Tier 2 (Standard skills) - 19 files
**Phase 2C:** Tier 1 (Core teaching) - 12 files

**Rationale:** Start with most aggressive cuts, monitor results, adjust approach for core teaching if needed
