from __future__ import annotations

import uuid
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.wallet_topup import WalletTopup
from app.models.wallet_ledger import WalletLedgerEntry
from app.schemas.wallet import (
    TopupConfirmRequest,
    TopupConfirmResponse,
    TopupInitRequest,
    TopupInitResponse,
    WalletBalanceResponse,
    WalletLedgerEntryResponse,
    WalletLedgerResponse,
)
from app.services import fx as fx_service
from app.services import wallet as wallet_service

router = APIRouter()

SUPPORTED_TOPUP_PROVIDERS = {"google_pay", "apple_pay", "yoomoney"}


def _normalize_provider(provider: str) -> str:
    return provider.strip().lower()


@router.get("/wallet/me", response_model=WalletBalanceResponse)
def wallet_me(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> WalletBalanceResponse:
    balance = wallet_service.compute_balance(db, user.id)
    return WalletBalanceResponse(balance_cents=balance)


@router.get("/wallet/ledger", response_model=WalletLedgerResponse)
def wallet_ledger(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> WalletLedgerResponse:
    entries = db.execute(
        select(WalletLedgerEntry)
        .where(WalletLedgerEntry.user_id == user.id)
        .order_by(WalletLedgerEntry.created_at.desc())
    ).scalars().all()
    balance = wallet_service.compute_balance(db, user.id)
    return WalletLedgerResponse(
        balance_cents=balance,
        entries=[
            WalletLedgerEntryResponse(
                id=str(entry.id),
                amount_cents=entry.amount_cents,
                currency=entry.currency,
                entry_type=entry.entry_type,
                description=entry.description,
                idempotency_key=entry.idempotency_key,
                created_at=entry.created_at,
            )
            for entry in entries
        ],
    )


@router.post("/wallet/topup/init", response_model=TopupInitResponse)
def topup_init(
    payload: TopupInitRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TopupInitResponse:
    provider = _normalize_provider(payload.provider)
    if provider not in SUPPORTED_TOPUP_PROVIDERS:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Unsupported provider")
    if payload.amount <= 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Amount must be positive")

    existing = db.execute(
        select(WalletTopup).where(
            WalletTopup.user_id == user.id,
            WalletTopup.idempotency_key == payload.idempotency_key,
        )
    ).scalar_one_or_none()
    if existing:
        return TopupInitResponse(
            topup_id=str(existing.id),
            status=existing.status,
            provider=existing.provider,
            amount=existing.amount_currency,
            currency=existing.currency,
            amount_rub_cents=existing.amount_rub_cents,
            rate_date=existing.rate_date,
            rate_to_rub=existing.rate_to_rub,
            markup_percent=existing.markup_percent,
        )

    currency = payload.currency.upper()
    if currency == "RUB":
        rate_to_rub = Decimal("1")
        rate_date = wallet_service.default_rate_date()
        markup_percent = Decimal("0")
    else:
        rate = fx_service.get_latest_rate_for_ccy(db, currency)
        if not rate:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="FX rate not found")
        rate_to_rub = Decimal(rate.rate_to_rub)
        rate_date = rate.rate_date
        markup_percent = Decimal("5.0")
    _, amount_rub_cents = wallet_service.convert_fx_to_rub_cents(
        amount=payload.amount,
        rate_to_rub=rate_to_rub,
        markup_percent=markup_percent,
    )

    topup = WalletTopup(
        user_id=user.id,
        provider=provider,
        status="pending",
        amount_currency=payload.amount,
        currency=currency,
        amount_rub_cents=amount_rub_cents,
        rate_date=rate_date,
        rate_to_rub=rate_to_rub,
        markup_percent=markup_percent,
        idempotency_key=payload.idempotency_key,
        created_at=wallet_service.utcnow(),
        updated_at=wallet_service.utcnow(),
    )
    db.add(topup)
    db.commit()
    db.refresh(topup)
    return TopupInitResponse(
        topup_id=str(topup.id),
        status=topup.status,
        provider=topup.provider,
        amount=topup.amount_currency,
        currency=topup.currency,
        amount_rub_cents=topup.amount_rub_cents,
        rate_date=topup.rate_date,
        rate_to_rub=topup.rate_to_rub,
        markup_percent=topup.markup_percent,
    )


@router.post("/wallet/topup/confirm", response_model=TopupConfirmResponse)
def topup_confirm(
    payload: TopupConfirmRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TopupConfirmResponse:
    try:
        topup_id = uuid.UUID(payload.topup_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid topup id") from exc

    topup = db.get(WalletTopup, topup_id)
    if not topup or topup.user_id != user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Topup not found")

    if payload.provider_reference:
        topup.provider_reference = payload.provider_reference

    if topup.status != "succeeded":
        wallet_service.create_ledger_entry(
            db,
            user_id=user.id,
            amount_cents=topup.amount_rub_cents,
            currency="RUB",
            entry_type="topup",
            description=f"{topup.provider} topup",
            idempotency_key=payload.idempotency_key,
        )
        topup.status = "succeeded"
        topup.updated_at = wallet_service.utcnow()
        db.add(topup)
        db.commit()
        db.refresh(topup)
    else:
        db.commit()

    balance = wallet_service.compute_balance(db, user.id)
    return TopupConfirmResponse(topup_id=str(topup.id), status=topup.status, balance_cents=balance)
