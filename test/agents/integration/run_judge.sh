#!/usr/bin/env bash
# Run judge on agent test output
#
# Usage: ./run_judge.sh <run_directory>
# Example: ./run_judge.sh ../../tmp/test/integration/runs/20251102_123456_01_simple_model_plan

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIOS_DIR="$SCRIPT_DIR/scenarios"
JUDGE_DIR="$SCRIPT_DIR/judge"
RAILS_AI_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Parse arguments
RUN_DIR="$1"

if [ -z "$RUN_DIR" ]; then
    echo -e "${RED}Error: Run directory required${NC}"
    echo "Usage: $0 <run_directory>"
    echo ""
    echo "Example:"
    echo "  $0 \$RAILS_AI_ROOT/tmp/test/integration/runs/20251102_123456_01_simple_model_plan"
    exit 1
fi

# Check if run directory exists
if [ ! -d "$RUN_DIR" ]; then
    echo -e "${RED}Error: Run directory not found: $RUN_DIR${NC}"
    exit 1
fi

# Extract scenario name from directory
SCENARIO_NAME=$(basename "$RUN_DIR" | sed 's/^[0-9]*_[0-9]*_//')
SCENARIO_FILE="$SCENARIOS_DIR/${SCENARIO_NAME}.md"
AGENT_OUTPUT="$RUN_DIR/agent_plan.md"

echo -e "${YELLOW}=== Running Judge ===${NC}"
echo "Run directory: $RUN_DIR"
echo "Scenario: $SCENARIO_NAME"
echo ""

# Check if agent output exists
if [ ! -f "$AGENT_OUTPUT" ]; then
    echo -e "${RED}Error: Agent output not found at $AGENT_OUTPUT${NC}"
    echo "Run ./run_test.sh first to generate agent output"
    exit 1
fi

# Check if scenario file exists
if [ ! -f "$SCENARIO_FILE" ]; then
    echo -e "${RED}Error: Scenario file not found: $SCENARIO_FILE${NC}"
    exit 1
fi

echo "Agent output: $AGENT_OUTPUT ($(wc -l < "$AGENT_OUTPUT") lines)"
echo ""

# Run parallel domain judges
echo -e "${YELLOW}Step 1: Running parallel domain judges${NC}"
echo ""

bash "$JUDGE_DIR/run_parallel_judges.sh" "$SCENARIO_FILE" "$AGENT_OUTPUT" "$RUN_DIR"

echo ""

# Combine results
echo -e "${YELLOW}Step 2: Combining domain judgments${NC}"
echo ""

bash "$JUDGE_DIR/combine_judgments.sh" "$RUN_DIR"
EXIT_CODE=$?

echo ""

echo ""
echo -e "${GREEN}=== Judge Complete ===${NC}"
echo "Combined report: $RUN_DIR/combined_judgment.md"
echo ""

# Display summary
if [ -f "$RUN_DIR/combined_judgment.md" ]; then
    echo "View full report with:"
    echo "  cat $RUN_DIR/combined_judgment.md"
fi
echo ""

exit $EXIT_CODE
