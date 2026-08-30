from datetime import date

from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.modules.goal.goal_model import Goal
from app.modules.savings.savings_model import Saving
from app.common.exceptions import (
    NotFoundException,
    ValidationException,
)


class GoalService:

    # ============================================================
    # CREATE GOAL
    # ============================================================

    @staticmethod
    def create_goal(data):

        user_id = get_jwt_identity()

        target_amount = float(data["target_amount"])
        initial_saving_amount = float(
            data.get("initial_saving_amount", 0)
        )

        # --------------------------------------------------
        # VALIDATION
        # --------------------------------------------------

        if initial_saving_amount < 0:
            raise ValidationException(
                "Initial saving cannot be negative."
            )

        if initial_saving_amount > target_amount:
            raise ValidationException(
                "Initial saving cannot be greater than the target amount."
            )

        # --------------------------------------------------
        # CREATE GOAL
        # --------------------------------------------------
        # Start with zero.
        # If initial money exists, it will be added through
        # a Saving record below.
        # --------------------------------------------------

        goal = Goal(
            user_id=user_id,
            title=data["title"],
            target_amount=data["target_amount"],
            current_amount=0,
            target_date=data["target_date"],
            description=data.get("description"),
        )

        db.session.add(goal)

        # Flush so goal.id becomes available before creating
        # the linked Saving record.
        db.session.flush()

        # --------------------------------------------------
        # INITIAL SAVING
        # --------------------------------------------------
        # Treat initial money exactly like "Add Money to Goal".
        # This creates the actual Saving ledger record.
        # --------------------------------------------------

        if initial_saving_amount > 0:

            saving = Saving(
                user_id=user_id,
                goal_id=goal.id,
                amount=initial_saving_amount,
                date=date.today(),
                description=f"Initial saving for goal: {goal.title}",
            )

            db.session.add(saving)

            goal.current_amount = initial_saving_amount

        # --------------------------------------------------
        # COMPLETION STATUS
        # --------------------------------------------------

        goal.is_completed = (
            float(goal.current_amount)
            >= float(goal.target_amount)
        )

        # --------------------------------------------------
        # COMMIT EVERYTHING TOGETHER
        # --------------------------------------------------

        db.session.commit()

        return goal

    # ============================================================
    # GET ALL GOALS
    # ============================================================

    @staticmethod
    def get_all_goals():

        return Goal.query.filter_by(
            user_id=get_jwt_identity()
        ).order_by(
            Goal.target_date.asc()
        ).all()

    # ============================================================
    # GET SINGLE GOAL
    # ============================================================

    @staticmethod
    def get_goal(goal_id):

        goal = Goal.query.filter_by(
            id=goal_id,
            user_id=get_jwt_identity()
        ).first()

        if not goal:
            raise NotFoundException(
                "Goal not found."
            )

        return goal

    # ============================================================
    # UPDATE GOAL
    # ============================================================

    @staticmethod
    def update_goal(goal_id, data):

        goal = GoalService.get_goal(goal_id)

        for key, value in data.items():
            setattr(goal, key, value)

        # --------------------------------------------------
        # Prevent invalid target/current relationship
        # --------------------------------------------------

        if float(goal.current_amount) > float(goal.target_amount):
            raise ValidationException(
                "Current savings cannot be greater than the target amount."
            )

        goal.is_completed = (
            float(goal.current_amount)
            >= float(goal.target_amount)
        )

        db.session.commit()

        return goal

    # ============================================================
    # DELETE GOAL
    # ============================================================

    @staticmethod
    def delete_goal(goal_id):

        goal = GoalService.get_goal(goal_id)

        # --------------------------------------------------
        # PRESERVE ALLOCATED MONEY
        # --------------------------------------------------
        # When a goal is cancelled, its saved money becomes
        # unassigned/general savings.
        #
        # This creates a new Saving record with goal_id=None.
        # --------------------------------------------------

        if goal.current_amount and goal.current_amount > 0:

            unassigned_saving = Saving(
                user_id=goal.user_id,
                goal_id=None,
                amount=goal.current_amount,
                date=date.today(),
                description=(
                    f"Returned from cancelled goal: "
                    f"{goal.title}"
                ),
            )

            db.session.add(unassigned_saving)

        # --------------------------------------------------
        # DELETE GOAL
        # --------------------------------------------------

        db.session.delete(goal)

        db.session.commit()