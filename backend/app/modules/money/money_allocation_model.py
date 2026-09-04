from app.extensions import db
from app.models.base_model import BaseModel


class MoneyAllocation(BaseModel):
    """
    Records every internal movement or controlled-money adjustment.

    IMPORTANT:
    This table does NOT represent new money.

    Income creates controlled money.
    Expense removes controlled money.

    This table only records where controlled money is allocated
    or how an allocation changes.
    """

    __tablename__ = "money_allocations"

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id"),
        nullable=False
    )

    # ------------------------------------------------------------
    # BUCKET
    # ------------------------------------------------------------
    # general
    # goal
    # emergency
    # budget
    # fun_fund
    #
    # This identifies the area whose balance changes.
    # ------------------------------------------------------------

    bucket_type = db.Column(
        db.String(30),
        nullable=False
    )

    # ID of the related bucket object.
    #
    # goal      -> goals.id
    # budget    -> budgets.id
    # fun_fund  -> fun_funds.id
    #
    # general/emergency -> NULL
    #
    # We intentionally do NOT use foreign keys here because one
    # column needs to reference different entity tables.
    # Validation is handled by MoneyService.
    # ------------------------------------------------------------

    bucket_id = db.Column(
        db.Integer,
        nullable=True
    )

    # ------------------------------------------------------------
    # AMOUNT
    # ------------------------------------------------------------
    #
    # Positive = money enters this allocation.
    # Negative = money leaves this allocation.
    #
    # Example:
    #
    # General -> Goal ₹3,000
    #
    # General allocation:
    #   -3000
    #
    # Goal allocation:
    #   +3000
    #
    # Total controlled money remains unchanged.
    # ------------------------------------------------------------

    amount = db.Column(
        db.Numeric(12, 2),
        nullable=False
    )

    # ------------------------------------------------------------
    # ENTRY TYPE
    # ------------------------------------------------------------
    #
    # allocation
    # release
    # expense
    # income
    # adjustment
    # ------------------------------------------------------------

    entry_type = db.Column(
        db.String(30),
        nullable=False
    )

    # ------------------------------------------------------------
    # REFERENCE
    # ------------------------------------------------------------
    #
    # These are audit references only.
    #
    # Examples:
    #
    # reference_type = "goal"
    # reference_id   = 12
    #
    # reference_type = "expense"
    # reference_id   = 45
    #
    # This does NOT make Expense a child of a bucket.
    # It simply tells us which financial event caused this
    # ledger entry.
    # ------------------------------------------------------------

    reference_type = db.Column(
        db.String(30),
        nullable=True
    )

    reference_id = db.Column(
        db.Integer,
        nullable=True
    )

    description = db.Column(
        db.Text,
        nullable=True
    )

    user = db.relationship(
        "User",
        backref=db.backref(
            "money_allocations",
            lazy=True,
            cascade="all, delete-orphan"
        )
    )

    def __repr__(self):
        return (
            f"<MoneyAllocation "
            f"{self.bucket_type}:{self.bucket_id} "
            f"{self.amount}>"
        )