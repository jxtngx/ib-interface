---
name: PROTO-014 Open Order Handler
overview: Implement _handle_open_order_proto() to decode OpenOrder protobuf and invoke wrapper.openOrder() with converted dataclasses.
todos:
  - id: add-imports
    content: Import OpenOrderProto and ProtobufConverter
    status: pending
  - id: add-converter
    content: Add self.converter in __init__
    status: pending
  - id: impl-handler
    content: Implement _handle_open_order_proto()
    status: pending
  - id: convert-objects
    content: Convert contract, order, order_state
    status: pending
  - id: call-wrapper
    content: Call wrapper.openOrder()
    status: pending
  - id: commit
    content: Git commit with [PROTO-014]
    status: pending
isProject: false
---

# PROTO-014: Add _handle_open_order_proto handler

**Owner**: Protocol Developer  
**Effort**: 1 day  
**Depends On**: PROTO-012, PROTO-009

---

## File

[src/ib_interface/api/decoder.py](src/ib_interface/api/decoder.py)

---

## Implementation

```python
from ib_interface.protobuf.messages import OpenOrderProto
from ib_interface.protobuf.converter import ProtobufConverter
from ib_interface.api.order import OrderState

def _handle_open_order_proto(self, data: bytes):
    """Handle Protobuf OpenOrder message."""
    proto = ProtobufCodec.decode(data, OpenOrderProto)
    
    # Convert protobuf to dataclasses
    contract = self.converter.contract_from_proto(proto.contract)
    order = self.converter.order_from_proto(proto.order)
    order_state = OrderState()
    
    # Populate order_state from proto if present
    if proto.HasField('orderState'):
        order_state.status = proto.orderState.status
        order_state.initMarginBefore = proto.orderState.initMarginBefore
        order_state.maintMarginBefore = proto.orderState.maintMarginBefore
        order_state.commission = proto.orderState.commission
    
    # Invoke wrapper with converted objects
    self.wrapper.openOrder(proto.orderId, contract, order, order_state)
```

---

## Tasks

1. Import OpenOrderProto from messages
2. Import ProtobufConverter
3. Add self.converter = ProtobufConverter() in **init**
4. Implement _handle_open_order_proto()
5. Convert contract, order, order_state
6. Call wrapper.openOrder()

---

## Git Commit

```bash
git commit -m "[PROTO-014] Add _handle_open_order_proto handler

- Decode OpenOrder protobuf message
- Convert contract and order using ProtobufConverter
- Populate OrderState from proto
- Invoke wrapper.openOrder() with dataclasses
"
```

---

## Acceptance Criteria

- Decodes OpenOrder protobuf correctly
- Converts to Contract, Order, OrderState dataclasses
- Calls wrapper.openOrder() with converted objects

