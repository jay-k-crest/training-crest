"""create phone number for user column

Revision ID: 5fff31d518cd
Revises: 
Create Date: 2026-02-03 10:29:09.451903

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '5fff31d518cd'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('users', sa.Column('phone_number', sa.String(),nullable=True))


def downgrade() -> None:
    op.drop_column('users', 'phone_number')

