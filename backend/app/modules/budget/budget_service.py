from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.modules.budget.budget_model import Budget
from app.common.exceptions import (
    NotFoundException,
    ValidationException,
)


class BudgetService:

    @staticmethod
    def create_budget(data):

        existing = Budget.query.filter_by(
            user_id=get_jwt_identity(),
            category=data["category"],
            month=data["month"],
            year=data["year"]
        ).first()

        if existing:
            raise ValidationException(
                "Budget already exists for this category and month."
            )

        budget = Budget(
            user_id=get_jwt_identity(),
            category=data["category"],
            amount=data["amount"],
            month=data["month"],
            year=data["year"]
        )

        db.session.add(budget)
        db.session.commit()

        return budget

    @staticmethod
    def get_all_budgets():

        return Budget.query.filter_by(
            user_id=get_jwt_identity()
        ).all()

    @staticmethod
    def get_budget(budget_id):

        budget = Budget.query.filter_by(
            id=budget_id,
            user_id=get_jwt_identity()
        ).first()

        if not budget:
            raise NotFoundException("Budget not found.")

        return budget

    @staticmethod
    def update_budget(budget_id, data):

        budget = BudgetService.get_budget(budget_id)

        for key, value in data.items():
            setattr(budget, key, value)

        db.session.commit()

        return budget

    @staticmethod
    def delete_budget(budget_id):

        budget = BudgetService.get_budget(budget_id)

        db.session.delete(budget)
        db.session.commit()