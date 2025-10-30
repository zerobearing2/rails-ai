# Codex Integration Audit

## Overview
- Assessed the current Rails AI agent system for portability beyond Claude, with a focus on OpenAI Codex and Cursor environments.
- Scope covered the published governance docs, README, STATUS report, agent instructions, and shared rules/contexts.
- Key themes: stale documentation, Claude-specific tooling assumptions, missing assets, and gaps in install/distribution guidance for Codex/Cursor.

## Findings

### 1. Documentation Drift & Missing Assets
- README still advertises 8 agents, a global installer, and a 39-example catalog that no longer ship (`README.md:52-70`, `README.md:85-90`). Docs/plan mirrors the same obsolete structure and install expectations (`docs/plan.md:189-240`).
- `install.sh` is referenced repeatedly but does not exist, so neither Codex nor Cursor users can actually symlink the agents.
- `AGENTS.md` reflects the new 6-agent layout, but the rest of the documentation (README, plan, roadmap bullets) disagrees, which will misroute users setting up Codex/Cursor installs.
- Recommendation: align README/plan/roadmap with the real 6-agent tree, remove non-existent examples/install steps, and document the current manual install workflow (or finish the installer).

### 2. Claude-Only Tooling Instructions
- Multiple agents tell the operator to call Anthropic MCP tools such as `mcp__context7__resolve-library-id` and `mcp__context7__get-library-docs` (`agents/rails.md:91-126`, `agents/rails-frontend.md:215-242`, `agents/rails-backend.md:311-335`, `agents/rails-tests.md:257-287`, `agents/rails-debug.md:290-317`, `agents/rails-security.md:224-249`). Codex and Cursor do not expose MCP, so these instructions will fail outright.
- `rules/SHARED_CONTEXT.md` bakes the same MCP dependency into the shared context (`rules/SHARED_CONTEXT.md:423-460`).
- Recommendation: abstract documentation lookups behind a neutral helper (e.g., “consult official docs/manual links”) and gate MCP-specific guidance so Claude can still use it without breaking other runtimes.

### 3. Hard-Coded `.claude` References
- Agents repeatedly cite `.claude/examples/...` even though the examples directory was removed (`agents/rails-frontend.md:193-209`, `agents/rails-backend.md:287-305`, `agents/rails-tests.md:236-605`, `agents/rails-debug.md:283-286`). Cursor/Codex installs will have no way to follow those references.
- Shared context instructs agents to `<import src=".claude/SHARED_CONTEXT.md#…">`, which points at a non-existent location for Cursor/Codex (`rules/SHARED_CONTEXT.md:598-608`).
- Recommendation: replace `.claude/...` paths with repo-relative links (or resurrect the examples under `docs/examples/`) and provide a cross-LM import path convention.

### 4. Claude-Specific Operational Assumptions
- Coordinator workflows assume Claude’s “Task tool” for parallel dispatch (`agents/rails.md:67`, `rules/DECISION_MATRICES.yml:219`); Codex and Cursor do not expose that tool name or semantics.
- Several docs reference a missing `CLAUDE.md` to source version info and workflow rules (`agents/rails.md:117-127`, `docs/STATUS.md:527`, `docs/STATUS.md:889`).
- Commit template hard-codes “🤖 Generated with Claude Code” (`rules/SHARED_CONTEXT.md:498-507`), which is inaccurate for Codex/Cursor usage.
- Recommendation: rewrite operational guidance in tool-agnostic terms (e.g., “issue multiple requests in parallel when supported”), supply a vendor-neutral configuration file, and update commit templates to reflect the active assistant.

### 5. Distribution & Install Gaps for Codex/Cursor
- Although the plan mentions detecting `~/.claude` and `~/.cursor` (`docs/plan.md:301-467`), there is no executable script, verification steps, or Cursor-specific layout guidance. Cursor currently expects rules under `~/.cursor/rules/` and custom agents under `~/.cursor/agents/`; those steps need to be codified.
- README claims Codex support, but there is no documented path (e.g., `~/.openai/agents/` or instructions for the OpenAI CLI) and no adaptation notes for Codex’s toolset.
- Recommendation: finish the installer (or provide manual symlink instructions), document the expected directory structure for Cursor and Codex separately, and call out any capabilities that differ by platform (context limits, tool availability, etc.).

## Suggested Next Steps
1. Ship an updated README/plan that reflects the current asset set and clarifies installation for each target IDE/runtime.
2. Refactor agent instructions so Claude-specific MCP guidance is optional, with vendor-neutral fallbacks.
3. Replace `.claude` path references with repo-relative docs or reintroduce the missing assets in a shared location both Cursor and Codex can read.
4. Update shared rules/commit templates to remove Claude branding and note how to attribute Codex/Cursor contributions.
5. Provide a dedicated onboarding doc for Codex/Cursor users (directory structure, how to enable the agents, known limitations).
