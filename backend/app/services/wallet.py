from __future__ import annotations

from datetime import date, datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.wallet_ledger import WalletLedgerEntry


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _round2(value: Decimal) -> Decimal:
    return value.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def convert_fx_to_rub_cents(
    *, amount: Decimal, rate_to_rub: Decimal, markup_percent: Decimal
) -> tuple[Decimal, int]:
    multiplier = Decimal("1") + (markup_percent / Decimal("100"))
    rub_amount = _round2(amount * rate_to_rub * multiplier)
    rub_cents = int((rub_amount * Decimal("100")).to_integral_value(rounding=ROUND_HALF_UP))
    return rub_amount, rub_cents


def compute_balance(db: Session, user_id) -> int:
    balance = db.execute(
        select(func.coalesce(func.sum(WalletLedgerEntry.amount_cents), 0)).where(
            WalletLedgerEntry.user_id == user_id
        )
    ).scalar_one()
    return int(balance)


def create_ledger_entry(
    db: Session,
    *,
    user_id,
    amount_cents: int,
    currency: str,
    entry_type: str,
    description: str | None,
    idempotency_key: str,
) -> WalletLedgerEntry:
    existing = db.execute(
        select(WalletLedgerEntry).where(
            WalletLedgerEntry.user_id == user_id,
            WalletLedgerEntry.idempotency_key == idempotency_key,
        )
    ).scalar_one_or_none()
    if existing:
        return existing

    entry = WalletLedgerEntry(
        user_id=user_id,
        amount_cents=amount_cents,
        currency=currency,
        entry_type=entry_type,
        description=description,
        idempotency_key=idempotency_key,
        created_at=utcnow(),
    )
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry


def default_rate_date() -> date:
    return utcnow().date()
