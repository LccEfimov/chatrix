from __future__ import annotations

from datetime import datetime, timezone
from decimal import Decimal
import uuid

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.devbox_package import DevboxPackage
from app.models.devbox_rate import InfraRate
from app.models.devbox_session import DevboxSession
from app.models.devbox_stack import DevboxStack


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def get_active_rate(db: Session) -> InfraRate | None:
    return (
        db.execute(
            select(InfraRate).where(InfraRate.is_active.is_(True)).order_by(InfraRate.updated_at.desc())
        )
        .scalars()
        .first()
    )


def list_packages(db: Session) -> list[DevboxPackage]:
    return (
        db.execute(select(DevboxPackage).where(DevboxPackage.is_active.is_(True)))
        .scalars()
        .all()
    )


def list_stacks(db: Session) -> list[DevboxStack]:
    return (
        db.execute(select(DevboxStack).where(DevboxStack.is_active.is_(True)))
        .scalars()
        .all()
    )


def compute_price(
    *,
    rate: InfraRate,
    cpu_cores: int,
    ram_gb: int,
    disk_gb: int,
    hours: int,
    duration_days: int,
    egress_gb: int,
) -> Decimal:
    hours_decimal = Decimal(hours)
    disk_month_part = Decimal(duration_days) / Decimal(30)
    subtotal = (
        Decimal(rate.platform_fee_rub)
        + (Decimal(cpu_cores) * Decimal(rate.cpu_core_hour_rub)
        + Decimal(ram_gb) * Decimal(rate.ram_gb_hour_rub))
        * hours_decimal
        + Decimal(disk_gb) * Decimal(rate.disk_gb_month_rub) * disk_month_part
        + Decimal(egress_gb) * Decimal(rate.egress_gb_rub)
    )
    margin_multiplier = Decimal("1") + (Decimal(rate.margin_percent) / Decimal("100"))
    total = subtotal * margin_multiplier
    return total.quantize(Decimal("0.01"))


def get_active_session(db: Session, *, user_id: uuid.UUID) -> DevboxSession | None:
    return (
        db.execute(
            select(DevboxSession)
            .where(DevboxSession.user_id == user_id, DevboxSession.status == "running")
            .order_by(DevboxSession.started_at.desc())
        )
        .scalars()
        .first()
    )


def start_session(
    db: Session,
    *,
    user_id: uuid.UUID,
    package_code: str,
    stack_code: str,
    idempotency_key: str | None,
) -> DevboxSession:
    if idempotency_key:
        existing = db.execute(
            select(DevboxSession).where(
                DevboxSession.user_id == user_id,
                DevboxSession.idempotency_key == idempotency_key,
            )
        ).scalar_one_or_none()
        if existing:
            return existing

    active_session = get_active_session(db, user_id=user_id)
    if active_session:
        return active_session

    package = db.get(DevboxPackage, package_code)
    if not package or not package.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Package not found")

    stack = db.get(DevboxStack, stack_code)
    if not stack or not stack.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Stack not found")

    rate = get_active_rate(db)
    if not rate:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Infra rates not configured")

    now = utcnow()
    price_rub = compute_price(
        rate=rate,
        cpu_cores=package.cpu_cores,
        ram_gb=package.ram_gb,
        disk_gb=package.disk_gb,
        hours=package.included_hours,
        duration_days=package.duration_days,
        egress_gb=package.egress_gb,
    )

    session = DevboxSession(
        user_id=user_id,
        package_code=package.code,
        stack_code=stack.code,
        status="running",
        cpu_cores=package.cpu_cores,
        ram_gb=package.ram_gb,
        disk_gb=package.disk_gb,
        egress_gb=package.egress_gb,
        hours=package.included_hours,
        price_rub=price_rub,
        idempotency_key=idempotency_key,
        started_at=now,
        created_at=now,
        updated_at=now,
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


def stop_session(db: Session, *, user_id: uuid.UUID) -> DevboxSession | None:
    session = get_active_session(db, user_id=user_id)
    if not session:
        return None
    now = utcnow()
    session.status = "stopped"
    session.stopped_at = now
    session.updated_at = now
    db.add(session)
    db.commit()
    db.refresh(session)
    return session
