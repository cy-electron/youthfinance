from flask import Blueprint
from flask import request

from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.common.validators import validate_schema

from app.modules.fun_fund.fun_fund_schema import (
    CreateFunFundSchema,
    UpdateFunFundSchema,
)

from app.modules.fun_fund.fun_fund_service import (
    FunFundService,
)


fun_fund_bp = Blueprint(
    "fun_fund",
    __name__,
    url_prefix="/api/fun-funds",
)


# ============================================================
# CREATE
# ============================================================

@fun_fund_bp.route("/", methods=["POST"])
@jwt_required()
def create():

    data = validate_schema(
        CreateFunFundSchema,
        request.json,
    )

    fund = FunFundService.create(data)

    return success_response(
        data=fund.to_dict(),
        message="Fun Fund created successfully.",
    )


# ============================================================
# GET ALL
# ============================================================

@fun_fund_bp.route("/", methods=["GET"])
@jwt_required()
def get_all():

    funds = FunFundService.get_all()

    return success_response(
        data=[f.to_dict() for f in funds],
    )


# ============================================================
# GET ONE
# ============================================================

@fun_fund_bp.route("/<int:fun_fund_id>", methods=["GET"])
@jwt_required()
def get_by_id(fun_fund_id):

    fund = FunFundService.get_by_id(
        fun_fund_id,
    )

    return success_response(
        data=fund.to_dict(),
    )


# ============================================================
# UPDATE
# ============================================================

@fun_fund_bp.route("/<int:fun_fund_id>", methods=["PUT"])
@jwt_required()
def update(fun_fund_id):

    data = validate_schema(
        UpdateFunFundSchema,
        request.json,
    )

    fund = FunFundService.update(
        fun_fund_id,
        data,
    )

    return success_response(
        data=fund.to_dict(),
        message="Fun Fund updated successfully.",
    )


# ============================================================
# CANCEL FUN FUND
# ============================================================

@fun_fund_bp.route("/<int:fun_fund_id>", methods=["DELETE"])
@jwt_required()
def delete(fun_fund_id):

    FunFundService.delete(fun_fund_id)

    return success_response(
        message=(
            "Fun Fund cancelled successfully. "
            "Remaining money was returned to the Budget."
        ),
    )


# ============================================================
# FINISH FUN FUND
# ============================================================

@fun_fund_bp.route(
    "/<int:fun_fund_id>/finish",
    methods=["POST"],
)
@jwt_required()
def finish(fun_fund_id):

    data = request.get_json(silent=True) or {}

    expense = FunFundService.finish(
        fun_fund_id,
        data,
    )

    return success_response(
        data={
            "expense_id": expense.id,
            "category": expense.category,
            "amount": float(expense.amount),
            "date": expense.date.isoformat(),
            "description": expense.description,
        },
        message=(
            "Fun Fund finished and recorded as an expense."
        ),
    )