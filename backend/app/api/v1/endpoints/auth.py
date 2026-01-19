from __future__ import annotations

import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.auth_session import AuthSession
from app.models.oauth_account import OAuthAccount
from app.models.user import User
from app.schemas.auth import (
    AuthResponse,
    LinkProviderRequest,
    LogoutRequest,
    OAuthCallbackRequest,
    OAuthStartResponse,
    RefreshRequest,
    TokenPair,
    UserMeResponse,
    UserProvider,
)
from app.services.auth import create_access_token, create_refresh_token, decode_token

router = APIRouter()

SUPPORTED_PROVIDERS = {"google", "apple", "yandex", "telegram", "discord", "tiktok"}


def _validate_provider(provider: str) -> str:
    provider = provider.lower()
    if provider not in SUPPORTED_PROVIDERS:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Unsupported provider")
    return provider


def _user_response(user: User, providers: list[OAuthAccount]) -> UserMeResponse:
    return UserMeResponse(
        id=str(user.id),
        email=user.email,
        plan_code=user.plan_code,
        providers=[
            UserProvider(provider=account.provider, provider_user_id=account.provider_user_id)
            for account in providers
        ],
    )


@router.post("/auth/oauth/{provider}/start", response_model=OAuthStartResponse)
def oauth_start(provider: str) -> OAuthStartResponse:
    provider = _validate_provider(provider)
    return OAuthStartResponse(provider=provider, auth_url=f"https://oauth.example/{provider}")


@router.post("/auth/oauth/{provider}/callback", response_model=AuthResponse)
def oauth_callback(
    provider: str,
    payload: OAuthCallbackRequest,
    db: Session = Depends(get_db),
) -> AuthResponse:
    provider = _validate_provider(provider)

    account = db.execute(
        select(OAuthAccount).where(
            OAuthAccount.provider == provider,
            OAuthAccount.provider_user_id == payload.provider_user_id,
        )
    ).scalar_one_or_none()

    if account:
        user = db.get(User, account.user_id)
    else:
        user = db.execute(select(User).where(User.email == payload.email)).scalar_one_or_none()
        if not user:
            user = User(email=payload.email)
            db.add(user)
            db.flush()

        account = OAuthAccount(
            user_id=user.id,
            provider=provider,
            provider_user_id=payload.provider_user_id,
        )
        db.add(account)

    access_token = create_access_token(user.id)
    refresh_token, jti, expires_at = create_refresh_token(user.id)
    session = AuthSession(
        user_id=user.id,
        refresh_jti=jti,
        created_at=datetime.now(timezone.utc),
        expires_at=expires_at,
    )
    db.add(session)
    db.commit()

    providers = db.execute(select(OAuthAccount).where(OAuthAccount.user_id == user.id)).scalars()
    return AuthResponse(
        user=_user_response(user, list(providers)),
        tokens=TokenPair(access_token=access_token, refresh_token=refresh_token),
    )


@router.post("/auth/refresh", response_model=TokenPair)
def refresh_token(payload: RefreshRequest, db: Session = Depends(get_db)) -> TokenPair:
    decoded = decode_token(payload.refresh_token, expected_type="refresh")
    jti = decoded.get("jti")
    user_id = decoded.get("sub")
    if not jti or not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    session = db.execute(select(AuthSession).where(AuthSession.refresh_jti == jti)).scalar_one_or_none()
    if not session or session.revoked_at is not None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session revoked")

    session.revoked_at = datetime.now(timezone.utc)
    access_token = create_access_token(uuid.UUID(user_id))
    refresh_token, new_jti, expires_at = create_refresh_token(uuid.UUID(user_id))
    db.add(
        AuthSession(
            user_id=uuid.UUID(user_id),
            refresh_jti=new_jti,
            created_at=datetime.now(timezone.utc),
            expires_at=expires_at,
        )
    )
    db.commit()
    return TokenPair(access_token=access_token, refresh_token=refresh_token)


@router.post("/auth/logout")
def logout(payload: LogoutRequest, db: Session = Depends(get_db)) -> dict:
    decoded = decode_token(payload.refresh_token, expected_type="refresh")
    jti = decoded.get("jti")
    if not jti:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    session = db.execute(select(AuthSession).where(AuthSession.refresh_jti == jti)).scalar_one_or_none()
    if session and session.revoked_at is None:
        session.revoked_at = datetime.now(timezone.utc)
        db.commit()
    return {"status": "ok"}


@router.get("/me", response_model=UserMeResponse)
def me(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserMeResponse:
    providers = db.execute(select(OAuthAccount).where(OAuthAccount.user_id == user.id)).scalars()
    return _user_response(user, list(providers))


@router.post("/me/link/{provider}", response_model=UserMeResponse)
def link_provider(
    provider: str,
    payload: LinkProviderRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserMeResponse:
    provider = _validate_provider(provider)
    existing = db.execute(
        select(OAuthAccount).where(
            OAuthAccount.provider == provider,
            OAuthAccount.provider_user_id == payload.provider_user_id,
        )
    ).scalar_one_or_none()
    if existing and existing.user_id != user.id:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Provider already linked")
    if not existing:
        db.add(
            OAuthAccount(
                user_id=user.id,
                provider=provider,
                provider_user_id=payload.provider_user_id,
            )
        )
        db.commit()
    providers = db.execute(select(OAuthAccount).where(OAuthAccount.user_id == user.id)).scalars()
    return _user_response(user, list(providers))


@router.delete("/me/link/{provider}", response_model=UserMeResponse)
def unlink_provider(
    provider: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserMeResponse:
    provider = _validate_provider(provider)
    account = db.execute(
        select(OAuthAccount).where(
            OAuthAccount.user_id == user.id,
            OAuthAccount.provider == provider,
        )
    ).scalar_one_or_none()
    if account:
        db.delete(account)
        db.commit()
    providers = db.execute(select(OAuthAccount).where(OAuthAccount.user_id == user.id)).scalars()
    return _user_response(user, list(providers))
