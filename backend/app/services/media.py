from __future__ import annotations

from datetime import datetime, timezone
import uuid

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import ImageJob, VideoAvatar, VideoJob, VoiceSession


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def create_voice_session(
    db: Session,
    *,
    user_id: uuid.UUID,
    mode: str,
    provider_code: str | None,
    model: str | None,
) -> VoiceSession:
    if mode not in {"live", "standard"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported voice mode",
        )
    now = utcnow()
    session = VoiceSession(
        user_id=user_id,
        mode=mode,
        status="active",
        provider_code=provider_code,
        model=model,
        started_at=now,
        ended_at=None,
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


def list_voice_sessions(db: Session, *, user_id: uuid.UUID) -> list[VoiceSession]:
    return (
        db.execute(
            select(VoiceSession)
            .where(VoiceSession.user_id == user_id)
            .order_by(VoiceSession.started_at.desc())
        )
        .scalars()
        .all()
    )


def stop_voice_session(
    db: Session,
    *,
    session_id: uuid.UUID,
    user_id: uuid.UUID,
) -> VoiceSession:
    session = db.execute(
        select(VoiceSession).where(
            VoiceSession.id == session_id,
            VoiceSession.user_id == user_id,
        )
    ).scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Voice session not found")
    session.status = "stopped"
    session.ended_at = utcnow()
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


def create_video_avatar(
    db: Session,
    *,
    user_id: uuid.UUID,
    name: str,
    prompt: str | None,
    provider_code: str | None,
    model: str | None,
) -> VideoAvatar:
    now = utcnow()
    avatar = VideoAvatar(
        user_id=user_id,
        name=name,
        prompt=prompt,
        status="ready",
        provider_code=provider_code,
        model=model,
        created_at=now,
        updated_at=now,
    )
    db.add(avatar)
    db.commit()
    db.refresh(avatar)
    return avatar


def list_video_avatars(db: Session, *, user_id: uuid.UUID) -> list[VideoAvatar]:
    return (
        db.execute(
            select(VideoAvatar)
            .where(VideoAvatar.user_id == user_id)
            .order_by(VideoAvatar.created_at.desc())
        )
        .scalars()
        .all()
    )


def create_image_job(
    db: Session,
    *,
    user_id: uuid.UUID,
    prompt: str,
    provider_code: str | None,
    model: str | None,
) -> ImageJob:
    now = utcnow()
    job = ImageJob(
        user_id=user_id,
        prompt=prompt,
        status="queued",
        provider_code=provider_code,
        model=model,
        result_url=None,
        created_at=now,
        updated_at=now,
    )
    db.add(job)
    db.commit()
    db.refresh(job)
    return job


def list_image_jobs(db: Session, *, user_id: uuid.UUID) -> list[ImageJob]:
    return (
        db.execute(
            select(ImageJob)
            .where(ImageJob.user_id == user_id)
            .order_by(ImageJob.created_at.desc())
        )
        .scalars()
        .all()
    )


def create_video_job(
    db: Session,
    *,
    user_id: uuid.UUID,
    prompt: str,
    provider_code: str | None,
    model: str | None,
) -> VideoJob:
    now = utcnow()
    job = VideoJob(
        user_id=user_id,
        prompt=prompt,
        status="queued",
        provider_code=provider_code,
        model=model,
        result_url=None,
        created_at=now,
        updated_at=now,
    )
    db.add(job)
    db.commit()
    db.refresh(job)
    return job


def list_video_jobs(db: Session, *, user_id: uuid.UUID) -> list[VideoJob]:
    return (
        db.execute(
            select(VideoJob)
            .where(VideoJob.user_id == user_id)
            .order_by(VideoJob.created_at.desc())
        )
        .scalars()
        .all()
    )
