# ChatriX — Conventions

## Общие правила
- Python 3.12
- Mobile: Flutter (Android first)
- Каждый шаг = маленькая завершённая итерация, один коммит.
- Любые допущения фиксируются в `docs/DECISIONS.md`.

## Backend
- Framework: FastAPI
- ORM: SQLAlchemy 2 + Alembic
- Schemas: Pydantic v2
- Tests: pytest
- Форматирование/линт: ruff + black (см. `backend/requirements-dev.txt`)

Команды:
- tests: `./scripts/test_backend.sh`
- lint: `./scripts/lint_backend.sh`
- format: `./scripts/fmt_backend.sh`

## Mobile
- State: Riverpod
- Navigation: go_router
- HTTP: dio
- Secure storage: flutter_secure_storage
- Tests: flutter test + golden tests на ключевые экраны

Команды:
- scaffold: `./scripts/bootstrap_flutter_project.sh`
- tests: `./scripts/test_mobile.sh`
- build APK: `./scripts/build_apk_docker.sh`

## CI
- `./scripts/ci.sh` — обязательный gate перед отметкой пункта как DONE.

## Git
- Branch naming: `codex/<milestone>-<feature>`
- PR template должен содержать:
  - summary
  - migrations (если были)
  - tests output (команды + итог)
  - rollback notes (если менялась схема)
