# Skills Optimization Summary

**Quick Reference Guide for Token Reduction Through Delegation**

---

## TL;DR

- **Current Waste:** 50,688 tokens (20% of system context)
- **Optimization Potential:** 29,316 tokens (58% of waste)
- **Primary Strategy:** Delegate security & testing to specialized agents
- **Implementation:** 4-phase rollout over 4 weeks

---

## Top 5 High-Impact Changes

### 1. Remove All Security Skills from @backend
**Savings:** 10,217 tokens (15.5% of agent context)
**Skills:** security-sql-injection, security-xss, security-csrf, security-strong-parameters, security-command-injection, security-file-uploads
**Rationale:** @security owns security auditing; @backend implements per patterns
**Implementation:** Update `agents/backend.md`, add delegation pattern to @architect

---

### 2. Remove All Security Skills from @frontend
**Savings:** 7,104 tokens (13.3% of agent context)
**Skills:** security-xss, security-csrf, security-strong-parameters, security-file-uploads
**Rationale:** Rails provides automatic XSS/CSRF protection; @security audits compliance
**Implementation:** Update `agents/frontend.md`, add delegation pattern to @architect

---

### 3. Remove Testing Skills from @backend and @frontend
**Savings:** 4,622 tokens combined
**Skills:** tdd-minitest (both), fixtures-test-data (frontend only)
**Rationale:** TDD principles in TEAM_RULES.md; @tests reviews test quality
**Implementation:** Update both agent files, add peer review coordination

---

### 4. Convert Backend Skills to Dynamic for @security
**Savings:** 4,164 tokens (10.4% of agent context)
**Skills:** activerecord-patterns → dynamic, credentials-management → dynamic
**Rationale:** Most security audits focus on specific vulnerabilities, not full patterns
**Implementation:** Update `agents/security.md` with "When to Load" sections

---

### 5. Convert Refactoring Skill to Dynamic for @debug
**Savings:** 2,129 tokens (7.6% of agent context)
**Skills:** antipattern-fat-controllers → dynamic
**Rationale:** Debugging focuses on reproduction first, refactoring second
**Implementation:** Update `agents/debug.md` with dynamic loading pattern

---

## Agent-Specific Recommendations

### @backend (Current: 74,852 tokens)
```
REMOVE:
  ❌ All 6 security-* skills      → Delegate to @security
  ❌ tdd-minitest skill           → Delegate to @tests

RESULT: 63,278 tokens (15.5% reduction)
```

### @frontend (Current: 53,214 tokens)
```
REMOVE:
  ❌ All 4 security-* skills      → Delegate to @security
  ❌ fixtures-test-data           → Delegate to @tests
  ❌ tdd-minitest                 → Delegate to @tests

DYNAMIC:
  ⚠️ controller-restful           → Load only when building forms

RESULT: 41,729 tokens (21.6% reduction)
```

### @security (Current: 39,942 tokens)
```
DYNAMIC:
  ⚠️ activerecord-patterns        → Load for complex model audits
  ⚠️ credentials-management       → Load for secrets audits

RESULT: 35,778 tokens (10.4% reduction)
```

### @debug (Current: ~28,000 tokens)
```
DYNAMIC:
  ⚠️ antipattern-fat-controllers  → Load when refactoring needed

RESULT: ~25,871 tokens (7.6% reduction)
```

### @tests (Current: ~12,000 tokens)
```
NO CHANGES
All testing skills are core to primary responsibility
```

---

## Skill Overlap Matrix (Top 10 Most Duplicated)

| Skill                      | Loaded By               | Times | Wasted Tokens |
|----------------------------|-------------------------|-------|---------------|
| tdd-minitest               | 4 agents                | 4×    | 4,071         |
| activerecord-patterns      | backend, security, debug| 3×    | 5,682         |
| security-file-uploads      | backend, frontend, sec  | 3×    | 4,802         |
| security-csrf              | backend, frontend, sec  | 3×    | 3,822         |
| minitest-mocking           | security, debug, tests  | 3×    | 4,206         |
| viewcomponent-testing      | frontend, debug, tests  | 3×    | 4,398         |
| fixtures-test-data         | frontend, debug, tests  | 3×    | 3,816         |
| security-strong-parameters | backend, frontend, sec  | 3×    | 3,412         |
| model-testing-advanced     | debug, tests            | 2×    | 2,930         |
| security-xss               | backend, frontend, sec  | 3×    | 2,172         |

**Total from Top 10:** 39,311 tokens (78% of all waste)

---

## Implementation Priorities

### Phase 1: Security Delegation (Week 1) - LOW RISK
```
✅ Remove 6 security skills from @backend
✅ Remove 4 security skills from @frontend
✅ Update @architect coordination patterns

Expected Savings: 17,321 tokens (34% of waste)
Risk: Low - Clear delegation, automatic Rails protections
```

### Phase 2: Testing Delegation (Week 2) - LOW RISK
```
✅ Remove tdd-minitest from @backend
✅ Remove tdd-minitest + fixtures-test-data from @frontend
✅ Update @tests peer review patterns

Expected Savings: 4,622 tokens (9% of waste)
Risk: Low - TDD principles remain in TEAM_RULES.md
```

### Phase 3: Dynamic Conversion (Week 3) - MEDIUM RISK
```
⚠️ Convert activerecord-patterns to dynamic (@security)
⚠️ Convert credentials-management to dynamic (@security)
⚠️ Convert controller-restful to dynamic (@frontend)
⚠️ Convert antipattern-fat-controllers to dynamic (@debug)

Expected Savings: 7,409 tokens (15% of waste)
Risk: Medium - Monitor loading frequency, adjust if >30%
```

