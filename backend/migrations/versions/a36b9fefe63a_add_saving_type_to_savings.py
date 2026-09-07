"""add saving type to savings

Revision ID: a36b9fefe63a
Revises: a1b2c3d4e5f6
Create Date: 2026-09-07 14:05:12.584166

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "a36b9fefe63a"
down_revision = "a1b2c3d4e5f6"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column(
        "savings",
        sa.Column(
            "saving_type",
            sa.String(length=20),
            nullable=False,
            server_default="general",
        ),
    )


def downgrade():
    op.drop_column("savings", "saving_type")