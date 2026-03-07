# Create GitHub Issue

Create a GitHub issue from a sprint ticket ID.

## Usage

```
@create-github-issue TICKET-ID
```

## Purpose

This command creates a GitHub issue for a specific sprint ticket by:
1. Looking up the ticket in the sprint plan
2. Finding the associated plan file
3. Extracting metadata and deliverables
4. Creating a GitHub issue via `gh` CLI

## Examples

```bash
# Create issue for single ticket
@create-github-issue PROTO-001

# Create issues for all tickets with plans
@create-github-issue --all
```

## What It Does

### Sprint Epic Management

The scripts automatically manage a sprint epic issue:
1. Checks if a sprint epic exists for the sprint plan (by label)
2. If not found, creates an epic issue with:
   - Title: `Epic: Sprint 1 Modernization`
   - Labels: `sprint-epic`, `sprint-1-modernization`
   - Body: Sprint overview, duration, goal, link to sprint plan
3. Returns the epic issue number for linking

### Single Ticket Mode

1. Gets or creates the sprint epic issue
2. Looks up ticket ID in sprint plan table
3. Finds plan file slug from "Plan" column
4. Reads plan file frontmatter and content
5. Extracts:
   - Overview/description
   - Deliverables
   - Tasks (from frontmatter todos)
6. Creates GitHub issue with:
   - Title: `[TICKET-ID] Description` (max 256 chars)
   - Body: Links to sprint epic (#N), plan file, description, deliverables, definition of done
   - Labels: `cursor-plan`, `ticket`, and ticket type (`proto`, `api`, `test`, `obs`, or `doc`)
   - Assignee: Current user

### Bulk Mode (`--all`)

Processes all tickets in the sprint plan that have plan files (excludes "TBD"):
- Filters to only tickets with actual plan files
- Skips tickets marked as "TBD" in the Plan column
- Creates issue for each valid ticket
- Includes 2-second rate limit between API calls
- Reports success/failure summary

## Prerequisites

### GitHub CLI Authentication

```bash
# Install gh CLI
brew install gh

# Authenticate
gh auth login
```

### Required Permissions

Your GitHub token needs:
- `repo` scope (create issues)

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| Ticket not found | Ticket ID doesn't exist in sprint plan | Check ticket ID spelling |
| Invalid ticket format | Ticket doesn't match expected pattern | Use format: PROTO-XXX, API-XXX, TEST-XXX, OBS-XXX, or DOC-XXX |
| Plan file TBD | Plan file hasn't been created yet | Create plan file first |
| Plan file not found | File path incorrect or missing | Verify `.cursor/plans/` directory |
| gh auth required | Not authenticated with GitHub | Run `gh auth login` |
| Title too long | Description exceeds 256 chars | Title auto-truncates to fit |

## Implementation

The command runs: `.cursor/scripts/create-github-issue.sh`

### Script Behavior

1. **Validation**: Checks ticket ID format (must be PROTO-XXX, API-XXX, TEST-XXX, OBS-XXX, or DOC-XXX)
2. **Label Extraction**: Extracts ticket type prefix for labeling
3. **Lookup**: Parses sprint plan table to find plan file slug
4. **Validation**: Checks plan file exists
5. **Extraction**: Parses frontmatter YAML and markdown sections
6. **Title Formatting**: Ensures title fits within GitHub's 256 char limit
7. **Issue Creation**: Uses `gh issue create` with structured body and type-specific labels

### Title Length Handling

GitHub issue titles have a 256 character limit. The script:
1. Builds title as `[TICKET-ID] Description`
2. Checks total length
3. If over 256 chars, truncates description to fit
4. Preserves ticket ID in all cases

Example:
```
# Original (300 chars)
[PROTO-001] This is a very long description that exceeds the maximum allowed character limit for GitHub issue titles and needs to be truncated to fit within the 256 character constraint while preserving the ticket identifier

# Truncated (256 chars)
[PROTO-001] This is a very long description that exceeds the maximum allowed character limit for GitHub issue titles and needs to be truncated to fit within the 256 character constraint while preserving...
```

## File References

The issue body uses GitHub blob URLs that link directly to the files:
- Sprint plan: `https://github.com/jxtngx/ib-interface/blob/main/.cursor/plans/sprint_1_modernization_e041af8d.plan.md`
- Plan file: `https://github.com/jxtngx/ib-interface/blob/main/.cursor/plans/proto-001_module_structure_fac33c9f.plan.md`

These URLs allow direct navigation from the GitHub issue to the source files.

## Output

```
Finding sprint epic issue...
Sprint epic: #42

Creating GitHub issue for ticket: PROTO-001
Plan file: .cursor/plans/proto-001_module_structure_fac33c9f.plan.md

✓ GitHub issue created successfully
✓ Ticket ID: PROTO-001
```

## Bulk Mode Output

```
Creating GitHub issues for all sprint tickets...

Found 29 tickets with plan files

[1] Processing: PROTO-001
  ✓ Created

[2] Processing: PROTO-002
  ✓ Created

[3] Processing: PROTO-003
  ✗ Failed

================================
Summary:
  Total: 29
  Success: 28
  Failed: 1
================================
```

## Related Scripts

- `.cursor/scripts/create-github-issue.sh` - Single ticket creation
- `.cursor/scripts/get-sprint-issue.sh` - Get or create sprint epic
- `.cursor/scripts/bulk-create-issues.sh` - All tickets creation

## Integration

This command integrates with:
- Sprint plan table (ticket to plan file mapping)
- Plan file frontmatter (metadata)
- GitHub Issues API (via `gh` CLI)
- GitHub issue linking (Part of #N)
- Sprint epic management (automatic creation)
- Cursor plan template (`.github/ISSUE_TEMPLATE/cursor_plan.yml`)

### Sprint Epic Structure

```
Epic: Sprint 1 Modernization (#42)
├── [PROTO-001] Create protobuf module structure (#43)
├── [PROTO-002] Implement ProtobufCodec.encode() (#44)
├── [API-001] Update MaxClientVersion to 222 (#45)
└── ... (all sprint tickets)
```

Each ticket issue body starts with `Part of #42` which creates a link in GitHub's issue relationships.
