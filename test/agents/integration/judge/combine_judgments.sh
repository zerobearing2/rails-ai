#!/usr/bin/env bash
# Combine parallel judge results into final assessment
#
# Usage: ./combine_judgments.sh <output_dir>

set -e

OUTPUT_DIR="$1"

if [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <output_dir>"
    exit 1
fi

COMBINED="$OUTPUT_DIR/combined_judgment.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Combining Domain Judgments ==="
echo ""

# Extract scores from each domain
extract_score() {
    local file="$1"
    local domain="$2"
    grep "^## ${domain^} Total:" "$file" 2>/dev/null | grep -o '[0-9]\+/50' | cut -d'/' -f1 || echo "0"
}

BACKEND_SCORE=$(extract_score "$OUTPUT_DIR/backend_judgment.md" "backend")
TESTS_SCORE=$(extract_score "$OUTPUT_DIR/tests_judgment.md" "tests")
SECURITY_SCORE=$(extract_score "$OUTPUT_DIR/security_judgment.md" "security")

TOTAL_SCORE=$((BACKEND_SCORE + TESTS_SCORE + SECURITY_SCORE))
MAX_SCORE=150
PERCENTAGE=$((TOTAL_SCORE * 100 / MAX_SCORE))

# Create combined report
cat > "$COMBINED" << EOF
# Combined Integration Test Judgment

**Date**: $(date +%Y-%m-%d)
**Total Score**: $TOTAL_SCORE/$MAX_SCORE ($PERCENTAGE%)

## Domain Scores

- **Backend**: $BACKEND_SCORE/50
- **Tests**: $TESTS_SCORE/50
- **Security**: $SECURITY_SCORE/50

---

EOF

# Append each domain's judgment
for domain in backend tests security; do
    echo "## ${domain^} Domain Judgment" >> "$COMBINED"
    echo "" >> "$COMBINED"
    cat "$OUTPUT_DIR/${domain}_judgment.md" >> "$COMBINED"
    echo "" >> "$COMBINED"
    echo "---" >> "$COMBINED"
    echo "" >> "$COMBINED"
done

# Determine pass/fail (70% threshold = 105/150)
THRESHOLD=105

cat >> "$COMBINED" << EOF

## Final Assessment

**Threshold**: $THRESHOLD/$MAX_SCORE (70%)
**Result**:
EOF

if [ "$TOTAL_SCORE" -ge "$THRESHOLD" ]; then
    echo "**PASS** ✓" >> "$COMBINED"
    RESULT="PASS"
    COLOR="$GREEN"
else
    echo "**FAIL** ✗" >> "$COMBINED"
    RESULT="FAIL"
    COLOR="$RED"
fi

cat >> "$COMBINED" << EOF

### Scoring Breakdown

Each domain is scored out of 50 points across 5 criteria (10 points each):

**Backend (Models, Migrations, Validations)**
- Model Design
- Migration Quality
- Validations
- Business Logic
- Rails Conventions

**Tests (Coverage, Quality, Organization)**
- Test Coverage
- Test Quality
- Test Organization
- Edge Cases
- Test Maintainability

**Security (Authorization, Protection, Best Practices)**
- Authorization
- Mass Assignment Protection
- Data Validation
- Sensitive Data Handling
- Security Best Practices

### Pass/Fail Criteria

- **PASS**: Total score ≥ $THRESHOLD (70%)
- **FAIL**: Total score < $THRESHOLD

EOF

# Display results
echo -e "${YELLOW}Domain Scores:${NC}"
echo -e "  Backend:  $BACKEND_SCORE/50"
echo -e "  Tests:    $TESTS_SCORE/50"
echo -e "  Security: $SECURITY_SCORE/50"
echo ""
echo -e "${YELLOW}Total Score:${NC} $TOTAL_SCORE/$MAX_SCORE ($PERCENTAGE%)"
echo ""
echo -e "${YELLOW}Result:${NC} ${COLOR}${RESULT}${NC}"
echo ""
echo "Combined report: $COMBINED"
echo ""

# Append to judge log
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAILS_AI_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
JUDGE_LOG="$RAILS_AI_ROOT/tmp/test/integration/JUDGE_LOG.md"

# Ensure log exists
if [ ! -f "$JUDGE_LOG" ]; then
    cat > "$JUDGE_LOG" << 'LOGHEADER'
# Judge Evaluation Log

This file contains a chronological log of all judge evaluations for tracking accuracy and improvement over time.

Format: Each entry includes date, scenario, agent version, scores, and pass/fail result.

---

LOGHEADER
fi

cat >> "$JUDGE_LOG" << EOF
## Evaluation: $(date '+%Y-%m-%d %H:%M:%S')

**Scenario**: $(basename "$(ls $OUTPUT_DIR/../scenarios/*.md 2>/dev/null | head -1)" .md)
**Agent Version**: $(cd "$SCRIPT_DIR/../../.." && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
**Branch**: $(cd "$SCRIPT_DIR/../../.." && git branch --show-current 2>/dev/null || echo "unknown")

### Scores
- Backend: $BACKEND_SCORE/50
- Tests: $TESTS_SCORE/50
- Security: $SECURITY_SCORE/50
- **Total**: $TOTAL_SCORE/$MAX_SCORE ($PERCENTAGE%)

### Result
**$RESULT** (Threshold: $THRESHOLD/$MAX_SCORE)

### Critical Issues
$(for domain in backend tests security; do
    echo "**${domain^}**:"
    grep -A 5 "^## Critical" "$OUTPUT_DIR/${domain}_judgment.md" 2>/dev/null | tail -n +2 | head -5 || echo "  - None"
done)

---

EOF

echo "✓ Logged to: $JUDGE_LOG"
echo ""

# Exit with appropriate code
if [ "$RESULT" = "PASS" ]; then
    exit 0
else
    exit 1
fi
