---
name: PROTO-005 Copy Messages
overview: Copy 204 protobuf message files from pythonclient/ibapi/protobuf/ to src/ib_interface/protobuf/messages/ and update import paths.
todos:
  - id: copy-files
    content: Copy all *_pb2.py files to messages/
    status: pending
  - id: update-imports
    content: Update import paths in each file
    status: pending
  - id: create-exports
    content: Create messages/__init__.py with key exports
    status: pending
  - id: verify-imports
    content: Verify imports work without errors
    status: pending
  - id: commit
    content: Git commit with [PROTO-005]
    status: pending
isProject: false
---

# PROTO-005: Copy and reorganize protobuf messages

**Owner**: Protocol Developer  
**Effort**: 1 day  
**Depends On**: PROTO-001

---

## Source

`pythonclient/ibapi/protobuf/*.py` (204 files)

## Destination

`src/ib_interface/protobuf/messages/`

---

## Tasks

1. Copy all `*_pb2.py` files from source to destination
2. Update import paths in each file (replace `ibapi.protobuf` with `ib_interface.protobuf.messages`)
3. Create `messages/__init__.py` with key exports
4. Verify imports work

---

## Key Exports for **init**.py

```python
from .ConfigRequest_pb2 import ConfigRequest
from .ConfigResponse_pb2 import ConfigResponse
from .Order_pb2 import Order as OrderProto
from .Contract_pb2 import Contract as ContractProto
from .OrderStatus_pb2 import OrderStatus as OrderStatusProto
from .OpenOrder_pb2 import OpenOrder as OpenOrderProto
from .TickPrice_pb2 import TickPrice as TickPriceProto
```

---

## Git Commit

```bash
git commit -m "[PROTO-005] Copy and reorganize protobuf messages

- Migrate 204 *_pb2.py files from official API
- Update import paths to ib_interface.protobuf.messages
- Export key message types from __init__.py
"
```

---

## Acceptance Criteria

- All 204 files copied
- Import paths updated
- `from ib_interface.protobuf.messages import OrderProto` works
- No import errors

