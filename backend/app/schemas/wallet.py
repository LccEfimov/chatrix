from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, Field


class WalletBalanceResponse(BaseModel):
    balance_cents: int
    currency: str = "RUB"


class WalletLedgerEntryResponse(BaseModel):
    id: str
    amount_cents: int
    currency: str
    entry_type: str
    description: str | None
    idempotency_key: str
    created_at: datetime


class WalletLedgerResponse(BaseModel):
    balance_cents: int
    currency: str = "RUB"
    entries: list[WalletLedgerEntryResponse]


class TopupInitRequest(BaseModel):
    provider: str
    amount: Decimal
    currency: str = "RUB"
    idempotency_key: str = Field(..., min_length=6, max_length=64)


class TopupInitResponse(BaseModel):
    topup_id: str
    status: str
    provider: str
    amount: Decimal
    currency: str
    amount_rub_cents: int
    rate_date: date
    rate_to_rub: Decimal
    markup_percent: Decimal


class TopupConfirmRequest(BaseModel):
    topup_id: str
    idempotency_key: str = Field(..., min_length=6, max_length=64)
    provider_reference: str | None = None


class TopupConfirmResponse(BaseModel):
    topup_id: str
    status: str
    balance_cents: int
    currency: str = "RUB"
