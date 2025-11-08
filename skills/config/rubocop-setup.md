---
name: rubocop-setup
domain: config
dependencies: []
version: 2.0
rails_version: 7.2+
criticality: REQUIRED

# Configuration
applies_to:
  - .rubocop.yml
  - Gemfile
---

# RuboCop Setup

RuboCop is a Ruby static code analyzer and formatter. **Rails 8 comes with RuboCop pre-configured via `rubocop-rails-omakase`** - DHH's opinionated style guide. This skill covers customizing that base configuration to enforce additional TEAM_RULES.md standards.

<when-to-use>
- Customizing stock Rails RuboCop configuration for team standards
- Adding team-specific style rules (Rules #16, #20)
- Configuring CI/CD to enforce code quality (Rule #17)
- Auditing existing projects for compliance with team standards
</when-to-use>

<benefits>
- **Start with Rails Defaults** - Build on top of rubocop-rails-omakase
- **Automatic Enforcement** - Style rules enforced by CI, not manual review
- **Consistency** - Same standards across all projects
- **Fast Feedback** - Catch issues before code review
- **Auto-Correction** - Many issues fixed automatically with `rubocop -a`
</benefits>

<standards>
- ALWAYS build on top of rubocop-rails-omakase (Rails 8 default)
- ALWAYS enable cops that enforce TEAM_RULES.md
- ALWAYS integrate with bin/ci (Rule #17)
- Only override rules when team standards differ from Rails defaults
</standards>

## Rails 8 Default Configuration

<pattern name="rails-8-default">
<description>Rails 8 comes with rubocop-rails-omakase by default</description>

**Stock .rubocop.yml in new Rails 8 apps:**
```yaml
# Omakase Ruby styling for Rails
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Overwrite or add rules to create your own house style
#
# # Use `[a, [b, c]]` not `[ a, [ b, c ] ]`
# Layout/SpaceInsideArrayLiteralBrackets:
#   Enabled: false
```

**What rubocop-rails-omakase provides:**
- DHH's opinionated Ruby style guide for Rails
- Reasonable defaults for Rails projects
- Pre-configured with best practices
- Automatically updates with gem updates

**Philosophy:** Start with these defaults and only override when your team standards differ.

</pattern>

## Team-Specific Customizations

<pattern name="team-overrides">
<description>Add TEAM_RULES.md-specific overrides to .rubocop.yml</description>

Customize the stock Rails configuration by adding overrides to `.rubocop.yml`:

```yaml
# .rubocop.yml

# Omakase Ruby styling for Rails
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Team-specific overrides (TEAM_RULES.md)

# Rule #16: Double Quotes Always
# Override omakase if it uses single quotes
Style/StringLiterals:
  EnforcedStyle: double_quotes

# Rule #20: Hash#dig for Nested Access
Style/HashFetchChain:
  Enabled: true

Style/DigChain:
  Enabled: true

# Additional team preferences (optional)
# Add any other team-specific rules here
```

**Key Points:**
- Inherit from rubocop-rails-omakase first
- Add overrides below inheritance
- Only override rules that conflict with team standards
- Comment each override with TEAM_RULES.md reference

</pattern>

## Additional Plugins (Optional)

<pattern name="additional-plugins">
<description>Optional RuboCop plugins for enhanced functionality</description>

Rails 8 includes basic RuboCop. Add these plugins if needed:

```ruby
# Gemfile
group :development, :test do
  # Already included in Rails 8:
  # gem "rubocop"
  # gem "rubocop-rails-omakase"

  # Optional: Add if using Minitest and want Minitest-specific cops
  gem "rubocop-minitest", require: false

  # Optional: Add if you want Rake-specific cops
  gem "rubocop-rake", require: false

  # Optional: Enhanced Rails cops (stricter than omakase)
  # gem "rubocop-rails", require: false
end
```

**Installation:**
```bash
bundle install
```

**When to add plugins:**
- **rubocop-minitest**: If you want stricter Minitest test style enforcement
- **rubocop-rake**: If you have complex Rake tasks that need linting
- **rubocop-rails**: If you want stricter Rails cops (N+1 detection, etc.)

**Note:** Most Rails projects don't need these plugins. The omakase defaults are sufficient.

</pattern>

## TEAM_RULES.md Enforcement

<pattern name="team-rules-cops">
<description>RuboCop cops that directly enforce TEAM_RULES.md</description>

| Rule | Cop | Enforcement | Auto-correctable |
|------|-----|-------------|------------------|
| Rule #16: Double Quotes | `Style/StringLiterals` | ✅ Always | Yes |
| Rule #20: Hash#dig | `Style/HashFetchChain`, `Style/DigChain` | ✅ Always | Yes |
| Rule #17: bin/ci Must Pass | RuboCop integrated in bin/ci | ✅ CI blocker | N/A |

**How it works:**

1. **Style/StringLiterals** - Enforces double quotes (Rule #16)
   ```ruby
   # Bad (detected and auto-corrected)
   name = 'John'

   # Good
   name = "John"
   ```

2. **Style/HashFetchChain** - Detects chained fetch calls (Rule #20)
   ```ruby
   # Bad (detected)
   hash.fetch(:a, nil)&.fetch(:b, nil)

   # Good (suggested)
   hash.dig(:a, :b)
   ```

3. **Style/DigChain** - Collapses chained dig calls (Rule #20)
   ```ruby
   # Bad (detected)
   hash.dig(:a).dig(:b).dig(:c)

   # Good (suggested)
   hash.dig(:a, :b, :c)
   ```

</pattern>

## Integration with bin/ci

<pattern name="rubocop-bin-ci">
<description>Integrating RuboCop with bin/ci (TEAM_RULES.md Rule #17)</description>

Rails 8 comes with `bin/rubocop` by default. Integrate it into your CI pipeline:

**In your Rakefile:**
```ruby
# Rakefile

# RuboCop is included in Rails 8, just add a task
desc "Run RuboCop"
task :rubocop do
  sh "bin/rubocop --display-cop-names"
end

desc "Run all CI checks"
task ci: [:test, :rubocop, :brakeman, :bundle_audit]
```

**In bin/ci:**
```bash
#!/usr/bin/env bash
set -e

echo "Running tests..."
bin/rails test

echo "Running RuboCop..."
bin/rubocop

echo "Running Brakeman (security)..."
bin/brakeman -q

echo "Running Bundler Audit..."
bundle exec bundler-audit check --update

echo "✅ All CI checks passed!"
```

**Usage:**
```bash
bin/ci                    # Run all checks (must pass before commit)
bin/rubocop               # Run RuboCop only
bin/rubocop -a            # Auto-fix violations
bin/rubocop -A            # Auto-fix all (including unsafe)
```

**IMPORTANT:** bin/ci must pass before committing (TEAM_RULES.md Rule #17).

</pattern>

## Common Commands

<pattern name="rubocop-commands">
<description>Essential RuboCop commands for daily workflow</description>

```bash
# Check code for violations (Rails 8 default command)
bin/rubocop

# Auto-correct safe violations
bin/rubocop -a

# Auto-correct all violations (including unsafe)
bin/rubocop -A

# Check specific file or directory
bin/rubocop app/models/user.rb
bin/rubocop app/controllers/

# Show cop names in output (useful for debugging)
bin/rubocop --display-cop-names

# Only run specific cops
bin/rubocop --only Style/StringLiterals

# Exclude specific cops (for testing)
bin/rubocop --except Metrics/MethodLength
```

**Best Practices:**
- Run `bin/rubocop -a` before committing (safe auto-corrections)
- Fix violations immediately (don't accumulate technical debt)
- Use `--display-cop-names` to understand which rule failed

</pattern>

## Auditing Existing Projects

<pattern name="rubocop-audit">
<description>Steps to audit and configure RuboCop in existing Rails projects</description>

### 1. Check if using rubocop-rails-omakase (Rails 8 default)
```bash
grep -q "rubocop-rails-omakase" .rubocop.yml && echo "✅ Using omakase" || echo "❌ Not using omakase"
```

### 2. If missing, add rubocop-rails-omakase
```ruby
# Gemfile
gem "rubocop-rails-omakase", group: [:development, :test]
```

```yaml
# .rubocop.yml
inherit_gem: { rubocop-rails-omakase: rubocop.yml }
```

### 3. Add team-specific overrides (Rules #16, #20)
```yaml
# .rubocop.yml
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Rule #16: Double Quotes
Style/StringLiterals:
  EnforcedStyle: double_quotes

# Rule #20: Hash#dig
Style/HashFetchChain:
  Enabled: true

Style/DigChain:
  Enabled: true
```

### 4. Run audit
```bash
bin/rubocop --display-cop-names
```

**If violations found:**
```bash
# Auto-fix what you can
bin/rubocop -a

# Review remaining violations
bin/rubocop

# Fix manually or configure exceptions with justification
```

### 5. Integrate with bin/ci
See "Integration with bin/ci" pattern above.

</pattern>

## Migrating from Legacy RuboCop Config

<pattern name="migrate-to-omakase">
<description>Migrating projects with custom RuboCop configs to rubocop-rails-omakase</description>

**For projects with large custom .rubocop.yml files:**

1. **Backup current config**
   ```bash
   cp .rubocop.yml .rubocop.yml.backup
   ```

2. **Start fresh with omakase base**
   ```yaml
   # .rubocop.yml
   inherit_gem: { rubocop-rails-omakase: rubocop.yml }
   ```

3. **Run RuboCop to see what changed**
   ```bash
   bin/rubocop > violations.txt
   ```

4. **Decide on strategy:**
   - **Option A: Adopt omakase** - Fix violations, embrace Rails defaults
   - **Option B: Override selectively** - Add overrides only for dealbreakers
   - **Option C: Keep custom config** - Don't use omakase (not recommended)

5. **Add minimal overrides**
   Only override rules that conflict with critical team standards:
   ```yaml
   inherit_gem: { rubocop-rails-omakase: rubocop.yml }

   # Only override critical team standards
   Style/StringLiterals:
     EnforcedStyle: double_quotes  # TEAM_RULES.md Rule #16

   Style/HashFetchChain:
     Enabled: true  # TEAM_RULES.md Rule #20
   ```

6. **Auto-fix what you can**
   ```bash
   bin/rubocop -a
   ```

7. **Commit the migration**
   ```bash
   git add .rubocop.yml
   git commit -m "Migrate to rubocop-rails-omakase with team overrides"
   ```

**Philosophy:** Trust the Rails defaults. Only override when truly necessary.

</pattern>

## Antipatterns

<antipatterns>
### ❌ DON'T: Replace rubocop-rails-omakase entirely

```yaml
# BAD: Throwing away Rails defaults
# inherit_gem: { rubocop-rails-omakase: rubocop.yml }

plugins:
  - rubocop-minitest
  - rubocop-rake

AllCops:
  NewCops: enable
  # ... 200 lines of custom configuration
```

**Problem:** You lose the benefit of Rails defaults and have to maintain everything yourself.

**Fix:** Inherit from omakase and only override what's necessary:
```yaml
# GOOD: Build on Rails defaults
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Only override team-specific rules
Style/StringLiterals:
  EnforcedStyle: double_quotes
```

### ❌ DON'T: Skip RuboCop in CI

```bash
# BAD: bin/ci without RuboCop
#!/usr/bin/env bash
bin/rails test  # Missing RuboCop check!
```

**Problem:** Violations slip into codebase, inconsistent style.

**Fix:** Always include RuboCop in bin/ci (Rule #17):
```bash
#!/usr/bin/env bash
set -e
bin/rails test
bin/rubocop      # ✅ Included
bin/brakeman -q
```

### ❌ DON'T: Disable cops globally without justification

```yaml
# BAD: Disabling cops wholesale
Style/StringLiterals:
  Enabled: false  # Why? This violates Rule #16!

Metrics/MethodLength:
  Enabled: false  # This is too broad!
```

**Problem:** Defeats purpose of linter, violates team standards.

**Fix:** Only disable for specific paths with clear reason:
```yaml
# GOOD: Targeted exclusions with reasons
Metrics/MethodLength:
  Exclude:
    - 'db/migrate/**/*'  # Migrations can be long
    - 'test/**/*'        # Test setup can be long
```

### ❌ DON'T: Use single quotes (violates Rule #16)

```ruby
# BAD: Detected by Style/StringLiterals
name = 'John'
message = 'Hello world'
```

**Problem:** Violates TEAM_RULES.md Rule #16 (Double Quotes Always).

**Fix:** Use double quotes:
```ruby
# GOOD: Enforced by RuboCop
name = "John"
message = "Hello world"
```

</antipatterns>

## Best Practices

<best-practices>
### ✅ DO: Start with Rails defaults

```yaml
# Good: Trust the Rails community defaults
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Only add team-specific overrides
Style/StringLiterals:
  EnforcedStyle: double_quotes
```

**Why:** Rails defaults are well-considered. Don't reinvent the wheel.

### ✅ DO: Auto-correct before committing

```bash
bin/rubocop -a
git add .
git commit -m "Fix RuboCop violations"
```

**Why:** Catch issues early, keep CI green.

### ✅ DO: Use cop names in overrides

```yaml
# Good: Clear what's overridden and why
Style/StringLiterals:
  EnforcedStyle: double_quotes  # TEAM_RULES.md Rule #16

# Why this override is necessary
```

**Why:** Future developers understand reasoning.

### ✅ DO: Run RuboCop in editor/IDE

Configure your editor to run RuboCop on save:
- **VS Code:** Ruby LSP extension
- **RubyMine:** Built-in RuboCop support
- **Vim/Neovim:** ALE or coc-rubocop

**Why:** Instant feedback, fix violations as you code.

### ✅ DO: Keep overrides minimal

```yaml
# Good: Only 2-3 critical overrides
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

Style/StringLiterals:
  EnforcedStyle: double_quotes

Style/HashFetchChain:
  Enabled: true
```

**Why:** Less to maintain, easier to upgrade rubocop-rails-omakase.

</best-practices>

## Troubleshooting

<troubleshooting>
### Issue: "Unrecognized cop Style/HashFetchChain"

```bash
Error: unrecognized cop Style/HashFetchChain
```

**Cause:** RuboCop version too old.

**Fix:**
```bash
bundle update rubocop
```

### Issue: Conflicts between omakase and team rules

**Example:** Omakase enforces single quotes, but Rule #16 requires double quotes.

**Solution:** Override in .rubocop.yml:
```yaml
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Team standard takes precedence
Style/StringLiterals:
  EnforcedStyle: double_quotes  # TEAM_RULES.md Rule #16
```

### Issue: Too many violations in legacy project

**Solution 1:** Auto-fix what you can:
```bash
bin/rubocop -a  # Safe fixes
bin/rubocop -A  # All fixes (review carefully)
```

**Solution 2:** Gradual adoption:
```yaml
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Temporarily disable problematic cops during migration
Metrics/MethodLength:
  Enabled: false  # TODO: Re-enable after refactoring
```

**Then:** Create tickets to address violations incrementally.

### Issue: RuboCop runs slowly

**Cause:** Checking too many files.

**Solution:** Exclude unnecessary directories:
```yaml
AllCops:
  Exclude:
    - 'vendor/**/*'
    - 'node_modules/**/*'
    - 'tmp/**/*'
    - 'log/**/*'
```

</troubleshooting>

## Quick Start Checklist

<implementation-checklist>
### New Rails 8 Project
- [x] RuboCop already configured via rubocop-rails-omakase
- [ ] Add team overrides to .rubocop.yml (Rules #16, #20)
- [ ] Run `bin/rubocop` to verify
- [ ] Auto-fix: `bin/rubocop -a`
- [ ] Integrate with bin/ci
- [ ] Run `bin/ci` to verify all checks pass
- [ ] Commit configuration

### Existing Project (Migrating to Omakase)
- [ ] Check if using rubocop-rails-omakase: `grep rubocop-rails-omakase .rubocop.yml`
- [ ] If not, add gem: `gem "rubocop-rails-omakase"`
- [ ] Update .rubocop.yml: `inherit_gem: { rubocop-rails-omakase: rubocop.yml }`
- [ ] Add team overrides (Rules #16, #20)
- [ ] Run `bin/rubocop` to see violations
- [ ] Auto-fix: `bin/rubocop -a`
- [ ] Review remaining violations
- [ ] Integrate with bin/ci
- [ ] Run `bin/ci` to verify
- [ ] Commit with message: "Migrate to rubocop-rails-omakase"

### Existing Project (Already Using Omakase)
- [ ] Verify team overrides present (Rules #16, #20)
- [ ] Run `bin/rubocop` to check compliance
- [ ] Auto-fix if needed: `bin/rubocop -a`
- [ ] Verify bin/ci integration
- [ ] Run `bin/ci` to verify all checks pass

</implementation-checklist>

## Custom Cops for Team-Specific Rules

<pattern name="custom-cops">
<description>Create custom RuboCop cops to enforce team-specific patterns not covered by stock RuboCop</description>

### When to Use Custom Cops

Use custom cops when:
- Team has coding standards not covered by existing RuboCop cops
- Need to enforce project-specific patterns or anti-patterns
- Want to catch common mistakes specific to your codebase
- Standardizing patterns across a large team

### Example: Detecting Nested Hash Bracket Access (Rule #20 Enhancement)

While `Style/HashFetchChain` and `Style/DigChain` handle chained `.fetch()` and `.dig()` calls, they **don't detect** the most dangerous pattern: nested bracket access like `hash[:a][:b][:c]`.

**Create a custom cop:**

```ruby
# lib/rails_ai/cops/style/nested_bracket_access.rb
# frozen_string_literal: true

module RailsAi
  module Cops
    module Style
      # Detects nested hash bracket access and suggests using Hash#dig or Hash#fetch
      class NestedBracketAccess < RuboCop::Cop::Base
      MSG = "Avoid nested bracket access `%<code>s`. " \
            "Use `dig` (safe) or chained `fetch` (raises) for explicit error handling."

      # Detects when a [] call is made on the result of another [] call
      def_node_matcher :nested_bracket_access?, <<~PATTERN
        (send (send $_ :[] $_) :[] $...)
      PATTERN

      def on_send(node)
        nested_bracket_access?(node) do
          next unless looks_like_hash_access?(node)
          add_offense(node, message: format(MSG, code: node.source))
        end
      end

      private

      def looks_like_hash_access?(node)
        inner_node = node.receiver
        return false unless inner_node&.send_type?
        has_hash_like_key?(node) || has_hash_like_key?(inner_node)
      end

      def has_hash_like_key?(node)
        first_arg = node.first_argument
        return false unless first_arg
        first_arg.sym_type? || first_arg.str_type?
      end
    end
  end
end
end
```

**Enable in .rubocop.yml:**

```yaml
# .rubocop.yml
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

# Load custom cops
require:
  - ./lib/rails_ai/cops/style/nested_bracket_access.rb

# Team overrides
Style/StringLiterals:
  EnforcedStyle: double_quotes

Style/HashFetchChain:
  Enabled: true

Style/DigChain:
  Enabled: true

# Custom cop configuration
Style/NestedBracketAccess:
  Enabled: true
  Severity: warning  # Warn only, don't fail CI yet
  Description: 'Detects nested hash bracket access and suggests Hash#dig'
```

**Test it:**

```bash
# Test on sample code
echo 'user[:profile][:theme]' | bundle exec rubocop --stdin test.rb \
  --require ./lib/rails_ai/cops/style/nested_bracket_access.rb \
  --only Style/NestedBracketAccess

# Output:
# test.rb:1:1: C: Style/NestedBracketAccess:
# Avoid nested bracket access `user[:profile][:theme]`.
# Use `dig` (safe) or chained `fetch` (raises) for explicit error handling.
```

**What it catches:**

```ruby
# ❌ BAD - Custom cop detects these
user[:profile][:settings][:theme]          # 3 levels deep
config[:database][:pool][:size]            # Hash access
hash["key1"]["key2"]                       # String keys
user[:profile][0]                          # Mixed hash/array

# ✅ GOOD - No violations
user.dig(:profile, :settings, :theme)      # Explicit safe access
config.fetch(:database).fetch(:pool)       # Explicit raising
user[:profile]                             # Single level is fine
```

### Custom Cop Resources

- **AST Explorer**: https://docs.rubocop.org/rubocop-ast/node_pattern.html
- **Node Patterns**: https://docs.rubocop.org/rubocop-ast/node_pattern.html
- **Writing Cops**: https://docs.rubocop.org/rubocop/development.html

</pattern>

## References

- [rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase) - Rails default RuboCop config
- [RuboCop Documentation](https://docs.rubocop.org/)
- [Ruby Style Guide](https://rubystyle.guide/)
- [RuboCop AST](https://docs.rubocop.org/rubocop-ast/) - For custom cops

## Related Skills

- **TEAM_RULES.md** - Rule #16 (Double Quotes), Rule #17 (bin/ci Must Pass), Rule #20 (Hash#dig)
- `tdd-minitest` - Testing workflow (integrates with bin/ci)
- `initializers-best-practices` - Code organization standards

## Related TEAM_RULES

- **Rule #16:** Double Quotes Always (enforced by Style/StringLiterals override)
- **Rule #17:** bin/ci Must Pass (RuboCop integrated)
- **Rule #20:** Hash#dig for Nested Access (enforced by Style/HashFetchChain, Style/DigChain overrides)
