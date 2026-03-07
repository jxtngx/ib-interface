# Run Ticket Plan

Select the next available ticket, validate dependencies, create feature branch, and direct the user to the ticket's plan file for implementation.

## Usage

```
@run-ticket-plan
```

No ticket ID required - the command automatically determines the next ticket to work on.

## Purpose

This command does NOT implement code. It:
1. Selects the optimal next ticket using agent consultation
2. Validates git state and dependencies
3. Creates the feature branch
4. Directs you to the ticket plan file to begin implementation

**You implement from the ticket plan file directly.**

## Workflow

```mermaid
graph TD
    A[Invoke Command] --> A1[Run generate-scrum-context.sh]
    A1 --> B[Consult Agents]
    B --> C[Select Next Ticket]
    C --> D[Validate Git State]
    D --> E[Check Dependencies]
    E --> F[Check GitHub Issue]
    F --> G{Issue exists?}
    G -->|No| H[Create GitHub Issue]
    G -->|Yes| I[Use Existing Issue]
    H --> J[Create Feature Branch]
    I --> J
    J --> K[Display Plan Path + Issue]
    K --> L[User Implements]
    
    A1 --> A2[Execute Git Commands]
    A2 --> A3[Parse Sprint Plan]
    A3 --> A4[Format Markdown]
    A4 --> A5[Write scrum-context.md]
    
    B --> B1[Scrum Master]
    B --> B2[Chief Quant Architect]
    B1 --> B3[Read scrum-context.md]
    B2 --> B4[Read scrum-context.md]
    B3 --> C
    B4 --> C
    
    D --> D1{On main?}
    D1 -->|No| D2[Fail: Switch to main]
    D1 -->|Yes| D3{Clean state?}
    D3 -->|No| D4[Fail: Commit changes]
    D3 -->|Yes| E
    
    E --> E1[Load Sprint Plan]
    E1 --> E2[Extract Dependencies]
    E2 --> E3[Load Ticket Plan]
    E3 --> E4[Check Each Dependency]
    E4 --> E5{All merged?}
    E5 -->|No| E6[Fail: List pending PRs]
    E5 -->|Yes| F
```

## Steps

### 0. Ticket Selection (Automated)

Consult agents to determine next ticket:

**Scrum Master Assessment** (`.cursor/agents/scrum-master.md`):
- Review sprint plan progress
- Identify completed tickets from git history
- Calculate sprint velocity and capacity
- Filter to tickets with satisfied dependencies
- Prioritize by phase and critical path

**Chief Quant Architect Assessment** (`.cursor/agents/chief-quant-architect.md`):
- Evaluate technical readiness
- Check for architectural blockers
- Verify prerequisite knowledge available
- Assess risk and complexity
- Recommend optimal ticket for current context

**Selection Criteria**:
1. All dependencies merged to main
2. Highest priority in current phase
3. Matches team member specialization (if agent context available)
4. Technically ready (no architectural blockers)
5. Fits within remaining sprint capacity

**Output**: Selected ticket ID (e.g., `PROTO-002`)

### 1. Git State Validation

Verify repository state before starting work:

- Current branch is `main`
- Working directory is clean
- Local main is up to date with remote

### 2. Dependency Resolution

Check ticket dependencies are satisfied:

- Parse sprint plan table for ticket's "Depends On" column
- Parse ticket plan file for dependency mentions
- Verify each dependency ticket has merged PR in git history
- Report any unmerged dependencies with commit search

### 3. Create GitHub Issue

Before creating the feature branch, ensure a GitHub issue exists for tracking:

1. Check if issue already exists for ticket ID
2. If no issue exists:
   - Extract metadata from ticket plan file
   - Create issue using `create-github-issue.sh`
   - Link issue to sprint epic automatically
   - Add ticket-type label (proto, api, test, obs, doc)
3. Display issue number and URL
4. Issue number will be available for PR linking

**Script**: `.cursor/scripts/create-github-issue.sh <TICKET-ID>`
**Check**: `.cursor/scripts/fetch-github-state.sh <TICKET-ID>`

**Error Handling**: If GitHub issue creation fails, warn but continue with branch creation (fail-soft approach to not block development).

### 4. Branch Creation

Create feature branch following convention:

