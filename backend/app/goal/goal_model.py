from app.extensions import db
from app.models.base_model import BaseModel


class Goal(BaseModel):
    __tablename__ = "goals"

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id"),
        nullable=False
    )

    title = db.Column(
        db.String(150),
        nullable=False
    )

    target_amount = db.Column(
        db.Numeric(10, 2),
        nullable=False
    )

    current_amount = db.Column(
        db.Numeric(10, 2),
        nullable=False,
        default=0
    )

    target_date = db.Column(
        db.Date,
        nullable=False
    )

    description = db.Column(
        db.Text
    )

    is_completed = db.Column(
        db.Boolean,
        default=False
    )

    user = db.relationship(
        "User",
        backref=db.backref(
            "goals",
            lazy=True,
            cascade="all, delete-orphan"
        )
    )

    def __repr__(self):
        return f"<Goal {self.title}>"