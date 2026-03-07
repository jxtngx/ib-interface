#!/bin/bash
# Intelligent issue creation handler
# Usage: .cursor/scripts/run-issue-handler.sh [ticket-id]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPRINT_PLAN="$PROJECT_ROOT/.cursor/plans/sprint_1_modernization_e041af8d.plan.md"

cd "$PROJECT_ROOT"

echo ""
echo "Fetching GitHub state..."
echo ""

# Capture state in variable (stderr goes to terminal, stdout captured)
STATE_JSON=$(bash "$SCRIPT_DIR/fetch-github-state.sh" "$SPRINT_PLAN")

if [ -z "$STATE_JSON" ]; then
    echo "Error: Failed to fetch GitHub state"
    exit 1
fi

# Extract summary
TOTAL_TICKETS=$(echo "$STATE_JSON" | jq -r '.summary.total_tickets // 0')
IN_PROJECT=$(echo "$STATE_JSON" | jq -r '.summary.in_project // 0')
WITH_PLANS=$(echo "$STATE_JSON" | jq '[.sprint_tickets[] | select(.has_plan == true)] | length')
WITH_ISSUES=$(echo "$STATE_JSON" | jq '[.sprint_tickets[] | select(.has_issue == true)] | length')
WITH_PRS=$(echo "$STATE_JSON" | jq '[.sprint_tickets[] | select(.pr_state == "MERGED" or .pr_state == "CLOSED")] | length')
NEEDS_ISSUES=$(echo "$STATE_JSON" | jq '[.sprint_tickets[] | select(.needs_issue == true)] | length')

echo ""
echo "Summary:"
echo "  Total tickets: $TOTAL_TICKETS"
echo "  In GitHub Project: $IN_PROJECT"
echo "  With plans: $WITH_PLANS"
echo "  With issues: $WITH_ISSUES"
echo "  With closed PRs: $WITH_PRS"
echo "  Need issues: $NEEDS_ISSUES"
echo ""
PROJECT_URL=$(echo "$STATE_JSON" | jq -r '.project_url')
echo "View project: $PROJECT_URL"
echo ""

# Mode 1: Single ticket
if [ -n "$1" ]; then
    TICKET_ID="$1"
    echo "Mode: Single ticket ($TICKET_ID)"
    echo ""
    
    HAS_PLAN=$(echo "$STATE_JSON" | jq -r ".sprint_tickets[] | select(.ticket_id == \"$TICKET_ID\") | .has_plan")
    
    if [ "$HAS_PLAN" != "true" ]; then
        echo "Error: Ticket $TICKET_ID does not have a plan file"
        exit 1
    fi
    
    HAS_ISSUE=$(echo "$STATE_JSON" | jq -r ".sprint_tickets[] | select(.ticket_id == \"$TICKET_ID\") | .has_issue")
    ISSUE_NUMBER=$(echo "$STATE_JSON" | jq -r ".sprint_tickets[] | select(.ticket_id == \"$TICKET_ID\") | .issue_number")
    PR_STATE=$(echo "$STATE_JSON" | jq -r ".sprint_tickets[] | select(.ticket_id == \"$TICKET_ID\") | .pr_state")
    PR_NUMBER=$(echo "$STATE_JSON" | jq -r ".sprint_tickets[] | select(.ticket_id == \"$TICKET_ID\") | .pr_number")
    
    if [ "$PR_STATE" = "MERGED" ] || [ "$PR_STATE" = "CLOSED" ]; then
        echo "✓ Ticket $TICKET_ID already has a closed/merged PR: #$PR_NUMBER"
        echo "  No issue needed - work is complete"
        exit 0
    fi
    
    if [ "$HAS_ISSUE" = "true" ]; then
        echo "⚠ Issue already exists for $TICKET_ID: #$ISSUE_NUMBER"
        read -p "Create anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipped"
            exit 0
        fi
    fi
    
    echo "Creating issue for $TICKET_ID..."
    bash "$SCRIPT_DIR/create-github-issue.sh" "$TICKET_ID"
    
else
    # Mode 2: Bulk processing
    echo "Mode: Bulk processing"
    echo ""
    
    TICKETS_NEEDING_ISSUES=$(echo "$STATE_JSON" | jq -r '.sprint_tickets[] | select(.needs_issue == true) | .ticket_id')
    NEED_COUNT=$(echo "$TICKETS_NEEDING_ISSUES" | grep -c . || echo "0")
    
    if [ "$NEED_COUNT" -eq 0 ]; then
        echo "✓ All tickets with plans either have issues or closed PRs"
        exit 0
    fi
    
    echo "Found $NEED_COUNT tickets that need issues:"
    echo "$TICKETS_NEEDING_ISSUES"
    echo ""
    
    read -p "Create issues for all $NEED_COUNT tickets? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    
    echo ""
    echo "Creating issues..."
    echo "================================"
    
    COUNT=0
    SUCCESS=0
    FAILED=0
    
    while IFS= read -r ticket_id; do
        if [ -n "$ticket_id" ]; then
            COUNT=$((COUNT + 1))
            echo ""
            echo "[$COUNT/$NEED_COUNT] Processing: $ticket_id"
            
            if bash "$SCRIPT_DIR/create-github-issue.sh" "$ticket_id" 2>&1; then
                SUCCESS=$((SUCCESS + 1))
                echo "  ✓ Created"
            else
                FAILED=$((FAILED + 1))
                echo "  ✗ Failed"
            fi
            
            if [ $COUNT -lt $NEED_COUNT ]; then
                sleep 2
            fi
        fi
    done <<< "$TICKETS_NEEDING_ISSUES"
    
    echo ""
    echo "================================"
    echo "Summary:"
    echo "  Total: $COUNT"
    echo "  Success: $SUCCESS"
    echo "  Failed: $FAILED"
    echo "================================"
fi
