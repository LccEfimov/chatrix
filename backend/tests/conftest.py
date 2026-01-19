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

from app.api.deps import get_db  # noqa: E402
from app.db.base import Base  # noqa: E402
from app.main import create_app  # noqa: E402
from app.models import (  # noqa: F401, E402
    auth_session,
    fx_rate,
    oauth_account,
    plan,
    plan_entitlement,
    plan_limit,
    referral_reward,
    referral_tier,
    user,
    wallet_ledger,
    wallet_topup,
)


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
