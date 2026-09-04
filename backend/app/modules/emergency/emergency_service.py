from decimal import Decimal

from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.modules.money.money_service import MoneyService


class EmergencyService:

    @staticmethod
    def _user_id():
        return int(get_jwt_identity())

    @staticmethod
    def _decimal(value):
        return Decimal(str(value))

    # ============================================================
    # GET EMERGENCY FUND
    # ============================================================

    @staticmethod
    def get_emergency_balance():
        user_id = EmergencyService._user_id()

        balance = MoneyService.get_bucket_balance(
            MoneyService.EMERGENCY,
            user_id=user_id
        )

        return balance

    # ============================================================
    # ADD MONEY TO EMERGENCY FUND
    # ============================================================
    #
    # General -> Emergency
    #
    # This is an INTERNAL relocation.
    # It does NOT create money.
    # It does NOT create an Expense.
    # ============================================================

    @staticmethod
    def add_money(amount, description=None):
        user_id = EmergencyService._user_id()

        amount = EmergencyService._decimal(amount)

        if amount <= 0:
            raise ValueError(
                "Emergency fund amount must be greater than zero."
            )

        try:
            MoneyService.allocate(
                destination_type=MoneyService.EMERGENCY,
                amount=amount,
                destination_id=None,
                description=description or "Added to emergency fund",
                reference_type="emergency"
            )

            db.session.commit()

        except Exception:
            db.session.rollback()
            raise

        return EmergencyService.get_emergency_balance()

    # ============================================================
    # USE / RELEASE EMERGENCY MONEY
    # ============================================================
    #
    # Emergency -> General
    #
    # This returns controlled money to General.
    # It is NOT an Expense.
    # ============================================================

    @staticmethod
    def release_money(amount, description=None):
        user_id = EmergencyService._user_id()

        amount = EmergencyService._decimal(amount)

        if amount <= 0:
            raise ValueError(
                "Emergency fund amount must be greater than zero."
            )

        try:
            MoneyService.release(
                source_type=MoneyService.EMERGENCY,
                amount=amount,
                source_id=None,
                destination_type=MoneyService.GENERAL,
                destination_id=None,
                description=description or "Emergency fund money released"
            )

            db.session.commit()

        except Exception:
            db.session.rollback()
            raise

        return EmergencyService.get_emergency_balance()