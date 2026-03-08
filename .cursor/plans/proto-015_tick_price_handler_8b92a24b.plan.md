---
name: PROTO-015 Tick Price Handler
overview: Implement _handle_tick_price_proto() to decode TickPrice protobuf and invoke wrapper.priceSizeTick().
todos:
  - id: add-import
    content: Import TickPriceProto from messages
    status: pending
  - id: impl-handler
    content: Implement _handle_tick_price_proto()
    status: pending
  - id: handle-optional
    content: Handle optional size field
    status: pending
  - id: call-wrapper
    content: Call wrapper.priceSizeTick()
    status: pending
  - id: commit
    content: Git commit with [PROTO-015]
    status: pending
  - id: update-sprint
    content: Update sprint_1_modernization_e041af8d.plan.md to mark PROTO-015 completed
    status: pending
isProject: false
---

# PROTO-015: Add _handle_tick_price_proto handler

**Owner**: Protocol Developer  
**Effort**: 0.5 day  
**Depends On**: PROTO-012

---

## File

[src/ib_interface/api/decoder.py](src/ib_interface/api/decoder.py)

---

## Implementation

```python
from ibapi.protobuf.TickPrice_pb2 import TickPrice as TickPriceProto

def _handle_tick_price_proto(self, data: bytes):
    """Handle Protobuf TickPrice message."""
    proto = ProtobufCodec.decode(data, TickPriceProto)
    
    # Invoke wrapper (same interface)
    self.wrapper.priceSizeTick(
        proto.reqId,
        proto.tickType,
        proto.price,
        proto.size if proto.HasField('size') else 0,
    )
```

---

## Tasks

1. Import TickPriceProto from ibapi.protobuf.TickPrice_pb2
2. Implement _handle_tick_price_proto()
3. Decode proto using ProtobufCodec.decode()
4. Call wrapper.priceSizeTick() with fields

---

## Git Commit

```bash
git commit -m "[PROTO-015] Add _handle_tick_price_proto handler

- Decode TickPrice protobuf message
- Invoke wrapper.priceSizeTick() with converted fields
"
```

---

## Acceptance Criteria

- Decodes TickPrice protobuf correctly
- Handles optional size field
- Calls wrapper.priceSizeTick()
