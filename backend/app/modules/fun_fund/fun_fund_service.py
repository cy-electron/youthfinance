from decimal import Decimal
from datetime import date

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
from app.modules.expense.expense_model import Expense


class FunFundService:

    # ============================================================
    # FUN FUND RULES
    # ============================================================

    # Maximum number of active Fun Funds per user.
    MAX_ACTIVE_FUNDS = 2

    # A maximum of 50% of a Budget can be allocated
    # to Fun Funds.
    MAX_BUDGET_PERCENT = Decimal("0.50")

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
            user_id=user_id,
        ).first()

        if not budget:
            raise NotFoundException(
                "Budget not found."
            )

        return budget

    @staticmethod
    def _validate_current_month_budget(budget):
        """
        Fun Funds can only be created from the
        current month's Budget.
        """

        today = date.today()

        if (
            budget.month != today.month
            or budget.year != today.year
        ):
            raise ValidationException(
                "Fun Funds can only be created from "
                "the current month's Budget."
            )

    @staticmethod
    def _get_active_fund_count(user_id):
        return FunFund.query.filter_by(
            user_id=user_id,
            status="Active",
        ).count()

    @staticmethod
    def _get_budget_fun_fund_allocation(
        budget_id,
        user_id,
    ):
        """
        Returns actual money currently allocated
        from this Budget into its Fun Funds.
        """

        funds = FunFund.query.filter_by(
            user_id=user_id,
            budget_id=budget_id,
        ).all()

        total = Decimal("0.00")

        for fund in funds:
            balance = MoneyService.get_bucket_balance(
                bucket_type=MoneyService.FUN_FUND,
                bucket_id=fund.id,
                user_id=user_id,
            )

            total += FunFundService._decimal(balance)

        return total

    @staticmethod
    def _get_max_fun_fund_allocation(budget):
        return (
            FunFundService._decimal(budget.amount)
            * FunFundService.MAX_BUDGET_PERCENT
        )

    @staticmethod
    def _validate_fun_fund_budget_limit(
        budget,
        user_id,
        additional_amount,
        excluded_fund_id=None,
    ):
        """
        Ensures that total actual money allocated
        to Fun Funds from this Budget does not exceed 50%.
        """

        funds = FunFund.query.filter_by(
            user_id=user_id,
            budget_id=budget.id,
        ).all()

        current_fun_fund_allocation = Decimal("0.00")

        for fund in funds:

            if (
                excluded_fund_id is not None
                and fund.id == excluded_fund_id
            ):
                continue

            balance = MoneyService.get_bucket_balance(
                bucket_type=MoneyService.FUN_FUND,
                bucket_id=fund.id,
                user_id=user_id,
            )

            current_fun_fund_allocation += (
                FunFundService._decimal(balance)
            )

        maximum_allocation = (
            FunFundService._get_max_fun_fund_allocation(
                budget
            )
        )

        proposed_allocation = (
            current_fun_fund_allocation
            + FunFundService._decimal(additional_amount)
        )

        if proposed_allocation > maximum_allocation:
            raise ValidationException(
                "Fun Funds can use at most 50% "
                "of the current month's Budget."
            )

    # ============================================================
    # CREATE FUN FUND
    # ============================================================

    @staticmethod
    def create(data):

        user_id = get_jwt_identity()

        budget = FunFundService._get_budget(
            data["budget_id"],
            user_id,
        )

        FunFundService._validate_current_month_budget(
            budget
        )

        active_count = FunFundService._get_active_fund_count(
            user_id
        )

        if active_count >= FunFundService.MAX_ACTIVE_FUNDS:
            raise ValidationException(
                "You can have a maximum of 2 active "
                "Fun Funds."
            )

        target_amount = FunFundService._decimal(
            data["target_amount"]
        )

        if target_amount <= 0:
            raise ValidationException(
                "Fun Fund amount must be greater than zero."
            )

        FunFundService._validate_fun_fund_budget_limit(
            budget=budget,
            user_id=user_id,
            additional_amount=target_amount,
        )

        budget_balance = MoneyService.get_bucket_balance(
            bucket_type=MoneyService.BUDGET,
            bucket_id=budget.id,
            user_id=user_id,
        )

        budget_balance = FunFundService._decimal(
            budget_balance
        )

        if target_amount > budget_balance:
            raise ValidationException(
                "Insufficient Budget balance to create "
                "this Fun Fund."
            )

        fund = FunFund(
            user_id=user_id,
            budget_id=budget.id,
            title=data["title"],
            target_amount=target_amount,
            current_amount=Decimal("0.00"),
            target_date=data.get("target_date"),
            status="Active",
            notes=data.get("notes"),
        )

        db.session.add(fund)

        db.session.flush()

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
            ),
        )

        fund.current_amount = (
            MoneyService.get_bucket_balance(
                bucket_type=MoneyService.FUN_FUND,
                bucket_id=fund.id,
                user_id=user_id,
            )
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
            user_id=user_id,
        ).order_by(
            FunFund.created_at.desc()
        ).all()

        for fund in funds:

            fund.current_amount = (
                MoneyService.get_bucket_balance(
                    bucket_type=MoneyService.FUN_FUND,
                    bucket_id=fund.id,
                    user_id=user_id,
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
            user_id=user_id,
        ).first()

        if not fund:
            raise NotFoundException(
                "Fun Fund not found."
            )

        fund.current_amount = (
            MoneyService.get_bucket_balance(
                bucket_type=MoneyService.FUN_FUND,
                bucket_id=fund.id,
                user_id=user_id,
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
                old_target,
            )
        )

        if new_target <= 0:
            raise ValidationException(
                "Fun Fund amount must be greater than zero."
            )

        current_balance = MoneyService.get_bucket_balance(
            bucket_type=MoneyService.FUN_FUND,
            bucket_id=fund.id,
            user_id=user_id,
        )

        current_balance = FunFundService._decimal(
            current_balance
        )

        budget = FunFundService._get_budget(
            fund.budget_id,
            user_id,
        )

        # --------------------------------------------------------
        # Increase target
        # --------------------------------------------------------

        if new_target > old_target:

            difference = new_target - old_target

            FunFundService._validate_fun_fund_budget_limit(
                budget=budget,
                user_id=user_id,
                additional_amount=new_target,
                excluded_fund_id=fund.id,
            )

            budget_balance = MoneyService.get_bucket_balance(
                bucket_type=MoneyService.BUDGET,
                bucket_id=budget.id,
                user_id=user_id,
            )

            budget_balance = FunFundService._decimal(
                budget_balance
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
                description="Fun Fund increased.",
            )

        # --------------------------------------------------------
        # Decrease target
        # --------------------------------------------------------

        elif new_target < old_target:

            difference = old_target - new_target

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
                description="Fun Fund reduced.",
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
        fund.status = "Active"

        fund.current_amount = (
            MoneyService.get_bucket_balance(
                bucket_type=MoneyService.FUN_FUND,
                bucket_id=fund.id,
                user_id=user_id,
            )
        )

        db.session.commit()

        return fund

    # ============================================================
    # CANCEL FUN FUND
    # ============================================================

    @staticmethod
    def delete(fun_fund_id):

        user_id = get_jwt_identity()

        fund = FunFundService.get_by_id(
            fun_fund_id
        )

        # A Fun Fund with spending history cannot be cancelled.
        historical_spending = MoneyAllocation.query.filter_by(
            user_id=user_id,
            bucket_type=MoneyService.FUN_FUND,
            bucket_id=fund.id,
            entry_type=MoneyService.EXPENSE,
        ).first()

        if historical_spending:
            raise ValidationException(
                "This Fun Fund has spending history "
                "and cannot be cancelled."
            )

        current_balance = MoneyService.get_bucket_balance(
            bucket_type=MoneyService.FUN_FUND,
            bucket_id=fund.id,
            user_id=user_id,
        )

        current_balance = FunFundService._decimal(
            current_balance
        )

        # --------------------------------------------------------
        # Fun Fund → Budget
        # --------------------------------------------------------

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
                    f"cancelled Fun Fund: {fund.title}"
                ),
            )

        db.session.delete(fund)

        db.session.commit()

        return True

    # ============================================================
    # FINISH FUN FUND
    # ============================================================

    @staticmethod
    def finish(fun_fund_id, data):

        user_id = get_jwt_identity()

        fund = FunFundService.get_by_id(
            fun_fund_id
        )

        # --------------------------------------------------------
        # Get actual remaining Fun Fund balance
        # --------------------------------------------------------

        current_balance = MoneyService.get_bucket_balance(
            bucket_type=MoneyService.FUN_FUND,
            bucket_id=fund.id,
            user_id=user_id,
        )

        current_balance = FunFundService._decimal(
            current_balance
        )

        if current_balance <= 0:
            raise ValidationException(
                "This Fun Fund has no remaining money to finish."
            )

        # --------------------------------------------------------
        # Expense details
        # --------------------------------------------------------

        category = data.get(
            "category",
            "Fun Fund",
        )

        expense_date = data.get(
            "date",
            date.today(),
        )

        description = data.get(
            "description"
        )

        # --------------------------------------------------------
        # Create Expense
        # --------------------------------------------------------

        expense = Expense(
            user_id=user_id,
            category=category,
            amount=current_balance,
            date=expense_date,
            description=description,
        )

        db.session.add(expense)

        # Generate Expense ID.
        db.session.flush()

        # --------------------------------------------------------
        # Fun Fund → Expense
        #
        # This removes the remaining money from
        # controlled money.
        # --------------------------------------------------------

        MoneyService.spend_money(
            amount=current_balance,
            source_type=MoneyService.FUN_FUND,
            source_id=fund.id,
            reference_type="expense",
            reference_id=expense.id,
            description=(
                f"Finished Fun Fund: {fund.title}"
            ),
        )

        # --------------------------------------------------------
        # Remove Fun Fund record
        #
        # MoneyAllocation keeps the historical ledger entry,
        # so the financial history remains intact even though
        # the Fun Fund itself no longer exists.
        # --------------------------------------------------------

        db.session.delete(fund)

        db.session.commit()

        return expense