### Phase 4: Monitor & Adjust (Week 4)
```
📊 Track metrics: token usage, coordination overhead, loading frequency
📊 Identify bottlenecks in delegation patterns
📊 Adjust dynamic loading thresholds
📊 Document lessons learned

Success Criteria:
  - Total savings: 29,316 tokens (58% of waste)
  - Coordination overhead: <10% increase
  - Development velocity: maintained or improved
```

---

## Coordination Patterns

### Security Review Workflow
```
[Feature Request]
    ↓
@backend implements (no security skills)
    ↓
@architect triggers security review
    ↓
@security audits for vulnerabilities
    ↓
@backend fixes issues
    ↓
@security verifies
    ↓
[Complete]
```

### Test Quality Review Workflow
```
[Feature Request]
    ↓
@backend/@frontend writes tests
    ↓
@architect triggers test review
    ↓
@tests reviews quality & coverage
    ↓
@backend/@frontend improves
    ↓
@tests verifies
    ↓
[Complete]
```

### Dynamic Loading Workflow
```
[Agent receives task]
    ↓
Check "When to Load" criteria
    ↓
If match: Load skill (fast - single file)
    ↓
Apply patterns
    ↓
[Complete]
```

---

## Expected Outcomes

### Token Reduction
```
Before:  253,972 tokens total
After:   224,656 tokens total
Savings:  29,316 tokens (11.5%)

Remaining Waste: 21,372 tokens (necessary duplication)
```

### Per-Agent Impact
```
@backend:  74,852 → 63,278 (-15.5%)
@frontend: 53,214 → 41,729 (-21.6%)
@security: 39,942 → 35,778 (-10.4%)
@debug:    28,000 → 25,871 (-7.6%)
@tests:    12,000 → 12,000 (no change)
```

### Quality Impact
```
✅ Security: Improved (specialized agent reviews all)
✅ Testing: Improved (dedicated agent ensures standards)
✅ Coordination: Slight increase (10% overhead)
✅ Velocity: Maintained (clear delegation patterns)
```

---

## Risk Mitigation

### Low-Risk Changes (Implement First)
- Security delegation (Rails automatic protections exist)
- Testing delegation (TDD in TEAM_RULES.md)
- Clear rollback path (re-add skills if needed)

### Medium-Risk Changes (Monitor Closely)
- Dynamic loading (track frequency)
- Adjust thresholds if loaded >30% of time
- Pre-load again if causing friction

### Monitoring Metrics
1. Token usage per agent (before/after)
2. Coordination overhead (time to complete tasks)
3. Dynamic load frequency (% of tasks needing skill)
4. Code quality (security vulnerabilities, test coverage)

---

## Quick Reference: What to Remove

### From @backend
```yaml
remove:
  - security-sql-injection
  - security-xss
  - security-csrf
  - security-strong-parameters
  - security-command-injection
  - security-file-uploads
  - tdd-minitest

add_to_dynamic:
  - "Load security-* when coordinating with @security"
  - "Load tdd-minitest when needing methodology details"
```

### From @frontend
```yaml
remove:
  - security-xss
  - security-csrf
  - security-strong-parameters
  - security-file-uploads
  - fixtures-test-data
  - tdd-minitest

add_to_dynamic:
  - "Load security-* when coordinating with @security"
  - "Load testing skills when coordinating with @tests"
  - "Load controller-restful when building forms"
```

### From @security
```yaml
convert_to_dynamic:
  - activerecord-patterns: "Load when auditing complex models"
  - credentials-management: "Load when auditing secrets"
```

### From @debug
```yaml
convert_to_dynamic:
  - antipattern-fat-controllers: "Load when refactoring needed"
```

---

## Files to Update

1. `/home/dave/Projects/rails-ai/agents/backend.md`
   - Remove security and testing skills
   - Add "When to Load More Skills" section
   - Add delegation patterns

2. `/home/dave/Projects/rails-ai/agents/frontend.md`
   - Remove security and testing skills
   - Convert controller-restful to dynamic
   - Add delegation patterns

3. `/home/dave/Projects/rails-ai/agents/security.md`
   - Convert 2 backend skills to dynamic
   - Add "When to Load" sections

4. `/home/dave/Projects/rails-ai/agents/debug.md`
   - Convert antipattern skill to dynamic
   - Add "When to Load" section

5. `/home/dave/Projects/rails-ai/agents/architect.md`
   - Add security review coordination pattern
   - Add test quality review coordination pattern

---

## Success Criteria

### Week 1 (Phase 1)
- [ ] Security skills removed from @backend and @frontend
- [ ] @architect coordination pattern working smoothly
- [ ] No security vulnerabilities introduced
- [ ] Token savings verified: ~17,300 tokens

### Week 2 (Phase 2)
- [ ] Testing skills removed/delegated
- [ ] @tests peer review pattern working
- [ ] Test coverage remains >85%
- [ ] Token savings verified: ~4,600 tokens

### Week 3 (Phase 3)
- [ ] Dynamic loading patterns implemented
- [ ] Loading frequency <30% for all dynamic skills
- [ ] No development velocity impact
- [ ] Token savings verified: ~7,400 tokens

### Week 4 (Phase 4)
- [ ] Total savings achieved: ~29,300 tokens
- [ ] System context reduced to ~224,656 tokens
- [ ] No degradation in code quality
- [ ] Documentation complete

---

## Next Steps

1. **Review Analysis:** Verify findings and recommendations
2. **Approve Plan:** Get sign-off on phased rollout
3. **Start Phase 1:** Implement security delegation (lowest risk)
4. **Monitor Metrics:** Track token usage, coordination overhead
5. **Iterate:** Adjust based on real-world usage patterns

---

**For detailed analysis, see:** `SKILL_LOADING_ANALYSIS.md`
