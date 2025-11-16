# Rails-AI Test Suite

This directory contains all tests for Rails-AI skills, agents, and rules.

## Structure

```
test/
├── test_helper.rb              # Test configuration and helper methods
├── support/
│   ├── skill_test_case.rb      # Base test class for skill validation
│   ├── agent_integration_test_case.rb  # Base class for agent tests
│   └── llm_adapter.rb          # LLM integration for agent tests
├── unit/
│   └── skills/                 # 9 consolidated skill test files
│       ├── configuration_test.rb
│       ├── controllers_test.rb
│       ├── debugging_test.rb
│       ├── jobs_mailers_test.rb
│       ├── models_test.rb
│       ├── security_test.rb
│       ├── testing_test.rb
│       ├── using_rails_ai_test.rb
│       └── views_test.rb
└── integration/                # 7 agent integration scenarios
    ├── bootstrap_test.rb
    ├── developer_agent_test.rb
    ├── devops_agent_test.rb
    ├── security_agent_test.rb
    ├── skill_loading_test.rb
    ├── superpowers_integration_test.rb
    ├── uat_agent_test.rb
    ├── README.md               # Integration test documentation
    └── QUICK_REFERENCE.md      # Quick integration test guide
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

Each skill test validates:

1. **Directory Structure**
   - Skill directory exists at `skills/{skill-name}/`
   - `SKILL.md` file exists in directory

2. **Frontmatter**
   - YAML frontmatter is present
   - Has `name` field
   - Has `description` field
   - Name has `rails-ai:` prefix (except `using-rails-ai` meta skill)

3. **Content Structure**
   - Has required XML sections: `<when-to-use>`, `<benefits>`, `<standards>`
   - XML tags are properly matched (opening/closing)
   - Has code examples

4. **Quality**
   - Description is not empty
   - Code examples are not empty

## SkillTestCase Base Class

The `SkillTestCase` base class provides:

### Class Attributes
- `skill_name` - Full skill name (e.g., "rails-ai:tdd-minitest")
- `skill_directory` - Directory name (e.g., "tdd-minitest")

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
- `assert_references_superpowers(skill)` - Validates superpowers reference

## Test Statistics

- **Total unit test files**: 9
- **Tests per skill**: 8
- **Total test runs**: 72 (9 skills × 8 tests)
- **Total integration scenarios**: 7
- **Skill coverage**: 100% (9/9 skills tested)

## Known Variations

Some skills have different structures based on their purpose:

1. **using-rails-ai** - Meta/documentation skill
   - Skips `test_has_required_sections` (uses markdown headers, not XML sections)
   - Skips `test_has_code_examples` (documentation-focused)

2. **security** - Attack-focused skill
   - Uses `<attack-vectors>` instead of `<benefits>`
   - Uses `<standards>` for security patterns

3. **debugging** - Phase-based skill
   - Uses `<superpowers-integration>` instead of `<benefits>`/`<standards>`
   - Integrates with superpowers:systematic-debugging workflow

These variations are intentional and properly tested.

## Example Test

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

When adding a new skill, create a corresponding test file:

1. Name format: `{skill_directory}_test.rb` (use underscores, not hyphens)
2. Class name: Convert to CamelCase + "Test" (e.g., `ModelsTest`, `JobsMailersTest`)
3. Set `skill_name` and `skill_directory` class attributes
4. Include standard assertions
5. Customize for special cases (meta skills, phase-based skills)

## Skill Structure

Current consolidated skill structure (v0.3.0):
- Path: `skills/{directory}/SKILL.md`
- Frontmatter: Minimal YAML (`name`, `description`)
- Naming: Directory name without prefix, frontmatter name has `rails-ai:` prefix
- 9 domain-organized skills (controllers, models, views, testing, security, configuration, jobs-mailers, debugging, using-rails-ai)

Example:
- Directory: `skills/models/`
- File: `skills/models/SKILL.md`
- Frontmatter name: `rails-ai:models`
