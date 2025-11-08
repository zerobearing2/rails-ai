# Contributing to rails-ai

First off, thanks for taking the time to contribute!

The following is a set of guidelines for contributing to rails-ai. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (code snippets, screenshots, etc.)
- **Describe the behavior you observed** and what you expected
- **Include environment details** (Rails version, Ruby version, OS, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **List any alternatives you've considered**

### Pull Requests

1. **Fork the repo** and create your branch from `master`
2. **Follow our development setup** instructions in the README
3. **Write tests** for any new functionality (we use Minitest)
4. **Ensure all tests pass** by running `bin/ci`
5. **Follow our coding conventions** (see below)
6. **Write clear commit messages**
7. **Update documentation** if needed
8. **Submit your pull request in draft mode** (per our team conventions)

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/rails-ai.git
cd rails-ai

# Run setup
bin/setup

# Verify everything works
bin/ci
```

## Testing

We use a two-tier Minitest strategy:

### Tier 1: Unit Tests (Fast)
```bash
rake test:unit                     # Run all unit tests
rake test:unit:skills              # Skills only
rake test:unit:agents              # Agents only
```

### Tier 2: Integration Tests (Slow, requires Claude CLI - individual scenarios only)
```bash
rake test:integration:scenario[simple_model_plan]  # Specific scenario
```

**Note:** Bulk integration runs are disabled due to cost/time. Run scenarios individually.

See [TESTING.md](TESTING.md) for comprehensive testing documentation.

### Running CI
```bash
# Quick check (linting + unit tests)
bin/ci

# Note: Integration tests must be run individually, not via CI
# rake test:integration:scenario[simple_model_plan]
```

## Coding Conventions

This project follows Rails conventions and 37signals philosophy:

### General Guidelines
- **Keep it simple** - Delete code, don't add complexity
- **Follow Rails conventions** - REST-only, no custom actions
- **Write tests first** - TDD (RED-GREEN-REFACTOR)
- **Use Minitest** - No RSpec
- **Follow the Solid Stack** - SolidQueue, SolidCache, SolidCable

### Agent Development
- Agents should be focused and specialized
- Skills should be modular and testable
- Follow the decision matrices in `rules/`
- Document agent capabilities clearly

### Code Style
- Run `rake lint:fix` before committing
- Use 2 spaces for indentation
- Keep lines under 100 characters when reasonable
- Use descriptive variable and method names

### Commit Messages
- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Reference issues and pull requests when relevant
- First line should be 50 characters or less
- Add detailed description if needed after a blank line

### Documentation
- Update README.md if you change functionality
- Add/update comments for complex logic
- Keep CHANGELOG.md up to date
- Document new skills in the skills registry

## Project Structure

```text
rails-ai/
├── agents/          # 7 specialized Rails agents
├── skills/          # Modular skills registry
├── rules/           # Team rules and decision matrices
├── test/            # Minitest-based testing framework
├── bin/             # Development scripts
└── docs/            # Documentation and guides
```

## Agent and Skills Architecture

### Adding New Rules, Skills, or Agents

**⚠️ CRITICAL:** Before adding new resources, **always consult the comprehensive checklists** in [AGENTS.md - Contributor Checklists](AGENTS.md#contributor-checklists). These checklists ensure you update ALL required files and tests.

Quick reference:
- **[Adding a New Rule Checklist](AGENTS.md#-adding-a-new-rule)** - Covers TEAM_RULES.md, RULES_TO_SKILLS_MAPPING.yml, tests, and more
- **[Adding a New Skill Checklist](AGENTS.md#-adding-a-new-skill)** - Covers skill files, SKILLS_REGISTRY.yml, agent updates, tests
- **[Adding a New Agent Checklist](AGENTS.md#-adding-a-new-agent)** - Covers agent files, documentation, integration testing

**Common mistakes to avoid:**
- ❌ Forgetting to update counts in metadata sections
- ❌ Missing test file updates (hardcoded counts)
- ❌ Not updating AGENTS.md with new counts
- ❌ Forgetting to update relevant agent files
- ❌ YAML syntax errors (special characters like `[]`, `()`, `:`)

**Verification steps:**
1. ✅ Use the appropriate checklist from AGENTS.md
2. ✅ Run `bin/ci` - All tests must pass
3. ✅ Run `rake lint:fix` - Fix any style issues
4. ✅ Commit with clear, descriptive message

### Modifying Existing Resources
- **Rules:** Use checklist in [AGENTS.md - Updating Existing Resources](AGENTS.md#-updating-existing-resources)
- **Skills:** Update skill file, SKILLS_REGISTRY.yml, and affected agents
- **Agents:** Update agent file, AGENTS.md, and verify integration
- **Always run `bin/ci`** to verify changes

## Getting Help

- Check the [README](README.md) for basic information
- Review [AGENTS.md](AGENTS.md) for agent architecture
- Browse the [docs/](docs/) directory for detailed guides
- Open an issue with the "question" label
- Reach out to maintainers

## Recognition

Contributors will be recognized in our README and release notes. Thank you for helping make rails-ai better!
