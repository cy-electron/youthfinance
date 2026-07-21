from marshmallow import Schema, fields, validate
from app.common.custom_validators import positive_amount, non_negative_amount

class FunFundSchema(Schema):

    title = fields.String(required=True)

    target_amount = fields.Decimal(
    required=True,
    as_string=True,
    validate=positive_amount
)

    current_amount = fields.Decimal(
    required=False,
    as_string=True,
    validate=non_negative_amount
)

    target_date = fields.Date(
        required=False,
        allow_none=True
    )

    status = fields.String(
        required=False,
        validate=validate.OneOf([
            "Active",
            "Completed",
            "Cancelled"
        ])
    )

    notes = fields.String(
        required=False,
        allow_none=True
    )


fun_fund_schema = FunFundSchema()

fun_fund_update_schema = FunFundSchema(partial=True)