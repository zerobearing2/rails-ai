Evaluate Rails security implementation plan.

## Scoring (50 points total, 5 categories × 10 points each)

**IMPORTANT**: If a category is not applicable to this feature, award full points (10/10) for that category. Only deduct points for missing or incorrect implementation of relevant aspects.

Score the plan against these security skills:

**Input Validation & Injection (0-10)**
- If user input: skills/security/security-sql-injection.md, security-command-injection.md
- If static content: 10/10 (not applicable)

**Mass Assignment & Parameters (0-10)**
- If forms/params: skills/security/security-strong-parameters.md
- If no user input: 10/10 (not applicable)

**XSS & CSRF Protection (0-10)**
- XSS: skills/security/security-xss.md (always check output escaping)
- CSRF: skills/security/security-csrf.md (if forms)
- If no forms: Score only on XSS protection

**File Upload Security (0-10)**
- If file uploads: skills/security/security-file-uploads.md
- If no uploads: 10/10 (not applicable)

**Authorization & Data Protection (0-10)**
- If user data/auth: Access control, scope isolation, credentials
- If public static page: 10/10 (not applicable)
