---
skill: jobs
antipattern: perform_now
description: Agent uses perform_now instead of perform_later for job execution
---

# Scenario

Create a data export job that generates a CSV file.

Requirements:
- Export user data to CSV
- Email CSV to requesting user
- Handle large datasets (10k+ rows)

Implement the export job.

# Expected Baseline Behavior (WITHOUT skill)

Agent should use `perform_now` which blocks execution.

# Expected With-Skill Behavior (WITH skill)

Agent should use `perform_later` for async execution.

# Assertions

Must include:
- perform_later
- ApplicationJob
- queue
