---
name: OBS-002 Telemetry Module
overview: Create telemetry.py with OTel logging bridge that connects Python's standard logging to OpenTelemetry for export to SigNoz.
todos:
  - id: create-file
    content: Create src/ib_interface/telemetry.py
    status: pending
  - id: impl-setup
    content: Implement setup_telemetry() function
    status: pending
  - id: impl-shutdown
    content: Implement shutdown_telemetry() function
    status: pending
  - id: add-exports
    content: Add to package __init__.py exports
    status: pending
  - id: commit
    content: Git commit with [OBS-002]
    status: pending
  - id: update-sprint
    content: Update sprint_1_modernization_e041af8d.plan.md to mark OBS-002 completed
    status: pending
isProject: false
---

# OBS-002: Create telemetry.py with OTel logging bridge

**Owner**: Observability Engineer  
**Effort**: 1 day  
**Depends On**: OBS-001

---

## File

[src/ib_interface/telemetry.py](src/ib_interface/telemetry.py) (new)

---

## Implementation

```python
"""
OpenTelemetry configuration for ib-interface observability.

Bridges Python's standard logging to OTel for export to SigNoz
or other OTLP-compatible backends.
"""

import logging
from typing import Optional

from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor, ConsoleLogExporter
from opentelemetry.sdk.resources import Resource, SERVICE_NAME
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter


_logger_provider: Optional[LoggerProvider] = None


def setup_telemetry(
    service_name: str = "ib-interface",
    otlp_endpoint: Optional[str] = None,
) -> LoggerProvider:
    """
    Configure OTel-compatible logging.
    
    Args:
        service_name: Service identifier in SigNoz
        otlp_endpoint: OTLP collector endpoint (e.g., "localhost:4317")
                       If None, logs to console in OTel format.
    
    Returns:
        Configured LoggerProvider
    """
    global _logger_provider
    
    resource = Resource.create({SERVICE_NAME: service_name})
    _logger_provider = LoggerProvider(resource=resource)
    
    if otlp_endpoint:
        exporter = OTLPLogExporter(endpoint=otlp_endpoint, insecure=True)
    else:
        exporter = ConsoleLogExporter()
    
    _logger_provider.add_log_record_processor(
        BatchLogRecordProcessor(exporter)
    )
    
    handler = LoggingHandler(logger_provider=_logger_provider)
    logging.getLogger("ib_insync").addHandler(handler)
    
    return _logger_provider


def shutdown_telemetry():
    """Flush and shutdown telemetry."""
    global _logger_provider
    if _logger_provider:
        _logger_provider.shutdown()
        _logger_provider = None
```

---

## Tasks

1. Create `src/ib_interface/telemetry.py`
2. Implement `setup_telemetry()` function
3. Implement `shutdown_telemetry()` function
4. Add to package exports in `__init__.py`

---

## Git Commit

```bash
git commit -m "[OBS-002] Create telemetry.py with OTel logging bridge

- setup_telemetry() configures OTel LoggerProvider
- Supports OTLP export to SigNoz or console fallback
- Bridges ib_insync logger hierarchy to OTel
"
```

---

## Acceptance Criteria

- `telemetry.py` exists with setup/shutdown functions
- Logs from `ib_insync.*` loggers flow to OTel
- Works with and without OTLP endpoint (console fallback)
