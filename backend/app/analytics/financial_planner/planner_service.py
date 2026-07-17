from datetime import date

from app.analytics.dashboard.dashboard_service import DashboardService

class FinancialPlannerService:

    @staticmethod
    def analyze(target_amount, target_date):

        dashboard = DashboardService.get_dashboard_summary()

        today = date.today()

        days_remaining = (target_date - today).days

        months_remaining = max(days_remaining / 30, 1)

        required_monthly_saving = (
            target_amount / months_remaining
        )

        current_monthly_saving = max(
            dashboard["net_savings"],
            0
        )

        if current_monthly_saving >= required_monthly_saving:

            affordability = "Affordable"

            preparedness = 100

            message = (
                "You're financially prepared."
            )

        else:

            preparedness = (
                current_monthly_saving
                / required_monthly_saving
            ) * 100

            affordability = "Needs Planning"

            shortage = (
                required_monthly_saving
                - current_monthly_saving
            )

            message = (
                f"You need ₹{shortage:.2f} more every month."
            )

        return {

            "target_amount": float(target_amount),

            "months_remaining": round(
                months_remaining,
                1
            ),

            "required_monthly_saving": round(
                required_monthly_saving,
                2
            ),

            "current_monthly_saving": round(
                current_monthly_saving,
                2
            ),

            "preparedness": round(
                min(preparedness, 100),
                1
            ),

            "affordability": affordability,

            "message": message
        }