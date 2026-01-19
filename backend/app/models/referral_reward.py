import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import DateTime, ForeignKey, Integer, Numeric, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class ReferralReward(Base):
    __tablename__ = "referral_rewards"
    __table_args__ = (
        UniqueConstraint(
            "referrer_id",
            "referred_user_id",
            "level",
            "source_plan_code",
            name="uq_referral_rewards_unique",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    referrer_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    referred_user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    level: Mapped[int] = mapped_column(Integer)
    referrer_plan_code: Mapped[str] = mapped_column(String(32))
    source_plan_code: Mapped[str] = mapped_column(String(32))
    percent: Mapped[Decimal] = mapped_column(Numeric(5, 2))
    paid_amount_cents: Mapped[int] = mapped_column(Integer)
    reward_amount_cents: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
