from decimal import Decimal

from sqlalchemy import text


def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _login(client, *, provider: str, provider_user_id: str, email: str) -> str:
    response = client.post(
        f"/v1/auth/oauth/{provider}/callback",
        json={"provider_user_id": provider_user_id, "email": email},
    )
    return response.json()["tokens"]["access_token"]


def _seed_devbox_data(db_session) -> None:
    db_session.execute(
        text(
            """
        INSERT INTO infra_rates (
            id, cpu_core_hour_rub, ram_gb_hour_rub, disk_gb_month_rub, egress_gb_rub,
            platform_fee_rub, margin_percent, is_active, created_at, updated_at
        ) VALUES
        (1, 10.00, 4.00, 20.00, 2.00, 100.00, 10.00, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        """
        )
    )
    db_session.execute(
        text(
            """
        INSERT INTO devbox_packages (
            code, name, cpu_cores, ram_gb, disk_gb, duration_days, included_hours, egress_gb, is_active,
            created_at, updated_at
        ) VALUES
        ('S', 'DevBox S', 1, 2, 10, 30, 720, 0, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
        ('M', 'DevBox M', 2, 4, 30, 30, 720, 0, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
        ('L', 'DevBox L', 4, 8, 80, 30, 720, 0, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        """
        )
    )
    db_session.execute(
        text(
            """
        INSERT INTO devbox_stacks (code, name, is_active, created_at, updated_at) VALUES
        ('python', 'Python', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
        ('node', 'Node.js', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        """
        )
    )
    db_session.commit()


def test_devbox_flow(client, db_session) -> None:
    token = _login(
        client,
        provider="google",
        provider_user_id="devbox-user",
        email="devbox@example.com",
    )

    forbidden = client.get("/v1/devbox/status", headers=_auth_headers(token))
    assert forbidden.status_code == 403

    activate = client.post(
        "/v1/subscriptions/activate",
        json={"plan_code": "DEV"},
        headers=_auth_headers(token),
    )
    assert activate.status_code == 200

    _seed_devbox_data(db_session)

    status_response = client.get("/v1/devbox/status", headers=_auth_headers(token))
    assert status_response.status_code == 200
    payload = status_response.json()
    assert payload["status"] == "stopped"
    assert len(payload["packages"]) == 3
    assert len(payload["stacks"]) == 2

    start_response = client.post(
        "/v1/devbox/start",
        json={"package_code": "S", "stack_code": "python", "idempotency_key": "start-1"},
        headers=_auth_headers(token),
    )
    assert start_response.status_code == 200
    start_payload = start_response.json()
    assert start_payload["status"] == "running"
    assert Decimal(start_payload["price_rub"]) > 0

    duplicate_start = client.post(
        "/v1/devbox/start",
        json={"package_code": "S", "stack_code": "python", "idempotency_key": "start-1"},
        headers=_auth_headers(token),
    )
    assert duplicate_start.status_code == 200
    assert duplicate_start.json()["session_id"] == start_payload["session_id"]

    stop_response = client.post("/v1/devbox/stop", headers=_auth_headers(token))
    assert stop_response.status_code == 200
    stop_payload = stop_response.json()
    assert stop_payload["status"] == "stopped"
    assert stop_payload["session"]["status"] == "stopped"
