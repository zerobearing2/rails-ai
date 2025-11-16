# Skills Documentation Audit & Update Design

**Date:** 2025-11-16
**Status:** Validated

## Overview

Comprehensive audit and update of documentation resources across all 12 Rails-AI skills to ensure current, well-organized references to official Rails documentation.

## Goals

1. Add `<resources>` sections to skills missing them (debugging, using-rails-ai)
2. Audit all existing `<resources>` sections across 10 skills
3. Verify all documentation URLs are valid (automated check)
4. Review resources for relevance and currency (manual)
5. Organize all resources with topic grouping (Official Docs, Gems, Tools, Community)

## Scope

**What we'll do:**
- Add missing `<resources>` sections (2 skills)
- Audit existing resources for validity and relevance (10 skills)
- Organize all resources using standardized topic grouping
- Verify URLs are active and current

**What we won't do:**
- Change skill content or code examples
- Rewrite patterns to match Rails 8 specifics
- Update YAML frontmatter or other sections

**Version approach:** Link to stable Rails Guides URLs that work across versions, with version-specific callouts where features are Rails 8+ only (e.g., Solid Stack).

**Implementation:** Single batch update with one comprehensive commit covering all 12 skills.

## Resource Organization Structure

**Standard `<resources>` template:**

```markdown
<resources>

**Official Documentation:**
- [Rails Guides - Topic Name](https://guides.rubyonrails.org/...)
- [Rails API - ClassName](https://api.rubyonrails.org/...)

**Gems & Libraries:**
- [gem-name](https://github.com/owner/gem-name)
- [another-gem](https://rubygems.org/gems/another-gem)

**Tools & Testing:**
- [Tool Name](https://toolsite.com)

**Community Resources:**
- [Article/Tutorial Title](https://site.com/article)

</resources>
```

**Category definitions:**

1. **Official Documentation** - Rails Guides, Rails API docs, Ruby docs
2. **Gems & Libraries** - Third-party gems referenced in the skill (GitHub or RubyGems links)
3. **Tools & Testing** - Development tools, browser extensions, testing services
4. **Community Resources** - Blog posts, tutorials, external guides (use sparingly)

**Ordering:** Most important/foundational first within each category

**Note:** Not every skill needs all categories - only include what's relevant.

## Skill-by-Skill Plan

### Skills Needing New Resources (2)

**1. debugging/SKILL.md**
- Add Official Documentation:
  - [Rails Guides - Debugging Rails Applications](https://guides.rubyonrails.org/debugging_rails_applications.html)
  - [Rails API - ActiveSupport::Logger](https://api.rubyonrails.org/classes/ActiveSupport/Logger.html)
- Add Gems & Libraries:
  - [byebug](https://github.com/deivid-rodriguez/byebug)
- Add Tools:
  - Rails console guide

**2. using-rails-ai/SKILL.md**
- Add Official Documentation:
  - [Rails-AI GitHub](https://github.com/zerobearing2/rails-ai)
  - [Superpowers](https://github.com/zerobearing2/superpowers) (dependency)
- Add Internal References:
  - TEAM_RULES.md (internal reference)

### Skills With Existing Resources to Audit (10)

**3. configuration/SKILL.md**
- Verify: Rails credentials, environment config, initializers docs
- Check: Docker, Kamal, RuboCop gem links

**4. controllers/SKILL.md**
- Verify: Rails routing guide, Action Controller guide
- Check: Strong parameters, concerns, nested resources

**5. hotwire/SKILL.md**
- Verify: Turbo handbook, Stimulus handbook
- Check: hotwired.dev official site
- Note: Ensure Turbo Morph (Rails 8) is mentioned

**6. jobs/SKILL.md**
- Verify: SolidQueue documentation (Rails 8+)
- Check: Active Job guide
- Note: Ensure no Sidekiq/Redis references

**7. mailers/SKILL.md** ✅
- Already has good resources (verified)
- Rails Guides, letter_opener, SendGrid
- No changes needed unless links are broken

**8. models/SKILL.md**
- Verify: Active Record guide, associations, validations, callbacks
- Check: Query interface, migrations guides

**9. security/SKILL.md**
- Verify: Rails Security Guide
- Check: OWASP Top 10 reference
- Add: Secure coding best practices

**10. styling/SKILL.md**
- Verify: Tailwind CSS documentation
- Check: DaisyUI documentation
- Note: Ensure links to latest versions

**11. testing/SKILL.md**
- Verify: Rails Testing Guide
- Check: Minitest documentation, fixtures guide
- Add: WebMock gem reference

**12. views/SKILL.md**
- Verify: Action View guide, form helpers
- Check: WCAG 2.1 AA accessibility guidelines
- Add: Partials, layouts, helpers documentation

## Implementation Process

### Step 1: Automated URL Validation

```bash
# Extract all URLs from skills
grep -rh "https://" skills/*/SKILL.md | grep -o 'https://[^)]*' > urls.txt

# Test each URL (simple HTTP HEAD request)
while read url; do
  if curl -I -s -f "$url" > /dev/null; then
    echo "✅ $url"
  else
    echo "❌ $url"
  fi
done < urls.txt
```

Flag any 404s or redirects for manual review.

### Step 2: Manual Audit (Skill-by-Skill)

For each of the 12 skills:
1. Review existing resources (if any) for relevance
2. Check if links point to current/stable documentation
3. Identify missing foundational resources
4. Add/update/remove as needed
5. Organize into topic groups (Official Docs → Gems → Tools → Community)

### Step 3: Quality Checks

- Ensure every skill has at least 2-3 official Rails documentation links
- Verify gem links go to GitHub (preferred) or RubyGems
- Remove outdated/dead links
- Prefer official sources over blog posts
- Check for consistency in formatting

### Step 4: Testing

```bash
# Run CI to check markdown linting
bin/ci

# Verify YAML frontmatter still valid
bundle exec rake lint:yaml

# Spot-check a few URLs manually
curl -I https://guides.rubyonrails.org/...
```

### Step 5: Commit

Single commit with comprehensive summary:

```
Audit and update documentation resources across all skills

**Added:**
- debugging: Rails debugging guide, byebug gem
- using-rails-ai: GitHub repo, Superpowers dependency

**Updated:**
- Organized all resources into topic groups
- Verified all URLs are current and active
- Removed 3 broken links
- Added 8 missing official Rails Guides references

**Fixed:**
- controllers: Updated routing guide link
- jobs: Added SolidQueue documentation
- testing: Added WebMock gem reference

All 12 skills now have comprehensive, well-organized documentation.
```

## Deliverable

All 12 skills with:
- ✅ `<resources>` section present
- ✅ Resources organized by topic (Official Docs, Gems, Tools, Community)
- ✅ All URLs verified as active
- ✅ Comprehensive coverage of official Rails documentation
- ✅ Version-agnostic links with Rails 8+ callouts where relevant

## Benefits

1. **Easier learning** - Developers can quickly find official documentation
2. **Up-to-date references** - All links verified and current
3. **Consistent structure** - Same organization pattern across all skills
4. **Quality resources** - Prioritizes official docs over blog posts
5. **Maintainability** - Clear structure makes future updates easier

## Testing Checklist

- [ ] All 12 skills have `<resources>` section
- [ ] Resources organized into topic groups
- [ ] All URLs return 200 OK
- [ ] Markdown linting passes (`bin/ci`)
- [ ] YAML frontmatter valid
- [ ] At least 2-3 official Rails docs per skill
- [ ] Gem links point to GitHub or RubyGems
- [ ] No broken or outdated links
