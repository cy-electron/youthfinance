from app.extensions import db
from app.income.income_model import Income
from app.common.exceptions import NotFoundException


class IncomeService:

    @staticmethod
    def create_income(user_id, data):

        income = Income(
            user_id=user_id,
            source=data["source"],
            amount=data["amount"],
            date=data["date"],
            description=data.get("description")
        )

        db.session.add(income)
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

        for key, value in data.items():
            setattr(income, key, value)

        db.session.commit()

        return {
            "message": "Income updated successfully."
        }

    @staticmethod
    def delete_income(user_id, income_id):

        income = IncomeService.get_income(
            user_id,
            income_id
        )

        db.session.delete(income)
        db.session.commit()

        return {
            "message": "Income deleted successfully."
        }