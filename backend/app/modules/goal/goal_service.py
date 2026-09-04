from decimal import Decimal

from app.extensions import db
from app.modules.goal.goal_model import Goal
from app.modules.savings.savings_model import Saving
from app.modules.money.money_service import MoneyService


class GoalService:

    @staticmethod
    def _user_id():
        from flask_jwt_extended import get_jwt_identity
        return int(get_jwt_identity())

    @staticmethod
    def _decimal(value):
        return Decimal(str(value))

    @staticmethod
    def _sync_goal(goal):
        """
        Synchronize Goal.current_amount and Goal.is_completed
        with the actual Goal bucket balance in the money ledger.

        The Goal table remains the source for Goal information.
        The money ledger is used only to keep the current money
        position accurate.
        """

        balance = MoneyService.get_bucket_balance(
            MoneyService.GOAL,
            goal.id,
            user_id=goal.user_id
        )

        goal.current_amount = balance

        target = GoalService._decimal(goal.target_amount)

        goal.is_completed = balance >= target

        return goal

    # ============================================================
    # CREATE GOAL
    # ============================================================

    @staticmethod
    def create_goal(data):
        user_id = GoalService._user_id()

        title = data["title"]
        target_amount = data["target_amount"]
        initial_saving_amount = data.get(
            "initial_saving_amount",
            Decimal("0")
        )
        target_date = data["target_date"]
        description = data.get("description")

        target_amount = GoalService._decimal(target_amount)
        initial_saving_amount = GoalService._decimal(
            initial_saving_amount
        )

        if target_amount <= 0:
            raise ValueError(
                "Target amount must be greater than zero."
            )

        if initial_saving_amount < 0:
            raise ValueError(
                "Initial saving amount cannot be negative."
            )

        if initial_saving_amount > target_amount:
            raise ValueError(
                "Initial saving amount cannot exceed the target amount."
            )

        # ---------------------------------------------------------
        # Create Goal
        # ---------------------------------------------------------

        goal = Goal(
            user_id=user_id,
            title=title,
            target_amount=target_amount,
            current_amount=Decimal("0"),
            target_date=target_date,
            description=description,
            is_completed=False
        )

        db.session.add(goal)
        db.session.flush()

        # ---------------------------------------------------------
        # Initial Goal Saving
        # ---------------------------------------------------------
        #
        # This is an INTERNAL relocation:
        #
        # General -> Goal
        #
        # It is NOT an Expense.
        # ---------------------------------------------------------

        if initial_saving_amount > 0:

            general_balance = MoneyService.get_general_balance(
                user_id=user_id
            )

            # Never create money that does not exist.
            if general_balance < initial_saving_amount:
                raise ValueError(
                    "Insufficient general savings for the initial goal saving."
                )

            # Create the historical Saving record first so that
            # the ledger can reference the Saving's actual ID.
            saving = Saving(
                user_id=user_id,
                goal_id=goal.id,
                saving_type="goal",
                amount=initial_saving_amount,
                date=target_date,
                description="Initial saving for goal"
            )

            db.session.add(saving)
            db.session.flush()

            # Internal money relocation:
            #
            # General -> Goal
            #
            # This creates MoneyAllocation records only.
            # It does NOT create an Expense record.
            MoneyService.allocate(
                destination_type=MoneyService.GOAL,
                amount=initial_saving_amount,
                destination_id=goal.id,
                description="Initial saving for goal",
                reference_type="saving",
                reference_id=saving.id
            )

        # Synchronize the cached Goal money fields.
        GoalService._sync_goal(goal)

        db.session.commit()

        return goal

    # ============================================================
    # GET ALL GOALS
    # ============================================================

    @staticmethod
    def get_all_goals():
        user_id = GoalService._user_id()

        goals = (
            Goal.query
            .filter_by(user_id=user_id)
            .order_by(Goal.created_at.desc())
            .all()
        )

        # Goals are all-time records.
        # Synchronize their current money position.
        for goal in goals:
            GoalService._sync_goal(goal)

        db.session.commit()

        return goals

    # ============================================================
    # GET SINGLE GOAL
    # ============================================================

    @staticmethod
    def get_goal(goal_id):
        user_id = GoalService._user_id()

        goal = (
            Goal.query
            .filter_by(
                id=goal_id,
                user_id=user_id
            )
            .first()
        )

        if not goal:
            raise ValueError("Goal not found.")

        GoalService._sync_goal(goal)

        db.session.commit()

        return goal

    # ============================================================
    # UPDATE GOAL
    # ============================================================

    @staticmethod
    def update_goal(goal_id, data):
        user_id = GoalService._user_id()

        goal = (
            Goal.query
            .filter_by(
                id=goal_id,
                user_id=user_id
            )
            .first()
        )

        if not goal:
            raise ValueError("Goal not found.")

        # Always use the actual ledger balance when validating
        # the Goal's current saved amount.
        GoalService._sync_goal(goal)

        current_balance = MoneyService.get_bucket_balance(
            MoneyService.GOAL,
            goal.id,
            user_id=user_id
        )

        # ---------------------------------------------------------
        # Target amount
        # ---------------------------------------------------------

        if "target_amount" in data:

            target_amount = GoalService._decimal(
                data["target_amount"]
            )

            if target_amount <= 0:
                raise ValueError(
                    "Target amount must be greater than zero."
                )

            if target_amount < current_balance:
                raise ValueError(
                    "Target amount cannot be less than the amount already saved."
                )

            goal.target_amount = target_amount

        # ---------------------------------------------------------
        # Other Goal information
        # ---------------------------------------------------------

        if "title" in data:
            goal.title = data["title"]

        if "target_date" in data:
            goal.target_date = data["target_date"]

        if "description" in data:
            goal.description = data["description"]

        # Recalculate completion status.
        GoalService._sync_goal(goal)

        db.session.commit()

        return goal

    # ============================================================
    # DELETE GOAL
    # ============================================================

    @staticmethod
    def delete_goal(goal_id):
        user_id = GoalService._user_id()

        goal = (
            Goal.query
            .filter_by(
                id=goal_id,
                user_id=user_id
            )
            .first()
        )

        if not goal:
            raise ValueError("Goal not found.")

        # Get the actual remaining money assigned to this Goal.
        goal_balance = MoneyService.get_bucket_balance(
            MoneyService.GOAL,
            goal.id,
            user_id=user_id
        )

        # ---------------------------------------------------------
        # Release remaining Goal money
        # ---------------------------------------------------------
        #
        # Goal -> General
        #
        # This is an INTERNAL relocation.
        # It is NOT an Expense.
        # ---------------------------------------------------------

        if goal_balance > 0:

            MoneyService.release(
                source_type=MoneyService.GOAL,
                amount=goal_balance,
                source_id=goal.id,
                destination_type=MoneyService.GENERAL,
                description="Release remaining goal money"
            )

        db.session.delete(goal)

        db.session.commit()

        return True