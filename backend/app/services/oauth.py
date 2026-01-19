from __future__ import annotations

import base64
import hashlib
import secrets
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Any

import httpx
import jwt
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.oauth_state import OAuthState


class OAuthError(RuntimeError):
    pass


class OAuthProviderNotConfigured(OAuthError):
    pass


class OAuthStateError(OAuthError):
    pass


class OAuthExchangeError(OAuthError):
    pass


@dataclass(frozen=True)
class OAuthProviderConfig:
    name: str
    client_id: str
    client_secret: str
    auth_url: str
    token_url: str
    userinfo_url: str | None
    scopes: list[str]
    user_id_field: str
    email_field: str


@dataclass(frozen=True)
class OAuthStateData:
    state: str
    code_challenge: str


@dataclass(frozen=True)
class OAuthProfile:
    provider_user_id: str
    email: str


_PROVIDER_DEFAULTS: dict[str, dict[str, Any]] = {
    "google": {
        "auth_url": "https://accounts.google.com/o/oauth2/v2/auth",
        "token_url": "https://oauth2.googleapis.com/token",
        "userinfo_url": "https://openidconnect.googleapis.com/v1/userinfo",
        "scopes": ["openid", "email", "profile"],
        "user_id_field": "sub",
        "email_field": "email",
    },
    "apple": {
        "auth_url": "https://appleid.apple.com/auth/authorize",
        "token_url": "https://appleid.apple.com/auth/token",
        "userinfo_url": None,
        "scopes": ["email", "name"],
        "user_id_field": "sub",
        "email_field": "email",
    },
    "yandex": {
        "auth_url": "https://oauth.yandex.com/authorize",
        "token_url": "https://oauth.yandex.com/token",
        "userinfo_url": "https://login.yandex.ru/info",
        "scopes": ["login:email", "login:info"],
        "user_id_field": "id",
        "email_field": "default_email",
    },
    "telegram": {
        "auth_url": "",
        "token_url": "",
        "userinfo_url": "",
        "scopes": [],
        "user_id_field": "id",
        "email_field": "email",
    },
    "discord": {
        "auth_url": "https://discord.com/api/oauth2/authorize",
        "token_url": "https://discord.com/api/oauth2/token",
        "userinfo_url": "https://discord.com/api/users/@me",
        "scopes": ["identify", "email"],
        "user_id_field": "id",
        "email_field": "email",
    },
    "tiktok": {
        "auth_url": "https://www.tiktok.com/v2/auth/authorize/",
        "token_url": "https://open.tiktokapis.com/v2/oauth/token/",
        "userinfo_url": "https://open.tiktokapis.com/v2/user/info/",
        "scopes": ["user.info.basic"],
        "user_id_field": "open_id",
        "email_field": "email",
    },
}


def create_oauth_state(db: Session, provider: str) -> OAuthStateData:
    state = secrets.token_urlsafe(32)
    code_verifier = secrets.token_urlsafe(64)
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=settings.oauth_state_ttl_minutes)
    db.add(
        OAuthState(
            state=state,
            provider=provider,
            code_verifier=code_verifier,
            created_at=datetime.now(timezone.utc),
            expires_at=expires_at,
        )
    )
    db.commit()
    return OAuthStateData(state=state, code_challenge=_code_challenge(code_verifier))


def get_oauth_state(db: Session, provider: str, state: str) -> OAuthState:
    record = db.execute(
        select(OAuthState).where(OAuthState.state == state, OAuthState.provider == provider)
    ).scalar_one_or_none()
    if not record:
        raise OAuthStateError("Invalid OAuth state")
    expires_at = record.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if expires_at < datetime.now(timezone.utc):
        db.delete(record)
        db.commit()
        raise OAuthStateError("OAuth state expired")
    return record


