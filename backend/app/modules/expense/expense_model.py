from app.extensions import db
from app.models.base_model import BaseModel


class Expense(BaseModel):
    __tablename__ = "expenses"

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id"),
        nullable=False
    )

    category = db.Column(
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
        db.Text
    )

    user = db.relationship(
        "User",
        backref=db.backref(
            "expenses",
            lazy=True,
            cascade="all, delete-orphan"
        )
    )

    def __repr__(self):
        return f"<Expense {self.category} - {self.amount}>"