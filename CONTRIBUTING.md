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

See [TESTING.md](TESTING.md) for comprehensive testing documentation.

### Running CI
```bash
# Run all linters and unit tests
bin/ci
```

## Coding Conventions

This project follows Rails conventions and 37signals philosophy:

### General Guidelines
- **Keep it simple** - Delete code, don't add complexity
- **Follow Rails conventions** - REST-only, no custom actions
- **Write tests first** - TDD (RED-GREEN-REFACTOR)
- **Use Minitest** - No RSpec
- **Follow the Solid Stack** - SolidQueue, SolidCache, SolidCable

### Plugin Development
- The architect agent coordinates work by loading Superpowers workflows and Rails-AI skills
- Skills should be modular and testable
- Follow the conventions in `rules/TEAM_RULES.md`
- Document skill capabilities clearly with YAML front matter

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
├── agents/          # @rails-ai:architect (single agent)
├── commands/        # /rails-ai:architect convenience command
├── skills/          # 12 domain-organized skills
├── rules/           # Team rules (TEAM_RULES.md)
├── test/            # Minitest-based testing framework
├── bin/             # Development scripts (setup, ci)
└── docs/            # Documentation and guides
```

## Agent and Skills Architecture

### Adding New Skills or Rules

When adding new skills or rules:

**Skills:**
- Add YAML front matter with name and description
- Follow existing skill structure in `skills/` directory
- Create corresponding unit tests in `test/unit/skills/`
- Document in `skills/using-rails-ai/SKILL.md` if it's a domain skill
- Update the architect agent if needed

**Rules:**
- Add to `rules/TEAM_RULES.md`
- Include in the quick lookup index
- Add enforcement severity level
- Create tests in `test/unit/rules/`

**Verification steps:**
1. ✅ Run `bin/ci` - All tests must pass
2. ✅ Run `rake lint:fix` - Fix any style issues
3. ✅ Commit with clear, descriptive message

## Getting Help

- Check the [README](README.md) for basic information
- Review `skills/using-rails-ai/SKILL.md` for architecture and usage
- Browse the [docs/](docs/) directory for detailed guides
- Open an issue with the "question" label
- Reach out to maintainers

## Recognition

Contributors will be recognized in our README and release notes. Thank you for helping make rails-ai better!
