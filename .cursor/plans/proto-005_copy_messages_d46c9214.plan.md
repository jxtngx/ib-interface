---
name: PROTO-005 Setup ibapi Local Installation
overview: Setup ibapi as a local path dependency and import protobuf messages directly from the installed package.
todos:
  - id: add-pyproject-dependency
    content: Add ibapi as local path dependency in pyproject.toml
    status: completed
  - id: update-converter
    content: Add protobuf imports to converter.py
    status: completed
  - id: verify-imports
    content: Verify ibapi.protobuf imports work correctly
    status: completed
  - id: commit
    content: Git commit with [PROTO-005]
    status: completed
isProject: false
---

# PROTO-005: Setup ibapi Local Installation and Imports

**Owner**: Protocol Developer  
**Effort**: 0.5 day  
**Depends On**: PROTO-001

---

## Approach

Import protobuf messages directly from the **ibapi package** installed from `ibapi/pythonclient/` in the repository. No file copying needed.

---

## Source

`ibapi/pythonclient/` - Installed as package via pip

---

## Tasks

1. Add ibapi as local path dependency in `pyproject.toml`
2. Adjust protobuf version to match ibapi requirements (>=5.29.0)
3. Add imports to `converter.py` from `ibapi.protobuf.`*
4. Verify imports work with `uv run python -c`
5. Commit changes

---

## Changes Made

### pyproject.toml

Added ibapi as local path dependency:

```toml
dependencies = [
    "ibapi @ file:///${PROJECT_ROOT}/ibapi/pythonclient",
    "matplotlib>=3.10.8",
    "numpy>=2.4.2",
    "pandas>=3.0.1",
    "protobuf>=5.29.0",
]
```

### converter.py

Added direct imports:

```python
from ibapi.protobuf.Order_pb2 import Order as OrderProto
from ibapi.protobuf.Contract_pb2 import Contract as ContractProto
from ibapi.protobuf.OrderStatus_pb2 import OrderStatus as OrderStatusProto
from ibapi.protobuf.OpenOrder_pb2 import OpenOrder as OpenOrderProto
from ibapi.protobuf.TickPrice_pb2 import TickPrice as TickPriceProto
from ibapi.protobuf.ConfigRequest_pb2 import ConfigRequest
from ibapi.protobuf.ConfigResponse_pb2 import ConfigResponse
```

---

## Git Commit

```bash
git commit -m "[PROTO-005] Setup ibapi local installation and imports

- Add ibapi as local path dependency in pyproject.toml
- Adjust protobuf version to >=5.29.0 for compatibility
- Add protobuf message imports to converter.py
- Import directly from installed ibapi package
"
```

---

## Acceptance Criteria

- `ibapi/pythonclient/` source exists in repository
- `ibapi` added to `pyproject.toml` as local path dependency
- `converter.py` imports directly from `ibapi.protobuf.*`
- No `messages/` directory created in `src/ib_interface/protobuf/`
- Import test passes: `uv run python -c "from ibapi.protobuf.Order_pb2 import Order"`
- No import errors

