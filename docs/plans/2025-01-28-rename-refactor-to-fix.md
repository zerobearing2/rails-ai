# Rename /refactor to /fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rename `/rails-ai:refactor` command to `/rails-ai:fix` with broader scope (no baseline requirement, behavior change allowed).

**Architecture:** Rename command file, remove `refactor` mode from developer agent, update `fix` mode wording to cover both bugs and code improvements.

**Tech Stack:** Markdown files, Ruby Minitest

---

## Task 1: Update Developer Agent - Remove refactor mode, update fix mode

**Files:**
- Modify: `agents/developer.md`

**Step 1: Update the mode table**

Replace:
```markdown
| Mode | Baseline Required | Behavior Change OK | Use Case |
|------|-------------------|-------------------|----------|
| `feature` | No | Yes (new functionality) | Implementing new features |
| `refactor` | Yes (tests must pass) | No (restructuring only) | Improving existing code |
| `fix` | No | Yes (fixing issues) | Fixing bugs or review findings |
```

With:
```markdown
| Mode | Baseline Required | Behavior Change OK | Use Case |
|------|-------------------|-------------------|----------|
| `feature` | No | Yes (new functionality) | Implementing new features |
| `fix` | No | Yes | Fixing bugs, improving code, addressing review findings |
```

**Step 2: Update mode announcement section**

Replace:
```markdown
**FIRST: Announce your mode to the user:**
- If feature mode: "🚀 Running @agent-rails-ai:developer in FEATURE mode"
- If refactor mode: "🔧 Running @agent-rails-ai:developer in REFACTOR mode"
- If fix mode: "🐛 Running @agent-rails-ai:developer in FIX mode"
```

With:
```markdown
**FIRST: Announce your mode to the user:**
- If feature mode: "🚀 Running @agent-rails-ai:developer in FEATURE mode"
- If fix mode: "🔧 Running @agent-rails-ai:developer in FIX mode"
```

**Step 3: Remove `<mode-refactor>` section entirely**

Delete:
```markdown
<mode-refactor>
**Refactor Mode:**
- Baseline was verified by coordinator (tests pass)
- You are restructuring, NOT changing behavior
- All existing tests must continue to pass
- Make incremental changes, run tests after each
- If tests fail, revert and try smaller steps
</mode-refactor>
```

**Step 4: Update `<mode-fix>` section**

Replace:
```markdown
<mode-fix>
**Fix Mode:**
- No baseline verification needed (things may be broken)
- You're fixing specific issues
- Follow TDD: write test that exposes the bug, then fix
- Changed behavior is expected (that's the fix)
</mode-fix>
```

With:
```markdown
<mode-fix>
**Fix Mode:**
- No baseline verification needed
- You're fixing or improving existing code
- For bugs: write test that exposes the bug, then fix
- For improvements: ensure tests cover the change, then implement
- Changed behavior is allowed when it's the intended improvement
</mode-fix>
```

**Step 5: Update Input section**

Replace:
```markdown
- **Mode:** feature | refactor | fix
```

With:
```markdown
- **Mode:** feature | fix
```

**Step 6: Update Output section**

Replace:
```markdown
mode: feature | refactor | fix
```

With:
```markdown
mode: feature | fix
```

**Step 7: Remove refactor-specific output note**

Delete the entire block:
```markdown
<mode-refactor>
**CRITICAL for Refactor Mode:**
- If behavior changed (tests fail), report `status: failed` immediately
- Do not continue if tests fail after refactoring
</mode-refactor>
```

**Step 8: Run tests to verify changes**

Run: `cd /home/dave/Projects/rails-ai/.worktrees/rename-refactor-to-fix && bin/ci`

Expected: Some tests will fail (developer_test.rb tests for refactor mode)

**Step 9: Commit**

```bash
git add agents/developer.md
git commit -m "refactor: remove refactor mode from developer agent, update fix mode"
```

---

