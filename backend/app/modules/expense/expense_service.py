from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.modules.expense.expense_model import Expense
from app.common.exceptions import NotFoundException, ValidationException
from app.modules.money.money_service import MoneyService


class ExpenseService:

    @staticmethod
    def _validate_source(data):
        source_type = data.get("source_type")
        source_id = data.get("source_id")

        if source_type == MoneyService.FUN_FUND and source_id is None:
            raise ValidationException(
                "Fun Fund expenses require a Fun Fund ID."
            )

        if source_type is None and source_id is not None:
            raise ValidationException(
                "Source type is required when source ID is provided."
            )

        if source_type in [
            MoneyService.GENERAL,
            MoneyService.EMERGENCY,
        ] and source_id is not None:
            raise ValidationException(
                "This money source cannot have a source ID."
            )

        if source_type in [
            MoneyService.BUDGET,
            MoneyService.GOAL,
            MoneyService.FUN_FUND,
        ] and source_id is None:
            raise ValidationException(
                "This money source requires a source ID."
            )

    @staticmethod
    def create_expense(data):
        user_id = get_jwt_identity()

        ExpenseService._validate_source(data)

        expense = Expense(
            user_id=user_id,
            category=data["category"],
            amount=data["amount"],
            date=data["date"],
            description=data.get("description")
        )

        db.session.add(expense)

        # Get the database ID before creating ledger references.
        db.session.flush()

        try:
            MoneyService.spend_money(
                amount=expense.amount,
                reference_type="expense",
                reference_id=expense.id,
                source_type=data.get("source_type"),
                source_id=data.get("source_id"),
                category=expense.category,
                description=expense.description
            )

            db.session.commit()

        except Exception:
            db.session.rollback()
            raise

        return expense

    @staticmethod
    def get_all_expenses():
        return Expense.query.filter_by(
            user_id=get_jwt_identity()
        ).order_by(
            Expense.date.desc()
        ).all()

    @staticmethod
    def get_expense(expense_id):
        expense = Expense.query.filter_by(
            id=expense_id,
            user_id=get_jwt_identity()
        ).first()

        if not expense:
            raise NotFoundException("Expense not found.")

        return expense

    @staticmethod
    def update_expense(expense_id, data):
        expense = ExpenseService.get_expense(expense_id)

        ExpenseService._validate_source(data)

        # --------------------------------------------------------
        # Save the original values.
        # --------------------------------------------------------

        old_amount = expense.amount
        old_category = expense.category
        old_description = expense.description

        # --------------------------------------------------------
        # Reverse the original expense funding.
        #
        # This returns money to the EXACT buckets from which
        # the original expense was funded.
        # --------------------------------------------------------

        try:
            MoneyService.reverse_expense(
                reference_type="expense",
                reference_id=expense.id,
                description="Previous expense funding reversed."
            )

            # ----------------------------------------------------
            # Update expense fields.
            # ----------------------------------------------------

            if "category" in data:
                expense.category = data["category"]

            if "amount" in data:
                expense.amount = data["amount"]

            if "date" in data:
                expense.date = data["date"]

            if "description" in data:
                expense.description = data["description"]

            # ----------------------------------------------------
            # Re-apply funding for the updated expense.
            #
            # If the new expense cannot be funded, the exception
            # causes the transaction to roll back, restoring the
            # original expense and original ledger state.
            # ----------------------------------------------------

            MoneyService.spend_money(
                amount=expense.amount,
                reference_type="expense",
                reference_id=expense.id,
                source_type=data.get("source_type"),
                source_id=data.get("source_id"),
                category=expense.category,
                description=expense.description
            )

            db.session.commit()

        except Exception:
            db.session.rollback()
            raise

        return expense

    @staticmethod
    def delete_expense(expense_id):
        expense = ExpenseService.get_expense(expense_id)

        try:
            # ----------------------------------------------------
            # Return the money to the EXACT buckets that funded
            # this expense.
            # ----------------------------------------------------

            MoneyService.reverse_expense(
                reference_type="expense",
                reference_id=expense.id,
                description="Expense deleted. Money returned."
            )

            db.session.delete(expense)

            db.session.commit()

        except Exception:
            db.session.rollback()
            raise