# Run Ticket Plan

Verify git state, check sprint progress, and display the next ticket to work on.

## Usage

```
@run-ticket-plan
```

## Workflow

1. Check git: `git checkout main && git pull origin main`
2. Read sprint plan frontmatter todos from `sprint_1_modernization_e041af8d.plan.md`
3. Find last ticket with `status: completed`
4. Ask user: "Is [TICKET-ID] the last ticket you completed?"
5. If yes: Display next pending ticket plan path
6. If no: Ask which ticket was last, then display next

## No Automation

This command does NOT:
- Create branches (user does this)
- Create GitHub issues (user runs create-github-issue.sh if needed)
- Run scripts
- Consult agents

It only tells you what to work on next.

## Implementation Steps

When user invokes this command, the agent should:

1. Run: `git checkout main && git pull origin main`
2. Read: `.cursor/plans/sprint_1_modernization_e041af8d.plan.md` frontmatter
3. Parse todos, find last with `status: completed`
4. Ask user with AskQuestion tool: "Last completed: TICKET-ID. Correct?"
5. If confirmed: find next pending ticket in sequence
6. Display: "Next ticket: TICKET-ID"
7. Display: "Plan file: @.cursor/plans/[ticket-plan-file].plan.md"
8. If confirmed run: `git checkout -b {ticket-type}/{TICKET-ID-description`

## Collaborative Steps After Checkout

1. Parse sprint plan for ticket issue link
2. If no issue, create GitHub issue: `bash .cursor/scripts/create-github-issue.sh TICKET-ID`
3. Give user the link to the plan file so user can implement from there
4. DO NOT run any git commmand, continue to 5
5. Final step in ticket plan: Move sprint plan to `.cursor/plans/sprint-1-completed/`
6. DO NOT run any git commmand return to user with message that the ticket plan is complete
