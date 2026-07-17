from datetime import date

from flask_jwt_extended import get_jwt_identity

from app.modules.goal.goal_model import Goal
from app.analytics.dashboard.dashboard_service import DashboardService
from app.common.exceptions import NotFoundException


class GoalReadinessService:

    @staticmethod
    def analyze(goal_id):

        goal = Goal.query.filter_by(
            id=goal_id,
            user_id=get_jwt_identity()
        ).first()

        if not goal:
            raise NotFoundException("Goal not found.")

        dashboard = DashboardService.get_dashboard_summary()

        today = date.today()

        remaining_amount = (
            float(goal.target_amount)
            - float(goal.current_amount)
        )

        days_remaining = (
            goal.target_date - today
        ).days

        months_remaining = max(days_remaining / 30, 1)

        required_monthly_saving = (
            remaining_amount / months_remaining
        )

        current_monthly_saving = max(
            dashboard["net_savings"],
            0
        )
        if current_monthly_saving >= required_monthly_saving:

            readiness = 100

            status = "On Track"

            recommendation = (
                "You're on track to achieve this goal."
            )

        else:

            readiness = (
                current_monthly_saving
                /
                required_monthly_saving
            ) * 100

            status = "Behind Schedule"

            shortage = (
                required_monthly_saving
                - current_monthly_saving
            )

            recommendation = (
                f"Increase monthly savings by ₹{shortage:.2f}"
            )
        
        return {
            "goal": goal.title,
            "target_amount": float(goal.target_amount),
            "current_amount": float(goal.current_amount),
            "remaining_amount": remaining_amount,
            "months_remaining": round(months_remaining, 1),
            "required_monthly_saving": round(
                required_monthly_saving,
                2
            ),
            "current_monthly_saving": round(
                current_monthly_saving,
                2
            )
        }
        