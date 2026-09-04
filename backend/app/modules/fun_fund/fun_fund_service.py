from decimal import Decimal

from flask_jwt_extended import get_jwt_identity

from app.extensions import db

from app.common.exceptions import (
    NotFoundException,
    ValidationException,
)

from app.modules.fun_fund.fun_fund_model import FunFund
from app.modules.budget.budget_model import Budget
from app.modules.money.money_service import MoneyService
from app.modules.money.money_allocation_model import MoneyAllocation


class FunFundService:

    # ============================================================
    # BASIC HELPERS
    # ============================================================

    @staticmethod
    def _decimal(value):
        return Decimal(str(value))

    @staticmethod
    def _get_budget(budget_id, user_id):

        budget = Budget.query.filter_by(
            id=budget_id,
            user_id=user_id
        ).first()

        if not budget:
            raise NotFoundException(
                "Budget not found."
            )

        return budget

    # ============================================================
    # CREATE FUN FUND
    # ============================================================

    @staticmethod
    def create(data):

        user_id = get_jwt_identity()

        budget = FunFundService._get_budget(
            data["budget_id"],
            user_id
        )

        target_amount = FunFundService._decimal(
            data["target_amount"]
        )

        if target_amount <= 0:
            raise ValidationException(
                "Fun Fund amount must be greater than zero."
            )

        # Check how much money is currently available
        # inside the parent Budget.
        budget_balance = MoneyService.get_bucket_balance(
            bucket_type=MoneyService.BUDGET,
            bucket_id=budget.id,
            user_id=user_id
        )

        if target_amount > budget_balance:
            raise ValidationException(
                "Insufficient Budget balance to create this Fun Fund."
            )

        fund = FunFund(
            user_id=user_id,
            budget_id=budget.id,
            title=data["title"],
            target_amount=target_amount,
            current_amount=Decimal("0.00"),
            target_date=data.get("target_date"),
            status="Active",
            notes=data.get("notes")
        )

        db.session.add(fund)

        # Generate Fun Fund ID before creating
        # the ledger destination entry.
        db.session.flush()

        # --------------------------------------------------------
        # Budget → Fun Fund
        # --------------------------------------------------------

        MoneyService.release(
            source_type=MoneyService.BUDGET,
            source_id=budget.id,
            amount=target_amount,
            destination_type=MoneyService.FUN_FUND,
            destination_id=fund.id,
            reference_type="fun_fund",
            reference_id=fund.id,
            description=(
                f"Allocation to Fun Fund: {fund.title}"
            )
        )

        # current_amount represents the current amount
        # actually held by this Fun Fund.
        fund.current_amount = MoneyService.get_bucket_balance(
            bucket_type=MoneyService.FUN_FUND,
            bucket_id=fund.id,
            user_id=user_id
        )

        db.session.commit()

        return fund

    # ============================================================
    # GET ALL FUN FUNDS
    # ============================================================

    @staticmethod
    def get_all():

        user_id = get_jwt_identity()

        funds = FunFund.query.filter_by(
            user_id=user_id
        ).order_by(
            FunFund.created_at.desc()
        ).all()

        # Keep current_amount synchronized with the ledger.
        for fund in funds:

            fund.current_amount = (
                MoneyService.get_bucket_balance(
                    bucket_type=MoneyService.FUN_FUND,
                    bucket_id=fund.id,
                    user_id=user_id
                )
            )

        return funds

    # ============================================================
    # GET ONE FUN FUND
    # ============================================================

    @staticmethod
    def get_by_id(fun_fund_id):

        user_id = get_jwt_identity()

        fund = FunFund.query.filter_by(
            id=fun_fund_id,
            user_id=user_id
        ).first()

        if not fund:
            raise NotFoundException(
                "Fun Fund not found."
            )

        # Synchronize displayed balance with ledger.
        fund.current_amount = (
            MoneyService.get_bucket_balance(
                bucket_type=MoneyService.FUN_FUND,
                bucket_id=fund.id,
                user_id=user_id
            )
        )

        return fund

    # ============================================================
    # UPDATE FUN FUND
    # ============================================================

    @staticmethod
    def update(fun_fund_id, data):

        user_id = get_jwt_identity()

        fund = FunFundService.get_by_id(
            fun_fund_id
        )

        old_target = FunFundService._decimal(
            fund.target_amount
        )

        new_target = FunFundService._decimal(
            data.get(
                "target_amount",
                old_target
            )
        )

        if new_target <= 0:
            raise ValidationException(
                "Fun Fund amount must be greater than zero."
            )

        current_balance = MoneyService.get_bucket_balance(
            bucket_type=MoneyService.FUN_FUND,
            bucket_id=fund.id,
            user_id=user_id
        )

        # --------------------------------------------------------
        # Increase target
        # --------------------------------------------------------

        if new_target > old_target:

            difference = new_target - old_target

            budget_balance = MoneyService.get_bucket_balance(
                bucket_type=MoneyService.BUDGET,
                bucket_id=fund.budget_id,
                user_id=user_id
            )

            if difference > budget_balance:

                raise ValidationException(
                    "Insufficient Budget balance to increase "
                    "this Fun Fund."
                )

            MoneyService.release(
                source_type=MoneyService.BUDGET,
                source_id=fund.budget_id,
                amount=difference,
                destination_type=MoneyService.FUN_FUND,
                destination_id=fund.id,
                reference_type="fun_fund",
                reference_id=fund.id,
                description="Fun Fund increased."
            )

        # --------------------------------------------------------
        # Decrease target
        # --------------------------------------------------------

        elif new_target < old_target:

            difference = old_target - new_target

            # We can only release money that is still
            # physically available inside the Fun Fund.
            if difference > current_balance:

                raise ValidationException(
                    "Fun Fund cannot be reduced because "
                    "part of its allocated money has already "
                    "been spent."
                )

            MoneyService.release(
                source_type=MoneyService.FUN_FUND,
                source_id=fund.id,
                amount=difference,
                destination_type=MoneyService.BUDGET,
                destination_id=fund.budget_id,
                reference_type="fun_fund",
                reference_id=fund.id,
                description="Fun Fund reduced."
            )

        # --------------------------------------------------------
        # Update normal fields
        # --------------------------------------------------------

        if "title" in data:
            fund.title = data["title"]

        if "target_date" in data:
            fund.target_date = data["target_date"]

        if "notes" in data:
            fund.notes = data["notes"]

        fund.target_amount = new_target

        # Recalculate actual balance from the ledger.
        fund.current_amount = (
            MoneyService.get_bucket_balance(
                bucket_type=MoneyService.FUN_FUND,
                bucket_id=fund.id,
                user_id=user_id
            )
        )

        # Status remains backend controlled.
        #
        # Reaching the target does NOT mean the money
        # has been spent. It simply means the allocation
        # is complete.
        fund.status = "Active"

        db.session.commit()

        return fund

    # ============================================================
    # DELETE FUN FUND
    # ============================================================

    @staticmethod
    def delete(fun_fund_id):

        user_id = get_jwt_identity()

        fund = FunFundService.get_by_id(
            fun_fund_id
        )

        # --------------------------------------------------------
        # Do not delete a Fun Fund with spending history.
        # --------------------------------------------------------

        historical_spending = MoneyAllocation.query.filter_by(
            user_id=user_id,
            bucket_type=MoneyService.FUN_FUND,
            bucket_id=fund.id,
            entry_type=MoneyService.EXPENSE
        ).first()

        if historical_spending:

            raise ValidationException(
                "This Fun Fund has spending history "
                "and cannot be deleted."
            )

        # --------------------------------------------------------
        # Return remaining money to parent Budget.
        # --------------------------------------------------------

        current_balance = MoneyService.get_bucket_balance(
            bucket_type=MoneyService.FUN_FUND,
            bucket_id=fund.id,
            user_id=user_id
        )

        if current_balance > 0:

            MoneyService.release(
                source_type=MoneyService.FUN_FUND,
                source_id=fund.id,
                amount=current_balance,
                destination_type=MoneyService.BUDGET,
                destination_id=fund.budget_id,
                reference_type="fun_fund",
                reference_id=fund.id,
                description=(
                    f"Remaining money returned from "
                    f"deleted Fun Fund: {fund.title}"
                )
            )

        db.session.delete(fund)

        db.session.commit()