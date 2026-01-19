# Architectural Decisions (ADR-lite)

Use this file to record decisions Codex makes when the TZ is ambiguous.

Template:
- Date:
- Decision:
- Context:
- Options considered:
- Why:
- Consequences:

- Date: 2026-01-19
- Decision: Implemented OAuth callbacks as stubbed API accepting provider_user_id + email, issuing JWT access/refresh tokens stored with refresh JTI.
- Context: Milestone 1 requires OAuth provider support and JWT sessions, but full provider integrations are out of scope for the skeleton.
- Options considered: (1) Full OAuth flows per provider, (2) Stub callbacks with provider identifiers and email payloads.
- Why: Keeps API contracts testable and supports linking multiple providers without introducing external dependencies yet.
- Consequences: Real OAuth flows must replace the stubbed callback inputs before production, and email becomes required in the stubbed callback.