## Task 2: Update Developer Agent Tests

**Files:**
- Modify: `test/unit/agents/developer_test.rb`

**Step 1: Update test_agent_documents_input_format**

Replace:
```ruby
def test_agent_documents_input_format
  assert_match(/Mode:.*feature.*refactor.*fix/im, @content,
               "Agent should document Mode input")
```

With:
```ruby
def test_agent_documents_input_format
  assert_match(/Mode:.*feature.*fix/im, @content,
               "Agent should document Mode input")
```

**Step 2: Remove test_agent_uses_xml_mode_tags refactor assertion**

Replace:
```ruby
def test_agent_uses_xml_mode_tags
  assert_match(/<mode-feature>/i, @content,
               "Agent should have <mode-feature> XML tag")
  assert_match(/<mode-refactor>/i, @content,
               "Agent should have <mode-refactor> XML tag")
  assert_match(/<mode-fix>/i, @content,
               "Agent should have <mode-fix> XML tag")
end
```

With:
```ruby
def test_agent_uses_xml_mode_tags
  assert_match(/<mode-feature>/i, @content,
               "Agent should have <mode-feature> XML tag")
  assert_match(/<mode-fix>/i, @content,
               "Agent should have <mode-fix> XML tag")
end
```

**Step 3: Remove test_agent_defines_refactor_mode**

Delete entire method:
```ruby
def test_agent_defines_refactor_mode
  assert_match(/mode.*refactor/i, @content,
               "Agent should define refactor mode")
end
```

**Step 4: Update test_agent_explains_mode_differences**

Replace:
```ruby
def test_agent_explains_mode_differences
  # Feature: no baseline, new functionality (check table)
  assert_match(/feature.*No.*Yes.*new functionality/im, @content,
               "Feature mode should not require baseline, allow behavior change")

  # Refactor: baseline required, no behavior change (check table)
  assert_match(/refactor.*Yes.*tests must pass.*No.*restructuring/im, @content,
               "Refactor mode should require baseline, not allow behavior change")

  # Fix: no baseline, fixes issues (check table)
  assert_match(/fix.*No.*Yes.*fixing/im, @content,
               "Fix mode should not require baseline, allow behavior change")
end
```

With:
```ruby
def test_agent_explains_mode_differences
  # Feature: no baseline, new functionality (check table)
  assert_match(/feature.*No.*Yes.*new functionality/im, @content,
               "Feature mode should not require baseline, allow behavior change")

  # Fix: no baseline, behavior change allowed (check table)
  assert_match(/fix.*No.*Yes.*Fixing bugs.*improving code/im, @content,
               "Fix mode should not require baseline, allow behavior change")
end
```

**Step 5: Remove test_refactor_mode_requires_behavior_unchanged**

Delete entire method:
```ruby
def test_refactor_mode_requires_behavior_unchanged
  # Check that refactor mode has critical requirement about behavior change
  assert_match(/CRITICAL.*Refactor.*behavior changed.*status: failed/im, @content,
               "Refactor mode should fail if behavior changed")
end
```

**Step 6: Run tests**

Run: `cd /home/dave/Projects/rails-ai/.worktrees/rename-refactor-to-fix && rake test:unit:agents`

Expected: PASS

**Step 7: Commit**

```bash
git add test/unit/agents/developer_test.rb
git commit -m "test: update developer agent tests for two-mode system"
```

---

## Task 3: Rename refactor.md to fix.md and update content

**Files:**
- Rename: `commands/refactor.md` → `commands/fix.md`
- Modify: `commands/fix.md`

**Step 1: Rename file**

```bash
git mv commands/refactor.md commands/fix.md
```

**Step 2: Update YAML front matter**

Replace:
```yaml
---
description: Improve existing code and fill test gaps
---
```

With:
```yaml
---
description: Fix or improve existing code
---
```

**Step 3: Update title and purpose**

