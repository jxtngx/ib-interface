# Skill: TWS Wire Protocol

Understanding of Interactive Brokers TWS API socket protocol.

## Competencies

- Knowledge of TWS message framing (length-prefixed messages)
- Understanding of legacy string-based protocol (message IDs 1-107)
- Understanding of protobuf protocol (message ID 0 + type ID)
- Familiarity with server version negotiation
- Knowledge of request/response patterns and callbacks

## Context

TWS API uses a TCP socket protocol with two formats: legacy string-delimited messages and newer protobuf messages. Server version determines available features.

## Key Concepts

- Message ID 0 indicates protobuf format
- Server versions 100-222 with feature flags
- Request throttling (45 requests/second)
- Dual-protocol support for backwards compatibility
