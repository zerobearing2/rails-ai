# Enhanced Rails-AI Review Command Design

**Date:** 2025-01-23
**Status:** Ready for implementation

---

## Problem Statement

The current `rails-ai:review` command doesn't delegate rails-ai skills to the subagent. Reviews miss skill-specific checks (security patterns, model conventions, Hotwire best practices) because the code-reviewer agent doesn't receive that context.

## Solution Overview

Replace the current review command with a parallel multi-agent architecture:
- **1 reusable reviewer agent** with 5 roles
- **1 orchestrating command** that dispatches agents in parallel
- **Comprehensive coverage** of security, TEAM_RULES, domain skills, testing, and UI

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scope coverage | Both rails-ai skills AND TEAM_RULES | Comprehensive review |
| Agent architecture | Parallel specialized agents | Thoroughness over simplicity |
| Number of agents | 3 (security-and-rules, implementation, ui) | **FINAL: 40% cost savings while maintaining coverage** |
| Output format | Severity-based with category tags | Easy prioritization + clear source |
| Trigger method | `/rails-ai:review` standalone | Self-contained, simple |
| Git range detection | Smart detection with fallbacks | Flexible, minimal user input |
| Agent structure | 1 agent with mode parameter | Clean, reusable, minimal files |
| Post-review flow | Present next actions | Guided workflow closure |

**Note:** Initial design specified 5 agents (security, rules, domain, testing, ui) for maximum coverage. During implementation, consolidated to 3 modes for 40% cost reduction: security-and-rules (combines security + TEAM_RULES + quality), implementation (combines domain + testing patterns), and ui (unchanged). This maintains comprehensive coverage while significantly reducing review costs.

---

## Architecture

### File Structure

```
agents/
└── reviewer.md        # Single agent, accepts mode parameter

commands/
└── review.md          # Orchestrates 3 parallel reviewer calls
```

### Flow

```
User runs /rails-ai:review [optional: PR URL or branch]
                    │
                    ▼
        ┌───────────────────────┐
        │  1. Detect Scope      │
        │  - PR URL → PR diff   │
        │  - Branch → vs main   │
        │  - Feature branch →   │
        │    vs main            │
        │  - Else → uncommitted │
        └───────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  2. Get Diff & Files  │
        │  - git diff content   │
        │  - list changed files │
        └───────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  3. Analyze Files     │
        │  - Determine relevant │
        │    domain skills      │
        │  - Check if frontend  │
        │    files changed      │
        └───────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  4. Dispatch 5 Agents │
        │     (in parallel)     │
        └───────────────────────┘
                    │
    ┌───────┬───────┼───────┬───────┐
    ▼       ▼       ▼       ▼       ▼
┌───────┐┌───────┐┌───────┐┌───────┐┌───────┐
│Security││Rules  ││Domain ││Testing││UI     │
│Agent  ││Agent  ││Agent  ││Agent  ││Agent  │
└───────┘└───────┘└───────┘└───────┘└───────┘
    │       │       │       │       │
    └───────┴───────┼───────┴───────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  5. Consolidate       │
        │  - Dedupe findings    │
        │  - Sort by severity   │
        │  - Add category tags  │
        └───────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  6. Present Verdict   │
        │  - Ready to merge?    │
        │  - Summary            │
        └───────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  7. Present Next      │
        │     Actions           │
        └───────────────────────┘
```

---

## Agent Specification

### `agents/reviewer.md`

**Inputs:**
- `role`: One of `security`, `rules`, `domain`, `testing`, `ui`
- `diff`: Git diff content
- `files_changed`: List of changed file paths
- `skill_content`: (For domain/ui roles) Relevant skill content to check against

**Role Responsibilities:**

| Role | Checks | Tags |
|------|--------|------|
| `security` | XSS, SQL injection, CSRF, file uploads, command injection | `[SECURITY]` |
| `rules` | All 20 TEAM_RULES + general code quality (architecture, error handling, DRY) | `[RULE #N]`, `[QUALITY]` |
| `domain` | Model patterns, controller conventions, jobs, mailers | `[MODELS]`, `[CONTROLLERS]`, `[JOBS]`, `[MAILERS]` |
| `testing` | TDD compliance, fixtures, WebMock, test structure | `[TESTING]` |
| `ui` | Turbo patterns, Stimulus, ViewComponent, accessibility | `[UI]`, `[HOTWIRE]`, `[STYLING]` |

**Output Format:**
```
FINDINGS:
- severity: critical|important|minor
  tag: "[TAG]"
  file: "path/to/file.rb"
  line: 45
  issue: "Description of the problem"
  fix: "How to fix it"
```

---

## Command Specification

### `commands/review.md`

**Step 1: Parse Arguments**
- If `{{ARGS}}` contains GitHub PR URL → extract PR number, use `gh pr diff`
- If `{{ARGS}}` contains branch name → use `git diff main...branch`
- If on feature branch (not main/master) → use `git diff main...HEAD`
- Else → use `git diff HEAD` (uncommitted changes)

**Step 2: Gather Context**
```bash
# Get diff
git diff [range] > diff_content

# Get changed files
git diff --name-only [range]
```

**Step 3: Determine Skills to Inject**