def build_authorization_url(provider: str, state: str, code_challenge: str) -> str:
    config = _get_provider_config(provider)
    redirect_uri = f"{settings.oauth_redirect_base}/{provider}/callback"
    query = httpx.QueryParams(
        {
            "response_type": "code",
            "client_id": config.client_id,
            "redirect_uri": redirect_uri,
            "scope": " ".join(config.scopes),
            "state": state,
            "code_challenge": code_challenge,
            "code_challenge_method": "S256",
        }
    )
    return f"{config.auth_url}?{query}"


def exchange_code_for_profile(provider: str, code: str, code_verifier: str) -> OAuthProfile:
    config = _get_provider_config(provider)
    redirect_uri = f"{settings.oauth_redirect_base}/{provider}/callback"
    token_payload = {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirect_uri,
        "client_id": config.client_id,
        "client_secret": config.client_secret,
        "code_verifier": code_verifier,
    }
    try:
        with httpx.Client(timeout=10) as client:
            token_response = client.post(config.token_url, data=token_payload)
            token_response.raise_for_status()
            token_data = token_response.json()
            access_token = token_data.get("access_token")
            id_token = token_data.get("id_token")
            if not access_token and not id_token:
                raise OAuthExchangeError("Token response missing access token")
            userinfo = _fetch_userinfo(client, config, access_token, id_token)
    except httpx.HTTPError as exc:
        raise OAuthExchangeError("OAuth exchange failed") from exc

    provider_user_id = str(userinfo.get(config.user_id_field) or "").strip()
    email = str(userinfo.get(config.email_field) or "").strip()
    if not provider_user_id:
        raise OAuthExchangeError("Provider user id missing")
    if not email:
        raise OAuthExchangeError("Email missing from provider")
    return OAuthProfile(provider_user_id=provider_user_id, email=email)


def _fetch_userinfo(
    client: httpx.Client, config: OAuthProviderConfig, access_token: str | None, id_token: str | None
) -> dict[str, Any]:
    if config.userinfo_url:
        headers = {"Authorization": f"Bearer {access_token}"} if access_token else {}
        userinfo_response = client.get(config.userinfo_url, headers=headers)
        userinfo_response.raise_for_status()
        return userinfo_response.json()
    if not id_token:
        raise OAuthExchangeError("Userinfo endpoint not configured and id_token missing")
    return jwt.decode(id_token, options={"verify_signature": False, "verify_aud": False})


def _code_challenge(code_verifier: str) -> str:
    digest = hashlib.sha256(code_verifier.encode("utf-8")).digest()
    return base64.urlsafe_b64encode(digest).rstrip(b"=").decode("utf-8")


def _get_provider_config(provider: str) -> OAuthProviderConfig:
    defaults = _PROVIDER_DEFAULTS[provider]
    client_id = getattr(settings, f"oauth_{provider}_client_id")
    client_secret = getattr(settings, f"oauth_{provider}_client_secret")
    if not client_id or not client_secret:
        raise OAuthProviderNotConfigured(f"Provider {provider} is not configured")
    auth_url = getattr(settings, f"oauth_{provider}_auth_url") or defaults["auth_url"]
    token_url = getattr(settings, f"oauth_{provider}_token_url") or defaults["token_url"]
    userinfo_url = getattr(settings, f"oauth_{provider}_userinfo_url") or defaults["userinfo_url"]
    scopes = (
        getattr(settings, f"oauth_{provider}_scopes").split()
        if getattr(settings, f"oauth_{provider}_scopes")
        else defaults["scopes"]
    )
    if not auth_url or not token_url:
        raise OAuthProviderNotConfigured(f"Provider {provider} is missing OAuth endpoints")
    return OAuthProviderConfig(
        name=provider,
        client_id=client_id,
        client_secret=client_secret,
        auth_url=auth_url,
        token_url=token_url,
        userinfo_url=userinfo_url or None,
        scopes=scopes,
        user_id_field=defaults["user_id_field"],
        email_field=defaults["email_field"],
    )
