"""add oauth state table

Revision ID: 0012_oauth_state
Revises: 0011_analytics_support
Create Date: 2026-01-24 00:00:00.000000
"""

from __future__ import annotations

import sqlalchemy as sa
from alembic import op

revision = "0012_oauth_state"
down_revision = "0011_analytics_support"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "oauth_states",
        sa.Column("state", sa.String(length=128), nullable=False),
        sa.Column("provider", sa.String(length=50), nullable=False),
        sa.Column("code_verifier", sa.String(length=255), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("state"),
    )
    op.create_index("ix_oauth_states_expires_at", "oauth_states", ["expires_at"])
    op.create_index("ix_oauth_states_provider", "oauth_states", ["provider"])


def downgrade() -> None:
    op.drop_index("ix_oauth_states_provider", table_name="oauth_states")
    op.drop_index("ix_oauth_states_expires_at", table_name="oauth_states")
    op.drop_table("oauth_states")
