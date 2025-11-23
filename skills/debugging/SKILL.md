---
name: rails-ai:debugging
description: Use when debugging Rails issues - provides Rails-specific debugging tools (logs, console, byebug, SQL logging) and browser debugging with Playwright
---

# Rails Debugging Tools & Techniques

<when-to-use>
- Rails application behaving unexpectedly
- Tests failing with unclear errors
- Performance issues or N+1 queries
- Production errors need investigation
- JavaScript console errors or exceptions
- Visual/layout issues (CSS, responsiveness)
- Hotwire/Turbo/Stimulus behavior problems
- Form submission or interaction bugs
</when-to-use>

<verification-checklist>
Before completing debugging work:
- ✅ Root cause identified (not just symptoms)
- ✅ Regression test added (prevents recurrence)
- ✅ Fix verified in development and test environments
- ✅ All tests passing (bin/ci passes)
- ✅ Logs reviewed for related issues
- ✅ Performance impact verified (if applicable)
- ✅ JavaScript console errors checked (if UI issue)
- ✅ Screenshots reviewed for visual regressions (if UI issue)
</verification-checklist>

<phase1-root-cause-investigation>

<tool name="rails-logs">
<description>Check Rails logs for errors and request traces</description>

```bash
# Development logs
tail -f log/development.log

# Production logs (Kamal)
kamal app logs --tail

# Filter by severity
grep ERROR log/production.log

# Filter by request
grep "Started GET" log/development.log

```
</tool>

<tool name="rails-console">
<description>Interactive Rails console for testing models/queries</description>

```ruby
# Start console
rails console

# Or production console (Kamal)
kamal app exec 'bin/rails console'

# Test models
user = User.find(1)
user.valid?  # Check validations
user.errors.full_messages  # See errors

# Test queries
User.where(email: "test@example.com").to_sql  # See SQL
User.includes(:posts).where(posts: { published: true })  # Avoid N+1

```
</tool>

<tool name="byebug">
<description>Breakpoint debugger for stepping through code</description>

```ruby
# Add to any Rails file
def some_method
  byebug  # Execution stops here
  # ... rest of method
end

# Byebug commands:
# n  - next line
# s  - step into method
# c  - continue execution
# pp variable  - pretty print
# var local  - show local variables
# exit  - quit debugger

```
</tool>

<tool name="sql-logging">
<description>Enable verbose SQL logging to see queries</description>

```ruby
# In rails console or code
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Now all SQL queries print to console
User.all
# => SELECT "users".* FROM "users"

```
</tool>

</phase1-root-cause-investigation>

<phase-browser-debugging>

Use these tools for JavaScript errors, visual issues, and Hotwire/Turbo/Stimulus problems.
Requires Node.js. Artifacts saved to `tmp/playwright/<timestamp>/` for human review.

<subagent-delegation>
**IMPORTANT:** Browser debugging should be delegated to a subagent to preserve main context.

**Why:** Browser debugging is iterative and verbose. Running Playwright scripts, analyzing artifacts, and retrying consumes significant context. Delegate to keep the coordinator context clean.

**How to delegate:**

```
Use Task tool with prompt:

## Browser Debugging Task

### Issue
[Description of the browser/UI issue to investigate]

### URL
[The URL to debug, e.g., http://localhost:3000/users]

### Instructions
1. Use `npx playwright install chromium` if not already installed
2. Use browser-capture or browser-interact tools from rails-ai:debugging skill
3. Analyze artifacts (screenshot, console.log, page.html)
4. If issue not found, try additional interactions or different pages
5. Report findings

### Return Format
Report back with:
- **Summary:** Brief description of what you found (1-2 sentences)
- **Console Errors:** List any JavaScript errors (summarized)
- **Visual Issues:** Description of any visual problems observed
- **Artifact Paths:** Full paths to saved artifacts for human review
- **Suggested Fix:** If root cause identified, suggest the fix
```

**Example subagent response:**

