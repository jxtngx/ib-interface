# Agent Creation Plan: ib-interface Modernization

**Author**: Chief Quantitative Developer  
**Status**: Complete

---

## 1. Agent Architecture

```mermaid
graph TD
    Chief[Chief Quant Architect] --> Proto[Protocol Developer]
    Chief --> API[API Developer]
    Chief --> Test[Test Developer]
    
    Proto -.->|delivers to| API
    API -.->|delivers to| Test
    
    subgraph "Scope Boundaries"
        Proto --> P1[protobuf/]
        API --> A1[api/]
        Test --> T1[tests/]
    end
```

---

## 2. Created Agents

| Agent | File | Scope |
|-------|------|-------|
| Chief Quant Architect | `.cursor/agents/chief-quant-architect.md` | Architecture, coordination, approval |
| Protocol Developer | `.cursor/agents/protocol-developer.md` | Protobuf codec, converter, messages |
| API Developer | `.cursor/agents/api-developer.md` | Client, wrapper, IB facade, dataclasses |
| Test Developer | `.cursor/agents/test-developer.md` | Unit tests, integration tests, CI/CD |

---

## 3. Scope Isolation

Each agent has explicit boundaries to prevent overlap:

```mermaid
graph LR
    subgraph "Protocol Developer"
        P1[codec.py]
        P2[converter.py]
        P3[messages/]
    end
    
    subgraph "API Developer"
        A1[client.py]
        A2[wrapper.py]
        A3[ib.py]
        A4[order.py]
        A5[contract.py]
    end
    
    subgraph "Test Developer"
        T1[test_*.py]
        T2[conftest.py]
    end
```

---

## 4. Delegation Protocol

When the Chief Architect delegates to a subagent:

1. **Specify scope**: Which files to modify
2. **State constraints**: What NOT to change
3. **Define deliverables**: Expected output
4. **Require tests**: Coverage expectations

---

## 5. Execution Order

```mermaid
graph LR
    P[Protocol Developer] --> A[API Developer] --> T[Test Developer]
```

| Phase | Agent | Deliverable |
|-------|-------|-------------|
| 1 | Protocol Developer | `protobuf/` module with codec, converter, messages |
| 2 | API Developer | Updated client, wrapper, dataclasses |
| 3 | Test Developer | Test suite with coverage |

---

## 6. Agent Invocation

To invoke a subagent, reference the agent file:

```
@.cursor/agents/protocol-developer.md implement the ProtobufCodec class
```

```
@.cursor/agents/api-developer.md add the includeOvernight attribute to Order
```

```
@.cursor/agents/test-developer.md write unit tests for ProtobufCodec
```

---

## 7. Completion Criteria

| Agent | Done When |
|-------|-----------|
| Protocol Developer | codec.py, converter.py, messages/ exist and pass unit tests |
| API Developer | MaxClientVersion=222, all new attributes added, config API works |
| Test Developer | All tests pass, coverage threshold met |

---

*Agents created and ready for delegation.*
