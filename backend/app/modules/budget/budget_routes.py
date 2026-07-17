from flask import Blueprint, request
from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.common.validators import validate_schema
from app.modules.budget.budget_schema import (
    CreateBudgetSchema,
    UpdateBudgetSchema,
)
from app.modules.budget.budget_service import BudgetService

budget_bp = Blueprint(
    "budget",
    __name__,
    url_prefix="/api/budget"
)


@budget_bp.route("/", methods=["POST"])
@jwt_required()
def create_budget():

    data = validate_schema(CreateBudgetSchema, request.json)

    budget = BudgetService.create_budget(data)

    return success_response(
        message="Budget created successfully.",
        data={
            "id": budget.id
        },
        status_code=201
    )


@budget_bp.route("/", methods=["GET"])
@jwt_required()
def get_budgets():

    budgets = BudgetService.get_all_budgets()

    data = []

    for budget in budgets:
        data.append({
            "id": budget.id,
            "category": budget.category,
            "amount": float(budget.amount),
            "month": budget.month,
            "year": budget.year,
            
            
        })

    return success_response(data=data)


@budget_bp.route("/<int:budget_id>", methods=["GET"])
@jwt_required()
def get_budget(budget_id):

    budget = BudgetService.get_budget(budget_id)

    return success_response(
      data={
    "id": budget.id,
    "category": budget.category,
    "amount": float(budget.amount),
    "month": budget.month,
    "year": budget.year,
    
})


@budget_bp.route("/<int:budget_id>", methods=["PUT"])
@jwt_required()
def update_budget(budget_id):

    data = validate_schema(UpdateBudgetSchema, request.json)

    budget = BudgetService.update_budget(
        budget_id,
        data
    )

    return success_response(
        message="Budget updated successfully.",
        data={
            "id": budget.id
        }
    )


@budget_bp.route("/<int:budget_id>", methods=["DELETE"])
@jwt_required()
def delete_budget(budget_id):

    BudgetService.delete_budget(budget_id)

    return success_response(
        message="Budget deleted successfully."
    )