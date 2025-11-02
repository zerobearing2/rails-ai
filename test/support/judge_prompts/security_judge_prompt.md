Evaluate Rails security implementation plan.

## Scoring (50 points total, 5 categories × 10 points each)

Score the plan against these security skills:

**Input Validation & Injection (0-10)**
- skills/security/security-sql-injection.md
- skills/security/security-command-injection.md
- Parameterized queries, input validation
- No dangerous methods (eval, send with user input)

**Mass Assignment & Parameters (0-10)**
- skills/security/security-strong-parameters.md
- Strong parameters, only necessary fields
- No sensitive fields in permitted params

**XSS & CSRF Protection (0-10)**
- skills/security/security-xss.md
- skills/security/security-csrf.md
- Output escaping, CSRF tokens
- Secure defaults, Rails protections

**File Upload Security (0-10)**
- skills/security/security-file-uploads.md
- File type validation, size limits
- Secure storage, virus scanning

**Authorization & Data Protection (0-10)**
- Access control, authorization checks
- Scope isolation (users see only their data)
- No plain-text passwords, encryption
- Rails credentials, environment variables
- Session/cookie security