```
## Browser Debugging Report

**Summary:** Login form submit button not responding due to missing Stimulus controller.

**Console Errors:**
- [ERROR] Error connecting controller: login (http://localhost:3000/login:45)

**Visual Issues:** None - page renders correctly but button click has no effect.

**Artifact Paths:**
- tmp/playwright/2025-11-23_143052/screenshot.png
- tmp/playwright/2025-11-23_143052/console.log
- tmp/playwright/2025-11-23_143052/page.html

**Suggested Fix:** Add `data-controller="login"` to form element or create missing LoginController in app/javascript/controllers/.
```

</subagent-delegation>

<tool name="browser-install">
<description>One-time setup: install Playwright and Chromium browser</description>

```bash
# Install Playwright and download Chromium
npx playwright install chromium
```

</tool>

<tool name="browser-capture">
<description>Capture screenshot, console logs, and HTML from a URL</description>

```bash
# Capture artifacts from a page
# Set URL (default: localhost:3000, adjust port if using foreman/overmind)
URL="${URL:-http://localhost:3000}/users"
SESSION="tmp/playwright/$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$SESSION"
node -e "
const { chromium } = require('playwright');
(async () => {
  let browser;
  const logs = [];
  try {
    browser = await chromium.launch();
    const page = await browser.newPage();
    page.on('console', msg => {
      const loc = msg.location();
      const location = loc.url ? ' (' + loc.url + ':' + loc.lineNumber + ')' : '';
      logs.push('[' + msg.type() + '] ' + msg.text() + location);
    });
    page.on('pageerror', err => logs.push('[ERROR] ' + err.message + '\n' + (err.stack || '')));
    await page.goto('$URL', { timeout: 30000, waitUntil: 'domcontentloaded' });
    await page.screenshot({ path: '$SESSION/screenshot.png', fullPage: true });
    require('fs').writeFileSync('$SESSION/console.log', logs.join('\n'));
    require('fs').writeFileSync('$SESSION/page.html', await page.content());
    console.log('Artifacts saved to: $SESSION/');
  } catch (error) {
    console.error('Browser capture failed:', error.message);
    require('fs').writeFileSync('$SESSION/error.log', error.stack || error.message);
    if (logs.length) require('fs').writeFileSync('$SESSION/console.log', logs.join('\n'));
    process.exit(1);
  } finally {
    if (browser) await browser.close();
  }
})();
"

# Review artifacts
ls -la "$SESSION"
cat "$SESSION/console.log"
```

</tool>

<tool name="browser-interact">
<description>Capture with interactions: fill forms, click buttons, wait for elements</description>

```bash
# Example: Debug login flow
# Set BASE_URL (default: localhost:3000, adjust port if using foreman/overmind)
BASE_URL="${BASE_URL:-http://localhost:3000}"
SESSION="tmp/playwright/$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$SESSION"
node -e "
const { chromium } = require('playwright');
(async () => {
  let browser;
  const logs = [];
  try {
    browser = await chromium.launch();
    const page = await browser.newPage();
    page.on('console', msg => {
      const loc = msg.location();
      const location = loc.url ? ' (' + loc.url + ':' + loc.lineNumber + ')' : '';
      logs.push('[' + msg.type() + '] ' + msg.text() + location);
    });
    page.on('pageerror', err => logs.push('[ERROR] ' + err.message + '\n' + (err.stack || '')));

    // Navigate to login page
    await page.goto('$BASE_URL/login', { timeout: 30000, waitUntil: 'domcontentloaded' });

    // Fill form
    await page.fill('input[name=\"email\"]', 'test@example.com');
    await page.fill('input[name=\"password\"]', 'password');

    // Screenshot before submit
    await page.screenshot({ path: '$SESSION/before_submit.png', fullPage: true });

    // Submit and wait for navigation
    await page.click('button[type=\"submit\"]');
    await page.waitForLoadState('networkidle');

    // Capture final state
    await page.screenshot({ path: '$SESSION/screenshot.png', fullPage: true });
    require('fs').writeFileSync('$SESSION/console.log', logs.join('\n'));
    require('fs').writeFileSync('$SESSION/page.html', await page.content());
    console.log('Artifacts saved to: $SESSION/');
  } catch (error) {
    console.error('Browser interaction failed:', error.message);
    require('fs').writeFileSync('$SESSION/error.log', error.stack || error.message);
    if (logs.length) require('fs').writeFileSync('$SESSION/console.log', logs.join('\n'));
    process.exit(1);
  } finally {
    if (browser) await browser.close();
  }
})();
"
```

