---
name: API-004 Order Attached
overview: "Add attached order attributes to Order dataclass: slOrderId, slOrderType, ptOrderId, ptOrderType for stop-loss and profit-target linking."
todos:
  - id: add-sl-id
    content: "Add slOrderId: int = UNSET_INTEGER"
    status: pending
  - id: add-sl-type
    content: "Add slOrderType: str = \"\""
    status: pending
  - id: add-pt-id
    content: "Add ptOrderId: int = UNSET_INTEGER"
    status: pending
  - id: add-pt-type
    content: "Add ptOrderType: str = \"\""
    status: pending
  - id: commit
    content: Git commit with [API-004]
    status: pending
isProject: false
---

# API-004: Add Order attached order attributes

**Owner**: API Developer  
**Effort**: 0.5 day  
**Depends On**: API-001

---

## File

[src/ib_interface/api/order.py](src/ib_interface/api/order.py)

---

## New Attributes

```python
from ib_interface.api.util import UNSET_INTEGER

@dataclass
class Order:
    # ... existing fields ...
    
    # Attached Orders (v218+)
    slOrderId: int = UNSET_INTEGER
    slOrderType: str = ""
    ptOrderId: int = UNSET_INTEGER
    ptOrderType: str = ""
```

---

## Tasks

1. Add slOrderId field (stop-loss order ID)
2. Add slOrderType field (stop-loss order type)
3. Add ptOrderId field (profit-target order ID)
4. Add ptOrderType field (profit-target order type)
5. Use UNSET_INTEGER for IDs

---

## Git Commit

```bash
git commit -m "[API-004] Add Order attached order attributes

- slOrderId, slOrderType: Stop-loss linking
- ptOrderId, ptOrderType: Profit-target linking
- Required for v218+ bracket order features
"
```

---

## Acceptance Criteria

- Four new fields added
- UNSET_INTEGER used for ID defaults
- Enables bracket order linking
