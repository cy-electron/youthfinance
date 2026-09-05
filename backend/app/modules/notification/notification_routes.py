from flask import Blueprint, request
from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.common.validators import validate_schema
from app.modules.notification.notification_schema import NotificationPreferenceSchema
from app.modules.notification.notification_service import NotificationService


notification_bp = Blueprint(
    "notification",
    __name__,
    url_prefix="/api/notifications",
)


@notification_bp.route("", methods=["GET"])
@jwt_required()
def get_notifications():
    notifications = NotificationService.get_all()
    return success_response(data=[notification.to_dict() for notification in notifications])


@notification_bp.route("/unread-count", methods=["GET"])
@jwt_required()
def get_unread_count():
    return success_response(data={"count": NotificationService.unread_count()})


@notification_bp.route("/<int:notification_id>/read", methods=["PATCH"])
@jwt_required()
def mark_notification_read(notification_id):
    notification = NotificationService.mark_read(notification_id)
    return success_response(data=notification.to_dict())


@notification_bp.route("/read-all", methods=["POST"])
@jwt_required()
def mark_all_notifications_read():
    NotificationService.mark_all_read()
    return success_response(message="Notifications marked as read.")


@notification_bp.route("/preferences", methods=["GET", "PATCH"])
@jwt_required()
def notification_preferences():
    if request.method == "PATCH":
        data = validate_schema(NotificationPreferenceSchema, request.get_json())
        preference = NotificationService.update_preferences(data)
    else:
        preference = NotificationService.get_preferences()
        # Persist a first-use preference record so the selected default is stable.
        from app.extensions import db
        db.session.commit()

    return success_response(data=preference.to_dict())