**Common Playwright interactions:**

```javascript
// Click elements
await page.click('button.submit');
await page.click('a[href="/dashboard"]');

// Fill inputs
await page.fill('input[name="email"]', 'user@example.com');
await page.fill('textarea#comment', 'My comment');

// Select dropdowns
await page.selectOption('select#country', 'US');

// Wait for elements
await page.waitForSelector('.flash-message');
await page.waitForURL('**/dashboard');
await page.waitForLoadState('networkidle');

// Check visibility
const visible = await page.isVisible('.error-message');

// Get text content
const text = await page.textContent('.alert');
```

</tool>

<tool name="browser-trace">
<description>Capture detailed trace with timeline, DOM snapshots, and network requests. Best for debugging Hotwire/Turbo issues where event sequence matters.</description>

```bash
# Capture trace for detailed debugging (especially useful for Hotwire/Turbo)
BASE_URL="${BASE_URL:-http://localhost:3000}"
SESSION="tmp/playwright/$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$SESSION"
node -e "
const { chromium } = require('playwright');
(async () => {
  let browser;
  const logs = [];
  try {
    browser = await chromium.launch();
    const context = await browser.newContext();

    // Start tracing with screenshots, DOM snapshots, and source files
    await context.tracing.start({ screenshots: true, snapshots: true, sources: true });

    const page = await context.newPage();
    page.on('console', msg => {
      const loc = msg.location();
      const location = loc.url ? ' (' + loc.url + ':' + loc.lineNumber + ')' : '';
      logs.push('[' + msg.type() + '] ' + msg.text() + location);
    });
    page.on('pageerror', err => logs.push('[ERROR] ' + err.message + '\n' + (err.stack || '')));

    // Navigate and perform interactions
    await page.goto('$BASE_URL/users', { timeout: 30000, waitUntil: 'domcontentloaded' });

    // Add your interactions here (clicks, form fills, etc.)

    // Stop and save trace
    await context.tracing.stop({ path: '$SESSION/trace.zip' });

    await page.screenshot({ path: '$SESSION/screenshot.png', fullPage: true });
    require('fs').writeFileSync('$SESSION/console.log', logs.join('\n'));
    require('fs').writeFileSync('$SESSION/page.html', await page.content());

    console.log('Artifacts saved to: $SESSION/');
    console.log('View trace: npx playwright show-trace $SESSION/trace.zip');
  } catch (error) {
    console.error('Trace capture failed:', error.message);
    require('fs').writeFileSync('$SESSION/error.log', error.stack || error.message);
    if (logs.length) require('fs').writeFileSync('$SESSION/console.log', logs.join('\n'));
    process.exit(1);
  } finally {
    if (browser) await browser.close();
  }
})();
"

# View trace in Playwright Trace Viewer (opens browser UI)
npx playwright show-trace "$SESSION/trace.zip"
```

**Trace includes:**
- Timeline of all actions
- DOM snapshots before/after each action
- Network requests and responses
- Console logs with timestamps
- Screenshots at each step

</tool>

<workflow name="system-test-debugging">
<description>Debug failing system/integration tests</description>

1. Identify the failing test and URL being tested
2. Run `browser-capture` against that URL
3. Check `console.log` for JavaScript errors
4. Review `screenshot.png` for visual issues
5. Inspect `page.html` for missing/incorrect DOM elements
6. Fix the issue and re-run test

