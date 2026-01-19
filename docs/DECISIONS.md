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

- Date: 2026-01-19
- Decision: Store the current subscription as `users.plan_code` and expose `/subscriptions/activate` as a direct plan switch for Milestone 2.
- Context: Milestone 2 requires plan tables and subscription endpoints, but does not specify a full subscription history schema.
- Options considered: (1) Dedicated subscriptions table with history, (2) Current plan stored on user for the skeleton.
- Why: Keeps the milestone lightweight while still enforcing plan-based policy checks in the backend.
- Consequences: A future milestone must introduce a proper subscription history table and migrate `users.plan_code` if needed.
