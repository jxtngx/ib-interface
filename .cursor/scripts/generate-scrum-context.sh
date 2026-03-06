#!/bin/bash
# Generate scrum-context.md from standardized git commands
# Usage: .cursor/scripts/generate-scrum-context.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_FILE="$PROJECT_ROOT/.cursor/plans/scrum-context.md"
SPRINT_PLAN="$PROJECT_ROOT/.cursor/plans/sprint_1_modernization_e041af8d.plan.md"

cd "$PROJECT_ROOT"

echo "Generating scrum context..."

# Capture git state
CURRENT_BRANCH=$(git branch --show-current)
GIT_STATUS=$(git status --porcelain)
if [ -z "$GIT_STATUS" ]; then
    STATUS_TEXT="clean"
else
    STATUS_TEXT="uncommitted changes"
fi

# Capture completed tickets
COMPLETED_TICKETS=$(git log --all --oneline --grep='\[PROTO-' --grep='\[API-' --grep='\[TEST-' --grep='\[OBS-' --grep='\[DOC-' -n 50 2>/dev/null | cat)
if [ -n "$COMPLETED_TICKETS" ]; then
    COMPLETED_COUNT=$(echo "$COMPLETED_TICKETS" | wc -l | tr -d ' ')
else
    COMPLETED_COUNT="0"
fi

# Capture recent commits
RECENT_COMMITS=$(git log --all --oneline -n 20)

# Capture branches
ALL_BRANCHES=$(git branch -a)

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Parse sprint plan if exists
SPRINT_NAME="Unknown"
TOTAL_TICKETS="Unknown"
CURRENT_PHASE="Unknown"

if [ -f "$SPRINT_PLAN" ]; then
    SPRINT_NAME=$(grep '^name:' "$SPRINT_PLAN" | sed 's/name: *//' || echo "Unknown")
    TOTAL_TICKETS=$(grep -E '^\| (PROTO|API|TEST|OBS|DOC)-[0-9]+' "$SPRINT_PLAN" | wc -l | tr -d ' ')
    CURRENT_PHASE="Week 1 - Protocol Foundation"
fi

# Calculate completion percentage
if [ "$TOTAL_TICKETS" != "Unknown" ] && [ "$TOTAL_TICKETS" -gt 0 ] && [ "$COMPLETED_COUNT" -gt 0 ]; then
    COMPLETION_PCT=$((COMPLETED_COUNT * 100 / TOTAL_TICKETS))
else
    COMPLETION_PCT="0"
fi

# Write scrum-context.md
cat > "$OUTPUT_FILE" << EOF
# Scrum Context

Generated: $TIMESTAMP

## Current Git State

**Branch**: $CURRENT_BRANCH
**Status**: $STATUS_TEXT

## Completed Tickets

EOF

if [ -n "$COMPLETED_TICKETS" ]; then
    echo "$COMPLETED_TICKETS" >> "$OUTPUT_FILE"
else
    echo "No completed tickets found." >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" << EOF

## Recent Commits (Last 20)

$RECENT_COMMITS

## Available Branches

$ALL_BRANCHES

## Sprint Summary

Sprint: $SPRINT_NAME
Total Tickets: $TOTAL_TICKETS
Current Phase: $CURRENT_PHASE
Completed: $COMPLETED_COUNT/$TOTAL_TICKETS ($COMPLETION_PCT%)

---

## Usage for Agents

This file provides standardized git context for sprint planning decisions:

- **Scrum Master**: Use "Completed Tickets" to assess velocity and identify next tickets
- **Chief Quant Architect**: Use "Recent Commits" to understand technical context
- Both agents should verify dependencies using the "Completed Tickets" section

This file is regenerated on each run of the run-ticket-plan command.
EOF

echo "✓ Scrum context written to: $OUTPUT_FILE"
echo "✓ Current branch: $CURRENT_BRANCH"
echo "✓ Status: $STATUS_TEXT"
echo "✓ Completed tickets: $COMPLETED_COUNT"
echo "✓ Total tickets: $TOTAL_TICKETS ($COMPLETION_PCT% complete)"
