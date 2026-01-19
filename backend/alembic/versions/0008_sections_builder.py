"""sections builder tables

Revision ID: 0008_sections_builder
Revises: 0007_media
Create Date: 2026-01-20

"""

from alembic import op
import sqlalchemy as sa

revision = "0008_sections_builder"
down_revision = "0007_media"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "sections",
        sa.Column("id", sa.Uuid(), primary_key=True, nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("category", sa.String(length=24), nullable=False),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("brief", sa.JSON(), nullable=False),
        sa.Column("ux_config", sa.JSON(), nullable=False),
        sa.Column("ai_workflow", sa.JSON(), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("fee_cents", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("idempotency_key", sa.String(length=64), nullable=True),
        sa.Column("last_run_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_sections_user_id", "sections", ["user_id"])
    op.create_index("ix_sections_category", "sections", ["category"])
    op.create_unique_constraint(
        "uq_sections_idempotency",
        "sections",
        ["user_id", "idempotency_key"],
    )


def downgrade() -> None:
    op.drop_constraint("uq_sections_idempotency", "sections", type_="unique")
    op.drop_index("ix_sections_category", table_name="sections")
    op.drop_index("ix_sections_user_id", table_name="sections")
    op.drop_table("sections")
