from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.modules.expense.expense_model import Expense
from app.common.exceptions import NotFoundException


class ExpenseService:

    @staticmethod
    def create_expense(data):
        expense = Expense(
            user_id=get_jwt_identity(),
            category=data["category"],
            amount=data["amount"],
            date=data["date"],
            description=data.get("description")
        )

        db.session.add(expense)
        db.session.commit()

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

        for key, value in data.items():
            setattr(expense, key, value)

        db.session.commit()

        return expense

    @staticmethod
    def delete_expense(expense_id):
        expense = ExpenseService.get_expense(expense_id)

        db.session.delete(expense)
        db.session.commit()