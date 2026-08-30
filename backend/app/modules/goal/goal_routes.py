from flask import Blueprint, request
from flask_jwt_extended import jwt_required

from app.common.responses import success_response
from app.common.validators import validate_schema

from app.modules.goal.goal_schema import (
    CreateGoalSchema,
    UpdateGoalSchema,
)

from app.modules.goal.goal_service import GoalService


goal_bp = Blueprint(
    "goal",
    __name__,
    url_prefix="/api/goal"
)


# ============================================================
# CREATE GOAL
# ============================================================

@goal_bp.route("/", methods=["POST"])
@jwt_required()
def create_goal():

    data = validate_schema(
        CreateGoalSchema,
        request.json
    )

    goal = GoalService.create_goal(data)

    return success_response(
        message="Goal created successfully.",
        data={
            "id": goal.id,
            "title": goal.title,
            "target_amount": float(goal.target_amount),
            "current_amount": float(goal.current_amount),
            "target_date": goal.target_date.isoformat(),
            "description": goal.description,
            "is_completed": goal.is_completed,
        },
        status_code=201
    )


# ============================================================
# GET ALL GOALS
# ============================================================

@goal_bp.route("/", methods=["GET"])
@jwt_required()
def get_goals():

    goals = GoalService.get_all_goals()

    data = []

    for goal in goals:

        data.append({
            "id": goal.id,
            "title": goal.title,
            "target_amount": float(goal.target_amount),
            "current_amount": float(goal.current_amount),
            "target_date": goal.target_date.isoformat(),
            "description": goal.description,
            "is_completed": goal.is_completed,
        })

    return success_response(
        data=data
    )


# ============================================================
# GET SINGLE GOAL
# ============================================================

@goal_bp.route("/<int:goal_id>", methods=["GET"])
@jwt_required()
def get_goal(goal_id):

    goal = GoalService.get_goal(goal_id)

    return success_response(
        data={
            "id": goal.id,
            "title": goal.title,
            "target_amount": float(goal.target_amount),
            "current_amount": float(goal.current_amount),
            "target_date": goal.target_date.isoformat(),
            "description": goal.description,
            "is_completed": goal.is_completed,
        }
    )


# ============================================================
# UPDATE GOAL
# ============================================================

@goal_bp.route("/<int:goal_id>", methods=["PUT"])
@jwt_required()
def update_goal(goal_id):

    data = validate_schema(
        UpdateGoalSchema,
        request.json
    )

    goal = GoalService.update_goal(
        goal_id,
        data
    )

    return success_response(
        message="Goal updated successfully.",
        data={
            "id": goal.id,
            "title": goal.title,
            "target_amount": float(goal.target_amount),
            "current_amount": float(goal.current_amount),
            "target_date": goal.target_date.isoformat(),
            "description": goal.description,
            "is_completed": goal.is_completed,
        }
    )


# ============================================================
# DELETE GOAL
# ============================================================

@goal_bp.route("/<int:goal_id>", methods=["DELETE"])
@jwt_required()
def delete_goal(goal_id):

    GoalService.delete_goal(goal_id)

    return success_response(
        message="Goal deleted successfully."
    )