- Pattern: `<type>/TICKET-ID-short-description`
- Type matches GitHub labels: `proto`, `api`, `obs`, `documentation`, `test`
- Example: `proto/PROTO-002-codec-encode`
- Example: `api/API-001-version-update`
- Branch from current main

### 5. Display Plan Path and Issue

### 5. Display Plan Path and Issue

Provide clear instruction to user:

- Display full path to ticket plan file
- Display GitHub issue number and URL
- Highlight the plan file for the user to reference
- Summarize key deliverables from plan
- Remind user to link issue when creating PR (e.g., `Closes #42`)
- Confirm branch is ready for work

**The user implements from the plan file - the command does NOT auto-implement.**

## Pre-flight Checks

Before executing, validate:

| Check | Command | Expected |
|-------|---------|----------|
| Sprint plan exists | Read `.cursor/plans/sprint_*.plan.md` | File found |
| Agents available | Read `.cursor/agents/scrum-master.md` | File found |
| Agents available | Read `.cursor/agents/chief-quant-architect.md` | File found |
| Script exists | Check `.cursor/scripts/generate-scrum-context.sh` | File found and executable |
| Generate context | Run `.cursor/scripts/generate-scrum-context.sh` | Write `.cursor/plans/scrum-context.md` |
| Current branch | From scrum-context.md | `main` |
| Clean state | From scrum-context.md | `clean` status |
| Up to date | `git fetch && git status` | No "behind" message |
| Dependencies | From scrum-context.md completed tickets | Commit exists for each |

### Script: generate-scrum-context.sh

Location: `.cursor/scripts/generate-scrum-context.sh`

This bash script standardizes all git operations and ensures consistent output format.

**What it does**:
1. Runs all required git commands
2. Captures output into shell variables
3. Parses sprint plan metadata
4. Formats into markdown
5. Writes to `.cursor/plans/scrum-context.md`
6. Reports status to stdout

**Why a script**:
- Enforces consistency across runs
- Eliminates ad-hoc git commands
- Centralizes git query logic
- Makes debugging easier
- Ensures agents always get same format

## Ticket Selection Process

### Step 1: Generate scrum-context.md using script

**CRITICAL**: Run the standardized script to generate `.cursor/plans/scrum-context.md`

Execute the script:

```bash
.cursor/scripts/generate-scrum-context.sh
```

This script is located at `.cursor/scripts/generate-scrum-context.sh` and:

1. Runs all standardized git commands
2. Captures output into variables
3. Parses sprint plan for metadata
4. Writes formatted `.cursor/plans/scrum-context.md`
5. Reports completion status

**Script Operations**:

- Current branch: `git branch --show-current`
- Working status: `git status --porcelain`
- Completed tickets: Parse frontmatter `status: completed` tasks from sprint plan
- Pending tickets: Parse frontmatter `status: pending` tasks from sprint plan
- Recent commits: `git log --all --oneline -n 20`
- All branches: `git branch -a`
- Sprint metadata: parsed from sprint plan frontmatter and tables

**Note**: The script prioritizes frontmatter tasks as the source of truth for completion tracking. If no frontmatter tasks exist, it falls back to git log grep for legacy support.

**Generated File Structure**:

The script writes `.cursor/plans/scrum-context.md` with sections:
- Current Git State (branch, status)
- Ticket Status Summary (total, completed, pending, percentage)
- Completed Tickets (from sprint plan frontmatter)
- Pending Tickets (from sprint plan frontmatter, top 20)
- Recent Commits (last 20 for technical context)
- Available Branches (all branches)
- Sprint Metadata (name, total, completed, percentage)
- Usage for Agents (instructions and source of truth guidance)

### Step 2: Consult Scrum Master

Invoke scrum-master agent with context:
- `.cursor/plans/scrum-context.md` (standardized git state)
- Sprint plan file path

Ask scrum-master to:
1. Review completed tickets from scrum-context.md
2. Identify tickets ready to start (dependencies satisfied)
3. Prioritize by sprint goals and critical path
4. Consider sprint velocity and capacity
5. Return top 3 candidate tickets

### Step 3: Consult Chief Quant Architect

Invoke chief-quant-architect agent with:
- `.cursor/plans/scrum-context.md` (standardized git state)
- Top 3 candidate tickets from scrum-master
- Current codebase state

