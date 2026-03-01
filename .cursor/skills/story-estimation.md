# Story Estimation

Estimate task complexity using Planning Poker and story points.

## Planning Poker

```mermaid
graph LR
    Story[Present Story] --> Individual[Individual Estimate]
    Individual --> Reveal[Simultaneous Reveal]
    Reveal --> Discuss[Discuss Differences]
    Discuss --> Converge{Consensus?}
    Converge -->|No| Individual
    Converge -->|Yes| Record[Record Points]
```

## Estimation Factors

Consider these when estimating:

1. **Complexity**: Algorithm difficulty, logic branches
2. **Uncertainty**: Unknown dependencies, new technology
3. **Effort**: Time required for implementation
4. **Risk**: Potential for rework or blockers

## Fibonacci Sequence

Use: 1, 2, 3, 5, 8, 13

Why: Forces meaningful distinctions, prevents false precision

## Reference Stories

Maintain baseline stories for comparison:

| Points | Reference Example |
|--------|-------------------|
| 1 | Add validation to existing field |
| 2 | Create simple DTO class |
| 3 | Implement standard CRUD endpoint |
| 5 | Add new protocol message with codec |
| 8 | Refactor subsystem with tests |

## Velocity Tracking

- **Measure**: Completed points per sprint
- **Calculate**: Rolling 3-sprint average
- **Adjust**: Update capacity planning
- **Trend**: Watch for consistent over/under estimation

## Anti-Patterns

Avoid:
- Estimating in hours (use story points)
- Comparing velocity across teams
- Using estimates for individual performance
- Re-estimating mid-sprint
