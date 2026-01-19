from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.ai_provider import AiProvider


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def select_provider(db: Session, requested: str | None = None) -> AiProvider | None:
    if requested:
        return db.execute(
            select(AiProvider).where(
                AiProvider.code == requested,
                AiProvider.is_active.is_(True),
            )
        ).scalar_one_or_none()
    return db.execute(
        select(AiProvider)
        .where(AiProvider.is_active.is_(True))
        .order_by(AiProvider.code)
    ).scalars().first()


def generate_stub_reply(
    *,
    user_message: str,
    system_prompt: str | None,
    provider: AiProvider,
    model: str | None = None,
) -> str:
    prompt_hint = f" | prompt: {system_prompt}" if system_prompt else ""
    model_hint = f"/{model}" if model else ""
    return (
        f"[stub:{provider.code}{model_hint}] Received: {user_message}"
        f"{prompt_hint}"
    )
