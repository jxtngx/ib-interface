#!/bin/bash
# Fetch GitHub Projects state for sprint tickets
# Usage: .cursor/scripts/fetch-github-state.sh <sprint-plan-file>
# Outputs JSON to stdout

set -e

SPRINT_PLAN="$1"
PROJECT_NUMBER="29"

if [ ! -f "$SPRINT_PLAN" ]; then
    echo "Error: Sprint plan file not found: $SPRINT_PLAN" >&2
    exit 1
fi

echo "Fetching GitHub Projects state..." >&2

# Get project items
PROJECT_DATA=$(gh project item-list "$PROJECT_NUMBER" \
    --owner jxtngx \
    --format json \
    --limit 1000 2>/dev/null || echo '{"items":[],"totalCount":0}')

PROJECT_ITEMS=$(echo "$PROJECT_DATA" | jq '.items')
ITEMS_IN_PROJECT=$(echo "$PROJECT_DATA" | jq '.totalCount')

if [ "$ITEMS_IN_PROJECT" -eq 0 ]; then
    echo "Warning: No items found in GitHub Project #$PROJECT_NUMBER" >&2
fi

# Fetch all PRs once
echo "Fetching PRs..." >&2
ALL_PRS=$(gh pr list --state all --json number,title,state --limit 1000 2>/dev/null || echo "[]")

# Extract ticket IDs from sprint plan
SPRINT_TICKETS=$(grep -E '^\| (PROTO|API|TEST|OBS|DOC)-[0-9]+' "$SPRINT_PLAN" | \
    awk -F'|' '{print $2}' | \
    sed 's/^ *//;s/ *$//' | \
    grep -v '^Plan$')

# Output JSON to stdout
cat << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "project_url": "https://github.com/users/jxtngx/projects/$PROJECT_NUMBER",
  "sprint_tickets": [
EOF

FIRST=true
while IFS= read -r ticket_id; do
    if [ -n "$ticket_id" ]; then
        # Find matching project item
        PROJECT_ITEM=$(echo "$PROJECT_ITEMS" | jq -c ".[] | select(.title | contains(\"[$ticket_id]\"))" 2>/dev/null | head -1)
        
        # Find matching PR from cached list
        TICKET_NUM=$(echo "$ticket_id" | grep -oE '[0-9]+$')
        TICKET_PREFIX=$(echo "$ticket_id" | grep -oE '^[A-Z]+')
        
        # Match PR by multiple patterns:
        # 1. [PROTO-001] or PROTO-001 (standard format)
        # 2. proto 001 or proto-001 (lowercase, space or dash)
        # 3. Feature/proto 001 (branch name format)
        PR_MATCH=$(echo "$ALL_PRS" | jq -c "
          .[] | select(
            .title | test(\"(?i)(\\\\[?${TICKET_PREFIX}[- _]0*${TICKET_NUM}\\\\b|${TICKET_PREFIX,,}[- _/]0*${TICKET_NUM})\")
          )
        " 2>/dev/null | head -1)
        
        HAS_PR="false"
        PR_NUMBER="null"
        PR_STATE="none"
        
        if [ -n "$PR_MATCH" ]; then
            HAS_PR="true"
            PR_NUMBER=$(echo "$PR_MATCH" | jq -r '.number')
            PR_STATE=$(echo "$PR_MATCH" | jq -r '.state')
        fi
        
        # Get plan file status
        PLAN_SLUG=$(grep -E "^\| $ticket_id " "$SPRINT_PLAN" | awk -F'|' '{print $6}' | sed 's/^ *//;s/ *$//')
        HAS_PLAN="false"
        if [ -n "$PLAN_SLUG" ] && [ "$PLAN_SLUG" != "TBD" ]; then
            HAS_PLAN="true"
        fi
        
        # Extract project item fields
        if [ -n "$PROJECT_ITEM" ]; then
            ISSUE_NUMBER=$(echo "$PROJECT_ITEM" | jq -r '.content.number // null')
            ISSUE_STATE=$(echo "$PROJECT_ITEM" | jq -r '.content.state // "unknown"')
            PROJECT_STATUS=$(echo "$PROJECT_ITEM" | jq -r '.status // "No Status"')
            HAS_ISSUE="true"
        else
            ISSUE_NUMBER="null"
            ISSUE_STATE="not_created"
            PROJECT_STATUS="Not in Project"
            HAS_ISSUE="false"
        fi
        
        # Determine if ticket needs issue
        NEEDS_ISSUE="false"
        if [ "$HAS_PLAN" = "true" ] && [ "$HAS_ISSUE" = "false" ] && [ "$PR_STATE" != "MERGED" ] && [ "$PR_STATE" != "CLOSED" ]; then
            NEEDS_ISSUE="true"
        fi
        
        # Add comma separator
        if [ "$FIRST" = false ]; then
            echo "    ,"
        fi
        FIRST=false
        
        # Output ticket data
        cat << TICKET_EOF
    {
      "ticket_id": "$ticket_id",
      "has_plan": $HAS_PLAN,
      "plan_file": "$PLAN_SLUG",
      "has_issue": $HAS_ISSUE,
      "issue_number": $ISSUE_NUMBER,
      "issue_state": "$ISSUE_STATE",
      "project_status": "$PROJECT_STATUS",
      "has_pr": $HAS_PR,
      "pr_number": $PR_NUMBER,
      "pr_state": "$PR_STATE",
      "needs_issue": $NEEDS_ISSUE
    }
TICKET_EOF
    fi
done <<< "$SPRINT_TICKETS"

# Close JSON
TOTAL_TICKETS=$(echo "$SPRINT_TICKETS" | wc -l | tr -d ' ')
cat << EOF

  ],
  "summary": {
    "total_tickets": $TOTAL_TICKETS,
    "in_project": $ITEMS_IN_PROJECT,
    "project_number": $PROJECT_NUMBER
  }
}
EOF
