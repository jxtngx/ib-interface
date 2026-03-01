---
name: PROTO-002 Codec Encode
overview: Implement ProtobufCodec.encode() static method that frames protobuf messages for TWS socket transmission.
todos:
  - id: add-imports
    content: Add struct, TypeVar, Message imports
    status: pending
  - id: add-constant
    content: Define PROTOBUF_MSG_ID = 0
    status: pending
  - id: create-class
    content: Create ProtobufCodec class with docstring
    status: pending
  - id: impl-encode
    content: Implement encode() static method
    status: pending
  - id: commit
    content: Git commit with [PROTO-002]
    status: pending
isProject: false
---

# PROTO-002: Implement ProtobufCodec.encode()

**Owner**: Protocol Developer  
**Effort**: 1 day  
**Depends On**: PROTO-001

---

## File

[src/ib_interface/protobuf/codec.py](src/ib_interface/protobuf/codec.py)

---

## Implementation

```python
import struct
from typing import TypeVar
from google.protobuf.message import Message

PROTOBUF_MSG_ID = 0

class ProtobufCodec:
    """Encode and decode Protobuf messages for TWS API."""
    
    @staticmethod
    def encode(msg: Message, msg_type_id: int) -> bytes:
        """
        Encode a Protobuf message for transmission to TWS.
        
        Frame format: [length:4][msgId:1][typeId:2][payload:n]
        """
        payload = msg.SerializeToString()
        header = struct.pack('>IBH', len(payload) + 3, PROTOBUF_MSG_ID, msg_type_id)
        return header + payload
```

---

## Tasks

1. Add imports: `struct`, `TypeVar`, `Message`
2. Define `PROTOBUF_MSG_ID = 0` constant
3. Create `ProtobufCodec` class with docstring
4. Implement `encode()` static method
5. Add type hints

---

## Git Commit

```bash
git commit -m "[PROTO-002] Implement ProtobufCodec.encode()

- Add struct-based framing for TWS protocol
- Frame format: [length:4][msgId:1][typeId:2][payload:n]
"
```

---

## Acceptance Criteria

- Encodes protobuf message with correct header
- Returns bytes ready for socket transmission
- Type hints present

