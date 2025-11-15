# Unit Tests for New Skills Structure

This directory contains unit tests for the new Rails-AI skills structure located in `/skills/`.

## Structure

```
test-new/
├── test_helper.rb              # Test configuration and helper methods
├── support/
│   └── skill_test_case.rb      # Base test class for skill validation
└── unit/
    └── skills/                 # 38 individual skill test files
        ├── accessibility_test.rb
        ├── action_mailer_test.rb
        ├── activerecord_patterns_test.rb
        └── ... (38 total)
```

## Running Tests

Run all tests:
```bash
ruby -Itest-new -e 'Dir.glob("test-new/unit/skills/*_test.rb").each { |f| require_relative f }'
```

Run a single test:
```bash
ruby -Itest-new test-new/unit/skills/tdd_minitest_test.rb
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

- **Total test files**: 38
- **Total lines of test code**: ~1,600
- **Tests per skill**: 8
- **Total test runs**: 304 (38 skills × 8 tests)

## Known Issues

Some skills don't follow the exact same XML structure:

1. **using-rails-ai** - Meta skill with different structure (doesn't have `<when-to-use>`, `<benefits>`, `<standards>`)
2. **Security skills** - Use `<attack-vectors>` instead of `<benefits>`
3. **debugging-rails** - Uses phase-specific sections instead of standard sections

These differences are intentional based on skill type. Tests may need customization for these special cases.

## Example Test

```ruby
# frozen_string_literal: true

require_relative "../../support/skill_test_case"

class TddMinitestTest < SkillTestCase
  self.skill_name = "rails-ai:tdd-minitest"
  self.skill_directory = "tdd-minitest"

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
2. Class name: Convert to CamelCase + "Test" (e.g., `TddMinitestTest`)
3. Set `skill_name` and `skill_directory` class attributes
4. Include standard assertions

## Migration Notes

These tests are designed for the **new** flat skill structure:
- Path: `skills/{directory}/SKILL.md`
- Frontmatter: Minimal (`name`, `description`)
- Naming: Directory has no prefix, but frontmatter name has `rails-ai:` prefix

Differences from old structure:
- Old: `skills/{domain}/{name}.md` (e.g., `skills/testing/tdd-minitest.md`)
- New: `skills/{name}/SKILL.md` (e.g., `skills/tdd-minitest/SKILL.md`)
- Old frontmatter: Rich metadata (domain, version, dependencies, etc.)
- New frontmatter: Minimal (name, description only)
