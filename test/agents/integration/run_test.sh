#!/usr/bin/env bash
# Integration test runner for agent planning tests
#
# Usage: ./run_test.sh <scenario_number>
# Example: ./run_test.sh 01

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAILS_AI_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SCENARIOS_DIR="$SCRIPT_DIR/scenarios"
JUDGE_DIR="$SCRIPT_DIR/judge"

# Parse arguments
SCENARIO_NUM="${1:-01}"
SCENARIO_FILE="$SCENARIOS_DIR/${SCENARIO_NUM}_simple_model_plan.md"
SCENARIO_NAME=$(basename "$SCENARIO_FILE" .md)

# Create timestamped run directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUN_DIR="$RAILS_AI_ROOT/tmp/test/integration/runs/${TIMESTAMP}_${SCENARIO_NAME}"
mkdir -p "$RUN_DIR"

if [ ! -f "$SCENARIO_FILE" ]; then
    echo -e "${RED}Error: Scenario file not found: $SCENARIO_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}=== Rails-AI Integration Test Runner ===${NC}"
echo "Scenario: $SCENARIO_NUM ($SCENARIO_NAME)"
echo "Run directory: $RUN_DIR"
echo ""

# Step 1: Setup run directory (already created above)
echo -e "${YELLOW}Step 1: Run directory ready${NC}"
echo "✓ $RUN_DIR"
echo ""

# Step 2: Run agent with scenario
echo -e "${YELLOW}Step 2: Running agent with scenario${NC}"
echo "Scenario file: $SCENARIO_FILE"
echo "Agent output: $RUN_DIR/agent_plan.md"
echo ""

# Extract the system prompt (between ## System Prompt and ## Agent Prompt)
SYSTEM_PROMPT="$RUN_DIR/system_prompt.txt"
sed -n '/^## System Prompt$/,/^## Agent Prompt$/p' "$SCENARIO_FILE" | sed '1d;$d' > "$SYSTEM_PROMPT"

# Extract the agent prompt (from first ``` to last ``` in the file)
AGENT_PROMPT="$RUN_DIR/agent_prompt.txt"
awk '/^```$/,0' "$SCENARIO_FILE" | sed '1d' | sed '$d' > "$AGENT_PROMPT"

echo "System prompt preview:"
head -3 "$SYSTEM_PROMPT"
echo ""
echo "Agent prompt preview:"
head -5 "$AGENT_PROMPT"
echo "..."
echo ""

# Run claude with system prompt and agent prompt
echo "Executing: claude --print --system-prompt ..."
echo ""
echo "DEBUG: System prompt length: $(cat "$SYSTEM_PROMPT" | wc -c) chars"
echo "DEBUG: Agent prompt length: $(cat "$AGENT_PROMPT" | wc -c) chars"
echo ""

# Run claude CLI
echo "Starting claude CLI (this may take a moment)..."
echo ""
claude --print --system-prompt "$(cat "$SYSTEM_PROMPT")" <<< "$(cat "$AGENT_PROMPT")" 2>&1 | tee "$RUN_DIR/agent_plan.md"
CLAUDE_EXIT_CODE=${PIPESTATUS[0]}
echo ""
echo "DEBUG: Claude exit code: $CLAUDE_EXIT_CODE"

echo ""

# Step 3: Verify agent output exists
echo -e "${YELLOW}Step 3: Verifying agent output${NC}"
AGENT_OUTPUT="$RUN_DIR/agent_plan.md"

if [ ! -f "$AGENT_OUTPUT" ]; then
    echo -e "${RED}Error: Agent output not found at $AGENT_OUTPUT${NC}"
    echo "Expected the agent to write the plan to this file."
    exit 1
fi

echo "✓ Agent output found: $AGENT_OUTPUT"
echo "  Size: $(wc -l < "$AGENT_OUTPUT") lines"
echo ""


echo ""
echo -e "${GREEN}=== Test Complete ===${NC}"
echo "Results saved to: $RUN_DIR"
echo ""
echo "To review:"
echo "  Agent plan: $RUN_DIR/agent_plan.md"
echo ""
echo "To run judge:"
echo "  ./run_judge.sh $RUN_DIR"
echo ""
