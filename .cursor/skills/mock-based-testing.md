# Skill: Mock-Based Testing

Proficiency in mock objects for isolated testing.

## Competencies

- Understanding of unittest.mock (Mock, MagicMock, patch)
- Knowledge of return_value and side_effect
- Familiarity with call assertions
- Understanding of mock context managers
- Experience with mocking network I/O

## Context

ib-interface tests must run without live TWS connections. Mock objects simulate TWS responses for deterministic testing.

## Key Patterns

- Mock protobuf messages for decoder tests
- Mock socket connections for client tests
- Mock events for wrapper tests
