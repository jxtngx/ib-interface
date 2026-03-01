# Skill: Python Dataclasses

Proficiency in Python dataclasses for structured data.

## Competencies

- Understanding of @dataclass decorator and options
- Knowledge of field defaults and default_factory
- Familiarity with type hints and Optional types
- Understanding of dataclass inheritance
- Knowledge of frozen vs mutable dataclasses
- Experience with dataclass serialization patterns

## Context

ib-interface uses dataclasses for all API objects (Order, Contract, BarData, etc.), providing type safety and immutability where appropriate.

## Key Patterns

- Default values for optional fields
- UNSET_* constants for "not set" semantics
- Field ordering for backwards compatibility
