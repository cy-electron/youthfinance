from sqlalchemy import Numeric

from app.extensions import db
from app.models.base_model import BaseModel


class Investment(BaseModel):

    __tablename__ = "investments"

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id"),
        nullable=False
    )

    investment_type = db.Column(
        db.String(50),
        nullable=False
    )

    investment_name = db.Column(
        db.String(100),
        nullable=False
    )

    amount = db.Column(
        Numeric(12, 2),
        nullable=False
    )

    current_value = db.Column(
        Numeric(12, 2),
        nullable=True
    )

    investment_date = db.Column(
        db.Date,
        nullable=False
    )

    notes = db.Column(
        db.Text
    )
    def to_dict(self):
        return {
        "id": self.id,
        "user_id": self.user_id,
        "investment_type": self.investment_type,
        "investment_name": self.investment_name,
        "amount": float(self.amount),
        "current_value": float(self.current_value) if self.current_value is not None else None,
        "investment_date": self.investment_date.isoformat() if self.investment_date else None,
        "notes": self.notes,
        "created_at": self.created_at.isoformat() if self.created_at else None,
        "updated_at": self.updated_at.isoformat() if self.updated_at else None,
    }