Replace:
```markdown
# Rails Refactor Workflow

## Role

You are a **COORDINATOR ONLY** for refactoring work. You **NEVER implement directly**.
```

With:
```markdown
# Rails Fix Workflow

## Role

You are a **COORDINATOR ONLY** for fix/improvement work. You **NEVER implement directly**.
```

**Step 4: Update Coordinator table**

Replace:
```markdown
| Coordinator (You) | Developer Agent (Task tool) |
|-------------------|----------------------------|
| Verify baseline passes | Load skills (with embedded rules) |
| Plan the refactor scope | Write code with TDD |
```

With:
```markdown
| Coordinator (You) | Developer Agent (Task tool) |
|-------------------|----------------------------|
| Plan the fix/improvement scope | Load skills (with embedded rules) |
| Dispatch `@agent-rails-ai:developer` agent | Write code with TDD |
```

**Step 5: Update Purpose section**

Replace:
```markdown
## Purpose

Use this workflow when:
- Improving existing code structure
- Extracting concerns, services, or query objects
- Filling gaps in test coverage
- Cleaning up technical debt
- Improving UI/view code
```

With:
```markdown
## Purpose

Use this workflow when:
- Fixing code quality issues
- Improving existing code structure
- Addressing review feedback
- Filling gaps in test coverage
- Cleaning up technical debt
- Extracting concerns, services, or query objects
```

**Step 6: Update Superpowers section - remove baseline verification**

Replace:
```markdown
**Always:**
- `superpowers:using-git-worktrees` — isolate refactor work
- `superpowers:verification-before-completion` — verify tests pass BEFORE and AFTER refactoring
- `superpowers:finishing-a-development-branch` — merge/PR options

**If refactor has 3+ independent areas:**
- `superpowers:dispatching-parallel-agents` — run independent refactors concurrently
```

With:
```markdown
**Always:**
- `superpowers:using-git-worktrees` — isolate fix work
- `superpowers:verification-before-completion` — verify tests pass after changes
- `superpowers:finishing-a-development-branch` — merge/PR options

**If fix has 3+ independent areas:**
- `superpowers:dispatching-parallel-agents` — run independent fixes concurrently
```

**Step 7: Remove Step 1 (Verify Baseline) entirely**

Delete the entire section:
```markdown
### Step 1: Verify Baseline (CRITICAL - HARD STOP)

**Before anything else, verify tests pass:**

\`\`\`bash
bin/ci
\`\`\`

**If tests fail:** STOP. Do not proceed. Refactoring requires a green baseline.

Tell the user: "Cannot refactor - `bin/ci` is failing. Fix the failing tests first with `/rails-ai:debug`, then retry `/rails-ai:refactor`."

**If tests pass:** Continue to Step 2.
```

**Step 8: Renumber remaining steps (Step 2 becomes Step 1, etc.)**

Update all step numbers throughout the document.

**Step 9: Update Step 1 (was Step 2) - Create Isolated Workspace**

Replace:
```markdown
### Step 2: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for refactor work.
```

With:
```markdown
### Step 1: Create Isolated Workspace

Use `superpowers:using-git-worktrees` to create isolated branch for fix work.
```

**Step 10: Update Step 2 (was Step 3) - Plan the Fix**

Replace:
```markdown
### Step 3: Plan the Refactor

Assess what needs to be refactored:
- What code is being restructured?
- What test coverage exists?
- Do test gaps need filling first?
- What is the expected outcome?
```

With:
```markdown
### Step 2: Plan the Fix

Assess what needs to be fixed or improved:
- What code needs changing?
- What test coverage exists?
- Do test gaps need filling first?
- What is the expected outcome?
```

**Step 11: Update Step 3 (was Step 4) - Dispatch Developer Agent**

Replace all references to `refactor` with `fix`, remove behavior_changed requirements. Update the dispatch example:

