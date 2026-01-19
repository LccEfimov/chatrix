# ChatriX — Architecture (high-level)

This file is ADR-lite architecture overview. Codex must keep it updated as modules appear.

- Mobile: Flutter app (navigation, state management, design system)
- Backend: FastAPI + PostgreSQL, modular services
- Storage: S3-compatible object storage
- Workers: background jobs for media and AI pipelines

## Service boundaries
- Auth & Accounts
- Plans & Policy (entitlements/limits)
- Billing
- AI Orchestrator
- Chat
- Media
- Storage
- Docs & File Processing
- Referrals
- Sections Builder (Hobby/Study/Work)
- Developer DevBox
