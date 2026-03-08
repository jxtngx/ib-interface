# Agent Tools Reference

This document lists all tools available to the AI agent in Cursor. Use these when writing custom commands, rules, or instructions.

## File Operations

### Read
Reads file contents from the filesystem.

```markdown
Read: path/to/file.py
```

Parameters:
- `path` (required): Absolute or relative file path
- `offset` (optional): Line number to start reading from
- `limit` (optional): Number of lines to read

### Write
Creates or overwrites a file.

```markdown
Write new file: path/to/file.py
```

Parameters:
- `path` (required): File path
- `contents` (required): File contents

### StrReplace
Performs exact string replacements in files.

```markdown
Replace text in: path/to/file.py
```

Parameters:
- `path` (required): File path
- `old_string` (required): Text to replace
- `new_string` (required): Replacement text
- `replace_all` (optional): Replace all occurrences (default: false)

### Delete
Deletes a file.

```markdown
Delete: path/to/file.py
```

Parameters:
- `path` (required): File path

### EditNotebook
Edits Jupyter notebook cells.

Parameters:
- `target_notebook` (required): Notebook path
- `cell_idx` (required): Cell index (0-based)
- `is_new_cell` (required): Create new cell vs edit existing
- `cell_language` (required): python, markdown, etc.
- `old_string` (required): Text to replace
- `new_string` (required): Replacement text

## Search & Navigation

### Grep
Search file contents using regex patterns.

```markdown
Search for pattern "function.*Order" in *.py files
```

Parameters:
- `pattern` (required): Regex pattern
- `path` (optional): Directory or file to search
- `glob` (optional): File pattern filter (e.g., "*.js")
- `type` (optional): File type (js, py, rust, etc.)
- `output_mode` (optional): content, files_with_matches, count
- `-i` (optional): Case insensitive
- `-A`, `-B`, `-C` (optional): Context lines

### Glob
Find files by name pattern.

```markdown
Find all .plan.md files
```

Parameters:
- `glob_pattern` (required): Pattern like "*.js" or "**/*.plan.md"
- `target_directory` (optional): Directory to search

### SemanticSearch
Search code by meaning/concept.

```markdown
Find where user authentication is handled
```

Parameters:
- `query` (required): Natural language question
- `target_directories` (required): Array of directories to search (empty for all)
- `num_results` (optional): Number of results (default: 15)

## Execution

### Shell
Run bash commands in terminal.

```markdown
Run: git status
```

Parameters:
- `command` (required): Shell command to execute
- `description` (optional): Human-readable description
- `working_directory` (optional): Directory to run command in
- `block_until_ms` (optional): How long to wait before backgrounding (default: 30000)

Notes:
- Use specialized tools (Read, Write, Grep) instead of cat, sed, grep commands
- Chain sequential commands with `&&`
- Commands run in stateful shell (cwd persists)

## Code Quality

### ReadLints
Check linter errors and diagnostics.

```markdown
Check lints for: src/api/
```

Parameters:
- `paths` (optional): Array of file/directory paths to check

## User Interaction

### AskQuestion
Present multiple-choice questions to user.

```markdown
Ask user: "Which ticket did you complete?"
Options: ["PROTO-007", "PROTO-008", "Other"]
```

Parameters:
- `questions` (required): Array of question objects
  - `id`: Question identifier
  - `prompt`: Question text
  - `options`: Array of {id, label} objects
  - `allow_multiple`: Allow multiple selections (default: false)
- `title` (optional): Form title

### TodoWrite
Create and manage task lists.

```markdown
Create todos for implementation steps
```

Parameters:
- `todos` (required): Array of todo items
  - `id`: Unique identifier
  - `content`: Task description
  - `status`: pending, in_progress, completed, cancelled
- `merge` (required): Merge with existing (true) or replace (false)

## Delegation

### Task
Launch subagents for complex tasks.

```markdown
Launch explore subagent to find authentication code
```

Parameters:
- `prompt` (required): Task description
- `description` (required): Short 3-5 word summary
- `subagent_type` (required): generalPurpose, explore, shell, browser-use
- `model` (optional): fast (for simple tasks)
- `readonly` (optional): Run in readonly mode
- `run_in_background` (optional): Background execution

Subagent types:
- `generalPurpose`: Research, search, multi-step tasks
- `explore`: Fast codebase exploration, file finding
- `shell`: Command execution specialist
- `browser-use`: Browser testing and automation

## Mode Switching

### SwitchMode
Switch between Agent, Plan, and Ask modes.

```markdown
Switch to Plan mode to design implementation
```

Parameters:
- `target_mode_id` (required): "plan" (only switchable mode)
- `explanation` (optional): Why switching modes

Modes:
- Agent: Full implementation mode (default)
- Plan: Readonly collaborative design mode
- Ask: Readonly question answering mode
- Debug: Systematic troubleshooting mode

Note: Can only switch TO plan mode. Other modes are entered by user or system.

## Web

### WebSearch
Search the web for information.

```markdown
Search web for: "Python async best practices 2026"
```

Parameters:
- `search_term` (required): Search query
- `explanation` (optional): Why searching

### WebFetch
Fetch content from URLs.

```markdown
Fetch: https://docs.python.org/3/library/asyncio.html
```

Parameters:
- `url` (required): URL to fetch

## Media

### GenerateImage
Generate images from text descriptions.

```markdown
Generate app icon with minimal flat design
```

Parameters:
- `description` (required): Detailed image description
- `filename` (optional): Output filename
- `reference_image_paths` (optional): Reference images

## Tool Usage in Commands

When writing `.cursor/commands/*.md` files, structure instructions like:

```markdown
## Implementation Steps

1. Read: `.cursor/plans/sprint_plan.md` frontmatter
2. Parse todos, find last with `status: completed`
3. Ask user with AskQuestion tool: "Last completed: TICKET-ID. Correct?"
4. If confirmed: find next pending ticket
5. Display: "Next ticket: TICKET-ID"
6. Run: `git checkout -b feature/ticket-branch`
```

## Tool Usage in Rules

When writing `.cursor/rules/*.md` files, reference tools in constraints:

```markdown
## Code Review Process

Before committing:
1. Agent must use ReadLints tool to check for errors
2. Agent must use Grep tool to verify no TODOs remain
3. Agent must use Shell tool to run test suite
```

## Tool Limitations

Tools the agent CANNOT use:
- No tool to open files in Cursor editor UI
- No tool to control Cursor UI elements
- No tool to install system packages (use Shell for package managers)
- No tool for real-time file watching
- No direct database access (use Shell to run CLI tools)

## Best Practices

1. Use specialized tools over Shell commands:
   - Use Read instead of `cat`
   - Use Grep instead of `grep` or `find`
   - Use Write instead of `echo >` or heredocs

2. Batch independent tool calls:
   - Multiple Read calls in parallel
   - Multiple Grep searches simultaneously

3. Chain dependent Shell commands:
   - Use `&&` for sequential execution
   - Single Shell call for related commands

4. Prefer Task tool for:
   - Broad codebase exploration
   - Multi-step investigations
   - Parallel workstreams

5. Use AskQuestion for:
   - User confirmation before destructive actions
   - Clarifying ambiguous requirements
   - Choosing between valid alternatives
