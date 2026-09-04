from flask import Blueprint, request
from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.common.validators import validate_schema

from app.modules.emergency.emergency_schema import (
    EmergencyMoneySchema,
)

from app.modules.emergency.emergency_service import (
    EmergencyService,
)


emergency_bp = Blueprint(
    "emergency",
    __name__,
    url_prefix="/api/emergency"
)


# ============================================================
# GET EMERGENCY FUND
# ============================================================

@emergency_bp.route("", methods=["GET"])
@jwt_required()
def get_emergency():

    balance = EmergencyService.get_emergency_balance()

    return success_response(
        data={
            "balance": float(balance)
        }
    )


# ============================================================
# ADD MONEY
# ============================================================

@emergency_bp.route("/add", methods=["POST"])
@jwt_required()
def add_emergency_money():

    data = validate_schema(
        EmergencyMoneySchema,
        request.json
    )

    balance = EmergencyService.add_money(
        amount=data["amount"],
        description=data.get("description")
    )

    return success_response(
        message="Money added to emergency fund successfully.",
        data={
            "balance": float(balance)
        },
        status_code=201
    )


# ============================================================
# USE MONEY
# ============================================================
#
# This endpoint means:
#
# Emergency -> General
#
# For Emergency -> Expense, use the existing
# /api/expense endpoint with source_type="emergency".
# ============================================================

@emergency_bp.route("/use", methods=["POST"])
@jwt_required()
def use_emergency_money():

    data = validate_schema(
        EmergencyMoneySchema,
        request.json
    )

    balance = EmergencyService.release_money(
        amount=data["amount"],
        description=data.get("description")
    )

    return success_response(
        message="Emergency fund money released successfully.",
        data={
            "balance": float(balance)
        }
    )