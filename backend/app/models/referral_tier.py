from decimal import Decimal

from sqlalchemy import ForeignKey, Integer, Numeric, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class ReferralTier(Base):
    __tablename__ = "referral_tiers"
    __table_args__ = (
        UniqueConstraint("plan_code", "level", name="uq_referral_tiers_plan_level"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    plan_code: Mapped[str] = mapped_column(
        ForeignKey("plans.code", ondelete="CASCADE"), index=True
    )
    level: Mapped[int] = mapped_column(Integer)
    percent: Mapped[Decimal] = mapped_column(Numeric(5, 2))
