# GitHub Actions CI/CD Setup

This project uses GitHub Actions for continuous integration and deployment.

## Workflows

### CI Workflow (`.github/workflows/ci.yml`)

Automatically runs quality checks and tests on every PR and push to main.

#### When it Runs

**Lint & Unit Tests** (fast, ~10 seconds):
- ✅ On every push to `master` branch
- ✅ On every pull request (when opened, updated, or marked ready)
- ✅ Manually via workflow_dispatch
- ❌ Skipped on draft PRs (to save CI time)

**Integration Tests:**
- ❌ **Not part of GitHub Actions workflow** (due to LLM API costs)
- ✅ Run locally via `rake test:integration:scenario[name]`
- 💡 May be added to CI later if cost-effective solution is found

#### What it Checks

**Lint & Unit Tests Job:**
1. Ruby code style (Rubocop)
2. Markdown formatting (mdl - informational)
3. YAML validation
4. Unit tests (< 1 second, ~50 test files)

**Note:** Integration tests with LLM-as-judge are run manually locally, not in CI.

#### Concurrency

The workflow uses concurrency groups to cancel in-progress runs when new commits are pushed:
- Saves CI time
- Ensures only the latest commit is tested
- Safe because each run is independent

## Setup Instructions

### 1. Enable GitHub Actions

GitHub Actions is enabled by default for all repositories. No setup needed.

### 2. Configure Branch Protection (Recommended)

Protect your `master` branch to require CI checks before merging:

1. Go to repository **Settings** → **Branches**
2. Add branch protection rule for `master`:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - Select required check: **All Checks Passed**
3. Save changes

### 3. Draft PR Workflow

To save CI resources:
- Mark PRs as **Draft** while working (CI won't run)
- Mark **Ready for review** when done (CI runs)
- CI automatically runs on every commit to ready PRs

## Triggering Workflows Manually

You can manually trigger workflows from the GitHub UI:

1. Go to **Actions** tab
2. Select **CI** workflow
3. Click **Run workflow**
4. Choose branch
5. Click **Run workflow**

Useful for:
- Re-running failed tests
- Testing workflow changes
- Verifying CI configuration

## Viewing Results

### On Pull Requests

CI status appears at the bottom of every PR:
- ✅ Green checkmark: All checks passed
- ❌ Red X: Some checks failed
- 🟡 Yellow dot: Checks in progress

Click "Details" to see full logs.

### On Actions Tab

See all workflow runs:
1. Go to **Actions** tab
2. Select a workflow run
3. View detailed logs for each job

### Artifacts

Test results are uploaded as artifacts:
- `test-results`: Unit test results

Download from the workflow run page.

## Troubleshooting

### CI Failing on Linting

**Problem:** Rubocop style errors

**Solution:**
```bash
# Locally
rake lint:fix              # Auto-fix issues
bin/ci                     # Verify passes
git commit -m "Fix linting issues"
```

### CI Failing on Tests

**Problem:** Unit tests failing

**Solution:**
```bash
# Locally
rake test:unit      # Run tests
# Fix the failing tests
bin/ci                     # Verify passes
git commit -m "Fix failing tests"
```

### Workflow Not Running

**Problem:** PR created but CI not running

**Possible causes:**
1. PR is marked as **Draft** (CI skips drafts)
   - Solution: Mark PR as ready for review
2. Workflow file has syntax errors
   - Solution: Check `.github/workflows/ci.yml` for YAML errors
3. Actions disabled in repository settings
   - Solution: Enable in Settings → Actions → General

### CI Taking Too Long

**Problem:** CI runs are slow

**Optimizations:**
- Bundle caching is already enabled (saves ~30 seconds)
- Draft PRs skip CI (saves resources while working)
- Concurrency cancels old runs (avoids duplicate work)
- Only unit tests run (fast, < 10 seconds)

## Local Development

Always run CI locally before pushing:

```bash
# Quick check (< 10 seconds)
bin/ci

# Full check with integration tests (requires API keys)
export OPENAI_API_KEY="sk-..."
INTEGRATION=1 bin/ci
```

This catches issues before pushing and saves CI time.

## Workflow Configuration

### Editing the Workflow

Edit `.github/workflows/ci.yml` to customize:

**Change Ruby version:**
```yaml
- name: Set up Ruby
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: 3.4  # Change here
```

**Add more jobs:**

```yaml
jobs:
  lint-and-test:
    # existing job

  my-new-job:
    name: My New Job
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Hello!"
```

### Testing Workflow Changes

1. Create a branch: `git checkout -b test-workflow`
2. Edit `.github/workflows/ci.yml`
3. Commit: `git commit -am "Test workflow change"`
4. Push: `git push -u origin test-workflow`
5. Open PR or manually trigger workflow
6. View results in Actions tab

## Cost Estimation

### CI Minutes (Free Tier)

GitHub provides 2,000 CI minutes/month for free (public repos have unlimited).

**Per CI run:**
- Lint & Unit Tests: ~1 minute

**Monthly usage estimate:**
- 100 PRs × 1 min = 100 minutes
- 50 master pushes × 1 min = 50 minutes
- **Total: ~150 minutes/month** (well under free tier)

### Integration Tests

Integration tests are run manually locally and are not part of the GitHub Actions workflow:

- **Cost:** ~$0.01 per test run (using GPT-4o mini)
- **When:** Run manually via `rake test:integration:scenario[name]`
- **API Keys:** Use your own OpenAI/Anthropic API keys locally

## Best Practices

### 1. Always Test Locally First
```bash
bin/ci  # Before pushing
```

### 2. Use Draft PRs While Working
- Saves CI minutes
- Marks PR ready when done
- CI runs automatically

### 3. Keep PRs Small
- Faster to review
- Faster to test
- Easier to debug failures

### 4. Don't Skip CI
- Never merge without CI passing
- Use branch protection to enforce

### 5. Run Integration Tests Locally
- Use `rake test:integration:scenario[name]` before major releases
- Track API usage in your OpenAI/Anthropic dashboard
- Integration tests ensure end-to-end functionality

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Ruby Setup Action](https://github.com/ruby/setup-ruby)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Managing Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## Support

If you encounter issues with CI/CD:
1. Check this documentation first
2. View workflow logs in Actions tab
3. Test locally with `bin/ci`
4. Open an issue if problem persists
