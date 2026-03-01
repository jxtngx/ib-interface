---
name: API-007 ContractDetails Fund
overview: "Add fund data fields to ContractDetails: fundName, fundFamily, fundType, management fees, distribution info, and blue sky states."
todos:
  - id: add-fund-id
    content: Add fundName, fundFamily, fundType
    status: pending
  - id: add-fund-fees
    content: Add fundFrontLoad, fundBackLoad, fundManagementFee
    status: pending
  - id: add-fund-closed
    content: Add fundClosed flags (3 fields)
    status: pending
  - id: add-fund-min
    content: Add fundMinimumInitialPurchase, fundSubsequentMinimumPurchase
    status: pending
  - id: add-fund-bluesky
    content: Add fundBlueSkyStates, fundBlueSkyTerritories
    status: pending
  - id: commit
    content: Git commit with [API-007]
    status: pending
isProject: false
---

# API-007: Add ContractDetails fund fields

**Owner**: API Developer  
**Effort**: 1 day  
**Depends On**: None

---

## File

[src/ib_interface/api/contract.py](src/ib_interface/api/contract.py)

---

## New Attributes

```python
@dataclass
class ContractDetails:
    # ... existing fields ...
    
    # Fund fields (v179+)
    fundName: str = ""
    fundFamily: str = ""
    fundType: str = ""
    fundFrontLoad: str = ""
    fundBackLoad: str = ""
    fundBackLoadTimeInterval: str = ""
    fundManagementFee: str = ""
    fundClosed: bool = False
    fundClosedForNewInvestors: bool = False
    fundClosedForNewMoney: bool = False
    fundNotifyAmount: str = ""
    fundMinimumInitialPurchase: str = ""
    fundSubsequentMinimumPurchase: str = ""
    fundBlueSkyStates: str = ""
    fundBlueSkyTerritories: str = ""
```

---

## Tasks

1. Add fundName, fundFamily, fundType fields
2. Add fundFrontLoad, fundBackLoad fields
3. Add fundBackLoadTimeInterval field
4. Add fundManagementFee field
5. Add fundClosed flags (3 fields)
6. Add fundNotifyAmount field
7. Add purchase minimum fields
8. Add fundBlueSkyStates, fundBlueSkyTerritories

---

## Git Commit

```bash
git commit -m "[API-007] Add ContractDetails fund fields

- Fund identification: name, family, type
- Fee structure: frontLoad, backLoad, managementFee
- Status: closed flags
- Minimums and blue sky compliance (v179+)
"
```

---

## Acceptance Criteria

- 15 new fund fields added
- All string fields default to ""
- All bool fields default to False
