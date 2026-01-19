from __future__ import annotations

from datetime import datetime, timezone
import uuid

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.section import Section

FREE_SECTION_LIMIT = 3
PAID_SECTION_FEE_CENTS = 30000


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def get_section_or_404(db: Session, *, section_id: uuid.UUID, user_id: uuid.UUID) -> Section:
    section = db.execute(
        select(Section).where(Section.id == section_id, Section.user_id == user_id)
    ).scalar_one_or_none()
    if not section:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Section not found")
    return section


def list_sections(db: Session, *, user_id: uuid.UUID) -> list[Section]:
    return (
        db.execute(
            select(Section)
            .where(Section.user_id == user_id)
            .order_by(Section.updated_at.desc())
        )
        .scalars()
        .all()
    )


def _existing_section_count(db: Session, *, user_id: uuid.UUID) -> int:
    return int(
        db.execute(
            select(func.count(Section.id)).where(Section.user_id == user_id)
        ).scalar_one()
    )


def create_section(
    db: Session,
    *,
    user_id: uuid.UUID,
    category: str,
    brief: dict,
    ux_config: dict,
    ai_workflow: dict,
    idempotency_key: str | None,
) -> Section:
    if idempotency_key:
        existing = db.execute(
            select(Section).where(
                Section.user_id == user_id, Section.idempotency_key == idempotency_key
            )
        ).scalar_one_or_none()
        if existing:
            return existing

    now = utcnow()
    existing_count = _existing_section_count(db, user_id=user_id)
    fee_cents = 0
    note = None
    if existing_count >= FREE_SECTION_LIMIT:
        fee_cents = PAID_SECTION_FEE_CENTS
        note = "Payment required for section beyond free quota"

    section = Section(
        user_id=user_id,
        category=category,
        title=brief.get("title", "Untitled"),
        brief=brief,
        ux_config=ux_config,
        ai_workflow=ai_workflow,
        is_active=True,
        fee_cents=fee_cents,
        idempotency_key=idempotency_key,
        created_at=now,
        updated_at=now,
        note=note,
    )
    db.add(section)
    db.commit()
    db.refresh(section)
    return section


def run_section(
    db: Session,
    *,
    section: Section,
    input_payload: dict,
) -> tuple[datetime, dict]:
    now = utcnow()
    section.last_run_at = now
    section.updated_at = now
    db.add(section)
    db.commit()
    db.refresh(section)

    output_preview = {
        "summary": "Workflow queued",
        "inputs": input_payload,
        "section": section.title,
    }
    return now, output_preview
