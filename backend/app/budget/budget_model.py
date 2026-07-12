from app.extensions import db
from app.models.base_model import BaseModel


class Budget(BaseModel):
    __tablename__ = "budgets"

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

    month = db.Column(
        db.Integer,
        nullable=False
    )

    year = db.Column(
        db.Integer,
        nullable=False
    )

    user = db.relationship(
        "User",
        backref=db.backref(
            "budgets",
            lazy=True,
            cascade="all, delete-orphan"
        )
    )

    __table_args__ = (
        db.UniqueConstraint(
            "user_id",
            "category",
            "month",
            "year",
            name="unique_budget_per_month"
        ),
    )

    def __repr__(self):
        return f"<Budget {self.category}>"