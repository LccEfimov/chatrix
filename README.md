# ChatriX — Monorepo (Mobile + Backend)

This repository contains:
- `mobile/` — Flutter mobile app (Android first, iOS-ready)
- `backend/` — FastAPI + PostgreSQL backend
- `docs/` — product spec (TZ), Codex prompt, and runbook

## Quick start (dev)

### 1) Backend + Postgres (Docker)
```bash
cp backend/.env.example backend/.env
docker compose up --build
```
API: http://localhost:8000/docs

### 2) Mobile (Flutter)
This repo includes a minimal Flutter starter (`mobile/lib/main.dart`).
Create a full Flutter project (recommended) and copy `lib/` + `assets/` from this repo, or let Codex run `flutter create` and migrate files.

See `docs/CODEX_RUNBOOK.md`.
