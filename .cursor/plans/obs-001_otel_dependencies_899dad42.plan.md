---
name: OBS-001 OTel Dependencies
overview: Add OpenTelemetry dependencies to pyproject.toml for logging, tracing, and OTLP export to SigNoz.
todos:
  - id: add-api
    content: Add opentelemetry-api>=1.20.0
    status: pending
  - id: add-sdk
    content: Add opentelemetry-sdk>=1.20.0
    status: pending
  - id: add-otlp
    content: Add opentelemetry-exporter-otlp>=1.20.0
    status: pending
  - id: sync
    content: Run uv sync to update lock
    status: pending
  - id: commit
    content: Git commit with [OBS-001]
    status: pending
  - id: update-sprint
    content: Update sprint_1_modernization_e041af8d.plan.md to mark OBS-001 completed
    status: pending
isProject: false
---

# OBS-001: Add OpenTelemetry dependencies to pyproject.toml

**Owner**: Observability Engineer  
**Effort**: 0.5 day  
**Depends On**: None

---

## File

[pyproject.toml](pyproject.toml)

---

## Changes

Add OTel packages to dependencies:

```toml
dependencies = [
    "matplotlib>=3.10.8",
    "numpy>=2.4.2",
    "pandas>=3.0.1",
    "opentelemetry-api>=1.20.0",
    "opentelemetry-sdk>=1.20.0",
    "opentelemetry-exporter-otlp>=1.20.0",
]
```

---

## Tasks

1. Add `opentelemetry-api>=1.20.0` to dependencies
2. Add `opentelemetry-sdk>=1.20.0` to dependencies
3. Add `opentelemetry-exporter-otlp>=1.20.0` to dependencies
4. Run `uv sync` to update lock file

---

## Git Commit

```bash
git commit -m "[OBS-001] Add OpenTelemetry dependencies to pyproject.toml

- opentelemetry-api: Core OTel interfaces
- opentelemetry-sdk: SDK implementation
- opentelemetry-exporter-otlp: Export to SigNoz/collectors
"
```

---

## Acceptance Criteria

- OTel packages listed in pyproject.toml
- `uv.lock` updated
- `from opentelemetry import trace` imports successfully
