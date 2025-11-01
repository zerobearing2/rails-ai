# TEAM_RULES.md → YML Conversion Analysis

**Date:** 2025-11-01
**Question:** Should TEAM_RULES.md be converted to YAML format?

---

## Current State: TEAM_RULES.md

**Format:** Markdown with embedded YAML and XML tags
**Lines:** 799
**Structure:**
- YAML front matter (metadata)
- Quick lookup YAML block
- Domain index (markdown)
- 19 detailed rule sections (markdown with XML tags)
- Enforcement strategy (markdown)
- Quick reference tables

**Example Structure:**
```markdown
---
name: TEAM_RULES
type: enforcement_rules
---

<quick-lookup>
## Quick Rule Lookup (Machine-Readable)
```yaml
rule_index:
  1: {name: "Solid Stack Only", severity: critical}
```
</quick-lookup>

<rule id="1" priority="critical">
### 1. Solid Stack Only

<violation-triggers>
Keywords: sidekiq, redis, memcached
</violation-triggers>

✅ **REQUIRE:** SolidQueue/SolidCache
❌ **REJECT:** Sidekiq/Redis

**Why:** Rails 8 provides excellent defaults...
</rule>
```

---

## Proposed: TEAM_RULES.yml

**Format:** Pure YAML
**Estimated Lines:** ~600-700 (more concise, no markdown prose)

**Example Structure:**
```yaml
---
metadata:
  name: TEAM_RULES
  version: 4.0
  philosophy: "37signals-inspired Rails development"
  total_rules: 19

rules:
  rule_1:
    id: 1
    name: "Solid Stack Only"
    category: stack_architecture
    severity: critical
    enforcement: REJECT

    violation_triggers:
      keywords: [sidekiq, redis, memcached, resque]
      patterns: ['gem "sidekiq"', 'Redis.new']

    require:
      - "SolidQueue for background jobs"
      - "SolidCache for caching"
      - "SolidCable for WebSockets"

    reject:
      - "Sidekiq/Redis"
      - "Memcached"
      - "External job queues"

    response_pattern: "We use Rails 8 Solid Stack per TEAM_RULES.md Rule #1"
    redirect: "SolidQueue is already configured"

    rationale: "Rails 8 provides excellent defaults. No external dependencies needed."

    skills:
      primary: solid-stack-setup
      location: "skills/config/solid-stack-setup.md"
```

---

## Analysis: Markdown vs YAML

### Advantages of Current Markdown Format

#### 1. **Human Readability** ✅
- Markdown is designed for human consumption
- Headers, bullets, emphasis make scanning easier
- Code examples render nicely in editors/GitHub
- Emojis (✅/❌) provide visual cues

**Example:**
```markdown
✅ **REQUIRE:** SolidQueue for background jobs
❌ **REJECT:** Sidekiq/Redis
```

More scannable than:
```yaml
require: ["SolidQueue for background jobs"]
reject: ["Sidekiq/Redis"]
```

#### 2. **Rich Explanations** ✅
- Can include prose, examples, context
- "Why" sections with detailed rationale
- Migration guides with code snippets
- Tables for comparison

**Example:**
```markdown
**Why:** Rails 8 provides excellent defaults. SolidQueue uses
the same database you already have, eliminating Redis dependency.

**Migration:**
```ruby
# ❌ Old: Sidekiq
class EmailJob < ApplicationJob
  queue_as :default
end

# ✅ New: SolidQueue (no changes needed!)
class EmailJob < ApplicationJob
  queue_as :default
end
```

This richness is harder in pure YAML.

#### 3. **GitHub Rendering** ✅
- Renders beautifully on GitHub
- Markdown links work
- Tables, code blocks, headers all render
- Easy to read in PR reviews

#### 4. **Mixed Format Benefits** ✅
- YAML front matter for machine parsing
- Markdown body for human reading
- XML tags for semantic structure
- Best of all worlds

---

### Advantages of YAML Format

#### 1. **Machine Parsing** ⚠️ (Partial)
**Pro:** Pure YAML is easier to parse programmatically

**Con:** Current format already has machine-readable sections:
- YAML front matter
- Quick lookup YAML block
- XML semantic tags

**Current parsing capability:**
```ruby
# Already works:
yaml = extract_yaml_front_matter("rules/TEAM_RULES.md")
yaml["metadata"]["total_rules"] # => 19

