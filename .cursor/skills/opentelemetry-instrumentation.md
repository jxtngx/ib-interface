# Skill: OpenTelemetry Instrumentation

Proficiency in instrumenting Python applications with OpenTelemetry.

## Competencies

- Understanding of OTel signals (logs, traces, metrics)
- Knowledge of OTel SDK and API separation
- Familiarity with LoggerProvider and LoggingHandler
- Understanding of TracerProvider and span context
- Knowledge of OTLP exporters (gRPC, HTTP)
- Experience with resource attributes and service naming

## Context

ib-interface uses OpenTelemetry for observability, enabling export to SigNoz and other OTel-compatible backends.

## Key Concepts

- OTel Logging Bridge connects Python logging to OTel
- BatchLogRecordProcessor for efficient export
- Resource attributes identify service in backends
- Trace context propagation for distributed tracing
