# Development Setup

## Prerequisites

- Ruby 3.3.0+
- Bundler 2.5+

## Installation

```bash
# Install dependencies
bundle install

# Verify installation
bundle exec rake -T
```

## Running Tests

### Unit Tests (Fast)

```bash
# Run all unit tests
rake test:skills:unit

# Run specific skill test
ruby -Itest test/skills/unit/turbo_page_refresh_test.rb

# Run with verbose output
rake test:skills:unit TESTOPTS="-v"
```

### Integration Tests (Slow - Requires LLM APIs)

```bash
# Run all integration tests
INTEGRATION=1 rake test:skills:integration

# Run with cross-validation
INTEGRATION=1 CROSS_VALIDATE=1 rake test:skills:integration

# Set API keys
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
```

## Linting

### Run All Linters

```bash
# Default task runs linting + unit tests
rake

# Or run linters explicitly
rake lint
```

### Individual Linters

```bash
# Ruby code style
rake lint:ruby

# Markdown formatting
rake lint:markdown

# YAML validation
rake lint:yaml

# Auto-fix Ruby issues
rake lint:fix
```

### What Gets Linted

- **Ruby files**: `test/**/*.rb`, `Rakefile`
    - Style guide: Rubocop with Minitest extensions
    - Max line length: 120 characters
    - Frozen string literals required

- **Markdown files**: `skills/**/*.md`, `docs/**/*.md`, `*.md`
    - Style guide: Markdownlint
    - Max line length: 120 (code blocks exempt)
    - Allows inline HTML/XML tags

- **YAML front matter**: All skill files
    - Valid YAML syntax
    - Required fields present
    - Proper structure

## Pre-commit Hook (Optional)

```bash
# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running linters..."
bundle exec rake lint

if [ $? -ne 0 ]; then
  echo "Linting failed. Fix errors before committing."
  exit 1
fi
EOF

chmod +x .git/hooks/pre-commit
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Tests

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.3
          bundler-cache: true
      - run: bundle exec rake lint

  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.3
          bundler-cache: true
      - run: bundle exec rake test:skills:unit
```

## Coverage Report

```bash
# Generate test coverage report
rake test:skills:report

# Output:
# === Skill Test Coverage Report ===
# Total Skills: 33
# Unit Tests: 1
# Integration Tests: 1
# Coverage: 2.6%
```

## Troubleshooting

### Rubocop errors

```bash
# View offenses
bundle exec rubocop

# Auto-fix safe issues
bundle exec rubocop -a

# Auto-fix including unsafe
bundle exec rubocop -A
```

### Markdown linting errors

```bash
# Run with verbose output
bundle exec mdl -v skills/

# Ignore specific rule
bundle exec mdl -r ~MD013 skills/
```

### YAML validation errors

```bash
# Check specific file
ruby -e "require 'yaml'; puts YAML.load_file('skills/frontend/turbo-page-refresh.md')"
```

## Editor Integration

### VS Code

```json
{
  "ruby.rubocop.executePath": "bundle exec ",
  "ruby.rubocop.onSave": true,
  "[ruby]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "misogi.ruby-rubocop"
  }
}
```

### RubyMine

Settings → Editor → Inspections → Ruby → Gems and gem management → Rubocop

### Vim

```vim
" Add to .vimrc
Plugin 'ngmy/vim-rubocop'
let g:vimrubocop_rubocop_cmd = 'bundle exec rubocop'
```
