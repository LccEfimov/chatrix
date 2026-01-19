from datetime import datetime
from decimal import Decimal

from sqlalchemy import Boolean, DateTime, Numeric
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class InfraRate(Base):
    __tablename__ = "infra_rates"

    id: Mapped[int] = mapped_column(primary_key=True)
    cpu_core_hour_rub: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    ram_gb_hour_rub: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    disk_gb_month_rub: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    egress_gb_rub: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    platform_fee_rub: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    margin_percent: Mapped[Decimal] = mapped_column(Numeric(5, 2), default=Decimal("0"))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
