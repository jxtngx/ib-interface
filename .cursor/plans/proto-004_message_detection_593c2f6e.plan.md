---
name: PROTO-004 Message Detection
overview: Implement ProtobufCodec.is_protobuf_message() to detect protobuf vs legacy protocol by checking message ID 0.
todos:
  - id: impl-detection
    content: Implement is_protobuf_message() method
    status: pending
  - id: add-docstring
    content: Document message ID 0 convention
    status: pending
  - id: update-exports
    content: Update protobuf/__init__.py exports
    status: pending
  - id: commit
    content: Git commit with [PROTO-004]
    status: pending
isProject: false
---

# PROTO-004: Implement ProtobufCodec.is_protobuf_message()

**Owner**: Protocol Developer  
**Effort**: 0.5 day  
**Depends On**: PROTO-002, PROTO-003

---

## File

[src/ib_interface/protobuf/codec.py](src/ib_interface/protobuf/codec.py)

---

## Implementation

```python
class ProtobufCodec:
    # ... existing encode(), decode() ...
    
    @staticmethod
    def is_protobuf_message(fields: list) -> bool:
        """
        Detect if incoming fields represent a Protobuf message.
        
        The TWS API uses message ID 0 to indicate protobuf format.
        """
        return len(fields) > 0 and fields[0] == '0'
```

---

## Tasks

1. Implement `is_protobuf_message()` static method
2. Document message ID 0 convention in docstring
3. Update `protobuf/__init__.py` exports

---

## Git Commit

```bash
git commit -m "[PROTO-004] Implement ProtobufCodec.is_protobuf_message()

- Detect protobuf vs legacy protocol by message ID 0
"
```

---

## Acceptance Criteria

- Returns True for `['0', ...]` fields
- Returns False for legacy message IDs
- Handles empty list safely
