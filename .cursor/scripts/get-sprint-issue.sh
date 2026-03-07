#!/bin/bash
# Find or create a sprint epic issue
# Usage: .cursor/scripts/get-sprint-issue.sh <sprint-plan-file>

set -e

SPRINT_PLAN="$1"

if [ ! -f "$SPRINT_PLAN" ]; then
    echo "Error: Sprint plan file not found: $SPRINT_PLAN"
    exit 1
fi

# Extract sprint name from frontmatter
SPRINT_NAME=$(grep -m 1 '^name:' "$SPRINT_PLAN" | sed 's/name: *//')
SPRINT_OVERVIEW=$(grep -m 1 '^overview:' "$SPRINT_PLAN" | sed 's/overview: *//')

# Create a unique label for this sprint
SPRINT_LABEL=$(echo "$SPRINT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Search for existing sprint issue by label
EXISTING_ISSUE=$(gh issue list --label "sprint-epic,$SPRINT_LABEL" --json number --jq '.[0].number' 2>/dev/null || echo "")

if [ -n "$EXISTING_ISSUE" ]; then
    # Sprint issue exists
    echo "$EXISTING_ISSUE"
else
    # Create new sprint epic issue
    SPRINT_TITLE="Epic: $SPRINT_NAME"
    
    # Extract sprint details for body
    DURATION=$(awk '/^\*\*Duration\*\*:/ {for(i=2; i<=NF; i++) printf $i " "; print ""}' "$SPRINT_PLAN" | head -1)
    GOAL=$(awk '/^\*\*Goal\*\*:/ {for(i=2; i<=NF; i++) printf $i " "; print ""}' "$SPRINT_PLAN" | head -1)
    
    SPRINT_BODY="## $SPRINT_NAME

$SPRINT_OVERVIEW

**Duration**: $DURATION
**Goal**: $GOAL

## Tracked Tickets

This epic tracks all tickets in this sprint. Individual tickets will be linked below as they are created.

---

**Sprint Plan**: See [\`.cursor/plans/$(basename "$SPRINT_PLAN")\`](https://github.com/jxtngx/ib-interface/blob/main/.cursor/plans/$(basename "$SPRINT_PLAN"))
"

    # Create sprint epic issue
    gh issue create \
        --title "$SPRINT_TITLE" \
        --body "$SPRINT_BODY" \
        --label "sprint-epic,$SPRINT_LABEL" > /tmp/sprint-issue-create.txt
    
    # Extract issue number from output
    NEW_ISSUE=$(grep -oE '#[0-9]+' /tmp/sprint-issue-create.txt | head -1 | tr -d '#')
    rm -f /tmp/sprint-issue-create.txt
    
    echo "$NEW_ISSUE"
fi