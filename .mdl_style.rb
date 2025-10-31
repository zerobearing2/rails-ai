# frozen_string_literal: true

# Markdown linting style for skill files

all

# Allow long lines (code examples, YAML, URLs)
# Disabled: Line length not enforced
exclude_rule "MD013"

# Exclude reversed link syntax (causes false positives in Ruby code blocks)
exclude_rule "MD011"

# Allow multiple headers with the same content
exclude_rule "MD024"

# Don't require fenced code blocks to be surrounded by blank lines
exclude_rule "MD031"

# Don't require lists to be surrounded by blank lines
exclude_rule "MD032"

# Allow inline HTML (needed for XML semantic tags)
exclude_rule "MD033"

# Allow raw URLs (useful in resources sections)
exclude_rule "MD034"

# Don't require first line to be a top-level header (YAML front matter)
exclude_rule "MD041"

# Don't require blank line after headers (conflicts with YAML front matter)
exclude_rule "MD022"

# Allow emphasis markers in middle of words
exclude_rule "MD037"

# Allow dollar signs in code without escaping
exclude_rule "MD014"

# Don't enforce ordered list prefix style
exclude_rule "MD029"

# Don't enforce code block style (fenced vs indented)
# Can cause false positives with complex nested structures
exclude_rule "MD046"

# Allow nested list items with 2-space indentation
# MD007 expects 4 spaces but standard Markdown allows 2
exclude_rule "MD007"
