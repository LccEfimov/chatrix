from app.models.ai_provider import AiProvider


def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _login(client, *, provider: str, provider_user_id: str, email: str) -> str:
    response = client.post(
        f"/v1/auth/oauth/{provider}/callback",
        json={"provider_user_id": provider_user_id, "email": email},
    )
    return response.json()["tokens"]["access_token"]


def test_chat_flow(client, db_session) -> None:
    token = _login(
        client,
        provider="google",
        provider_user_id="chat-user",
        email="chat-user@example.com",
    )

    create_response = client.post(
        "/v1/chats",
        json={"title": "Daily Notes", "system_prompt": "Be concise"},
        headers=_auth_headers(token),
    )
    assert create_response.status_code == 200
    chat_id = create_response.json()["id"]

    send_response = client.post(
        f"/v1/chats/{chat_id}/messages",
        json={"content": "Hello"},
        headers=_auth_headers(token),
    )
    assert send_response.status_code == 200
    payload = send_response.json()
    assert payload["message"]["role"] == "user"
    assert payload["assistant_message"]["role"] == "assistant"
    assert payload["assistant_message"]["provider"] == "stub"

    list_response = client.get(
        f"/v1/chats/{chat_id}/messages",
        headers=_auth_headers(token),
    )
    assert list_response.status_code == 200
    messages = list_response.json()["messages"]
    assert [msg["role"] for msg in messages] == ["user", "assistant"]

    chat_list = client.get("/v1/chats", headers=_auth_headers(token))
    assert chat_list.status_code == 200
    assert chat_list.json()["chats"][0]["title"] == "Daily Notes"

    provider = db_session.get(AiProvider, "stub")
    assert provider is not None


def test_ai_providers_list(client) -> None:
    response = client.get("/v1/ai/providers")
    assert response.status_code == 200
    providers = response.json()["providers"]
    assert providers
    assert providers[0]["code"] == "stub"
