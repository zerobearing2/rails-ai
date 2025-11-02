# Judge Evaluation Log

## Purpose

The `JUDGE_LOG.md` file maintains a chronological record of all judge evaluations. This helps track:
- Agent improvement over time
- Which scenarios pass/fail consistently
- Impact of agent changes on quality
- Regression detection

## Log Format

Each evaluation entry includes:

```markdown
## Evaluation: 2025-11-02 14:30:45

**Scenario**: 01_simple_model_plan
**Agent Version**: abc123f
**Branch**: integration-test-prompts

### Scores
- Backend: 42/50
- Tests: 38/50
- Security: 45/50
- **Total**: 125/150 (83%)

### Result
**PASS** (Threshold: 105/150)

### Critical Issues
**Backend**:
  - None

**Tests**:
  - Missing edge case tests for published scope

**Security**:
  - None

---
```

## Usage

### View All Evaluations

```bash
cat test/agents/integration/judge/JUDGE_LOG.md
```

### View Latest Evaluation

```bash
tail -25 test/agents/integration/judge/JUDGE_LOG.md
```

### Count Evaluations

```bash
grep "^## Evaluation:" test/agents/integration/judge/JUDGE_LOG.md | wc -l
```

### Filter by Result

```bash
# Show all PASS results
grep -A 15 "^## Evaluation:" test/agents/integration/judge/JUDGE_LOG.md | grep -A 14 "PASS"

# Show all FAIL results
grep -A 15 "^## Evaluation:" test/agents/integration/judge/JUDGE_LOG.md | grep -A 14 "FAIL"
```

### Track Improvement Over Time

```bash
# Extract scores over time
grep "Total\*\*:" test/agents/integration/judge/JUDGE_LOG.md
```

## Analysis Examples

### Average Score

```bash
grep "Total\*\*:" test/agents/integration/judge/JUDGE_LOG.md | \
  grep -o '[0-9]\+/150' | \
  cut -d'/' -f1 | \
  awk '{sum+=$1; count++} END {print "Average:", sum/count, "/150"}'
```

### Pass Rate

```bash
total=$(grep "^## Evaluation:" test/agents/integration/judge/JUDGE_LOG.md | wc -l)
passes=$(grep "\*\*PASS\*\*" test/agents/integration/judge/JUDGE_LOG.md | wc -l)
echo "Pass Rate: $passes/$total ($(( passes * 100 / total ))%)"
```

### Most Common Issues

```bash
grep -A 20 "### Critical Issues" test/agents/integration/judge/JUDGE_LOG.md | \
  grep "^  -" | \
  sort | \
  uniq -c | \
  sort -rn | \
  head -10
```

## Automated Tracking

The log is automatically updated every time you run:

```bash
./run_judge_only.sh
```

No manual intervention needed!

## Log Rotation

If the log grows too large, you can archive it:

```bash
# Archive old log
mv judge/JUDGE_LOG.md judge/JUDGE_LOG_2025-11.md

# Start fresh
echo "# Judge Evaluation Log" > judge/JUDGE_LOG.md
echo "" >> judge/JUDGE_LOG.md
echo "This file contains a chronological log..." >> judge/JUDGE_LOG.md
echo "" >> judge/JUDGE_LOG.md
echo "---" >> judge/JUDGE_LOG.md
echo "" >> judge/JUDGE_LOG.md
```

## Git Integration

The log is tracked in git, so you can:

```bash
# See log changes over time
git log -p judge/JUDGE_LOG.md

# See when scores improved
git diff HEAD~5 judge/JUDGE_LOG.md

# Blame specific evaluations
git blame judge/JUDGE_LOG.md
```

## Benefits

1. **Track Progress**: See agent improvements across commits
2. **Detect Regressions**: Catch when changes hurt quality
3. **Identify Patterns**: Find common failure modes
4. **Benchmark**: Compare different agent configurations
5. **Accountability**: Know exactly when/why scores changed
