---
name: API-008 Fund Enums
overview: Add FundAssetType and FundDistributionPolicyIndicator enums, and add corresponding fields to ContractDetails.
todos:
  - id: import-enum
    content: Import Enum from enum
    status: pending
  - id: define-asset-type
    content: Define FundAssetType enum (9 values)
    status: pending
  - id: define-distribution
    content: Define FundDistributionPolicyIndicator enum (3 values)
    status: pending
  - id: add-fields
    content: Add enum fields to ContractDetails
    status: pending
  - id: commit
    content: Git commit with [API-008]
    status: pending
  - id: update-sprint
    content: Update sprint_1_modernization_e041af8d.plan.md to mark API-008 completed
    status: pending
isProject: false
---

# API-008: Add FundAssetType and FundDistributionPolicyIndicator enums

**Owner**: API Developer  
**Effort**: 0.5 day  
**Depends On**: API-007

---

## File

[src/ib_interface/api/contract.py](src/ib_interface/api/contract.py)

---

## New Enums

```python
from enum import Enum

class FundAssetType(Enum):
    """Fund asset type classification."""
    NONE = ("None", "None")
    OTHERS = ("000", "Others")
    MONEY_MARKET = ("001", "Money Market")
    FIXED_INCOME = ("002", "Fixed Income")
    MULTI_ASSET = ("003", "Multi-asset")
    EQUITY = ("004", "Equity")
    SECTOR = ("005", "Sector")
    GUARANTEED = ("006", "Guaranteed")
    ALTERNATIVE = ("007", "Alternative")


class FundDistributionPolicyIndicator(Enum):
    """Fund distribution policy classification."""
    NONE = ("None", "None")
    ACCUMULATION = ("N", "Accumulation Fund")
    INCOME = ("Y", "Income Fund")
```

---

## ContractDetails Fields

```python
@dataclass
class ContractDetails:
    # ... existing fields ...
    
    fundDistributionPolicyIndicator: FundDistributionPolicyIndicator = FundDistributionPolicyIndicator.NONE
    fundAssetType: FundAssetType = FundAssetType.NONE
```

---

## Tasks

1. Import Enum
2. Define FundAssetType enum with 9 values
3. Define FundDistributionPolicyIndicator enum with 3 values
4. Add fields to ContractDetails with NONE defaults

---

## Git Commit

```bash
git commit -m "[API-008] Add FundAssetType and FundDistributionPolicyIndicator enums

- FundAssetType: 9 asset classifications
- FundDistributionPolicyIndicator: accumulation vs income
- Add enum fields to ContractDetails
"
```

---

## Acceptance Criteria

- Two enums defined with correct values
- ContractDetails has enum fields
- Default is NONE for backwards compatibility