Ask chief-quant-architect to:
1. Review recent changes from scrum-context.md
2. Assess technical readiness for each candidate
3. Identify any architectural blockers
4. Recommend single ticket to work on next
5. Provide technical context for implementation

### Step 4: Final Selection

Select the ticket recommended by chief-quant-architect and proceed with validation and branch creation.

## Dependency Validation

For ticket with dependencies `PROTO-002, PROTO-003`:

1. Read completed tickets from `.cursor/plans/scrum-context.md`
2. Verify each dependency ticket appears in "Completed Tickets (from Sprint Plan)" section
3. Cross-reference with git commits for technical validation
4. Check commit exists on main branch (not on abandoned branch)
5. Repeat for each dependency

If dependency missing:

- Report unmerged dependency ticket
- Show status from sprint plan frontmatter (completed vs pending)
- List expected commit message pattern: `[TICKET-ID]`
- Show completed tickets from scrum-context.md
- Block execution until dependencies satisfied

**Note**: The sprint plan frontmatter tasks (`status: completed`) are the primary source of truth. Git commits provide technical validation that the work was actually merged.

## Branch Naming

Extract short description from ticket plan file and derive type from ticket ID:

- Read plan name field
- Convert to kebab-case
- Extract type from ticket ID prefix (PROTO → proto, API → api, TEST → test, OBS → obs, DOC → documentation)
- Limit to 50 chars total
- Format: `<type>/TICKET-ID-description`

Examples:

- `proto/PROTO-002-codec-encode`
- `api/API-001-version-update`
- `obs/OBS-003-protocol-logging`
- `documentation/DOC-001-readme-update`
- `test/TEST-005-integration-tests`

## Error Handling

| Error | Message | Resolution |
|-------|---------|------------|
| Sprint plan not found | `No sprint plan found in .cursor/plans/. Create sprint plan first.` | Create sprint plan file |
| Agent not found | `Agent {name} not found at {path}. Check agent files.` | Verify agent file exists |
| No available tickets | `No tickets ready to start. All available tickets have unmet dependencies.` | Complete dependency tickets first |
| Not on main | `Current branch is {branch}. Switch to main first.` | `git checkout main` |
| Dirty working tree | `Uncommitted changes detected. Commit or stash.` | `git status` |
| Missing dependency | `Dependency {TICKET} not merged. Required PRs: {list}` | Wait for PR merge |
| Plan file not found | `No plan file for {TICKET}. Create plan first.` | Create plan file |
| Branch exists | `Branch feature/{TICKET} exists. Delete or reuse?` | `git branch -D feature/{TICKET}` |
| Agent disagreement | `Scrum master and architect disagree on ticket priority. Manual selection required.` | Provide ticket ID manually |

## Implementation Flow

After successful ticket selection and validation:

1. Display selected ticket ID and rationale
2. Show agent recommendations and context
3. Create feature branch
4. Display ticket plan file path
5. Summarize key deliverables
6. User implements by referencing the plan file directly

**IMPORTANT**: This command only prepares the environment. The user always implements from the ticket plan file (e.g., `@.cursor/plans/proto-001_module_structure_fac33c9f.plan.md`).

## Agent Coordination

```mermaid
sequenceDiagram
    participant C as Command
    participant SC as scrum-context.md
    participant SM as Scrum Master
    participant CQA as Chief Architect
    participant G as Git
    
    C->>G: Run Standard Git Commands
    G-->>C: Output
    C->>SC: Write scrum-context.md
    C->>C: Load Sprint Plan
    C->>SM: Assess Sprint Status
    Note over SM: Reads scrum-context.md
    SM-->>C: Top 3 Candidates
    C->>CQA: Evaluate Technical Readiness
    Note over CQA: Reads scrum-context.md
    CQA-->>C: Recommended Ticket + Context
    C->>C: Validate Dependencies
    C->>G: Create Feature Branch
    C->>C: Display Plan
```

## Scrum Context File

The command generates `.cursor/plans/scrum-context.md` by running git commands and capturing their output.

### Implementation Steps

1. Run each standard git command
2. Capture the output
3. Format into markdown sections
4. Write to `.cursor/plans/scrum-context.md`

### Example Generated File

