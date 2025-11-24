---
description: Comprehensive code review using parallel specialized agents
allowed-tools: Bash(git *), Bash(gh *), Glob, Grep, Read, Task
---

# Rails-AI Code Review

Multi-agent code review with 3 parallel reviewers: security-and-rules, implementation, and UI/Hotwire.

## Superpowers Workflows

**Always:**
- `superpowers:finishing-a-development-branch` — present merge/PR/cleanup options after review

**If Critical or Important issues found:**
- `superpowers:dispatching-parallel-agents` — fix multiple independent issues concurrently (via `/rails-ai:feature`)

## Process

### Step 1: Detect Review Scope

Determine what to review based on arguments:

```
{{ARGS}} provided?
├── Contains github.com PR URL → Extract PR number, use `gh pr diff`
├── Contains branch name → use `git diff main...{branch}`
├── Empty and on feature branch → use `git diff main...HEAD`
└── Empty and on main → use `git diff HEAD` (uncommitted changes)
```

Run these commands to gather context:

```bash
# Detect current branch
git branch --show-current

# Check if on main/master
git rev-parse --verify main 2>/dev/null || git rev-parse --verify master

# Get diff (adjust based on scope detection)
git diff --stat [range]
git diff [range]

# Get changed files
git diff --name-only [range]
```

### Step 2: Analyze Changed Files

Categorize files to determine which agents/skills are needed:

| File Pattern | Domain | Skill to Reference |
|--------------|--------|-------------------|
| `app/models/**` | models | rails-ai:models |
| `app/controllers/**` | controllers | rails-ai:controllers |
| `app/jobs/**` | jobs | rails-ai:jobs |
| `app/mailers/**` | mailers | rails-ai:mailers |
| `app/views/**` | ui | rails-ai:ui |
| `app/components/**` | ui | rails-ai:ui |
| `app/javascript/**` | hotwire | rails-ai:hotwire |
| `*_controller.js` | hotwire | rails-ai:hotwire |
| `**/*.css`, `**/*.scss` | styling | rails-ai:styling |
| `test/**` | testing | rails-ai:testing |

### Step 3: Dispatch 3 Parallel Review Agents

Use the Task tool to dispatch 3 `@agent-rails-ai:reviewer` agents **in parallel** (single message with 3 Task tool calls):

**Agent 1: Security-and-Rules**
```
Mode: security-and-rules
Task: Review for security vulnerabilities, TEAM_RULES violations, and code quality
Files: [list of changed files]
Context: [diff content]
```

**Agent 2: Implementation**
```
Mode: implementation
Task: Review domain patterns (models, controllers, jobs, mailers) and testing
Files: [list of changed files]
Context: [diff content]
```

**Agent 3: UI/Hotwire** (only if frontend files changed)
```
Mode: ui
Task: Review UI patterns (views, Hotwire, styling)
Files: [list of changed files]
Context: [diff content]
Skip if: No files in app/views, app/components, app/javascript, or CSS files
```

**Dispatch Template:**

For each agent, use the Task tool with:
- subagent_type: `@agent-rails-ai:reviewer`
- prompt: |
    Mode: [security-and-rules | implementation | ui]
    Task: [what to review]
    Files: [list of changed files]
    Context:
    ```diff
    [diff content]
    ```

The `@agent-rails-ai:reviewer` agent will automatically load its instructions and relevant skills based on the mode.

### Step 4: Consolidate Findings

Collect findings from all agents and:

1. **Parse** each agent's YAML output
2. **Dedupe** - Same file:line + similar issue = keep one, note "flagged by multiple agents"
3. **Sort** by severity: critical → important → minor
4. **Format** with tags

### Step 5: Generate Verdict

Based on findings:
- **Critical issues exist** → "No - X Critical issues must be fixed"
- **Only Important/Minor** → "With fixes - X Important issues should be addressed"
- **Clean** → "Yes - No significant issues found"

### Step 6: Present Output

Format the consolidated review:

```markdown
## Rails-AI Code Review

**Scope:** [describe what was reviewed]
**Files reviewed:** X files changed (+Y, -Z)
**Agents run:** [list agents that ran]

---

### Critical (Must Fix)

1. **[TAG] Issue title**
   - File: path/to/file.rb:line
   - Issue: Description of the problem
   - Fix: How to fix it

### Important (Should Fix)

2. **[TAG] Issue title**
   - File: path/to/file.rb:line
   - Issue: Description
   - Fix: Solution

### Minor (Nice to Have)

3. **[TAG] Issue title**
   - File: path/to/file.rb:line
   - Issue: Description
   - Fix: Solution

---

### Verdict

**Ready to merge:** [Yes | No | With fixes]

**Summary:** [1-2 sentence summary of findings]
```

### Step 7: Present Next Actions

Use `superpowers:finishing-a-development-branch` to guide next steps.

**If Critical or Important issues found:**

Present fix options first:

> **Issues to address:**
>
> 1. **Fix issues** - Use `/rails-ai:feature` to fix with proper skill loading
> 2. **Help me fix [issue]** - Get help fixing a specific issue
> 3. **Discuss [issue]** - Challenge or clarify a finding

If user chooses option 1, invoke `/rails-ai:feature` with a summary of issues to fix:
```
/rails-ai:feature Fix review findings: [list critical/important issues]
```

This ensures fixes are done via subagents with proper Rails-AI skills loaded.
Note: Use `feature` not `refactor` since refactor expects stable baseline (passing tests).

**If only Minor issues or clean:**

Use `superpowers:finishing-a-development-branch` to present completion options:
- Merge to main
- Create PR (draft or ready)
- Continue working
- Cleanup/abandon

---

## Quick Reference

**Tags used in findings:**
- `[SECURITY]` - Security vulnerabilities
- `[RULE #N]` - TEAM_RULES violations (with rule number)
- `[QUALITY]` - General code quality issues
- `[MODELS]` - Model pattern violations
- `[CONTROLLERS]` - Controller pattern violations
- `[JOBS]` - Background job issues
- `[MAILERS]` - Mailer issues
- `[TESTING]` - Test quality issues
- `[UI]` - View/component issues
- `[HOTWIRE]` - Turbo/Stimulus issues
- `[STYLING]` - CSS/Tailwind issues

**Severity levels:**
- **Critical** - Must fix before merge (security, critical rule violations, bugs)
- **Important** - Should fix (high-severity rules, missing tests, poor patterns)
- **Minor** - Nice to have (style, suggestions, optimizations)

---

**Now execute the review for: {{ARGS}}**
