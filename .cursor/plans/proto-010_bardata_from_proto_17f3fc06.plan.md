---
name: PROTO-010 BarData From Proto
overview: Implement bar_data_from_proto() method to convert Protobuf historical bar to ib-interface BarData dataclass.
todos:
  - id: add-imports
    content: Add BarData import
    status: pending
  - id: impl-ohlcv
    content: Implement OHLCV field conversion
    status: pending
  - id: handle-volume
    content: Handle volume as Decimal
    status: pending
  - id: commit
    content: Git commit with [PROTO-010]
    status: pending
  - id: update-sprint
    content: Update sprint_1_modernization_e041af8d.plan.md to mark PROTO-010 completed
    status: pending
isProject: false
---

# PROTO-010: Implement bar_data_from_proto()

**Owner**: Protocol Developer  
**Effort**: 0.5 day  
**Depends On**: PROTO-006

---

## File

[src/ib_interface/protobuf/converter.py](src/ib_interface/protobuf/converter.py)

---

## Implementation

```python
from decimal import Decimal
from ib_interface.api.objects import BarData
from ibapi.protobuf.HistoricalDataBar_pb2 import HistoricalDataBar

@staticmethod
def bar_data_from_proto(proto: HistoricalDataBar) -> BarData:
    """Convert Protobuf historical bar to ib-interface BarData."""
    return BarData(
        date=proto.time if proto.HasField('time') else "",
        open=proto.open if proto.HasField('open') else 0.0,
        high=proto.high if proto.HasField('high') else 0.0,
        low=proto.low if proto.HasField('low') else 0.0,
        close=proto.close if proto.HasField('close') else 0.0,
        volume=Decimal(str(proto.volume)) if proto.HasField('volume') else Decimal(0),
        barCount=proto.barCount if proto.HasField('barCount') else 0,
        average=proto.wap if proto.HasField('wap') else 0.0,
    )
```

---

## Tasks

1. Add BarData import from ib_interface.api.objects
2. Add HistoricalDataBar import from ibapi.protobuf.HistoricalDataBar_pb2
3. Implement bar_data_from_proto()
4. Handle volume as Decimal
5. Map wap to average field

---

## Git Commit

```bash
git commit -m "[PROTO-010] Implement bar_data_from_proto()

- Convert Protobuf bar to ib-interface BarData
- Handle volume as Decimal
- Map wap to average
"
```

---

## Acceptance Criteria

- Converts OHLCV fields correctly
- Volume is Decimal type
- Returns valid BarData dataclass
