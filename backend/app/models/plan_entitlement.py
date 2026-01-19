from sqlalchemy import Boolean, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class PlanEntitlement(Base):
    __tablename__ = "plan_entitlements"
    __table_args__ = (UniqueConstraint("plan_code", "key", name="uq_plan_entitlements_key"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    plan_code: Mapped[str] = mapped_column(
        ForeignKey("plans.code", ondelete="CASCADE"), index=True
    )
    key: Mapped[str] = mapped_column(String(64))
    is_enabled: Mapped[bool] = mapped_column(Boolean, default=True)

    plan: Mapped["Plan"] = relationship(back_populates="entitlements")


from app.models.plan import Plan  # noqa: E402
