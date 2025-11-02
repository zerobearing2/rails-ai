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
</when-to-use>

<attack-vectors>
- **Authentication Bypass** - `' OR '1'='1`
- **Data Theft** - `' UNION SELECT * FROM users --`
- **Data Modification** - `'; UPDATE users SET admin=true --`
- **Data Deletion** - `'; DROP TABLE users --`
</attack-vectors>

<standards>
- NEVER use string interpolation in SQL queries
- Use hash conditions for simple queries: `where(name: value)`
- Use positional placeholders: `where("name = ?", value)`
- Use named placeholders: `where("name = :name", name: value)`
- Use `sanitize_sql_like` for LIKE queries
- Rely on ActiveRecord query methods (automatic protection)
- Validate and sanitize user input before queries
</standards>

## Vulnerable Patterns

<pattern name="string-interpolation-danger">
<description>NEVER interpolate user input into SQL strings</description>

**CRITICAL VULNERABILITIES:**
```ruby
# ❌ CRITICAL - Authentication bypass
Project.where("name = '#{params[:name]}'")
# Attack: params[:name] = "' OR '1'='1"
# Result: WHERE (name = '' OR '1'='1') - Returns ALL projects

# ❌ CRITICAL - Authentication bypass
User.find_by("login = '#{params[:login]}' AND password = '#{params[:password]}'")
# Attack: params[:login] = "admin'--"
# Result: Password check is commented out, grants admin access

# ❌ CRITICAL - Data theft via UNION
Project.where("id = #{params[:id]}")
# Attack: params[:id] = "1 UNION SELECT id,email,password,1,1 FROM users"
# Impact: Exposes user credentials

# ❌ CRITICAL - Data deletion
Article.where("title = '#{params[:title]}'")
# Attack: params[:title] = "'; DROP TABLE articles; --"
# Impact: Deletes entire table
```

**Why This Happens:**
User input is directly inserted into SQL, allowing attackers to inject malicious SQL commands.
</pattern>

## Secure Patterns

<pattern name="hash-conditions">
<description>Use hash conditions for simple equality checks (RECOMMENDED)</description>

```ruby
# ✅ SECURE - ActiveRecord escapes automatically
Project.where(name: params[:name])
User.find_by(login: params[:login])

# ✅ SECURE - Multiple conditions
Project.where(name: params[:name], status: params[:status], user_id: current_user.id)

# ✅ SECURE - IN queries (works with arrays)
Project.where(id: params[:ids])  # Generates: WHERE id IN (1, 2, 3)
```

**Why Secure:**
ActiveRecord automatically escapes values and prevents injection.
</pattern>

<pattern name="positional-placeholders">
<description>Use ? placeholders for complex queries</description>

```ruby
# ✅ SECURE - Single placeholder
Project.where("name = ?", params[:name])
Project.where("created_at > ?", 1.week.ago)

# ✅ SECURE - Multiple placeholders (order matches parameters)
User.where("login = ? AND status = ? AND created_at > ?", params[:login], "active", 1.month.ago)

# ✅ SECURE - Complex conditions
Feedback.where("status = ? AND (priority = ? OR created_at < ?)", params[:status], "high", 1.day.ago)

# ✅ SECURE - Array syntax
User.find_by(["login = ? AND password_digest = ?", params[:login], hashed_password])
```

**Why Secure:**
Rails escapes each parameter value, preventing injection.
</pattern>

<pattern name="named-placeholders">
<description>Use :named placeholders for readability</description>

```ruby
# ✅ SECURE - More readable for complex queries
Project.where(
  "zip_code = :zip AND quantity >= :qty AND status = :status",
  zip: params[:zip], qty: params[:quantity], status: "active"
)

# ✅ SECURE - With hash
conditions = { name: params[:name], email: params[:email], status: "active" }
User.where("name = :name AND email = :email AND status = :status", conditions)
```

**Why Secure:**
Named placeholders are escaped just like positional ones, but more readable.
</pattern>

<pattern name="like-queries-safe">
<description>Safely handle LIKE queries with wildcards</description>

```ruby
# ✅ SECURE - Escape special LIKE characters (% -> \%, _ -> \_)
search_term = Book.sanitize_sql_like(params[:title])
Book.where("title LIKE ?", "#{search_term}%")

# ✅ SECURE - Case-insensitive search
search_term = Book.sanitize_sql_like(params[:query])
Book.where("LOWER(title) LIKE LOWER(?)", "%#{search_term}%")

# ✅ SECURE - Multiple columns
search = Book.sanitize_sql_like(params[:search])
Book.where("title LIKE ? OR author LIKE ?", "%#{search}%", "%#{search}%")
```

**Why Sanitize:**
Without `sanitize_sql_like`, users could inject `%` or `_` wildcards and see unintended results.
</pattern>

<pattern name="activerecord-query-methods">
<description>Use ActiveRecord query methods (automatic protection)</description>

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

# ✅ SECURE - Scopes
class Project < ApplicationRecord
  scope :active, -> { where(status: "active") }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :search, ->(term) {
    sanitized = sanitize_sql_like(term)
    where("name LIKE ?", "%#{sanitized}%")
  }
end

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
@projects = Project.where("name LIKE '%#{params[:query]}%'")
# Attack: params[:query] = "%'; DROP TABLE projects; --"
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use placeholders
query = Project.sanitize_sql_like(params[:query])
@projects = Project.where("name LIKE ?", "%#{query}%")
```
</good-example>
</antipattern>

<antipattern>
<description>Building ORDER BY clauses from user input</description>
<reason>Allows column enumeration and injection</reason>
<bad-example>
```ruby
# ❌ VULNERABLE
Project.order("#{params[:sort]} #{params[:direction]}")
# Attack: params[:sort] = "name); DROP TABLE projects; --"
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Allowlist approach
allowed_columns = %w[name created_at status]
column = allowed_columns.include?(params[:sort]) ? params[:sort] : "created_at"
dir = %w[ASC DESC].include?(params[:direction]&.upcase) ? params[:direction] : "DESC"
Project.order("#{column} #{dir}")
```
</good-example>
</antipattern>

<antipattern>
<description>Using find_by_sql with interpolation</description>
<reason>Raw SQL bypass of ActiveRecord protections</reason>
<bad-example>
```ruby
# ❌ CRITICAL
User.find_by_sql("SELECT * FROM users WHERE login = '#{params[:login]}'")
```
</bad-example>
<good-example>
```ruby
# ✅ SECURE - Use placeholders
User.find_by_sql(["SELECT * FROM users WHERE login = ?", params[:login]])

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
    project = projects(:one)
    malicious_input = "'; DROP TABLE projects; --"

    assert_nothing_raised { Project.search(malicious_input) }
    assert Project.exists?(project.id)
  end

  test "search escapes LIKE wildcards" do
    projects(:one).update!(name: "Project A")
    results = Project.search("%")

    assert_empty results  # % should be escaped
  end
end

# test/controllers/projects_controller_test.rb
class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "index with malicious sort parameter is safe" do
    get projects_path, params: { sort: "name); DROP TABLE projects; --" }

    assert_response :success
    assert Project.count > 0
  end
end
```
</testing>

<related-skills>
- strong-parameters - Filter allowed parameters
- activerecord-patterns - Efficient ActiveRecord patterns
- security-xss - Output escaping
</related-skills>

<resources>
- [Rails Security Guide - SQL Injection](https://guides.rubyonrails.org/security.html#sql-injection)
- [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [Rails Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
</resources>
