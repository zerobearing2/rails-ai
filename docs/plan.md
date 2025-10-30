# Plan: rails-ai - Opinionated Rails Agent System

**Date:** 2025-10-30
**Updated:** 2025-10-30 (Simplified to Rails-only, global install via symlinks)
**Status:** Ready to Execute
**Estimated Effort:** 8-12 hours (1 week part-time)

---

## Overview

Create an opinionated, Rails-only AI agent system called **rails-ai**. This is a focused project that provides battle-tested agents for Rails development with Claude Code and OpenAI support.

**Philosophy:** Keep it simple. This is a Rails-focused agent system that will be refined and tuned over time. No framework abstractions, no complex adapters - just great Rails agents that work globally on your machine.

**Development Approach:**
- **Private repository** during tuning and testing phase
- **Open source later** once agents are refined and battle-tested
- **Focus on quality** before community release

**Key Decisions:**
- **Project Name:** rails-ai
- **Scope:** Rails-only, opinionated (no other frameworks)
- **LLM Support:** Claude Code + OpenAI (via global config symlinks)
- **Installation:** Global installation via symlinks to `~/.claude/` or `~/.cursor/`
- **Distribution:** Private GitHub repo → tune agents → public release later
- **Philosophy:** Tune and refine agents first, open source when ready

---

## Project Structure (Simplified)

```text
rails-ai/
├── agents/                    # 6 specialized Rails agents
│   ├── rails.md              # Coordinator
│   ├── rails-frontend.md     # Frontend specialist
│   ├── rails-backend.md      # Backend specialist
│   ├── rails-tests.md        # Test specialist
│   ├── rails-security.md     # Security specialist
│   └── rails-debug.md        # Debug specialist
├── skills/                    # Skills registry and implementations
│   └── SKILLS_REGISTRY.yml   # 33 modular skills catalog
├── rules/                     # Team rules and context
│   ├── TEAM_RULES.md
│   ├── SHARED_CONTEXT.md
│   └── DECISION_MATRICES.yml
├── test/                      # Minitest-based testing framework
├── bin/                       # Development scripts
├── install.sh                 # Global installer (coming in Phase 3)
├── README.md
├── LICENSE
└── docs/
    └── plan.md
```

**Why this structure?**
- Simple and flat - easy to navigate and maintain
- All agent files in one place for easy editing during tuning phase
- Skills-based architecture with comprehensive registry
- Single install script that symlinks to global configs
- No complex abstractions or adapters

### Claude Code Plugin Architecture

**Update (2025-10-30):** rails-ai is now distributed as a Claude Code plugin for easier installation.

**Plugin manifests:**
- `.claude-plugin/plugin.json` - Plugin metadata and configuration
- `.claude-plugin/marketplace.json` - Self-distributing marketplace definition

**Installation methods:**
1. **GitHub Install (Primary):**
   ```
   /plugin marketplace add zerobearing2/rails-ai
   /plugin install rails-ai
   ```

2. **Local Development:**
   ```
   /plugin marketplace add /path/to/rails-ai
   /plugin install rails-ai
   ```

3. **Manual Install (Alternative):** Symlink agents/ and rules/ to ~/.claude/

**Skills folder:**
- Keeping `skills/` folder name (testing for collision with Claude native skills)
- Claude native skills expect directories with `SKILL.md` files
- Our files use different naming (no `SKILL.md`), so collision unlikely
- Will monitor and rename to `rails-skills/` if needed

**Benefits:**
- One-command installation
- Works with Claude Code's plugin system
- Automatic updates via git pull
- Clean separation from user's other agents

---

## Phase 0: Project Setup (COMPLETED ✅)

**Status:** Initial commit done, files copied from feedback-app

### What was completed:
- ✅ Created `/home/dave/Projects/rails-ai/` directory
- ✅ Copied 8 agent files
- ✅ Copied ~39 example files
- ✅ Copied rules and documentation
- ✅ Initial git commit created

