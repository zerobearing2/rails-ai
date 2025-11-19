#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INTRO_FILE="$PLUGIN_ROOT/skills/using-rails-ai/SKILL.md"

if [ ! -f "$INTRO_FILE" ]; then
  echo '{"error": "using-rails-ai/SKILL.md not found"}' >&2
  exit 1
fi

CONTENT=$(cat "$INTRO_FILE")

# Escape for JSON
CONTENT=$(echo "$CONTENT" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}')

# Output JSON
cat << EOF
{
  "event": "session-start",
  "context": "🚀 Rails-AI SessionStart Hook Executed - using-rails-ai skill loaded with Superpowers dependency check and skill-loading protocol. Use /rails-ai:architect for Rails development.",
  "content": "$CONTENT",
  "debug": {
    "hook_executed": true,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "skill_loaded": "rails-ai:using-rails-ai",
    "skill_path": "$INTRO_FILE",
    "content_length": $(echo "$CONTENT" | wc -c)
  }
}
EOF

exit 0
