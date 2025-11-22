# Rails-AI Test Suite

This directory contains all tests for Rails-AI skills, commands, and rules.

## Structure

```
test/
├── test_helper.rb              # Test configuration and helper methods
├── support/
│   ├── skill_test_case.rb      # Base test class for skill validation
│   ├── agent_integration_test_case.rb  # Base class for agent tests
│   └── llm_adapter.rb          # LLM integration for agent tests
├── unit/
│   ├── commands/               # Workflow command tests
│   │   └── command_structure_test.rb
│   ├── skills/                 # 11 domain skill test files
│   │   ├── controllers_test.rb
│   │   ├── debugging_test.rb
│   │   ├── hotwire_test.rb
│   │   ├── jobs_test.rb
│   │   ├── mailers_test.rb
│   │   ├── models_test.rb
│   │   ├── project_setup_test.rb
│   │   ├── security_test.rb
│   │   ├── styling_test.rb
│   │   ├── testing_test.rb
│   │   └── views_test.rb
│   └── rules/                  # Team rules tests
└── integration/                # Agent integration scenarios
```

## Running Tests

### Run all unit tests (fast):
```bash
rake test:unit
# or via CI
./bin/ci
```

### Run skill tests only:
```bash
rake test:unit:skills
```

### Run command tests only:
```bash
rake test:unit:commands
```

### Run a single unit test:
```bash
rake test:file[test/unit/skills/models_test.rb]
```

### Run integration tests (slow, individual scenarios):
```bash
rake test:integration:scenario[bootstrap]
rake test:integration:scenario[developer_agent]
```

### List available integration scenarios:
```bash
rake test:integration:list
```

## Test Coverage

### Skill Tests

Each skill test validates:

1. **Directory Structure**
   - Skill directory exists at `skills/{skill-name}/`
   - `SKILL.md` file exists in directory

2. **Frontmatter**
   - YAML frontmatter is present
   - Has `name` field
   - Has `description` field
   - Name has `rails-ai:` prefix

3. **Content Structure**
   - Has required XML sections: `<when-to-use>`, `<benefits>`, `<standards>`
   - XML tags are properly matched (opening/closing)
   - Has code examples

4. **Quality**
   - Description is not empty
   - Code examples are not empty

### Command Tests

Each workflow command test validates:

1. **Structure**
   - Command file exists
   - Has YAML frontmatter with description
   - Has `{{ARGS}}` placeholder

2. **Superpowers Integration**
   - References appropriate superpowers workflows
   - Feature/refactor/debug have completion checklists
   - bin/ci requirements documented

3. **Rails-AI Skills**
   - Describes which skills to load dynamically

## SkillTestCase Base Class

The `SkillTestCase` base class provides:

### Class Attributes
- `skill_name` - Full skill name (e.g., "rails-ai:models")
- `skill_directory` - Directory name (e.g., "models")

### Helper Methods
- `skill_path` - Full path to skill directory
- `skill_file_path` - Full path to SKILL.md
- `skill_content` - Loaded skill content
- `skill_metadata` - Parsed YAML frontmatter
- `frontmatter` - Raw frontmatter string

### Assertion Methods
- `assert_skill_directory_exists` - Validates directory exists
- `assert_has_skill_md_file` - Validates SKILL.md exists
- `assert_has_minimal_frontmatter` - Validates name and description
- `assert_name_has_rails_ai_prefix` - Validates rails-ai: prefix
- `assert_description_is_present` - Validates non-empty description
- `assert_skill_has_section(name)` - Validates XML section exists
- `assert_xml_tags_valid` - Validates XML tag matching
- `assert_code_examples_are_valid` - Validates code blocks exist

## Test Statistics

- **Total unit test files**: 15
- **Skill test files**: 11
- **Command test files**: 1
- **Rules test files**: 3
- **Skill coverage**: 100% (11/11 skills tested)
- **Command coverage**: 100% (6/6 commands tested)

## Known Variations

Some skills have different structures based on their purpose:

1. **security** - Attack-focused skill
   - Uses `<attack-vectors>` instead of `<benefits>`
   - Uses `<standards>` for security patterns

2. **debugging** - Tools-focused skill
   - Uses `<verification-checklist>` instead of `<benefits>`/`<standards>`
   - Provides Rails debugging tools and patterns

These variations are intentional and properly tested.

## Example Skill Test

```ruby
# frozen_string_literal: true

require "test_helper"

class ModelsTest < SkillTestCase
  self.skill_name = "models"
  self.skill_directory = "models"

  def test_skill_directory_exists
    assert_skill_directory_exists
  end

  def test_has_skill_md_file
    assert_has_skill_md_file
  end

  def test_has_minimal_frontmatter
    assert_has_minimal_frontmatter
  end

  def test_name_has_rails_ai_prefix
    assert_name_has_rails_ai_prefix
  end

  def test_description_is_present
    assert_description_is_present
  end

  def test_has_required_sections
    assert_skill_has_section("when-to-use")
    assert_skill_has_section("benefits")
    assert_skill_has_section("standards")
  end

  def test_xml_tags_valid
    assert_xml_tags_valid
  end

  def test_has_code_examples
    assert_code_examples_are_valid
  end
end
```

## Adding New Tests

### When adding a new skill:
1. Name format: `{skill_directory}_test.rb` (use underscores, not hyphens)
2. Class name: Convert to CamelCase + "Test" (e.g., `ModelsTest`)
3. Set `skill_name` and `skill_directory` class attributes
4. Include standard assertions
5. Customize for special cases

### When adding a new workflow command:
1. Add tests to `test/unit/commands/command_structure_test.rb`
2. Test for YAML frontmatter
3. Test for `{{ARGS}}` placeholder
4. Test for superpowers references
5. Test for completion checklist (if applicable)

## Skill Structure

Current skill structure:
- Path: `skills/{directory}/SKILL.md`
- Frontmatter: Minimal YAML (`name`, `description`)
- Naming: Directory name without prefix, frontmatter name has `rails-ai:` prefix

Example:
- Directory: `skills/models/`
- File: `skills/models/SKILL.md`
- Frontmatter name: `rails-ai:models`
