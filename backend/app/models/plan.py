from sqlalchemy import Boolean, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class Plan(Base):
    __tablename__ = "plans"

    code: Mapped[str] = mapped_column(String(32), primary_key=True)
    name: Mapped[str] = mapped_column(String(120))
    period_months: Mapped[int | None] = mapped_column(Integer, nullable=True)
    price_rub: Mapped[int] = mapped_column(Integer)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    limits: Mapped[list["PlanLimit"]] = relationship(
        back_populates="plan", cascade="all, delete-orphan"
    )
    entitlements: Mapped[list["PlanEntitlement"]] = relationship(
        back_populates="plan", cascade="all, delete-orphan"
    )


from app.models.plan_entitlement import PlanEntitlement  # noqa: E402
from app.models.plan_limit import PlanLimit  # noqa: E402
