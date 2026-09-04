from datetime import date

from flask_jwt_extended import get_jwt_identity
from sqlalchemy import func

from app.extensions import db
from app.modules.income.income_model import Income
from app.modules.expense.expense_model import Expense
from app.modules.budget.budget_model import Budget
from app.modules.goal.goal_model import Goal
from app.modules.money.money_service import MoneyService


class DashboardService:

    @staticmethod
    def get_dashboard_summary():

        user_id = int(get_jwt_identity())

        today = date.today()

        # ============================================================
        # ALL-TIME INCOME
        # ============================================================

        total_income = (
            db.session.query(
                func.coalesce(func.sum(Income.amount), 0)
            )
            .filter(
                Income.user_id == user_id
            )
            .scalar()
        )

        # ============================================================
        # ALL-TIME EXPENSE
        # ============================================================

        total_expense = (
            db.session.query(
                func.coalesce(func.sum(Expense.amount), 0)
            )
            .filter(
                Expense.user_id == user_id
            )
            .scalar()
        )

        # ============================================================
        # CURRENT MONTH INCOME
        # ============================================================

        monthly_income = (
            db.session.query(
                func.coalesce(func.sum(Income.amount), 0)
            )
            .filter(
                Income.user_id == user_id,
                func.extract("month", Income.date) == today.month,
                func.extract("year", Income.date) == today.year
            )
            .scalar()
        )

        # ============================================================
        # CURRENT MONTH EXPENSE
        # ============================================================

        monthly_expense = (
            db.session.query(
                func.coalesce(func.sum(Expense.amount), 0)
            )
            .filter(
                Expense.user_id == user_id,
                func.extract("month", Expense.date) == today.month,
                func.extract("year", Expense.date) == today.year
            )
            .scalar()
        )

        # ============================================================
        # CURRENT MONTH BUDGET
        # ============================================================

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

        # ============================================================
        # CURRENT CONTROLLED MONEY
        # ============================================================
        #
        # These are allocations/positions, NOT additional money.
        #
        # General + Goals + Emergency + Budget + Fun Fund
        # represent different locations of the same controlled money.
        # ============================================================

        general_available = MoneyService.get_general_balance(
            user_id=user_id
        )

        goal_allocated = MoneyService.get_bucket_balance(
            MoneyService.GOAL,
            user_id=user_id
        )

        emergency_allocated = MoneyService.get_bucket_balance(
            MoneyService.EMERGENCY,
            user_id=user_id
        )

        budget_allocated = MoneyService.get_bucket_balance(
            MoneyService.BUDGET,
            user_id=user_id
        )

        fun_fund_allocated = MoneyService.get_bucket_balance(
            MoneyService.FUN_FUND,
            user_id=user_id
        )

        # ============================================================
        # GOALS
        # ============================================================
        #
        # Goals are ALL-TIME entities.
        # They are not filtered by month.
        # ============================================================

        active_goals = Goal.query.filter_by(
            user_id=user_id,
            is_completed=False
        ).count()

        completed_goals = Goal.query.filter_by(
            user_id=user_id,
            is_completed=True
        ).count()

        # ============================================================
        # CASH-FLOW MEASURES
        # ============================================================

        net_savings = total_income - total_expense

        monthly_surplus = monthly_income - monthly_expense

        # ============================================================
        # RESPONSE
        # ============================================================

        return {
            # All-time flow history
            "total_income": float(total_income),
            "total_expense": float(total_expense),

            # All-time cash-flow result
            "net_savings": float(net_savings),

            # Current month cash-flow result
            "monthly_surplus": float(monthly_surplus),

            # Current month budget
            "monthly_budget": float(monthly_budget),

            # Current controlled-money positions
            "general_available": float(general_available),
            "goal_allocated": float(goal_allocated),
            "emergency_allocated": float(emergency_allocated),
            "budget_allocated": float(budget_allocated),
            "fun_fund_allocated": float(fun_fund_allocated),

            # All-time Goal counts
            "active_goals": active_goals,
            "completed_goals": completed_goals
        }