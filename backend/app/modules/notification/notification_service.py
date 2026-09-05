from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.common.exceptions import NotFoundException
from app.modules.notification.notification_model import Notification
from app.modules.notification.notification_preference_model import (
    NotificationPreference,
)


class NotificationService:
    @staticmethod
    def _user_id():
        return int(get_jwt_identity())

    @staticmethod
    def _preference(user_id):
        preference = NotificationPreference.query.filter_by(
            user_id=user_id,
        ).first()

        if preference is None:
            preference = NotificationPreference(user_id=user_id)
            db.session.add(preference)

        return preference

    @staticmethod
    def get_preferences():
        return NotificationService._preference(NotificationService._user_id())

    @staticmethod
    def update_preferences(data):
        preference = NotificationService.get_preferences()
        preference.emergency_fund_enabled = data["emergency_fund_enabled"]
        db.session.commit()
        return preference

    @staticmethod
    def create_emergency_fund_notification(title, message):
        user_id = NotificationService._user_id()
        preference = NotificationService._preference(user_id)

        if not preference.emergency_fund_enabled:
            return None

        notification = Notification(
            user_id=user_id,
            notification_type="emergency_fund",
            title=title,
            message=message,
        )
        db.session.add(notification)
        return notification

    @staticmethod
    def get_all():
        return Notification.query.filter_by(
            user_id=NotificationService._user_id(),
        ).order_by(Notification.created_at.desc()).all()

    @staticmethod
    def unread_count():
        return Notification.query.filter_by(
            user_id=NotificationService._user_id(),
            is_read=False,
        ).count()

    @staticmethod
    def mark_read(notification_id):
        notification = Notification.query.filter_by(
            id=notification_id,
            user_id=NotificationService._user_id(),
        ).first()

        if notification is None:
            raise NotFoundException("Notification not found.")

        notification.is_read = True
        db.session.commit()
        return notification

    @staticmethod
    def mark_all_read():
        Notification.query.filter_by(
            user_id=NotificationService._user_id(),
            is_read=False,
        ).update({"is_read": True}, synchronize_session=False)
        db.session.commit()
