# The Specification Pyramid: A Framework for AI-Driven Development

## Executive Summary

The Specification Pyramid is a revolutionary framework for defining software products in the age of AI-assisted development. Unlike traditional Product Requirements Documents (PRDs) that were designed for human developers, the Specification Pyramid recognizes that Large Language Models (LLMs) like Claude require a fundamentally different approach to specification.

**Key Insight:** Traditional specs are written for humans who infer context. LLMs need the inverse—maximum precision, minimum fluff.

This document explains what the Specification Pyramid is, why it works better than PRDs, and how to implement it systematically.

---

## Table of Contents

1. [The Problem with Traditional PRDs](#the-problem-with-traditional-prds)
2. [What is the Specification Pyramid?](#what-is-the-specification-pyramid)
3. [The Four Layers Explained](#the-four-layers-explained)
4. [Why This Framework Works for LLMs](#why-this-framework-works-for-llms)
5. [Core Principles](#core-principles)
6. [How to Use the Specification Pyramid](#how-to-use-the-specification-pyramid)
7. [Implementation Example](#implementation-example)
8. [Common Pitfalls and How to Avoid Them](#common-pitfalls-and-how-to-avoid-them)
9. [Adapting the Framework](#adapting-the-framework)
10. [Conclusion](#conclusion)

---

## The Problem with Traditional PRDs

### What PRDs Were Designed For

Traditional Product Requirements Documents evolved in an era where:
- **Human developers** were the primary audience
- **Inferential thinking** was expected and valued
- **Context** was shared through meetings, Slack, and tribal knowledge
- **Ambiguity** could be resolved through quick questions
- **"Why"** mattered as much as "what" and "how"

A typical PRD includes:
- Executive summaries
- Market analysis
- User personas
- Success metrics
- High-level feature descriptions
- "The user should be able to..." statements

### Why PRDs Fail with LLMs

When you hand a traditional PRD to an LLM like Claude and ask it to build your product, several problems emerge:

**1. Too Much Context, Not Enough Precision**
- PRDs explain *why* features exist (market need, user pain points)
- LLMs don't need motivation—they need exact specifications
- Context that helps humans make decisions becomes noise for LLMs

**2. Ambiguous Requirements**
- "User-friendly interface" means nothing to an LLM
- "Should handle errors gracefully" is impossible to implement without specifics
- "Intuitive navigation" provides zero implementation guidance

**3. Missing Technical Detail**
- PRDs intentionally avoid implementation details
- They leave "how" to engineering teams
- LLMs need to know database schemas, API contracts, component structures

**4. Non-Testable Acceptance Criteria**
- "Users love the experience" can't be verified
- "Fast performance" has no measurable definition
- "Works well on mobile" doesn't specify breakpoints or behaviors

**5. Linear Structure**
- PRDs present features as a flat list
- No clear dependency chain
- Difficult to break into parallelizable work

### The Result

When developers try to use PRDs with AI coding tools like Claude Code, Cursor, or GitHub Copilot, they get:
- Vague implementations that need constant refinement
- Inconsistent patterns across features
- Missing edge case handling
- Incomplete error states
- Generic UI that doesn't match intent
- Constant back-and-forth clarification

**The problem isn't the LLM—it's that we're using documentation designed for humans.**

---

## What is the Specification Pyramid?

The Specification Pyramid is a four-layer documentation framework that inverts traditional software specification. Instead of broad strokes that developers fill in, it provides increasing precision at each layer, ending with exact implementation instructions.

### Visual Representation

```
                    ┌─────────────────┐
                    │  VISION DOC     │  ← Why & What (Strategic)
                    │   (5-10 pages)  │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  ARCHITECTURE   │  ← How (System Design)
                    │   (20-60 pages) │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ FEATURE SPECS   │  ← Exactly What (Precise)
                    │ (10-30 per feat)│
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │     TASKS       │  ← Do This (Executable)
                    │   (Granular)    │
                    └─────────────────┘
```

### The Pyramid Structure

The pyramid narrows as you descend:
- **Top is broad:** Vision and strategy
- **Middle layers add precision:** Architecture and features
- **Bottom is exact:** Executable tasks

Think of it as **progressive refinement**—each layer adds detail until you reach instructions an LLM can execute without ambiguity.

---

## The Four Layers Explained

### Layer 1: Vision Document (The "What" and "Why")

**Purpose:** Define what you're building and why it matters.

**Audience:** Humans (stakeholders, team members, future you) + LLM for context

**Length:** 5-10 pages

**Contents:**
- **Product Overview:** One-paragraph description of what this is
- **Problem Statement:** What user pain does this solve?
- **Target Users:** Who is this for? (Specific, not generic personas)
- **Core Use Cases:** 5-10 concrete scenarios of how people will use this
- **Success Criteria:** Measurable outcomes that define success
- **Out of Scope:** What you're explicitly NOT building (prevent scope creep)
- **Key Decisions:** Major product choices and their rationale

**Example Vision Statement:**
```
Multi-Persona Chat is a desktop application that lets users create AI-powered
"chat rooms" where multiple Claude personas discuss topics together. Unlike
traditional single-AI chat, users get diverse perspectives by having personas
with different expertise, communication styles, and viewpoints collaborate
on problems.

Target user: Knowledge workers, writers, and decision-makers who want to
explore ideas from multiple angles without assembling actual human groups.
```

**What Makes a Good Vision Doc:**
- ✅ Specific use cases with names and scenarios
- ✅ Clear success metrics (not vanity metrics)
- ✅ Explicit scope boundaries
- ✅ Written in plain language
- ❌ No technical implementation details
- ❌ No UI mockups or wireframes
- ❌ No database schemas or API specs

### Layer 2: Architecture Document (The "How")

**Purpose:** Define the technical foundation and major system decisions.

**Audience:** LLM + technical stakeholders

**Length:** 20-60 pages

**Contents:**
- **Tech Stack:** Every library, framework, and tool with versions
- **System Architecture:** How components interact (with diagrams)
- **Data Models:** All entities, relationships, and schemas
- **API Contracts:** Every endpoint, function signature, and IPC call
- **File Structure:** Complete directory layout
- **Database Schema:** Full DDL for all tables
- **State Management:** How data flows through the application
- **Authentication/Authorization:** Security model and implementation
- **External Integrations:** Third-party services and APIs
- **Development Conventions:** Code style, naming, and patterns
- **Non-Functional Requirements:** Performance, security, scalability specs

**Example Architecture Decision:**
```typescript
// State Management: Zustand with TypeScript
interface AppState {
  rooms: Room[];
  activeRoomId: string | null;
  personas: Persona[];
  addRoom: (room: Room) => void;
  removeRoom: (id: string) => void;
  setActiveRoom: (id: string) => void;
}

// Rationale: Zustand over Redux because:
// - Less boilerplate for small/medium apps
// - Better TypeScript support out of the box
// - Simpler mental model for AI code generation
// - No provider wrapper needed
```

**What Makes a Good Architecture Doc:**
- ✅ Every interface fully typed with comments
- ✅ Complete database schema with constraints
- ✅ Exact versions of all dependencies
- ✅ Rationale for major technical decisions
- ✅ Examples of how components interact
- ✅ Clear naming conventions
- ❌ No vague descriptions like "modern web stack"
- ❌ No missing pieces that require inference
- ❌ No "TBD" or "will decide later"

#### Modular Architecture Documentation (For Large Projects)

**Problem:** Large architecture documents can exceed AI context limits (25,000+ tokens).

**Solution:** Split architecture into focused sub-documents organized in a directory:

```
docs/
├── architecture/
│   ├── index.md              # Overview with links to all sub-docs
│   ├── local-development.md  # Dev environment setup
│   ├── tech-stack.md          # Technologies and versions
│   ├── system-design.md       # High-level architecture
│   ├── data-models.md         # Entities and schemas
│   ├── api-contracts.md       # Server Actions, APIs
│   ├── file-structure.md      # Directory layout
│   ├── security.md            # Security architecture
│   ├── email-system.md        # Email integration
│   ├── ai-integration.md      # AI/ML systems
│   ├── rate-limiting.md       # Protection mechanisms
│   ├── conventions.md         # Code style and patterns
│   ├── requirements.md        # Non-functional requirements
│   ├── workflow.md            # Development workflow
│   └── deployment.md          # Deployment strategy
```

**Benefits of Modular Architecture:**
- ✅ Each document stays under AI context limits
- ✅ Easy to update specific sections without affecting others
- ✅ Quick navigation to relevant information
- ✅ Clear separation of concerns
- ✅ Can read only what you need for current work

**The index.md Pattern:**

The index.md serves as a navigation hub with:
1. Version info and changelog
2. Brief overview of the architecture
3. Links to all sub-documents with descriptions
4. Quick navigation guides for different use cases

**Example index.md structure:**

```markdown
# Technical Architecture

**Version:** 3.0
**Date:** 2025-10-11

## Overview
[Brief summary of architecture goals and benefits]

## Architecture Documents

### 1. [Local Development](./local-development.md)
Dev environment setup with Docker, database, cache...

### 2. [Tech Stack](./tech-stack.md)
Complete list of technologies with exact versions...

[... other sections ...]

## Quick Navigation

**For AI-Assisted Development:**
1. Start with Local Development
2. Review Tech Stack for exact versions
3. Reference Data Models for schemas
[... more guidance ...]
```

**When to Use Modular Architecture:**
- Architecture document > 20 pages
- Multiple distinct subsystems (auth, AI, email, etc.)
- Working with AI tools that have context limits
- Multiple developers need to reference different sections
- Frequent updates to specific areas

**When to Keep it Monolithic:**
- Small projects (< 10 features)
- Single, cohesive system
- Architecture document < 15 pages
- Solo developer with simple stack

### Layer 3: Feature Specifications (The "Exactly What")

**Purpose:** Define each feature with implementation-level precision.

**Audience:** Primarily LLM, secondarily humans

**Length:** 10-30 pages per feature

**Format:** Standardized template (consistency is critical)

**Contents for Each Feature:**
- **Feature Name & ID:** Unique identifier (e.g., "F-003: Message Composer")
- **User Story:** One sentence describing user value
- **Acceptance Criteria:** Must Have / Should Have / Won't Have
- **Technical Implementation:**
  - Data models with TypeScript interfaces
  - Database changes (SQL DDL)
  - Component breakdown with props and state
  - Service functions with signatures
  - IPC APIs (for Electron apps)
- **UI/UX Specification:**
  - ASCII wireframes
  - Exact Tailwind classes for styling
  - User flow step-by-step
  - Interactive states (hover, active, disabled)
- **Error Handling:** Every error case and its handling
- **Testing Requirements:** Specific test cases
- **Dependencies:** What must exist before this can be built

**Example Feature Spec Excerpt:**
```typescript
// Feature: Real-time Message Streaming

// Data Model
interface StreamingMessage {
  id: string;
  roomId: string;
  personaId: string;
  content: string;        // Accumulated content
  isStreaming: boolean;   // Currently receiving tokens
  timestamp: number;
  tokens: number;         // Total tokens received
}

// Component Props
interface MessageStreamProps {
  message: StreamingMessage;
  onComplete: (finalContent: string) => void;
}

// Acceptance Criteria
✓ Tokens appear within 100ms of being received from API
✓ Cursor blinks at end of streaming content
✓ User can stop stream mid-generation
✓ Completed messages are persisted to DB
✓ Network errors show retry option
```

**What Makes a Good Feature Spec:**
- ✅ No ambiguity in requirements
- ✅ All edge cases documented
- ✅ Exact component structure defined
- ✅ Database changes specified in SQL
- ✅ Error states explicitly handled
- ✅ Testable acceptance criteria
- ❌ No "nice-to-have" without defining what that means
- ❌ No "user-friendly" without specifying exact behavior
- ❌ No implementation gaps that require guessing

### Layer 4: Tasks (The "Do This")

**Purpose:** Break features into atomic, executable work items.

**Audience:** LLM (especially tools like Claude Code)

**Length:** 1-3 paragraphs per task

**Granularity:** Each task should be completable in one session

**Contents:**
- **Task ID:** Unique identifier linked to parent feature
- **Title:** Clear, action-oriented (verb + noun)
- **Description:** Exact steps to complete
- **Files to Modify:** Specific file paths
- **Code to Add/Change:** Precise instructions
- **Test Command:** How to verify it works
- **Dependencies:** What must be done first

**Example Task:**
```
Task ID: T-F003-002
Feature: Message Composer (F-003)
Title: Implement Token Counter Display

Description:
Add a real-time token counter to the message input that updates as the
user types. Counter should show current tokens and warn when approaching
model limit (4000 tokens for Claude Sonnet).

Files:
- src/components/MessageComposer.tsx
- src/utils/tokenCounter.ts (create new)

Implementation:
1. Create tokenCounter.ts with estimateTokens(text: string): number
   - Use simple heuristic: words * 1.3 (good enough approximation)
2. Add tokenCount state to MessageComposer
3. Update tokenCount on every input change (debounced 100ms)
4. Display in bottom-right of textarea
5. Turn orange when > 3500 tokens, red when > 4000

Styling:
- Text: text-sm text-gray-500
- Warning: text-orange-500
- Error: text-red-500
- Position: absolute bottom-2 right-2

Acceptance:
✓ Counter updates within 100ms of typing
✓ Color changes at correct thresholds
✓ Doesn't impact typing performance
✓ Accessible via screen readers

Test:
npm run dev → Type long message → Verify count and colors
```

**What Makes a Good Task:**
- ✅ Atomic (can't be broken down further)
- ✅ Specific files and functions named
- ✅ Exact styling classes provided
- ✅ Clear definition of "done"
- ✅ Easy to verify completion
- ❌ No vague instructions
- ❌ No multiple separate concerns mixed together
- ❌ No missing context that requires reading other docs

---

## Why This Framework Works for LLMs

### 1. **Matches LLM Strengths**

LLMs excel at:
- Following precise instructions
- Implementing well-defined patterns
- Generating code from clear specifications
- Working with structured data

LLMs struggle with:
- Inferring intent from vague descriptions
- Making subjective design decisions
- Understanding implicit requirements
- Resolving ambiguity

**The Specification Pyramid eliminates LLM weaknesses by providing the precision they need.**

### 2. **Progressive Refinement**

Each layer adds detail:
- Vision → "Build a chat app with multiple AI personas"
- Architecture → "Use React + TypeScript + Electron + Zustand + SQLite"
- Features → "Persona creation form with name, role, expertise fields using specific Tailwind classes"
- Tasks → "Create PersonaForm.tsx with exact interface, validation rules, and error messages"

By the time you reach tasks, there's **no ambiguity left**.

### 3. **Context Without Noise**

Traditional PRDs mix:
- Strategic thinking (why we're building this)
- User research (market validation)
- Feature descriptions (what to build)
- Success metrics (how we measure)

LLMs don't need market analysis to write code. The pyramid separates:
- **Human context** (Vision) from **implementation detail** (Features/Tasks)
- **Strategic decisions** (Architecture) from **tactical work** (Tasks)

This means you can give Claude just the layers it needs for the task at hand.

### 4. **Testable Everything**

Every layer has clear verification:
- **Vision:** Do use cases work end-to-end?
- **Architecture:** Can the system handle the requirements?
- **Features:** Does it meet acceptance criteria?
- **Tasks:** Can you check it off the list?

No subjective "looks good" or "feels right"—everything is measurable.

### 5. **Parallelizable by Design**

Features are independent modules:
- Can be built in any order (once dependencies are met)
- Can be assigned to different AI sessions
- Can be tested in isolation
- Can be refactored without breaking others

This matches how LLMs work best: focused, bounded problems with clear inputs and outputs.

---

## Core Principles

These principles underpin the entire framework:

### 1. **Precision Over Prose**

**Traditional:** "The interface should be intuitive and easy to navigate."

**Specification Pyramid:**
```
Navigation consists of:
- Sidebar: 240px wide, fixed position, dark gray background (#1F2937)
- Items: 16px padding, hover state changes background to #374151
- Active item: Blue left border (4px, #3B82F6) + blue text
- Click navigation item → setActiveView(item.id) → render corresponding component
```

**Rule:** If an LLM would need to guess or make assumptions, you haven't been precise enough.

### 2. **Show, Don't Tell**

**Traditional:** "Users can manage their personas."

**Specification Pyramid:**
```typescript
interface PersonaManagerProps {
  personas: Persona[];
  onAdd: (persona: Persona) => void;
  onEdit: (id: string, updates: Partial<Persona>) => void;
  onDelete: (id: string) => void;
}

// UI Layout:
┌─────────────────────────────────────┐
│  My Personas                    [+] │
├─────────────────────────────────────┤
│  📊 Data Analyst          [Edit][×] │
│  🎨 Creative Writer       [Edit][×] │
│  🔧 Systems Engineer      [Edit][×] │
└─────────────────────────────────────┘

Interactions:
- [+] button → Opens PersonaFormModal
- [Edit] button → Opens PersonaFormModal with pre-filled data
- [×] button → Shows confirmation: "Delete [name]? This cannot be undone."
```

**Rule:** Provide examples, code snippets, wireframes, and exact specifications instead of descriptions.

### 3. **Explicit Dependencies**

Every feature/task lists what must exist first:

```
Feature: Message Search
Dependencies:
- F-001: Database setup (messages table exists)
- F-003: Message display (UI components to show results)
- F-007: Full-text search enabled on SQLite

Task: Add Search Input
Dependencies:
- T-F003-001: MessageList component exists
- T-F001-005: FTS5 extension enabled
```

**Rule:** Never assume an LLM knows what order to build things. Make it explicit.

### 4. **Modular and Atomic**

Each feature should be:
- **Independent:** Doesn't require changes to other features
- **Complete:** Contains everything needed to implement it
- **Testable:** Has clear pass/fail criteria

Each task should be:
- **Atomic:** Can't be broken down further
- **Single-purpose:** Does one thing well
- **Time-boxed:** Completable in one focused session

**Rule:** If a feature or task description contains "and also," it should probably be split.

### 5. **Error States Are First-Class**

Happy path + error handling both get equal detail:

```
User Flow:
1. User clicks "Create Room"
2. System validates name (3-50 chars, alphanumeric + spaces)
   - ✓ Valid → Create room, add to list, navigate to room
   - ✗ Invalid → Show error below input: "Name must be 3-50 characters"
3. User selects personas (min 2, max 6)
   - ✓ Valid selection → Enable "Create" button
   - ✗ < 2 selected → Keep button disabled, show hint: "Select at least 2 personas"
   - ✗ > 6 selected → Disable further selection, show: "Maximum 6 personas"
4. User clicks "Create"
   - ✓ Success → Navigate to room
   - ✗ Network error → Show retry option: "Failed to create room. [Retry]"
   - ✗ Database error → Show error + log: "Something went wrong. Please try again."
```

**Rule:** Every user action should have defined success, validation failure, and system error states.

### 6. **Technology-Specific**

Don't say "modern web framework"—say "React 18.2.0 with TypeScript 5.0."

Don't say "database"—say "SQLite 3.42 with FTS5 extension enabled."

Don't say "styled nicely"—say "bg-blue-500 hover:bg-blue-600 px-4 py-2 rounded-lg."

**Rule:** Be specific about every technology, version, and implementation detail.

### 7. **Consistency Through Templates**

Use the same format for every feature spec. Use the same structure for every task.

This allows LLMs to:
- Parse documentation more reliably
- Know where to find specific information
- Generate consistent output

**Rule:** Create templates for Vision, Architecture, Features, and Tasks—then stick to them religiously.

---

## How to Use the Specification Pyramid

### Step-by-Step Process

#### Phase 1: Vision (Strategic Thinking)

**Time Investment:** 2-4 hours

**Process:**
1. **Start with the problem:** What pain are you solving? For whom?
2. **Define success:** What does "done" look like? What are the metrics?
3. **Write use cases:** 5-10 specific scenarios with named users and concrete actions
4. **Set boundaries:** What are you explicitly NOT building?
5. **Review:** Does this give clear direction without implementation detail?

**Output:** 5-10 page Vision Document

**Tip:** Write this for humans first, LLMs second. This is your north star when making decisions.

#### Phase 2: Architecture (Technical Foundation)

**Time Investment:** 4-8 hours

**Process:**
1. **Choose your stack:** Be specific about every technology and version
2. **Design data models:** Every entity, relationship, and field
3. **Define APIs:** Every function signature, IPC call, and endpoint
4. **Structure the codebase:** Complete file/folder layout
5. **Document patterns:** How will you handle auth, errors, state, etc.?
6. **Create schemas:** Full database DDL with types, constraints, indexes
7. **Consider modular architecture:** If document exceeds 20 pages, split into focused sub-documents (see Modular Architecture Documentation)
8. **Review:** Could an LLM implement any feature using just this doc?

**Output:** 20-60 page Architecture Document (or modular docs/architecture/ directory)

**Tip:** This is the most critical document. Invest time here to save 10x later. For large projects, use modular architecture to stay under AI context limits.

#### Phase 3: Feature Breakdown (Detailed Specs)

**Time Investment:** 1-2 hours per feature

**Process:**
1. **List all features:** Break product into 15-30 distinct features
2. **Prioritize:** Order by dependencies and value
3. **Create spec template:** Standardize structure for consistency
4. **Write specs sequentially:** Start with foundation features
5. **For each feature:**
   - User story and value proposition
   - Must Have / Should Have / Won't Have
   - Data models and schemas
   - Component breakdown
   - UI/UX wireframes with exact styling
   - Error handling for every case
   - Test criteria
6. **Review:** Is every detail specified? Could you hand this to an LLM today?

**Output:** 10-30 page specification per feature

**Tip:** Don't write all specs upfront. Write 3-5 foundation features, build them, then write more.

#### Phase 4: Task Generation (Executable Work)

**Time Investment:** 30-60 minutes per feature

**Process:**
1. **Read the feature spec completely**
2. **Break into atomic tasks:** Each task = one focused coding session
3. **Order by dependencies:** What must be done first?
4. **For each task:**
   - Clear, action-oriented title
   - Exact files to create/modify
   - Specific code to add/change
   - Test command to verify
5. **Review:** Could you hand each task to Claude Code individually?

**Output:** 5-15 tasks per feature

**Tip:** Generate tasks just-in-time. Don't create tasks for features you won't build for months.

### Workflow with AI Tools

#### Option A: Claude Code (Command Line)

```bash
# 1. Feed architecture + feature spec
$ cat docs/architecture.md docs/features/F-003-message-composer.md | claude-code

# 2. Give specific task
$ echo "Implement Task T-F003-002: Token Counter Display" | claude-code

# 3. Review changes
$ git diff

# 4. Test
$ npm run dev

# 5. Commit or iterate
```

#### Option B: Claude Chat (Conversational)

```
You: I'm building [product name]. Here's my Architecture Doc and Feature Spec
for [feature name]. [Paste docs]

Can you implement [specific task/component]?

Claude: [Generates code]

You: [Tests, provides feedback]

Claude: [Iterates]
```

#### Option C: Cursor / GitHub Copilot (In-Editor)

1. Keep Architecture and Feature Specs open in editor tabs
2. Reference them in code comments
3. Let autocomplete pull from your specifications
4. Use chat sidebar for specific questions

### When to Update the Pyramid

**Vision Doc:** Rarely (only for major pivots)

**Architecture Doc:** When you:
- Add a new technology or library
- Change a fundamental pattern
- Add a new data model
- Modify database schema

**Feature Specs:** When you:
- Discover edge cases during implementation
- Get user feedback that changes requirements
- Realize the spec was ambiguous

**Tasks:** Continuously as you work through them

**Golden Rule:** Keep specs in sync with reality. Don't let documentation drift from implementation.

---

## Implementation Example

Let's walk through creating a Specification Pyramid for a simple feature: **User Authentication**

### Layer 1: Vision Excerpt

```markdown
## Authentication Requirements

Users need a way to securely access their private chat rooms and persona
configurations. Since this is a desktop app with no server component, we'll
use local authentication with encrypted storage.

**Use Case:**
Sarah launches the app for the first time. She creates a master password,
which encrypts her local database. On subsequent launches, she enters her
password to unlock the app. If she forgets her password, there's no recovery—
this is a security feature, not a bug.

**Success Criteria:**
- Users can set and change master passwords
- Database remains encrypted at rest
- No way to bypass authentication
- Clear warning about password loss = data loss
```

### Layer 2: Architecture Excerpt

```markdown
## Authentication System

**Technology:** SQLCipher (SQLite with encryption)

**Flow:**
1. On first launch: User sets master password → encrypts database
2. On subsequent launches: User enters password → attempts to open database
3. Incorrect password: Show error, allow retry
4. Correct password: Load app state

**Schema:**

```sql
-- No users table needed (single user app)
-- Password is used as encryption key for entire database
-- Store only a hash for password change verification

CREATE TABLE app_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Store bcrypt hash of password for change verification
-- This is separate from SQLCipher encryption key
INSERT INTO app_config (key, value) VALUES
  ('password_hash', '[bcrypt hash]');
```

**Security Requirements:**
- SQLCipher key derivation: PBKDF2 with 256,000 iterations
- Password change: Requires old password + new password
- No password hints (they're security theater)
- No "forgot password" (impossible without server)
- Lock app after 15 minutes of inactivity

**Implementation:**

```typescript
// src/services/auth.ts

interface AuthService {
  // First-time setup
  initializeDatabase(password: string): Promise<void>;

  // Unlock database
  unlockDatabase(password: string): Promise<boolean>;

  // Change password
  changePassword(oldPassword: string, newPassword: string): Promise<boolean>;

  // Lock app
  lockApp(): void;

  // Check if locked
  isLocked(): boolean;
}
```

**Dependencies:**
- `@journeyapps/sqlcipher`: 5.3.1
- `bcryptjs`: 2.4.3
```

### Layer 3: Feature Spec

```markdown
# Feature Spec: Authentication Lock Screen

**Feature ID:** F-002
**Dependencies:** F-001 (Database Setup)

## User Story
As a user, I need to enter my master password to access the app so that my
chat history and personas remain private.

## Acceptance Criteria

### Must Have
1. Lock screen appears on app launch if database is encrypted
2. Password input is masked (type="password")
3. "Unlock" button is disabled until password length >= 8
4. Incorrect password shows error: "Incorrect password"
5. Correct password unlocks app and navigates to main view
6. After 3 failed attempts, add 2-second delay before next attempt
7. Warning text explains: "No password recovery available"

### Should Have
1. "Show password" toggle (eye icon)
2. Remember window position and size on unlock
3. Focus password input on load

### Won't Have (V1)
- Biometric authentication (fingerprint/face)
- Password hints
- Multiple user accounts

## Technical Implementation

### Data Models

```typescript
interface UnlockAttempt {
  timestamp: number;
  success: boolean;
}

interface LockScreenState {
  password: string;
  showPassword: boolean;
  error: string | null;
  isUnlocking: boolean;
  failedAttempts: number;
  lastAttemptTime: number;
}
```

### Components

**LockScreen.tsx**
- Props: `onUnlock: () => void`
- State: `LockScreenState`
- Functions:
  - `handlePasswordChange(e: ChangeEvent<HTMLInputElement>)`
  - `handleSubmit(e: FormEvent)`
  - `toggleShowPassword()`
  - `checkRateLimit(): boolean`

### UI Layout

```
┌─────────────────────────────────────────┐
│                                         │
│          🔒 Multi-Persona Chat          │
│                                         │
│      ┌───────────────────────────┐     │
│      │ Password: [············] 👁│     │
│      └───────────────────────────┘     │
│                                         │
│          [      Unlock      ]           │
│                                         │
│   ⚠️  No password recovery available    │
│       Keep your password safe!          │
│                                         │
└─────────────────────────────────────────┘
```

### Styling

```tsx
<div className="min-h-screen flex items-center justify-center bg-gray-900">
  <div className="bg-gray-800 p-8 rounded-lg shadow-xl w-96">
    <h1 className="text-2xl font-bold text-white text-center mb-6">
      🔒 Multi-Persona Chat
    </h1>

    <form onSubmit={handleSubmit}>
      <div className="relative mb-4">
        <input
          type={showPassword ? "text" : "password"}
          value={password}
          onChange={handlePasswordChange}
          placeholder="Enter password"
          className="w-full px-4 py-2 bg-gray-700 text-white rounded
                     border border-gray-600 focus:border-blue-500
                     focus:outline-none"
          autoFocus
        />
        <button
          type="button"
          onClick={toggleShowPassword}
          className="absolute right-3 top-2.5 text-gray-400
                     hover:text-white"
        >
          {showPassword ? "🙈" : "👁"}
        </button>
      </div>

      {error && (
        <div className="text-red-400 text-sm mb-4">{error}</div>
      )}

      <button
        type="submit"
        disabled={password.length < 8 || isUnlocking}
        className="w-full py-2 bg-blue-600 text-white rounded
                   hover:bg-blue-700 disabled:bg-gray-600
                   disabled:cursor-not-allowed"
      >
        {isUnlocking ? "Unlocking..." : "Unlock"}
      </button>
    </form>

    <div className="mt-4 text-sm text-gray-400 text-center">
      ⚠️ No password recovery available<br/>
      Keep your password safe!
    </div>
  </div>
</div>
```

## Error Handling

| Error Case | Handling | User Message |
|------------|----------|--------------|
| Password < 8 chars | Disable submit button | (none - just disabled state) |
| Incorrect password | Show error, clear input | "Incorrect password" |
| 3+ failed attempts | Add 2s delay | "Too many attempts. Wait 2 seconds." |
| Database file corrupted | Fatal error | "Database corrupted. Cannot unlock." |
| SQLCipher not available | Fatal error | "Encryption library missing. Reinstall app." |

## Test Cases

- [ ] Lock screen appears on encrypted database
- [ ] Password input is masked by default
- [ ] Eye icon toggles password visibility
- [ ] Submit button disabled for passwords < 8 chars
- [ ] Incorrect password shows error message
- [ ] Error clears on next input
- [ ] Correct password unlocks and navigates to main app
- [ ] Rate limiting activates after 3 failed attempts
- [ ] Focus moves to password input on mount
- [ ] Warning text is visible and readable
```

### Layer 4: Tasks

```markdown
## Task Breakdown: Authentication Lock Screen

### T-F002-001: Create LockScreen Component Structure
**Estimated Time:** 30 minutes

Create the basic LockScreen component with state management and form structure.

**Files to Create:**
- `src/components/LockScreen.tsx`
- `src/components/__tests__/LockScreen.test.tsx`

**Implementation:**
```tsx
import React, { useState, FormEvent, ChangeEvent } from 'react';

interface LockScreenProps {
  onUnlock: () => void;
}

interface LockScreenState {
  password: string;
  showPassword: boolean;
  error: string | null;
  isUnlocking: boolean;
  failedAttempts: number;
  lastAttemptTime: number;
}

export const LockScreen: React.FC<LockScreenProps> = ({ onUnlock }) => {
  const [state, setState] = useState<LockScreenState>({
    password: '',
    showPassword: false,
    error: null,
    isUnlocking: false,
    failedAttempts: 0,
    lastAttemptTime: 0,
  });

  const handlePasswordChange = (e: ChangeEvent<HTMLInputElement>) => {
    setState(prev => ({
      ...prev,
      password: e.target.value,
      error: null, // Clear error on input
    }));
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    // Implementation in next task
  };

  const toggleShowPassword = () => {
    setState(prev => ({ ...prev, showPassword: !prev.showPassword }));
  };

  return (
    // UI implementation in next task
    <div>Lock Screen</div>
  );
};
```

**Acceptance:**
✓ Component compiles without errors
✓ State is properly typed
✓ Event handlers are defined
✓ Exports correctly

---

### T-F002-002: Implement Lock Screen UI
**Estimated Time:** 45 minutes
**Dependencies:** T-F002-001

Add the complete UI with styling, form elements, and layout.

**Files to Modify:**
- `src/components/LockScreen.tsx`

**Replace return statement with:**
```tsx
return (
  <div className="min-h-screen flex items-center justify-center bg-gray-900">
    <div className="bg-gray-800 p-8 rounded-lg shadow-xl w-96">
      <h1 className="text-2xl font-bold text-white text-center mb-6">
        🔒 Multi-Persona Chat
      </h1>

      <form onSubmit={handleSubmit}>
        <div className="relative mb-4">
          <input
            type={state.showPassword ? "text" : "password"}
            value={state.password}
            onChange={handlePasswordChange}
            placeholder="Enter password"
            className="w-full px-4 py-2 bg-gray-700 text-white rounded
                       border border-gray-600 focus:border-blue-500
                       focus:outline-none"
            autoFocus
            aria-label="Password"
          />
          <button
            type="button"
            onClick={toggleShowPassword}
            className="absolute right-3 top-2.5 text-gray-400
                       hover:text-white transition-colors"
            aria-label={state.showPassword ? "Hide password" : "Show password"}
          >
            {state.showPassword ? "🙈" : "👁"}
          </button>
        </div>

        {state.error && (
          <div
            className="text-red-400 text-sm mb-4 px-3 py-2 bg-red-900/20 rounded"
            role="alert"
          >
            {state.error}
          </div>
        )}

        <button
          type="submit"
          disabled={state.password.length < 8 || state.isUnlocking}
          className="w-full py-2 bg-blue-600 text-white rounded
                     hover:bg-blue-700 disabled:bg-gray-600
                     disabled:cursor-not-allowed transition-colors
                     font-medium"
        >
          {state.isUnlocking ? "Unlocking..." : "Unlock"}
        </button>
      </form>

      <div className="mt-4 text-sm text-gray-400 text-center">
        ⚠️ No password recovery available<br/>
        Keep your password safe!
      </div>
    </div>
  </div>
);
```

**Acceptance:**
✓ UI matches the wireframe
✓ Input autofocuses on mount
✓ Password toggle works
✓ Submit button disabled for passwords < 8 chars
✓ Warning text is visible

**Test:**
```bash
npm run dev
# Navigate to lock screen
# Verify visual appearance
# Test password toggle
# Test button disabled state
```

---

### T-F002-003: Integrate Authentication Service
**Estimated Time:** 1 hour
**Dependencies:** T-F002-002, Architecture (AuthService must exist)

Connect the LockScreen component to the authentication service for actual unlocking.

**Files to Modify:**
- `src/components/LockScreen.tsx`

**Add import:**
```tsx
import { authService } from '../services/auth';
```

**Replace handleSubmit:**
```tsx
const handleSubmit = async (e: FormEvent) => {
  e.preventDefault();

  // Check rate limiting
  const now = Date.now();
  if (state.failedAttempts >= 3) {
    const timeSinceLastAttempt = now - state.lastAttemptTime;
    if (timeSinceLastAttempt < 2000) {
      const remainingTime = Math.ceil((2000 - timeSinceLastAttempt) / 1000);
      setState(prev => ({
        ...prev,
        error: `Too many attempts. Wait ${remainingTime} seconds.`,
      }));
      return;
    } else {
      // Reset counter after delay has passed
      setState(prev => ({ ...prev, failedAttempts: 0 }));
    }
  }

  setState(prev => ({ ...prev, isUnlocking: true, error: null }));

  try {
    const success = await authService.unlockDatabase(state.password);

    if (success) {
      onUnlock();
    } else {
      setState(prev => ({
        ...prev,
        password: '', // Clear password on failure
        isUnlocking: false,
        error: 'Incorrect password',
        failedAttempts: prev.failedAttempts + 1,
        lastAttemptTime: now,
      }));
    }
  } catch (error) {
    console.error('Unlock error:', error);
    setState(prev => ({
      ...prev,
      password: '',
      isUnlocking: false,
      error: 'Failed to unlock database. Please try again.',
      failedAttempts: prev.failedAttempts + 1,
      lastAttemptTime: now,
    }));
  }
};
```

**Acceptance:**
✓ Correct password unlocks the app
✓ Incorrect password shows error and clears input
✓ Rate limiting activates after 3 failures
✓ Error messages are user-friendly
✓ Loading state shows during unlock attempt

**Test:**
```bash
npm run dev
# Enter wrong password 3 times
# Verify rate limiting activates
# Wait 2 seconds
# Enter correct password
# Verify app unlocks
```

---

### T-F002-004: Add Error Boundary and Edge Cases
**Estimated Time:** 30 minutes
**Dependencies:** T-F002-003

Handle edge cases and fatal errors gracefully.

**Files to Modify:**
- `src/components/LockScreen.tsx`

**Add useEffect for fatal errors:**
```tsx
import { useState, FormEvent, ChangeEvent, useEffect } from 'react';

// Inside component, after state declaration:
useEffect(() => {
  // Check if database is accessible
  const checkDatabase = async () => {
    try {
      const isInitialized = await authService.isDatabaseInitialized();
      if (!isInitialized) {
        setState(prev => ({
          ...prev,
          error: 'Database not initialized. Please reinstall the app.',
        }));
      }
    } catch (error) {
      setState(prev => ({
        ...prev,
        error: 'Failed to access database. Please check installation.',
      }));
    }
  };

  checkDatabase();
}, []);
```

**Add keyboard shortcuts:**
```tsx
useEffect(() => {
  const handleKeyDown = (e: KeyboardEvent) => {
    // Ctrl/Cmd + V to toggle password visibility
    if ((e.ctrlKey || e.metaKey) && e.key === 'v') {
      e.preventDefault();
      toggleShowPassword();
    }
  };

  window.addEventListener('keydown', handleKeyDown);
  return () => window.removeEventListener('keydown', handleKeyDown);
}, []);
```

**Acceptance:**
✓ Database initialization errors are caught
✓ Fatal errors show helpful messages
✓ Keyboard shortcut (Ctrl+V) toggles password visibility
✓ Component doesn't crash on errors

**Test:**
```bash
# Test with corrupted database
# Test with missing SQLCipher
# Test keyboard shortcuts
# Verify error messages are clear
```

---

### T-F002-005: Add Unit Tests
**Estimated Time:** 1 hour
**Dependencies:** T-F002-004

Write comprehensive tests for the LockScreen component.

**Files to Modify:**
- `src/components/__tests__/LockScreen.test.tsx`

**Implementation:**
```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LockScreen } from '../LockScreen';
import { authService } from '../../services/auth';

jest.mock('../../services/auth');

describe('LockScreen', () => {
  const mockOnUnlock = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders lock screen with password input', () => {
    render(<LockScreen onUnlock={mockOnUnlock} />);

    expect(screen.getByPlaceholderText('Enter password')).toBeInTheDocument();
    expect(screen.getByText('🔒 Multi-Persona Chat')).toBeInTheDocument();
    expect(screen.getByText(/No password recovery available/)).toBeInTheDocument();
  });

  it('disables submit button when password is too short', () => {
    render(<LockScreen onUnlock={mockOnUnlock} />);

    const submitButton = screen.getByRole('button', { name: /unlock/i });
    expect(submitButton).toBeDisabled();

    const input = screen.getByPlaceholderText('Enter password');
    fireEvent.change(input, { target: { value: 'short' } });

    expect(submitButton).toBeDisabled();
  });

  it('enables submit button when password is 8+ characters', () => {
    render(<LockScreen onUnlock={mockOnUnlock} />);

    const input = screen.getByPlaceholderText('Enter password');
    fireEvent.change(input, { target: { value: 'password123' } });

    const submitButton = screen.getByRole('button', { name: /unlock/i });
    expect(submitButton).not.toBeDisabled();
  });

  it('toggles password visibility', async () => {
    render(<LockScreen onUnlock={mockOnUnlock} />);

    const input = screen.getByPlaceholderText('Enter password') as HTMLInputElement;
    expect(input.type).toBe('password');

    const toggleButton = screen.getByLabelText(/show password/i);
    fireEvent.click(toggleButton);

    expect(input.type).toBe('text');

    fireEvent.click(toggleButton);
    expect(input.type).toBe('password');
  });

  it('calls onUnlock when correct password is entered', async () => {
    (authService.unlockDatabase as jest.Mock).mockResolvedValue(true);

    render(<LockScreen onUnlock={mockOnUnlock} />);

    const input = screen.getByPlaceholderText('Enter password');
    fireEvent.change(input, { target: { value: 'correctpassword' } });

    const form = screen.getByRole('button', { name: /unlock/i }).closest('form');
    fireEvent.submit(form!);

    await waitFor(() => {
      expect(authService.unlockDatabase).toHaveBeenCalledWith('correctpassword');
      expect(mockOnUnlock).toHaveBeenCalled();
    });
  });

  it('shows error message for incorrect password', async () => {
    (authService.unlockDatabase as jest.Mock).mockResolvedValue(false);

    render(<LockScreen onUnlock={mockOnUnlock} />);

    const input = screen.getByPlaceholderText('Enter password');
    fireEvent.change(input, { target: { value: 'wrongpassword' } });

    const form = screen.getByRole('button', { name: /unlock/i }).closest('form');
    fireEvent.submit(form!);

    await waitFor(() => {
      expect(screen.getByText('Incorrect password')).toBeInTheDocument();
      expect(mockOnUnlock).not.toHaveBeenCalled();
    });
  });

  it('implements rate limiting after 3 failed attempts', async () => {
    (authService.unlockDatabase as jest.Mock).mockResolvedValue(false);

    render(<LockScreen onUnlock={mockOnUnlock} />);

    const input = screen.getByPlaceholderText('Enter password');
    const form = screen.getByRole('button', { name: /unlock/i }).closest('form');

    // Fail 3 times
    for (let i = 0; i < 3; i++) {
      fireEvent.change(input, { target: { value: 'wrong' + i } });
      fireEvent.submit(form!);
      await waitFor(() => screen.getByText('Incorrect password'));
    }

    // 4th attempt should be rate limited
    fireEvent.change(input, { target: { value: 'wrong4' } });
    fireEvent.submit(form!);

    await waitFor(() => {
      expect(screen.getByText(/Too many attempts/)).toBeInTheDocument();
    });
  });

  it('clears error message when user types', async () => {
    (authService.unlockDatabase as jest.Mock).mockResolvedValue(false);

    render(<LockScreen onUnlock={mockOnUnlock} />);

    const input = screen.getByPlaceholderText('Enter password');
    fireEvent.change(input, { target: { value: 'wrongpassword' } });

    const form = screen.getByRole('button', { name: /unlock/i }).closest('form');
    fireEvent.submit(form!);

    await waitFor(() => {
      expect(screen.getByText('Incorrect password')).toBeInTheDocument();
    });

    fireEvent.change(input, { target: { value: 'newattempt' } });

    expect(screen.queryByText('Incorrect password')).not.toBeInTheDocument();
  });
});
```

**Acceptance:**
✓ All tests pass
✓ Test coverage > 90%
✓ Edge cases are tested
✓ Rate limiting is tested
✓ Error states are tested

**Test:**
```bash
npm run test -- LockScreen.test.tsx
# Verify all tests pass
npm run test:coverage
# Verify > 90% coverage
```
```

---

## Summary of the Example

This example demonstrates how each layer builds on the previous:

1. **Vision** sets the strategic context (local auth, no recovery)
2. **Architecture** defines the technical approach (SQLCipher, specific libraries)
3. **Feature Spec** provides exact UI, behavior, and error handling
4. **Tasks** break it into executable work items with code samples

By the time you reach Task 5, an LLM has everything it needs to implement this feature without ambiguity.

---

## Common Pitfalls and How to Avoid Them

### Pitfall 1: Vague Requirements

❌ **Bad:** "The app should be fast and responsive."

✅ **Good:**
```
Performance Requirements:
- Message render time: < 50ms for 100 messages
- Search results: < 200ms for 10,000 messages
- App launch time: < 2 seconds on modern hardware
- Memory usage: < 500MB with 50 chat rooms loaded
```

**Fix:** Replace adjectives with numbers. Replace subjective terms with measurable criteria.

### Pitfall 2: Missing Edge Cases

❌ **Bad:** "User can upload images."

✅ **Good:**
```
Image Upload Requirements:
- Accepted formats: PNG, JPG, WEBP, GIF
- Max file size: 10MB
- Min dimensions: 100x100px
- Max dimensions: 4096x4096px

Error Handling:
- File too large → "Image must be under 10MB"
- Wrong format → "Please upload PNG, JPG, WEBP, or GIF"
- Dimensions too small → "Image must be at least 100x100 pixels"
- Upload fails → Show retry button with error message
- Network timeout (30s) → "Upload timed out. Please try again."
```

**Fix:** List every error case and its handling explicitly.

### Pitfall 3: Implicit Dependencies

❌ **Bad:** Feature list with no order

✅ **Good:**
```
Build Order:
1. F-001: Database Setup (no dependencies)
2. F-002: Authentication (requires F-001)
3. F-003: User Profile (requires F-002)
4. F-004: Message System (requires F-001, F-003)
5. F-005: Search (requires F-004)
```

**Fix:** Always specify what must exist before you can build something.

### Pitfall 4: Inconsistent Formatting

❌ **Bad:** Different structure for each feature spec

✅ **Good:** Use the exact same template for every feature:
- Same section headers
- Same order
- Same level of detail
- Same code formatting

**Fix:** Create a template and never deviate.

### Pitfall 5: Technology Ambiguity

❌ **Bad:** "Use a modern JavaScript framework"

✅ **Good:** "React 18.2.0 with TypeScript 5.0.4, Vite 4.3.9 as build tool"

**Fix:** Specify exact versions of every dependency.

### Pitfall 6: UI Without Exact Styling

❌ **Bad:** "A button that stands out"

✅ **Good:**
```tsx
<button className="px-6 py-3 bg-blue-600 hover:bg-blue-700
                   text-white font-semibold rounded-lg
                   transition-colors duration-200
                   disabled:bg-gray-400 disabled:cursor-not-allowed">
  Submit
</button>
```

**Fix:** Provide exact Tailwind classes or CSS.

### Pitfall 7: Testability Theater

❌ **Bad:** "Feature should work correctly"

✅ **Good:**
```
Test Cases:
1. Load page with 0 messages → Shows "No messages yet"
2. Load page with 1 message → Displays message correctly
3. Load page with 1000 messages → Renders within 500ms
4. Message with special chars → Escapes HTML correctly
5. Message > 10k chars → Truncates with "Show more"
6. Network error → Shows "Failed to load" with retry button
```

**Fix:** Write specific, verifiable test cases for every feature.

### Pitfall 8: Mixing Layers

❌ **Bad:** Vision doc with database schemas, or tasks with strategic reasoning

✅ **Good:** Keep each layer focused:
- Vision = Why and what (no technical detail)
- Architecture = How (system-level decisions)
- Features = Exactly what (implementation detail)
- Tasks = Do this (step-by-step instructions)

**Fix:** If you're writing architecture in your vision doc, move it down a layer.

### Pitfall 9: Premature Optimization

❌ **Bad:** Writing all 50 feature specs before building anything

✅ **Good:**
- Write Vision and Architecture fully
- Write 3-5 foundation feature specs
- Build those features
- Learn and adjust
- Write next batch of specs

**Fix:** Spec just-in-time, not just-in-case.

### Pitfall 10: Stale Documentation

❌ **Bad:** Implementation diverges from specs, specs never updated

✅ **Good:** When implementation reveals spec issues:
1. Update the spec immediately
2. Note what was wrong and why
3. Apply learnings to future specs

**Fix:** Treat specs as living documents, not write-once artifacts.

---

## Adapting the Framework

The Specification Pyramid is flexible. Here's how to adapt it for different scenarios:

### For Small Projects (< 10 features)

**Simplify:**
- Combine Vision + Architecture into one 10-15 page doc
- Keep feature specs but make them lighter (5-10 pages each)
- Skip tasks layer—work directly from feature specs

**Still maintain:**
- Precise specifications
- Complete data models
- Exact styling
- Error handling

### For Large Projects (50+ features)

**Expand:**
- Add a "System Architecture" layer between Vision and Architecture
- Create feature modules (groups of related features)
- Add integration specs (how features work together)
- Create a master dependency graph

**Add structure:**
- Feature roadmap with phases
- Version planning (what's in V1, V2, V3)
- Migration guides between versions

### For Teams (Multiple Developers)

**Add collaboration layers:**
- Feature ownership (who owns what)
- PR templates that reference spec sections
- Acceptance checklist from spec
- Shared component library with exact specs

**Communication:**
- Weekly spec reviews
- Spec approval process
- Change log for spec updates
- Slack channel for spec questions

### For API-First Products

**Extend Architecture:**
- OpenAPI/Swagger specs for all endpoints
- Request/response schemas with examples
- Error codes and messages catalog
- Rate limiting and auth specifications

**Add API-specific layers:**
- Endpoint specifications (like feature specs)
- Integration guides for clients
- SDK generation instructions

### For Mobile Apps

**Adjust Architecture:**
- Platform-specific considerations (iOS/Android)
- Native module specifications
- Offline-first data sync strategy
- App store optimization requirements

**Expand Feature Specs:**
- Touch interactions and gestures
- Different screen sizes and orientations
- Platform-specific UI patterns
- Accessibility requirements (VoiceOver, TalkBack)

### For AI/ML Products

**Add ML-specific layers:**
- Model architecture and requirements
- Training data specifications
- Evaluation metrics and thresholds
- Model versioning and rollback strategy

**Feature specs include:**
- Model input/output formats
- Fallback behavior when model fails
- Confidence thresholds
- A/B testing specifications

### For Refactoring Existing Code

**Modified approach:**
- Vision = What we're improving and why
- Architecture = Current state + target state
- Feature specs = Migration path for each component
- Tasks = Refactoring steps with rollback plans

**Add sections:**
- What's staying the same
- What's changing and why
- Migration strategy
- Rollback procedures

---

## Measuring Success

How do you know if your Specification Pyramid is working?

### Quantitative Metrics

**Speed of implementation:**
- Time from spec complete to feature shipped
- Compare with pre-pyramid timelines
- Track: Should decrease 30-50%

**Rework rate:**
- How often do you need to rewrite code?
- Count: "This isn't what I wanted" moments
- Track: Should decrease 60-80%

**Questions asked:**
- How many clarifications does the LLM need?
- Count: Follow-up questions per feature
- Track: Should be < 5 per feature

**Code quality:**
- How many bugs in first implementation?
- Test coverage achieved
- Track: Fewer bugs, higher coverage

### Qualitative Indicators

**Good signs:**
- LLM implementations match your vision
- Features work end-to-end on first try
- Edge cases are handled automatically
- Code follows consistent patterns
- You can hand specs to LLM and walk away

**Bad signs:**
- Constant "that's not what I meant"
- Generic implementations that need refinement
- Missing error handling
- Inconsistent UI across features
- You're still hand-coding everything

### Iteration Improvements

Track what you learn:
- What ambiguities appeared most often?
- Which sections of specs were most valuable?
- What level of detail is "just right"?
- Which features were easiest to specify?

Use this to:
- Improve your templates
- Add common patterns to architecture
- Build a spec library of reusable sections

---

## Advanced Techniques

### Technique 1: Specification Inheritance

Create reusable spec modules that multiple features inherit:

```markdown
## Standard Form Module

All forms in this app inherit these behaviors:

**Validation:**
- Real-time validation on blur
- Error messages below fields in red text
- Prevent submit until all fields valid

**Styling:**
- Labels: text-sm font-medium text-gray-700
- Inputs: px-4 py-2 border border-gray-300 rounded-lg
- Errors: text-sm text-red-600 mt-1
- Submit: bg-blue-600 hover:bg-blue-700 text-white

**Error Handling:**
- Network errors show toast notification
- Validation errors inline below field
- Success shows toast + redirect

Then in feature specs:
"Persona creation form inherits Standard Form Module + custom fields..."
```

### Technique 2: Decision Records

Document architectural decisions within specs:

```markdown
## ADR-003: Why SQLite Instead of PostgreSQL

**Context:** Need local database for desktop app

**Decision:** Use SQLite with SQLCipher

**Rationale:**
- No server setup required
- Built-in encryption available
- Excellent Electron support
- Perfect for single-user app
- 10x simpler than PostgreSQL

**Consequences:**
+ Simple deployment
+ Better privacy (local-only)
- Can't sync across devices (acceptable for V1)
- Limited concurrent writes (not an issue for single user)

**Alternatives Considered:**
- PostgreSQL: Overkill for local app
- IndexedDB: No SQL capabilities
- Realm: Unnecessary complexity
```

### Technique 3: Spec Versioning

Version your specs alongside code:

```markdown
# Feature Spec: Message Composer
**Version:** 2.1.0
**Last Updated:** 2024-10-01
**Status:** Implemented

## Changelog
- 2.1.0 (2024-10-01): Added markdown preview
- 2.0.0 (2024-09-15): Complete redesign with token counter
- 1.0.0 (2024-09-01): Initial version

## Current Implementation
[Spec content...]

## Deprecated Features (Removed in 2.0.0)
- Plain text only mode
- Character counter (replaced with token counter)
```

### Technique 4: Spec Testing

Yes, you can test your specs before implementation:

```markdown
## Spec Self-Test

Before implementing, verify this spec is complete:

□ Every data model has TypeScript interface
□ Every UI element has exact styling
□ Every user action has defined outcome
□ Every error case has handling strategy
□ Every function has signature and purpose
□ No words like "should", "could", "maybe"
□ No TBD or TODO items
□ Clear acceptance criteria (5-10 items)
□ Dependencies explicitly listed
□ Can answer: "How will I know it's done?"

If any box unchecked → spec is incomplete
```

### Technique 5: Progressive Disclosure

For complex features, layer the detail:

```markdown
# Feature Spec: Advanced Search

## Level 1: Overview (Read this first)
Simple search with filters and sorting.

## Level 2: User Perspective (What they see)
[UI wireframes, user flows, basic behavior]

## Level 3: Implementation (How it works)
[Data models, algorithms, API calls]

## Level 4: Edge Cases (All the details)
[Error handling, performance, security]

## Level 5: Testing (How to verify)
[Test cases, acceptance criteria]

Read levels in order. Skip levels only if you're sure you understand.
```

---

## Tools and Templates

### Recommended Tech Stack for Spec Management

**Documentation:**
- **Markdown** for all specs (readable, versionable, searchable)
- **Obsidian** or **Notion** for linking between specs
- **Git** for version control

**Diagrams:**
- **ASCII art** for simple wireframes (stays in markdown)
- **Mermaid** for system diagrams (renders in markdown)
- **Excalidraw** for complex visuals (export to PNG)

**Code Examples:**
- Always use syntax highlighting
- Include imports and types
- Show complete, runnable examples

### Spec Template Repository

Create a `/templates` directory:

```
templates/
├── vision-doc-template.md
├── architecture-template.md
├── feature-spec-template.md
├── task-template.md
├── adr-template.md (Architecture Decision Record)
└── examples/
    ├── example-vision.md
    ├── example-architecture.md
    └── example-feature.md
```

### Automation Opportunities

**Generate from specs:**
- TypeScript interfaces from data models
- Database migrations from schema changes
- Test skeletons from acceptance criteria
- OpenAPI specs from API definitions

**Validate specs:**
- Linter to check for TBD/TODO
- Parser to verify all interfaces are complete
- Checker to ensure dependencies exist
- Coverage tool (are all features specified?)

**Link code to specs:**
```typescript
// Feature: F-003 Message Composer
// Spec: docs/features/F-003-message-composer.md
// Task: T-F003-002 Token Counter
export function estimateTokens(text: string): number {
  // Implementation from spec...
}
```

---

## Real-World Results

### Case Study 1: Multi-Persona Chat (This Project)

**Without Specification Pyramid:**
- Estimated time: 3-4 months of iterative development
- Expected rework: 40-50%
- Clarity: Medium (lots of "let's see how it feels")

**With Specification Pyramid:**
- Estimated time: 3-4 weeks with Claude Code
- Expected rework: < 10%
- Clarity: High (every detail pre-decided)

**Key wins:**
- Vision doc surfaced scope issues before coding
- Architecture doc prevented tech debt
- Feature specs eliminated ambiguity
- Tasks made progress measurable

### Case Study 2: API Refactor

**Problem:** Existing API inconsistent, hard to maintain

**Solution:** Created Specification Pyramid for new API

**Results:**
- **Before:** 2 weeks to add new endpoint
- **After:** 2 days to add new endpoint (using spec template)
- **Quality:** Zero breaking changes in 6 months
- **Team:** New devs productive in days, not weeks

### Case Study 3: AI Code Generation

**Experiment:** Same feature, two approaches

**Approach A:** Traditional PRD (3 pages)
- Claude asked 27 clarification questions
- 5 major rewrites needed
- Final code: 60% of original kept
- Time: 8 hours of back-and-forth

**Approach B:** Specification Pyramid (20 pages)
- Claude asked 3 clarification questions
- 1 minor adjustment needed
- Final code: 95% of original kept
- Time: 1.5 hours total

**Insight:** More detailed specs = faster implementation

---

## FAQ

### "Isn't this just over-engineering?"

**Short answer:** Only if you're building a quick prototype you'll throw away.

**Long answer:**

The Specification Pyramid pays for itself when:
- Your product will be maintained > 3 months
- Multiple features need to work together
- You're using AI code generation
- You have a team (even just you + AI)
- Quality and consistency matter

It's NOT worth it when:
- Proof-of-concept to test an idea
- One-off script or tool
- Requirements are genuinely unknown
- You're still in discovery phase

**Rule of thumb:** If you're going to build it properly, spec it properly.

### "What if requirements change?"

**Answer:** Update the specs.

The Specification Pyramid makes changes easier, not harder:
- Clear dependency graph shows impact
- Modular features isolate changes
- Existing specs serve as templates
- You know exactly what to update

**Process:**
1. Update Vision if strategic change
2. Update Architecture if technical change
3. Update affected Feature Specs
4. Generate new Tasks
5. Commit changes to Git

**Key insight:** Changing a spec is faster than debugging ambiguous code.

### "How detailed is too detailed?"

**Answer:** When you're specifying implementation minutiae that don't matter.

**Too vague:**
```markdown
The button should look good.
```

**Just right:**
```markdown
Primary button: bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded-lg
```

**Too detailed:**
```markdown
The button should use RGB(37, 99, 235) with a hover state of RGB(29, 78, 216),
with padding-left of 16px, padding-right of 16px, padding-top of 8px,
padding-bottom of 8px, and border-radius of 8px, transitioning over 200ms
using cubic-bezier(0.4, 0, 0.2, 1)...
```

**Rule:** Specify enough that an LLM makes no subjective decisions.

### "Can I use this with human developers?"

**Answer:** Absolutely, but adapt it.

**For humans:**
- Vision Doc: Same
- Architecture: Same
- Feature Specs: Can be less detailed (humans infer more)
- Tasks: Optional (humans break down work themselves)

**For LLMs:**
- Vision Doc: Same
- Architecture: Same
- Feature Specs: More detailed (no inference)
- Tasks: Essential (explicit work breakdown)

**Best of both:** Write specs detailed enough for LLMs. Humans will appreciate the clarity too.

### "What about Agile/Scrum?"

**Answer:** Specification Pyramid works with Agile, not against it.

**How they fit:**
- **User Stories** → Vision Use Cases
- **Acceptance Criteria** → Feature Spec Acceptance Criteria
- **Sprint Planning** → Task breakdown from specs
- **Retrospectives** → Update specs based on learnings
- **Iterative Development** → Build and spec in parallel

**Key difference:** Agile says "working software over documentation." Specification Pyramid says "working software THROUGH documentation."

For AI-assisted development, the spec IS how you build working software.

### "How do I convince my team to use this?"

**Answer:** Start small and show results.

**Step 1:** Pick one feature
- Write full Specification Pyramid for it
- Build it with Claude/AI tools
- Track time, rework, questions

**Step 2:** Compare
- Show before/after metrics
- Demonstrate consistency
- Highlight fewer bugs

**Step 3:** Scale up
- Create templates for team
- Run workshop on framework
- Make it optional at first

**Selling points for stakeholders:**
- Faster development (30-50% reduction)
- Higher quality (fewer bugs)
- Better AI leverage (10x productivity gains)
- Clearer communication
- Less technical debt

### "What if I don't know all the details upfront?"

**Answer:** Spec what you know, iterate on the rest.

**Waterfall approach (NOT recommended):**
1. Spec everything
2. Build everything
3. Discover problems

**Iterative approach (RECOMMENDED):**
1. Write Vision (complete)
2. Write Architecture (complete)
3. Write 3-5 foundation feature specs
4. Build those features
5. Learn and adjust patterns
6. Write next batch of specs
7. Repeat

**Key:** Vision and Architecture should be complete. Feature specs can be done just-in-time.

### "Can I use this for non-code projects?"

**Answer:** Yes, with adaptations.

**Content creation:**
- Layer 1: Content strategy (Vision)
- Layer 2: Style guide (Architecture)
- Layer 3: Content briefs (Feature Specs)
- Layer 4: Writing tasks (Tasks)

**Business processes:**
- Layer 1: Process goals (Vision)
- Layer 2: Workflow design (Architecture)
- Layer 3: Procedure docs (Feature Specs)
- Layer 4: Action items (Tasks)

**Principle applies universally:** Progressive refinement from strategic to tactical.

---

## Getting Started Checklist

Ready to implement the Specification Pyramid? Follow these steps:

### Week 1: Foundation

□ **Read this entire guide**
□ **Pick your first project** (start small—3-10 features)
□ **Set up documentation system** (Markdown in Git)
□ **Create template files** (copy from this guide)
□ **Write your Vision Doc** (5-10 pages)
  - Product overview
  - Problem statement
  - Use cases (5-10 concrete scenarios)
  - Success criteria
  - Scope boundaries

### Week 2: Architecture

□ **Choose your tech stack** (with exact versions)
□ **Design data models** (all entities + relationships)
□ **Define APIs/interfaces** (complete signatures)
□ **Plan file structure** (full directory layout)
□ **Write Architecture Doc** (20-60 pages)
□ **Review with team/AI** (ensure no gaps)

### Week 3: Features

□ **List all features** (15-30 items)
□ **Order by dependencies** (what needs what)
□ **Prioritize** (foundation first, value second)
□ **Write 3-5 feature specs** (using template)
  - Must-haves clearly defined
  - UI/UX with exact styling
  - All error cases documented
  - Test criteria specified

### Week 4: Build

□ **Generate tasks** from feature specs
□ **Start building** (with Claude Code or AI tools)
□ **Track metrics** (time, questions, rework)
□ **Update specs** as you learn
□ **Iterate** (build → learn → improve specs)

### Ongoing

□ **Review specs monthly** (are they current?)
□ **Update templates** (incorporate learnings)
□ **Share patterns** (what works well?)
□ **Measure success** (compare before/after)
□ **Scale gradually** (add more features over time)

---

## Conclusion

The Specification Pyramid represents a fundamental shift in how we think about software documentation:

**Old paradigm:** Specs are for human developers who fill in the blanks.

**New paradigm:** Specs are precise instructions for AI that eliminate ambiguity.

### Key Takeaways

1. **LLMs need different specs than humans do** — more precision, less context
2. **Progressive refinement works** — Vision → Architecture → Features → Tasks
3. **Upfront investment pays off** — More detail = less rework
4. **Consistency is critical** — Templates and patterns scale success
5. **Specs are living documents** — Update them as you learn

### The Future of Development

As AI coding tools become more powerful, the bottleneck shifts from "writing code" to "knowing exactly what to build." The Specification Pyramid addresses this bottleneck.

**The developer's job is evolving:**
- Less: Writing boilerplate and implementation code
- More: Designing systems and specifying requirements
- Focus: Making good decisions, not typing fast

The Specification Pyramid is how you communicate those decisions to AI clearly, completely, and unambiguously.

### Start Today

You don't need to adopt the entire framework at once. Start with:

1. **Next feature you build:** Write a detailed spec first
2. **One project:** Apply Vision + Architecture
3. **Your workflow:** Add templates to your process

Track what works. Adjust what doesn't. Share your learnings.

### Resources

**Templates:**
- Vision Doc Template (see Appendix A)
- Architecture Template (see Appendix B)
- Feature Spec Template (see Appendix C)
- Task Template (see Appendix D)

**Further Reading:**
- Anthropic's prompt engineering guide
- System design principles
- Technical writing best practices
- Specification by example

**Community:**
- Share your Specification Pyramids
- Discuss what works (and what doesn't)
- Build a library of reusable patterns

---

## Appendix A: Vision Doc Template

```markdown
# [Product Name] - Vision Document

**Version:** 1.0
**Date:** YYYY-MM-DD
**Author:** [Your Name]
**Status:** Draft | Review | Approved

---

## Product Overview

[2-3 paragraph description of what this product is and what it does]

---

## Problem Statement

### What problem are we solving?
[Describe the user pain point]

### Who has this problem?
[Specific target users, not generic personas]

### How are they solving it today?
[Current alternatives and their shortcomings]

### Why does this matter?
[Impact if we solve this well]

---

## Use Cases

### Use Case 1: [Descriptive Name]

**Actor:** [Specific person - "Sarah, a product manager at a startup"]

**Context:** [When and why they're using your product]

**Steps:**
1. [What they do first]
2. [Next action]
3. [How it ends]

**Outcome:** [What value they got]

**Frequency:** [How often this happens - daily, weekly, monthly]

[Repeat for 5-10 use cases]

---

## Success Criteria

### Metrics That Matter

**User Success:**
- [Specific, measurable outcome]
- [Another measurable outcome]

**Business Success:**
- [Revenue/growth metric]
- [Engagement metric]

**Product Quality:**
- [Performance benchmark]
- [Reliability target]

### What "Good" Looks Like

In 6 months, success means:
- [Concrete milestone]
- [Another concrete milestone]
- [User feedback indicator]

---

## Scope

### In Scope (V1)

**Core Features:**
1. [Essential feature]
2. [Essential feature]
3. [Essential feature]

**Must-Have Capabilities:**
- [Critical capability]
- [Critical capability]

### Future Scope (V2+)

**Nice-to-Have:**
- [Feature for later]
- [Enhancement for later]

**Integrations:**
- [Third-party integration]
- [Platform expansion]

### Explicitly Out of Scope

**We are NOT building:**
- [Feature that might be tempting but isn't needed]
- [Common request that doesn't fit our vision]
- [Technical capability that's unnecessary]

**Rationale for exclusions:**
[Why we're saying no to these things]

---

## Key Decisions

### Decision 1: [Major Product Choice]

**What we decided:** [The decision]

**Why:** [Reasoning]

**Trade-offs:** [What we're giving up]

[Repeat for 3-5 major decisions]

---

## Open Questions

1. [Question we still need to answer]
2. [Another unresolved question]

**Research needed:**
- [What we need to learn]
- [Who we need to talk to]

---

## Success Definition

**This product is successful when:**
1. [Measurable outcome]
2. [User behavior we want to see]
3. [Business result we achieve]

**We'll know we failed if:**
1. [Red flag metric]
2. [Sign we missed the mark]
```

---

## Appendix B: Architecture Template

```markdown
# [Product Name] - Technical Architecture

**Version:** 1.0
**Date:** YYYY-MM-DD
**Author:** [Your Name]
**Status:** Draft | Review | Approved

---

## Tech Stack

### Frontend
- **Framework:** [React 18.2.0, Vue 3.3.0, etc.]
- **Language:** [TypeScript 5.0.4]
- **Build Tool:** [Vite 4.3.9, Webpack 5.88.0]
- **State Management:** [Zustand 4.3.9, Redux 8.1.0]
- **Styling:** [Tailwind CSS 3.3.2]
- **Icons:** [lucide-react 0.263.1]

### Backend (if applicable)
- **Runtime:** [Node.js 20.5.0]
- **Framework:** [Express 4.18.2]
- **Language:** [TypeScript 5.0.4]

### Database
- **Primary DB:** [SQLite 3.42.0, PostgreSQL 15.3]
- **ORM/Query Builder:** [Drizzle 0.28.5, Prisma 5.1.0]
- **Migrations:** [Custom scripts, Prisma Migrate]

### Desktop (if applicable)
- **Framework:** [Electron 25.3.0]
- **IPC:** [electron-trpc 0.5.0]

### Testing
- **Unit Tests:** [Vitest 0.33.0]
- **Component Tests:** [Testing Library 13.4.0]
- **E2E Tests:** [Playwright 1.36.0]

### Development Tools
- **Linter:** [ESLint 8.45.0]
- **Formatter:** [Prettier 3.0.0]
- **Type Checker:** [TypeScript 5.0.4]

---

## System Architecture

### Component Diagram

```
┌─────────────────────────────────────────┐
│         User Interface Layer            │
│  (React Components + Tailwind CSS)      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         State Management Layer          │
│         (Zustand Stores)                │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Service Layer                  │
│   (Business Logic + API Calls)          │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Data Layer                     │
│     (Database + File System)            │
└─────────────────────────────────────────┘
```

### Data Flow

1. User interaction in UI component
2. Component calls Zustand action
3. Action calls service function
4. Service updates database
5. Database change triggers state update
6. UI re-renders with new data

---

## Data Models

### Core Entities

```typescript
// Entity 1
interface User {
  id: string;              // UUID v4
  email: string;           // Valid email format
  name: string;            // 1-100 characters
  createdAt: number;       // Unix timestamp
  updatedAt: number;       // Unix timestamp
}

// Entity 2
interface Project {
  id: string;
  userId: string;          // Foreign key to User
  title: string;           // 1-200 characters
  description: string;     // 0-5000 characters
  status: 'active' | 'archived' | 'deleted';
  createdAt: number;
  updatedAt: number;
}

// Add all entities here
```

### Relationships

- User (1) → (many) Projects
- Project (1) → (many) Tasks
- Task (many) → (many) Tags

---

## Database Schema

```sql
-- Users table
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX idx_users_email ON users(email);

-- Projects table
CREATE TABLE projects (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL CHECK(status IN ('active', 'archived', 'deleted')),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_status ON projects(status);

-- Add all tables here
```

---

## API Contracts

### Service Functions

```typescript
// User Service
interface UserService {
  createUser(data: CreateUserInput): Promise<User>;
  getUser(id: string): Promise<User | null>;
  updateUser(id: string, data: Partial<User>): Promise<User>;
  deleteUser(id: string): Promise<void>;
  listUsers(filters?: UserFilters): Promise<User[]>;
}

// Project Service
interface ProjectService {
  createProject(data: CreateProjectInput): Promise<Project>;
  getProject(id: string): Promise<Project | null>;
  updateProject(id: string, data: Partial<Project>): Promise<Project>;
  deleteProject(id: string): Promise<void>;
  listProjects(userId: string, filters?: ProjectFilters): Promise<Project[]>;
}

// Add all services here
```

### IPC APIs (if Electron)

```typescript
interface ElectronAPI {
  // File operations
  readFile: (path: string) => Promise<string>;
  writeFile: (path: string, content: string) => Promise<void>;

  // Database operations
  query: (sql: string, params: any[]) => Promise<any[]>;

  // Add all IPC methods here
}
```

---

## File Structure

```
project-root/
├── src/
│   ├── main/                  # Electron main process (if applicable)
│   │   ├── index.ts
│   │   ├── ipc/
│   │   └── services/
│   ├── renderer/              # Frontend application
│   │   ├── components/
│   │   │   ├── common/
│   │   │   ├── features/
│   │   │   └── layouts/
│   │   ├── stores/
│   │   ├── services/
│   │   ├── utils/
│   │   ├── types/
│   │   ├── App.tsx
│   │   └── main.tsx
│   └── shared/                # Shared types/utils
│       ├── types/
│       └── constants/
├── docs/
│   ├── vision.md
│   ├── architecture.md
│   └── features/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

---

## State Management

### Zustand Store Structure

```typescript
// Main app store
interface AppState {
  // Current user
  currentUser: User | null;
  setCurrentUser: (user: User | null) => void;

  // Projects
  projects: Project[];
  addProject: (project: Project) => void;
  updateProject: (id: string, updates: Partial<Project>) => void;
  removeProject: (id: string) => void;

  // UI state
  sidebarOpen: boolean;
  toggleSidebar: () => void;

  // Add all state here
}
```

---

## Error Handling Strategy

### Error Types

```typescript
class AppError extends Error {
  code: string;
  statusCode: number;

  constructor(message: string, code: string, statusCode: number = 500) {
    super(message);
    this.code = code;
    this.statusCode = statusCode;
  }
}

// Specific error types
class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 'VALIDATION_ERROR', 400);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 'NOT_FOUND', 404);
  }
}

// Add all error types
```

### Error Handling Pattern

```typescript
// In services
async function getUser(id: string): Promise<User> {
  try {
    const user = await db.users.findOne({ id });
    if (!user) {
      throw new NotFoundError('User');
    }
    return user;
  } catch (error) {
    if (error instanceof AppError) throw error;
    logger.error('Unexpected error in getUser:', error);
    throw new AppError('Failed to fetch user', 'INTERNAL_ERROR');
  }
}

// In components
try {
  const user = await userService.getUser(id);
  setUser(user);
} catch (error) {
  if (error instanceof NotFoundError) {
    showToast('User not found', 'error');
  } else {
    showToast('Something went wrong', 'error');
  }
}
```

---

## Development Conventions

### Naming Conventions
- **Files:** kebab-case (`user-service.ts`)
- **Components:** PascalCase (`UserProfile.tsx`)
- **Functions:** camelCase (`getUserById`)
- **Constants:** UPPER_SNAKE_CASE (`MAX_FILE_SIZE`)
- **Types/Interfaces:** PascalCase (`UserData`)

### Code Style
- **Line length:** 80-100 characters
- **Indentation:** 2 spaces
- **Quotes:** Single quotes for strings
- **Semicolons:** Required
- **Trailing commas:** Required in multiline

### TypeScript Rules
- Strict mode enabled
- No `any` types (use `unknown` if needed)
- Explicit return types on functions
- Interfaces over type aliases for objects

### Component Structure
```tsx
// 1. Imports
import { useState } from 'react';
import { Button } from './Button';

// 2. Types
interface Props {
  title: string;
}

// 3. Component
export function MyComponent({ title }: Props) {
  // 4. State
  const [count, setCount] = useState(0);

  // 5. Effects
  useEffect(() => {}, []);

  // 6. Handlers
  const handleClick = () => {};

  // 7. Render
  return <div>{title}</div>;
}
```

---

## Non-Functional Requirements

### Performance
- **Page load:** < 2 seconds
- **Time to interactive:** < 3 seconds
- **Component render:** < 16ms (60 FPS)
- **Database queries:** < 100ms (95th percentile)

### Security
- **Input validation:** All user input sanitized
- **SQL injection:** Parameterized queries only
- **XSS protection:** React's built-in escaping
- **Authentication:** [Specify method]

### Scalability
- **Local storage:** Up to 1GB database
- **Concurrent operations:** [Number]
- **Max entities:** [Limits per type]

### Reliability
- **Uptime:** N/A (desktop app)
- **Data persistence:** All changes saved immediately
- **Backup:** User-initiated export to JSON
- **Error recovery:** Graceful degradation

---

## Development Workflow

### Setup
```bash
git clone [repo]
cd [project]
npm install
npm run dev
```

### Testing
```bash
npm run test              # Unit tests
npm run test:e2e          # E2E tests
npm run test:coverage     # Coverage report
```

### Building
```bash
npm run build            # Production build
npm run package          # Package for distribution
```

### Deployment
[Specify deployment process]

---

## Open Technical Questions

1. [Unresolved technical decision]
2. [Area needing more research]

**Decisions needed by:** [Date]

```

---

## Appendix C: Feature Spec Template

[See "Layer 3: Feature Specifications" section for complete template]

---

## Appendix D: Task Template

```markdown
## Task ID: T-[FEATURE_ID]-[TASK_NUMBER]

**Feature:** [Feature Name] (F-[ID])
**Title:** [Action-Oriented Task Title]
**Estimated Time:** [X minutes/hours]
**Dependencies:** [List of task IDs that must be complete first, or "None"]
**Status:** Not Started | In Progress | Complete

---

### Description

[2-3 sentences describing what needs to be done and why]

---

### Files to Create/Modify

**Create:**
- `path/to/new/file.ts`

**Modify:**
- `path/to/existing/file.ts`

---

### Implementation Steps

1. [First specific step]
2. [Second specific step]
3. [Third specific step]

---

### Code to Add

```typescript
// Location: src/path/to/file.ts

// Add this interface
interface NewInterface {
  field: string;
}

// Add this function
export function newFunction(param: Type): ReturnType {
  // Implementation details
  return result;
}
```

---

### Styling (if UI component)

```tsx
<div className="exact tailwind classes here">
  <button className="specific button classes">
    Click Me
  </button>
</div>
```

---

### Acceptance Criteria

✓ [Specific testable criterion]
✓ [Another specific criterion]
✓ [One more criterion]

---

### Testing

**Manual test:**
```bash
npm run dev
# 1. Do this action
# 2. Verify this outcome
# 3. Check this behavior
```

**Unit test location:**
`src/path/__tests__/file.test.ts`

**Test cases to add:**
- [ ] Test case 1
- [ ] Test case 2

---

### Notes

- [Any additional context]
- [Gotchas to watch for]
- [References to docs or examples]
```

---

## Final Thoughts

The Specification Pyramid is not just a documentation framework—it's a mindset shift for the AI era of software development.

**Remember:**
- Precision beats brevity
- Explicit beats implicit
- Tested beats assumed
- Modular beats monolithic

Start small. Iterate often. Share your learnings.

Happy building! 🚀