```markdown
# Scrum Context

Generated: 2026-03-06 14:30:00

## Current Git State

**Branch**: main
**Status**: clean

## Ticket Status Summary

Total Tickets: 63
Completed: 5
Pending: 58
Completion: 7.9%

## Completed Tickets (from Sprint Plan)

PROTO-001 - Create protobuf module structure
PROTO-002 - Implement ProtobufCodec.encode()
PROTO-003 - Implement ProtobufCodec.decode()
PROTO-004 - Implement ProtobufCodec.is_protobuf_message()
PROTO-005 - Setup ibapi local installation and imports

## Pending Tickets (from Sprint Plan)

PROTO-006 - Create ProtobufConverter class skeleton
PROTO-007 - Implement order_from_proto()
PROTO-008 - Implement order_to_proto()
PROTO-009 - Implement contract_from_proto()
PROTO-010 - Implement bar_data_from_proto()
API-001 - Update MaxClientVersion to 222
API-002 - Add Order regulatory attributes
... and 48 more pending tickets

## Recent Commits (Last 20)

abc1234 [PROTO-001] Create protobuf module structure
def5678 [PROTO-002] Implement ProtobufCodec.encode()
ghi9012 [PROTO-003] Implement ProtobufCodec.decode()
jkl3456 [PROTO-004] Implement ProtobufCodec.is_protobuf_message()
mno7890 [PROTO-005] Copy protobuf message files
...

## Available Branches

* main
  remotes/origin/main
  remotes/origin/feature/PROTO-006-converter-skeleton

## Sprint Metadata

Sprint: Sprint 1 Modernization
Total Tickets: 63
Current Phase: Week 1 - Protocol Foundation
Completed: 5/63 (7.9%)

---

## Usage for Agents

This file provides standardized context for sprint planning decisions:

- **Completed Tickets**: Parsed from sprint plan frontmatter `status: completed` tasks
- **Pending Tickets**: Parsed from sprint plan frontmatter `status: pending` tasks
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
```

This file provides consistent input for agent decision-making and is regenerated on every run. The frontmatter tasks in the sprint plan are the single source of truth for ticket completion status.

## Example Output

```
[GENERATING SCRUM CONTEXT]
Running: .cursor/scripts/generate-scrum-context.sh

Generating scrum context...
✓ Scrum context written to: .cursor/plans/scrum-context.md
✓ Current branch: main
✓ Status: clean
✓ Completed tickets: 3
✓ Total tickets: 56 (5% complete)

Context file generated successfully

[CONSULTING AGENTS]
Reading scrum-context.md for sprint status...

[TICKET SELECTION]
Scrum Master recommends: PROTO-002, PROTO-003, API-001
  - PROTO-002: Highest priority, critical path
  - PROTO-003: Parallel work opportunity
  - API-001: Independent, can start anytime

Chief Quant Architect recommends: PROTO-002
  - Technical readiness: HIGH
  - Dependencies satisfied: PROTO-001 merged in commit abc123
  - Context: Codec module structure ready, encode logic straightforward
  - Risk: LOW - isolated to codec.py

[SELECTED TICKET]
PROTO-002: Implement ProtobufCodec.encode()

[GIT VALIDATION]
✓ On main branch
✓ Working directory clean
✓ Up to date with origin/main
✓ Dependency PROTO-001 merged

[GITHUB ISSUE]
Checking for existing issue...
✓ No issue found for PROTO-002
Finding sprint epic issue...
Sprint epic: #1
Creating GitHub issue for ticket: PROTO-002
Plan file: .cursor/plans/proto-002_codec_encode_614da315.plan.md

✓ GitHub issue created successfully
✓ Ticket ID: PROTO-002
✓ Issue #42: https://github.com/jxtngx/ib-interface/issues/42

[BRANCH CREATION]
Creating branch: feature/PROTO-002-codec-encode
Branch created successfully

[READY FOR IMPLEMENTATION]
Plan file: @.cursor/plans/proto-002_codec_encode_614da315.plan.md
GitHub Issue: #42 (https://github.com/jxtngx/ib-interface/issues/42)

Use the plan file above to implement this ticket.

Key deliverables:
- Implement ProtobufCodec.encode() method
- Add type hints and docstrings
- Handle encoding errors gracefully

When creating your PR, link to issue #42 using "Closes #42" in the PR description.

The feature branch is ready. Begin implementation from the plan file.
```
