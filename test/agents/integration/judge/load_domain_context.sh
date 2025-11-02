#!/usr/bin/env bash
# Load skills and rules for a specific domain
#
# Usage: ./load_domain_context.sh <domain> <output_file>
# Example: ./load_domain_context.sh backend /tmp/backend_context.txt

set -e

DOMAIN="$1"
OUTPUT_FILE="$2"

if [ -z "$DOMAIN" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 <domain> <output_file>"
    echo "Domains: backend, tests, security"
    exit 1
fi

# Get the rails-ai root directory
RAILS_AI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SKILLS_DIR="$RAILS_AI_ROOT/skills"
AGENTS_DIR="$RAILS_AI_ROOT/agents"

# Clear output file
> "$OUTPUT_FILE"

echo "# Domain Context: $DOMAIN" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

case "$DOMAIN" in
    backend)
        echo "## Backend Agent Definition" >> "$OUTPUT_FILE"
        if [ -f "$AGENTS_DIR/backend.md" ]; then
            cat "$AGENTS_DIR/backend.md" >> "$OUTPUT_FILE"
        fi
        echo "" >> "$OUTPUT_FILE"

        echo "## Relevant Skills" >> "$OUTPUT_FILE"
        # Add backend-related skills
        for skill in models migrations associations validations activerecord database; do
            skill_file=$(find "$SKILLS_DIR" -type f -iname "*${skill}*.md" 2>/dev/null | head -1)
            if [ -n "$skill_file" ] && [ -f "$skill_file" ]; then
                echo "### Skill: $(basename "$skill_file" .md)" >> "$OUTPUT_FILE"
                cat "$skill_file" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            fi
        done
        ;;

    tests)
        echo "## Tests Agent Definition" >> "$OUTPUT_FILE"
        if [ -f "$AGENTS_DIR/tests.md" ]; then
            cat "$AGENTS_DIR/tests.md" >> "$OUTPUT_FILE"
        fi
        echo "" >> "$OUTPUT_FILE"

        echo "## Relevant Skills" >> "$OUTPUT_FILE"
        # Add testing-related skills
        for skill in test minitest rspec coverage fixtures factories; do
            skill_file=$(find "$SKILLS_DIR" -type f -iname "*${skill}*.md" 2>/dev/null | head -1)
            if [ -n "$skill_file" ] && [ -f "$skill_file" ]; then
                echo "### Skill: $(basename "$skill_file" .md)" >> "$OUTPUT_FILE"
                cat "$skill_file" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            fi
        done
        ;;

    security)
        echo "## Security Agent Definition" >> "$OUTPUT_FILE"
        if [ -f "$AGENTS_DIR/security.md" ]; then
            cat "$AGENTS_DIR/security.md" >> "$OUTPUT_FILE"
        fi
        echo "" >> "$OUTPUT_FILE"

        echo "## Relevant Skills" >> "$OUTPUT_FILE"
        # Add security-related skills
        for skill in security authorization authentication csrf xss sql_injection; do
            skill_file=$(find "$SKILLS_DIR" -type f -iname "*${skill}*.md" 2>/dev/null | head -1)
            if [ -n "$skill_file" ] && [ -f "$skill_file" ]; then
                echo "### Skill: $(basename "$skill_file" .md)" >> "$OUTPUT_FILE"
                cat "$skill_file" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            fi
        done
        ;;

    *)
        echo "Unknown domain: $DOMAIN"
        exit 1
        ;;
esac

echo "✓ Loaded context for $DOMAIN domain: $(wc -l < "$OUTPUT_FILE") lines"
