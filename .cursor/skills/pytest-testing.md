# Skill: pytest Testing

Proficiency in pytest for Python testing.

## Competencies

- Understanding of test discovery and naming conventions
- Knowledge of fixtures and conftest.py
- Familiarity with parametrized tests
- Understanding of markers (skip, integration, etc.)
- Knowledge of assertion introspection
- Experience with pytest plugins

## Context

ib-interface uses pytest with pytest-asyncio for testing. Tests must work without live TWS connections using mocks and fixtures.

## Key Patterns

- `test_*.py` file naming
- `@pytest.fixture` for reusable setup
- `@pytest.mark.asyncio` for async tests
- `@pytest.mark.integration` for optional tests
