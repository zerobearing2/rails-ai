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

### Tier 2: Integration Tests (Slow, requires Claude CLI)
```bash
rake test:integration              # All integration scenarios
rake test:integration:scenario[X]  # Specific scenario
```

See [TESTING.md](TESTING.md) for comprehensive testing documentation.

### Running CI
```bash
# Quick check (linting + unit tests)
bin/ci

# Full check with integration tests
INTEGRATION=1 bin/ci
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
├── agents/          # 6 specialized Rails agents
├── skills/          # Modular skills registry
├── rules/           # Team rules and decision matrices
├── test/            # Minitest-based testing framework
├── bin/             # Development scripts
└── docs/            # Documentation and guides
```

## Agent and Skills Architecture

### Adding New Skills
1. Add skill to appropriate domain directory in `skills/`
2. Write unit tests in `test/unit/skills/`
3. Skills are validated through agent integration tests
4. Update agent prompts if the skill changes their capabilities
5. Document the skill with clear description and when to use it

### Modifying Agents
1. Agent files are in `agents/` directory
2. Test changes across multiple Rails projects
3. Ensure agent stays focused on its specialty
4. Update AGENTS.md if you change agent responsibilities
5. Follow the coordinator pattern (architect delegates to specialists)

## Getting Help

- Check the [README](README.md) for basic information
- Review [AGENTS.md](AGENTS.md) for agent architecture
- Browse the [docs/](docs/) directory for detailed guides
- Open an issue with the "question" label
- Reach out to maintainers

## Recognition

Contributors will be recognized in our README and release notes. Thank you for helping make rails-ai better!
