"""referrals

Revision ID: 0005_referrals
Revises: 0004_wallet_payments_fx
Create Date: 2026-01-19

"""

from decimal import Decimal

from alembic import op
import sqlalchemy as sa

revision = "0005_referrals"
down_revision = "0004_wallet_payments_fx"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("referrer_id", sa.Uuid(), nullable=True))
    op.create_index("ix_users_referrer_id", "users", ["referrer_id"])
    op.create_foreign_key(
        "fk_users_referrer_id",
        "users",
        "users",
        ["referrer_id"],
        ["id"],
        ondelete="SET NULL",
    )

    op.create_table(
        "referral_tiers",
        sa.Column("id", sa.Integer(), primary_key=True, nullable=False),
        sa.Column("plan_code", sa.String(length=32), nullable=False),
        sa.Column("level", sa.Integer(), nullable=False),
        sa.Column("percent", sa.Numeric(5, 2), nullable=False),
        sa.ForeignKeyConstraint(["plan_code"], ["plans.code"], ondelete="CASCADE"),
        sa.UniqueConstraint("plan_code", "level", name="uq_referral_tiers_plan_level"),
    )
    op.create_index("ix_referral_tiers_plan_code", "referral_tiers", ["plan_code"])

    op.create_table(
        "referral_rewards",
        sa.Column("id", sa.Uuid(), primary_key=True, nullable=False),
        sa.Column("referrer_id", sa.Uuid(), nullable=False),
        sa.Column("referred_user_id", sa.Uuid(), nullable=False),
        sa.Column("level", sa.Integer(), nullable=False),
        sa.Column("referrer_plan_code", sa.String(length=32), nullable=False),
        sa.Column("source_plan_code", sa.String(length=32), nullable=False),
        sa.Column("percent", sa.Numeric(5, 2), nullable=False),
        sa.Column("paid_amount_cents", sa.Integer(), nullable=False),
        sa.Column("reward_amount_cents", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["referrer_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["referred_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.UniqueConstraint(
            "referrer_id",
            "referred_user_id",
            "level",
            "source_plan_code",
            name="uq_referral_rewards_unique",
        ),
    )
    op.create_index("ix_referral_rewards_referrer_id", "referral_rewards", ["referrer_id"])
    op.create_index(
        "ix_referral_rewards_referred_user_id", "referral_rewards", ["referred_user_id"]
    )

    referral_tiers_table = sa.table(
        "referral_tiers",
        sa.column("plan_code", sa.String),
        sa.column("level", sa.Integer),
        sa.column("percent", sa.Numeric),
    )

    data: list[dict[str, object]] = []

    def add(plan_code: str, percents: list[Decimal]) -> None:
        for level, percent in enumerate(percents, start=1):
            data.append({"plan_code": plan_code, "level": level, "percent": percent})

    add(
        "CORE",
        [
            Decimal("3"),
            Decimal("2.7"),
            Decimal("2.4"),
            Decimal("2.1"),
            Decimal("1.8"),
            Decimal("1.6"),
            Decimal("1.4"),
            Decimal("1.2"),
            Decimal("1.0"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.45"),
            Decimal("0.4"),
            Decimal("0.35"),
            Decimal("0.3"),
            Decimal("0.25"),
            Decimal("0.2"),
            Decimal("0.18"),
            Decimal("0.16"),
            Decimal("0.14"),
            Decimal("0.12"),
            Decimal("0.10"),
        ],
    )
    add(
        "START",
        [
            Decimal("5"),
            Decimal("4.5"),
            Decimal("4"),
            Decimal("3.6"),
            Decimal("3.2"),
            Decimal("2.8"),
            Decimal("2.4"),
            Decimal("2.0"),
            Decimal("1.8"),
            Decimal("1.6"),
            Decimal("1.4"),
            Decimal("1.2"),
            Decimal("1.0"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.4"),
            Decimal("0.3"),
            Decimal("0.25"),
            Decimal("0.2"),
            Decimal("0.15"),
            Decimal("0.12"),
            Decimal("0.10"),
        ],
    )
    add(
        "PRIME",
        [
            Decimal("5.5"),
            Decimal("5.0"),
            Decimal("4.5"),
            Decimal("4.0"),
            Decimal("3.5"),
            Decimal("3.1"),
            Decimal("2.7"),
            Decimal("2.3"),
            Decimal("2.0"),
            Decimal("1.8"),
            Decimal("1.6"),
            Decimal("1.4"),
            Decimal("1.2"),
            Decimal("1.0"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.4"),
            Decimal("0.3"),
            Decimal("0.22"),
            Decimal("0.16"),
            Decimal("0.12"),
            Decimal("0.10"),
        ],
    )
    add(
        "ADVANCED",
        [
            Decimal("6"),
            Decimal("5.5"),
            Decimal("5"),
            Decimal("4.5"),
            Decimal("4"),
            Decimal("3.5"),
            Decimal("3"),
            Decimal("2.7"),
            Decimal("2.4"),
            Decimal("2.1"),
            Decimal("1.8"),
            Decimal("1.5"),
            Decimal("1.2"),
            Decimal("1.0"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.4"),
            Decimal("0.3"),
            Decimal("0.2"),
            Decimal("0.15"),
            Decimal("0.12"),
            Decimal("0.10"),
        ],
    )
    add(
        "STUDIO",
        [
            Decimal("7"),
            Decimal("6"),
            Decimal("5.5"),
            Decimal("5"),
            Decimal("4.5"),
            Decimal("4"),
            Decimal("3.5"),
            Decimal("3"),
            Decimal("2.5"),
            Decimal("2.2"),
            Decimal("2.0"),
            Decimal("1.6"),
            Decimal("1.2"),
            Decimal("1.0"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.4"),
            Decimal("0.3"),
            Decimal("0.2"),
            Decimal("0.15"),
            Decimal("0.12"),
            Decimal("0.10"),
        ],
    )
    add(
        "BUSINESS",
        [
            Decimal("8"),
            Decimal("7"),
            Decimal("6"),
            Decimal("5.5"),
            Decimal("5"),
            Decimal("4.5"),
            Decimal("4"),
            Decimal("3.5"),
            Decimal("3"),
            Decimal("2.5"),
            Decimal("2"),
            Decimal("1.5"),
            Decimal("1.2"),
            Decimal("1.0"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.4"),
            Decimal("0.3"),
            Decimal("0.2"),
            Decimal("0.15"),
            Decimal("0.12"),
            Decimal("0.10"),
        ],
    )
    add(
        "BLD_DIALOGUE",
        [
            Decimal("5.8"),
            Decimal("5.2"),
            Decimal("4.6"),
            Decimal("4.0"),
            Decimal("3.6"),
            Decimal("3.2"),
            Decimal("2.8"),
            Decimal("2.4"),
            Decimal("2.1"),
            Decimal("1.9"),
            Decimal("1.7"),
            Decimal("1.5"),
            Decimal("1.2"),
            Decimal("1.0"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.4"),
            Decimal("0.3"),
            Decimal("0.2"),
            Decimal("0.15"),
            Decimal("0.12"),
            Decimal("0.10"),
        ],
    )
    add(
        "BLD_MEDIA",
        [
            Decimal("7.5"),
            Decimal("7.0"),
            Decimal("6.0"),
            Decimal("5.5"),
            Decimal("5.0"),
            Decimal("4.5"),
            Decimal("4.0"),
            Decimal("3.5"),
            Decimal("3.0"),
            Decimal("2.5"),
            Decimal("2.0"),
            Decimal("1.5"),
            Decimal("1.2"),
            Decimal("1.0"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.4"),
            Decimal("0.3"),
            Decimal("0.2"),
            Decimal("0.15"),
            Decimal("0.12"),
            Decimal("0.10"),
        ],
    )
    add(
        "BLD_DOCS",
        [
            Decimal("6.5"),
            Decimal("6.0"),
            Decimal("5.5"),
            Decimal("5.0"),
            Decimal("4.5"),
            Decimal("4.0"),
            Decimal("3.5"),
            Decimal("3.0"),
            Decimal("2.6"),
            Decimal("2.2"),
            Decimal("2.0"),
            Decimal("1.6"),
            Decimal("1.2"),
            Decimal("1.0"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.4"),
            Decimal("0.3"),
            Decimal("0.2"),
            Decimal("0.15"),
            Decimal("0.12"),
            Decimal("0.10"),
        ],
    )
    add(
        "DEV",
        [
            Decimal("10"),
            Decimal("9"),
            Decimal("8"),
            Decimal("7"),
            Decimal("6"),
            Decimal("5"),
            Decimal("4"),
            Decimal("3.5"),
            Decimal("3"),
            Decimal("2.5"),
            Decimal("2"),
            Decimal("1.5"),
            Decimal("1.2"),
            Decimal("1.0"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.4"),
            Decimal("0.3"),
            Decimal("0.2"),
            Decimal("0.15"),
            Decimal("0.12"),
            Decimal("0.10"),
        ],
    )
    add(
        "VIP",
        [
            Decimal("12"),
            Decimal("11"),
            Decimal("10"),
            Decimal("9"),
            Decimal("8"),
            Decimal("7"),
            Decimal("6"),
            Decimal("5"),
            Decimal("4"),
            Decimal("3"),
            Decimal("2"),
            Decimal("1"),
            Decimal("0.9"),
            Decimal("0.8"),
            Decimal("0.7"),
            Decimal("0.6"),
            Decimal("0.5"),
            Decimal("0.4"),
            Decimal("0.3"),
            Decimal("0.2"),
            Decimal("0.09"),
            Decimal("0.08"),
            Decimal("0.07"),
            Decimal("0.06"),
            Decimal("0.05"),
        ],
    )

    op.bulk_insert(referral_tiers_table, data)


def downgrade() -> None:
    op.drop_index("ix_referral_rewards_referred_user_id", table_name="referral_rewards")
    op.drop_index("ix_referral_rewards_referrer_id", table_name="referral_rewards")
    op.drop_table("referral_rewards")
    op.drop_index("ix_referral_tiers_plan_code", table_name="referral_tiers")
    op.drop_table("referral_tiers")
    op.drop_constraint("fk_users_referrer_id", "users", type_="foreignkey")
    op.drop_index("ix_users_referrer_id", table_name="users")
    op.drop_column("users", "referrer_id")