Replace:
```markdown
### Step 4: Dispatch Developer Agent (MANDATORY)

**You MUST dispatch refactoring to the `@agent-rails-ai:developer` agent using the Task tool.**

#### Parallel Dispatch for Independent Refactors

Use `superpowers:dispatching-parallel-agents` when the refactor scope includes **3+ independent areas** that:
- Don't share state or dependencies
- Can be refactored without affecting each other
- Touch different files/domains

**Parallel dispatch example:** If refactoring involves extracting 3 different concerns from a large model — and they're independent — dispatch 3 `@agent-rails-ai:developer` agents concurrently in a single message with multiple Task tool calls.

**Sequential dispatch:** If refactors depend on each other (e.g., extracting a concern then using it elsewhere), dispatch one at a time.

**IMPORTANT for refactor mode:** Even with parallel dispatch, each agent must independently verify `behavior_changed: false`. If ANY agent reports behavior changed, stop all work and escalate.

#### Dispatch to Developer Agent

Use the Task tool to dispatch to the `@agent-rails-ai:developer` agent:

\`\`\`
Task tool:
- subagent_type: @agent-rails-ai:developer
- prompt: |
    Mode: refactor
    Task: [What to restructure]
    Files: [Absolute paths needed]
    Context: [Baseline status, expected outcome]

    CRITICAL: Behavior must NOT change. Report behavior_changed: false.
\`\`\`
```

With:
```markdown
### Step 3: Dispatch Developer Agent (MANDATORY)

**You MUST dispatch fixes to the `@agent-rails-ai:developer` agent using the Task tool.**

#### Parallel Dispatch for Independent Fixes

Use `superpowers:dispatching-parallel-agents` when the fix scope includes **3+ independent areas** that:
- Don't share state or dependencies
- Can be fixed without affecting each other
- Touch different files/domains

**Parallel dispatch example:** If fixing involves 3 different areas — and they're independent — dispatch 3 `@agent-rails-ai:developer` agents concurrently in a single message with multiple Task tool calls.

**Sequential dispatch:** If fixes depend on each other, dispatch one at a time.

#### Dispatch to Developer Agent

Use the Task tool to dispatch to the `@agent-rails-ai:developer` agent:

\`\`\`
Task tool:
- subagent_type: @agent-rails-ai:developer
- prompt: |
    Mode: fix
    Task: [What to fix or improve]
    Files: [Absolute paths needed]
    Context: [Current state, expected outcome]
\`\`\`
```

**Step 12: Update Step 4 (was Step 5) - Handle Developer Agent Response**

Replace:
```markdown
### Step 5: Handle Developer Agent Response

When agent returns:

**If successful AND behavior unchanged:**
- Verify agent ran `bin/ci`
- Verify tests are passing
- Confirm `behavior_changed: false` in report
- Continue to Step 6

**If behavior changed:**
- **DO NOT RETRY** — This is not a retry situation
- Escalate immediately to user with:
  - What behavior changed
  - Which tests revealed the change
  - Recommendation: revert and rethink approach

**If failed or incomplete (but behavior not changed):**
- Apply retry logic (see below)
```

With:
```markdown
### Step 4: Handle Developer Agent Response

When agent returns:

**If successful:**
- Verify agent ran `bin/ci`
- Verify tests are passing
- Continue to Step 5

**If failed or incomplete:**
- Apply retry logic (see below)
```

**Step 13: Update Retry Logic section**

Replace:
```markdown
### Retry Logic

If `@agent-rails-ai:developer` agent fails or returns incomplete work (but behavior was not changed):
```

With:
```markdown
### Retry Logic

If `@agent-rails-ai:developer` agent fails or returns incomplete work:
```

**Step 14: Update Step 5 (was Step 6) - Code Review**

Replace:
```markdown
### Step 6: Code Review

Before finalizing, run `/rails-ai:review`:

1. Review the refactoring against team rules (embedded in skills/agents)
2. Check for over-abstraction, pattern violations
3. Verify behavior was truly preserved
4. Address any blockers found
```

