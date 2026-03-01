# Skill: EventKit Reactive Programming

Proficiency in EventKit event-driven programming patterns.

## Competencies

- Understanding of Event class and emit/subscribe patterns
- Knowledge of event operators (filter, map, throttle)
- Familiarity with event chaining and composition
- Understanding of async iteration over events
- Experience with RxPy-like reactive patterns

## Context

ib-interface uses EventKit for reactive event streaming, providing RxPy-like operators for market data, order updates, and account changes.

## Key Patterns

- `event += handler` for subscription
- `event -= handler` for unsubscription
- `event.emit(*args)` for publishing
- `async for item in event:` for async iteration
