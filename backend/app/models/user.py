from app.extensions import db
from app.models.base_model import BaseModel


class User(BaseModel):
    __tablename__ = "users"

    full_name = db.Column(db.String(100), nullable=False)

    email = db.Column(
        db.String(120),
        unique=True,
        nullable=False,
        index=True
    )

    password_hash = db.Column(
        db.String(255),
        nullable=False
    )

    is_active = db.Column(
        db.Boolean,
        default=True
    )

    def __repr__(self):
        return f"<User {self.email}>"