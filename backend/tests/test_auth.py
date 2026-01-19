def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def test_oauth_flow_and_refresh(client, oauth_login) -> None:
    response = oauth_login(provider="google", email="user@example.com", provider_user_id="google-123")
    assert response.status_code == 200
    body = response.json()
    assert body["user"]["email"] == "user@example.com"
    assert body["user"]["providers"][0]["provider"] == "google"

    access_token = body["tokens"]["access_token"]
    refresh_token = body["tokens"]["refresh_token"]

    me_response = client.get("/v1/me", headers=_auth_headers(access_token))
    assert me_response.status_code == 200
    assert me_response.json()["email"] == "user@example.com"

    refresh_response = client.post("/v1/auth/refresh", json={"refresh_token": refresh_token})
    assert refresh_response.status_code == 200
    assert refresh_response.json()["access_token"]
    assert refresh_response.json()["refresh_token"]


def test_link_and_unlink_provider(client, oauth_login) -> None:
    response = oauth_login(provider="telegram", email="linker@example.com", provider_user_id="tg-1")
    access_token = response.json()["tokens"]["access_token"]

    start_response = client.post("/v1/auth/oauth/discord/start")
    state = start_response.json()["state"]
    link_response = client.post(
        "/v1/me/link/discord",
        json={"code": "linker@example.com|discord-1", "state": state},
        headers=_auth_headers(access_token),
    )
    assert link_response.status_code == 200
    providers = {provider["provider"] for provider in link_response.json()["providers"]}
    assert providers == {"telegram", "discord"}

    unlink_response = client.delete("/v1/me/link/discord", headers=_auth_headers(access_token))
    assert unlink_response.status_code == 200
    providers = {provider["provider"] for provider in unlink_response.json()["providers"]}
    assert providers == {"telegram"}
