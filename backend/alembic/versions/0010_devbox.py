"""devbox infra rates and packages

Revision ID: 0010_devbox
Revises: 0009_docs_files
Create Date: 2026-01-20

"""

from datetime import datetime, timezone
from decimal import Decimal

from alembic import op
import sqlalchemy as sa

revision = "0010_devbox"
down_revision = "0009_docs_files"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "infra_rates",
        sa.Column("id", sa.Integer(), primary_key=True, nullable=False),
        sa.Column("cpu_core_hour_rub", sa.Numeric(12, 2), nullable=False),
        sa.Column("ram_gb_hour_rub", sa.Numeric(12, 2), nullable=False),
        sa.Column("disk_gb_month_rub", sa.Numeric(12, 2), nullable=False),
        sa.Column("egress_gb_rub", sa.Numeric(12, 2), nullable=False),
        sa.Column("platform_fee_rub", sa.Numeric(12, 2), nullable=False),
        sa.Column("margin_percent", sa.Numeric(5, 2), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_infra_rates_is_active", "infra_rates", ["is_active"])

    op.create_table(
        "devbox_packages",
        sa.Column("code", sa.String(length=8), primary_key=True, nullable=False),
        sa.Column("name", sa.String(length=64), nullable=False),
        sa.Column("cpu_cores", sa.Integer(), nullable=False),
        sa.Column("ram_gb", sa.Integer(), nullable=False),
        sa.Column("disk_gb", sa.Integer(), nullable=False),
        sa.Column("duration_days", sa.Integer(), nullable=False, server_default="30"),
        sa.Column("included_hours", sa.Integer(), nullable=False, server_default="720"),
        sa.Column("egress_gb", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_devbox_packages_is_active", "devbox_packages", ["is_active"])

    op.create_table(
        "devbox_stacks",
        sa.Column("code", sa.String(length=32), primary_key=True, nullable=False),
        sa.Column("name", sa.String(length=64), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_devbox_stacks_is_active", "devbox_stacks", ["is_active"])

    op.create_table(
        "devbox_sessions",
        sa.Column("id", sa.Uuid(), primary_key=True, nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("package_code", sa.String(length=8), nullable=False),
        sa.Column("stack_code", sa.String(length=32), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("cpu_cores", sa.Integer(), nullable=False),
        sa.Column("ram_gb", sa.Integer(), nullable=False),
        sa.Column("disk_gb", sa.Integer(), nullable=False),
        sa.Column("egress_gb", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("hours", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("price_rub", sa.Numeric(12, 2), nullable=False),
        sa.Column("idempotency_key", sa.String(length=64), nullable=True),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("stopped_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["package_code"], ["devbox_packages.code"]),
        sa.ForeignKeyConstraint(["stack_code"], ["devbox_stacks.code"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("user_id", "idempotency_key", name="uq_devbox_sessions_idempotency"),
    )
    op.create_index("ix_devbox_sessions_user_id", "devbox_sessions", ["user_id"])
    op.create_index("ix_devbox_sessions_status", "devbox_sessions", ["status"])

    now = datetime.now(timezone.utc)
    infra_rates_table = sa.table(
        "infra_rates",
        sa.column("id", sa.Integer),
        sa.column("cpu_core_hour_rub", sa.Numeric),
        sa.column("ram_gb_hour_rub", sa.Numeric),
        sa.column("disk_gb_month_rub", sa.Numeric),
        sa.column("egress_gb_rub", sa.Numeric),
        sa.column("platform_fee_rub", sa.Numeric),
        sa.column("margin_percent", sa.Numeric),
        sa.column("is_active", sa.Boolean),
        sa.column("created_at", sa.DateTime),
        sa.column("updated_at", sa.DateTime),
    )
    op.bulk_insert(
        infra_rates_table,
        [
            {
                "id": 1,
                "cpu_core_hour_rub": Decimal("8.00"),
                "ram_gb_hour_rub": Decimal("3.00"),
                "disk_gb_month_rub": Decimal("25.00"),
                "egress_gb_rub": Decimal("5.00"),
                "platform_fee_rub": Decimal("150.00"),
                "margin_percent": Decimal("15.00"),
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            }
        ],
    )

    packages_table = sa.table(
        "devbox_packages",
        sa.column("code", sa.String),
        sa.column("name", sa.String),
        sa.column("cpu_cores", sa.Integer),
        sa.column("ram_gb", sa.Integer),
        sa.column("disk_gb", sa.Integer),
        sa.column("duration_days", sa.Integer),
        sa.column("included_hours", sa.Integer),
        sa.column("egress_gb", sa.Integer),
        sa.column("is_active", sa.Boolean),
        sa.column("created_at", sa.DateTime),
        sa.column("updated_at", sa.DateTime),
    )
    op.bulk_insert(
        packages_table,
        [
            {
                "code": "S",
                "name": "DevBox S",
                "cpu_cores": 1,
                "ram_gb": 2,
                "disk_gb": 10,
                "duration_days": 30,
                "included_hours": 720,
                "egress_gb": 0,
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
            {
                "code": "M",
                "name": "DevBox M",
                "cpu_cores": 2,
                "ram_gb": 4,
                "disk_gb": 30,
                "duration_days": 30,
                "included_hours": 720,
                "egress_gb": 0,
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
            {
                "code": "L",
                "name": "DevBox L",
                "cpu_cores": 4,
                "ram_gb": 8,
                "disk_gb": 80,
                "duration_days": 30,
                "included_hours": 720,
                "egress_gb": 0,
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
        ],
    )

    stacks_table = sa.table(
        "devbox_stacks",
        sa.column("code", sa.String),
        sa.column("name", sa.String),
        sa.column("is_active", sa.Boolean),
        sa.column("created_at", sa.DateTime),
        sa.column("updated_at", sa.DateTime),
    )
    op.bulk_insert(
        stacks_table,
        [
            {
                "code": "python",
                "name": "Python",
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
            {
                "code": "node",
                "name": "Node.js",
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
            {
                "code": "go",
                "name": "Go",
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
        ],
    )


def downgrade() -> None:
    op.drop_index("ix_devbox_sessions_status", table_name="devbox_sessions")
    op.drop_index("ix_devbox_sessions_user_id", table_name="devbox_sessions")
    op.drop_table("devbox_sessions")
    op.drop_index("ix_devbox_stacks_is_active", table_name="devbox_stacks")
    op.drop_table("devbox_stacks")
    op.drop_index("ix_devbox_packages_is_active", table_name="devbox_packages")
    op.drop_table("devbox_packages")
    op.drop_index("ix_infra_rates_is_active", table_name="infra_rates")
    op.drop_table("infra_rates")
