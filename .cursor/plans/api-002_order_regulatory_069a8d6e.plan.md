---
name: API-002 Order Regulatory
overview: "Add regulatory compliance attributes to Order dataclass: customerAccount, professionalCustomer, bondAccruedInterest."
todos:
  - id: add-customer
    content: "Add customerAccount: str = \"\""
    status: pending
  - id: add-professional
    content: "Add professionalCustomer: bool = False"
    status: pending
  - id: add-bond
    content: "Add bondAccruedInterest: str = \"\""
    status: pending
  - id: commit
    content: Git commit with [API-002]
    status: pending
isProject: false
---

# API-002: Add Order regulatory attributes

**Owner**: API Developer  
**Effort**: 0.5 day  
**Depends On**: API-001

---

## File

[src/ib_interface/api/order.py](src/ib_interface/api/order.py)

---

## New Attributes

```python
@dataclass
class Order:
    # ... existing fields ...
    
    # Regulatory / Compliance (v183+)
    customerAccount: str = ""
    professionalCustomer: bool = False
    bondAccruedInterest: str = ""
```

---

## Tasks

1. Add customerAccount field with default ""
2. Add professionalCustomer field with default False
3. Add bondAccruedInterest field with default ""
4. Add comment indicating v183+ requirement

---

## Git Commit

```bash
git commit -m "[API-002] Add Order regulatory attributes

- customerAccount: str
- professionalCustomer: bool
- bondAccruedInterest: str
- Required for v183+ compliance
"
```

---

## Acceptance Criteria

- Three new fields added to Order
- Correct default values
- Backwards compatible (defaults work)
