
def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _login(oauth_login, *, provider: str, provider_user_id: str, email: str) -> str:
    response = oauth_login(provider=provider, email=email, provider_user_id=provider_user_id)
    return response.json()["tokens"]["access_token"]


def test_support_ticket_flow(client, oauth_login) -> None:
    token = _login(
        oauth_login,
        provider="google",
        provider_user_id="support-user",
        email="support@example.com",
    )

    create_response = client.post(
        "/v1/support/tickets",
        json={
            "subject": "Payment issue",
            "message": "Top-up is pending for over 30 minutes.",
            "category": "billing",
        },
        headers=_auth_headers(token),
    )
    assert create_response.status_code == 200
    payload = create_response.json()
    assert payload["status"] == "open"
    assert payload["subject"] == "Payment issue"

    list_response = client.get(
        "/v1/support/tickets",
        headers=_auth_headers(token),
    )
    assert list_response.status_code == 200
    tickets = list_response.json()["tickets"]
    assert len(tickets) == 1
    assert tickets[0]["subject"] == "Payment issue"
