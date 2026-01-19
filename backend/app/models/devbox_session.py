import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import DateTime, ForeignKey, Numeric, String, UniqueConstraint, Integer
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class DevboxSession(Base):
    __tablename__ = "devbox_sessions"
    __table_args__ = (
        UniqueConstraint("user_id", "idempotency_key", name="uq_devbox_sessions_idempotency"),
    )

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    package_code: Mapped[str] = mapped_column(ForeignKey("devbox_packages.code"))
    stack_code: Mapped[str] = mapped_column(ForeignKey("devbox_stacks.code"))
    status: Mapped[str] = mapped_column(String(16), index=True)
    cpu_cores: Mapped[int] = mapped_column(Integer)
    ram_gb: Mapped[int] = mapped_column(Integer)
    disk_gb: Mapped[int] = mapped_column(Integer)
    egress_gb: Mapped[int] = mapped_column(Integer, default=0)
    hours: Mapped[int] = mapped_column(Integer, default=0)
    price_rub: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    idempotency_key: Mapped[str | None] = mapped_column(String(64), nullable=True)
    started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    stopped_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
