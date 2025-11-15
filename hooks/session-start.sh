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
  "context": "Rails-AI loaded - domain layer on Superpowers workflows. Use @architect for Rails development.",
  "content": "$CONTENT"
}
EOF

exit 0
