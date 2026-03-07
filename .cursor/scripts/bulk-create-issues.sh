#!/bin/bash
# Create GitHub issues for all sprint tickets
# Usage: .cursor/scripts/bulk-create-issues.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPRINT_PLAN="$PROJECT_ROOT/.cursor/plans/sprint_1_modernization_e041af8d.plan.md"

cd "$PROJECT_ROOT"

echo "Creating GitHub issues for all sprint tickets..."
echo ""

# Extract all ticket IDs with plan files (not TBD) from sprint plan
TICKET_IDS=$(grep -E '^\| (PROTO|API|TEST|OBS|DOC)-[0-9]+' "$SPRINT_PLAN" | \
    awk -F'|' '{ 
        ticket=$2; 
        plan=$6; 
        gsub(/^ *| *$/, "", ticket); 
        gsub(/^ *| *$/, "", plan); 
        if (plan != "TBD" && plan != "Plan" && plan != "") 
            print ticket 
    }')

if [ -z "$TICKET_IDS" ]; then
    echo "No tickets with plan files found in sprint plan"
    exit 1
fi

echo "Found $(echo "$TICKET_IDS" | wc -l | tr -d ' ') tickets with plan files"
echo ""

COUNT=0
SUCCESS=0
FAILED=0

while IFS= read -r ticket_id; do
    if [ -n "$ticket_id" ]; then
        COUNT=$((COUNT + 1))
        echo "[$COUNT] Processing: $ticket_id"
        
        if bash "$SCRIPT_DIR/create-github-issue.sh" "$ticket_id" 2>&1; then
            SUCCESS=$((SUCCESS + 1))
            echo "  ✓ Created"
        else
            FAILED=$((FAILED + 1))
            echo "  ✗ Failed"
        fi
        
        # Rate limit: wait 2 seconds between API calls
        sleep 2
        echo ""
    fi
done <<< "$TICKET_IDS"

echo "================================"
echo "Summary:"
echo "  Total: $COUNT"
echo "  Success: $SUCCESS"
echo "  Failed: $FAILED"
echo "================================"
