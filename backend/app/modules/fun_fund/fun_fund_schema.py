from marshmallow import Schema, fields, validate


class FunFundSchema(Schema):

    title = fields.String(required=True)

    target_amount = fields.Decimal(
    required=True,
    as_string=True,
    validate=validate.Range(
        min=0,
        min_inclusive=False,
        error="Target amount must be greater than 0."
    )
)

    current_amount = fields.Decimal(
    required=False,
    as_string=True,
    validate=validate.Range(
        min=0,
        min_inclusive=True,
        error="Current amount cannot be negative."
    )
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