**Note:** Files are currently in `adapters/framework/rails/*` structure. Next phase will flatten this.

---

## Phase 1: Simplify Directory Structure (1-2 hours)

**Goal:** Flatten the directory structure to match the simple layout above.

### Step 1: Reorganize Files

```bash
cd /home/dave/Projects/rails-ai

# Move agent files to top-level agents/ directory
mkdir -p agents
mv adapters/framework/rails/agents/*.md agents/

# Move examples to top-level
mv adapters/framework/rails/examples .

# Move rules to top-level
mv adapters/framework/rails/rules .

# Remove old structure
rm -rf adapters core templates scripts

# Clean up docs
# Keep docs/plan.md, remove other copied docs if not needed
```

### Step 2: Update .gitignore

```bash
cat > .gitignore << 'EOF'
# OS files
.DS_Store
Thumbs.db

# Editor files
.vscode/
.idea/
*.swp
*.swo
*~

# Test files
test-projects/
.test-*

# Local development
.env
.env.local
*.local
EOF
```

### Step 3: Commit Restructure

```bash
git add .
git commit -m "Simplify directory structure

- Flatten to simple agents/, examples/, rules/ structure
- Remove complex adapter/core directories
- Focus on Rails-only opinionated approach"
```

### Deliverables:
- ✅ Clean, flat directory structure
- ✅ agents/ contains all 8 agent files
- ✅ examples/ contains all code examples
- ✅ rules/ contains team rules and context
- ✅ Ready for GitHub setup

---

## Phase 2: GitHub Repository Setup (1 hour)

**Goal:** Create private GitHub repo for agent tuning and development.

### Step 1: Create Private GitHub Repository

```bash
cd /home/dave/Projects/rails-ai

# Create PRIVATE GitHub repo (we'll open source later)
gh repo create zerobearing2/rails-ai \
  --private \
  --description "Opinionated Rails-only AI agent system (private during tuning)" \
  --disable-wiki

# Or create manually at: https://github.com/new
# Make sure to select "Private" visibility
```

### Step 2: Create Initial README (Private Version)

```bash
cat > README.md << 'EOF'
# rails-ai 🚂

**Opinionated Rails-only AI agent system**

> 🔒 **Private Repository**: This is a private repo during the agent tuning and testing phase. Will be open-sourced once battle-tested.

## What is rails-ai?

An opinionated AI agent system specifically for Ruby on Rails development. Provides 8 specialized agents that work together following Rails conventions and 37signals-inspired best practices.

## Current Status: Agent Tuning Phase

This project is currently **private** and in active development. We're:
- 🔧 Tuning and refining the 8 specialized agents
- 🧪 Testing across real Rails projects
- 📝 Gathering examples and patterns
- 🎯 Improving decision matrices and rules

**Will open source** once the agents are refined and battle-tested.

## Features

- 🎯 **6 Specialized Agents**: Coordinator, Frontend, Backend, Tests, Security, Debug
- 🚂 **Rails-Only**: Focused exclusively on Ruby on Rails (no other frameworks)
- 🤖 **LLM Support**: Works with Claude Code and OpenAI/Cursor
- 🌍 **Global Install**: Symlinks to your home folder for use across all Rails projects
- 📋 **Team Rules**: Enforced conventions (Solid Stack, Minitest, REST-only, TDD)
- 🧪 **Skills-Based**: Modular skill system with testing framework

## Installation (Local)

```bash
# Clone repo
cd ~/Projects/rails-ai