# Quick lookup YAML is in markdown block
quick_lookup = extract_yaml_block(content, "rule_index")
```

**Verdict:** Current format is 80% machine-parseable already.

#### 2. **Consistency** ⚠️ (Not Critical)
**Pro:** Other rules files are YAML (ARCHITECT_DECISIONS.yml, RULES_TO_SKILLS_MAPPING.yml)

**Con:** TEAM_RULES.md serves different purpose:
- ARCHITECT_DECISIONS.yml: Decision logic for automation
- RULES_TO_SKILLS_MAPPING.yml: Data mapping
- TEAM_RULES.md: **Governance documentation** (human + machine)

**Verdict:** Having one MD file for governance docs is acceptable.

#### 3. **Conciseness** ✅
**Pro:** YAML would be ~100-150 lines shorter (no prose, no examples)

**Con:** Loses explanatory value

**Token Impact:**
- Current: ~5,600 tokens
- Pure YAML estimate: ~4,200 tokens
- **Savings: ~1,400 tokens (25% reduction)**

**Verdict:** Token savings are modest, but lose significant readability.

#### 4. **Structured Queries** ⚠️ (Marginal Benefit)
**Pro:** Could query like:
```ruby
rules = YAML.load_file("rules/TEAM_RULES.yml")
critical_rules = rules["rules"].select { |r| r["severity"] == "critical" }
```

**Con:** Already possible with current structure via RULES_TO_SKILLS_MAPPING.yml:
```ruby
mapping = YAML.load_file("rules/RULES_TO_SKILLS_MAPPING.yml")
critical_rules = mapping["enforcement"]["critical_rules"]["rules"]
```

**Verdict:** Structured querying already available via mapping file.

---

## Key Questions

### 1. Who is the primary consumer?

**Humans (developers):**
- Reading to understand rules
- Referring during code reviews
- Learning project standards

**Machines (LLMs):**
- Parsing for rule enforcement
- Extracting metadata
- Loading into context

**Current answer:** **Both**, but humans benefit more from markdown.

**YAML answer:** Optimizes for machines, degrades human experience.

---

### 2. How often is programmatic access needed?

**Current usage:**
- Tests validate structure (1 test file)
- No runtime parsing of TEAM_RULES.md
- Agents read as documentation, not data

**YAML would enable:**
- Runtime rule validation (not currently needed)
- Dynamic rule loading (not currently needed)
- Automated enforcement tooling (not currently needed)

**Verdict:** Current usage doesn't require pure YAML.

---

### 3. What's the token/readability tradeoff?

**Token savings:** ~1,400 tokens (25% reduction of TEAM_RULES only)
**System-wide impact:** ~0.5% (1,400 / ~270,000 total system tokens)

**Readability loss:**
- Harder to scan rules quickly
- Lose "why" explanations and context
- Lose code examples and migration guides
- Worse GitHub rendering

**Verdict:** 0.5% system token savings not worth significant readability loss.

---

## Hybrid Approach (Current Best Practice)

### What We Have Now ✅

**TEAM_RULES.md (Markdown):**
- Human-readable governance documentation
- Rich explanations, examples, context
- Beautiful GitHub rendering
- YAML front matter + quick lookup for machines
- XML semantic tags for structure

**RULES_TO_SKILLS_MAPPING.yml (YAML):**
- Pure data for programmatic access
- Bidirectional rule-skill mapping
- Domain organization
- Enforcement patterns
- Keyword lookup

**ARCHITECT_DECISIONS.yml (YAML):**
- Decision logic for @architect
- Pair programming patterns
- Delegation strategies

### Why This Works ✅

**Separation of concerns:**
- **Governance documentation** (TEAM_RULES.md): Human-first with machine-readable sections
- **Data structures** (RULES_TO_SKILLS_MAPPING.yml): Machine-first
- **Decision logic** (ARCHITECT_DECISIONS.yml): Machine-first

**Best of both worlds:**
- Humans read TEAM_RULES.md for understanding
- Machines parse RULES_TO_SKILLS_MAPPING.yml for data
- @architect uses ARCHITECT_DECISIONS.yml for automation

---

## Alternative: Enhanced Hybrid (If Optimization Needed)

### Option: Add TEAM_RULES_DATA.yml

**Keep:** TEAM_RULES.md (human documentation)

**Add:** TEAM_RULES_DATA.yml (machine data)

**Structure:**
```yaml
# TEAM_RULES_DATA.yml - Machine-readable rule data
# Generated from TEAM_RULES.md or maintained separately

rules:
  rule_1:
    id: 1
    name: "Solid Stack Only"
    severity: critical
    category: stack_architecture
    violation_triggers: [sidekiq, redis, memcached]
    enforcement: REJECT
    response: "We use Rails 8 Solid Stack per TEAM_RULES.md Rule #1"
    skills: [solid-stack-setup]
  # ... all 19 rules
