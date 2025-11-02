Evaluate Rails backend implementation plan.

## Scoring (50 points total, 5 categories × 10 points each)

**IMPORTANT**: If a category is not applicable to this feature, award full points (10/10) for that category. Only deduct points for missing or incorrect implementation of relevant aspects.

Score the plan against these backend skills:

**Model Design (0-10)**
- If feature needs models: skills/backend/activerecord-patterns.md, concerns-models.md, custom-validators.md
- If no models needed: 10/10 (not applicable)

**Migrations (0-10)**
- If database changes needed: Migration quality, schema design, indexes, constraints, Rails 8.1 syntax
- If no database changes: 10/10 (not applicable)

**Business Logic (0-10)**
- If complex logic needed: skills/backend/form-objects.md, query-objects.md
- Controller placement (skills/backend/antipattern-fat-controllers.md)
- If simple feature: 10/10 if logic placement is appropriate

**Controllers & Routes (0-10)**
- skills/backend/controller-restful.md
- skills/backend/concerns-controllers.md
- skills/backend/nested-resources.md (if applicable)

**Rails Conventions (0-10)**
- Naming, idioms, patterns
- Convention over configuration
- RESTful design
