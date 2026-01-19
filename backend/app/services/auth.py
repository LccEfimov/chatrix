from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

import jwt
from fastapi import HTTPException, status

from app.core.config import settings


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def create_access_token(user_id: uuid.UUID) -> str:
    expires_at = _utcnow() + timedelta(minutes=settings.jwt_access_ttl_min)
    payload = {"sub": str(user_id), "type": "access", "exp": expires_at}
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")


def create_refresh_token(user_id: uuid.UUID) -> tuple[str, str, datetime]:
    expires_at = _utcnow() + timedelta(days=settings.jwt_refresh_ttl_days)
    jti = uuid.uuid4().hex
    payload = {"sub": str(user_id), "type": "refresh", "jti": jti, "exp": expires_at}
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256"), jti, expires_at


def decode_token(token: str, expected_type: str) -> dict:
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=["HS256"])
    except jwt.PyJWTError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token") from exc

    if payload.get("type") != expected_type:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    return payload
