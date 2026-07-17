from datetime import datetime

from flask import Blueprint
from flask import request

from flask_jwt_extended import jwt_required

from app.common.responses import success_response

from app.analytics.financial_planner.planner_service import (
    FinancialPlannerService
)

planner_bp = Blueprint(
    "planner",
    __name__,
    url_prefix="/api/planner"
)


@planner_bp.route("/", methods=["POST"])
@jwt_required()
def planner():

    data = request.json

    target_amount = float(
        data["target_amount"]
    )

    target_date = datetime.strptime(
        data["target_date"],
        "%Y-%m-%d"
    ).date()

    result = FinancialPlannerService.analyze(
        target_amount,
        target_date
    )

    return success_response(data=result)