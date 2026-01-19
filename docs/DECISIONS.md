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

- Date: 2026-01-20
- Decision: Implemented Milestone 5 chat flows with persisted chat/message tables and a stub AI orchestrator provider ("stub") that returns deterministic placeholder replies.
- Context: Milestone 5 requires chat + AI orchestrator, but no concrete provider integrations are specified yet.
- Options considered: (1) Integrate a real provider immediately, (2) Stub the orchestrator with a configurable provider table and placeholder responses.
- Why: Keeps API contracts and storage ready while allowing future provider integrations without schema changes.
- Consequences: Real provider adapters and usage tracking must replace the stub responses in a future milestone.

- Date: 2026-01-20
- Decision: Sections beyond the free 3 are created with a stored fee (300 ₽ / 3 months) and a note indicating payment is required; no payment capture occurs in Milestone 7.
- Context: Milestone 7 requires enforcing the free section quota and pricing, but there is no dedicated billing flow for section add-ons yet.
- Options considered: (1) Block creation without immediate payment, (2) Allow creation while recording the fee for later billing.
- Why: Keeps API usable while preserving pricing metadata for later billing integration.
- Consequences: Billing enforcement must be added to prevent unpaid premium sections in production.

- Date: 2026-01-20
- Decision: Implemented Docs uploads as a stubbed storage flow with `files` metadata, S3-style placeholder paths, and parser adapters returning placeholder text for txt/md/csv/docx/pdf. Storage quota enforcement uses the `storage_bytes` plan limit when configured; missing limits are treated as unlimited.
- Context: Milestone 8 requires upload/download, whitelist enforcement, and parser adapters, but no object storage integration or parsing libraries are defined yet.
- Options considered: (1) Integrate real S3 + document parsers now, (2) Stub storage paths and adapters while preserving schema/API contracts.
- Why: Keeps API contracts and quota logic testable without external dependencies, while making the adapters explicit for later replacement.
- Consequences: Real object storage and parser implementations must replace placeholders, and storage limits should be populated in plan limits before production.

- Date: 2026-01-20
- Decision: Seeded DevBox infra rates, packages (S/M/L), and stack options (Python/Node.js/Go) in the database; DevBox pricing uses a 30-day package duration (720 hours) with disk costs prorated by duration_days/30 and zero default egress. Margin percent applies to the subtotal after platform fee and resource costs.
- Context: Milestone 9 requires infra_rates, package bundles, and a pricing formula, but the TZ does not specify default rate values, hours assumptions, or stack presets.
- Options considered: (1) Hardcode defaults in service code, (2) seed configurable defaults in DB and compute pricing dynamically.
- Why: Keeps pricing and stack selection configurable while still allowing immediate API usage and testing.
- Consequences: Real rates and stack catalogs must be updated in production to match infrastructure costs.

- Date: 2026-01-21
- Decision: Deferred adding Flutter golden tests because binary artifacts are not supported in this workflow.
- Context: Milestone 01 requests a golden test, but the environment/user instructions prohibit committing binary files.
- Options considered: (1) Commit binary golden images, (2) skip golden tests and document the gap.
- Why: The repository cannot accept binary test assets, so golden tests would be impossible to store or review.
- Consequences: Golden tests must be added later in an environment that supports binary artifacts.
