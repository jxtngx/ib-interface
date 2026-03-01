---
name: OBS-003 Protocol Type Logging
overview: Add structured logging to Decoder.interpret() that logs whether each message was decoded as protobuf or legacy string format.
todos:
  - id: import-constant
    content: Import PROTOBUF_MSG_ID from codec
    status: pending
  - id: log-protobuf
    content: Add structured log for protobuf messages
    status: pending
  - id: log-legacy
    content: Add structured log for legacy messages
    status: pending
  - id: verify-level
    content: Ensure INFO level logging
    status: pending
  - id: commit
    content: Git commit with [OBS-003]
    status: pending
isProject: false
---

# OBS-003: Add protocol type logging to Decoder.interpret()

**Owner**: Observability Engineer  
**Effort**: 0.5 day  
**Depends On**: OBS-002, PROTO-012

---

## File

[src/ib_interface/api/decoder.py](src/ib_interface/api/decoder.py)

---

## Implementation

Update the `interpret()` method (after PROTO-012 adds dual-protocol routing):

```python
def interpret(self, fields):
    """
    Decode fields and invoke corresponding wrapper method.
    
    Automatically detects protocol type and routes appropriately.
    Logs protocol type for observability.
    """
    try:
        msgId = int(fields[0])
        
        if msgId == PROTOBUF_MSG_ID:
            proto_type_id = int(fields[1]) if len(fields) > 1 else -1
            self.logger.info(
                "Received protobuf message",
                extra={
                    "protocol": "protobuf",
                    "proto_type_id": proto_type_id,
                }
            )
            self._interpret_protobuf(fields)
        else:
            self.logger.info(
                "Received legacy message",
                extra={
                    "protocol": "legacy",
                    "message_id": msgId,
                }
            )
            handler = self.handlers.get(msgId)
            if handler:
                handler(fields)
            else:
                self.logger.warning(f"Unknown message ID: {msgId}")
                
    except Exception:
        self.logger.exception(f"Error handling fields: {fields}")
```

---

## Log Attributes


| Attribute       | Type   | Description                               |
| --------------- | ------ | ----------------------------------------- |
| `protocol`      | string | "protobuf" or "legacy"                    |
| `proto_type_id` | int    | Protobuf message type (only for protobuf) |
| `message_id`    | int    | Legacy message ID (only for legacy)       |


---

## SigNoz Queries

After implementation, you can query in SigNoz:

```
# Count by protocol type
service.name="ib-interface" | stats count() by protocol

# Filter protobuf only
service.name="ib-interface" protocol="protobuf"

# Track specific message types
service.name="ib-interface" proto_type_id=1
```

---

## Tasks

1. Import PROTOBUF_MSG_ID from codec module
2. Add structured log for protobuf messages with `extra={"protocol": "protobuf", ...}`
3. Add structured log for legacy messages with `extra={"protocol": "legacy", ...}`
4. Ensure logging at INFO level (not DEBUG) for visibility

---

## Git Commit

```bash
git commit -m "[OBS-003] Add protocol type logging to Decoder.interpret()

- Log protocol='protobuf' or protocol='legacy' for each message
- Include proto_type_id for protobuf, message_id for legacy
- Enables protocol adoption tracking in SigNoz
"
```

---

## Acceptance Criteria

- Every decoded message logs its protocol type
- Logs include structured `extra` attributes
- Queryable in SigNoz by `protocol` field

