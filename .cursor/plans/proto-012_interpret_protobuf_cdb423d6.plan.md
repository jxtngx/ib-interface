---
name: PROTO-012 Interpret Protobuf
overview: Implement _interpret_protobuf() method and update interpret() to route protobuf messages (ID 0) to the new handler.
todos:
  - id: update-interpret
    content: Update interpret() to check msgId == 0
    status: pending
  - id: add-routing
    content: Route msgId 0 to _interpret_protobuf()
    status: pending
  - id: impl-interpret-proto
    content: Implement _interpret_protobuf() method
    status: pending
  - id: extract-fields
    content: Extract proto_type_id and proto_data
    status: pending
  - id: commit
    content: Git commit with [PROTO-012]
    status: pending
isProject: false
---

# PROTO-012: Implement _interpret_protobuf() routing

**Owner**: Protocol Developer  
**Effort**: 1 day  
**Depends On**: PROTO-011

---

## File

[src/ib_interface/api/decoder.py](src/ib_interface/api/decoder.py)

---

## Implementation

```python
def interpret(self, fields):
    """
    Decode fields and invoke corresponding wrapper method.
    
    Automatically detects protocol type and routes appropriately.
    """
    try:
        msgId = int(fields[0])
        
        if msgId == PROTOBUF_MSG_ID:
            # Protobuf message - extract type and decode
            self._interpret_protobuf(fields)
        else:
            # Legacy string protocol
            handler = self.handlers.get(msgId)
            if handler:
                handler(fields)
            else:
                self.logger.warning(f"Unknown message ID: {msgId}")
                
    except Exception:
        self.logger.exception(f"Error handling fields: {fields}")

def _interpret_protobuf(self, fields):
    """
    Handle Protobuf-encoded messages.
    
    Fields format: ['0', proto_type_id, proto_bytes...]
    """
    try:
        proto_type_id = int(fields[1])
        proto_data = fields[2] if len(fields) > 2 else b''
        
        handler = self.proto_handlers.get(proto_type_id)
        if handler:
            handler(proto_data)
        else:
            self.logger.warning(f"Unknown protobuf type: {proto_type_id}")
            
    except Exception:
        self.logger.exception(f"Error handling protobuf message")
```

---

## Tasks

1. Update interpret() to check for msgId == 0
2. Route msgId 0 to _interpret_protobuf()
3. Implement _interpret_protobuf() method
4. Extract proto_type_id and proto_data from fields
5. Route to proto_handlers

---

## Git Commit

```bash
git commit -m "[PROTO-012] Implement _interpret_protobuf() routing

- Update interpret() to detect protobuf (msgId 0)
- Add _interpret_protobuf() for proto message routing
- Extract type ID and data from fields
"
```

---

## Acceptance Criteria

- interpret() routes msgId 0 to _interpret_protobuf()
- _interpret_protobuf() extracts type ID and data
- Unknown types logged as warning
