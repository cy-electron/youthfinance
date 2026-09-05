from datetime import date

from flask_jwt_extended import get_jwt_identity
from sqlalchemy import func

from app.extensions import db

from app.modules.investment.investment_model import Investment
from app.modules.fun_fund.fun_fund_model import FunFund
from app.modules.money.money_service import MoneyService
from app.modules.goal.goal_model import Goal
from app.modules.income.income_model import Income
from app.modules.expense.expense_model import Expense
from app.modules.budget.budget_model import Budget

from app.analytics.dashboard.dashboard_service import DashboardService

from app.common.constants import FINANCIAL_HEALTH_WEIGHTS


class FinancialHealthService:

    # ============================================================
    # CURRENT FINANCIAL HEALTH
    # ============================================================

    @staticmethod
    def calculate_score():

        user_id = int(get_jwt_identity())

        dashboard = DashboardService.get_dashboard_summary()

        score_data = FinancialHealthService.calculate_score_for_period(
            user_id=user_id,
            start_date=None,
            end_date=None,
            dashboard=dashboard
        )

        current_score = score_data["score"]

        previous_score = (
            FinancialHealthService.calculate_previous_month_score(
                user_id
            )
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
                user_id=user_id,
                start_date=start_date,
                end_date=end_date
            )
        )

        goal_score = (
            FinancialHealthService.calculate_goal_score(
                user_id=user_id
            )
        )

        income_score = (
            FinancialHealthService.calculate_income_stability(
                user_id=user_id,
                start_date=start_date,
                end_date=end_date
            )
        )

        expense_score = (
            FinancialHealthService.calculate_expense_stability(
                user_id=user_id,
                start_date=start_date,
                end_date=end_date
            )
        )

        emergency_score = (
            FinancialHealthService.calculate_emergency_fund(
                user_id=user_id,
                start_date=start_date,
                end_date=end_date
            )
        )

        investment_score = (
            FinancialHealthService.calculate_investment_score(
                user_id=user_id,
                start_date=start_date,
                end_date=end_date
            )
        )

        fun_fund_score = (
            FinancialHealthService.calculate_fun_fund_score(
                user_id=user_id
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
                "savings": round(savings_score, 2),
                "budget": round(budget_score, 2),
                "goals": round(goal_score, 2),
                "income": round(income_score, 2),
                "expense": round(expense_score, 2),
                "emergency": round(emergency_score, 2),
                "investment": round(investment_score, 2),
                "fun_fund": round(fun_fund_score, 2)
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

        # --------------------------------------------------------
        # Check whether the user had financial activity
        # during the previous month.
        # --------------------------------------------------------

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
                func.coalesce(
                    func.sum(Income.amount),
                    0
                )
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
                func.coalesce(
                    func.sum(Expense.amount),
                    0
                )
            )
            .filter(
                Expense.user_id == user_id,
                Expense.date >= start_date,
                Expense.date < end_date
            )
            .scalar()
        )

        monthly_budget = (
            db.session.query(
                func.coalesce(
                    func.sum(Budget.amount),
                    0
                )
            )
            .filter(
                Budget.user_id == user_id,
                Budget.month == start_date.month,
                Budget.year == start_date.year
            )
            .scalar()
        )

        return {
            "total_income": float(total_income or 0),
            "total_expense": float(total_expense or 0),
            "net_savings": float(
                (total_income or 0) -
                (total_expense or 0)
            ),
            "monthly_budget": float(
                monthly_budget or 0
            )
        }

    # ============================================================
    # SAVINGS HABIT
    # MAXIMUM: 20
    # ============================================================

    @staticmethod
    def calculate_savings_score(dashboard):

        income = dashboard["total_income"]
        expense = dashboard["total_expense"]

        max_score = FINANCIAL_HEALTH_WEIGHTS[
            "savings_habit"
        ]

        if income <= 0:
            return 0

        savings_rate = (
            (income - expense) / income
        ) * 100

        if savings_rate >= 40:
            return max_score

        elif savings_rate >= 30:
            return max_score * 0.90

        elif savings_rate >= 20:
            return max_score * 0.75

        elif savings_rate >= 10:
            return max_score * 0.50

        return max_score * 0.20

    # ============================================================
    # BUDGET DISCIPLINE
    # MAXIMUM: 15
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

        # Previous-month calculation:
        # only consider that month's budgets.
        if start_date is not None:
            query = query.filter(
                Budget.month == start_date.month,
                Budget.year == start_date.year
            )

        budgets = query.all()

        if not budgets:
            return 0

        total_budget = sum(
            float(budget.amount)
            for budget in budgets
        )

        if total_budget <= 0:
            return 0

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
            float(expense.amount)
            for expense in expenses
        )

        usage = (
            total_expense / total_budget
        ) * 100

        max_score = FINANCIAL_HEALTH_WEIGHTS[
            "budget_discipline"
        ]

        if usage <= 90:
            return max_score

        elif usage <= 100:
            return max_score * 0.80

        elif usage <= 110:
            return max_score * 0.50

        return max_score * 0.20

    # ============================================================
    # GOAL PROGRESS
    # MAXIMUM: 20
    # ============================================================

    @staticmethod
    def calculate_goal_score(user_id):

        goals = Goal.query.filter_by(
            user_id=user_id
        ).all()

        if not goals:
            return 0

        total_progress = 0
        valid_goals = 0

        for goal in goals:

            target = float(goal.target_amount)

            if target <= 0:
                continue

            # Goal.current_amount is synchronized by GoalService
            # with the MoneyAllocation Goal bucket.
            current = float(goal.current_amount)

            progress = current / target

            total_progress += min(progress, 1.0)
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
    # MAXIMUM: 10
    # ============================================================
    #
    # IMPORTANT:
    # Stability is measured using monthly income totals,
    # not individual income transaction amounts.
    #
    # This prevents:
    #
    # ₹10,000 + ₹5,000
    #
    # from being interpreted as unstable simply because
    # the user received money in multiple transactions.
    #
    # ------------------------------------------------------------

    @staticmethod
    def calculate_income_stability(
        user_id,
        start_date=None,
        end_date=None
    ):

        query = db.session.query(
            func.extract("year", Income.date).label("year"),
            func.extract("month", Income.date).label("month"),
            func.sum(Income.amount).label("total")
        ).filter(
            Income.user_id == user_id
        )

        if start_date is not None:
            query = query.filter(
                Income.date >= start_date,
                Income.date < end_date
            )

        monthly_income = (
            query
            .group_by(
                func.extract("year", Income.date),
                func.extract("month", Income.date)
            )
            .order_by(
                func.extract("year", Income.date),
                func.extract("month", Income.date)
            )
            .all()
        )

        max_score = FINANCIAL_HEALTH_WEIGHTS[
            "income_stability"
        ]

        # With fewer than two months there is not enough
        # historical information to measure variation.
        # Give neutral half-credit.
        if len(monthly_income) < 2:
            return max_score * 0.50

        amounts = [
            float(month[2])
            for month in monthly_income
        ]

        average = (
            sum(amounts) / len(amounts)
        )

        if average <= 0:
            return 0

        variation = (
            (max(amounts) - min(amounts))
            / average
        )

        if variation <= 0.10:
            return max_score

        elif variation <= 0.25:
            return max_score * 0.80

        elif variation <= 0.50:
            return max_score * 0.60

        return max_score * 0.30

    # ============================================================
    # EXPENSE STABILITY
    # MAXIMUM: 10
    # ============================================================
    #
    # Stability is measured using monthly expense totals,
    # not individual expense transaction amounts.
    #
    # ------------------------------------------------------------

    @staticmethod
    def calculate_expense_stability(
        user_id,
        start_date=None,
        end_date=None
    ):

        query = db.session.query(
            func.extract("year", Expense.date).label("year"),
            func.extract("month", Expense.date).label("month"),
            func.sum(Expense.amount).label("total")
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
            .order_by(
                func.extract("year", Expense.date),
                func.extract("month", Expense.date)
            )
            .all()
        )

        max_score = FINANCIAL_HEALTH_WEIGHTS[
            "expense_stability"
        ]

        # Not enough historical information to measure
        # month-to-month variation.
        if len(monthly_expenses) < 2:
            return max_score * 0.50

        amounts = [
            float(month[2])
            for month in monthly_expenses
        ]

        average = (
            sum(amounts) / len(amounts)
        )

        if average <= 0:
            return 0

        variation = (
            (max(amounts) - min(amounts))
            / average
        )

        if variation <= 0.10:
            return max_score

        elif variation <= 0.25:
            return max_score * 0.80

        elif variation <= 0.50:
            return max_score * 0.60

        return max_score * 0.30

    # ============================================================
    # EMERGENCY FUND
    # MAXIMUM: 10
    # ============================================================
    #
    # Emergency is a cumulative controlled-money bucket.
    #
    # Actual emergency balance comes directly from:
    #
    # MoneyAllocation
    #
    # Emergency coverage:
    #
    # emergency balance
    # -----------------
    # average monthly expenses
    #
    # ------------------------------------------------------------

    @staticmethod
    def calculate_emergency_fund(
        user_id,
        start_date=None,
        end_date=None
    ):

        query = db.session.query(
            func.extract(
                "year",
                Expense.date
            ),
            func.extract(
                "month",
                Expense.date
            ),
            func.sum(
                Expense.amount
            )
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
                func.extract(
                    "year",
                    Expense.date
                ),
                func.extract(
                    "month",
                    Expense.date
                )
            )
            .all()
        )

        if not monthly_expenses:
            return 0

        average_monthly_expense = (
            sum(
                float(month[2])
                for month in monthly_expenses
            )
            /
            len(monthly_expenses)
        )

        if average_monthly_expense <= 0:
            return 0

        # IMPORTANT:
        # Emergency is not stored in an Emergency model.
        # It is the cumulative Emergency MoneyAllocation bucket.
        emergency_balance = (
            MoneyService.get_bucket_balance(
                MoneyService.EMERGENCY,
                user_id=user_id
            )
        )

        months_covered = (
            float(emergency_balance)
            /
            average_monthly_expense
        )

        max_score = FINANCIAL_HEALTH_WEIGHTS[
            "emergency_fund"
        ]

        if months_covered >= 6:
            return max_score

        elif months_covered >= 3:
            return max_score * 0.80

        elif months_covered >= 1:
            return max_score * 0.50

        return max_score * 0.20

    # ============================================================
    # INVESTMENT HABIT
    # MAXIMUM: 10
    # ============================================================
    #
    # This measures investment activity/habit by the number
    # of investment records.
    #
    # It does NOT measure investment wealth.
    #
    # ------------------------------------------------------------

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
            return max_score * 0.80

        return max_score * 0.50

    # ============================================================
    # FUN FUND
    # MAXIMUM: 5
    # ============================================================

    @staticmethod
    def calculate_fun_fund_score(user_id):

        funds = FunFund.query.filter_by(
            user_id=user_id
        ).all()

        if not funds:
            return 0

        total_progress = 0
        valid_funds = 0

        for fund in funds:

            target = float(
                fund.target_amount
            )

            if target <= 0:
                continue

            # current_amount is synchronized with the
            # actual Fun Fund MoneyAllocation bucket.
            current = float(
                fund.current_amount
            )

            progress = current / target

            total_progress += min(
                progress,
                1.0
            )

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