# Run installer
./install.sh
```

This will symlink the agents to `~/.claude/agents/` or `~/.cursor/agents/` so they're available in all your Rails projects.

## Usage

In any Rails project with Claude Code:

```text
@rails - Add user authentication feature
```

The coordinator agent will create a plan, delegate to specialists, and deliver a complete implementation.

## Project Structure

```text
rails-ai/
├── agents/          # 6 specialized Rails agents
├── skills/          # Modular skills registry with 33 skills
├── rules/           # Team rules and decision matrices
├── test/            # Minitest-based testing framework
├── bin/             # Development scripts
└── install.sh       # Global installer (coming in Phase 3)
```

## Philosophy

This is an **opinionated** Rails agent system that follows:
- 37signals philosophy (simple, pragmatic, delete code)
- Rails conventions (REST-only, no custom actions)
- Solid Stack (Rails 8: SolidQueue, SolidCache, SolidCable)
- Minitest (no RSpec)
- TDD always (RED-GREEN-REFACTOR)
- Peer review workflow

## Roadmap

### Phase 1: Private Tuning (Current)
- Refine agent instructions based on real usage
- Improve examples and patterns
- Test across multiple Rails projects
- Document learnings

### Phase 2: Open Source Release (Future)
- Clean up and finalize agents
- Complete documentation
- Add MIT license
- Public release with announcement

## Credits

Inspired by 37signals' philosophy of simple, conventional Rails development.
EOF

git add README.md
git commit -m "Add initial README (private repo during tuning)"
```

### Step 3: Push to GitHub

```bash
# Add remote
git remote add origin git@github.com:zerobearing2/rails-ai.git

# Push
git push -u origin main
```

### Deliverables:
- ✅ Private GitHub repo created: `zerobearing2/rails-ai`
- ✅ README created (private version)
- ✅ Initial commits pushed
- ✅ Ready for installer development
- ✅ LICENSE will be added when we open source

---

## Phase 3: Create Global Installer (3-4 hours)

**Goal:** Build a simple bash installer that symlinks agents to global LLM config directories.

### Installer Requirements

The installer should:
1. Detect which LLM tool is installed (Claude Code, Cursor, both)
2. Backup existing agent files if present
3. Create symlinks from `rails-ai/agents/` to `~/.claude/agents/` or `~/.cursor/agents/`
4. Create symlinks for skills and rules
5. Provide clear feedback and next steps

### install.sh

