from __future__ import annotations

from datetime import datetime, timezone
import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.analytics_event import AnalyticsEvent


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def create_event(
    db: Session,
    *,
    user_id: uuid.UUID,
    event_name: str,
    event_source: str | None,
    payload: dict | None,
) -> AnalyticsEvent:
    event = AnalyticsEvent(
        user_id=user_id,
        event_name=event_name,
        event_source=event_source,
        payload=payload,
        created_at=utcnow(),
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return event


def list_events(
    db: Session,
    *,
    user_id: uuid.UUID,
    limit: int = 50,
) -> list[AnalyticsEvent]:
    return (
        db.execute(
            select(AnalyticsEvent)
            .where(AnalyticsEvent.user_id == user_id)
            .order_by(AnalyticsEvent.created_at.desc())
            .limit(limit)
        )
        .scalars()
        .all()
    )