</workflow>

<workflow name="ad-hoc-debugging">
<description>Debug browser issues reported by users or discovered during development</description>

1. Get the URL where issue occurs
2. Use `browser-capture` for simple inspection
3. Use `browser-interact` if issue requires form submission or navigation
4. Analyze console errors and screenshots
5. Fix and verify with another capture

</workflow>

</phase-browser-debugging>

<phase2-pattern-analysis>

<tool name="rails-routes">
<description>Check route definitions and paths</description>

```bash
# List all routes
rails routes

# Filter routes
rails routes | grep users

# Show routes for controller
rails routes -c users

```
</tool>

<tool name="rails-db-status">
<description>Check migration status and schema</description>

```bash
# Migration status
rails db:migrate:status

# Show schema version
rails db:version

# Check pending migrations
rails db:abort_if_pending_migrations

```
</tool>

</phase2-pattern-analysis>

<phase3-hypothesis-testing>

<tool name="rails-runner">
<description>Run Ruby code in Rails environment</description>

```bash
# Run one-liner
rails runner "puts User.count"

# Run script
rails runner scripts/investigate_users.rb

# Production environment
RAILS_ENV=production rails runner "User.pluck(:email)"

```
</tool>

</phase3-hypothesis-testing>

<phase4-implementation>

<tool name="rails-test-verbose">
<description>Run tests with detailed output</description>

```bash
# Run single test with backtrace
rails test test/models/user_test.rb --verbose

# Run with warnings enabled
RUBYOPT=-W rails test

# Run with seed for reproducibility
rails test --seed 12345

```
</tool>

</phase4-implementation>

<common-issues>

<issue name="n-plus-one-queries">
<detection>
Check logs for many similar queries:

```

User Load (0.1ms)  SELECT * FROM users WHERE id = 1
Post Load (0.1ms)  SELECT * FROM posts WHERE user_id = 1
Post Load (0.1ms)  SELECT * FROM posts WHERE user_id = 2
Post Load (0.1ms)  SELECT * FROM posts WHERE user_id = 3

```
</detection>
<solution>
Use includes/preload:

```ruby
# Bad
users.each { |user| user.posts.count }

# Good
users.includes(:posts).each { |user| user.posts.count }

```
</solution>
</issue>

<issue name="missing-migration">
<detection>
Error: "ActiveRecord::StatementInvalid: no such column"
</detection>
<solution>

```bash
# Check migration status
rails db:migrate:status

# Run pending migrations
rails db:migrate

# Or rollback and retry
rails db:rollback
rails db:migrate

```
</solution>
</issue>

</common-issues>

<related-skills>
- rails-ai:models (Query optimization, N+1 debugging)
- rails-ai:controllers (Request debugging, parameter inspection)
- rails-ai:testing (Test debugging, failure investigation)
- rails-ai:hotwire (Turbo/Stimulus debugging, JavaScript behavior)
</related-skills>

<resources>

**Official Documentation:**
- [Rails Guides - Debugging Rails Applications](https://guides.rubyonrails.org/debugging_rails_applications.html)
- [Rails API - ActiveSupport::Logger](https://api.rubyonrails.org/classes/ActiveSupport/Logger.html)
- [Ruby Debugging Guide](https://ruby-doc.org/stdlib-3.0.0/libdoc/debug/rdoc/index.html)
- [Playwright Documentation](https://playwright.dev/docs/intro)
- [Playwright CLI Reference](https://playwright.dev/docs/test-cli)

**Gems & Libraries:**
- [byebug](https://github.com/deivid-rodriguez/byebug) - Ruby debugger
- [bullet](https://github.com/flyerhzm/bullet) - N+1 query detection

**Tools:**
- [Rack Mini Profiler](https://github.com/MiniProfiler/rack-mini-profiler) - Performance profiling
- [Playwright](https://playwright.dev/) - Browser automation for debugging

</resources>