| File Pattern | Skill to Inject |
|--------------|-----------------|
| `app/models/**` | rails-ai:models |
| `app/controllers/**` | rails-ai:controllers |
| `app/jobs/**` | rails-ai:jobs |
| `app/mailers/**` | rails-ai:mailers |
| `app/views/**`, `app/components/**` | rails-ai:ui |
| `app/javascript/**`, `*_controller.js` | rails-ai:hotwire |
| `**/*.css`, `**/*.scss` | rails-ai:styling |
| `test/**` | rails-ai:testing |

**Step 4: Dispatch Parallel Agents**

Dispatch 5 `rails-ai:reviewer` agents with:
1. `role: security` - Always
2. `role: rules` - Always
3. `role: domain` - With relevant skill content based on file patterns
4. `role: testing` - Always
5. `role: ui` - Only if frontend files changed (views, components, JS, CSS)

**Step 5: Consolidate Findings**
- Collect all agent responses
- Dedupe: Same file:line + similar issue = keep one, note multiple agents flagged
- Sort: Critical → Important → Minor
- Format with tags

**Step 6: Generate Verdict**
- Critical issues exist → "No - X Critical issues must be fixed"
- Only Important/Minor → "With fixes - X Important issues should be addressed"
- Clean → "Yes - No significant issues found"

**Step 7: Present Next Actions**

If Critical/Important issues:
1. "Fix issues and re-run `/rails-ai:review`"
2. "Help me fix [specific issue]"
3. "I disagree with [issue] - let's discuss"

If Minor only or clean:
1. "Create PR" (if reviewing branch)
2. "Commit changes" (if reviewing uncommitted)
3. "Mark PR ready for review" (if reviewing draft PR)
4. "Run `bin/ci` to verify"

---

## Output Format

```markdown
## Rails-AI Code Review

**Scope:** [PR #123 | feature-branch vs main | uncommitted changes]
**Files reviewed:** 12 files changed (+245, -89)
**Agents run:** Security, TEAM_RULES, Models, Controllers, Testing

---

### Critical (Must Fix)

1. **[SECURITY] SQL injection risk in search query**
   - File: app/models/feedback.rb:45
   - Issue: String interpolation in `where` clause
   - Fix: Use parameterized query `where("name LIKE ?", "%#{term}%")`

2. **[RULE #1] Sidekiq gem detected**
   - File: Gemfile:23
   - Issue: Sidekiq violates Solid Stack rule
   - Fix: Use SolidQueue instead

### Important (Should Fix)

3. **[MODELS] Missing validation on user input**
   - File: app/models/feedback.rb:12
   - Issue: `content` field accepts any input without length limit
   - Fix: Add `validates :content, presence: true, length: { maximum: 5000 }`

4. **[TESTING] Test mocks return value instead of testing behavior**
   - File: test/models/feedback_test.rb:34
   - Issue: Stubbing the method under test
   - Fix: Test real behavior, only mock external dependencies

5. **[QUALITY] Error silently swallowed without logging**
   - File: app/services/webhook_sender.rb:28
   - Issue: `rescue => e` with no logging or re-raise
   - Fix: Log error with context: `Rails.logger.error("Webhook failed: #{e.message}")`

### Minor (Nice to Have)

6. **[RULE #16] Single quotes used**
   - File: app/controllers/feedbacks_controller.rb:8
   - Issue: Single quotes instead of double quotes
   - Fix: Run `rake lint:fix` to auto-correct

---

### Verdict

**Ready to merge:** No - 2 Critical issues

**Summary:** Security vulnerability and TEAM_RULES violation must be fixed. Important issues around validation and test quality should be addressed.

---

### What's Next?

1. **Fix issues** - Address Critical issues, then re-run `/rails-ai:review`
2. **Get help** - "Help me fix the SQL injection issue"
3. **Discuss** - "I disagree with [issue] - explain why it's a problem"
```

---

## Embedded Content

The `reviewer.md` agent will have embedded sections for each role:

### Security Role Content
- Embedded from `rails-ai:security` skill
- XSS patterns, SQL injection patterns, CSRF checks, file upload validation, command injection prevention

### Rules Role Content
- Embedded from `TEAM_RULES.md`
- All 20 rules with violation triggers and severity levels
- General code quality checks (from superpowers:code-reviewer patterns):
  - Architecture soundness and separation of concerns
  - Proper error handling with meaningful messages
  - DRY principle - no unnecessary duplication
  - Edge cases handled appropriately
  - No obvious bugs or logic errors

### Domain Role Content
- Dynamically injected based on changed files
- Skill content passed as parameter from orchestrating command

### Testing Role Content
- Embedded from `rails-ai:testing` skill
- TDD patterns, fixture usage, WebMock patterns, test organization

### UI Role Content
- Embedded from `rails-ai:hotwire`, `rails-ai:styling`, `rails-ai:ui` skills
- Turbo patterns, Stimulus conventions, ViewComponent standards, accessibility

---

## Implementation Checklist

- [ ] Create `agents/reviewer.md` with role-based sections
- [ ] Update `commands/review.md` with orchestration logic
- [ ] Test with sample PR/branch/uncommitted changes
- [ ] Verify parallel agent dispatch works
- [ ] Verify deduplication logic
- [ ] Verify next actions flow

---

## Future Enhancements

1. **Integration with superpowers** - Hook into `superpowers:requesting-code-review` for rails-ai projects
2. **Caching** - Cache skill content to reduce prompt size
3. **Configurable severity thresholds** - Allow teams to customize what's Critical vs Important
4. **Auto-fix suggestions** - Generate patch files for simple fixes