```bash
#!/bin/bash
# rails-ai global installer
# Symlinks Rails agents to your LLM tool's global config

set -e

RAILS_AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.rails-ai-backup-$(date +%Y%m%d-%H%M%S)"

echo "🚂 rails-ai installer"
echo ""

# Detect LLM tools
CLAUDE_DIR="$HOME/.claude"
CURSOR_DIR="$HOME/.cursor"
INSTALL_TARGETS=()

if [ -d "$CLAUDE_DIR" ]; then
  INSTALL_TARGETS+=("claude")
  echo "✓ Detected: Claude Code (~/.claude/)"
fi

if [ -d "$CURSOR_DIR" ]; then
  INSTALL_TARGETS+=("cursor")
  echo "✓ Detected: Cursor (~/.cursor/)"
fi

if [ ${#INSTALL_TARGETS[@]} -eq 0 ]; then
  echo "⚠ No LLM tool config directories found"
  echo ""
  echo "This installer looks for:"
  echo "  - ~/.claude/ (Claude Code)"
  echo "  - ~/.cursor/ (Cursor)"
  echo ""
  read -p "Create ~/.claude/ directory? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p "$CLAUDE_DIR"
    INSTALL_TARGETS+=("claude")
  else
    echo "Installation cancelled."
    exit 1
  fi
fi

echo ""
echo "Will install to:"
for target in "${INSTALL_TARGETS[@]}"; do
  if [ "$target" = "claude" ]; then
    echo "  - $CLAUDE_DIR/agents/"
  elif [ "$target" = "cursor" ]; then
    echo "  - $CURSOR_DIR/agents/"
  fi
done

echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

# Backup existing files
echo ""
echo "💾 Creating backup..."
mkdir -p "$BACKUP_DIR"

for target in "${INSTALL_TARGETS[@]}"; do
  if [ "$target" = "claude" ]; then
    TARGET_DIR="$CLAUDE_DIR"
  elif [ "$target" = "cursor" ]; then
    TARGET_DIR="$CURSOR_DIR"
  fi

  if [ -d "$TARGET_DIR/agents" ]; then
    echo "  Backing up $TARGET_DIR/agents/ ..."
    cp -r "$TARGET_DIR/agents" "$BACKUP_DIR/$target-agents" 2>/dev/null || true
  fi
done

echo "  Backup saved to: $BACKUP_DIR"

# Install symlinks
echo ""
echo "🔗 Creating symlinks..."

for target in "${INSTALL_TARGETS[@]}"; do
  if [ "$target" = "claude" ]; then
    TARGET_DIR="$CLAUDE_DIR"
  elif [ "$target" = "cursor" ]; then
    TARGET_DIR="$CURSOR_DIR"
  fi

  # Create directories
  mkdir -p "$TARGET_DIR/agents"
  mkdir -p "$TARGET_DIR/skills"

  # Symlink each agent file
  for agent in "$RAILS_AI_DIR/agents"/*.md; do
    agent_name=$(basename "$agent")
    target_path="$TARGET_DIR/agents/$agent_name"

    # Remove existing file/symlink
    rm -f "$target_path"

    # Create symlink
    ln -s "$agent" "$target_path"
    echo "  ✓ Linked: $agent_name"
  done

  # Symlink skills directory
  rm -rf "$TARGET_DIR/skills"
  ln -s "$RAILS_AI_DIR/skills" "$TARGET_DIR/skills"
  echo "  ✓ Linked: skills/"

  # Copy rules (don't symlink - users might want to customize)
  cp -r "$RAILS_AI_DIR/rules" "$TARGET_DIR/"
  echo "  ✓ Copied: rules/"
done

echo ""
echo "✅ rails-ai installed successfully!"
echo ""
echo "📖 Next steps:"
echo "   1. Open any Rails project in your LLM tool"
echo "   2. Try: @rails - Add categories feature"
echo "   3. The agents will work globally across all Rails projects"
echo ""
echo "📝 Notes:"
echo "   - Agent files are symlinked (edit in $RAILS_AI_DIR/agents/)"
echo "   - Skills are symlinked (edit in $RAILS_AI_DIR/skills/)"
echo "   - Rules are copied (edit in ~/.claude/rules/ or ~/.cursor/rules/)"
echo "   - Backup saved to: $BACKUP_DIR"
echo ""
echo "🔄 To update: cd $RAILS_AI_DIR && git pull && ./install.sh"
echo ""
```

### Make installer executable

```bash
chmod +x install.sh
git add install.sh
git commit -m "Add global installer script

- Detects Claude Code and/or Cursor
- Creates backups of existing agents
- Symlinks agents and examples to global config
- Copies rules for user customization
- Provides clear feedback and next steps"
```

### Test Installation

```bash
# Test on your machine
./install.sh

# Verify symlinks
ls -la ~/.claude/agents/
ls -la ~/.claude/examples

# Test in Claude Code
# @rails - should now be available globally
```

### Deliverables:
- ✅ `install.sh` script created
- ✅ Supports Claude Code and Cursor
- ✅ Creates backups before installation
- ✅ Symlinks agents and skills
- ✅ Copies rules for customization
- ✅ Clear user feedback
- ✅ Tested and working

---

## Phase 4: Documentation & Polish (1-2 hours)

**Goal:** Complete internal documentation for tuning phase (public docs come later).

### Step 1: Create Internal Documentation

