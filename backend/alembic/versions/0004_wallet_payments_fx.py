"""wallet payments and fx

Revision ID: 0004_wallet_payments_fx
Revises: 0003_plans_and_entitlements
Create Date: 2026-01-19

"""

from alembic import op
import sqlalchemy as sa

revision = "0004_wallet_payments_fx"
down_revision = "0003_plans_and_entitlements"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "fx_rates",
        sa.Column("rate_date", sa.Date(), nullable=False),
        sa.Column("ccy", sa.String(length=3), nullable=False),
        sa.Column("rate_to_rub", sa.Numeric(12, 6), nullable=False),
        sa.Column("fetched_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("source", sa.String(length=32), nullable=False, server_default="CBR"),
        sa.PrimaryKeyConstraint("rate_date", "ccy"),
    )
    op.create_index("ix_fx_rates_rate_date", "fx_rates", ["rate_date"])

    op.create_table(
        "wallet_topups",
        sa.Column("id", sa.Uuid(), primary_key=True, nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("provider", sa.String(length=32), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("amount_currency", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False),
        sa.Column("amount_rub_cents", sa.Integer(), nullable=False),
        sa.Column("rate_date", sa.Date(), nullable=False),
        sa.Column("rate_to_rub", sa.Numeric(12, 6), nullable=False),
        sa.Column("markup_percent", sa.Numeric(5, 2), nullable=False),
        sa.Column("provider_reference", sa.String(length=64), nullable=True),
        sa.Column("idempotency_key", sa.String(length=64), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("user_id", "idempotency_key", name="uq_wallet_topups_idempotency"),
    )
    op.create_index("ix_wallet_topups_user_id", "wallet_topups", ["user_id"])

    op.create_table(
        "wallet_ledger",
        sa.Column("id", sa.Uuid(), primary_key=True, nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("amount_cents", sa.Integer(), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False, server_default="RUB"),
        sa.Column("entry_type", sa.String(length=32), nullable=False),
        sa.Column("description", sa.String(length=255), nullable=True),
        sa.Column("idempotency_key", sa.String(length=64), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("user_id", "idempotency_key", name="uq_wallet_ledger_idempotency"),
    )
    op.create_index("ix_wallet_ledger_user_id", "wallet_ledger", ["user_id"])


def downgrade() -> None:
    op.drop_index("ix_wallet_ledger_user_id", table_name="wallet_ledger")
    op.drop_table("wallet_ledger")
    op.drop_index("ix_wallet_topups_user_id", table_name="wallet_topups")
    op.drop_table("wallet_topups")
    op.drop_index("ix_fx_rates_rate_date", table_name="fx_rates")
    op.drop_table("fx_rates")
