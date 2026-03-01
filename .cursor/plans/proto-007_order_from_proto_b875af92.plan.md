---
name: PROTO-007 Order From Proto
overview: Implement order_from_proto() method to convert Protobuf Order message to ib-interface Order dataclass.
todos:
  - id: add-imports
    content: Add Decimal and OrderProto imports
    status: pending
  - id: impl-core
    content: Implement core field conversion
    status: pending
  - id: impl-extended
    content: Implement extended field conversion (v178+)
    status: pending
  - id: impl-attached
    content: Implement attached order fields (v218+)
    status: pending
  - id: commit
    content: Git commit with [PROTO-007]
    status: pending
isProject: false
---

# PROTO-007: Implement order_from_proto()

**Owner**: Protocol Developer  
**Effort**: 1 day  
**Depends On**: PROTO-006

---

## File

[src/ib_interface/protobuf/converter.py](src/ib_interface/protobuf/converter.py)

---

## Implementation

```python
from decimal import Decimal
from ib_interface.api.order import Order
from ib_interface.protobuf.messages import OrderProto

@staticmethod
def order_from_proto(proto: OrderProto) -> Order:
    """Convert Protobuf Order to ib-interface Order dataclass."""
    order = Order()
    
    # Core fields
    order.orderId = proto.orderId if proto.HasField('orderId') else 0
    order.clientId = proto.clientId if proto.HasField('clientId') else 0
    order.permId = proto.permId if proto.HasField('permId') else 0
    order.action = proto.action if proto.HasField('action') else ""
    order.totalQuantity = Decimal(str(proto.totalQuantity)) if proto.HasField('totalQuantity') else Decimal(0)
    order.orderType = proto.orderType if proto.HasField('orderType') else ""
    order.lmtPrice = proto.lmtPrice if proto.HasField('lmtPrice') else 0.0
    order.auxPrice = proto.auxPrice if proto.HasField('auxPrice') else 0.0
    order.tif = proto.tif if proto.HasField('tif') else ""
    
    # Extended fields (v178+)
    if proto.HasField('customerAccount'):
        order.customerAccount = proto.customerAccount
    if proto.HasField('professionalCustomer'):
        order.professionalCustomer = proto.professionalCustomer
    if proto.HasField('includeOvernight'):
        order.includeOvernight = proto.includeOvernight
    
    # Attached orders (v218+)
    if proto.HasField('slOrderId'):
        order.slOrderId = proto.slOrderId
    if proto.HasField('ptOrderId'):
        order.ptOrderId = proto.ptOrderId
    
    return order
```

---

## Tasks

1. Add Decimal import
2. Add OrderProto import from messages
3. Implement order_from_proto() with HasField checks
4. Handle core fields (orderId, action, totalQuantity, etc.)
5. Handle extended fields (customerAccount, includeOvernight)
6. Handle attached order fields (slOrderId, ptOrderId)

---

## Git Commit

```bash
git commit -m "[PROTO-007] Implement order_from_proto()

- Convert Protobuf Order to ib-interface dataclass
- Handle optional fields with HasField()
- Support v178+ and v218+ attributes
"
```

---

## Acceptance Criteria

- Converts all core Order fields
- Handles optional fields safely with HasField()
- Returns valid Order dataclass