```bash
# Create tuning log
cat > docs/TUNING_LOG.md << 'EOF'
# Agent Tuning Log

Track improvements, learnings, and changes as we refine the agents.

## Format

```
### [Date] - [Agent Name]
**Issue:** What wasn't working
**Change:** What was modified
**Result:** What improved
```

## Entries

(To be filled in as we tune agents)
EOF

# Create changelog for internal tracking
cat > CHANGELOG.md << 'EOF'
# Changelog

Internal changelog during private tuning phase.

## [Unreleased] - Private Tuning Phase

### Added
- Initial project setup
- 8 specialized Rails agents
- ~39 Rails code examples
- Global installer with symlinks
- Team rules and decision matrices

### In Progress
- Agent tuning and refinement
- Testing across real Rails projects
- Gathering examples and patterns

### Future
- Open source release (TBD)
- MIT License (upon open source)
- Public documentation
EOF
```

### Step 2: Simple Internal Notes

Just keep the documentation minimal and focused on tuning. Public docs will come later when we open source.

### Deliverables:
- ✅ Internal tuning log created
- ✅ Changelog for tracking progress
- ✅ Minimal docs (expand when going public)
- ✅ Focus stays on agent refinement

---

## Phase 5: Testing & Validation (2-3 hours)

**Goal:** Test the full installation and agent workflow.

### Test Scenarios

#### 1. Fresh Installation (Claude Code)

```bash
# On a test machine or clean user account
git clone https://github.com/zerobearing2/rails-ai
cd rails-ai
./install.sh

# Verify
ls -la ~/.claude/agents/
ls -la ~/.claude/examples/

# Test agent
# Open Claude Code in a Rails project
# @rails - Add a simple Post model with title and body
```

#### 2. Fresh Installation (Cursor)

Same as above but verify `~/.cursor/` installation.

#### 3. Update Workflow

```bash
# Make changes to agents
cd ~/Projects/rails-ai
# Edit agents/rails.md
git add .
git commit -m "Improve coordinator agent"
git push

# Update on user machine
cd rails-ai
git pull

# Verify changes immediately available (symlinks!)
# No need to reinstall
```

#### 4. Multiple Rails Projects

Test that agents work across multiple Rails projects without per-project setup.

### Validation Checklist

**Installation:**
- [ ] Installs successfully on fresh system
- [ ] Detects Claude Code correctly
- [ ] Detects Cursor correctly
- [ ] Creates backups of existing files
- [ ] Creates symlinks correctly
- [ ] Clear, helpful output messages

**Agent Functionality:**
- [ ] @rails coordinator responds correctly
- [ ] Can delegate to specialist agents
- [ ] Examples are accessible
- [ ] Rules are enforced
- [ ] Works across multiple Rails projects

**Updates:**
- [ ] git pull updates agent files immediately (symlinks)
- [ ] No reinstallation needed for updates
- [ ] User customizations in rules/ preserved

**Documentation:**
- [ ] README is clear and complete
- [ ] Installation instructions work
- [ ] Usage examples are accurate
- [ ] Troubleshooting helps resolve issues

### Deliverables:
- ✅ Tested on fresh installation
- ✅ Verified symlink behavior
- ✅ Confirmed multi-project support
- ✅ Validated update workflow
- ✅ Documentation accurate
- ✅ Ready for release

---

## Phase 6: Initial Private Release (30 mins)

**Goal:** Tag v0.1.0 for internal use and tuning phase.

### Step 1: Tag Initial Version

```bash
cd /home/dave/Projects/rails-ai

# Create version file
echo "0.1.0" > VERSION
git add VERSION

# Tag for internal use
git commit -m "Prepare v0.1.0 - Initial private release for tuning"

# Tag
git tag -a v0.1.0 -m "rails-ai v0.1.0 - Private Tuning Release

- 6 specialized Rails agents (private tuning phase)
- 33 modular skills with registry
- Skills-based architecture with testing framework
- Global installer for Claude Code and Cursor
- Symlink-based installation
- Rails-only, opinionated approach

Private release for agent tuning and refinement.
Will be open sourced once battle-tested."

# Push
git push origin main --tags
```

### Deliverables:
- ✅ v0.1.0 tagged (private)
- ✅ Ready for internal testing and tuning
- ✅ Public v1.0.0 release will come later after tuning

