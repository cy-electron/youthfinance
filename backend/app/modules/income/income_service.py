from app.extensions import db
from app.modules.income.income_model import Income
from app.common.exceptions import NotFoundException, ValidationException
from app.modules.money.money_service import MoneyService


class IncomeService:

    @staticmethod
    def create_income(user_id, data):

        amount = MoneyService._decimal(data["amount"])

        if amount <= 0:
            raise ValidationException(
                "Income amount must be greater than zero."
            )

        income = Income(
            user_id=user_id,
            source=data["source"],
            amount=amount,
            date=data["date"],
            description=data.get("description")
        )

        db.session.add(income)
        db.session.flush()

        MoneyService._add_entry(
            user_id=user_id,
            bucket_type=MoneyService.GENERAL,
            bucket_id=None,
            amount=amount,
            entry_type=MoneyService.INCOME,
            reference_type="income",
            reference_id=income.id,
            description=f"Income: {income.source}"
        )

        db.session.commit()

        return {
            "message": "Income created successfully.",
            "income": {
                "id": income.id,
                "source": income.source,
                "amount": float(income.amount),
                "date": str(income.date),
                "description": income.description
            }
        }

    @staticmethod
    def get_all_incomes(user_id):

        incomes = Income.query.filter_by(
            user_id=user_id
        ).order_by(
            Income.date.desc()
        ).all()

        return [
            {
                "id": income.id,
                "source": income.source,
                "amount": float(income.amount),
                "date": str(income.date),
                "description": income.description
            }
            for income in incomes
        ]

    @staticmethod
    def get_income(user_id, income_id):

        income = Income.query.filter_by(
            id=income_id,
            user_id=user_id
        ).first()

        if not income:
            raise NotFoundException("Income not found.")

        return income

    @staticmethod
    def update_income(user_id, income_id, data):

        income = IncomeService.get_income(
            user_id,
            income_id
        )

        old_amount = MoneyService._decimal(income.amount)
        new_amount = MoneyService._decimal(
            data.get("amount", old_amount)
        )

        if new_amount <= 0:
            raise ValidationException(
                "Income amount must be greater than zero."
            )

        try:

            # ----------------------------------------------------
            # Handle amount change.
            #
            # Income originally added money to General.
            # Therefore changes must also be reflected in General.
            # ----------------------------------------------------

            if new_amount > old_amount:

                difference = new_amount - old_amount

                MoneyService._add_entry(
                    user_id=user_id,
                    bucket_type=MoneyService.GENERAL,
                    bucket_id=None,
                    amount=difference,
                    entry_type=MoneyService.INCOME,
                    reference_type="income",
                    reference_id=income.id,
                    description="Income increased."
                )

            elif new_amount < old_amount:

                difference = old_amount - new_amount

                general_balance = MoneyService.get_general_balance(
                    user_id
                )

                if difference > general_balance:
                    raise ValidationException(
                        "Income cannot be reduced because "
                        "the money has already been allocated or spent."
                    )

                MoneyService._add_entry(
                    user_id=user_id,
                    bucket_type=MoneyService.GENERAL,
                    bucket_id=None,
                    amount=-difference,
                    entry_type=MoneyService.RELEASE,
                    reference_type="income",
                    reference_id=income.id,
                    description="Income reduced."
                )

            # ----------------------------------------------------
            # Update normal Income fields.
            # ----------------------------------------------------

            if "source" in data:
                income.source = data["source"]

            if "amount" in data:
                income.amount = new_amount

            if "date" in data:
                income.date = data["date"]

            if "description" in data:
                income.description = data["description"]

            db.session.commit()

        except Exception:
            db.session.rollback()
            raise

        return {
            "message": "Income updated successfully."
        }

    @staticmethod
    def delete_income(user_id, income_id):

        income = IncomeService.get_income(
            user_id,
            income_id
        )

        amount = MoneyService._decimal(income.amount)

        try:

            # ----------------------------------------------------
            # Income originally entered General.
            #
            # It can only be deleted if that money is still
            # available in General.
            # ----------------------------------------------------

            general_balance = MoneyService.get_general_balance(
                user_id
            )

            if amount > general_balance:
                raise ValidationException(
                    "Income cannot be deleted because "
                    "the money has already been allocated or spent."
                )

            MoneyService._add_entry(
                user_id=user_id,
                bucket_type=MoneyService.GENERAL,
                bucket_id=None,
                amount=-amount,
                entry_type=MoneyService.RELEASE,
                reference_type="income",
                reference_id=income.id,
                description="Income deleted."
            )

            db.session.delete(income)

            db.session.commit()

        except Exception:
            db.session.rollback()
            raise

        return {
            "message": "Income deleted successfully."
        }