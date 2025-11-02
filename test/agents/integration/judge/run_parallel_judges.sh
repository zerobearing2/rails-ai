#!/usr/bin/env bash
# Run multiple domain judges in parallel
#
# Usage: ./run_parallel_judges.sh <scenario_file> <agent_output_file> <output_dir>

set -e

SCENARIO_FILE="$1"
AGENT_OUTPUT="$2"
OUTPUT_DIR="$3"

if [ -z "$SCENARIO_FILE" ] || [ -z "$AGENT_OUTPUT" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <scenario_file> <agent_output_file> <output_dir>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Running Parallel Domain Judges ==="
echo ""

# Domains to judge
DOMAINS=("backend" "tests" "security")

# Load domain contexts in parallel
echo "Step 1: Loading domain contexts..."
for domain in "${DOMAINS[@]}"; do
    (
        bash "$SCRIPT_DIR/load_domain_context.sh" "$domain" "$OUTPUT_DIR/${domain}_context.txt"
    ) &
done
wait
echo "✓ All domain contexts loaded"
echo ""

# Run judges in parallel
echo "Step 2: Running domain judges in parallel..."
for domain in "${DOMAINS[@]}"; do
    (
        # Create combined input for this judge
        JUDGE_INPUT="$OUTPUT_DIR/${domain}_judge_input.txt"
        cat "$SCRIPT_DIR/${domain}_judge_prompt.md" > "$JUDGE_INPUT"
        echo "" >> "$JUDGE_INPUT"
        echo "## Domain Context (Skills & Rules)" >> "$JUDGE_INPUT"
        cat "$OUTPUT_DIR/${domain}_context.txt" >> "$JUDGE_INPUT"
        echo "" >> "$JUDGE_INPUT"
        echo "## Scenario" >> "$JUDGE_INPUT"
        cat "$SCENARIO_FILE" >> "$JUDGE_INPUT"
        echo "" >> "$JUDGE_INPUT"
        echo "## Agent's Plan to Evaluate" >> "$JUDGE_INPUT"
        cat "$AGENT_OUTPUT" >> "$JUDGE_INPUT"

        # Run judge
        echo "  Running $domain judge..."
        claude --print "$(cat "$JUDGE_INPUT")" > "$OUTPUT_DIR/${domain}_judgment.md" 2>&1
        echo "  ✓ $domain judge complete"
    ) &
done

# Wait for all judges to complete
wait
echo "✓ All domain judges complete"
echo ""

echo "Results:"
for domain in "${DOMAINS[@]}"; do
    lines=$(wc -l < "$OUTPUT_DIR/${domain}_judgment.md")
    echo "  - $domain: $OUTPUT_DIR/${domain}_judgment.md ($lines lines)"
done
echo ""
