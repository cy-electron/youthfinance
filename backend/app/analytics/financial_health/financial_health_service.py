from datetime import date

from flask_jwt_extended import get_jwt_identity
from sqlalchemy import func

from app.extensions import db
from app.modules.investment.investment_model import Investment
from app.modules.fun_fund.fun_fund_model import FunFund
from app.analytics.dashboard.dashboard_service import DashboardService
from app.modules.goal.goal_model import Goal
from app.modules.income.income_model import Income
from app.modules.expense.expense_model import Expense
from app.modules.budget.budget_model import Budget
from app.common.constants import FINANCIAL_HEALTH_WEIGHTS


class FinancialHealthService:

    # ============================================================
    # CURRENT FINANCIAL HEALTH
    # ============================================================

    @staticmethod
    def calculate_score():

        user_id = get_jwt_identity()

        dashboard = DashboardService.get_dashboard_summary()

        score_data = FinancialHealthService.calculate_score_for_period(
            user_id=user_id,
            start_date=None,
            end_date=None,
            dashboard=dashboard
        )

        current_score = score_data["score"]

        previous_score = FinancialHealthService.calculate_previous_month_score(
            user_id
        )

        score_change = None

        if previous_score is not None:
            score_change = current_score - previous_score

        return {
            "score": current_score,
            "previous_score": previous_score,
            "score_change": score_change,
            "breakdown": score_data["breakdown"]
        }

    # ============================================================
    # SCORE FOR A PERIOD
    # ============================================================

    @staticmethod
    def calculate_score_for_period(
        user_id,
        start_date,
        end_date,
        dashboard=None
    ):

        if dashboard is None:

            dashboard = FinancialHealthService.get_period_dashboard(
                user_id=user_id,
                start_date=start_date,
                end_date=end_date
            )

        savings_score = (
            FinancialHealthService.calculate_savings_score(
                dashboard
            )
        )

        budget_score = (
            FinancialHealthService.calculate_budget_score(
                user_id,
                start_date,
                end_date
            )
        )

        goal_score = (
            FinancialHealthService.calculate_goal_score(
                user_id,
                start_date,
                end_date
            )
        )

        income_score = (
            FinancialHealthService.calculate_income_stability(
                user_id,
                start_date,
                end_date
            )
        )

        expense_score = (
            FinancialHealthService.calculate_expense_stability(
                user_id,
                start_date,
                end_date
            )
        )

        emergency_score = (
            FinancialHealthService.calculate_emergency_fund(
                user_id,
                dashboard,
                start_date,
                end_date
            )
        )

        investment_score = (
            FinancialHealthService.calculate_investment_score(
                user_id,
                start_date,
                end_date
            )
        )

        fun_fund_score = (
            FinancialHealthService.calculate_fun_fund_score(
                user_id,
                start_date,
                end_date
            )
        )

        total = (
            savings_score
            + budget_score
            + goal_score
            + income_score
            + expense_score
            + emergency_score
            + investment_score
            + fun_fund_score
        )

        return {
            "score": round(total),
            "breakdown": {
                "savings": savings_score,
                "budget": budget_score,
                "goals": goal_score,
                "income": income_score,
                "expense": expense_score,
                "emergency": emergency_score,
                "investment": investment_score,
                "fun_fund": fun_fund_score
            }
        }

    # ============================================================
    # PREVIOUS MONTH SCORE
    # ============================================================

    @staticmethod
    def calculate_previous_month_score(user_id):

        today = date.today()

        if today.month == 1:
            previous_month = 12
            previous_year = today.year - 1
        else:
            previous_month = today.month - 1
            previous_year = today.year

        start_date = date(
            previous_year,
            previous_month,
            1
        )

        if previous_month == 12:
            next_month = 1
            next_year = previous_year + 1
        else:
            next_month = previous_month + 1
            next_year = previous_year

        end_date = date(
            next_year,
            next_month,
            1
        )

        # Check whether the user actually has financial activity
        # in the previous month.
        has_activity = (
            Income.query.filter(
                Income.user_id == user_id,
                Income.date >= start_date,
                Income.date < end_date
            ).first()
            or
            Expense.query.filter(
                Expense.user_id == user_id,
                Expense.date >= start_date,
                Expense.date < end_date
            ).first()
            or
            Budget.query.filter(
                Budget.user_id == user_id,
                Budget.month == previous_month,
                Budget.year == previous_year
            ).first()
        )

        if not has_activity:
            return None

        dashboard = FinancialHealthService.get_period_dashboard(
            user_id=user_id,
            start_date=start_date,
            end_date=end_date
        )

        result = FinancialHealthService.calculate_score_for_period(
            user_id=user_id,
            start_date=start_date,
            end_date=end_date,
            dashboard=dashboard
        )

        return result["score"]

    # ============================================================
    # PERIOD DASHBOARD
    # ============================================================

    @staticmethod
    def get_period_dashboard(
        user_id,
        start_date,
        end_date
    ):

        total_income = (
            db.session.query(
                func.coalesce(func.sum(Income.amount), 0)
            )
            .filter(
                Income.user_id == user_id,
                Income.date >= start_date,
                Income.date < end_date
            )
            .scalar()
        )

        total_expense = (
            db.session.query(
                func.coalesce(func.sum(Expense.amount), 0)
            )
            .filter(
                Expense.user_id == user_id,
                Expense.date >= start_date,
                Expense.date < end_date
            )
            .scalar()
        )

        budget_query = Budget.query.filter(
            Budget.user_id == user_id
        )

        if start_date is not None:

            budget_query = budget_query.filter(
                Budget.month == start_date.month,
                Budget.year == start_date.year
            )

        monthly_budget = (
            db.session.query(
                func.coalesce(func.sum(Budget.amount), 0)
            )
            .filter(
                Budget.user_id == user_id,
                Budget.month == start_date.month,
                Budget.year == start_date.year
            )
            .scalar()
        )

        return {
            "total_income": float(total_income),
            "total_expense": float(total_expense),
            "net_savings": float(
                total_income - total_expense
            ),
            "monthly_budget": float(monthly_budget)
        }

    # ============================================================
    # SAVINGS
    # ============================================================

    @staticmethod
    def calculate_savings_score(dashboard):

        income = dashboard["total_income"]
        expense = dashboard["total_expense"]

        if income <= 0:
            return 0

        savings_rate = (
            (income - expense) / income
        ) * 100

        max_score = FINANCIAL_HEALTH_WEIGHTS["savings_habit"]

        if savings_rate >= 40:
            return max_score

        elif savings_rate >= 30:
            return max_score * 0.9

        elif savings_rate >= 20:
            return max_score * 0.75

        elif savings_rate >= 10:
            return max_score * 0.5

        return max_score * 0.2

    # ============================================================
    # BUDGET
    # ============================================================

    @staticmethod
    def calculate_budget_score(
        user_id,
        start_date=None,
        end_date=None
    ):

        query = Budget.query.filter_by(
            user_id=user_id
        )

        if start_date is not None:
            query = query.filter(
                Budget.month == start_date.month,
                Budget.year == start_date.year
            )

        budgets = query.all()

        if not budgets:
            return 0

        total_budget = sum(
            float(b.amount)
            for b in budgets
        )

        expense_query = Expense.query.filter_by(
            user_id=user_id
        )

        if start_date is not None:
            expense_query = expense_query.filter(
                Expense.date >= start_date,
                Expense.date < end_date
            )

        expenses = expense_query.all()

        total_expense = sum(
            float(e.amount)
            for e in expenses
        )

        if total_budget <= 0:
            return 0

        usage = (
            total_expense / total_budget
        ) * 100

        max_score = FINANCIAL_HEALTH_WEIGHTS[
            "budget_discipline"
        ]

        if usage <= 90:
            return max_score

        elif usage <= 100:
            return max_score * 0.8

        elif usage <= 110:
            return max_score * 0.5

        return max_score * 0.2

    # ============================================================
    # GOALS
    # ============================================================

    @staticmethod
    def calculate_goal_score(
        user_id,
        start_date=None,
        end_date=None
    ):

        goals = Goal.query.filter_by(
            user_id=user_id
        ).all()

        if not goals:
            return 0

        total_progress = 0
        valid_goals = 0

        for goal in goals:

            if float(goal.target_amount) > 0:

                progress = (
                    float(goal.current_amount)
                    /
                    float(goal.target_amount)
                )

                total_progress += min(progress, 1)
                valid_goals += 1

        if valid_goals == 0:
            return 0

        average_progress = (
            total_progress / valid_goals
        )

        return (
            average_progress
            *
            FINANCIAL_HEALTH_WEIGHTS["goal_progress"]
        )

    # ============================================================
    # INCOME STABILITY
    # ============================================================

    @staticmethod
    def calculate_income_stability(
        user_id,
        start_date=None,
        end_date=None
    ):

        query = Income.query.filter_by(
            user_id=user_id
        )

        if start_date is not None:
            query = query.filter(
                Income.date >= start_date,
                Income.date < end_date
            )

        incomes = (
            query
            .order_by(Income.date.asc())
            .all()
        )

        if len(incomes) < 2:
            return 5

        amounts = [
            float(i.amount)
            for i in incomes
        ]

        average = sum(amounts) / len(amounts)

        if average == 0:
            return 0

        variation = (
            max(amounts) - min(amounts)
        ) / average

        max_score = FINANCIAL_HEALTH_WEIGHTS[
            "income_stability"
        ]

        if variation <= 0.10:
            return max_score

        elif variation <= 0.25:
            return max_score * 0.8

        elif variation <= 0.50:
            return max_score * 0.6

        return max_score * 0.3

    # ============================================================
    # EXPENSE STABILITY
    # ============================================================

    @staticmethod
    def calculate_expense_stability(
        user_id,
        start_date=None,
        end_date=None
    ):

        query = Expense.query.filter_by(
            user_id=user_id
        )

        if start_date is not None:
            query = query.filter(
                Expense.date >= start_date,
                Expense.date < end_date
            )

        expenses = (
            query
            .order_by(Expense.date.asc())
            .all()
        )

        if len(expenses) < 2:
            return 5

        amounts = [
            float(e.amount)
            for e in expenses
        ]

        average = sum(amounts) / len(amounts)

        if average == 0:
            return 0

        variation = (
            max(amounts) - min(amounts)
        ) / average

        max_score = FINANCIAL_HEALTH_WEIGHTS[
            "expense_stability"
        ]

        if variation <= 0.10:
            return max_score

        elif variation <= 0.25:
            return max_score * 0.8

        elif variation <= 0.50:
            return max_score * 0.6

        return max_score * 0.3

    # ============================================================
    # EMERGENCY FUND
    # ============================================================

    @staticmethod
    def calculate_emergency_fund(
        user_id,
        dashboard,
        start_date=None,
        end_date=None
    ):

        savings = dashboard["net_savings"]

        query = db.session.query(
            func.extract("year", Expense.date),
            func.extract("month", Expense.date),
            func.sum(Expense.amount)
        ).filter(
            Expense.user_id == user_id
        )

        if start_date is not None:
            query = query.filter(
                Expense.date >= start_date,
                Expense.date < end_date
            )

        monthly_expenses = (
            query
            .group_by(
                func.extract("year", Expense.date),
                func.extract("month", Expense.date)
            )
            .all()
        )

        if not monthly_expenses:
            return 0

        average_monthly_expense = (
            sum(float(month[2]) for month in monthly_expenses)
            /
            len(monthly_expenses)
        )

        if average_monthly_expense <= 0:
            return 0

        months = (
            savings / average_monthly_expense
        )

        max_score = FINANCIAL_HEALTH_WEIGHTS[
            "emergency_fund"
        ]

        if months >= 6:
            return max_score

        elif months >= 3:
            return max_score * 0.8

        elif months >= 1:
            return max_score * 0.5

        return max_score * 0.2

    # ============================================================
    # INVESTMENT
    # ============================================================

    @staticmethod
    def calculate_investment_score(
        user_id,
        start_date=None,
        end_date=None
    ):

        query = Investment.query.filter_by(
            user_id=user_id
        )

        if start_date is not None:
            query = query.filter(
                Investment.investment_date >= start_date,
                Investment.investment_date < end_date
            )

        investments = query.all()

        if not investments:
            return 0

        count = len(investments)

        max_score = FINANCIAL_HEALTH_WEIGHTS[
            "investment_habit"
        ]

        if count >= 4:
            return max_score

        elif count >= 2:
            return max_score * 0.8

        return max_score * 0.5

    # ============================================================
    # FUN FUND
    # ============================================================

    @staticmethod
    def calculate_fun_fund_score(
        user_id,
        start_date=None,
        end_date=None
    ):

        funds = FunFund.query.filter_by(
            user_id=user_id
        ).all()

        if not funds:
            return 0

        total_progress = 0
        valid_funds = 0

        for fund in funds:

            if float(fund.target_amount) > 0:

                progress = (
                    float(fund.current_amount)
                    /
                    float(fund.target_amount)
                )

                total_progress += min(progress, 1)
                valid_funds += 1

        if valid_funds == 0:
            return 0

        average_progress = (
            total_progress / valid_funds
        )

        return (
            average_progress
            *
            FINANCIAL_HEALTH_WEIGHTS["fun_fund"]
        )