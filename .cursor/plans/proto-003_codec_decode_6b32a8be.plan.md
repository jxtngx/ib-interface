---
name: PROTO-003 Codec Decode
overview: Implement ProtobufCodec.decode() static method that deserializes protobuf bytes into typed message objects.
todos:
  - id: add-type-import
    content: Add Type import from typing
    status: pending
  - id: add-typevar
    content: Define T = TypeVar('T', bound=Message)
    status: pending
  - id: impl-decode
    content: Implement decode() static method
    status: pending
  - id: error-handling
    content: Handle ParseFromString errors
    status: pending
  - id: commit
    content: Git commit with [PROTO-003]
    status: pending
isProject: false
---

# PROTO-003: Implement ProtobufCodec.decode()

**Owner**: Protocol Developer  
**Effort**: 1 day  
**Depends On**: PROTO-001

---

## File

[src/ib_interface/protobuf/codec.py](src/ib_interface/protobuf/codec.py)

---

## Implementation

```python
from typing import Type

T = TypeVar('T', bound=Message)

class ProtobufCodec:
    # ... existing encode() ...
    
    @staticmethod
    def decode(data: bytes, msg_class: Type[T]) -> T:
        """
        Decode a Protobuf message received from TWS.
        
        Args:
            data: Raw protobuf bytes (after framing removed)
            msg_class: The protobuf message class to decode into
        """
        msg = msg_class()
        msg.ParseFromString(data)
        return msg
```

---

## Tasks

1. Add `Type` import from typing
2. Define `T = TypeVar('T', bound=Message)`
3. Implement `decode()` static method
4. Handle ParseFromString errors gracefully

---

## Git Commit

```bash
git commit -m "[PROTO-003] Implement ProtobufCodec.decode()

- Generic decode for any protobuf message type
- Uses TypeVar for type-safe return
"
```

---

## Acceptance Criteria

- Decodes bytes to correct message type
- Generic type parameter works
- Handles malformed data without crash
