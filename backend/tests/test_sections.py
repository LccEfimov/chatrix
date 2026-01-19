import uuid

from app.models.section import Section


def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _login(client, *, provider: str, provider_user_id: str, email: str) -> str:
    response = client.post(
        f"/v1/auth/oauth/{provider}/callback",
        json={"provider_user_id": provider_user_id, "email": email},
    )
    return response.json()["tokens"]["access_token"]


def _brief(title: str) -> dict:
    return {
        "title": title,
        "goal": "Organize workflows",
        "scenarios": ["Plan tasks", "Summarize progress", "Track outcomes"],
        "inputs": ["Notes", "Links"],
        "outputs": ["Checklist", "Summary"],
        "ai_operations": ["summarize", "classify"],
        "constraints": "Keep tone professional",
        "update_policy": "manual",
        "ui_blocks": ["cards", "timeline"],
        "limits": "Max 5 items",
    }


def test_sections_flow(client, db_session) -> None:
    token = _login(
        client,
        provider="google",
        provider_user_id="sections-user",
        email="sections@example.com",
    )

    created_ids = []
    for index in range(3):
        response = client.post(
            "/v1/sections",
            json={
                "category": "hobby",
                "brief": _brief(f"Section {index + 1}"),
                "ux_config": {"layout": "cards"},
                "ai_workflow": {"steps": ["summarize"]},
            },
            headers=_auth_headers(token),
        )
        assert response.status_code == 200
        payload = response.json()
        created_ids.append(payload["id"])
        assert payload["fee_cents"] == 0

    paid_response = client.post(
        "/v1/sections",
        json={
            "category": "work",
            "brief": _brief("Section 4"),
            "ux_config": {},
            "ai_workflow": {},
            "idempotency_key": "section-4",
        },
        headers=_auth_headers(token),
    )
    assert paid_response.status_code == 200
    paid_payload = paid_response.json()
    assert paid_payload["fee_cents"] == 30000
    assert paid_payload["note"]

    duplicate_response = client.post(
        "/v1/sections",
        json={
            "category": "work",
            "brief": _brief("Section 4"),
            "ux_config": {},
            "ai_workflow": {},
            "idempotency_key": "section-4",
        },
        headers=_auth_headers(token),
    )
    assert duplicate_response.status_code == 200
    assert duplicate_response.json()["id"] == paid_payload["id"]

    list_response = client.get("/v1/sections", headers=_auth_headers(token))
    assert list_response.status_code == 200
    assert len(list_response.json()["sections"]) == 4

    section_id = created_ids[0]
    get_response = client.get(f"/v1/sections/{section_id}", headers=_auth_headers(token))
    assert get_response.status_code == 200
    assert get_response.json()["id"] == section_id

    run_response = client.post(
        f"/v1/sections/{section_id}/run",
        json={"input_payload": {"text": "hello"}},
        headers=_auth_headers(token),
    )
    assert run_response.status_code == 200
    assert run_response.json()["status"] == "queued"

    assert db_session.get(Section, uuid.UUID(section_id)) is not None
