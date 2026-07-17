from collections import defaultdict

from flask_jwt_extended import get_jwt_identity

from app.modules.expense.expense_model import Expense


class SpendingAnalysisService:

    @staticmethod
    def analyze():

        expenses = Expense.query.filter_by(
            user_id=get_jwt_identity()
        ).all()

        if not expenses:
            return {
                "message": "No expenses found."
            }

        category_totals = defaultdict(float)

        total_spent = 0

        for expense in expenses:

            amount = float(expense.amount)

            category_totals[
                expense.category
            ] += amount

            total_spent += amount

        return SpendingAnalysisService.build_analysis(
            category_totals,
            total_spent
        )
    @staticmethod
    def build_analysis(
        category_totals,
        total_spent
    ):

        highest_category = max(
            category_totals,
            key=category_totals.get
        )

        category_percentages = {}

        for category, amount in category_totals.items():

            category_percentages[category] = round(
                (amount / total_spent) * 100,
                1
            )

        return {

            "total_spent": round(
                total_spent,
                2
            ),

            "highest_category": highest_category,

            "highest_amount": round(
                category_totals[
                    highest_category
                ],
                2
            ),

            "category_breakdown": category_percentages
        }