---

## Timeline Summary

**Total Estimated Effort:** 8-12 hours (1 week part-time)

| Phase | Effort | Status |
|-------|--------|--------|
| 0. Project Setup | 1-2 hours | ✅ COMPLETED |
| 1. Simplify Structure | 1-2 hours | 🔜 Next |
| 2. Private GitHub Setup | 30 mins | 🔜 Pending |
| 3. Global Installer | 3-4 hours | 🔜 Pending |
| 4. Internal Docs | 1-2 hours | 🔜 Pending |
| 5. Testing | 2-3 hours | 🔜 Pending |
| 6. Tag v0.1.0 | 30 mins | 🔜 Pending |

**Recommended Approach:**
- **Days 1-2**: Phases 1-3 (structure, GitHub, installer)
- **Days 3-4**: Phases 4-6 (docs, testing, tagging)
- **Ongoing**: Agent tuning and refinement

---

## Success Criteria (Private Tuning Phase)

### Installation Success
- [ ] One-command installation works
- [ ] Detects Claude Code and Cursor correctly
- [ ] Creates backups automatically
- [ ] Symlinks work correctly
- [ ] Clear, helpful output

### Agent Functionality
- [ ] Agents work in Claude Code
- [ ] Agents work in Cursor (if available)
- [ ] Works across multiple Rails projects
- [ ] No per-project setup needed
- [ ] Examples and rules accessible

### Updates
- [ ] git pull updates agents immediately
- [ ] No reinstallation needed
- [ ] User customizations preserved

### Tuning Phase Goals
- [ ] Test agents on 3+ real Rails projects
- [ ] Document 10+ agent improvements in TUNING_LOG.md
- [ ] Refine decision matrices based on real usage
- [ ] Add 5+ new examples from real scenarios
- [ ] Achieve consistent, high-quality agent responses

---

## Future Enhancements

### Phase 7: Open Source Preparation (Future)

When agents are battle-tested and refined:

1. **Add MIT License**
2. **Clean up and finalize documentation**
3. **Create public README with community guidelines**
4. **Add CONTRIBUTING.md**
5. **Create issue/PR templates**
6. **Make repository public**
7. **Tag v1.0.0**
8. **Announce on Twitter/Reddit**

### Post-Open Source (v1.x+)

- Community-contributed examples
- Additional agent specializations
- Project-specific install option
- Video tutorials
- Usage analytics

**Current Focus:** Private tuning and refinement. Open source when ready.

---

## Key Principles

### 1. Simplicity First
- One command install
- Global availability
- No complex configuration
- Just works

### 2. Rails-Only Focus
- No other frameworks
- Deep Rails expertise
- Rails conventions enforced
- Opinionated and proud of it

### 3. Easy to Maintain
- Flat directory structure
- Symlinks for easy updates
- No build process
- Plain markdown files

### 4. Community Driven
- Open source (MIT)
- Accept contributions
- Grow example library
- Transparent development

### 5. Agent Tuning Priority
- Refine agents first
- Learn from real usage
- Improve over time
- Add features later

### 6. 37signals Philosophy
- Simple, pragmatic
- Conventional Rails
- Delete code
- Less is more

---

## Next Immediate Action

**Phase 1: Simplify Directory Structure**

```bash
cd /home/dave/Projects/rails-ai

# Flatten structure
mkdir -p agents examples rules
mv adapters/framework/rails/agents/*.md agents/
mv adapters/framework/rails/examples/* examples/
mv adapters/framework/rails/rules/* rules/
rm -rf adapters core templates scripts

# Commit
git add .
git commit -m "Simplify directory structure - flatten to agents/examples/rules"
```

Then proceed to Phase 2 (GitHub setup).

---

**Document Version:** 2.0 (Simplified)
**Last Updated:** 2025-10-30
**Status:** Ready to execute Phase 1