With:
```markdown
### Step 5: Code Review

Before finalizing, run `/rails-ai:review`:

1. Review the changes against team rules (embedded in skills/agents)
2. Check for over-engineering, pattern violations
3. Address any blockers found
```

**Step 15: Update Step 6 (was Step 7) - CHANGELOG**

Replace:
```markdown
### Step 7: Update CHANGELOG

Add entry under `## [Unreleased]`:

\`\`\`markdown
### Changed
- [Description of refactoring]
\`\`\`

Or if fixing issues:

\`\`\`markdown
### Fixed
- [Description of what was fixed]
\`\`\`
```

With:
```markdown
### Step 6: Update CHANGELOG

Add entry under `## [Unreleased]`:

\`\`\`markdown
### Fixed
- [Description of what was fixed/improved]
\`\`\`

Or if changing functionality:

\`\`\`markdown
### Changed
- [Description of what changed]
\`\`\`
```

**Step 16: Update Step 7 (was Step 8) - Complete Branch**

Replace:
```markdown
### Step 8: Complete Branch
```

With:
```markdown
### Step 7: Complete Branch
```

**Step 17: Update Completion Checklist**

Replace:
```markdown
## Completion Checklist

Before claiming refactor is complete:

- [ ] Baseline verified (`bin/ci` passed BEFORE dispatching)
- [ ] Developer agent was dispatched via Task tool (MANDATORY)
- [ ] Agent reported `bin/ci` passes
- [ ] Behavior NOT changed (`behavior_changed: false`)
- [ ] `/rails-ai:review` completed — blockers addressed
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] `superpowers:verification-before-completion` used — evidence before claims
- [ ] `superpowers:finishing-a-development-branch` used — proper completion
```

With:
```markdown
## Completion Checklist

Before claiming fix is complete:

- [ ] Developer agent was dispatched via Task tool (MANDATORY)
- [ ] Agent reported `bin/ci` passes
- [ ] `/rails-ai:review` completed — blockers addressed
- [ ] CHANGELOG.md updated under `## [Unreleased]`
- [ ] `superpowers:verification-before-completion` used — evidence before claims
- [ ] `superpowers:finishing-a-development-branch` used — proper completion
```

**Step 18: Update final line**

Replace:
```markdown
**Now handle the refactor request: {{ARGS}}**
```

With:
```markdown
**Now handle the fix request: {{ARGS}}**
```

**Step 19: Run tests**

Run: `cd /home/dave/Projects/rails-ai/.worktrees/rename-refactor-to-fix && bin/ci`

Expected: Some command tests will fail (looking for refactor.md)

**Step 20: Commit**

```bash
git add commands/fix.md
git commit -m "feat: rename /refactor to /fix with broader scope"
```

---

## Task 4: Update Command Structure Tests

**Files:**
- Modify: `test/unit/commands/command_structure_test.rb`

**Step 1: Update WORKFLOW_COMMANDS constant**

Replace:
```ruby
WORKFLOW_COMMANDS = %w[setup plan feature refactor debug review].freeze
```

With:
```ruby
WORKFLOW_COMMANDS = %w[setup plan feature fix debug review].freeze
```

**Step 2: Update test_refactor_command_references_superpowers**

Rename method and update content:

Replace:
```ruby
def test_refactor_command_references_superpowers
  refactor = @command_files.find { |f| f.include?("refactor.md") }
  content = File.read(refactor)

  assert_match(/superpowers:verification-before-completion/i, content,
               "Refactor command should reference verification superpowers workflow")
  assert_match(/superpowers:test-driven-development/i, content,
               "Refactor command should reference TDD superpowers workflow")
end
```

With:
```ruby
def test_fix_command_references_superpowers
  fix = @command_files.find { |f| f.include?("fix.md") }
  content = File.read(fix)

  assert_match(/superpowers:verification-before-completion/i, content,
               "Fix command should reference verification superpowers workflow")
  assert_match(/superpowers:finishing-a-development-branch/i, content,
               "Fix command should reference finishing-a-development-branch superpowers workflow")
