---
name: PROTO-006 Converter Skeleton
overview: Create ProtobufConverter class with method stubs for proto-to-dataclass conversion (order, contract, bar_data).
todos:
  - id: add-imports
    content: Add imports for Order, Contract, BarData
    status: pending
  - id: add-docstring
    content: Add module docstring with design philosophy
    status: pending
  - id: create-class
    content: Create ProtobufConverter class
    status: pending
  - id: add-stubs
    content: Add method stubs with NotImplementedError
    status: pending
  - id: update-exports
    content: Update protobuf/__init__.py exports
    status: pending
  - id: commit
    content: Git commit with [PROTO-006]
    status: pending
isProject: false
---

# PROTO-006: Create ProtobufConverter class skeleton

**Owner**: Protocol Developer  
**Effort**: 1 day  
**Depends On**: PROTO-005

---

## File

[src/ib_interface/protobuf/converter.py](src/ib_interface/protobuf/converter.py)

---

## Implementation

```python
"""
Convert between Protobuf messages and ib-interface dataclasses.

Design Philosophy:
- Protobuf is used for wire protocol only
- All internal state uses ib-interface dataclasses
- User-facing API never exposes Protobuf types
"""

from ib_interface.api.contract import Contract
from ib_interface.api.order import Order
from ib_interface.api.objects import BarData


class ProtobufConverter:
    """Bidirectional converter between Protobuf and dataclasses."""
    
    @staticmethod
    def order_from_proto(proto) -> Order:
        """Convert Protobuf Order to dataclass."""
        raise NotImplementedError("PROTO-007")
    
    @staticmethod
    def order_to_proto(order: Order):
        """Convert dataclass Order to Protobuf."""
        raise NotImplementedError("PROTO-008")
    
    @staticmethod
    def contract_from_proto(proto) -> Contract:
        """Convert Protobuf Contract to dataclass."""
        raise NotImplementedError("PROTO-009")
    
    @staticmethod
    def bar_data_from_proto(proto) -> BarData:
        """Convert Protobuf bar to dataclass."""
        raise NotImplementedError("PROTO-010")
```

---

## Tasks

1. Add imports for dataclass types (Order, Contract, BarData)
2. Add module docstring with design philosophy
3. Create `ProtobufConverter` class
4. Add method stubs with `NotImplementedError`
5. Update `protobuf/__init__.py` exports

---

## Git Commit

```bash
git commit -m "[PROTO-006] Create ProtobufConverter class skeleton

- Define converter interface for proto <-> dataclass
- Method stubs for order, contract, bar_data conversion
"
```

---

## Acceptance Criteria

- Class importable from `ib_interface.protobuf`
- Method signatures match expected types
- Design philosophy documented