```

**Benefits:**
- Human docs stay readable
- Machine parsing gets pure data
- Can validate sync between MD and YML

**Drawbacks:**
- Duplication (DRY violation)
- Maintenance burden (keep two files in sync)
- Adds complexity

**Verdict:** Not worth it - RULES_TO_SKILLS_MAPPING.yml already serves this purpose.

---

## Recommendation: Keep Markdown

### Reasoning

1. **Human readability is critical** ✅
   - TEAM_RULES is governance documentation
   - Developers need to understand WHY, not just WHAT
   - Rich explanations, examples, context matter

2. **Token savings are minimal** ⚠️
   - ~1,400 tokens (0.5% system-wide)
   - Not worth readability tradeoff

3. **Machine parsing already works** ✅
   - YAML front matter for metadata
   - Quick lookup YAML block for rule index
   - RULES_TO_SKILLS_MAPPING.yml for structured data
   - XML tags for semantic structure

4. **Hybrid approach is best practice** ✅
   - TEAM_RULES.md: Human-first governance docs
   - RULES_TO_SKILLS_MAPPING.yml: Machine-first data
   - ARCHITECT_DECISIONS.yml: Machine-first logic
   - Separation of concerns

5. **GitHub rendering matters** ✅
   - Markdown renders beautifully
   - YAML renders as plain text
   - Code reviews benefit from markdown

6. **Current format already machine-first optimized** ✅
   - Version 3.0 (2025-10-30) removed verbose examples
   - Concise rules with enforcement logic
   - Minimal code examples
   - Already at 799 lines (was likely 1,200+ before v3.0)

---

## When YAML Would Make Sense

**Scenarios where YAML > Markdown:**

1. **Runtime rule validation tool**
   - Parse rules at runtime to validate code
   - Currently: No such tool exists

2. **Automated enforcement system**
   - CI/CD checks against rule definitions
   - Currently: bin/ci checks, but doesn't parse TEAM_RULES

3. **Dynamic rule loading**
   - Load/unload rules based on context
   - Currently: Rules are static governance

4. **API for rule queries**
   - Service that serves rule data
   - Currently: Not needed

**None of these scenarios currently exist.**

---

## Potential Future Evolution

### If Machine Parsing Becomes Critical

**Step 1:** Add YAML export to build process
```ruby
# Rakefile
task :export_rules do
  # Parse TEAM_RULES.md
  # Extract rule data
  # Write to TEAM_RULES_DATA.yml (generated)
end
```

**Step 2:** Use generated YAML for automation
- Keep TEAM_RULES.md as source of truth
- Generate TEAM_RULES_DATA.yml for machines
- Best of both worlds, single source of truth

**Step 3:** Validate sync in tests
```ruby
def test_team_rules_sync
  md_rules = extract_rules_from_markdown("rules/TEAM_RULES.md")
  yml_rules = YAML.load_file("rules/TEAM_RULES_DATA.yml")
  assert_equal md_rules, yml_rules, "TEAM_RULES.md and DATA.yml out of sync"
end
```

---

## Final Answer

### Should TEAM_RULES.md be converted to YML?

**NO** ❌

### Why Not?

1. **Modest token savings (0.5% system-wide)** don't justify readability loss
2. **Human readability is critical** for governance documentation
3. **Current hybrid approach works well** (MD for docs, YML for data)
4. **Machine parsing already possible** via existing structure
5. **No current use case** requiring pure YAML format
6. **GitHub rendering** benefits from markdown

### What Should We Do Instead?

**Keep current approach:** ✅
- TEAM_RULES.md: Human-first governance with machine-readable sections
- RULES_TO_SKILLS_MAPPING.yml: Machine-first data structure
- ARCHITECT_DECISIONS.yml: Machine-first decision logic

**Future consideration:**
- If runtime rule parsing becomes needed
- Generate TEAM_RULES_DATA.yml from TEAM_RULES.md
- Keep markdown as source of truth

---

## Impact Summary

### Converting to YAML

**Gains:**
- ~1,400 tokens saved (0.5% system-wide)
- Slightly easier programmatic parsing
- Format consistency with other rules files

**Losses:**
- Human readability significantly degraded
- Lose rich explanations and "why" context
- Lose code examples and migration guides
- Worse GitHub rendering
- Harder to scan and reference during development

**Verdict:** Losses far outweigh gains.

---

## Status

**Current format:** ✅ **OPTIMAL** for current needs

**Recommendation:** ✅ **KEEP TEAM_RULES.md AS MARKDOWN**

**Rationale:** Governance documentation optimized for humans with sufficient machine-readability.
