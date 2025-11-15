# Rails-AI Skills Migration Plan
## From Custom Agent System to Official Claude Code Skills Structure (Leveraging Superpowers)

**Version:** 3.0
**Date:** 2025-11-15
**Status:** Architecture Planning - REVISED
**Complexity:** HIGH - Major structural transformation
**Estimated Duration:** 3-4 weeks
**Risk Level:** MODERATE (reversible, can run parallel)

---

## Executive Summary

This document outlines a comprehensive migration strategy to transform rails-ai from its current custom agent system (7 agents, 41 skills, centralized YAML registry) to the official Claude Code skills structure **while leveraging superpowers for universal workflows**.

**Key Strategic Shift:**
- **Rails-AI = Rails Domain Layer** on top of **Superpowers = Universal Workflow Foundation**
- **Reuse superpowers orchestration** (brainstorming, planning, TDD, debugging, review) instead of reimplementing
- **Keep architect as agent** (not /rails command) to reference superpowers workflows and coordinate Rails-specific work
- **Preserve XML tags** in skills for machine-parseable semantics (benefits outweigh markdown simplicity)
- **Reorganize agents by domain** (architect, developer, security, devops, uat)
- **Remove ViewComponent skills** (not using yet - defer to future)
- **Remove plan agent** (separate project scope)

