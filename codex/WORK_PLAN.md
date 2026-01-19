# План работ (Codex) — ChatriX

## Milestone 0 — Каркас (готово)
- [x] Monorepo структура
- [x] Backend skeleton (FastAPI + Postgres)
- [x] Docker compose
- [x] Docs placeholders

## Milestone 1 — Auth & Accounts
- [x] OAuth провайдеры: Google / Apple / Yandex / Telegram / Discord / TikTok
- [x] Привязка нескольких провайдеров к одному user
- [x] JWT sessions + refresh

## Milestone 2 — Plans/Entitlements (12 тарифов)
- [x] Таблицы: plans, plan_limits, plan_entitlements
- [x] Инициализация тарифов: ZERO, CORE, START, PRIME, ADVANCED, STUDIO, BUSINESS, BLD_DIALOGUE, BLD_MEDIA, BLD_DOCS, VIP, DEV
- [x] Сервис policy engine: проверка прав/лимитов

## Milestone 3 — Wallet/Payments + FX
- [x] Ledger (идемпотентность) и расчёт баланса
- [x] Top-up провайдеры: Google Pay / Apple Pay / ЮMoney (контракты + заглушки)
- [x] fx_rates: обновление курса ЦБ 1 раз/день и API latest
- [x] Конвертация FX → RUB: курс ЦБ +5%

## Milestone 4 — Referrals (до 25 уровней)
- [x] referral tree + rewards
- [x] Условия начисления: платёж + ≥2 провайдера
- [x] Хранить проценты по уровням в БД (конфиг)

## Milestone 5 — Chat (text)
- [x] Чаты/сообщения
- [x] AI-orchestrator

## Milestone 6 — Media
- [x] Voice live
- [x] Video avatar
- [x] Image tools
- [x] Video tools

## Milestone 7 — Sections Builder (Hobby/Study/Work)
- [x] Создание разделов по брифу
- [x] 3 раздела бесплатно, далее 300 ₽/3м
- [x] UX-конфиг + AI-workflow

## Milestone 8 — Docs (файлы)
- [x] Upload/Download + квоты
- [x] Whitelist форматов из ТЗ
- [x] Парсеры адаптерами (минимально: txt/md/csv/docx/pdf)

## Milestone 9 — Developer DevBox
- [x] DEV add-on: Dev-Container
- [x] infra_rates + формула стоимости
- [x] Пакеты S/M/L

## Milestone 10 — Полировка
- [ ] UX polish, analytics, support
