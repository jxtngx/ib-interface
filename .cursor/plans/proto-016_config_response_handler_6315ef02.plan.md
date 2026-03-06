---
name: PROTO-016 Config Response Handler
overview: Implement _handle_config_response_proto() to decode ConfigResponse protobuf and invoke wrapper.configResponse().
todos:
  - id: add-import
    content: Import ConfigResponseProto from messages
    status: pending
  - id: impl-handler
    content: Implement _handle_config_response_proto()
    status: pending
  - id: check-wrapper
    content: Check wrapper has configResponse method
    status: pending
  - id: call-wrapper
    content: Call wrapper.configResponse()
    status: pending
  - id: commit
    content: Git commit with [PROTO-016]
    status: pending
isProject: false
---

# PROTO-016: Add _handle_config_response_proto handler

**Owner**: Protocol Developer  
**Effort**: 0.5 day  
**Depends On**: PROTO-012

---

## File

[src/ib_interface/api/decoder.py](src/ib_interface/api/decoder.py)

---

## Implementation

```python
from ibapi.protobuf.ConfigResponse_pb2 import ConfigResponse as ConfigResponseProto

def _handle_config_response_proto(self, data: bytes):
    """Handle Protobuf ConfigResponse message (NEW feature)."""
    proto = ProtobufCodec.decode(data, ConfigResponseProto)
    
    # NEW wrapper method for configuration
    if hasattr(self.wrapper, 'configResponse'):
        self.wrapper.configResponse(proto.reqId, proto)
```

---

## Tasks

1. Import ConfigResponseProto from ibapi.protobuf.ConfigResponse_pb2
2. Implement _handle_config_response_proto()
3. Decode proto using ProtobufCodec.decode()
4. Check wrapper has configResponse method
5. Call wrapper.configResponse() with reqId and proto

---

## Git Commit

```bash
git commit -m "[PROTO-016] Add _handle_config_response_proto handler

- Decode ConfigResponse protobuf message
- Invoke wrapper.configResponse() if available
- Enables new Config API feature
"
```

---

## Acceptance Criteria

- Decodes ConfigResponse protobuf correctly
- Safely checks for wrapper method
- Passes proto object to wrapper
