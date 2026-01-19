def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _login(oauth_login) -> str:
    response = oauth_login(provider="google", email="plan-user@example.com", provider_user_id="google-200")
    return response.json()["tokens"]["access_token"]


def test_list_plans(client) -> None:
    response = client.get("/v1/plans")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 12
    codes = {plan["code"] for plan in data}
    assert {"ZERO", "CORE", "DEV"}.issubset(codes)


def test_activate_subscription(client, oauth_login) -> None:
    access_token = _login(oauth_login)
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
