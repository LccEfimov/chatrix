import uuid
from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(String(320), unique=True, index=True)
    plan_code: Mapped[str] = mapped_column(
        ForeignKey("plans.code"), default="ZERO", index=True
    )
    plan: Mapped["Plan"] = relationship()
    oauth_accounts: Mapped[list["OAuthAccount"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    sessions: Mapped[list["AuthSession"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )


from app.models.auth_session import AuthSession  # noqa: E402
from app.models.oauth_account import OAuthAccount  # noqa: E402
from app.models.plan import Plan  # noqa: E402
