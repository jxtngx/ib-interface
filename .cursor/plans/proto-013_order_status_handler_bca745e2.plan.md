---
name: PROTO-013 Order Status Handler
overview: Implement _handle_order_status_proto() to decode OrderStatus protobuf and invoke wrapper.orderStatus().
todos:
  - id: add-import
    content: Import OrderStatusProto from messages
    status: pending
  - id: impl-handler
    content: Implement _handle_order_status_proto()
    status: pending
  - id: decode-proto
    content: Decode using ProtobufCodec.decode()
    status: pending
  - id: call-wrapper
    content: Call wrapper.orderStatus() with fields
    status: pending
  - id: commit
    content: Git commit with [PROTO-013]
    status: pending
isProject: false
---

# PROTO-013: Add _handle_order_status_proto handler

**Owner**: Protocol Developer  
**Effort**: 0.5 day  
**Depends On**: PROTO-012, PROTO-007

---

## File

[src/ib_interface/api/decoder.py](src/ib_interface/api/decoder.py)

---

## Implementation

```python
from ib_interface.protobuf.messages import OrderStatusProto

def _handle_order_status_proto(self, data: bytes):
    """Handle Protobuf OrderStatus message."""
    proto = ProtobufCodec.decode(data, OrderStatusProto)
    
    # Convert and invoke wrapper (same interface as legacy)
    self.wrapper.orderStatus(
        orderId=proto.orderId,
        status=proto.status,
        filled=float(proto.filled),
        remaining=float(proto.remaining),
        avgFillPrice=proto.avgFillPrice,
        permId=proto.permId,
        parentId=proto.parentId,
        lastFillPrice=proto.lastFillPrice,
        clientId=proto.clientId,
        whyHeld=proto.whyHeld,
        mktCapPrice=proto.mktCapPrice,
    )
```

---

## Tasks

1. Import OrderStatusProto from messages
2. Implement _handle_order_status_proto()
3. Decode proto using ProtobufCodec.decode()
4. Call wrapper.orderStatus() with extracted fields

---

## Git Commit

```bash
git commit -m "[PROTO-013] Add _handle_order_status_proto handler

- Decode OrderStatus protobuf message
- Invoke wrapper.orderStatus() with converted fields
"
```

---

## Acceptance Criteria

- Decodes OrderStatus protobuf correctly
- Calls wrapper.orderStatus() with all fields
- Same interface as legacy handler
