#!/bin/bash
# Check if a ticket has an existing GitHub issue
# Usage: .cursor/scripts/fetch-github-state.sh <ticket-id>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <ticket-id>"
    echo "Example: $0 PROTO-006"
    exit 1
fi

TICKET_ID="$1"

# Search for existing issue by title pattern
EXISTING_ISSUE=$(gh issue list --search "[$TICKET_ID]" --state all --json number,title,state --jq '.[0]' 2>/dev/null || echo "")

if [ -z "$EXISTING_ISSUE" ] || [ "$EXISTING_ISSUE" = "null" ]; then
    # No issue found
    echo "false"
    exit 0
fi

# Issue found - extract number and state
ISSUE_NUMBER=$(echo "$EXISTING_ISSUE" | jq -r '.number')
ISSUE_STATE=$(echo "$EXISTING_ISSUE" | jq -r '.state')

# Check if there's a closed/merged PR for this ticket
PR_STATE=$(gh pr list --search "$TICKET_ID" --state all --json number,state --jq '.[0].state' 2>/dev/null || echo "")

# Output: issue_number if exists, empty if not
if [ -n "$ISSUE_NUMBER" ] && [ "$ISSUE_NUMBER" != "null" ]; then
    echo "$ISSUE_NUMBER"
else
    echo "false"
fi
