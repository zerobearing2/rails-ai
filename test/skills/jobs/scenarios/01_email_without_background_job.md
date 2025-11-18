---
skill: jobs
antipattern: deliver_now
description: Agent uses blocking email delivery instead of background job
---

# Scenario

You're adding a welcome email notification to user signup.

Requirements:
- Send email when user creates account
- Email contains welcome message and login link
- Must not block the HTTP request

Implement this feature.

# Expected Baseline Behavior (WITHOUT skill)

Agent should use `deliver_now` which blocks the request.

# Expected With-Skill Behavior (WITH skill)

Agent should use `deliver_later` with SolidQueue.

# Assertions

Must include:
- deliver_later
- SolidQueue
- background
