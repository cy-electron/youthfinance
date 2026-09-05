from flask import Blueprint, request
from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.common.validators import validate_schema

from app.modules.savings.savings_schema import (
    CreateSavingSchema,
)

from app.modules.savings.savings_service import SavingService


saving_bp = Blueprint(
    "saving",
    __name__,
    url_prefix="/api/saving"
)


@saving_bp.route("", methods=["POST"])
@jwt_required()
def create_saving():
    data = validate_schema(CreateSavingSchema, request.get_json())

    saving = SavingService.create_saving(data)

    return success_response(
        message="Saving added successfully.",
        data={
            "id": saving.id,
            "goal_id": saving.goal_id,
            "amount": float(saving.amount),
            "date": saving.date.isoformat(),
            "description": saving.description,
            "saving_type": saving.saving_type,
        },
        status_code=201,
    )

@saving_bp.route("", methods=["GET"])
@jwt_required()
def get_savings():
    savings = SavingService.get_all_savings()

    data = [
        {
            "id": saving.id,
            "goal_id": saving.goal_id,
            "amount": float(saving.amount),
            "date": saving.date.isoformat(),
            "description": saving.description,
            "saving_type": saving.saving_type,
        }
        for saving in savings
    ]

    return success_response(data=data)

@saving_bp.route("/<int:saving_id>", methods=["GET"])
@jwt_required()
def get_saving(saving_id):

    saving = SavingService.get_saving(saving_id)

    return success_response(
        data={
            "id": saving.id,
            "goal_id": saving.goal_id,
            "amount": float(saving.amount),
            "date": saving.date.isoformat(),
            "description": saving.description,
        }
    )


@saving_bp.route("/<int:saving_id>", methods=["DELETE"])
@jwt_required()
def delete_saving(saving_id):

    SavingService.delete_saving(saving_id)

    return success_response(
        message="Saving deleted successfully."
    )