# План работ (Codex) — ChatriX

## Milestone 0 — Каркас (готово)
- [x] Monorepo структура
- [x] Backend skeleton (FastAPI + Postgres)
- [x] Docker compose
- [x] Docs placeholders

## Milestone 1 — Auth & Accounts
- [ ] OAuth провайдеры: Google / Apple / Yandex / Telegram / Discord / TikTok
- [ ] Привязка нескольких провайдеров к одному user
- [ ] JWT sessions + refresh

## Milestone 2 — Plans/Entitlements (12 тарифов)
- [ ] Таблицы: plans, plan_limits, plan_entitlements
- [ ] Инициализация тарифов: ZERO, CORE, START, PRIME, ADVANCED, STUDIO, BUSINESS, BLD_DIALOGUE, BLD_MEDIA, BLD_DOCS, VIP, DEV
- [ ] Сервис policy engine: проверка прав/лимитов

## Milestone 3 — Wallet/Payments + FX
- [ ] Ledger (идемпотентность) и расчёт баланса
- [ ] Top-up провайдеры: Google Pay / Apple Pay / ЮMoney (контракты + заглушки)
- [ ] fx_rates: обновление курса ЦБ 1 раз/день и API latest
- [ ] Конвертация FX → RUB: курс ЦБ +5%

## Milestone 4 — Referrals (до 25 уровней)
- [ ] referral tree + rewards
- [ ] Условия начисления: платёж + ≥2 провайдера
- [ ] Хранить проценты по уровням в БД (конфиг)

## Milestone 5 — Chat (text)
- [ ] Чаты/сообщения
- [ ] AI-orchestrator

## Milestone 6 — Media
- [ ] Voice live
- [ ] Video avatar
- [ ] Image tools
- [ ] Video tools

## Milestone 7 — Sections Builder (Hobby/Study/Work)
- [ ] Создание разделов по брифу
- [ ] 3 раздела бесплатно, далее 300 ₽/3м
- [ ] UX-конфиг + AI-workflow

## Milestone 8 — Docs (файлы)
- [ ] Upload/Download + квоты
- [ ] Whitelist форматов из ТЗ
- [ ] Парсеры адаптерами (минимально: txt/md/csv/docx/pdf)

## Milestone 9 — Developer DevBox
- [ ] DEV add-on: Dev-Container
- [ ] infra_rates + формула стоимости
- [ ] Пакеты S/M/L

## Milestone 10 — Полировка
- [ ] UX polish, analytics, support
