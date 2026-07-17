from flask import Blueprint
from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.analytics.dashboard.dashboard_service import DashboardService

dashboard_bp = Blueprint(
    "dashboard",
    __name__,
    url_prefix="/api/dashboard"
)


@dashboard_bp.route("/summary", methods=["GET"])
@jwt_required()
def dashboard_summary():

    summary = DashboardService.get_dashboard_summary()

    return success_response(data=summary)