**Key Objectives:**
- Maintain ALL current functionality
- Adopt official Claude Code patterns for better ecosystem integration
- **Leverage superpowers for orchestration workflows** (don't reimplement)
- Enable automatic skill discovery without centralized registry
- **Reorganize 5 agents by domain** (down from 7)
- Namespace all skills as `rails-ai:skillname`
- Preserve 20 team rules enforcement
- **Add superpowers dependency** for workflow integration

**Success Criteria:**
- **33 skills migrated** (37 existing - 4 ViewComponent + 1 new using-rails-ai - 1 removed plan)
- 5 agents reorganized by domain
- All tests passing (adapted for new structure)
- Team rules enforcement preserved
- Superpowers integration working (architect references superpowers workflows)
- Documentation updated
- bin/ci passes with all quality gates

---

## Table of Contents

1. [Architecture Analysis](#1-architecture-analysis)
2. [Migration Strategy](#2-migration-strategy)
3. [Structural Transformation](#3-structural-transformation)
4. [Content Adaptation](#4-content-adaptation)
5. [Skills Registry Replacement](#5-skills-registry-replacement)
6. [Rules System Integration](#6-rules-system-integration)
7. [Superpowers Integration](#7-superpowers-integration)
8. [Testing Transformation](#8-testing-transformation)
9. [Technical Implementation](#9-technical-implementation)
10. [Execution Roadmap](#10-execution-roadmap)
11. [Risk Assessment & Mitigation](#11-risk-assessment--mitigation)
12. [Rollback Plan](#12-rollback-plan)

---

## 1. Architecture Analysis

### 1.1 Current State Mapping

#### **Current System (rails-ai v0.2.x)**

```
rails-ai/
├── agents/                    # 7 specialized agents (TO BE REORGANIZED)
│   ├── architect.md          # 1,192 lines - Coordinator
│   ├── backend.md            # Backend specialist
│   ├── frontend.md           # Frontend specialist
│   ├── tests.md              # Testing specialist
│   ├── security.md           # Security specialist
│   ├── debug.md              # Debugging specialist
│   └── plan.md               # Planning specialist (TO BE REMOVED)
│
├── skills/                    # 41 modular skills
│   ├── SKILLS_REGISTRY.yml   # 624 lines - Central catalog
│   ├── frontend/             # 13 skills (4 ViewComponent TO BE REMOVED)
│   ├── backend/              # 10 skills
│   ├── testing/              # 6 skills
│   ├── security/             # 6 skills
│   └── config/               # 6 skills
│
├── rules/                     # Team governance
│   ├── TEAM_RULES.md         # 20 rules with enforcement
│   ├── RULES_TO_SKILLS_MAPPING.yml  # Bidirectional linking
│   └── ARCHITECT_DECISIONS.yml      # Decision matrices
│
├── test/                      # 56 test files
│   ├── unit/
│   │   ├── agents/           # Agent validation tests
│   │   ├── skills/           # Skill validation tests (41 files)
│   │   └── rules/            # Rules consistency tests
│   └── integration/          # End-to-end agent tests
│
└── .claude-plugin/
    └── marketplace.json      # Plugin metadata
```

**Skills to be REMOVED (not using yet):**
- `viewcomponent-basics.md`
- `viewcomponent-previews.md`
- `viewcomponent-slots.md`
- `viewcomponent-variants.md`

**Result:** 41 skills → 37 skills (after removing 4 ViewComponent)

### 1.2 Target State (Superpowers-Integrated Model)

#### **Target System (Rails-AI v0.3.0 + Superpowers)**

```
rails-ai/
├── skills/                    # Flat skill directories (33 total)
│   ├── using-rails-ai/       # NEW - Meta skill (SessionStart hook)
│   │   └── SKILL.md
│   ├── tdd-minitest/
│   │   └── SKILL.md          # References superpowers:test-driven-development
│   ├── debugging-rails/      # NEW - Rails debugging tools
│   │   └── SKILL.md          # References superpowers:systematic-debugging
│   ├── hotwire-turbo/
│   │   └── SKILL.md
│   └── ... (33 total skills)
│
├── agents/                    # 5 DOMAIN-ORGANIZED AGENTS
│   ├── architect.md          # REFACTORED - Coordinator, orchestrator, visionary
│   ├── developer.md          # NEW - Full-stack Rails developer (merges backend, frontend, debug)
│   ├── security.md           # REFACTORED - Security expert
│   ├── devops.md             # NEW - DevOps engineer (deployment, infra, config)
│   └── uat.md                # NEW - UAT/QA engineer (merges tests + QA focus)
│
├── hooks/                     # System hooks
│   ├── hooks.json            # Hook configuration
│   └── session-start.sh      # SessionStart hook (loads using-rails-ai)
│
├── rules/                     # Keep governance files
│   ├── TEAM_RULES.md         # Keep as-is
│   └── ARCHITECT_DECISIONS.yml  # Keep as-is
│
├── test/                      # Adapted testing
│   ├── unit/                 # Structure validation
│   └── integration/          # End-to-end tests
│
└── .claude-plugin/
    ├── plugin.json           # NEW - with superpowers dependency
    └── marketplace.json      # Updated
```

**Agent Reorganization (7 → 5):**

| Old Agent | New Agent | Rationale |
|-----------|-----------|-----------|
| architect.md | **architect.md** (refactored) | Coordinator, orchestrator, visionary - references superpowers workflows |
| backend.md + frontend.md + debug.md | **developer.md** (new) | Full-stack Rails developer with unified skillset |
| tests.md | **uat.md** (new) | UAT/QA engineer - broader testing + quality assurance focus |
| security.md | **security.md** (refactored) | Security expert - unchanged role, updated to reference superpowers |
| plan.md | **REMOVED** | Separate project scope |
| N/A | **devops.md** (new) | DevOps engineer - deployment, infrastructure, config skills |

**Key Characteristics:**
1. **Layered Architecture**: Rails-AI (domain) on Superpowers (workflows)
2. **Minimal Metadata**: Just `name` and `description` in frontmatter
3. **Directory Discovery**: No central registry needed
4. **XML Tags Preserved**: For machine-parseable semantics
5. **Superpowers Integration**: Architect references superpowers workflows
6. **Domain-Organized Agents**: 5 agents by functional domain (not tech stack)
7. **33 Skills Total**: 37 existing - 4 ViewComponent + 1 new using-rails-ai

---

### 1.3 Layered Architecture Model

```
┌─────────────────────────────────────────────────────┐
│ RAILS-AI DOMAIN LAYER                               │
│ - Rails patterns (Hotwire, ActiveRecord, Tailwind)  │
│ - Rails debugging tools (logs, console, byebug)     │
│ - TEAM_RULES.md enforcement (Solid Stack, Minitest) │
│ - Rails file structure knowledge                    │
│ - Context7 Rails/gem documentation queries          │
│ - Architect agent (coordinator)                     │
│ - Specialist agents (developer, security, etc.)     │
└─────────────────────────────────────────────────────┘
                          ↓ references
┌─────────────────────────────────────────────────────┐
│ SUPERPOWERS UNIVERSAL LAYER                         │
│ - Orchestration (brainstorming, planning, executing)│
│ - Process enforcement (TDD, verification, debugging)│
│ - Code review (requesting, reviewing)               │
│ - Parallelization (dispatching agents)              │
└─────────────────────────────────────────────────────┘
                          ↓ uses
┌─────────────────────────────────────────────────────┐
│ CLAUDE CODE BASE LAYER                              │
│ - Task tool (agent dispatch)                        │
│ - File tools (Read, Write, Edit, Glob, Grep)        │
│ - Bash tool (git, testing, builds)                  │
│ - MCP tools (Context7)                              │
└─────────────────────────────────────────────────────┘
```

---

### 1.4 What Stays, What Changes, What's New

#### **STAYS (Minimal Changes)**
✅ **37 existing skills** - Content largely preserved, XML tags kept (excludes 4 ViewComponent skills)
✅ **20 team rules** - Enforcement logic intact
✅ **Testing philosophy** - TDD, coverage, quality
✅ **Security patterns** - All 6 security skills
✅ **Skill content** - Patterns, examples, guidance
✅ **Context7 integration** - MCP server usage
✅ **TEAM_RULES.md** - Governance document

#### **CHANGES (Transformations)**
🔄 **Agent reorganization** - 7 agents → 5 domain-organized agents
  - architect (refactored, references superpowers)
  - developer (merges backend + frontend + debug)
  - security (refactored)
  - devops (new - infrastructure focus)
  - uat (new - merges tests + QA)
🔄 **SKILLS_REGISTRY.yml** → DELETE (directory discovery)
🔄 **Rich YAML frontmatter** → Minimal name + description
🔄 **Skill filenames** → `SKILL.md` in own directory
🔄 **Skill names** → `rails-ai:skillname` format
🔄 **Test discovery** → Scan directories not registry
🔄 **Skills reference superpowers** → Add REQUIRED BACKGROUND sections

#### **REMOVED**
❌ **plan.md agent** - Separate project scope (planning will use superpowers:writing-plans)
❌ **ViewComponent skills (4)** - Not using yet, defer to future:
  - viewcomponent-basics.md
  - viewcomponent-previews.md
  - viewcomponent-slots.md
  - viewcomponent-variants.md

#### **NEW (Additions)**
➕ **Superpowers dependency** - plugin.json dependency
➕ **using-rails-ai skill** - Meta skill loaded at SessionStart
➕ **SessionStart hook** - Loads using-rails-ai
➕ **hooks.json** - Hook configuration
➕ **plugin.json** - Official plugin metadata with dependencies
➕ **rails-ai:debugging-rails** - New skill (Rails debugging tools)
➕ **Superpowers integration** - Architect references superpowers workflows
➕ **3 new agents** - developer, devops, uat (domain-organized)

---

## 2. Migration Strategy

### 2.1 Phased Approach (Recommended)

**Strategy:** Parallel development with gradual cutover + superpowers integration

#### **Phase 1: Foundation (Week 1)**
- Create new directory structure alongside existing
- Build transformation scripts
- Implement SessionStart hook
- **Add superpowers dependency**
- **Refactor architect to reference superpowers**
- Create using-rails-ai meta skill
- Validate new structure with 5 pilot skills

**Success Criteria:**
- [ ] New directories created
- [ ] Scripts tested on 5 skills
- [ ] SessionStart hook functional
- [ ] Architect refactored (~400 lines, references superpowers)
- [ ] using-rails-ai skill created
- [ ] Pilot skills discoverable by Claude
- [ ] Superpowers workflows accessible

#### **Phase 2: Bulk Migration (Week 2)**
- Transform all 41 skills
- Add superpowers references to skills (REQUIRED BACKGROUND)
- Create rails-ai:debugging-rails skill
- Adapt all 56 test files
- Update documentation
- Preserve git history

**Success Criteria:**
- [ ] All 42 skills in new structure
- [ ] Superpowers references added where appropriate
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Git history clean

#### **Phase 3: Integration & Validation (Week 3)**
- Test skill discovery
- **Test superpowers integration** (architect uses superpowers workflows)
- Validate rules enforcement
- Run integration tests
- Performance testing
- Community testing

**Success Criteria:**
- [ ] All skills auto-discovered
- [ ] Architect successfully references superpowers workflows
- [ ] Rules enforcement working
- [ ] Integration tests passing
- [ ] Performance acceptable
- [ ] 3+ successful beta testers

#### **Phase 4: Cutover & Cleanup (Week 4)**
- Switch default to new structure
- Archive old structure
- Update marketplace
- Release v0.3.0
- Monitor for issues

**Success Criteria:**
- [ ] New structure default
- [ ] Old structure archived
- [ ] Marketplace updated
- [ ] Release published
- [ ] No critical issues

---

## 3. Structural Transformation

### 3.1 Agent Transformation Strategy

#### **Agent Reorganization: 7 → 5 Domain-Based Agents**

| Old Agents | New Agent | Domain | Rationale |
|-----------|-----------|--------|-----------|
| architect.md | **architect** | Coordination | Refactored - coordinator, orchestrator, visionary - references superpowers workflows |
| backend.md + frontend.md + debug.md | **developer** | Full-stack Rails | NEW - Unified full-stack Rails developer with debugging capabilities |
| tests.md | **uat** | Quality Assurance | NEW - UAT/QA engineer with broader testing + quality focus |
| security.md | **security** | Security | Refactored - security expert, references superpowers for systematic debugging |
| plan.md | **REMOVED** | (none) | Out of scope - use superpowers:writing-plans instead |
| (none) | **devops** | Infrastructure | NEW - DevOps engineer for deployment, infrastructure, config |

**KEY DECISIONS:**

**1. Keep architect as agent (not /rails command)**
- **State Management**: Coordination requires tracking context across multiple agent dispatches
- **Superpowers Integration**: Agent can reference superpowers workflows and adapt based on responses
- **Tool Access**: May need to query Context7, read TEAM_RULES.md, analyze project structure
- **Flexibility**: Can orchestrate complex multi-phase workflows (design → plan → execute → review)

**2. Merge backend + frontend + debug → developer**
- **Rationale**: Modern Rails development is full-stack; artificial separation creates overhead
- **Unified Skillset**: Developer has access to all Rails skills (backend, frontend, debugging)
- **Simplicity**: Architect delegates to one agent for most development work
- **Flexibility**: Developer can handle full feature implementation end-to-end

**3. Rename tests → uat (User Acceptance Testing)**
- **Broader Focus**: Not just test writing, but quality assurance and verification
- **Aligns with Workflow**: UAT validates features meet requirements
- **Includes**: Minitest, integration tests, manual testing, QA processes

**4. Create devops agent**
- **Separate Concern**: Infrastructure and deployment distinct from development
- **Skills**: Docker, deployment, Solid Stack config, environment management
- **Responsibilities**: Production readiness, CI/CD, infrastructure as code

**5. Remove plan agent**
- **Rationale**: Planning is a workflow, not a distinct role
- **Use Superpowers**: superpowers:writing-plans provides planning process
- **Architect Coordinates**: Architect invokes superpowers planning workflows

---

### 3.2 Architect Agent Refactoring

#### **Current Architect (1,192 lines)**
**Problems:**
- Reimplements orchestration that superpowers provides
- Too large, mixes coordination with workflow details
- Duplicates TDD/debugging/review logic

#### **Target Architect (~400 lines)**

**Structure:**
```markdown
---
name: architect
description: Rails development coordinator - analyzes requests, loads rails-ai skills, delegates to specialized agents, enforces TEAM_RULES.md, references superpowers workflows
model: inherit
---

# Rails Architect & Coordinator

## Role
Senior Rails architect coordinating specialized agents.

**YOU ARE A COORDINATOR, NOT IMPLEMENTER.**
- ✅ Analyze requests, load skills, delegate, enforce rules, review
- ❌ Never write code, run tests, create components

## Critical Rules (TEAM_RULES.md)
[Keep 6 critical rules with enforcement]

## Workflow Selection (Reference Superpowers)

### Design Phase (Rough Idea → Design)
**Use superpowers:brainstorming**
- Load rails-ai skills for context (Hotwire, ActiveRecord, etc.)
- Query Context7 for current Rails/gem docs

### Planning Phase (Design → Implementation Plan)
**Use superpowers:writing-plans**
- Reference rails-ai skills in tasks
- Include exact Rails file paths

### Execution Phase (Plan → Implementation)
**Choose execution style:**
- **Batch:** superpowers:executing-plans
- **Fast:** superpowers:subagent-driven-development
- Delegate to @backend, @frontend, @tests with rails-ai skills

### Debugging Phase (Issues → Root Cause → Fix)
**Use superpowers:systematic-debugging**
- Load rails-ai:debugging-rails for Rails tools
- Delegate to @debug agent

### Review Phase (Work → Verification)
**Use superpowers:requesting-code-review**
- Review against TEAM_RULES.md + Rails conventions
**Use superpowers:verification-before-completion**
- Run bin/ci before success claims

## Parallel Coordination
**Use superpowers:dispatching-parallel-agents**

## MCP Integration (Context7)
[Keep Context7 queries]

## Rails-AI Skills Catalog
[Simplified skill loading logic]

## Agent Delegation Rules
[Coordinator role definition]
```

**What to Remove:**
- ❌ Detailed brainstorming process (use superpowers:brainstorming)
- ❌ Plan creation methodology (use superpowers:writing-plans)
- ❌ Batch execution logic (use superpowers:executing-plans)
- ❌ TDD enforcement details (use superpowers:test-driven-development)
- ❌ Debugging framework (use superpowers:systematic-debugging)
- ❌ Code review workflow (use superpowers:requesting-code-review)

**What to Keep:**
- ✅ TEAM_RULES.md enforcement (Rails governance)
- ✅ Rails file structure knowledge
- ✅ Context7 integration
- ✅ Agent routing logic (updated for 5 agents)
- ✅ Rails skills catalog
- ✅ Coordinator role definition

**Result:** 66% reduction (1,192 → ~400 lines)

**Delegation Pattern:**
```markdown
Architect analyzes request → Determines domain:
- Development work → @developer
- Security audit → @security
- Infrastructure/deployment → @devops
- Testing/QA → @uat
```

---

### 3.3 New Agent: developer (Full-Stack Rails Developer)

**Created from:** backend.md + frontend.md + debug.md

**Role:** Full-stack Rails developer handling end-to-end feature implementation

**Target Structure (~500-600 lines):**
```markdown
---
name: developer
description: Full-stack Rails developer - implements features end-to-end (models, controllers, views, Hotwire, tests, debugging) following TDD and TEAM_RULES.md
model: inherit
---

# Full-Stack Rails Developer

## Role
Senior full-stack Rails developer implementing features end-to-end.

**Unified Skillset:**
- ✅ Backend: Models, controllers, API, database, ActiveRecord
- ✅ Frontend: Hotwire (Turbo, Stimulus), Tailwind, DaisyUI, views
- ✅ Debugging: Rails logs, console, byebug, SQL logging

**TDD Mandatory:**
**Use superpowers:test-driven-development for process**
**Use rails-ai:tdd-minitest for Rails/Minitest patterns**

## Critical Rules
[Subset of TEAM_RULES.md relevant to development]

## Skill Loading
**Backend Skills (10):**
- rails-ai:controller-restful, rails-ai:activerecord-patterns
- rails-ai:form-objects, rails-ai:query-objects
- rails-ai:concerns-models, rails-ai:concerns-controllers
- rails-ai:custom-validators, rails-ai:action-mailer
- rails-ai:nested-resources, rails-ai:antipattern-fat-controllers

**Frontend Skills (9 - excludes ViewComponent):**
- rails-ai:hotwire-turbo, rails-ai:turbo-morph, rails-ai:hotwire-stimulus
- rails-ai:tailwind, rails-ai:daisyui
- rails-ai:view-helpers, rails-ai:forms-nested
- rails-ai:accessibility, rails-ai:partials

**Testing Skills (6):**
- rails-ai:tdd-minitest, rails-ai:fixtures, rails-ai:minitest-mocking
- rails-ai:test-helpers, rails-ai:model-testing

**Debugging:**
- rails-ai:debugging-rails (+ superpowers:systematic-debugging)

## Workflow
1. Architect delegates task with context
2. Load relevant rails-ai skills for feature domain
3. Follow TDD: RED → GREEN → REFACTOR
4. Implement end-to-end (model → controller → view → tests)
5. Use superpowers:verification-before-completion
6. Report back to architect with evidence
```

**Key Benefits:**
- One agent handles full feature (no handoffs)
- Unified context (backend + frontend together)
- Faster iteration
- Clearer ownership

---

### 3.4 New Agent: uat (User Acceptance Testing / QA)

**Created from:** tests.md (expanded focus)

**Role:** QA engineer focused on testing, quality assurance, user acceptance validation

**Target Structure (~400 lines):**
```markdown
---
name: uat
description: UAT/QA engineer - validates features meet requirements, writes comprehensive tests, ensures quality gates pass, performs user acceptance testing
model: inherit
---

# UAT & QA Engineer

## Role
Quality assurance engineer focused on testing and validation.

**Broader than just test writing:**
- ✅ Test-driven development enforcement
- ✅ Integration and acceptance testing
- ✅ Manual QA and user acceptance testing
- ✅ Quality gates (bin/ci, RuboCop, Brakeman)
- ✅ Test coverage and quality metrics

**TDD Enforcement:**
**Use superpowers:test-driven-development for process**
**Use rails-ai:tdd-minitest for Rails testing**

## Critical Rules
- Rule #4: TDD Always (RED-GREEN-REFACTOR)
- Rule #17: bin/ci Must Pass
- Rule #18: WebMock: No Live HTTP in Tests

## Skills
- rails-ai:tdd-minitest (Minitest patterns)
- rails-ai:fixtures (test data)
- rails-ai:minitest-mocking (mocking strategies)
- rails-ai:test-helpers (custom helpers)
- rails-ai:model-testing (model tests)

## Workflow
1. Receives feature specification from architect
2. Writes acceptance criteria
3. Creates failing tests (RED)
4. Validates developer implementation passes (GREEN)
5. Ensures bin/ci passes (all quality gates)
6. Performs manual QA if needed
7. Reports back with test results and coverage
```

**Key Benefits:**
- Quality-focused role (not just test coding)
- User acceptance validation
- Quality gates enforcement

---

### 3.5 Refactored Agent: security (Security Expert)

**Updated from:** security.md

**Changes:**
- References superpowers:systematic-debugging for security investigation
- Updated skill loading for new structure

**Target Structure (~400 lines):**
```markdown
---
name: security
description: Security expert - audits code for vulnerabilities (XSS, SQL injection, CSRF, etc.), ensures OWASP compliance, reviews authentication/authorization
model: inherit
---

# Security Expert

## Role
Senior security expert auditing Rails applications for vulnerabilities.

**Security Focus:**
- ✅ OWASP Top 10 vulnerabilities
- ✅ Rails-specific security patterns
- ✅ Authentication & authorization review
- ✅ Secure configuration audit

**Investigation:**
**Use superpowers:systematic-debugging for security investigation**
**Use rails-ai security skills for Rails-specific patterns**

## Skills (6)
- rails-ai:security-xss (Cross-site scripting)
- rails-ai:security-sql-injection (SQL injection prevention)
- rails-ai:security-csrf (CSRF protection)
- rails-ai:security-strong-params (Strong parameters)
- rails-ai:security-file-uploads (Secure file handling)
- rails-ai:security-command-injection (Command injection)

## Workflow
1. Receives code/feature for security audit
2. Loads relevant security skills
3. Systematically reviews for vulnerabilities
4. Uses superpowers:systematic-debugging for investigation
5. Reports findings with severity (Critical/High/Medium/Low)
6. Provides remediation guidance
```

---

### 3.6 New Agent: devops (DevOps Engineer)

**Created from:** (new - infrastructure focus)

**Role:** DevOps engineer handling deployment, infrastructure, configuration

**Target Structure (~350 lines):**
```markdown
---
name: devops
description: DevOps engineer - handles deployment, infrastructure, Docker, CI/CD, environment configuration, production readiness for Rails 8+ applications
model: inherit
---

# DevOps Engineer

## Role
DevOps engineer managing infrastructure and deployment.

**Responsibilities:**
- ✅ Docker configuration and containerization
- ✅ Deployment pipelines (CI/CD)
- ✅ Environment configuration
- ✅ Solid Stack production setup
- ✅ Infrastructure as code
- ✅ Production monitoring and scaling

## Critical Rules
- Rule #1: Solid Stack Only (SolidQueue, SolidCache, SolidCable)
- Rule #17: bin/ci Must Pass (CI/CD gates)

## Skills (6)
- rails-ai:solid-stack (SolidQueue/Cache/Cable production config)
- rails-ai:docker (Dockerfile, docker-compose, production images)
- rails-ai:rubocop (code quality enforcement)
- rails-ai:initializers (Rails initializers)
- rails-ai:credentials (encrypted credentials management)
- rails-ai:environment-config (environment-specific config)

## Workflow
1. Receives deployment/infrastructure task
2. Loads relevant config/deployment skills
3. Implements infrastructure changes
4. Tests in staging environment
5. Ensures production readiness
6. Documents deployment procedures
7. Reports back with verification
```

**Key Benefits:**
- Separates infrastructure concerns from development
- Production readiness focus
- DevOps best practices

---

### 3.7 Skills Organization (Flat Namespace)

#### **Current Structure (Domain Hierarchy)**
```
skills/
├── frontend/
│   ├── viewcomponent-basics.md
│   └── ... (13 files)
├── backend/
│   ├── controller-restful.md
│   └── ... (10 files)
├── testing/
├── security/
└── config/
```

#### **Target Structure (Flat Namespace)**
```
skills/
├── using-rails-ai/              # Meta skill (SessionStart)
│   └── SKILL.md
├── tdd-minitest/
│   └── SKILL.md                # References superpowers:test-driven-development
├── debugging-rails/            # NEW - Rails debugging tools
│   └── SKILL.md                # References superpowers:systematic-debugging
├── controller-restful/
│   └── SKILL.md
├── hotwire-turbo/
│   └── SKILL.md
└── ... (33 total directories)
```

#### **Naming Convention**

**Directory Pattern:** `concept` or `domain-concept` (kebab-case, NO prefix)

**Frontmatter Pattern:** `rails-ai:concept` (WITH prefix in name field)

**Examples:**
- Directory: `tdd-minitest/` → Frontmatter: `name: rails-ai:tdd-minitest`
- Directory: `turbo-morph/` → Frontmatter: `name: rails-ai:turbo-morph` (rename for clarity)
- Directory: `debugging-rails/` → Frontmatter: `name: rails-ai:debugging-rails` (NEW)

**Rationale:**
- **Clean filesystem**: No special characters in directory names
- **Namespaced references**: `rails-ai:` prefix only when referencing skills
- **Discoverable**: Claude Code namespaces plugin skills automatically

---

## 4. Content Adaptation

### 4.1 YAML Frontmatter Transformation

#### **Current Format (Rich Metadata)**
```yaml
---
name: turbo-page-refresh
domain: frontend
dependencies: [hotwire-turbo]
version: 1.0
rails_version: 8.1+
gem_requirements:
  - turbo-rails: 2.0.0+
enforces_team_rule:
  - rule_id: 7
    rule_name: "Turbo Morph by Default"
    severity: high
---
```

#### **Target Format (Minimal)**
```yaml
---
name: rails-ai:turbo-morph
description: Use when building SPA-like page updates in Rails - Turbo Morph preserves scroll/form state without complex Frames setup (Team Rule #7 preferred pattern)
---
```

**Description Writing Formula:**
```
Use when [triggering condition] - [what it does] - [key benefit/rule enforcement]
```

### 4.2 XML Tags - KEEP THEM

**DECISION: Preserve XML semantic tags**

**Rationale:**
1. **Machine-Parseable**: LLMs can extract specific sections reliably
2. **Semantic Structure**: Clear boundaries for when-to-use, benefits, standards, patterns, antipatterns
3. **Search Optimization**: Can extract specific sections without full skill load
4. **Proven Pattern**: Already optimized, tested, works well
5. **Minimal Cost**: Slightly more tokens but better structure

**What Standard Markdown Loses:**
- ❌ Reliable section extraction (H2 headers can be ambiguous)
- ❌ Semantic clarity (is "## Overview" the same as when-to-use?)
- ❌ Nested structures (patterns within patterns)

**What XML Provides:**
- ✅ Unambiguous section boundaries
- ✅ Nested semantic structures
- ✅ Machine-parseable with 100% reliability
- ✅ Already optimized and tested

**Recommendation:** **Keep XML tags** - Don't convert to markdown

**Updated Skill Structure:**
```yaml
---
name: rails-ai:turbo-morph
description: Use when building SPA-like page updates - preserves scroll/form state without Frames (Rule #7)
---

# Turbo Page Refresh with Morphing

<when-to-use>
- Want SPA-like experience without complex Turbo Frame setup
- Need to preserve scroll position and form state
- Building real-time features that update the full page
</when-to-use>

<benefits>
- **Simpler Architecture** - No need to wrap everything in Turbo Frames
- **State Preservation** - Keeps scroll position, form state, focus automatically
- **Clean SPA Behavior** - Page updates feel instant and smooth
</benefits>

<standards>
- Enable morph refresh with `data-turbo-refresh-method="morph"` on body
- Use `data-turbo-permanent` to prevent morphing specific elements
- Broadcast full page renders via Turbo Streams with `refresh` action
</standards>

<pattern name="basic-setup">
<description>Enable Turbo Page Refresh with morphing</description>
<implementation>
```erb
<!-- app/views/layouts/application.html.erb -->
<body data-turbo-refresh-method="morph">
  <%= yield %>
</body>
```
</implementation>
</pattern>

<antipatterns>
<antipattern>
<description>Using Turbo Frames when Page Refresh would be simpler</description>
<bad-example>
```erb
<%# Complex nested frames %>
<%= turbo_frame_tag :posts do %>
  <%= turbo_frame_tag :header %>
  <%= turbo_frame_tag :content %>
<% end %>
```
</bad-example>
<good-example>
```erb
<%# Simple page refresh with morph %>
<body data-turbo-refresh-method="morph">
  <%= render @posts %>
</body>
```
</good-example>
</antipattern>
</antipatterns>

<testing>
```ruby
# test/system/page_refresh_test.rb
test "preserves scroll position after update" do
  visit posts_path
  execute_script("window.scrollTo(0, 500)")

  # Trigger update via Turbo Stream
  Post.create!(title: "New Post")

  assert_equal 500, evaluate_script("window.scrollY")
end
```
</testing>
```

---

### 4.3 Superpowers Integration in Skills

**Pattern: Reference superpowers skills for universal processes**

**Example: rails-ai:tdd-minitest**

```yaml
---
name: rails-ai:tdd-minitest
description: Use when implementing Rails features with Minitest - applies RED-GREEN-REFACTOR with Rails-specific test patterns (fixtures, controller tests, component tests)
---

# Test-Driven Development with Rails and Minitest

<superpowers-integration>
**REQUIRED BACKGROUND:** Use superpowers:test-driven-development for TDD process
  - That skill defines RED-GREEN-REFACTOR cycle
  - That skill enforces "NO CODE WITHOUT FAILING TEST FIRST"
  - This skill adds Rails/Minitest implementation specifics
</superpowers-integration>

<when-to-use>
- Implementing any Rails feature (models, controllers, components, jobs)
- Fixing Rails bugs (write failing test first)
- Refactoring Rails code (tests stay green)
</when-to-use>

<tdd-process-from-superpowers>
1. RED: Write failing test → Verify RED
2. GREEN: Minimal code to pass → Verify GREEN
3. REFACTOR: Clean up while keeping tests green
4. Repeat

See superpowers:test-driven-development for full process and discipline
</tdd-process-from-superpowers>

<rails-minitest-specifics>

<pattern name="model-test">
<description>Testing Rails models with Minitest</description>
<implementation>
```ruby
# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "validates email presence" do
    user = User.new(email: nil)
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "validates email uniqueness" do
    existing = users(:valid_user)  # fixture
    user = User.new(email: existing.email)
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end
end
```
</implementation>
</pattern>

<pattern name="controller-test">
<description>Testing Rails controllers with Minitest</description>
<implementation>
```ruby
# test/controllers/users_controller_test.rb
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_url
    assert_response :success
    assert_select "h1", "Users"
  end

  test "should create user" do
    assert_difference("User.count", 1) do
      post users_url, params: { user: { email: "test@example.com" } }
    end

    assert_redirected_to user_url(User.last)
  end
end
```
</implementation>
</pattern>

<pattern name="fixtures">
<description>Using fixtures for test data</description>
<implementation>
```yaml
# test/fixtures/users.yml
valid_user:
  email: "test@example.com"
  created_at: <%= 1.day.ago %>

admin_user:
  email: "admin@example.com"
  admin: true
```

```ruby
# In test
user = users(:valid_user)
```
</implementation>
</pattern>

</rails-minitest-specifics>

<related-skills>
- superpowers:test-driven-development (TDD process)
- rails-ai:fixtures (Detailed fixture patterns)
- rails-ai:minitest-mocking (Mocking strategies)
- rails-ai:test-helpers (Custom test helpers)
</related-skills>
```

**Key Points:**
- `<superpowers-integration>` section at top
- Reference superpowers for PROCESS
- Provide Rails/Minitest IMPLEMENTATION
- Clear separation of concerns

---

### 4.4 New Skill: rails-ai:debugging-rails

**Create new skill for Rails-specific debugging tools**

```yaml
---
name: rails-ai:debugging-rails
description: Use when debugging Rails issues - provides Rails-specific debugging tools (logs, console, byebug, SQL logging) integrated with systematic debugging process
---

# Rails Debugging Tools & Techniques

<superpowers-integration>
**REQUIRED BACKGROUND:** Use superpowers:systematic-debugging for investigation process
  - That skill defines 4-phase framework (Root Cause → Pattern → Hypothesis → Implementation)
  - This skill provides Rails-specific debugging tools for each phase
</superpowers-integration>

<when-to-use>
- Rails application behaving unexpectedly
- Tests failing with unclear errors
- Performance issues or N+1 queries
- Production errors need investigation
</when-to-use>

<phase1-root-cause-investigation>

<tool name="rails-logs">
<description>Check Rails logs for errors and request traces</description>
```bash
# Development logs
tail -f log/development.log

# Production logs (Heroku)
heroku logs --tail --app production

# Filter by severity
grep ERROR log/production.log

# Filter by request
grep "Started GET" log/development.log
```
</tool>

<tool name="rails-console">
<description>Interactive Rails console for testing models/queries</description>
```ruby
# Start console
rails console

# Or production console (read-only)
heroku run rails console --app production

# Test models
user = User.find(1)
user.valid?  # Check validations
user.errors.full_messages  # See errors

# Test queries
User.where(email: "test@example.com").to_sql  # See SQL
User.includes(:posts).where(posts: { published: true })  # Avoid N+1
```
</tool>

<tool name="byebug">
<description>Breakpoint debugger for stepping through code</description>
```ruby
# Add to any Rails file
def some_method
  byebug  # Execution stops here
  # ... rest of method
end

# Byebug commands:
# n  - next line
# s  - step into method
# c  - continue execution
# pp variable  - pretty print
# var local  - show local variables
# exit  - quit debugger
```
</tool>

<tool name="sql-logging">
<description>Enable verbose SQL logging to see queries</description>
```ruby
# In rails console or code
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Now all SQL queries print to console
User.all
# => SELECT "users".* FROM "users"
```
</tool>

</phase1-root-cause-investigation>

<phase2-pattern-analysis>

<tool name="rails-routes">
<description>Check route definitions and paths</description>
```bash
# List all routes
rails routes

# Filter routes
rails routes | grep users

# Show routes for controller
rails routes -c users
```
</tool>

<tool name="rails-db-status">
<description>Check migration status and schema</description>
```bash
# Migration status
rails db:migrate:status

# Show schema version
rails db:version

# Check pending migrations
rails db:abort_if_pending_migrations
```
</tool>

</phase2-pattern-analysis>

<phase3-hypothesis-testing>

<tool name="rails-runner">
<description>Run Ruby code in Rails environment</description>
```bash
# Run one-liner
rails runner "puts User.count"

# Run script
rails runner scripts/investigate_users.rb

# Production environment
RAILS_ENV=production rails runner "User.pluck(:email)"
```
</tool>

</phase3-hypothesis-testing>

<phase4-implementation>

<tool name="rails-test-verbose">
<description>Run tests with detailed output</description>
```bash
# Run single test with backtrace
rails test test/models/user_test.rb --verbose

# Run with warnings enabled
RUBYOPT=-W rails test

# Run with seed for reproducibility
rails test --seed 12345
```
</tool>

</phase4-implementation>

<common-issues>

<issue name="n-plus-one-queries">
<detection>
Check logs for many similar queries:
```
User Load (0.1ms)  SELECT * FROM users WHERE id = 1
Post Load (0.1ms)  SELECT * FROM posts WHERE user_id = 1
Post Load (0.1ms)  SELECT * FROM posts WHERE user_id = 2
Post Load (0.1ms)  SELECT * FROM posts WHERE user_id = 3
```
</detection>
<solution>
Use includes/preload:
```ruby
# Bad
users.each { |user| user.posts.count }

# Good
users.includes(:posts).each { |user| user.posts.count }
```
</solution>
</issue>

<issue name="missing-migration">
<detection>
Error: "ActiveRecord::StatementInvalid: no such column"
</detection>
<solution>
```bash
# Check migration status
rails db:migrate:status

# Run pending migrations
rails db:migrate

# Or rollback and retry
rails db:rollback
rails db:migrate
```
</solution>
</issue>

</common-issues>

<related-skills>
- superpowers:systematic-debugging (4-phase framework)
- superpowers:root-cause-tracing (Deep stack traces)
- rails-ai:activerecord-patterns (Query optimization)
- rails-ai:tdd-minitest (Test debugging)
</related-skills>
```

---

## 5. Skills Registry Replacement

### 5.1 Current Registry Functions

**SKILLS_REGISTRY.yml provides:**
1. Skill catalog with metadata
2. Domain organization
3. Dependency tracking
4. Keyword → skills mapping
5. Load order

### 5.2 Directory-Based Discovery

**Replacement strategy:**

**1. Metadata → Skill frontmatter**
```yaml
# OLD: SKILLS_REGISTRY.yml
tdd-minitest:
  domain: testing
  dependencies: []
  when_to_use: "Implementing Rails features with TDD"
  enforces_team_rule: [rule_2, rule_4]

# NEW: skills/tdd-minitest/SKILL.md frontmatter
---
name: rails-ai:tdd-minitest
description: Use when implementing Rails features with Minitest - applies RED-GREEN-REFACTOR (enforces Team Rules #2, #4)
---
```

**Note:** Directory name has NO prefix, but frontmatter `name` field includes `rails-ai:` prefix

**2. Dependencies → Skill content**
```markdown
# In SKILL.md body
<related-skills>
**REQUIRED BACKGROUND:**
- superpowers:test-driven-development (TDD process)

**OPTIONAL:**
- rails-ai:fixtures (Test data patterns)
- rails-ai:minitest-mocking (Mocking strategies)
</related-skills>
```

**3. Domain → Description**
```yaml
description: Use when implementing Rails features with Minitest - (testing skill) applies RED-GREEN-REFACTOR
```

**4. Statistics → Generate script**
```bash
# bin/stats - Generate metrics from directory scan
#!/usr/bin/env ruby
skills_count = Dir["skills/*/SKILL.md"].count
# ... analyze dependencies, generate report
```

### 5.3 Migration Plan for Registry

**Actions:**
1. Extract metadata into skill frontmatter descriptions
2. Document dependencies in skill `<related-skills>` sections
3. Create bin/stats for metrics generation
4. **DELETE SKILLS_REGISTRY.yml**
5. Update tests to scan directories instead of registry

---

## 6. Rules System Integration

### 6.1 Hybrid Rules Enforcement

**Three-Layer Approach:**

**Layer 1: TEAM_RULES.md (Keep as-is)**
- Human-readable governance document
- 20 rules with priority, enforcement actions
- Single source of truth

**Layer 2: Skill Descriptions (Embed rule references)**
```yaml
---
name: rails-ai:solid-stack
description: Configure SolidQueue, SolidCache, SolidCable - ENFORCES Rule #1 (NO Sidekiq/Redis/Memcached)
---
```

**Layer 3: Architect Agent (Enforcement logic)**
```markdown
## Critical Rules Enforcement

When you detect these violations, REJECT immediately:

| Keyword | Rule | Redirect |
|---------|------|----------|
| sidekiq, redis | #1 | Load rails-ai:solid-stack |
| rspec, describe | #2 | Load rails-ai:tdd-minitest |
| member do | #3 | Load rails-ai:controller-restful |
```

**Benefits:**
- ✅ Single source of truth (TEAM_RULES.md)
- ✅ Discoverable (skill descriptions mention rules)
- ✅ Enforceable (architect checks keywords)
- ✅ Maintainable (update one place)

### 6.2 Rules → Skills Mapping Preservation

**Update TEAM_RULES.md to reference skills:**

```markdown
## Rule #1: Solid Stack Only

NO Sidekiq, Redis, Memcached, Resque, or Delayed Job.

USE: SolidQueue, SolidCache, SolidCable (Rails 8 defaults)

**Enforcement:** REJECT violations immediately
**Implementation Skill:** rails-ai:solid-stack
**Related Skills:** rails-ai:action-mailer (background jobs)
```

**In skills, reference rules:**

```markdown
# skills/rails-ai:solid-stack/SKILL.md

<team-rule-enforcement>
This skill enforces **Rule #1: Solid Stack Only**

**Violations to REJECT:**
- ❌ Adding Sidekiq gem
- ❌ Using Redis for caching
- ❌ Configuring Memcached

**Correct Approach:**
- ✅ SolidQueue for background jobs
- ✅ SolidCache for caching
- ✅ SolidCable for WebSockets
</team-rule-enforcement>
```

---

## 7. Superpowers Integration

### 7.1 Plugin Dependency

**Add to .claude-plugin/plugin.json:**

```json
{
  "name": "rails-ai",
  "version": "0.3.0",
  "author": {
    "name": "zerobearing2",
    "email": "your-email@example.com"
  },
  "description": "Rails development skills library with TDD, testing, security patterns, and team rules for Rails 8+",
  "dependencies": {
    "superpowers": "^3.0.0"
  },
  "repository": "https://github.com/zerobearing2/rails-ai",
  "license": "MIT",
  "keywords": [
    "rails",
    "ruby",
    "skills",
    "tdd",
    "testing",
    "security",
    "hotwire",
    "tailwind"
  ]
}
```

### 7.2 What Rails-AI Reuses from Superpowers

**REUSE (Don't Reimplement):**

**Orchestration & Workflow:**
- ✅ superpowers:brainstorming (design refinement)
- ✅ superpowers:writing-plans (plan creation)
- ✅ superpowers:executing-plans (batch execution)
- ✅ superpowers:subagent-driven-development (task-by-task with review)
- ✅ superpowers:dispatching-parallel-agents (parallel coordination)

**Process Enforcement:**
- ✅ superpowers:test-driven-development (TDD discipline)
- ✅ superpowers:verification-before-completion (evidence before claims)
- ✅ superpowers:systematic-debugging (4-phase framework)

**Code Review:**
- ✅ superpowers:requesting-code-review (review workflow)
- ✅ superpowers:code-reviewer (agent)

**Meta:**
- ✅ superpowers:using-superpowers (skill usage discipline)
- ✅ superpowers:writing-skills (skill creation with TDD)

### 7.3 What Rails-AI Implements (Domain-Specific)

**IMPLEMENT (Rails Knowledge):**

**Rails Skills (keep/enhance):**
- ✅ rails-ai:tdd-minitest (Minitest patterns)
- ✅ rails-ai:hotwire-* (Hotwire/Turbo/Stimulus)
- ✅ rails-ai:activerecord-patterns (ActiveRecord)
- ✅ rails-ai:controller-restful (Controllers/routes)
- ✅ rails-ai:security-* (Rails security)
- ✅ rails-ai:solid-stack (Rails 8 Solid Stack)
- ✅ rails-ai:tailwind, rails-ai:daisyui (CSS frameworks)

**NEW Rails Skills:**
- ➕ rails-ai:debugging-rails (Rails debugging tools)

**Governance:**
- ✅ TEAM_RULES.md (Rails team rules)
- ✅ ARCHITECT_DECISIONS.yml (Rails decisions)

### 7.4 Integration Patterns in Skills

**Pattern: Superpowers for PROCESS + Rails-AI for IMPLEMENTATION**

**Example 1: Testing**
```markdown
# rails-ai:tdd-minitest/SKILL.md

<superpowers-integration>
**REQUIRED BACKGROUND:** superpowers:test-driven-development
  - Defines RED-GREEN-REFACTOR process
  - Enforces "NO CODE WITHOUT FAILING TEST"
  - This skill adds Rails/Minitest implementation
</superpowers-integration>

[Rails-specific Minitest patterns follow]
```

**Example 2: Debugging**
```markdown
# rails-ai:debugging-rails/SKILL.md

<superpowers-integration>
**REQUIRED BACKGROUND:** superpowers:systematic-debugging
  - Defines 4-phase investigation framework
  - This skill provides Rails debugging tools
</superpowers-integration>

[Rails logs, console, byebug, SQL logging]
```

**Example 3: Planning** (if creating rails-ai:planning-rails)
```markdown
# rails-ai:planning-rails/SKILL.md

<superpowers-integration>
**REQUIRED BACKGROUND:** superpowers:writing-plans
  - Defines bite-sized task methodology
  - This skill provides Rails file structure patterns
</superpowers-integration>

[Rails-specific task patterns: Migration → Model → Test]
```

### 7.5 Architect Integration with Superpowers

**Refactored architect.md workflow selection:**

```markdown
## Workflow Selection (Reference Superpowers)

Analyze request and select appropriate workflow:

### Design Phase (Rough Idea → Design)
**Use superpowers:brainstorming**

Rails-AI additions:
1. Load relevant rails-ai skills for context:
   - rails-ai:hotwire-turbo (if Turbo feature)
   - rails-ai:activerecord-patterns (if data model)
   - rails-ai:tailwind (if UI styling)
2. Query Context7 for current Rails/gem docs
3. Document design to docs/plans/YYYY-MM-DD-<topic>-design.md

### Planning Phase (Design → Implementation Plan)
**Use superpowers:writing-plans**

Rails-AI additions:
1. Reference rails-ai skills in plan tasks:
   - "@rails-ai:tdd-minitest for testing approach"
   - "@rails-ai:hotwire-turbo for Turbo features"
2. Include exact Rails file paths:
   - Models: app/models/<resource>.rb
   - Controllers: app/controllers/<resource>_controller.rb
   - Components: app/components/<name>_component.rb
   - Tests: test/<type>/<path>_test.rb
3. Save to docs/plans/YYYY-MM-DD-<feature>-plan.md

### Execution Phase (Plan → Implementation)
**Choose execution style:**

**Option 1: Batch with checkpoints**
- Use superpowers:executing-plans
- Delegate to @backend/@frontend/@tests with rails-ai skills

**Option 2: Fast iteration with review**
- Use superpowers:subagent-driven-development
- Review against TEAM_RULES.md + Rails conventions

### Debugging Phase (Issues → Root Cause → Fix)
**Use superpowers:systematic-debugging**

Rails-AI additions:
1. Load rails-ai:debugging-rails for Rails tools
2. Delegate to @debug agent with Rails context

### Review Phase (Work → Verification)
**Use superpowers:requesting-code-review**
- Review against TEAM_RULES.md + Rails conventions

**Use superpowers:verification-before-completion**
- Run bin/ci before success claims

## Parallel Coordination
**Use superpowers:dispatching-parallel-agents**

Rails application:
- Task("Fix users_controller_test.rb", agent: @backend)
- Task("Fix button_component_test.rb", agent: @frontend)
- All run concurrently
```

---

## 8. Testing Transformation

### 8.1 Current Testing Infrastructure

**Test Suite Overview:**
- 56 test files total
- Unit tests (48 files): Structure validation
- Integration tests (2 files): End-to-end behavior

### 8.2 Test Migration Strategy

#### **Phase 1: Adapt Unit Tests**

**Current:**
```ruby
class TddMinitestTest < SkillTestCase
  self.skill_domain = "testing"
  self.skill_name = "tdd-minitest"

  def test_skill_file_exists
    assert skill_file_exists?("testing", "tdd-minitest")
  end
end
```

**Migrated:**
```ruby
class TddMinitestTest < SkillTestCase
  self.skill_name = "rails-ai:tdd-minitest"
  self.skill_directory = "tdd-minitest"

  def test_skill_directory_exists
    assert Dir.exist?(skill_path) # skills/tdd-minitest/
  end

  def test_has_skill_md_file
    assert File.exist?(skill_file_path) # skills/tdd-minitest/SKILL.md
  end

  def test_has_minimal_frontmatter
    assert_match /^---\nname: rails-ai:tdd-minitest\n/, frontmatter
    assert_match /description: /, frontmatter
  end

  def test_references_superpowers
    assert_match /superpowers:test-driven-development/, skill_content
  end

  private

  def skill_path
    File.join("skills", skill_directory)
  end

  def skill_file_path
    File.join(skill_path, "SKILL.md")
  end
end
```

**Note:** Directory name (`tdd-minitest`) differs from skill name (`rails-ai:tdd-minitest`)

**New validations:**
- Check for SKILL.md (not domain/name.md)
- Validate minimal frontmatter
- Verify superpowers references where appropriate
- No domain checks (flat namespace)

#### **Phase 2: Integration Tests**

**Keep existing, update agent references:**
```ruby
# test/integration/bootstrap_test.rb

def test_architect_can_coordinate
  # Architect now references superpowers workflows
  response = invoke_agent("@architect", "Create a User model")

  # Should reference superpowers:writing-plans
  assert_match /superpowers:writing-plans/, response

  # Should load rails-ai skills
  assert_match /rails-ai:tdd-minitest/, response
end
```

---

## 9. Technical Implementation

### 9.1 SessionStart Hook

**Create hooks/session-start.sh:**

```bash
#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INTRO_FILE="$PLUGIN_ROOT/skills/using-rails-ai/SKILL.md"

if [ ! -f "$INTRO_FILE" ]; then
  echo '{"error": "using-rails-ai/SKILL.md not found"}' >&2
  exit 1
fi

CONTENT=$(cat "$INTRO_FILE")

# Escape for JSON
CONTENT=$(echo "$CONTENT" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}')

# Output JSON
cat << EOF
{
  "event": "session-start",
  "context": "Rails-AI loaded - domain layer on Superpowers workflows. Use @architect for Rails development.",
  "content": "$CONTENT"
}
EOF

exit 0
```

**Create hooks/hooks.json:**

```json
{
  "SessionStart": "./session-start.sh"
}
```

**Make executable:**
```bash
chmod +x hooks/session-start.sh
```

### 9.2 using-rails-ai Meta Skill

**Create skills/using-rails-ai/SKILL.md:**

```markdown
---
name: using-rails-ai
description: Rails-AI introduction - explains how rails-ai (Rails domain layer) integrates with superpowers (universal workflows) for Rails development
---

# Using Rails-AI: Rails Domain Layer on Superpowers Workflows

## What is Rails-AI?

Rails-AI provides **Rails-specific domain knowledge** that integrates with **Superpowers universal workflows**.

**Two-Layer Architecture:**

```
┌─────────────────────────────────────────┐
│ RAILS-AI (Domain Layer)                 │
│ - Rails patterns (Hotwire, AR, etc.)    │
│ - TEAM_RULES.md enforcement             │
│ - Rails debugging tools                 │
│ - Context7 Rails docs integration       │
└─────────────────────────────────────────┘
           ↓ uses
┌─────────────────────────────────────────┐
│ SUPERPOWERS (Workflow Layer)            │
│ - brainstorming, planning, executing    │
│ - TDD, debugging, verification          │
│ - Code review, parallelization          │
└─────────────────────────────────────────┘
```

## When to Use Rails-AI

**Use Rails-AI for:**
- ✅ Rails patterns (Hotwire, ActiveRecord, Tailwind)
- ✅ Rails debugging (logs, console, byebug)
- ✅ TEAM_RULES.md enforcement (Solid Stack, Minitest, REST, TDD)
- ✅ Rails file structure knowledge

**Use Superpowers for:**
- ✅ Design refinement (brainstorming)
- ✅ Implementation planning (writing-plans)
- ✅ Execution workflows (executing-plans, subagent-driven-development)
- ✅ TDD process (test-driven-development)
- ✅ Debugging process (systematic-debugging)
- ✅ Code review (requesting-code-review)

## Typical Rails Workflow

**User:** "I need a user authentication system"

**Architect coordinates:**

1. **Design Phase:**
   - Use superpowers:brainstorming (Socratic questioning)
   - Load rails-ai:solid-stack, rails-ai:activerecord-patterns for context
   - Query Context7 for current Rails auth patterns
   - Document to docs/plans/YYYY-MM-DD-auth-design.md

2. **Planning Phase:**
   - Use superpowers:writing-plans (bite-sized TDD tasks)
   - Reference rails-ai:tdd-minitest, rails-ai:activerecord-patterns in tasks
   - Include exact Rails paths (app/models/user.rb, test/models/user_test.rb)
   - Save to docs/plans/YYYY-MM-DD-auth-plan.md

3. **Execution Phase:**
   - Use superpowers:subagent-driven-development (fast iteration + review)
   - Delegate to @backend with rails-ai skills
   - Each task: RED-GREEN-REFACTOR (superpowers:TDD process + rails-ai:tdd-minitest patterns)
   - Review with superpowers:code-reviewer against TEAM_RULES.md

4. **Verification:**
   - Use superpowers:verification-before-completion
   - Run bin/ci (all quality gates)
   - Confirm evidence before success claim

## Available Rails-AI Skills

**Frontend (9 skills - ViewComponent removed):**
- rails-ai:hotwire-turbo, rails-ai:turbo-morph, rails-ai:hotwire-stimulus
- rails-ai:tailwind, rails-ai:daisyui
- rails-ai:view-helpers, rails-ai:forms-nested
- rails-ai:accessibility, rails-ai:partials

**Backend (10 skills):**
- rails-ai:controller-restful, rails-ai:activerecord-patterns
- rails-ai:form-objects, rails-ai:query-objects
- rails-ai:concerns-models, rails-ai:concerns-controllers
- rails-ai:custom-validators, rails-ai:action-mailer
- rails-ai:nested-resources, rails-ai:antipattern-fat-controllers

**Testing (5 skills):**
- rails-ai:tdd-minitest (+ superpowers:test-driven-development)
- rails-ai:fixtures, rails-ai:minitest-mocking
- rails-ai:test-helpers, rails-ai:model-testing

**Security (6 skills):**
- rails-ai:security-xss, rails-ai:security-sql-injection, rails-ai:security-csrf
- rails-ai:security-strong-params, rails-ai:security-file-uploads, rails-ai:security-command-injection

**Config (6 skills):**
- rails-ai:solid-stack, rails-ai:docker, rails-ai:rubocop
- rails-ai:initializers, rails-ai:credentials, rails-ai:environment-config

**Debugging (1 skill):**
- rails-ai:debugging-rails (+ superpowers:systematic-debugging)

## TEAM_RULES.md Enforcement

**6 Critical Rules (REJECT violations):**
1. ❌ NEVER Sidekiq/Redis → ✅ SolidQueue/SolidCache
2. ❌ NEVER RSpec → ✅ Minitest only
3. ❌ NEVER custom routes → ✅ RESTful resources
4. ❌ NEVER skip TDD → ✅ RED-GREEN-REFACTOR
5. ❌ NEVER merge without bin/ci → ✅ All quality gates pass
6. ❌ NEVER WebMock bypass → ✅ Mock all HTTP in tests

See rules/TEAM_RULES.md for all 20 rules.

## Getting Started

**Entry point:** @architect
- Analyzes requests
- Loads relevant rails-ai skills
- References superpowers workflows
- Delegates to specialized agents (@backend, @frontend, @tests, @security, @debug)
- Enforces TEAM_RULES.md
- Queries Context7 for current Rails/gem docs

**Example:**
```
User: "Add email validation to User model"

@architect:
1. Determines this is backend work
2. References superpowers:test-driven-development for TDD process
3. Loads rails-ai:tdd-minitest for Rails/Minitest patterns
4. Loads rails-ai:activerecord-patterns for validation patterns
5. Delegates to @backend with context
6. @backend follows TDD: write test → RED → implement → GREEN → refactor
7. Reviews with superpowers:code-reviewer against TEAM_RULES.md
```

## Learn More

**Superpowers skills:** Use superpowers:using-superpowers for full introduction
**Rails-AI rules:** See rules/TEAM_RULES.md
**Context7 docs:** Architect queries automatically for current Rails/gem patterns
```

---

## 10. Execution Roadmap

### 10.1 Phase 1: Foundation (Week 1)

**Day 1-2: Setup & Superpowers Integration**

**Tasks:**
- [ ] Create `feature/refactor-skills` branch
- [ ] Create directory structure:
  ```bash
  mkdir -p skills-new hooks agents-refactored test-new
  ```
- [ ] **Add superpowers dependency to plugin.json**
- [ ] Create SessionStart hook (hooks/session-start.sh, hooks/hooks.json)
- [ ] Create using-rails-ai meta skill
- [ ] Write transformation scripts (bin/transform-skill.rb)
- [ ] Update .gitignore

**Success Criteria:**
- [ ] Superpowers dependency added
- [ ] Hooks functional
- [ ] using-rails-ai skill created
- [ ] Scripts executable

**Time:** 16 hours

---

**Day 3-4: Architect Refactoring & Pilot Skills**

**Tasks:**
- [ ] **Refactor architect.md:**
  - [ ] Remove orchestration details (reference superpowers instead)
  - [ ] Keep Rails-specific knowledge (TEAM_RULES.md, Context7)
  - [ ] Add workflow selection (superpowers:brainstorming, writing-plans, etc.)
  - [ ] Reduce from 1,192 lines to ~400 lines
- [ ] Transform 5 pilot skills:
  1. rails-ai:tdd-minitest (+ superpowers reference)
  2. rails-ai:controller-restful
  3. rails-ai:hotwire-turbo
  4. rails-ai:security-xss
  5. rails-ai:solid-stack
- [ ] Create rails-ai:debugging-rails (NEW skill)
- [ ] Manual review of transformed skills
- [ ] Test architect references superpowers workflows

**Success Criteria:**
- [ ] Architect refactored (~400 lines)
- [ ] Architect successfully references superpowers workflows
- [ ] 5 pilot skills transformed with superpowers references
- [ ] rails-ai:debugging-rails created
- [ ] Claude can discover skills

**Time:** 16 hours

---

**Day 5: Testing & Validation**

**Tasks:**
- [ ] Create unit tests for new structure
- [ ] Test superpowers integration (architect uses superpowers workflows)
- [ ] Test skill discovery
- [ ] Test SessionStart hook
- [ ] Document issues/adjustments

**Success Criteria:**
- [ ] Unit tests pass
- [ ] Superpowers workflows accessible from architect
- [ ] Skills discoverable
- [ ] Hook loads using-rails-ai

**Time:** 8 hours

**Phase 1 Total:** 40 hours

---

### 10.2 Phase 2: Bulk Migration (Week 2)

**Day 1: Frontend Skills (13 skills)**

**Tasks:**
- [ ] Transform all frontend skills
- [ ] Add superpowers references where appropriate (minimal - most are Rails-specific)
- [ ] Update cross-references to new names
- [ ] Create unit tests
- [ ] Run tests

**Time:** 8 hours

---

**Day 2: Backend Skills (10 skills)**

**Tasks:**
- [ ] Transform all backend skills
- [ ] Add superpowers references where appropriate
- [ ] Update cross-references
- [ ] Create unit tests
- [ ] Run tests

**Time:** 8 hours

---

**Day 3: Testing + Security Skills (12 skills)**

**Tasks:**
- [ ] Transform testing skills (ADD superpowers:test-driven-development references)
- [ ] Transform security skills
- [ ] Update cross-references
- [ ] Create unit tests
- [ ] Run tests

**Time:** 8 hours

---

**Day 4: Config Skills (6 skills) + Plan Agent**

**Tasks:**
- [ ] Transform config skills
- [ ] Review plan agent (keep as-is or refactor to reference superpowers?)
- [ ] Update cross-references
- [ ] Create unit tests
- [ ] Run tests

**Time:** 8 hours

---

**Day 5: Test Adaptation & Documentation**

**Tasks:**
- [ ] Adapt all 56 skill unit tests
- [ ] Update test helper modules
- [ ] Update README.md (emphasize superpowers integration)
- [ ] Create docs/migration-v0.3.md
- [ ] Update docs/superpowers-integration.md (NEW)

**Success Criteria:**
- [ ] All 42 skill tests passing
- [ ] Documentation complete
- [ ] Superpowers integration documented

**Time:** 8 hours

**Phase 2 Total:** 40 hours

---

### 10.3 Phase 3: Integration & Validation (Week 3)

**Day 1-2: Superpowers Integration Testing**

**Tasks:**
- [ ] Test architect → superpowers:brainstorming flow
- [ ] Test architect → superpowers:writing-plans flow
- [ ] Test architect → superpowers:executing-plans flow
- [ ] Test architect → superpowers:systematic-debugging flow
- [ ] Test architect → superpowers:requesting-code-review flow
- [ ] Test skills referencing superpowers (rails-ai:tdd-minitest → superpowers:TDD)
- [ ] Test SessionStart hook loads using-rails-ai
- [ ] Verify superpowers dependency works

**Success Criteria:**
- [ ] Architect successfully uses all superpowers workflows
- [ ] Skills correctly reference superpowers backgrounds
- [ ] No circular dependencies
- [ ] Superpowers + rails-ai work together

**Time:** 16 hours

---

**Day 3: Rules & Quality**

**Tasks:**
- [ ] Test critical rules enforcement (all 6)
- [ ] Test skill → rule linkage
- [ ] Test rule → skill linkage
- [ ] Run RuboCop, shellcheck
- [ ] Run bin/ci
- [ ] Fix quality issues

**Time:** 8 hours

---

**Day 4-5: Beta Testing**

**Tasks:**
- [ ] Create beta testing guide (with superpowers requirements)
- [ ] Recruit 3-5 beta testers (must have superpowers installed)
- [ ] Deploy to test branch
- [ ] Monitor beta usage
- [ ] Collect feedback on superpowers integration
- [ ] Identify critical issues

**Success Criteria:**
- [ ] 3+ beta testers active
- [ ] Superpowers integration validated
- [ ] Feedback collected
- [ ] Critical issues identified

**Time:** 16 hours

**Phase 3 Total:** 40 hours

---

### 10.4 Phase 4: Cutover & Cleanup (Week 4)

**Day 1: Final Fixes**

**Tasks:**
- [ ] Address all critical beta issues
- [ ] Fix failing tests
- [ ] Update changelog (emphasize superpowers integration)
- [ ] Final code review
- [ ] Tag release candidate: v0.3.0-rc1

**Time:** 8 hours

---

**Day 2: Structure Swap**

**Tasks:**
- [ ] Run final test suite
- [ ] Backup current structure (git tag v0.2-final)
- [ ] Promote new structure (mv skills-new skills, etc.)
- [ ] Update plugin.json version to 0.3.0
- [ ] Commit
- [ ] Test post-swap

**Time:** 4 hours

---

**Day 3: Release**

**Tasks:**
- [ ] Update marketplace listing (mention superpowers dependency)
- [ ] Create GitHub release v0.3.0
- [ ] Write release notes (highlight superpowers integration)
- [ ] Update README.md
- [ ] Post announcement (mention superpowers requirement)

**Time:** 8 hours

---

**Day 4-5: Monitoring & Support**

**Tasks:**
- [ ] Monitor GitHub issues (especially superpowers integration)
- [ ] Respond to bug reports
- [ ] Hot-fix critical issues if needed
- [ ] Create v0.3.1 if needed

**Time:** 16 hours

**Phase 4 Total:** 36 hours

---

### 10.5 Timeline Summary

| Phase | Duration | Key Deliverable | Superpowers Integration |
|-------|----------|----------------|------------------------|
| **Phase 1** | Week 1 | Architect refactored, 5 pilot skills | Architect references workflows |
| **Phase 2** | Week 2 | All 42 skills migrated | Skills reference superpowers |
| **Phase 3** | Week 3 | Integration validated | End-to-end workflow testing |
| **Phase 4** | Week 4 | v0.3.0 released | Production ready |

**Total:** 4 weeks (156 hours)

---

## 11. Risk Assessment & Mitigation

### 11.1 Technical Risks

#### **Risk: Superpowers Not Installed**

**Impact:** CRITICAL
**Probability:** MEDIUM
**Description:** Users install rails-ai without superpowers dependency

**Mitigation:**
- Declare superpowers as dependency in plugin.json
- Check for superpowers in SessionStart hook
- using-rails-ai skill explains requirement
- Clear error message if missing
- Installation docs emphasize superpowers requirement

**Detection:** Phase 3 beta testing

---

#### **Risk: Superpowers Workflow Integration Breaks**

**Impact:** HIGH
**Probability:** LOW
**Description:** Architect can't reference superpowers workflows

**Mitigation:**
- Test all workflow integrations in Phase 3
- Fallback: architect can work without superpowers (degraded mode)
- Document which features require superpowers
- Beta testing validates integration

**Detection:** Phase 3, Day 1-2

---

#### **Risk: Circular Dependencies (rails-ai ↔ superpowers)**

**Impact:** MEDIUM
**Probability:** LOW
**Description:** Rails-AI references superpowers, superpowers references rails-ai (circular)

**Mitigation:**
- Rails-AI references superpowers (one-way only)
- Superpowers is universal (no Rails knowledge)
- Clear layering (Rails-AI = domain, superpowers = workflow)
- Dependency graph validation

**Detection:** Phase 2 design review

---

#### **Risk: XML Tags Confuse Users**

**Impact:** LOW
**Probability:** MEDIUM
**Description:** Contributors unfamiliar with XML tags

**Mitigation:**
- Document XML tag patterns in contributing guide
- Provide skill template with examples
- using-rails-ai explains structure
- Benefits (machine-parseable) outweigh confusion

**Detection:** Post-release feedback

---

### 11.2 Integration Risks

#### **Risk: Superpowers Version Incompatibility**

**Impact:** HIGH
**Probability:** LOW
**Description:** Rails-AI v0.3.0 incompatible with future superpowers updates

**Mitigation:**
- Semantic versioning (^3.0.0 allows minor updates)
- Monitor superpowers releases
- Test against new superpowers versions
- Update dependency range as needed

**Detection:** Continuous monitoring

---

### 11.3 Risk Summary Table

| Risk | Severity | Likelihood | Mitigation Strategy | Responsible |
|------|----------|-----------|-------------------|-------------|
| Superpowers not installed | CRITICAL | MEDIUM | Dependency check, docs | Phase 1 |
| Workflow integration breaks | HIGH | LOW | Test all workflows | Phase 3 |
| Circular dependencies | MEDIUM | LOW | One-way reference only | Phase 2 |
| XML tag confusion | LOW | MEDIUM | Documentation, templates | Ongoing |
| Version incompatibility | HIGH | LOW | Semantic versioning | Continuous |

---

## 12. Rollback Plan

### 12.1 Rollback Decision Points

**When to Rollback:**

1. **Phase 1:** Superpowers integration fundamentally broken → Abandon new structure
2. **Phase 2:** >50% of skills can't be migrated → Pause and redesign
3. **Phase 3:** Superpowers workflows don't work → Rollback and fix
4. **Phase 4:** Critical bugs in production → Immediate rollback

### 12.2 Rollback Procedures

#### **During Phase 1-3 (Before Cutover)**

**Simple Rollback:**
```bash
# Delete new structure
rm -rf skills-new hooks agents-refactored

# Continue using old structure
# No impact on users
```

**Recovery Time:** < 1 hour
**Data Loss:** None (work in separate directories)

---

#### **During Phase 4 (After Cutover)**

**Emergency Rollback:**
```bash
# 1. Revert git commit
git revert HEAD

# 2. Restore legacy structure
git checkout v0.2-final -- agents skills

# 3. Remove new structure
rm -rf hooks

# 4. Update plugin.json (remove superpowers dependency)
git checkout v0.2-final -- .claude-plugin/

# 5. Commit
git commit -m "ROLLBACK: Revert to v0.2 structure"

# 6. Tag emergency release
git tag v0.2.2

# 7. Push
git push origin main --tags
```

**Recovery Time:** < 4 hours

---

## 13. Success Criteria & Validation

### 13.1 Phase-by-Phase Success Metrics

**Phase 1 (Foundation):**
- [ ] Superpowers dependency added
- [ ] Architect refactored (~400 lines, references superpowers)
- [ ] 5 pilot skills transformed
- [ ] rails-ai:debugging-rails created
- [ ] SessionStart hook functional
- [ ] Superpowers workflows accessible

**Phase 2 (Bulk Migration):**
- [ ] All 42 skills migrated
- [ ] Superpowers references added to skills
- [ ] All tests passing
- [ ] Documentation complete

**Phase 3 (Integration & Validation):**
- [ ] Architect successfully uses all superpowers workflows
- [ ] Skills correctly reference superpowers
- [ ] Integration tests passing
- [ ] 3+ successful beta testers

**Phase 4 (Cutover & Release):**
- [ ] v0.3.0 released
- [ ] Marketplace updated (superpowers dependency noted)
- [ ] No critical issues within 48 hours
- [ ] User adoption > 50% within 1 week

---

## Appendices

### Appendix A: Superpowers Workflows Referenced by Architect

| Superpowers Workflow | Rails-AI Usage | When |
|---------------------|---------------|------|
| superpowers:brainstorming | Design refinement + Rails context | Design phase |
| superpowers:writing-plans | Implementation plans + Rails paths | Planning phase |
| superpowers:executing-plans | Batch execution + Rails agents | Execution (batch) |
| superpowers:subagent-driven-development | Fast iteration + Rails review | Execution (fast) |
| superpowers:test-driven-development | TDD process (Rails-AI adds Minitest) | All development |
| superpowers:systematic-debugging | 4-phase framework + Rails tools | Debugging |
| superpowers:requesting-code-review | Review workflow + TEAM_RULES.md | Review phase |
| superpowers:verification-before-completion | Evidence before claims + bin/ci | Verification |
| superpowers:dispatching-parallel-agents | Parallel coordination + Rails agents | Multiple issues |

### Appendix B: Skills That Reference Superpowers

| Rails-AI Skill | References | Type |
|---------------|-----------|------|
| rails-ai:tdd-minitest | superpowers:test-driven-development | REQUIRED BACKGROUND |
| rails-ai:debugging-rails | superpowers:systematic-debugging | REQUIRED BACKGROUND |
| rails-ai:planning-rails (if created) | superpowers:writing-plans | REQUIRED BACKGROUND |

### Appendix C: File Mapping Table

| Current File | New Location | Notes |
|-------------|-------------|-------|
| `agents/architect.md` | `agents/architect.md` | Refactored (~400 lines, references superpowers) |
| `agents/backend.md` + `agents/frontend.md` + `agents/debug.md` | `agents/developer.md` | **MERGED** into full-stack developer |
| `agents/tests.md` | `agents/uat.md` | **RENAMED** - broader QA focus |
| `agents/security.md` | `agents/security.md` | Refactored (references superpowers) |
| `agents/plan.md` | **DELETE** | Use superpowers:writing-plans |
| N/A | `agents/devops.md` | **NEW** - infrastructure/deployment |
| `skills/testing/tdd-minitest.md` | `skills/tdd-minitest/SKILL.md` | Transform, add superpowers ref |
| `skills/backend/controller-restful.md` | `skills/controller-restful/SKILL.md` | Transform, keep XML |
| `skills/frontend/hotwire-turbo.md` | `skills/hotwire-turbo/SKILL.md` | Transform, keep XML |
| `skills/frontend/viewcomponent-*.md` (4 files) | **DELETE** | Not using yet, defer to future |
| N/A | `skills/debugging-rails/SKILL.md` | **NEW** |
| N/A | `skills/using-rails-ai/SKILL.md` | **NEW** (meta skill) |
| `skills/SKILLS_REGISTRY.yml` | **DELETE** | Replaced by directory discovery |
| `.claude-plugin/marketplace.json` | `.claude-plugin/marketplace.json` | Update version |
| N/A | `.claude-plugin/plugin.json` | **NEW** (with superpowers dependency) |
| N/A | `hooks/session-start.sh` | **NEW** |
| N/A | `hooks/hooks.json` | **NEW** |

**Key Pattern:**
- Directory: `skills/tdd-minitest/SKILL.md` (NO prefix in path)
- Frontmatter: `name: rails-ai:tdd-minitest` (WITH prefix in name field)

---

## Conclusion

This migration plan transforms rails-ai into a **Rails domain layer on top of Superpowers universal workflows**, creating a powerful, composable system:

**Key Principles:**
1. **Leverage, don't reimplement** - Use superpowers for orchestration
2. **Preserve functionality** - All Rails knowledge intact
3. **Maintain quality** - XML tags, TEAM_RULES.md, testing
4. **Validate incrementally** - Test superpowers integration at each phase
5. **Enable rollback** - Always have an escape hatch

**Positioning:**
- **Superpowers** = Universal workflows (brainstorming, TDD, debugging, review)
- **Rails-AI** = Rails patterns (Hotwire, ActiveRecord, Tailwind, security)
- **Together** = Complete Rails development system

**Next Steps:**
1. Review and approve this plan
2. Ensure superpowers plugin installed
3. Create `feature/refactor-skills` branch
4. Begin Phase 1: Foundation (Week 1)

---

**Document Version:** 3.0
**Last Updated:** 2025-11-15
**Status:** Ready for Review
**Key Changes:**
- Integrated superpowers workflows
- Kept architect as agent (not /rails command)
- Preserved XML tags for machine-parseability
- Reorganized 7 agents → 5 domain-based agents (architect, developer, security, devops, uat)
- Removed plan agent (use superpowers:writing-plans)
- Removed 4 ViewComponent skills (not using yet)
- 33 total skills (37 existing - 4 ViewComponent + 1 new using-rails-ai - 1 removed debugging placeholder)
- **Skill directory naming:** NO prefix in directory names (e.g., `skills/tdd-minitest/`), WITH prefix in frontmatter name field (e.g., `name: rails-ai:tdd-minitest`)
