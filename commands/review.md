---
description: Comprehensive code review using parallel specialized agents
allowed-tools: Bash(git *), Bash(gh *), Glob, Grep, Read, Task
---

# Rails-AI Code Review

Multi-agent code review checking security, TEAM_RULES, domain patterns, testing, and UI/Hotwire.

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

### Step 3: Dispatch 5 Parallel Review Agents

Use the Task tool to dispatch 5 `rails-ai:reviewer` agents in parallel:

**Agent 1: Security**
```
Role: security
Task: Review for XSS, SQL injection, CSRF, file upload, command injection vulnerabilities
```

**Agent 2: Rules + Quality**
```
Role: rules
Task: Review against all 20 TEAM_RULES + general code quality (architecture, error handling, DRY)
```

**Agent 3: Domain**
```
Role: domain
Task: Review against domain-specific patterns based on changed file types
Inject: Relevant skill content for models/controllers/jobs/mailers
```

**Agent 4: Testing**
```
Role: testing
Task: Review test quality, TDD compliance, fixtures, mocking patterns
```

**Agent 5: UI/Hotwire** (only if frontend files changed)
```
Role: ui
Task: Review Turbo patterns, Stimulus, ViewComponent, styling, accessibility
Skip if: No files in app/views, app/components, app/javascript, or CSS files
```

**Dispatch Template:**

For each agent, use the Task tool with:
- subagent_type: `general-purpose`
- prompt: Include the reviewer agent content from `agents/reviewer.md` with:
  - The role set (security, rules, domain, testing, ui)
  - The diff content
  - The list of changed files
  - Any additional skill content for domain/ui roles

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

Based on the verdict, present options:

**If Critical or Important issues found:**

> What would you like to do next?
>
> 1. **Fix issues** - Use `/rails-ai:refactor` to fix with proper skill loading
> 2. **Help me fix [issue]** - Get help fixing a specific issue
> 3. **Discuss [issue]** - Challenge or clarify a finding

If user chooses option 1, invoke `/rails-ai:refactor` with a summary of issues to fix:
```
/rails-ai:refactor Fix review findings: [list critical/important issues]
```

This ensures fixes are done via subagents with proper Rails-AI skills loaded.

**If only Minor issues or clean:**

> What would you like to do next?
>
> 1. **Create PR** - Run `gh pr create --draft`
> 2. **Commit changes** - Commit the reviewed changes
> 3. **Mark PR ready** - Run `gh pr ready`
> 4. **Run bin/ci** - Final verification before merge

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
