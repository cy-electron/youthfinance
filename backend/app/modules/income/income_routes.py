from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.common.responses import success_response
from app.common.validators import validate_schema

from app.modules.income.income_schema import (
    CreateIncomeSchema,
    UpdateIncomeSchema
)
from app.modules.income.income_service import IncomeService


income_bp = Blueprint(
    "income",
    __name__,
    url_prefix="/api/income"
)

create_income_schema = CreateIncomeSchema()
update_income_schema = UpdateIncomeSchema()


@income_bp.route("", methods=["POST"])
@jwt_required()
def create_income():

    data = validate_schema(
        create_income_schema,
        request.get_json()
    )

    result = IncomeService.create_income(
        get_jwt_identity(),
        data
    )

    return success_response(
        message=result["message"],
        data=result["income"],
        status_code=201
    )


@income_bp.route("", methods=["GET"])
@jwt_required()
def get_all_incomes():

    incomes = IncomeService.get_all_incomes(
        get_jwt_identity()
    )

    return success_response(
        data=incomes
    )


@income_bp.route("/<int:income_id>", methods=["GET"])
@jwt_required()
def get_income(income_id):

    income = IncomeService.get_income(
        get_jwt_identity(),
        income_id
    )

    return success_response(
        data={
            "id": income.id,
            "source": income.source,
            "amount": float(income.amount),
            "date": str(income.date),
            "description": income.description
        }
    )


@income_bp.route("/<int:income_id>", methods=["PUT"])
@jwt_required()
def update_income(income_id):

    data = validate_schema(
        update_income_schema,
        request.get_json()
    )

    result = IncomeService.update_income(
        get_jwt_identity(),
        income_id,
        data
    )

    return success_response(
        message=result["message"]
    )


@income_bp.route("/<int:income_id>", methods=["DELETE"])
@jwt_required()
def delete_income(income_id):

    result = IncomeService.delete_income(
        get_jwt_identity(),
        income_id
    )

    return success_response(
        message=result["message"]
    )