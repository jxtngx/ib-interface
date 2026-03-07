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

# Parse frontmatter tasks from sprint plan for completion tracking
COMPLETED_TASKS=""
PENDING_TASKS=""
COMPLETED_COUNT="0"
PENDING_COUNT="0"

if [ -f "$SPRINT_PLAN" ]; then
    # Extract frontmatter todos section (between 'todos:' and next top-level key)
    FRONTMATTER_TODOS=$(awk '/^todos:/,/^[a-z_]+:/ {
        if ($0 !~ /^[a-z_]+:/ || $0 ~ /^todos:/) print
    }' "$SPRINT_PLAN")
    
    # Parse completed tasks
    COMPLETED_TASKS=$(echo "$FRONTMATTER_TODOS" | awk '
        /content:/ { content=$0; sub(/.*content: */, "", content); getline; 
        if ($0 ~ /status: *completed/) print content }
    ')
    
    # Parse pending tasks
    PENDING_TASKS=$(echo "$FRONTMATTER_TODOS" | awk '
        /content:/ { content=$0; sub(/.*content: */, "", content); getline; 
        if ($0 ~ /status: *pending/) print content }
    ')
    
    # Count tasks (grep for ticket patterns)
    if [ -n "$COMPLETED_TASKS" ]; then
        COMPLETED_COUNT=$(echo "$COMPLETED_TASKS" | grep -c 'PROTO\|API\|TEST\|OBS\|DOC' || echo "0")
    fi
    
    if [ -n "$PENDING_TASKS" ]; then
        PENDING_COUNT=$(echo "$PENDING_TASKS" | grep -c 'PROTO\|API\|TEST\|OBS\|DOC' || echo "0")
    fi
fi

# Fallback: If no frontmatter tasks found, use git log (legacy)
if [ "$COMPLETED_COUNT" -eq 0 ]; then
    GIT_COMPLETED=$(git log --all --oneline --grep='\[PROTO-' --grep='\[API-' --grep='\[TEST-' --grep='\[OBS-' --grep='\[DOC-' -n 50 2>/dev/null | cat)
    if [ -n "$GIT_COMPLETED" ]; then
        COMPLETED_COUNT=$(echo "$GIT_COMPLETED" | wc -l | tr -d ' ')
    fi
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
if [ "$TOTAL_TICKETS" != "Unknown" ] && [ "$TOTAL_TICKETS" -gt 0 ]; then
    if [ "$COMPLETED_COUNT" -gt 0 ]; then
        COMPLETION_PCT=$((COMPLETED_COUNT * 100 / TOTAL_TICKETS))
    else
        COMPLETION_PCT="0"
    fi
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

## Ticket Status Summary

Total Tickets: $TOTAL_TICKETS
Completed: $COMPLETED_COUNT
Pending: $PENDING_COUNT
Completion: $COMPLETION_PCT%

## Completed Tickets (from Sprint Plan)

EOF

if [ -n "$COMPLETED_TASKS" ] && [ "$COMPLETED_COUNT" -gt 0 ]; then
    echo "$COMPLETED_TASKS" >> "$OUTPUT_FILE"
else
    echo "No completed tickets found in sprint plan frontmatter." >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" << EOF

## Pending Tickets (from Sprint Plan)

EOF

if [ -n "$PENDING_TASKS" ] && [ "$PENDING_COUNT" -gt 0 ]; then
    echo "$PENDING_TASKS" | head -20 >> "$OUTPUT_FILE"
    if [ "$PENDING_COUNT" -gt 20 ]; then
        echo "... and $((PENDING_COUNT - 20)) more pending tickets" >> "$OUTPUT_FILE"
    fi
else
    echo "No pending tickets found in sprint plan frontmatter." >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" << EOF

## Recent Commits (Last 20)

$RECENT_COMMITS

## Available Branches

$ALL_BRANCHES

## Sprint Metadata

Sprint: $SPRINT_NAME
Total Tickets: $TOTAL_TICKETS
Current Phase: $CURRENT_PHASE
Completed: $COMPLETED_COUNT/$TOTAL_TICKETS ($COMPLETION_PCT%)

---

## Usage for Agents

This file provides standardized context for sprint planning decisions:

- **Completed Tickets**: Parsed from sprint plan frontmatter \`status: completed\` tasks
- **Pending Tickets**: Parsed from sprint plan frontmatter \`status: pending\` tasks
- **Recent Commits**: Git history for technical context
- **Available Branches**: Current branch state

### For Scrum Master

Use "Completed Tickets" and "Pending Tickets" sections to:
- Assess velocity and progress
- Identify next tickets based on dependencies
- Verify prerequisite tickets are completed

### For Chief Quant Architect

Use "Recent Commits" and "Available Branches" to:
- Understand technical context
- Verify dependency implementation details
- Cross-reference frontmatter status with git history

**Note**: Sprint plan frontmatter is the single source of truth for ticket status.
Git commits provide technical validation and context only.

This file is regenerated on each run of the run-ticket-plan command.
EOF

echo "✓ Scrum context written to: $OUTPUT_FILE"
echo "✓ Current branch: $CURRENT_BRANCH"
echo "✓ Status: $STATUS_TEXT"
echo "✓ Completed tickets: $COMPLETED_COUNT"
echo "✓ Pending tickets: $PENDING_COUNT"
echo "✓ Total tickets: $TOTAL_TICKETS ($COMPLETION_PCT% complete)"
