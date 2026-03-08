---
name: API-005 Order Post-Only
overview: "Add post-only and auction attributes to Order dataclass: postOnly, allowPreOpen, ignoreOpenAuction, deactivate, seekPriceImprovement."
todos:
  - id: add-post-only
    content: "Add postOnly: bool = False"
    status: pending
  - id: add-preopen
    content: "Add allowPreOpen: bool = False"
    status: pending
  - id: add-ignore-auction
    content: "Add ignoreOpenAuction: bool = False"
    status: pending
  - id: add-deactivate
    content: "Add deactivate: bool = False"
    status: pending
  - id: add-seek-price
    content: "Add seekPriceImprovement: Optional[bool] = None"
    status: pending
  - id: commit
    content: Git commit with [API-005]
    status: pending
  - id: update-sprint
    content: Update sprint_1_modernization_e041af8d.plan.md to mark API-005 completed
    status: pending
isProject: false
---

# API-005: Add Order post-only/auction attributes

**Owner**: API Developer  
**Effort**: 0.5 day  
**Depends On**: API-001

---

## File

[src/ib_interface/api/order.py](src/ib_interface/api/order.py)

---

## New Attributes

```python
from typing import Optional

@dataclass
class Order:
    # ... existing fields ...
    
    # Post-Only / Auction (v216+)
    postOnly: bool = False
    allowPreOpen: bool = False
    ignoreOpenAuction: bool = False
    deactivate: bool = False
    seekPriceImprovement: Optional[bool] = None
```

---

## Tasks

1. Add postOnly field
2. Add allowPreOpen field
3. Add ignoreOpenAuction field
4. Add deactivate field
5. Add seekPriceImprovement as Optional[bool]

---

## Git Commit

```bash
git commit -m "[API-005] Add Order post-only/auction attributes

- postOnly, allowPreOpen, ignoreOpenAuction, deactivate: bool
- seekPriceImprovement: Optional[bool]
- Required for v216+ auction controls
"
```

---

## Acceptance Criteria

- Five new fields added
- seekPriceImprovement is Optional[bool]
- Default values are backwards compatible
