from sqlalchemy import Numeric

from app.extensions import db
from app.models.base_model import BaseModel


class FunFund(BaseModel):

    __tablename__ = "fun_funds"

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id"),
        nullable=False
    )

    title = db.Column(
        db.String(100),
        nullable=False
    )

    target_amount = db.Column(
        Numeric(12, 2),
        nullable=False
    )

    current_amount = db.Column(
        Numeric(12, 2),
        default=0
    )

    target_date = db.Column(
        db.Date,
        nullable=True
    )

    status = db.Column(
        db.String(30),
        default="Active"
    )

    notes = db.Column(
        db.Text
    )
    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "title": self.title,
            "target_amount": float(self.target_amount),
            "current_amount": float(self.current_amount) if self.current_amount is not None else None,
            "target_date": self.target_date.isoformat() if self.target_date else None,
            "status": self.status,
            "notes": self.notes,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }