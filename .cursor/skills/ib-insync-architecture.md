# Skill: ib-insync Architecture

Deep familiarity with ib-insync/ib-interface codebase structure.

## Competencies

- Understanding of Client/Wrapper/IB layered architecture
- Knowledge of Decoder message routing
- Familiarity with dataclass-based objects (Order, Contract, etc.)
- Understanding of request ID management
- Knowledge of automatic throttling mechanism
- Experience with connection lifecycle

## Context

ib-interface is derived from ib-insync, an asyncio alternative to the official TWS API. Understanding its architecture is essential for maintaining compatibility.

## Key Components

- `IB` - High-level facade with convenience methods
- `Client` - asyncio socket client, request sending
- `Wrapper` - Callback implementations, state management
- `Decoder` - Message parsing and routing
