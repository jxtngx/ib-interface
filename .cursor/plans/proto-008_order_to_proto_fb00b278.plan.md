---
name: PROTO-008 Order To Proto
overview: Implement order_to_proto() method to convert ib-interface Order dataclass to Protobuf Order message.
todos:
  - id: add-imports
    content: Add dataclass_fields import
    status: pending
  - id: impl-reflection
    content: Implement reflection-based field mapping
    status: pending
  - id: handle-decimal
    content: Handle Decimal to float conversion
    status: pending
  - id: commit
    content: Git commit with [PROTO-008]
    status: pending
isProject: false
---

# PROTO-008: Implement order_to_proto()

**Owner**: Protocol Developer  
**Effort**: 1 day  
**Depends On**: PROTO-006

---

## File

[src/ib_interface/protobuf/converter.py](src/ib_interface/protobuf/converter.py)

---

## Implementation

```python
from dataclasses import fields as dataclass_fields
from decimal import Decimal
from ib_interface.api.order import Order
from ibapi.protobuf.Order_pb2 import Order as OrderProto

@staticmethod
def order_to_proto(order: Order) -> OrderProto:
    """Convert ib-interface Order dataclass to Protobuf Order."""
    proto = OrderProto()
    
    for field in dataclass_fields(order):
        value = getattr(order, field.name)
        if value is not None and hasattr(proto, field.name):
            if isinstance(value, Decimal):
                setattr(proto, field.name, float(value))
            else:
                setattr(proto, field.name, value)
    
    return proto
```

---

## Tasks

1. Add dataclass_fields import
2. Add Order import from ib_interface.api.order
3. Add OrderProto import from ibapi.protobuf.Order_pb2
4. Implement order_to_proto() using reflection
5. Handle Decimal to float conversion
6. Skip None values

---

## Git Commit

```bash
git commit -m "[PROTO-008] Implement order_to_proto()

- Convert ib-interface Order to Protobuf message
- Use reflection for field mapping
- Handle Decimal to float conversion
"
```

---

## Acceptance Criteria

- Converts Order dataclass to Protobuf
- Handles Decimal fields correctly
- Skips None/unset values
