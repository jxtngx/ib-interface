# Skill: Async Testing

Proficiency in testing asyncio code.

## Competencies

- Understanding of pytest-asyncio plugin
- Knowledge of async fixture patterns
- Familiarity with mocking async functions
- Understanding of event loop management in tests
- Experience with timeout handling in async tests

## Context

ib-interface is asyncio-native, requiring async-aware testing patterns. Tests must handle event-driven callbacks and async I/O.

## Key Patterns

- `@pytest.mark.asyncio` decorator
- `async def test_*` functions
- `AsyncMock` for mocking coroutines
- Event-based assertions
