from app.extensions import db
from app.models.base_model import BaseModel


class NotificationPreference(BaseModel):
    __tablename__ = "notification_preferences"

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id"),
        nullable=False,
        unique=True,
    )
    emergency_fund_enabled = db.Column(db.Boolean, nullable=False, default=True)

    def to_dict(self):
        return {
            "emergency_fund_enabled": self.emergency_fund_enabled,
        }
