# SQL Injection Prevention Examples
# Reference: TEAM_RULES.md, Rails Security Guide
# Category: CRITICAL SECURITY

# ============================================================================
# ❌ VULNERABLE: String Interpolation (SQL Injection)
# ============================================================================

# NEVER do this - allows SQL injection
Project.where("name = '#{params[:name]}'")
# Attack: params[:name] = "' OR '1'='1"
# Result: SELECT * FROM projects WHERE (name = '' OR '1'='1')
# Impact: Returns ALL projects

User.find_by("login = '#{params[:name]}' AND password = '#{params[:password]}'")
# Attack: params[:name] = "' OR '1'='1", params[:password] = "' OR '2'>'1"
# Result: SELECT * FROM users WHERE login = '' OR '1'='1' AND password = '' OR '2'>'1' LIMIT 1
# Impact: Authentication bypass, grants access to first user

# UNION injection for data theft
Project.where("name = '#{params[:name]}'")
# Attack: params[:name] = "') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --"
# Result: SELECT * FROM projects WHERE (name = '') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --'
# Impact: Exposes user credentials

# ============================================================================
# ✅ SECURE: Positional Placeholders (Recommended)
# ============================================================================

# Use ? placeholders with values as arguments
Project.where("name = ?", params[:name])
# Rails automatically sanitizes params[:name]
# Safe from injection attacks

User.find_by(["login = ? AND password = ?", params[:name], params[:password]])
# Secure: Rails escapes special characters

# Complex queries with multiple conditions
Model.where("zip_code = ? AND quantity >= ?", entered_zip_code, entered_quantity).first

# LIKE queries with wildcard escaping
Book.where("title LIKE ?", Book.sanitize_sql_like(params[:title]) + "%")
# sanitize_sql_like escapes % and _ in user input
# Then adds your intended % wildcard

# ============================================================================
# ✅ SECURE: Named Placeholders
# ============================================================================

# Use :named placeholders with hash
values = { zip: entered_zip_code, qty: entered_quantity }
Model.where("zip_code = :zip AND quantity >= :qty", values).first
# More readable for complex queries

# ============================================================================
# ✅ SECURE: Hash Conditions (Recommended for Simple Queries)
# ============================================================================

# Automatically safe from SQL injection
Project.where(name: params[:name])
# Generated SQL: SELECT * FROM projects WHERE name = ? (with params[:name] escaped)

User.find_by(login: params[:name], password: params[:password])
# Secure and readable

# Chain multiple conditions
Model.where(zip_code: entered_zip_code).where("quantity >= ?", entered_quantity).first

# ============================================================================
# ✅ BEST PRACTICE: Combine Hash + Placeholders
# ============================================================================

# Use hash for simple equality, placeholders for complex conditions
Feedback.where(status: "pending")
        .where("created_at > ?", 30.days.ago)
        .where("recipient_email = ?", params[:email])

# ============================================================================
# RULE: NEVER use string interpolation in where/find_by
# ALWAYS use: Hash conditions, ? placeholders, or :named placeholders
# ============================================================================
