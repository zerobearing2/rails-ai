---
name: security-sql-injection
domain: security
dependencies: []
version: 1.0
rails_version: 8.1+
criticality: CRITICAL
---

# SQL Injection Prevention

Prevent SQL injection attacks by using parameterized queries, never interpolating user input into SQL strings.

<when-to-use>
- Writing ANY database query with user input
- Building dynamic WHERE clauses
- Search functionality with user-provided terms
- Filtering, sorting, or pagination with user parameters
- ALWAYS - SQL injection prevention is ALWAYS required
</when-to-use>

<attack-vectors>
- **Authentication Bypass** - `' OR '1'='1`
- **Data Theft** - `' UNION SELECT * FROM users --`
- **Data Modification** - `'; UPDATE users SET admin=true --`
- **Data Deletion** - `'; DROP TABLE users --`
- **Privilege Escalation** - Accessing unauthorized records
</attack-vectors>

<standards>
- NEVER use string interpolation in SQL queries
- Use hash conditions for simple queries: `where(name: value)`
- Use positional placeholders for complex queries: `where("name = ?", value)`
- Use named placeholders for readability: `where("name = :name", name: value)`
- Use `sanitize_sql_like` for LIKE queries with wildcards
- Rely on ActiveRecord query methods (automatic protection)
- Validate and sanitize user input before queries
- Use strong parameters to control input
</standards>

## Vulnerable Patterns

<pattern name="string-interpolation-danger">
<description>NEVER interpolate user input into SQL strings</description>

**CRITICAL VULNERABILITIES:**
```ruby
# ❌ CRITICAL - Authentication bypass
Project.where("name = '#{params[:name]}'")
# Attack: params[:name] = "' OR '1'='1"
# Result: SELECT * FROM projects WHERE (name = '' OR '1'='1')
# Impact: Returns ALL projects

# ❌ CRITICAL - Authentication bypass
User.find_by("login = '#{params[:login]}' AND password = '#{params[:password]}'")
# Attack: params[:login] = "admin'--"
# Result: SELECT * FROM users WHERE (login = 'admin'--' AND password = '...')
# Impact: Password check is commented out, grants admin access

# ❌ CRITICAL - Data theft via UNION
Project.where("id = #{params[:id]}")
# Attack: params[:id] = "1 UNION SELECT id,email,password,1,1 FROM users"
# Impact: Exposes user credentials

# ❌ CRITICAL - Data deletion
Article.where("title = '#{params[:title]}'")
# Attack: params[:title] = "'; DROP TABLE articles; --"
# Impact: Deletes entire articles table
```

**Why This Happens:**
User input is directly inserted into SQL, allowing attackers to inject malicious SQL commands.
</pattern>

## Secure Patterns

<pattern name="hash-conditions">
<description>Use hash conditions for simple equality checks (RECOMMENDED)</description>

**Simple Equality:**
```ruby
# ✅ SECURE - ActiveRecord escapes automatically
Project.where(name: params[:name])
User.find_by(login: params[:login])
Feedback.where(status: params[:status])
```

**Multiple Conditions:**
```ruby
# ✅ SECURE
Project.where(
  name: params[:name],
  status: params[:status],
  user_id: current_user.id
)
```

**IN Queries:**
```ruby
# ✅ SECURE
Project.where(id: params[:ids])  # Works with arrays
# Generates: WHERE id IN (1, 2, 3)
```

**Why Secure:**
ActiveRecord automatically escapes values and prevents injection.
</pattern>

<pattern name="positional-placeholders">
<description>Use ? placeholders for complex queries</description>

**Single Placeholder:**
```ruby
# ✅ SECURE
Project.where("name = ?", params[:name])
Project.where("created_at > ?", 1.week.ago)
```

**Multiple Placeholders:**
```ruby
# ✅ SECURE - Order matches parameters
User.where(
  "login = ? AND status = ? AND created_at > ?",
  params[:login],
  "active",
  1.month.ago
)
```

**Complex Conditions:**
```ruby
# ✅ SECURE
Feedback.where(
  "status = ? AND (priority = ? OR created_at < ?)",
  params[:status],
  "high",
  1.day.ago
)
```

**Array Syntax:**
```ruby
# ✅ SECURE - Alternative syntax
User.find_by(["login = ? AND password_digest = ?", params[:login], hashed_password])
```

**Why Secure:**
Rails escapes each parameter value, preventing injection.
</pattern>

<pattern name="named-placeholders">
<description>Use :named placeholders for readability</description>

**Named Parameters:**
```ruby
# ✅ SECURE - More readable for complex queries
Project.where(
  "zip_code = :zip AND quantity >= :qty AND status = :status",
  zip: params[:zip],
  qty: params[:quantity],
  status: "active"
)
```

**With Hash:**
```ruby
# ✅ SECURE
conditions = {
  name: params[:name],
  email: params[:email],
  status: "active"
}
User.where("name = :name AND email = :email AND status = :status", conditions)
```

**Why Secure:**
Named placeholders are escaped just like positional ones, but more readable.
</pattern>

<pattern name="like-queries-safe">
<description>Safely handle LIKE queries with wildcards</description>

**LIKE with Sanitization:**
```ruby
# ✅ SECURE - Escape special LIKE characters
search_term = Book.sanitize_sql_like(params[:title])
Book.where("title LIKE ?", "#{search_term}%")

# sanitize_sql_like escapes:
# % -> \%
# _ -> \_
# Then you add your intended wildcards
```

