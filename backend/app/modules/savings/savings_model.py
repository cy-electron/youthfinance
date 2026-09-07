from app.extensions import db
from app.models.base_model import BaseModel


class Saving(BaseModel):
    __tablename__ = "savings"

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id"),
        nullable=False
    )

    goal_id = db.Column(
        db.Integer,
        db.ForeignKey("goals.id"),
        nullable=True
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
        db.Text,
        nullable=True
    )

    saving_type = db.Column(
        db.String(20),
        nullable=False,
        default="general"
    )

    user = db.relationship(
        "User",
        backref=db.backref(
            "savings",
            lazy=True,
            cascade="all, delete-orphan"
        )
    )

    goal = db.relationship(
        "Goal",
        backref=db.backref(
            "savings",
            lazy=True
        )
    )

    def __repr__(self):
        return f"<Saving {self.amount}>"