from flask import Blueprint
from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.analytics.goal_readiness.goal_readiness_service import (
    GoalReadinessService
)

goal_readiness_bp = Blueprint(
    "goal_readiness",
    __name__,
    url_prefix="/api/goal-readiness"
)


@goal_readiness_bp.route("/<int:goal_id>", methods=["GET"])
@jwt_required()
def analyze_goal(goal_id):

    data = GoalReadinessService.analyze(goal_id)

    return success_response(data=data)