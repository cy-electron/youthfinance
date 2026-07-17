from flask import Blueprint
from flask import request

from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.common.validators import validate_schema

from app.modules.investment.investment_schema import (
    investment_schema,
    investment_update_schema
)
from app.modules.investment.investment_service import InvestmentService

investment_bp = Blueprint(
    "investment",
    __name__,
    url_prefix="/api/investments"
)


@investment_bp.route("/", methods=["POST"])
@jwt_required()
def create():

    data = validate_schema(
        investment_schema,
        request.json
    )

    investment = InvestmentService.create(data)

    return success_response(
        data=investment.to_dict(),
        message="Investment created successfully."
    )


@investment_bp.route("/", methods=["GET"])
@jwt_required()
def get_all():

    investments = InvestmentService.get_all()

    return success_response(
        data=[i.to_dict() for i in investments]
    )


@investment_bp.route("/<int:investment_id>", methods=["GET"])
@jwt_required()
def get_by_id(investment_id):

    investment = InvestmentService.get_by_id(
        investment_id
    )

    return success_response(
        data=investment.to_dict()
    )


@investment_bp.route("/<int:investment_id>", methods=["PUT"])
@jwt_required()
def update(investment_id):

    data = validate_schema(
        investment_update_schema,
        request.json
    )

    investment = InvestmentService.update(
        investment_id,
        data
    )

    return success_response(
        data=investment.to_dict(),
        message="Investment updated successfully."
    )


@investment_bp.route("/<int:investment_id>", methods=["DELETE"])
@jwt_required()
def delete(investment_id):

    InvestmentService.delete(investment_id)

    return success_response(
        message="Investment deleted successfully."
    )