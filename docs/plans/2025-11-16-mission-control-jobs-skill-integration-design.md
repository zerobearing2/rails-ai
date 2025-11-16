# Mission Control Integration for Jobs Skill

**Date:** 2025-11-16
**Status:** Approved
**Context:** Add Mission Control - Jobs throughout the jobs skill, not just resources section

## Problem

Mission Control was added to the resources section but isn't integrated into the skill patterns. Developers need comprehensive guidance on setup, dashboard features, and when to use Mission Control vs other monitoring approaches.

## Solution

Integrate Mission Control into existing patterns and add new dedicated pattern for dashboard usage.

### 1. Update `solidqueue-basic-setup` Pattern

Add Mission Control setup as fourth subsection after Queue Configuration:

**Mission Control Setup (Web Dashboard):**
- Gem installation
- Route mounting with authentication (user admin check + HTTP basic auth example)
- Optional configuration (retention periods, parameter filtering)
- Why: Production-ready web UI with team access

### 2. Add Monitoring Approach Comparison

Insert comparison table after `job-monitoring` pattern (line 271):

| Approach | Best For | Access |
|----------|----------|--------|
| Mission Control | Production monitoring, team collaboration, visual investigation | Web UI at /jobs |
| Rails Console | Quick debugging, one-off queries, scripting | Terminal/SSH |
| Custom Endpoints | Programmatic monitoring, alerting systems, health checks | HTTP API |

### 3. Add New `mission-control-dashboard` Pattern

Insert after comparison table, focused on dashboard features:

**Content:**
- Accessing the dashboard (/jobs URL)
- Dashboard features overview:
  - Jobs overview (all queues, real-time status, performance metrics)
  - Job details (arguments, timeline, errors, retry history)
  - Common operations (retry, discard, pause/resume, filtering)
- Example workflows:
  - Investigating failed jobs (filter → inspect → fix → retry)
  - Monitoring queue health (queues tab → metrics → bottlenecks)
  - Bulk operations (select multiple → retry/discard)
- Why: Team accessibility, visual investigation faster than console

### 4. Resources Section

Already completed - Mission Control positioned after Solid Stack gems.

### 5. Testing

No changes - Mission Control is a monitoring tool, testing it doesn't add value to the skill.

## Implementation Checklist

- [ ] Update `solidqueue-basic-setup` pattern with Mission Control setup section
- [ ] Add monitoring approach comparison table after `job-monitoring` pattern
- [ ] Add new `mission-control-dashboard` pattern after comparison table
- [ ] Verify all markdown formatting and code blocks
- [ ] Run bin/ci to verify changes
- [ ] Commit changes

## Benefits

- **Complete coverage** - Setup, configuration, and usage all documented
- **Clear guidance** - Comparison table helps developers choose right tool
- **Practical workflows** - Real examples of investigating failures and monitoring health
- **Team-friendly** - Emphasizes Mission Control's accessibility advantage

## Alternatives Considered

1. **Replace existing monitoring** - Rejected, console and custom endpoints still valuable
2. **Minimal setup only** - Rejected, comprehensive setup with auth/config more useful
3. **Configuration-focused pattern** - Rejected, dashboard features more immediately useful
4. **Add testing** - Rejected, monitoring tool doesn't need UI tests in skill

## Related

- skills/jobs/SKILL.md - Target file for changes
- Mission Control - Jobs: https://github.com/rails/mission_control-jobs
