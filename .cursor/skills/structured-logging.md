# Skill: Structured Logging

Proficiency in structured logging patterns for observability.

## Competencies

- Understanding of structured vs unstructured logs
- Knowledge of log levels and severity semantics
- Familiarity with contextual attributes (request ID, user ID)
- Understanding of log correlation with traces
- Experience with log sampling strategies
- Knowledge of PII handling in logs

## Context

ib-interface uses structured logging to enable effective querying, filtering, and correlation in SigNoz.

## Key Patterns

- Include contextual attributes (orderId, reqId, conId)
- Use consistent field names across components
- Log at appropriate severity levels
- Avoid logging sensitive data (account numbers, credentials)
