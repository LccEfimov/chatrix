import uuid

from app.models.image_job import ImageJob
from app.models.video_avatar import VideoAvatar
from app.models.video_job import VideoJob
from app.models.voice_session import VoiceSession


def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _login(oauth_login, *, provider: str, provider_user_id: str, email: str) -> str:
    response = oauth_login(provider=provider, email=email, provider_user_id=provider_user_id)
    return response.json()["tokens"]["access_token"]


def test_media_endpoints(client, db_session, oauth_login) -> None:
    token = _login(
        oauth_login,
        provider="google",
        provider_user_id="media-user",
        email="media-user@example.com",
    )

    voice_response = client.post(
        "/v1/voice/sessions",
        json={"mode": "live", "provider": "stub", "model": "voice-v1"},
        headers=_auth_headers(token),
    )
    assert voice_response.status_code == 200
    voice_id = voice_response.json()["id"]

    voice_list = client.get("/v1/voice/sessions", headers=_auth_headers(token))
    assert voice_list.status_code == 200
    assert voice_list.json()["sessions"][0]["id"] == voice_id

    voice_stop = client.post(
        f"/v1/voice/sessions/{voice_id}/stop",
        headers=_auth_headers(token),
    )
    assert voice_stop.status_code == 200
    assert voice_stop.json()["status"] == "stopped"

    avatar_response = client.post(
        "/v1/video/avatars",
        json={"name": "Studio Host", "prompt": "Energetic", "provider": "stub"},
        headers=_auth_headers(token),
    )
    assert avatar_response.status_code == 200
    avatar_id = avatar_response.json()["id"]

    avatars = client.get("/v1/video/avatars", headers=_auth_headers(token))
    assert avatars.status_code == 200
    assert avatars.json()["avatars"][0]["id"] == avatar_id

    image_job = client.post(
        "/v1/tools/image/jobs",
        json={"prompt": "Futuristic skyline", "provider": "stub"},
        headers=_auth_headers(token),
    )
    assert image_job.status_code == 200
    image_id = image_job.json()["id"]

    image_list = client.get("/v1/tools/image/jobs", headers=_auth_headers(token))
    assert image_list.status_code == 200
    assert image_list.json()["jobs"][0]["id"] == image_id

    video_job = client.post(
        "/v1/tools/video/jobs",
        json={"prompt": "City timelapse", "provider": "stub"},
        headers=_auth_headers(token),
    )
    assert video_job.status_code == 200
    video_id = video_job.json()["id"]

    video_list = client.get("/v1/tools/video/jobs", headers=_auth_headers(token))
    assert video_list.status_code == 200
    assert video_list.json()["jobs"][0]["id"] == video_id

    assert db_session.get(VoiceSession, uuid.UUID(voice_id)) is not None
    assert db_session.get(VideoAvatar, uuid.UUID(avatar_id)) is not None
    assert db_session.get(ImageJob, uuid.UUID(image_id)) is not None
    assert db_session.get(VideoJob, uuid.UUID(video_id)) is not None
