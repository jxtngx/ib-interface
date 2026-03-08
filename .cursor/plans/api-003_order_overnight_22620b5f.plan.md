---
name: API-003 Order Overnight
overview: "Add overnight/extended hours attribute to Order dataclass: includeOvernight."
todos:
  - id: add-overnight
    content: "Add includeOvernight: bool = False"
    status: pending
  - id: add-comment
    content: Add v189+ version comment
    status: pending
  - id: commit
    content: Git commit with [API-003]
    status: pending
  - id: update-sprint
    content: Update sprint_1_modernization_e041af8d.plan.md to mark API-003 completed
    status: pending
isProject: false
---

# API-003: Add Order overnight attributes

**Owner**: API Developer  
**Effort**: 0.5 day  
**Depends On**: API-001

---

## File

[src/ib_interface/api/order.py](src/ib_interface/api/order.py)

---

## New Attribute

```python
@dataclass
class Order:
    # ... existing fields ...
    
    # Overnight / Extended Hours (v189+)
    includeOvernight: bool = False
```

---

## Tasks

1. Add includeOvernight field with default False
2. Add comment indicating v189+ requirement

---

## Git Commit

```bash
git commit -m "[API-003] Add Order overnight attribute

- includeOvernight: bool
- Enables extended hours trading (v189+)
"
```

---

## Acceptance Criteria

- includeOvernight field added
- Default is False (backwards compatible)
