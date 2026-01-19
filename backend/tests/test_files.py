from sqlalchemy import text


def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _login(oauth_login, *, provider: str, provider_user_id: str, email: str) -> str:
    response = oauth_login(provider=provider, email=email, provider_user_id=provider_user_id)
    return response.json()["tokens"]["access_token"]


def test_files_flow(client, db_session, oauth_login) -> None:
    db_session.execute(
        text(
            """
            INSERT INTO plan_limits (plan_code, key, limit_value)
            VALUES ('ZERO', 'storage_bytes', 1500)
            """
        )
    )
    db_session.commit()

    token = _login(
        oauth_login,
        provider="google",
        provider_user_id="files-user",
        email="files@example.com",
    )

    init_response = client.post(
        "/v1/files/upload/init",
        json={
            "filename": "notes.txt",
            "content_type": "text/plain",
            "size_bytes": 1000,
            "idempotency_key": "file-upload-1",
        },
        headers=_auth_headers(token),
    )
    assert init_response.status_code == 200
    init_payload = init_response.json()
    assert init_payload["status"] == "pending_upload"

    complete_response = client.post(
        "/v1/files/upload/complete",
        json={
            "file_id": init_payload["file_id"],
            "content_text": "Hello docs",
        },
        headers=_auth_headers(token),
    )
    assert complete_response.status_code == 200
    complete_payload = complete_response.json()
    assert complete_payload["status"] == "stored"
    assert "Hello docs" in complete_payload["parsed_text"]

    download_response = client.get(
        f"/v1/files/{init_payload['file_id']}/download",
        headers=_auth_headers(token),
    )
    assert download_response.status_code == 200
    assert download_response.json()["download_url"]

    list_response = client.get("/v1/files", headers=_auth_headers(token))
    assert list_response.status_code == 200
    assert len(list_response.json()["files"]) == 1

    quota_response = client.post(
        "/v1/files/upload/init",
        json={
            "filename": "large.pdf",
            "content_type": "application/pdf",
            "size_bytes": 600,
        },
        headers=_auth_headers(token),
    )
    assert quota_response.status_code == 403

    delete_response = client.delete(
        f"/v1/files/{init_payload['file_id']}",
        headers=_auth_headers(token),
    )
    assert delete_response.status_code == 200
    assert delete_response.json()["status"] == "deleted"


def test_files_rejects_unsupported_extension(client, oauth_login) -> None:
    token = _login(
        oauth_login,
        provider="google",
        provider_user_id="files-user-2",
        email="files2@example.com",
    )

    response = client.post(
        "/v1/files/upload/init",
        json={
            "filename": "malware.exe",
            "content_type": "application/octet-stream",
            "size_bytes": 100,
        },
        headers=_auth_headers(token),
    )
    assert response.status_code == 400
