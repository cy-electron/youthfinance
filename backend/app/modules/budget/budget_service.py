from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.modules.budget.budget_model import Budget
from app.common.exceptions import (
    NotFoundException,
    ValidationException,
)
from app.modules.money.money_service import MoneyService


class BudgetService:

    @staticmethod
    def create_budget(data):

        user_id = get_jwt_identity()

        existing = Budget.query.filter_by(
            user_id=user_id,
            category=data["category"],
            month=data["month"],
            year=data["year"]
        ).first()

        if existing:
            raise ValidationException(
                "Budget already exists for this category and month."
            )

        amount = MoneyService._decimal(data["amount"])

        if amount <= 0:
            raise ValidationException(
                "Budget amount must be greater than zero."
            )

        # Create the budget first so it receives an ID.
        budget = Budget(
            user_id=user_id,
            category=data["category"],
            amount=amount,
            month=data["month"],
            year=data["year"]
        )

        db.session.add(budget)
        db.session.flush()

        # Reserve existing money from General Savings.
        MoneyService.allocate(
            destination_type=MoneyService.BUDGET,
            destination_id=budget.id,
            amount=amount,
            reference_type="budget",
            reference_id=budget.id,
            description=(
                f"Budget allocation: "
                f"{budget.category} "
                f"{budget.month}/{budget.year}"
            )
        )

        db.session.commit()

        return budget

    @staticmethod
    def get_all_budgets():

        return Budget.query.filter_by(
            user_id=get_jwt_identity()
        ).order_by(
            Budget.year.desc(),
            Budget.month.desc(),
            Budget.category.asc()
        ).all()

    @staticmethod
    def get_budget(budget_id):

        budget = Budget.query.filter_by(
            id=budget_id,
            user_id=get_jwt_identity()
        ).first()

        if not budget:
            raise NotFoundException(
                "Budget not found."
            )

        return budget

    @staticmethod
    def get_budget_balance(budget_id):

        budget = BudgetService.get_budget(budget_id)

        return MoneyService.get_bucket_balance(
            bucket_type=MoneyService.BUDGET,
            bucket_id=budget.id
        )

    @staticmethod
    def update_budget(budget_id, data):

        budget = BudgetService.get_budget(budget_id)

        user_id = get_jwt_identity()

        old_amount = MoneyService._decimal(
            budget.amount
        )

        new_amount = MoneyService._decimal(
            data.get("amount", old_amount)
        )

        if new_amount <= 0:
            raise ValidationException(
                "Budget amount must be greater than zero."
            )

        # --------------------------------------------------------
        # Handle amount change through the money ledger.
        # --------------------------------------------------------

        if new_amount > old_amount:

            difference = new_amount - old_amount

            MoneyService.allocate(
                destination_type=MoneyService.BUDGET,
                destination_id=budget.id,
                amount=difference,
                reference_type="budget",
                reference_id=budget.id,
                description="Budget increased."
            )

        elif new_amount < old_amount:

            difference = old_amount - new_amount

            current_balance = MoneyService.get_bucket_balance(
                MoneyService.BUDGET,
                budget.id,
                user_id
            )

            if difference > current_balance:
                raise ValidationException(
                    "Budget cannot be reduced because "
                    "part of the allocated money has already been spent "
                    "or moved to a Fun Fund."
                )

            MoneyService.release(
                source_type=MoneyService.BUDGET,
                source_id=budget.id,
                amount=difference,
                destination_type=MoneyService.GENERAL,
                destination_id=None,
                reference_type="budget",
                reference_id=budget.id,
                description="Budget reduced."
            )

        # --------------------------------------------------------
        # Update normal Budget fields.
        # --------------------------------------------------------

        if "category" in data:
            budget.category = data["category"]

        if "month" in data:
            budget.month = data["month"]

        if "year" in data:
            budget.year = data["year"]

        budget.amount = new_amount

        db.session.commit()

        return budget

    @staticmethod
    def delete_budget(budget_id):

        budget = BudgetService.get_budget(
            budget_id
        )

        balance = MoneyService.get_bucket_balance(
            MoneyService.BUDGET,
            budget.id
        )

        # Any remaining budget money must return to General.
        if balance > 0:

            MoneyService.release(
                source_type=MoneyService.BUDGET,
                source_id=budget.id,
                amount=balance,
                destination_type=MoneyService.GENERAL,
                destination_id=None,
                reference_type="budget",
                reference_id=budget.id,
                description=(
                    f"Remaining money returned from "
                    f"deleted budget: {budget.category}"
                )
            )

        # If balance is zero, there is nothing left to return.
        # We still allow deletion because all allocated money
        # has already been spent or moved elsewhere.

        db.session.delete(budget)

        db.session.commit()