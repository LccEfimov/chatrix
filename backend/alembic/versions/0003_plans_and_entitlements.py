"""plans and entitlements

Revision ID: 0003_plans_and_entitlements
Revises: 0002_auth_tables
Create Date: 2026-01-19

"""

from alembic import op
import sqlalchemy as sa

revision = "0003_plans_and_entitlements"
down_revision = "0002_auth_tables"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "plans",
        sa.Column("code", sa.String(length=32), primary_key=True, nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("period_months", sa.Integer(), nullable=True),
        sa.Column("price_rub", sa.Integer(), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
    )

    plans_table = sa.table(
        "plans",
        sa.column("code", sa.String),
        sa.column("name", sa.String),
        sa.column("period_months", sa.Integer),
        sa.column("price_rub", sa.Integer),
        sa.column("is_active", sa.Boolean),
    )
    op.bulk_insert(
        plans_table,
        [
            {"code": "ZERO", "name": "Zero", "period_months": None, "price_rub": 0, "is_active": True},
            {"code": "CORE", "name": "Core", "period_months": 1, "price_rub": 150, "is_active": True},
            {"code": "START", "name": "Start", "period_months": 3, "price_rub": 500, "is_active": True},
            {"code": "PRIME", "name": "Prime", "period_months": 3, "price_rub": 800, "is_active": True},
            {"code": "ADVANCED", "name": "Advanced", "period_months": 3, "price_rub": 1100, "is_active": True},
            {"code": "STUDIO", "name": "Studio", "period_months": 3, "price_rub": 1400, "is_active": True},
            {"code": "BUSINESS", "name": "Business", "period_months": 3, "price_rub": 2000, "is_active": True},
            {
                "code": "BLD_DIALOGUE",
                "name": "Builder • Dialogue",
                "period_months": 3,
                "price_rub": 700,
                "is_active": True,
            },
            {
                "code": "BLD_MEDIA",
                "name": "Builder • Media",
                "period_months": 3,
                "price_rub": 700,
                "is_active": True,
            },
            {
                "code": "BLD_DOCS",
                "name": "Builder • Docs",
                "period_months": 3,
                "price_rub": 700,
                "is_active": True,
            },
            {"code": "VIP", "name": "VIP • Signature", "period_months": None, "price_rub": 15000, "is_active": True},
            {"code": "DEV", "name": "Developer • Gate", "period_months": 12, "price_rub": 5000, "is_active": True},
        ],
    )

    op.create_table(
        "plan_limits",
        sa.Column("id", sa.Integer(), primary_key=True, nullable=False),
        sa.Column("plan_code", sa.String(length=32), nullable=False),
        sa.Column("key", sa.String(length=64), nullable=False),
        sa.Column("limit_value", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["plan_code"], ["plans.code"], ondelete="CASCADE"),
        sa.UniqueConstraint("plan_code", "key", name="uq_plan_limits_key"),
    )
    op.create_index("ix_plan_limits_plan_code", "plan_limits", ["plan_code"])

    op.create_table(
        "plan_entitlements",
        sa.Column("id", sa.Integer(), primary_key=True, nullable=False),
        sa.Column("plan_code", sa.String(length=32), nullable=False),
        sa.Column("key", sa.String(length=64), nullable=False),
        sa.Column("is_enabled", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.ForeignKeyConstraint(["plan_code"], ["plans.code"], ondelete="CASCADE"),
        sa.UniqueConstraint("plan_code", "key", name="uq_plan_entitlements_key"),
    )
    op.create_index("ix_plan_entitlements_plan_code", "plan_entitlements", ["plan_code"])

    op.add_column(
        "users",
        sa.Column(
            "plan_code",
            sa.String(length=32),
            nullable=False,
            server_default=sa.text("'ZERO'"),
        ),
    )
    op.create_index("ix_users_plan_code", "users", ["plan_code"])
    op.create_foreign_key("fk_users_plan_code", "users", "plans", ["plan_code"], ["code"])


def downgrade() -> None:
    op.drop_constraint("fk_users_plan_code", "users", type_="foreignkey")
    op.drop_index("ix_users_plan_code", table_name="users")
    op.drop_column("users", "plan_code")
    op.drop_index("ix_plan_entitlements_plan_code", table_name="plan_entitlements")
    op.drop_table("plan_entitlements")
    op.drop_index("ix_plan_limits_plan_code", table_name="plan_limits")
    op.drop_table("plan_limits")
    op.drop_table("plans")
