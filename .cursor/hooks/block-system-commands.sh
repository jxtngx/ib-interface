#!/bin/bash
# Hook to block system modification commands
# Prevents chmod, chown, chgrp, and sudo from being executed by the agent

# Read JSON input from stdin
input=$(cat)

# Parse the command from the JSON input
command=$(echo "$input" | jq -r '.command // empty')

# Check if the command contains system modification commands
if [[ "$command" =~ ^chmod[[:space:]] ]] || [[ "$command" == "chmod" ]]; then
    # Block chmod command
    cat << 'EOF'
{
  "continue": true,
  "permission": "deny",
  "user_message": "chmod command blocked by hook",
  "agent_message": "The chmod command has been blocked. File permissions should be managed by the user.\n\nInstead:\n1. Create the file normally\n2. Tell the user to run: chmod +x <script-path>\n3. Or suggest: bash <script-path> to execute without changing permissions"
}
EOF
elif [[ "$command" =~ ^chown[[:space:]] ]] || [[ "$command" == "chown" ]]; then
    # Block chown command
    cat << 'EOF'
{
  "continue": true,
  "permission": "deny",
  "user_message": "chown command blocked by hook",
  "agent_message": "The chown command has been blocked. File ownership should be managed by the user, not by the agent."
}
EOF
elif [[ "$command" =~ ^chgrp[[:space:]] ]] || [[ "$command" == "chgrp" ]]; then
    # Block chgrp command
    cat << 'EOF'
{
  "continue": true,
  "permission": "deny",
  "user_message": "chgrp command blocked by hook",
  "agent_message": "The chgrp command has been blocked. File group ownership should be managed by the user, not by the agent."
}
EOF
elif [[ "$command" =~ ^sudo[[:space:]] ]] || [[ "$command" == "sudo" ]]; then
    # Block sudo command
    cat << 'EOF'
{
  "continue": true,
  "permission": "deny",
  "user_message": "sudo command blocked by hook",
  "agent_message": "The sudo command has been blocked. Elevated privilege operations should be run by the user, not by the agent."
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