**Case-Insensitive Search:**
```ruby
# ✅ SECURE
search_term = Book.sanitize_sql_like(params[:query])
Book.where("LOWER(title) LIKE LOWER(?)", "%#{search_term}%")
```

**Multiple Columns:**
```ruby
# ✅ SECURE
search = Book.sanitize_sql_like(params[:search])
Book.where(
  "title LIKE ? OR author LIKE ?",
  "%#{search}%",
  "%#{search}%"
)
```

**Why Sanitize:**
Without `sanitize_sql_like`, users could inject `%` or `_` wildcards and see unintended results.
</pattern>

<pattern name="activerecord-query-methods">
<description>Use ActiveRecord query methods (automatic protection)</description>

**Safe Query Methods:**
```ruby
# ✅ SECURE - All ActiveRecord methods are safe
Project.find(params[:id])
Project.find_by(name: params[:name])
Project.where(status: params[:status])
Project.order(:created_at)
Project.limit(10)
Project.offset(params[:page].to_i * 10)
Project.select(:id, :name)
Project.joins(:user)
Project.includes(:comments)
Project.group(:category)
Project.having("COUNT(*) > ?", 5)
```

**Scopes:**
```ruby
# app/models/project.rb
class Project < ApplicationRecord
  scope :active, -> { where(status: "active") }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :search, ->(term) {
    sanitized = sanitize_sql_like(term)
    where("name LIKE ?", "%#{sanitized}%")
  }
end

# ✅ SECURE - Scopes use safe methods
Project.active.by_user(params[:user_id]).search(params[:query])
```

**Why Secure:**
ActiveRecord methods automatically escape parameters.
</pattern>

<antipatterns>
<antipattern>
<description>Using string interpolation in queries</description>
<reason>CRITICAL - Allows arbitrary SQL injection</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY
def search
  @projects = Project.where("name LIKE '%#{params[:query]}%'")
end

# Attack: params[:query] = "%'; DROP TABLE projects; --"
# Result: Deletes entire projects table
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use placeholders
def search
  query = Project.sanitize_sql_like(params[:query])
  @projects = Project.where("name LIKE ?", "%#{query}%")
end
```
</good-example>
</antipattern>

<antipattern>
<description>Building ORDER BY clauses from user input</description>
<reason>Allows column enumeration and injection</reason>
<bad-example>
```ruby
# ❌ VULNERABLE - User controls ORDER BY
Project.order("#{params[:sort]} #{params[:direction]}")

# Attack: params[:sort] = "name); DROP TABLE projects; --"
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Allowlist approach
def safe_order
  sort_column = params[:sort].to_s
  direction = params[:direction].to_s.upcase

  # Allowlist columns
  allowed_columns = %w[name created_at status]
  column = allowed_columns.include?(sort_column) ? sort_column : "created_at"

  # Allowlist direction
  dir = %w[ASC DESC].include?(direction) ? direction : "DESC"

  Project.order("#{column} #{dir}")
end
```
</good-example>
</antipattern>

<antipattern>
<description>Not sanitizing LIKE wildcards</description>
<reason>Allows unintended wildcard matching</reason>
<bad-example>
```ruby
# ❌ VULNERABLE - User can inject wildcards
Book.where("title LIKE ?", "%#{params[:title]}%")

# Attack: params[:title] = "%"
# Result: Returns ALL books
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Escape wildcards first
search = Book.sanitize_sql_like(params[:title])
Book.where("title LIKE ?", "%#{search}%")
```
</good-example>
</antipattern>

<antipattern>
<description>Using find_by_sql with interpolation</description>
<reason>Raw SQL bypass of ActiveRecord protections</reason>
<bad-example>
```ruby
# ❌ CRITICAL VULNERABILITY
sql = "SELECT * FROM users WHERE login = '#{params[:login]}'"
User.find_by_sql(sql)
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use placeholders even in raw SQL
sql = ["SELECT * FROM users WHERE login = ?", params[:login]]
User.find_by_sql(sql)

# ✅ BETTER - Use ActiveRecord methods
User.where(login: params[:login])
```
</good-example>
</antipattern>
</antipatterns>

<testing>
Test SQL injection prevention:

```ruby
# test/models/project_test.rb
class ProjectTest < ActiveSupport::TestCase
  test "search handles malicious input safely" do
    # Create test project
    project = projects(:one)

    # Attempt SQL injection
    malicious_input = "'; DROP TABLE projects; --"

    # Should not raise error or delete data
    assert_nothing_raised do
      Project.search(malicious_input)
    end

    # Project should still exist
    assert Project.exists?(project.id)
  end

  test "search escapes LIKE wildcards" do
    project = projects(:one)
    project.update!(name: "Project A")

    # User tries to search for all projects with %
    results = Project.search("%")

    # Should not return results (% is escaped)
    assert_empty results
  end
end

# test/controllers/projects_controller_test.rb
class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "index with malicious sort parameter is safe" do
    # Attempt SQL injection via sort
    get projects_path, params: { sort: "name); DROP TABLE projects; --" }

    assert_response :success
    # Projects table should still exist
    assert Project.count > 0
  end
end
```
</testing>

<related-skills>
- strong-parameters - Filter allowed parameters
- activerecord-queries - Safe query patterns
- security-xss - Output escaping
- input-validation - Validate user input
</related-skills>

<resources>
- [Rails Security Guide - SQL Injection](https://guides.rubyonrails.org/security.html#sql-injection)
- [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [Rails Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
</resources>
