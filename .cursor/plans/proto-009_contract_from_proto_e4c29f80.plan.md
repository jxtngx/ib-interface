---
name: PROTO-009 Contract From Proto
overview: Implement contract_from_proto() method to convert Protobuf Contract message to ib-interface Contract dataclass.
todos:
  - id: add-imports
    content: Add Contract and ContractProto imports
    status: pending
  - id: impl-fields
    content: Implement all 17 Contract field conversions
    status: pending
  - id: handle-optional
    content: Handle optional fields with HasField()
    status: pending
  - id: commit
    content: Git commit with [PROTO-009]
    status: pending
isProject: false
---

# PROTO-009: Implement contract_from_proto()

**Owner**: Protocol Developer  
**Effort**: 1 day  
**Depends On**: PROTO-006

---

## File

[src/ib_interface/protobuf/converter.py](src/ib_interface/protobuf/converter.py)

---

## Implementation

```python
from ib_interface.api.contract import Contract
from ibapi.protobuf.Contract_pb2 import Contract as ContractProto

@staticmethod
def contract_from_proto(proto: ContractProto) -> Contract:
    """Convert Protobuf Contract to ib-interface Contract dataclass."""
    contract = Contract()
    
    contract.conId = proto.conId if proto.HasField('conId') else 0
    contract.symbol = proto.symbol if proto.HasField('symbol') else ""
    contract.secType = proto.secType if proto.HasField('secType') else ""
    contract.lastTradeDateOrContractMonth = proto.lastTradeDateOrContractMonth if proto.HasField('lastTradeDateOrContractMonth') else ""
    contract.strike = proto.strike if proto.HasField('strike') else 0.0
    contract.right = proto.right if proto.HasField('right') else ""
    contract.multiplier = proto.multiplier if proto.HasField('multiplier') else ""
    contract.exchange = proto.exchange if proto.HasField('exchange') else ""
    contract.currency = proto.currency if proto.HasField('currency') else ""
    contract.localSymbol = proto.localSymbol if proto.HasField('localSymbol') else ""
    contract.primaryExchange = proto.primaryExchange if proto.HasField('primaryExchange') else ""
    contract.tradingClass = proto.tradingClass if proto.HasField('tradingClass') else ""
    contract.includeExpired = proto.includeExpired if proto.HasField('includeExpired') else False
    contract.secIdType = proto.secIdType if proto.HasField('secIdType') else ""
    contract.secId = proto.secId if proto.HasField('secId') else ""
    contract.description = proto.description if proto.HasField('description') else ""
    contract.issuerId = proto.issuerId if proto.HasField('issuerId') else ""
    
    return contract
```

---

## Tasks

1. Add Contract import from ib_interface.api.contract
2. Add ContractProto import from ibapi.protobuf.Contract_pb2
3. Implement contract_from_proto() with HasField checks
4. Handle all Contract fields

---

## Git Commit

```bash
git commit -m "[PROTO-009] Implement contract_from_proto()

- Convert Protobuf Contract to ib-interface dataclass
- Handle all 17 Contract fields
"
```

---

## Acceptance Criteria

- Converts all Contract fields
- Handles optional fields with HasField()
- Returns valid Contract dataclass
