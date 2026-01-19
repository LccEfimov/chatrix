from __future__ import annotations

from datetime import date, datetime, timezone
from decimal import Decimal

from sqlalchemy import desc, select
from sqlalchemy.orm import Session

from app.models.fx_rate import FxRate


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def get_latest_rate_for_ccy(db: Session, ccy: str) -> FxRate | None:
    return (
        db.execute(
            select(FxRate).where(FxRate.ccy == ccy).order_by(desc(FxRate.rate_date))
        )
        .scalars()
        .first()
    )


def get_latest_rates(db: Session) -> list[FxRate]:
    latest_date = db.execute(select(FxRate.rate_date).order_by(desc(FxRate.rate_date))).scalars().first()
    if not latest_date:
        return []
    return db.execute(select(FxRate).where(FxRate.rate_date == latest_date)).scalars().all()


def upsert_rate(
    db: Session,
    *,
    ccy: str,
    rate_date: date,
    rate_to_rub: Decimal,
    source: str = "CBR",
    fetched_at: datetime | None = None,
) -> FxRate:
    fetched_at = fetched_at or _utcnow()
    existing = db.get(FxRate, {"rate_date": rate_date, "ccy": ccy})
    if existing:
        existing.rate_to_rub = rate_to_rub
        existing.source = source
        existing.fetched_at = fetched_at
        db.add(existing)
        db.commit()
        db.refresh(existing)
        return existing
    rate = FxRate(
        rate_date=rate_date,
        ccy=ccy,
        rate_to_rub=rate_to_rub,
        source=source,
        fetched_at=fetched_at,
    )
    db.add(rate)
    db.commit()
    db.refresh(rate)
    return rate
