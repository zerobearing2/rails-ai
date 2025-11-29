# Simplified Branch and Agent Workflow Design

> **Goal:** Remove worktrees and parallel agent dispatch to reduce Claude usage and complexity, while preserving the coordinator → developer agent pattern.

## Problem

Current workflows use:
- **Git worktrees** for isolated feature work (overhead, complexity)
- **Parallel agent dispatch** for 3+ independent tasks (3x usage cost)

These patterns add complexity and burn through Claude usage without proportional benefit.

## Solution

### Remove Worktrees

- Remove all `superpowers:using-git-worktrees` references
- Work in the user's current directory always
- Use simple feature branches instead (`git checkout -b`)

### Remove Parallel Agents

- Remove all `superpowers:dispatching-parallel-agents` references
- Always dispatch to developer agent sequentially
- Remove "If 3+ independent tasks, parallelize" logic

### Branch Management (Replacing Worktrees)

1. **Check current branch** — if already on feature/fix branch, use it
2. **If on main/develop** — create branch: `feature/short-description` or `fix/short-description`
3. **Work in place** — all changes in current directory
4. **Finish with existing flow** — `superpowers:finishing-a-development-branch` handles PR/merge

**Edge case — dirty working tree:** Ask user what to do (stash, commit, abort).

### What Stays

- Coordinator → developer agent pattern
- `superpowers:verification-before-completion`
- `superpowers:finishing-a-development-branch`
- `superpowers:brainstorming`, `writing-plans`, `executing-plans`
- `superpowers:systematic-debugging`, `root-cause-tracing`

## Files to Modify

| File | Changes |
|------|---------|
| `commands/feature.md` | Remove worktrees, remove parallel dispatch, add branch check/creation |
| `commands/fix.md` | Remove worktrees, remove parallel dispatch, add branch check/creation |
| `commands/debug.md` | Remove parallel dispatch (no branch changes needed for debug) |
| `README.md` | Update Workflow → Superpowers Mapping table |

## Trade-offs

**Accepted:**
- Slower for truly independent tasks (sequential vs parallel)
- Can't work on two features simultaneously (no worktree isolation)
- Feature branch blocks main directory during work

**Gained:**
- Simpler mental model
- Lower Claude usage
- Familiar git workflow
- Easier debugging when things go wrong
