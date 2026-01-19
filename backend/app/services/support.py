from __future__ import annotations

from datetime import datetime, timezone
import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.support_ticket import SupportTicket


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def create_ticket(
    db: Session,
    *,
    user_id: uuid.UUID,
    subject: str,
    message: str,
    category: str | None,
) -> SupportTicket:
    now = utcnow()
    ticket = SupportTicket(
        user_id=user_id,
        subject=subject,
        message=message,
        category=category,
        status="open",
        created_at=now,
        updated_at=now,
    )
    db.add(ticket)
    db.commit()
    db.refresh(ticket)
    return ticket


def list_tickets(
    db: Session,
    *,
    user_id: uuid.UUID,
    limit: int = 50,
) -> list[SupportTicket]:
    return (
        db.execute(
            select(SupportTicket)
            .where(SupportTicket.user_id == user_id)
            .order_by(SupportTicket.created_at.desc())
            .limit(limit)
        )
        .scalars()
        .all()
    )
