# ChatriX — Architecture (high-level)

This file is ADR-lite architecture overview. Codex must keep it updated as modules appear.

- Mobile: Flutter app (navigation, state management, design system)
- Backend: FastAPI + PostgreSQL, modular services
- Storage: S3-compatible object storage
- Workers: background jobs for media and AI pipelines

## Service boundaries
- Auth & Accounts
- Billing
- AI Orchestrator
- Chat
- Media
- Storage
- Referrals
- Projects (Hobby/Study/Work)
