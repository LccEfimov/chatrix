def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _login(client) -> str:
    payload = {"provider_user_id": "google-200", "email": "plan-user@example.com"}
    response = client.post("/v1/auth/oauth/google/callback", json=payload)
    return response.json()["tokens"]["access_token"]


def test_list_plans(client) -> None:
    response = client.get("/v1/plans")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 12
    codes = {plan["code"] for plan in data}
    assert {"ZERO", "CORE", "DEV"}.issubset(codes)


def test_activate_subscription(client) -> None:
    access_token = _login(client)
    activate_response = client.post(
        "/v1/subscriptions/activate",
        json={"plan_code": "CORE"},
        headers=_auth_headers(access_token),
    )
    assert activate_response.status_code == 200
    assert activate_response.json()["plan"]["code"] == "CORE"

    me_response = client.get("/v1/subscriptions/me", headers=_auth_headers(access_token))
    assert me_response.status_code == 200
    assert me_response.json()["plan"]["code"] == "CORE"
