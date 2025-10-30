# Codex Integration Audit

## Progress Tracker

| Issue | Status | Commit |
|-------|--------|--------|
| 1. Documentation Drift & Missing Assets | ✅ DONE | 2fc153d |
| 2. Claude-Only Tooling Instructions | 🔜 TODO | - |
| 3. Hard-Coded `.claude` References | ✅ DONE | 2fc153d |
| 4. Claude-Specific Operational Assumptions | 🔜 TODO | - |
| 5. Distribution & Install Gaps | ⏸️ DEFERRED | (installer phase) |

**Last Updated:** 2025-10-30

---

## Overview
- Assessed the current Rails AI agent system for portability beyond Claude, with a focus on OpenAI Codex and Cursor environments.
- Scope covered the published governance docs, README, STATUS report, agent instructions, and shared rules/contexts.
- Key themes: stale documentation, Claude-specific tooling assumptions, missing assets, and gaps in install/distribution guidance for Codex/Cursor.

## Findings

### 1. Documentation Drift & Missing Assets ✅ DONE

**Status:** Fixed in commit 2fc153d

**What was fixed:**
- ✅ Updated README.md: 8 agents → 6 agents (Architect/Coordinator, Frontend, Backend, Tests, Security, Debug)
- ✅ Removed references to non-existent "39+ Code Examples"
- ✅ Updated project structure to show `skills/` (33 modular skills) instead of `examples/`
- ✅ Fixed docs/plan.md to reflect 6 agents and skills-based architecture
- ✅ Updated installation instructions to show manual symlink approach
- ✅ Added skills-based architecture references throughout

**Original Issues:**
- README still advertises 8 agents, a global installer, and a 39-example catalog that no longer ship (`README.md:52-70`, `README.md:85-90`). Docs/plan mirrors the same obsolete structure and install expectations (`docs/plan.md:189-240`).
- `install.sh` is referenced repeatedly but does not exist, so neither Codex nor Cursor users can actually symlink the agents. *(Note: installer deferred to Phase 3)*
- `AGENTS.md` reflects the new 6-agent layout, but the rest of the documentation (README, plan, roadmap bullets) disagrees, which will misroute users setting up Codex/Cursor installs.

### 2. Claude-Only Tooling Instructions 🔜 TODO

**Status:** Not started

**Issues to address:**
- Multiple agents tell the operator to call Anthropic MCP tools such as `mcp__context7__resolve-library-id` and `mcp__context7__get-library-docs` (`agents/architect.md:91-126`, `agents/frontend.md:215-242`, `agents/backend.md:311-335`, `agents/tests.md:257-287`, `agents/debug.md:290-317`, `agents/security.md:224-249`). Codex and Cursor do not expose MCP, so these instructions will fail outright.
- `rules/SHARED_CONTEXT.md` bakes the same MCP dependency into the shared context (`rules/SHARED_CONTEXT.md:423-460`).

**Recommendation:** Abstract documentation lookups behind a neutral helper (e.g., "consult official docs/manual links") and gate MCP-specific guidance so Claude can still use it without breaking other runtimes.

**Proposed approach:**
- Add conditional MCP sections with fallback instructions for non-MCP environments
- Provide manual documentation links for Codex/Cursor
- Consider environment detection or configuration to toggle MCP instructions

### 3. Hard-Coded `.claude` References ✅ DONE

**Status:** Fixed in commit 2fc153d

**What was fixed:**
- ✅ Replaced all `.claude/examples/` references with `skills/SKILLS_REGISTRY.yml` references in agent files
- ✅ Updated `agents/frontend.md`: Changed examples references to skills registry (14+ skills listed)
- ✅ Updated `agents/backend.md`: Changed examples references to skills registry
- ✅ Updated `agents/tests.md`: Replaced 14+ occurrences of `.claude/examples/tests/` with skills references
- ✅ Updated `agents/debug.md`: Changed to reference skills registry
- ✅ Fixed `rules/SHARED_CONTEXT.md`: Changed `.claude/` import paths to repo-relative `rules/` paths
- ✅ Added note about cross-platform compatibility (works in Claude Code, Cursor, and Codex)

