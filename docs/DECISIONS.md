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

- Date: 2026-01-19
- Decision: Implemented wallet ledger/top-up as stubbed payment flow with idempotency keys, and FX rates stored in `fx_rates` with manual upsert helper.
- Context: Milestone 3 requires ledger-based balance, top-up providers, and daily CBR FX rates, but no scheduler is defined.
- Options considered: (1) Full payment gateway integrations with background jobs, (2) Stub payment/top-up records with explicit API contracts and idempotent ledger entries.
- Why: Keeps the milestone testable with clear API contracts while leaving room for provider-specific integrations and scheduled FX updates.
- Consequences: A future milestone must wire scheduled FX updates and real provider callbacks to move top-ups from pending to succeeded.

- Date: 2026-01-19
- Decision: Modeled referrals with `users.referrer_id` adjacency and exposed referral codes as the user's UUID in the stubbed referral link.
- Context: Milestone 4 requires a referral tree, rewards, and stored tier percentages, but does not define link encoding or referral graph schema.
- Options considered: (1) Separate referral link table with generated codes, (2) adjacency list on users with UUID-based code.
- Why: Keeps the tree traversal simple and allows deterministic referral links without extra tables.
- Consequences: If marketing requires short/rotatable codes, a dedicated referral code table will be introduced and backfilled.
