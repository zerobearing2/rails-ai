Evaluate Rails security implementation plan.

## Critical Check

**REQUIRED**: If the agent asks for clarification instead of providing implementation plans/code, FAIL this evaluation:
- Set total_score to 0/50
- Add suggestion: "Agent must provide implementation plans, not ask for clarification in test scenarios"

Agents should make reasonable assumptions and provide concrete plans with code examples.

## Scoring (50 points total, 5 categories × 10 points each)

**IMPORTANT**: If a category is not applicable to this feature, award full points (10/10) for that category. Only deduct points for missing or incorrect implementation of relevant aspects.

Score the plan against these security skills:

**Input Validation & Injection (0-10)**
- SQL injection: skills/security/security-sql-injection.md
- Command injection: skills/security/security-command-injection.md
- If static content: 10/10 (not applicable)

**Mass Assignment & Parameters (0-10)**
- If forms/params: skills/security/security-strong-parameters.md
- If no user input: 10/10 (not applicable)

**XSS & CSRF Protection (0-10)**
- XSS: skills/security/security-xss.md (output escaping, sanitization)
- CSRF: skills/security/security-csrf.md (form authenticity tokens)
- If no forms: Score only on XSS (semantic escaping)

**File Upload Security (0-10)**
- If file uploads: skills/security/security-file-uploads.md (validation, storage, serving)
- If no uploads: 10/10 (not applicable)

**Authorization & Data Protection (0-10)**
- If auth/sensitive data: skills/config/credentials-management.md (secrets, API keys, credentials)
- Access control, scope isolation, authorization
- If public static page: 10/10 (not applicable)