**Original Issues:**
- Agents repeatedly cite `.claude/examples/...` even though the examples directory was removed (`agents/frontend.md:193-209`, `agents/backend.md:287-305`, `agents/tests.md:236-605`, `agents/debug.md:283-286`). Cursor/Codex installs will have no way to follow those references.
- Shared context instructs agents to `<import src=".claude/SHARED_CONTEXT.md#…">`, which points at a non-existent location for Cursor/Codex (`rules/SHARED_CONTEXT.md:598-608`).

### 4. Claude-Specific Operational Assumptions 🔜 TODO

**Status:** Not started

**Issues to address:**
- Coordinator workflows assume Claude's "Task tool" for parallel dispatch (`agents/architect.md:67`, `rules/DECISION_MATRICES.yml:219`); Codex and Cursor do not expose that tool name or semantics.
- Several docs reference a missing `CLAUDE.md` to source version info and workflow rules (`agents/architect.md:117-127`, `docs/STATUS.md:527`, `docs/STATUS.md:889`).
- Commit template hard-codes "🤖 Generated with Claude Code" (`rules/SHARED_CONTEXT.md:498-507`), which is inaccurate for Codex/Cursor usage.

**Recommendation:** Rewrite operational guidance in tool-agnostic terms (e.g., "issue multiple requests in parallel when supported"), supply a vendor-neutral configuration file, and update commit templates to reflect the active assistant.

**Proposed approach:**
- Generalize Task tool references to platform-agnostic language
- Create environment-specific configuration that can detect runtime (Claude/Cursor/Codex)
- Make commit template configurable or auto-detect environment
- Remove or relocate missing `CLAUDE.md` references

### 5. Distribution & Install Gaps for Codex/Cursor ⏸️ DEFERRED

**Status:** Deferred to Phase 3 (installer development)

**Issues to address:**
- Although the plan mentions detecting `~/.claude` and `~/.cursor` (`docs/plan.md:301-467`), there is no executable script, verification steps, or Cursor-specific layout guidance. Cursor currently expects rules under `~/.cursor/rules/` and custom agents under `~/.cursor/agents/`; those steps need to be codified.
- README claims Codex support, but there is no documented path (e.g., `~/.openai/agents/` or instructions for the OpenAI CLI) and no adaptation notes for Codex's toolset.

**Partial fix:**
- ✅ README.md now includes manual symlink instructions for both Claude Code and Cursor
- ✅ docs/plan.md has updated installer template ready for implementation

**Remaining work (Phase 3):**
- Create and test `install.sh` script
- Document Codex-specific installation path
- Add verification steps
- Document platform-specific capabilities and limitations

**Note:** This is intentionally deferred as the installer is part of the roadmap Phase 3. Manual installation is now properly documented as an interim solution.

## Action Items Summary

### Completed ✅
1. ✅ **Ship an updated README/plan** that reflects the current asset set and clarifies installation for each target IDE/runtime. *(commit 2fc153d)*
2. ✅ **Replace `.claude` path references** with repo-relative docs and skills registry. *(commit 2fc153d)*

### Next Up 🔜
3. 🔜 **Refactor agent instructions** so Claude-specific MCP guidance is optional, with vendor-neutral fallbacks.
4. 🔜 **Update shared rules/commit templates** to remove Claude branding and note how to attribute Codex/Cursor contributions.
5. 🔜 **Remove/fix Claude-specific operational assumptions** (Task tool, missing CLAUDE.md references).

### Deferred ⏸️
6. ⏸️ **Complete installer implementation** (Phase 3 - manual install documented as interim solution)
7. ⏸️ **Provide a dedicated onboarding doc** for Codex/Cursor users (directory structure, how to enable the agents, known limitations).
