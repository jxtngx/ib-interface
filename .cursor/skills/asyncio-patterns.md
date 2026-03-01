# Skill: asyncio Patterns

Expert-level proficiency in Python asyncio for non-blocking I/O.

## Competencies

- Understanding of event loops and coroutines
- Knowledge of async/await syntax and semantics
- Familiarity with asyncio.Protocol for socket communication
- Understanding of Future, Task, and Event primitives
- Knowledge of sync-to-async bridging patterns
- Experience with asyncio debugging and error handling

## Context

ib-interface is asyncio-native, replacing the threaded model of the official TWS API. All network I/O and event handling uses asyncio patterns.

## Key Patterns

- `async def` / `await` for coroutines
- `asyncio.create_task()` for concurrent operations
- `asyncio.wait_for()` for timeouts
- `run()` helper for blocking wrappers
