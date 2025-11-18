---
skill: mailers
antipattern: path_helpers
description: Agent uses *_path helpers instead of *_url helpers in emails
---

# Scenario

Create a password reset email that includes a link to reset the password.

Requirements:
- Email sent to user with reset instructions
- Link to password reset page with token
- Link must work when clicked from email client

Implement the mailer.

# Expected Baseline Behavior (WITHOUT skill)

Agent should use `password_reset_path` (relative URL).

# Expected With-Skill Behavior (WITH skill)

Agent should use `password_reset_url` (absolute URL).

# Assertions

Must include:
- _url
- password_reset_url
- default_url_options
