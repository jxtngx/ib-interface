---
name: API-006 ContractDetails Size
overview: "Add size precision fields to ContractDetails: minSize, sizeIncrement, suggestedSizeIncrement, minAlgoSize, lastPricePrecision, lastSizePrecision."
todos:
  - id: add-min-size
    content: "Add minSize: Decimal = Decimal(0)"
    status: pending
  - id: add-increment
    content: "Add sizeIncrement: Decimal = Decimal(0)"
    status: pending
  - id: add-suggested
    content: "Add suggestedSizeIncrement: Decimal = Decimal(0)"
    status: pending
  - id: add-algo
    content: "Add minAlgoSize: Decimal = Decimal(0)"
    status: pending
  - id: add-price-prec
    content: "Add lastPricePrecision: Decimal = Decimal(0)"
    status: pending
  - id: add-size-prec
    content: "Add lastSizePrecision: Decimal = Decimal(0)"
    status: pending
  - id: commit
    content: Git commit with [API-006]
    status: pending
isProject: false
---

# API-006: Add ContractDetails size precision fields

**Owner**: API Developer  
**Effort**: 0.5 day  
**Depends On**: None

---

## File

[src/ib_interface/api/contract.py](src/ib_interface/api/contract.py)

---

## New Attributes

```python
from decimal import Decimal

@dataclass
class ContractDetails:
    # ... existing fields ...
    
    # Size precision fields (v164+)
    minSize: Decimal = Decimal(0)
    sizeIncrement: Decimal = Decimal(0)
    suggestedSizeIncrement: Decimal = Decimal(0)
    minAlgoSize: Decimal = Decimal(0)
    lastPricePrecision: Decimal = Decimal(0)
    lastSizePrecision: Decimal = Decimal(0)
```

---

## Tasks

1. Import Decimal if not present
2. Add minSize field
3. Add sizeIncrement field
4. Add suggestedSizeIncrement field
5. Add minAlgoSize field
6. Add lastPricePrecision field
7. Add lastSizePrecision field

---

## Git Commit

```bash
git commit -m "[API-006] Add ContractDetails size precision fields

- minSize, sizeIncrement, suggestedSizeIncrement
- minAlgoSize, lastPricePrecision, lastSizePrecision
- All Decimal type for precision (v164+)
"
```

---

## Acceptance Criteria

- Six new Decimal fields added
- Default values are Decimal(0)
- ContractDetails remains backwards compatible
