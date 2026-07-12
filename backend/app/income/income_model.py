from app.extensions import db
from app.models.base_model import BaseModel


class Income(BaseModel):
    __tablename__ = "incomes"

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id"),
        nullable=False
    )

    source = db.Column(
        db.String(100),
        nullable=False
    )

    amount = db.Column(
        db.Numeric(10, 2),
        nullable=False
    )

    date = db.Column(
        db.Date,
        nullable=False
    )

    description = db.Column(
        db.String(255)
    )

    user = db.relationship(
        "User",
        backref=db.backref(
            "incomes",
            lazy=True,
            cascade="all, delete-orphan"
        )
    )

    def __repr__(self):
        return f"<Income {self.source} - ₹{self.amount}>"