end
```

**Step 3: Update test_refactor_command_has_completion_checklist**

Rename method and update:

Replace:
```ruby
def test_refactor_command_has_completion_checklist
  refactor = @command_files.find { |f| f.include?("refactor.md") }
  content = File.read(refactor)

  assert_match(/completion checklist/i, content,
               "Refactor command should have completion checklist")
  assert_match(%r{bin/ci}i, content,
               "Refactor command should require bin/ci")
  assert_match(/CHANGELOG/i, content,
               "Refactor command should require CHANGELOG update")
end
```

With:
```ruby
def test_fix_command_has_completion_checklist
  fix = @command_files.find { |f| f.include?("fix.md") }
  content = File.read(fix)

  assert_match(/completion checklist/i, content,
               "Fix command should have completion checklist")
  assert_match(%r{bin/ci}i, content,
               "Fix command should require bin/ci")
  assert_match(/CHANGELOG/i, content,
               "Fix command should require CHANGELOG update")
end
```

**Step 4: Update test_refactor_command_has_coordinator_pattern**

Rename method and update (remove behavior_changed check):

Replace:
```ruby
def test_refactor_command_has_coordinator_pattern
  refactor = @command_files.find { |f| f.include?("refactor.md") }
  content = File.read(refactor)

  assert_match(/COORDINATOR ONLY/i, content,
               "Refactor command should declare COORDINATOR ONLY role")
  assert_match(/NEVER implement directly/i, content,
               "Refactor command should prohibit direct implementation")
  assert_match(/Task tool/i, content,
               "Refactor command should reference Task tool for subagent dispatch")
  assert_match(/Retry Logic/i, content,
               "Refactor command should have Retry Logic section")
  assert_match(/Verify Baseline/i, content,
               "Refactor command should have baseline verification step")
  assert_match(/behavior.changed/i, content,
               "Refactor command should include behavior change check")
  assert_match(/subagent_type.*@agent-rails-ai:developer/im, content,
               "Refactor command should dispatch to @agent-rails-ai:developer agent")
end
```

With:
```ruby
def test_fix_command_has_coordinator_pattern
  fix = @command_files.find { |f| f.include?("fix.md") }
  content = File.read(fix)

  assert_match(/COORDINATOR ONLY/i, content,
               "Fix command should declare COORDINATOR ONLY role")
  assert_match(/NEVER implement directly/i, content,
               "Fix command should prohibit direct implementation")
  assert_match(/Task tool/i, content,
               "Fix command should reference Task tool for subagent dispatch")
  assert_match(/Retry Logic/i, content,
               "Fix command should have Retry Logic section")
  assert_match(/subagent_type.*@agent-rails-ai:developer/im, content,
               "Fix command should dispatch to @agent-rails-ai:developer agent")
end
```

**Step 5: Update test_feature_and_refactor_delegate_to_developer_agent**

Rename and update:

Replace:
```ruby
def test_feature_and_refactor_delegate_to_developer_agent
  # Feature and refactor delegate skill loading to developer agent
  %w[feature refactor].each do |command|
    file = @command_files.find { |f| f.include?("#{command}.md") }
    content = File.read(file)

    assert_match(/@agent-rails-ai:developer/i, content,
                 "#{command} command should reference @agent-rails-ai:developer agent")
    assert_match(/mode.*#{command}/i, content,
                 "#{command} command should specify mode")
  end
end
```

With:
```ruby
def test_feature_and_fix_delegate_to_developer_agent
  # Feature uses feature mode, fix uses fix mode
  { "feature" => "feature", "fix" => "fix" }.each do |command, mode|
    file = @command_files.find { |f| f.include?("#{command}.md") }
    content = File.read(file)

    assert_match(/@agent-rails-ai:developer/i, content,
                 "#{command} command should reference @agent-rails-ai:developer agent")
    assert_match(/mode.*#{mode}/i, content,
                 "#{command} command should specify #{mode} mode")
  end
end
```

**Step 6: Run tests**

Run: `cd /home/dave/Projects/rails-ai/.worktrees/rename-refactor-to-fix && rake test:unit:commands`

Expected: PASS

**Step 7: Commit**

```bash
git add test/unit/commands/command_structure_test.rb
git commit -m "test: update command tests for /fix rename"
```

---

## Task 5: Update AGENTS.md Documentation

**Files:**
- Modify: `AGENTS.md`

**Step 1: Update Architecture section command list**

Replace:
```markdown
│   ├── refactor.md            # /rails-ai:refactor (uses developer agent)
```

With:
```markdown
│   ├── fix.md                 # /rails-ai:fix (uses developer agent)
```

**Step 2: Update Workflow Commands table**

Replace:
```markdown
| `/rails-ai:refactor` | Improve existing code (uses developer agent) | **Yes** |
```

With:
```markdown
| `/rails-ai:fix` | Fix or improve existing code (uses developer agent) | **Yes** |
```

**Step 3: Update Agents table**

Replace:
```markdown
| `developer.md` | Implementation agent with 3 modes + DHH-lite persona | feature, refactor, debug commands |
```

With:
```markdown
| `developer.md` | Implementation agent with 2 modes + DHH-lite persona | feature, fix, debug commands |
```

**Step 4: Update Developer Agent Modes table**

Replace:
```markdown
### Developer Agent Modes

| Mode | Baseline Required | Behavior Change OK | Use Case |
|------|-------------------|-------------------|----------|
| `feature` | No | Yes | Implementing new features |
| `refactor` | Yes (tests must pass) | No | Improving existing code |
| `fix` | No | Yes | Fixing bugs or review findings |
```

With:
```markdown
### Developer Agent Modes

| Mode | Baseline Required | Behavior Change OK | Use Case |
|------|-------------------|-------------------|----------|
| `feature` | No | Yes | Implementing new features |
| `fix` | No | Yes | Fixing bugs, improving code, addressing review findings |
```

**Step 5: Update any remaining references**

Search and replace any remaining mentions of `/rails-ai:refactor` with `/rails-ai:fix`.

**Step 6: Run linter**

Run: `cd /home/dave/Projects/rails-ai/.worktrees/rename-refactor-to-fix && rake lint:markdown`

Expected: PASS

**Step 7: Commit**

```bash
git add AGENTS.md
git commit -m "docs: update AGENTS.md for /refactor -> /fix rename"
```

---

## Task 6: Run Full CI and Verify

**Step 1: Run full CI**

Run: `cd /home/dave/Projects/rails-ai/.worktrees/rename-refactor-to-fix && bin/ci`

Expected: ALL CHECKS PASSED

**Step 2: If any failures, fix them**

Address any remaining test failures or lint issues.

**Step 3: Final commit (if needed)**

If any fixes were made, commit them.

---

## Task 7: Update CHANGELOG

**Files:**
- Modify: `CHANGELOG.md`

**Step 1: Add entry under [Unreleased]**

Add:
```markdown
### Changed
- Renamed `/rails-ai:refactor` to `/rails-ai:fix` for broader scope
- Developer agent now has 2 modes (feature, fix) instead of 3
- `/fix` command no longer requires passing baseline
- `/fix` command allows behavior changes (unlike old `/refactor`)
```

**Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for /refactor -> /fix rename"
```

---

## Summary

After completing all tasks:
- `commands/refactor.md` → `commands/fix.md` (renamed + updated)
- `agents/developer.md` — 2 modes (feature, fix) instead of 3
- `AGENTS.md` — updated documentation
- `CHANGELOG.md` — documented the change
- All tests updated and passing
