from sqlalchemy import ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class PlanLimit(Base):
    __tablename__ = "plan_limits"
    __table_args__ = (UniqueConstraint("plan_code", "key", name="uq_plan_limits_key"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    plan_code: Mapped[str] = mapped_column(
        ForeignKey("plans.code", ondelete="CASCADE"), index=True
    )
    key: Mapped[str] = mapped_column(String(64))
    limit_value: Mapped[int] = mapped_column(Integer)

    plan: Mapped["Plan"] = relationship(back_populates="limits")


from app.models.plan import Plan  # noqa: E402
