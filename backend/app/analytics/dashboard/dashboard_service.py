from datetime import date

from flask_jwt_extended import get_jwt_identity
from sqlalchemy import func

from app.extensions import db
from app.modules.income.income_model import Income
from app.modules.expense.expense_model import Expense
from app.modules.budget.budget_model import Budget
from app.modules.goal.goal_model import Goal


class DashboardService:

    @staticmethod
    def get_dashboard_summary():

        user_id = get_jwt_identity()

        today = date.today()

        total_income = (
            db.session.query(
                func.coalesce(func.sum(Income.amount), 0)
            )
            .filter(
                Income.user_id == user_id
            )
            .scalar()
        )

        total_expense = (
            db.session.query(
                func.coalesce(func.sum(Expense.amount), 0)
            )
            .filter(
                Expense.user_id == user_id
            )
            .scalar()
        )

        monthly_budget = (
            db.session.query(
                func.coalesce(func.sum(Budget.amount), 0)
            )
            .filter(
                Budget.user_id == user_id,
                Budget.month == today.month,
                Budget.year == today.year
            )
            .scalar()
        )

        active_goals = Goal.query.filter_by(
            user_id=user_id,
            is_completed=False
        ).count()

        completed_goals = Goal.query.filter_by(
            user_id=user_id,
            is_completed=True
        ).count()

        return {
            "total_income": float(total_income),
            "total_expense": float(total_expense),
            "net_savings": float(
                total_income - total_expense
            ),
            "monthly_budget": float(monthly_budget),
            "active_goals": active_goals,
            "completed_goals": completed_goals
        }