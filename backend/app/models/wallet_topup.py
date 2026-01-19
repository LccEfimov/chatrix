import uuid
from datetime import date, datetime
from decimal import Decimal

from sqlalchemy import Date, DateTime, ForeignKey, Integer, Numeric, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class WalletTopup(Base):
    __tablename__ = "wallet_topups"
    __table_args__ = (
        UniqueConstraint("user_id", "idempotency_key", name="uq_wallet_topups_idempotency"),
    )

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    provider: Mapped[str] = mapped_column(String(32))
    status: Mapped[str] = mapped_column(String(32))
    amount_currency: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    currency: Mapped[str] = mapped_column(String(3))
    amount_rub_cents: Mapped[int] = mapped_column(Integer)
    rate_date: Mapped[date] = mapped_column(Date)
    rate_to_rub: Mapped[Decimal] = mapped_column(Numeric(12, 6))
    markup_percent: Mapped[Decimal] = mapped_column(Numeric(5, 2))
    provider_reference: Mapped[str | None] = mapped_column(String(64), nullable=True)
    idempotency_key: Mapped[str] = mapped_column(String(64))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
