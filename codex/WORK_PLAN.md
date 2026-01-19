# ChatriX — WORK_PLAN для Codex (реалистичный, с Quality Gates)

Легенда статусов:
- `[x]` DONE (CI зелёный, тесты есть)
- `[-]` DONE‑STUB (функционал заглушкой, есть тесты заглушки, есть отдельный пункт на замену)
- `[ ]` TODO

## Quality Gates (нельзя обойти)
Перед началом **каждого** пункта и после выполнения:
- запуск `./scripts/ci.sh`
- если красно — фикс до зелёного

---

## Milestone 00 — Repository Excellence (обязательный фундамент)
- [x] `scripts/test_backend.sh` (pytest в Docker и/или локально)
- [x] `scripts/test_mobile.sh` (flutter analyze + flutter test в Docker)
- [x] `scripts/ci.sh` (backend tests + mobile tests; опционально build APK)
- [x] Добавить dev‑линтеры (backend: ruff/black) и команды `scripts/lint_backend.sh`, `scripts/fmt_backend.sh`
- [x] Обновить `README.md` (как гонять CI локально)

Acceptance:
- `./scripts/ci.sh` зелёный на чистой машине

---

## Milestone 01 — Mobile Foundation (сборка, дизайн‑система, навигация)
- [ ] Создать полноценный Flutter scaffold (`flutter create`), чтобы появились `android/`, gradle и т.д.
- [x] Подключить зависимости: `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `freezed`/`json_serializable` (по желанию)
- [x] Ввести архитектуру папок:
  - `lib/app/*` (boot, shell)
  - `lib/theme/*` (tokens, typography)
  - `lib/ui/components/*` (buttons/cards/inputs/sheets)
  - `lib/features/*` (auth, plans, wallet, referrals, chat, sections...)
  - `lib/api/*` (client, interceptors)
- [x] Дизайн‑система: tokens (цвет/типографика/радиусы/spacing/animation durations)
- [x] AppShell: обработка ошибок, snackbar/toast, loading overlay, offline banner
- [x] Навигация (go_router) + заглушки экранов
- [ ] Tests: 1 widget test + 1 golden test (AppShell)

Acceptance:
- `./scripts/test_mobile.sh` зелёный
- `./scripts/build_apk_docker.sh` даёт APK

---

## Milestone 02 — Auth UX + Sessions (ZERO после регистрации)
Backend статус:
- [x] Auth endpoints (JWT + refresh) и tests (sqlite)
- [-] OAuth provider adapters (сейчас упрощённые callbacks; заменить на real позже)

Mobile:
- [x] Экран Onboarding/Login (Material 3, красиво, анимация)
- [x] Social buttons (Google/Apple/Yandex/TG/Discord/TikTok) — пока STUB UI + wiring на backend контракт
- [x] Secure token storage + refresh flow
- [x] Экран “Профиль/Привязки” (link/unlink providers)
- [x] Логика ZERO:
  - после регистрации тариф ZERO
  - скрыть referral entrypoint

Tests:
- [x] widget tests: login UI states
- [x] integration test (smoke): login -> /me

---

## Milestone 03 — Plans/Entitlements + Paywall UX
Backend:
- [x] Plans/limits/entitlements + policy engine tests

Mobile:
- [x] Экран “Тарифы/Paywall” (12 тарифов, красиво)
- [x] Экран “Мой тариф и лимиты”
- [x] UI‑гейтинг функций по entitlements (сервер — источник истины)

Tests:
- [ ] golden: paywall
- [x] unit: entitlement gating mapper

---

## Milestone 04 — Wallet + TopUp + FX (Google Pay / Apple Pay / ЮMoney)
Backend:
- [x] Ledger + topup contracts + FX расчёт (ЦБ +5%) + tests
- [-] Реальная интеграция платежей (webhooks/подписи) — заменить позже

Mobile:
- [x] Экран “Баланс” (RUB, копейки) + история ledger
- [x] Пополнение: выбор провайдера, сумма, подтверждение (contract)
- [x] Экран “Курс ЦБ” (инфо: дата курса, +5%)

Tests:
- [x] widget: wallet screen states

---

## Milestone 05 — Referrals (до 25 уровней) + дерево
Backend:
- [x] Referral tree + rewards + tiers config in DB + tests

Mobile:
- [x] Экран Referrals:
  - скрыт для ZERO
  - ссылка/QR/код приглашения для платных
  - дерево до N уровней (пагинация)
  - rewards list
- [x] Возможность открыть чат с рефералом (по id)

Tests:
- [x] widget: referrals hidden for ZERO

---

## Milestone 06 — Chat (text) + AI Orchestrator (MVP)
Backend:
- [x] chats/messages endpoints + AI orchestrator stub provider + tests
- [-] Реальные AI провайдеры (OpenAI и др.) — заменить позже

Mobile:
- [x] Список чатов + создание чата
- [x] Экран чата:
  - streaming UI (если backend поддерживает), иначе polling
  - attachments entrypoint (будущие)
  - настройки чата (prompt, voice/video settings gated)
- [x] Красивые message bubbles + animations

Tests:
- [-] golden: chat screen (baseline pending)

---

## Milestone 07 — Voice (MVP) + Audio Tools
Backend:
- [x] voice session models/endpoints (если есть)
- [-] Реальный live voice SDK (Agora/WebRTC) — позже

Mobile:
- [x] Экран Voice:
  - старт/стоп сессии
  - лимиты по тарифу
  - выбор голоса (2 для старта)
- [x] Экран Audio Tools (карточки возможностей, gated)

Tests:
- [x] widget smoke for voice screen

---

## Milestone 08 — Video Avatar / Video Tools (MVP)
Backend:
- [x] video models/endpoints (если есть)
- [-] Реальная генерация/анимация — позже

Mobile:
- [ ] Экран Video:
  - список “video chats”
  - создание: title + media + voice + prompt
  - демо 10 сек для стартовых, unlimited для топ‑планов
- [ ] Экран Video Tools (gated)

---

## Milestone 09 — Storage/Files + DOCS whitelist
Backend:
- [x] files metadata + whitelist + parsers adapters (минимальные) + tests
- [-] Реальный S3/MinIO upload (init/complete) — заменить позже

Mobile:
- [ ] Экран Files:
  - загрузка (пока простой multipart) + список
  - квоты, занято/лимит
- [ ] Экран Docs:
  - выбор файла
  - preview (где возможно) и “AI summary/QA” (через backend)

---

## Milestone 10 — Sections Builder (Hobby/Study/Work)
Backend:
- [x] sections CRUD + pricing (3 free then paid) + tests

Mobile:
- [ ] Экран Hobby/Study/Work:
  - библиотека готовых UI‑элементов
  - создание раздела через бриф (form)
  - paywall на 4+ раздел
  - список разделов + запуск workflow

---

## Milestone 11 — Developer DevBox (платный add‑on)
Backend:
- [x] devbox pricing + packages + tests
- [-] Реальное управление контейнерами (docker/k8s) — позже

Mobile:
- [ ] Экран Work (DEV):
  - DevBox packages
  - выбор стека
  - старт/стоп/status
  - биллинг add‑on

---

## Milestone 12 — Replace STUB With REAL (интеграции)
- [ ] OAuth real flows (Google/Apple/Yandex/TG/Discord/TikTok)
- [ ] Payments real (Google Pay/Apple Pay/ЮMoney): подписи, webhooks, idempotency, sandbox/prod
- [ ] AI providers real (OpenAI + optional others): metering, retries, rate limits
- [ ] S3/MinIO upload real + signed URLs
- [ ] Voice/Video real (Agora/WebRTC) + device permissions

---

## Milestone 13 — Release readiness
- [ ] End‑to‑end smoke tests (backend+mobile)
- [ ] Crash reporting (Sentry) — optional decision
- [ ] Observability (structured logs, correlation ids)
- [ ] Android release pipeline (versioning, keystore instructions)
