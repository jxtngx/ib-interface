#!/bin/bash
# Hook to enforce git commit standards
# Prevents git commits with --trailer flag per git-commit-standards.md

# Read JSON input from stdin
input=$(cat)

# Parse the command from the JSON input
command=$(echo "$input" | jq -r '.command // empty')

# Check if the command contains git commit with --trailer
if [[ "$command" =~ git[[:space:]].*commit.*--trailer ]] || [[ "$command" =~ git[[:space:]].*--trailer.*commit ]]; then
    # Block git commit with --trailer flag
    cat << 'EOF'
{
  "continue": false,
  "permission": "deny",
  "user_message": "git commit with --trailer blocked by hook",
  "agent_message": "Git commits with --trailer flag are blocked per git-commit-standards.md\n\nProhibited pattern detected:\n- git commit --trailer \"Made-with: Cursor\"\n- git commit --trailer \"Made-with: <any-tool>\"\n\nRationale: Commits should reflect the work done, not the tools used. Tool metadata clutters commit history and provides no value for code review or history tracking.\n\nRemove the --trailer flag from your git commit command."
}
EOF
else
    # Allow all other commands
    cat << 'EOF'
{
  "continue": true,
  "permission": "allow"
}
EOF
fi
