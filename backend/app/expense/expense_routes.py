from flask import Blueprint, request
from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.common.validators import validate_schema
from app.expense.expense_schema import (
    CreateExpenseSchema,
    UpdateExpenseSchema,
)
from app.expense.expense_service import ExpenseService

expense_bp = Blueprint(
    "expense",
    __name__,
    url_prefix="/api/expense"
)


@expense_bp.route("/", methods=["POST"])
@jwt_required()
def create_expense():
    data = validate_schema(CreateExpenseSchema, request.json)

    expense = ExpenseService.create_expense(data)

    return success_response(
        message="Expense created successfully.",
        data={
            "id": expense.id
        },
        status_code=201
    )


@expense_bp.route("/", methods=["GET"])
@jwt_required()
def get_expenses():

    expenses = ExpenseService.get_all_expenses()

    data = []

    for expense in expenses:
        data.append({
            "id": expense.id,
            "category": expense.category,
            "amount": float(expense.amount),
            "date": expense.date.isoformat(),
            "description": expense.description
        })

    return success_response(data=data)


@expense_bp.route("/<int:expense_id>", methods=["GET"])
@jwt_required()
def get_expense(expense_id):

    expense = ExpenseService.get_expense(expense_id)

    return success_response(
        data={
            "id": expense.id,
            "category": expense.category,
            "amount": float(expense.amount),
            "date": expense.date.isoformat(),
            "description": expense.description
        }
    )


@expense_bp.route("/<int:expense_id>", methods=["PUT"])
@jwt_required()
def update_expense(expense_id):

    data = validate_schema(UpdateExpenseSchema, request.json)

    expense = ExpenseService.update_expense(
        expense_id,
        data
    )

    return success_response(
        message="Expense updated successfully.",
        data={
            "id": expense.id
        }
    )


@expense_bp.route("/<int:expense_id>", methods=["DELETE"])
@jwt_required()
def delete_expense(expense_id):

    ExpenseService.delete_expense(expense_id)

    return success_response(
        message="Expense deleted successfully."
    )