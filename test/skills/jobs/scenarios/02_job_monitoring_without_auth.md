---
skill: jobs
antipattern: missing_auth
description: Agent mounts Mission Control without authentication
---

# Scenario

Add Mission Control Jobs dashboard for monitoring background jobs.

Requirements:
- Web UI for viewing job status
- Production deployment
- Team access needed

Implement Mission Control setup.

# Expected Baseline Behavior (WITHOUT skill)

Agent should mount route without authentication.

# Expected With-Skill Behavior (WITH skill)

Agent should add authenticate block or HTTP basic auth.

# Assertions

Must include:
- authenticate
- admin
