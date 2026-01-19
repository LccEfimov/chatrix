"""docs files tables

Revision ID: 0009_docs_files
Revises: 0008_sections_builder
Create Date: 2026-01-20

"""

from alembic import op
import sqlalchemy as sa

revision = "0009_docs_files"
down_revision = "0008_sections_builder"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "files",
        sa.Column("id", sa.Uuid(), primary_key=True, nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("filename", sa.String(length=255), nullable=False),
        sa.Column("extension", sa.String(length=16), nullable=False),
        sa.Column("content_type", sa.String(length=120), nullable=False),
        sa.Column("size_bytes", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(length=24), nullable=False),
        sa.Column("storage_path", sa.String(length=500), nullable=True),
        sa.Column("idempotency_key", sa.String(length=64), nullable=True),
        sa.Column("parsed_text", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_files_user_id", "files", ["user_id"])
    op.create_index("ix_files_extension", "files", ["extension"])
    op.create_index("ix_files_status", "files", ["status"])
    op.create_unique_constraint(
        "uq_files_idempotency",
        "files",
        ["user_id", "idempotency_key"],
    )


def downgrade() -> None:
    op.drop_constraint("uq_files_idempotency", "files", type_="unique")
    op.drop_index("ix_files_status", table_name="files")
    op.drop_index("ix_files_extension", table_name="files")
    op.drop_index("ix_files_user_id", table_name="files")
    op.drop_table("files")
