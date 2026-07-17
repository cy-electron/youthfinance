from flask import Blueprint
from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.analytics.financial_health.financial_health_service import (
    FinancialHealthService
)

financial_health_bp = Blueprint(
    "financial_health",
    __name__,
    url_prefix="/api/financial-health"
)


@financial_health_bp.route("/", methods=["GET"])
@jwt_required()
def get_score():

    data = FinancialHealthService.calculate_score()

    return success_response(data=data)