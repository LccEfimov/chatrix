
def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _login(client, *, provider: str, provider_user_id: str, email: str) -> str:
    response = client.post(
        f"/v1/auth/oauth/{provider}/callback",
        json={"provider_user_id": provider_user_id, "email": email},
    )
    return response.json()["tokens"]["access_token"]


def test_analytics_event_flow(client) -> None:
    token = _login(
        client,
        provider="google",
        provider_user_id="analytics-user",
        email="analytics@example.com",
    )

    create_response = client.post(
        "/v1/analytics/events",
        json={
            "event_name": "screen_open",
            "event_source": "mobile",
            "payload": {"screen": "support"},
        },
        headers=_auth_headers(token),
    )
    assert create_response.status_code == 200
    payload = create_response.json()
    assert payload["event_name"] == "screen_open"
    assert payload["payload"]["screen"] == "support"

    list_response = client.get(
        "/v1/analytics/events",
        headers=_auth_headers(token),
    )
    assert list_response.status_code == 200
    events = list_response.json()["events"]
    assert len(events) == 1
    assert events[0]["event_name"] == "screen_open"
