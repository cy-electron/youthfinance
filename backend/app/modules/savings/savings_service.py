from flask_jwt_extended import get_jwt_identity

from app.extensions import db

from app.modules.savings.savings_model import Saving
from app.modules.goal.goal_model import Goal
from app.modules.money.money_allocation_model import MoneyAllocation
from app.modules.money.money_service import MoneyService

from app.common.exceptions import (
    NotFoundException,
    ValidationException,
)


class SavingService:

    # ============================================================
    # CREATE SAVING
    # ============================================================

    @staticmethod
    def create_saving(data):

        user_id = get_jwt_identity()

        saving_type = data.get(
            "saving_type",
            "general"
        )

        goal_id = data.get("goal_id")

        amount = MoneyService._decimal(
            data["amount"]
        )

        if amount <= 0:
            raise ValidationException(
                "Saving amount must be greater than zero."
            )

        # ========================================================
        # GOAL SAVING
        # ========================================================

        if saving_type == "goal":

            if goal_id is None:
                raise ValidationException(
                    "Goal ID is required for goal saving."
                )

            goal = Goal.query.filter_by(
                id=goal_id,
                user_id=user_id
            ).first()

            if not goal:
                raise NotFoundException(
                    "Goal not found."
                )

            current_goal_balance = MoneyService.get_bucket_balance(
                bucket_type=MoneyService.GOAL,
                bucket_id=goal.id,
                user_id=user_id
            )

            remaining = (
                MoneyService._decimal(goal.target_amount)
                - current_goal_balance
            )

            if amount > remaining:
                raise ValidationException(
                    "Saving amount exceeds the remaining goal amount."
                )

            saving = Saving(
                user_id=user_id,
                goal_id=goal.id,
                saving_type="goal",
                amount=amount,
                date=data["date"],
                description=data.get("description")
            )

            db.session.add(saving)
            db.session.flush()

            # General → Goal
            MoneyService.allocate(
                destination_type=MoneyService.GOAL,
                destination_id=goal.id,
                amount=amount,
                reference_type="saving",
                reference_id=saving.id,
                description=(
                    data.get("description")
                    or f"Saving toward goal: {goal.title}"
                )
            )

            goal.current_amount = MoneyService.get_bucket_balance(
                bucket_type=MoneyService.GOAL,
                bucket_id=goal.id,
                user_id=user_id
            )

            goal.is_completed = (
                goal.current_amount
                >= goal.target_amount
            )

        # ========================================================
        # EMERGENCY SAVING
        # ========================================================

        elif saving_type == "emergency":

            if goal_id is not None:
                raise ValidationException(
                    "Emergency saving cannot be linked to a goal."
                )

            saving = Saving(
                user_id=user_id,
                goal_id=None,
                saving_type="emergency",
                amount=amount,
                date=data["date"],
                description=data.get("description")
            )

            db.session.add(saving)
            db.session.flush()

            # General → Emergency
            MoneyService.allocate(
                destination_type=MoneyService.EMERGENCY,
                destination_id=None,
                amount=amount,
                reference_type="saving",
                reference_id=saving.id,
                description=(
                    data.get("description")
                    or "Emergency saving."
                )
            )

        # ========================================================
        # GENERAL SAVING
        # ========================================================

        else:

            if goal_id is not None:
                raise ValidationException(
                    "General saving cannot be linked to a goal."
                )

            saving = Saving(
                user_id=user_id,
                goal_id=None,
                saving_type="general",
                amount=amount,
                date=data["date"],
                description=data.get("description")
            )

            db.session.add(saving)
            db.session.flush()

            # No ledger movement.
            #
            # General money is already the user's
            # unallocated controlled money.
            #
            # This record represents saving history only.

        # ========================================================
        # COMMIT
        # ========================================================

        try:

            db.session.commit()

        except Exception:

            db.session.rollback()
            raise

        return saving

    # ============================================================
    # GET ALL SAVINGS
    # ============================================================

    @staticmethod
    def get_all_savings():

        return Saving.query.filter_by(
            user_id=get_jwt_identity()
        ).order_by(
            Saving.date.desc()
        ).all()

    # ============================================================
    # GET SAVING
    # ============================================================

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

    # ============================================================
    # DELETE SAVING
    # ============================================================

    @staticmethod
    def delete_saving(saving_id):

        user_id = get_jwt_identity()

        saving = SavingService.get_saving(
            saving_id
        )

        amount = MoneyService._decimal(
            saving.amount
        )

        try:

            # ====================================================
            # GOAL SAVING
            # ====================================================

            if saving.saving_type == "goal":

                if saving.goal_id is None:
                    raise ValidationException(
                        "Goal saving is missing its goal."
                    )

                goal = Goal.query.filter_by(
                    id=saving.goal_id,
                    user_id=user_id
                ).first()

                if not goal:
                    raise NotFoundException(
                        "Goal not found."
                    )

                ledger_entry = MoneyAllocation.query.filter_by(
                    user_id=user_id,
                    bucket_type=MoneyService.GOAL,
                    bucket_id=goal.id,
                    entry_type=MoneyService.ALLOCATION,
                    reference_type="saving",
                    reference_id=saving.id
                ).first()

                if not ledger_entry:
                    raise ValidationException(
                        "Saving money movement was not found."
                    )

                goal_balance = MoneyService.get_bucket_balance(
                    bucket_type=MoneyService.GOAL,
                    bucket_id=goal.id,
                    user_id=user_id
                )

                if amount > goal_balance:
                    raise ValidationException(
                        "This saving cannot be deleted because "
                        "the allocated goal money has already been "
                        "spent or moved elsewhere."
                    )

                MoneyService.release(
                    source_type=MoneyService.GOAL,
                    source_id=goal.id,
                    amount=amount,
                    destination_type=MoneyService.GENERAL,
                    destination_id=None,
                    reference_type="saving",
                    reference_id=saving.id,
                    description=(
                        "Saving deleted. "
                        "Money returned to General."
                    )
                )

                goal.current_amount = (
                    MoneyService.get_bucket_balance(
                        bucket_type=MoneyService.GOAL,
                        bucket_id=goal.id,
                        user_id=user_id
                    )
                )

                goal.is_completed = (
                    goal.current_amount
                    >= goal.target_amount
                )

            # ====================================================
            # EMERGENCY SAVING
            # ====================================================

            elif saving.saving_type == "emergency":

                emergency_balance = (
                    MoneyService.get_bucket_balance(
                        bucket_type=MoneyService.EMERGENCY,
                        bucket_id=None,
                        user_id=user_id
                    )
                )

                if amount > emergency_balance:
                    raise ValidationException(
                        "This emergency saving cannot be deleted "
                        "because the emergency money has already "
                        "been used elsewhere."
                    )

                ledger_entry = MoneyAllocation.query.filter_by(
                    user_id=user_id,
                    bucket_type=MoneyService.EMERGENCY,
                    bucket_id=None,
                    entry_type=MoneyService.ALLOCATION,
                    reference_type="saving",
                    reference_id=saving.id
                ).first()

                if not ledger_entry:
                    raise ValidationException(
                        "Emergency saving money movement was not found."
                    )

                # Emergency → General
                MoneyService.release(
                    source_type=MoneyService.EMERGENCY,
                    source_id=None,
                    amount=amount,
                    destination_type=MoneyService.GENERAL,
                    destination_id=None,
                    reference_type="saving",
                    reference_id=saving.id,
                    description=(
                        "Emergency saving deleted. "
                        "Money returned to General."
                    )
                )

            # ====================================================
            # GENERAL SAVING
            # ====================================================

            elif saving.saving_type == "general":

                # No ledger movement.
                #
                # General saving never created a separate
                # controlled-money bucket.

                pass

            # ====================================================
            # DELETE HISTORY RECORD
            # ====================================================

            db.session.delete(saving)

            db.session.commit()

        except Exception:

            db.session.rollback()
            raise