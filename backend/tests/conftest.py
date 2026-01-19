import os
import sys
from collections.abc import Generator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.append(str(ROOT_DIR))

os.environ.setdefault("DATABASE_URL", "sqlite+pysqlite:///:memory:")
os.environ.setdefault("JWT_SECRET", "test-secret")
os.environ.setdefault("OAUTH_GOOGLE_CLIENT_ID", "test-google-client")
os.environ.setdefault("OAUTH_GOOGLE_CLIENT_SECRET", "test-google-secret")
os.environ.setdefault("OAUTH_APPLE_CLIENT_ID", "test-apple-client")
os.environ.setdefault("OAUTH_APPLE_CLIENT_SECRET", "test-apple-secret")
os.environ.setdefault("OAUTH_YANDEX_CLIENT_ID", "test-yandex-client")
os.environ.setdefault("OAUTH_YANDEX_CLIENT_SECRET", "test-yandex-secret")
os.environ.setdefault("OAUTH_TELEGRAM_CLIENT_ID", "test-telegram-client")
os.environ.setdefault("OAUTH_TELEGRAM_CLIENT_SECRET", "test-telegram-secret")
os.environ.setdefault("OAUTH_TELEGRAM_AUTH_URL", "https://telegram.example/auth")
os.environ.setdefault("OAUTH_TELEGRAM_TOKEN_URL", "https://telegram.example/token")
os.environ.setdefault("OAUTH_TELEGRAM_USERINFO_URL", "https://telegram.example/userinfo")
os.environ.setdefault("OAUTH_DISCORD_CLIENT_ID", "test-discord-client")
os.environ.setdefault("OAUTH_DISCORD_CLIENT_SECRET", "test-discord-secret")
os.environ.setdefault("OAUTH_TIKTOK_CLIENT_ID", "test-tiktok-client")
os.environ.setdefault("OAUTH_TIKTOK_CLIENT_SECRET", "test-tiktok-secret")

from app.api.deps import get_db  # noqa: E402
from app.api.v1.endpoints import auth as auth_endpoints  # noqa: E402
from app.db.base import Base  # noqa: E402
from app.main import create_app  # noqa: E402
from app.models import (  # noqa: F401, E402
    ai_provider,
    analytics_event,
    auth_session,
    chat,
    chat_message,
    devbox_package,
    devbox_rate,
    devbox_session,
    devbox_stack,
    file,
    fx_rate,
    oauth_account,
    oauth_state,
    plan,
    plan_entitlement,
    plan_limit,
    referral_reward,
    referral_tier,
    section,
    support_ticket,
    user,
    wallet_ledger,
    wallet_topup,
)
from app.services import oauth as oauth_service  # noqa: E402
from app.services.oauth import OAuthProfile  # noqa: E402


@pytest.fixture()
def db_session() -> Generator[Session, None, None]:
    engine = create_engine(
        "sqlite+pysqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    try:
        session.execute(
            text(
                """
                INSERT INTO plans (code, name, period_months, price_rub, is_active) VALUES
                ('ZERO', 'Zero', NULL, 0, 1),
                ('CORE', 'Core', 1, 150, 1),
                ('START', 'Start', 3, 500, 1),
                ('PRIME', 'Prime', 3, 800, 1),
                ('ADVANCED', 'Advanced', 3, 1100, 1),
                ('STUDIO', 'Studio', 3, 1400, 1),
                ('BUSINESS', 'Business', 3, 2000, 1),
                ('BLD_DIALOGUE', 'Builder • Dialogue', 3, 700, 1),
                ('BLD_MEDIA', 'Builder • Media', 3, 700, 1),
                ('BLD_DOCS', 'Builder • Docs', 3, 700, 1),
                ('VIP', 'VIP • Signature', NULL, 15000, 1),
                ('DEV', 'Developer • Gate', 12, 5000, 1)
                """
            )
        )
        session.execute(
            text(
                """
                INSERT INTO ai_providers (code, display_name, is_active, created_at) VALUES
                ('stub', 'Stub Provider', 1, CURRENT_TIMESTAMP)
                """
            )
        )
        session.commit()
        yield session
    finally:
        session.close()


@pytest.fixture()
def client(db_session: Session) -> Generator[TestClient, None, None]:
    app = create_app()

    def override_get_db() -> Generator[Session, None, None]:
        yield db_session

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture(autouse=True)
def oauth_exchange_mock(monkeypatch: pytest.MonkeyPatch) -> None:
    def _fake_exchange(provider: str, code: str, code_verifier: str) -> OAuthProfile:
        parts = code.split("|", 1)
        if len(parts) == 2:
            email, provider_user_id = parts
        else:
            email = f"{code}@example.com"
            provider_user_id = f"{provider}-{code}"
        return OAuthProfile(provider_user_id=provider_user_id, email=email)

    monkeypatch.setattr(oauth_service, "exchange_code_for_profile", _fake_exchange)
    monkeypatch.setattr(auth_endpoints, "exchange_code_for_profile", _fake_exchange)


@pytest.fixture()
def oauth_login(client: TestClient):
    def _login(provider: str = "google", email: str = "user@example.com", provider_user_id: str = "user-1"):
        start_response = client.post(f"/v1/auth/oauth/{provider}/start")
        assert start_response.status_code == 200
        state = start_response.json()["state"]
        code = f"{email}|{provider_user_id}"
        return client.post(f"/v1/auth/oauth/{provider}/callback", json={"code": code, "state": state})

    return _login
