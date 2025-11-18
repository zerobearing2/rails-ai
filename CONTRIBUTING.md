# Contributing

Thanks for contributing to rails-ai!

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/rails-ai.git
cd rails-ai
bin/setup
bin/ci
```

## Pull Requests

1. Fork and create branch from `master`
2. Write tests (Minitest)
3. Run `bin/ci` - must pass
4. Submit as draft PR

See [Code of Conduct](CODE_OF_CONDUCT.md).

## Development

### Testing

```bash
rake test:unit              # All unit tests
rake test:unit:skills       # Skills only
rake test:unit:agents       # Agents only
bin/ci                      # Full check
```

See [TESTING.md](TESTING.md) for details.

### Adding Skills

1. Create `skills/domain/skill-name.md` with YAML front matter
2. Add unit tests in `test/unit/skills/`
3. Document in `skills/using-rails-ai/SKILL.md`
4. Run `bin/ci`

### Adding Rules

1. Add to `rules/TEAM_RULES.md`
2. Update quick lookup index
3. Add tests in `test/unit/rules/`
4. Run `bin/ci`

## Conventions

- TDD always (RED-GREEN-REFACTOR)
- Minitest, not RSpec
- REST-only, no custom routes
- Solid Stack (SolidQueue, SolidCache, SolidCable)
- Follow `rules/TEAM_RULES.md`
- Run `rake lint:fix` before committing

## Getting Help

- [README](README.md) - basics
- [TESTING.md](TESTING.md) - development guide
- `skills/using-rails-ai/SKILL.md` - architecture
- [GitHub Issues](https://github.com/zerobearing2/rails-ai/issues) - questions

## Recognition

Contributors recognized in release notes. Thank you!
