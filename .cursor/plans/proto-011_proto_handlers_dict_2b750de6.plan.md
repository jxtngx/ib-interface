---
name: PROTO-011 Proto Handlers Dict
overview: Add proto_handlers dictionary to Decoder class for routing protobuf messages by type ID.
todos:
  - id: add-imports
    content: Import ProtobufCodec and PROTOBUF_MSG_ID
    status: pending
  - id: add-constants
    content: Add PROTO_* type ID constants
    status: pending
  - id: add-dict
    content: Add proto_handlers dict in __init__
    status: pending
  - id: commit
    content: Git commit with [PROTO-011]
    status: pending
  - id: update-sprint
    content: Update sprint_1_modernization_e041af8d.plan.md to mark PROTO-011 completed
    status: pending
isProject: false
---

# PROTO-011: Add proto_handlers dict to Decoder

**Owner**: Protocol Developer  
**Effort**: 0.5 day  
**Depends On**: PROTO-004

---

## File

[src/ib_interface/api/decoder.py](src/ib_interface/api/decoder.py)

---

## Implementation

```python
from ib_interface.protobuf.codec import ProtobufCodec, PROTOBUF_MSG_ID

class Decoder:
    # Protobuf message type IDs (from official API)
    PROTO_ORDER_STATUS = 1
    PROTO_OPEN_ORDER = 2
    PROTO_TICK_PRICE = 10
    PROTO_CONFIG_RESPONSE = 100

    def __init__(self, wrapper, serverVersion: int):
        self.wrapper = wrapper
        self.serverVersion = serverVersion
        
        # Existing legacy handlers
        self.handlers: Dict[int, Callable] = {
            # ... existing handlers 1-107 ...
        }
        
        # Protobuf message handlers (NEW)
        self.proto_handlers: Dict[int, Callable] = {
            self.PROTO_ORDER_STATUS: self._handle_order_status_proto,
            self.PROTO_OPEN_ORDER: self._handle_open_order_proto,
            self.PROTO_TICK_PRICE: self._handle_tick_price_proto,
            self.PROTO_CONFIG_RESPONSE: self._handle_config_response_proto,
        }
```

---

## Tasks

1. Import ProtobufCodec and PROTOBUF_MSG_ID
2. Add PROTO_* type ID constants
3. Add proto_handlers dict in **init**
4. Map type IDs to handler methods (stubs)

---

## Git Commit

```bash
git commit -m "[PROTO-011] Add proto_handlers dict to Decoder

- Import ProtobufCodec from protobuf module
- Add PROTO_* message type ID constants
- Initialize proto_handlers dictionary
"
```

---

## Acceptance Criteria

- proto_handlers dict exists in Decoder
- Type ID constants defined
- Handler method references (can be stubs)

