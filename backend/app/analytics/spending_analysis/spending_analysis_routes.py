from flask import Blueprint

from flask_jwt_extended import jwt_required

from app.common.responses import success_response

from app.analytics.spending_analysis.spending_analysis_service import (
    SpendingAnalysisService
)

analysis_bp = Blueprint(
    "analysis",
    __name__,
    url_prefix="/api/spending-analysis"
)


@analysis_bp.route("/", methods=["GET"])
@jwt_required()
def analyze():

    data = SpendingAnalysisService.analyze()

    return success_response(data=data)