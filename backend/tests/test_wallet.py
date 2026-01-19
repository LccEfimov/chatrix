from datetime import date, datetime, timezone
from decimal import Decimal

from app.models.fx_rate import FxRate


def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _create_token(client) -> str:
    response = client.post(
        "/v1/auth/oauth/google/callback",
        json={"provider_user_id": "wallet-1", "email": "wallet@example.com"},
    )
    return response.json()["tokens"]["access_token"]


def test_wallet_topup_flow(client, db_session) -> None:
    db_session.add(
        FxRate(
            rate_date=date.today(),
            ccy="USD",
            rate_to_rub=Decimal("90.00"),
            fetched_at=datetime.now(timezone.utc),
            source="CBR",
        )
    )
    db_session.commit()

    token = _create_token(client)

    init_response = client.post(
        "/v1/wallet/topup/init",
        headers=_auth_headers(token),
        json={
            "provider": "google_pay",
            "amount": "10.00",
            "currency": "USD",
            "idempotency_key": "init-123456",
        },
    )
    assert init_response.status_code == 200
    init_payload = init_response.json()
    assert init_payload["amount_rub_cents"] == 94500

    confirm_response = client.post(
        "/v1/wallet/topup/confirm",
        headers=_auth_headers(token),
        json={
            "topup_id": init_payload["topup_id"],
            "idempotency_key": "confirm-123456",
        },
    )
    assert confirm_response.status_code == 200
    assert confirm_response.json()["balance_cents"] == 94500

    confirm_again = client.post(
        "/v1/wallet/topup/confirm",
        headers=_auth_headers(token),
        json={
            "topup_id": init_payload["topup_id"],
            "idempotency_key": "confirm-123456",
        },
    )
    assert confirm_again.status_code == 200
    assert confirm_again.json()["balance_cents"] == 94500

    ledger_response = client.get("/v1/wallet/ledger", headers=_auth_headers(token))
    assert ledger_response.status_code == 200
    assert len(ledger_response.json()["entries"]) == 1

    wallet_response = client.get("/v1/wallet/me", headers=_auth_headers(token))
    assert wallet_response.status_code == 200
    assert wallet_response.json()["balance_cents"] == 94500
