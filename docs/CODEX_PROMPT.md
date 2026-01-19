ТЫ — ChatGPT Codex в режиме работы с репозиторием. Твоя цель: довести проект **ChatriX** до production-ready системы (mobile + backend) строго по ТЗ.

# 0) Порядок старта (обязателен)
Сразу прочитай файлы:
- docs/TZ.md
- docs/CODEX_RUNBOOK.md
- docs/ARCHITECTURE.md
- docs/DECISIONS.md
- docs/SECTION_BRIEF_TEMPLATE.md
- codex/WORK_PLAN.md
- codex/CONVENTIONS.md

# 1) Железные правила
- docs/TZ.md — единственный источник истины.
- Не задавай вопросов, если можешь выбрать разумный дефолт. Любое допущение фиксируй в docs/DECISIONS.md.
- Работай итерациями: 1 PR/коммит = 1 завершённый модуль.
- Каждый PR/коммит обязан включать:
  - миграции БД (если меняется схема),
  - тесты,
  - обновление codex/WORK_PLAN.md (галочки/статусы),
  - обновление docs/ARCHITECTURE.md при архитектурных изменениях.
- После изменений всегда прогоняй проверки:
  - backend: pytest
  - docker compose up --build (health)
- Секреты не коммить: только через env и .env.example.
- Все тарифные ограничения должны проверяться на сервере (policy engine).

# 2) Рекомендуемый стек (если не противоречит ТЗ)
Mobile:
- Flutter (Material 3)
- Состояние: Riverpod
- Навигация: go_router
- HTTP: dio
- Secure storage: flutter_secure_storage

Backend:
- Python + FastAPI
- PostgreSQL
- ORM: SQLAlchemy 2.0 + Alembic
- Тесты: pytest
- Фоновые задачи: Celery + Redis (если выберешь другое, зафиксируй)
- Объектное хранилище: S3-compatible (dev: MinIO)

# 3) Домены (обязательные)
- Auth (OAuth провайдеры)
- Plans/Entitlements (тарифы, лимиты, права)
- Payments/Wallet (пополнение, внутренний ledger)
- FX Rates (курс ЦБ + обновление раз в день)
- Referrals (дерево и начисления до 25 уровней)
- Storage/Files (квоты и S3)
- AI Orchestrator (провайдеры/маршрутизация/учёт использования)
- Chat (text)
- Voice (audio)
- Video (avatar/chat)
- Tools (audio/image/video)
- Sections Builder (Hobby/Study/Work)
- Developer DevBox (платный контейнер)

# 4) Ключевые требования ChatriX, которые нельзя пропустить
## 4.1 Тарифы
Тарифов всего 12 (коды см. в docs/TZ.md). **ZERO** назначается при регистрации и:
- не показывает реферальную ссылку;
- не участвует в реферальной программе.

## 4.2 Реферальная программа
- Выплаты до 25 уровня.
- Начисления только если: реферал оплатил/сменил тариф на платный и у него ≥2 привязанных провайдера.
- Проценты по уровням для каждого тарифа хранить как конфиг в БД (не хардкодить в коде).

## 4.3 Конструкторы (3 типа)
- Builder • Dialogue (текст+аудио)
- Builder • Media (текст+аудио+фото+видео)
- Builder • Docs (доки/файлы + мультимодал)
Ценообразование: база 700 ₽/3м + сумма модулей + пакеты хранилища + платные разделы + add-ons.

## 4.4 Разделы в Hobby/Study/Work
- Экран строится из подготовленных UI-элементов.
- Разделы создаются по запросу пользователя.
- 3 раздела бесплатно (суммарно на Hobby+Study+Work), далее 300 ₽/3 месяца за раздел.
- Перед созданием раздела обязательно требуй бриф (docs/SECTION_BRIEF_TEMPLATE.md).
- Раздел — это UX-конфигурация + AI-workflow, использующий AI API как функциональный движок.

## 4.5 Пополнение баланса
- Способы: Google Pay, Apple Pay, ЮMoney.
- Внутренний баланс: RUB (копейки).
- Если платёж в USD/другой валюте: считать по курсу ЦБ за день +5%.
- Курс ЦБ обновлять в БД раз в день.

## 4.6 Developer DevBox
- Только для тарифа DEV, как платный add-on в разделе Work.
- Пользователь выбирает стек контейнера из списка.
- Цена: пакеты S/M/L и/или формула через infra_rates (см. ТЗ).

## 4.7 Docs (форматы)
Поддерживаемые расширения — whitelist из ТЗ. Парсеры/конвертеры должны быть изолированы адаптерами.

# 5) API базовый путь
Используй базовый путь API: **/v1** (как в текущем каркасе).

Минимальные эндпойнты (скелеты внедрять по milestone):
Auth:
- POST /v1/auth/oauth/{provider}/start
- POST /v1/auth/oauth/{provider}/callback
- POST /v1/auth/refresh
- POST /v1/auth/logout
- GET  /v1/me
- POST /v1/me/link/{provider}
- DELETE /v1/me/link/{provider}

Plans:
- GET /v1/plans
- POST /v1/subscriptions/activate
- GET /v1/subscriptions/me

Wallet/Payments:
- GET  /v1/wallet/me
- GET  /v1/wallet/ledger
- POST /v1/wallet/topup/init
- POST /v1/wallet/topup/confirm
- POST /v1/payments/webhook/{provider}

FX:
- GET /v1/fx/rates/latest

Referrals:
- GET /v1/referrals/me
- GET /v1/referrals/tree
- GET /v1/referrals/rewards

Storage:
- POST /v1/files/upload/init
- POST /v1/files/upload/complete
- GET  /v1/files
- DELETE /v1/files/{id}

Sections:
- POST /v1/sections
- GET  /v1/sections
- GET  /v1/sections/{id}
- POST /v1/sections/{id}/run

DevBox:
- POST /v1/devbox/start
- POST /v1/devbox/stop
- GET  /v1/devbox/status

# 6) Как выполнять работу
- Иди по codex/WORK_PLAN.md сверху вниз.
- В каждом milestone делай: backend API + минимальный UI-скелет на mobile + тесты + миграции.
- Любые новые таблицы сопровождай индексами и ограничениями.
- В конце milestone обновляй codex/WORK_PLAN.md.

# 7) Definition of Done
Готовность milestone:
- docker compose поднимается без ошибок
- backend тесты проходят
- mobile собирается и показывает нужный экран/флоу
- документация и решения обновлены
