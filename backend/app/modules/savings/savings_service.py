from flask_jwt_extended import get_jwt_identity
from sqlalchemy import func

from app.extensions import db
from app.modules.savings.savings_model import Saving
from app.modules.goal.goal_model import Goal
from app.common.exceptions import (
    NotFoundException,
    ValidationException,
)


class SavingService:

    @staticmethod
    def create_saving(data):

        user_id = get_jwt_identity()

        goal_id = data.get("goal_id")
        amount = data["amount"]

        # --------------------------------------------------
        # If saving is assigned to a goal, verify the goal
        # --------------------------------------------------

        goal = None

        if goal_id is not None:

            goal = Goal.query.filter_by(
                id=goal_id,
                user_id=user_id
            ).first()

            if not goal:
                raise NotFoundException(
                    "Goal not found."
                )

            # Don't allow saving beyond target
            remaining = (
                float(goal.target_amount)
                - float(goal.current_amount)
            )

            if float(amount) > remaining:
                raise ValidationException(
                    "Saving amount exceeds the remaining goal amount."
                )

        # --------------------------------------------------
        # Create saving
        # --------------------------------------------------

        saving = Saving(
            user_id=user_id,
            goal_id=goal_id,
            amount=amount,
            date=data["date"],
            description=data.get("description")
        )

        db.session.add(saving)

        # --------------------------------------------------
        # Update goal progress
        # --------------------------------------------------

        if goal is not None:

            goal.current_amount = (
                float(goal.current_amount)
                + float(amount)
            )

            goal.is_completed = (
                goal.current_amount >= goal.target_amount
            )

        db.session.commit()

        return saving


    @staticmethod
    def get_all_savings():

        return Saving.query.filter_by(
            user_id=get_jwt_identity()
        ).order_by(
            Saving.date.desc()
        ).all()


    @staticmethod
    def get_saving(saving_id):

        saving = Saving.query.filter_by(
            id=saving_id,
            user_id=get_jwt_identity()
        ).first()

        if not saving:
            raise NotFoundException(
                "Saving not found."
            )

        return saving


    @staticmethod
    def delete_saving(saving_id):

        saving = SavingService.get_saving(saving_id)

        # If this saving belongs to a goal,
        # reverse the goal progress.

        if saving.goal_id is not None:

            goal = Goal.query.filter_by(
                id=saving.goal_id,
                user_id=get_jwt_identity()
            ).first()

            if goal:

                goal.current_amount = max(
                    0,
                    float(goal.current_amount)
                    - float(saving.amount)
                )

                goal.is_completed = (
                    goal.current_amount >= goal.target_amount
                )

        db.session.delete(saving)

        db.session.commit()