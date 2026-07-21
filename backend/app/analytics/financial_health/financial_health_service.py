from flask_jwt_extended import get_jwt_identity
from app.modules.investment.investment_model import Investment
from sqlalchemy import func
from app.extensions import db
from app.modules.fun_fund.fun_fund_model import FunFund
from app.analytics.dashboard.dashboard_service import DashboardService
from app.modules.goal.goal_model import Goal
from app.modules.income.income_model import Income
from app.modules.expense.expense_model import Expense
from app.modules.budget.budget_model import Budget
from app.common.constants import FINANCIAL_HEALTH_WEIGHTS


class FinancialHealthService:

    @staticmethod
    def calculate_score():

        user_id = get_jwt_identity()

        dashboard = DashboardService.get_dashboard_summary()

        savings_score = FinancialHealthService.calculate_savings_score(
            dashboard
        )

        budget_score = FinancialHealthService.calculate_budget_score(
            user_id
        )

        goal_score = FinancialHealthService.calculate_goal_score(
            user_id
        )

        income_score = FinancialHealthService.calculate_income_stability(
            user_id
        )

        expense_score = FinancialHealthService.calculate_expense_stability(
            user_id
        )

        emergency_score = FinancialHealthService.calculate_emergency_fund(
            dashboard
        )

        investment_score = (
        FinancialHealthService.calculate_investment_score(
            user_id
        )
    )

        fun_fund_score = (
        FinancialHealthService.calculate_fun_fund_score(
            user_id
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
        
    
    @staticmethod
    def calculate_savings_score(dashboard):
        
        income = dashboard["total_income"]
        expense = dashboard["total_expense"]

        if income <= 0:
            return 0

        savings_rate = ((income - expense) / income) * 100

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

    @staticmethod
    def calculate_budget_score(user_id):
        budgets = Budget.query.filter_by(
            user_id=user_id
        ).all()

        if not budgets:
            return 0

        total_budget = sum(float(b.amount) for b in budgets)

        expenses = Expense.query.filter_by(
            user_id=user_id
        ).all()

        total_expense = sum(float(e.amount) for e in expenses)

        if total_budget <= 0:
            return 0

        usage = (total_expense / total_budget) * 100

        max_score = FINANCIAL_HEALTH_WEIGHTS["budget_discipline"]

        if usage <= 90:
            return max_score

        elif usage <= 100:
            return max_score * 0.8

        elif usage <= 110:
            return max_score * 0.5

        return max_score * 0.2

    @staticmethod
    def calculate_goal_score(user_id):
        goals = Goal.query.filter_by(
            user_id=user_id
        ).all()

        if not goals:
            return 0

        total_progress = 0

        for goal in goals:

            if goal.target_amount > 0:

                progress = (
                    float(goal.current_amount)
                    /
                    float(goal.target_amount)
                )

                total_progress += min(progress, 1)

        average_progress = total_progress / len(goals)

        return (
            average_progress
            *
            FINANCIAL_HEALTH_WEIGHTS["goal_progress"]
        )

    @staticmethod
    def calculate_income_stability(user_id):
        incomes = (
        Income.query
        .filter_by(user_id=user_id)
        .order_by(Income.date.asc())
        .all()
    )

        if len(incomes) < 2:
            return 5

        amounts = [float(i.amount) for i in incomes]

        average = sum(amounts) / len(amounts)

        if average == 0:
            return 0

        variation = (
            max(amounts) - min(amounts)
        ) / average

        max_score = FINANCIAL_HEALTH_WEIGHTS["income_stability"]

        if variation <= 0.10:
            return max_score

        elif variation <= 0.25:
            return max_score * 0.8

        elif variation <= 0.50:
            return max_score * 0.6

        return max_score * 0.3

    @staticmethod
    def calculate_expense_stability(user_id):
        expenses = (
        Expense.query
        .filter_by(user_id=user_id)
        .order_by(Expense.date.asc())
        .all()
        )

        if len(expenses) < 2:
            return 5

        amounts = [float(e.amount) for e in expenses]

        average = sum(amounts) / len(amounts)

        if average == 0:
            return 0

        variation = (
            max(amounts) - min(amounts)
        ) / average

        max_score = FINANCIAL_HEALTH_WEIGHTS["expense_stability"]

        if variation <= 0.10:
            return max_score

        elif variation <= 0.25:
            return max_score * 0.8

        elif variation <= 0.50:
            return max_score * 0.6

        return max_score * 0.3

    @staticmethod
    def calculate_emergency_fund(dashboard):

        user_id = get_jwt_identity()

        savings = dashboard["net_savings"]

        monthly_expenses = (
            db.session.query(
                func.extract("year", Expense.date),
                func.extract("month", Expense.date),
                func.sum(Expense.amount)
            )
            .filter(
                Expense.user_id == user_id
            )
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

        months = savings / average_monthly_expense

        max_score = FINANCIAL_HEALTH_WEIGHTS["emergency_fund"]

        if months >= 6:
            return max_score

        elif months >= 3:
            return max_score * 0.8

        elif months >= 1:
            return max_score * 0.5

        return max_score * 0.2
    
    @staticmethod
    def calculate_investment_score(user_id):

        investments = Investment.query.filter_by(
            user_id=user_id
        ).all()

        if not investments:
            return 0

        count = len(investments)

        max_score = FINANCIAL_HEALTH_WEIGHTS["investment_habit"]

        if count >= 4:
            return max_score

        elif count >= 2:
            return max_score * 0.8

        return max_score * 0.5

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

        average_progress = total_progress / valid_funds

        return (
            average_progress
            *
            FINANCIAL_HEALTH_WEIGHTS["fun_fund"]
        )
    