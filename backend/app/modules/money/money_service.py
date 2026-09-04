from decimal import Decimal

from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.common.exceptions import ValidationException

from app.modules.money.money_allocation_model import MoneyAllocation
from app.modules.goal.goal_model import Goal
from app.modules.budget.budget_model import Budget

try:
    from app.modules.fun_fund.fun_fund_model import FunFund
except ImportError:
    FunFund = None


class MoneyService:

    GENERAL = "general"
    GOAL = "goal"
    EMERGENCY = "emergency"
    BUDGET = "budget"
    FUN_FUND = "fun_fund"

    ALLOCATION = "allocation"
    RELEASE = "release"
    EXPENSE = "expense"
    INCOME = "income"
    ADJUSTMENT = "adjustment"

    # ============================================================
    # BASIC HELPERS
    # ============================================================

    @staticmethod
    def _user_id():
        return get_jwt_identity()

    @staticmethod
    def _decimal(value):
        return Decimal(str(value))

    # ============================================================
    # CREATE LEDGER ENTRY
    # ============================================================

    @staticmethod
    def _add_entry(
        user_id,
        bucket_type,
        amount,
        entry_type,
        bucket_id=None,
        reference_type=None,
        reference_id=None,
        description=None,
    ):
        entry = MoneyAllocation(
            user_id=user_id,
            bucket_type=bucket_type,
            bucket_id=bucket_id,
            amount=amount,
            entry_type=entry_type,
            reference_type=reference_type,
            reference_id=reference_id,
            description=description,
        )

        db.session.add(entry)

        return entry

    # ============================================================
    # GET BUCKET BALANCE
    # ============================================================

    @staticmethod
    def get_bucket_balance(
        bucket_type,
        bucket_id=None,
        user_id=None
    ):
        if user_id is None:
            user_id = MoneyService._user_id()

        total = (
            db.session.query(
                db.func.coalesce(
                    db.func.sum(MoneyAllocation.amount),
                    0
                )
            )
            .filter(
                MoneyAllocation.user_id == user_id,
                MoneyAllocation.bucket_type == bucket_type,
            )
        )

        if bucket_id is None:
            total = total.filter(
                MoneyAllocation.bucket_id.is_(None)
            )
        else:
            total = total.filter(
                MoneyAllocation.bucket_id == bucket_id
            )

        value = total.scalar()

        return MoneyService._decimal(value or 0)

    # ============================================================
    # VALIDATE BUCKET
    # ============================================================

    @staticmethod
    def _validate_bucket(
        user_id,
        bucket_type,
        bucket_id=None
    ):
        if bucket_type == MoneyService.GENERAL:
            if bucket_id is not None:
                raise ValidationException(
                    "General savings cannot have a bucket ID."
                )
            return

        if bucket_type == MoneyService.EMERGENCY:
            if bucket_id is not None:
                raise ValidationException(
                    "Emergency Fund cannot have a bucket ID."
                )
            return

        if bucket_type == MoneyService.GOAL:

            if bucket_id is None:
                raise ValidationException(
                    "Goal allocation requires a goal ID."
                )

            goal = Goal.query.filter_by(
                id=bucket_id,
                user_id=user_id
            ).first()

            if not goal:
                raise ValidationException(
                    "Goal not found."
                )

            return

        if bucket_type == MoneyService.BUDGET:

            if bucket_id is None:
                raise ValidationException(
                    "Budget allocation requires a budget ID."
                )

            budget = Budget.query.filter_by(
                id=bucket_id,
                user_id=user_id
            ).first()

            if not budget:
                raise ValidationException(
                    "Budget not found."
                )

            return

        if bucket_type == MoneyService.FUN_FUND:

            if bucket_id is None:
                raise ValidationException(
                    "Fun Fund allocation requires a Fun Fund ID."
                )

            if FunFund is None:
                raise ValidationException(
                    "Fun Fund module is not available."
                )

            fund = FunFund.query.filter_by(
                id=bucket_id,
                user_id=user_id
            ).first()

            if not fund:
                raise ValidationException(
                    "Fun Fund not found."
                )

            return

        raise ValidationException(
            f"Invalid money bucket: {bucket_type}"
        )

    # ============================================================
    # GENERAL AVAILABLE BALANCE
    # ============================================================

    @staticmethod
    def get_general_balance(user_id=None):

        return MoneyService.get_bucket_balance(
            bucket_type=MoneyService.GENERAL,
            bucket_id=None,
            user_id=user_id
        )

    # ============================================================
    # ALLOCATE MONEY
    # ============================================================

    @staticmethod
    def allocate(
        destination_type,
        amount,
        destination_id=None,
        description=None,
        reference_type=None,
        reference_id=None,
    ):
        """
        Move existing money from General Savings into another
        controlled-money area.

        Example:

        General ₹10,000
        Goal allocation ₹3,000

        General -> -₹3,000
        Goal    -> +₹3,000
        """

        user_id = MoneyService._user_id()
        amount = MoneyService._decimal(amount)

        if amount <= 0:
            raise ValidationException(
                "Allocation amount must be greater than zero."
            )

        MoneyService._validate_bucket(
            user_id,
            destination_type,
            destination_id
        )

        general_balance = MoneyService.get_general_balance(
            user_id
        )

        if amount > general_balance:
            raise ValidationException(
                "Insufficient available money. "
                f"You only have ₹{general_balance:.2f} "
                "available to allocate."
            )

        MoneyService._add_entry(
            user_id=user_id,
            bucket_type=MoneyService.GENERAL,
            bucket_id=None,
            amount=-amount,
            entry_type=MoneyService.ALLOCATION,
            reference_type=reference_type,
            reference_id=reference_id,
            description=description,
        )

        MoneyService._add_entry(
            user_id=user_id,
            bucket_type=destination_type,
            bucket_id=destination_id,
            amount=amount,
            entry_type=MoneyService.ALLOCATION,
            reference_type=reference_type,
            reference_id=reference_id,
            description=description,
        )

        return amount

    # ============================================================
    # RELEASE MONEY
    # ============================================================

    @staticmethod
    def release(
        source_type,
        amount,
        source_id=None,
        destination_type=MoneyService.GENERAL,
        destination_id=None,
        description=None,
        reference_type=None,
        reference_id=None,
    ):
        """
        Move money from one controlled allocation back to General.

        Example:

        Goal ₹3,000
        Goal deleted

        Goal    -> -₹3,000
        General -> +₹3,000
        """

        user_id = MoneyService._user_id()
        amount = MoneyService._decimal(amount)

        if amount <= 0:
            raise ValidationException(
                "Release amount must be greater than zero."
            )

        MoneyService._validate_bucket(
            user_id,
            source_type,
            source_id
        )

        MoneyService._validate_bucket(
            user_id,
            destination_type,
            destination_id
        )

        source_balance = MoneyService.get_bucket_balance(
            source_type,
            source_id,
            user_id
        )

        if amount > source_balance:
            raise ValidationException(
                "Insufficient money in the selected allocation."
            )

        MoneyService._add_entry(
            user_id=user_id,
            bucket_type=source_type,
            bucket_id=source_id,
            amount=-amount,
            entry_type=MoneyService.RELEASE,
            reference_type=reference_type,
            reference_id=reference_id,
            description=description,
        )

        MoneyService._add_entry(
            user_id=user_id,
            bucket_type=destination_type,
            bucket_id=destination_id,
            amount=amount,
            entry_type=MoneyService.RELEASE,
            reference_type=reference_type,
            reference_id=reference_id,
            description=description,
        )

        return amount

    # ============================================================
    # DIRECT BUCKET DEBIT
    # ============================================================

    @staticmethod
    def debit_bucket(
        bucket_type,
        amount,
        bucket_id=None,
        entry_type=EXPENSE,
        reference_type=None,
        reference_id=None,
        description=None,
    ):
        """
        Remove controlled money from a specific bucket.

        Used by Expense processing.

        This does NOT make Expense a child of the bucket.
        It only records the financial effect of the expense.
        """

        user_id = MoneyService._user_id()
        amount = MoneyService._decimal(amount)

        if amount <= 0:
            raise ValidationException(
                "Debit amount must be greater than zero."
            )

        MoneyService._validate_bucket(
            user_id,
            bucket_type,
            bucket_id
        )

        balance = MoneyService.get_bucket_balance(
            bucket_type,
            bucket_id,
            user_id
        )

        if amount > balance:
            raise ValidationException(
                "Insufficient money in the selected allocation."
            )

        return MoneyService._add_entry(
            user_id=user_id,
            bucket_type=bucket_type,
            bucket_id=bucket_id,
            amount=-amount,
            entry_type=entry_type,
            reference_type=reference_type,
            reference_id=reference_id,
            description=description,
        )

        # ============================================================
    # SPEND MONEY
    # ============================================================

    @staticmethod
    def spend_money(
        amount,
        reference_type,
        reference_id,
        source_type=None,
        source_id=None,
        category=None,
        description=None,
    ):
        """
        Spend controlled money on a real-world expense.

        Normal expense priority:
            1. Budget
            2. General
            3. Goal
            4. Emergency

        Fun Fund expenses MUST explicitly specify:
            source_type="fun_fund"
            source_id=<fun fund id>

        The expense itself remains an independent transaction.
        This method only records where the money came from.
        """

        user_id = MoneyService._user_id()
        amount = MoneyService._decimal(amount)

        if amount <= 0:
            raise ValidationException(
                "Expense amount must be greater than zero."
            )

        if not reference_type or reference_id is None:
            raise ValidationException(
                "Expense reference is required."
            )

        # --------------------------------------------------------
        # EXPLICIT SOURCE
        # --------------------------------------------------------

        if source_type is not None:

            # Fun Fund must always be explicit.
            if source_type == MoneyService.FUN_FUND and source_id is None:
                raise ValidationException(
                    "Fun Fund expenses require a Fun Fund ID."
                )

            MoneyService._validate_bucket(
                user_id,
                source_type,
                source_id
            )

            balance = MoneyService.get_bucket_balance(
                source_type,
                source_id,
                user_id
            )

            if amount > balance:
                raise ValidationException(
                    "Insufficient money in the selected allocation."
                )

            MoneyService._add_entry(
                user_id=user_id,
                bucket_type=source_type,
                bucket_id=source_id,
                amount=-amount,
                entry_type=MoneyService.EXPENSE,
                reference_type=reference_type,
                reference_id=reference_id,
                description=description,
            )

            return [
                {
                    "bucket_type": source_type,
                    "bucket_id": source_id,
                    "amount": amount,
                }
            ]

        # --------------------------------------------------------
        # AUTOMATIC NORMAL EXPENSE FUNDING
        #
        # Budget -> General -> Goal -> Emergency
        # --------------------------------------------------------

        remaining = amount
        funding = []

        # --------------------------------------------------------
        # 1. BUDGET
        #
        # Prefer a budget matching the expense category.
        # Only use budgets belonging to this user.
        # --------------------------------------------------------

        budgets_query = Budget.query.filter_by(
            user_id=user_id
        )

        budgets = budgets_query.order_by(
            Budget.year.desc(),
            Budget.month.desc(),
            Budget.id.desc()
        ).all()

        # Put category-matching budgets first.
        if category:
            matching = [
                budget for budget in budgets
                if budget.category.lower() == category.lower()
            ]

            non_matching = [
                budget for budget in budgets
                if budget.category.lower() != category.lower()
            ]

            budgets = matching + non_matching

        for budget in budgets:

            if remaining <= 0:
                break

            balance = MoneyService.get_bucket_balance(
                MoneyService.BUDGET,
                budget.id,
                user_id
            )

            if balance <= 0:
                continue

            amount_from_budget = min(
                remaining,
                balance
            )

            MoneyService.debit_bucket(
                bucket_type=MoneyService.BUDGET,
                bucket_id=budget.id,
                amount=amount_from_budget,
                entry_type=MoneyService.EXPENSE,
                reference_type=reference_type,
                reference_id=reference_id,
                description=description,
            )

            funding.append(
                {
                    "bucket_type": MoneyService.BUDGET,
                    "bucket_id": budget.id,
                    "amount": amount_from_budget,
                }
            )

            remaining -= amount_from_budget

        # --------------------------------------------------------
        # 2. GENERAL
        # --------------------------------------------------------

        if remaining > 0:

            general_balance = MoneyService.get_general_balance(
                user_id
            )

            amount_from_general = min(
                remaining,
                general_balance
            )

            if amount_from_general > 0:

                MoneyService.debit_bucket(
                    bucket_type=MoneyService.GENERAL,
                    bucket_id=None,
                    amount=amount_from_general,
                    entry_type=MoneyService.EXPENSE,
                    reference_type=reference_type,
                    reference_id=reference_id,
                    description=description,
                )

                funding.append(
                    {
                        "bucket_type": MoneyService.GENERAL,
                        "bucket_id": None,
                        "amount": amount_from_general,
                    }
                )

                remaining -= amount_from_general

        # --------------------------------------------------------
        # 3. GOALS
        # --------------------------------------------------------

        if remaining > 0:

            goals = Goal.query.filter_by(
                user_id=user_id
            ).order_by(
                Goal.id.asc()
            ).all()

            for goal in goals:

                if remaining <= 0:
                    break

                balance = MoneyService.get_bucket_balance(
                    MoneyService.GOAL,
                    goal.id,
                    user_id
                )

                if balance <= 0:
                    continue

                amount_from_goal = min(
                    remaining,
                    balance
                )

                MoneyService.debit_bucket(
                    bucket_type=MoneyService.GOAL,
                    bucket_id=goal.id,
                    amount=amount_from_goal,
                    entry_type=MoneyService.EXPENSE,
                    reference_type=reference_type,
                    reference_id=reference_id,
                    description=description,
                )

                funding.append(
                    {
                        "bucket_type": MoneyService.GOAL,
                        "bucket_id": goal.id,
                        "amount": amount_from_goal,
                    }
                )

                remaining -= amount_from_goal

        # --------------------------------------------------------
        # 4. EMERGENCY FUND
        # --------------------------------------------------------

        if remaining > 0:

            emergency_balance = MoneyService.get_bucket_balance(
                MoneyService.EMERGENCY,
                None,
                user_id
            )

            amount_from_emergency = min(
                remaining,
                emergency_balance
            )

            if amount_from_emergency > 0:

                MoneyService.debit_bucket(
                    bucket_type=MoneyService.EMERGENCY,
                    bucket_id=None,
                    amount=amount_from_emergency,
                    entry_type=MoneyService.EXPENSE,
                    reference_type=reference_type,
                    reference_id=reference_id,
                    description=description,
                )

                funding.append(
                    {
                        "bucket_type": MoneyService.EMERGENCY,
                        "bucket_id": None,
                        "amount": amount_from_emergency,
                    }
                )

                remaining -= amount_from_emergency

        # --------------------------------------------------------
        # NOT ENOUGH MONEY
        # --------------------------------------------------------

        if remaining > 0:

            raise ValidationException(
                "Insufficient controlled money to cover this expense."
            )

        return funding

    # ============================================================
    # REVERSE EXPENSE
    # ============================================================

    @staticmethod
    def reverse_expense(
        reference_type,
        reference_id,
        description=None,
    ):
        """
        Reverse the currently active funding of an expense.

        Only the latest unreversed expense entries are reversed.
        Historical expense entries remain in the ledger for audit.
        """

        user_id = MoneyService._user_id()

        entries = MoneyAllocation.query.filter_by(
            user_id=user_id,
            reference_type=reference_type,
            reference_id=reference_id,
            entry_type=MoneyService.EXPENSE,
        ).order_by(
            MoneyAllocation.id.desc()
        ).all()

        if not entries:
            raise ValidationException(
                "No money movement was found for this expense."
            )

        # --------------------------------------------------------
        # Calculate how much of each bucket has already been
        # returned through RELEASE entries for this expense.
        # --------------------------------------------------------

        release_entries = MoneyAllocation.query.filter_by(
            user_id=user_id,
            reference_type=reference_type,
            reference_id=reference_id,
            entry_type=MoneyService.RELEASE,
        ).all()

        released_by_bucket = {}

        for entry in release_entries:
            key = (
                entry.bucket_type,
                entry.bucket_id
            )

            released_by_bucket[key] = (
                released_by_bucket.get(key, Decimal("0.00"))
                + MoneyService._decimal(entry.amount)
            )

        # --------------------------------------------------------
        # Determine currently unreversed expense amounts.
        # --------------------------------------------------------

        active_entries = []

        for entry in entries:
            key = (
                entry.bucket_type,
                entry.bucket_id
            )

            spent = abs(
                MoneyService._decimal(entry.amount)
            )

            already_released = released_by_bucket.get(
                key,
                Decimal("0.00")
            )

            remaining = spent - already_released

            if remaining > 0:
                active_entries.append(
                    (
                        entry,
                        remaining
                    )
                )

        if not active_entries:
            raise ValidationException(
                "This expense has already been reversed."
            )

        # --------------------------------------------------------
        # SAFETY CHECK
        # --------------------------------------------------------

        for entry, amount_to_reverse in active_entries:

            current_balance = MoneyService.get_bucket_balance(
                entry.bucket_type,
                entry.bucket_id,
                user_id
            )

            if amount_to_reverse > current_balance:
                raise ValidationException(
                    "This expense cannot be reversed because "
                    "the money has already been used elsewhere."
                )

        # --------------------------------------------------------
        # RETURN MONEY TO EXACT ORIGINAL BUCKETS
        # --------------------------------------------------------

        reversed_funding = []

        for entry, amount_to_reverse in active_entries:

            MoneyService._add_entry(
                user_id=user_id,
                bucket_type=entry.bucket_type,
                bucket_id=entry.bucket_id,
                amount=amount_to_reverse,
                entry_type=MoneyService.RELEASE,
                reference_type=reference_type,
                reference_id=reference_id,
                description=description or "Expense reversed.",
            )

            reversed_funding.append(
                {
                    "bucket_type": entry.bucket_type,
                    "bucket_id": entry.bucket_id,
                    "amount": amount_to_reverse,
                }
            )
    
        return reversed_funding

    @staticmethod
    def get_total_allocated(user_id=None):

        if user_id is None:
            user_id = MoneyService._user_id()

        total = (
            db.session.query(
                db.func.coalesce(
                    db.func.sum(MoneyAllocation.amount),
                    0
                )
            )
            .filter(
                MoneyAllocation.user_id == user_id
            )
            .scalar()
        )

        return MoneyService._decimal(total or 0)

    # ============================================================
    # ALL BUCKET BALANCES
    # ============================================================

    @staticmethod
    def get_money_summary(user_id=None):

        if user_id is None:
            user_id = MoneyService._user_id()

        general = MoneyService.get_bucket_balance(
            MoneyService.GENERAL,
            None,
            user_id
        )

        emergency = MoneyService.get_bucket_balance(
            MoneyService.EMERGENCY,
            None,
            user_id
        )

        goal_total = (
            db.session.query(
                db.func.coalesce(
                    db.func.sum(MoneyAllocation.amount),
                    0
                )
            )
            .filter(
                MoneyAllocation.user_id == user_id,
                MoneyAllocation.bucket_type == MoneyService.GOAL
            )
            .scalar()
        )

        budget_total = (
            db.session.query(
                db.func.coalesce(
                    db.func.sum(MoneyAllocation.amount),
                    0
                )
            )
            .filter(
                MoneyAllocation.user_id == user_id,
                MoneyAllocation.bucket_type == MoneyService.BUDGET
            )
            .scalar()
        )

        fun_fund_total = (
            db.session.query(
                db.func.coalesce(
                    db.func.sum(MoneyAllocation.amount),
                    0
                )
            )
            .filter(
                MoneyAllocation.user_id == user_id,
                MoneyAllocation.bucket_type == MoneyService.FUN_FUND
            )
            .scalar()
        )

        return {
            "general_available": float(general),
            "goal_allocated": float(
                MoneyService._decimal(goal_total or 0)
            ),
            "emergency_allocated": float(emergency),
            "budget_allocated": float(
                MoneyService._decimal(budget_total or 0)
            ),
            "fun_fund_allocated": float(
                MoneyService._decimal(fun_fund_total or 0)
            ),
        }